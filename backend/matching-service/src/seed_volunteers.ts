import { Firestore } from '@google-cloud/firestore';

const db = new Firestore();

const mockVolunteers = [
    {
        volunteer_id: 'vol_001',
        display_name: 'Arjun Singh',
        skills: ['medical', 'first_aid', 'driving'],
        status: 'active',
        location: { latitude: 30.7333, longitude: 76.7794 }, // Chandigarh Sector 17
        last_active: new Date(),
    },
    {
        volunteer_id: 'vol_002',
        display_name: 'Priya Sharma',
        skills: ['food_distribution', 'hindi_translation'],
        status: 'active',
        location: { latitude: 30.7500, longitude: 76.6144 }, // Near Kharar
        last_active: new Date(),
    },
    {
        volunteer_id: 'vol_003',
        display_name: 'Rahul Verma',
        skills: ['search_and_rescue', 'swimming'],
        status: 'active',
        location: { latitude: 30.7046, longitude: 76.7179 }, // Mohali
        last_active: new Date(),
    },
    {
        volunteer_id: 'vol_004',
        display_name: 'Deepa Kaur',
        skills: ['medicine', 'pediatrics'],
        status: 'active',
        location: { latitude: 30.7650, longitude: 76.6200 }, // North Kharar
        last_active: new Date(),
    },
    {
        volunteer_id: 'vol_005',
        display_name: 'Amit Patel',
        skills: ['logistics', 'heavy_vehicle'],
        status: 'active',
        location: { latitude: 30.7400, longitude: 76.7600 }, // Near Rose Garden
        last_active: new Date(),
    }
];

async function seed() {
    console.log('🌱 Seeding mock volunteers...');
    for (const vol of mockVolunteers) {
        await db.collection('volunteers').doc(vol.volunteer_id).set(vol);
        console.log(`Added: ${vol.display_name}`);
    }
    console.log('✅ Seeding complete!');
}

seed().catch(console.error);
