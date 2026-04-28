export interface ParsedSignal {
    is_valid_signal: boolean;
    need_type: string;
    ward_id: string;
    city_id: string;
    people_count: number;
    urgency_raw: number;
    original_text: string;
    language_detected: string;
    latitude?: number;
    longitude?: number;
}
/**
 * Parse an unstructured signal (Hindi, Hinglish, or English) into a structured
 * need signal using Gemini 1.5 Flash.
 */
export declare function parseSignalWithGemini(text: string, senderId: string, location?: {
    lat: number;
    lng: number;
}, base64Image?: string): Promise<ParsedSignal>;
