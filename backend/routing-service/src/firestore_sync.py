from google.cloud import firestore
from typing import Dict, Any, List, Optional
from datetime import datetime

# Use AsyncClient for non-blocking Firestore operations
db = firestore.AsyncClient()

_SIGNALS = "need_signals"
_FLEET = "ngo_fleet"
_ROUTES = "optimized_routes"


async def get_active_signals(ngo_id: str) -> List[Dict[str, Any]]:
    """Fetch all active/assigned signals for an NGO."""
    query = (
        db.collection(_SIGNALS)
        .where("ngo_id", "==", ngo_id)
        .where("status", "in", ["active", "assigned"])
        .order_by("created_at", direction=firestore.Query.DESCENDING)
        .limit(100)
    )
    # query.stream() returns an AsyncIterator in AsyncClient
    return [doc.to_dict() async for doc in query.stream()]


async def get_fleet(ngo_id: str) -> List[Dict[str, Any]]:
    """Fetch the vehicle fleet for an NGO."""
    query = (
        db.collection(_FLEET)
        .where("ngo_id", "==", ngo_id)
        .where("is_available", "==", True)
    )
    return [doc.to_dict() async for doc in query.stream()]


async def save_routes(ngo_id: str, routes: List[Dict[str, Any]]) -> None:
    """Save optimized routes to Firestore and update signal statuses."""
    batch = db.batch()
    timestamp = datetime.utcnow()

    # Save the route plan
    route_doc = db.collection(_ROUTES).document()
    batch.set(route_doc, {
        "ngo_id": ngo_id,
        "routes": routes,
        "created_at": timestamp,
        "status": "active",
    })

    # Update each signal's assigned_vehicle_route
    for route in routes:
        for stop in route.get("stops", []):
            signal_ref = db.collection(_SIGNALS).document(stop["signal_id"])
            batch.update(signal_ref, {
                "assigned_vehicle_route": route.get("vehicle_id", ""),
                "status": "assigned",
            })

    await batch.commit()
