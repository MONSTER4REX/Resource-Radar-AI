import os
import google.generativeai as genai
from typing import List
from dotenv import load_dotenv

# Try current dir, then parent dir
if not load_dotenv():
    load_dotenv(dotenv_path=os.path.join(os.path.dirname(__file__), "..", ".env"))

# Configure Gemini
api_key = os.getenv("GEMINI_API_KEY")
if api_key:
    genai.configure(api_key=api_key)

_MODEL_ID = "models/text-embedding-004"

async def generate_task_embedding(text: str) -> List[float]:
    """
    Generate a 768-dim embedding vector from a task description
    using Gemini's text-embedding model.
    """
    try:
        # Note: genai.embed_content is synchronous, so we run in thread
        import asyncio
        result = await asyncio.to_thread(
            genai.embed_content,
            model=_MODEL_ID,
            content=text,
            task_type="clustering"
        )
        return result['embedding']
    except Exception as e:
        print(f"Embedding error: {e}")
        # Return dummy embedding if it fails for now to avoid breaking the flow
        return [0.0] * 768

async def generate_volunteer_embedding(volunteer: dict) -> List[float]:
    """
    Generate embedding for a volunteer profile.
    """
    skills = ", ".join(volunteer.get("skills", []))
    bio = volunteer.get("bio", "")
    location = volunteer.get("ward_id", "")

    profile_text = (
        f"Volunteer with skills: {skills}. "
        f"Located in {location}. "
        f"Background: {bio}"
    )

    try:
        import asyncio
        result = await asyncio.to_thread(
            genai.embed_content,
            model=_MODEL_ID,
            content=profile_text,
            task_type="retrieval_document"
        )
        return result['embedding']
    except Exception as e:
        print(f"Volunteer embedding error: {e}")
        return [0.0] * 768
