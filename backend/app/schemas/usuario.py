from pydantic import BaseModel, EmailStr, validator
from typing import Optional
from datetime import date
from app.models.usuario import RolEnum

class UsuarioBase(BaseModel):
    username: str
    email: str
    nombre: str
    apellido: str
    rol: RolEnum
    dni: str  # Obligatorio para todos
    fecha_nacimiento: Optional[date] = None  # Solo para estudiantes
    edad: Optional[int] = None  # Se calculará automáticamente para estudiantes
    grado: Optional[str] = None
    seccion: Optional[str] = None
    sexo: Optional[str] = None
    tenant_id: str = "default"

    @validator('edad', always=True)
    def calcular_edad_automatica(cls, v, values):
        """Calcula la edad automáticamente para estudiantes"""
        if (values.get('rol') == RolEnum.ESTUDIANTE and 
            'fecha_nacimiento' in values and values['fecha_nacimiento']):
            from app.utils.edad_utils import calcular_edad
            return calcular_edad(values['fecha_nacimiento'])
        return v

class UsuarioCreate(UsuarioBase):
    password: str

class UsuarioOut(UsuarioBase):
    id: int
    activo: str
    puntos_matematicas: int = 0
    puntos_comunicacion: int = 0
    puntos_personal_social: int = 0
    puntos_ciencia_tecnologia: int = 0
    puntos_ingles: int = 0
    puntos_totales: int = 0
    
    class Config:
        orm_mode = True

class UsuarioLogin(BaseModel):
    username: str
    password: str

class Token(BaseModel):
    access_token: str
    token_type: str
    user_info: UsuarioOut

# Esquema para que profesores creen estudiantes
class EstudianteCreateByProfesor(BaseModel):
    dni: str
    nombre: str
    apellido: str
    fecha_nacimiento: date  # Nueva fecha de nacimiento
    edad: Optional[int] = None  # Se calculará automáticamente
    grado: str
    seccion: str
    sexo: str
    email: Optional[str] = None  # Email opcional
    password: str
    tenant_id: str = "default"

    @validator('edad', always=True)
    def calcular_edad_automatica(cls, v, values):
        """Calcula la edad automáticamente basada en la fecha de nacimiento"""
        if 'fecha_nacimiento' in values and values['fecha_nacimiento']:
            from app.utils.edad_utils import calcular_edad
            return calcular_edad(values['fecha_nacimiento'])
        return v

# Esquema para ranking
class RankingEstudiante(BaseModel):
    id: int
    nombre: str
    apellido: str
    grado: str
    seccion: str
    puntos_totales: int
    puntos_matematicas: int
    puntos_comunicacion: int
    puntos_personal_social: int
    puntos_ciencia_tecnologia: int
    puntos_ingles: int
    
    class Config:
        orm_mode = True
