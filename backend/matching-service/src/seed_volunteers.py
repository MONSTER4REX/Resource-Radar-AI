import firebase_admin
from firebase_admin import credentials, firestore
from datetime import datetime

# Use default credentials
if not firebase_admin._apps:
    firebase_admin.initialize_app()

db = firestore.client()

mock_volunteers = [
    {
        "volunteer_id": "vol_001",
        "display_name": "Arjun Singh",
        "skills": ["medical", "first_aid", "driving"],
        "status": "active",
        "location": {"latitude": 30.7333, "longitude": 76.7794},  # Chandigarh Sector 17
        "last_active": datetime.now(),
    },
    {
        "volunteer_id": "vol_002",
        "display_name": "Priya Sharma",
        "skills": ["food_distribution", "hindi_translation"],
        "status": "active",
        "location": {"latitude": 30.7500, "longitude": 76.6144},  # Near Kharar
        "last_active": datetime.now(),
    },
    {
        "volunteer_id": "vol_003",
        "display_name": "Rahul Verma",
        "skills": ["search_and_rescue", "swimming"],
        "status": "active",
        "location": {"latitude": 30.7046, "longitude": 76.7179},  # Mohali
        "last_active": datetime.now(),
    },
    {
        "volunteer_id": "vol_004",
        "display_name": "Deepa Kaur",
        "skills": ["medicine", "pediatrics"],
        "status": "active",
        "location": {"latitude": 30.7650, "longitude": 76.6200},  # North Kharar
        "last_active": datetime.now(),
    },
    {
        "volunteer_id": "vol_005",
        "display_name": "Amit Patel",
        "skills": ["logistics", "heavy_vehicle"],
        "status": "active",
        "location": {"latitude": 30.7400, "longitude": 76.7600},  # Near Rose Garden
        "last_active": datetime.now(),
    }
]

def seed():
    print("Seeding mock volunteers (Python)...")
    for vol in mock_volunteers:
        db.collection("volunteers").document(vol["volunteer_id"]).set(vol)
        print(f"Added: {vol['display_name']}")
    print("Seeding complete!")

if __name__ == "__main__":
    seed()
