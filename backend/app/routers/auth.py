from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List
from app.database import get_db
from app.models.usuario import Usuario
from app.schemas.usuario import UsuarioCreate, UsuarioOut, UsuarioLogin, Token, EstudianteCreateByProfesor, RankingEstudiante
from app.auth import hash_password, authenticate_user, create_access_token, get_current_profesor

router = APIRouter(prefix="/auth", tags=["Autenticación"])

@router.post("/register", response_model=UsuarioOut)
def registrar_usuario(usuario: UsuarioCreate, db: Session = Depends(get_db)):
    """Registra un nuevo usuario (estudiante o profesor)"""
    
    # Verificar si el username ya existe
    if db.query(Usuario).filter(Usuario.username == usuario.username).first():
        raise HTTPException(
            status_code=400,
            detail="El nombre de usuario ya está registrado"
        )
    
    # Verificar si el email ya existe
    if db.query(Usuario).filter(Usuario.email == usuario.email).first():
        raise HTTPException(
            status_code=400,
            detail="El email ya está registrado"
        )
    
    # Verificar DNI si es estudiante
    if usuario.rol.value == "estudiante" and usuario.dni:
        if db.query(Usuario).filter(Usuario.dni == usuario.dni).first():
            raise HTTPException(
                status_code=400,
                detail="El DNI ya está registrado"
            )
    
    # Hashear la contraseña
    password_hash = hash_password(usuario.password)
    
    # Crear el usuario
    nuevo_usuario = Usuario(
        username=usuario.username,
        email=usuario.email,
        password_hash=password_hash,
        rol=usuario.rol,
        nombre=usuario.nombre,
        apellido=usuario.apellido,
        dni=usuario.dni,
        edad=usuario.edad,
        grado=usuario.grado,
        seccion=usuario.seccion,
        sexo=usuario.sexo,
        tenant_id=usuario.tenant_id
    )
    
    db.add(nuevo_usuario)
    db.commit()
    db.refresh(nuevo_usuario)
    
    return nuevo_usuario

@router.post("/login", response_model=Token)
def login(user_credentials: UsuarioLogin, db: Session = Depends(get_db)):
    """Autentica un usuario y devuelve un token JWT"""
    
    user = authenticate_user(db, user_credentials.username, user_credentials.password)
    
    if not user:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Usuario o contraseña incorrectos",
            headers={"WWW-Authenticate": "Bearer"},
        )
    
    if user.activo != "true":
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Usuario inactivo"
        )
    
    # Crear token
    access_token = create_access_token(
        data={"sub": user.username, "user_id": user.id, "rol": user.rol.value}
    )
    
    return {
        "access_token": access_token,
        "token_type": "bearer",
        "user_info": user
    }

@router.post("/crear-estudiante", response_model=UsuarioOut)
def crear_estudiante_por_profesor(
    estudiante: EstudianteCreateByProfesor, 
    db: Session = Depends(get_db),
    current_user: Usuario = Depends(get_current_profesor)
):
    """Permite a un profesor crear una cuenta de estudiante"""
    
    # Verificar si el DNI ya existe
    if db.query(Usuario).filter(Usuario.dni == estudiante.dni).first():
        raise HTTPException(
            status_code=400,
            detail="El DNI ya está registrado"
        )
    
    # Verificar si el email ya existe
    if db.query(Usuario).filter(Usuario.email == estudiante.email).first():
        raise HTTPException(
            status_code=400,
            detail="El email ya está registrado"
        )
    
    # Hashear la contraseña
    password_hash = hash_password(estudiante.password)
    
    # Crear el estudiante
    nuevo_estudiante = Usuario(
        username=estudiante.dni,  # DNI como username
        email=estudiante.email,
        password_hash=password_hash,
        rol="estudiante",
        nombre=estudiante.nombre,
        apellido=estudiante.apellido,
        dni=estudiante.dni,
        edad=estudiante.edad,
        grado=estudiante.grado,
        seccion=estudiante.seccion,
        sexo=estudiante.sexo,
        tenant_id=current_user.tenant_id  # Mismo tenant que el profesor
    )
    
    db.add(nuevo_estudiante)
    db.commit()
    db.refresh(nuevo_estudiante)
    
    return nuevo_estudiante

@router.get("/ranking", response_model=List[RankingEstudiante])
def obtener_ranking(
    materia: str = None,
    grado: str = None,
    db: Session = Depends(get_db),
    current_user: Usuario = Depends(get_current_profesor)
):
    """Obtiene el ranking de estudiantes por puntos"""
    
    query = db.query(Usuario).filter(
        Usuario.rol == "estudiante",
        Usuario.tenant_id == current_user.tenant_id,
        Usuario.activo == "true"
    )
    
    if grado:
        query = query.filter(Usuario.grado == grado)
    
    if materia:
        # Ordenar por materia específica
        if materia == "matematicas":
            query = query.order_by(Usuario.puntos_matematicas.desc())
        elif materia == "comunicacion":
            query = query.order_by(Usuario.puntos_comunicacion.desc())
        elif materia == "personal_social":
            query = query.order_by(Usuario.puntos_personal_social.desc())
        elif materia == "ciencia_tecnologia":
            query = query.order_by(Usuario.puntos_ciencia_tecnologia.desc())
        elif materia == "ingles":
            query = query.order_by(Usuario.puntos_ingles.desc())
        else:
            query = query.order_by(Usuario.puntos_totales.desc())
    else:
        # Ordenar por puntos totales
        query = query.order_by(Usuario.puntos_totales.desc())
    
    estudiantes = query.limit(20).all()  # Top 20
    return estudiantes
