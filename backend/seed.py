# seed.py
import sys
import os
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

from database import engine, SessionLocal
from models import Base, User, Task, Bid, Rating, TaskType, TaskStatus, BidStatus
from auth import hash_password
import random
from datetime import datetime, timedelta

def seed():
    print("Dropping all tables...")
    Base.metadata.drop_all(bind=engine)
    print("Recreating tables...")
    Base.metadata.create_all(bind=engine)

    db = SessionLocal()

    # ─── USERS ───────────────────────────────────────────────
    print("Seeding users...")
    users_data = [
        {
            "name": "Yacine Benali",
            "email": "yacine@etudiant.dz",
            "password": "password123",
            "university": "Université Sétif 1",
            "skills": "Design, Illustration, Photoshop",
            "wallet_balance": 8000.0,
            "trust_score": 92.0,
        },
        {
            "name": "Amira Khelif",
            "email": "amira@etudiant.dz",
            "password": "password123",
            "university": "USTHB Alger",
            "skills": "Web Dev, Python, FastAPI",
            "wallet_balance": 12000.0,
            "trust_score": 88.0,
        },
        {
            "name": "Rami Bouzid",
            "email": "rami@etudiant.dz",
            "password": "password123",
            "university": "Université Sétif 1",
            "skills": "Translation, Writing, English",
            "wallet_balance": 5000.0,
            "trust_score": 76.0,
        },
        {
            "name": "Sara Mammeri",
            "email": "sara@etudiant.dz",
            "password": "password123",
            "university": "Université Constantine 1",
            "skills": "Tutoring, Math, Physics",
            "wallet_balance": 7500.0,
            "trust_score": 95.0,
        },
        {
            "name": "Mehdi Lazreg",
            "email": "mehdi@etudiant.dz",
            "password": "password123",
            "university": "Université Oran 1",
            "skills": "Video Editing, Premiere Pro, YouTube",
            "wallet_balance": 4000.0,
            "trust_score": 81.0,
        },
        {
            "name": "Lina Hadj",
            "email": "lina@etudiant.dz",
            "password": "password123",
            "university": "USTHB Alger",
            "skills": "Logo Design, Canva, Branding",
            "wallet_balance": 6000.0,
            "trust_score": 89.0,
        },
    ]

    users = []
    for u in users_data:
        user = User(
            name=u["name"],
            email=u["email"],
            password_hash=hash_password(u["password"]),
            university=u["university"],
            skills=u["skills"],
            wallet_balance=u["wallet_balance"],
            trust_score=u["trust_score"],
        )
        db.add(user)
        users.append(user)

    db.commit()
    for u in users:
        db.refresh(u)
    print(f"  ✓ {len(users)} users created")

    # Shortcuts
    yacine, amira, rami, sara, mehdi, lina = users

    # ─── TASKS ───────────────────────────────────────────────
    print("Seeding tasks...")
    tasks_data = [
        # OPEN tasks — visible in the feed
        {
            "title": "Design a logo for my engineering club",
            "description": "I need a clean modern logo for our robotics club at Sétif 1. Needs to include gears and the club name 'RoboSétif'. Deliver PNG + SVG.",
            "category": "Design",
            "task_type": TaskType.digital,
            "poster": yacine,
            "suggested_price": 3000.0,
            "ai_price": 2800.0,
            "status": TaskStatus.open,
        },
        {
            "title": "Translate 3 pages from French to English",
            "description": "Academic paper translation. Technical content about renewable energy. Must be accurate, not Google Translate level.",
            "category": "Translation",
            "task_type": TaskType.digital,
            "poster": amira,
            "suggested_price": 1500.0,
            "ai_price": 1800.0,
            "status": TaskStatus.open,
        },
        {
            "title": "Help me understand Fourier Transform before my exam",
            "description": "I have an exam in 3 days. Need 2 hours of tutoring via Google Meet. Must explain it simply, I struggle with the math.",
            "category": "Tutoring",
            "task_type": TaskType.digital,
            "poster": rami,
            "suggested_price": 2000.0,
            "ai_price": 2200.0,
            "status": TaskStatus.open,
        },
        {
            "title": "Edit a 5-minute video for my YouTube channel",
            "description": "Raw footage is already shot. Need cuts, background music, subtitles in Arabic. Style: clean and modern.",
            "category": "Video Editing",
            "task_type": TaskType.digital,
            "poster": sara,
            "suggested_price": 4000.0,
            "ai_price": 3500.0,
            "status": TaskStatus.open,
        },
        # IN PROGRESS tasks — bid accepted, worker assigned
        {
            "title": "Build a simple landing page for my portfolio",
            "description": "HTML/CSS only. One page. Shows my projects, skills, and contact. Mobile responsive.",
            "category": "Web Dev",
            "task_type": TaskType.digital,
            "poster": mehdi,
            "suggested_price": 5000.0,
            "ai_price": 4800.0,
            "status": TaskStatus.in_progress,
            "worker": amira,
            "escrow_amount": 4800.0,
            "pin": "A3F9C1",
        },
        {
            "title": "Create 5 Instagram posts for my small business",
            "description": "Selling handmade bracelets. Need 5 clean product posts with Arabic captions. Canva is fine.",
            "category": "Design",
            "task_type": TaskType.digital,
            "poster": yacine,
            "suggested_price": 2500.0,
            "ai_price": 2000.0,
            "status": TaskStatus.in_progress,
            "worker": lina,
            "escrow_amount": 2000.0,
            "pin": "B7K2M4",
        },
        # COMPLETED tasks — full flow done, ratings exist
        {
            "title": "Write a CV in English for internship applications",
            "description": "I'm a 3rd year CS student. Need a professional 1-page CV in English targeting French tech companies.",
            "category": "Writing",
            "task_type": TaskType.digital,
            "poster": sara,
            "suggested_price": 1500.0,
            "ai_price": 1200.0,
            "status": TaskStatus.completed,
            "worker": rami,
            "escrow_amount": 0.0,
        },
        {
            "title": "Explain machine learning basics — 1 hour session",
            "description": "Complete beginner. Need someone to explain supervised vs unsupervised, give examples, and recommend what to study next.",
            "category": "Tutoring",
            "task_type": TaskType.digital,
            "poster": lina,
            "suggested_price": 2000.0,
            "ai_price": 2500.0,
            "status": TaskStatus.completed,
            "worker": amira,
            "escrow_amount": 0.0,
        },
    ]

    tasks = []
    for t in tasks_data:
        task = Task(
            title=t["title"],
            description=t["description"],
            category=t["category"],
            task_type=t["task_type"],
            poster_id=t["poster"].id,
            suggested_price=t["suggested_price"],
            ai_price=t["ai_price"],
            status=t["status"],
            worker_id=t.get("worker").id if t.get("worker") else None,
            escrow_amount=t.get("escrow_amount", 0.0),
            pin=t.get("pin"),
            created_at=datetime.utcnow() - timedelta(hours=random.randint(1, 48)),
        )
        db.add(task)
        tasks.append(task)

    db.commit()
    for t in tasks:
        db.refresh(t)
    print(f"  ✓ {len(tasks)} tasks created")

    task_logo, task_translate, task_fourier, task_video, \
        task_landing, task_instagram, task_cv, task_ml = tasks

    # ─── BIDS ─────────────────────────────────────────────────
    print("Seeding bids...")

    bids_data = [
        # Bids on open tasks
        {"task": task_logo, "bidder": lina, "amount": 2800.0, "message": "Logo design is my specialty, I've done 12 logos for student clubs. I'll deliver PNG + SVG within 24 hours.", "status": BidStatus.pending},
        {"task": task_logo, "bidder": rami, "amount": 2500.0, "message": "I can do this, I use Illustrator daily. Check my previous work.", "status": BidStatus.pending},
        {"task": task_translate, "bidder": rami, "amount": 1600.0, "message": "IELTS 7.5, I've translated 6 academic papers. Technical content is not a problem.", "status": BidStatus.pending},
        {"task": task_fourier, "bidder": sara, "amount": 2000.0, "message": "Math teacher assistant in my faculty. I've tutored 20+ students on signal processing. 2 hours is enough for Fourier.", "status": BidStatus.pending},
        {"task": task_video, "bidder": mehdi, "amount": 3500.0, "message": "Video editor with 2 years experience. Premiere Pro, Final Cut. I'll add subtitles and background music.", "status": BidStatus.pending},
        {"task": task_video, "bidder": rami, "amount": 3000.0, "message": "I edit for my faculty's YouTube channel. Can deliver in 48 hours.", "status": BidStatus.pending},

        # Accepted bids on in_progress tasks
        {"task": task_landing, "bidder": amira, "amount": 4800.0, "message": "I build React and plain HTML sites. Portfolio page is 4 hours max for me.", "status": BidStatus.accepted},
        {"task": task_instagram, "bidder": lina, "amount": 2000.0, "message": "I manage social media for 3 small businesses already. Arabic captions included.", "status": BidStatus.accepted},

        # Rejected bids on in_progress tasks
        {"task": task_landing, "bidder": yacine, "amount": 5000.0, "message": "I can do this.", "status": BidStatus.rejected},

        # Accepted bids on completed tasks
        {"task": task_cv, "bidder": rami, "amount": 1200.0, "message": "English writing is my strength. IELTS certified. I'll format it properly for European applications.", "status": BidStatus.accepted},
        {"task": task_ml, "bidder": amira, "amount": 2500.0, "message": "2nd year ML student, I explain this to juniors every week. 1 hour is plenty.", "status": BidStatus.accepted},
    ]

    bids = []
    for b in bids_data:
        bid = Bid(
            task_id=b["task"].id,
            bidder_id=b["bidder"].id,
            amount=b["amount"],
            message=b["message"],
            status=b["status"],
            created_at=datetime.utcnow() - timedelta(hours=random.randint(1, 24)),
        )
        db.add(bid)
        bids.append(bid)

    db.commit()
    print(f"  ✓ {len(bids)} bids created")

    # ─── RATINGS ──────────────────────────────────────────────
    print("Seeding ratings...")
    ratings_data = [
        # task_cv: sara rated rami, rami rated sara
        {"task": task_cv, "rater": sara, "rated": rami, "score": 5, "comment": "Delivered fast, perfect English, exactly what I needed. Will hire again."},
        {"task": task_cv, "rater": rami, "rated": sara, "score": 5, "comment": "Clear instructions, paid immediately, great communication."},
        # task_ml: lina rated amira, amira rated lina
        {"task": task_ml, "rater": lina, "rated": amira, "score": 4, "comment": "Very clear explanation, patient with my questions. Took slightly longer than 1 hour but worth it."},
        {"task": task_ml, "rater": amira, "rated": lina, "score": 5, "comment": "Engaged student, came prepared with questions. Easy to teach."},
    ]

    for r in ratings_data:
        rating = Rating(
            task_id=r["task"].id,
            rater_id=r["rater"].id,
            rated_id=r["rated"].id,
            score=r["score"],
            comment=r["comment"],
            created_at=datetime.utcnow() - timedelta(hours=random.randint(1, 12)),
        )
        db.add(rating)

    db.commit()
    print(f"  ✓ {len(ratings_data)} ratings created")

    db.close()
    print("\n✅ Database seeded successfully.")
    print("─────────────────────────────────")
    print(f"  Users    : {len(users)}")
    print(f"  Tasks    : {len(tasks)} (4 open, 2 in_progress, 2 completed)")
    print(f"  Bids     : {len(bids)}")
    print(f"  Ratings  : {len(ratings_data)}")
    print("─────────────────────────────────")
    print("\nTest credentials (all passwords: password123):")
    for u in users_data:
        print(f"  {u['email']}")

if __name__ == "__main__":
    seed()
