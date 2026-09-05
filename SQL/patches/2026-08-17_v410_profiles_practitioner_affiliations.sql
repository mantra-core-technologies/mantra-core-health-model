-- ============================================================================
-- SALUD · patch v4.1.0 (profiles.practitioner_affiliations) sobre una BD viva
-- Fecha: 2026-08-17
-- Idempotente (CREATE TABLE / INDEX IF NOT EXISTS · duplicate_object en las FK)
--
-- Contexto: gen_ddl.py ya emite esta tabla en SQL/05_profiles/ desde que el
-- .puml del módulo 05 la declara, así que en un rebuild desde cero este patch
-- NO hace falta. Existe únicamente para una base ya aplicada y poblada.
-- gen_apply.py no escanea SQL/patches/ (solo directorios NN_schema), así que no
-- entra en apply_all.sql.
--
-- Qué cierra: el historial laboral del profesional (UC-05-16). El backend venía
-- con la entidad, el repositorio, los DTOs, los conceptos y los dos endpoints
-- `GET`/`POST /profiles/practitioners/me/affiliations` mergeados en `dev`, pero
-- la tabla nunca llegó al modelo canónico: los dos endpoints respondían 500 y la
-- pestaña Trayectoria del perfil no tenía dónde persistir. La deuda estaba
-- documentada al inicio de ESTADO-Y-PENDIENTES.md del repo de la API.
--
-- Este archivo es la salida de gen_ddl.py 05, no DDL escrito a mano: la tabla se
-- declara en `Mantra Core Health Context/modules/diagram_05_profiles.puml` y el
-- destino de la FK al padre en
-- `SALUD/FK/FK profiles.practitioner_affiliations.practitioner_profile_id.md`
-- (la convención por nombre no alcanzaba: el subtipo CTI comparte PK y el
-- destino es `health_practitioner_profiles(profile_id)`, no `id`).
--
-- Reemplaza a `mantra-core-health-api/tools/alovida/2026-08-15_c05_practitioner_affiliations.sql`,
-- que declaraba la misma tabla FUERA de SQL/ y por eso hacía fallar el paso 0/4
-- de rebuild_stack.py (`check_ddl_sources.py`) para todo el equipo. Ese archivo
-- se elimina en el mismo cambio.
--
-- Dos decisiones de modelo que este DDL refleja y conviene no revertir:
--   * `organization_name` es varchar, no FK: la mayoría de los hospitales donde
--     alguien trabajó no están en la plataforma, y exigir que existan como
--     `directory.tenants` convertiría un dato de currículum en un alta de
--     organizaciones. Cuando la institución sí está dentro, `practice_site_id`
--     la ata por identificador y las dos formas conviven.
--   * `status_concept_id` es el estado del REGISTRO (activo / retractado); que el
--     vínculo siga vigente lo dice `end_date IS NULL`. Mezclarlos abriría el
--     estado inconsistente «activo pero con fecha de fin».
--
-- Delta esperado sobre los conteos canónicos: +1 tabla · +6 FKs · +8 índices
-- (6 IX + 1 UNIQUE + la PK).
-- ============================================================================

-- ── Tabla (de SQL/05_profiles/02_tables.sql) ────────────────────────────────
CREATE TABLE IF NOT EXISTS "profiles"."practitioner_affiliations" (
    "id" uuid NOT NULL,
    "practitioner_profile_id" uuid NOT NULL,
    "organization_name" varchar NOT NULL,
    "practice_site_id" uuid,
    "role_title" varchar NOT NULL,
    "department_text" varchar,
    "affiliation_type_concept_id" uuid,
    "start_date" date NOT NULL,
    "end_date" date,
    "status_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_practitioner_affiliations" PRIMARY KEY ("id")
);

-- ── Índices (de SQL/05_profiles/04_indexes.sql) ─────────────────────────────
CREATE INDEX IF NOT EXISTS "ix_practitioner_affiliations_practitioner_profile_id" ON "profiles"."practitioner_affiliations" ("practitioner_profile_id");
CREATE INDEX IF NOT EXISTS "ix_practitioner_affiliations_practice_site_id" ON "profiles"."practitioner_affiliations" ("practice_site_id");
CREATE INDEX IF NOT EXISTS "ix_practitioner_affiliations_affiliation_type_concept_id" ON "profiles"."practitioner_affiliations" ("affiliation_type_concept_id");
CREATE INDEX IF NOT EXISTS "ix_practitioner_affiliations_status_concept_id" ON "profiles"."practitioner_affiliations" ("status_concept_id");
CREATE INDEX IF NOT EXISTS "ix_practitioner_affiliations_created_by_user_id" ON "profiles"."practitioner_affiliations" ("created_by_user_id");
CREATE INDEX IF NOT EXISTS "ix_practitioner_affiliations_updated_by_user_id" ON "profiles"."practitioner_affiliations" ("updated_by_user_id");

-- Mismo criterio de duplicado que aplica el servicio (`findSame`): misma
-- institución, mismo cargo y mismo inicio es un doble envío del formulario, no
-- dos vínculos reales. El servicio ya responde 409; el índice es la red que
-- sostiene esa regla ante dos peticiones simultáneas.
CREATE UNIQUE INDEX IF NOT EXISTS "uq_practitioner_affiliation_same" ON "profiles"."practitioner_affiliations" ("practitioner_profile_id", "organization_name", "role_title", "start_date");

-- ── FK del propio schema (de SQL/05_profiles/03_fk_intra.sql) ───────────────
DO $$ BEGIN
    ALTER TABLE "profiles"."practitioner_affiliations"
        ADD CONSTRAINT "fk_practitioner_affiliations_practitioner_profile_id" FOREIGN KEY ("practitioner_profile_id")
        REFERENCES "profiles"."health_practitioner_profiles" ("profile_id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- ── FK cross-schema (de SQL/05_profiles/90_fk_deferred.sql) ─────────────────
DO $$ BEGIN
    ALTER TABLE "profiles"."practitioner_affiliations"
        ADD CONSTRAINT "fk_practitioner_affiliations_practice_site_id" FOREIGN KEY ("practice_site_id")
        REFERENCES "practice"."practice_sites" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "profiles"."practitioner_affiliations"
        ADD CONSTRAINT "fk_practitioner_affiliations_affiliation_type_concept_id" FOREIGN KEY ("affiliation_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "profiles"."practitioner_affiliations"
        ADD CONSTRAINT "fk_practitioner_affiliations_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "profiles"."practitioner_affiliations"
        ADD CONSTRAINT "fk_practitioner_affiliations_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "profiles"."practitioner_affiliations"
        ADD CONSTRAINT "fk_practitioner_affiliations_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;
