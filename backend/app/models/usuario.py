from sqlalchemy import Column, Integer, String, Enum, DateTime
from sqlalchemy.sql import func
from app.database import Base
import enum

class RolEnum(str, enum.Enum):
    ESTUDIANTE = "estudiante"
    PROFESOR = "profesor"
    ADMIN = "admin"

class Usuario(Base):
    __tablename__ = "usuarios"

    id = Column(Integer, primary_key=True, index=True)
    username = Column(String, unique=True, nullable=False, index=True)
    email = Column(String, unique=True, nullable=False, index=True)
    password_hash = Column(String, nullable=False)
    rol = Column(Enum(RolEnum), nullable=False, default=RolEnum.ESTUDIANTE)
    nombre = Column(String, nullable=False)
    apellido = Column(String, nullable=False)
    dni = Column(String, unique=True, nullable=True)  # Solo para estudiantes
    edad = Column(Integer, nullable=True)  # Solo para estudiantes
    grado = Column(String, nullable=True)  # Solo para estudiantes
    seccion = Column(String, nullable=True)  # Solo para estudiantes
    sexo = Column(String, nullable=True)
    activo = Column(String, nullable=False, default="true")
    tenant_id = Column(String, nullable=False, default="default")
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), onupdate=func.now())
