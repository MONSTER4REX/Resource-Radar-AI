import { PubSub, Message } from "@google-cloud/pubsub";
import { processRawSignal } from "./normalizer.js";
import type { RawSignal } from "./types.js";
import dotenv from "dotenv";

dotenv.config();

const pubsub = new PubSub();
const subscriptionName = process.env.PUBSUB_SUBSCRIPTION || "need-signals-sub";

export function startListening() {
    const subscription = pubsub.subscription(subscriptionName);

    console.log(`Listening for messages on ${subscriptionName}...`);

    subscription.on("message", async (message: Message) => {
        try {
            const data: RawSignal = JSON.parse(message.data.toString());
            await processRawSignal(data);
            message.ack();
        } catch (error) {
            console.error("Error processing Pub/Sub message:", error);
            // Don't ack if processing failed, so it can be retried
            // message.nack(); 
        }
    });

    subscription.on("error", (error) => {
        console.error("Pub/Sub subscription error:", error);
    });
}
