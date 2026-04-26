import { Firestore } from "@google-cloud/firestore";

async function check() {
    const db = new Firestore();
    const snapshot = await db.collection("need_signals").orderBy("created_at", "desc").limit(1).get();
    
    if (snapshot.empty) {
        console.log("No signals found in Firestore.");
        return;
    }

    snapshot.forEach(doc => {
        const data = doc.data();
        console.log(`Signal ID: ${doc.id}`);
        console.log(`Need Type: ${data.need_type}`);
        console.log(`Ward ID: ${data.ward_id}`);
        console.log(`Created At: ${new Date(data.created_at._seconds * 1000).toLocaleString()}`);
        console.log(`Full Data:`, JSON.stringify(data, null, 2));
    });
}
check();
