from sqlalchemy import Column, Integer, String, Date
from app.database import Base

class Estudiante(Base):
    __tablename__ = "estudiantes"

    id = Column(Integer, primary_key=True, index=True)
    dni = Column(String, unique=True, nullable=False)
    nombre = Column(String, nullable=False)
    apellido = Column(String, nullable=False)
    fecha_nacimiento = Column(Date, nullable=False)  # Nueva columna para fecha de nacimiento
    edad = Column(Integer, nullable=False)  # Se calculará automáticamente
    grado = Column(String, nullable=False)
    seccion = Column(String, nullable=False)
    sexo = Column(String, nullable=False)
    correo = Column(String, nullable=False)
    password = Column(String, nullable=False)
    tenant_id = Column(String, nullable=False, default="default")
