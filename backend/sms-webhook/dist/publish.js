import { PubSub } from '@google-cloud/pubsub';
const pubsub = new PubSub();
const TOPIC_NAME = process.env.PUBSUB_INGESTION_TOPIC || 'raw-signals';
/**
 * Publish a parsed SMS signal to the Pub/Sub ingestion topic.
 * The normaliser service will pick it up and process it.
 */
export async function publishToIngestion(signal) {
    const topic = pubsub.topic(TOPIC_NAME);
    const data = Buffer.from(JSON.stringify(signal));
    const messageId = await topic.publishMessage({ data });
    console.log(`Published signal to ${TOPIC_NAME}, messageId: ${messageId}`);
    return messageId;
}
//# sourceMappingURL=publish.js.map