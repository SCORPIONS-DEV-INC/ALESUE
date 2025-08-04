from pydantic import BaseModel, EmailStr
from typing import Optional
from app.models.usuario import RolEnum

class UsuarioBase(BaseModel):
    username: str
    email: str
    nombre: str
    apellido: str
    rol: RolEnum
    dni: str  # Obligatorio para todos
    edad: Optional[int] = None
    grado: Optional[str] = None
    seccion: Optional[str] = None
    sexo: Optional[str] = None
    tenant_id: str = "default"

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
    edad: int
    grado: str
    seccion: str
    sexo: str
    email: Optional[str] = None  # Email opcional
    password: str
    tenant_id: str = "default"

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
