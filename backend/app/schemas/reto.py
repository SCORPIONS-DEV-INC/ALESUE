from pydantic import BaseModel
from typing import Optional

class RetoBase(BaseModel):
    titulo: str
    descripcion: str
    puntos: int = 10
    nivel: str  # facil, medio, dificil
    materia: str
    tenant_id: str = "default"

class RetoCreate(RetoBase):
    pass

class RetoOut(RetoBase):
    id: int
    profesor_id: int
    activo: str
    
    class Config:
        orm_mode = True
