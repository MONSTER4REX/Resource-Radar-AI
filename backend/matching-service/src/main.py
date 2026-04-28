from dotenv import load_dotenv
import os

# Try current dir, then parent dir
if not load_dotenv():
    load_dotenv(dotenv_path=os.path.join(os.path.dirname(__file__), "..", ".env"))

from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from typing import List, Optional
from embed_task import generate_task_embedding, generate_volunteer_embedding
from matching_engine import find_nearest_volunteers, upsert_volunteer_embedding
from distance_filter import filter_by_distance
from firestore_sync import get_signal, update_signal_matches, get_volunteer_profiles, get_volunteer_profile

app = FastAPI(title="ResourceRadar Matching Service")


class MatchRequest(BaseModel):
    signal_id: str
    max_results: int = 5
    max_distance_km: float = 15.0


class VolunteerMatch(BaseModel):
    volunteer_id: str
    display_name: str
    skills: List[str]
    distance_km: float
    match_score: float


class MatchResponse(BaseModel):
    signal_id: str
    matches: List[VolunteerMatch]
    total_candidates: int


@app.get("/health")
async def health_check():
    return {"status": "ok", "service": "matching"}


@app.post("/match", response_model=MatchResponse)
async def match_volunteers(request: MatchRequest):
    """
    Match a need signal to the nearest qualified volunteers using Vertex AI embeddings.
    1. Fetch signal from Firestore
    2. Generate embedding vector from signal attributes
    3. Query Vertex AI Matching Engine for nearest neighbors
    4. Filter by max_distance_km
    5. Update signal with assigned volunteers
    """
    # 1. Fetch signal
    signal = await get_signal(request.signal_id)
    if not signal:
        raise HTTPException(status_code=404, detail=f"Signal {request.signal_id} not found")

    # 2. Generate task embedding
    task_text = _build_task_description(signal)
    embedding = await generate_task_embedding(task_text)

    # 3. Find nearest volunteers via Matching Engine
    signal_location = signal.get("location", {})
    candidates = await find_nearest_volunteers(
        query_embedding=embedding,
        num_neighbors=request.max_results * 3,  # Over-fetch for distance filtering
        task_location=signal_location,
    )

    # 4. Filter by distance
    filtered = filter_by_distance(
        candidates=candidates,
        signal_lat=signal_location.get("latitude", 0),
        signal_lng=signal_location.get("longitude", 0),
        max_km=request.max_distance_km,
    )

    # 5. Rank and limit
    ranked = sorted(filtered, key=lambda v: v["match_score"], reverse=True)
    top_matches_data = ranked[: request.max_results]

    # 6. Enrich with Profile Data
    volunteer_ids = [m["volunteer_id"] for m in top_matches_data]
    profiles = await get_volunteer_profiles(volunteer_ids)
    
    # Map profiles to matches
    enriched_matches = []
    for m in top_matches_data:
        profile = next((p for p in profiles if p["volunteer_id"] == m["volunteer_id"]), {})
        enriched_matches.append({
            **m,
            "display_name": profile.get("display_name", profile.get("display_name", "Anonymous Volunteer")),
            "skills": profile.get("skills", []),
        })

    # 7. Update Firestore (Optional/Pending Confirmation)
    # await update_signal_matches(request.signal_id, [m["volunteer_id"] for m in enriched_matches[:1]])

    return MatchResponse(
        signal_id=request.signal_id,
        matches=[VolunteerMatch(**m) for m in enriched_matches],
        total_candidates=len(candidates),
    )


class SyncRequest(BaseModel):
    volunteer_id: str


@app.post("/sync-volunteer")
async def sync_volunteer(request: SyncRequest):
    """
    Sync a specific volunteer's profile to the Vector Search index.
    Called when a volunteer registers or updates their profile.
    """
    profile = await get_volunteer_profile(request.volunteer_id)
    if not profile:
        raise HTTPException(status_code=404, detail="Volunteer not found")

    embedding = await generate_volunteer_embedding(profile)
    await upsert_volunteer_embedding(request.volunteer_id, embedding)

    return {"status": "success", "volunteer_id": request.volunteer_id}


def _build_task_description(signal: dict) -> str:
    """Build a natural language task description for embedding generation."""
    need = signal.get("need_type", "unknown")
    ward = signal.get("ward_id", "unknown")
    people = signal.get("people_count", 0)
    urgency = signal.get("urgency_tier", "medium")
    notes = signal.get("notes", "")

    return (
        f"Urgent humanitarian need: {need} assistance required in {ward}. "
        f"Approximately {people} people affected. Priority: {urgency}. "
        f"Additional context: {notes}"
    )


if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=int(os.getenv("PORT", 8001)))
