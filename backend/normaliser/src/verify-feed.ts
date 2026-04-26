import { Firestore } from "@google-cloud/firestore";

async function verifyFeed() {
    const db = new Firestore();
    // Simulate the query used in SignalService.getActiveSignals()
    const snapshot = await db.collection("need_signals")
        .where("status", "==", "active")
        .orderBy("created_at", "desc")
        .get();
    
    console.log(`Found ${snapshot.size} active signals.`);
    
    snapshot.forEach(doc => {
        const data = doc.data();
        console.log(`- [${data.need_type.toUpperCase()}] at ${data.ward_id} (ID: ${doc.id})`);
    });

    const hasBandra = snapshot.docs.some(doc => doc.data().ward_id === "Bandra Station");
    if (hasBandra) {
        console.log("\nVERIFICATION SUCCESS: Bandra Station signal is present in the global feed query.");
    } else {
        console.log("\nVERIFICATION FAILED: Bandra Station signal is NOT present in the global feed query.");
    }
}
verifyFeed();
