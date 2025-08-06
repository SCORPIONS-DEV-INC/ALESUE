from pydantic import BaseModel, validator
from typing import Optional
from datetime import date


class EstudianteBase(BaseModel):
    dni: str
    nombre: str
    apellido: str
    fecha_nacimiento: date  # Nueva fecha de nacimiento
    edad: Optional[int] = None  # Se calculará automáticamente
    grado: str
    seccion: str
    sexo: str
    correo: str
    password: str
    tenant_id: str 

    @validator('edad', always=True)
    def calcular_edad_automatica(cls, v, values):
        """Calcula la edad automáticamente basada en la fecha de nacimiento"""
        if 'fecha_nacimiento' in values and values['fecha_nacimiento']:
            from app.utils.edad_utils import calcular_edad
            return calcular_edad(values['fecha_nacimiento'])
        return v

class EstudianteCreate(EstudianteBase):
    pass

class EstudianteOut(EstudianteBase):
    id: int

    class Config:
        orm_mode = True
