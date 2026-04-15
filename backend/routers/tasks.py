from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from database import get_db
from auth import get_current_user
from services.llm import analyze_task
from services.escrow import hold_escrow
from schemas import CreateTaskRequest, BidRequest
import models
import secrets

router = APIRouter(prefix="/tasks", tags=["tasks"])


@router.post("/create")
async def create_task(
    req: CreateTaskRequest,
    db: Session = Depends(get_db),
    current_user: models.User = Depends(get_current_user)
):
    # 1. Ask LLM: is this task okay? what's a fair price?
    ai_result = await analyze_task(req.title, req.description, req.category)

    # 2. Reject immediately if LLM flagged it
    if not ai_result["allowed"]:
        raise HTTPException(
            status_code=400,
            detail=f"Task rejected: {ai_result['reason']}"
        )

    # 3. Save task with both user price and AI price
    task = models.Task(
        title=req.title,
        description=req.description,
        category=req.category,
        task_type=req.task_type,
        suggested_price=req.suggested_price,
        ai_price=ai_result["suggested_price"],
        poster_id=current_user.id,
        status=models.TaskStatus.open
    )
    db.add(task)
    db.commit()
    db.refresh(task)

    return {
        "task_id": task.id,
        "ai_price": task.ai_price,
        "message": "Task created successfully"
    }


@router.get("/feed")
def get_feed(
    db: Session = Depends(get_db),
    current_user: models.User = Depends(get_current_user)
):
    tasks = (
        db.query(models.Task)
        .filter(models.Task.status == models.TaskStatus.open)
        .filter(models.Task.poster_id != current_user.id)
        .order_by(models.Task.created_at.desc())
        .all()
    )
    return [
        {
            "id": t.id,
            "title": t.title,
            "category": t.category,
            "task_type": t.task_type,
            "ai_price": t.ai_price,
            "suggested_price": t.suggested_price,
            "created_at": t.created_at
        }
        for t in tasks
    ]


@router.get("/my/posted")
def my_posted_tasks(
        db: Session = Depends(get_db),
        current_user: models.User = Depends(get_current_user)
):
    tasks = (
        db.query(models.Task)
        .filter(models.Task.poster_id == current_user.id)
        .order_by(models.Task.created_at.desc())
        .all()
    )

    result = []
    for t in tasks:
        bid_count = db.query(models.Bid).filter(
            models.Bid.task_id == t.id
        ).count()

        result.append({
            "id": t.id,
            "title": t.title,
            "category": t.category,
            "task_type": t.task_type,
            "status": t.status,
            "ai_price": t.ai_price,
            "suggested_price": t.suggested_price,
            "escrow_amount": t.escrow_amount,
            "bid_count": bid_count,
            "created_at": t.created_at
        })

    return result


@router.get("/my/working")
def my_working_tasks(
        db: Session = Depends(get_db),
        current_user: models.User = Depends(get_current_user)
):
    tasks = (
        db.query(models.Task)
        .filter(models.Task.worker_id == current_user.id)
        .order_by(models.Task.created_at.desc())
        .all()
    )

    result = []
    for t in tasks:
        # Get the accepted bid to know the agreed amount
        accepted_bid = db.query(models.Bid).filter(
            models.Bid.task_id == t.id,
            models.Bid.status == models.BidStatus.accepted
        ).first()

        # Get the poster's basic info
        poster = db.query(models.User).filter(
            models.User.id == t.poster_id
        ).first()

        result.append({
            "id": t.id,
            "title": t.title,
            "category": t.category,
            "task_type": t.task_type,
            "status": t.status,
            "agreed_amount": accepted_bid.amount if accepted_bid else None,
            "poster": {
                "id": poster.id,
                "name": poster.name,
                "trust_score": poster.trust_score
            },
            "delivered_at": t.delivered_at,
            "created_at": t.created_at
        })

    return result
@router.get("/{task_id}")
def get_task(
    task_id: int,
    db: Session = Depends(get_db),
    current_user: models.User = Depends(get_current_user)
):
    task = db.query(models.Task).filter(models.Task.id == task_id).first()
    if not task:
        raise HTTPException(status_code=404, detail="Task not found")

    bids = db.query(models.Bid).filter(models.Bid.task_id == task_id).all()

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
        "bids": [
            {
                "id": b.id,
                "bidder_id": b.bidder_id,
                "amount": b.amount,
                "message": b.message,
                "status": b.status,
                "created_at": b.created_at
            }
            for b in bids
        ]
    }


@router.post("/{task_id}/bid")
def place_bid(
    task_id: int,
    req: BidRequest,
    db: Session = Depends(get_db),
    current_user: models.User = Depends(get_current_user)
):
    task = db.query(models.Task).filter(models.Task.id == task_id).first()
    if not task:
        raise HTTPException(status_code=404, detail="Task not found")
    if task.status != models.TaskStatus.open:
        raise HTTPException(status_code=400, detail="Task is not open for bids")
    if task.poster_id == current_user.id:
        raise HTTPException(status_code=400, detail="You cannot bid on your own task")

    existing = db.query(models.Bid).filter(
        models.Bid.task_id == task_id,
        models.Bid.bidder_id == current_user.id
    ).first()
    if existing:
        raise HTTPException(status_code=400, detail="You already placed a bid on this task")

    bid = models.Bid(
        task_id=task_id,
        bidder_id=current_user.id,
        amount=req.amount,
        message=req.message,
        status=models.BidStatus.pending
    )
    db.add(bid)
    db.commit()
    db.refresh(bid)

    return {"bid_id": bid.id, "message": "Bid placed successfully"}


@router.post("/{task_id}/accept/{bid_id}")
def accept_bid(
    task_id: int,
    bid_id: int,
    db: Session = Depends(get_db),
    current_user: models.User = Depends(get_current_user)
):
    task = db.query(models.Task).filter(models.Task.id == task_id).first()
    if not task:
        raise HTTPException(status_code=404, detail="Task not found")
    if task.poster_id != current_user.id:
        raise HTTPException(status_code=403, detail="Only the task poster can accept bids")
    if task.status != models.TaskStatus.open:
        raise HTTPException(status_code=400, detail="Task is not open")

    bid = db.query(models.Bid).filter(
        models.Bid.id == bid_id,
        models.Bid.task_id == task_id
    ).first()
    if not bid:
        raise HTTPException(status_code=404, detail="Bid not found")

    # Lock the money in escrow
    hold_escrow(task, current_user, bid.amount, db)

    # Generate delivery PIN — poster gives this to worker on satisfaction
    pin = secrets.token_hex(3).upper()  # e.g. "A3F9C1"

    task.status = models.TaskStatus.in_progress
    task.worker_id = bid.bidder_id
    task.pin = pin
    bid.status = models.BidStatus.accepted

    # Auto-reject all other bids on this task
    db.query(models.Bid).filter(
        models.Bid.task_id == task_id,
        models.Bid.id != bid_id
    ).update({"status": models.BidStatus.rejected})

    db.commit()

    return {
        "message": "Bid accepted. Work can begin.",
        "escrow_held": bid.amount,
        "pin": pin
    }