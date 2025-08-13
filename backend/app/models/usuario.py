from sqlalchemy import Column, Integer, String, Enum, DateTime, Date
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
    dni = Column(String, unique=True, nullable=False)  # Obligatorio para todos los usuarios
    fecha_nacimiento = Column(Date, nullable=True)  # Solo para estudiantes
    edad = Column(Integer, nullable=True)  # Solo para estudiantes, se calculará automáticamente
    grado = Column(String, nullable=True)  # Solo para estudiantes
    seccion = Column(String, nullable=True)  # Solo para estudiantes
    sexo = Column(String, nullable=True)
    # Campos para puntuación por materia
    puntos_matematicas = Column(Integer, nullable=False, default=0)
    puntos_comunicacion = Column(Integer, nullable=False, default=0)
    puntos_personal_social = Column(Integer, nullable=False, default=0)
    puntos_ciencia_tecnologia = Column(Integer, nullable=False, default=0)
    puntos_ingles = Column(Integer, nullable=False, default=0)
    puntos_totales = Column(Integer, nullable=False, default=0)
    activo = Column(String, nullable=False, default="true")
    tenant_id = Column(String, nullable=False, default="default")
    profile_image_url = Column(String, nullable=True)
    # Removido temporalmente: created_at = Column(DateTime(timezone=True), server_default=func.now())
    # Removido temporalmente: updated_at = Column(DateTime(timezone=True), onupdate=func.now())
