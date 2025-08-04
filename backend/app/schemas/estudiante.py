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
    password: str
    tenant_id: str 

class EstudianteCreate(EstudianteBase):
    pass

class EstudianteOut(EstudianteBase):
    id: int

    class Config:
        orm_mode = True
