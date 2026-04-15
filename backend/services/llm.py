"""
services/llm.py - LLM Service for Khadmli
------------------------------------------
Calls an LLM to moderate tasks and suggest prices.
Set LLM_PROVIDER in .env: gemini | groq | auto (default: auto)

auto → tries Gemini first, falls back to Groq if it fails.

Required keys (only the ones you use):
  GEMINI_API_KEY
  GROQ_API_KEY
"""
from __future__ import annotations
import os
import httpx
import json

GEMINI_API_KEY = os.getenv("GEMINI_API_KEY", "")
GROQ_API_KEY   = os.getenv("GROQ_API_KEY", "")
LLM_PROVIDER   = os.getenv("LLM_PROVIDER", "auto").lower()

PROMPT_TEMPLATE = """
You are a moderation and pricing assistant for Khadmli, a student task marketplace in Algeria.
Students post tasks and other students complete them for DZD (Algerian Dinar).

Given this task:
Title: {title}
Description: {description}
Category: {category}

Respond with ONLY a JSON object, no explanation, no markdown:
{{
  "allowed": true or false,
  "reason": "short reason if rejected, empty string if allowed",
  "suggested_price": a fair price in DZD as a number (between 200 and 50000)
}}

Reject if: illegal, inappropriate, harmful, or violates academic integrity (e.g. "do my exam").
Price should reflect real Algerian student economy.
"""

async def _call_gemini(prompt: str) -> dict:
    url = f"https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key={GEMINI_API_KEY}"
    body = {
        "contents": [{"parts": [{"text": prompt}]}],
        "generationConfig": {"temperature": 0}
    }
    async with httpx.AsyncClient(timeout=15) as client:
        r = await client.post(url, json=body)
        r.raise_for_status()
        text = r.json()["candidates"][0]["content"]["parts"][0]["text"]
        return json.loads(text.strip().strip("```json").strip("```").strip())

async def _call_groq(prompt: str) -> dict:
    url = "https://api.groq.com/openai/v1/chat/completions"
    headers = {
        "Authorization": f"Bearer {GROQ_API_KEY}",
        "Content-Type": "application/json"
    }
    body = {
        "model": os.getenv("GROQ_MODEL", "llama-3.3-70b-versatile"),
        "messages": [{"role": "user", "content": prompt}],
        "temperature": 0
    }
    async with httpx.AsyncClient(timeout=15) as client:
        r = await client.post(url, headers=headers, json=body)
        r.raise_for_status()
        text = r.json()["choices"][0]["message"]["content"]
        return json.loads(text.strip().strip("```json").strip("```").strip())

async def analyze_task(title: str, description: str, category: str) -> dict:
    """
    Returns: { "allowed": bool, "reason": str, "suggested_price": float }
    Falls back to a safe default if all providers fail.
    """
    prompt = PROMPT_TEMPLATE.format(
        title=title,
        description=description,
        category=category
    )

    providers = []
    if LLM_PROVIDER == "gemini":
        providers = [_call_gemini]
    elif LLM_PROVIDER == "groq":
        providers = [_call_groq]
    else:  # auto
        providers = [_call_gemini, _call_groq]

    last_error = None
    for provider_fn in providers:
        try:
            return await provider_fn(prompt)
        except Exception as e:
            last_error = e
            continue

    # All providers failed — log and allow with default price
    print(f"[llm.py] All providers failed: {last_error}. Using fallback.")
    return {
        "allowed": True,
        "reason": "",
        "suggested_price": 1500.0
    }