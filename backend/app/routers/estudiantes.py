from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from app.database import get_db
from app import models, schemas

router = APIRouter(prefix="/estudiantes", tags=["Estudiantes"])

@router.post("/", response_model=schemas.EstudianteOut)
def crear_estudiante(estudiante: schemas.EstudianteCreate, db: Session = Depends(get_db)):
    nuevo = models.Estudiante(**estudiante.dict())
    db.add(nuevo)
    db.commit()
    db.refresh(nuevo)
    return nuevo

@router.get("/", response_model=list[schemas.EstudianteOut])
def listar_estudiantes(db: Session = Depends(get_db)):
    return db.query(models.Estudiante).all()
