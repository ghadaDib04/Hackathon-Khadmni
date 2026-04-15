from sqlalchemy import Column, Integer, String, Float, Boolean, DateTime, ForeignKey, Text, Enum
from sqlalchemy.orm import relationship
from datetime import datetime
from database import Base
import enum

class TaskType(str, enum.Enum):
    physical = "physical"
    digital = "digital"

class TaskStatus(str, enum.Enum):
    open = "open"
    in_progress = "in_progress"
    delivered = "delivered"
    completed = "completed"
    disputed = "disputed"
    cancelled = "cancelled"

class BidStatus(str, enum.Enum):
    pending = "pending"
    accepted = "accepted"
    rejected = "rejected"

class User(Base):
    __tablename__ = "users"
    id = Column(Integer, primary_key=True, index=True)
    name = Column(String, nullable=False)
    email = Column(String, unique=True, index=True, nullable=False)
    password_hash = Column(String, nullable=False)
    university = Column(String)
    skills = Column(String, default="")
    wallet_balance = Column(Float, default=5000.0)
    trust_score = Column(Float, default=100.0)
    skill_vector = Column(Text, nullable=True)
    created_at = Column(DateTime, default=datetime.utcnow)

class Task(Base):
    __tablename__ = "tasks"
    id = Column(Integer, primary_key=True, index=True)
    title = Column(String, nullable=False)
    description = Column(Text, nullable=False)
    category = Column(String, nullable=False)
    task_type = Column(Enum(TaskType), nullable=False)
    suggested_price = Column(Float)
    ai_price = Column(Float)
    escrow_amount = Column(Float, default=0.0)
    status = Column(Enum(TaskStatus), default=TaskStatus.open)
    pin = Column(String, nullable=True)
    delivery_file_url = Column(String, nullable=True)
    dispute_reason = Column(Text, nullable=True)
    poster_id = Column(Integer, ForeignKey("users.id"))
    worker_id = Column(Integer, ForeignKey("users.id"), nullable=True)
    created_at = Column(DateTime, default=datetime.utcnow)
    task_vector = Column(Text, nullable=True)
    delivered_at = Column(DateTime, nullable=True)

class Bid(Base):
    __tablename__ = "bids"
    id = Column(Integer, primary_key=True, index=True)
    task_id = Column(Integer, ForeignKey("tasks.id"))
    bidder_id = Column(Integer, ForeignKey("users.id"))
    amount = Column(Float, nullable=False)
    message = Column(Text)
    status = Column(Enum(BidStatus), default=BidStatus.pending)
    created_at = Column(DateTime, default=datetime.utcnow)