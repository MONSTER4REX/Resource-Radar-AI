from google.cloud import firestore
from typing import Dict, Any, List, Optional

# Use AsyncClient for non-blocking Firestore operations
db = firestore.AsyncClient()

_SIGNALS_COLLECTION = "need_signals"
_VOLUNTEERS_COLLECTION = "volunteers"


async def get_signal(signal_id: str) -> Optional[Dict[str, Any]]:
    """Fetch a need signal from Firestore."""
    doc_ref = db.collection(_SIGNALS_COLLECTION).document(signal_id)
    doc = await doc_ref.get()
    if doc.exists:
        return doc.to_dict()
    return None


async def update_signal_matches(signal_id: str, volunteer_ids: List[str]) -> None:
    """Update a signal with its matched volunteer IDs."""
    doc_ref = db.collection(_SIGNALS_COLLECTION).document(signal_id)
    await doc_ref.update({
        "assigned_volunteers": volunteer_ids,
        "status": "assigned" if volunteer_ids else "active",
    })


async def get_volunteer_profiles(volunteer_ids: List[str]) -> List[Dict[str, Any]]:
    """Fetch volunteer profiles from Firestore."""
    profiles = []
    for vid in volunteer_ids:
        doc_ref = db.collection(_VOLUNTEERS_COLLECTION).document(vid)
        doc = await doc_ref.get()
        if doc.exists:
            data = doc.to_dict()
            data["volunteer_id"] = vid
            profiles.append(data)
    return profiles
