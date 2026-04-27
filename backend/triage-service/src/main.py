import logging
import os
from dotenv import load_dotenv

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Try current dir, then parent dir
if not load_dotenv():
    load_dotenv(dotenv_path=os.path.join(os.path.dirname(__file__), "..", ".env"))

logger.info(f"GEMINI_API_KEY loaded: {'Yes' if os.getenv('GEMINI_API_KEY') else 'No'}")
logger.info(f"GOOGLE_API_KEY loaded: {'Yes' if os.getenv('GOOGLE_API_KEY') else 'No'}")

from fastapi import FastAPI, BackgroundTasks, HTTPException
from pydantic import BaseModel
import asyncio
from triage_engine import triage_signal
from firestore_sync import update_signal_triage
from listener import start_triage_listener
from typing import Optional, List

app = FastAPI(title="ResourceRadar Triage Service")

@app.on_event("startup")
async def startup_event():
    # Start the automated listener in the background
    asyncio.create_task(start_triage_listener())
    logger.info("Background triage listener started.")

class TriageRequest(BaseModel):
    signal_id: str
    text: str
    photo_url: Optional[str] = None

@app.get("/health")
async def health_check():
    return {"status": "ok"}

@app.post("/triage")
async def trigger_triage(request: TriageRequest, background_tasks: BackgroundTasks):
    """
    Manually trigger triage for a signal. 
    In production, this would be called by a Firestore Trigger (Cloud Function).
    """
    background_tasks.add_task(run_triage_flow, request.signal_id, request.text, request.photo_url)
    return {"message": "Triage started in background", "signal_id": request.signal_id}

async def run_triage_flow(signal_id: str, text: str, photo_url: Optional[str] = None):
    logger.info(f"Starting triage flow for {signal_id}")
    try:
        results = await triage_signal(text, photo_url)
        logger.info(f"Triage results for {signal_id}: {results}")
        await update_signal_triage(signal_id, results)
        logger.info(f"Successfully updated {signal_id} in Firestore")
    except Exception as e:
        logger.error(f"Triage flow failed for {signal_id}: {e}", exc_info=True)

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=int(os.getenv("PORT", 8000)))
