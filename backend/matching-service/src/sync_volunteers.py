import asyncio
import os
from google.cloud import firestore
from embed_task import generate_volunteer_embedding
from matching_engine import upsert_volunteer_embedding
from dotenv import load_dotenv

load_dotenv()

db = firestore.Client()

async def sync_all_volunteers():
    """
    Syncs all volunteers from Firestore to Vertex AI Vector Search.
    1. Fetch all active volunteers.
    2. Generate embeddings for each.
    3. Upsert to the live index.
    """
    print("🚀 Starting Batch Sync: Firestore -> Vertex AI Vector Search")
    
    volunteers_ref = db.collection("volunteers").where("status", "==", "active")
    volunteers = volunteers_ref.stream()
    
    count = 0
    for doc in volunteers:
        vol_data = doc.to_dict()
        vol_id = vol_data.get("volunteer_id")
        
        print(f"Processing volunteer: {vol_id} ({vol_data.get('display_name')})")
        
        # 1. Generate Embedding
        embedding = await generate_volunteer_embedding(vol_data)
        
        if not embedding or all(v == 0.0 for v in embedding):
            print(f"⚠️ Skipped {vol_id}: Embedding failed.")
            continue
            
        # 2. Upsert to Index
        try:
            await upsert_volunteer_embedding(
                volunteer_id=vol_id,
                embedding=embedding
            )
            count += 1
            print(f"✅ Synced {vol_id}")
        except Exception as e:
            print(f"❌ Error syncing {vol_id}: {e}")

    print(f"\n✨ Sync complete! {count} volunteers processed.")

if __name__ == "__main__":
    asyncio.run(sync_all_volunteers())
