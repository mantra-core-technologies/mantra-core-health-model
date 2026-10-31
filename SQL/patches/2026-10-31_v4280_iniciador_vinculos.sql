-- ============================================================================
-- SALUD · patch v4.2.80 (2026-10-31) · quién inició cada vínculo de la secretaria
-- ============================================================================
-- Los vínculos de la secretaria (personal de apoyo) viven en dos tablas que ya existían:
--   delegated_access.organization_user_assignments   (hospital, sede, servicio o piso)
--   practice.practitioner_support_assignments        (doctor)
-- y se aceptan por solicitud y aceptación: decide la parte que NO inició el vínculo. Quién inició
-- no se deduce de created_by_user_id (una cuenta puede ser secretaria, doctor o administradora a la
-- vez), así que se guarda explícito al crear el vínculo:
--   delegated_access:INITIATOR_SUPPORT_STAFF  (código DA_INITIATOR_SUPPORT_STAFF) · la secretaria pidió
--   delegated_access:INITIATOR_ORGANIZATION   (código DA_INITIATOR_ORGANIZATION)  · lo ofreció un OWNER/ADMIN
--   delegated_access:INITIATOR_PRACTITIONER   (código DA_INITIATOR_PRACTITIONER)  · lo ofreció el doctor
-- Fuente: diagram_29_delegated_access.puml y diagram_14_practice.puml (v4.2.80).
--
-- NULLABLE a propósito: una fila sin iniciador (anterior a este parche u otro flujo) no es
-- decidible y la API no abre nada (falla cerrada). Sin backfill.
--
-- Mismo efecto que el parche de la API database/SQL/patches/2026-10-31_secretaria_iniciador_vinculos.sql.
-- Los índices llevan los MISMOS nombres que los de la API; las FK, los nombres que emite gen_ddl.py.
-- Si la base ya tiene una FK sobre la columna (p. ej. la de la API, con otro nombre), no se agrega
-- una segunda. Idempotente: se puede aplicar N veces. Requiere el esquema base (terminology).
-- ============================================================================

BEGIN;

-- ---- 1. conceptos (mismos ids que deriva la API: deterministicId('delegated_access:INITIATOR_*')) ----
INSERT INTO terminology.terminology_sources (id, code, name, created_at, updated_at, row_version)
VALUES ('d94cf414-ad1b-59b9-afe2-903641f26011', 'MANTRA_CORE', 'Mantra Core Internal Terminology', now(), now(), 1)
ON CONFLICT DO NOTHING;
INSERT INTO terminology.code_systems (id, source_id, internal_code, name, canonical_url, case_sensitive, created_at, updated_at, row_version)
VALUES ('7d025a87-9c81-5c5c-9432-daf84d6fee8a', 'd94cf414-ad1b-59b9-afe2-903641f26011', 'mantra-core-internal',
        'Mantra Core Internal Code System', 'https://mantracore.health/fhir/CodeSystem/internal', true, now(), now(), 1)
ON CONFLICT DO NOTHING;
INSERT INTO terminology.code_system_versions (id, code_system_id, version, published_at, is_default, created_at, updated_at, row_version)
VALUES ('ffda3cef-e77a-5002-8709-e79f32e62fb4', '7d025a87-9c81-5c5c-9432-daf84d6fee8a', '1.0.0', now(), true, now(), now(), 1)
ON CONFLICT DO NOTHING;

INSERT INTO terminology.catalog_concepts (id, code_system_version_id, code, display, abstract, selectable, created_at, updated_at, row_version) VALUES
  ('b3079461-5c2b-5b8d-9a4e-100d0e268589', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'DA_INITIATOR_SUPPORT_STAFF', 'Initiated by the support staff member', false, true, now(), now(), 1),  -- delegated_access:INITIATOR_SUPPORT_STAFF
  ('991d107b-6a82-55c2-9166-94db5e3e7b90', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'DA_INITIATOR_ORGANIZATION', 'Initiated by an organization administrator', false, true, now(), now(), 1),  -- delegated_access:INITIATOR_ORGANIZATION
  ('6e00282d-84c4-59b0-bac2-9da5f945dfe7', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'DA_INITIATOR_PRACTITIONER', 'Initiated by the practitioner', false, true, now(), now(), 1)  -- delegated_access:INITIATOR_PRACTITIONER
ON CONFLICT DO NOTHING;

-- ---- 2. columnas ----
ALTER TABLE "delegated_access"."organization_user_assignments"
    ADD COLUMN IF NOT EXISTS "initiated_by_party_concept_id" uuid;

ALTER TABLE "practice"."practitioner_support_assignments"
    ADD COLUMN IF NOT EXISTS "initiated_by_party_concept_id" uuid;

-- ---- 3. FK a terminology.catalog_concepts (una sola por columna) ----
DO $$
DECLARE
    t record;
BEGIN
    FOR t IN SELECT * FROM (VALUES
        ('delegated_access.organization_user_assignments'::regclass, 'fk_organization_user_assignments_initiated_by_party_concept_id'),
        ('practice.practitioner_support_assignments'::regclass, 'fk_practitioner_support_assignments_initiated_by_party_7e268d24')
    ) v(rel, conname) LOOP
        IF NOT EXISTS (
            SELECT 1 FROM pg_constraint c
              JOIN pg_attribute a ON a.attrelid = c.conrelid AND a.attnum = ANY (c.conkey)
             WHERE c.conrelid = t.rel AND c.contype = 'f' AND a.attname = 'initiated_by_party_concept_id'
               AND c.confrelid = 'terminology.catalog_concepts'::regclass) THEN
            EXECUTE format('ALTER TABLE %s ADD CONSTRAINT %I FOREIGN KEY ("initiated_by_party_concept_id") '
                           'REFERENCES "terminology"."catalog_concepts" ("id")', t.rel, t.conname);
        END IF;
    END LOOP;
END $$;

-- ---- 4. índices (mismos nombres que el parche de la API) ----
CREATE INDEX IF NOT EXISTS "ix_org_user_assignments_initiated_by_party"
    ON "delegated_access"."organization_user_assignments" ("initiated_by_party_concept_id");

CREATE INDEX IF NOT EXISTS "ix_prac_support_assignments_initiated_by_party"
    ON "practice"."practitioner_support_assignments" ("initiated_by_party_concept_id");

COMMIT;
