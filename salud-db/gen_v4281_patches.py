#!/usr/bin/env python3
"""
gen_v4281_patches.py — Arma los parches para BASE VIVA de la franja F1b del portal de observabilidad y gobierno
(v4.2.81) a partir del DDL que `gen_ddl.py` y `gen_integrity.py` YA generaron. No escribe DDL: lo copia.

Un parche por entregable (se aplican en este orden, todos idempotentes, una transacción cada uno):

  idempotencia   SQL/patches/2026-10-31_v4281_idempotencia_anonima.sql
                 índice único parcial de los eventos anónimos + índice de búsqueda de los identificados
                 (módulo 28), con la deduplicación determinista previa.

Fuentes (todas generadas; correr antes `gen_ddl.py 11 28 29 67`, `gen_integrity.py`):
  SQL/28_telemetry/04_indexes.sql   sólo los dos índices nuevos de user_activity_events

Lo único que NO sale de los `.puml` y vive acá (como en los parches v4275/v4278/v4280): la deduplicación previa, las
políticas RLS, los permisos de `mantra_app`, las funciones de guarda parcial, los conceptos y las comprobaciones finales.

Uso:    python salud-db/gen_v4281_patches.py            # todos
        python salud-db/gen_v4281_patches.py idempotencia
"""
from __future__ import annotations

import re
import sys
import uuid

from paths import SQL_DIR
from gen_observability_patch import (  # noqa: F401  (helpers de lectura del DDL generado)
    CODE_SYSTEM_VERSION_ID, HEALTH_UUID_NAMESPACE, blocks, body, only, read)

VERSION = "v4.2.81"
PATCH_DIR = SQL_DIR / "patches"
ZERO_UUID = "00000000-0000-0000-0000-000000000000"


def write(name: str, text: str) -> tuple[str, str]:
    """Cada generador devuelve (nombre del parche, texto); `main` los escribe. Así una prueba puede comparar sin tocar el disco."""
    return name, text


# ----------------------------------------------------------------------------------------------------------------------
# helpers: extraer del DDL ya generado lo que le toca a cada parche (nada se escribe a mano)
# ----------------------------------------------------------------------------------------------------------------------
def qualified(schema: str, table: str) -> str:
    return f'"{schema}"."{table}"'


def select_blocks(text: str, schema: str, tables: list[str], extra: tuple[str, ...] = ()) -> str:
    """Bloques del DDL generado cuya tabla de origen (`ALTER TABLE "s"."t"`, `ON "s"."t"` o `CREATE TABLE IF NOT EXISTS "s"."t"`) está en
    `tables`, o que nombran alguna de las cadenas `extra` (un índice o una FK puntual de una tabla que ya existía)."""
    keys = {qualified(schema, t) for t in tables}
    out = []
    for b in blocks(text):
        head = "\n".join(l for l in b.splitlines() if not l.lstrip().startswith("--"))
        first = re.search(r'(?:ALTER TABLE|\sON|CREATE TABLE IF NOT EXISTS)\s+("[a-z_0-9]+"\."[a-z_0-9]+")', head)
        if (first and first.group(1) in keys) or any(e in b for e in extra):
            out.append(b)
    return "\n\n".join(out)


def table_section(text: str, table: str) -> str:
    """Sección `-- ═══ table ═══` de un 05_constraints.sql (hasta la siguiente sección)."""
    marker = f"-- ═══ {table} ═══"
    start = text.index(marker)
    nxt = text.find("-- ═══ ", start + len(marker))
    return text[start: nxt if nxt != -1 else len(text)].strip("\n")


def add_column(schema: str, table: str, column: str) -> str:
    """`ALTER TABLE ... ADD COLUMN IF NOT EXISTS` de una columna nueva en una tabla que ya existía, copiada del CREATE TABLE generado."""
    create = only(read(f"{MODULE_DIR[schema]}/02_tables.sql"), f"CREATE TABLE IF NOT EXISTS {qualified(schema, table)} (")
    m = re.search(rf'^\s+("{column}" [^\n]*?),?$', create, re.M)
    assert m, f"no está {column} en el CREATE TABLE generado de {schema}.{table}"
    definition = m.group(1)
    assert "NOT NULL" not in definition, f"{column}: una columna NOT NULL no se puede agregar a una tabla con filas sin default"
    return f"ALTER TABLE {qualified(schema, table)} ADD COLUMN IF NOT EXISTS {definition};"


def grants(immutable: list[str], mutable: list[str], schema: str, history_no_delete: list[str] = ()) -> str:
    """GRANT/REVOKE de `mantra_app` (solo si existe el rol): las inmutables sin UPDATE/TRUNCATE; el resto DML completo."""
    out = []
    for t in immutable:
        out.append(f'        GRANT SELECT, INSERT, DELETE ON {qualified(schema, t)} TO mantra_app;')
        out.append(f'        REVOKE UPDATE, TRUNCATE ON {qualified(schema, t)} FROM mantra_app;')
    for t in history_no_delete:
        out.append(f'        GRANT SELECT, INSERT, UPDATE ON {qualified(schema, t)} TO mantra_app;')
        out.append(f'        REVOKE DELETE, TRUNCATE ON {qualified(schema, t)} FROM mantra_app;')
    for t in mutable:
        out.append(f'        GRANT SELECT, INSERT, UPDATE, DELETE ON {qualified(schema, t)} TO mantra_app;')
    return "\n".join(out)


def concept_rows(concepts: list[tuple[str, str]]) -> str:
    rows = []
    for key, display in concepts:
        cid = uuid.uuid5(HEALTH_UUID_NAMESPACE, key)
        rows.append(f"  ('{cid}', '{CODE_SYSTEM_VERSION_ID}', '{key}', '{display}', false, true, now(), now(), 1)")
    return ",\n".join(rows)


CONCEPT_ANCHORS = f"""INSERT INTO terminology.terminology_sources (id, code, name, created_at, updated_at, row_version)
VALUES ('d94cf414-ad1b-59b9-afe2-903641f26011', 'MANTRA_CORE', 'Mantra Core Internal Terminology', now(), now(), 1)
ON CONFLICT DO NOTHING;
INSERT INTO terminology.code_systems (id, source_id, internal_code, name, canonical_url, case_sensitive, created_at, updated_at, row_version)
VALUES ('7d025a87-9c81-5c5c-9432-daf84d6fee8a', 'd94cf414-ad1b-59b9-afe2-903641f26011', 'mantra-core-internal',
        'Mantra Core Internal Code System', 'https://mantracore.health/fhir/CodeSystem/internal', true, now(), now(), 1)
ON CONFLICT DO NOTHING;
INSERT INTO terminology.code_system_versions (id, code_system_id, version, published_at, is_default, created_at, updated_at, row_version)
VALUES ('{CODE_SYSTEM_VERSION_ID}', '7d025a87-9c81-5c5c-9432-daf84d6fee8a', '1.0.0', now(), true, now(), now(), 1)
ON CONFLICT DO NOTHING;"""

MODULE_DIR = {"data_catalog": "67_data_catalog", "system_ops": "11_system_ops", "telemetry": "28_telemetry",
              "delegated_access": "29_delegated_access"}


# ======================================================================================================================
# 1. idempotencia anónima de telemetry.user_activity_events
# ======================================================================================================================
UAE_DEPENDENTS = {
    # tabla -> columnas que apuntan a user_activity_events(id)
    "user_activity_event_properties": ["user_activity_event_id"],
    "session_journeys": ["entry_event_id", "exit_event_id"],
    "conversion_events": ["completion_event_id"],
    "web_vitals": ["user_activity_event_id"],
}


def uae_dependents_in_model() -> dict[str, list[str]]:
    """Las FK que hoy apuntan a user_activity_events, leídas del DDL generado (no de memoria)."""
    found: dict[str, list[str]] = {}
    pat = re.compile(r'ALTER TABLE "(?P<s>[a-z_]+)"\."(?P<t>[a-z_0-9]+)"\s+ADD CONSTRAINT "[^"]+" FOREIGN KEY \("(?P<c>[a-z_0-9]+)"\)\s+'
                     r'REFERENCES "telemetry"\."user_activity_events" \("id"\)', re.S)
    for path in sorted(SQL_DIR.glob("[0-9][0-9]_*/*.sql")):
        for m in pat.finditer(path.read_text(encoding="utf-8")):
            found.setdefault(m["t"], []).append(m["c"])
    return {t: sorted(c) for t, c in found.items()}


def gen_idempotencia() -> tuple[str, str]:
    deps = uae_dependents_in_model()
    assert deps == {t: sorted(c) for t, c in UAE_DEPENDENTS.items()}, (
        f"cambiaron las FK hacia user_activity_events: {deps}; actualizar la deduplicación del parche")
    wanted = ('"ux_user_activity_events_anonymous_idempotency"', '"ix_user_activity_events_user_idempotency"')
    idx = "\n\n".join(b for b in blocks(read("28_telemetry/04_indexes.sql")) if any(w in b for w in wanted))
    assert idx.count("INDEX IF NOT EXISTS") == 2, "faltan los índices nuevos de user_activity_events: regenerar con gen_ddl.py 28"

    head = f"""-- ============================================================================
-- SALUD · patch {VERSION} (franja F1b del portal de observabilidad: idempotencia de los eventos anónimos) sobre BD viva
-- Fecha: 2026-10-31
-- GENERADO por salud-db/gen_v4281_patches.py a partir del DDL que ya emite gen_ddl.py (SQL/28_telemetry/04_indexes.sql): los dos
-- CREATE INDEX no están escritos a mano. Idempotente (CREATE INDEX IF NOT EXISTS; la deduplicación no hace nada si no hay repetidos).
-- UNA sola transacción; se puede volver a correr.
--
-- Contexto: hallazgo 2 (Alta) de evidencia-f0/REVISION-codigo-api.md del plan docs/trabajo/2026-10-31-portal-observabilidad-gobierno/ (repo
-- del front): `telemetry.user_activity_events` no tenía índice por clave de idempotencia, de modo que dos lotes concurrentes con la misma
-- clave pasaban a la vez el «buscar y luego insertar» de la API. En el evento anónimo (propósito PLATFORM_USAGE_AGGREGATE) `user_id` es
-- NULL y `event_idempotency_key` guarda un HMAC de (persona, organización, clave del cliente).
--
-- QUE AGREGA
--   ux_user_activity_events_anonymous_idempotency  UNIQUE (COALESCE(tenant_id, uuid cero), event_idempotency_key) WHERE user_id IS NULL
--       El tenant va envuelto en COALESCE a propósito: `tenant_id` admite NULL y un índice único trata cada NULL como distinto, así que un evento
--       anónimo sin organización nunca chocaría. La API debe inferir el conflicto con la MISMA expresión:
--         ON CONFLICT ((COALESCE(tenant_id, '{ZERO_UUID}'::uuid)), event_idempotency_key) WHERE user_id IS NULL DO NOTHING
--       o capturar SQLSTATE 23505 y contar el evento como `skipped`.
--   ix_user_activity_events_user_idempotency       (user_id, event_idempotency_key) WHERE user_id IS NOT NULL   (búsqueda, NO único)
--
-- DEDUPLICACION PREVIA (determinista): si la base ya tiene eventos anónimos repetidos (misma organización y misma clave), se conserva el
-- MAS ANTIGUO (created_at, luego id) y se eliminan los demás. Lo que colgaba de un repetido no se pierde:
--   session_journeys.entry_event_id / exit_event_id y conversion_events.completion_event_id  -> se reapuntan al conservado
--   web_vitals.user_activity_event_id                                                         -> se reapunta al conservado
--   user_activity_event_properties                                                            -> se reapuntan las propiedades que el conservado no
--       tenga (por property_name) y se borran las que ya tenía (son copias del mismo reintento)
-- La cantidad eliminada se informa con RAISE NOTICE. Corre con `app.system_context = 'true'` (local a la transacción): la tabla tiene RLS
-- forzada y un dueño sin BYPASSRLS no vería las filas de ninguna organización.
--
-- BLOQUEO: crear un índice único toma un lock que frena las escrituras de la tabla mientras se construye. `SET LOCAL lock_timeout` hace que
-- el parche falle rápido (y se pueda reintentar) en vez de esperar detrás de una transacción larga y encolar a todas las demás. En una tabla
-- grande, correr ANTES, fuera de transacción, los dos `CREATE [UNIQUE] INDEX CONCURRENTLY IF NOT EXISTS` de la sección 2 (con la
-- deduplicación de la sección 1 ya hecha a mano): este parche los encuentra y no los reconstruye.
--
-- REVERSA (solo agrega índices; lo deduplicado no se recupera):
--   DROP INDEX IF EXISTS "telemetry"."ux_user_activity_events_anonymous_idempotency", "telemetry"."ix_user_activity_events_user_idempotency";
-- ============================================================================

BEGIN;
SET LOCAL lock_timeout = '15s';

-- ---- 0. prerequisitos ----
DO $$
BEGIN
    IF to_regclass('telemetry.user_activity_events') IS NULL THEN
        RAISE EXCEPTION 'falta telemetry.user_activity_events: aplicar antes apply_all.sql';
    END IF;
END $$;
"""
    dedup = f"""
-- ---- 1. deduplicacion determinista de los eventos anonimos repetidos (antes de crear el indice unico) ----
DO $$
DECLARE
    v_dups bigint;
    v_props_moved bigint := 0;
    v_props_dropped bigint := 0;
    v_n bigint;
BEGIN
    PERFORM set_config('app.system_context', 'true', true);   -- local a la transaccion (la tabla tiene RLS forzada)

    CREATE TEMP TABLE _uae_dups ON COMMIT DROP AS
    SELECT r.id AS dup_id, r.keeper_id
      FROM (SELECT e.id,
                   first_value(e.id) OVER w AS keeper_id,
                   row_number() OVER w AS rn
              FROM telemetry.user_activity_events e
             WHERE e.user_id IS NULL
            WINDOW w AS (PARTITION BY COALESCE(e.tenant_id, '{ZERO_UUID}'::uuid), e.event_idempotency_key
                         ORDER BY e.created_at, e.id)) r
     WHERE r.rn > 1;
    CREATE INDEX ON _uae_dups (dup_id);
    SELECT count(*) INTO v_dups FROM _uae_dups;

    IF v_dups > 0 THEN
        -- un solo UPDATE por fila (dos sobre la misma fila obligarian a PostgreSQL a revalidar todas sus FK)
        UPDATE telemetry.session_journeys j
           SET entry_event_id = COALESCE((SELECT d.keeper_id FROM _uae_dups d WHERE d.dup_id = j.entry_event_id), j.entry_event_id),
               exit_event_id = COALESCE((SELECT d.keeper_id FROM _uae_dups d WHERE d.dup_id = j.exit_event_id), j.exit_event_id)
         WHERE j.entry_event_id IN (SELECT dup_id FROM _uae_dups) OR j.exit_event_id IN (SELECT dup_id FROM _uae_dups);
        UPDATE telemetry.conversion_events c SET completion_event_id = d.keeper_id FROM _uae_dups d WHERE c.completion_event_id = d.dup_id;
        UPDATE telemetry.web_vitals w SET user_activity_event_id = d.keeper_id FROM _uae_dups d WHERE w.user_activity_event_id = d.dup_id;

        UPDATE telemetry.user_activity_event_properties p SET user_activity_event_id = d.keeper_id
          FROM _uae_dups d
         WHERE p.user_activity_event_id = d.dup_id
           AND NOT EXISTS (SELECT 1 FROM telemetry.user_activity_event_properties k
                            WHERE k.user_activity_event_id = d.keeper_id AND k.property_name = p.property_name);
        GET DIAGNOSTICS v_props_moved = ROW_COUNT;
        DELETE FROM telemetry.user_activity_event_properties p USING _uae_dups d WHERE p.user_activity_event_id = d.dup_id;
        GET DIAGNOSTICS v_props_dropped = ROW_COUNT;

        DELETE FROM telemetry.user_activity_events e USING _uae_dups d WHERE e.id = d.dup_id;
        GET DIAGNOSTICS v_n = ROW_COUNT;
        IF v_n <> v_dups THEN
            RAISE EXCEPTION 'v4281: se esperaba eliminar % eventos anonimos repetidos y se eliminaron %', v_dups, v_n;
        END IF;
    END IF;
    RAISE NOTICE 'v4281: % evento(s) anonimo(s) repetido(s) eliminado(s) (propiedades reapuntadas: %, propiedades repetidas eliminadas: %)',
        v_dups, v_props_moved, v_props_dropped;
END $$;
"""
    indexes = ("\n-- ---- 2. indices (SQL/28_telemetry/04_indexes.sql, generados desde el .puml) ----\n" + idx + "\n")
    verify = f"""
-- ---- 3. verificacion final (si algo no cuadra, la transaccion entera se revierte) ----
DO $$
DECLARE
    n int;
BEGIN
    SELECT count(*) INTO n
      FROM pg_index i JOIN pg_class c ON c.oid = i.indexrelid JOIN pg_namespace s ON s.oid = c.relnamespace
     WHERE s.nspname = 'telemetry' AND c.relname = 'ux_user_activity_events_anonymous_idempotency'
       AND i.indisunique AND i.indisvalid AND i.indpred IS NOT NULL;
    IF n <> 1 THEN RAISE EXCEPTION 'v4281: el indice unico parcial de eventos anonimos no existe, no es unico o no es valido'; END IF;
    SELECT count(*) INTO n
      FROM pg_index i JOIN pg_class c ON c.oid = i.indexrelid JOIN pg_namespace s ON s.oid = c.relnamespace
     WHERE s.nspname = 'telemetry' AND c.relname = 'ix_user_activity_events_user_idempotency'
       AND NOT i.indisunique AND i.indisvalid AND i.indpred IS NOT NULL;
    IF n <> 1 THEN RAISE EXCEPTION 'v4281: falta el indice de busqueda de eventos identificados'; END IF;
END $$;

COMMIT;
"""
    return write("2026-10-31_v4281_idempotencia_anonima.sql", head + dedup + indexes + verify)


GENERATORS = {
    "idempotencia": gen_idempotencia,
}


def main(argv: list[str]) -> None:
    names = argv or list(GENERATORS)
    for name in names:
        patch, text = GENERATORS[name]()
        (PATCH_DIR / patch).write_text(text, encoding="utf-8")
        print(f"Generado SQL/patches/{patch}")


if __name__ == "__main__":
    main(sys.argv[1:])
