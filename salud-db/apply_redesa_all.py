#!/usr/bin/env python3
"""
apply_redesa_all.py — Script unificado para la inyección de esquemas y DDLs de REDESA.

Conecta a los puertos expuestos en la máquina host (+1):
  - PostgreSQL (relacional + TimescaleDB + pgvector): localhost:5433
  - MongoDB (document store): localhost:27018
  - OpenSearch (search platform): localhost:9201
  - MinIO (object storage): localhost:9002

Uso:
  python salud-db/apply_redesa_all.py
"""
import json
import os
import subprocess
import sys
import time
import urllib.request
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parent.parent
SQL_DIR = REPO_ROOT / "SQL"
NOSQL_DIR = REPO_ROOT / "NoSQL"

PG_HOST = "localhost"
PG_PORT = "5433"
PG_USER = "salud"
PG_DB = "salud"
PG_PASS = "salud_pass_dev"

MONGO_HOST = "localhost"
MONGO_PORT = "27018"
MONGO_DB = "salud_document_store"

OPENSEARCH_URL = "http://localhost:9201"


def run_psql(sql_filepath: Path):
    """Ejecuta psql en el contenedor de postgres o via psql local contra el puerto 5433."""
    print(f"── Aplicando SQL: {sql_filepath.name} en localhost:{PG_PORT}...")
    env = os.environ.copy()
    env["PGPASSWORD"] = PG_PASS
    
    # Intentar ejecutar con docker exec si el contenedor existe, o psql nativo
    cmd_docker = [
        "docker", "exec", "-i", "redesa-postgres",
        "psql", "-U", PG_USER, "-d", PG_DB, "-v", "ON_ERROR_STOP=1"
    ]
    
    try:
        with open(sql_filepath, "r", encoding="utf-8") as f:
            res = subprocess.run(cmd_docker, stdin=f, env=env, capture_output=True, text=True)
            if res.returncode == 0:
                print(f"  ✅ {sql_filepath.name} aplicado con éxito vía Docker exec.")
                return True
            else:
                print(f"  ⚠️ Docker exec dio aviso/error: {res.stderr[:200]}")
    except Exception as ex:
        print(f"  ⚠️ Docker exec no disponible ({ex}), probando psql local...")

    # Fallback a psql nativo local
    psql_local = r"C:\Program Files\PostgreSQL\18\bin\psql.exe"
    if not Path(psql_local).exists():
        psql_local = "psql"
        
    cmd_local = [
        psql_local, "-h", PG_HOST, "-p", PG_PORT, "-U", PG_USER, "-d", PG_DB,
        "-v", "ON_ERROR_STOP=1", "-f", str(sql_filepath)
    ]
    res_local = subprocess.run(cmd_local, env=env, capture_output=True, text=True)
    if res_local.returncode == 0:
        print(f"  ✅ {sql_filepath.name} aplicado con éxito vía psql local.")
        return True
    else:
        print(f"  ❌ Error en psql local: {res_local.stderr}")
        return False


def apply_opensearch():
    """Aplica los 13 mappings JSON en OpenSearch puerto 9201."""
    os_dir = NOSQL_DIR / "57_search_platform_opensearch"
    if not os_dir.exists():
        print(f"  ⚠️ Directorio {os_dir} no existe.")
        return

    print("\n── Aplicando Mappings de OpenSearch en localhost:9201...")
    for mapping_file in os_dir.glob("*.mapping.json"):
        index_name = mapping_file.name.replace(".mapping.json", "")
        url = f"{OPENSEARCH_URL}/{index_name}"
        data = mapping_file.read_bytes()
        req = urllib.request.Request(url, data=data, headers={"Content-Type": "application/json"}, method="PUT")
        try:
            with urllib.request.urlopen(req) as resp:
                print(f"  ✅ Índice OpenSearch '{index_name}' creado (HTTP {resp.status}).")
        except Exception as e:
            print(f"  ⚠️ Índice '{index_name}': {e}")


def main():
    print("=" * 60)
    print("🚀 REDESA - Inyector Unificado de DDL y Esquemas NoSQL")
    print("=" * 60)

    # 1. Base Relacional SQL (Módulos 00-54)
    apply_all_sql = SQL_DIR / "apply_all.sql"
    apply_deferred_sql = SQL_DIR / "apply_deferred.sql"

    if apply_all_sql.exists():
        run_psql(apply_all_sql)
    if apply_deferred_sql.exists():
        run_psql(apply_deferred_sql)

    # 2. Time Series (TimescaleDB - 58)
    ts_sql = NOSQL_DIR / "58_time_series_timescaledb" / "time_series.timescaledb.sql"
    if ts_sql.exists():
        run_psql(ts_sql)

    # 3. Vector RAG (pgvector - 59)
    vec_sql = NOSQL_DIR / "59_vector_rag_pgvector" / "vector_rag.pgvector.sql"
    if vec_sql.exists():
        run_psql(vec_sql)

    # 4. OpenSearch Mappings (57)
    apply_opensearch()

    print("\n" + "=" * 60)
    print("🎉 Inyección de Esquemas REDESA Finalizada.")
    print("=" * 60)


if __name__ == "__main__":
    main()
