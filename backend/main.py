from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from database import engine
import models
from routers import auth, tasks   # ← ajouter tasks ici

models.Base.metadata.create_all(bind=engine)

app = FastAPI(title="Khadmli API")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"]
)

app.include_router(auth.router)
app.include_router(tasks.router)  # ← ajouter cette ligne

@app.get("/")
def root():
    return {"status": "Khadmli API running"}