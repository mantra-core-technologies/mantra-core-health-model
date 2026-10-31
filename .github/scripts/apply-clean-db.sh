#!/usr/bin/env bash
# =========================================================================
# Aplica el DDL del modelo sobre una base PostgreSQL VACÍA, con
# ON_ERROR_STOP=1 en cada archivo. Lo usa `.github/workflows/ci.yml` y se
# puede correr a mano contra cualquier base limpia:
#
#   PGHOST=localhost PGPORT=5432 PGUSER=salud PGDATABASE=salud \
#     bash .github/scripts/apply-clean-db.sh
#
# El orden es el de `mantra-core-health-api/docker/db-init/init-postgres.sh`
# (el contenedor `postgres-init` que construye la base de verdad):
#
#   1. SQL/apply_all.sql        todo el DDL relacional, sin 90_fk_deferred
#   2. SQL/apply_deferred.sql   las FK cross-schema
#   3. NoSQL/58 (TimescaleDB) y NoSQL/59 (pgvector)
#   4. SQL/patches/*.sql        en orden de nombre (= cronológico)
#
# Los stores 58/59 van ANTES de patches/ porque
# `2026-07-25_v407_nullable_embedding_model_versions.sql` altera
# `vector_rag.embedding_model_versions`, que crea el 59.
#
# En patches/ solo se omiten los `*_dev_seed.sql` (datos de ejemplo que se
# aplican a mano, como en `postgres-init`), y cada omisión se imprime con su
# nombre. Los `*backfill*` SÍ se aplican: `postgres-init` los saltea en una base
# nueva por precaución, pero acá se exige que también corran limpios sobre una
# base vacía (hoy el único, v420, termina con `INSERT 0 0`).
#
# SKIP_TIMESCALE=1 omite el 58 (solo para probar en una máquina sin la
# extensión; el CI usa una imagen que la trae y no lo define).
# =========================================================================
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$root"

PSQL=(psql -X -q -v ON_ERROR_STOP=1)

run() {
    echo "::group::$1"
    "${PSQL[@]}" -f "$1"
    echo "::endgroup::"
}

run SQL/apply_all.sql
run SQL/apply_deferred.sql

if [[ "${SKIP_TIMESCALE:-0}" == "1" ]]; then
    echo "=== NoSQL 58 (TimescaleDB) OMITIDO: SKIP_TIMESCALE=1"
else
    run NoSQL/58_time_series_timescaledb/time_series.timescaledb.sql
fi
run NoSQL/59_vector_rag_pgvector/vector_rag.pgvector.sql

shopt -s nullglob
patches=(SQL/patches/*.sql)
shopt -u nullglob
if [[ ${#patches[@]} -eq 0 ]]; then
    echo "!!! SQL/patches/ no tiene ni un archivo: el montaje está mal." >&2
    exit 4
fi

aplicados=0
for patch in "${patches[@]}"; do
    nombre="$(basename "$patch")"
    if [[ "$nombre" == *_dev_seed.sql ]]; then
        echo "=== $nombre: seed de desarrollo — se omite"
        continue
    fi
    run "$patch"
    aplicados=$((aplicados + 1))
done

echo "=== patches aplicados: $aplicados de ${#patches[@]}"
"${PSQL[@]}" -tAc "SELECT 'tablas: ' || count(*) FROM information_schema.tables
                    WHERE table_type = 'BASE TABLE'
                      AND table_schema NOT IN ('pg_catalog', 'information_schema')
                      AND table_schema NOT LIKE '\_timescaledb%'"
echo "=== DDL aplicado sobre base limpia sin errores"
