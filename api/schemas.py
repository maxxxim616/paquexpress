from pydantic import BaseModel
from typing import Optional


class LoginRequest(BaseModel):
    email: str
    password: str


class RegisterRequest(BaseModel):
    nombre: str
    email: str
    password: str


class EntregaRequest(BaseModel):
    paquete_id: int
    foto_base64: str
    latitud: float
    longitud: float


class PaqueteResponse(BaseModel):
    id: int
    codigo: str
    direccion_destino: str
    latitud_destino: Optional[float]
    longitud_destino: Optional[float]
    estado: str
