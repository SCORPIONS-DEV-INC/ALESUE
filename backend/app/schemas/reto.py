from pydantic import BaseModel
from typing import Optional
from app.models.reto import MateriaEnum, NivelEnum

class RetoBase(BaseModel):
    titulo: str
    descripcion: str
    puntos: int = 10
    nivel: NivelEnum
    materia: MateriaEnum
    tenant_id: str = "default"

class RetoCreate(RetoBase):
    pass

class RetoOut(RetoBase):
    id: int
    profesor_id: int
    activo: str
    
    class Config:
        orm_mode = True

# Esquema para completar un reto
class CompletarReto(BaseModel):
    reto_id: int
    puntos_obtenidos: int

class ProgresoRetoOut(BaseModel):
    id: int
    estudiante_id: int
    reto_id: int
    completado: str
    puntos_obtenidos: int
    fecha_completado: Optional[str] = None
    
    class Config:
        orm_mode = True
