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
export declare function publishToIngestion(signal: RawSignalMessage): Promise<string>;
export {};
