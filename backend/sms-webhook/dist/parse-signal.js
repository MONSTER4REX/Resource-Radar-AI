import { GoogleGenerativeAI } from '@google/generative-ai';
/**
 * Parse an unstructured signal (Hindi, Hinglish, or English) into a structured
 * need signal using Gemini 1.5 Flash.
 */
export async function parseSignalWithGemini(text, senderId, location, base64Image) {
    const API_KEY = process.env.GEMINI_API_KEY || '';
    if (!API_KEY) {
        console.error("No API key found!");
    }
    const genAI = new GoogleGenerativeAI(API_KEY);
    const model = genAI.getGenerativeModel({ model: 'gemini-1.5-flash' });
    const prompt = `You are a humanitarian signal parser for ResourceRadar AI. 
Parse the following message (which may be in Hindi, Hinglish, or English) 
into a structured need signal.

Reporter ID: ${senderId}
Message Content: "${text}"
${location ? `GPS Location provided: Lat ${location.lat}, Lng ${location.lng}` : 'No GPS location provided.'}
${base64Image ? 'A photo of the situation is provided. Use it to verify the needs and urgency.' : ''}

Extract the following fields. If a field cannot be determined, use the default value shown:

1. is_valid_signal (boolean): Is this a genuine need/distress signal? (default: false)
2. need_type (string): One of: food, water, medicine, shelter, clothing, other (default: other)
3. ward_id (string): Location/area/ward mentioned (default: "unknown")
4. city_id (string): City mentioned (default: "default_city")
5. people_count (number): Approximate people affected (default: 1)
6. urgency_raw (number 1-5): Urgency level inferred from tone and content (default: 3)
7. language_detected (string): The language (hindi, hinglish, english, etc.)

Respond ONLY with a valid JSON object matching the schema above. No markdown, no explanation.`;
    try {
        const parts = [{ text: prompt }];
        if (base64Image) {
            parts.push({
                inlineData: {
                    data: base64Image,
                    mimeType: "image/jpeg"
                }
            });
        }
        const result = await model.generateContent(parts);
        const responseText = result.response.text() || '{}';
        console.log('Gemini raw response:', responseText);
        const cleaned = responseText
            .replace(/```json\n?/g, '')
            .replace(/```\n?/g, '')
            .trim();
        const parsed = JSON.parse(cleaned);
        return {
            ...parsed,
            original_text: text,
            latitude: location?.lat,
            longitude: location?.lng,
        };
    }
    catch (error) {
        console.error('Gemini parse error:', error);
        return {
            is_valid_signal: false,
            need_type: 'other',
            ward_id: 'unknown',
            city_id: 'default_city',
            people_count: 1,
            urgency_raw: 3,
            original_text: text,
            language_detected: 'unknown',
            latitude: location?.lat,
            longitude: location?.lng,
        };
    }
}
//# sourceMappingURL=parse-signal.js.map