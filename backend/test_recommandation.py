import json
from services.embeddings import embed, recommend_students, recommend_tasks

# ── Simuler 3 étudiants en base ──────────────────────────────────────────────
students = [
    {
        "id": 1,
        "name": "Yacine",
        "university": "USTHB",
        "skills": "Flutter Figma UI Design mobile",
        "skill_vector": json.dumps(embed("Flutter Figma UI Design mobile"))
    },
    {
        "id": 2,
        "name": "Rami",
        "university": "ESI",
        "skills": "HTML CSS JavaScript web frontend",
        "skill_vector": json.dumps(embed("HTML CSS JavaScript web frontend"))
    },
    {
        "id": 3,
        "name": "Sara",
        "university": "Constantine 2",
        "skills": "Python data science machine learning AI",
        "skill_vector": json.dumps(embed("Python data science machine learning AI"))
    },
]

# ── Simuler 3 tâches en base ──────────────────────────────────────────────────
tasks = [
    {
        "id": 1,
        "title": "Build a landing page",
        "category": "Web",
        "task_vector": json.dumps(embed("Build a landing page HTML CSS JavaScript"))
    },
    {
        "id": 2,
        "title": "Create a Flutter app screen",
        "category": "Mobile",
        "task_vector": json.dumps(embed("Create a Flutter app screen mobile UI"))
    },
    {
        "id": 3,
        "title": "Analyze survey data",
        "category": "Data",
        "task_vector": json.dumps(embed("Analyze survey data Python visualization"))
    },
]

# ── Test 1 : Qui peut faire la tâche web ? ────────────────────────────────────
print("\n═══ Tâche : Landing page web ═══")
task_vector = json.loads(tasks[0]["task_vector"])
ranked = recommend_students(task_vector, students)
for i, s in enumerate(ranked):
    print(f"  #{i+1} {s['name']} ({s['university']}) → {s['match_score']}")

# ── Test 2 : Quelles tâches pour Sara ? ──────────────────────────────────────
print("\n═══ Feed de Sara (Python/AI) ═══")
sara_vector = embed("Python data science machine learning AI")
ranked_tasks = recommend_tasks(sara_vector, tasks)
for i, t in enumerate(ranked_tasks):
    print(f"  #{i+1} {t['title']} → {t['match_score']}")