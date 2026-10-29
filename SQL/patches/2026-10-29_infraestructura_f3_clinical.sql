-- ============================================================================
-- SALUD · patch infraestructura hospitalaria F3 (internación / ADT: cama ↔ paciente 1:1,
-- traslado atómico, incidentes de ubicación y censo diario inmutable) sobre BD viva
-- Fecha: 2026-10-29 · Contrato: SALUD/Arquitectura/infraestructura-hospitalaria/
--   CONTRATO-F2-F5.md §0.1 y F3.1 (repositorio de documentación)
-- Se aplica DESPUÉS de 2026-10-29_infraestructura_f1.sql y de …_f1b_seguridad.sql (usa sus
-- UNIQUE (tenant_id, id) y sus funciones de historia). Idempotente: ADD COLUMN IF NOT
-- EXISTS / CREATE … IF NOT EXISTS / FK con `duplicate_object` / constraints y triggers
-- comprobados en el catálogo antes de crearlos / CREATE OR REPLACE. Se puede aplicar N veces;
-- la segunda pasada no cambia nada. gen_apply.py no escanea SQL/patches/: no entra en
-- apply_all.sql (postgres-init de la API aplica los patches en orden después del DDL).
--
-- Origen de las sentencias. Las columnas, tablas, FKs simples e índices de las secciones 1, 2,
-- 5 y 6 se copiaron de lo que gen_ddl.py emite desde diagram_08_clinical.puml y
-- diagram_10_audit.puml (corrido hacia un directorio temporal: este patch no toca los
-- SQL/NN_* generados, que son del integrador). Lo escrito a mano, porque el generador no lo
-- sabe expresar: backfills, precondiciones, FKs compuestas por tenant, EXCLUDE DEFERRABLE,
-- triggers, privilegios, RLS y la verificación final. Los CHECK y los EXCLUDE además están
-- declarados (CHECK_SQL / EXCLUDE_SQL) en diagram_33_integrity.puml, con los mismos nombres.
--
-- QUÉ CIERRA.
--   A. clinical.encounter_locations (historial de estancias = FHIR Encounter.location):
--      tenant_id (backfill desde el encuentro, después NOT NULL; un trigger lo completa si
--      el escritor no lo manda), is_bed_assignment, tipo de movimiento, ubicación previa
--      (PV1-6), motivo de fin, categoría de cama y vínculo al incidente de ubicación.
--      · INV-30  una cama, un paciente a la vez   → ex_encounter_locations_bed_occupancy
--      · INV-31  un encuentro, una cama a la vez  → ex_encounter_locations_encounter_single_bed
--      · un solo registro ACTIVO por encuentro    → ex_encounter_locations_encounter_one_active_bed
--      · una fila de cama exige espacio y período → ck_encounter_locations_bed_period(_order)
--      Los tres EXCLUDE son DEFERRABLE INITIALLY IMMEDIATE: el intercambio A17 hace
--      `SET CONSTRAINTS … DEFERRED` y cierra/abre las cuatro filas en cualquier orden.
--   B. clinical.encounters: nivel de cuidado, fuente de ingreso, tipo de egreso, precaución de
--      aislamiento, organismo y fecha estimada de alta (todo opcional).
--   C. Tablas nuevas: clinical.placement_incidents (incidente al forzar compatibilidad),
--      inpatient_census_days (censo por día y unidad), inpatient_census_entries y
--      inpatient_census_adjustments (append-only), y audit.encounter_locations_history /
--      audit.placement_incidents_history.
--   D. INV-35 censo inmutable: un día con closed_at no se modifica ni se borra (trigger);
--      entradas y ajustes son WORM (integrity.forbid_mutation); un ajuste sólo cabe sobre un
--      día cerrado y, si cita una entrada, de ese mismo día.
--   E. Aislamiento por tenant en la base: FK compuestas (tenant_id, x_id) → padre
--      (tenant_id, id), RLS `tenant_isolation` (texto exacto de 2026-08-05_tenant_rls.sql) en
--      las siete tablas con tenant_id, e historias con SELECT + INSERT + UPDATE de valid_to
--      (cierre SCD-2) y trigger que rechaza DELETE y todo otro UPDATE, igual que F1b.
--
-- LO QUE ESTE PATCH NO HACE.
--   - No siembra conceptos (LOCATION_RESERVED, LOCATION_CANCELLED, ADT_*, LOC_CARE_*,
--     PLC_INC_*, CENSUS_*, CEN_*…): sus ids los deriva la API (`clinical.concepts.ts`). Los
--     UUID literales de los EXCLUDE y del backfill salen de deterministicId('<módulo>:<CLAVE>')
--     (namespace 3f2b6c14-9d5e-5a41-b7c2-0a1e9f4d8b60) y se comentan abajo.
--   - No decide qué es «cerrado» por un concepto: el censo está cerrado cuando closed_at no
--     es NULL (la API fija closed_at, content_hash y el estado CLOSED en el mismo UPDATE).
--   - No borra ni renombra nada.
--
-- SUPUESTO (anotado también en DESVIOS-M-F3.md). El backfill de is_bed_assignment toma como
-- cama a todo espacio cuya forma sea ⟨practice:LOC_FORM_BED⟩ = 63ef5a86-740b-5fc6-8b93-3010ed5067a8.
-- El contrato nombra el concepto LOC_FORM_BED pero la clave exacta la fija practice.concepts.ts
-- de la API; si difiere, el backfill no marca nada (inocuo: antes de F1 no existían camas).
--
-- PRECONDICIONES (abortan sin tocar nada; el BEGIN hace rollback de todo):
--   - F1 y F1b sin aplicar (falta alguno de sus UNIQUE (tenant_id, id) o sus funciones).
--   - ubicaciones cuya sede, unidad o espacio es de OTRO tenant que el encuentro.
--   - filas de cama (is_bed_assignment) sin inicio de período o sin espacio, o con el fin
--     antes del inicio.
--   - dos filas de cama que solapan en la misma cama, o en el mismo encuentro (estados
--     ACTIVE/RESERVED/COMPLETED y ACTIVE/COMPLETED respectivamente), o dos ACTIVE del mismo
--     encuentro. Consulta para el operador, tras revisar el detalle del mensaje:
--       SELECT a.id, b.id, a.care_space_id FROM clinical.encounter_locations a
--         JOIN clinical.encounter_locations b ON a.care_space_id = b.care_space_id AND a.id < b.id
--        WHERE a.is_bed_assignment AND b.is_bed_assignment
--          AND tstzrange(a.period_start, a.period_end, '[)') && tstzrange(b.period_start, b.period_end, '[)');
--
-- DELTAS ESPERADOS sobre una base con F1/F1b/F5 (antes de este patch):
--   columnas +13 (encounters 6 · encounter_locations 7) · tablas +6 (4 clinical, 2 audit)
--   FKs simples +48 · FKs compuestas +18 · índices +56 · CHECK +8 · EXCLUDE +3
--   triggers +9 · políticas RLS +7
-- ============================================================================

BEGIN;

-- El backfill y las comprobaciones leen tablas con RLS forzada (encounters desde
-- 2026-08-05_tenant_rls.sql). El rol dueño la sortea si es superusuario; si no lo es, esto
-- abre el contexto SYSTEM sólo para esta transacción (SET LOCAL).
SET LOCAL app.system_context = 'true';

CREATE EXTENSION IF NOT EXISTS btree_gist;  -- requerido por EXCLUDE sobre uuid + rangos

-- ------------------------------------------------------------- 0. dependencias
DO $$
DECLARE
    faltan text[] := '{}';
BEGIN
    IF to_regclass('clinical.encounters') IS NULL OR to_regclass('clinical.encounter_locations') IS NULL THEN
        faltan := array_append(faltan, 'clinical.encounters / clinical.encounter_locations'::text);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE schemaname = 'practice' AND indexname = 'ux_practice_sites_tenant_id_id') THEN
        faltan := array_append(faltan, 'practice.ux_practice_sites_tenant_id_id (F1b)'::text);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE schemaname = 'practice' AND indexname = 'ux_clinical_units_tenant_id_id') THEN
        faltan := array_append(faltan, 'practice.ux_clinical_units_tenant_id_id (F1b)'::text);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE schemaname = 'practice' AND indexname = 'ux_care_spaces_tenant_id_id') THEN
        faltan := array_append(faltan, 'practice.ux_care_spaces_tenant_id_id (F1b)'::text);
    END IF;
    IF to_regprocedure('audit.structure_history_fill_tenant()') IS NULL
       OR to_regprocedure('audit.structure_history_close_only()') IS NULL THEN
        faltan := array_append(faltan, 'audit.structure_history_fill_tenant() / structure_history_close_only() (F1b)'::text);
    END IF;
    IF array_length(faltan, 1) > 0 THEN
        RAISE EXCEPTION 'infraestructura F3 requiere F1 y F1b aplicados (2026-10-29_infraestructura_f1.sql y …_f1b_seguridad.sql). Falta: %', array_to_string(faltan, '; ')
            USING ERRCODE = 'undefined_object';
    END IF;
END $$;

-- ------------------------------------------------------------- 1. columnas
-- clinical.encounters (B)
ALTER TABLE "clinical"."encounters"
    ADD COLUMN IF NOT EXISTS "level_of_care_concept_id" uuid;

ALTER TABLE "clinical"."encounters"
    ADD COLUMN IF NOT EXISTS "admission_source_concept_id" uuid;

ALTER TABLE "clinical"."encounters"
    ADD COLUMN IF NOT EXISTS "discharge_disposition_concept_id" uuid;

ALTER TABLE "clinical"."encounters"
    ADD COLUMN IF NOT EXISTS "isolation_precaution_concept_id" uuid;

ALTER TABLE "clinical"."encounters"
    ADD COLUMN IF NOT EXISTS "isolation_organism_text" varchar;

ALTER TABLE "clinical"."encounters"
    ADD COLUMN IF NOT EXISTS "expected_discharge_at" timestamptz;

-- clinical.encounter_locations (A)
ALTER TABLE "clinical"."encounter_locations"
    ADD COLUMN IF NOT EXISTS "tenant_id" uuid;  -- NOT NULL tras el backfill

ALTER TABLE "clinical"."encounter_locations"
    ADD COLUMN IF NOT EXISTS "is_bed_assignment" boolean NOT NULL DEFAULT false;

ALTER TABLE "clinical"."encounter_locations"
    ADD COLUMN IF NOT EXISTS "movement_type_concept_id" uuid;

ALTER TABLE "clinical"."encounter_locations"
    ADD COLUMN IF NOT EXISTS "previous_encounter_location_id" uuid;

ALTER TABLE "clinical"."encounter_locations"
    ADD COLUMN IF NOT EXISTS "end_reason_concept_id" uuid;

ALTER TABLE "clinical"."encounter_locations"
    ADD COLUMN IF NOT EXISTS "bed_category_concept_id" uuid;

ALTER TABLE "clinical"."encounter_locations"
    ADD COLUMN IF NOT EXISTS "placement_incident_id" uuid;

-- ------------------------------------------------------------- 2. tablas nuevas (C)
CREATE TABLE IF NOT EXISTS "clinical"."placement_incidents" (
    "id" uuid NOT NULL,
    "tenant_id" uuid NOT NULL,
    "encounter_id" uuid NOT NULL,
    "encounter_location_id" uuid,
    "care_space_id" uuid NOT NULL,
    "patient_profile_id" uuid NOT NULL,
    "violations_json" jsonb NOT NULL,
    "justification_text" text NOT NULL,
    "authorized_by_user_id" uuid NOT NULL,
    "status_concept_id" uuid NOT NULL,
    "reviewed_by_user_id" uuid,
    "reviewed_at" timestamptz,
    "review_note" text,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_placement_incidents" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "clinical"."inpatient_census_days" (
    "id" uuid NOT NULL,
    "tenant_id" uuid NOT NULL,
    "practice_site_id" uuid NOT NULL,
    "clinical_unit_id" uuid NOT NULL,
    "census_date" date NOT NULL,
    "cutoff_at" timestamptz NOT NULL,
    "status_concept_id" uuid NOT NULL,
    "closed_at" timestamptz,
    "closed_by_user_id" uuid,
    "beds_censable" integer NOT NULL,
    "beds_available" integer NOT NULL,
    "beds_blocked" integer NOT NULL,
    "patients_at_cutoff" integer NOT NULL,
    "admissions" integer NOT NULL,
    "discharges" integer NOT NULL,
    "deaths" integer NOT NULL,
    "transfers_in" integer NOT NULL,
    "transfers_out" integer NOT NULL,
    "same_day_stays" integer NOT NULL,
    "patient_days" integer NOT NULL,
    "discharge_stay_days" integer NOT NULL,
    "content_hash" varchar,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_inpatient_census_days" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "clinical"."inpatient_census_entries" (
    "id" uuid NOT NULL,
    "tenant_id" uuid NOT NULL,
    "census_day_id" uuid NOT NULL,
    "encounter_id" uuid NOT NULL,
    "patient_profile_id" uuid NOT NULL,
    "care_space_id" uuid,
    "bed_category_concept_id" uuid,
    "movement_concept_id" uuid NOT NULL,
    "occurred_at" timestamptz NOT NULL,
    CONSTRAINT "pk_inpatient_census_entries" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "clinical"."inpatient_census_adjustments" (
    "id" uuid NOT NULL,
    "tenant_id" uuid NOT NULL,
    "census_day_id" uuid NOT NULL,
    "field_code" varchar NOT NULL,
    "previous_value" integer NOT NULL,
    "new_value" integer NOT NULL,
    "reason_text" text NOT NULL,
    "entry_ref_id" uuid,
    "adjusted_by_user_id" uuid NOT NULL,
    "request_id" varchar,
    "created_at" timestamptz NOT NULL,
    CONSTRAINT "pk_inpatient_census_adjustments" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "audit"."encounter_locations_history" (
    "history_id" uuid NOT NULL,
    "encounter_location_id" uuid NOT NULL,
    "revision_no" integer NOT NULL,
    "operation_concept_id" uuid NOT NULL,
    "valid_from" timestamptz NOT NULL,
    "valid_to" timestamptz,
    "data_snapshot" jsonb NOT NULL,
    "changed_by_user_id" uuid,
    "change_reason_concept_id" uuid,
    "recorded_at" timestamptz NOT NULL,
    "tenant_id" uuid NOT NULL,
    CONSTRAINT "pk_encounter_locations_history" PRIMARY KEY ("history_id")
);

CREATE TABLE IF NOT EXISTS "audit"."placement_incidents_history" (
    "history_id" uuid NOT NULL,
    "placement_incident_id" uuid NOT NULL,
    "revision_no" integer NOT NULL,
    "operation_concept_id" uuid NOT NULL,
    "valid_from" timestamptz NOT NULL,
    "valid_to" timestamptz,
    "data_snapshot" jsonb NOT NULL,
    "changed_by_user_id" uuid,
    "change_reason_concept_id" uuid,
    "recorded_at" timestamptz NOT NULL,
    "tenant_id" uuid NOT NULL,
    CONSTRAINT "pk_placement_incidents_history" PRIMARY KEY ("history_id")
);

-- ------------------------------------------------------------- 3. backfill
-- tenant_id de la ubicación = el de su encuentro. Sólo filas con NULL.
UPDATE "clinical"."encounter_locations" el
   SET "tenant_id" = e."tenant_id"
  FROM "clinical"."encounters" e
 WHERE e."id" = el."encounter_id"
   AND el."tenant_id" IS NULL;

-- is_bed_assignment = true para toda ubicación cuyo espacio sea una CAMA.
-- 63ef5a86-740b-5fc6-8b93-3010ed5067a8 = deterministicId('practice:LOC_FORM_BED').
UPDATE "clinical"."encounter_locations" el
   SET "is_bed_assignment" = true
  FROM "practice"."care_spaces" cs
 WHERE cs."id" = el."care_space_id"
   AND cs."form_concept_id" = '63ef5a86-740b-5fc6-8b93-3010ed5067a8'
   AND NOT el."is_bed_assignment";

-- ------------------------------------------------------------- 4. precondiciones
DO $$
DECLARE
    n_null integer;
BEGIN
    SELECT count(*) INTO n_null FROM "clinical"."encounter_locations" WHERE "tenant_id" IS NULL;
    IF n_null > 0 THEN
        RAISE EXCEPTION 'infraestructura F3: % ubicación(es) sin tenant_id tras el backfill desde el encuentro. No se puede poner NOT NULL: corregirlas a mano y volver a aplicar.', n_null
            USING ERRCODE = 'not_null_violation';
    END IF;
END $$;

-- Referencias de la ubicación a un padre de OTRO tenant que el encuentro: se listan todas y
-- se aborta. Decidir cuál de los dos tenants es el correcto no le toca al patch.
DO $$
DECLARE
    n_cruz  integer;
    detalle text;
BEGIN
    WITH cruces(relacion, hijo) AS (
        SELECT 'encounter_locations.practice_site_id', c."id" FROM "clinical"."encounter_locations" c
          JOIN "practice"."practice_sites" p ON p."id" = c."practice_site_id" WHERE p."tenant_id" <> c."tenant_id"
        UNION ALL
        SELECT 'encounter_locations.clinical_unit_id', c."id" FROM "clinical"."encounter_locations" c
          JOIN "practice"."clinical_units" p ON p."id" = c."clinical_unit_id" WHERE p."tenant_id" <> c."tenant_id"
        UNION ALL
        SELECT 'encounter_locations.care_space_id', c."id" FROM "clinical"."encounter_locations" c
          JOIN "practice"."care_spaces" p ON p."id" = c."care_space_id" WHERE p."tenant_id" <> c."tenant_id"
    )
    SELECT count(*), string_agg(format('%s (%s filas, p. ej. %s)', relacion, n, ejemplo), '; ')
      INTO n_cruz, detalle
      FROM (SELECT relacion, count(*) AS n, min(hijo::text) AS ejemplo FROM cruces GROUP BY relacion) g;
    IF n_cruz > 0 THEN
        RAISE EXCEPTION 'infraestructura F3: hay ubicaciones que apuntan a una sede/unidad/espacio de OTRO tenant en % relación(es): %. No se crean las FK compuestas y no se toca ningún dato; corregirlas a mano y volver a aplicar.', n_cruz, detalle
            USING ERRCODE = 'foreign_key_violation';
    END IF;
END $$;

-- Filas de cama que ya violan los CHECK (se comprueba ANTES del solape: un rango invertido
-- haría fallar a tstzrange() con un error menos claro).
DO $$
DECLARE
    n_sin   integer;
    n_orden integer;
BEGIN
    SELECT count(*) INTO n_sin FROM "clinical"."encounter_locations"
     WHERE "is_bed_assignment" AND ("period_start" IS NULL OR "care_space_id" IS NULL);
    IF n_sin > 0 THEN
        RAISE EXCEPTION 'infraestructura F3: % fila(s) de cama sin inicio de período o sin espacio; no se crea ck_encounter_locations_bed_period y no se toca ningún dato. Completarlas a mano y volver a aplicar.', n_sin
            USING ERRCODE = 'check_violation';
    END IF;
    SELECT count(*) INTO n_orden FROM "clinical"."encounter_locations"
     WHERE "is_bed_assignment" AND "period_end" IS NOT NULL AND "period_end" < "period_start";
    IF n_orden > 0 THEN
        RAISE EXCEPTION 'infraestructura F3: % fila(s) de cama con period_end anterior a period_start; no se crea ck_encounter_locations_bed_period_order. Corregirlas a mano y volver a aplicar.', n_orden
            USING ERRCODE = 'check_violation';
    END IF;
END $$;

-- Solapes que impedirían crear los EXCLUDE (estados: 809db700… ACTIVE · cdd86257… RESERVED ·
-- 8cf00069… COMPLETED, ver sección 9).
DO $$
DECLARE
    n_cama   integer;
    n_enc    integer;
    n_activa integer;
    detalle  text;
BEGIN
    SELECT count(*), string_agg(format('cama %s: %s y %s', care_space_id, a_id, b_id), '; ')
      INTO n_cama, detalle
      FROM (SELECT a."care_space_id", a."id" AS a_id, b."id" AS b_id
              FROM "clinical"."encounter_locations" a
              JOIN "clinical"."encounter_locations" b
                ON a."care_space_id" = b."care_space_id" AND a."id" < b."id"
             WHERE a."is_bed_assignment" AND b."is_bed_assignment"
               AND a."location_status_concept_id" IN ('809db700-0627-5fe3-8278-4f038f4475b3', 'cdd86257-4297-5941-8ae8-b95e11439a48', '8cf00069-81ca-56e1-8e71-9e16333a1f6c')
               AND b."location_status_concept_id" IN ('809db700-0627-5fe3-8278-4f038f4475b3', 'cdd86257-4297-5941-8ae8-b95e11439a48', '8cf00069-81ca-56e1-8e71-9e16333a1f6c')
               AND tstzrange(a."period_start", a."period_end", '[)') && tstzrange(b."period_start", b."period_end", '[)')
             ORDER BY a."care_space_id", a."id"
             LIMIT 20) s;
    IF n_cama > 0 THEN
        RAISE EXCEPTION 'infraestructura F3: hay pacientes solapados en la misma cama (% par(es) en la muestra: %). No se crea ex_encounter_locations_bed_occupancy y no se toca ningún dato; resolver a mano (decidir qué estancia es la real) y volver a aplicar.', n_cama, detalle
            USING ERRCODE = 'exclusion_violation';
    END IF;

    SELECT count(*), string_agg(format('encuentro %s: %s y %s', encounter_id, a_id, b_id), '; ')
      INTO n_enc, detalle
      FROM (SELECT a."encounter_id", a."id" AS a_id, b."id" AS b_id
              FROM "clinical"."encounter_locations" a
              JOIN "clinical"."encounter_locations" b
                ON a."encounter_id" = b."encounter_id" AND a."id" < b."id"
             WHERE a."is_bed_assignment" AND b."is_bed_assignment"
               AND a."location_status_concept_id" IN ('809db700-0627-5fe3-8278-4f038f4475b3', '8cf00069-81ca-56e1-8e71-9e16333a1f6c')
               AND b."location_status_concept_id" IN ('809db700-0627-5fe3-8278-4f038f4475b3', '8cf00069-81ca-56e1-8e71-9e16333a1f6c')
               AND tstzrange(a."period_start", a."period_end", '[)') && tstzrange(b."period_start", b."period_end", '[)')
             ORDER BY a."encounter_id", a."id"
             LIMIT 20) s;
    IF n_enc > 0 THEN
        RAISE EXCEPTION 'infraestructura F3: hay encuentros en dos camas a la vez (% par(es) en la muestra: %). No se crea ex_encounter_locations_encounter_single_bed y no se toca ningún dato; resolver a mano y volver a aplicar.', n_enc, detalle
            USING ERRCODE = 'exclusion_violation';
    END IF;

    SELECT count(*), string_agg(format('encuentro %s', encounter_id), '; ')
      INTO n_activa, detalle
      FROM (SELECT "encounter_id" FROM "clinical"."encounter_locations"
             WHERE "is_bed_assignment" AND "location_status_concept_id" = '809db700-0627-5fe3-8278-4f038f4475b3'
             GROUP BY "encounter_id" HAVING count(*) > 1
             ORDER BY "encounter_id" LIMIT 20) s;
    IF n_activa > 0 THEN
        RAISE EXCEPTION 'infraestructura F3: hay encuentros con más de una ubicación de cama ACTIVA (% en la muestra: %). No se crea ex_encounter_locations_encounter_one_active_bed y no se toca ningún dato; resolver a mano y volver a aplicar.', n_activa, detalle
            USING ERRCODE = 'exclusion_violation';
    END IF;
END $$;

-- ------------------------------------------------------------- 5. NOT NULL
ALTER TABLE "clinical"."encounter_locations" ALTER COLUMN "tenant_id" SET NOT NULL;

-- ------------------------------------------------------------- 6. índices (copiados de 04_indexes)
CREATE UNIQUE INDEX IF NOT EXISTS "ux_encounters_tenant_id_id" ON "clinical"."encounters" ("tenant_id", "id");

CREATE INDEX IF NOT EXISTS "ix_encounters_level_of_care_concept_id" ON "clinical"."encounters" ("level_of_care_concept_id");

CREATE INDEX IF NOT EXISTS "ix_encounters_admission_source_concept_id" ON "clinical"."encounters" ("admission_source_concept_id");

CREATE INDEX IF NOT EXISTS "ix_encounters_discharge_disposition_concept_id" ON "clinical"."encounters" ("discharge_disposition_concept_id");

CREATE INDEX IF NOT EXISTS "ix_encounters_isolation_precaution_concept_id" ON "clinical"."encounters" ("isolation_precaution_concept_id");

CREATE UNIQUE INDEX IF NOT EXISTS "ux_encounter_locations_tenant_id_id" ON "clinical"."encounter_locations" ("tenant_id", "id");

CREATE INDEX IF NOT EXISTS "ix_encounter_locations_tenant_id" ON "clinical"."encounter_locations" ("tenant_id");

CREATE INDEX IF NOT EXISTS "ix_encounter_locations_movement_type_concept_id" ON "clinical"."encounter_locations" ("movement_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_encounter_locations_previous_encounter_location_id" ON "clinical"."encounter_locations" ("previous_encounter_location_id");

CREATE INDEX IF NOT EXISTS "ix_encounter_locations_end_reason_concept_id" ON "clinical"."encounter_locations" ("end_reason_concept_id");

CREATE INDEX IF NOT EXISTS "ix_encounter_locations_bed_category_concept_id" ON "clinical"."encounter_locations" ("bed_category_concept_id");

CREATE INDEX IF NOT EXISTS "ix_encounter_locations_placement_incident_id" ON "clinical"."encounter_locations" ("placement_incident_id");

CREATE UNIQUE INDEX IF NOT EXISTS "ux_placement_incidents_tenant_id_id" ON "clinical"."placement_incidents" ("tenant_id", "id");

CREATE INDEX IF NOT EXISTS "ix_placement_incidents_tenant_id" ON "clinical"."placement_incidents" ("tenant_id");

CREATE INDEX IF NOT EXISTS "ix_placement_incidents_encounter_id" ON "clinical"."placement_incidents" ("encounter_id");

CREATE INDEX IF NOT EXISTS "ix_placement_incidents_encounter_location_id" ON "clinical"."placement_incidents" ("encounter_location_id");

CREATE INDEX IF NOT EXISTS "ix_placement_incidents_care_space_id" ON "clinical"."placement_incidents" ("care_space_id");

CREATE INDEX IF NOT EXISTS "ix_placement_incidents_patient_profile_id" ON "clinical"."placement_incidents" ("patient_profile_id");

CREATE INDEX IF NOT EXISTS "ix_placement_incidents_authorized_by_user_id" ON "clinical"."placement_incidents" ("authorized_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_placement_incidents_status_concept_id" ON "clinical"."placement_incidents" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_placement_incidents_reviewed_by_user_id" ON "clinical"."placement_incidents" ("reviewed_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_placement_incidents_created_by_user_id" ON "clinical"."placement_incidents" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_placement_incidents_updated_by_user_id" ON "clinical"."placement_incidents" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_placement_incidents_tenant_id_status_concept_id" ON "clinical"."placement_incidents" ("tenant_id", "status_concept_id", "created_at" DESC);

CREATE UNIQUE INDEX IF NOT EXISTS "ux_inpatient_census_days_site_unit_date" ON "clinical"."inpatient_census_days" ("practice_site_id", "clinical_unit_id", "census_date");

CREATE UNIQUE INDEX IF NOT EXISTS "ux_inpatient_census_days_tenant_id_id" ON "clinical"."inpatient_census_days" ("tenant_id", "id");

CREATE INDEX IF NOT EXISTS "ix_inpatient_census_days_tenant_id" ON "clinical"."inpatient_census_days" ("tenant_id");

CREATE INDEX IF NOT EXISTS "ix_inpatient_census_days_clinical_unit_id" ON "clinical"."inpatient_census_days" ("clinical_unit_id");

CREATE INDEX IF NOT EXISTS "ix_inpatient_census_days_status_concept_id" ON "clinical"."inpatient_census_days" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_inpatient_census_days_closed_by_user_id" ON "clinical"."inpatient_census_days" ("closed_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_inpatient_census_days_created_by_user_id" ON "clinical"."inpatient_census_days" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_inpatient_census_days_updated_by_user_id" ON "clinical"."inpatient_census_days" ("updated_by_user_id");

CREATE UNIQUE INDEX IF NOT EXISTS "ux_inpatient_census_entries_tenant_id_id" ON "clinical"."inpatient_census_entries" ("tenant_id", "id");

CREATE INDEX IF NOT EXISTS "ix_inpatient_census_entries_tenant_id" ON "clinical"."inpatient_census_entries" ("tenant_id");

CREATE INDEX IF NOT EXISTS "ix_inpatient_census_entries_census_day_id" ON "clinical"."inpatient_census_entries" ("census_day_id", "movement_concept_id");

CREATE INDEX IF NOT EXISTS "ix_inpatient_census_entries_encounter_id" ON "clinical"."inpatient_census_entries" ("encounter_id");

CREATE INDEX IF NOT EXISTS "ix_inpatient_census_entries_patient_profile_id" ON "clinical"."inpatient_census_entries" ("patient_profile_id");

CREATE INDEX IF NOT EXISTS "ix_inpatient_census_entries_care_space_id" ON "clinical"."inpatient_census_entries" ("care_space_id");

CREATE INDEX IF NOT EXISTS "ix_inpatient_census_entries_bed_category_concept_id" ON "clinical"."inpatient_census_entries" ("bed_category_concept_id");

CREATE INDEX IF NOT EXISTS "ix_inpatient_census_entries_movement_concept_id" ON "clinical"."inpatient_census_entries" ("movement_concept_id");

CREATE INDEX IF NOT EXISTS "ix_inpatient_census_adjustments_tenant_id" ON "clinical"."inpatient_census_adjustments" ("tenant_id");

CREATE INDEX IF NOT EXISTS "ix_inpatient_census_adjustments_census_day_id" ON "clinical"."inpatient_census_adjustments" ("census_day_id", "created_at");

CREATE INDEX IF NOT EXISTS "ix_inpatient_census_adjustments_entry_ref_id" ON "clinical"."inpatient_census_adjustments" ("entry_ref_id");

CREATE INDEX IF NOT EXISTS "ix_inpatient_census_adjustments_adjusted_by_user_id" ON "clinical"."inpatient_census_adjustments" ("adjusted_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_encounter_locations_history_encounter_location_id" ON "audit"."encounter_locations_history" ("encounter_location_id");

CREATE INDEX IF NOT EXISTS "ix_encounter_locations_history_operation_concept_id" ON "audit"."encounter_locations_history" ("operation_concept_id");

CREATE INDEX IF NOT EXISTS "ix_encounter_locations_history_changed_by_user_id" ON "audit"."encounter_locations_history" ("changed_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_encounter_locations_history_change_reason_concept_id" ON "audit"."encounter_locations_history" ("change_reason_concept_id");

CREATE INDEX IF NOT EXISTS "brin_encounter_locations_history_recorded_at" ON "audit"."encounter_locations_history" USING brin ("recorded_at") WITH (pages_per_range=128);

CREATE INDEX IF NOT EXISTS "ix_encounter_locations_history_tenant_id" ON "audit"."encounter_locations_history" ("tenant_id");

CREATE INDEX IF NOT EXISTS "ix_placement_incidents_history_placement_incident_id" ON "audit"."placement_incidents_history" ("placement_incident_id");

CREATE INDEX IF NOT EXISTS "ix_placement_incidents_history_operation_concept_id" ON "audit"."placement_incidents_history" ("operation_concept_id");

CREATE INDEX IF NOT EXISTS "ix_placement_incidents_history_changed_by_user_id" ON "audit"."placement_incidents_history" ("changed_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_placement_incidents_history_change_reason_concept_id" ON "audit"."placement_incidents_history" ("change_reason_concept_id");

CREATE INDEX IF NOT EXISTS "brin_placement_incidents_history_recorded_at" ON "audit"."placement_incidents_history" USING brin ("recorded_at") WITH (pages_per_range=128);

CREATE INDEX IF NOT EXISTS "ix_placement_incidents_history_tenant_id" ON "audit"."placement_incidents_history" ("tenant_id");

-- ------------------------------------------------------------- 7. FKs simples (copiadas de 03_fk_intra y 90_fk_deferred)
DO $$ BEGIN
    ALTER TABLE "clinical"."encounter_locations"
        ADD CONSTRAINT "fk_encounter_locations_previous_encounter_location_id" FOREIGN KEY ("previous_encounter_location_id")
        REFERENCES "clinical"."encounter_locations" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "clinical"."encounter_locations"
        ADD CONSTRAINT "fk_encounter_locations_placement_incident_id" FOREIGN KEY ("placement_incident_id")
        REFERENCES "clinical"."placement_incidents" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "clinical"."placement_incidents"
        ADD CONSTRAINT "fk_placement_incidents_encounter_id" FOREIGN KEY ("encounter_id")
        REFERENCES "clinical"."encounters" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "clinical"."placement_incidents"
        ADD CONSTRAINT "fk_placement_incidents_encounter_location_id" FOREIGN KEY ("encounter_location_id")
        REFERENCES "clinical"."encounter_locations" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "clinical"."inpatient_census_entries"
        ADD CONSTRAINT "fk_inpatient_census_entries_census_day_id" FOREIGN KEY ("census_day_id")
        REFERENCES "clinical"."inpatient_census_days" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "clinical"."inpatient_census_entries"
        ADD CONSTRAINT "fk_inpatient_census_entries_encounter_id" FOREIGN KEY ("encounter_id")
        REFERENCES "clinical"."encounters" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "clinical"."inpatient_census_adjustments"
        ADD CONSTRAINT "fk_inpatient_census_adjustments_census_day_id" FOREIGN KEY ("census_day_id")
        REFERENCES "clinical"."inpatient_census_days" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "clinical"."inpatient_census_adjustments"
        ADD CONSTRAINT "fk_inpatient_census_adjustments_entry_ref_id" FOREIGN KEY ("entry_ref_id")
        REFERENCES "clinical"."inpatient_census_entries" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "clinical"."encounters"
        ADD CONSTRAINT "fk_encounters_level_of_care_concept_id" FOREIGN KEY ("level_of_care_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "clinical"."encounters"
        ADD CONSTRAINT "fk_encounters_admission_source_concept_id" FOREIGN KEY ("admission_source_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "clinical"."encounters"
        ADD CONSTRAINT "fk_encounters_discharge_disposition_concept_id" FOREIGN KEY ("discharge_disposition_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "clinical"."encounters"
        ADD CONSTRAINT "fk_encounters_isolation_precaution_concept_id" FOREIGN KEY ("isolation_precaution_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: directory.tenants (requiere schema directory)
DO $$ BEGIN
    ALTER TABLE "clinical"."encounter_locations"
        ADD CONSTRAINT "fk_encounter_locations_tenant_id" FOREIGN KEY ("tenant_id")
        REFERENCES "directory"."tenants" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "clinical"."encounter_locations"
        ADD CONSTRAINT "fk_encounter_locations_movement_type_concept_id" FOREIGN KEY ("movement_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "clinical"."encounter_locations"
        ADD CONSTRAINT "fk_encounter_locations_end_reason_concept_id" FOREIGN KEY ("end_reason_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "clinical"."encounter_locations"
        ADD CONSTRAINT "fk_encounter_locations_bed_category_concept_id" FOREIGN KEY ("bed_category_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: directory.tenants (requiere schema directory)
DO $$ BEGIN
    ALTER TABLE "clinical"."placement_incidents"
        ADD CONSTRAINT "fk_placement_incidents_tenant_id" FOREIGN KEY ("tenant_id")
        REFERENCES "directory"."tenants" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: practice.care_spaces (requiere schema practice)
DO $$ BEGIN
    ALTER TABLE "clinical"."placement_incidents"
        ADD CONSTRAINT "fk_placement_incidents_care_space_id" FOREIGN KEY ("care_space_id")
        REFERENCES "practice"."care_spaces" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: profiles.patient_profiles (requiere schema profiles)
DO $$ BEGIN
    ALTER TABLE "clinical"."placement_incidents"
        ADD CONSTRAINT "fk_placement_incidents_patient_profile_id" FOREIGN KEY ("patient_profile_id")
        REFERENCES "profiles"."patient_profiles" ("profile_id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "clinical"."placement_incidents"
        ADD CONSTRAINT "fk_placement_incidents_authorized_by_user_id" FOREIGN KEY ("authorized_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "clinical"."placement_incidents"
        ADD CONSTRAINT "fk_placement_incidents_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "clinical"."placement_incidents"
        ADD CONSTRAINT "fk_placement_incidents_reviewed_by_user_id" FOREIGN KEY ("reviewed_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "clinical"."placement_incidents"
        ADD CONSTRAINT "fk_placement_incidents_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "clinical"."placement_incidents"
        ADD CONSTRAINT "fk_placement_incidents_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: directory.tenants (requiere schema directory)
DO $$ BEGIN
    ALTER TABLE "clinical"."inpatient_census_days"
        ADD CONSTRAINT "fk_inpatient_census_days_tenant_id" FOREIGN KEY ("tenant_id")
        REFERENCES "directory"."tenants" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: practice.practice_sites (requiere schema practice)
DO $$ BEGIN
    ALTER TABLE "clinical"."inpatient_census_days"
        ADD CONSTRAINT "fk_inpatient_census_days_practice_site_id" FOREIGN KEY ("practice_site_id")
        REFERENCES "practice"."practice_sites" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: practice.clinical_units (requiere schema practice)
DO $$ BEGIN
    ALTER TABLE "clinical"."inpatient_census_days"
        ADD CONSTRAINT "fk_inpatient_census_days_clinical_unit_id" FOREIGN KEY ("clinical_unit_id")
        REFERENCES "practice"."clinical_units" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "clinical"."inpatient_census_days"
        ADD CONSTRAINT "fk_inpatient_census_days_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "clinical"."inpatient_census_days"
        ADD CONSTRAINT "fk_inpatient_census_days_closed_by_user_id" FOREIGN KEY ("closed_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "clinical"."inpatient_census_days"
        ADD CONSTRAINT "fk_inpatient_census_days_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "clinical"."inpatient_census_days"
        ADD CONSTRAINT "fk_inpatient_census_days_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: directory.tenants (requiere schema directory)
DO $$ BEGIN
    ALTER TABLE "clinical"."inpatient_census_entries"
        ADD CONSTRAINT "fk_inpatient_census_entries_tenant_id" FOREIGN KEY ("tenant_id")
        REFERENCES "directory"."tenants" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: profiles.patient_profiles (requiere schema profiles)
DO $$ BEGIN
    ALTER TABLE "clinical"."inpatient_census_entries"
        ADD CONSTRAINT "fk_inpatient_census_entries_patient_profile_id" FOREIGN KEY ("patient_profile_id")
        REFERENCES "profiles"."patient_profiles" ("profile_id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: practice.care_spaces (requiere schema practice)
DO $$ BEGIN
    ALTER TABLE "clinical"."inpatient_census_entries"
        ADD CONSTRAINT "fk_inpatient_census_entries_care_space_id" FOREIGN KEY ("care_space_id")
        REFERENCES "practice"."care_spaces" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "clinical"."inpatient_census_entries"
        ADD CONSTRAINT "fk_inpatient_census_entries_bed_category_concept_id" FOREIGN KEY ("bed_category_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "clinical"."inpatient_census_entries"
        ADD CONSTRAINT "fk_inpatient_census_entries_movement_concept_id" FOREIGN KEY ("movement_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: directory.tenants (requiere schema directory)
DO $$ BEGIN
    ALTER TABLE "clinical"."inpatient_census_adjustments"
        ADD CONSTRAINT "fk_inpatient_census_adjustments_tenant_id" FOREIGN KEY ("tenant_id")
        REFERENCES "directory"."tenants" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "clinical"."inpatient_census_adjustments"
        ADD CONSTRAINT "fk_inpatient_census_adjustments_adjusted_by_user_id" FOREIGN KEY ("adjusted_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: clinical.encounter_locations (requiere schema clinical)
DO $$ BEGIN
    ALTER TABLE "audit"."encounter_locations_history"
        ADD CONSTRAINT "fk_encounter_locations_history_encounter_location_id" FOREIGN KEY ("encounter_location_id")
        REFERENCES "clinical"."encounter_locations" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "audit"."encounter_locations_history"
        ADD CONSTRAINT "fk_encounter_locations_history_operation_concept_id" FOREIGN KEY ("operation_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "audit"."encounter_locations_history"
        ADD CONSTRAINT "fk_encounter_locations_history_changed_by_user_id" FOREIGN KEY ("changed_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "audit"."encounter_locations_history"
        ADD CONSTRAINT "fk_encounter_locations_history_change_reason_concept_id" FOREIGN KEY ("change_reason_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: directory.tenants (requiere schema directory)
DO $$ BEGIN
    ALTER TABLE "audit"."encounter_locations_history"
        ADD CONSTRAINT "fk_encounter_locations_history_tenant_id" FOREIGN KEY ("tenant_id")
        REFERENCES "directory"."tenants" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: clinical.placement_incidents (requiere schema clinical)
DO $$ BEGIN
    ALTER TABLE "audit"."placement_incidents_history"
        ADD CONSTRAINT "fk_placement_incidents_history_placement_incident_id" FOREIGN KEY ("placement_incident_id")
        REFERENCES "clinical"."placement_incidents" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "audit"."placement_incidents_history"
        ADD CONSTRAINT "fk_placement_incidents_history_operation_concept_id" FOREIGN KEY ("operation_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "audit"."placement_incidents_history"
        ADD CONSTRAINT "fk_placement_incidents_history_changed_by_user_id" FOREIGN KEY ("changed_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "audit"."placement_incidents_history"
        ADD CONSTRAINT "fk_placement_incidents_history_change_reason_concept_id" FOREIGN KEY ("change_reason_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: directory.tenants (requiere schema directory)
DO $$ BEGIN
    ALTER TABLE "audit"."placement_incidents_history"
        ADD CONSTRAINT "fk_placement_incidents_history_tenant_id" FOREIGN KEY ("tenant_id")
        REFERENCES "directory"."tenants" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- ------------------------------------------------------------- 8. FKs compuestas (escritas a mano)
-- (tenant_id, x_id) → padre (tenant_id, id): la fila hija sólo puede apuntar a un padre del
-- MISMO tenant (el RLS filtra filas, no valida a dónde apunta una FK). MATCH SIMPLE: si x_id
-- es NULL no se exige nada, así que sirven también para los vínculos opcionales. Conviven con
-- la FK simple generada.
DO $$
DECLARE
    r record;
BEGIN
    FOR r IN
        SELECT * FROM (VALUES
            ('clinical.encounter_locations',          'fk_encounter_locations_tenant_encounter',        'encounter_id',                   'clinical.encounters'),
            ('clinical.encounter_locations',          'fk_encounter_locations_tenant_site',             'practice_site_id',               'practice.practice_sites'),
            ('clinical.encounter_locations',          'fk_encounter_locations_tenant_unit',             'clinical_unit_id',               'practice.clinical_units'),
            ('clinical.encounter_locations',          'fk_encounter_locations_tenant_space',            'care_space_id',                  'practice.care_spaces'),
            ('clinical.encounter_locations',          'fk_encounter_locations_tenant_previous',         'previous_encounter_location_id', 'clinical.encounter_locations'),
            ('clinical.encounter_locations',          'fk_encounter_locations_tenant_incident',         'placement_incident_id',          'clinical.placement_incidents'),
            ('clinical.placement_incidents',          'fk_placement_incidents_tenant_encounter',        'encounter_id',                   'clinical.encounters'),
            ('clinical.placement_incidents',          'fk_placement_incidents_tenant_location',         'encounter_location_id',          'clinical.encounter_locations'),
            ('clinical.placement_incidents',          'fk_placement_incidents_tenant_space',            'care_space_id',                  'practice.care_spaces'),
            ('clinical.inpatient_census_days',        'fk_inpatient_census_days_tenant_site',           'practice_site_id',               'practice.practice_sites'),
            ('clinical.inpatient_census_days',        'fk_inpatient_census_days_tenant_unit',           'clinical_unit_id',               'practice.clinical_units'),
            ('clinical.inpatient_census_entries',     'fk_inpatient_census_entries_tenant_day',         'census_day_id',                  'clinical.inpatient_census_days'),
            ('clinical.inpatient_census_entries',     'fk_inpatient_census_entries_tenant_encounter',   'encounter_id',                   'clinical.encounters'),
            ('clinical.inpatient_census_entries',     'fk_inpatient_census_entries_tenant_space',       'care_space_id',                  'practice.care_spaces'),
            ('clinical.inpatient_census_adjustments', 'fk_inpatient_census_adjustments_tenant_day',     'census_day_id',                  'clinical.inpatient_census_days'),
            ('clinical.inpatient_census_adjustments', 'fk_inpatient_census_adjustments_tenant_entry',   'entry_ref_id',                   'clinical.inpatient_census_entries'),
            ('audit.encounter_locations_history',     'fk_encounter_locations_history_tenant_source',   'encounter_location_id',          'clinical.encounter_locations'),
            ('audit.placement_incidents_history',     'fk_placement_incidents_history_tenant_source',   'placement_incident_id',          'clinical.placement_incidents')
        ) AS v(hijo, nombre, columna, padre)
    LOOP
        BEGIN
            EXECUTE format('ALTER TABLE %s ADD CONSTRAINT %I FOREIGN KEY ("tenant_id", %I) REFERENCES %s ("tenant_id", "id")',
                           r.hijo, r.nombre, r.columna, r.padre);
        EXCEPTION WHEN duplicate_object THEN NULL;
        END;
    END LOOP;
END $$;

-- ------------------------------------------------------------- 9. CHECK y EXCLUDE
-- UUID literales (el predicado de un EXCLUDE debe ser IMMUTABLE), deterministicId() de la API:
--   809db700-0627-5fe3-8278-4f038f4475b3 = clinical:LOCATION_ACTIVE
--   8cf00069-81ca-56e1-8e71-9e16333a1f6c = clinical:LOCATION_COMPLETED
--   cdd86257-4297-5941-8ae8-b95e11439a48 = clinical:LOCATION_RESERVED (concepto nuevo de F3)
-- Los CHECK se crean sólo si no existen (gen_integrity ya los emite en 05_constraints con el
-- mismo nombre). Los EXCLUDE se crean DEFERRABLE INITIALLY IMMEDIATE; si ya existen sin ser
-- diferibles (gen_integrity no sabe declarar DEFERRABLE, así que su 05_constraints los deja
-- inmediatos) se recrean: no es una pérdida de datos, las precondiciones ya garantizan que
-- las filas actuales los cumplen.
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conrelid = 'clinical.encounter_locations'::regclass AND conname = 'ck_encounter_locations_bed_period') THEN
        ALTER TABLE "clinical"."encounter_locations" ADD CONSTRAINT "ck_encounter_locations_bed_period"
            CHECK (NOT "is_bed_assignment" OR ("period_start" IS NOT NULL AND "care_space_id" IS NOT NULL));
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conrelid = 'clinical.encounter_locations'::regclass AND conname = 'ck_encounter_locations_bed_period_order') THEN
        ALTER TABLE "clinical"."encounter_locations" ADD CONSTRAINT "ck_encounter_locations_bed_period_order"
            CHECK (NOT "is_bed_assignment" OR "period_end" IS NULL OR "period_end" >= "period_start");
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conrelid = 'clinical.placement_incidents'::regclass AND conname = 'ck_placement_incidents_justification_length') THEN
        ALTER TABLE "clinical"."placement_incidents" ADD CONSTRAINT "ck_placement_incidents_justification_length"
            CHECK (length(btrim("justification_text")) >= 20);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conrelid = 'clinical.placement_incidents'::regclass AND conname = 'ck_placement_incidents_violations_array') THEN
        ALTER TABLE "clinical"."placement_incidents" ADD CONSTRAINT "ck_placement_incidents_violations_array"
            CHECK (jsonb_typeof("violations_json") = 'array');
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conrelid = 'clinical.inpatient_census_days'::regclass AND conname = 'ck_inpatient_census_days_counts') THEN
        ALTER TABLE "clinical"."inpatient_census_days" ADD CONSTRAINT "ck_inpatient_census_days_counts"
            CHECK ("beds_censable" >= 0 AND "beds_available" >= 0 AND "beds_blocked" >= 0 AND "patients_at_cutoff" >= 0 AND "admissions" >= 0 AND "discharges" >= 0 AND "deaths" >= 0 AND "transfers_in" >= 0 AND "transfers_out" >= 0 AND "same_day_stays" >= 0 AND "patient_days" >= 0 AND "discharge_stay_days" >= 0 AND "beds_available" + "beds_blocked" = "beds_censable");
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conrelid = 'clinical.inpatient_census_days'::regclass AND conname = 'ck_inpatient_census_days_closed_has_hash') THEN
        ALTER TABLE "clinical"."inpatient_census_days" ADD CONSTRAINT "ck_inpatient_census_days_closed_has_hash"
            CHECK ("closed_at" IS NULL OR "content_hash" IS NOT NULL);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conrelid = 'clinical.inpatient_census_adjustments'::regclass AND conname = 'ck_inpatient_census_adjustments_field_code') THEN
        ALTER TABLE "clinical"."inpatient_census_adjustments" ADD CONSTRAINT "ck_inpatient_census_adjustments_field_code"
            CHECK ("field_code" IN ('beds_censable', 'beds_available', 'beds_blocked', 'patients_at_cutoff', 'admissions', 'discharges', 'deaths', 'transfers_in', 'transfers_out', 'same_day_stays', 'patient_days', 'discharge_stay_days'));
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conrelid = 'clinical.inpatient_census_adjustments'::regclass AND conname = 'ck_inpatient_census_adjustments_reason') THEN
        ALTER TABLE "clinical"."inpatient_census_adjustments" ADD CONSTRAINT "ck_inpatient_census_adjustments_reason"
            CHECK (btrim("reason_text") <> '' AND "new_value" >= 0);
    END IF;
END $$;

DO $$
BEGIN
    -- INV-30: una cama, un paciente a la vez (historial y reservas incluidos).
    IF EXISTS (SELECT 1 FROM pg_constraint WHERE conrelid = 'clinical.encounter_locations'::regclass
                  AND conname = 'ex_encounter_locations_bed_occupancy' AND NOT condeferrable) THEN
        ALTER TABLE "clinical"."encounter_locations" DROP CONSTRAINT "ex_encounter_locations_bed_occupancy";
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conrelid = 'clinical.encounter_locations'::regclass AND conname = 'ex_encounter_locations_bed_occupancy') THEN
        ALTER TABLE "clinical"."encounter_locations" ADD CONSTRAINT "ex_encounter_locations_bed_occupancy"
            EXCLUDE USING gist ("care_space_id" WITH =, tstzrange("period_start", "period_end", '[)') WITH &&)
            WHERE ("is_bed_assignment" AND "location_status_concept_id" IN ('809db700-0627-5fe3-8278-4f038f4475b3', 'cdd86257-4297-5941-8ae8-b95e11439a48', '8cf00069-81ca-56e1-8e71-9e16333a1f6c'))
            DEFERRABLE INITIALLY IMMEDIATE;
    END IF;

    -- INV-31: un encuentro, una cama a la vez (la reserva de traslado puede convivir).
    IF EXISTS (SELECT 1 FROM pg_constraint WHERE conrelid = 'clinical.encounter_locations'::regclass
                  AND conname = 'ex_encounter_locations_encounter_single_bed' AND NOT condeferrable) THEN
        ALTER TABLE "clinical"."encounter_locations" DROP CONSTRAINT "ex_encounter_locations_encounter_single_bed";
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conrelid = 'clinical.encounter_locations'::regclass AND conname = 'ex_encounter_locations_encounter_single_bed') THEN
        ALTER TABLE "clinical"."encounter_locations" ADD CONSTRAINT "ex_encounter_locations_encounter_single_bed"
            EXCLUDE USING gist ("encounter_id" WITH =, tstzrange("period_start", "period_end", '[)') WITH &&)
            WHERE ("is_bed_assignment" AND "location_status_concept_id" IN ('809db700-0627-5fe3-8278-4f038f4475b3', '8cf00069-81ca-56e1-8e71-9e16333a1f6c'))
            DEFERRABLE INITIALLY IMMEDIATE;
    END IF;

    -- Un encuentro tiene a lo sumo una ubicación de cama ACTIVA (igualdad pura: unicidad parcial
    -- diferible, que un índice UNIQUE no puede ser).
    IF EXISTS (SELECT 1 FROM pg_constraint WHERE conrelid = 'clinical.encounter_locations'::regclass
                  AND conname = 'ex_encounter_locations_encounter_one_active_bed' AND NOT condeferrable) THEN
        ALTER TABLE "clinical"."encounter_locations" DROP CONSTRAINT "ex_encounter_locations_encounter_one_active_bed";
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conrelid = 'clinical.encounter_locations'::regclass AND conname = 'ex_encounter_locations_encounter_one_active_bed') THEN
        ALTER TABLE "clinical"."encounter_locations" ADD CONSTRAINT "ex_encounter_locations_encounter_one_active_bed"
            EXCLUDE USING gist ("encounter_id" WITH =)
            WHERE ("is_bed_assignment" AND "location_status_concept_id" = '809db700-0627-5fe3-8278-4f038f4475b3')
            DEFERRABLE INITIALLY IMMEDIATE;
    END IF;
END $$;

-- ------------------------------------------------------------- 10. triggers
-- 10a. encounter_locations.tenant_id: el escritor actual (EncountersService.checkIn/close) no lo
-- manda; se completa desde el encuentro antes de evaluar el NOT NULL y el RLS. Si el escritor lo
-- manda y no coincide, la FK compuesta (tenant_id, encounter_id) lo rechaza.
CREATE OR REPLACE FUNCTION "clinical"."encounter_locations_fill_tenant"()
RETURNS trigger
LANGUAGE plpgsql
SET search_path = pg_catalog, pg_temp
AS $fn$
BEGIN
    IF NEW."tenant_id" IS NULL THEN
        SELECT e."tenant_id" INTO NEW."tenant_id"
          FROM "clinical"."encounters" e
         WHERE e."id" = NEW."encounter_id";
    END IF;
    RETURN NEW;
END $fn$;

DROP TRIGGER IF EXISTS "trg_encounter_locations_fill_tenant" ON "clinical"."encounter_locations";
CREATE TRIGGER "trg_encounter_locations_fill_tenant"
    BEFORE INSERT ON "clinical"."encounter_locations"
    FOR EACH ROW EXECUTE FUNCTION "clinical"."encounter_locations_fill_tenant"();

-- 10b. INV-35: un censo cerrado (closed_at) no se modifica ni se borra. Los días abiertos sí
-- (se cierran con un UPDATE que fija closed_at; la vista previa de un día abierto no se persiste).
CREATE OR REPLACE FUNCTION "clinical"."inpatient_census_days_guard_closed"()
RETURNS trigger
LANGUAGE plpgsql
SET search_path = pg_catalog, pg_temp
AS $fn$
BEGIN
    IF OLD."closed_at" IS NOT NULL THEN
        RAISE EXCEPTION 'inpatient_census_days: el censo del % (unidad %) está cerrado y es inmutable; corregirlo con un ajuste en inpatient_census_adjustments (% no permitido)',
            OLD."census_date", OLD."clinical_unit_id", TG_OP
            USING ERRCODE = 'restrict_violation';
    END IF;
    IF TG_OP = 'DELETE' THEN
        RETURN OLD;
    END IF;
    RETURN NEW;
END $fn$;

DROP TRIGGER IF EXISTS "trg_inpatient_census_days_closed_guard" ON "clinical"."inpatient_census_days";
CREATE TRIGGER "trg_inpatient_census_days_closed_guard"
    BEFORE UPDATE OR DELETE ON "clinical"."inpatient_census_days"
    FOR EACH ROW EXECUTE FUNCTION "clinical"."inpatient_census_days_guard_closed"();

-- 10c. Un ajuste sólo corrige un censo CERRADO (CENSUS_NOT_CLOSED) y, si cita una entrada,
-- que sea de ese mismo día. Si el día no se ve (otro tenant o inexistente) la FK compuesta
-- da el error; este trigger no revela su existencia.
CREATE OR REPLACE FUNCTION "clinical"."inpatient_census_adjustments_require_closed"()
RETURNS trigger
LANGUAGE plpgsql
SET search_path = pg_catalog, pg_temp
AS $fn$
DECLARE
    v_closed_at timestamptz;
    v_found     boolean;
    v_entry_day uuid;
BEGIN
    SELECT d."closed_at", true INTO v_closed_at, v_found
      FROM "clinical"."inpatient_census_days" d
     WHERE d."id" = NEW."census_day_id";
    IF v_found AND v_closed_at IS NULL THEN
        RAISE EXCEPTION 'inpatient_census_adjustments: el censo % no está cerrado (CENSUS_NOT_CLOSED); un día abierto no se ajusta', NEW."census_day_id"
            USING ERRCODE = 'check_violation';
    END IF;
    IF NEW."entry_ref_id" IS NOT NULL THEN
        SELECT en."census_day_id" INTO v_entry_day
          FROM "clinical"."inpatient_census_entries" en
         WHERE en."id" = NEW."entry_ref_id";
        IF v_entry_day IS NOT NULL AND v_entry_day IS DISTINCT FROM NEW."census_day_id" THEN
            RAISE EXCEPTION 'inpatient_census_adjustments: la entrada % no pertenece al censo %', NEW."entry_ref_id", NEW."census_day_id"
                USING ERRCODE = 'check_violation';
        END IF;
    END IF;
    RETURN NEW;
END $fn$;

DROP TRIGGER IF EXISTS "trg_inpatient_census_adjustments_require_closed" ON "clinical"."inpatient_census_adjustments";
CREATE TRIGGER "trg_inpatient_census_adjustments_require_closed"
    BEFORE INSERT ON "clinical"."inpatient_census_adjustments"
    FOR EACH ROW EXECUTE FUNCTION "clinical"."inpatient_census_adjustments_require_closed"();

-- 10d. WORM de entradas y ajustes del censo: misma función y mismo nombre de trigger que emite
-- gen_integrity.py para `UPDATE_DELETE : forbidden` (diagram_33), así que ambos caminos coinciden.
CREATE SCHEMA IF NOT EXISTS "integrity";

CREATE OR REPLACE FUNCTION "integrity"."forbid_mutation"() RETURNS trigger
LANGUAGE plpgsql AS $$
BEGIN
    RAISE EXCEPTION 'append-only/immutable: % no permitido en %.%',
        TG_OP, TG_TABLE_SCHEMA, TG_TABLE_NAME USING ERRCODE = 'restrict_violation';
END $$;

DO $$
DECLARE
    t text;
BEGIN
    FOREACH t IN ARRAY ARRAY['inpatient_census_entries', 'inpatient_census_adjustments'] LOOP
        EXECUTE format('REVOKE UPDATE, DELETE ON "clinical".%I FROM PUBLIC', t);
        EXECUTE format('DROP TRIGGER IF EXISTS trg_forbid_mutation ON "clinical".%I', t);
        EXECUTE format('CREATE TRIGGER trg_forbid_mutation BEFORE UPDATE OR DELETE ON "clinical".%I FOR EACH ROW EXECUTE FUNCTION "integrity"."forbid_mutation"()', t);
    END LOOP;
END $$;

-- 10e. Historia: tenant por defecto desde la fila de origen y «sólo inserción + cierre de
-- valid_to», con las funciones de F1b. Los triggers llevan nombre propio (trg_f3_*) para no
-- alterar el conteo `trg_fill_tenant` / `trg_close_only` de la verificación de F1b.
DO $$
DECLARE
    r record;
BEGIN
    FOR r IN
        SELECT * FROM (VALUES
            ('encounter_locations_history', 'clinical.encounter_locations', 'encounter_location_id'),
            ('placement_incidents_history',  'clinical.placement_incidents',  'placement_incident_id')
        ) AS v(historia, origen, columna)
    LOOP
        EXECUTE format('DROP TRIGGER IF EXISTS trg_f3_fill_tenant ON "audit".%I', r.historia);
        EXECUTE format('CREATE TRIGGER trg_f3_fill_tenant BEFORE INSERT ON "audit".%I FOR EACH ROW EXECUTE FUNCTION "audit"."structure_history_fill_tenant"(%L, %L)',
                       r.historia, r.origen, r.columna);
        EXECUTE format('DROP TRIGGER IF EXISTS trg_f3_close_only ON "audit".%I', r.historia);
        EXECUTE format('CREATE TRIGGER trg_f3_close_only BEFORE UPDATE OR DELETE ON "audit".%I FOR EACH ROW EXECUTE FUNCTION "audit"."structure_history_close_only"()',
                       r.historia);
    END LOOP;
END $$;

-- ------------------------------------------------------------- 11. privilegios y RLS
-- Mismo criterio que F1/F1b. Si 2026-08-05_tenant_rls.sql se reaplica después (GRANT … ON ALL
-- TABLES), vuelve a dar UPDATE/DELETE de tabla en las historias y en las dos tablas WORM: los
-- triggers siguen rechazando todo lo que no sea cerrar valid_to; reaplicar este patch deja otra
-- vez los privilegios mínimos.
DO $$
DECLARE
    t         text;
    con_dml   text[] := ARRAY['clinical.placement_incidents', 'clinical.inpatient_census_days'];
    solo_ins  text[] := ARRAY['clinical.inpatient_census_entries', 'clinical.inpatient_census_adjustments'];
    historias text[] := ARRAY['audit.encounter_locations_history', 'audit.placement_incidents_history'];
    con_rls   text[] := ARRAY[
        'clinical.encounter_locations',
        'clinical.placement_incidents',
        'clinical.inpatient_census_days',
        'clinical.inpatient_census_entries',
        'clinical.inpatient_census_adjustments',
        'audit.encounter_locations_history',
        'audit.placement_incidents_history'
    ];
BEGIN
    IF EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'mantra_app') THEN
        FOREACH t IN ARRAY con_dml LOOP
            EXECUTE format('GRANT SELECT, INSERT, UPDATE, DELETE ON %s TO mantra_app', t);
        END LOOP;
        FOREACH t IN ARRAY solo_ins LOOP
            EXECUTE format('REVOKE UPDATE, DELETE, TRUNCATE ON %s FROM mantra_app', t);
            EXECUTE format('GRANT SELECT, INSERT ON %s TO mantra_app', t);
        END LOOP;
        FOREACH t IN ARRAY historias LOOP
            EXECUTE format('REVOKE UPDATE, DELETE, TRUNCATE ON %s FROM mantra_app', t);
            EXECUTE format('GRANT SELECT, INSERT ON %s TO mantra_app', t);
            EXECUTE format('GRANT UPDATE ("valid_to") ON %s TO mantra_app', t);
        END LOOP;
    END IF;

    -- Texto exacto de la política de 2026-08-05_tenant_rls.sql (ese patch también la pondría
    -- sola ahora que estas tablas tienen tenant_id).
    FOREACH t IN ARRAY con_rls LOOP
        EXECUTE format('ALTER TABLE %s ENABLE ROW LEVEL SECURITY', t);
        EXECUTE format('ALTER TABLE %s FORCE ROW LEVEL SECURITY', t);
        EXECUTE format('DROP POLICY IF EXISTS tenant_isolation ON %s', t);
        EXECUTE format($pol$
        CREATE POLICY tenant_isolation ON %s
          USING (
            tenant_id = NULLIF(
              current_setting('app.current_tenant_id', true),
              ''
            )::uuid
            OR current_setting('app.system_context', true) = 'true'
          )
          WITH CHECK (
            tenant_id = NULLIF(
              current_setting('app.current_tenant_id', true),
              ''
            )::uuid
            OR current_setting('app.system_context', true) = 'true'
          )
        $pol$, t);
    END LOOP;
END $$;

-- ------------------------------------------------------------- 12. verificación
DO $$
DECLARE
    n_cols  integer;
    n_nn    integer;
    n_tab   integer;
    n_fks   integer;
    n_fkc   integer;
    n_fkbad integer;
    n_ux    integer;
    n_idx   integer;
    n_ck    integer;
    n_ex    integer;
    n_exdef integer;
    n_trg   integer;
    n_rls   integer;
    n_priv  integer;
BEGIN
    SELECT count(*) INTO n_cols FROM information_schema.columns
     WHERE (table_schema, table_name, column_name) IN (
            ('clinical', 'encounters', 'level_of_care_concept_id'), ('clinical', 'encounters', 'admission_source_concept_id'),
            ('clinical', 'encounters', 'discharge_disposition_concept_id'), ('clinical', 'encounters', 'isolation_precaution_concept_id'),
            ('clinical', 'encounters', 'isolation_organism_text'), ('clinical', 'encounters', 'expected_discharge_at'),
            ('clinical', 'encounter_locations', 'tenant_id'), ('clinical', 'encounter_locations', 'is_bed_assignment'),
            ('clinical', 'encounter_locations', 'movement_type_concept_id'), ('clinical', 'encounter_locations', 'previous_encounter_location_id'),
            ('clinical', 'encounter_locations', 'end_reason_concept_id'), ('clinical', 'encounter_locations', 'bed_category_concept_id'),
            ('clinical', 'encounter_locations', 'placement_incident_id'));

    SELECT count(*) INTO n_nn FROM information_schema.columns
     WHERE is_nullable = 'NO'
       AND (table_schema, table_name, column_name) IN (
            ('clinical', 'encounter_locations', 'tenant_id'), ('clinical', 'encounter_locations', 'is_bed_assignment'),
            ('clinical', 'placement_incidents', 'tenant_id'), ('clinical', 'inpatient_census_days', 'tenant_id'),
            ('clinical', 'inpatient_census_entries', 'tenant_id'), ('clinical', 'inpatient_census_adjustments', 'tenant_id'),
            ('audit', 'encounter_locations_history', 'tenant_id'), ('audit', 'placement_incidents_history', 'tenant_id'));

    SELECT count(*) INTO n_tab FROM information_schema.tables
     WHERE (table_schema, table_name) IN (('clinical', 'placement_incidents'), ('clinical', 'inpatient_census_days'),
            ('clinical', 'inpatient_census_entries'), ('clinical', 'inpatient_census_adjustments'),
            ('audit', 'encounter_locations_history'), ('audit', 'placement_incidents_history'));

    SELECT count(*) INTO n_fks FROM pg_constraint
     WHERE contype = 'f' AND convalidated
       AND conname = ANY (ARRAY['fk_encounter_locations_previous_encounter_location_id',
           'fk_encounter_locations_placement_incident_id', 'fk_placement_incidents_encounter_id',
           'fk_placement_incidents_encounter_location_id', 'fk_inpatient_census_entries_census_day_id',
           'fk_inpatient_census_entries_encounter_id', 'fk_inpatient_census_adjustments_census_day_id',
           'fk_inpatient_census_adjustments_entry_ref_id', 'fk_encounters_level_of_care_concept_id',
           'fk_encounters_admission_source_concept_id', 'fk_encounters_discharge_disposition_concept_id',
           'fk_encounters_isolation_precaution_concept_id', 'fk_encounter_locations_tenant_id',
           'fk_encounter_locations_movement_type_concept_id', 'fk_encounter_locations_end_reason_concept_id',
           'fk_encounter_locations_bed_category_concept_id', 'fk_placement_incidents_tenant_id',
           'fk_placement_incidents_care_space_id', 'fk_placement_incidents_patient_profile_id',
           'fk_placement_incidents_authorized_by_user_id', 'fk_placement_incidents_status_concept_id',
           'fk_placement_incidents_reviewed_by_user_id', 'fk_placement_incidents_created_by_user_id',
           'fk_placement_incidents_updated_by_user_id', 'fk_inpatient_census_days_tenant_id',
           'fk_inpatient_census_days_practice_site_id', 'fk_inpatient_census_days_clinical_unit_id',
           'fk_inpatient_census_days_status_concept_id', 'fk_inpatient_census_days_closed_by_user_id',
           'fk_inpatient_census_days_created_by_user_id', 'fk_inpatient_census_days_updated_by_user_id',
           'fk_inpatient_census_entries_tenant_id', 'fk_inpatient_census_entries_patient_profile_id',
           'fk_inpatient_census_entries_care_space_id',
           'fk_inpatient_census_entries_bed_category_concept_id',
           'fk_inpatient_census_entries_movement_concept_id', 'fk_inpatient_census_adjustments_tenant_id',
           'fk_inpatient_census_adjustments_adjusted_by_user_id',
           'fk_encounter_locations_history_encounter_location_id',
           'fk_encounter_locations_history_operation_concept_id',
           'fk_encounter_locations_history_changed_by_user_id',
           'fk_encounter_locations_history_change_reason_concept_id',
           'fk_encounter_locations_history_tenant_id',
           'fk_placement_incidents_history_placement_incident_id',
           'fk_placement_incidents_history_operation_concept_id',
           'fk_placement_incidents_history_changed_by_user_id',
           'fk_placement_incidents_history_change_reason_concept_id',
           'fk_placement_incidents_history_tenant_id']);

    SELECT count(*) INTO n_fkc FROM pg_constraint
     WHERE contype = 'f' AND convalidated AND array_length(conkey, 1) = 2
       AND conname IN ('fk_encounter_locations_tenant_encounter', 'fk_encounter_locations_tenant_site',
            'fk_encounter_locations_tenant_unit', 'fk_encounter_locations_tenant_space',
            'fk_encounter_locations_tenant_previous', 'fk_encounter_locations_tenant_incident',
            'fk_placement_incidents_tenant_encounter', 'fk_placement_incidents_tenant_location',
            'fk_placement_incidents_tenant_space', 'fk_inpatient_census_days_tenant_site',
            'fk_inpatient_census_days_tenant_unit', 'fk_inpatient_census_entries_tenant_day',
            'fk_inpatient_census_entries_tenant_encounter', 'fk_inpatient_census_entries_tenant_space',
            'fk_inpatient_census_adjustments_tenant_day', 'fk_inpatient_census_adjustments_tenant_entry',
            'fk_encounter_locations_history_tenant_source', 'fk_placement_incidents_history_tenant_source');

    SELECT count(*) INTO n_fkbad FROM pg_constraint c
      JOIN pg_class r ON r.oid = c.conrelid JOIN pg_namespace n ON n.oid = r.relnamespace
     WHERE c.contype = 'f' AND NOT c.convalidated
       AND (n.nspname, r.relname) IN (('clinical', 'encounter_locations'), ('clinical', 'placement_incidents'),
            ('clinical', 'inpatient_census_days'), ('clinical', 'inpatient_census_entries'),
            ('clinical', 'inpatient_census_adjustments'), ('audit', 'encounter_locations_history'),
            ('audit', 'placement_incidents_history'));

    SELECT count(*) INTO n_ux FROM pg_indexes
     WHERE indexname IN ('ux_encounters_tenant_id_id', 'ux_encounter_locations_tenant_id_id',
            'ux_placement_incidents_tenant_id_id', 'ux_inpatient_census_days_tenant_id_id',
            'ux_inpatient_census_days_site_unit_date', 'ux_inpatient_census_entries_tenant_id_id');

    SELECT count(*) INTO n_idx FROM pg_indexes
     WHERE indexname = ANY (ARRAY['ux_encounters_tenant_id_id', 'ix_encounters_level_of_care_concept_id',
           'ix_encounters_admission_source_concept_id', 'ix_encounters_discharge_disposition_concept_id',
           'ix_encounters_isolation_precaution_concept_id', 'ux_encounter_locations_tenant_id_id',
           'ix_encounter_locations_tenant_id', 'ix_encounter_locations_movement_type_concept_id',
           'ix_encounter_locations_previous_encounter_location_id',
           'ix_encounter_locations_end_reason_concept_id', 'ix_encounter_locations_bed_category_concept_id',
           'ix_encounter_locations_placement_incident_id', 'ux_placement_incidents_tenant_id_id',
           'ix_placement_incidents_tenant_id', 'ix_placement_incidents_encounter_id',
           'ix_placement_incidents_encounter_location_id', 'ix_placement_incidents_care_space_id',
           'ix_placement_incidents_patient_profile_id', 'ix_placement_incidents_authorized_by_user_id',
           'ix_placement_incidents_status_concept_id', 'ix_placement_incidents_reviewed_by_user_id',
           'ix_placement_incidents_created_by_user_id', 'ix_placement_incidents_updated_by_user_id',
           'ix_placement_incidents_tenant_id_status_concept_id', 'ux_inpatient_census_days_site_unit_date',
           'ux_inpatient_census_days_tenant_id_id', 'ix_inpatient_census_days_tenant_id',
           'ix_inpatient_census_days_clinical_unit_id', 'ix_inpatient_census_days_status_concept_id',
           'ix_inpatient_census_days_closed_by_user_id', 'ix_inpatient_census_days_created_by_user_id',
           'ix_inpatient_census_days_updated_by_user_id', 'ux_inpatient_census_entries_tenant_id_id',
           'ix_inpatient_census_entries_tenant_id', 'ix_inpatient_census_entries_census_day_id',
           'ix_inpatient_census_entries_encounter_id', 'ix_inpatient_census_entries_patient_profile_id',
           'ix_inpatient_census_entries_care_space_id',
           'ix_inpatient_census_entries_bed_category_concept_id',
           'ix_inpatient_census_entries_movement_concept_id', 'ix_inpatient_census_adjustments_tenant_id',
           'ix_inpatient_census_adjustments_census_day_id', 'ix_inpatient_census_adjustments_entry_ref_id',
           'ix_inpatient_census_adjustments_adjusted_by_user_id',
           'ix_encounter_locations_history_encounter_location_id',
           'ix_encounter_locations_history_operation_concept_id',
           'ix_encounter_locations_history_changed_by_user_id',
           'ix_encounter_locations_history_change_reason_concept_id',
           'brin_encounter_locations_history_recorded_at', 'ix_encounter_locations_history_tenant_id',
           'ix_placement_incidents_history_placement_incident_id',
           'ix_placement_incidents_history_operation_concept_id',
           'ix_placement_incidents_history_changed_by_user_id',
           'ix_placement_incidents_history_change_reason_concept_id',
           'brin_placement_incidents_history_recorded_at', 'ix_placement_incidents_history_tenant_id']);

    SELECT count(*) INTO n_ck FROM pg_constraint
     WHERE contype = 'c' AND convalidated
       AND conname IN ('ck_encounter_locations_bed_period', 'ck_encounter_locations_bed_period_order',
            'ck_placement_incidents_justification_length', 'ck_placement_incidents_violations_array',
            'ck_inpatient_census_days_counts', 'ck_inpatient_census_days_closed_has_hash',
            'ck_inpatient_census_adjustments_field_code', 'ck_inpatient_census_adjustments_reason');

    SELECT count(*) INTO n_ex FROM pg_constraint
     WHERE conrelid = 'clinical.encounter_locations'::regclass AND contype = 'x'
       AND condeferrable AND NOT condeferred
       AND conname IN ('ex_encounter_locations_bed_occupancy', 'ex_encounter_locations_encounter_single_bed',
            'ex_encounter_locations_encounter_one_active_bed');

    -- que la definición sea la del contrato y no una homónima distinta
    SELECT count(*) INTO n_exdef FROM pg_constraint
     WHERE conrelid = 'clinical.encounter_locations'::regclass AND contype = 'x'
       AND ((conname = 'ex_encounter_locations_bed_occupancy'
             AND pg_get_constraintdef(oid) LIKE '%809db700-0627-5fe3-8278-4f038f4475b3%'
             AND pg_get_constraintdef(oid) LIKE '%cdd86257-4297-5941-8ae8-b95e11439a48%'
             AND pg_get_constraintdef(oid) LIKE '%8cf00069-81ca-56e1-8e71-9e16333a1f6c%'
             AND pg_get_constraintdef(oid) LIKE '%care_space_id WITH =%')
         OR (conname = 'ex_encounter_locations_encounter_single_bed'
             AND pg_get_constraintdef(oid) LIKE '%809db700-0627-5fe3-8278-4f038f4475b3%'
             AND pg_get_constraintdef(oid) LIKE '%8cf00069-81ca-56e1-8e71-9e16333a1f6c%'
             AND pg_get_constraintdef(oid) NOT LIKE '%cdd86257%'
             AND pg_get_constraintdef(oid) LIKE '%encounter_id WITH =%')
         OR (conname = 'ex_encounter_locations_encounter_one_active_bed'
             AND pg_get_constraintdef(oid) LIKE '%809db700-0627-5fe3-8278-4f038f4475b3%'
             AND pg_get_constraintdef(oid) NOT LIKE '%8cf00069%'));

    SELECT count(*) INTO n_trg FROM pg_trigger t
      JOIN pg_class r ON r.oid = t.tgrelid JOIN pg_namespace n ON n.oid = r.relnamespace
     WHERE NOT t.tgisinternal
       AND ((n.nspname = 'clinical' AND r.relname = 'encounter_locations' AND t.tgname = 'trg_encounter_locations_fill_tenant')
         OR (n.nspname = 'clinical' AND r.relname = 'inpatient_census_days' AND t.tgname = 'trg_inpatient_census_days_closed_guard')
         OR (n.nspname = 'clinical' AND r.relname = 'inpatient_census_adjustments' AND t.tgname = 'trg_inpatient_census_adjustments_require_closed')
         OR (n.nspname = 'clinical' AND r.relname IN ('inpatient_census_entries', 'inpatient_census_adjustments') AND t.tgname = 'trg_forbid_mutation')
         OR (n.nspname = 'audit' AND r.relname IN ('encounter_locations_history', 'placement_incidents_history')
             AND t.tgname IN ('trg_f3_fill_tenant', 'trg_f3_close_only')));

    SELECT count(*) INTO n_rls
      FROM pg_class c JOIN pg_namespace n ON n.oid = c.relnamespace
      JOIN pg_policies p ON p.schemaname = n.nspname AND p.tablename = c.relname AND p.policyname = 'tenant_isolation'
     WHERE c.relrowsecurity AND c.relforcerowsecurity
       AND (n.nspname, c.relname) IN (('clinical', 'encounter_locations'), ('clinical', 'placement_incidents'),
            ('clinical', 'inpatient_census_days'), ('clinical', 'inpatient_census_entries'),
            ('clinical', 'inpatient_census_adjustments'), ('audit', 'encounter_locations_history'),
            ('audit', 'placement_incidents_history'));

    n_priv := 0;
    IF EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'mantra_app') THEN
        SELECT count(*) INTO n_priv FROM unnest(ARRAY['clinical.inpatient_census_entries', 'clinical.inpatient_census_adjustments',
                'audit.encounter_locations_history', 'audit.placement_incidents_history']) t
         WHERE has_table_privilege('mantra_app', t, 'UPDATE') OR has_table_privilege('mantra_app', t, 'DELETE');
    END IF;

    IF n_cols <> 13 OR n_nn <> 8 OR n_tab <> 6 OR n_fks <> 48 OR n_fkc <> 18 OR n_fkbad <> 0 OR n_ux <> 6
       OR n_idx <> 56 OR n_ck <> 8 OR n_ex <> 3 OR n_exdef <> 3 OR n_trg <> 9 OR n_rls <> 7 OR n_priv <> 0 THEN
        RAISE EXCEPTION
            'infraestructura F3 incompleta: columnas=% (13), NOT NULL=% (8), tablas=% (6), FK simples=% (48), FK compuestas=% (18), FK sin validar=% (0), únicos=% (6), índices=% (56), CHECK=% (8), EXCLUDE diferibles=% (3), con la definición del contrato=% (3), triggers=% (9), RLS=% (7), tablas WORM/historia con UPDATE o DELETE para mantra_app=% (0)',
            n_cols, n_nn, n_tab, n_fks, n_fkc, n_fkbad, n_ux, n_idx, n_ck, n_ex, n_exdef, n_trg, n_rls, n_priv;
    END IF;

    RAISE NOTICE 'infraestructura F3 aplicada: 13 columnas, 6 tablas, 18 FK compuestas por tenant, 3 EXCLUDE diferibles (cama 1:1, encuentro 1 cama, 1 ACTIVA), censo cerrado inmutable, 7 tablas con RLS.';
END $$;

COMMIT;
