import { VertexAI } from '@google-cloud/vertexai';

const PROJECT_ID = process.env.GOOGLE_CLOUD_PROJECT || '';
const LOCATION = process.env.VERTEX_AI_LOCATION || 'us-central1';

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
export async function parseSmsWithGemini(
    smsBody: string,
    senderPhone: string,
): Promise<ParsedSms> {
    const vertexAi = new VertexAI({ project: PROJECT_ID, location: LOCATION });
    const model = vertexAi.getGenerativeModel({ model: 'gemini-1.5-flash' });

    const prompt = `You are a humanitarian SMS parser for ResourceRadar AI. 
Parse the following SMS message (which may be in Hindi, Hinglish, or English) 
into a structured need signal.

SMS from ${senderPhone}:
"${smsBody}"

Extract the following fields. If a field cannot be determined, use the default value shown:

1. is_valid_signal (boolean): Is this a genuine need/distress signal? (default: false)
2. need_type (string): One of: food, water, medicine, shelter, clothing, other (default: other)
3. ward_id (string): Location/area/ward mentioned (default: "unknown")
4. city_id (string): City mentioned (default: "default_city")
5. people_count (number): Approximate people affected (default: 1)
6. urgency_raw (number 1-5): Urgency level inferred from tone and content (default: 3)
7. language_detected (string): The language of the SMS (hindi, hinglish, english)

Respond ONLY with a valid JSON object matching the schema above. No markdown, no explanation.`;

    try {
        const result = await model.generateContent(prompt);
        const responseText = result.response.candidates?.[0]?.content?.parts?.[0]?.text || '{}';

        // Clean JSON from potential markdown code blocks
        const cleaned = responseText
            .replace(/```json\n?/g, '')
            .replace(/```\n?/g, '')
            .trim();

        const parsed: ParsedSms = {
            ...JSON.parse(cleaned),
            original_text: smsBody,
        };

        return parsed;
    } catch (error) {
        console.error('Gemini parse error:', error);
        return {
            is_valid_signal: false,
            need_type: 'other',
            ward_id: 'unknown',
            city_id: 'default_city',
            people_count: 1,
            urgency_raw: 3,
            original_text: smsBody,
            language_detected: 'unknown',
        };
    }
}
