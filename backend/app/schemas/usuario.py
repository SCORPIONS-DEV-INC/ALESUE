from pydantic import BaseModel, EmailStr
from typing import Optional
from app.models.usuario import RolEnum

class UsuarioBase(BaseModel):
    username: str
    email: str
    nombre: str
    apellido: str
    rol: RolEnum
    dni: Optional[str] = None
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
    
    class Config:
        orm_mode = True

class UsuarioLogin(BaseModel):
    username: str
    password: str

class Token(BaseModel):
    access_token: str
    token_type: str
    user_info: UsuarioOut
