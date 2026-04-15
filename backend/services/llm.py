import os
import json
import httpx
from dotenv import load_dotenv

load_dotenv()

GEMINI_API_KEY = os.getenv("GEMINI_API_KEY", "")
GEMINI_URL = (
    "https://generativelanguage.googleapis.com/v1beta/models/"
    "gemini-2.0-flash:generateContent"
)

SYSTEM_PROMPT = """
You are a moderation and pricing assistant for Khademni — a student micro-service 
platform in Algeria where students exchange services for DZD (Algerian Dinar).

When given a task title, description, and category, you must return ONLY a JSON 
object with exactly these 3 fields:
- allowed (bool): false if the task is illegal, unethical, asks someone to cheat 
  academically (do my exam, write my thesis), or is inappropriate for a university 
  platform. true otherwise.
- reason (str): if allowed is false, explain why in one sentence. if true, empty string.
- suggested_price (float): a fair price in DZD for this task based on the Algerian 
  student economy. Typical range: 500 DZD (simple errand) to 8000 DZD (complex design 
  or dev work). Be realistic — students are paying each other.

Return ONLY the JSON. No explanation, no markdown, no code blocks.
Example: {"allowed": true, "reason": "", "suggested_price": 2500.0}
"""

async def analyze_task(title: str, description: str, category: str) -> dict:
    """
    Calls Gemini to moderate a task and suggest a price.
    Returns safe defaults if the API call fails.
    """
    # Safe default — never blocks task creation if AI is down
    default = {"allowed": True, "reason": "", "suggested_price": 1500.0}

    if not GEMINI_API_KEY:
        return default

    prompt = f"Title: {title}\nDescription: {description}\nCategory: {category}"

    payload = {
        "contents": [
            {
                "parts": [
                    {"text": SYSTEM_PROMPT + "\n\n" + prompt}
                ]
            }
        ]
    }

    try:
        async with httpx.AsyncClient(timeout=10.0) as client:
            response = await client.post(
                f"{GEMINI_URL}?key={GEMINI_API_KEY}",
                json=payload
            )
            response.raise_for_status()
            data = response.json()

        # Extract the text content from Gemini's response structure
        raw_text = (
            data["candidates"][0]["content"]["parts"][0]["text"]
        )

        # Clean markdown fences if Gemini wraps in ```json ... ```
        cleaned = raw_text.strip()
        if cleaned.startswith("```"):
            cleaned = cleaned.split("```")[1]
            if cleaned.startswith("json"):
                cleaned = cleaned[4:]

        result = json.loads(cleaned.strip())

        # Validate all 3 fields exist
        return {
            "allowed": bool(result.get("allowed", True)),
            "reason": str(result.get("reason", "")),
            "suggested_price": float(result.get("suggested_price", 1500.0))
        }

    except Exception:
        # Any failure (network, parsing, quota) → allow task with default price
        return default