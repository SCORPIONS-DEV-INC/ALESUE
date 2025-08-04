from sqlalchemy import Column, Integer, String, ForeignKey, DateTime
from sqlalchemy.sql import func
from app.database import Base

class ProgresoReto(Base):
    __tablename__ = "progreso_retos"

    id = Column(Integer, primary_key=True, index=True)
    estudiante_id = Column(Integer, ForeignKey("usuarios.id"), nullable=False)
    reto_id = Column(Integer, ForeignKey("retos.id"), nullable=False)
    completado = Column(String, nullable=False, default="false")  # "true" o "false"
    puntos_obtenidos = Column(Integer, nullable=False, default=0)
    fecha_completado = Column(DateTime(timezone=True), nullable=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    # Removido temporalmente: updated_at = Column(DateTime(timezone=True), onupdate=func.now())
