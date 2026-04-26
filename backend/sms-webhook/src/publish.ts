import { PubSub } from '@google-cloud/pubsub';

const pubsub = new PubSub();
const TOPIC_NAME = process.env.PUBSUB_INGESTION_TOPIC || 'raw-signals';

interface RawSignalMessage {
    ward_id: string;
    city_id: string;
    need_type: string;
    people_count: number;
    urgency_raw: number;
    notes?: string;
    reporter_id: string;
    reporter_role: string;
    source_channel: string;
    latitude?: number;
    longitude?: number;
}

/**
 * Publish a parsed SMS signal to the Pub/Sub ingestion topic.
 * The normaliser service will pick it up and process it.
 */
export async function publishToIngestion(signal: RawSignalMessage): Promise<string> {
    const topic = pubsub.topic(TOPIC_NAME);

    const data = Buffer.from(JSON.stringify(signal));
    const messageId = await topic.publishMessage({ data });

    console.log(`Published signal to ${TOPIC_NAME}, messageId: ${messageId}`);
    return messageId;
}
