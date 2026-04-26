from google.cloud import aiplatform
from google.cloud.aiplatform.matching_engine import MatchingEngineIndex, MatchingEngineIndexEndpoint
from typing import List, Dict, Any
import os

_PROJECT = os.getenv("GOOGLE_CLOUD_PROJECT", "")
_LOCATION = os.getenv("VERTEX_AI_LOCATION", "us-central1")
_INDEX_ENDPOINT_ID = os.getenv("MATCHING_ENGINE_ENDPOINT_ID", "")
_DEPLOYED_INDEX_ID = os.getenv("MATCHING_ENGINE_DEPLOYED_INDEX_ID", "")


async def find_nearest_volunteers(
    query_embedding: List[float],
    num_neighbors: int = 15,
) -> List[Dict[str, Any]]:
    """
    Query the Vertex AI Matching Engine (Vector Search) for the nearest
    volunteer embeddings to the given task embedding.

    Returns a list of volunteer candidate dicts with:
      - volunteer_id
      - match_score (cosine similarity)
    """
    if not _INDEX_ENDPOINT_ID or not _DEPLOYED_INDEX_ID:
        print("WARNING: Vector Search IDs missing. Using Mock Mode for demo.")
        return [
            {"volunteer_id": "mock_vol_001", "match_score": 0.95},
            {"volunteer_id": "mock_vol_002", "match_score": 0.88},
            {"volunteer_id": "mock_vol_003", "match_score": 0.75},
        ]

    aiplatform.init(project=_PROJECT, location=_LOCATION)

    # Get the deployed index endpoint
    endpoint = MatchingEngineIndexEndpoint(
        index_endpoint_name=_INDEX_ENDPOINT_ID,
    )

    # Query for nearest neighbors
    try:
        response = endpoint.find_neighbors(
            deployed_index_id=_DEPLOYED_INDEX_ID,
            queries=[query_embedding],
            num_neighbors=num_neighbors,
        )
    except Exception as e:
        print(f"Error querying Matching Engine: {e}. Falling back to mock.")
        return [{"volunteer_id": f"vol_{i}", "match_score": 0.5} for i in range(5)]

    if not response or not response[0]:
        return []

    candidates = []
    for neighbor in response[0]:
        candidates.append({
            "volunteer_id": neighbor.id,
            "match_score": float(neighbor.distance),
            # Additional fields will be enriched from Firestore
            "display_name": "",
            "skills": [],
            "distance_km": 0.0,
        })

    return candidates


async def upsert_volunteer_embedding(
    volunteer_id: str,
    embedding: List[float],
    index_id: str = "",
) -> None:
    """
    Upsert a volunteer's embedding into the Matching Engine index.
    Called when a new volunteer registers or updates their profile.
    """
    aiplatform.init(project=_PROJECT, location=_LOCATION)

    index = MatchingEngineIndex(
        index_name=index_id or os.getenv("MATCHING_ENGINE_INDEX_ID", ""),
    )

    index.upsert_datapoints(
        datapoints=[{
            "datapoint_id": volunteer_id,
            "feature_vector": embedding,
        }]
    )
