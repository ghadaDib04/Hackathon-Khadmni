from pydantic import BaseModel
from typing import Optional

# ── Auth ───────────────────────────────────────────────────────────────────

class RegisterRequest(BaseModel):
    name: str
    email: str
    password: str
    university: str
    skills: str  # list of skills

class LoginRequest(BaseModel):
    email: str
    password: str

# ── Tasks ──────────────────────────────────────────────────────────────────

class CreateTaskRequest(BaseModel):
    title: str
    description: str
    category: str
    task_type: str          # "physical" or "digital"
    suggested_price: Optional[float] = None

class BidRequest(BaseModel):
    amount: float
    message: Optional[str] = ""



# ---Rating and Reviews---
class RatingRequest(BaseModel):
    score: int        # 1 to 5
    comment: Optional[str] = ""