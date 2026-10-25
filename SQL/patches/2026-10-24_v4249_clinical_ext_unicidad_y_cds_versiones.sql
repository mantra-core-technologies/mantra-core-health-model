-- ============================================================================
-- SALUD · patch (clinical_ext · unicidad de brechas, referencias y sesiones virtuales; versiones de reglas CDS) sobre BD viva
-- Fecha: 2026-10-24 · hallazgos CE-03 y CE-04 (API #782)
-- Idempotente (IF NOT EXISTS / IF EXISTS / duplicate_object). UNA sola pasada. Sin backfill.
-- Contexto: gen_ddl.py y gen_integrity.py ya emiten esto en SQL/<NN>_<schema>/ desde que los
-- .puml lo declaran, así que en un rebuild desde cero este patch NO hace falta. Existe para una
-- base ya aplicada y poblada: un CREATE TABLE IF NOT EXISTS no agrega columnas a una tabla que
-- ya existe. gen_apply.py no escanea SQL/patches/: no entra en apply_all.sql. Las sentencias se
-- copiaron de los archivos generados, no se escribieron a mano.
--
-- QUÉ CIERRA.
--   1. CE-04: índices únicos sobre la clave lógica que el servicio ya comprobaba leyendo antes:
--      - care_gaps: una brecha ABIERTA (closed_at IS NULL) por (paciente, tipo, medida); la medida
--        NULL cuenta como un valor (COALESCE a un UUID nulo), igual que findOpen. Cerrar la brecha
--        (closed_at) libera la clave: se puede abrir otra.
--      - referrals: (source_encounter_id, target_profile_id, specialty_concept_id) cuando los tres
--        existen, sin importar el estado, igual que findDuplicate.
--      - virtual_encounters: una sesión virtual por encuentro (encounter_id); reemplaza al índice
--        plano ix_virtual_encounters_encounter_id.
--   2. CE-03: clinical_ext.cds_rule_versions, instantáneas inmutables de una regla CDS
--      (UNIQUE (cds_rule_id, version_number); UPDATE prohibido por trigger). Sin retroactividad:
--      las versiones previas que cds_rules ya sobrescribió no se pueden reconstruir.
--
-- PRECONDICIÓN: no debe haber claves lógicas repetidas. El patch lo comprueba antes de tocar
-- nada y aborta con un mensaje; el BEGIN hace rollback de todo.
--
-- DELTAS ESPERADOS sobre la base viva:
--   tablas +1 · columnas +0 · NOT NULL quitados 0 · FKs +4 · índices +7 (-1) · constraints +2
-- ============================================================================

BEGIN;

DO $$
DECLARE
    duplicados integer;
BEGIN
    SELECT count(*) INTO duplicados FROM (
        SELECT 1
          FROM "clinical_ext"."care_gaps"
         WHERE "closed_at" IS NULL
         GROUP BY "patient_profile_id", "gap_type_concept_id", COALESCE("measure_concept_id", '00000000-0000-0000-0000-000000000000'::uuid)
        HAVING count(*) > 1
    ) d;
    IF duplicados > 0 THEN
        RAISE EXCEPTION 'clinical_ext.care_gaps abiertas (patient_profile_id, gap_type_concept_id, measure_concept_id) tiene % grupo(s) repetido(s): resolverlos antes de crear el índice único', duplicados;
    END IF;
END $$;

DO $$
DECLARE
    duplicados integer;
BEGIN
    SELECT count(*) INTO duplicados FROM (
        SELECT 1
          FROM "clinical_ext"."referrals"
         WHERE "source_encounter_id" IS NOT NULL AND "target_profile_id" IS NOT NULL AND "specialty_concept_id" IS NOT NULL
         GROUP BY "source_encounter_id", "target_profile_id", "specialty_concept_id"
        HAVING count(*) > 1
    ) d;
    IF duplicados > 0 THEN
        RAISE EXCEPTION 'clinical_ext.referrals (source_encounter_id, target_profile_id, specialty_concept_id) tiene % grupo(s) repetido(s): resolverlos antes de crear el índice único', duplicados;
    END IF;
END $$;

DO $$
DECLARE
    duplicados integer;
BEGIN
    SELECT count(*) INTO duplicados FROM (
        SELECT 1
          FROM "clinical_ext"."virtual_encounters"
         GROUP BY "encounter_id"
        HAVING count(*) > 1
    ) d;
    IF duplicados > 0 THEN
        RAISE EXCEPTION 'clinical_ext.virtual_encounters (encounter_id) tiene % grupo(s) repetido(s): resolverlos antes de crear el índice único', duplicados;
    END IF;
END $$;

CREATE UNIQUE INDEX IF NOT EXISTS "uq_care_gaps_open_logical_key" ON "clinical_ext"."care_gaps" ("patient_profile_id", "gap_type_concept_id", COALESCE(measure_concept_id, '00000000-0000-0000-0000-000000000000'::uuid)) WHERE closed_at IS NULL;

CREATE UNIQUE INDEX IF NOT EXISTS "uq_referrals_source_encounter_target_specialty" ON "clinical_ext"."referrals" ("source_encounter_id", "target_profile_id", "specialty_concept_id") WHERE source_encounter_id IS NOT NULL AND target_profile_id IS NOT NULL AND specialty_concept_id IS NOT NULL;

CREATE UNIQUE INDEX IF NOT EXISTS "uq_virtual_encounters_encounter_id" ON "clinical_ext"."virtual_encounters" ("encounter_id");

DROP INDEX IF EXISTS "clinical_ext"."ix_virtual_encounters_encounter_id";

CREATE TABLE IF NOT EXISTS "clinical_ext"."cds_rule_versions" (
    "id" uuid NOT NULL,
    "cds_rule_id" uuid NOT NULL,
    "version_number" integer NOT NULL,
    "logic_json" jsonb,
    "message_template" text,
    "severity_concept_id" uuid NOT NULL,
    "approved_by_user_id" uuid,
    "approved_at" timestamptz,
    "created_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    CONSTRAINT "pk_cds_rule_versions" PRIMARY KEY ("id")
);

DO $$ BEGIN
    ALTER TABLE "clinical_ext"."cds_rule_versions"
        ADD CONSTRAINT "fk_cds_rule_versions_cds_rule_id" FOREIGN KEY ("cds_rule_id")
        REFERENCES "clinical_ext"."cds_rules" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "clinical_ext"."cds_rule_versions"
        ADD CONSTRAINT "fk_cds_rule_versions_severity_concept_id" FOREIGN KEY ("severity_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "clinical_ext"."cds_rule_versions"
        ADD CONSTRAINT "fk_cds_rule_versions_approved_by_user_id" FOREIGN KEY ("approved_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "clinical_ext"."cds_rule_versions"
        ADD CONSTRAINT "fk_cds_rule_versions_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

CREATE UNIQUE INDEX IF NOT EXISTS "uq_cds_rule_versions_rule_version" ON "clinical_ext"."cds_rule_versions" ("cds_rule_id", "version_number");

CREATE INDEX IF NOT EXISTS "ix_cds_rule_versions_severity_concept_id" ON "clinical_ext"."cds_rule_versions" ("severity_concept_id");

CREATE INDEX IF NOT EXISTS "ix_cds_rule_versions_approved_by_user_id" ON "clinical_ext"."cds_rule_versions" ("approved_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_cds_rule_versions_created_by_user_id" ON "clinical_ext"."cds_rule_versions" ("created_by_user_id");

-- ═══ cds_rule_versions ═══
--   UPDATE: forbidden
-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "clinical_ext"."cds_rule_versions" DROP CONSTRAINT IF EXISTS "ck_cds_rule_versions_number";
ALTER TABLE "clinical_ext"."cds_rule_versions" ADD CONSTRAINT "ck_cds_rule_versions_number" CHECK ("version_number" >= 1);

-- UPDATE: forbidden → barrera física parcial (DELETE permitido: retención)
REVOKE UPDATE ON "clinical_ext"."cds_rule_versions" FROM PUBLIC;
DROP TRIGGER IF EXISTS trg_forbid_update ON "clinical_ext"."cds_rule_versions";
CREATE TRIGGER trg_forbid_update BEFORE UPDATE ON "clinical_ext"."cds_rule_versions"
    FOR EACH ROW EXECUTE FUNCTION "integrity"."forbid_mutation"();

COMMIT;
