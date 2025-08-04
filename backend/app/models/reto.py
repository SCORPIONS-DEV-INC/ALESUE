from sqlalchemy import Column, Integer, String
from app.database import Base

class Reto(Base):
    __tablename__ = "retos"

    id = Column(Integer, primary_key=True, index=True)
    titulo = Column(String, nullable=False)
    descripcion = Column(String, nullable=False)
    puntos = Column(Integer, nullable=False, default=10)
    nivel = Column(String, nullable=False)  # facil, medio, dificil
    materia = Column(String, nullable=False)
    profesor_id = Column(Integer, nullable=False)  # ID del profesor que lo creó
    activo = Column(String, nullable=False, default="true")
    tenant_id = Column(String, nullable=False, default="default")
