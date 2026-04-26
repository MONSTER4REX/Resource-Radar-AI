import { PubSub } from "@google-cloud/pubsub";

async function check() {
    const pubsub = new PubSub();
    const [topics] = await pubsub.getTopics();
    console.log("Topics:", topics.map(t => t.name));

    const [subscriptions] = await pubsub.getSubscriptions();
    console.log("Subscriptions:", subscriptions.map(s => s.name));

    for (const sub of subscriptions) {
        try {
            const [metadata] = await sub.getMetadata();
            console.log(`Sub: ${sub.name}, Topic: ${metadata.topic}`);
            // Note: Cloud Pub/Sub doesn't have a direct "count" in metadata easily, 
            // but we can try to pull a message with a short timeout.
        } catch (e) {
            console.log(`Sub: ${sub.name}, Error getting metadata`);
        }
    }
}
check();
