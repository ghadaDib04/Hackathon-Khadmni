"""
services/escrow.py - Wallet & Escrow Logic for Khadmli
-------------------------------------------------------
When a bid is accepted:
  1. Deduct amount from poster's wallet → held in task.escrow_amount
When task is completed:
  2. Release escrow → add to worker's wallet
When task is cancelled/disputed and refunded:
  3. Return escrow → back to poster's wallet
"""
from fastapi import HTTPException
from sqlalchemy.orm import Session
import models

def hold_escrow(task: models.Task, poster: models.User, amount: float, db: Session):
    """Deduct from poster wallet, hold in task escrow."""
    if poster.wallet_balance < amount:
        raise HTTPException(
            status_code=400,
            detail=f"Insufficient wallet balance. You have {poster.wallet_balance} DZD, need {amount} DZD."
        )
    poster.wallet_balance -= amount
    task.escrow_amount = amount
    db.commit()

def release_escrow(task: models.Task, worker: models.User, db: Session):
    """Release escrow to worker on task completion."""
    if task.escrow_amount <= 0:
        raise HTTPException(status_code=400, detail="No escrow to release.")
    worker.wallet_balance += task.escrow_amount
    task.escrow_amount = 0.0
    db.commit()

def refund_escrow(task: models.Task, poster: models.User, db: Session):
    """Return escrow to poster on cancellation or lost dispute."""
    if task.escrow_amount <= 0:
        return  # nothing to refund
    poster.wallet_balance += task.escrow_amount
    task.escrow_amount = 0.0
    db.commit()