#!/usr/bin/env python3
"""
gen_ui_visibility_patch.py — Arma el parche para BASE VIVA de la visibilidad de la interfaz
(`authz.ui_visibility_elements` y `authz.ui_visibility_rules`) a partir del DDL que `gen_ddl.py 06` y
`gen_integrity.py` YA generaron. No escribe DDL: lo copia.

Fuentes (todas generadas; correr antes `gen_ddl.py 06` y `gen_integrity.py`):
  SQL/06_authz/{02_tables,03_fk_intra,04_indexes,05_constraints,90_fk_deferred}.sql   (solo lo de ui_visibility_*)

Lo único que NO sale de los `.puml` y vive acá: los permisos de `mantra_app` y las comprobaciones finales.
Contrato: mantra-core-health/docs/trabajo/2026-10-31-visibilidad-rbac/CONTRATO.md.

Salida: SQL/patches/2026-10-31_ui_visibility.sql (idempotente, una transacción).
Uso:    python salud-db/gen_ui_visibility_patch.py
"""
from __future__ import annotations

import re

from paths import SQL_DIR

TARGET = SQL_DIR / "patches" / "2026-10-31_ui_visibility.sql"
TABLES = ("ui_visibility_elements", "ui_visibility_rules")


def read(rel: str) -> str:
    return (SQL_DIR / rel).read_text(encoding="utf-8")


def blocks(text: str) -> list[str]:
    """Bloques separados por línea en blanco (cada DO $$ … $$, CREATE TABLE o CREATE INDEX es uno)."""
    lines = text.splitlines()
    while lines and lines[0].strip():
        lines.pop(0)
    return [b for b in re.split(r"\n\s*\n", "\n".join(lines).strip("\n")) if b.strip()]


def only(text: str) -> str:
    """Los bloques que mencionan alguna de las dos tablas (con comillas, para no confundir prefijos)."""
    return "\n\n".join(b for b in blocks(text) if any(f'"{t}"' in b for t in TABLES))


def constraints(text: str) -> str:
    out = []
    for t in TABLES:
        marker = f"-- ═══ {t} ═══"
        start = text.index(marker)
        nxt = text.find("-- ═══", start + len(marker))
        out.append(text[start: nxt if nxt != -1 else len(text)].strip("\n"))
    return "\n\n".join(out)


def main() -> None:
    tables = only(read("06_authz/02_tables.sql"))
    fk_intra = only(read("06_authz/03_fk_intra.sql"))
    indexes = only(read("06_authz/04_indexes.sql"))
    fk_deferred = only(read("06_authz/90_fk_deferred.sql"))
    checks = constraints(read("06_authz/05_constraints.sql"))
    n_tables = tables.count("CREATE TABLE IF NOT EXISTS")
    n_idx = indexes.count("CREATE ")
    n_unique = indexes.count("CREATE UNIQUE INDEX")
    n_fk = fk_intra.count("ADD CONSTRAINT") + fk_deferred.count("ADD CONSTRAINT")
    n_chk = checks.count("ADD CONSTRAINT")
    assert n_tables == 2 and n_unique == 3 and n_chk == 14, "regenerar con gen_ddl.py 06 y gen_integrity.py"

    parts = [f"""-- ============================================================================
-- SALUD · patch de la visibilidad de la interfaz (authz.ui_visibility_elements y authz.ui_visibility_rules) sobre BD viva
-- Fecha: 2026-10-31
-- GENERADO por salud-db/gen_ui_visibility_patch.py a partir del DDL que ya emiten gen_ddl.py y gen_integrity.py: aquí no hay DDL escrito a
-- mano. Idempotente (CREATE ... IF NOT EXISTS, FKs con duplicate_object, CHECK con DROP IF EXISTS + ADD). UNA sola transaccion; se puede
-- volver a correr. En un rebuild desde cero apply_all.sql + apply_deferred.sql ya traen todo salvo la seccion 6 (permisos de `mantra_app`).
--
-- Contrato: mantra-core-health/docs/trabajo/2026-10-31-visibilidad-rbac/CONTRATO.md. LA VISIBILIDAD NO ES AUTORIZACION: estas tablas
-- deciden que se presenta; la API sigue autorizando cada peticion con authz.*.
--
-- PREREQUISITOS: schema authz, iam.users. Se comprueban al principio; si falta alguno el parche aborta sin tocar nada.
--
-- QUE AGREGA ({n_tables} tablas)
--   authz.ui_visibility_elements  catalogo de elementos de la interfaz (key unica, jerarquia por parent_element_id)
--   authz.ui_visibility_rules     reglas SHOW/HIDE por sujeto (USER | TENANT | ROLE | ORG_TYPE | ALL), vigencia opcional, se TERMINAN (no se borran)
--   unicidad real: key; y la terna elemento+sujeto NO terminada (2 indices unicos parciales: sujeto concreto y ALL)
--
-- DELTAS ESPERADOS sobre una base con v4.2.81 y sin este parche:
--   tablas +{n_tables} · FKs +{n_fk} · indices +{n_idx} (de ellos {n_unique} unicos; los PK nacen con las tablas) · CHECK +{n_chk}
--
-- RLS: ninguna de las dos lleva columna `tenant_id` (D-UV-1 del .puml 06), asi que 2026-08-05_tenant_rls.sql no las alcanza: el catalogo es de
-- plataforma y la organizacion que acota una regla se llama `scope_tenant_id`. El alcance por organizacion lo aplica la API (404 identico).
--
-- REVERSA (el parche solo agrega; un rollback de la API deja datos inertes):
--   DROP TABLE IF EXISTS "authz"."ui_visibility_rules"; DROP TABLE IF EXISTS "authz"."ui_visibility_elements";
-- ============================================================================

BEGIN;

-- ---- 0. prerequisitos ----
DO $$
BEGIN
    IF to_regclass('iam.users') IS NULL THEN
        RAISE EXCEPTION 'falta iam.users: aplicar antes apply_all.sql';
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.schemata WHERE schema_name = 'authz') THEN
        RAISE EXCEPTION 'falta el schema authz: aplicar antes apply_all.sql';
    END IF;
END $$;
""",
             "-- ---- 1. tablas (SQL/06_authz/02_tables.sql) ----\n" + tables + "\n",
             "-- ---- 2. FK dentro del schema authz (SQL/06_authz/03_fk_intra.sql) ----\n" + fk_intra + "\n",
             "-- ---- 3. indices, incluidos los 3 unicos (SQL/06_authz/04_indexes.sql) ----\n" + indexes + "\n",
             "-- ---- 4. FK entre schemas (SQL/06_authz/90_fk_deferred.sql) ----\n" + fk_deferred + "\n",
             "-- ---- 5. integridad: CHECK de vocabularios y de forma (SQL/06_authz/05_constraints.sql) ----\n" + checks + "\n",
             """-- ---- 6. permisos de la aplicacion (solo si existe el rol). Sin DELETE: los elementos se retiran y las reglas se terminan. ----
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'mantra_app') THEN
        GRANT SELECT, INSERT, UPDATE ON "authz"."ui_visibility_elements" TO mantra_app;
        GRANT SELECT, INSERT, UPDATE ON "authz"."ui_visibility_rules" TO mantra_app;
        REVOKE DELETE, TRUNCATE ON "authz"."ui_visibility_elements" FROM mantra_app;
        REVOKE DELETE, TRUNCATE ON "authz"."ui_visibility_rules" FROM mantra_app;
    END IF;
END $$;
""",
             f"""-- ---- 7. verificacion final (si algo no cuadra, la transaccion entera se revierte) ----
DO $$
DECLARE
    n int;
BEGIN
    SELECT count(*) INTO n FROM information_schema.tables
     WHERE table_schema = 'authz' AND table_name IN ('ui_visibility_elements', 'ui_visibility_rules');
    IF n <> 2 THEN RAISE EXCEPTION 'deberia haber 2 tablas ui_visibility_* y hay %', n; END IF;
    -- D-UV-1: ninguna de las dos puede llevar una columna tenant_id (el RLS la alcanzaria y rompería la escritura de plataforma).
    SELECT count(*) INTO n FROM information_schema.columns
     WHERE table_schema = 'authz' AND table_name IN ('ui_visibility_elements', 'ui_visibility_rules') AND column_name = 'tenant_id';
    IF n <> 0 THEN RAISE EXCEPTION 'las tablas ui_visibility_* no deben tener columna tenant_id (RLS): %', n; END IF;
    SELECT count(*) INTO n FROM pg_indexes
     WHERE schemaname = 'authz' AND indexdef LIKE 'CREATE UNIQUE INDEX%'
       AND indexname IN ('uq_ui_visibility_elements_key', 'uq_ui_visibility_rules_open_subject', 'uq_ui_visibility_rules_open_all');
    IF n <> 3 THEN RAISE EXCEPTION 'deberia haber 3 indices unicos de visibilidad y hay %', n; END IF;
    SELECT count(*) INTO n FROM pg_constraint c JOIN pg_class t ON t.oid = c.conrelid JOIN pg_namespace s ON s.oid = t.relnamespace
     WHERE c.contype = 'c' AND s.nspname = 'authz' AND t.relname IN ('ui_visibility_elements', 'ui_visibility_rules');
    IF n <> {n_chk} THEN RAISE EXCEPTION 'deberia haber {n_chk} CHECK en ui_visibility_* y hay %', n; END IF;
END $$;

COMMIT;
"""]
    TARGET.write_text("\n".join(parts), encoding="utf-8")
    print(f"Generado {TARGET.relative_to(SQL_DIR.parent)} · {n_tables} tablas · {n_fk} FK · {n_idx} índices · {n_chk} CHECK")


if __name__ == "__main__":
    main()
