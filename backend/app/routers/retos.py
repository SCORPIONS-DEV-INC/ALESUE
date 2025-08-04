from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import List
from app.database import get_db
from app.models.reto import Reto
from app.models.usuario import Usuario
from app.models.progreso_reto import ProgresoReto
from app.schemas.reto import RetoCreate, RetoOut, CompletarReto, ProgresoRetoOut
from app.auth import get_current_profesor, get_current_active_user, get_current_estudiante
from sqlalchemy.sql import func

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

@router.post("/completar", response_model=ProgresoRetoOut)
def completar_reto(
    datos: CompletarReto,
    db: Session = Depends(get_db),
    current_user: Usuario = Depends(get_current_estudiante)
):
    """Permite a un estudiante completar un reto"""
    
    # Verificar que el reto existe
    reto = db.query(Reto).filter(Reto.id == datos.reto_id, Reto.activo == "true").first()
    if not reto:
        raise HTTPException(status_code=404, detail="Reto no encontrado")
    
    # Verificar si ya completó este reto
    progreso_existente = db.query(ProgresoReto).filter(
        ProgresoReto.estudiante_id == current_user.id,
        ProgresoReto.reto_id == datos.reto_id
    ).first()
    
    if progreso_existente and progreso_existente.completado == "true":
        raise HTTPException(status_code=400, detail="Ya completaste este reto")
    
    # Crear o actualizar progreso
    if progreso_existente:
        progreso_existente.completado = "true"
        progreso_existente.puntos_obtenidos = datos.puntos_obtenidos
        progreso_existente.fecha_completado = func.now()
        progreso = progreso_existente
    else:
        progreso = ProgresoReto(
            estudiante_id=current_user.id,
            reto_id=datos.reto_id,
            completado="true",
            puntos_obtenidos=datos.puntos_obtenidos,
            fecha_completado=func.now()
        )
        db.add(progreso)
    
    # Actualizar puntos del estudiante según la materia
    if reto.materia.value == "matematicas":
        current_user.puntos_matematicas += datos.puntos_obtenidos
    elif reto.materia.value == "comunicacion":
        current_user.puntos_comunicacion += datos.puntos_obtenidos
    elif reto.materia.value == "personal_social":
        current_user.puntos_personal_social += datos.puntos_obtenidos
    elif reto.materia.value == "ciencia_tecnologia":
        current_user.puntos_ciencia_tecnologia += datos.puntos_obtenidos
    elif reto.materia.value == "ingles":
        current_user.puntos_ingles += datos.puntos_obtenidos
    
    # Actualizar puntos totales
    current_user.puntos_totales += datos.puntos_obtenidos
    
    db.commit()
    db.refresh(progreso)
    
    return progreso

@router.get("/mi-progreso", response_model=List[ProgresoRetoOut])
def obtener_mi_progreso(
    db: Session = Depends(get_db),
    current_user: Usuario = Depends(get_current_estudiante)
):
    """Obtiene el progreso del estudiante actual"""
    
    progreso = db.query(ProgresoReto).filter(
        ProgresoReto.estudiante_id == current_user.id
    ).all()
    
    return progreso

@router.get("/por-materia/{materia}", response_model=List[RetoOut])
def listar_retos_por_materia(
    materia: str,
    db: Session = Depends(get_db),
    current_user: Usuario = Depends(get_current_active_user)
):
    """Lista retos filtrados por materia"""
    
    retos = db.query(Reto).filter(
        Reto.activo == "true",
        Reto.tenant_id == current_user.tenant_id,
        Reto.materia == materia
    ).all()
    
    return retos
