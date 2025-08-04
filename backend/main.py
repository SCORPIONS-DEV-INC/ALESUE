from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.routers import estudiantes
from app.database import Base, engine

# ✅ Crea las tablas si no existen en la base de datos
Base.metadata.create_all(bind=engine)

# ✅ Instancia de la app FastAPI
app = FastAPI(
    title="API para Estudiantes del Colegio",
    description="API REST usando FastAPI y PostgreSQL para gestión escolar",
    version="1.0.0"
)

# ✅ Configurar CORS para permitir peticiones desde Flutter u otros orígenes
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Reemplaza con origen específico en producción
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# ✅ Incluir las rutas del router de estudiantes
app.include_router(estudiantes.router)









# ✅ Ruta base de prueba
@app.get("/")
def read_root():
    return {"mensaje": "API funcionando correctamente"}
