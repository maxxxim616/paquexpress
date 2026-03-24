CREATE DATABASE IF NOT EXISTS paquexpress;
USE paquexpress;

CREATE TABLE agentes (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE paquetes (
    id INT AUTO_INCREMENT PRIMARY KEY,
    codigo VARCHAR(50) UNIQUE NOT NULL,
    direccion_destino VARCHAR(255) NOT NULL,
    latitud_destino DOUBLE,
    longitud_destino DOUBLE,
    agente_id INT,
    estado ENUM('pendiente', 'entregado') DEFAULT 'pendiente',
    foto_evidencia LONGTEXT,
    latitud_entrega DOUBLE,
    longitud_entrega DOUBLE,
    fecha_entrega TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (agente_id) REFERENCES agentes(id)
);
