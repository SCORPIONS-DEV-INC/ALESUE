from fastapi import APIRouter, UploadFile, File, Depends, HTTPException
from sqlalchemy.orm import Session
from app.database import get_db
from app.models.usuario import Usuario
import os
from starlette.responses import JSONResponse

router = APIRouter(prefix="/usuarios", tags=["Usuarios"])

UPLOAD_DIR = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), '..', '..', 'static', 'profile_images')
os.makedirs(UPLOAD_DIR, exist_ok=True)

@router.post("/{user_id}/profile-image")
def upload_profile_image(user_id: int, file: UploadFile = File(...), db: Session = Depends(get_db)):
    user = db.query(Usuario).filter(Usuario.id == user_id).first()
    if not user:
        raise HTTPException(status_code=404, detail="Usuario no encontrado")
    # Guardar archivo
    ext = os.path.splitext(file.filename)[1]
    filename = f"user_{user_id}{ext}"
    file_path = os.path.join(UPLOAD_DIR, filename)
    with open(file_path, "wb") as f:
        f.write(file.file.read())
    # URL pública (ajusta según tu server)
    url = f"/static/profile_images/{filename}"
    user.profile_image_url = url
    db.commit()
    return JSONResponse(content={"profile_image_url": url})
