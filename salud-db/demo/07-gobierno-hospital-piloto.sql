-- ============================================================================
-- HOSPITAL PILOTO · GOBIERNO DE ACCESOS (v4.2.72) — datos de DEMOSTRACIÓN (100 % FICTICIOS)
-- ============================================================================
-- Qué es: la extensión del hospital piloto de `04-hospital-piloto.sql` para probar el gobierno de accesos (permisos de ultra
-- granularidad y gobierno de usuarios, CONTRATO-GOBIERNO.md §10): 6 cuentas nuevas (jefa de Ecografía, jefe del Piso 1, caja, enfermería,
-- central telefónica que se va, segundo administrador de seguridad), 7 pacientes ficticios con 3 banderas (VIP, confidencial, familiar de
-- personal), 12 citas, permisos con condiciones, una DENY, reglas de la organización, una campaña de certificación vencida, una aprobación de
-- cuatro ojos pendiente, una excepción SoD activa, uso agregado y anomalías abiertas, casos de ciclo de vida y la configuración
-- `support.governance`. Nombres, documentos y correos son inventados (nada real). Todo id es uuid5(3f2b6c14-…, 'demo:gov:<tipo>:<clave>').
--
-- «HOY» DE REFERENCIA de las pruebas: martes 2026-11-03 10:30 (America/La_Paz, UTC-4). Las fechas del escenario son ABSOLUTAS (no relativas a
-- now()): sirve para que el dominio puro, el mock y esta base cuenten la misma historia. La excepción de Ricardo vence el 2026-12-31 y la
-- campaña «Certificación Q4-2026» venció el 2026-10-30.
--
-- Cuándo correrlo: DESPUÉS de `04-hospital-piloto.sql` y de los parches SQL/patches/2026-10-30_v4269_personal_apoyo.sql y
-- SQL/patches/2026-11-02_v4272_gobierno_de_accesos.sql. Es idempotente (ids deterministas + ON CONFLICT DO NOTHING) y cada UPDATE lleva su
-- guarda: volver a correrlo no duplica ni reescribe nada. Verifica: `08-verifica-gobierno.sql` (G9).
--
-- Interacción con `05-verifica-hospital-piloto.sql`: la referencia SQL de 05 es GRUESA (ignora condiciones, átomos y DENY). Las concesiones de
-- Ana×Rojas y de Marcos×Suárez(Norte) conservan sus filas ALIAS de 04 y reciben ADEMÁS los átomos con condiciones (regla del contrato: si el
-- mismo permiso trae el alias y el átomo, gana el átomo), así que 05 y 06 siguen en verde también después de este script.
--
-- Contraseña de TODAS las cuentas demo: Demo-Apoyo-2026 (argon2id; documento de acceso = `authentication_credentials.external_subject`,
-- p. ej. DEMO-SOFIA-CAMACHO). NO cargar en producción.
--
-- GUARDA B4 (como el 04): este script crea 6 cuentas con una contraseña CONOCIDA y el MISMO hash. Exige bandera explícita y, sin ella,
-- FALLA con un mensaje claro ANTES de escribir nada (una sola transacción):
--     psql -v ON_ERROR_STOP=1 -v demo_accounts=1 -d <base> -f salud-db/demo/07-gobierno-hospital-piloto.sql
-- (equivalente: `\set demo_accounts 1` en la sesión o PGOPTIONS="-c mantra.demo_accounts=1"). Valores aceptados: 1, true, on, yes.
-- ============================================================================

BEGIN;

-- GUARDA B4: sin la bandera explícita no se crea ninguna cuenta con contraseña conocida.
\if :{?demo_accounts}
  SELECT set_config('mantra.demo_accounts', :'demo_accounts', false);
\endif
DO $guard$
BEGIN
  IF lower(COALESCE(current_setting('mantra.demo_accounts', true), '')) NOT IN ('1', 'true', 'on', 'yes') THEN
    RAISE EXCEPTION 'gobierno del hospital piloto (demo): este script crea cuentas con una contraseña CONOCIDA (Demo-Apoyo-2026) y no corre sin consentimiento explícito. Vuelve a correrlo con -v demo_accounts=1 (o \set demo_accounts 1) SOLO en una base de demostración o pruebas, nunca en producción.'
      USING ERRCODE = 'insufficient_privilege',
            HINT = 'psql -v ON_ERROR_STOP=1 -v demo_accounts=1 -d <base> -f salud-db/demo/07-gobierno-hospital-piloto.sql';
  END IF;
  -- el escenario cuelga del hospital de 04: sin él no hay a qué extender
  IF NOT EXISTS (SELECT 1 FROM directory.tenants WHERE id = '830e47e1-8e82-50ff-99c0-bfed0a7971a4') THEN
    RAISE EXCEPTION 'gobierno del hospital piloto (demo): falta el Hospital Piloto de 04-hospital-piloto.sql; córralo primero'
      USING ERRCODE = 'undefined_object';
  END IF;
  RAISE WARNING 'gobierno del hospital piloto (demo): se crearán cuentas con la contraseña conocida Demo-Apoyo-2026 en la base %', current_database();
END
$guard$;

-- 0 · Anclas y conceptos que esta demo usa. Mismos ids que deriva la API (uuid5 sobre su namespace):
-- si la API ya arrancó, o si los seeds de boot / el parche v4272 ya los cargaron, todo esto es un no-op.
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
  ('1ec189f8-507a-5fce-9fac-09a584864c04', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'authz:APPROVAL_DOCTOR', 'Approval required from the practitioner', false, true, now(), now(), 1),  -- authz:APPROVAL_DOCTOR
  ('610c6456-d162-539e-b21e-2d19a4a99b88', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'authz:APPROVAL_SECOND_APPROVER', 'Approval required from a second approver (four eyes)', false, true, now(), now(), 1),  -- authz:APPROVAL_SECOND_APPROVER
  ('6905e0db-1650-5d49-adca-8b2688ac049c', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'authz:EFFECT_ALLOW', 'Allow', false, true, now(), now(), 1),  -- authz:EFFECT_ALLOW
  ('b038e546-a6ba-5848-9cd2-04b02ccb22b0', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'authz:EFFECT_DENY', 'Deny', false, true, now(), now(), 1),  -- authz:EFFECT_DENY
  ('32909f2c-edc4-5318-871a-e91a3879ad3e', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'authz:IP_RULE_ALLOW', 'Network rule: allow the range', false, true, now(), now(), 1),  -- authz:IP_RULE_ALLOW
  ('1b45f74f-f39e-58eb-b29a-86c100efeb67', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'authz:SCOPE_TENANT', 'Tenant scope', false, true, now(), now(), 1),  -- authz:SCOPE_TENANT
  ('d2f990d1-1def-59e1-b4bc-d3caf4b65e5d', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'community:CONVERSATION_ASSIGNMENT_TAKEN', 'Conversation assignment taken', false, true, now(), now(), 1),  -- community:CONVERSATION_ASSIGNMENT_TAKEN
  ('aa620322-258d-59bd-977f-77af000e2695', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'community:CONVERSATION_DIRECT', 'Direct conversation', false, true, now(), now(), 1),  -- community:CONVERSATION_DIRECT
  ('c2b1a0a7-47de-5d40-97af-bf20603d4335', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'SUBJ_CASE', 'Case subject', false, true, now(), now(), 1),  -- crm:subject-type:case
  ('b188b551-f49c-557f-95d0-432e1cfb3214', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'delegated_access:ANOMALY_INACTIVE_ACCOUNT', 'Anomaly: inactive account with live access', false, true, now(), now(), 1),  -- delegated_access:ANOMALY_INACTIVE_ACCOUNT
  ('5dc5d5c6-03af-5c50-9841-2559f959a180', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'delegated_access:ANOMALY_OPEN', 'Anomaly open', false, true, now(), now(), 1),  -- delegated_access:ANOMALY_OPEN
  ('7f20d407-aa33-5757-a6e0-3ddf9160592d', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'delegated_access:ANOMALY_SEARCH_SPIKE', 'Anomaly: spike of patient searches', false, true, now(), now(), 1),  -- delegated_access:ANOMALY_SEARCH_SPIKE
  ('505006e8-310d-5cfc-9758-e2856958d9ab', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'delegated_access:ASSIGN_ROLE_BILLING', 'Billing assignment', false, true, now(), now(), 1),  -- delegated_access:ASSIGN_ROLE_BILLING
  ('2e3e235b-5144-5e08-9141-41a402e3bee1', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'delegated_access:ASSIGN_ROLE_CALL_CENTER', 'Call center assignment', false, true, now(), now(), 1),  -- delegated_access:ASSIGN_ROLE_CALL_CENTER
  ('4afa11c6-c4ae-542a-8e47-b8b78d8c8aba', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'delegated_access:ASSIGN_ROLE_NURSE', 'Nurse assignment', false, true, now(), now(), 1),  -- delegated_access:ASSIGN_ROLE_NURSE
  ('3a5bfde0-e0f3-570d-b5f4-68bcdbf23102', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'delegated_access:ASSIGN_ROLE_ORG_MANAGEMENT', 'Organization management assignment', false, true, now(), now(), 1),  -- delegated_access:ASSIGN_ROLE_ORG_MANAGEMENT
  ('afb80bf4-0d35-5088-b4e3-bdba011cf227', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'delegated_access:DELEGATE_ROLE_SECRETARY', 'Secretary delegate role', false, true, now(), now(), 1),  -- delegated_access:DELEGATE_ROLE_SECRETARY
  ('320e177a-bda6-543f-97e6-d6c30873db41', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'delegated_access:ENGAGEMENT_ORIGIN_INVITATION', 'Engagement origin: invitation', false, true, now(), now(), 1),  -- delegated_access:ENGAGEMENT_ORIGIN_INVITATION
  ('a36afaec-1203-5ec7-beb3-d1595e264929', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'delegated_access:ENGAGEMENT_ORIGIN_QR', 'Engagement origin: QR code', false, true, now(), now(), 1),  -- delegated_access:ENGAGEMENT_ORIGIN_QR
  ('cdef8f46-a60e-5a84-97e3-37d5007e905d', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'delegated_access:ENGAGEMENT_ORIGIN_REQUEST', 'Engagement origin: request', false, true, now(), now(), 1),  -- delegated_access:ENGAGEMENT_ORIGIN_REQUEST
  ('013d578f-38af-564c-aff1-e36d1fdec6dd', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'delegated_access:FOUR_EYES_EXECUTED', 'Four-eyes request executed', false, true, now(), now(), 1),  -- delegated_access:FOUR_EYES_EXECUTED
  ('201ca117-97ad-58c2-a6d3-803ea412cd2c', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'delegated_access:FOUR_EYES_KIND_ACTION', 'Four-eyes kind: sensitive action', false, true, now(), now(), 1),  -- delegated_access:FOUR_EYES_KIND_ACTION
  ('5b36bf36-7f60-5d20-a2ea-3c7826e8d492', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'delegated_access:FOUR_EYES_KIND_SOD_EXCEPTION', 'Four-eyes kind: SoD exception', false, true, now(), now(), 1),  -- delegated_access:FOUR_EYES_KIND_SOD_EXCEPTION
  ('a977935a-9073-5113-9644-7df96732e776', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'delegated_access:FOUR_EYES_PENDING', 'Four-eyes request pending', false, true, now(), now(), 1),  -- delegated_access:FOUR_EYES_PENDING
  ('ce906685-7a58-54e7-b4d2-458062c0c303', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'delegated_access:GOV_RULE_CEILING', 'Governance rule: delegation ceiling', false, true, now(), now(), 1),  -- delegated_access:GOV_RULE_CEILING
  ('f2534b4a-a8cc-5fb1-a431-30e1a750274b', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'delegated_access:GOV_RULE_FIELD_FLOOR', 'Governance rule: field visibility floor', false, true, now(), now(), 1),  -- delegated_access:GOV_RULE_FIELD_FLOOR
  ('1b6db045-2cc5-5985-9c89-18b8ac0969be', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'delegated_access:GOV_RULE_REQUIRE_CONDITION', 'Governance rule: mandatory condition', false, true, now(), now(), 1),  -- delegated_access:GOV_RULE_REQUIRE_CONDITION
  ('e8273ad4-4e98-5dcb-869e-f34019625dbc', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'delegated_access:IDENTITY_METHOD_IN_PERSON', 'Identity verified in person with a document', false, true, now(), now(), 1),  -- delegated_access:IDENTITY_METHOD_IN_PERSON
  ('4734035e-72cf-519f-8e27-e6cf25ba557f', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'delegated_access:LIFECYCLE_COMPLETED', 'Lifecycle case completed', false, true, now(), now(), 1),  -- delegated_access:LIFECYCLE_COMPLETED
  ('c2a9a59d-c88c-5e87-9065-1e0e068c479d', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'delegated_access:LIFECYCLE_JOINER', 'Lifecycle case: joiner', false, true, now(), now(), 1),  -- delegated_access:LIFECYCLE_JOINER
  ('4f73e30c-25ba-52ff-969e-862e588cce13', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'delegated_access:LIFECYCLE_OPEN', 'Lifecycle case open', false, true, now(), now(), 1),  -- delegated_access:LIFECYCLE_OPEN
  ('6397159b-1477-5551-9950-862b8b8ce122', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'delegated_access:OWNER_KIND_ORGANIZATION', 'Support owner: organization', false, true, now(), now(), 1),  -- delegated_access:OWNER_KIND_ORGANIZATION
  ('697c3db6-133e-5d64-a6fb-6b9d4d5342d5', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'delegated_access:PATIENT_FLAG_CONFIDENTIAL', 'Patient restriction: confidential', false, true, now(), now(), 1),  -- delegated_access:PATIENT_FLAG_CONFIDENTIAL
  ('e384ff44-2406-56ea-80f7-f7f37018cc35', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'delegated_access:PATIENT_FLAG_STAFF_RELATIVE', 'Patient restriction: relative of staff', false, true, now(), now(), 1),  -- delegated_access:PATIENT_FLAG_STAFF_RELATIVE
  ('baf4dc8a-ac39-5c94-a176-92e012bd024f', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'delegated_access:PATIENT_FLAG_VIP', 'Patient restriction: VIP', false, true, now(), now(), 1),  -- delegated_access:PATIENT_FLAG_VIP
  ('7078aa21-2624-5d9e-beb2-a8bdfa8ad471', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'delegated_access:REPLY_DISCLOSURE_SHOW', 'Show that the care team replied', false, true, now(), now(), 1),  -- delegated_access:REPLY_DISCLOSURE_SHOW
  ('ca9f26e2-6ed7-5292-b073-b876770c6433', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'delegated_access:REVIEWER_KIND_ADMIN', 'Reviewer: organization administrator', false, true, now(), now(), 1),  -- delegated_access:REVIEWER_KIND_ADMIN
  ('75b09a0e-44df-5830-93d0-6539c00145fd', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'delegated_access:REVIEWER_KIND_DOCTOR_OWNER', 'Reviewer: the practitioner', false, true, now(), now(), 1),  -- delegated_access:REVIEWER_KIND_DOCTOR_OWNER
  ('716540f6-d919-5f7f-8fe9-7f50909b789f', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'delegated_access:REVIEWER_KIND_SERVICE_HEAD', 'Reviewer: head of service', false, true, now(), now(), 1),  -- delegated_access:REVIEWER_KIND_SERVICE_HEAD
  ('7e4272cc-9ebe-575a-bc36-b6983980a68f', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'delegated_access:REVIEWER_KIND_SUPERVISOR', 'Reviewer: supervisor of the account', false, true, now(), now(), 1),  -- delegated_access:REVIEWER_KIND_SUPERVISOR
  ('faa5c9bf-5300-5e43-8829-19a9f0e94fef', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'delegated_access:REVIEW_CAMPAIGN_OPEN', 'Access review campaign open', false, true, now(), now(), 1),  -- delegated_access:REVIEW_CAMPAIGN_OPEN
  ('a3896ca4-e2a6-5b1b-a192-6b457ea34586', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'delegated_access:REVIEW_ITEM_CERTIFIED', 'Access review item certified', false, true, now(), now(), 1),  -- delegated_access:REVIEW_ITEM_CERTIFIED
  ('55a6db07-19e7-5bb4-978a-3d246492f49d', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'delegated_access:REVIEW_ITEM_PENDING', 'Access review item pending', false, true, now(), now(), 1),  -- delegated_access:REVIEW_ITEM_PENDING
  ('bce72e9a-b3bb-5fab-8e79-85d411ba692c', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'delegated_access:REVIEW_ITEM_REVOKED', 'Access review item revoked', false, true, now(), now(), 1),  -- delegated_access:REVIEW_ITEM_REVOKED
  ('969627cf-9dff-5f7d-b6c6-8478414a6822', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'delegated_access:REVIEW_KIND_PERIODIC', 'Access review kind: periodic', false, true, now(), now(), 1),  -- delegated_access:REVIEW_KIND_PERIODIC
  ('e49e9baa-f3b1-5011-83ee-d1e3017aed36', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'delegated_access:SCOPE_TENANT', 'Tenant scope', false, true, now(), now(), 1),  -- delegated_access:SCOPE_TENANT
  ('d9ed1dfe-f5e6-55f3-94f2-2bd60993a536', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'delegated_access:SUPPORT_EXPANSION_DYNAMIC', 'Support grant expansion: dynamic (follows the organization)', false, true, now(), now(), 1),  -- delegated_access:SUPPORT_EXPANSION_DYNAMIC
  ('ccfbc54f-4744-53db-ab1f-abe1af31f784', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'delegated_access:SUPPORT_GRANT_ACTIVE', 'Support grant active', false, true, now(), now(), 1),  -- delegated_access:SUPPORT_GRANT_ACTIVE
  ('5cf6ef7d-3f5f-5864-93c8-eba9a9cd8af6', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'delegated_access:SUPPORT_GRANT_REVOKED', 'Support grant revoked', false, true, now(), now(), 1),  -- delegated_access:SUPPORT_GRANT_REVOKED
  ('cf4de420-16da-57f8-8c3a-f6ff717fc59e', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'delegated_access:SUPPORT_TARGET_ALL_LOCATIONS', 'Support grant target: all locations', false, true, now(), now(), 1),  -- delegated_access:SUPPORT_TARGET_ALL_LOCATIONS
  ('10510d38-c6cf-5243-9327-5cefc6c3aee5', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'delegated_access:SUPPORT_TARGET_LOCATION', 'Support grant target: location', false, true, now(), now(), 1),  -- delegated_access:SUPPORT_TARGET_LOCATION
  ('785d1671-5754-58d3-b1a3-e3cd467b82b7', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'delegated_access:SUPPORT_TARGET_PRACTITIONER', 'Support grant target: practitioner', false, true, now(), now(), 1),  -- delegated_access:SUPPORT_TARGET_PRACTITIONER
  ('953e4408-5e19-521b-a25a-3d062d788911', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'delegated_access:SUPPORT_TARGET_SERVICE', 'Support grant target: service', false, true, now(), now(), 1),  -- delegated_access:SUPPORT_TARGET_SERVICE
  ('cdc3190b-22f6-5662-8ae0-34c1fb5c2ed2', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'delegated_access:UNCERTIFIED_REVOKE', 'Not certified: revoke', false, true, now(), now(), 1),  -- delegated_access:UNCERTIFIED_REVOKE
  ('13ca1b46-61d5-5c25-9d49-8247bcd7769c', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'directory:MEMBERSHIP_ACTIVE', 'Membership active', false, true, now(), now(), 1),  -- directory:MEMBERSHIP_ACTIVE
  ('43634daf-8ee6-5e37-891b-3cf44d7a52f9', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'directory:ROLE_ADMIN', 'Tenant admin', false, true, now(), now(), 1),  -- directory:ROLE_ADMIN
  ('be676db1-0700-5b0f-892b-232cafd15afc', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'directory:ROLE_STAFF', 'Tenant staff', false, true, now(), now(), 1),  -- directory:ROLE_STAFF
  ('297d044a-a1e9-51db-8f96-68f4de6b3d62', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'directory:SCOPE_ALL_TENANT', 'All-tenant access scope', false, true, now(), now(), 1),  -- directory:SCOPE_ALL_TENANT
  ('f13fb5a6-e3b9-5d5d-bf90-f551a17b40c0', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'COMPANY', 'Company', false, true, now(), now(), 1),  -- directory:legal-entity:company
  ('4d38ec64-227a-599d-8924-21424d9a8986', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'TENANT_ACTIVE', 'Tenant active', false, true, now(), now(), 1),  -- directory:tenant-status:active
  ('670b3ab6-afef-5cb0-a582-667d95421049', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'PAYER', 'Insurance payer / carrier', false, true, now(), now(), 1),  -- directory:tenant-type:payer
  ('205bce05-3eb5-5785-8aa0-6120227dc4a5', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'TENANT_VERIFIED', 'Tenant verified', false, true, now(), now(), 1),  -- directory:tenant-verification:verified
  ('37da1281-cc62-5032-b598-1eb39dc46060', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'PASSWORD', 'Password credential', false, true, now(), now(), 1),  -- iam:cred-method:password
  ('646c89e7-29d5-5450-a4c6-17817fe55aa9', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'ARGON2ID', 'Argon2id', false, true, now(), now(), 1),  -- iam:hash-algo:argon2id
  ('e32f4e7d-cb62-56a2-b80e-4640d7c77b7c', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'MFA_DISABLED', 'MFA disabled', false, true, now(), now(), 1),  -- iam:mfa-status:disabled
  ('77b476d1-0600-54ba-9176-3670ab769435', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'SECURITY_ADMIN', 'Security administrator', false, true, now(), now(), 1),  -- iam:role:security-admin
  ('51f28f0b-95c2-57b1-a53b-2240c7e80731', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'USER', 'Standard user', false, true, now(), now(), 1),  -- iam:role:user
  ('32dbed9f-cf1f-5c7a-9070-dfb937cf68a1', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'USER_ACTIVE', 'User active', false, true, now(), now(), 1),  -- iam:user-status:active
  ('1ec18da3-d00f-53c9-a8fa-cee1ea549ab2', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'insurance:CARRIER_ACTIVE', 'Aseguradora activa', false, true, now(), now(), 1),  -- insurance:CARRIER_ACTIVE
  ('9a84b7ab-b1f5-5d62-af80-5483e1c62c3b', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'insurance:COVERAGE_ACTIVE', 'Cobertura activa', false, true, now(), now(), 1),  -- insurance:COVERAGE_ACTIVE
  ('267aa516-9431-555e-9500-d6d0f3e8af1f', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'insurance:PLAN_ACTIVE', 'Plan activo', false, true, now(), now(), 1),  -- insurance:PLAN_ACTIVE
  ('3d6c3013-5b47-530c-a656-3a5811b00f3f', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'insurance:PRODUCT_ACTIVE', 'Producto activo', false, true, now(), now(), 1),  -- insurance:PRODUCT_ACTIVE
  ('d8d87333-b4f6-5068-90e9-692ae665c0af', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'insurance:PRODUCT_TYPE_HEALTH', 'Producto de salud', false, true, now(), now(), 1),  -- insurance:PRODUCT_TYPE_HEALTH
  ('0b0e5055-6fc9-5100-906b-092852f09d72', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'insurance:RELATIONSHIP_SELF', 'Titular', false, true, now(), now(), 1),  -- insurance:RELATIONSHIP_SELF
  ('2ec60018-1de8-525f-835a-9c60e5cea3e4', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'insurance:VERIFY_VERIFIED', 'Verificado', false, true, now(), now(), 1),  -- insurance:VERIFY_VERIFIED
  ('64f1b3bf-78e2-5904-8a62-811edde0f779', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'practice:SETTING_CATEGORY_GENERAL', 'General setting category', false, true, now(), now(), 1),  -- practice:SETTING_CATEGORY_GENERAL
  ('6db29320-acc3-50f6-ac19-cb906aa96209', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'profiles:ACCOUNT_LINK_ACTIVE', 'Account link active', false, true, now(), now(), 1),  -- profiles:ACCOUNT_LINK_ACTIVE
  ('66d20226-5c40-5584-9f56-a892ac45676f', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'profiles:ACCOUNT_LINK_SELF', 'Self account link type', false, true, now(), now(), 1),  -- profiles:ACCOUNT_LINK_SELF
  ('3b904f87-050e-5cc0-bf9e-8c48ee43dc61', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'profiles:ACCOUNT_LINK_VERIFIED', 'Account link verified', false, true, now(), now(), 1),  -- profiles:ACCOUNT_LINK_VERIFIED
  ('d4939b72-ea54-524d-9021-bdca59efa37a', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'profiles:PERSON_ACTIVE', 'Person active', false, true, now(), now(), 1),  -- profiles:PERSON_ACTIVE
  ('4abd7a42-a25c-5b7d-9f07-e5e844fa903c', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'profiles:VITAL_ALIVE', 'Vital status alive', false, true, now(), now(), 1),  -- profiles:VITAL_ALIVE
  ('bf910452-1485-58ca-88dc-184b8b4b2935', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'BOOKING_CONFIRMED', 'Booking confirmed', false, true, now(), now(), 1),  -- scheduling:booking-status:confirmed
  ('de6bce1b-8b85-5edb-bea0-3994b5245d27', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'scheduling:BOOKING_PENDING_CONFIRMATION', 'Booking pending confirmation', false, true, now(), now(), 1),  -- scheduling:BOOKING_PENDING_CONFIRMATION
  ('f60c0fb5-7cb1-5c97-843b-f6581c52e9ef', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'CH_DESK', 'Front desk', false, true, now(), now(), 1),  -- scheduling:channel:desk
  ('a1df879c-4ac6-5a7e-8548-bc04207e92fa', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'RES_PRACTITIONER', 'Practitioner', false, true, now(), now(), 1),  -- scheduling:resource-type:practitioner
  ('0feda299-39ec-56b9-b1fd-7146db17e16c', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'SLOT_BOOKED', 'Slot booked', false, true, now(), now(), 1),  -- scheduling:slot-status:booked
  ('38a1d301-f40d-5b17-a695-5e6d605f8b19', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'ACTIVE', 'Active', false, true, now(), now(), 1),  -- state:active
  ('d681d62e-fc33-5a51-b7a5-81a15dfafd49', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'WFI_ACTIVE', 'Workflow instance active', false, true, now(), now(), 1),  -- workflow:instance-status:active
  ('4778c049-011c-5e91-9bd6-1e6bf8a0a42c', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'WFT_OPEN', 'Workflow task open', false, true, now(), now(), 1),  -- workflow:task-status:open
  ('dfe977d8-d6d3-5c44-8ed3-cdf934ba7f8e', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'WFTT_ACTION', 'Action task', false, true, now(), now(), 1)  -- workflow:task-type:action
ON CONFLICT DO NOTHING;

-- Cuentas (una por persona). Sin correo real: el acceso es por documento + contraseña demo.
INSERT INTO iam.users (id, status_concept_id, display_name, time_zone, email_verified, phone_verified, mfa_status_concept_id, created_at, updated_at, row_version, must_change_password) VALUES
  ('161a6e07-9098-52d4-82e9-d0485c5646a2', '32dbed9f-cf1f-5c7a-9070-dfb937cf68a1', 'Sofía Camacho', 'America/La_Paz', true, false, 'e32f4e7d-cb62-56a2-b80e-4640d7c77b7c', now(), now(), 1, false),
  ('4631fd76-9c97-50a5-8273-30ff2579dce5', '32dbed9f-cf1f-5c7a-9070-dfb937cf68a1', 'Ricardo Terceros', 'America/La_Paz', true, false, 'e32f4e7d-cb62-56a2-b80e-4640d7c77b7c', now(), now(), 1, false),
  ('1a4fe4d3-2f89-5a9d-9b63-b2b0df3cf2b1', '32dbed9f-cf1f-5c7a-9070-dfb937cf68a1', 'Mario Salvatierra', 'America/La_Paz', true, false, 'e32f4e7d-cb62-56a2-b80e-4640d7c77b7c', now(), now(), 1, false),
  ('8b6a27d3-3f51-5feb-8bf0-71db52f7e1c2', '32dbed9f-cf1f-5c7a-9070-dfb937cf68a1', 'Nora Villarroel', 'America/La_Paz', true, false, 'e32f4e7d-cb62-56a2-b80e-4640d7c77b7c', now(), now(), 1, false),
  ('902be75b-9e55-59c7-9f3f-01c34cde9dee', '32dbed9f-cf1f-5c7a-9070-dfb937cf68a1', 'Pablo Mamani', 'America/La_Paz', true, false, 'e32f4e7d-cb62-56a2-b80e-4640d7c77b7c', now(), now(), 1, false),
  ('2e6f6a4b-ccf2-5eaa-975a-d5883bbd25e2', '32dbed9f-cf1f-5c7a-9070-dfb937cf68a1', 'Gonzalo Pinto', 'America/La_Paz', true, false, 'e32f4e7d-cb62-56a2-b80e-4640d7c77b7c', now(), now(), 1, false)
ON CONFLICT DO NOTHING;

-- Credencial de contraseña (Demo-Apoyo-2026).
INSERT INTO iam.authentication_credentials (id, user_id, method_concept_id, external_subject, secret_hash, hash_algorithm_concept_id, state_concept_id, created_at, updated_at, row_version) VALUES
  ('f0b92a7f-9db3-5350-8362-189ad87ef1e5', '161a6e07-9098-52d4-82e9-d0485c5646a2', '37da1281-cc62-5032-b598-1eb39dc46060', 'DEMO-SOFIA-CAMACHO', '$argon2id$v=19$m=65536,p=4,t=3$VvAW/IsJO1zOPaFyfF9Isg$35k5DPJcNuW3UX2biUugDZlWeVPNRXjZ7GX1ydtFqPE', '646c89e7-29d5-5450-a4c6-17817fe55aa9', '38a1d301-f40d-5b17-a695-5e6d605f8b19', now(), now(), 1),
  ('0a0b433c-c7a4-5ed6-be4c-be34bf2dd3ac', '4631fd76-9c97-50a5-8273-30ff2579dce5', '37da1281-cc62-5032-b598-1eb39dc46060', 'DEMO-RICARDO-TERCEROS', '$argon2id$v=19$m=65536,p=4,t=3$VvAW/IsJO1zOPaFyfF9Isg$35k5DPJcNuW3UX2biUugDZlWeVPNRXjZ7GX1ydtFqPE', '646c89e7-29d5-5450-a4c6-17817fe55aa9', '38a1d301-f40d-5b17-a695-5e6d605f8b19', now(), now(), 1),
  ('c140ba2d-11e3-5850-a5f2-4a0b8f8f9184', '1a4fe4d3-2f89-5a9d-9b63-b2b0df3cf2b1', '37da1281-cc62-5032-b598-1eb39dc46060', 'DEMO-MARIO-SALVATIERRA', '$argon2id$v=19$m=65536,p=4,t=3$VvAW/IsJO1zOPaFyfF9Isg$35k5DPJcNuW3UX2biUugDZlWeVPNRXjZ7GX1ydtFqPE', '646c89e7-29d5-5450-a4c6-17817fe55aa9', '38a1d301-f40d-5b17-a695-5e6d605f8b19', now(), now(), 1),
  ('e6e6e1f0-a779-58a2-92b4-89ab48a8cdb1', '8b6a27d3-3f51-5feb-8bf0-71db52f7e1c2', '37da1281-cc62-5032-b598-1eb39dc46060', 'DEMO-NORA-VILLARROEL', '$argon2id$v=19$m=65536,p=4,t=3$VvAW/IsJO1zOPaFyfF9Isg$35k5DPJcNuW3UX2biUugDZlWeVPNRXjZ7GX1ydtFqPE', '646c89e7-29d5-5450-a4c6-17817fe55aa9', '38a1d301-f40d-5b17-a695-5e6d605f8b19', now(), now(), 1),
  ('eb181eae-5c63-5fba-b241-e29f78499f2a', '902be75b-9e55-59c7-9f3f-01c34cde9dee', '37da1281-cc62-5032-b598-1eb39dc46060', 'DEMO-PABLO-MAMANI', '$argon2id$v=19$m=65536,p=4,t=3$VvAW/IsJO1zOPaFyfF9Isg$35k5DPJcNuW3UX2biUugDZlWeVPNRXjZ7GX1ydtFqPE', '646c89e7-29d5-5450-a4c6-17817fe55aa9', '38a1d301-f40d-5b17-a695-5e6d605f8b19', now(), now(), 1),
  ('6bc5834e-a0dd-5c68-b7ec-f594b40086b4', '2e6f6a4b-ccf2-5eaa-975a-d5883bbd25e2', '37da1281-cc62-5032-b598-1eb39dc46060', 'DEMO-GONZALO-PINTO', '$argon2id$v=19$m=65536,p=4,t=3$VvAW/IsJO1zOPaFyfF9Isg$35k5DPJcNuW3UX2biUugDZlWeVPNRXjZ7GX1ydtFqPE', '646c89e7-29d5-5450-a4c6-17817fe55aa9', '38a1d301-f40d-5b17-a695-5e6d605f8b19', now(), now(), 1)
ON CONFLICT DO NOTHING;

-- Rol base USER; el administrador del hospital (de 04) y Gonzalo Pinto son SECURITY_ADMIN: quien aprueba lo que el otro pide (cuatro ojos).
INSERT INTO iam.user_global_roles (id, user_id, role_concept_id, state_concept_id, created_at, updated_at, row_version) VALUES
  ('001f8b6b-7ad8-5d22-b6a7-bd82ccb8ef22', '161a6e07-9098-52d4-82e9-d0485c5646a2', '51f28f0b-95c2-57b1-a53b-2240c7e80731', '38a1d301-f40d-5b17-a695-5e6d605f8b19', now(), now(), 1),
  ('f91e217d-bf57-5748-906a-b45c0cb91c01', '4631fd76-9c97-50a5-8273-30ff2579dce5', '51f28f0b-95c2-57b1-a53b-2240c7e80731', '38a1d301-f40d-5b17-a695-5e6d605f8b19', now(), now(), 1),
  ('c12a2697-9711-5d94-9426-3ac5b1b15172', '1a4fe4d3-2f89-5a9d-9b63-b2b0df3cf2b1', '51f28f0b-95c2-57b1-a53b-2240c7e80731', '38a1d301-f40d-5b17-a695-5e6d605f8b19', now(), now(), 1),
  ('a8dd034f-aedd-5ce0-a33e-5247bf91de31', '8b6a27d3-3f51-5feb-8bf0-71db52f7e1c2', '51f28f0b-95c2-57b1-a53b-2240c7e80731', '38a1d301-f40d-5b17-a695-5e6d605f8b19', now(), now(), 1),
  ('0168e396-7ad2-5d39-ba04-c3efc565c29a', '902be75b-9e55-59c7-9f3f-01c34cde9dee', '51f28f0b-95c2-57b1-a53b-2240c7e80731', '38a1d301-f40d-5b17-a695-5e6d605f8b19', now(), now(), 1),
  ('cc4a9e9c-65cf-5548-810c-da1d6948d848', '2e6f6a4b-ccf2-5eaa-975a-d5883bbd25e2', '51f28f0b-95c2-57b1-a53b-2240c7e80731', '38a1d301-f40d-5b17-a695-5e6d605f8b19', now(), now(), 1),
  ('3e63522d-368b-549b-88ec-c893f3ac14bb', '2e6f6a4b-ccf2-5eaa-975a-d5883bbd25e2', '77b476d1-0600-54ba-9176-3670ab769435', '38a1d301-f40d-5b17-a695-5e6d605f8b19', now(), now(), 1),
  ('1fc2dfdb-0d3c-5655-b545-890d00e8ffbf', 'a9dd40bb-1eb5-5b58-ae2a-06896d8c2810', '77b476d1-0600-54ba-9176-3670ab769435', '38a1d301-f40d-5b17-a695-5e6d605f8b19', now(), now(), 1)
ON CONFLICT DO NOTHING;

-- Personas de las cuentas nuevas.
INSERT INTO profiles.persons (id, person_status_concept_id, name, last_name, display_name, vital_status_concept_id, created_at, updated_at, row_version) VALUES
  ('5bb043f4-3c62-54d8-a546-765ba8f5b8fe', 'd4939b72-ea54-524d-9021-bdca59efa37a', 'Sofía', 'Camacho', 'Sofía Camacho', '4abd7a42-a25c-5b7d-9f07-e5e844fa903c', now(), now(), 1),
  ('85061eb8-d577-5e16-9165-d5b5be29f336', 'd4939b72-ea54-524d-9021-bdca59efa37a', 'Ricardo', 'Terceros', 'Ricardo Terceros', '4abd7a42-a25c-5b7d-9f07-e5e844fa903c', now(), now(), 1),
  ('ba4dad38-3cff-53dd-9eaa-ee48ee636ae9', 'd4939b72-ea54-524d-9021-bdca59efa37a', 'Mario', 'Salvatierra', 'Mario Salvatierra', '4abd7a42-a25c-5b7d-9f07-e5e844fa903c', now(), now(), 1),
  ('734165ae-bada-52b9-b27f-fcbe0bc4e83f', 'd4939b72-ea54-524d-9021-bdca59efa37a', 'Nora', 'Villarroel', 'Nora Villarroel', '4abd7a42-a25c-5b7d-9f07-e5e844fa903c', now(), now(), 1),
  ('7fd88ecc-02eb-55fe-8345-9dfc6cce8d9e', 'd4939b72-ea54-524d-9021-bdca59efa37a', 'Pablo', 'Mamani', 'Pablo Mamani', '4abd7a42-a25c-5b7d-9f07-e5e844fa903c', now(), now(), 1),
  ('8e63ba82-dab1-551b-aa47-7782ed5bd9ee', 'd4939b72-ea54-524d-9021-bdca59efa37a', 'Gonzalo', 'Pinto', 'Gonzalo Pinto', '4abd7a42-a25c-5b7d-9f07-e5e844fa903c', now(), now(), 1)
ON CONFLICT DO NOTHING;

-- Cada cuenta es titular de su persona.
INSERT INTO profiles.person_account_links (id, person_id, user_id, link_type_concept_id, verification_status_concept_id, valid_from, status_concept_id, created_at, updated_at, row_version) VALUES
  ('0207691e-41b0-57d4-89b8-908da32fe0d9', '5bb043f4-3c62-54d8-a546-765ba8f5b8fe', '161a6e07-9098-52d4-82e9-d0485c5646a2', '66d20226-5c40-5584-9f56-a892ac45676f', '3b904f87-050e-5cc0-bf9e-8c48ee43dc61', now(), '6db29320-acc3-50f6-ac19-cb906aa96209', now(), now(), 1),
  ('4b323f16-35b4-5c34-ab93-b46b5d3a1329', '85061eb8-d577-5e16-9165-d5b5be29f336', '4631fd76-9c97-50a5-8273-30ff2579dce5', '66d20226-5c40-5584-9f56-a892ac45676f', '3b904f87-050e-5cc0-bf9e-8c48ee43dc61', now(), '6db29320-acc3-50f6-ac19-cb906aa96209', now(), now(), 1),
  ('865641c1-2a06-5193-bb70-9543a898386c', 'ba4dad38-3cff-53dd-9eaa-ee48ee636ae9', '1a4fe4d3-2f89-5a9d-9b63-b2b0df3cf2b1', '66d20226-5c40-5584-9f56-a892ac45676f', '3b904f87-050e-5cc0-bf9e-8c48ee43dc61', now(), '6db29320-acc3-50f6-ac19-cb906aa96209', now(), now(), 1),
  ('fdf3a187-8b15-5767-a84d-780886db1c53', '734165ae-bada-52b9-b27f-fcbe0bc4e83f', '8b6a27d3-3f51-5feb-8bf0-71db52f7e1c2', '66d20226-5c40-5584-9f56-a892ac45676f', '3b904f87-050e-5cc0-bf9e-8c48ee43dc61', now(), '6db29320-acc3-50f6-ac19-cb906aa96209', now(), now(), 1),
  ('86511be7-409e-59fc-ac4f-e12f3a8a1f65', '7fd88ecc-02eb-55fe-8345-9dfc6cce8d9e', '902be75b-9e55-59c7-9f3f-01c34cde9dee', '66d20226-5c40-5584-9f56-a892ac45676f', '3b904f87-050e-5cc0-bf9e-8c48ee43dc61', now(), '6db29320-acc3-50f6-ac19-cb906aa96209', now(), now(), 1),
  ('fe0022fe-7a3c-550b-84f2-4c2d20637282', '8e63ba82-dab1-551b-aa47-7782ed5bd9ee', '2e6f6a4b-ccf2-5eaa-975a-d5883bbd25e2', '66d20226-5c40-5584-9f56-a892ac45676f', '3b904f87-050e-5cc0-bf9e-8c48ee43dc61', now(), '6db29320-acc3-50f6-ac19-cb906aa96209', now(), now(), 1)
ON CONFLICT DO NOTHING;

-- Membresías en el hospital: 5 de apoyo (STAFF) y el segundo administrador de seguridad (ADMIN).
INSERT INTO directory.tenant_memberships (id, user_id, tenant_id, tenant_role_concept_id, status_concept_id, access_scope_concept_id, start_date, created_at, updated_at, row_version) VALUES
  ('bcfc349c-0dce-547a-babd-51ef4e2ef708', '161a6e07-9098-52d4-82e9-d0485c5646a2', '830e47e1-8e82-50ff-99c0-bfed0a7971a4', 'be676db1-0700-5b0f-892b-232cafd15afc', '13ca1b46-61d5-5c25-9d49-8247bcd7769c', '297d044a-a1e9-51db-8f96-68f4de6b3d62', now(), now(), now(), 1),
  ('b9ece1b2-d191-57c3-a485-bda8e028787e', '4631fd76-9c97-50a5-8273-30ff2579dce5', '830e47e1-8e82-50ff-99c0-bfed0a7971a4', 'be676db1-0700-5b0f-892b-232cafd15afc', '13ca1b46-61d5-5c25-9d49-8247bcd7769c', '297d044a-a1e9-51db-8f96-68f4de6b3d62', now(), now(), now(), 1),
  ('0775bcbb-412b-5280-a01a-8c1b642a91a3', '1a4fe4d3-2f89-5a9d-9b63-b2b0df3cf2b1', '830e47e1-8e82-50ff-99c0-bfed0a7971a4', 'be676db1-0700-5b0f-892b-232cafd15afc', '13ca1b46-61d5-5c25-9d49-8247bcd7769c', '297d044a-a1e9-51db-8f96-68f4de6b3d62', now(), now(), now(), 1),
  ('8d99d949-0885-5612-9858-bdf311119fc0', '8b6a27d3-3f51-5feb-8bf0-71db52f7e1c2', '830e47e1-8e82-50ff-99c0-bfed0a7971a4', 'be676db1-0700-5b0f-892b-232cafd15afc', '13ca1b46-61d5-5c25-9d49-8247bcd7769c', '297d044a-a1e9-51db-8f96-68f4de6b3d62', now(), now(), now(), 1),
  ('440dd0e6-e129-58ec-ae03-c67256e7afd2', '902be75b-9e55-59c7-9f3f-01c34cde9dee', '830e47e1-8e82-50ff-99c0-bfed0a7971a4', 'be676db1-0700-5b0f-892b-232cafd15afc', '13ca1b46-61d5-5c25-9d49-8247bcd7769c', '297d044a-a1e9-51db-8f96-68f4de6b3d62', now(), now(), now(), 1),
  ('e148c6e1-fa3d-563a-8612-ade213308807', '2e6f6a4b-ccf2-5eaa-975a-d5883bbd25e2', '830e47e1-8e82-50ff-99c0-bfed0a7971a4', '43634daf-8ee6-5e37-891b-3cf44d7a52f9', '13ca1b46-61d5-5c25-9d49-8247bcd7769c', '297d044a-a1e9-51db-8f96-68f4de6b3d62', now(), now(), now(), 1)
ON CONFLICT DO NOTHING;

-- 7 pacientes ficticios (sin cuenta). Sandra Vargas no tiene fecha de nacimiento registrada (la regla de edad falla cerrado).
INSERT INTO profiles.persons (id, person_status_concept_id, name, last_name, display_name, birth_date, vital_status_concept_id, created_at, updated_at, row_version) VALUES
  ('1b0127e2-5979-540f-9f51-3fc0ca699331', 'd4939b72-ea54-524d-9021-bdca59efa37a', 'Carmen', 'Ortuño', 'Carmen Ortuño', date '1981-03-15', '4abd7a42-a25c-5b7d-9f07-e5e844fa903c', now(), now(), 1),
  ('0d79d694-fa71-5d38-8a36-829b738dfdac', 'd4939b72-ea54-524d-9021-bdca59efa37a', 'Luis', 'Choque', 'Luis Choque', date '1954-06-02', '4abd7a42-a25c-5b7d-9f07-e5e844fa903c', now(), now(), 1),
  ('50197407-ba97-5793-b92c-fd9b2e522d09', 'd4939b72-ea54-524d-9021-bdca59efa37a', 'Mateo', 'Rivera', 'Mateo Rivera', date '2018-05-20', '4abd7a42-a25c-5b7d-9f07-e5e844fa903c', now(), now(), 1),
  ('51abb7a4-a81f-52fb-b6e2-bcb550ff775b', 'd4939b72-ea54-524d-9021-bdca59efa37a', 'Paciente', 'Reservado 01', 'Paciente Reservado 01', date '1980-01-01', '4abd7a42-a25c-5b7d-9f07-e5e844fa903c', now(), now(), 1),
  ('fe49b2c8-98be-51e3-a7b3-6f7e1ed0ef99', 'd4939b72-ea54-524d-9021-bdca59efa37a', 'Paciente', 'Reservado 02', 'Paciente Reservado 02', date '1975-09-09', '4abd7a42-a25c-5b7d-9f07-e5e844fa903c', now(), now(), 1),
  ('9a2712ad-f6bb-58ec-a22d-50e13bf2ee28', 'd4939b72-ea54-524d-9021-bdca59efa37a', 'Sandra', 'Vargas', 'Sandra Vargas', NULL, '4abd7a42-a25c-5b7d-9f07-e5e844fa903c', now(), now(), 1),
  ('d0db7bd9-de04-555d-853f-315b2cefbc22', 'd4939b72-ea54-524d-9021-bdca59efa37a', 'Julián', 'Terán', 'Julián Terán', date '1997-02-14', '4abd7a42-a25c-5b7d-9f07-e5e844fa903c', now(), now(), 1)
ON CONFLICT DO NOTHING;

-- Perfil de paciente de cada una.
INSERT INTO profiles.patient_profiles (profile_id, patient_code, created_at, updated_at, row_version) VALUES
  ('1b0127e2-5979-540f-9f51-3fc0ca699331', 'DEMO-GOV-P01', now(), now(), 1),
  ('0d79d694-fa71-5d38-8a36-829b738dfdac', 'DEMO-GOV-P02', now(), now(), 1),
  ('50197407-ba97-5793-b92c-fd9b2e522d09', 'DEMO-GOV-P03', now(), now(), 1),
  ('51abb7a4-a81f-52fb-b6e2-bcb550ff775b', 'DEMO-GOV-P04', now(), now(), 1),
  ('fe49b2c8-98be-51e3-a7b3-6f7e1ed0ef99', 'DEMO-GOV-P05', now(), now(), 1),
  ('9a2712ad-f6bb-58ec-a22d-50e13bf2ee28', 'DEMO-GOV-P06', now(), now(), 1),
  ('d0db7bd9-de04-555d-853f-315b2cefbc22', 'DEMO-GOV-P07', now(), now(), 1)
ON CONFLICT DO NOTHING;

-- Banderas de acceso por organización (no son datos clínicos).
INSERT INTO delegated_access.patient_restriction_flags (id, tenant_id, patient_profile_id, flag_concept_id, reason_text, status_concept_id, valid_from, created_by_user_id, created_at, updated_at, row_version) VALUES
  ('72f1fc72-f266-5312-9df3-723ce61a29a0', '830e47e1-8e82-50ff-99c0-bfed0a7971a4', '51abb7a4-a81f-52fb-b6e2-bcb550ff775b', 'baf4dc8a-ac39-5c94-a176-92e012bd024f', 'Personalidad pública: solo el personal autorizado ve su agenda.', '38a1d301-f40d-5b17-a695-5e6d605f8b19', timestamptz '2026-10-01 08:00:00-04', 'a9dd40bb-1eb5-5b58-ae2a-06896d8c2810', now(), now(), 1),
  ('828d1f90-708f-5313-bf92-f395093e3caf', '830e47e1-8e82-50ff-99c0-bfed0a7971a4', 'fe49b2c8-98be-51e3-a7b3-6f7e1ed0ef99', '697c3db6-133e-5d64-a6fb-6b9d4d5342d5', 'Caso reservado por el doctor titular (confidencialidad reforzada).', '38a1d301-f40d-5b17-a695-5e6d605f8b19', timestamptz '2026-10-01 08:00:00-04', 'a9dd40bb-1eb5-5b58-ae2a-06896d8c2810', now(), now(), 1),
  ('43839346-3067-5c1b-af92-5372d83704e9', '830e47e1-8e82-50ff-99c0-bfed0a7971a4', 'd0db7bd9-de04-555d-853f-315b2cefbc22', 'e384ff44-2406-56ea-80f7-f7f37018cc35', 'Familiar de una persona del personal del hospital: acceso restringido.', '38a1d301-f40d-5b17-a695-5e6d605f8b19', timestamptz '2026-10-01 08:00:00-04', 'a9dd40bb-1eb5-5b58-ae2a-06896d8c2810', now(), now(), 1)
ON CONFLICT DO NOTHING;

-- Organización de la aseguradora ficticia.
INSERT INTO directory.tenants (id, code, tenant_type_concept_id, legal_name, trade_name, legal_entity_type_concept_id, status_concept_id, verification_status_concept_id, time_zone, created_at, updated_at, row_version) VALUES
  ('1bd96173-ddb0-53d8-87d1-1473263cf7b0', 'DEMO_ASEGURADORA_PILOTO', '670b3ab6-afef-5cb0-a582-667d95421049', 'Aseguradora Piloto (DEMO)', 'Aseguradora Piloto — datos ficticios de demostración', 'f13fb5a6-e3b9-5d5d-bf90-f551a17b40c0', '4d38ec64-227a-599d-8924-21424d9a8986', '205bce05-3eb5-5785-8aa0-6120227dc4a5', 'America/La_Paz', now(), now(), 1)
ON CONFLICT DO NOTHING;

-- Aseguradora ficticia.
INSERT INTO insurance.insurance_carriers (id, tenant_id, carrier_code, legal_name, sigla, verification_status_concept_id, status_concept_id, created_at, updated_at, row_version) VALUES
  ('30c3f404-69af-5bda-98a8-0dee304410c5', '1bd96173-ddb0-53d8-87d1-1473263cf7b0', 'DEMO-ASEG-01', 'Aseguradora Piloto (DEMO)', 'ASEGPIL', '2ec60018-1de8-525f-835a-9c60e5cea3e4', '1ec18da3-d00f-53c9-a8fa-cee1ea549ab2', now(), now(), 1)
ON CONFLICT DO NOTHING;

-- Producto de salud.
INSERT INTO insurance.insurance_products (id, insurance_carrier_id, product_code, name, product_type_concept_id, status_concept_id, created_at, updated_at, row_version) VALUES
  ('3c0d99fd-08c3-5a6d-838e-06808e9416b4', '30c3f404-69af-5bda-98a8-0dee304410c5', 'DEMO-PROD-SALUD', 'Salud integral (DEMO)', 'd8d87333-b4f6-5068-90e9-692ae665c0af', '3d6c3013-5b47-530c-a656-3a5811b00f3f', now(), now(), 1)
ON CONFLICT DO NOTHING;

-- Plan.
INSERT INTO insurance.insurance_plans (id, insurance_product_id, plan_code, name, status_concept_id, created_at, updated_at, row_version) VALUES
  ('34aa956e-60c1-57c6-ac41-f556396c2fb1', '3c0d99fd-08c3-5a6d-838e-06808e9416b4', 'DEMO-PLAN-BASICO', 'Plan básico (DEMO)', '267aa516-9431-555e-9500-d6d0f3e8af1f', now(), now(), 1)
ON CONFLICT DO NOTHING;

-- Cobertura vigente de Carmen y Mateo; Luis (y el resto) no tiene seguro.
INSERT INTO insurance.patient_coverages (id, patient_profile_id, insurance_plan_id, member_identifier, coverage_order, relationship_to_subscriber_concept_id, effective_from, verification_status_concept_id, status_concept_id, created_at, updated_at, row_version) VALUES
  ('af9d294b-5d8d-55a8-9e9a-366f0e7e9949', '1b0127e2-5979-540f-9f51-3fc0ca699331', '34aa956e-60c1-57c6-ac41-f556396c2fb1', 'DEMO-AFIL-001', 1, '0b0e5055-6fc9-5100-906b-092852f09d72', date '2026-01-01', '2ec60018-1de8-525f-835a-9c60e5cea3e4', '9a84b7ab-b1f5-5d62-af80-5483e1c62c3b', now(), now(), 1),
  ('7cac1521-2015-5b9b-960a-19ef5a97e404', '50197407-ba97-5793-b92c-fd9b2e522d09', '34aa956e-60c1-57c6-ac41-f556396c2fb1', 'DEMO-AFIL-002', 1, '0b0e5055-6fc9-5100-906b-092852f09d72', date '2026-01-01', '2ec60018-1de8-525f-835a-9c60e5cea3e4', '9a84b7ab-b1f5-5d62-af80-5483e1c62c3b', now(), now(), 1)
ON CONFLICT DO NOTHING;

-- Una agenda por doctor con citas en el piloto de gobierno.
INSERT INTO scheduling.schedulable_resources (id, tenant_id, practice_id, resource_type_concept_id, resource_ref_type, resource_ref_id, name, time_zone, capacity, state_concept_id, created_at, updated_at, row_version) VALUES
  ('5549832e-faf2-549a-bd3d-b800d570d06b', '830e47e1-8e82-50ff-99c0-bfed0a7971a4', '314eeab4-0062-5e4f-b3f1-4e26174daa10', 'a1df879c-4ac6-5a7e-8548-bc04207e92fa', 'health_practitioner_profiles', '96307267-f432-5fd2-9bd0-e609625088ab', 'Agenda Perez (DEMO)', 'America/La_Paz', 1, '38a1d301-f40d-5b17-a695-5e6d605f8b19', now(), now(), 1),
  ('8ea38260-8e96-5c08-909e-5689a5616e13', '830e47e1-8e82-50ff-99c0-bfed0a7971a4', '314eeab4-0062-5e4f-b3f1-4e26174daa10', 'a1df879c-4ac6-5a7e-8548-bc04207e92fa', 'health_practitioner_profiles', 'fe30dd79-cad3-567e-ac02-8f3ee5f27bf9', 'Agenda Suarez (DEMO)', 'America/La_Paz', 1, '38a1d301-f40d-5b17-a695-5e6d605f8b19', now(), now(), 1),
  ('a68520ec-0fcf-52ca-8bf0-4a8b07bfa1e1', '830e47e1-8e82-50ff-99c0-bfed0a7971a4', '314eeab4-0062-5e4f-b3f1-4e26174daa10', 'a1df879c-4ac6-5a7e-8548-bc04207e92fa', 'health_practitioner_profiles', '2af4ef83-2676-5032-ab17-ffef12c48e47', 'Agenda Rojas (DEMO)', 'America/La_Paz', 1, '38a1d301-f40d-5b17-a695-5e6d605f8b19', now(), now(), 1),
  ('efcf33f9-a6ca-59c2-97a1-3898dd822ef7', '830e47e1-8e82-50ff-99c0-bfed0a7971a4', '314eeab4-0062-5e4f-b3f1-4e26174daa10', 'a1df879c-4ac6-5a7e-8548-bc04207e92fa', 'health_practitioner_profiles', '569fa481-abe1-5b70-ba9e-add5bd4dbf54', 'Agenda Antelo (DEMO)', 'America/La_Paz', 1, '38a1d301-f40d-5b17-a695-5e6d605f8b19', now(), now(), 1),
  ('d70757d8-c49b-554c-8a69-4378546acfb2', '830e47e1-8e82-50ff-99c0-bfed0a7971a4', '314eeab4-0062-5e4f-b3f1-4e26174daa10', 'a1df879c-4ac6-5a7e-8548-bc04207e92fa', 'health_practitioner_profiles', '4a443ffa-92e4-5015-86a5-2d51c726bf76', 'Agenda Mendez (DEMO)', 'America/La_Paz', 1, '38a1d301-f40d-5b17-a695-5e6d605f8b19', now(), now(), 1)
ON CONFLICT DO NOTHING;

-- La API nombra la tabla de perfiles como `health_practitioner_profiles` (o `practitioner_profiles`: PRACTITIONER_PROFILE_TABLES); con el nombre
-- calificado `profiles.health_practitioner_profiles` que traían las versiones anteriores la política de agenda no encuentra al doctor de la cita y todo
-- da DOCTOR_NOT_ACCEPTED. Este UPDATE normaliza también una base ya cargada con el nombre antiguo (no toca ninguna otra fila).
UPDATE scheduling.schedulable_resources SET resource_ref_type = 'health_practitioner_profiles', updated_at = now()
 WHERE resource_ref_type = 'profiles.health_practitioner_profiles' AND name LIKE 'Agenda % (DEMO)';

-- Un cupo ocupado por cita (A1…A12 del contrato §10.2 + A13, la cita pendiente que creó Pablo).
INSERT INTO scheduling.bookable_slots (id, resource_id, start_at, end_at, capacity, remaining_capacity, status_concept_id, care_space_id, healthcare_service_id, created_at, updated_at, row_version) VALUES
  ('541e084c-c775-5a6a-acf1-aa17374425e8', '5549832e-faf2-549a-bd3d-b800d570d06b', timestamptz '2026-11-03 16:30:00-04', timestamptz '2026-11-03 17:00:00-04', 1, 0, '0feda299-39ec-56b9-b1fd-7146db17e16c', '0feafc25-2f9c-50b7-a3c0-af4efd4e7fb1', 'a6972272-66d5-52e5-8b97-01abeedb908c', now(), now(), 1),
  ('d1c770bd-0593-553c-85f0-545ad60359b2', '5549832e-faf2-549a-bd3d-b800d570d06b', timestamptz '2026-11-04 07:00:00-04', timestamptz '2026-11-04 07:30:00-04', 1, 0, '0feda299-39ec-56b9-b1fd-7146db17e16c', '0feafc25-2f9c-50b7-a3c0-af4efd4e7fb1', 'a6972272-66d5-52e5-8b97-01abeedb908c', now(), now(), 1),
  ('f68090d8-fe4f-51ae-b4cc-6dec9d02bac7', '5549832e-faf2-549a-bd3d-b800d570d06b', timestamptz '2026-11-20 10:00:00-04', timestamptz '2026-11-20 10:30:00-04', 1, 0, '0feda299-39ec-56b9-b1fd-7146db17e16c', '0feafc25-2f9c-50b7-a3c0-af4efd4e7fb1', 'a6972272-66d5-52e5-8b97-01abeedb908c', now(), now(), 1),
  ('0733038f-f61e-57a5-9e39-78e54404b14d', '8ea38260-8e96-5c08-909e-5689a5616e13', timestamptz '2026-11-04 09:00:00-04', timestamptz '2026-11-04 09:30:00-04', 1, 0, '0feda299-39ec-56b9-b1fd-7146db17e16c', '709a4334-ae78-569c-bc24-755f2be12403', 'e7f7d45a-16ca-56f8-a208-10c828f3506b', now(), now(), 1),
  ('e8572131-69d7-524d-973d-f38b75c057b0', '5549832e-faf2-549a-bd3d-b800d570d06b', timestamptz '2026-11-03 11:30:00-04', timestamptz '2026-11-03 12:00:00-04', 1, 0, '0feda299-39ec-56b9-b1fd-7146db17e16c', '0feafc25-2f9c-50b7-a3c0-af4efd4e7fb1', 'a6972272-66d5-52e5-8b97-01abeedb908c', now(), now(), 1),
  ('9348d5d7-cade-575f-9296-436c322adde7', 'a68520ec-0fcf-52ca-8bf0-4a8b07bfa1e1', timestamptz '2026-11-03 14:00:00-04', timestamptz '2026-11-03 14:30:00-04', 1, 0, '0feda299-39ec-56b9-b1fd-7146db17e16c', '6e40ca20-7c68-5796-a884-27fd44b0a89e', '73e20b2b-af05-523c-9d6c-1b2ebbff778d', now(), now(), 1),
  ('deffa940-f4d1-5508-8796-694a40adbac1', 'efcf33f9-a6ca-59c2-97a1-3898dd822ef7', timestamptz '2026-11-05 10:00:00-04', timestamptz '2026-11-05 10:30:00-04', 1, 0, '0feda299-39ec-56b9-b1fd-7146db17e16c', '462ffc1f-f086-509d-b26a-487dfdb82b03', 'da47af6a-fc7a-5d56-93cb-7bbe45b26ce5', now(), now(), 1),
  ('a4b074b4-4f23-5885-a4a2-32a9ae8ed452', 'd70757d8-c49b-554c-8a69-4378546acfb2', timestamptz '2026-11-03 12:00:00-04', timestamptz '2026-11-03 12:30:00-04', 1, 0, '0feda299-39ec-56b9-b1fd-7146db17e16c', 'c6ba3db5-3f9a-5cc9-b07a-6eff8a0f3887', '56dc1368-9366-52d5-b5da-09c605bf0382', now(), now(), 1),
  ('16783712-7815-5634-a262-874079263cbb', '5549832e-faf2-549a-bd3d-b800d570d06b', timestamptz '2026-11-03 09:00:00-04', timestamptz '2026-11-03 09:30:00-04', 1, 0, '0feda299-39ec-56b9-b1fd-7146db17e16c', '0feafc25-2f9c-50b7-a3c0-af4efd4e7fb1', 'a6972272-66d5-52e5-8b97-01abeedb908c', now(), now(), 1),
  ('faee3dfc-292e-5027-9297-ce7279c9b463', 'a68520ec-0fcf-52ca-8bf0-4a8b07bfa1e1', timestamptz '2026-11-03 16:30:00-04', timestamptz '2026-11-03 17:00:00-04', 1, 0, '0feda299-39ec-56b9-b1fd-7146db17e16c', '6e40ca20-7c68-5796-a884-27fd44b0a89e', '73e20b2b-af05-523c-9d6c-1b2ebbff778d', now(), now(), 1),
  ('7c1c7ec5-1a59-5c13-bc81-af4e66f20a3a', 'a68520ec-0fcf-52ca-8bf0-4a8b07bfa1e1', timestamptz '2026-11-05 11:00:00-04', timestamptz '2026-11-05 11:30:00-04', 1, 0, '0feda299-39ec-56b9-b1fd-7146db17e16c', '6e40ca20-7c68-5796-a884-27fd44b0a89e', '73e20b2b-af05-523c-9d6c-1b2ebbff778d', now(), now(), 1),
  ('987da6d7-7107-57a0-ae79-c9586dd42ffc', 'd70757d8-c49b-554c-8a69-4378546acfb2', timestamptz '2026-11-04 15:00:00-04', timestamptz '2026-11-04 15:30:00-04', 1, 0, '0feda299-39ec-56b9-b1fd-7146db17e16c', 'c6ba3db5-3f9a-5cc9-b07a-6eff8a0f3887', '56dc1368-9366-52d5-b5da-09c605bf0382', now(), now(), 1),
  ('84d3f20b-e940-5b57-aa11-2fa7b8517c4b', '5549832e-faf2-549a-bd3d-b800d570d06b', timestamptz '2026-11-10 09:00:00-04', timestamptz '2026-11-10 09:30:00-04', 1, 0, '0feda299-39ec-56b9-b1fd-7146db17e16c', '0feafc25-2f9c-50b7-a3c0-af4efd4e7fb1', 'a6972272-66d5-52e5-8b97-01abeedb908c', now(), now(), 1)
ON CONFLICT DO NOTHING;

-- A4 (Mateo con Suárez, mañana 09:00) está en el consultorio N102 de la Sede Norte y NO en B102 (Edificio B de la Sede Central): el contrato (casos 36 y 39) hace que
-- Marcos la pueda cancelar con su permiso «Suárez × Sede Norte», que B102 no cubre (caso 08: «Suárez en el Edificio B» queda negado). Suárez también atiende en N102.
-- Las citas (todas con booked_via_grant_id NULL). Los motivos son frases ficticias, sin datos de nadie.
INSERT INTO scheduling.appointment_bookings (id, tenant_id, patient_profile_id, bookable_slot_id, resource_id, booking_channel_concept_id, booked_by_user_id, status_concept_id, reason_text, care_space_id, healthcare_service_id, created_at, updated_at, row_version) VALUES
  ('94e68cf4-45b2-59d1-88bf-bcd7123c0153', '830e47e1-8e82-50ff-99c0-bfed0a7971a4', '1b0127e2-5979-540f-9f51-3fc0ca699331', '541e084c-c775-5a6a-acf1-aa17374425e8', '5549832e-faf2-549a-bd3d-b800d570d06b', 'f60c0fb5-7cb1-5c97-843b-f6581c52e9ef', NULL, 'bf910452-1485-58ca-88dc-184b8b4b2935', 'Control de presión arterial (ficticio)', '0feafc25-2f9c-50b7-a3c0-af4efd4e7fb1', 'a6972272-66d5-52e5-8b97-01abeedb908c', now(), now(), 1),
  ('f8ac4d60-21d7-5c82-9fc0-5d93296dd02e', '830e47e1-8e82-50ff-99c0-bfed0a7971a4', '1b0127e2-5979-540f-9f51-3fc0ca699331', 'd1c770bd-0593-553c-85f0-545ad60359b2', '5549832e-faf2-549a-bd3d-b800d570d06b', 'f60c0fb5-7cb1-5c97-843b-f6581c52e9ef', NULL, 'bf910452-1485-58ca-88dc-184b8b4b2935', 'Resultados de laboratorio (ficticio)', '0feafc25-2f9c-50b7-a3c0-af4efd4e7fb1', 'a6972272-66d5-52e5-8b97-01abeedb908c', now(), now(), 1),
  ('4ab690a0-a28e-5e30-8f4a-aa6f0ac22f78', '830e47e1-8e82-50ff-99c0-bfed0a7971a4', '0d79d694-fa71-5d38-8a36-829b738dfdac', 'f68090d8-fe4f-51ae-b4cc-6dec9d02bac7', '5549832e-faf2-549a-bd3d-b800d570d06b', 'f60c0fb5-7cb1-5c97-843b-f6581c52e9ef', NULL, 'bf910452-1485-58ca-88dc-184b8b4b2935', 'Control semestral (ficticio)', '0feafc25-2f9c-50b7-a3c0-af4efd4e7fb1', 'a6972272-66d5-52e5-8b97-01abeedb908c', now(), now(), 1),
  ('02d06e6c-3f9f-5a58-bc4c-362aeb6c6861', '830e47e1-8e82-50ff-99c0-bfed0a7971a4', '50197407-ba97-5793-b92c-fd9b2e522d09', '0733038f-f61e-57a5-9e39-78e54404b14d', '8ea38260-8e96-5c08-909e-5689a5616e13', 'f60c0fb5-7cb1-5c97-843b-f6581c52e9ef', NULL, 'bf910452-1485-58ca-88dc-184b8b4b2935', 'Control de niño sano (ficticio)', '709a4334-ae78-569c-bc24-755f2be12403', 'e7f7d45a-16ca-56f8-a208-10c828f3506b', now(), now(), 1),
  ('c389372e-1343-582c-967f-0500bebebe6e', '830e47e1-8e82-50ff-99c0-bfed0a7971a4', '51abb7a4-a81f-52fb-b6e2-bcb550ff775b', 'e8572131-69d7-524d-973d-f38b75c057b0', '5549832e-faf2-549a-bd3d-b800d570d06b', 'f60c0fb5-7cb1-5c97-843b-f6581c52e9ef', NULL, 'bf910452-1485-58ca-88dc-184b8b4b2935', 'Consulta reservada (ficticio)', '0feafc25-2f9c-50b7-a3c0-af4efd4e7fb1', 'a6972272-66d5-52e5-8b97-01abeedb908c', now(), now(), 1),
  ('14b7f2bc-47bd-5301-b874-f24549818bde', '830e47e1-8e82-50ff-99c0-bfed0a7971a4', 'fe49b2c8-98be-51e3-a7b3-6f7e1ed0ef99', '9348d5d7-cade-575f-9296-436c322adde7', 'a68520ec-0fcf-52ca-8bf0-4a8b07bfa1e1', 'f60c0fb5-7cb1-5c97-843b-f6581c52e9ef', NULL, 'bf910452-1485-58ca-88dc-184b8b4b2935', 'Consulta reservada (ficticio)', '6e40ca20-7c68-5796-a884-27fd44b0a89e', '73e20b2b-af05-523c-9d6c-1b2ebbff778d', now(), now(), 1),
  ('a20a30f8-009e-5aa2-a16e-3c3263303aa7', '830e47e1-8e82-50ff-99c0-bfed0a7971a4', '1b0127e2-5979-540f-9f51-3fc0ca699331', 'deffa940-f4d1-5508-8796-694a40adbac1', 'efcf33f9-a6ca-59c2-97a1-3898dd822ef7', 'f60c0fb5-7cb1-5c97-843b-f6581c52e9ef', NULL, 'bf910452-1485-58ca-88dc-184b8b4b2935', 'Ecografía abdominal (ficticio)', '462ffc1f-f086-509d-b26a-487dfdb82b03', 'da47af6a-fc7a-5d56-93cb-7bbe45b26ce5', now(), now(), 1),
  ('b678f714-1bc8-53f7-903f-580ad568d226', '830e47e1-8e82-50ff-99c0-bfed0a7971a4', '9a2712ad-f6bb-58ec-a22d-50e13bf2ee28', 'a4b074b4-4f23-5885-a4a2-32a9ae8ed452', 'd70757d8-c49b-554c-8a69-4378546acfb2', 'f60c0fb5-7cb1-5c97-843b-f6581c52e9ef', NULL, 'bf910452-1485-58ca-88dc-184b8b4b2935', 'Chequeo general (ficticio)', 'c6ba3db5-3f9a-5cc9-b07a-6eff8a0f3887', '56dc1368-9366-52d5-b5da-09c605bf0382', now(), now(), 1),
  ('19ba6cd8-58f7-5d12-b2b4-94fe83611da7', '830e47e1-8e82-50ff-99c0-bfed0a7971a4', 'd0db7bd9-de04-555d-853f-315b2cefbc22', '16783712-7815-5634-a262-874079263cbb', '5549832e-faf2-549a-bd3d-b800d570d06b', 'f60c0fb5-7cb1-5c97-843b-f6581c52e9ef', NULL, 'bf910452-1485-58ca-88dc-184b8b4b2935', 'Consulta de seguimiento (ficticio)', '0feafc25-2f9c-50b7-a3c0-af4efd4e7fb1', 'a6972272-66d5-52e5-8b97-01abeedb908c', now(), now(), 1),
  ('defd605d-eab0-544f-8b27-6a103d1faaaa', '830e47e1-8e82-50ff-99c0-bfed0a7971a4', '0d79d694-fa71-5d38-8a36-829b738dfdac', 'faee3dfc-292e-5027-9297-ce7279c9b463', 'a68520ec-0fcf-52ca-8bf0-4a8b07bfa1e1', 'f60c0fb5-7cb1-5c97-843b-f6581c52e9ef', NULL, 'bf910452-1485-58ca-88dc-184b8b4b2935', 'Consulta ginecológica (ficticio)', '6e40ca20-7c68-5796-a884-27fd44b0a89e', '73e20b2b-af05-523c-9d6c-1b2ebbff778d', now(), now(), 1),
  ('c2aa2413-478e-50b5-ad18-782761f453aa', '830e47e1-8e82-50ff-99c0-bfed0a7971a4', '1b0127e2-5979-540f-9f51-3fc0ca699331', '7c1c7ec5-1a59-5c13-bc81-af4e66f20a3a', 'a68520ec-0fcf-52ca-8bf0-4a8b07bfa1e1', 'f60c0fb5-7cb1-5c97-843b-f6581c52e9ef', NULL, 'bf910452-1485-58ca-88dc-184b8b4b2935', 'Control ginecológico (ficticio)', '6e40ca20-7c68-5796-a884-27fd44b0a89e', '73e20b2b-af05-523c-9d6c-1b2ebbff778d', now(), now(), 1),
  ('c22bf59a-3fed-525d-a7ca-1a97a14f8945', '830e47e1-8e82-50ff-99c0-bfed0a7971a4', '1b0127e2-5979-540f-9f51-3fc0ca699331', '987da6d7-7107-57a0-ae79-c9586dd42ffc', 'd70757d8-c49b-554c-8a69-4378546acfb2', 'f60c0fb5-7cb1-5c97-843b-f6581c52e9ef', NULL, 'bf910452-1485-58ca-88dc-184b8b4b2935', 'Control de medicina interna (ficticio)', 'c6ba3db5-3f9a-5cc9-b07a-6eff8a0f3887', '56dc1368-9366-52d5-b5da-09c605bf0382', now(), now(), 1),
  ('03ba03b9-9e29-5219-8b0f-b5c94a32b81d', '830e47e1-8e82-50ff-99c0-bfed0a7971a4', '0d79d694-fa71-5d38-8a36-829b738dfdac', '84d3f20b-e940-5b57-aa11-2fa7b8517c4b', '5549832e-faf2-549a-bd3d-b800d570d06b', 'f60c0fb5-7cb1-5c97-843b-f6581c52e9ef', '902be75b-9e55-59c7-9f3f-01c34cde9dee', 'de6bce1b-8b85-5edb-bea0-3994b5245d27', 'Cita agendada por la central telefónica (pendiente de seguimiento)', '0feafc25-2f9c-50b7-a3c0-af4efd4e7fb1', 'a6972272-66d5-52e5-8b97-01abeedb908c', now(), now(), 1)
ON CONFLICT DO NOTHING;

-- Una base cargada con la versión anterior de este script dejó A4 en B102: se mueve la reserva Y su cupo a N102 (con guarda: solo si siguen en B102).
UPDATE scheduling.bookable_slots SET care_space_id = '709a4334-ae78-569c-bc24-755f2be12403', updated_at = now()
 WHERE id = '0733038f-f61e-57a5-9e39-78e54404b14d' AND care_space_id = 'b8b695a4-36ef-59d1-976a-372df6c8e3e1';
UPDATE scheduling.appointment_bookings SET care_space_id = '709a4334-ae78-569c-bc24-755f2be12403', updated_at = now()
 WHERE id = '02d06e6c-3f9f-5a58-bc4c-362aeb6c6861' AND care_space_id = 'b8b695a4-36ef-59d1-976a-372df6c8e3e1';

-- A13 (la cita que dejó creada Pablo) nace PENDIENTE DE CONFIRMAR: es lo que busca el traspaso al dar de baja (HandoverWorkRepository.findPendingBookings
-- exige `scheduling:BOOKING_PENDING_CONFIRMATION` y un horario futuro). Antes del v4.2.72-B7a nacía CONFIRMADA y el traspaso de Pablo no la veía (caso 30);
-- este UPDATE (con su guarda) la corrige también en una base ya cargada. Las demás citas no se tocan.
UPDATE scheduling.appointment_bookings SET status_concept_id = 'de6bce1b-8b85-5edb-bea0-3994b5245d27', updated_at = now()
 WHERE id = '03ba03b9-9e29-5219-8b0f-b5c94a32b81d' AND status_concept_id = 'bf910452-1485-58ca-88dc-184b8b4b2935';

-- Nora (L-06, caso 35): su vínculo nace el 2026-11-03, POSTERIOR a `onboardingRequiredSince` (2026-11-02, ajuste `support.governance` de más abajo), para que la
-- compuerta de ingreso la alcance; con la fecha de la carga (now()) quedaba ANTERIOR y la compuerta no regía. Ana (K-04, caso 28) vence su recertificación el 2026-11-23
-- (04 la deja a 6 meses de la carga): el UPDATE de después del INSERT lo ajusta, con guarda, también en una base ya cargada.
-- Vínculos de apoyo con identidad verificada, incorporación, certificación y última actividad. Nora no tiene dueño ni incorporación terminada; Pablo no se usa hace 70 días.
INSERT INTO delegated_access.organization_user_assignments (id, tenant_membership_id, assignment_role_concept_id, access_scope_concept_id, supervisor_user_id, valid_from, status_concept_id, created_at, updated_at, row_version, origin_concept_id, owner_kind_concept_id, role_template_id, recertify_every_months, next_recertification_at, identity_verified_at, identity_verified_by_user_id, identity_method_concept_id, onboarding_completed_at, last_certified_at, last_active_at, tenant_id) VALUES
  ('234196e9-3644-5d09-85b0-b5fd9a474296', 'bcfc349c-0dce-547a-babd-51ef4e2ef708', '3a5bfde0-e0f3-570d-b5f4-68bcdbf23102', 'e49e9baa-f3b1-5011-83ee-d1e3017aed36', 'a9dd40bb-1eb5-5b58-ae2a-06896d8c2810', timestamptz '2026-10-01 08:00:00-04', '38a1d301-f40d-5b17-a695-5e6d605f8b19', now(), now(), 1, 'cdef8f46-a60e-5a84-97e3-37d5007e905d', '6397159b-1477-5551-9950-862b8b8ce122', 'ce7f96dd-6f85-5121-a4ca-f5b4877f7267', 6, timestamptz '2027-01-15 09:00:00-04', timestamptz '2026-10-01 09:00:00-04', 'a9dd40bb-1eb5-5b58-ae2a-06896d8c2810', 'e8273ad4-4e98-5dcb-869e-f34019625dbc', timestamptz '2026-11-02 09:00:00-04', timestamptz '2026-10-21 10:00:00-04', timestamptz '2026-11-03 08:40:00-04', '830e47e1-8e82-50ff-99c0-bfed0a7971a4'),
  ('398054f3-49c6-5ca4-b164-096e89c4b180', 'b9ece1b2-d191-57c3-a485-bda8e028787e', '3a5bfde0-e0f3-570d-b5f4-68bcdbf23102', 'e49e9baa-f3b1-5011-83ee-d1e3017aed36', 'a9dd40bb-1eb5-5b58-ae2a-06896d8c2810', timestamptz '2026-10-01 08:00:00-04', '38a1d301-f40d-5b17-a695-5e6d605f8b19', now(), now(), 1, 'cdef8f46-a60e-5a84-97e3-37d5007e905d', '6397159b-1477-5551-9950-862b8b8ce122', 'ce7f96dd-6f85-5121-a4ca-f5b4877f7267', 6, timestamptz '2027-01-15 09:00:00-04', timestamptz '2026-10-01 09:00:00-04', 'a9dd40bb-1eb5-5b58-ae2a-06896d8c2810', 'e8273ad4-4e98-5dcb-869e-f34019625dbc', timestamptz '2026-11-02 09:00:00-04', NULL, timestamptz '2026-11-03 09:10:00-04', '830e47e1-8e82-50ff-99c0-bfed0a7971a4'),
  ('c5300641-8cf5-537c-bae3-dd70c84bf465', '0775bcbb-412b-5280-a01a-8c1b642a91a3', '505006e8-310d-5cfc-9758-e2856958d9ab', 'e49e9baa-f3b1-5011-83ee-d1e3017aed36', 'a9dd40bb-1eb5-5b58-ae2a-06896d8c2810', timestamptz '2026-10-01 08:00:00-04', '38a1d301-f40d-5b17-a695-5e6d605f8b19', now(), now(), 1, '320e177a-bda6-543f-97e6-d6c30873db41', '6397159b-1477-5551-9950-862b8b8ce122', '0856c6ec-216d-5d47-9c24-4f62a46925ee', 6, timestamptz '2027-01-15 09:00:00-04', timestamptz '2026-10-01 09:00:00-04', 'a9dd40bb-1eb5-5b58-ae2a-06896d8c2810', 'e8273ad4-4e98-5dcb-869e-f34019625dbc', timestamptz '2026-11-02 09:30:00-04', timestamptz '2026-10-20 11:00:00-04', timestamptz '2026-11-03 08:05:00-04', '830e47e1-8e82-50ff-99c0-bfed0a7971a4'),
  ('de0204d4-f9d7-5394-8ba3-45e92b46b610', '8d99d949-0885-5612-9858-bdf311119fc0', '4afa11c6-c4ae-542a-8e47-b8b78d8c8aba', 'e49e9baa-f3b1-5011-83ee-d1e3017aed36', NULL, timestamptz '2026-10-01 08:00:00-04', '38a1d301-f40d-5b17-a695-5e6d605f8b19', timestamptz '2026-11-03 08:00:00-04', now(), 1, '320e177a-bda6-543f-97e6-d6c30873db41', '6397159b-1477-5551-9950-862b8b8ce122', 'bb877c7b-6e11-5d8c-a2dd-6b578c8eeb57', 12, timestamptz '2027-01-15 09:00:00-04', timestamptz '2026-10-01 09:00:00-04', 'a9dd40bb-1eb5-5b58-ae2a-06896d8c2810', 'e8273ad4-4e98-5dcb-869e-f34019625dbc', NULL, NULL, timestamptz '2026-11-03 07:50:00-04', '830e47e1-8e82-50ff-99c0-bfed0a7971a4'),
  ('ebe3a9a3-0191-59b1-b3b8-944579f95573', '440dd0e6-e129-58ec-ae03-c67256e7afd2', '2e3e235b-5144-5e08-9141-41a402e3bee1', 'e49e9baa-f3b1-5011-83ee-d1e3017aed36', '161a6e07-9098-52d4-82e9-d0485c5646a2', timestamptz '2026-10-01 08:00:00-04', '38a1d301-f40d-5b17-a695-5e6d605f8b19', now(), now(), 1, 'a36afaec-1203-5ec7-beb3-d1595e264929', '6397159b-1477-5551-9950-862b8b8ce122', 'da9a9ff5-16ec-55f0-a56a-44183573326a', 6, timestamptz '2027-01-15 09:00:00-04', timestamptz '2026-10-01 09:00:00-04', 'a9dd40bb-1eb5-5b58-ae2a-06896d8c2810', 'e8273ad4-4e98-5dcb-869e-f34019625dbc', timestamptz '2026-08-02 09:00:00-04', NULL, timestamptz '2026-08-25 17:00:00-04', '830e47e1-8e82-50ff-99c0-bfed0a7971a4')
ON CONFLICT DO NOTHING;

-- Bases cargadas con la versión anterior: Nora con el vínculo de la fecha de la carga (anterior a `onboardingRequiredSince`) y Ana a 6 meses. Cada UPDATE tiene su guarda
-- y se queda quieto si ya está corregido o si el vínculo cambió de verdad (Nora con la incorporación terminada; Ana ya recertificada por la API a otra fecha ≤ 2026-11-23).
UPDATE delegated_access.organization_user_assignments SET created_at = timestamptz '2026-11-03 08:00:00-04', updated_at = now()
 WHERE id = 'de0204d4-f9d7-5394-8ba3-45e92b46b610' AND onboarding_completed_at IS NULL AND created_at < timestamptz '2026-11-02 00:00:00Z';
UPDATE delegated_access.organization_user_assignments SET next_recertification_at = timestamptz '2026-11-23 10:00:00-04', updated_at = now()
 WHERE id = '9f1761b6-e456-5a99-bf11-d14b05077d4f' AND next_recertification_at > timestamptz '2026-11-23 10:00:00-04';

-- Dueños de cuenta del piloto base: Lucía Paz → Ricardo; Marcos → Sofía (la columna `supervisor_user_id` significa «dueño de la cuenta»).
UPDATE delegated_access.organization_user_assignments SET supervisor_user_id = '4631fd76-9c97-50a5-8273-30ff2579dce5', updated_at = now() WHERE id = 'f9e96f37-5a9a-5ccb-aaea-21b880985301' AND supervisor_user_id IS NULL;
UPDATE delegated_access.organization_user_assignments SET supervisor_user_id = '161a6e07-9098-52d4-82e9-d0485c5646a2', updated_at = now() WHERE id = 'c10fff7f-6b09-5a73-bec6-f96365eb2fb6' AND supervisor_user_id IS NULL;

-- Permisos nuevos (todos vigentes salvo el revocado por la campaña). Un permiso con efecto DENY NO es un permiso: no entra a effective_support_access.
INSERT INTO delegated_access.support_scope_grants (id, tenant_id, organization_user_assignment_id, target_kind_concept_id, practitioner_role_assignment_id, healthcare_service_id, care_space_id, practice_site_id, expansion_mode_concept_id, valid_from, status_concept_id, approved_by_user_id, created_at, updated_at, row_version, effect_concept_id, condition_json, condition_schema_version, reason_text, source_role_template_id) VALUES
  ('92d4bc87-c221-5c9e-8f71-08127a2ef789', '830e47e1-8e82-50ff-99c0-bfed0a7971a4', '234196e9-3644-5d09-85b0-b5fd9a474296', '953e4408-5e19-521b-a25a-3d062d788911', NULL, 'da47af6a-fc7a-5d56-93cb-7bbe45b26ce5', NULL, NULL, 'd9ed1dfe-f5e6-55f3-94f2-2bd60993a536', timestamptz '2026-10-01 08:00:00-04', 'ccfbc54f-4744-53db-ab1f-abe1af31f784', 'a9dd40bb-1eb5-5b58-ae2a-06896d8c2810', now(), now(), 1, '6905e0db-1650-5d49-adca-8b2688ac049c', '{"schemaVersion": 1, "time": {"timeZone": "America/La_Paz", "windows": [{"days": [1, 2, 3, 4, 5, 6], "from": "07:00", "to": "20:00"}]}}'::jsonb, 1, 'Jefatura del servicio', 'ce7f96dd-6f85-5121-a4ca-f5b4877f7267'),
  ('c3ba91f6-9a38-597b-ace6-c0c0366964b6', '830e47e1-8e82-50ff-99c0-bfed0a7971a4', '398054f3-49c6-5ca4-b164-096e89c4b180', '10510d38-c6cf-5243-9327-5cefc6c3aee5', NULL, NULL, 'a5b6c244-a0ce-56e2-9d76-cdb2f3f184c1', NULL, 'd9ed1dfe-f5e6-55f3-94f2-2bd60993a536', timestamptz '2026-10-01 08:00:00-04', 'ccfbc54f-4744-53db-ab1f-abe1af31f784', 'a9dd40bb-1eb5-5b58-ae2a-06896d8c2810', now(), now(), 1, '6905e0db-1650-5d49-adca-8b2688ac049c', '{"schemaVersion": 1, "time": {"timeZone": "America/La_Paz", "windows": [{"days": [1, 2, 3, 4, 5, 6], "from": "07:00", "to": "20:00"}]}}'::jsonb, 1, 'Jefatura del Piso 1 (Edificio A)', 'ce7f96dd-6f85-5121-a4ca-f5b4877f7267'),
  ('e610ee74-1e75-545c-8b01-013cd083afdc', '830e47e1-8e82-50ff-99c0-bfed0a7971a4', '398054f3-49c6-5ca4-b164-096e89c4b180', '10510d38-c6cf-5243-9327-5cefc6c3aee5', NULL, NULL, 'a5b6c244-a0ce-56e2-9d76-cdb2f3f184c1', NULL, 'd9ed1dfe-f5e6-55f3-94f2-2bd60993a536', timestamptz '2026-10-01 08:00:00-04', 'ccfbc54f-4744-53db-ab1f-abe1af31f784', 'a9dd40bb-1eb5-5b58-ae2a-06896d8c2810', now(), now(), 1, '6905e0db-1650-5d49-adca-8b2688ac049c', NULL, NULL, 'Cobra en el Piso 1 mientras no haya cajero (excepción SoD aprobada)', NULL),
  ('8ff87d73-8239-5762-8aec-0ca277f33282', '830e47e1-8e82-50ff-99c0-bfed0a7971a4', 'c5300641-8cf5-537c-bae3-dd70c84bf465', 'cf4de420-16da-57f8-8c3a-f6ff717fc59e', NULL, NULL, NULL, NULL, 'd9ed1dfe-f5e6-55f3-94f2-2bd60993a536', timestamptz '2026-10-01 08:00:00-04', 'ccfbc54f-4744-53db-ab1f-abe1af31f784', 'a9dd40bb-1eb5-5b58-ae2a-06896d8c2810', now(), now(), 1, '6905e0db-1650-5d49-adca-8b2688ac049c', '{"schemaVersion": 1, "time": {"windows": [{"days": [1, 2, 3, 4, 5, 6], "from": "08:00", "to": "20:00"}]}, "device": {"knownOnly": true}}'::jsonb, 1, 'Cajero del hospital', '0856c6ec-216d-5d47-9c24-4f62a46925ee'),
  ('bc90da67-5c44-5032-8153-a87a07216400', '830e47e1-8e82-50ff-99c0-bfed0a7971a4', 'de0204d4-f9d7-5394-8ba3-45e92b46b610', '785d1671-5754-58d3-b1a3-e3cd467b82b7', '223616d5-8cc4-5ea1-9e2e-5b971b001cad', NULL, NULL, NULL, 'd9ed1dfe-f5e6-55f3-94f2-2bd60993a536', timestamptz '2026-10-01 08:00:00-04', 'ccfbc54f-4744-53db-ab1f-abe1af31f784', 'a9dd40bb-1eb5-5b58-ae2a-06896d8c2810', now(), now(), 1, '6905e0db-1650-5d49-adca-8b2688ac049c', NULL, NULL, 'Enfermería de Internación', 'bb877c7b-6e11-5d8c-a2dd-6b578c8eeb57'),
  ('70331249-6ffe-5eca-a359-2261a740faae', '830e47e1-8e82-50ff-99c0-bfed0a7971a4', 'ebe3a9a3-0191-59b1-b3b8-944579f95573', '785d1671-5754-58d3-b1a3-e3cd467b82b7', 'f4e4d910-002f-5a42-a3fa-8696220f940b', NULL, NULL, NULL, 'd9ed1dfe-f5e6-55f3-94f2-2bd60993a536', timestamptz '2026-10-01 08:00:00-04', 'ccfbc54f-4744-53db-ab1f-abe1af31f784', 'a9dd40bb-1eb5-5b58-ae2a-06896d8c2810', now(), now(), 1, '6905e0db-1650-5d49-adca-8b2688ac049c', NULL, NULL, NULL, NULL),
  ('a5e5ca0b-9375-57ed-8c03-c2981d19d48e', '830e47e1-8e82-50ff-99c0-bfed0a7971a4', 'ebe3a9a3-0191-59b1-b3b8-944579f95573', '785d1671-5754-58d3-b1a3-e3cd467b82b7', '223616d5-8cc4-5ea1-9e2e-5b971b001cad', NULL, NULL, NULL, 'd9ed1dfe-f5e6-55f3-94f2-2bd60993a536', timestamptz '2026-10-01 08:00:00-04', 'ccfbc54f-4744-53db-ab1f-abe1af31f784', 'a9dd40bb-1eb5-5b58-ae2a-06896d8c2810', now(), now(), 1, '6905e0db-1650-5d49-adca-8b2688ac049c', NULL, NULL, NULL, NULL),
  ('21416f29-8a21-52b0-a1bf-62a268aea5b3', '830e47e1-8e82-50ff-99c0-bfed0a7971a4', 'f9e96f37-5a9a-5ccb-aaea-21b880985301', '953e4408-5e19-521b-a25a-3d062d788911', NULL, 'da47af6a-fc7a-5d56-93cb-7bbe45b26ce5', NULL, NULL, 'd9ed1dfe-f5e6-55f3-94f2-2bd60993a536', timestamptz '2026-10-01 08:00:00-04', '5cf6ef7d-3f5f-5864-93c8-eba9a9cd8af6', 'a9dd40bb-1eb5-5b58-ae2a-06896d8c2810', now(), now(), 1, '6905e0db-1650-5d49-adca-8b2688ac049c', NULL, NULL, 'Permiso temporal de apoyo en Ecografía (revocado en la campaña Q4-2026)', NULL),
  ('5c5a02e2-fb89-5d09-894e-b9903a5ff269', '830e47e1-8e82-50ff-99c0-bfed0a7971a4', '9f1761b6-e456-5a99-bf11-d14b05077d4f', '785d1671-5754-58d3-b1a3-e3cd467b82b7', 'c3e867d0-28d9-526d-bd16-71e4cdb285d2', NULL, NULL, NULL, 'd9ed1dfe-f5e6-55f3-94f2-2bd60993a536', timestamptz '2026-10-01 08:00:00-04', 'ccfbc54f-4744-53db-ab1f-abe1af31f784', 'a9dd40bb-1eb5-5b58-ae2a-06896d8c2810', now(), now(), 1, 'b038e546-a6ba-5848-9cd2-04b02ccb22b0', '{"schemaVersion": 1, "patients": {"flags": {"anyOf": ["CONFIDENTIAL"]}}}'::jsonb, 1, 'Negar el motivo de consulta de pacientes confidenciales de la Dra. Rojas', NULL)
ON CONFLICT DO NOTHING;

-- Acciones de cada permiso (átomos y, donde el piloto prueba compatibilidad, alias). Las filas nuevas de Ana×Rojas y Marcos×Suárez se SUMAN a las alias de 04.
INSERT INTO delegated_access.support_grant_actions (id, tenant_id, support_scope_grant_id, permission_id, created_at, condition_json, condition_schema_version) VALUES
  ('e16d4996-28a0-5d86-969f-d5278c365bb5', '830e47e1-8e82-50ff-99c0-bfed0a7971a4', '92d4bc87-c221-5c9e-8f71-08127a2ef789', 'efeeea20-52a5-5973-a94a-37793ded463a', now(), NULL, NULL),
  ('1e64832f-fedb-5a9d-8a8e-b9860e804652', '830e47e1-8e82-50ff-99c0-bfed0a7971a4', '92d4bc87-c221-5c9e-8f71-08127a2ef789', '44941499-4002-5836-bc41-561f86916a91', now(), NULL, NULL),
  ('1acfb01d-b86a-5f80-8c6b-36b277e80bf1', '830e47e1-8e82-50ff-99c0-bfed0a7971a4', '92d4bc87-c221-5c9e-8f71-08127a2ef789', 'dcb281d5-ade2-548e-a600-94049262bc99', now(), NULL, NULL),
  ('0f77ce7d-5e1c-5e97-ab6e-6e6c49f35240', '830e47e1-8e82-50ff-99c0-bfed0a7971a4', '92d4bc87-c221-5c9e-8f71-08127a2ef789', '672e888a-62f7-5dcb-98be-8a584c9c9e00', now(), NULL, NULL),
  ('5b1c9c1b-3a65-518c-a4ac-b0de406dcf0e', '830e47e1-8e82-50ff-99c0-bfed0a7971a4', '92d4bc87-c221-5c9e-8f71-08127a2ef789', '1c4a946d-8915-5423-b5f7-6708c207a3aa', now(), NULL, NULL),
  ('5b574be0-20e1-5887-ab6a-51da514b2f24', '830e47e1-8e82-50ff-99c0-bfed0a7971a4', '92d4bc87-c221-5c9e-8f71-08127a2ef789', 'f4782b09-e8a1-5922-935d-cfecc88d74f3', now(), NULL, NULL),
  ('68c20a19-9647-5c86-9cec-a26bc7eb0133', '830e47e1-8e82-50ff-99c0-bfed0a7971a4', '92d4bc87-c221-5c9e-8f71-08127a2ef789', '3acf14a6-7c28-528b-9db3-6e9c50b99739', now(), NULL, NULL),
  ('bb221d22-6ce5-5ade-875e-1fa6717d0877', '830e47e1-8e82-50ff-99c0-bfed0a7971a4', '92d4bc87-c221-5c9e-8f71-08127a2ef789', '662896ab-39d9-5fa6-9200-d6fa6fdd1447', now(), NULL, NULL),
  ('4e2136f6-bd02-59f3-8264-1169afe59a69', '830e47e1-8e82-50ff-99c0-bfed0a7971a4', '92d4bc87-c221-5c9e-8f71-08127a2ef789', '04e3b714-1b35-540d-b93b-2908e8a8d068', now(), NULL, NULL),
  ('5271b0a1-d896-518d-81a5-5eb66bcb92c0', '830e47e1-8e82-50ff-99c0-bfed0a7971a4', '92d4bc87-c221-5c9e-8f71-08127a2ef789', 'cfac3bbb-b59d-5aa0-9b51-4d09bf5f538a', now(), NULL, NULL),
  ('23f03998-48fc-5acf-97e2-17c37b35e38e', '830e47e1-8e82-50ff-99c0-bfed0a7971a4', '92d4bc87-c221-5c9e-8f71-08127a2ef789', 'e743048f-b7bd-586f-bb3b-b3b47ef4bcf5', now(), NULL, NULL),
  ('3081224d-aa52-55fc-847c-632e763ba608', '830e47e1-8e82-50ff-99c0-bfed0a7971a4', '92d4bc87-c221-5c9e-8f71-08127a2ef789', '39aa19d5-1fc5-552d-84b8-d23f281dc849', now(), NULL, NULL),
  ('8a7bdd68-2a73-56a2-a19c-1d6addf961bf', '830e47e1-8e82-50ff-99c0-bfed0a7971a4', '92d4bc87-c221-5c9e-8f71-08127a2ef789', '378f04dc-abf9-5a86-86c4-3a8447790644', now(), NULL, NULL),
  ('0ed15ad0-43ad-5bdd-89ec-38809a5b6183', '830e47e1-8e82-50ff-99c0-bfed0a7971a4', '92d4bc87-c221-5c9e-8f71-08127a2ef789', '53a5479b-dd19-51c4-802b-7359cd8be359', now(), NULL, NULL),
  ('858f48c4-b9cd-5ad8-9a7f-1250d657bab1', '830e47e1-8e82-50ff-99c0-bfed0a7971a4', '92d4bc87-c221-5c9e-8f71-08127a2ef789', 'a1303ccf-446c-527a-b30b-c8e08b77f4b1', now(), NULL, NULL),
  ('f7c69699-10cc-5338-92c7-67d062ce716f', '830e47e1-8e82-50ff-99c0-bfed0a7971a4', '92d4bc87-c221-5c9e-8f71-08127a2ef789', 'b88c1279-bdf5-5c9c-be82-79702a9df31c', now(), NULL, NULL),
  ('78707945-2442-5c1c-a6c6-0052e933eea8', '830e47e1-8e82-50ff-99c0-bfed0a7971a4', '92d4bc87-c221-5c9e-8f71-08127a2ef789', '4833c0f0-16d0-5a8d-a440-c6bcbbe10527', now(), NULL, NULL),
  ('5091e7b1-93b7-50c2-9c07-04da7c188e5c', '830e47e1-8e82-50ff-99c0-bfed0a7971a4', '92d4bc87-c221-5c9e-8f71-08127a2ef789', 'e7c33743-ba81-58d9-a2e1-d94db64e7ce7', now(), NULL, NULL),
  ('63eef98d-5ae3-5ab9-81c9-abcdee7d7ddc', '830e47e1-8e82-50ff-99c0-bfed0a7971a4', '92d4bc87-c221-5c9e-8f71-08127a2ef789', '0f600fde-de44-5b9c-9dd2-120c7913f4ea', now(), NULL, NULL),
  ('cfa498e6-0e47-588e-acc0-5ded10332d16', '830e47e1-8e82-50ff-99c0-bfed0a7971a4', '92d4bc87-c221-5c9e-8f71-08127a2ef789', 'd293bde0-9b2d-5650-b0b6-7ac2f3bc230f', now(), NULL, NULL),
  ('1dc9d8b1-7d8d-5ded-b4f2-2574028d0da9', '830e47e1-8e82-50ff-99c0-bfed0a7971a4', '92d4bc87-c221-5c9e-8f71-08127a2ef789', '3e298c9e-5e8e-58ad-b1d1-4aa176ba6235', now(), NULL, NULL),
  ('baf4aae6-b0e8-5693-9452-fc2f6a3b49ea', '830e47e1-8e82-50ff-99c0-bfed0a7971a4', '92d4bc87-c221-5c9e-8f71-08127a2ef789', '9619ea42-4bb9-52cc-b7a3-7f5ec23a5439', now(), '{"schemaVersion": 1, "delegationCeiling": {"allowAtoms": ["agenda.*", "patients.search.exact", "patients.profile.view_basic", "messages.inbox.view", "messages.conversation.reply_on_behalf", "messages.template.use"], "templates": ["SECRETARY", "MEDICAL_ASSISTANT", "NURSING", "FRONT_DESK", "CALL_CENTER"], "maxValidDays": 180}}'::jsonb, 1),
  ('f9f9d691-fff6-5c93-8f17-e9d727257ee2', '830e47e1-8e82-50ff-99c0-bfed0a7971a4', '92d4bc87-c221-5c9e-8f71-08127a2ef789', '61db4521-3e45-5210-9113-21282d3209f3', now(), NULL, NULL),
  ('e351aeea-46ef-59f0-b92d-d24fbed8270b', '830e47e1-8e82-50ff-99c0-bfed0a7971a4', '92d4bc87-c221-5c9e-8f71-08127a2ef789', 'd545b48b-53cf-5d15-918a-42a53d3ecc78', now(), NULL, NULL),
  ('8ba678bd-a788-5dda-b901-ddeaf0c73419', '830e47e1-8e82-50ff-99c0-bfed0a7971a4', '92d4bc87-c221-5c9e-8f71-08127a2ef789', '35b0e156-afca-54bd-8858-0ec806f3da35', now(), NULL, NULL),
  ('d8b7b468-8796-5b3d-b9c2-a408b4bce106', '830e47e1-8e82-50ff-99c0-bfed0a7971a4', '92d4bc87-c221-5c9e-8f71-08127a2ef789', '8b2722fe-b1e5-57ac-8fb9-ad7f6ec75def', now(), NULL, NULL),
  ('792cac96-4d70-54de-84f4-8f2779dccce1', '830e47e1-8e82-50ff-99c0-bfed0a7971a4', '92d4bc87-c221-5c9e-8f71-08127a2ef789', '15292618-2c42-52d0-b01d-d56c78bd680a', now(), NULL, NULL),
  ('d2a1cc9b-c2f5-55d6-8957-001283cf8263', '830e47e1-8e82-50ff-99c0-bfed0a7971a4', '92d4bc87-c221-5c9e-8f71-08127a2ef789', 'fbe1d36f-310d-557c-b014-5d81414351ca', now(), NULL, NULL),
  ('08965d77-fb2a-5226-a771-70755f9cf218', '830e47e1-8e82-50ff-99c0-bfed0a7971a4', '92d4bc87-c221-5c9e-8f71-08127a2ef789', '9bc38d0f-a05f-5b36-a1f0-6b3f79ca89ad', now(), NULL, NULL),
  ('3d26ef3d-edc6-570d-8bcd-6e06d8854f88', '830e47e1-8e82-50ff-99c0-bfed0a7971a4', 'c3ba91f6-9a38-597b-ace6-c0c0366964b6', 'efeeea20-52a5-5973-a94a-37793ded463a', now(), NULL, NULL),
  ('4df222ab-d47f-5907-a6fb-2a467c2c90ad', '830e47e1-8e82-50ff-99c0-bfed0a7971a4', 'c3ba91f6-9a38-597b-ace6-c0c0366964b6', '44941499-4002-5836-bc41-561f86916a91', now(), NULL, NULL),
  ('ba3eb2c1-ce97-5015-b3ee-0706ebbd326e', '830e47e1-8e82-50ff-99c0-bfed0a7971a4', 'c3ba91f6-9a38-597b-ace6-c0c0366964b6', 'dcb281d5-ade2-548e-a600-94049262bc99', now(), NULL, NULL),
  ('7bc8a305-65a5-5ba5-b1a4-2d48c3b55fa2', '830e47e1-8e82-50ff-99c0-bfed0a7971a4', 'c3ba91f6-9a38-597b-ace6-c0c0366964b6', '672e888a-62f7-5dcb-98be-8a584c9c9e00', now(), NULL, NULL),
  ('cadd0982-3a3d-51b5-8c87-8a47cd8a7bb5', '830e47e1-8e82-50ff-99c0-bfed0a7971a4', 'c3ba91f6-9a38-597b-ace6-c0c0366964b6', '1c4a946d-8915-5423-b5f7-6708c207a3aa', now(), NULL, NULL),
  ('6157d244-4716-52b9-9873-cac8ff1ec622', '830e47e1-8e82-50ff-99c0-bfed0a7971a4', 'c3ba91f6-9a38-597b-ace6-c0c0366964b6', 'f4782b09-e8a1-5922-935d-cfecc88d74f3', now(), NULL, NULL),
  ('13c3cfd1-c1c3-5089-997e-34a110d28e78', '830e47e1-8e82-50ff-99c0-bfed0a7971a4', 'c3ba91f6-9a38-597b-ace6-c0c0366964b6', '3acf14a6-7c28-528b-9db3-6e9c50b99739', now(), NULL, NULL),
  ('5c66e64f-4bff-5e32-88de-4a75e0c6feb3', '830e47e1-8e82-50ff-99c0-bfed0a7971a4', 'c3ba91f6-9a38-597b-ace6-c0c0366964b6', '662896ab-39d9-5fa6-9200-d6fa6fdd1447', now(), NULL, NULL),
  ('8bf43fba-df69-5b8e-a768-9a5ab7ac0267', '830e47e1-8e82-50ff-99c0-bfed0a7971a4', 'c3ba91f6-9a38-597b-ace6-c0c0366964b6', '04e3b714-1b35-540d-b93b-2908e8a8d068', now(), NULL, NULL),
  ('5eea6d39-03f8-509d-bc1c-ffbe1a1cece5', '830e47e1-8e82-50ff-99c0-bfed0a7971a4', 'c3ba91f6-9a38-597b-ace6-c0c0366964b6', 'cfac3bbb-b59d-5aa0-9b51-4d09bf5f538a', now(), NULL, NULL),
  ('b0585953-f587-5dce-b97d-3ba42724ea4a', '830e47e1-8e82-50ff-99c0-bfed0a7971a4', 'c3ba91f6-9a38-597b-ace6-c0c0366964b6', 'e743048f-b7bd-586f-bb3b-b3b47ef4bcf5', now(), NULL, NULL),
  ('03de698f-a70d-5f93-9605-0de51026804b', '830e47e1-8e82-50ff-99c0-bfed0a7971a4', 'c3ba91f6-9a38-597b-ace6-c0c0366964b6', '39aa19d5-1fc5-552d-84b8-d23f281dc849', now(), NULL, NULL),
  ('e355f36a-21b3-5d8f-bfe5-d38a701e0334', '830e47e1-8e82-50ff-99c0-bfed0a7971a4', 'c3ba91f6-9a38-597b-ace6-c0c0366964b6', '378f04dc-abf9-5a86-86c4-3a8447790644', now(), NULL, NULL),
  ('91e73c48-a876-5cae-aa12-a7f2797d7d1a', '830e47e1-8e82-50ff-99c0-bfed0a7971a4', 'c3ba91f6-9a38-597b-ace6-c0c0366964b6', '53a5479b-dd19-51c4-802b-7359cd8be359', now(), NULL, NULL),
  ('3f19047f-8c7b-5650-9e4c-9d3cb539212d', '830e47e1-8e82-50ff-99c0-bfed0a7971a4', 'c3ba91f6-9a38-597b-ace6-c0c0366964b6', 'a1303ccf-446c-527a-b30b-c8e08b77f4b1', now(), NULL, NULL),
  ('318f82f4-037e-5cb4-baf2-53a19ae17ff8', '830e47e1-8e82-50ff-99c0-bfed0a7971a4', 'c3ba91f6-9a38-597b-ace6-c0c0366964b6', 'b88c1279-bdf5-5c9c-be82-79702a9df31c', now(), NULL, NULL),
  ('f726de41-a7dd-5677-b3d4-5a7ed95b7b96', '830e47e1-8e82-50ff-99c0-bfed0a7971a4', 'c3ba91f6-9a38-597b-ace6-c0c0366964b6', '4833c0f0-16d0-5a8d-a440-c6bcbbe10527', now(), NULL, NULL),
  ('51e6dfa7-bfd4-57c7-b3eb-459ca595b4a9', '830e47e1-8e82-50ff-99c0-bfed0a7971a4', 'c3ba91f6-9a38-597b-ace6-c0c0366964b6', 'e7c33743-ba81-58d9-a2e1-d94db64e7ce7', now(), NULL, NULL),
  ('b155f5de-6f83-5a22-93f9-2e00d6801aaa', '830e47e1-8e82-50ff-99c0-bfed0a7971a4', 'c3ba91f6-9a38-597b-ace6-c0c0366964b6', '0f600fde-de44-5b9c-9dd2-120c7913f4ea', now(), NULL, NULL),
  ('22c70cab-5f16-51b5-999c-e488c6294535', '830e47e1-8e82-50ff-99c0-bfed0a7971a4', 'c3ba91f6-9a38-597b-ace6-c0c0366964b6', 'd293bde0-9b2d-5650-b0b6-7ac2f3bc230f', now(), NULL, NULL),
  ('53c17d37-f110-51b1-9704-3ca16b304117', '830e47e1-8e82-50ff-99c0-bfed0a7971a4', 'c3ba91f6-9a38-597b-ace6-c0c0366964b6', '3e298c9e-5e8e-58ad-b1d1-4aa176ba6235', now(), NULL, NULL),
  ('fc966d85-4edc-5987-875e-5615da800821', '830e47e1-8e82-50ff-99c0-bfed0a7971a4', 'c3ba91f6-9a38-597b-ace6-c0c0366964b6', '9619ea42-4bb9-52cc-b7a3-7f5ec23a5439', now(), '{"schemaVersion": 1, "delegationCeiling": {"allowAtoms": ["agenda.*", "patients.search.exact", "patients.profile.view_basic", "messages.inbox.view", "messages.conversation.reply_on_behalf", "messages.template.use"], "templates": ["SECRETARY", "MEDICAL_ASSISTANT", "NURSING", "FRONT_DESK", "CALL_CENTER"], "maxValidDays": 180}}'::jsonb, 1),
  ('2e71199f-796e-5996-b4d9-2687684d7b71', '830e47e1-8e82-50ff-99c0-bfed0a7971a4', 'c3ba91f6-9a38-597b-ace6-c0c0366964b6', '61db4521-3e45-5210-9113-21282d3209f3', now(), NULL, NULL),
  ('8d1ce5bc-76a8-56c7-885e-86a7e11d3dcc', '830e47e1-8e82-50ff-99c0-bfed0a7971a4', 'c3ba91f6-9a38-597b-ace6-c0c0366964b6', 'd545b48b-53cf-5d15-918a-42a53d3ecc78', now(), NULL, NULL),
  ('41152b78-5cb1-5359-8127-62a84a2834ee', '830e47e1-8e82-50ff-99c0-bfed0a7971a4', 'c3ba91f6-9a38-597b-ace6-c0c0366964b6', '35b0e156-afca-54bd-8858-0ec806f3da35', now(), NULL, NULL),
  ('93563549-8bfa-55ca-8c57-9c517badb5cc', '830e47e1-8e82-50ff-99c0-bfed0a7971a4', 'c3ba91f6-9a38-597b-ace6-c0c0366964b6', '8b2722fe-b1e5-57ac-8fb9-ad7f6ec75def', now(), NULL, NULL),
  ('302f50f4-a533-59ab-9898-51145112f546', '830e47e1-8e82-50ff-99c0-bfed0a7971a4', 'c3ba91f6-9a38-597b-ace6-c0c0366964b6', '15292618-2c42-52d0-b01d-d56c78bd680a', now(), NULL, NULL),
  ('df9f229a-3698-5fc9-aa36-09c2477fc040', '830e47e1-8e82-50ff-99c0-bfed0a7971a4', 'c3ba91f6-9a38-597b-ace6-c0c0366964b6', 'fbe1d36f-310d-557c-b014-5d81414351ca', now(), NULL, NULL),
  ('22732b55-e95e-51b7-b706-71383d9bc31f', '830e47e1-8e82-50ff-99c0-bfed0a7971a4', 'c3ba91f6-9a38-597b-ace6-c0c0366964b6', '9bc38d0f-a05f-5b36-a1f0-6b3f79ca89ad', now(), NULL, NULL),
  ('1a0032d2-9415-59d4-9562-0a1817939c19', '830e47e1-8e82-50ff-99c0-bfed0a7971a4', 'e610ee74-1e75-545c-8b01-013cd083afdc', '72274a1f-c418-5bc6-95a8-374531b64fef', now(), NULL, NULL),
  ('85aa4cfb-7671-533f-aec2-e73840e2f38a', '830e47e1-8e82-50ff-99c0-bfed0a7971a4', '8ff87d73-8239-5762-8aec-0ca277f33282', 'efeeea20-52a5-5973-a94a-37793ded463a', now(), NULL, NULL),
  ('892ae5be-269a-5168-9cfa-84b825ae819f', '830e47e1-8e82-50ff-99c0-bfed0a7971a4', '8ff87d73-8239-5762-8aec-0ca277f33282', '44941499-4002-5836-bc41-561f86916a91', now(), NULL, NULL),
  ('0579035d-1c11-5971-a0c2-10a518762dbd', '830e47e1-8e82-50ff-99c0-bfed0a7971a4', '8ff87d73-8239-5762-8aec-0ca277f33282', 'f16aed56-f135-5b2e-8538-a4b48b22b351', now(), NULL, NULL),
  ('08fb14b2-486d-54e1-a0ad-2f796ef5ed14', '830e47e1-8e82-50ff-99c0-bfed0a7971a4', '8ff87d73-8239-5762-8aec-0ca277f33282', '72274a1f-c418-5bc6-95a8-374531b64fef', now(), '{"schemaVersion": 1, "amount": {"currency": "BOB", "perTransactionMax": 2000, "perDayMax": 20000, "onExceed": "REQUIRE_APPROVAL"}}'::jsonb, 1),
  ('d1b7b4e7-080f-5413-8eca-7441ff836b15', '830e47e1-8e82-50ff-99c0-bfed0a7971a4', '8ff87d73-8239-5762-8aec-0ca277f33282', 'c8887db8-1bf5-5a9f-974d-75eca68d28d7', now(), NULL, NULL),
  ('2ff8714b-4e3a-5d1a-a391-0203685c9fe7', '830e47e1-8e82-50ff-99c0-bfed0a7971a4', 'bc90da67-5c44-5032-8153-a87a07216400', 'efeeea20-52a5-5973-a94a-37793ded463a', now(), NULL, NULL),
  ('cc96c1f7-b8c7-5d23-b5ce-edebbecad5c2', '830e47e1-8e82-50ff-99c0-bfed0a7971a4', 'bc90da67-5c44-5032-8153-a87a07216400', '44941499-4002-5836-bc41-561f86916a91', now(), NULL, NULL),
  ('cd7c3a43-d022-54d9-9f13-4fe01ea6ee11', '830e47e1-8e82-50ff-99c0-bfed0a7971a4', 'bc90da67-5c44-5032-8153-a87a07216400', '5ed80082-4016-52bc-912d-19b2a6ad9ea4', now(), '{"schemaVersion": 1, "patients": {"scope": "WITH_APPOINTMENT_WINDOW", "appointmentWindow": {"daysBefore": 0, "daysAfter": 0, "withCoveredDoctor": true}}, "fields": {"agenda.appointment.view.reason": {"mask": "PARTIAL"}}}'::jsonb, 1),
  ('e0a59854-92cf-5a38-9be6-c838d6e31020', '830e47e1-8e82-50ff-99c0-bfed0a7971a4', 'bc90da67-5c44-5032-8153-a87a07216400', '3acf14a6-7c28-528b-9db3-6e9c50b99739', now(), NULL, NULL),
  ('1756bc87-2dbe-5af7-9319-452b1cbffadf', '830e47e1-8e82-50ff-99c0-bfed0a7971a4', 'bc90da67-5c44-5032-8153-a87a07216400', '04e3b714-1b35-540d-b93b-2908e8a8d068', now(), NULL, NULL),
  ('cf027924-7fb7-54d6-9080-1e4788bec51c', '830e47e1-8e82-50ff-99c0-bfed0a7971a4', 'bc90da67-5c44-5032-8153-a87a07216400', '53a5479b-dd19-51c4-802b-7359cd8be359', now(), NULL, NULL),
  ('ac5dc34b-88a7-5c2a-8502-062e13d58b9a', '830e47e1-8e82-50ff-99c0-bfed0a7971a4', 'bc90da67-5c44-5032-8153-a87a07216400', 'a1303ccf-446c-527a-b30b-c8e08b77f4b1', now(), NULL, NULL),
  ('bd986cda-e6e0-5b48-83cf-2dd97f98adeb', '830e47e1-8e82-50ff-99c0-bfed0a7971a4', '70331249-6ffe-5eca-a359-2261a740faae', '438c578b-e5ea-5c58-86ed-fcf7da71780e', now(), NULL, NULL),
  ('f6bcd022-58c5-52f8-adb6-c2c120f5c028', '830e47e1-8e82-50ff-99c0-bfed0a7971a4', '70331249-6ffe-5eca-a359-2261a740faae', '7c5a3eeb-ac26-5d5e-a7b0-993955c63a2e', now(), NULL, NULL),
  ('3bc70fdc-f954-55a0-9cf8-20020d1038dc', '830e47e1-8e82-50ff-99c0-bfed0a7971a4', '70331249-6ffe-5eca-a359-2261a740faae', '9246c74e-5181-5a6b-b070-a8eef9887948', now(), NULL, NULL),
  ('c661c6b6-e664-555c-8b7e-6201ecc03405', '830e47e1-8e82-50ff-99c0-bfed0a7971a4', '70331249-6ffe-5eca-a359-2261a740faae', 'cd48f1e6-f8ed-5aba-bfbd-aec1829312ab', now(), NULL, NULL),
  ('e301e5e1-9cd2-5bab-b727-0129e3ffe1b0', '830e47e1-8e82-50ff-99c0-bfed0a7971a4', 'a5e5ca0b-9375-57ed-8c03-c2981d19d48e', '438c578b-e5ea-5c58-86ed-fcf7da71780e', now(), NULL, NULL),
  ('7566d287-28e0-56eb-b818-776d7e8b5c1b', '830e47e1-8e82-50ff-99c0-bfed0a7971a4', 'a5e5ca0b-9375-57ed-8c03-c2981d19d48e', '7c5a3eeb-ac26-5d5e-a7b0-993955c63a2e', now(), NULL, NULL),
  ('a9666757-8a52-52f0-b751-2302c1d653ce', '830e47e1-8e82-50ff-99c0-bfed0a7971a4', 'a5e5ca0b-9375-57ed-8c03-c2981d19d48e', '9246c74e-5181-5a6b-b070-a8eef9887948', now(), NULL, NULL),
  ('9f0a2b69-3202-556e-b044-6e6a2e2f958d', '830e47e1-8e82-50ff-99c0-bfed0a7971a4', 'a5e5ca0b-9375-57ed-8c03-c2981d19d48e', 'cd48f1e6-f8ed-5aba-bfbd-aec1829312ab', now(), NULL, NULL),
  ('edc78aad-c060-5e49-a5e1-444342792402', '830e47e1-8e82-50ff-99c0-bfed0a7971a4', '21416f29-8a21-52b0-a1bf-62a268aea5b3', '438c578b-e5ea-5c58-86ed-fcf7da71780e', now(), NULL, NULL),
  ('062d3b21-47b5-5dae-bc7a-8977291325ab', '830e47e1-8e82-50ff-99c0-bfed0a7971a4', '5c5a02e2-fb89-5d09-894e-b9903a5ff269', '5ed80082-4016-52bc-912d-19b2a6ad9ea4', now(), NULL, NULL),
  ('ce38d702-a159-5f58-81b2-4bcdfbaf8508', '830e47e1-8e82-50ff-99c0-bfed0a7971a4', '552db38b-e6ef-5b1b-9e4f-fd354ab57b8f', 'efeeea20-52a5-5973-a94a-37793ded463a', now(), NULL, NULL),
  ('06af8422-c555-5521-ac7f-53b64e6cb57c', '830e47e1-8e82-50ff-99c0-bfed0a7971a4', '552db38b-e6ef-5b1b-9e4f-fd354ab57b8f', '44941499-4002-5836-bc41-561f86916a91', now(), NULL, NULL),
  ('2e04a42a-ca03-5bdb-ba87-86d7ecd3b6f5', '830e47e1-8e82-50ff-99c0-bfed0a7971a4', '552db38b-e6ef-5b1b-9e4f-fd354ab57b8f', '5ed80082-4016-52bc-912d-19b2a6ad9ea4', now(), '{"schemaVersion": 1, "appointment": {"window": {"daysBefore": 1, "daysAfter": 14}}, "fields": {"agenda.appointment.view.reason": {"mask": "PARTIAL"}}}'::jsonb, 1),
  ('55e914b4-ef1d-5ca2-899c-363f91e34b23', '830e47e1-8e82-50ff-99c0-bfed0a7971a4', '552db38b-e6ef-5b1b-9e4f-fd354ab57b8f', 'dcb281d5-ade2-548e-a600-94049262bc99', now(), NULL, NULL),
  ('2331f4ea-d3d1-552e-8c41-397699184181', '830e47e1-8e82-50ff-99c0-bfed0a7971a4', '552db38b-e6ef-5b1b-9e4f-fd354ab57b8f', '672e888a-62f7-5dcb-98be-8a584c9c9e00', now(), NULL, NULL),
  ('3aac159f-45fb-5957-a6f5-014df8e07359', '830e47e1-8e82-50ff-99c0-bfed0a7971a4', '552db38b-e6ef-5b1b-9e4f-fd354ab57b8f', '1c4a946d-8915-5423-b5f7-6708c207a3aa', now(), '{"schemaVersion": 1, "appointment": {"leadTime": {"minHours": 24, "onViolation": "REQUIRE_APPROVAL"}}, "limits": [{"metric": "ACTIONS", "per": "DAY", "max": 20, "onExceed": "DENY"}], "patients": {"exclude": {"flags": ["VIP", "CONFIDENTIAL"]}}}'::jsonb, 1),
  ('53a95cc2-ad61-5a8b-8a57-2bd105a05616', '830e47e1-8e82-50ff-99c0-bfed0a7971a4', '552db38b-e6ef-5b1b-9e4f-fd354ab57b8f', 'f4782b09-e8a1-5922-935d-cfecc88d74f3', now(), NULL, NULL),
  ('975af513-5084-56a5-9ec6-3d17255e115e', '830e47e1-8e82-50ff-99c0-bfed0a7971a4', '552db38b-e6ef-5b1b-9e4f-fd354ab57b8f', '3acf14a6-7c28-528b-9db3-6e9c50b99739', now(), NULL, NULL),
  ('c0033fa6-94c2-5977-800e-79de1b392be4', '830e47e1-8e82-50ff-99c0-bfed0a7971a4', '552db38b-e6ef-5b1b-9e4f-fd354ab57b8f', '662896ab-39d9-5fa6-9200-d6fa6fdd1447', now(), NULL, NULL),
  ('0b78056d-512d-5cb8-903c-6c5a3d2e10bc', '830e47e1-8e82-50ff-99c0-bfed0a7971a4', '552db38b-e6ef-5b1b-9e4f-fd354ab57b8f', '04e3b714-1b35-540d-b93b-2908e8a8d068', now(), NULL, NULL),
  ('83777f32-dba3-5bb4-b012-605d8ee4fdd2', '830e47e1-8e82-50ff-99c0-bfed0a7971a4', '552db38b-e6ef-5b1b-9e4f-fd354ab57b8f', 'cfac3bbb-b59d-5aa0-9b51-4d09bf5f538a', now(), NULL, NULL),
  ('ebae1ef6-117e-580f-9f9e-e4397d98b95a', '830e47e1-8e82-50ff-99c0-bfed0a7971a4', '552db38b-e6ef-5b1b-9e4f-fd354ab57b8f', '53a5479b-dd19-51c4-802b-7359cd8be359', now(), NULL, NULL),
  ('c7305052-f3f2-59f8-a4b3-7a67a850c520', '830e47e1-8e82-50ff-99c0-bfed0a7971a4', '552db38b-e6ef-5b1b-9e4f-fd354ab57b8f', 'a1303ccf-446c-527a-b30b-c8e08b77f4b1', now(), NULL, NULL),
  ('8ec356fb-4a82-593a-b8ce-58b2d295be27', '830e47e1-8e82-50ff-99c0-bfed0a7971a4', '552db38b-e6ef-5b1b-9e4f-fd354ab57b8f', 'b88c1279-bdf5-5c9c-be82-79702a9df31c', now(), NULL, NULL),
  ('1297d619-1141-5bb7-af01-9e9e791f260a', '830e47e1-8e82-50ff-99c0-bfed0a7971a4', '552db38b-e6ef-5b1b-9e4f-fd354ab57b8f', '4833c0f0-16d0-5a8d-a440-c6bcbbe10527', now(), NULL, NULL),
  ('2362d63b-9dd4-51f9-ae65-518503111dab', '830e47e1-8e82-50ff-99c0-bfed0a7971a4', '552db38b-e6ef-5b1b-9e4f-fd354ab57b8f', '42d19611-205f-5380-b51c-b55738727905', now(), NULL, NULL),
  ('b2cff58f-3bc7-5187-a09d-28ffe9bc44ce', '830e47e1-8e82-50ff-99c0-bfed0a7971a4', '552db38b-e6ef-5b1b-9e4f-fd354ab57b8f', '6b674c45-b9ea-58a2-aaac-deb008d63569', now(), NULL, NULL),
  ('c55cfd95-8b8c-5d03-be89-175c62801fe4', '830e47e1-8e82-50ff-99c0-bfed0a7971a4', '552db38b-e6ef-5b1b-9e4f-fd354ab57b8f', '7a76a3cc-8b12-5015-840e-bdca9a2caa6b', now(), NULL, NULL),
  ('7518d487-59b0-5adb-8f0d-b0ccbffb8ed4', '830e47e1-8e82-50ff-99c0-bfed0a7971a4', '552db38b-e6ef-5b1b-9e4f-fd354ab57b8f', '5ee0247f-139d-57e1-b662-9584cba0310b', now(), NULL, NULL),
  ('5184653a-f290-57c6-ac2b-b90c422b06c3', '830e47e1-8e82-50ff-99c0-bfed0a7971a4', '552db38b-e6ef-5b1b-9e4f-fd354ab57b8f', '36c0f0da-72de-5fc2-9649-07d42c69f134', now(), NULL, NULL),
  ('5f7166f1-95ca-56eb-aa70-fbbd19396882', '830e47e1-8e82-50ff-99c0-bfed0a7971a4', '2af9f387-d337-5ea7-bedf-716967fd740d', 'efeeea20-52a5-5973-a94a-37793ded463a', now(), NULL, NULL),
  ('bc495298-aaa9-51b3-b5f7-31c8118cdb11', '830e47e1-8e82-50ff-99c0-bfed0a7971a4', '2af9f387-d337-5ea7-bedf-716967fd740d', '44941499-4002-5836-bc41-561f86916a91', now(), NULL, NULL),
  ('684f75b3-7f3d-56e5-9dd5-59f7c74cfd11', '830e47e1-8e82-50ff-99c0-bfed0a7971a4', '2af9f387-d337-5ea7-bedf-716967fd740d', 'dcb281d5-ade2-548e-a600-94049262bc99', now(), NULL, NULL),
  ('f718ccc9-92f5-5ca5-9e70-9421062a425f', '830e47e1-8e82-50ff-99c0-bfed0a7971a4', '2af9f387-d337-5ea7-bedf-716967fd740d', '672e888a-62f7-5dcb-98be-8a584c9c9e00', now(), NULL, NULL),
  ('a64cf59d-f24a-5039-b390-69775ac64703', '830e47e1-8e82-50ff-99c0-bfed0a7971a4', '2af9f387-d337-5ea7-bedf-716967fd740d', '1c4a946d-8915-5423-b5f7-6708c207a3aa', now(), '{"schemaVersion": 1, "appointment": {"leadTime": {"minHours": 24, "onViolation": "REQUIRE_APPROVAL"}}, "limits": [{"metric": "ACTIONS", "per": "DAY", "max": 20, "onExceed": "DENY"}]}'::jsonb, 1),
  ('c29e1811-e77c-5b02-9316-e5d72fe5d132', '830e47e1-8e82-50ff-99c0-bfed0a7971a4', '2af9f387-d337-5ea7-bedf-716967fd740d', '53a5479b-dd19-51c4-802b-7359cd8be359', now(), NULL, NULL),
  ('335da0c4-850f-5601-bb06-a570759caade', '830e47e1-8e82-50ff-99c0-bfed0a7971a4', '2af9f387-d337-5ea7-bedf-716967fd740d', 'a1303ccf-446c-527a-b30b-c8e08b77f4b1', now(), NULL, NULL)
ON CONFLICT DO NOTHING;

-- Condiciones de nivel de permiso de Ana×Rojas (horario y red de la organización) y su plantilla de origen: solo si todavía no las tiene.
UPDATE delegated_access.support_scope_grants SET condition_json = '{"schemaVersion": 1, "time": {"timeZone": "America/La_Paz", "windows": [{"days": [1, 2, 3, 4, 5], "from": "07:30", "to": "18:30"}]}, "network": {"require": "ORG_RULES"}}'::jsonb, condition_schema_version = 1, source_role_template_id = '473b58e0-2a4f-5985-98eb-6d5fcc513a23', reason_text = 'Paquete v2 de secretaría con condiciones (piloto de gobierno)', updated_at = now() WHERE id = '552db38b-e6ef-5b1b-9e4f-fd354ab57b8f' AND condition_json IS NULL;
UPDATE delegated_access.support_scope_grants SET source_role_template_id = '8c162d64-2b36-57b4-94c7-c034d6c3b26c', reason_text = 'Paquete v2 de central telefónica con cancelación condicionada (piloto de gobierno)', updated_at = now() WHERE id = '2af9f387-d337-5ea7-bedf-716967fd740d' AND source_role_template_id IS NULL;

-- Aceptación del doctor para cada persona de apoyo nueva (ninguna puede responder en su nombre).
INSERT INTO delegated_access.practitioner_delegate_assignments (id, practitioner_role_assignment_id, delegate_user_assignment_id, delegated_permission_set_id, delegate_role_concept_id, may_view_clinical_content, may_edit_drafts, may_sign_clinical_content, valid_from, status_concept_id, created_at, updated_at, row_version, may_reply_on_behalf, reply_disclosure_concept_id, accepted_at, tenant_id) VALUES
  ('fdf9e8f3-6ea7-5fed-b12b-a2a6f02d5f50', '30a0f73d-3668-5859-9f78-ade7a0a7cde7', '234196e9-3644-5d09-85b0-b5fd9a474296', '0ba62ad0-e22f-553b-9496-14829b7bbf9c', 'afb80bf4-0d35-5088-b4e3-bdba011cf227', false, false, false, now(), '38a1d301-f40d-5b17-a695-5e6d605f8b19', now(), now(), 1, false, '7078aa21-2624-5d9e-beb2-a8bdfa8ad471', timestamptz '2026-10-01 10:00:00-04', '830e47e1-8e82-50ff-99c0-bfed0a7971a4'),
  ('edf912b7-0f0e-532b-84f9-d882611b410e', 'f4e4d910-002f-5a42-a3fa-8696220f940b', '234196e9-3644-5d09-85b0-b5fd9a474296', '0ba62ad0-e22f-553b-9496-14829b7bbf9c', 'afb80bf4-0d35-5088-b4e3-bdba011cf227', false, false, false, now(), '38a1d301-f40d-5b17-a695-5e6d605f8b19', now(), now(), 1, false, '7078aa21-2624-5d9e-beb2-a8bdfa8ad471', timestamptz '2026-10-01 10:00:00-04', '830e47e1-8e82-50ff-99c0-bfed0a7971a4'),
  ('4ecc6fd5-a3d5-5ff5-8856-8ce2b047a716', 'f4e4d910-002f-5a42-a3fa-8696220f940b', '398054f3-49c6-5ca4-b164-096e89c4b180', '0ba62ad0-e22f-553b-9496-14829b7bbf9c', 'afb80bf4-0d35-5088-b4e3-bdba011cf227', false, false, false, now(), '38a1d301-f40d-5b17-a695-5e6d605f8b19', now(), now(), 1, false, '7078aa21-2624-5d9e-beb2-a8bdfa8ad471', timestamptz '2026-10-01 10:00:00-04', '830e47e1-8e82-50ff-99c0-bfed0a7971a4'),
  ('c47af638-4afb-585a-8cc0-e65c2d1de6b8', '223616d5-8cc4-5ea1-9e2e-5b971b001cad', '398054f3-49c6-5ca4-b164-096e89c4b180', '0ba62ad0-e22f-553b-9496-14829b7bbf9c', 'afb80bf4-0d35-5088-b4e3-bdba011cf227', false, false, false, now(), '38a1d301-f40d-5b17-a695-5e6d605f8b19', now(), now(), 1, false, '7078aa21-2624-5d9e-beb2-a8bdfa8ad471', timestamptz '2026-10-01 10:00:00-04', '830e47e1-8e82-50ff-99c0-bfed0a7971a4'),
  ('42491170-7cf4-5d8a-9eb5-6617fc6ec799', 'd52be48f-1b3b-5ba7-8c4a-4e53eb3bed9c', '398054f3-49c6-5ca4-b164-096e89c4b180', '0ba62ad0-e22f-553b-9496-14829b7bbf9c', 'afb80bf4-0d35-5088-b4e3-bdba011cf227', false, false, false, now(), '38a1d301-f40d-5b17-a695-5e6d605f8b19', now(), now(), 1, false, '7078aa21-2624-5d9e-beb2-a8bdfa8ad471', timestamptz '2026-10-01 10:00:00-04', '830e47e1-8e82-50ff-99c0-bfed0a7971a4'),
  ('35bbe45a-3dcb-5768-84ab-1df3d11b3a0f', 'f4e4d910-002f-5a42-a3fa-8696220f940b', 'c5300641-8cf5-537c-bae3-dd70c84bf465', '0ba62ad0-e22f-553b-9496-14829b7bbf9c', 'afb80bf4-0d35-5088-b4e3-bdba011cf227', false, false, false, now(), '38a1d301-f40d-5b17-a695-5e6d605f8b19', now(), now(), 1, false, '7078aa21-2624-5d9e-beb2-a8bdfa8ad471', timestamptz '2026-10-01 10:00:00-04', '830e47e1-8e82-50ff-99c0-bfed0a7971a4'),
  ('8adb5749-e5b5-53da-8f49-43e2600fafe7', 'c3e867d0-28d9-526d-bd16-71e4cdb285d2', 'c5300641-8cf5-537c-bae3-dd70c84bf465', '0ba62ad0-e22f-553b-9496-14829b7bbf9c', 'afb80bf4-0d35-5088-b4e3-bdba011cf227', false, false, false, now(), '38a1d301-f40d-5b17-a695-5e6d605f8b19', now(), now(), 1, false, '7078aa21-2624-5d9e-beb2-a8bdfa8ad471', timestamptz '2026-10-01 10:00:00-04', '830e47e1-8e82-50ff-99c0-bfed0a7971a4'),
  ('4cacb6d9-c96f-560b-8794-caba59d8b903', 'd487ae98-c6f5-57d1-ac38-b651d303f080', 'c5300641-8cf5-537c-bae3-dd70c84bf465', '0ba62ad0-e22f-553b-9496-14829b7bbf9c', 'afb80bf4-0d35-5088-b4e3-bdba011cf227', false, false, false, now(), '38a1d301-f40d-5b17-a695-5e6d605f8b19', now(), now(), 1, false, '7078aa21-2624-5d9e-beb2-a8bdfa8ad471', timestamptz '2026-10-01 10:00:00-04', '830e47e1-8e82-50ff-99c0-bfed0a7971a4'),
  ('455c3882-9ff7-52cb-9842-12acdfd85a08', '223616d5-8cc4-5ea1-9e2e-5b971b001cad', 'c5300641-8cf5-537c-bae3-dd70c84bf465', '0ba62ad0-e22f-553b-9496-14829b7bbf9c', 'afb80bf4-0d35-5088-b4e3-bdba011cf227', false, false, false, now(), '38a1d301-f40d-5b17-a695-5e6d605f8b19', now(), now(), 1, false, '7078aa21-2624-5d9e-beb2-a8bdfa8ad471', timestamptz '2026-10-01 10:00:00-04', '830e47e1-8e82-50ff-99c0-bfed0a7971a4'),
  ('3b79cbc7-307b-5d6f-baad-1f3f409da60d', '30a0f73d-3668-5859-9f78-ade7a0a7cde7', 'c5300641-8cf5-537c-bae3-dd70c84bf465', '0ba62ad0-e22f-553b-9496-14829b7bbf9c', 'afb80bf4-0d35-5088-b4e3-bdba011cf227', false, false, false, now(), '38a1d301-f40d-5b17-a695-5e6d605f8b19', now(), now(), 1, false, '7078aa21-2624-5d9e-beb2-a8bdfa8ad471', timestamptz '2026-10-01 10:00:00-04', '830e47e1-8e82-50ff-99c0-bfed0a7971a4'),
  ('0ce61e5a-876a-5d8d-9bcf-fb969f7227fb', '223616d5-8cc4-5ea1-9e2e-5b971b001cad', 'de0204d4-f9d7-5394-8ba3-45e92b46b610', '0ba62ad0-e22f-553b-9496-14829b7bbf9c', 'afb80bf4-0d35-5088-b4e3-bdba011cf227', false, false, false, now(), '38a1d301-f40d-5b17-a695-5e6d605f8b19', now(), now(), 1, false, '7078aa21-2624-5d9e-beb2-a8bdfa8ad471', timestamptz '2026-10-01 10:00:00-04', '830e47e1-8e82-50ff-99c0-bfed0a7971a4'),
  ('3dae6c22-b879-59ab-ab11-cf6ff9d94485', 'f4e4d910-002f-5a42-a3fa-8696220f940b', 'ebe3a9a3-0191-59b1-b3b8-944579f95573', '0ba62ad0-e22f-553b-9496-14829b7bbf9c', 'afb80bf4-0d35-5088-b4e3-bdba011cf227', false, false, false, now(), '38a1d301-f40d-5b17-a695-5e6d605f8b19', now(), now(), 1, false, '7078aa21-2624-5d9e-beb2-a8bdfa8ad471', timestamptz '2026-10-01 10:00:00-04', '830e47e1-8e82-50ff-99c0-bfed0a7971a4'),
  ('14858b7d-4b4b-5403-b838-33d159bc839a', '223616d5-8cc4-5ea1-9e2e-5b971b001cad', 'ebe3a9a3-0191-59b1-b3b8-944579f95573', '0ba62ad0-e22f-553b-9496-14829b7bbf9c', 'afb80bf4-0d35-5088-b4e3-bdba011cf227', false, false, false, now(), '38a1d301-f40d-5b17-a695-5e6d605f8b19', now(), now(), 1, false, '7078aa21-2624-5d9e-beb2-a8bdfa8ad471', timestamptz '2026-10-01 10:00:00-04', '830e47e1-8e82-50ff-99c0-bfed0a7971a4')
ON CONFLICT DO NOTHING;

-- Ajustes de gobierno de la organización (mismo mecanismo que `org_account_mode`): son DATOS, no código.
INSERT INTO practice.practice_settings (id, practice_id, setting_key, value_json, category_concept_id, created_at, updated_at, row_version) VALUES
  ('8bb11402-e5ab-531f-8a70-a816e6811b63', '314eeab4-0062-5e4f-b3f1-4e26174daa10', 'support.governance', '{"onboardingRequired": true, "onboardingRequiredSince": "2026-11-02T00:00:00Z", "inactivityDays": 45, "unusedDays": 60, "autoSuspendInactiveDays": null, "reviewCadenceMonths": 6, "maxSodExceptionDays": 90, "creepThreshold": 15, "fourEyesActionTtlMinutes": 60, "suspensionReviewAfterDays": 60}'::jsonb, '64f1b3bf-78e2-5904-8a62-811edde0f779', now(), now(), 1)
ON CONFLICT DO NOTHING;

-- Regla de red ALLOW para que `network.require = ORG_RULES` tenga sentido.
INSERT INTO authz.ip_access_rules (id, tenant_id, scope_concept_id, rule_type_concept_id, cidr, description, priority, status_concept_id, created_at, updated_at, row_version) VALUES
  ('469a5cb9-e676-5d03-8bde-c3df3def2d8e', '830e47e1-8e82-50ff-99c0-bfed0a7971a4', '1b45f74f-f39e-58eb-b29a-86c100efeb67', '32909f2c-edc4-5318-871a-e91a3879ad3e', '192.0.2.0/24', 'Red del hospital (rango de documentación, ficticio)', 10, '38a1d301-f40d-5b17-a695-5e6d605f8b19', now(), now(), 1)
ON CONFLICT DO NOTHING;

-- Reglas de la organización (L1): techo, condición obligatoria y piso de campo.
INSERT INTO delegated_access.governance_rules (id, tenant_id, rule_kind_concept_id, role_template_code, permission_pattern, rule_json, rule_schema_version, message_text, status_concept_id, valid_from, created_by_user_id, created_at, updated_at, row_version) VALUES
  ('b0d2cf2c-4876-589a-9552-0b1fee227536', '830e47e1-8e82-50ff-99c0-bfed0a7971a4', 'ce906685-7a58-54e7-b4d2-458062c0c303', 'SECRETARY', 'billing.*', '{}'::jsonb, 1, 'Secretaría no cobra', '38a1d301-f40d-5b17-a695-5e6d605f8b19', timestamptz '2026-10-01 08:00:00-04', 'a9dd40bb-1eb5-5b58-ae2a-06896d8c2810', now(), now(), 1),
  ('bdda8df2-1838-5dd2-983a-462fb0c1055e', '830e47e1-8e82-50ff-99c0-bfed0a7971a4', '1b6db045-2cc5-5985-9c89-18b8ac0969be', NULL, 'billing.*', '{"condition": {"schemaVersion": 1, "network": {"require": "ORG_RULES"}}, "appliesTo": "ALL"}'::jsonb, 1, 'La facturación solo se opera desde la red del hospital', '38a1d301-f40d-5b17-a695-5e6d605f8b19', timestamptz '2026-10-01 08:00:00-04', 'a9dd40bb-1eb5-5b58-ae2a-06896d8c2810', now(), now(), 1),
  ('be7ff8c2-190c-55b0-9c28-694442602207', '830e47e1-8e82-50ff-99c0-bfed0a7971a4', 'f2534b4a-a8cc-5fb1-a431-30e1a750274b', NULL, 'agenda.appointment.view.patient_document', '{"maxVisibility": "PARTIAL"}'::jsonb, 1, 'Su organización limita este dato a la vista parcial', '38a1d301-f40d-5b17-a695-5e6d605f8b19', timestamptz '2026-10-01 08:00:00-04', 'a9dd40bb-1eb5-5b58-ae2a-06896d8c2810', now(), now(), 1)
ON CONFLICT DO NOTHING;

-- Cuatro ojos de la excepción SoD de Ricardo: la pidió el administrador y la aprobó Gonzalo (no se aprueba lo propio).
INSERT INTO delegated_access.four_eyes_requests (id, tenant_id, kind_concept_id, requester_user_id, subject_user_id, organization_user_assignment_id, approver_kind_concept_id, payload_json, payload_hash, payload_schema_version, reason_text, status_concept_id, expires_at, decided_at, decided_by_user_id, decision_comment_text, approved_until, consumed_at, executed_at, created_by_user_id, created_at, updated_at, row_version) VALUES
  ('42b5312e-ca2e-5768-b3c9-a51fc9d7560b', '830e47e1-8e82-50ff-99c0-bfed0a7971a4', '5b36bf36-7f60-5d20-a2ea-3c7826e8d492', 'a9dd40bb-1eb5-5b58-ae2a-06896d8c2810', '4631fd76-9c97-50a5-8273-30ff2579dce5', '398054f3-49c6-5ca4-b164-096e89c4b180', '610c6456-d162-539e-b21e-2d19a4a99b88', '{"ruleCode": "SOD-GOV-03", "engagementId": "398054f3-49c6-5ca4-b164-096e89c4b180", "validTo": "2026-12-31T23:59:59-04:00", "justification": "Ricardo cobra en el Piso 1 hasta que se contrate un cajero"}'::jsonb, '82bbfdac93af3852e666dfee4be117201793d8e1d02fa13bcc480f4b84ec13fa', 1, 'Ricardo cobra en el Piso 1 hasta que se contrate un cajero', '013d578f-38af-564c-aff1-e36d1fdec6dd', timestamptz '2026-11-09 09:00:00-04', timestamptz '2026-11-02 11:00:00-04', '2e6f6a4b-ccf2-5eaa-975a-d5883bbd25e2', 'Aprobado hasta fin de año', NULL, NULL, timestamptz '2026-11-02 11:00:00-04', 'a9dd40bb-1eb5-5b58-ae2a-06896d8c2810', timestamptz '2026-11-02 09:00:00-04', timestamptz '2026-11-02 11:00:00-04', 1)
ON CONFLICT DO NOTHING;

-- Excepción SoD ACTIVA hasta el 2026-12-31 (hallazgo SOD-GOV-03 de Ricardo).
INSERT INTO delegated_access.sod_exceptions (id, tenant_id, sod_rule_id, organization_user_assignment_id, four_eyes_request_id, justification_text, valid_from, valid_to, status_concept_id, created_by_user_id, created_at, updated_at, row_version) VALUES
  ('92c61c9e-034d-5120-be99-85b43d0bc1f8', '830e47e1-8e82-50ff-99c0-bfed0a7971a4', 'd003dffd-cd20-5ff4-b3d1-43648214c17f', '398054f3-49c6-5ca4-b164-096e89c4b180', '42b5312e-ca2e-5768-b3c9-a51fc9d7560b', 'Ricardo cobra en el Piso 1 hasta que se contrate un cajero (excepción aprobada por el segundo administrador de seguridad).', timestamptz '2026-11-02 11:00:00-04', timestamptz '2026-12-31 23:59:59-04', '38a1d301-f40d-5b17-a695-5e6d605f8b19', 'a9dd40bb-1eb5-5b58-ae2a-06896d8c2810', now(), now(), 1)
ON CONFLICT DO NOTHING;

-- Campaña «Certificación Q4-2026»: lanzada el 2026-10-16, venció el 2026-10-30 (gracia de 7 días: cierre automático el 2026-11-06; escala a los 3 días; sin certificar se revoca).
INSERT INTO delegated_access.access_review_campaigns (id, tenant_id, name, kind_concept_id, scope_json, scope_schema_version, filters_json, due_at, grace_days, reminder_days_before_json, escalate_after_days, uncertified_action_concept_id, owner_user_id, status_concept_id, launched_at, created_by_user_id, created_at, updated_at, row_version) VALUES
  ('8ba4b626-a493-5611-937a-0a54373c3adc', '830e47e1-8e82-50ff-99c0-bfed0a7971a4', 'Certificación Q4-2026', '969627cf-9dff-5f7d-b6c6-8478414a6822', '{"kind": "ALL"}'::jsonb, 1, NULL, timestamptz '2026-10-30 18:00:00-04', 7, '[7, 3, 1]'::jsonb, 3, 'cdc3190b-22f6-5662-8ae0-34c1fb5c2ed2', NULL, 'faa5c9bf-5300-5e43-8829-19a9f0e94fef', timestamptz '2026-10-16 08:00:00-04', 'a9dd40bb-1eb5-5b58-ae2a-06896d8c2810', timestamptz '2026-10-15 17:00:00-04', now(), 1)
ON CONFLICT DO NOTHING;

-- 6 ítems: 2 certificados, 1 revocado y 3 pendientes (vencidos hace 4 días y ya escalados desde el 2026-11-02). Cada ítem lleva su evidencia sellada con SHA-256.
INSERT INTO delegated_access.access_review_items (id, tenant_id, access_review_campaign_id, organization_user_assignment_id, support_scope_grant_id, reviewer_user_id, reviewer_kind_concept_id, decision_concept_id, decided_at, decided_by_user_id, decision_comment_text, adjustment_json, evidence_json, evidence_hash, due_at, reminder_count, last_reminded_at, escalated_at, escalated_to_user_id, created_at, updated_at, row_version) VALUES
  ('64be7eca-ecae-5595-93eb-a51dbf1acf76', '830e47e1-8e82-50ff-99c0-bfed0a7971a4', '8ba4b626-a493-5611-937a-0a54373c3adc', 'c5300641-8cf5-537c-bae3-dd70c84bf465', '8ff87d73-8239-5762-8aec-0ca277f33282', 'a9dd40bb-1eb5-5b58-ae2a-06896d8c2810', 'ca9f26e2-6ed7-5292-b073-b876770c6433', 'a3896ca4-e2a6-5b1b-a192-6b457ea34586', timestamptz '2026-10-20 11:00:00-04', 'a9dd40bb-1eb5-5b58-ae2a-06896d8c2810', 'Verificado con la jefatura de caja: la persona sigue en el puesto.', NULL, '{"collectedAt": "2026-10-16T08:00:00-04:00", "item": "mario", "grantId": "8ff87d73-8239-5762-8aec-0ca277f33282", "assignmentId": "c5300641-8cf5-537c-bae3-dd70c84bf465", "usage90d": {"permits": 40, "denies": 1}}'::jsonb, '74e5b358807e6a63cef8b2c3be37aae87ebf85ec687f58f021043195c3a24796', timestamptz '2026-10-30 18:00:00-04', 1, timestamptz '2026-11-02 08:00:00-04', NULL, NULL, now(), now(), 1),
  ('df0ad9fe-d1ef-5048-8c62-ee795aa588f4', '830e47e1-8e82-50ff-99c0-bfed0a7971a4', '8ba4b626-a493-5611-937a-0a54373c3adc', '234196e9-3644-5d09-85b0-b5fd9a474296', '92d4bc87-c221-5c9e-8f71-08127a2ef789', 'a9dd40bb-1eb5-5b58-ae2a-06896d8c2810', 'ca9f26e2-6ed7-5292-b073-b876770c6433', 'a3896ca4-e2a6-5b1b-a192-6b457ea34586', timestamptz '2026-10-21 10:00:00-04', 'a9dd40bb-1eb5-5b58-ae2a-06896d8c2810', 'La jefatura de Ecografía necesita administrar al equipo del servicio.', NULL, '{"collectedAt": "2026-10-16T08:00:00-04:00", "item": "sofia", "grantId": "92d4bc87-c221-5c9e-8f71-08127a2ef789", "assignmentId": "234196e9-3644-5d09-85b0-b5fd9a474296", "usage90d": {"permits": 40, "denies": 1}}'::jsonb, '3f63e14ccd7e3970d7654f9d96edb8df512bf8c43d7bf7ce1321130137dfc7f9', timestamptz '2026-10-30 18:00:00-04', 1, timestamptz '2026-11-02 08:00:00-04', NULL, NULL, now(), now(), 1),
  ('fb97fd1d-37f7-5bf9-bdb8-66906c5e721d', '830e47e1-8e82-50ff-99c0-bfed0a7971a4', '8ba4b626-a493-5611-937a-0a54373c3adc', 'f9e96f37-5a9a-5ccb-aaea-21b880985301', '21416f29-8a21-52b0-a1bf-62a268aea5b3', '4631fd76-9c97-50a5-8273-30ff2579dce5', '7e4272cc-9ebe-575a-bc36-b6983980a68f', 'bce72e9a-b3bb-5fab-8e79-85d411ba692c', timestamptz '2026-10-22 09:30:00-04', '4631fd76-9c97-50a5-8273-30ff2579dce5', 'La persona ya no apoya en Ecografía; se retira el permiso.', NULL, '{"collectedAt": "2026-10-16T08:00:00-04:00", "item": "lucia-extra", "grantId": "21416f29-8a21-52b0-a1bf-62a268aea5b3", "assignmentId": "f9e96f37-5a9a-5ccb-aaea-21b880985301", "usage90d": {"permits": 40, "denies": 1}}'::jsonb, '4a887621692ad3625dc5aed15a1e1f2b365742e6f657209b383375253b717108', timestamptz '2026-10-30 18:00:00-04', 1, timestamptz '2026-11-02 08:00:00-04', NULL, NULL, now(), now(), 1),
  ('4f40e63f-38b0-5273-8612-3f13449acf57', '830e47e1-8e82-50ff-99c0-bfed0a7971a4', '8ba4b626-a493-5611-937a-0a54373c3adc', 'c10fff7f-6b09-5a73-bec6-f96365eb2fb6', '0ac0749f-d76d-588b-bafa-037a5e6cad50', '161a6e07-9098-52d4-82e9-d0485c5646a2', '716540f6-d919-5f7f-8fe9-7f50909b789f', '55a6db07-19e7-5bb4-978a-3d246492f49d', NULL, NULL, NULL, NULL, '{"collectedAt": "2026-10-16T08:00:00-04:00", "item": "marcos-eco", "grantId": "0ac0749f-d76d-588b-bafa-037a5e6cad50", "assignmentId": "c10fff7f-6b09-5a73-bec6-f96365eb2fb6", "usage90d": {"permits": 40, "denies": 1}}'::jsonb, '3df36d27dfbd2521c135a99b36a1218be3ebb79275ede22f7c7efd985bcf7748', timestamptz '2026-10-30 18:00:00-04', 3, timestamptz '2026-11-02 08:00:00-04', timestamptz '2026-11-02 10:00:00-04', 'a9dd40bb-1eb5-5b58-ae2a-06896d8c2810', now(), now(), 1),
  ('c877658e-2cdc-541f-a76e-5e31307a363b', '830e47e1-8e82-50ff-99c0-bfed0a7971a4', '8ba4b626-a493-5611-937a-0a54373c3adc', '9f1761b6-e456-5a99-bf11-d14b05077d4f', '552db38b-e6ef-5b1b-9e4f-fd354ab57b8f', '9f73a942-98e1-5bab-8647-3dd8ce9916bc', '75b09a0e-44df-5830-93d0-6539c00145fd', '55a6db07-19e7-5bb4-978a-3d246492f49d', NULL, NULL, NULL, NULL, '{"collectedAt": "2026-10-16T08:00:00-04:00", "item": "ana-rojas", "grantId": "552db38b-e6ef-5b1b-9e4f-fd354ab57b8f", "assignmentId": "9f1761b6-e456-5a99-bf11-d14b05077d4f", "usage90d": {"permits": 40, "denies": 1}}'::jsonb, 'c2b93e11ffbf1f3ee25259ff1b73fed4bbc4acc3b1022ec4e2a010bbc9095dad', timestamptz '2026-10-30 18:00:00-04', 3, timestamptz '2026-11-02 08:00:00-04', timestamptz '2026-11-02 10:00:00-04', 'a9dd40bb-1eb5-5b58-ae2a-06896d8c2810', now(), now(), 1),
  ('24d7d75f-b6de-5e6c-aa87-2f5b14e1152a', '830e47e1-8e82-50ff-99c0-bfed0a7971a4', '8ba4b626-a493-5611-937a-0a54373c3adc', 'de0204d4-f9d7-5394-8ba3-45e92b46b610', 'bc90da67-5c44-5032-8153-a87a07216400', 'a9dd40bb-1eb5-5b58-ae2a-06896d8c2810', 'ca9f26e2-6ed7-5292-b073-b876770c6433', '55a6db07-19e7-5bb4-978a-3d246492f49d', NULL, NULL, NULL, NULL, '{"collectedAt": "2026-10-16T08:00:00-04:00", "item": "nora", "grantId": "bc90da67-5c44-5032-8153-a87a07216400", "assignmentId": "de0204d4-f9d7-5394-8ba3-45e92b46b610", "usage90d": {"permits": 0, "denies": 1}}'::jsonb, '5545ccebab9391f549ad195b78439dd24909371ecd04f3e07804dd91a55536a0', timestamptz '2026-10-30 18:00:00-04', 3, timestamptz '2026-11-02 08:00:00-04', timestamptz '2026-11-02 10:00:00-04', '2e6f6a4b-ccf2-5eaa-975a-d5883bbd25e2', now(), now(), 1)
ON CONFLICT DO NOTHING;

-- Aprobación de cuatro ojos PENDIENTE: Marcos pide cancelar la cita A4 (menos de 24 h); aprueba el Dr. Suárez (titular de la agenda).
INSERT INTO delegated_access.four_eyes_requests (id, tenant_id, kind_concept_id, requester_user_id, organization_user_assignment_id, permission_code, approver_kind_concept_id, payload_json, payload_hash, payload_schema_version, reason_text, status_concept_id, expires_at, created_by_user_id, created_at, updated_at, row_version) VALUES
  ('6de19031-215a-54f5-8b72-f2a6264de269', '830e47e1-8e82-50ff-99c0-bfed0a7971a4', '201ca117-97ad-58c2-a6d3-803ea412cd2c', '1a7b8230-215a-5cc7-8788-b8b69e5c3721', 'c10fff7f-6b09-5a73-bec6-f96365eb2fb6', 'agenda.appointment.cancel', '1ec189f8-507a-5fce-9fac-09a584864c04', '{"atom": "agenda.appointment.cancel", "bookingId": "02d06e6c-3f9f-5a58-bc4c-362aeb6c6861", "practitionerRoleAssignmentId": "d487ae98-c6f5-57d1-ac38-b651d303f080", "patientProfileId": "50197407-ba97-5793-b92c-fd9b2e522d09", "appointmentStartAt": "2026-11-04T09:00:00-04:00"}'::jsonb, '8765228014d33d40fbb4eec32baaab895833ea77e7e7b2ef22a5673f9e11e7af', 1, 'La familia pidió cancelar el control del niño por un viaje (22,5 horas antes).', 'a977935a-9073-5113-9644-7df96732e776', timestamptz '2026-11-04 10:20:00-04', '1a7b8230-215a-5cc7-8788-b8b69e5c3721', timestamptz '2026-11-03 10:20:00-04', now(), 1)
ON CONFLICT DO NOTHING;

-- Uso de Marcos: 18 búsquedas en la última hora (línea base p95 = 4) y 3 cancelaciones hoy.
INSERT INTO delegated_access.grant_usage_stats (id, tenant_id, user_id, support_scope_grant_id, permission_code, bucket_start, permit_count, deny_count, challenge_count, off_hours_count, distinct_patients_in_bucket, last_used_at, updated_at) VALUES
  ('da07ac62-4c1a-5255-9702-bc63ddfd86b2', '830e47e1-8e82-50ff-99c0-bfed0a7971a4', '1a7b8230-215a-5cc7-8788-b8b69e5c3721', '0ac0749f-d76d-588b-bafa-037a5e6cad50', 'patients.search.exact', timestamptz '2026-11-03 10:00:00-04', 18, 0, 0, 0, 15, timestamptz '2026-11-03 10:45:00-04', now()),
  ('188e47f9-0b2f-5cd9-8ec4-d74b46134a97', '830e47e1-8e82-50ff-99c0-bfed0a7971a4', '1a7b8230-215a-5cc7-8788-b8b69e5c3721', '2af9f387-d337-5ea7-bedf-716967fd740d', 'agenda.appointment.cancel', timestamptz '2026-11-03 09:00:00-04', 2, 0, 0, 0, 2, timestamptz '2026-11-03 09:45:00-04', now()),
  ('1616ac77-7f60-50d4-a7a6-c490f5cd2e24', '830e47e1-8e82-50ff-99c0-bfed0a7971a4', '1a7b8230-215a-5cc7-8788-b8b69e5c3721', '2af9f387-d337-5ea7-bedf-716967fd740d', 'agenda.appointment.cancel', timestamptz '2026-11-03 10:00:00-04', 1, 0, 1, 0, 1, timestamptz '2026-11-03 10:45:00-04', now())
ON CONFLICT DO NOTHING;

-- Anomalías abiertas: pico de búsquedas de Marcos y cuenta inactiva de Pablo (70 días con acceso vivo).
INSERT INTO delegated_access.access_anomalies (id, tenant_id, user_id, organization_user_assignment_id, kind_concept_id, window_start, window_end, observed_value, baseline_value, threshold_value, evidence_json, status_concept_id, created_at, updated_at) VALUES
  ('ac47a401-dc4e-5314-a050-e8951afc66d5', '830e47e1-8e82-50ff-99c0-bfed0a7971a4', '1a7b8230-215a-5cc7-8788-b8b69e5c3721', 'c10fff7f-6b09-5a73-bec6-f96365eb2fb6', '7f20d407-aa33-5757-a6e0-3ddf9160592d', timestamptz '2026-11-03 09:30:00-04', timestamptz '2026-11-03 10:30:00-04', 18, 4, 15, '{"metric": "ACTIONS", "atom": "patients.search.exact", "max(15, 3 x p95)": 15, "distinctPatients": 15}'::jsonb, '5dc5d5c6-03af-5c50-9841-2559f959a180', timestamptz '2026-11-03 10:30:00-04', now()),
  ('99136457-5c8c-5aef-8f8e-8971f51f1763', '830e47e1-8e82-50ff-99c0-bfed0a7971a4', '902be75b-9e55-59c7-9f3f-01c34cde9dee', 'ebe3a9a3-0191-59b1-b3b8-944579f95573', 'b188b551-f49c-557f-95d0-432e1cfb3214', timestamptz '2026-08-25 17:00:00-04', timestamptz '2026-11-03 06:00:00-04', 70, NULL, 45, '{"lastActiveAt": "2026-08-25T17:00:00-04:00", "inactivityDays": 45, "liveGrants": 2}'::jsonb, '5dc5d5c6-03af-5c50-9841-2559f959a180', timestamptz '2026-11-03 06:00:00-04', now())
ON CONFLICT DO NOTHING;

-- Casos de ingreso: Mario completo; Nora abierto (falta SUPERVISOR_ASSIGNED).
INSERT INTO delegated_access.lifecycle_cases (id, tenant_id, organization_user_assignment_id, subject_user_id, kind_concept_id, status_concept_id, opened_by_user_id, opened_at, due_at, completed_at, reason_text, checklist_json, details_json, created_at, updated_at, row_version) VALUES
  ('bd6e6c2b-19a2-5b3c-8192-3c7ce8f31c4d', '830e47e1-8e82-50ff-99c0-bfed0a7971a4', 'c5300641-8cf5-537c-bae3-dd70c84bf465', '1a4fe4d3-2f89-5a9d-9b63-b2b0df3cf2b1', 'c2a9a59d-c88c-5e87-9065-1e0e068c479d', '4734035e-72cf-519f-8e27-e6cf25ba557f', 'a9dd40bb-1eb5-5b58-ae2a-06896d8c2810', timestamptz '2026-11-02 09:30:00-04', timestamptz '2026-11-09 09:30:00-04', timestamptz '2026-11-02 09:30:00-04', 'Ingreso de cajero', '[{"code": "IDENTITY_VERIFIED", "done": true}, {"code": "TEMPLATE_ASSIGNED", "done": true}, {"code": "DOCTOR_ACCEPTANCES", "done": true}, {"code": "SUPERVISOR_ASSIGNED", "done": true}, {"code": "ONBOARDING_COMPLETED", "done": true}]'::jsonb, NULL, now(), now(), 1),
  ('ce61a6f9-7a9d-525e-8f77-e491eea7e3a2', '830e47e1-8e82-50ff-99c0-bfed0a7971a4', 'de0204d4-f9d7-5394-8ba3-45e92b46b610', '8b6a27d3-3f51-5feb-8bf0-71db52f7e1c2', 'c2a9a59d-c88c-5e87-9065-1e0e068c479d', '4f73e30c-25ba-52ff-969e-862e588cce13', 'a9dd40bb-1eb5-5b58-ae2a-06896d8c2810', timestamptz '2026-11-02 09:45:00-04', timestamptz '2026-11-09 09:45:00-04', NULL, 'Ingreso de enfermería de Internación (falta asignar dueño de la cuenta)', '[{"code": "IDENTITY_VERIFIED", "done": true}, {"code": "TEMPLATE_ASSIGNED", "done": true}, {"code": "DOCTOR_ACCEPTANCES", "done": true}, {"code": "SUPERVISOR_ASSIGNED", "done": false}, {"code": "ONBOARDING_COMPLETED", "done": false}]'::jsonb, NULL, now(), now(), 1)
ON CONFLICT DO NOTHING;

-- 3 conversaciones de la bandeja asignadas a Pablo (2 de Pérez, 1 de Méndez).
INSERT INTO community.conversations (id, tenant_id, conversation_type_concept_id, status_concept_id, created_at, updated_at, row_version) VALUES
  ('025e9dfd-dfb8-5a0c-b324-9135fbf60e0a', '830e47e1-8e82-50ff-99c0-bfed0a7971a4', 'aa620322-258d-59bd-977f-77af000e2695', '38a1d301-f40d-5b17-a695-5e6d605f8b19', now(), now(), 1),
  ('8cf5e595-0e03-5683-a68b-eaa4448b05a0', '830e47e1-8e82-50ff-99c0-bfed0a7971a4', 'aa620322-258d-59bd-977f-77af000e2695', '38a1d301-f40d-5b17-a695-5e6d605f8b19', now(), now(), 1),
  ('403d3005-5c5c-5630-92a2-a290243a0d2f', '830e47e1-8e82-50ff-99c0-bfed0a7971a4', 'aa620322-258d-59bd-977f-77af000e2695', '38a1d301-f40d-5b17-a695-5e6d605f8b19', now(), now(), 1)
ON CONFLICT DO NOTHING;

-- Asignaciones de la bandeja.
INSERT INTO community.conversation_assignments (id, tenant_id, conversation_id, practitioner_profile_id, assigned_user_id, status_concept_id, sla_due_at, created_at, updated_at, row_version) VALUES
  ('f29d2cfd-ebb4-5e93-b506-5e0c96669945', '830e47e1-8e82-50ff-99c0-bfed0a7971a4', '025e9dfd-dfb8-5a0c-b324-9135fbf60e0a', '96307267-f432-5fd2-9bd0-e609625088ab', '902be75b-9e55-59c7-9f3f-01c34cde9dee', 'd2f990d1-1def-59e1-b4bc-d3caf4b65e5d', timestamptz '2026-11-04 12:00:00-04', now(), now(), 1),
  ('5b532ad8-0371-5943-9d6a-cee71db0687a', '830e47e1-8e82-50ff-99c0-bfed0a7971a4', '8cf5e595-0e03-5683-a68b-eaa4448b05a0', '96307267-f432-5fd2-9bd0-e609625088ab', '902be75b-9e55-59c7-9f3f-01c34cde9dee', 'd2f990d1-1def-59e1-b4bc-d3caf4b65e5d', timestamptz '2026-11-04 12:00:00-04', now(), now(), 1),
  ('dc620652-1d8a-59ff-bc4d-0f16905e0d57', '830e47e1-8e82-50ff-99c0-bfed0a7971a4', '403d3005-5c5c-5630-92a2-a290243a0d2f', '4a443ffa-92e4-5015-86a5-2d51c726bf76', '902be75b-9e55-59c7-9f3f-01c34cde9dee', 'd2f990d1-1def-59e1-b4bc-d3caf4b65e5d', timestamptz '2026-11-04 12:00:00-04', now(), now(), 1)
ON CONFLICT DO NOTHING;

-- Instancia que agrupa las tareas abiertas de Pablo.
INSERT INTO workflow.workflow_instances (id, workflow_code, subject_type_concept_id, subject_id, tenant_id, current_state_concept_id, status_concept_id, created_at, updated_at, row_version) VALUES
  ('133a36d2-8fce-5254-a63c-a2ca88a5a569', 'DEMO_GOV_TAREAS_PABLO', 'c2b1a0a7-47de-5d40-97af-bf20603d4335', 'b2801747-454c-5ae8-b1b3-11be155e0c67', '830e47e1-8e82-50ff-99c0-bfed0a7971a4', 'd681d62e-fc33-5a51-b7a5-81a15dfafd49', 'd681d62e-fc33-5a51-b7a5-81a15dfafd49', now(), now(), 1)
ON CONFLICT DO NOTHING;

-- 2 tareas de workflow abiertas de Pablo.
INSERT INTO workflow.workflow_tasks (id, workflow_instance_id, task_code, task_type_concept_id, assigned_user_id, due_at, status_concept_id, created_at, updated_at, row_version) VALUES
  ('9d5cb9fc-b1c9-5e57-9af2-24c132f1ba4c', '133a36d2-8fce-5254-a63c-a2ca88a5a569', 'DEMO_GOV_TAREA_1', 'dfe977d8-d6d3-5c44-8ed3-cdf934ba7f8e', '902be75b-9e55-59c7-9f3f-01c34cde9dee', timestamptz '2026-11-05 12:00:00-04', '4778c049-011c-5e91-9bd6-1e6bf8a0a42c', now(), now(), 1),
  ('2e751ece-a1b1-52fc-8d57-4cdf39d994c5', '133a36d2-8fce-5254-a63c-a2ca88a5a569', 'DEMO_GOV_TAREA_2', 'dfe977d8-d6d3-5c44-8ed3-cdf934ba7f8e', '902be75b-9e55-59c7-9f3f-01c34cde9dee', timestamptz '2026-11-05 12:00:00-04', '4778c049-011c-5e91-9bd6-1e6bf8a0a42c', now(), now(), 1)
ON CONFLICT DO NOTHING;

COMMIT;

\echo == gobierno del hospital piloto (demo) cargado ==
SELECT (SELECT count(*) FROM iam.users WHERE display_name IN ('Sofía Camacho', 'Ricardo Terceros', 'Mario Salvatierra', 'Nora Villarroel', 'Pablo Mamani', 'Gonzalo Pinto')) AS cuentas_nuevas,
       (SELECT count(*) FROM profiles.patient_profiles WHERE patient_code LIKE 'DEMO-GOV-P%') AS pacientes,
       (SELECT count(*) FROM scheduling.appointment_bookings WHERE id IN ('94e68cf4-45b2-59d1-88bf-bcd7123c0153', 'f8ac4d60-21d7-5c82-9fc0-5d93296dd02e', '4ab690a0-a28e-5e30-8f4a-aa6f0ac22f78', '02d06e6c-3f9f-5a58-bc4c-362aeb6c6861', 'c389372e-1343-582c-967f-0500bebebe6e', '14b7f2bc-47bd-5301-b874-f24549818bde', 'a20a30f8-009e-5aa2-a16e-3c3263303aa7', 'b678f714-1bc8-53f7-903f-580ad568d226', '19ba6cd8-58f7-5d12-b2b4-94fe83611da7', 'defd605d-eab0-544f-8b27-6a103d1faaaa', 'c2aa2413-478e-50b5-ad18-782761f453aa', 'c22bf59a-3fed-525d-a7ca-1a97a14f8945', '03ba03b9-9e29-5219-8b0f-b5c94a32b81d')) AS citas,
       (SELECT count(*) FROM delegated_access.access_review_items WHERE access_review_campaign_id = '8ba4b626-a493-5611-937a-0a54373c3adc') AS items_de_campana,
       (SELECT count(*) FROM delegated_access.governance_rules WHERE tenant_id = '830e47e1-8e82-50ff-99c0-bfed0a7971a4') AS reglas_de_la_organizacion;
