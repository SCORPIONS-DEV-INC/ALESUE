from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import List
from app.database import get_db
from app.models.reto import Reto
from app.models.usuario import Usuario
from app.schemas.reto import RetoCreate, RetoOut
from app.auth import get_current_profesor, get_current_active_user

router = APIRouter(prefix="/retos", tags=["Retos"])

@router.post("/", response_model=RetoOut)
def crear_reto(
    reto: RetoCreate, 
    db: Session = Depends(get_db),
    current_user: Usuario = Depends(get_current_profesor)
):
    """Crea un nuevo reto (solo profesores)"""
    
    nuevo_reto = Reto(
        titulo=reto.titulo,
        descripcion=reto.descripcion,
        puntos=reto.puntos,
        nivel=reto.nivel,
        materia=reto.materia,
        profesor_id=current_user.id,
        tenant_id=reto.tenant_id
    )
    
    db.add(nuevo_reto)
    db.commit()
    db.refresh(nuevo_reto)
    
    return nuevo_reto

@router.get("/", response_model=List[RetoOut])
def listar_retos(
    db: Session = Depends(get_db),
    current_user: Usuario = Depends(get_current_active_user)
):
    """Lista todos los retos activos"""
    
    retos = db.query(Reto).filter(
        Reto.activo == "true",
        Reto.tenant_id == current_user.tenant_id
    ).all()
    
    return retos

@router.get("/mis-retos", response_model=List[RetoOut])
def mis_retos(
    db: Session = Depends(get_db),
    current_user: Usuario = Depends(get_current_profesor)
):
    """Lista los retos creados por el profesor actual"""
    
    retos = db.query(Reto).filter(
        Reto.profesor_id == current_user.id,
        Reto.activo == "true"
    ).all()
    
    return retos

@router.put("/{reto_id}", response_model=RetoOut)
def actualizar_reto(
    reto_id: int,
    reto_data: RetoCreate,
    db: Session = Depends(get_db),
    current_user: Usuario = Depends(get_current_profesor)
):
    """Actualiza un reto (solo el profesor que lo creó)"""
    
    reto = db.query(Reto).filter(Reto.id == reto_id).first()
    
    if not reto:
        raise HTTPException(status_code=404, detail="Reto no encontrado")
    
    if reto.profesor_id != current_user.id:
        raise HTTPException(status_code=403, detail="No puedes modificar este reto")
    
    # Actualizar campos
    reto.titulo = reto_data.titulo
    reto.descripcion = reto_data.descripcion
    reto.puntos = reto_data.puntos
    reto.nivel = reto_data.nivel
    reto.materia = reto_data.materia
    
    db.commit()
    db.refresh(reto)
    
    return reto

@router.delete("/{reto_id}")
def eliminar_reto(
    reto_id: int,
    db: Session = Depends(get_db),
    current_user: Usuario = Depends(get_current_profesor)
):
    """Elimina un reto (solo el profesor que lo creó)"""
    
    reto = db.query(Reto).filter(Reto.id == reto_id).first()
    
    if not reto:
        raise HTTPException(status_code=404, detail="Reto no encontrado")
    
    if reto.profesor_id != current_user.id:
        raise HTTPException(status_code=403, detail="No puedes eliminar este reto")
    
    # Marcar como inactivo en lugar de eliminar
    reto.activo = "false"
    db.commit()
    
    return {"message": "Reto eliminado exitosamente"}
