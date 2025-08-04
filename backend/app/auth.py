from passlib.context import CryptContext
from datetime import datetime, timedelta
from jose import JWTError, jwt
from fastapi import HTTPException, status, Depends
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from sqlalchemy.orm import Session
from app.database import get_db
from app.models.usuario import Usuario, RolEnum
import os

# Configuración de seguridad
SECRET_KEY = os.getenv("SECRET_KEY", "tu_clave_secreta_super_segura_cambiame")
ALGORITHM = "HS256"
ACCESS_TOKEN_EXPIRE_MINUTES = 1440  # 24 horas

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")
security = HTTPBearer()

def hash_password(password: str) -> str:
    """Hashea una contraseña"""
    return pwd_context.hash(password)

def verify_password(plain_password: str, hashed_password: str) -> bool:
    """Verifica una contraseña contra su hash"""
    return pwd_context.verify(plain_password, hashed_password)

def create_access_token(data: dict):
    """Crea un token JWT"""
    to_encode = data.copy()
    expire = datetime.utcnow() + timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
    to_encode.update({"exp": expire})
    encoded_jwt = jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)
    return encoded_jwt

def authenticate_user(db: Session, username: str, password: str):
    """Autentica un usuario"""
    user = db.query(Usuario).filter(Usuario.username == username).first()
    if not user:
        return False
    if not verify_password(password, user.password_hash):
        return False
    return user

async def get_current_user(credentials: HTTPAuthorizationCredentials = Depends(security), db: Session = Depends(get_db)):
    """Obtiene el usuario actual desde el token JWT"""
    credentials_exception = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="No se pudieron validar las credenciales",
        headers={"WWW-Authenticate": "Bearer"},
    )
    
    try:
        payload = jwt.decode(credentials.credentials, SECRET_KEY, algorithms=[ALGORITHM])
        username: str = payload.get("sub")
        if username is None:
            print("[DEBUG] Token sin username válido")
            raise credentials_exception
            
        print(f"[DEBUG] Buscando usuario: {username}")
        
    except JWTError as e:
        print(f"[ERROR] Error al decodificar JWT: {e}")
        raise credentials_exception
    except Exception as e:
        print(f"[ERROR] Error inesperado en auth: {e}")
        raise HTTPException(
            status_code=500,
            detail=f"Error interno de autenticación: {str(e)}"
        )
    
    try:
        user = db.query(Usuario).filter(Usuario.username == username).first()
        if user is None:
            print(f"[DEBUG] Usuario no encontrado: {username}")
            raise credentials_exception
            
        print(f"[DEBUG] Usuario encontrado: {user.id} - {user.username}")
        return user
        
    except Exception as e:
        print(f"[ERROR] Error al buscar usuario en BD: {e}")
        raise HTTPException(
            status_code=500,
            detail=f"Error al consultar base de datos: {str(e)}"
        )

async def get_current_active_user(current_user: Usuario = Depends(get_current_user)):
    """Obtiene el usuario actual activo"""
    try:
        print(f"[DEBUG] Verificando usuario activo: {current_user.username}")
        
        # Verificar si el usuario tiene el campo activo
        if not hasattr(current_user, 'activo'):
            print("[DEBUG] Usuario sin campo 'activo', asumiendo activo")
            return current_user
            
        if current_user.activo != "true":
            print(f"[DEBUG] Usuario inactivo: {current_user.activo}")
            raise HTTPException(status_code=400, detail="Usuario inactivo")
            
        print(f"[DEBUG] Usuario activo confirmado")
        return current_user
        
    except HTTPException:
        raise
    except Exception as e:
        print(f"[ERROR] Error verificando usuario activo: {e}")
        raise HTTPException(
            status_code=500,
            detail=f"Error al verificar estado del usuario: {str(e)}"
        )

async def get_current_profesor(current_user: Usuario = Depends(get_current_active_user)):
    """Verifica que el usuario actual sea profesor o admin"""
    try:
        print(f"[DEBUG] Verificando permisos de profesor para: {current_user.username} (rol: {current_user.rol})")
        
        if current_user.rol not in [RolEnum.PROFESOR, RolEnum.ADMIN]:
            print(f"[DEBUG] Usuario sin permisos de profesor: {current_user.rol}")
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="No tienes permisos de profesor"
            )
            
        print(f"[DEBUG] Permisos de profesor confirmados")
        return current_user
        
    except HTTPException:
        raise
    except Exception as e:
        print(f"[ERROR] Error verificando permisos de profesor: {e}")
        raise HTTPException(
            status_code=500,
            detail=f"Error al verificar permisos: {str(e)}"
        )

async def get_current_estudiante(current_user: Usuario = Depends(get_current_active_user)):
    """Verifica que el usuario actual sea estudiante"""
    if current_user.rol != RolEnum.ESTUDIANTE:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="No tienes permisos de estudiante"
        )
    return current_user
