-- ============================================================================
-- SALUD · patch v4.2.50 (terminology · TAREA-41 F1) sobre BD viva
-- Fecha: 2026-10-25
--
-- QUÉ ENTRA. La red de conocimiento del glosario gana evidencia con procedencia:
--   1. `terminology.concept_relationships`: 4 columnas DERIVADAS y nullable que
--      recalcula el cargador masivo (la app no las escribe): strength_score,
--      evidence_count, best_evidence_tier_concept_id, frequency_concept_id.
--      + clave natural única (source, target, tipo) y dos índices compuestos
--      con strength_score DESC para el vecindario del glosario.
--   2. Tabla nueva `terminology.concept_relationship_evidence` (1:N con la arista):
--      fuente, versión, nivel de evidencia, cita literal, frecuencia, calificadores
--      de población (sexo, edad, embarazo), nivel de atención, línea de tratamiento
--      y vigencia (valid_from/valid_to).
--
-- CLAVE NATURAL. Antes de declararla se midió la base viva del 2026-10-25:
-- 0 duplicados de (source, target, tipo) entre 20 390 filas, así que no hay nada
-- que fusionar. Si una base trae duplicados, este patch ABORTA y dice cuántos:
-- fusionarlos es trabajo del cargador (TAREA-41 F1.3), no de un DDL.
--
-- VALUE SETS. vs_evidence_tier, vs_relationship_frequency, vs_care_level y
-- vs_line_of_therapy NO van acá: los siembra `gen_seeds.py` (revisión
-- 2.8.0-v4.2.50) y se cargan con `load_seeds.py --skip-prod --refresh`.
--
-- MODELO. Declarado en `diagram_03_terminology.puml`; un rebuild desde cero lo trae
-- en SQL/03_terminology/0{2,3,4}_*.sql. Este patch es sólo para bases ya
-- aplicadas. Idempotente: cada sentencia es IF NOT EXISTS o tolera duplicate_object.
--
-- DELTAS ESPERADOS: tablas +1 · FKs +11 · índices +16 (5 en concept_relationships,
-- 10 + PK en concept_relationship_evidence)
-- ============================================================================
BEGIN;

DO $$
DECLARE dup bigint;
BEGIN
    SELECT count(*) INTO dup FROM (
        SELECT 1 FROM "terminology"."concept_relationships"
         GROUP BY "source_concept_id", "target_concept_id", "relationship_type_concept_id"
        HAVING count(*) > 1) d;
    IF dup > 0 AND to_regclass('"terminology"."ux_concept_relationships_natural_key"') IS NULL THEN
        RAISE EXCEPTION 'concept_relationships tiene % claves (source, target, tipo) duplicadas: fusionarlas antes de aplicar v4.2.50', dup;
    END IF;
END $$;

ALTER TABLE "terminology"."concept_relationships"
    ADD COLUMN IF NOT EXISTS "strength_score" numeric,
    ADD COLUMN IF NOT EXISTS "evidence_count" integer,
    ADD COLUMN IF NOT EXISTS "best_evidence_tier_concept_id" uuid,
    ADD COLUMN IF NOT EXISTS "frequency_concept_id" uuid;

CREATE TABLE IF NOT EXISTS "terminology"."concept_relationship_evidence" (
    "id" uuid NOT NULL,
    "concept_relationship_id" uuid NOT NULL,
    "terminology_source_id" uuid NOT NULL,
    "code_system_version_id" uuid NOT NULL,
    "evidence_tier_concept_id" uuid NOT NULL,
    "source_reference" varchar NOT NULL,
    "citation_text" text,
    "citation_locator" varchar,
    "frequency_concept_id" uuid,
    "frequency_numerator" integer,
    "frequency_denominator" integer,
    "statistic_value" numeric,
    "sex_concept_id" uuid,
    "age_min_days" integer,
    "age_max_days" integer,
    "pregnancy_applicability_concept_id" uuid,
    "care_level_concept_id" uuid,
    "line_of_therapy_concept_id" uuid,
    "valid_from" date NOT NULL,
    "valid_to" date,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_concept_relationship_evidence" PRIMARY KEY ("id")
);

DO $$ BEGIN
    ALTER TABLE "terminology"."concept_relationships"
        ADD CONSTRAINT "fk_concept_relationships_best_evidence_tier_concept_id" FOREIGN KEY ("best_evidence_tier_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "terminology"."concept_relationships"
        ADD CONSTRAINT "fk_concept_relationships_frequency_concept_id" FOREIGN KEY ("frequency_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "terminology"."concept_relationship_evidence"
        ADD CONSTRAINT "fk_concept_relationship_evidence_concept_relationship_id" FOREIGN KEY ("concept_relationship_id")
        REFERENCES "terminology"."concept_relationships" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "terminology"."concept_relationship_evidence"
        ADD CONSTRAINT "fk_concept_relationship_evidence_terminology_source_id" FOREIGN KEY ("terminology_source_id")
        REFERENCES "terminology"."terminology_sources" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "terminology"."concept_relationship_evidence"
        ADD CONSTRAINT "fk_concept_relationship_evidence_code_system_version_id" FOREIGN KEY ("code_system_version_id")
        REFERENCES "terminology"."code_system_versions" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "terminology"."concept_relationship_evidence"
        ADD CONSTRAINT "fk_concept_relationship_evidence_evidence_tier_concept_id" FOREIGN KEY ("evidence_tier_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "terminology"."concept_relationship_evidence"
        ADD CONSTRAINT "fk_concept_relationship_evidence_frequency_concept_id" FOREIGN KEY ("frequency_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "terminology"."concept_relationship_evidence"
        ADD CONSTRAINT "fk_concept_relationship_evidence_sex_concept_id" FOREIGN KEY ("sex_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "terminology"."concept_relationship_evidence"
        ADD CONSTRAINT "fk_concept_relationship_evidence_pregnancy_applicabili_541e3040" FOREIGN KEY ("pregnancy_applicability_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "terminology"."concept_relationship_evidence"
        ADD CONSTRAINT "fk_concept_relationship_evidence_care_level_concept_id" FOREIGN KEY ("care_level_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "terminology"."concept_relationship_evidence"
        ADD CONSTRAINT "fk_concept_relationship_evidence_line_of_therapy_concept_id" FOREIGN KEY ("line_of_therapy_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

CREATE INDEX IF NOT EXISTS "ix_concept_relationships_best_evidence_tier_concept_id" ON "terminology"."concept_relationships" ("best_evidence_tier_concept_id");

CREATE INDEX IF NOT EXISTS "ix_concept_relationships_frequency_concept_id" ON "terminology"."concept_relationships" ("frequency_concept_id");

CREATE UNIQUE INDEX IF NOT EXISTS "ux_concept_relationships_natural_key" ON "terminology"."concept_relationships" ("source_concept_id", "target_concept_id", "relationship_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_concept_relationships_source_type_strength" ON "terminology"."concept_relationships" ("source_concept_id", "relationship_type_concept_id", "strength_score" DESC);

CREATE INDEX IF NOT EXISTS "ix_concept_relationships_target_type_strength" ON "terminology"."concept_relationships" ("target_concept_id", "relationship_type_concept_id", "strength_score" DESC);

CREATE UNIQUE INDEX IF NOT EXISTS "ux_concept_relationship_evidence_natural_key" ON "terminology"."concept_relationship_evidence" ("concept_relationship_id", "terminology_source_id", "source_reference");

CREATE INDEX IF NOT EXISTS "ix_concept_relationship_evidence_concept_relationship_id" ON "terminology"."concept_relationship_evidence" ("concept_relationship_id");

CREATE INDEX IF NOT EXISTS "ix_concept_relationship_evidence_terminology_source_id" ON "terminology"."concept_relationship_evidence" ("terminology_source_id");

CREATE INDEX IF NOT EXISTS "ix_concept_relationship_evidence_code_system_version_id" ON "terminology"."concept_relationship_evidence" ("code_system_version_id");

CREATE INDEX IF NOT EXISTS "ix_concept_relationship_evidence_evidence_tier_concept_id" ON "terminology"."concept_relationship_evidence" ("evidence_tier_concept_id");

CREATE INDEX IF NOT EXISTS "ix_concept_relationship_evidence_frequency_concept_id" ON "terminology"."concept_relationship_evidence" ("frequency_concept_id");

CREATE INDEX IF NOT EXISTS "ix_concept_relationship_evidence_sex_concept_id" ON "terminology"."concept_relationship_evidence" ("sex_concept_id");

CREATE INDEX IF NOT EXISTS "ix_concept_relationship_evidence_pregnancy_applicabili_1eca2256" ON "terminology"."concept_relationship_evidence" ("pregnancy_applicability_concept_id");

CREATE INDEX IF NOT EXISTS "ix_concept_relationship_evidence_care_level_concept_id" ON "terminology"."concept_relationship_evidence" ("care_level_concept_id");

CREATE INDEX IF NOT EXISTS "ix_concept_relationship_evidence_line_of_therapy_concept_id" ON "terminology"."concept_relationship_evidence" ("line_of_therapy_concept_id");

COMMIT;
