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
    
    logger.info("Starting Firestore Triage Listener...")
    
    # In a real production environment, we'd use a watch/snapshot listener.
    # For this service, we'll poll or use the watch API if supported by the client.
    # The python-firestore async client supports watch() starting in recent versions.
    
    def on_snapshot(col_snapshot, changes, read_time):
        for change in changes:
            if change.type.name == 'ADDED' or change.type.name == 'MODIFIED':
                doc = change.document
                data = doc.to_dict()
                if data.get("verification_status") == "pending":
                    signal_id = doc.id
                    text = data.get("notes", "")
                    photo_url = data.get("photo_url")
                    
                    logger.info(f"Detected new pending signal: {signal_id}")
                    # Schedule triage in the background
                    asyncio.create_task(run_triage_and_update(signal_id, text, photo_url))

    # Note: AsyncClient.collection(...).on_snapshot is not directly available in some 
    # versions of the library, so we'll use a polling loop for reliability in this demo.
    while True:
        try:
            docs = await query.get()
            for doc in docs:
                data = doc.to_dict()
                signal_id = doc.id
                text = data.get("notes", "")
                photo_url = data.get("photo_url")
                
                logger.info(f"Processing pending signal: {signal_id}")
                await run_triage_and_update(signal_id, text, photo_url)
                
            await asyncio.sleep(10) # Poll every 10 seconds
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
