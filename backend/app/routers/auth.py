from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from app.database import get_db
from app.models.usuario import Usuario
from app.schemas.usuario import UsuarioCreate, UsuarioOut, UsuarioLogin, Token
from app.auth import hash_password, authenticate_user, create_access_token

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
