import os
import time
from google.cloud import aiplatform
from dotenv import load_dotenv

# Load env vars
load_dotenv()

PROJECT_ID = os.getenv("GOOGLE_CLOUD_PROJECT")
LOCATION = os.getenv("VERTEX_AI_LOCATION", "us-central1")
INDEX_DISPLAY_NAME = "resource_radar_volunteer_index"
ENDPOINT_DISPLAY_NAME = "resource_radar_matching_endpoint"

def setup_vector_search():
    """
    Sets up the Vertex AI Matching Engine (Vector Search) infrastructure.
    This is an asynchronous-style setup script. It checks for existing resources
    and creates them if missing.
    """
    if not PROJECT_ID:
        print("ERROR: GOOGLE_CLOUD_PROJECT environment variable is not set.")
        return

    aiplatform.init(project=PROJECT_ID, location=LOCATION)

    # 1. Check for/Create Index
    print(f"Checking for existing index: {INDEX_DISPLAY_NAME}...")
    existing_indexes = aiplatform.MatchingEngineIndex.list(
        filter=f'display_name="{INDEX_DISPLAY_NAME}"'
    )

    index = None
    if existing_indexes:
        index = existing_indexes[0]
        print(f"Found existing index: {index.resource_name}")
        # Note: If previous attempt failed with shard size error, we might need to delete and recreate.
        # But let's check if we can just deploy first.
    else:
        print(f"Creating new index: {INDEX_DISPLAY_NAME}...")
        index = aiplatform.MatchingEngineIndex.create_tree_ah_index(
            display_name=INDEX_DISPLAY_NAME,
            dimensions=768,  # Gemini embedding size
            approximate_neighbors_count=150,
            distance_measure_type="COSINE_DISTANCE",
            leaf_node_embedding_count=500,
            leaf_nodes_to_search_percent=7,
            description="Vector index for humanitarian volunteer matching",
            index_update_method="STREAM_UPDATE", # Critical for real-time sync
            shard_size="SHARD_SIZE_SMALL"        # Ensure small shard for lower-end machines
        )
        print(f"Index creation started: {index.resource_name}")

    # 2. Check for/Create Index Endpoint
    print(f"Checking for existing endpoint: {ENDPOINT_DISPLAY_NAME}...")
    existing_endpoints = aiplatform.MatchingEngineIndexEndpoint.list(
        filter=f'display_name="{ENDPOINT_DISPLAY_NAME}"'
    )

    if existing_endpoints:
        endpoint = existing_endpoints[0]
        print(f"Found existing endpoint: {endpoint.resource_name}")
    else:
        print(f"Creating new index endpoint: {ENDPOINT_DISPLAY_NAME}...")
        endpoint = aiplatform.MatchingEngineIndexEndpoint.create(
            display_name=ENDPOINT_DISPLAY_NAME,
            public_endpoint_enabled=True
        )
        print(f"Endpoint creation started: {endpoint.resource_name}")

    # 3. Check for Deployment
    print(f"Checking if index is deployed to endpoint...")
    deployed_indexes = endpoint.deployed_indexes
    is_deployed = any(idx.id == index.name for idx in deployed_indexes)

    if is_deployed:
        print("Index is already deployed.")
    else:
        print(f"Deploying index {index.name} to endpoint {endpoint.name}...")
        print("WARNING: This can take 30-60 minutes to complete.")
        try:
            # This is a long-running operation
            endpoint.deploy_index(
                index=index,
                deployed_index_id=f"deployed_{index.name}",
                display_name=INDEX_DISPLAY_NAME,
                machine_type="e2-standard-2",
                min_replica_count=1,
                max_replica_count=2,
            )
            print("Deployment triggered successfully.")
        except Exception as e:
            print(f"Deployment failed: {e}")
            if "SHARD_SIZE_MEDIUM" in str(e):
                print("DETECTION: Shard size mismatch. We need to delete and recreate the index with SHARD_SIZE_SMALL.")
                print("Deleting index...")
                index.delete()
                print("Index deleted. Please run this script again to recreate with correct shard size.")
            else:
                raise e

    print("\n--- STATUS ---")
    print(f"Index ID: {index.name}")
    print(f"Endpoint ID: {endpoint.name}")
    print(f"Deployed Index ID: deployed_{index.name}")

if __name__ == "__main__":
    setup_vector_search()
