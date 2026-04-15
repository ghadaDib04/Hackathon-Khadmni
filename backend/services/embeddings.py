from sentence_transformers import SentenceTransformer
import numpy as np
import json

# Loaded once when the server starts — not on every request
_model = SentenceTransformer("all-MiniLM-L6-v2")

def embed(text: str) -> list[float]:

    vector = _model.encode(text, normalize_embeddings=True)
    return vector.tolist()  # store as plain list (JSON-serializable)

def cosine_similarity(vec_a: list[float], vec_b: list[float]) -> float:
    a = np.array(vec_a)
    b = np.array(vec_b)
    return float(np.dot(a, b))

def score_match(task_vector: list[float], skill_vector: list[float]) -> float:
  
    return round(cosine_similarity(task_vector, skill_vector), 2)

def recommend_students(task_vector: list[float], students: list) -> list:
    """
    Prend le vecteur d'une tâche et une liste d'étudiants.
    Retourne les étudiants triés par match score, du meilleur au moins bon.
    """
    import json
    
    results = []
    for student in students:
        # Récupérer le vecteur du profil étudiant
        if not student.get("skill_vector"):
            continue
        
        try:
            student_vector = json.loads(student["skill_vector"])
        except:
            continue
        
        match = score_match(task_vector, student_vector)
        
        results.append({
            "id": student["id"],
            "name": student["name"],
            "university": student["university"],
            "skills": student["skills"],
            "match_score": match
        })
    
    # Trier du meilleur score au moins bon
    results.sort(key=lambda x: x["match_score"], reverse=True)
    return results


def recommend_tasks(skill_vector: list[float], tasks: list) -> list:
    import json
    
    results = []
    for task in tasks:
        if not task.get("task_vector"):
            results.append({**task, "match_score": 0.0})
            continue
        
        try:
            task_vector = json.loads(task["task_vector"])
        except:
            results.append({**task, "match_score": 0.0})
            continue
        
        match = score_match(skill_vector, task_vector)
        results.append({**task, "match_score": match})
    
    results.sort(key=lambda x: x["match_score"], reverse=True)
    return results