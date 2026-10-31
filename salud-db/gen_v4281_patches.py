#!/usr/bin/env python3
"""
gen_v4281_patches.py — Arma los parches para BASE VIVA de la franja F1b del portal de observabilidad y gobierno
(v4.2.81) a partir del DDL que `gen_ddl.py` y `gen_integrity.py` YA generaron. No escribe DDL: lo copia.

Un parche por entregable (se aplican en este orden, todos idempotentes, una transacción cada uno):

  idempotencia   SQL/patches/2026-10-31_v4281_idempotencia_anonima.sql
                 índice único parcial de los eventos anónimos + índice de búsqueda de los identificados
                 (módulo 28), con la deduplicación determinista previa.
  gobierno       SQL/patches/2026-10-31_v4281_gobierno_de_datos.sql
                 módulo 67 (12 tablas + catalog_objects.domain_id) y módulo 11 (governance_policy_revisions + índice
                 del change-log), con la guarda parcial de las revisiones de política.
  cargas         SQL/patches/2026-10-31_v4281_cargas_masivas.sql
                 lote persistente de bulk_import (módulo 11: bulk_import_batches y bulk_import_batch_rows).

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


# ======================================================================================================================
# 2. gobierno de datos: módulo 67 (data_catalog) y módulo 11 (system_ops.governance_policy_revisions)
# ======================================================================================================================
GOV67_TABLES = [
    "catalog_stewardships", "catalog_glossary_terms", "catalog_glossary_term_revisions", "catalog_glossary_term_links",
    "quality_rules", "quality_rule_runs", "quality_issues", "quality_issue_events", "quality_score_snapshots",
    "catalog_lineage_edges", "catalog_certifications", "catalog_change_acknowledgements",
]
GOV67_IMMUTABLE = ["catalog_glossary_term_revisions", "quality_issue_events", "quality_score_snapshots", "catalog_change_acknowledgements"]
GOV11_TABLES = ["governance_policy_revisions"]

POLICY_GUARD = """-- Guarda de columnas de las revisiones de politica (D-F1b-7 del .puml 11). No es expresable en el .puml: vive en este generador, como las
-- politicas RLS de los parches v4278/v4280. Un UPDATE solo puede mover el ciclo de vida (status, decided_*, decision_comment, effective_from);
-- lo propuesto no cambia nunca, una decision tomada no se reescribe, el estado no retrocede y la historia no se borra.
CREATE OR REPLACE FUNCTION "system_ops"."guard_governance_policy_revision"() RETURNS trigger
LANGUAGE plpgsql AS $fn$
BEGIN
    IF TG_OP = 'DELETE' THEN
        RAISE EXCEPTION 'append-only/immutable: DELETE no permitido en %.%', TG_TABLE_SCHEMA, TG_TABLE_NAME USING ERRCODE = 'restrict_violation';
    END IF;
    IF ROW(NEW.id, NEW.policy_type, NEW.policy_id, NEW.revision_no, NEW.content_json, NEW.content_hash, NEW.change_reason,
           NEW.submitted_by_user_id, NEW.submitted_at, NEW.created_at)
       IS DISTINCT FROM
       ROW(OLD.id, OLD.policy_type, OLD.policy_id, OLD.revision_no, OLD.content_json, OLD.content_hash, OLD.change_reason,
           OLD.submitted_by_user_id, OLD.submitted_at, OLD.created_at) THEN
        RAISE EXCEPTION 'append-only/immutable: lo propuesto de una revision de politica (contenido, hash, motivo, autor) no se modifica en %.%',
            TG_TABLE_SCHEMA, TG_TABLE_NAME USING ERRCODE = 'restrict_violation';
    END IF;
    IF OLD.decided_at IS NOT NULL
       AND ROW(NEW.decided_by_user_id, NEW.decided_at, NEW.decision_comment)
           IS DISTINCT FROM ROW(OLD.decided_by_user_id, OLD.decided_at, OLD.decision_comment) THEN
        RAISE EXCEPTION 'append-only/immutable: una decision ya tomada sobre una revision de politica no se reescribe (%.%)',
            TG_TABLE_SCHEMA, TG_TABLE_NAME USING ERRCODE = 'restrict_violation';
    END IF;
    IF (OLD.status IN ('REJECTED', 'SUPERSEDED') AND NEW.status <> OLD.status)
       OR (OLD.status = 'APPROVED' AND NEW.status NOT IN ('APPROVED', 'SUPERSEDED')) THEN
        RAISE EXCEPTION 'append-only/immutable: el estado de una revision de politica no retrocede (% -> %)', OLD.status, NEW.status
            USING ERRCODE = 'restrict_violation';
    END IF;
    RETURN NEW;
END $fn$;

DROP TRIGGER IF EXISTS trg_guard_policy_revision ON "system_ops"."governance_policy_revisions";
CREATE TRIGGER trg_guard_policy_revision BEFORE UPDATE OR DELETE ON "system_ops"."governance_policy_revisions"
    FOR EACH ROW EXECUTE FUNCTION "system_ops"."guard_governance_policy_revision"();"""


def gen_gobierno() -> tuple[str, str]:
    t67 = select_blocks(read("67_data_catalog/02_tables.sql"), "data_catalog", GOV67_TABLES)
    t11 = select_blocks(read("11_system_ops/02_tables.sql"), "system_ops", GOV11_TABLES)
    assert t67.count("CREATE TABLE IF NOT EXISTS") == len(GOV67_TABLES) and t11.count("CREATE TABLE IF NOT EXISTS") == 1
    add_domain = add_column("data_catalog", "catalog_objects", "domain_id")
    fk_intra = select_blocks(read("67_data_catalog/03_fk_intra.sql"), "data_catalog", GOV67_TABLES)
    idx67 = select_blocks(read("67_data_catalog/04_indexes.sql"), "data_catalog", GOV67_TABLES, ('"ix_data_catalog_objects_domain_id"',))
    idx11 = select_blocks(read("11_system_ops/04_indexes.sql"), "system_ops", GOV11_TABLES, ('"ix_governance_change_log_target_recorded"',))
    fk_def67 = select_blocks(read("67_data_catalog/90_fk_deferred.sql"), "data_catalog", GOV67_TABLES, ('"fk_catalog_objects_domain_id"',))
    fk_def11 = select_blocks(read("11_system_ops/90_fk_deferred.sql"), "system_ops", GOV11_TABLES)
    c67_text, c11_text = read("67_data_catalog/05_constraints.sql"), read("11_system_ops/05_constraints.sql")
    cons67 = "\n\n".join(table_section(c67_text, t) for t in GOV67_TABLES if f"-- ═══ {t} ═══" in c67_text)
    cons11 = "\n\n".join(table_section(c11_text, t) for t in GOV11_TABLES if f"-- ═══ {t} ═══" in c11_text)
    n_fk = (fk_intra + fk_def67 + fk_def11).count("ADD CONSTRAINT")
    n_idx = (idx67 + idx11).count("INDEX IF NOT EXISTS")
    n_chk = (cons67 + cons11).count("ADD CONSTRAINT")
    n_trg = cons67.count("CREATE TRIGGER trg_forbid_update")
    assert n_trg == len(GOV67_IMMUTABLE), f"triggers de inmutabilidad: {n_trg}"
    n_tables = len(GOV67_TABLES) + len(GOV11_TABLES)

    head = f"""-- ============================================================================
-- SALUD · patch {VERSION} (franja F1b del portal de observabilidad y gobierno: gobierno de datos, módulos 67 y 11) sobre BD viva
-- Fecha: 2026-10-31
-- GENERADO por salud-db/gen_v4281_patches.py a partir del DDL que ya emiten gen_ddl.py y gen_integrity.py: aquí no hay DDL escrito a mano
-- salvo la guarda de columnas de las revisiones de política (sección 6) y los permisos/comprobaciones. Idempotente (CREATE ... IF NOT
-- EXISTS, ADD COLUMN IF NOT EXISTS, FK con duplicate_object, CHECK con DROP IF EXISTS + ADD, disparadores con DROP IF EXISTS + CREATE).
-- UNA sola transacción; se puede volver a correr. Solo AGREGA: no cambia ni borra nada existente.
--
-- Contexto: 04-catalogo-y-gobierno.md §3 (H1.S1.M1–M4) del plan docs/trabajo/2026-10-31-portal-observabilidad-gobierno/ (repo del front).
--
-- QUE AGREGA
--   data_catalog (módulo 67)  +{len(GOV67_TABLES)} tablas: {", ".join(GOV67_TABLES)}
--                             + catalog_objects.domain_id (columna nullable, ADD COLUMN IF NOT EXISTS: no reescribe la tabla ni toma bloqueo largo)
--   system_ops (módulo 11)    +1 tabla: governance_policy_revisions; + índice ix_governance_change_log_target_recorded en la bitácora
--                             (CREATE INDEX normal: governance_change_log es chica; en una base grande, crearlo antes con CONCURRENTLY)
--   {n_fk} FK (las que van a iam.users, system_ops.data_domains, read_models y reporting son diferidas: sección 4), {n_idx} índices, {n_chk} CHECK,
--   {n_trg} disparadores de inmutabilidad (+1 de columnas en governance_policy_revisions)
--
-- DECISIONES (detalle en el .puml 67 y 11)
--   * Sin RLS, a propósito: ninguna tabla nueva tiene columna `tenant_id` ni `actor_tenant_id`. El catálogo y el gobierno son datos de PLATAFORMA
--     (`@TenantAgnostic()` en el API; los actores son `*_user_id`). 2026-08-05_tenant_rls.sql solo alcanza columnas `tenant_id`: la sección 8
--     aborta si aparece una. Si una tabla de este bloque llegara a llevar el tenant de un actor, debe llamarse `actor_tenant_id` y recibir
--     políticas explícitas (patrón del v4280).
--   * Inmutables (UPDATE prohibido por `integrity.forbid_mutation`): catalog_glossary_term_revisions, quality_issue_events,
--     quality_score_snapshots, catalog_change_acknowledgements. `mantra_app` pierde UPDATE/TRUNCATE sobre ellas.
--   * governance_policy_revisions NO usa forbid_mutation (D-F1b-7): su ciclo de vida vive en la misma fila y aprobar es un UPDATE. Un
--     disparador de columnas (sección 6) congela lo propuesto, no reescribe una decisión tomada, impide retroceder el estado y prohíbe el
--     DELETE; ck_governance_policy_revisions_not_self impone en la base que quien decide no es quien propuso.
--   * quality_rules.threshold_pct no lleva DEFAULT 0 (D-F1b-4): el API debe enviar el umbral.
--
-- REVERSA (solo agrega; un rollback de la API deja datos inertes). Orden: primero las tablas con FK hacia otras.
--   DROP TABLE IF EXISTS data_catalog.catalog_change_acknowledgements, data_catalog.catalog_certifications, data_catalog.catalog_lineage_edges,
--     data_catalog.quality_score_snapshots, data_catalog.quality_issue_events, data_catalog.quality_issues, data_catalog.quality_rule_runs,
--     data_catalog.quality_rules, data_catalog.catalog_glossary_term_links, data_catalog.catalog_glossary_term_revisions,
--     data_catalog.catalog_glossary_terms, data_catalog.catalog_stewardships, system_ops.governance_policy_revisions;
--   DROP FUNCTION IF EXISTS system_ops.guard_governance_policy_revision();
--   ALTER TABLE data_catalog.catalog_objects DROP COLUMN IF EXISTS domain_id;
--   DROP INDEX IF EXISTS system_ops.ix_governance_change_log_target_recorded;
-- ============================================================================

BEGIN;
SET LOCAL lock_timeout = '15s';

-- ---- 0. prerequisitos ----
DO $$
BEGIN
    IF to_regprocedure('integrity.forbid_mutation()') IS NULL THEN
        RAISE EXCEPTION 'falta integrity.forbid_mutation(): aplicar antes SQL/_integrity/00_integrity_functions.sql';
    END IF;
    IF to_regclass('iam.users') IS NULL OR to_regclass('system_ops.data_domains') IS NULL OR to_regclass('system_ops.governance_change_log') IS NULL
       OR to_regclass('data_catalog.catalog_objects') IS NULL OR to_regclass('data_catalog.catalog_columns') IS NULL
       OR to_regclass('data_catalog.catalog_change_events') IS NULL
       OR to_regclass('read_models.read_model_definitions') IS NULL OR to_regclass('reporting.report_definitions') IS NULL THEN
        RAISE EXCEPTION 'faltan tablas base (iam.users, system_ops.data_domains/governance_change_log, data_catalog.catalog_objects/columns/change_events, read_models.read_model_definitions, reporting.report_definitions): aplicar antes apply_all.sql';
    END IF;
END $$;
"""
    parts = [head]
    parts.append("-- ---- 1. tablas (SQL/67_data_catalog/02_tables.sql y SQL/11_system_ops/02_tables.sql) ----\n"
                 + t67 + "\n\n" + t11 + "\n\n"
                 + "-- la unica columna nueva en una tabla que ya existia (nullable: ADD COLUMN IF NOT EXISTS no reescribe ni bloquea)\n" + add_domain + "\n")
    parts.append("-- ---- 2. FK dentro del schema data_catalog (SQL/67_data_catalog/03_fk_intra.sql) ----\n" + fk_intra + "\n")
    parts.append("-- ---- 3. indices (SQL/67_data_catalog/04_indexes.sql y SQL/11_system_ops/04_indexes.sql) ----\n" + idx67 + "\n\n" + idx11 + "\n")
    parts.append("-- ---- 4. FK entre schemas: iam.users, system_ops.data_domains, read_models, reporting (90_fk_deferred.sql de los modulos 67 y 11) ----\n"
                 + fk_def67 + "\n\n" + fk_def11 + "\n")
    parts.append("-- ---- 5. integridad: CHECK de gobierno y UPDATE prohibido (05_constraints.sql de los modulos 67 y 11) ----\n" + cons67 + "\n\n" + cons11 + "\n")
    parts.append("-- ---- 6. guarda de columnas de governance_policy_revisions ----\n" + POLICY_GUARD + "\n")
    parts.append(f"""-- ---- 7. permisos de la aplicacion (solo si existe el rol; 2026-08-05_tenant_rls.sql vuelve a conceder DML, el disparador sigue frenando) ----
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'mantra_app') THEN
{grants(GOV67_IMMUTABLE, [t for t in GOV67_TABLES if t not in GOV67_IMMUTABLE], "data_catalog")}
{grants([], [], "system_ops", history_no_delete=GOV11_TABLES)}
    END IF;
END $$;
""")
    imm = ", ".join(f"'{t}'" for t in GOV67_IMMUTABLE)
    all67 = ", ".join(f"'{t}'" for t in GOV67_TABLES)
    parts.append(f"""-- ---- 8. verificacion final (si algo no cuadra, la transaccion entera se revierte) ----
DO $$
DECLARE
    n int;
BEGIN
    SELECT count(*) INTO n FROM information_schema.tables WHERE table_schema = 'data_catalog' AND table_type = 'BASE TABLE' AND table_name IN ({all67});
    IF n <> {len(GOV67_TABLES)} THEN RAISE EXCEPTION 'v4281 gobierno: deberia haber {len(GOV67_TABLES)} tablas nuevas en data_catalog y hay %', n; END IF;
    IF to_regclass('system_ops.governance_policy_revisions') IS NULL THEN RAISE EXCEPTION 'v4281 gobierno: falta system_ops.governance_policy_revisions'; END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'data_catalog' AND table_name = 'catalog_objects' AND column_name = 'domain_id') THEN
        RAISE EXCEPTION 'v4281 gobierno: falta catalog_objects.domain_id';
    END IF;
    IF to_regclass('system_ops.ix_governance_change_log_target_recorded') IS NULL THEN RAISE EXCEPTION 'v4281 gobierno: falta ix_governance_change_log_target_recorded'; END IF;
    -- D-F1b-1: ninguna tabla nueva lleva tenant (el RLS global las alcanzaria y la escritura de plataforma dejaria de funcionar)
    SELECT count(*) INTO n FROM information_schema.columns
     WHERE column_name IN ('tenant_id', 'actor_tenant_id')
       AND ((table_schema = 'data_catalog' AND table_name IN ({all67})) OR (table_schema = 'system_ops' AND table_name = 'governance_policy_revisions'));
    IF n <> 0 THEN RAISE EXCEPTION 'v4281 gobierno: las tablas nuevas no deben tener columna de tenant (decision D-F1b-1): %', n; END IF;
    SELECT count(*) INTO n FROM pg_trigger t JOIN pg_class c ON c.oid = t.tgrelid JOIN pg_namespace s ON s.oid = c.relnamespace
     WHERE t.tgname = 'trg_forbid_update' AND NOT t.tgisinternal AND s.nspname = 'data_catalog' AND c.relname IN ({imm});
    IF n <> {len(GOV67_IMMUTABLE)} THEN RAISE EXCEPTION 'v4281 gobierno: deberia haber {len(GOV67_IMMUTABLE)} disparadores trg_forbid_update y hay %', n; END IF;
    SELECT count(*) INTO n FROM pg_trigger t JOIN pg_class c ON c.oid = t.tgrelid JOIN pg_namespace s ON s.oid = c.relnamespace
     WHERE t.tgname = 'trg_guard_policy_revision' AND NOT t.tgisinternal AND s.nspname = 'system_ops' AND c.relname = 'governance_policy_revisions';
    IF n <> 1 THEN RAISE EXCEPTION 'v4281 gobierno: falta el disparador de columnas de governance_policy_revisions'; END IF;
    SELECT count(*) INTO n FROM pg_constraint k JOIN pg_class c ON c.oid = k.conrelid JOIN pg_namespace s ON s.oid = c.relnamespace
     WHERE k.contype = 'c' AND ((s.nspname = 'data_catalog' AND c.relname IN ({all67})) OR (s.nspname = 'system_ops' AND c.relname = 'governance_policy_revisions'));
    IF n <> {n_chk} THEN RAISE EXCEPTION 'v4281 gobierno: deberia haber {n_chk} CHECK y hay %', n; END IF;
    SELECT count(*) INTO n FROM pg_constraint k JOIN pg_class c ON c.oid = k.conrelid JOIN pg_namespace s ON s.oid = c.relnamespace
     WHERE k.contype = 'f' AND ((s.nspname = 'data_catalog' AND (c.relname IN ({all67}) OR k.conname = 'fk_catalog_objects_domain_id'))
                              OR (s.nspname = 'system_ops' AND c.relname = 'governance_policy_revisions'));
    IF n <> {n_fk} THEN RAISE EXCEPTION 'v4281 gobierno: deberia haber {n_fk} FK y hay %', n; END IF;
    RAISE NOTICE 'v4281 gobierno: {n_tables} tablas, {n_fk} FK, {n_idx} indices, {n_chk} CHECK, {len(GOV67_IMMUTABLE)}+1 disparadores';
END $$;

COMMIT;
""")
    return write("2026-10-31_v4281_gobierno_de_datos.sql", "\n".join(parts))


# ======================================================================================================================
# 3. cargas masivas: lote persistente de bulk_import (módulo 11)
# ======================================================================================================================
BULK_TABLES = ["bulk_import_batches", "bulk_import_batch_rows"]


def gen_cargas() -> tuple[str, str]:
    t11 = select_blocks(read("11_system_ops/02_tables.sql"), "system_ops", BULK_TABLES)
    assert t11.count("CREATE TABLE IF NOT EXISTS") == len(BULK_TABLES)
    fk_intra = select_blocks(read("11_system_ops/03_fk_intra.sql"), "system_ops", BULK_TABLES)
    idx11 = select_blocks(read("11_system_ops/04_indexes.sql"), "system_ops", BULK_TABLES)
    fk_def = select_blocks(read("11_system_ops/90_fk_deferred.sql"), "system_ops", BULK_TABLES)
    c11_text = read("11_system_ops/05_constraints.sql")
    cons11 = "\n\n".join(table_section(c11_text, t) for t in BULK_TABLES if f"-- ═══ {t} ═══" in c11_text)
    n_fk = (fk_intra + fk_def).count("ADD CONSTRAINT")
    n_idx = idx11.count("INDEX IF NOT EXISTS")
    n_chk = cons11.count("ADD CONSTRAINT")
    bulk = ", ".join(f"'{t}'" for t in BULK_TABLES)

    head = f"""-- ============================================================================
-- SALUD · patch {VERSION} (franja F1b del portal de observabilidad y gobierno: cargas masivas, lote persistente de bulk_import) sobre BD viva
-- Fecha: 2026-10-31
-- GENERADO por salud-db/gen_v4281_patches.py a partir del DDL que ya emiten gen_ddl.py y gen_integrity.py: aquí no hay DDL escrito a mano
-- salvo las políticas RLS, los permisos y las comprobaciones. Idempotente (CREATE ... IF NOT EXISTS, FK con duplicate_object, CHECK con DROP IF
-- EXISTS + ADD). UNA sola transacción; se puede volver a correr. Solo AGREGA.
--
-- Contexto: 06-cargas-masivas-aprobacion-gobierno-usuarios.md H2.S1.M1 del plan docs/trabajo/2026-10-31-portal-observabilidad-gobierno/ (repo del
-- front). Contrato del API que estas tablas calzan: src/modules/bulk_import/ports/bulk-import.ports.ts (BatchRecord, StoredRow, ReportRow,
-- BulkImportBatchRepository), bulk-import.constants.ts (estados y resultados) y bulk-import.error-reasons.ts (motivos).
--
-- QUE AGREGA (system_ops, módulo 11)
--   bulk_import_batches     el lote: tipo y versión, estado, formato y tamaño del archivo, hash del archivo, declaración (motivo, organización de origen,
--                           base legal, fecha de carga), contadores, hallazgos de la vista previa, clave de confirmación UNICA por (organización, clave),
--                           quién y cuándo confirmó, solicitud de aprobación (FK a delegated_access.four_eyes_requests), informe final
--   bulk_import_batch_rows  una fila por fila del archivo: resultado, motivo (código estable), columna, entidad creada (target_entity, target_id)
--                           {n_fk} FK, {n_idx} índices, {n_chk} CHECK en total
--   RLS: tenant_isolation en las 2 tablas (llevan `tenant_id`, a propósito)
--
-- DECISIONES (detalle en el .puml 11)
--   * Viven en system_ops, no en un módulo nuevo: no hay número libre (55-59 NoSQL, 70 observability, 71-89 PAY) y se evita un schema con
--     USAGE/GRANT propios.
--   * SIN PII en las columnas de resultado. Lo único con datos personales es bulk_import_batch_rows.row_data_json y su row_key (hash de
--     tenant+tipo+clave natural, seudónimo), ambos TRANSITORIOS: ck_bulk_import_batch_rows_closed_no_data impide que una fila con resultado los
--     conserve. El archivo original no se guarda, solo su hash. Para comprobar que no queda nada sobre un lote cerrado:
--       SELECT count(*) FROM system_ops.bulk_import_batch_rows r JOIN system_ops.bulk_import_batches b ON b.id = r.batch_id
--        WHERE b.status IN ('COMPLETADO','FALLIDO','RECHAZADO') AND (r.row_data_json IS NOT NULL OR r.row_key IS NOT NULL);   -- debe ser 0
--   * Estados y resultados son texto (los valores en español del enum del API) sin CHECK de vocabulario: el API los gobierna con
--     BATCH_TRANSITIONS y un estado nuevo no debe exigir un parche del modelo. La espera de aprobación (06 H3) se modela con approval_request_id.
--
-- REVERSA (solo agrega):
--   DROP TABLE IF EXISTS system_ops.bulk_import_batch_rows, system_ops.bulk_import_batches;
-- ============================================================================

BEGIN;
SET LOCAL lock_timeout = '15s';

-- ---- 0. prerequisitos ----
DO $$
BEGIN
    IF to_regclass('delegated_access.four_eyes_requests') IS NULL OR to_regclass('directory.tenants') IS NULL OR to_regclass('iam.users') IS NULL THEN
        RAISE EXCEPTION 'faltan tablas base (delegated_access.four_eyes_requests (parche v4278), directory.tenants, iam.users): aplicar antes apply_all.sql y los parches v4275/v4278';
    END IF;
END $$;
"""
    parts = [head]
    parts.append("-- ---- 1. tablas del lote (SQL/11_system_ops/02_tables.sql) ----\n" + t11 + "\n")
    parts.append("-- ---- 2. FK dentro de system_ops (SQL/11_system_ops/03_fk_intra.sql) ----\n" + fk_intra + "\n")
    parts.append("-- ---- 3. indices (SQL/11_system_ops/04_indexes.sql) ----\n" + idx11 + "\n")
    parts.append("-- ---- 4. FK entre schemas: directory.tenants, iam.users, delegated_access.four_eyes_requests (SQL/11_system_ops/90_fk_deferred.sql) ----\n" + fk_def + "\n")
    parts.append("-- ---- 5. integridad: contadores y «sin datos personales en una fila cerrada» (SQL/11_system_ops/05_constraints.sql) ----\n" + cons11 + "\n")
    parts.append("""-- ---- 6. RLS: tenant_isolation en las tablas del lote (mismo patron que 2026-08-05_tenant_rls.sql y el v4278; la fila repite el tenant del lote) ----
DO $$
DECLARE
    r record;
BEGIN
    FOR r IN SELECT * FROM (VALUES ('system_ops', 'bulk_import_batches'), ('system_ops', 'bulk_import_batch_rows')) AS v(s, t) LOOP
        EXECUTE format('ALTER TABLE %I.%I ENABLE ROW LEVEL SECURITY', r.s, r.t);
        EXECUTE format('ALTER TABLE %I.%I FORCE ROW LEVEL SECURITY', r.s, r.t);
        EXECUTE format('DROP POLICY IF EXISTS tenant_isolation ON %I.%I', r.s, r.t);
        EXECUTE format($pol$
        CREATE POLICY tenant_isolation ON %I.%I
          USING (
            tenant_id = NULLIF(current_setting('app.current_tenant_id', true), '')::uuid
            OR current_setting('app.system_context', true) = 'true'
          )
          WITH CHECK (
            tenant_id = NULLIF(current_setting('app.current_tenant_id', true), '')::uuid
            OR current_setting('app.system_context', true) = 'true'
          )
        $pol$, r.s, r.t);
    END LOOP;
END $$;
""")
    parts.append(f"""-- ---- 7. permisos de la aplicacion (solo si existe el rol) ----
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'mantra_app') THEN
{grants([], BULK_TABLES, "system_ops")}
    END IF;
END $$;
""")
    parts.append(f"""-- ---- 8. verificacion final (si algo no cuadra, la transaccion entera se revierte) ----
DO $$
DECLARE
    n int;
BEGIN
    SELECT count(*) INTO n FROM information_schema.tables WHERE table_schema = 'system_ops' AND table_type = 'BASE TABLE' AND table_name IN ({bulk});
    IF n <> {len(BULK_TABLES)} THEN RAISE EXCEPTION 'v4281 cargas: deberia haber {len(BULK_TABLES)} tablas del lote y hay %', n; END IF;
    SELECT count(*) INTO n FROM pg_indexes WHERE schemaname = 'system_ops' AND indexname = 'ux_bulk_import_batches_confirm_key' AND indexdef LIKE 'CREATE UNIQUE INDEX%';
    IF n <> 1 THEN RAISE EXCEPTION 'v4281 cargas: falta el indice unico de la clave de confirmacion por organizacion'; END IF;
    SELECT count(*) INTO n FROM pg_constraint k JOIN pg_class c ON c.oid = k.conrelid JOIN pg_namespace s ON s.oid = c.relnamespace
     WHERE k.contype = 'c' AND s.nspname = 'system_ops' AND c.relname IN ({bulk});
    IF n <> {n_chk} THEN RAISE EXCEPTION 'v4281 cargas: deberia haber {n_chk} CHECK y hay %', n; END IF;
    SELECT count(*) INTO n FROM pg_constraint k JOIN pg_class c ON c.oid = k.conrelid JOIN pg_namespace s ON s.oid = c.relnamespace
     WHERE k.contype = 'f' AND s.nspname = 'system_ops' AND c.relname IN ({bulk});
    IF n <> {n_fk} THEN RAISE EXCEPTION 'v4281 cargas: deberia haber {n_fk} FK y hay %', n; END IF;
    SELECT count(*) INTO n FROM pg_policies WHERE schemaname = 'system_ops' AND tablename IN ({bulk}) AND policyname = 'tenant_isolation';
    IF n <> {len(BULK_TABLES)} THEN RAISE EXCEPTION 'v4281 cargas: deberia haber {len(BULK_TABLES)} politicas tenant_isolation y hay %', n; END IF;
    SELECT count(*) INTO n FROM pg_class c JOIN pg_namespace s ON s.oid = c.relnamespace
     WHERE s.nspname = 'system_ops' AND c.relname IN ({bulk}) AND c.relrowsecurity AND c.relforcerowsecurity;
    IF n <> {len(BULK_TABLES)} THEN RAISE EXCEPTION 'v4281 cargas: las tablas del lote deben tener RLS forzada'; END IF;
    RAISE NOTICE 'v4281 cargas: {len(BULK_TABLES)} tablas, {n_fk} FK, {n_idx} indices, {n_chk} CHECK, RLS forzada';
END $$;

COMMIT;
""")
    return write("2026-10-31_v4281_cargas_masivas.sql", "\n".join(parts))


GENERATORS = {
    "idempotencia": gen_idempotencia,
    "gobierno": gen_gobierno,
    "cargas": gen_cargas,
}


def main(argv: list[str]) -> None:
    names = argv or list(GENERATORS)
    for name in names:
        patch, text = GENERATORS[name]()
        (PATCH_DIR / patch).write_text(text, encoding="utf-8")
        print(f"Generado SQL/patches/{patch}")


if __name__ == "__main__":
    main(sys.argv[1:])
