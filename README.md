# Paquexpress - App de Entregas

Aplicacion movil para agentes de entrega de Paquexpress S.A. de C.V.

## Tecnologias
- **App:** Flutter (Dart)
- **API:** FastAPI (Python)
- **BD:** MySQL

## Funcionalidades
- Login seguro con JWT y contrasenas encriptadas con bcrypt
- Lista de paquetes pendientes por agente
- Captura de foto como evidencia de entrega (camara)
- Obtencion de ubicacion GPS al momento de entrega
- Visualizacion de direccion destino en Google Maps
- Boton "Paquete Entregado" que guarda foto + GPS + timestamp en BD

## Instalacion

### 1. Base de datos
```bash
mysql -u root -p < db/schema.sql
```

### 2. API
```bash
cd api
pip install -r requirements.txt
# Editar database.py con tu password de MySQL
uvicorn main:app --reload --host 0.0.0.0 --port 8000
```
Registra un agente en: http://localhost:8000/docs -> POST /register

### 3. App Flutter
```bash
cd app
flutter pub get
flutter run
```

### Configuracion
- **Flutter Web:** La API se accede en `localhost:8000`
- **Emulador Android:** Cambiar `baseUrl` en `api_service.dart` a `http://10.0.2.2:8000`
- **Dispositivo fisico:** Cambiar `baseUrl` por tu IP local
- **Google Maps:** Agregar tu API Key en `AndroidManifest.xml`

## Estructura
```
paquexpress/
├── api/           -> FastAPI backend
├── db/            -> Scripts SQL
├── app/           -> Flutter app
└── README.md
```

## Autor
[Tu nombre] - [Tu matricula]
