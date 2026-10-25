-- ============================================================================
-- SALUD · patch centros médicos (módulos 08 clinical y 14 practice) sobre una BD viva
-- Fecha: 2026-10-25
--
-- Sigue la convención de los parches anteriores: escrito a mano, fuera de
-- `apply_all.sql`, idempotente (IF NOT EXISTS, FK con duplicate_object) y en UNA
-- sola pasada. Una base nueva sale con todo esto desde `SQL/08_clinical/` y
-- `SQL/14_practice/`, generado de `diagram_08_clinical.puml` y
-- `diagram_14_practice.puml`. Los bloques de FK son los que emite el generador.
--
-- QUÉ AGREGA.
--  1. clinical.service_requests: quién ejecuta la orden, como RECOMENDACIÓN del
--     médico (no concede acceso: `performer_tenant_id` sigue siendo la única
--     columna que lo hace).
--       performer_selection_concept_id    -> terminology.catalog_concepts
--       performer_practitioner_profile_id -> profiles.health_practitioner_profiles
--       suggested_practice_site_id        -> practice.practice_sites
--     Las tres admiten NULL: las órdenes existentes no las tienen y elegir un
--     valor por ellas sería decidir por ellas.
--  2. practice.healthcare_services.service_catalog_id -> billing.service_catalog:
--     el ítem que fija el precio del procedimiento en esa sede.
--  3. Un procedimiento por sede: índice único (practice_site_id, service_concept_id).
--     Los servicios sin sede (practice_site_id NULL) quedan fuera de la regla.
--
-- LO QUE ESTE PARCHE NO HACE.
--  - No toca datos. El conjunto `service-request-performer-selection`, el estado
--    «invitado» de la afiliación y el vínculo a `VS_BO_MEDICAL_PROCEDURE` los
--    siembra la API; no son DDL.
--
-- ANTES DEL ÍNDICE ÚNICO. Si la base ya tiene dos servicios del mismo procedimiento
-- en la misma sede, el índice falla al crearse. Consulta para el operador:
--
--   SELECT practice_site_id, service_concept_id, COUNT(*)
--     FROM practice.healthcare_services
--    WHERE practice_site_id IS NOT NULL
--    GROUP BY 1, 2 HAVING COUNT(*) > 1;
--
-- Delta esperado: +4 columnas · +3 índices (+1 único) · +4 FK.
-- ============================================================================

BEGIN;

-- 1. clinical.service_requests --------------------------------------------------
ALTER TABLE "clinical"."service_requests" ADD COLUMN IF NOT EXISTS "performer_selection_concept_id" uuid;
ALTER TABLE "clinical"."service_requests" ADD COLUMN IF NOT EXISTS "performer_practitioner_profile_id" uuid;
ALTER TABLE "clinical"."service_requests" ADD COLUMN IF NOT EXISTS "suggested_practice_site_id" uuid;

CREATE INDEX IF NOT EXISTS "ix_service_requests_performer_practitioner_profile_id" ON "clinical"."service_requests" ("performer_practitioner_profile_id");

CREATE INDEX IF NOT EXISTS "ix_service_requests_suggested_practice_site_id" ON "clinical"."service_requests" ("suggested_practice_site_id");

DO $$ BEGIN
    ALTER TABLE "clinical"."service_requests"
        ADD CONSTRAINT "fk_service_requests_performer_selection_concept_id" FOREIGN KEY ("performer_selection_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "clinical"."service_requests"
        ADD CONSTRAINT "fk_service_requests_performer_practitioner_profile_id" FOREIGN KEY ("performer_practitioner_profile_id")
        REFERENCES "profiles"."health_practitioner_profiles" ("profile_id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "clinical"."service_requests"
        ADD CONSTRAINT "fk_service_requests_suggested_practice_site_id" FOREIGN KEY ("suggested_practice_site_id")
        REFERENCES "practice"."practice_sites" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- 2. practice.healthcare_services -----------------------------------------------
ALTER TABLE "practice"."healthcare_services" ADD COLUMN IF NOT EXISTS "service_catalog_id" uuid;

CREATE INDEX IF NOT EXISTS "ix_healthcare_services_service_catalog_id" ON "practice"."healthcare_services" ("service_catalog_id");

DO $$ BEGIN
    ALTER TABLE "practice"."healthcare_services"
        ADD CONSTRAINT "fk_healthcare_services_service_catalog_id" FOREIGN KEY ("service_catalog_id")
        REFERENCES "billing"."service_catalog" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- 3. Un procedimiento por sede --------------------------------------------------
CREATE UNIQUE INDEX IF NOT EXISTS "ux_healthcare_services_site_service" ON "practice"."healthcare_services" ("practice_site_id", "service_concept_id");

COMMIT;
