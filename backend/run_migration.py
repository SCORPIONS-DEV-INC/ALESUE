#!/usr/bin/env python3
"""
Script para ejecutar migraciones de base de datos
"""

import os
import psycopg2
from psycopg2 import sql
from dotenv import load_dotenv

# Cargar variables de entorno
load_dotenv()

def get_db_connection():
    """Obtener conexión a la base de datos"""
    database_url = os.getenv("DATABASE_URL")
    if not database_url:
        raise ValueError("DATABASE_URL no está configurada en las variables de entorno")
    
    return psycopg2.connect(database_url)

def run_migration(migration_file):
    """Ejecutar un archivo de migración"""
    try:
        with get_db_connection() as conn:
            with conn.cursor() as cursor:
                # Leer el archivo de migración
                with open(migration_file, 'r', encoding='utf-8') as file:
                    migration_sql = file.read()
                
                # Ejecutar la migración
                cursor.execute(migration_sql)
                conn.commit()
                
                print(f"✅ Migración ejecutada exitosamente: {migration_file}")
                
    except psycopg2.Error as e:
        print(f"❌ Error ejecutando migración {migration_file}: {e}")
        raise
    except FileNotFoundError:
        print(f"❌ Archivo de migración no encontrado: {migration_file}")
        raise

def main():
    """Función principal"""
    migration_dir = "migrations"
    migration_file = os.path.join(migration_dir, "001_add_fecha_nacimiento.sql")
    
    print("🚀 Iniciando migración de base de datos...")
    print(f"📁 Ejecutando: {migration_file}")
    
    try:
        run_migration(migration_file)
        print("🎉 ¡Migración completada exitosamente!")
        print("\n📋 Cambios aplicados:")
        print("   - Agregada columna fecha_nacimiento a tabla usuarios")
        print("   - Agregada columna fecha_nacimiento a tabla estudiantes")
        print("   - Creados índices para optimizar consultas")
        print("   - Agregados comentarios de documentación")
        
    except Exception as e:
        print(f"💥 Error durante la migración: {e}")
        print("🔧 Revisa la configuración de la base de datos y las variables de entorno")
        return 1
    
    return 0

if __name__ == "__main__":
    exit(main())
