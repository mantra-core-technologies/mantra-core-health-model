-- ============================================================================
-- SALUD · patch infraestructura hospitalaria F3 (internación / ADT · schema clinical)
-- sobre BD viva
-- Fecha: 2026-10-29 · Contrato: SALUD/Arquitectura/infraestructura-hospitalaria/
--   CONTRATO-F2-F5.md §F3.1 (repositorio de documentación)
-- Requiere: 2026-10-29_infraestructura_f1.sql (practice.care_spaces.form_concept_id) y
--   2026-10-29_infraestructura_f1b_seguridad.sql (UNIQUE (tenant_id, id) de practice y las
--   funciones audit.structure_history_fill_tenant / structure_history_close_only).
-- Idempotente (ADD COLUMN IF NOT EXISTS / CREATE … IF NOT EXISTS / FK con
-- `duplicate_object` / DROP … IF EXISTS antes de cada CHECK, EXCLUDE, trigger y
-- política). Se puede aplicar N veces.
--
-- Contexto: gen_ddl.py / gen_integrity.py ya emiten las columnas, tablas, FKs, índices,
-- CHECK, EXCLUDE y guardas append-only en SQL/08_clinical/ (y las historias en
-- SQL/10_audit/, que regenera el integrador) desde que diagram_08/10/33 los declaran. Las
-- sentencias de columnas, tablas, FKs, índices y restricciones se copiaron de los
-- archivos generados, no se escribieron a mano. Lo escrito a mano: la precondición, los
-- backfills, el SET NOT NULL, la guarda del censo cerrado (que el módulo 33 no expresa),
-- el RLS y la verificación final.
--
-- QUÉ CIERRA.
--   A. clinical.encounters (internación = ENC_IMP): level_of_care, admission_source,
--      discharge_disposition, isolation_precaution (+ organismo), expected_discharge_at.
--   B. clinical.encounter_locations (historial de estancias): tenant_id (backfill desde el
--      encuentro, después NOT NULL), is_bed_assignment (backfill: true sólo si el espacio
--      es forma LOC_FORM_BED), movimiento, ubicación previa, motivo de cierre, foto de la
--      categoría de cama e incidente de ubicación.
--   C. Restricciones de cama: ck_encounter_locations_bed_period y los dos EXCLUDE
--      DEFERRABLE INITIALLY IMMEDIATE (una cama, un paciente a la vez; un encuentro, una
--      cama a la vez) — el intercambio A17 los difiere con SET CONSTRAINTS.
--   D. Tablas nuevas: clinical.placement_incidents, inpatient_census_days,
--      inpatient_census_entries, inpatient_census_adjustments; audit.encounter_locations_
--      history y audit.placement_incidents_history.
--   E. Guardas: detalle y ajustes del censo append-only (forbid_mutation); el día de censo
--      CERRADO rechaza UPDATE/DELETE (trg_inpatient_census_days_closed_guard).
--   F. Aislamiento entre tenants en las REFERENCIAS (patrón F1b, 2026-10-29_infraestructura_
--      f1b_seguridad.sql): UNIQUE (tenant_id, id) en encounters, encounter_locations,
--      placement_incidents e inpatient_census_days, y 17 FK compuestas (tenant_id, x_id) →
--      padre (tenant_id, id): encuentro, sede, unidad, espacio, ubicación previa, incidente,
--      día de censo y origen de la historia. El paciente (profiles.patient_profiles) no tiene
--      tenant: trigger BEFORE INSERT/UPDATE que exige que placement_incidents y
--      inpatient_census_entries lleven el MISMO paciente que su encuentro.
--   G. Historia (audit.encounter_locations_history, audit.placement_incidents_history) con
--      el patrón F1b: tenant_id NOT NULL (lo completa un trigger desde la fila de origen si la
--      API no lo manda), sólo inserción + cierre de valid_to (trigger, también para el dueño),
--      mantra_app con SELECT, INSERT y UPDATE ("valid_to") únicamente, RLS tenant_isolation.
--   H. RLS tenant_isolation (texto exacto de 2026-08-05_tenant_rls.sql) en las siete tablas
--      con tenant_id: encounter_locations, placement_incidents, las tres del censo y las dos
--      historias.
--
-- UUID LITERALES (deterministicId de la API, common/constants/concepts.ts):
--   809db700-0627-5fe3-8278-4f038f4475b3  clinical:LOCATION_ACTIVE
--   8cf00069-81ca-56e1-8e71-9e16333a1f6c  clinical:LOCATION_COMPLETED
--   cdd86257-4297-5941-8ae8-b95e11439a48  clinical:LOCATION_RESERVED   (concepto nuevo, F3)
--   f17b79e2-e453-5b4e-aa70-6691fba364ec  clinical:CENSUS_CLOSED       (concepto nuevo, F3)
--   63ef5a86-740b-5fc6-8b93-3010ed5067a8  practice:LOC_FORM_BED        (concepto de F1)
--
-- LO QUE ESTE PATCH NO HACE.
--   - No siembra conceptos (LOCATION_RESERVED/CANCELLED, ADT_*, CENSUS_*, CEN_*, PLC_INC_*,
--     LOC_CARE_*, ADM_SRC_*, DISP_*, ENC_IMP): los siembra la API (clinical.concepts.ts).
--   - No toca period_start/period_end ni estados de filas existentes.
--
-- PRECONDICIÓN. Antes de crear los EXCLUDE cuenta, entre las filas que quedarían como
-- cama (is_bed_assignment ya en true, o espacio con forma LOC_FORM_BED), los solapes por
-- cama y por encuentro, las camas sin period_start y los rangos invertidos. Si hay alguno
-- aborta con RAISE EXCEPTION y el detalle; el BEGIN hace rollback de todo. Sin backfill
-- silencioso: resolver a mano y volver a aplicar. Consulta para el operador:
--
--   SELECT a.id, b.id, a.care_space_id, a.period_start, a.period_end, b.period_start, b.period_end
--     FROM clinical.encounter_locations a
--     JOIN clinical.encounter_locations b ON b.care_space_id = a.care_space_id AND a.id < b.id
--      AND tstzrange(a.period_start, a.period_end, '[)') && tstzrange(b.period_start, b.period_end, '[)')
--     JOIN practice.care_spaces cs ON cs.id = a.care_space_id
--    WHERE cs.form_concept_id = '63ef5a86-740b-5fc6-8b93-3010ed5067a8';
--
-- DELTAS ESPERADOS sobre la base viva (antes de este patch):
--   columnas  +13  (encounters 6 · encounter_locations 7)
--   tablas     +6  (4 en clinical, 2 en audit)
--   FKs       +64  (47 generadas + 17 compuestas)
--   índices   +61  (55 declarados, 5 de ellos únicos, + 6 PK de las tablas nuevas)
--             +2   (índices de los dos EXCLUDE)
--   CHECK      +3 · EXCLUDE +2 · triggers +9 · políticas RLS +7
-- ============================================================================

BEGIN;

-- Los backfills leen encounters/care_spaces y escriben encounter_locations; con RLS
-- forzada el rol dueño la sortea si es superusuario. Si no lo es, se abre el contexto
-- SYSTEM sólo para esta transacción (SET LOCAL).
SET LOCAL app.system_context = 'true';

CREATE EXTENSION IF NOT EXISTS btree_gist;  -- requerido por EXCLUDE

-- ------------------------------------------------------------- A. encounters

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

-- ------------------------------------------------------------- B. encounter_locations

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

-- tenant_id: el del encuentro. Sólo las filas con NULL: una segunda pasada no cambia nada.
UPDATE "clinical"."encounter_locations" el
   SET "tenant_id" = e."tenant_id"
  FROM "clinical"."encounters" e
 WHERE e."id" = el."encounter_id"
   AND el."tenant_id" IS NULL;

DO $$
DECLARE
    n_sin  integer;
    n_cruz integer;
BEGIN
    SELECT count(*) INTO n_sin FROM "clinical"."encounter_locations" WHERE "tenant_id" IS NULL;
    IF n_sin > 0 THEN
        RAISE EXCEPTION 'clinical.encounter_locations: % fila(s) sin tenant tras el backfill (¿encounter_id huérfano?)', n_sin;
    END IF;
    -- Una fila con tenant distinto al de su encuentro rompería el aislamiento: se aborta
    -- en vez de corregirla, porque decidir cuál es el correcto no le toca al patch.
    SELECT count(*) INTO n_cruz
      FROM "clinical"."encounter_locations" el
      JOIN "clinical"."encounters" e ON e."id" = el."encounter_id"
     WHERE el."tenant_id" IS DISTINCT FROM e."tenant_id";
    IF n_cruz > 0 THEN
        RAISE EXCEPTION 'clinical.encounter_locations: % fila(s) con tenant_id distinto al de su encuentro; revisar a mano', n_cruz;
    END IF;
END $$;

ALTER TABLE "clinical"."encounter_locations" ALTER COLUMN "tenant_id" SET NOT NULL;

-- ------------------------------------------------------------- 0. precondición de cama
-- Se evalúa sobre las filas que QUEDARÍAN como cama tras el backfill, antes de tocarlas.
DO $$
DECLARE
    n_cama     integer;
    n_enc      integer;
    n_sin_ini  integer;
    n_inv      integer;
    detalle    text;
BEGIN
    CREATE TEMP TABLE _f3_camas ON COMMIT DROP AS
        SELECT el."id", el."encounter_id", el."care_space_id", el."period_start",
               el."period_end", el."location_status_concept_id"
          FROM "clinical"."encounter_locations" el
          LEFT JOIN "practice"."care_spaces" cs ON cs."id" = el."care_space_id"
         WHERE el."is_bed_assignment"
            OR cs."form_concept_id" = '63ef5a86-740b-5fc6-8b93-3010ed5067a8';  -- LOC_FORM_BED

    SELECT count(*) INTO n_sin_ini FROM _f3_camas
     WHERE "period_start" IS NULL OR "care_space_id" IS NULL;
    SELECT count(*) INTO n_inv FROM _f3_camas
     WHERE "period_end" IS NOT NULL AND "period_start" IS NOT NULL AND "period_end" < "period_start";
    IF n_sin_ini > 0 OR n_inv > 0 THEN
        RAISE EXCEPTION 'clinical.encounter_locations: % fila(s) de cama sin period_start/care_space_id y % con period_end < period_start; no se marca is_bed_assignment ni se crean los EXCLUDE. Corregir a mano y volver a aplicar.', n_sin_ini, n_inv
            USING ERRCODE = 'check_violation';
    END IF;

    SELECT count(*), string_agg(format('cama %s: %s × %s', a."care_space_id", a."id", b."id"), '; ')
      INTO n_cama, detalle
      FROM _f3_camas a
      JOIN _f3_camas b
        ON b."care_space_id" = a."care_space_id" AND a."id" < b."id"
       AND tstzrange(a."period_start", a."period_end", '[)') && tstzrange(b."period_start", b."period_end", '[)')
     WHERE a."location_status_concept_id" IN ('809db700-0627-5fe3-8278-4f038f4475b3', 'cdd86257-4297-5941-8ae8-b95e11439a48', '8cf00069-81ca-56e1-8e71-9e16333a1f6c')
       AND b."location_status_concept_id" IN ('809db700-0627-5fe3-8278-4f038f4475b3', 'cdd86257-4297-5941-8ae8-b95e11439a48', '8cf00069-81ca-56e1-8e71-9e16333a1f6c');
    IF n_cama > 0 THEN
        RAISE EXCEPTION 'clinical.encounter_locations: % par(es) de estancias solapadas en la misma cama; no se crea ex_encounter_locations_bed_occupancy y no se toca ningún dato. Detalle: %', n_cama, left(detalle, 2000)
            USING ERRCODE = 'exclusion_violation';
    END IF;

    SELECT count(*), string_agg(format('encuentro %s: %s × %s', a."encounter_id", a."id", b."id"), '; ')
      INTO n_enc, detalle
      FROM _f3_camas a
      JOIN _f3_camas b
        ON b."encounter_id" = a."encounter_id" AND a."id" < b."id"
       AND tstzrange(a."period_start", a."period_end", '[)') && tstzrange(b."period_start", b."period_end", '[)')
     WHERE a."location_status_concept_id" IN ('809db700-0627-5fe3-8278-4f038f4475b3', '8cf00069-81ca-56e1-8e71-9e16333a1f6c')
       AND b."location_status_concept_id" IN ('809db700-0627-5fe3-8278-4f038f4475b3', '8cf00069-81ca-56e1-8e71-9e16333a1f6c');
    IF n_enc > 0 THEN
        RAISE EXCEPTION 'clinical.encounter_locations: % par(es) de camas solapadas del mismo encuentro; no se crea ex_encounter_locations_encounter_single_bed y no se toca ningún dato. Detalle: %', n_enc, left(detalle, 2000)
            USING ERRCODE = 'exclusion_violation';
    END IF;
END $$;

-- is_bed_assignment: sólo espacios con forma BED (F1). La API la escribe desde ahora.
UPDATE "clinical"."encounter_locations" el
   SET "is_bed_assignment" = true
  FROM "practice"."care_spaces" cs
 WHERE cs."id" = el."care_space_id"
   AND cs."form_concept_id" = '63ef5a86-740b-5fc6-8b93-3010ed5067a8'  -- LOC_FORM_BED
   AND NOT el."is_bed_assignment";

-- ------------------------------------------------------------- D. tablas nuevas

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
    "care_space_id" uuid NOT NULL,
    "bed_category_concept_id" uuid,
    "movement_concept_id" uuid NOT NULL,
    "occurred_at" timestamptz NOT NULL,
    "created_at" timestamptz NOT NULL,
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

-- Historia creada por una versión previa de este patch (sin tenant_id): se agrega, se
-- completa desde la fila de origen y pasa a NOT NULL. En una base nueva no hace nada.
ALTER TABLE "audit"."encounter_locations_history" ADD COLUMN IF NOT EXISTS "tenant_id" uuid;
ALTER TABLE "audit"."placement_incidents_history" ADD COLUMN IF NOT EXISTS "tenant_id" uuid;
UPDATE "audit"."encounter_locations_history" h SET "tenant_id" = o."tenant_id"
  FROM "clinical"."encounter_locations" o
 WHERE o."id" = h."encounter_location_id" AND h."tenant_id" IS NULL;
UPDATE "audit"."placement_incidents_history" h SET "tenant_id" = o."tenant_id"
  FROM "clinical"."placement_incidents" o
 WHERE o."id" = h."placement_incident_id" AND h."tenant_id" IS NULL;
DO $$
DECLARE n integer;
BEGIN
    SELECT (SELECT count(*) FROM "audit"."encounter_locations_history" WHERE "tenant_id" IS NULL)
         + (SELECT count(*) FROM "audit"."placement_incidents_history" WHERE "tenant_id" IS NULL) INTO n;
    IF n > 0 THEN
        RAISE EXCEPTION 'audit: % fila(s) de historia F3 sin tenant derivable desde su origen; revisar a mano', n;
    END IF;
END $$;
ALTER TABLE "audit"."encounter_locations_history" ALTER COLUMN "tenant_id" SET NOT NULL;
ALTER TABLE "audit"."placement_incidents_history" ALTER COLUMN "tenant_id" SET NOT NULL;

-- ------------------------------------------------------------- FKs (copiadas de 03_fk_intra y 90_fk_deferred)

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
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: profiles.patient_profiles (requiere schema profiles)
DO $$ BEGIN
    ALTER TABLE "clinical"."placement_incidents"
        ADD CONSTRAINT "fk_placement_incidents_patient_profile_id" FOREIGN KEY ("patient_profile_id")
        REFERENCES "profiles"."patient_profiles" ("profile_id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

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
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: practice.clinical_units (requiere schema practice)
DO $$ BEGIN
    ALTER TABLE "clinical"."inpatient_census_days"
        ADD CONSTRAINT "fk_inpatient_census_days_clinical_unit_id" FOREIGN KEY ("clinical_unit_id")
        REFERENCES "practice"."clinical_units" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

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
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: practice.care_spaces (requiere schema practice)
DO $$ BEGIN
    ALTER TABLE "clinical"."inpatient_census_entries"
        ADD CONSTRAINT "fk_inpatient_census_entries_care_space_id" FOREIGN KEY ("care_space_id")
        REFERENCES "practice"."care_spaces" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

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

-- ------------------------------------------------------------- índices (copiados de 04_indexes)

CREATE INDEX IF NOT EXISTS "ix_encounters_level_of_care_concept_id" ON "clinical"."encounters" ("level_of_care_concept_id");

CREATE INDEX IF NOT EXISTS "ix_encounters_admission_source_concept_id" ON "clinical"."encounters" ("admission_source_concept_id");

CREATE INDEX IF NOT EXISTS "ix_encounters_discharge_disposition_concept_id" ON "clinical"."encounters" ("discharge_disposition_concept_id");

CREATE INDEX IF NOT EXISTS "ix_encounters_isolation_precaution_concept_id" ON "clinical"."encounters" ("isolation_precaution_concept_id");

CREATE UNIQUE INDEX IF NOT EXISTS "ux_encounters_tenant_id_id" ON "clinical"."encounters" ("tenant_id", "id");

CREATE INDEX IF NOT EXISTS "ix_encounter_locations_tenant_id" ON "clinical"."encounter_locations" ("tenant_id");

CREATE INDEX IF NOT EXISTS "ix_encounter_locations_movement_type_concept_id" ON "clinical"."encounter_locations" ("movement_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_encounter_locations_previous_encounter_location_id" ON "clinical"."encounter_locations" ("previous_encounter_location_id");

CREATE INDEX IF NOT EXISTS "ix_encounter_locations_end_reason_concept_id" ON "clinical"."encounter_locations" ("end_reason_concept_id");

CREATE INDEX IF NOT EXISTS "ix_encounter_locations_bed_category_concept_id" ON "clinical"."encounter_locations" ("bed_category_concept_id");

CREATE INDEX IF NOT EXISTS "ix_encounter_locations_placement_incident_id" ON "clinical"."encounter_locations" ("placement_incident_id");

CREATE INDEX IF NOT EXISTS "ix_encounter_locations_bed_period" ON "clinical"."encounter_locations" ("care_space_id", "period_start" DESC) WHERE is_bed_assignment;

CREATE UNIQUE INDEX IF NOT EXISTS "ux_encounter_locations_tenant_id_id" ON "clinical"."encounter_locations" ("tenant_id", "id");

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

CREATE UNIQUE INDEX IF NOT EXISTS "ux_placement_incidents_tenant_id_id" ON "clinical"."placement_incidents" ("tenant_id", "id");

CREATE UNIQUE INDEX IF NOT EXISTS "ux_inpatient_census_days_site_unit_date" ON "clinical"."inpatient_census_days" ("practice_site_id", "clinical_unit_id", "census_date");

CREATE INDEX IF NOT EXISTS "ix_inpatient_census_days_tenant_id" ON "clinical"."inpatient_census_days" ("tenant_id");

CREATE INDEX IF NOT EXISTS "ix_inpatient_census_days_clinical_unit_id" ON "clinical"."inpatient_census_days" ("clinical_unit_id");

CREATE INDEX IF NOT EXISTS "ix_inpatient_census_days_status_concept_id" ON "clinical"."inpatient_census_days" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_inpatient_census_days_closed_by_user_id" ON "clinical"."inpatient_census_days" ("closed_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_inpatient_census_days_created_by_user_id" ON "clinical"."inpatient_census_days" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_inpatient_census_days_updated_by_user_id" ON "clinical"."inpatient_census_days" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_inpatient_census_days_site_date" ON "clinical"."inpatient_census_days" ("practice_site_id", "census_date" DESC);

CREATE UNIQUE INDEX IF NOT EXISTS "ux_inpatient_census_days_tenant_id_id" ON "clinical"."inpatient_census_days" ("tenant_id", "id");

CREATE INDEX IF NOT EXISTS "ix_inpatient_census_entries_tenant_id" ON "clinical"."inpatient_census_entries" ("tenant_id");

CREATE INDEX IF NOT EXISTS "ix_inpatient_census_entries_census_day_id" ON "clinical"."inpatient_census_entries" ("census_day_id");

CREATE INDEX IF NOT EXISTS "ix_inpatient_census_entries_encounter_id" ON "clinical"."inpatient_census_entries" ("encounter_id");

CREATE INDEX IF NOT EXISTS "ix_inpatient_census_entries_patient_profile_id" ON "clinical"."inpatient_census_entries" ("patient_profile_id");

CREATE INDEX IF NOT EXISTS "ix_inpatient_census_entries_care_space_id" ON "clinical"."inpatient_census_entries" ("care_space_id");

CREATE INDEX IF NOT EXISTS "ix_inpatient_census_entries_bed_category_concept_id" ON "clinical"."inpatient_census_entries" ("bed_category_concept_id");

CREATE INDEX IF NOT EXISTS "ix_inpatient_census_entries_movement_concept_id" ON "clinical"."inpatient_census_entries" ("movement_concept_id");

CREATE INDEX IF NOT EXISTS "ix_inpatient_census_adjustments_tenant_id" ON "clinical"."inpatient_census_adjustments" ("tenant_id");

CREATE INDEX IF NOT EXISTS "ix_inpatient_census_adjustments_census_day_id" ON "clinical"."inpatient_census_adjustments" ("census_day_id", "created_at");

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

-- ------------------------------------------------------------- F. FKs compuestas (escritas a mano)
-- (tenant_id, x_id) → padre (tenant_id, id), igual que F1b. MATCH SIMPLE: si x_id es NULL no
-- se exige nada. Conviven con la FK simple generada. Antes de crearlas se cuentan las
-- referencias entre tenants distintos y se aborta con la lista (la FK fallaría igual, pero
-- sin decir cuáles son).
CREATE TEMP TABLE _f3_fk_tenant (hijo text, nombre text, columna text, padre text) ON COMMIT DROP;
INSERT INTO _f3_fk_tenant VALUES
    ('clinical.encounter_locations',          'fk_encounter_locations_tenant_encounter',      'encounter_id',                   'clinical.encounters'),
    ('clinical.encounter_locations',          'fk_encounter_locations_tenant_site',           'practice_site_id',               'practice.practice_sites'),
    ('clinical.encounter_locations',          'fk_encounter_locations_tenant_unit',           'clinical_unit_id',               'practice.clinical_units'),
    ('clinical.encounter_locations',          'fk_encounter_locations_tenant_space',          'care_space_id',                  'practice.care_spaces'),
    ('clinical.encounter_locations',          'fk_encounter_locations_tenant_previous',       'previous_encounter_location_id', 'clinical.encounter_locations'),
    ('clinical.encounter_locations',          'fk_encounter_locations_tenant_incident',       'placement_incident_id',          'clinical.placement_incidents'),
    ('clinical.placement_incidents',          'fk_placement_incidents_tenant_encounter',      'encounter_id',                   'clinical.encounters'),
    ('clinical.placement_incidents',          'fk_placement_incidents_tenant_location',       'encounter_location_id',          'clinical.encounter_locations'),
    ('clinical.placement_incidents',          'fk_placement_incidents_tenant_space',          'care_space_id',                  'practice.care_spaces'),
    ('clinical.inpatient_census_days',        'fk_inpatient_census_days_tenant_site',         'practice_site_id',               'practice.practice_sites'),
    ('clinical.inpatient_census_days',        'fk_inpatient_census_days_tenant_unit',         'clinical_unit_id',               'practice.clinical_units'),
    ('clinical.inpatient_census_entries',     'fk_inpatient_census_entries_tenant_day',       'census_day_id',                  'clinical.inpatient_census_days'),
    ('clinical.inpatient_census_entries',     'fk_inpatient_census_entries_tenant_encounter', 'encounter_id',                   'clinical.encounters'),
    ('clinical.inpatient_census_entries',     'fk_inpatient_census_entries_tenant_space',     'care_space_id',                  'practice.care_spaces'),
    ('clinical.inpatient_census_adjustments', 'fk_inpatient_census_adjustments_tenant_day',   'census_day_id',                  'clinical.inpatient_census_days'),
    ('audit.encounter_locations_history',     'fk_encounter_locations_history_tenant_source', 'encounter_location_id',          'clinical.encounter_locations'),
    ('audit.placement_incidents_history',     'fk_placement_incidents_history_tenant_source', 'placement_incident_id',          'clinical.placement_incidents');

DO $$
DECLARE
    r       record;
    n       bigint;
    total   bigint := 0;
    detalle text := '';
BEGIN
    FOR r IN SELECT * FROM _f3_fk_tenant LOOP
        EXECUTE format('SELECT count(*) FROM %s h WHERE h.%I IS NOT NULL AND NOT EXISTS '
                       '(SELECT 1 FROM %s p WHERE p."id" = h.%I AND p."tenant_id" = h."tenant_id")',
                       r.hijo, r.columna, r.padre, r.columna)
           INTO n;
        IF n > 0 THEN
            total := total + n;
            detalle := detalle || format('%s.%s → %s: %s; ', r.hijo, r.columna, r.padre, n);
        END IF;
    END LOOP;
    IF total > 0 THEN
        RAISE EXCEPTION 'F3: % referencia(s) hijo → padre entre tenants distintos (o a un padre inexistente); no se crean las FK compuestas y no se toca ningún dato. Detalle: %', total, detalle
            USING ERRCODE = 'foreign_key_violation';
    END IF;

    FOR r IN SELECT * FROM _f3_fk_tenant LOOP
        BEGIN
            EXECUTE format('ALTER TABLE %s ADD CONSTRAINT %I FOREIGN KEY ("tenant_id", %I) REFERENCES %s ("tenant_id", "id")',
                           r.hijo, r.nombre, r.columna, r.padre);
        EXCEPTION WHEN duplicate_object THEN NULL;
        END;
    END LOOP;
END $$;

-- El paciente no tiene tenant (profiles.patient_profiles es la persona, global): no hay FK
-- compuesta posible. Lo que sí garantiza la base es que el incidente y la fila del censo
-- nombren al MISMO paciente que su encuentro (que sí está acotado al tenant por la FK de
-- arriba). SECURITY INVOKER: con RLS, el encuentro sólo es visible en su propio tenant.
CREATE OR REPLACE FUNCTION "clinical"."assert_patient_matches_encounter"()
RETURNS trigger
LANGUAGE plpgsql
SET search_path = pg_catalog, pg_temp
AS $fn$
DECLARE
    p uuid;
BEGIN
    SELECT e."patient_profile_id" INTO p FROM "clinical"."encounters" e WHERE e."id" = NEW."encounter_id";
    IF p IS DISTINCT FROM NEW."patient_profile_id" THEN
        RAISE EXCEPTION '%.%: patient_profile_id % no es el paciente del encuentro %',
            TG_TABLE_SCHEMA, TG_TABLE_NAME, NEW."patient_profile_id", NEW."encounter_id"
            USING ERRCODE = 'foreign_key_violation';
    END IF;
    RETURN NEW;
END $fn$;

DROP TRIGGER IF EXISTS trg_patient_matches_encounter ON "clinical"."placement_incidents";
CREATE TRIGGER trg_patient_matches_encounter BEFORE INSERT OR UPDATE OF "patient_profile_id", "encounter_id"
    ON "clinical"."placement_incidents"
    FOR EACH ROW EXECUTE FUNCTION "clinical"."assert_patient_matches_encounter"();
-- inpatient_census_entries es append-only (sin UPDATE): basta con el INSERT.
DROP TRIGGER IF EXISTS trg_patient_matches_encounter ON "clinical"."inpatient_census_entries";
CREATE TRIGGER trg_patient_matches_encounter BEFORE INSERT
    ON "clinical"."inpatient_census_entries"
    FOR EACH ROW EXECUTE FUNCTION "clinical"."assert_patient_matches_encounter"();

-- ------------------------------------------------------------- G. historia sólo inserción (funciones de F1b)
DO $$
DECLARE
    r record;
BEGIN
    FOR r IN
        SELECT * FROM (VALUES
            ('encounter_locations_history', 'clinical.encounter_locations', 'encounter_location_id'),
            ('placement_incidents_history', 'clinical.placement_incidents', 'placement_incident_id')
        ) AS v(historia, origen, columna)
    LOOP
        EXECUTE format('DROP TRIGGER IF EXISTS trg_fill_tenant ON "audit".%I', r.historia);
        EXECUTE format('CREATE TRIGGER trg_fill_tenant BEFORE INSERT ON "audit".%I FOR EACH ROW EXECUTE FUNCTION "audit"."structure_history_fill_tenant"(%L, %L)',
                       r.historia, r.origen, r.columna);
        EXECUTE format('DROP TRIGGER IF EXISTS trg_close_only ON "audit".%I', r.historia);
        EXECUTE format('CREATE TRIGGER trg_close_only BEFORE UPDATE OR DELETE ON "audit".%I FOR EACH ROW EXECUTE FUNCTION "audit"."structure_history_close_only"()',
                       r.historia);
    END LOOP;
END $$;

-- ------------------------------------------------------------- C. restricciones (copiadas de 05_constraints)

ALTER TABLE "clinical"."encounter_locations" DROP CONSTRAINT IF EXISTS "ck_encounter_locations_bed_period";
ALTER TABLE "clinical"."encounter_locations" ADD CONSTRAINT "ck_encounter_locations_bed_period" CHECK ((NOT "is_bed_assignment" OR ("period_start" IS NOT NULL AND "care_space_id" IS NOT NULL)));

-- Invariante 1: una cama, un paciente a la vez (historial y reservas incluidos).
ALTER TABLE "clinical"."encounter_locations" DROP CONSTRAINT IF EXISTS "ex_encounter_locations_bed_occupancy";
ALTER TABLE "clinical"."encounter_locations" ADD CONSTRAINT "ex_encounter_locations_bed_occupancy"
    EXCLUDE USING gist ("care_space_id" WITH =, tstzrange("period_start", "period_end", '[)') WITH &&) WHERE ("is_bed_assignment" AND "location_status_concept_id" IN ('809db700-0627-5fe3-8278-4f038f4475b3', 'cdd86257-4297-5941-8ae8-b95e11439a48', '8cf00069-81ca-56e1-8e71-9e16333a1f6c')) DEFERRABLE INITIALLY IMMEDIATE;

-- Un encuentro ocupa una sola cama a la vez (la reserva de traslado puede convivir).
ALTER TABLE "clinical"."encounter_locations" DROP CONSTRAINT IF EXISTS "ex_encounter_locations_encounter_single_bed";
ALTER TABLE "clinical"."encounter_locations" ADD CONSTRAINT "ex_encounter_locations_encounter_single_bed"
    EXCLUDE USING gist ("encounter_id" WITH =, tstzrange("period_start", "period_end", '[)') WITH &&) WHERE ("is_bed_assignment" AND "location_status_concept_id" IN ('809db700-0627-5fe3-8278-4f038f4475b3', '8cf00069-81ca-56e1-8e71-9e16333a1f6c')) DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "clinical"."placement_incidents" DROP CONSTRAINT IF EXISTS "ck_placement_incidents_justification_length";
ALTER TABLE "clinical"."placement_incidents" ADD CONSTRAINT "ck_placement_incidents_justification_length" CHECK ((char_length("justification_text") >= 20));

ALTER TABLE "clinical"."inpatient_census_adjustments" DROP CONSTRAINT IF EXISTS "ck_inpatient_census_adjustments_field_code";
ALTER TABLE "clinical"."inpatient_census_adjustments" ADD CONSTRAINT "ck_inpatient_census_adjustments_field_code" CHECK ("field_code" IN ('beds_censable', 'beds_available', 'beds_blocked', 'patients_at_cutoff', 'admissions', 'discharges', 'deaths', 'transfers_in', 'transfers_out', 'same_day_stays', 'patient_days', 'discharge_stay_days'));

-- ------------------------------------------------------------- E. guardas

-- UPDATE_DELETE: forbidden → barrera física (append-only)
REVOKE UPDATE, DELETE ON "clinical"."inpatient_census_entries" FROM PUBLIC;
DROP TRIGGER IF EXISTS trg_forbid_mutation ON "clinical"."inpatient_census_entries";
CREATE TRIGGER trg_forbid_mutation BEFORE UPDATE OR DELETE ON "clinical"."inpatient_census_entries"
    FOR EACH ROW EXECUTE FUNCTION "integrity"."forbid_mutation"();

-- UPDATE_DELETE: forbidden → barrera física (append-only)
REVOKE UPDATE, DELETE ON "clinical"."inpatient_census_adjustments" FROM PUBLIC;
DROP TRIGGER IF EXISTS trg_forbid_mutation ON "clinical"."inpatient_census_adjustments";
CREATE TRIGGER trg_forbid_mutation BEFORE UPDATE OR DELETE ON "clinical"."inpatient_census_adjustments"
    FOR EACH ROW EXECUTE FUNCTION "integrity"."forbid_mutation"();

-- Día de censo CERRADO: inmutable. Un día abierto se puede reescribir (y cerrar: la
-- transición OPEN → CLOSED es un UPDATE con OLD abierto). Las correcciones de un día
-- cerrado van a inpatient_census_adjustments. Mismo ERRCODE que forbid_mutation().
CREATE OR REPLACE FUNCTION "integrity"."forbid_closed_census_mutation"() RETURNS trigger
LANGUAGE plpgsql AS $$
BEGIN
    IF OLD."status_concept_id" = 'f17b79e2-e453-5b4e-aa70-6691fba364ec'::uuid THEN  -- CENSUS_CLOSED
        RAISE EXCEPTION 'censo cerrado: % no permitido en %.% (id %); registrar un ajuste',
            TG_OP, TG_TABLE_SCHEMA, TG_TABLE_NAME, OLD."id" USING ERRCODE = 'restrict_violation';
    END IF;
    IF TG_OP = 'DELETE' THEN
        RETURN OLD;
    END IF;
    RETURN NEW;
END $$;

DROP TRIGGER IF EXISTS trg_inpatient_census_days_closed_guard ON "clinical"."inpatient_census_days";
CREATE TRIGGER trg_inpatient_census_days_closed_guard BEFORE UPDATE OR DELETE ON "clinical"."inpatient_census_days"
    FOR EACH ROW EXECUTE FUNCTION "integrity"."forbid_closed_census_mutation"();

-- ------------------------------------------------------------- H. privilegios y RLS
-- Texto exacto de la política de 2026-08-05_tenant_rls.sql. Los GRANT cubren el caso en
-- que las tablas nuevas las cree un rol distinto del que fijó los DEFAULT PRIVILEGES.
DO $$
DECLARE
    t text;
    tablas text[] := ARRAY[
        'clinical.encounter_locations',
        'clinical.placement_incidents',
        'clinical.inpatient_census_days',
        'clinical.inpatient_census_entries',
        'clinical.inpatient_census_adjustments',
        'audit.encounter_locations_history',
        'audit.placement_incidents_history'
    ];
    nuevas text[] := ARRAY[
        'clinical.placement_incidents',
        'clinical.inpatient_census_days',
        'clinical.inpatient_census_entries',
        'clinical.inpatient_census_adjustments'
    ];
    historias text[] := ARRAY[
        'audit.encounter_locations_history',
        'audit.placement_incidents_history'
    ];
BEGIN
    IF EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'mantra_app') THEN
        FOREACH t IN ARRAY nuevas LOOP
            EXECUTE format('GRANT SELECT, INSERT, UPDATE, DELETE ON %s TO mantra_app', t);
        END LOOP;
        -- Historia (patrón F1b): SELECT e INSERT, y UPDATE sólo de valid_to (cierre SCD-2).
        -- Si 2026-08-05_tenant_rls.sql se reaplica (GRANT … ON ALL TABLES), trg_close_only
        -- sigue rechazando todo lo que no sea cerrar valid_to; reaplicar este patch deja
        -- otra vez los privilegios mínimos.
        FOREACH t IN ARRAY historias LOOP
            EXECUTE format('REVOKE UPDATE, DELETE, TRUNCATE ON %s FROM mantra_app', t);
            EXECUTE format('GRANT SELECT, INSERT ON %s TO mantra_app', t);
            EXECUTE format('GRANT UPDATE ("valid_to") ON %s TO mantra_app', t);
        END LOOP;
        -- La guarda append-only revoca UPDATE/DELETE a PUBLIC; el rol de aplicación
        -- tampoco los necesita sobre el detalle y los ajustes del censo.
        EXECUTE 'REVOKE UPDATE, DELETE ON "clinical"."inpatient_census_entries" FROM mantra_app';
        EXECUTE 'REVOKE UPDATE, DELETE ON "clinical"."inpatient_census_adjustments" FROM mantra_app';
    END IF;

    FOREACH t IN ARRAY tablas LOOP
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

-- ------------------------------------------------------------- verificación
DO $$
DECLARE
    n_columnas integer;
    n_tablas   integer;
    n_fk       integer;
    n_ix       integer;
    n_ck       integer;
    n_ex       integer;
    n_trg      integer;
    n_rls      integer;
    n_nn       integer;
    n_hist     integer;
BEGIN
    SELECT count(*) INTO n_columnas
      FROM information_schema.columns
     WHERE table_schema = 'clinical'
       AND (table_name, column_name) IN (
            ('encounters', 'level_of_care_concept_id'), ('encounters', 'admission_source_concept_id'),
            ('encounters', 'discharge_disposition_concept_id'), ('encounters', 'isolation_precaution_concept_id'),
            ('encounters', 'isolation_organism_text'), ('encounters', 'expected_discharge_at'),
            ('encounter_locations', 'tenant_id'), ('encounter_locations', 'is_bed_assignment'),
            ('encounter_locations', 'movement_type_concept_id'), ('encounter_locations', 'previous_encounter_location_id'),
            ('encounter_locations', 'end_reason_concept_id'), ('encounter_locations', 'bed_category_concept_id'),
            ('encounter_locations', 'placement_incident_id'));

    SELECT count(*) INTO n_tablas
      FROM information_schema.tables
     WHERE (table_schema, table_name) IN (
            ('clinical', 'placement_incidents'), ('clinical', 'inpatient_census_days'),
            ('clinical', 'inpatient_census_entries'), ('clinical', 'inpatient_census_adjustments'),
            ('audit', 'encounter_locations_history'), ('audit', 'placement_incidents_history'));

    SELECT count(*) INTO n_fk
      FROM pg_constraint
     WHERE contype = 'f' AND convalidated
       AND (conname = ANY (ARRAY[
            'fk_encounters_level_of_care_concept_id', 'fk_encounters_admission_source_concept_id',
            'fk_encounters_discharge_disposition_concept_id', 'fk_encounters_isolation_precaution_concept_id',
            'fk_encounter_locations_tenant_id', 'fk_encounter_locations_movement_type_concept_id',
            'fk_encounter_locations_previous_encounter_location_id', 'fk_encounter_locations_end_reason_concept_id',
            'fk_encounter_locations_bed_category_concept_id', 'fk_encounter_locations_placement_incident_id'])
         OR conname LIKE 'fk\_placement\_incidents\_%'
         OR conname LIKE 'fk\_inpatient\_census\_%'
         OR conname LIKE 'fk\_encounter\_locations\_history\_%'
         OR conname IN (SELECT nombre FROM _f3_fk_tenant));

    SELECT count(*) INTO n_ix
      FROM pg_indexes
     WHERE (schemaname = 'clinical' AND (
               indexname IN ('ix_encounters_level_of_care_concept_id', 'ix_encounters_admission_source_concept_id',
                             'ix_encounters_discharge_disposition_concept_id', 'ix_encounters_isolation_precaution_concept_id',
                             'ix_encounter_locations_tenant_id', 'ix_encounter_locations_movement_type_concept_id',
                             'ix_encounter_locations_previous_encounter_location_id', 'ix_encounter_locations_end_reason_concept_id',
                             'ix_encounter_locations_bed_category_concept_id', 'ix_encounter_locations_placement_incident_id',
                             'ix_encounter_locations_bed_period', 'ux_inpatient_census_days_site_unit_date',
                             'ux_encounters_tenant_id_id', 'ux_encounter_locations_tenant_id_id',
                             'ux_placement_incidents_tenant_id_id', 'ux_inpatient_census_days_tenant_id_id')
            OR indexname LIKE 'ix\_placement\_incidents\_%'
            OR indexname LIKE 'ix\_inpatient\_census\_%'))
        OR (schemaname = 'audit' AND (indexname LIKE 'ix\_encounter\_locations\_history\_%'
                                   OR indexname LIKE 'ix\_placement\_incidents\_history\_%'
                                   OR indexname IN ('brin_encounter_locations_history_recorded_at',
                                                    'brin_placement_incidents_history_recorded_at')));

    SELECT count(*) INTO n_ck
      FROM pg_constraint
     WHERE contype = 'c' AND conname IN ('ck_encounter_locations_bed_period',
            'ck_placement_incidents_justification_length', 'ck_inpatient_census_adjustments_field_code');

    SELECT count(*) INTO n_ex
      FROM pg_constraint
     WHERE contype = 'x' AND condeferrable AND NOT condeferred
       AND conname IN ('ex_encounter_locations_bed_occupancy', 'ex_encounter_locations_encounter_single_bed');

    SELECT count(*) INTO n_trg
      FROM pg_trigger tg JOIN pg_class c ON c.oid = tg.tgrelid
      JOIN pg_namespace n ON n.oid = c.relnamespace
     WHERE NOT tg.tgisinternal
       AND (n.nspname, c.relname, tg.tgname) IN (
            ('clinical', 'inpatient_census_entries', 'trg_forbid_mutation'),
            ('clinical', 'inpatient_census_adjustments', 'trg_forbid_mutation'),
            ('clinical', 'inpatient_census_days', 'trg_inpatient_census_days_closed_guard'),
            ('clinical', 'placement_incidents', 'trg_patient_matches_encounter'),
            ('clinical', 'inpatient_census_entries', 'trg_patient_matches_encounter'),
            ('audit', 'encounter_locations_history', 'trg_fill_tenant'),
            ('audit', 'encounter_locations_history', 'trg_close_only'),
            ('audit', 'placement_incidents_history', 'trg_fill_tenant'),
            ('audit', 'placement_incidents_history', 'trg_close_only'));

    SELECT count(*) INTO n_rls
      FROM pg_class c JOIN pg_namespace n ON n.oid = c.relnamespace
      JOIN pg_policies p ON p.schemaname = n.nspname AND p.tablename = c.relname
                        AND p.policyname = 'tenant_isolation'
     WHERE (n.nspname, c.relname) IN (('clinical', 'encounter_locations'), ('clinical', 'placement_incidents'),
            ('clinical', 'inpatient_census_days'), ('clinical', 'inpatient_census_entries'),
            ('clinical', 'inpatient_census_adjustments'), ('audit', 'encounter_locations_history'),
            ('audit', 'placement_incidents_history'))
       AND c.relrowsecurity AND c.relforcerowsecurity;

    SELECT count(*) INTO n_nn
      FROM information_schema.columns
     WHERE (table_schema, table_name) IN (('clinical', 'encounter_locations'),
            ('audit', 'encounter_locations_history'), ('audit', 'placement_incidents_history'))
       AND column_name = 'tenant_id' AND is_nullable = 'NO';

    -- Historia: mantra_app sin UPDATE/DELETE/TRUNCATE de tabla (sólo UPDATE de valid_to).
    IF EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'mantra_app') THEN
        SELECT count(*) INTO n_hist
          FROM unnest(ARRAY['audit.encounter_locations_history', 'audit.placement_incidents_history']) t
         WHERE has_table_privilege('mantra_app', t, 'UPDATE')
            OR has_table_privilege('mantra_app', t, 'DELETE')
            OR has_table_privilege('mantra_app', t, 'TRUNCATE')
            OR NOT has_column_privilege('mantra_app', t, 'valid_to', 'UPDATE')
            OR has_column_privilege('mantra_app', t, 'data_snapshot', 'UPDATE');
    ELSE
        n_hist := 0;
    END IF;

    IF n_columnas <> 13 OR n_tablas <> 6 OR n_fk <> 64 OR n_ix <> 55 OR n_ck <> 3 OR n_ex <> 2
       OR n_trg <> 9 OR n_rls <> 7 OR n_nn <> 3 OR n_hist <> 0 THEN
        RAISE EXCEPTION
            'F3 incompleto: columnas=% (13), tablas=% (6), fk=% (64), índices=% (55), check=% (3), exclude diferibles=% (2), triggers=% (9), rls=% (7), tenant_id NOT NULL=% (3), historia con privilegios de más=% (0)',
            n_columnas, n_tablas, n_fk, n_ix, n_ck, n_ex, n_trg, n_rls, n_nn, n_hist;
    END IF;

    RAISE NOTICE 'F3 aplicado: 13 columnas, 6 tablas, 64 FKs validadas (17 compuestas), 55 índices, 3 CHECK, 2 EXCLUDE diferibles, 9 triggers, 7 tablas con RLS, historia sólo inserción.';
END $$;

COMMIT;
