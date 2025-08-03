from pydantic import BaseModel
from typing import Optional

class EstudianteBase(BaseModel):
    dni: str
    nombre: str
    apellido: str
    edad: int
    grado: str
    seccion: str
    sexo: str
    correo: str
    tenant_id: Optional[str] = "default"

class EstudianteCreate(EstudianteBase):
    pass

class EstudianteOut(EstudianteBase):
    id: int

    class Config:
        orm_mode = True
