from google.cloud import aiplatform, firestore
from google.cloud.aiplatform.matching_engine import MatchingEngineIndex, MatchingEngineIndexEndpoint
from typing import List, Dict, Any
import os
import math

_PROJECT = os.getenv("GOOGLE_CLOUD_PROJECT", "")
_LOCATION = os.getenv("VERTEX_AI_LOCATION", "us-central1")
_INDEX_ENDPOINT_ID = os.getenv("MATCHING_ENGINE_ENDPOINT_ID", "")
_DEPLOYED_INDEX_ID = os.getenv("MATCHING_ENGINE_DEPLOYED_INDEX_ID", "")

db = firestore.Client()

def haversine(lat1, lon1, lat2, lon2):
    R = 6371  # Earth radius in km
    dLat = math.radians(lat2 - lat1)
    dLon = math.radians(lon2 - lon1)
    a = math.sin(dLat / 2) * math.sin(dLat / 2) + \
        math.cos(math.radians(lat1)) * math.cos(math.radians(lat2)) * \
        math.sin(dLon / 2) * math.sin(dLon / 2)
    c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a))
    return R * c

async def find_nearest_volunteers(
    query_embedding: List[float],
    num_neighbors: int = 15,
    task_location: Dict[str, float] = None
) -> List[Dict[str, Any]]:
    """
    Query the Vertex AI Matching Engine or fallback to Firestore Geolocation.
    """
    if not _INDEX_ENDPOINT_ID or not _DEPLOYED_INDEX_ID:
        print("Using Firestore Geolocation Fallback for nearest volunteers.")
        
        # In a real app, use GeoFirestore or S2 cells. 
        # For this high-fidelity demo, we fetch active volunteers and sort by Haversine.
        volunteers_ref = db.collection("volunteers").where("status", "==", "active").limit(100)
        docs = volunteers_ref.stream()
        
        candidates = []
        target_lat = task_location.get("latitude") if task_location else 30.7333
        target_lon = task_location.get("longitude") if task_location else 76.7794

        for doc in docs:
            data = doc.to_dict()
            loc = data.get("location", {})
            dist = haversine(target_lat, target_lon, loc.get("latitude", 0), loc.get("longitude", 0))
            
            candidates.append({
                "volunteer_id": data.get("volunteer_id"),
                "match_score": max(0, 1 - (dist / 50)), # Mock score based on distance
                "display_name": data.get("display_name"),
                "skills": data.get("skills", []),
                "distance_km": round(dist, 2),
            })
        
        # Sort by score descending
        candidates.sort(key=lambda x: x["match_score"], reverse=True)
        return candidates[:num_neighbors]

    # ... Vertex AI Logic ...
    aiplatform.init(project=_PROJECT, location=_LOCATION)
    endpoint = MatchingEngineIndexEndpoint(index_endpoint_name=_INDEX_ENDPOINT_ID)
    
    try:
        response = endpoint.find_neighbors(
            deployed_index_id=_DEPLOYED_INDEX_ID,
            queries=[query_embedding],
            num_neighbors=num_neighbors,
        )
    except Exception as e:
        print(f"Error querying Matching Engine: {e}")
        return []

    if not response or not response[0]:
        return []

    candidates = []
    for neighbor in response[0]:
        # Enrichment happens in the main service logic
        candidates.append({
            "volunteer_id": neighbor.id,
            "match_score": float(neighbor.distance),
        })

    return candidates

async def upsert_volunteer_embedding(
    volunteer_id: str,
    embedding: List[float],
    index_id: str = "",
) -> None:
    aiplatform.init(project=_PROJECT, location=_LOCATION)
    index = MatchingEngineIndex(index_name=index_id or os.getenv("MATCHING_ENGINE_INDEX_ID", ""))
    index.upsert_datapoints(datapoints=[{"datapoint_id": volunteer_id, "feature_vector": embedding}])
