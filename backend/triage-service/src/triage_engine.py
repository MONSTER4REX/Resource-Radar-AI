import google.generativeai as genai
import os
from dotenv import load_dotenv
import json
from typing import Dict, Any, Optional, List

load_dotenv()

genai.configure(api_key=os.getenv("GEMINI_API_KEY"))

# Use gemini-flash-latest based on available models in this project
model = genai.GenerativeModel('gemini-flash-latest')

SYSTEM_PROMPT = """
You are the AI Triage Engine for ResourceRadar AI, a humanitarian coordination platform.
Your task is to analyze incoming need signals (text and optional photos) from the field and provide a structured assessment.

Criteria for Urgency Score (0-100):
- Critical (80-100): Immediate life-safety risk (no water for 24h, medical emergency, active flooding).
- High (60-79): Significant distress (large group without food, displaced families).
- Medium (40-59): Sustained need (minor repairs, low stock of supplies).
- Low (0-39): General requests or informational reports.

Verification:
- If a photo is provided, check if it matches the text description.
- Set 'photo_matches_claim' accordingly.

Output Format (Strict JSON):
{
    "urgency_score": int,
    "urgency_tier": "critical" | "high" | "medium" | "low",
    "photo_matches_claim": bool | null,
    "verification_status": "verified" | "suspicious" | "needs_review",
    "gemini_reasoning": "string (max 2 sentences)"
}
"""

async def triage_signal(text: str, photo_url: Optional[str] = None) -> Dict[str, Any]:
    prompt = f"Analyze the following signal: {text}"
    
    content = [SYSTEM_PROMPT, prompt]
    
    if photo_url:
        # In a real implementation, we'd fetch the image from Cloud Storage
        # and pass it to Gemini. For this demo, we'll assume text analysis first
        # or handle image if provided as base64/bytes.
        pass

    print(f"DEBUG: Calling Gemini API for signal triage...")
    # Use async version to avoid blocking the event loop
    response = await model.generate_content_async(content)
    
    try:
        # Extract JSON from response
        text_response = response.text
        print(f"DEBUG: Gemini raw response: {text_response}")
        if "```json" in text_response:
            text_response = text_response.split("```json")[1].split("```")[0].strip()
        
        parsed = json.loads(text_response)
        print(f"DEBUG: Parsed JSON: {parsed}")
        return parsed
    except Exception as e:
        print(f"Error parsing Gemini response: {e}")
        return {
            "urgency_score": 50,
            "urgency_tier": "medium",
            "photo_matches_claim": None,
            "verification_status": "needs_review",
            "gemini_reasoning": "Error parsing AI response. Defaulting to medium urgency."
        }
