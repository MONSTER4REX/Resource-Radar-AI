import asyncio
import os
import httpx
from google.cloud import firestore
from triage_engine import triage_signal
from firestore_sync import update_signal_triage
import logging
from typing import Optional

logger = logging.getLogger(__name__)

async def start_triage_listener():
    """
    Listens for new signals in Firestore that have 'verification_status' == 'pending'
    and automatically triggers the Gemini triage flow.
    """
    db = firestore.AsyncClient()
    signals_ref = db.collection("need_signals")
    
    # Query for pending signals
    query = signals_ref.where("verification_status", "==", "pending")
    
    logger.info("Starting Firestore Triage Listener (Polling Mode)...")
    
    # Track processed signals to avoid redundant work in the same session
    processed_signals = set()

    while True:
        try:
            # Query for pending signals
            docs = await query.get()
            
            tasks = []
            for doc in docs:
                signal_id = doc.id
                if signal_id in processed_signals:
                    continue
                    
                data = doc.to_dict()
                text = data.get("notes", "")
                photo_url = data.get("photo_url")
                
                logger.info(f"Processing new pending signal: {signal_id}")
                # Add to set before processing to avoid race conditions with polling
                processed_signals.add(signal_id)
                tasks.append(asyncio.create_task(run_triage_and_update(signal_id, text, photo_url)))
            
            if tasks:
                await asyncio.gather(*tasks, return_exceptions=True)
                # After gather, if we want to clear them from memory or set to 'triaged' in DB
                # the run_triage_and_update logic handles the status update in Firestore.
            
            await asyncio.sleep(5) # Poll more frequently (5s) for responsive feel
        except Exception as e:
            logger.error(f"Listener error: {e}")
            await asyncio.sleep(10)

async def run_triage_and_update(signal_id: str, text: str, photo_url: Optional[str]):
    try:
        results = await triage_signal(text, photo_url)
        await update_signal_triage(signal_id, results)
        logger.info(f"Successfully triaged signal {signal_id}")
        
        # Trigger matching service
        matching_url = os.getenv("MATCHING_SERVICE_URL", "http://localhost:8001/match")
        async with httpx.AsyncClient() as client:
            try:
                await client.post(matching_url, json={"signal_id": signal_id})
                logger.info(f"Triggered matching for signal {signal_id}")
            except Exception as e:
                logger.error(f"Failed to trigger matching: {e}")
                
    except Exception as e:
        logger.error(f"Failed to triage signal {signal_id}: {e}")

if __name__ == "__main__":
    logging.basicConfig(level=logging.INFO)
    asyncio.run(start_triage_listener())
