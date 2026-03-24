import mysql.connector
from mysql.connector import pooling

db_config = {
    "host": "localhost",
    "user": "root",
    "password": "",  # <-- CAMBIA ESTO por tu contraseña de MySQL
    "database": "paquexpress"
}

pool = pooling.MySQLConnectionPool(pool_name="pool", pool_size=5, **db_config)

def get_db():
    conn = pool.get_connection()
    try:
        yield conn
    finally:
        conn.close()
