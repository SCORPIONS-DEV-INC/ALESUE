from sqlalchemy import Column, Integer, String, Enum, DateTime
from sqlalchemy.sql import func
from app.database import Base
import enum

class MateriaEnum(str, enum.Enum):
    MATEMATICAS = "matematicas"
    COMUNICACION = "comunicacion"
    PERSONAL_SOCIAL = "personal_social"
    CIENCIA_TECNOLOGIA = "ciencia_tecnologia"
    INGLES = "ingles"

class NivelEnum(str, enum.Enum):
    FACIL = "facil"
    MEDIO = "medio"
    DIFICIL = "dificil"

class Reto(Base):
    __tablename__ = "retos"

    id = Column(Integer, primary_key=True, index=True)
    titulo = Column(String, nullable=False)
    descripcion = Column(String, nullable=False)
    puntos = Column(Integer, nullable=False, default=10)
    nivel = Column(Enum(NivelEnum), nullable=False)
    materia = Column(Enum(MateriaEnum), nullable=False)
    profesor_id = Column(Integer, nullable=False)  # ID del profesor que lo creó
    activo = Column(String, nullable=False, default="true")
    tenant_id = Column(String, nullable=False, default="default")
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    # Removido temporalmente: updated_at = Column(DateTime(timezone=True), onupdate=func.now())
