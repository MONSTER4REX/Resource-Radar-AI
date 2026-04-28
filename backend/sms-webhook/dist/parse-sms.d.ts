interface ParsedSms {
    is_valid_signal: boolean;
    need_type: string;
    ward_id: string;
    city_id: string;
    people_count: number;
    urgency_raw: number;
    original_text: string;
    language_detected: string;
}
/**
 * Parse an unstructured SMS (Hindi, Hinglish, or English) into a structured
 * need signal using Gemini 1.5 Flash.
 */
export declare function parseSmsWithGemini(smsBody: string, senderPhone: string): Promise<ParsedSms>;
export {};
