from fastapi import FastAPI, Depends, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from database import get_db
from auth import hash_password, verify_password, create_access_token, decode_token
from schemas import LoginRequest, RegisterRequest, EntregaRequest
from datetime import datetime

app = FastAPI(title="Paquexpress API")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


# ==================== AUTH ====================

@app.post("/register")
def register(req: RegisterRequest, conn=Depends(get_db)):
    cursor = conn.cursor()
    hashed = hash_password(req.password)
    try:
        cursor.execute(
            "INSERT INTO agentes (nombre, email, password_hash) VALUES (%s, %s, %s)",
            (req.nombre, req.email, hashed),
        )
        conn.commit()
        return {"msg": "Agente registrado", "id": cursor.lastrowid}
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))
    finally:
        cursor.close()


@app.post("/login")
def login(req: LoginRequest, conn=Depends(get_db)):
    cursor = conn.cursor(dictionary=True)
    cursor.execute("SELECT * FROM agentes WHERE email = %s", (req.email,))
    agente = cursor.fetchone()
    cursor.close()
    if not agente or not verify_password(req.password, agente["password_hash"]):
        raise HTTPException(status_code=401, detail="Credenciales invalidas")
    token = create_access_token(
        {"sub": str(agente["id"]), "nombre": agente["nombre"]}
    )
    return {
        "access_token": token,
        "token_type": "bearer",
        "nombre": agente["nombre"],
    }


# ==================== PAQUETES ====================

@app.get("/paquetes")
def get_paquetes(agente_id: int = Depends(decode_token), conn=Depends(get_db)):
    cursor = conn.cursor(dictionary=True)
    cursor.execute(
        "SELECT id, codigo, direccion_destino, latitud_destino, longitud_destino, estado "
        "FROM paquetes WHERE agente_id = %s AND estado = 'pendiente'",
        (agente_id,),
    )
    paquetes = cursor.fetchall()
    cursor.close()
    return paquetes


@app.post("/entregar")
def entregar_paquete(
    req: EntregaRequest,
    agente_id: int = Depends(decode_token),
    conn=Depends(get_db),
):
    cursor = conn.cursor(dictionary=True)
    cursor.execute(
        "SELECT * FROM paquetes WHERE id = %s AND agente_id = %s",
        (req.paquete_id, agente_id),
    )
    paquete = cursor.fetchone()
    if not paquete:
        cursor.close()
        raise HTTPException(status_code=404, detail="Paquete no encontrado")
    if paquete["estado"] == "entregado":
        cursor.close()
        raise HTTPException(status_code=400, detail="Paquete ya entregado")

    cursor.execute(
        "UPDATE paquetes SET estado='entregado', foto_evidencia=%s, "
        "latitud_entrega=%s, longitud_entrega=%s, fecha_entrega=%s WHERE id=%s",
        (req.foto_base64, req.latitud, req.longitud, datetime.now(), req.paquete_id),
    )
    conn.commit()
    cursor.close()
    return {"msg": "Paquete marcado como entregado"}


@app.get("/historial")
def historial(agente_id: int = Depends(decode_token), conn=Depends(get_db)):
    cursor = conn.cursor(dictionary=True)
    cursor.execute(
        "SELECT id, codigo, direccion_destino, estado, fecha_entrega "
        "FROM paquetes WHERE agente_id = %s AND estado = 'entregado'",
        (agente_id,),
    )
    result = cursor.fetchall()
    cursor.close()
    return result
