from google.cloud import firestore
from datetime import datetime
from typing import Dict, Any

# Use AsyncClient for non-blocking Firestore operations
db = firestore.AsyncClient()

async def update_signal_triage(signal_id: str, triage_results: Dict[str, Any]):
    doc_ref = db.collection("need_signals").document(signal_id)
    
    update_data = {
        "urgency_score": triage_results["urgency_score"],
        "urgency_tier": triage_results["urgency_tier"],
        "photo_matches_claim": triage_results.get("photo_matches_claim"),
        "verification_status": triage_results["verification_status"],
        "gemini_reasoning": triage_results["gemini_reasoning"],
        "triaged_at": datetime.utcnow(),
        "status": "active" if triage_results["verification_status"] != "suspicious" else "needs_review"
    }
    
    await doc_ref.update(update_data)
    print(f"Signal {signal_id} updated with triage results.")
