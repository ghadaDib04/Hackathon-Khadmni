from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from database import get_db
from auth import get_current_user
import models

router = APIRouter(prefix="/users", tags=["users"])


@router.get("/me")
def get_my_profile(
    db: Session = Depends(get_db),
    current_user: models.User = Depends(get_current_user)
):
    # Count tasks posted
    tasks_posted = db.query(models.Task).filter(
        models.Task.poster_id == current_user.id
    ).count()

    # Count tasks completed as worker
    tasks_completed = db.query(models.Task).filter(
        models.Task.worker_id == current_user.id,
        models.Task.status == models.TaskStatus.completed
    ).count()

    # Count active bids
    active_bids = db.query(models.Bid).filter(
        models.Bid.bidder_id == current_user.id,
        models.Bid.status == models.BidStatus.pending
    ).count()

    return {
        "id": current_user.id,
        "name": current_user.name,
        "email": current_user.email,
        "university": current_user.university,
        "skills": current_user.skills,
        "wallet_balance": current_user.wallet_balance,
        "trust_score": current_user.trust_score,
        "stats": {
            "tasks_posted": tasks_posted,
            "tasks_completed": tasks_completed,
            "active_bids": active_bids
        },
        "member_since": current_user.created_at
    }


@router.get("/{user_id}")
def get_user_profile(
    user_id: int,
    db: Session = Depends(get_db),
    current_user: models.User = Depends(get_current_user)
):
    user = db.query(models.User).filter(models.User.id == user_id).first()
    if not user:
        from fastapi import HTTPException
        raise HTTPException(status_code=404, detail="User not found")

    tasks_completed = db.query(models.Task).filter(
        models.Task.worker_id == user.id,
        models.Task.status == models.TaskStatus.completed
    ).count()

    return {
        "id": user.id,
        "name": user.name,
        "university": user.university,
        "skills": user.skills,
        "trust_score": user.trust_score,
        "stats": {
            "tasks_completed": tasks_completed
        },
        "member_since": user.created_at
    }