from pydantic import BaseModel
from typing import Optional, List
from datetime import datetime

class NeedSignalUpdate(BaseModel):
    urgency_score: int
    urgency_tier: str
    photo_matches_claim: Optional[bool] = None
    verification_status: str
    gemini_reasoning: str
    triaged_at: datetime
