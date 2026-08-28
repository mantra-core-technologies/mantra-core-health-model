-- ============================================================================
-- SALUD · patch v4.1.7 (clinical_ext.prescription_favorites) sobre una BD viva
-- Fecha: 2026-08-21
-- Idempotente (CREATE TABLE / CREATE INDEX IF NOT EXISTS · duplicate_object en las FK)
--
-- Contexto: gen_ddl.py ya emite esta tabla en SQL/18_clinical_ext/ desde que el
-- .puml del módulo 18 la declara, así que en un rebuild desde cero este patch
-- NO hace falta. Existe únicamente para una base ya aplicada y poblada.
-- gen_apply.py no escanea SQL/patches/ (solo directorios NN_schema), así que no
-- entra en apply_all.sql.
--
-- Qué agrega: los favoritos de prescripción del profesional — la indicación que
-- repite todos los días («Amoxicilina 500 mg cada 8 h por 7 días»), guardada con
-- un rótulo propio para no volver a tipearla. Lo que se repite a mano se
-- equivoca, y la posología es justamente el campo donde un error de tipeo tiene
-- consecuencias.
--
-- Tres decisiones que el DDL no explica solo:
--  1. Vive en `clinical_ext` y no en `clinical` porque NO es historia del
--     paciente —no hay paciente— sino una comodidad de captura del profesional,
--     pariente de `order_sets` (la plantilla de la organización). Aplicar un
--     favorito produce una `clinical.medication_requests` normal: esta tabla no
--     participa de la máquina de estados de la receta ni de la firma D-05.
--  2. Sin `status_concept_id`: una lista de conveniencia se borra, no se
--     archiva. No hay obligación de conservación clínica sobre un atajo de
--     tipeo, y un value set «activo/borrado» sería vocabulario sin lector.
--  3. `uq_prescription_favorites_practitioner_name`: guardar dos veces el mismo
--     rótulo pisaría en silencio el favorito anterior, que es peor que rechazar.
--
-- `row_version integer NOT NULL DEFAULT 1` es la única excepción de defaults del
-- modelo, y la emite `gen_ddl.py`: MikroORM no inicializa la propiedad de
-- versión al crear la entidad y sin el default todo INSERT muere con 23502.
--
-- Este archivo es la salida de gen_ddl.py 18, no DDL escrito a mano: la entidad
-- se declara en `Mantra Core Health Context/modules/diagram_18_clinical_ext.puml`
-- y los destinos de las 7 FK en `SALUD/FK/FK clinical_ext.prescription_favorites.*.md`.
-- ============================================================================

CREATE TABLE IF NOT EXISTS "clinical_ext"."prescription_favorites" (
    "id" uuid NOT NULL,
    "practitioner_profile_id" uuid NOT NULL,
    "name" varchar NOT NULL,
    "medication_concept_id" uuid NOT NULL,
    "substance_atc_concept_id" uuid,
    "dose_text" varchar,
    "route_concept_id" uuid,
    "frequency_text" varchar,
    "quantity_decimal" numeric,
    "unit_concept_id" uuid,
    "patient_instructions_text" text,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_prescription_favorites" PRIMARY KEY ("id")
);

CREATE INDEX IF NOT EXISTS "ix_prescription_favorites_practitioner_profile_id" ON "clinical_ext"."prescription_favorites" ("practitioner_profile_id");

CREATE INDEX IF NOT EXISTS "ix_prescription_favorites_medication_concept_id" ON "clinical_ext"."prescription_favorites" ("medication_concept_id");

CREATE INDEX IF NOT EXISTS "ix_prescription_favorites_substance_atc_concept_id" ON "clinical_ext"."prescription_favorites" ("substance_atc_concept_id");

CREATE INDEX IF NOT EXISTS "ix_prescription_favorites_route_concept_id" ON "clinical_ext"."prescription_favorites" ("route_concept_id");

CREATE INDEX IF NOT EXISTS "ix_prescription_favorites_unit_concept_id" ON "clinical_ext"."prescription_favorites" ("unit_concept_id");

CREATE INDEX IF NOT EXISTS "ix_prescription_favorites_created_by_user_id" ON "clinical_ext"."prescription_favorites" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_prescription_favorites_updated_by_user_id" ON "clinical_ext"."prescription_favorites" ("updated_by_user_id");

CREATE UNIQUE INDEX IF NOT EXISTS "uq_prescription_favorites_practitioner_name" ON "clinical_ext"."prescription_favorites" ("practitioner_profile_id", "name");

-- destino: profiles.health_practitioner_profiles (requiere schema profiles)
DO $$ BEGIN
    ALTER TABLE "clinical_ext"."prescription_favorites"
        ADD CONSTRAINT "fk_prescription_favorites_practitioner_profile_id" FOREIGN KEY ("practitioner_profile_id")
        REFERENCES "profiles"."health_practitioner_profiles" ("profile_id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "clinical_ext"."prescription_favorites"
        ADD CONSTRAINT "fk_prescription_favorites_medication_concept_id" FOREIGN KEY ("medication_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "clinical_ext"."prescription_favorites"
        ADD CONSTRAINT "fk_prescription_favorites_substance_atc_concept_id" FOREIGN KEY ("substance_atc_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "clinical_ext"."prescription_favorites"
        ADD CONSTRAINT "fk_prescription_favorites_route_concept_id" FOREIGN KEY ("route_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "clinical_ext"."prescription_favorites"
        ADD CONSTRAINT "fk_prescription_favorites_unit_concept_id" FOREIGN KEY ("unit_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "clinical_ext"."prescription_favorites"
        ADD CONSTRAINT "fk_prescription_favorites_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "clinical_ext"."prescription_favorites"
        ADD CONSTRAINT "fk_prescription_favorites_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;
