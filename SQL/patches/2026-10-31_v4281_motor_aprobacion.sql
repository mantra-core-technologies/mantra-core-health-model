-- ============================================================================
-- SALUD · patch v4.2.81 (franja F1b del portal de observabilidad y gobierno: motor de aprobación único) sobre BD viva
-- Fecha: 2026-10-31
-- GENERADO por salud-db/gen_v4281_patches.py a partir del DDL que ya emiten gen_ddl.py y gen_integrity.py: aquí no hay DDL escrito a mano
-- salvo los conceptos y las comprobaciones. Idempotente (ADD COLUMN IF NOT EXISTS, CREATE INDEX IF NOT EXISTS, CHECK con DROP IF EXISTS + ADD,
-- conceptos con ON CONFLICT DO NOTHING). UNA sola transacción; se puede volver a correr. Solo AGREGA.
--
-- Contexto: 06-cargas-masivas-aprobacion-gobierno-usuarios.md H3.S1.M1 del plan docs/trabajo/2026-10-31-portal-observabilidad-gobierno/ (repo
-- del front): generalizar delegated_access.four_eyes_requests (v4278) para los `kind` BULK_IMPORT_CONFIRM, CATALOG_CLASSIFICATION,
-- GOVERNANCE_POLICY_CHANGE y ACCESS_SENSITIVE_CHANGE.
--
-- ES UN VOCABULARIO CERRADO? NO. Verificado en el DDL real de v4278: `kind_concept_id` es una FK a terminology.catalog_concepts y la tabla no tiene
-- ningún CHECK sobre el tipo (los CHECK de four_eyes_requests son not_self, hash, expiry, decision y reject_comment). Agregar un tipo es sembrar un
-- concepto: sin DDL. Lo único que cambia de forma son dos columnas aditivas nullable.
--
-- QUE AGREGA
--   four_eyes_requests    +subject_entity varchar, +subject_id uuid (sujeto genérico de lo que no es una persona: un lote, una anotación, una
--                         política; las columnas existentes subject_user_id / organization_user_assignment_id siguen para personas y vínculos),
--                         ix_four_eyes_requests_subject (parcial, WHERE subject_id IS NOT NULL) y ck_four_eyes_requests_subject_pair
--                         (el sujeto va completo o no va; las filas existentes lo cumplen: ambas columnas nacen NULL)
--   conceptos (+5)  los 4 `kind` nuevos y delegated_access:REVIEWER_KIND_PLATFORM_ADMIN. Este último no estaba en el pedido:
--                         approver_kind_concept_id es NOT NULL y el vocabulario previo (médico, jefe de servicio, supervisor, administrador de la
--                         organización) no tiene un aprobador de plataforma; sin él el API tendría que declarar «administrador de la organización»
--                         en los lotes y cambios sensibles de plataforma. Ids = UUIDv5 de la clave, los mismos que deriva la API con deterministicId.
--
-- NO CAMBIA: tenant_id sigue NOT NULL (lotes y clasificaciones siempre tienen tenant; una aprobación de plataforma usa el tenant de la plataforma),
-- ni el índice único de pendientes (uq_four_eyes_requests_pending_payload), ni las políticas RLS.
--
-- REVERSA (solo agrega):
--   ALTER TABLE delegated_access.four_eyes_requests DROP CONSTRAINT IF EXISTS ck_four_eyes_requests_subject_pair, DROP COLUMN IF EXISTS subject_entity, DROP COLUMN IF EXISTS subject_id;
--   DELETE FROM terminology.catalog_concepts WHERE code IN ('delegated_access:FOUR_EYES_KIND_BULK_IMPORT_CONFIRM', 'delegated_access:FOUR_EYES_KIND_CATALOG_CLASSIFICATION', 'delegated_access:FOUR_EYES_KIND_GOVERNANCE_POLICY_CHANGE', 'delegated_access:FOUR_EYES_KIND_ACCESS_SENSITIVE_CHANGE', 'delegated_access:REVIEWER_KIND_PLATFORM_ADMIN');   -- solo si ninguna solicitud los usa
-- ============================================================================

BEGIN;
SET LOCAL lock_timeout = '15s';

-- ---- 0. prerequisitos ----
DO $$
BEGIN
    IF to_regclass('delegated_access.four_eyes_requests') IS NULL OR to_regclass('terminology.catalog_concepts') IS NULL THEN
        RAISE EXCEPTION 'faltan delegated_access.four_eyes_requests (parche v4278) o terminology.catalog_concepts';
    END IF;
END $$;

-- ---- 1. columnas nuevas (SQL/29_delegated_access/02_tables.sql; nullable: ADD COLUMN IF NOT EXISTS no reescribe la tabla) ----
ALTER TABLE "delegated_access"."four_eyes_requests" ADD COLUMN IF NOT EXISTS "subject_entity" varchar;
ALTER TABLE "delegated_access"."four_eyes_requests" ADD COLUMN IF NOT EXISTS "subject_id" uuid;

-- ---- 2. indice (SQL/29_delegated_access/04_indexes.sql) ----
CREATE INDEX IF NOT EXISTS "ix_four_eyes_requests_subject" ON "delegated_access"."four_eyes_requests" ("subject_entity", "subject_id") WHERE subject_id IS NOT NULL;

-- ---- 3. integridad (SQL/29_delegated_access/05_constraints.sql) ----
-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "delegated_access"."four_eyes_requests" DROP CONSTRAINT IF EXISTS "ck_four_eyes_requests_subject_pair";
ALTER TABLE "delegated_access"."four_eyes_requests" ADD CONSTRAINT "ck_four_eyes_requests_subject_pair" CHECK ((("subject_entity" IS NULL) = ("subject_id" IS NULL)));

-- ---- 4. conceptos (5 nuevos; ids = UUIDv5 de la clave, como deriva la API con deterministicId) ----
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
  ('31e5342a-69ca-51f7-ba85-eae0846c0973', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'delegated_access:FOUR_EYES_KIND_BULK_IMPORT_CONFIRM', 'Four-eyes kind: bulk import confirmation', false, true, now(), now(), 1),
  ('96048d4a-724a-572e-9b3b-83f23d4a1144', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'delegated_access:FOUR_EYES_KIND_CATALOG_CLASSIFICATION', 'Four-eyes kind: data catalog classification', false, true, now(), now(), 1),
  ('76a6d23b-a609-5a4f-92bc-2bc5eab75436', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'delegated_access:FOUR_EYES_KIND_GOVERNANCE_POLICY_CHANGE', 'Four-eyes kind: governance policy change', false, true, now(), now(), 1),
  ('fd295668-f51c-5562-8cc2-41e342a59e60', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'delegated_access:FOUR_EYES_KIND_ACCESS_SENSITIVE_CHANGE', 'Four-eyes kind: sensitive access change', false, true, now(), now(), 1),
  ('db5ab60e-ce23-5766-a63d-d6a9f141858a', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'delegated_access:REVIEWER_KIND_PLATFORM_ADMIN', 'Reviewer: another platform administrator', false, true, now(), now(), 1)
ON CONFLICT DO NOTHING;

-- ---- 5. verificacion final (si algo no cuadra, la transaccion entera se revierte) ----
DO $$
DECLARE
    n int;
BEGIN
    SELECT count(*) INTO n FROM information_schema.columns WHERE table_schema = 'delegated_access' AND table_name = 'four_eyes_requests' AND column_name IN ('subject_entity', 'subject_id');
    IF n <> 2 THEN RAISE EXCEPTION 'v4281 aprobacion: faltan las columnas subject_entity/subject_id de four_eyes_requests'; END IF;
    IF to_regclass('delegated_access.ix_four_eyes_requests_subject') IS NULL THEN RAISE EXCEPTION 'v4281 aprobacion: falta ix_four_eyes_requests_subject'; END IF;
    SELECT count(*) INTO n FROM pg_constraint WHERE conname = 'ck_four_eyes_requests_subject_pair' AND conrelid = 'delegated_access.four_eyes_requests'::regclass;
    IF n <> 1 THEN RAISE EXCEPTION 'v4281 aprobacion: falta ck_four_eyes_requests_subject_pair'; END IF;
    SELECT count(*) INTO n FROM terminology.catalog_concepts WHERE code IN ('delegated_access:FOUR_EYES_KIND_BULK_IMPORT_CONFIRM', 'delegated_access:FOUR_EYES_KIND_CATALOG_CLASSIFICATION', 'delegated_access:FOUR_EYES_KIND_GOVERNANCE_POLICY_CHANGE', 'delegated_access:FOUR_EYES_KIND_ACCESS_SENSITIVE_CHANGE', 'delegated_access:REVIEWER_KIND_PLATFORM_ADMIN');
    IF n <> 5 THEN RAISE EXCEPTION 'v4281 aprobacion: deberia haber 5 conceptos nuevos y hay %', n; END IF;
    RAISE NOTICE 'v4281 aprobacion: 2 columnas, 1 indice, 1 CHECK, 5 conceptos';
END $$;

COMMIT;
