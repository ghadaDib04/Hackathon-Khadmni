from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from database import get_db
from models import Task, Bid, User, TaskStatus, BidStatus
from auth import get_current_user
from services.llm import analyze_task
from services.escrow import hold_escrow
from services.embeddings import embed, score_match
from pydantic import BaseModel
from typing import Optional
import json
import random
import string

router = APIRouter(prefix="/tasks", tags=["tasks"])

# ─── Schemas ────────────────────────────────────────────────

class TaskCreate(BaseModel):
    title: str
    description: str
    category: str
    task_type: str
    suggested_price: Optional[float] = None

class BidCreate(BaseModel):
    amount: float
    message: Optional[str] = ""

# ─── Helpers ────────────────────────────────────────────────

def generate_pin(length=6):
    return ''.join(random.choices(string.ascii_uppercase + string.digits, k=length))

def get_vector(obj, field="skill_vector"):
    raw = getattr(obj, field, None)
    if not raw:
        return None
    try:
        return json.loads(raw)
    except:
        return None

# ─── 1. Create Task ─────────────────────────────────────────

@router.post("/create")
async def create_task(
    data: TaskCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    # LLM moderation + price suggestion
    analysis = await analyze_task(data.title, data.description, data.category)

    if not analysis["allowed"]:
        raise HTTPException(status_code=400, detail=analysis["reason"])

    task = Task(
        title=data.title,
        description=data.description,
        category=data.category,
        task_type=data.task_type,
        suggested_price=data.suggested_price,
        ai_price=analysis["suggested_price"],
        poster_id=current_user.id
    )

    db.add(task)
    db.commit()
    db.refresh(task)

    # Embed task for semantic matching
    task_text = f"{data.title} {data.description} {data.category}"
    task.task_vector = json.dumps(embed(task_text))
    db.commit()

    return {
        "id": task.id,
        "title": task.title,
        "ai_price": task.ai_price,
        "suggested_price": task.suggested_price,
        "status": task.status
    }

# ─── 2. Feed — ranked by match score ────────────────────────

@router.get("/feed")
def get_feed(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    tasks = db.query(Task).filter(
        Task.status == TaskStatus.open,
        Task.poster_id != current_user.id
    ).all()

    user_vector = get_vector(current_user, "skill_vector")

    result = []
    for task in tasks:
        task_vector = get_vector(task, "task_vector")

        # If both vectors exist → semantic score
        # If not → default 0.0 (still shows up, just at the bottom)
        if user_vector and task_vector:
            match = score_match(task_vector, user_vector)
        else:
            match = 0.0

        result.append({
            "id": task.id,
            "title": task.title,
            "description": task.description,
            "category": task.category,
            "task_type": task.task_type,
            "ai_price": task.ai_price,
            "suggested_price": task.suggested_price,
            "poster_id": task.poster_id,
            "created_at": task.created_at,
            "match_score": match
        })

    # Sort by match score — best matches first
    result.sort(key=lambda x: x["match_score"], reverse=True)
    return result

# ─── 3. Task Detail + Bids ranked by match ──────────────────

@router.get("/{task_id}")
def get_task(
    task_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    task = db.query(Task).filter(Task.id == task_id).first()
    if not task:
        raise HTTPException(status_code=404, detail="Task not found")

    task_vector = get_vector(task, "task_vector")

    bids_data = []
    for bid in task.bids if hasattr(task, 'bids') else db.query(Bid).filter(Bid.task_id == task_id).all():
        bidder = db.query(User).filter(User.id == bid.bidder_id).first()
        bidder_vector = get_vector(bidder, "skill_vector") if bidder else None

        if task_vector and bidder_vector:
            match = score_match(task_vector, bidder_vector)
        else:
            match = 0.0

        bids_data.append({
            "id": bid.id,
            "bidder_id": bid.bidder_id,
            "bidder_name": bidder.name if bidder else "Unknown",
            "amount": bid.amount,
            "message": bid.message,
            "status": bid.status,
            "match_score": match,
            "created_at": bid.created_at
        })

    # Poster sees best-matched bidders first
    bids_data.sort(key=lambda x: x["match_score"], reverse=True)

    return {
        "id": task.id,
        "title": task.title,
        "description": task.description,
        "category": task.category,
        "task_type": task.task_type,
        "ai_price": task.ai_price,
        "suggested_price": task.suggested_price,
        "status": task.status,
        "poster_id": task.poster_id,
        "created_at": task.created_at,
        "bids": bids_data
    }

# ─── 4. Place a Bid ─────────────────────────────────────────

@router.post("/{task_id}/bid")
def place_bid(
    task_id: int,
    data: BidCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    task = db.query(Task).filter(Task.id == task_id).first()
    if not task:
        raise HTTPException(status_code=404, detail="Task not found")
    if task.status != TaskStatus.open:
        raise HTTPException(status_code=400, detail="Task is not open for bids")
    if task.poster_id == current_user.id:
        raise HTTPException(status_code=400, detail="Cannot bid on your own task")

    existing = db.query(Bid).filter(
        Bid.task_id == task_id,
        Bid.bidder_id == current_user.id
    ).first()
    if existing:
        raise HTTPException(status_code=400, detail="You already placed a bid on this task")

    bid = Bid(
        task_id=task_id,
        bidder_id=current_user.id,
        amount=data.amount,
        message=data.message
    )
    db.add(bid)
    db.commit()
    db.refresh(bid)
    return {"id": bid.id, "status": bid.status, "amount": bid.amount}

# ─── 5. Accept a Bid ────────────────────────────────────────

@router.post("/{task_id}/accept/{bid_id}")
def accept_bid(
    task_id: int,
    bid_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    task = db.query(Task).filter(Task.id == task_id).first()
    if not task:
        raise HTTPException(status_code=404, detail="Task not found")
    if task.poster_id != current_user.id:
        raise HTTPException(status_code=403, detail="Not your task")

    bid = db.query(Bid).filter(Bid.id == bid_id, Bid.task_id == task_id).first()
    if not bid:
        raise HTTPException(status_code=404, detail="Bid not found")

    # Lock money in escrow
    hold_escrow(task, current_user, bid.amount, db)

    # Generate delivery PIN
    task.pin = generate_pin()
    task.status = TaskStatus.in_progress
    task.worker_id = bid.bidder_id
    bid.status = BidStatus.accepted

    # Reject all other bids
    db.query(Bid).filter(
        Bid.task_id == task_id,
        Bid.id != bid_id
    ).update({"status": BidStatus.rejected})

    db.commit()

    return {
        "message": "Bid accepted",
        "pin": task.pin,
        "escrow_amount": task.escrow_amount
    }