-- ============================================================================
-- HOSPITAL PILOTO MANTRA — datos de DEMOSTRACIÓN (100 % FICTICIOS)
-- ============================================================================
-- Qué es: el escenario del diseño de «personal de apoyo» (secretaria y otros roles):
-- una organización-hospital con dos sedes, edificios, pisos y salas, siete doctores,
-- cuatro personas de apoyo con sus vínculos y permisos, y un consultorio privado aparte.
-- Nombres, documentos y correos son inventados (dominio `.invalid`); no hay personas
-- ni establecimientos reales. Todo código lleva el prefijo DEMO_ / DEMO-.
--
-- Cuándo correrlo: DESPUÉS de aplicar el esquema (SQL/apply_all.sql + apply_deferred.sql)
-- y, si la base es una ya poblada, DESPUÉS del parche
-- SQL/patches/2026-10-30_v4269_personal_apoyo.sql. Puede correrse sobre una base con los
-- seeds cargados o sobre una recién creada: siembra él mismo los conceptos que usa
-- (con los MISMOS ids que deriva la API, así que si la API ya arrancó no duplica nada).
-- Es idempotente: volver a correrlo no duplica nada (ids deterministas + ON CONFLICT DO NOTHING).
--
-- Contraseña de TODAS las cuentas demo: Demo-Apoyo-2026   (argon2id; documento de acceso =
-- `authentication_credentials.external_subject`, p. ej. DEMO-ANA-GUTIERREZ).
-- NO cargar en producción.
--
-- GUARDA (v4.2.70, revisión de seguridad B4): este script crea 13 cuentas con una contraseña CONOCIDA y el MISMO
-- hash, incluida la del administrador del hospital. Por eso NO corre «de rebote»: exige una bandera explícita y,
-- sin ella, FALLA con un mensaje claro ANTES de escribir nada (todo el script es una sola transacción):
--     psql -v ON_ERROR_STOP=1 -v demo_accounts=1 -d <base> -f salud-db/demo/04-hospital-piloto.sql
-- (equivalente: `\set demo_accounts 1` dentro de la sesión psql, o el ajuste de sesión
--  `PGOPTIONS="-c mantra.demo_accounts=1"`). Valores aceptados: 1, true, on, yes.
--
-- Casos de prueba que este escenario habilita (ver 05-verifica-hospital-piloto.sql):
--   01 Ana crea cita Pérez consulta A-P1            → permitido
--   02 Ana ecocardiograma Pérez A-P2                → permitido
--   03 Lucía check_in paciente de Méndez en 105     → permitido
--   04 Lucía check_in en A-P4                       → negado
--   05 Lucía crea cita Pérez P1                     → negado (plantilla sin create)
--   06 Marcos agenda Ecografía con Antelo sala 201  → permitido
--   07 Marcos eco obstétrica con Rojas B204         → negado
--   08 Marcos Suárez en Sede Norte permitido / Suárez en Edificio B negado
--   11 Rosa ve agenda de Céspedes en Hospital Piloto→ negado
--   12 Ana tras fin de vínculo                      → negado (sus citas siguen)
--   (09, 10 y 13 son reglas de la API: mensajes, historia clínica y búsqueda exacta)
-- ============================================================================

BEGIN;

-- GUARDA B4: sin la bandera explícita no se crea ninguna cuenta con contraseña conocida.
-- La variable psql `demo_accounts` (o el ajuste `mantra.demo_accounts`) debe valer 1/true/on/yes.
\if :{?demo_accounts}
  SELECT set_config('mantra.demo_accounts', :'demo_accounts', false);
\endif
DO $guard$
BEGIN
  IF lower(COALESCE(current_setting('mantra.demo_accounts', true), '')) NOT IN ('1', 'true', 'on', 'yes') THEN
    RAISE EXCEPTION 'hospital piloto (demo): este script crea cuentas con una contraseña CONOCIDA (Demo-Apoyo-2026) y no corre sin consentimiento explícito. Vuelve a correrlo con -v demo_accounts=1 (o \set demo_accounts 1) SOLO en una base de demostración o pruebas, nunca en producción.'
      USING ERRCODE = 'insufficient_privilege',
            HINT = 'psql -v ON_ERROR_STOP=1 -v demo_accounts=1 -d <base> -f salud-db/demo/04-hospital-piloto.sql';
  END IF;
  RAISE WARNING 'hospital piloto (demo): se crearán cuentas con la contraseña conocida Demo-Apoyo-2026 en la base %', current_database();
END
$guard$;

-- 0 · Anclas y conceptos que esta demo usa. Mismos ids que deriva la API (uuid5 sobre su namespace):
-- si la API ya arrancó, o si los seeds de boot ya se cargaron, todo esto es un no-op.
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
  ('89c2342b-cec1-5678-b97c-e33c304d5519', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'authz:ACTION_CREATE', 'Create', false, true, now(), now(), 1),  -- authz:ACTION_CREATE
  ('11f6b39b-272e-52c4-9583-3bd153b1e21e', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'authz:ACTION_EXECUTE', 'Execute', false, true, now(), now(), 1),  -- authz:ACTION_EXECUTE
  ('ea5aa219-9b0f-538f-9ca5-0e7eb4e715cf', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'authz:ACTION_READ', 'Read', false, true, now(), now(), 1),  -- authz:ACTION_READ
  ('0491c4bb-2c42-5acb-b422-8da33bd0b4a3', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'authz:ACTION_WRITE', 'Write', false, true, now(), now(), 1),  -- authz:ACTION_WRITE
  ('1b45f74f-f39e-58eb-b29a-86c100efeb67', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'authz:SCOPE_TENANT', 'Tenant scope', false, true, now(), now(), 1),  -- authz:SCOPE_TENANT
  ('0c2c8c70-2e98-55d1-82c4-764218621f8d', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'community:CONVERSATION_ASSIGNMENT_NEW', 'Conversation assignment new', false, true, now(), now(), 1),  -- community:CONVERSATION_ASSIGNMENT_NEW
  ('95ac72af-6851-59cf-ab57-8a2d2216901a', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'community:CONVERSATION_ASSIGNMENT_RESOLVED', 'Conversation assignment resolved', false, true, now(), now(), 1),  -- community:CONVERSATION_ASSIGNMENT_RESOLVED
  ('d2f990d1-1def-59e1-b4bc-d3caf4b65e5d', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'community:CONVERSATION_ASSIGNMENT_TAKEN', 'Conversation assignment taken', false, true, now(), now(), 1),  -- community:CONVERSATION_ASSIGNMENT_TAKEN
  ('7291cc80-05ba-5b65-aec9-4938550851cf', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'community:CONVERSATION_ASSIGNMENT_WAITING_DOCTOR', 'Conversation assignment waiting for the doctor', false, true, now(), now(), 1),  -- community:CONVERSATION_ASSIGNMENT_WAITING_DOCTOR
  ('d364a96e-1459-5546-bf8c-5184d24f5d77', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'community:REPLY_TEMPLATE_CATEGORY_BILLING', 'Reply template category: billing', false, true, now(), now(), 1),  -- community:REPLY_TEMPLATE_CATEGORY_BILLING
  ('5e413313-5202-526a-a3ad-66a901360327', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'community:REPLY_TEMPLATE_CATEGORY_GENERAL', 'Reply template category: general', false, true, now(), now(), 1),  -- community:REPLY_TEMPLATE_CATEGORY_GENERAL
  ('63928e74-8746-5dae-813e-857a2720c292', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'community:REPLY_TEMPLATE_CATEGORY_PREPARATION', 'Reply template category: visit preparation', false, true, now(), now(), 1),  -- community:REPLY_TEMPLATE_CATEGORY_PREPARATION
  ('1bf34fbc-455d-5373-bada-632eac6d1176', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'community:REPLY_TEMPLATE_CATEGORY_SCHEDULING', 'Reply template category: scheduling', false, true, now(), now(), 1),  -- community:REPLY_TEMPLATE_CATEGORY_SCHEDULING
  ('2e3e235b-5144-5e08-9141-41a402e3bee1', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'delegated_access:ASSIGN_ROLE_CALL_CENTER', 'Call center assignment', false, true, now(), now(), 1),  -- delegated_access:ASSIGN_ROLE_CALL_CENTER
  ('9663275c-312f-5165-bd04-aebe7b3fdf36', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'delegated_access:ASSIGN_ROLE_FRONT_DESK', 'Front desk assignment', false, true, now(), now(), 1),  -- delegated_access:ASSIGN_ROLE_FRONT_DESK
  ('3a5bfde0-e0f3-570d-b5f4-68bcdbf23102', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'delegated_access:ASSIGN_ROLE_ORG_MANAGEMENT', 'Organization management assignment', false, true, now(), now(), 1),  -- delegated_access:ASSIGN_ROLE_ORG_MANAGEMENT
  ('dc407af0-7ce8-56b3-9b7b-fe2b68bbb8ec', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'delegated_access:ASSIGN_ROLE_SECRETARY', 'Secretary assignment', false, true, now(), now(), 1),  -- delegated_access:ASSIGN_ROLE_SECRETARY
  ('afb80bf4-0d35-5088-b4e3-bdba011cf227', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'delegated_access:DELEGATE_ROLE_SECRETARY', 'Secretary delegate role', false, true, now(), now(), 1),  -- delegated_access:DELEGATE_ROLE_SECRETARY
  ('87d0ed36-3de2-50fd-9b81-776eb828f520', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'delegated_access:DELEGATE_TYPE_CALL_CENTER', 'Call center delegate type', false, true, now(), now(), 1),  -- delegated_access:DELEGATE_TYPE_CALL_CENTER
  ('c4b64a74-4924-5e62-aab0-d21f83ac95d9', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'delegated_access:DELEGATE_TYPE_FRONT_DESK', 'Front desk delegate type', false, true, now(), now(), 1),  -- delegated_access:DELEGATE_TYPE_FRONT_DESK
  ('46b786de-8523-56fb-bc00-24ba1847bcb3', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'delegated_access:DELEGATE_TYPE_ORG_MANAGEMENT', 'Organization management delegate type', false, true, now(), now(), 1),  -- delegated_access:DELEGATE_TYPE_ORG_MANAGEMENT
  ('da2c812c-2f0e-5d72-aa00-7cfa9e279fd5', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'delegated_access:DELEGATE_TYPE_SECRETARY', 'Secretary delegate type', false, true, now(), now(), 1),  -- delegated_access:DELEGATE_TYPE_SECRETARY
  ('f4429a2c-67ed-596b-91b9-d60b6340ad74', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'delegated_access:ENGAGEMENT_DECISION_ADJUSTED', 'Engagement item approved with adjustments', false, true, now(), now(), 1),  -- delegated_access:ENGAGEMENT_DECISION_ADJUSTED
  ('79be5b24-f196-5d6e-ad59-52d9e4810e4c', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'delegated_access:ENGAGEMENT_DECISION_APPROVED', 'Engagement item approved', false, true, now(), now(), 1),  -- delegated_access:ENGAGEMENT_DECISION_APPROVED
  ('f906bb33-2a72-58a1-bfca-c08ad585ba1a', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'delegated_access:ENGAGEMENT_DECISION_PENDING', 'Engagement item decision pending', false, true, now(), now(), 1),  -- delegated_access:ENGAGEMENT_DECISION_PENDING
  ('1e29fc03-4e69-53db-bb35-0e29efbcd8e9', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'delegated_access:ENGAGEMENT_DECISION_REJECTED', 'Engagement item rejected', false, true, now(), now(), 1),  -- delegated_access:ENGAGEMENT_DECISION_REJECTED
  ('f805f7a7-9c3f-51c5-955e-b099d28e656c', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'delegated_access:ENGAGEMENT_DIRECTION_INVITATION', 'Engagement direction: organization invites the person', false, true, now(), now(), 1),  -- delegated_access:ENGAGEMENT_DIRECTION_INVITATION
  ('48d72179-b75d-5f3e-9586-9013246ed0c4', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'delegated_access:ENGAGEMENT_DIRECTION_REQUEST', 'Engagement direction: person asks the organization', false, true, now(), now(), 1),  -- delegated_access:ENGAGEMENT_DIRECTION_REQUEST
  ('320e177a-bda6-543f-97e6-d6c30873db41', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'delegated_access:ENGAGEMENT_ORIGIN_INVITATION', 'Engagement origin: invitation', false, true, now(), now(), 1),  -- delegated_access:ENGAGEMENT_ORIGIN_INVITATION
  ('a36afaec-1203-5ec7-beb3-d1595e264929', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'delegated_access:ENGAGEMENT_ORIGIN_QR', 'Engagement origin: QR code', false, true, now(), now(), 1),  -- delegated_access:ENGAGEMENT_ORIGIN_QR
  ('cdef8f46-a60e-5a84-97e3-37d5007e905d', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'delegated_access:ENGAGEMENT_ORIGIN_REQUEST', 'Engagement origin: request', false, true, now(), now(), 1),  -- delegated_access:ENGAGEMENT_ORIGIN_REQUEST
  ('5e2979b9-3d0b-5370-97c7-1d59a0e35e1f', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'delegated_access:ENGAGEMENT_STATUS_APPROVED', 'Engagement request approved', false, true, now(), now(), 1),  -- delegated_access:ENGAGEMENT_STATUS_APPROVED
  ('457d78aa-4184-5c5f-adcd-e3bf3499eb23', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'delegated_access:ENGAGEMENT_STATUS_CANCELLED', 'Engagement request cancelled', false, true, now(), now(), 1),  -- delegated_access:ENGAGEMENT_STATUS_CANCELLED
  ('1771af53-b5bd-53fc-88bc-6e5f193841d5', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'delegated_access:ENGAGEMENT_STATUS_EXPIRED', 'Engagement request expired', false, true, now(), now(), 1),  -- delegated_access:ENGAGEMENT_STATUS_EXPIRED
  ('0aedb9a7-2bca-51ae-a086-c234e61782f6', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'delegated_access:ENGAGEMENT_STATUS_PENDING', 'Engagement request pending', false, true, now(), now(), 1),  -- delegated_access:ENGAGEMENT_STATUS_PENDING
  ('2bf808d0-5ab1-5fa4-933a-ec15a207358b', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'delegated_access:ENGAGEMENT_STATUS_REJECTED', 'Engagement request rejected', false, true, now(), now(), 1),  -- delegated_access:ENGAGEMENT_STATUS_REJECTED
  ('6397159b-1477-5551-9950-862b8b8ce122', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'delegated_access:OWNER_KIND_ORGANIZATION', 'Support owner: organization', false, true, now(), now(), 1),  -- delegated_access:OWNER_KIND_ORGANIZATION
  ('17bb2ba1-8ddd-58d8-92d4-d419980e4ff1', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'delegated_access:OWNER_KIND_PRIVATE_PRACTICE', 'Support owner: private practice', false, true, now(), now(), 1),  -- delegated_access:OWNER_KIND_PRIVATE_PRACTICE
  ('259a9a0d-4898-5757-a16f-fa40cdba90b7', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'delegated_access:REPLY_DISCLOSURE_HIDE', 'Hide that the care team replied', false, true, now(), now(), 1),  -- delegated_access:REPLY_DISCLOSURE_HIDE
  ('7078aa21-2624-5d9e-beb2-a8bdfa8ad471', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'delegated_access:REPLY_DISCLOSURE_SHOW', 'Show that the care team replied', false, true, now(), now(), 1),  -- delegated_access:REPLY_DISCLOSURE_SHOW
  ('6b070aec-a5af-52bc-8462-55be0d26298a', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'delegated_access:ROLE_TEMPLATE_ACTIVE', 'Role template active', false, true, now(), now(), 1),  -- delegated_access:ROLE_TEMPLATE_ACTIVE
  ('f2889c99-ac92-52a0-94dc-db6fed4edad8', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'delegated_access:ROLE_TEMPLATE_RETIRED', 'Role template retired', false, true, now(), now(), 1),  -- delegated_access:ROLE_TEMPLATE_RETIRED
  ('e49e9baa-f3b1-5011-83ee-d1e3017aed36', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'delegated_access:SCOPE_TENANT', 'Tenant scope', false, true, now(), now(), 1),  -- delegated_access:SCOPE_TENANT
  ('caa1efa9-2008-5c27-b8f9-1dab4fe4b228', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'delegated_access:STATE_SUSPENDED', 'Suspended', false, true, now(), now(), 1),  -- delegated_access:STATE_SUSPENDED
  ('d9ed1dfe-f5e6-55f3-94f2-2bd60993a536', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'delegated_access:SUPPORT_EXPANSION_DYNAMIC', 'Support grant expansion: dynamic (follows the organization)', false, true, now(), now(), 1),  -- delegated_access:SUPPORT_EXPANSION_DYNAMIC
  ('4f47115f-54ad-564f-bcd4-f06a0a0c13cd', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'delegated_access:SUPPORT_EXPANSION_FIXED', 'Support grant expansion: fixed snapshot', false, true, now(), now(), 1),  -- delegated_access:SUPPORT_EXPANSION_FIXED
  ('ccfbc54f-4744-53db-ab1f-abe1af31f784', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'delegated_access:SUPPORT_GRANT_ACTIVE', 'Support grant active', false, true, now(), now(), 1),  -- delegated_access:SUPPORT_GRANT_ACTIVE
  ('8ea0f60d-9149-50bd-b1e4-43be90b20fee', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'delegated_access:SUPPORT_GRANT_EXPIRED', 'Support grant expired', false, true, now(), now(), 1),  -- delegated_access:SUPPORT_GRANT_EXPIRED
  ('5cf6ef7d-3f5f-5864-93c8-eba9a9cd8af6', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'delegated_access:SUPPORT_GRANT_REVOKED', 'Support grant revoked', false, true, now(), now(), 1),  -- delegated_access:SUPPORT_GRANT_REVOKED
  ('30111410-d96d-5fc1-9e64-283dc3432617', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'delegated_access:SUPPORT_GRANT_SUSPENDED', 'Support grant suspended', false, true, now(), now(), 1),  -- delegated_access:SUPPORT_GRANT_SUSPENDED
  ('b1330928-a076-5348-bffd-154144fadc85', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'delegated_access:SUPPORT_TARGET_ALL', 'Support grant target: all', false, true, now(), now(), 1),  -- delegated_access:SUPPORT_TARGET_ALL
  ('cf4de420-16da-57f8-8c3a-f6ff717fc59e', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'delegated_access:SUPPORT_TARGET_ALL_LOCATIONS', 'Support grant target: all locations', false, true, now(), now(), 1),  -- delegated_access:SUPPORT_TARGET_ALL_LOCATIONS
  ('81f2ac43-a9ba-5043-b455-ed71b2d7e59f', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'delegated_access:SUPPORT_TARGET_ALL_PRACTITIONERS', 'Support grant target: all practitioners', false, true, now(), now(), 1),  -- delegated_access:SUPPORT_TARGET_ALL_PRACTITIONERS
  ('3df7a566-22b8-512d-85a7-4b89604cb26b', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'delegated_access:SUPPORT_TARGET_ALL_SERVICES', 'Support grant target: all services', false, true, now(), now(), 1),  -- delegated_access:SUPPORT_TARGET_ALL_SERVICES
  ('10510d38-c6cf-5243-9327-5cefc6c3aee5', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'delegated_access:SUPPORT_TARGET_LOCATION', 'Support grant target: location', false, true, now(), now(), 1),  -- delegated_access:SUPPORT_TARGET_LOCATION
  ('785d1671-5754-58d3-b1a3-e3cd467b82b7', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'delegated_access:SUPPORT_TARGET_PRACTITIONER', 'Support grant target: practitioner', false, true, now(), now(), 1),  -- delegated_access:SUPPORT_TARGET_PRACTITIONER
  ('2ed23be8-884f-5e75-bd63-a1ff92f42e89', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'delegated_access:SUPPORT_TARGET_PRACTITIONER_LOCATION', 'Support grant target: practitioner location', false, true, now(), now(), 1),  -- delegated_access:SUPPORT_TARGET_PRACTITIONER_LOCATION
  ('19ff6b5b-b998-54bb-af93-573b96764a6c', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'delegated_access:SUPPORT_TARGET_PRACTITIONER_SERVICE', 'Support grant target: practitioner service', false, true, now(), now(), 1),  -- delegated_access:SUPPORT_TARGET_PRACTITIONER_SERVICE
  ('953e4408-5e19-521b-a25a-3d062d788911', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'delegated_access:SUPPORT_TARGET_SERVICE', 'Support grant target: service', false, true, now(), now(), 1),  -- delegated_access:SUPPORT_TARGET_SERVICE
  ('cf017e3e-4c7f-5e2f-a7ca-2f2078eb89b3', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'delegated_access:SUPPORT_TARGET_SERVICE_LOCATION', 'Support grant target: service location', false, true, now(), now(), 1),  -- delegated_access:SUPPORT_TARGET_SERVICE_LOCATION
  ('e970ef04-bed6-55d1-9708-0efdba380208', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'demo-hospital-piloto:service:CARDIOLOGIA', 'Consulta de cardiología (DEMO)', false, true, now(), now(), 1),  -- demo-hospital-piloto:service:CARDIOLOGIA
  ('14978504-587a-504e-8c54-35e074c8b3c4', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'demo-hospital-piloto:service:CIRUGIA_GENERAL', 'Consulta de cirugía general (DEMO)', false, true, now(), now(), 1),  -- demo-hospital-piloto:service:CIRUGIA_GENERAL
  ('c9c90aea-8d91-56bd-8b8c-bc79a91c004a', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'demo-hospital-piloto:service:CONSULTA_GENERAL', 'Consulta general (DEMO)', false, true, now(), now(), 1),  -- demo-hospital-piloto:service:CONSULTA_GENERAL
  ('5a3836d9-b3b2-5273-b67d-d315b6f9f9fd', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'demo-hospital-piloto:service:ECOCARDIOGRAMA', 'Ecocardiograma (DEMO)', false, true, now(), now(), 1),  -- demo-hospital-piloto:service:ECOCARDIOGRAMA
  ('6cc05c51-c41d-5e9a-a2db-7406966694a6', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'demo-hospital-piloto:service:ECOGRAFIA', 'Ecografía (DEMO)', false, true, now(), now(), 1),  -- demo-hospital-piloto:service:ECOGRAFIA
  ('75b7b274-7e69-55e5-9e23-db05ddab4b08', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'demo-hospital-piloto:service:ECO_OBSTETRICA', 'Ecografía obstétrica (DEMO)', false, true, now(), now(), 1),  -- demo-hospital-piloto:service:ECO_OBSTETRICA
  ('f30d2eb3-60d2-5d4a-bdae-47343fc00d0f', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'demo-hospital-piloto:service:GINECOLOGIA', 'Consulta de ginecología (DEMO)', false, true, now(), now(), 1),  -- demo-hospital-piloto:service:GINECOLOGIA
  ('29c619c6-abf1-551d-a817-d75f69f01d73', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'demo-hospital-piloto:service:MEDICINA_INTERNA', 'Consulta de medicina interna (DEMO)', false, true, now(), now(), 1),  -- demo-hospital-piloto:service:MEDICINA_INTERNA
  ('acf443ba-b6d7-5117-913b-40feeb00d1c0', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'demo-hospital-piloto:service:PEDIATRIA', 'Consulta de pediatría (DEMO)', false, true, now(), now(), 1),  -- demo-hospital-piloto:service:PEDIATRIA
  ('7908abfd-3a3e-5bbd-86c8-f06451db8793', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'demo-hospital-piloto:service:TOMOGRAFIA', 'Tomografía (DEMO)', false, true, now(), now(), 1),  -- demo-hospital-piloto:service:TOMOGRAFIA
  ('a22519f1-1eaf-537a-94c3-af190fe5cb0a', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'demo-hospital-piloto:service:TRAUMATOLOGIA', 'Consulta de traumatología (DEMO)', false, true, now(), now(), 1),  -- demo-hospital-piloto:service:TRAUMATOLOGIA
  ('ba78fe78-e802-5a35-b51e-0d38ceea7aac', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'directory:AFFILIATION_INVITE_ACTIVE', 'Affiliation invitation active', false, true, now(), now(), 1),  -- directory:AFFILIATION_INVITE_ACTIVE
  ('52bdabd7-4959-53db-ab5c-da5f1ac0a5b8', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'directory:AFFILIATION_INVITE_EXHAUSTED', 'Affiliation invitation exhausted', false, true, now(), now(), 1),  -- directory:AFFILIATION_INVITE_EXHAUSTED
  ('c7960421-256b-5d8d-a2a1-6f1ac6a1b4c8', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'directory:AFFILIATION_INVITE_EXPIRED', 'Affiliation invitation expired', false, true, now(), now(), 1),  -- directory:AFFILIATION_INVITE_EXPIRED
  ('4035d1ea-b619-59d3-8175-ea5d1f467284', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'directory:AFFILIATION_INVITE_KIND_PRACTITIONER', 'Affiliation invitation for a practitioner', false, true, now(), now(), 1),  -- directory:AFFILIATION_INVITE_KIND_PRACTITIONER
  ('41cc4a3e-11bb-5611-ab5b-ff91a4ae9f8f', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'directory:AFFILIATION_INVITE_KIND_SUPPORT_STAFF', 'Affiliation invitation for support staff', false, true, now(), now(), 1),  -- directory:AFFILIATION_INVITE_KIND_SUPPORT_STAFF
  ('3681c086-3504-5f49-936b-e99e52303244', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'directory:AFFILIATION_INVITE_REVOKED', 'Affiliation invitation revoked', false, true, now(), now(), 1),  -- directory:AFFILIATION_INVITE_REVOKED
  ('659f9beb-ad4d-583e-828b-05a808ad08dc', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'directory:AFFILIATION_USE_ACCEPTED', 'Invitation use accepted', false, true, now(), now(), 1),  -- directory:AFFILIATION_USE_ACCEPTED
  ('ea71ebf5-2886-5a88-a142-91f3b8edb8dd', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'directory:AFFILIATION_USE_ALREADY_MEMBER', 'Invitation use rejected: already a member', false, true, now(), now(), 1),  -- directory:AFFILIATION_USE_ALREADY_MEMBER
  ('0a70e58a-9e77-5ffa-b4c8-8c2867cffc4b', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'directory:AFFILIATION_USE_REJECTED_EXHAUSTED', 'Invitation use rejected: exhausted', false, true, now(), now(), 1),  -- directory:AFFILIATION_USE_REJECTED_EXHAUSTED
  ('efa1442f-e0b5-5541-8090-2bdec97598e5', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'directory:AFFILIATION_USE_REJECTED_EXPIRED', 'Invitation use rejected: expired', false, true, now(), now(), 1),  -- directory:AFFILIATION_USE_REJECTED_EXPIRED
  ('c4766b03-5723-5ad0-922b-a6e25b8acf2d', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'directory:AFFILIATION_USE_REJECTED_REVOKED', 'Invitation use rejected: revoked', false, true, now(), now(), 1),  -- directory:AFFILIATION_USE_REJECTED_REVOKED
  ('13ca1b46-61d5-5c25-9d49-8247bcd7769c', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'directory:MEMBERSHIP_ACTIVE', 'Membership active', false, true, now(), now(), 1),  -- directory:MEMBERSHIP_ACTIVE
  ('76d35f5f-5140-55be-9853-ee1dfe6a12fd', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'directory:MEMBERSHIP_ENDED', 'Membership ended', false, true, now(), now(), 1),  -- directory:MEMBERSHIP_ENDED (05-verifica lo usa en la comprobación de membresía terminada)
  ('0fe54eed-1e2f-5885-aba2-fc46f1058cb7', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'directory:ROLE_OWNER', 'Tenant owner', false, true, now(), now(), 1),  -- directory:ROLE_OWNER
  ('9384ffcc-901f-5fb3-a9d6-2c1593d7f019', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'directory:ROLE_PRACTITIONER', 'Tenant practitioner', false, true, now(), now(), 1),  -- directory:ROLE_PRACTITIONER
  ('be676db1-0700-5b0f-892b-232cafd15afc', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'directory:ROLE_STAFF', 'Tenant staff', false, true, now(), now(), 1),  -- directory:ROLE_STAFF
  ('297d044a-a1e9-51db-8f96-68f4de6b3d62', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'directory:SCOPE_ALL_TENANT', 'All-tenant access scope', false, true, now(), now(), 1),  -- directory:SCOPE_ALL_TENANT
  ('f13fb5a6-e3b9-5d5d-bf90-f551a17b40c0', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'COMPANY', 'Company', false, true, now(), now(), 1),  -- directory:legal-entity:company
  ('4d38ec64-227a-599d-8924-21424d9a8986', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'TENANT_ACTIVE', 'Tenant active', false, true, now(), now(), 1),  -- directory:tenant-status:active
  ('2f68ad79-452a-5cba-aa7f-96f8fa2610ab', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'HOSPITAL', 'Hospital', false, true, now(), now(), 1),  -- directory:tenant-type:hospital
  ('1b191a91-244e-5965-8bc5-e6e07f1d0cb6', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'MEDICAL_OFFICE', 'Medical office', false, true, now(), now(), 1),  -- directory:tenant-type:medical-office
  ('205bce05-3eb5-5785-8aa0-6120227dc4a5', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'TENANT_VERIFIED', 'Tenant verified', false, true, now(), now(), 1),  -- directory:tenant-verification:verified
  ('1e693387-3519-57f5-9f79-dcd898435ecf', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'iam:SESSION_POLICY_SCOPE_ALL_ACCOUNTS', 'Session policy scope: all accounts', false, true, now(), now(), 1),  -- iam:SESSION_POLICY_SCOPE_ALL_ACCOUNTS
  ('028a8eb3-49f0-5bd0-a607-8237e4b52406', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'iam:SESSION_POLICY_SCOPE_ORG_STAFF', 'Session policy scope: organization staff', false, true, now(), now(), 1),  -- iam:SESSION_POLICY_SCOPE_ORG_STAFF
  ('b9137390-37e5-5de6-95cf-fc53860563fe', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'iam:SESSION_POLICY_SCOPE_ROLE', 'Session policy scope: one role', false, true, now(), now(), 1),  -- iam:SESSION_POLICY_SCOPE_ROLE
  ('37da1281-cc62-5032-b598-1eb39dc46060', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'PASSWORD', 'Password credential', false, true, now(), now(), 1),  -- iam:cred-method:password
  ('646c89e7-29d5-5450-a4c6-17817fe55aa9', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'ARGON2ID', 'Argon2id', false, true, now(), now(), 1),  -- iam:hash-algo:argon2id
  ('e32f4e7d-cb62-56a2-b80e-4640d7c77b7c', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'MFA_DISABLED', 'MFA disabled', false, true, now(), now(), 1),  -- iam:mfa-status:disabled
  ('56e7457d-fe3d-5d96-ba23-474311a9300f', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'PRACTITIONER', 'Health practitioner', false, true, now(), now(), 1),  -- iam:role:practitioner
  ('51f28f0b-95c2-57b1-a53b-2240c7e80731', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'USER', 'Standard user', false, true, now(), now(), 1),  -- iam:role:user
  ('77b476d1-0600-54ba-9176-3670ab769435', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'SECURITY_ADMIN', 'Security administrator', false, true, now(), now(), 1),  -- iam:role:security-admin (el administrador del hospital lo necesita: /org/* exige SECURITY_ADMIN)
  ('32dbed9f-cf1f-5c7a-9070-dfb937cf68a1', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'USER_ACTIVE', 'User active', false, true, now(), now(), 1),  -- iam:user-status:active
  ('efb52323-17eb-5282-81b9-1d19d2115a6d', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'practice:PRACTICE_ACTIVE', 'Practice active', false, true, now(), now(), 1),  -- practice:PRACTICE_ACTIVE
  ('c0457650-2252-5174-976e-c2d528a81925', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'practice:PRACTICE_TYPE_HOSPITAL', 'Hospital practice type', false, true, now(), now(), 1),  -- practice:PRACTICE_TYPE_HOSPITAL
  ('7d80e373-124b-5a53-b334-45033b75d313', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'practice:PRACTICE_TYPE_OFFICE', 'Medical office (consultorio) practice type', false, true, now(), now(), 1),  -- practice:PRACTICE_TYPE_OFFICE
  ('15fb063e-479c-56e6-b5d1-ebd5a36b62db', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'practice:ROLE_ASSIGNMENT_ACTIVE', 'Role assignment active', false, true, now(), now(), 1),  -- practice:ROLE_ASSIGNMENT_ACTIVE
  ('11fbd446-3e81-594d-b450-164d7c496c46', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'practice:ROLE_ATTENDING', 'Attending practitioner role', false, true, now(), now(), 1),  -- practice:ROLE_ATTENDING
  ('052058be-3c92-55ff-aefc-97395828be43', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'practice:SERVICE_ACTIVE', 'Healthcare service active', false, true, now(), now(), 1),  -- practice:SERVICE_ACTIVE
  ('64f1b3bf-78e2-5904-8a62-811edde0f779', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'practice:SETTING_CATEGORY_GENERAL', 'General setting category', false, true, now(), now(), 1),  -- practice:SETTING_CATEGORY_GENERAL
  ('5cfdf9bf-2b30-5c8f-9808-d8e858f11fab', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'practice:SITE_ACTIVE', 'Site active', false, true, now(), now(), 1),  -- practice:SITE_ACTIVE
  ('e76551c9-8ec3-566a-b573-101f2c0fbfc1', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'practice:SITE_TYPE_HOSPITAL', 'Hospital site type', false, true, now(), now(), 1),  -- practice:SITE_TYPE_HOSPITAL
  ('0df1a954-ee01-5fb2-bb91-90b1d838061c', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'practice:SITE_TYPE_OFFICE', 'Medical office (consultorio) site type', false, true, now(), now(), 1),  -- practice:SITE_TYPE_OFFICE
  ('9c27f70c-9472-5bee-92e7-78e209d581c7', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'practice:SPACE_ACTIVE', 'Care space active', false, true, now(), now(), 1),  -- practice:SPACE_ACTIVE
  ('7ce5a926-1c46-56d4-8ca8-679e7429fa1d', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'practice:SPACE_OP_AVAILABLE', 'Care space available', false, true, now(), now(), 1),  -- practice:SPACE_OP_AVAILABLE
  ('a05823ae-7bd1-5615-a8e3-7fcef8c185db', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'practice:SPACE_TYPE_BED', 'Bed care space type', false, true, now(), now(), 1),  -- practice:SPACE_TYPE_BED
  ('0273c9c6-a093-5a20-9096-19558961fbd8', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'practice:SPACE_TYPE_BUILDING', 'Building care space type', false, true, now(), now(), 1),  -- practice:SPACE_TYPE_BUILDING
  ('bcc7b209-6dc7-5e9b-808d-1d3575ae9aae', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'practice:SPACE_TYPE_CONSULTING_ROOM', 'Consulting room care space type', false, true, now(), now(), 1),  -- practice:SPACE_TYPE_CONSULTING_ROOM
  ('d8746e07-5bca-5a23-9849-9e5a76f8018b', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'practice:SPACE_TYPE_LEVEL', 'Level (floor) care space type', false, true, now(), now(), 1),  -- practice:SPACE_TYPE_LEVEL
  ('6e1e85c1-973a-57f5-8f31-92f4cdb8de4d', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'practice:SPACE_TYPE_OPERATING_ROOM', 'Operating room care space type', false, true, now(), now(), 1),  -- practice:SPACE_TYPE_OPERATING_ROOM
  ('61da384e-2f50-57e6-ba7c-f6c0b11102e7', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'practice:SPACE_TYPE_PROCEDURE_ROOM', 'Procedure room care space type', false, true, now(), now(), 1),  -- practice:SPACE_TYPE_PROCEDURE_ROOM
  ('7641a5f3-760f-5340-ba07-f516f9a7c1de', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'practice:SPACE_TYPE_ROOM', 'Room care space type', false, true, now(), now(), 1),  -- practice:SPACE_TYPE_ROOM
  ('af9e5cc8-bff2-5e7d-8b7a-1cc55b655d1f', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'practice:SPACE_TYPE_WING', 'Wing care space type', false, true, now(), now(), 1),  -- practice:SPACE_TYPE_WING
  ('6db29320-acc3-50f6-ac19-cb906aa96209', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'profiles:ACCOUNT_LINK_ACTIVE', 'Account link active', false, true, now(), now(), 1),  -- profiles:ACCOUNT_LINK_ACTIVE
  ('66d20226-5c40-5584-9f56-a892ac45676f', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'profiles:ACCOUNT_LINK_SELF', 'Self account link type', false, true, now(), now(), 1),  -- profiles:ACCOUNT_LINK_SELF
  ('3b904f87-050e-5cc0-bf9e-8c48ee43dc61', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'profiles:ACCOUNT_LINK_VERIFIED', 'Account link verified', false, true, now(), now(), 1),  -- profiles:ACCOUNT_LINK_VERIFIED
  ('d4939b72-ea54-524d-9021-bdca59efa37a', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'profiles:PERSON_ACTIVE', 'Person active', false, true, now(), now(), 1),  -- profiles:PERSON_ACTIVE
  ('6e5ec429-d281-5f1d-820c-2327fff172d5', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'profiles:PRACTICE_ACTIVE', 'Practice active', false, true, now(), now(), 1),  -- profiles:PRACTICE_ACTIVE
  ('3ab2aa19-69e2-5389-a82d-df0a3faf03de', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'profiles:PRACT_CATEGORY_GENERAL', 'General practitioner category', false, true, now(), now(), 1),  -- profiles:PRACT_CATEGORY_GENERAL
  ('4a2b28d1-28cc-5e84-aeab-0b6d75a9c966', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'profiles:PRACT_VERIF_VERIFIED', 'Practitioner verified', false, true, now(), now(), 1),  -- profiles:PRACT_VERIF_VERIFIED
  ('4abd7a42-a25c-5b7d-9f07-e5e844fa903c', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'profiles:VITAL_ALIVE', 'Vital status alive', false, true, now(), now(), 1),  -- profiles:VITAL_ALIVE
  ('38a1d301-f40d-5b17-a695-5e6d605f8b19', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'ACTIVE', 'Active', false, true, now(), now(), 1),  -- state:active
  ('03e151f3-be52-5ac9-bd11-e4392fff0440', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'EXPIRED', 'Expired', false, true, now(), now(), 1),  -- state:expired
  ('8d56de1d-f25e-54eb-bc54-3ab2fbc70249', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'REVOKED', 'Revoked', false, true, now(), now(), 1)  -- state:revoked
ON CONFLICT DO NOTHING;

-- Cuentas (una por persona). Sin correo real: el acceso es por documento + contraseña demo.
INSERT INTO iam.users (id, status_concept_id, display_name, time_zone, email_verified, phone_verified, mfa_status_concept_id, created_at, updated_at, row_version, must_change_password) VALUES
  ('a9dd40bb-1eb5-5b58-ae2a-06896d8c2810', '32dbed9f-cf1f-5c7a-9070-dfb937cf68a1', 'Administrador Hospital Piloto', 'America/La_Paz', true, false, 'e32f4e7d-cb62-56a2-b80e-4640d7c77b7c', now(), now(), 1, false),
  ('6a796b91-f7db-5160-97b8-f38ed8614f95', '32dbed9f-cf1f-5c7a-9070-dfb937cf68a1', 'Andrés Pérez', 'America/La_Paz', true, false, 'e32f4e7d-cb62-56a2-b80e-4640d7c77b7c', now(), now(), 1, false),
  ('9f73a942-98e1-5bab-8647-3dd8ce9916bc', '32dbed9f-cf1f-5c7a-9070-dfb937cf68a1', 'Valeria Rojas', 'America/La_Paz', true, false, 'e32f4e7d-cb62-56a2-b80e-4640d7c77b7c', now(), now(), 1, false),
  ('593a1506-cb08-57ab-845a-e6b1503f4dc4', '32dbed9f-cf1f-5c7a-9070-dfb937cf68a1', 'Martín Suárez', 'America/La_Paz', true, false, 'e32f4e7d-cb62-56a2-b80e-4640d7c77b7c', now(), now(), 1, false),
  ('9eab94a3-b02a-538e-b7a6-9e5269a7d5b5', '32dbed9f-cf1f-5c7a-9070-dfb937cf68a1', 'Carla Méndez', 'America/La_Paz', true, false, 'e32f4e7d-cb62-56a2-b80e-4640d7c77b7c', now(), now(), 1, false),
  ('2f1e1acf-2617-5bb8-bb8e-66973fb5d5d6', '32dbed9f-cf1f-5c7a-9070-dfb937cf68a1', 'Jorge Vaca', 'America/La_Paz', true, false, 'e32f4e7d-cb62-56a2-b80e-4640d7c77b7c', now(), now(), 1, false),
  ('3fdad937-0fe7-59b7-9afe-276fe61154da', '32dbed9f-cf1f-5c7a-9070-dfb937cf68a1', 'Lucía Antelo', 'America/La_Paz', true, false, 'e32f4e7d-cb62-56a2-b80e-4640d7c77b7c', now(), now(), 1, false),
  ('d54f4d6d-8073-5023-acce-76ac8be15c72', '32dbed9f-cf1f-5c7a-9070-dfb937cf68a1', 'Diego Flores', 'America/La_Paz', true, false, 'e32f4e7d-cb62-56a2-b80e-4640d7c77b7c', now(), now(), 1, false),
  ('25036a8b-fb9d-52c3-82ec-c5ca03179d75', '32dbed9f-cf1f-5c7a-9070-dfb937cf68a1', 'Paola Céspedes', 'America/La_Paz', true, false, 'e32f4e7d-cb62-56a2-b80e-4640d7c77b7c', now(), now(), 1, false),
  ('bc643859-d89d-582e-86fa-fb3f6819ee29', '32dbed9f-cf1f-5c7a-9070-dfb937cf68a1', 'Ana Gutiérrez', 'America/La_Paz', true, false, 'e32f4e7d-cb62-56a2-b80e-4640d7c77b7c', now(), now(), 1, false),
  ('2485d391-ec1c-5c0e-9888-b043d3f27321', '32dbed9f-cf1f-5c7a-9070-dfb937cf68a1', 'Lucía Paz', 'America/La_Paz', true, false, 'e32f4e7d-cb62-56a2-b80e-4640d7c77b7c', now(), now(), 1, false),
  ('1a7b8230-215a-5cc7-8788-b8b69e5c3721', '32dbed9f-cf1f-5c7a-9070-dfb937cf68a1', 'Marcos Ribera', 'America/La_Paz', true, false, 'e32f4e7d-cb62-56a2-b80e-4640d7c77b7c', now(), now(), 1, false),
  ('f2bef10b-df89-5ac8-a87e-3f6e75e9672a', '32dbed9f-cf1f-5c7a-9070-dfb937cf68a1', 'Rosa Quiroga', 'America/La_Paz', true, false, 'e32f4e7d-cb62-56a2-b80e-4640d7c77b7c', now(), now(), 1, false)
ON CONFLICT DO NOTHING;

-- Credencial de contraseña (Demo-Apoyo-2026).
INSERT INTO iam.authentication_credentials (id, user_id, method_concept_id, external_subject, secret_hash, hash_algorithm_concept_id, state_concept_id, created_at, updated_at, row_version) VALUES
  ('75f777e7-cef8-5411-9e6f-acb1bc4eaa63', 'a9dd40bb-1eb5-5b58-ae2a-06896d8c2810', '37da1281-cc62-5032-b598-1eb39dc46060', 'DEMO-ADMINISTRADOR-HOSPITAL-PILOTO', '$argon2id$v=19$m=65536,p=4,t=3$VvAW/IsJO1zOPaFyfF9Isg$35k5DPJcNuW3UX2biUugDZlWeVPNRXjZ7GX1ydtFqPE', '646c89e7-29d5-5450-a4c6-17817fe55aa9', '38a1d301-f40d-5b17-a695-5e6d605f8b19', now(), now(), 1),
  ('f2fe1f56-3a65-5970-8425-d82c7704baca', '6a796b91-f7db-5160-97b8-f38ed8614f95', '37da1281-cc62-5032-b598-1eb39dc46060', 'DEMO-ANDRES-PEREZ', '$argon2id$v=19$m=65536,p=4,t=3$VvAW/IsJO1zOPaFyfF9Isg$35k5DPJcNuW3UX2biUugDZlWeVPNRXjZ7GX1ydtFqPE', '646c89e7-29d5-5450-a4c6-17817fe55aa9', '38a1d301-f40d-5b17-a695-5e6d605f8b19', now(), now(), 1),
  ('d370f433-baa6-57ec-b02a-84888dd3b813', '9f73a942-98e1-5bab-8647-3dd8ce9916bc', '37da1281-cc62-5032-b598-1eb39dc46060', 'DEMO-VALERIA-ROJAS', '$argon2id$v=19$m=65536,p=4,t=3$VvAW/IsJO1zOPaFyfF9Isg$35k5DPJcNuW3UX2biUugDZlWeVPNRXjZ7GX1ydtFqPE', '646c89e7-29d5-5450-a4c6-17817fe55aa9', '38a1d301-f40d-5b17-a695-5e6d605f8b19', now(), now(), 1),
  ('e18d8839-bc8a-5e19-989a-f63fb60db7e4', '593a1506-cb08-57ab-845a-e6b1503f4dc4', '37da1281-cc62-5032-b598-1eb39dc46060', 'DEMO-MARTIN-SUAREZ', '$argon2id$v=19$m=65536,p=4,t=3$VvAW/IsJO1zOPaFyfF9Isg$35k5DPJcNuW3UX2biUugDZlWeVPNRXjZ7GX1ydtFqPE', '646c89e7-29d5-5450-a4c6-17817fe55aa9', '38a1d301-f40d-5b17-a695-5e6d605f8b19', now(), now(), 1),
  ('2657a724-75a0-52d1-901f-58db5e5752a8', '9eab94a3-b02a-538e-b7a6-9e5269a7d5b5', '37da1281-cc62-5032-b598-1eb39dc46060', 'DEMO-CARLA-MENDEZ', '$argon2id$v=19$m=65536,p=4,t=3$VvAW/IsJO1zOPaFyfF9Isg$35k5DPJcNuW3UX2biUugDZlWeVPNRXjZ7GX1ydtFqPE', '646c89e7-29d5-5450-a4c6-17817fe55aa9', '38a1d301-f40d-5b17-a695-5e6d605f8b19', now(), now(), 1),
  ('41589144-081e-51e7-b733-2190aed7b516', '2f1e1acf-2617-5bb8-bb8e-66973fb5d5d6', '37da1281-cc62-5032-b598-1eb39dc46060', 'DEMO-JORGE-VACA', '$argon2id$v=19$m=65536,p=4,t=3$VvAW/IsJO1zOPaFyfF9Isg$35k5DPJcNuW3UX2biUugDZlWeVPNRXjZ7GX1ydtFqPE', '646c89e7-29d5-5450-a4c6-17817fe55aa9', '38a1d301-f40d-5b17-a695-5e6d605f8b19', now(), now(), 1),
  ('79bbdf7d-a3f0-550f-a6c6-167e163a906a', '3fdad937-0fe7-59b7-9afe-276fe61154da', '37da1281-cc62-5032-b598-1eb39dc46060', 'DEMO-LUCIA-ANTELO', '$argon2id$v=19$m=65536,p=4,t=3$VvAW/IsJO1zOPaFyfF9Isg$35k5DPJcNuW3UX2biUugDZlWeVPNRXjZ7GX1ydtFqPE', '646c89e7-29d5-5450-a4c6-17817fe55aa9', '38a1d301-f40d-5b17-a695-5e6d605f8b19', now(), now(), 1),
  ('ec5359a6-0f44-52a3-acd8-f934515de8c8', 'd54f4d6d-8073-5023-acce-76ac8be15c72', '37da1281-cc62-5032-b598-1eb39dc46060', 'DEMO-DIEGO-FLORES', '$argon2id$v=19$m=65536,p=4,t=3$VvAW/IsJO1zOPaFyfF9Isg$35k5DPJcNuW3UX2biUugDZlWeVPNRXjZ7GX1ydtFqPE', '646c89e7-29d5-5450-a4c6-17817fe55aa9', '38a1d301-f40d-5b17-a695-5e6d605f8b19', now(), now(), 1),
  ('c6fa80b8-3a85-58e2-9f74-6edec1c94cfa', '25036a8b-fb9d-52c3-82ec-c5ca03179d75', '37da1281-cc62-5032-b598-1eb39dc46060', 'DEMO-PAOLA-CESPEDES', '$argon2id$v=19$m=65536,p=4,t=3$VvAW/IsJO1zOPaFyfF9Isg$35k5DPJcNuW3UX2biUugDZlWeVPNRXjZ7GX1ydtFqPE', '646c89e7-29d5-5450-a4c6-17817fe55aa9', '38a1d301-f40d-5b17-a695-5e6d605f8b19', now(), now(), 1),
  ('3cece94f-f249-5506-8b7c-340871b9369c', 'bc643859-d89d-582e-86fa-fb3f6819ee29', '37da1281-cc62-5032-b598-1eb39dc46060', 'DEMO-ANA-GUTIERREZ', '$argon2id$v=19$m=65536,p=4,t=3$VvAW/IsJO1zOPaFyfF9Isg$35k5DPJcNuW3UX2biUugDZlWeVPNRXjZ7GX1ydtFqPE', '646c89e7-29d5-5450-a4c6-17817fe55aa9', '38a1d301-f40d-5b17-a695-5e6d605f8b19', now(), now(), 1),
  ('5484c076-99ed-5ae3-93af-f8d116750d02', '2485d391-ec1c-5c0e-9888-b043d3f27321', '37da1281-cc62-5032-b598-1eb39dc46060', 'DEMO-LUCIA-PAZ', '$argon2id$v=19$m=65536,p=4,t=3$VvAW/IsJO1zOPaFyfF9Isg$35k5DPJcNuW3UX2biUugDZlWeVPNRXjZ7GX1ydtFqPE', '646c89e7-29d5-5450-a4c6-17817fe55aa9', '38a1d301-f40d-5b17-a695-5e6d605f8b19', now(), now(), 1),
  ('0c9ecd99-aebf-577e-8b7a-bf8530ee039a', '1a7b8230-215a-5cc7-8788-b8b69e5c3721', '37da1281-cc62-5032-b598-1eb39dc46060', 'DEMO-MARCOS-RIBERA', '$argon2id$v=19$m=65536,p=4,t=3$VvAW/IsJO1zOPaFyfF9Isg$35k5DPJcNuW3UX2biUugDZlWeVPNRXjZ7GX1ydtFqPE', '646c89e7-29d5-5450-a4c6-17817fe55aa9', '38a1d301-f40d-5b17-a695-5e6d605f8b19', now(), now(), 1),
  ('6643ad1e-550f-5e8b-a3b3-dc01eaa9069e', 'f2bef10b-df89-5ac8-a87e-3f6e75e9672a', '37da1281-cc62-5032-b598-1eb39dc46060', 'DEMO-ROSA-QUIROGA', '$argon2id$v=19$m=65536,p=4,t=3$VvAW/IsJO1zOPaFyfF9Isg$35k5DPJcNuW3UX2biUugDZlWeVPNRXjZ7GX1ydtFqPE', '646c89e7-29d5-5450-a4c6-17817fe55aa9', '38a1d301-f40d-5b17-a695-5e6d605f8b19', now(), now(), 1)
ON CONFLICT DO NOTHING;

-- Rol base USER para todos; PRACTITIONER para los doctores.
INSERT INTO iam.user_global_roles (id, user_id, role_concept_id, state_concept_id, created_at, updated_at, row_version) VALUES
  ('c93922d3-6377-5e42-852c-b35a24450a40', 'a9dd40bb-1eb5-5b58-ae2a-06896d8c2810', '51f28f0b-95c2-57b1-a53b-2240c7e80731', '38a1d301-f40d-5b17-a695-5e6d605f8b19', now(), now(), 1),
  ('2299cb9b-45eb-5039-bc20-4756985e67b9', '6a796b91-f7db-5160-97b8-f38ed8614f95', '51f28f0b-95c2-57b1-a53b-2240c7e80731', '38a1d301-f40d-5b17-a695-5e6d605f8b19', now(), now(), 1),
  ('97044e19-677c-5a39-b0ec-164210b43463', '9f73a942-98e1-5bab-8647-3dd8ce9916bc', '51f28f0b-95c2-57b1-a53b-2240c7e80731', '38a1d301-f40d-5b17-a695-5e6d605f8b19', now(), now(), 1),
  ('755b5337-832b-5c6c-a112-2b8bd42ca344', '593a1506-cb08-57ab-845a-e6b1503f4dc4', '51f28f0b-95c2-57b1-a53b-2240c7e80731', '38a1d301-f40d-5b17-a695-5e6d605f8b19', now(), now(), 1),
  ('b5c0049b-1520-571f-a23d-eefc8a36c938', '9eab94a3-b02a-538e-b7a6-9e5269a7d5b5', '51f28f0b-95c2-57b1-a53b-2240c7e80731', '38a1d301-f40d-5b17-a695-5e6d605f8b19', now(), now(), 1),
  ('4e6e136e-1923-5d9f-927f-cf0dc8c8eeb8', '2f1e1acf-2617-5bb8-bb8e-66973fb5d5d6', '51f28f0b-95c2-57b1-a53b-2240c7e80731', '38a1d301-f40d-5b17-a695-5e6d605f8b19', now(), now(), 1),
  ('afd620b8-646a-52fe-ba82-1a4d9f70c55b', '3fdad937-0fe7-59b7-9afe-276fe61154da', '51f28f0b-95c2-57b1-a53b-2240c7e80731', '38a1d301-f40d-5b17-a695-5e6d605f8b19', now(), now(), 1),
  ('6ed72c0c-4d18-5b32-a2d2-1864d4ae5f62', 'd54f4d6d-8073-5023-acce-76ac8be15c72', '51f28f0b-95c2-57b1-a53b-2240c7e80731', '38a1d301-f40d-5b17-a695-5e6d605f8b19', now(), now(), 1),
  ('8050468c-9ce3-5c6c-b78e-7b62c4d34be3', '25036a8b-fb9d-52c3-82ec-c5ca03179d75', '51f28f0b-95c2-57b1-a53b-2240c7e80731', '38a1d301-f40d-5b17-a695-5e6d605f8b19', now(), now(), 1),
  ('deb3306f-4cd8-523e-832c-1fad15d5c8ee', 'bc643859-d89d-582e-86fa-fb3f6819ee29', '51f28f0b-95c2-57b1-a53b-2240c7e80731', '38a1d301-f40d-5b17-a695-5e6d605f8b19', now(), now(), 1),
  ('1b428fc3-c206-528f-8a4e-9ae2a79acf42', '2485d391-ec1c-5c0e-9888-b043d3f27321', '51f28f0b-95c2-57b1-a53b-2240c7e80731', '38a1d301-f40d-5b17-a695-5e6d605f8b19', now(), now(), 1),
  ('dc933b6f-5365-58d9-98f5-ac6b68af4268', '1a7b8230-215a-5cc7-8788-b8b69e5c3721', '51f28f0b-95c2-57b1-a53b-2240c7e80731', '38a1d301-f40d-5b17-a695-5e6d605f8b19', now(), now(), 1),
  ('194acc8c-4e78-5ba7-b98f-3cbfe4aac899', 'f2bef10b-df89-5ac8-a87e-3f6e75e9672a', '51f28f0b-95c2-57b1-a53b-2240c7e80731', '38a1d301-f40d-5b17-a695-5e6d605f8b19', now(), now(), 1),
  ('3e916f56-5d97-5381-b992-844be6a3ec30', '6a796b91-f7db-5160-97b8-f38ed8614f95', '56e7457d-fe3d-5d96-ba23-474311a9300f', '38a1d301-f40d-5b17-a695-5e6d605f8b19', now(), now(), 1),
  ('948e2589-b161-599f-9f8d-3a0a7058301b', '9f73a942-98e1-5bab-8647-3dd8ce9916bc', '56e7457d-fe3d-5d96-ba23-474311a9300f', '38a1d301-f40d-5b17-a695-5e6d605f8b19', now(), now(), 1),
  ('8c461ef1-02d2-5b6a-9e89-2c13971b0abe', '593a1506-cb08-57ab-845a-e6b1503f4dc4', '56e7457d-fe3d-5d96-ba23-474311a9300f', '38a1d301-f40d-5b17-a695-5e6d605f8b19', now(), now(), 1),
  ('07f24c85-d080-561e-a9f4-879423fa9e80', '9eab94a3-b02a-538e-b7a6-9e5269a7d5b5', '56e7457d-fe3d-5d96-ba23-474311a9300f', '38a1d301-f40d-5b17-a695-5e6d605f8b19', now(), now(), 1),
  ('0b51bd00-b914-5051-8304-62dfc0ddda58', '2f1e1acf-2617-5bb8-bb8e-66973fb5d5d6', '56e7457d-fe3d-5d96-ba23-474311a9300f', '38a1d301-f40d-5b17-a695-5e6d605f8b19', now(), now(), 1),
  ('93044072-1356-5abc-a973-8444448e9b8d', '3fdad937-0fe7-59b7-9afe-276fe61154da', '56e7457d-fe3d-5d96-ba23-474311a9300f', '38a1d301-f40d-5b17-a695-5e6d605f8b19', now(), now(), 1),
  ('733f9501-31ec-5102-86d3-ffc0a5158243', 'd54f4d6d-8073-5023-acce-76ac8be15c72', '56e7457d-fe3d-5d96-ba23-474311a9300f', '38a1d301-f40d-5b17-a695-5e6d605f8b19', now(), now(), 1),
  ('80b13858-3065-57db-9286-052590b6f3f9', '25036a8b-fb9d-52c3-82ec-c5ca03179d75', '56e7457d-fe3d-5d96-ba23-474311a9300f', '38a1d301-f40d-5b17-a695-5e6d605f8b19', now(), now(), 1)
ON CONFLICT DO NOTHING;

-- El administrador del hospital es SECURITY_ADMIN (las rutas /org/* de gobierno y de seguridad exigen ese rol; con solo USER dan 403
-- ROLE_INSUFFICIENT). Mismo id de fila que 07-gobierno-hospital-piloto.sql, así correr 04, 07 o ambos no duplica nada.
INSERT INTO iam.user_global_roles (id, user_id, role_concept_id, state_concept_id, created_at, updated_at, row_version) VALUES
  ('1fc2dfdb-0d3c-5655-b545-890d00e8ffbf', 'a9dd40bb-1eb5-5b58-ae2a-06896d8c2810', '77b476d1-0600-54ba-9176-3670ab769435', '38a1d301-f40d-5b17-a695-5e6d605f8b19', now(), now(), 1)
ON CONFLICT DO NOTHING;

-- Personas.
INSERT INTO profiles.persons (id, person_status_concept_id, name, last_name, mother_last_name, display_name, vital_status_concept_id, created_at, updated_at, row_version) VALUES
  ('9ecd84b8-69ea-590c-addd-9ef76bfae44b', 'd4939b72-ea54-524d-9021-bdca59efa37a', 'Administrador', 'Hospital', 'Piloto', 'Administrador Hospital Piloto', '4abd7a42-a25c-5b7d-9f07-e5e844fa903c', now(), now(), 1),
  ('96307267-f432-5fd2-9bd0-e609625088ab', 'd4939b72-ea54-524d-9021-bdca59efa37a', 'Andrés', 'Pérez', NULL, 'Andrés Pérez', '4abd7a42-a25c-5b7d-9f07-e5e844fa903c', now(), now(), 1),
  ('2af4ef83-2676-5032-ab17-ffef12c48e47', 'd4939b72-ea54-524d-9021-bdca59efa37a', 'Valeria', 'Rojas', NULL, 'Valeria Rojas', '4abd7a42-a25c-5b7d-9f07-e5e844fa903c', now(), now(), 1),
  ('fe30dd79-cad3-567e-ac02-8f3ee5f27bf9', 'd4939b72-ea54-524d-9021-bdca59efa37a', 'Martín', 'Suárez', NULL, 'Martín Suárez', '4abd7a42-a25c-5b7d-9f07-e5e844fa903c', now(), now(), 1),
  ('4a443ffa-92e4-5015-86a5-2d51c726bf76', 'd4939b72-ea54-524d-9021-bdca59efa37a', 'Carla', 'Méndez', NULL, 'Carla Méndez', '4abd7a42-a25c-5b7d-9f07-e5e844fa903c', now(), now(), 1),
  ('4e8d2bae-d062-5b9c-8364-c371e9ce3efa', 'd4939b72-ea54-524d-9021-bdca59efa37a', 'Jorge', 'Vaca', NULL, 'Jorge Vaca', '4abd7a42-a25c-5b7d-9f07-e5e844fa903c', now(), now(), 1),
  ('569fa481-abe1-5b70-ba9e-add5bd4dbf54', 'd4939b72-ea54-524d-9021-bdca59efa37a', 'Lucía', 'Antelo', NULL, 'Lucía Antelo', '4abd7a42-a25c-5b7d-9f07-e5e844fa903c', now(), now(), 1),
  ('92c8b351-3f6c-5dd8-b14c-7f2b815f4b83', 'd4939b72-ea54-524d-9021-bdca59efa37a', 'Diego', 'Flores', NULL, 'Diego Flores', '4abd7a42-a25c-5b7d-9f07-e5e844fa903c', now(), now(), 1),
  ('aa68f795-8e80-5f57-8d12-27535bd5a146', 'd4939b72-ea54-524d-9021-bdca59efa37a', 'Paola', 'Céspedes', NULL, 'Paola Céspedes', '4abd7a42-a25c-5b7d-9f07-e5e844fa903c', now(), now(), 1),
  ('3ad1ac1b-63b2-5b9f-9b99-06bb2ac64972', 'd4939b72-ea54-524d-9021-bdca59efa37a', 'Ana', 'Gutiérrez', NULL, 'Ana Gutiérrez', '4abd7a42-a25c-5b7d-9f07-e5e844fa903c', now(), now(), 1),
  ('2b024e9a-c915-5743-88b8-a2cd14e5bc69', 'd4939b72-ea54-524d-9021-bdca59efa37a', 'Lucía', 'Paz', NULL, 'Lucía Paz', '4abd7a42-a25c-5b7d-9f07-e5e844fa903c', now(), now(), 1),
  ('604f680e-e18d-576f-9d52-6fd1b8fbcb95', 'd4939b72-ea54-524d-9021-bdca59efa37a', 'Marcos', 'Ribera', NULL, 'Marcos Ribera', '4abd7a42-a25c-5b7d-9f07-e5e844fa903c', now(), now(), 1),
  ('2371647d-c572-5d65-8bad-f29bb427f52c', 'd4939b72-ea54-524d-9021-bdca59efa37a', 'Rosa', 'Quiroga', NULL, 'Rosa Quiroga', '4abd7a42-a25c-5b7d-9f07-e5e844fa903c', now(), now(), 1)
ON CONFLICT DO NOTHING;

-- Cada cuenta es titular de su persona.
INSERT INTO profiles.person_account_links (id, person_id, user_id, link_type_concept_id, verification_status_concept_id, valid_from, status_concept_id, created_at, updated_at, row_version) VALUES
  ('a078fa9d-54f6-547b-8ef6-69741f9689d8', '9ecd84b8-69ea-590c-addd-9ef76bfae44b', 'a9dd40bb-1eb5-5b58-ae2a-06896d8c2810', '66d20226-5c40-5584-9f56-a892ac45676f', '3b904f87-050e-5cc0-bf9e-8c48ee43dc61', now(), '6db29320-acc3-50f6-ac19-cb906aa96209', now(), now(), 1),
  ('cf64c5b0-9029-5e9c-8b63-ee8b8307f95b', '96307267-f432-5fd2-9bd0-e609625088ab', '6a796b91-f7db-5160-97b8-f38ed8614f95', '66d20226-5c40-5584-9f56-a892ac45676f', '3b904f87-050e-5cc0-bf9e-8c48ee43dc61', now(), '6db29320-acc3-50f6-ac19-cb906aa96209', now(), now(), 1),
  ('6bc72db9-9f1d-5105-b5d7-8685cbee2176', '2af4ef83-2676-5032-ab17-ffef12c48e47', '9f73a942-98e1-5bab-8647-3dd8ce9916bc', '66d20226-5c40-5584-9f56-a892ac45676f', '3b904f87-050e-5cc0-bf9e-8c48ee43dc61', now(), '6db29320-acc3-50f6-ac19-cb906aa96209', now(), now(), 1),
  ('fa4bc08b-a002-59f9-b4de-9198c2518a74', 'fe30dd79-cad3-567e-ac02-8f3ee5f27bf9', '593a1506-cb08-57ab-845a-e6b1503f4dc4', '66d20226-5c40-5584-9f56-a892ac45676f', '3b904f87-050e-5cc0-bf9e-8c48ee43dc61', now(), '6db29320-acc3-50f6-ac19-cb906aa96209', now(), now(), 1),
  ('7b5bbb02-eb29-539c-8ad7-34317432c5f0', '4a443ffa-92e4-5015-86a5-2d51c726bf76', '9eab94a3-b02a-538e-b7a6-9e5269a7d5b5', '66d20226-5c40-5584-9f56-a892ac45676f', '3b904f87-050e-5cc0-bf9e-8c48ee43dc61', now(), '6db29320-acc3-50f6-ac19-cb906aa96209', now(), now(), 1),
  ('38ffda19-9f4f-5649-9966-eada300c856e', '4e8d2bae-d062-5b9c-8364-c371e9ce3efa', '2f1e1acf-2617-5bb8-bb8e-66973fb5d5d6', '66d20226-5c40-5584-9f56-a892ac45676f', '3b904f87-050e-5cc0-bf9e-8c48ee43dc61', now(), '6db29320-acc3-50f6-ac19-cb906aa96209', now(), now(), 1),
  ('ed6ee02d-efb4-57ae-af6f-ce9f0b8f67ca', '569fa481-abe1-5b70-ba9e-add5bd4dbf54', '3fdad937-0fe7-59b7-9afe-276fe61154da', '66d20226-5c40-5584-9f56-a892ac45676f', '3b904f87-050e-5cc0-bf9e-8c48ee43dc61', now(), '6db29320-acc3-50f6-ac19-cb906aa96209', now(), now(), 1),
  ('f1dd7c8a-2fde-5341-9682-ee0e29d8401d', '92c8b351-3f6c-5dd8-b14c-7f2b815f4b83', 'd54f4d6d-8073-5023-acce-76ac8be15c72', '66d20226-5c40-5584-9f56-a892ac45676f', '3b904f87-050e-5cc0-bf9e-8c48ee43dc61', now(), '6db29320-acc3-50f6-ac19-cb906aa96209', now(), now(), 1),
  ('ebb44045-c297-5966-aa6c-7928926205cc', 'aa68f795-8e80-5f57-8d12-27535bd5a146', '25036a8b-fb9d-52c3-82ec-c5ca03179d75', '66d20226-5c40-5584-9f56-a892ac45676f', '3b904f87-050e-5cc0-bf9e-8c48ee43dc61', now(), '6db29320-acc3-50f6-ac19-cb906aa96209', now(), now(), 1),
  ('21f103d4-c6f5-5dd2-ac14-e722ab6f8833', '3ad1ac1b-63b2-5b9f-9b99-06bb2ac64972', 'bc643859-d89d-582e-86fa-fb3f6819ee29', '66d20226-5c40-5584-9f56-a892ac45676f', '3b904f87-050e-5cc0-bf9e-8c48ee43dc61', now(), '6db29320-acc3-50f6-ac19-cb906aa96209', now(), now(), 1),
  ('80882e7a-4286-5741-a7ee-16c64a335df1', '2b024e9a-c915-5743-88b8-a2cd14e5bc69', '2485d391-ec1c-5c0e-9888-b043d3f27321', '66d20226-5c40-5584-9f56-a892ac45676f', '3b904f87-050e-5cc0-bf9e-8c48ee43dc61', now(), '6db29320-acc3-50f6-ac19-cb906aa96209', now(), now(), 1),
  ('5d314af5-48ca-54bb-b08a-e3816f3dc14c', '604f680e-e18d-576f-9d52-6fd1b8fbcb95', '1a7b8230-215a-5cc7-8788-b8b69e5c3721', '66d20226-5c40-5584-9f56-a892ac45676f', '3b904f87-050e-5cc0-bf9e-8c48ee43dc61', now(), '6db29320-acc3-50f6-ac19-cb906aa96209', now(), now(), 1),
  ('77b0da45-be5c-5922-9275-ea9fb6815986', '2371647d-c572-5d65-8bad-f29bb427f52c', 'f2bef10b-df89-5ac8-a87e-3f6e75e9672a', '66d20226-5c40-5584-9f56-a892ac45676f', '3b904f87-050e-5cc0-bf9e-8c48ee43dc61', now(), '6db29320-acc3-50f6-ac19-cb906aa96209', now(), now(), 1)
ON CONFLICT DO NOTHING;

-- Perfiles profesionales de los 8 doctores.
INSERT INTO profiles.health_practitioner_profiles (profile_id, practitioner_code, practitioner_category_concept_id, professional_title, verification_status_concept_id, practice_status_concept_id, accepts_new_patients, telehealth_available, created_at, updated_at, row_version) VALUES
  ('96307267-f432-5fd2-9bd0-e609625088ab', 'DEMO-MED-001', '3ab2aa19-69e2-5389-a82d-df0a3faf03de', 'Cardiólogo', '4a2b28d1-28cc-5e84-aeab-0b6d75a9c966', '6e5ec429-d281-5f1d-820c-2327fff172d5', true, false, now(), now(), 1),
  ('2af4ef83-2676-5032-ab17-ffef12c48e47', 'DEMO-MED-002', '3ab2aa19-69e2-5389-a82d-df0a3faf03de', 'Ginecóloga y obstetra', '4a2b28d1-28cc-5e84-aeab-0b6d75a9c966', '6e5ec429-d281-5f1d-820c-2327fff172d5', true, false, now(), now(), 1),
  ('fe30dd79-cad3-567e-ac02-8f3ee5f27bf9', 'DEMO-MED-003', '3ab2aa19-69e2-5389-a82d-df0a3faf03de', 'Pediatra', '4a2b28d1-28cc-5e84-aeab-0b6d75a9c966', '6e5ec429-d281-5f1d-820c-2327fff172d5', true, false, now(), now(), 1),
  ('4a443ffa-92e4-5015-86a5-2d51c726bf76', 'DEMO-MED-004', '3ab2aa19-69e2-5389-a82d-df0a3faf03de', 'Médica internista', '4a2b28d1-28cc-5e84-aeab-0b6d75a9c966', '6e5ec429-d281-5f1d-820c-2327fff172d5', true, false, now(), now(), 1),
  ('4e8d2bae-d062-5b9c-8364-c371e9ce3efa', 'DEMO-MED-005', '3ab2aa19-69e2-5389-a82d-df0a3faf03de', 'Traumatólogo', '4a2b28d1-28cc-5e84-aeab-0b6d75a9c966', '6e5ec429-d281-5f1d-820c-2327fff172d5', true, false, now(), now(), 1),
  ('569fa481-abe1-5b70-ba9e-add5bd4dbf54', 'DEMO-MED-006', '3ab2aa19-69e2-5389-a82d-df0a3faf03de', 'Radióloga', '4a2b28d1-28cc-5e84-aeab-0b6d75a9c966', '6e5ec429-d281-5f1d-820c-2327fff172d5', true, false, now(), now(), 1),
  ('92c8b351-3f6c-5dd8-b14c-7f2b815f4b83', 'DEMO-MED-007', '3ab2aa19-69e2-5389-a82d-df0a3faf03de', 'Cirujano general', '4a2b28d1-28cc-5e84-aeab-0b6d75a9c966', '6e5ec429-d281-5f1d-820c-2327fff172d5', true, false, now(), now(), 1),
  ('aa68f795-8e80-5f57-8d12-27535bd5a146', 'DEMO-MED-008', '3ab2aa19-69e2-5389-a82d-df0a3faf03de', 'Médica general', '4a2b28d1-28cc-5e84-aeab-0b6d75a9c966', '6e5ec429-d281-5f1d-820c-2327fff172d5', true, false, now(), now(), 1)
ON CONFLICT DO NOTHING;

-- Dos organizaciones aparte: el hospital (cuenta de organización) y un consultorio privado.
INSERT INTO directory.tenants (id, code, tenant_type_concept_id, legal_name, trade_name, legal_entity_type_concept_id, status_concept_id, verification_status_concept_id, time_zone, created_at, updated_at, row_version) VALUES
  ('830e47e1-8e82-50ff-99c0-bfed0a7971a4', 'DEMO_HOSPITAL_PILOTO', '2f68ad79-452a-5cba-aa7f-96f8fa2610ab', 'Hospital Piloto Mantra', 'Hospital Piloto Mantra — datos ficticios de demostración', 'f13fb5a6-e3b9-5d5d-bf90-f551a17b40c0', '4d38ec64-227a-599d-8924-21424d9a8986', '205bce05-3eb5-5785-8aa0-6120227dc4a5', 'America/La_Paz', now(), now(), 1),
  ('a52f851c-e5c2-5a32-b99e-a4993ff5a287', 'DEMO_CONSULTORIO_CESPEDES', '1b191a91-244e-5965-8bc5-e6e07f1d0cb6', 'Consultorio Dra. Paola Céspedes', 'Consultorio Dra. Paola Céspedes — datos ficticios de demostración', 'f13fb5a6-e3b9-5d5d-bf90-f551a17b40c0', '4d38ec64-227a-599d-8924-21424d9a8986', '205bce05-3eb5-5785-8aa0-6120227dc4a5', 'America/La_Paz', now(), now(), 1)
ON CONFLICT DO NOTHING;

-- Membresías: los 7 doctores y 3 de apoyo en el hospital; Céspedes y Rosa en el consultorio.
INSERT INTO directory.tenant_memberships (id, user_id, tenant_id, tenant_role_concept_id, status_concept_id, access_scope_concept_id, start_date, created_at, updated_at, row_version) VALUES
  ('82870f33-fc8f-5d3f-88e9-b600490281d2', 'a9dd40bb-1eb5-5b58-ae2a-06896d8c2810', '830e47e1-8e82-50ff-99c0-bfed0a7971a4', '0fe54eed-1e2f-5885-aba2-fc46f1058cb7', '13ca1b46-61d5-5c25-9d49-8247bcd7769c', '297d044a-a1e9-51db-8f96-68f4de6b3d62', now(), now(), now(), 1),
  ('919ba12c-fcbb-5596-b2c2-09f0f366200d', '6a796b91-f7db-5160-97b8-f38ed8614f95', '830e47e1-8e82-50ff-99c0-bfed0a7971a4', '9384ffcc-901f-5fb3-a9d6-2c1593d7f019', '13ca1b46-61d5-5c25-9d49-8247bcd7769c', '297d044a-a1e9-51db-8f96-68f4de6b3d62', now(), now(), now(), 1),
  ('58661f73-3651-560e-9e89-28458af4d530', '9f73a942-98e1-5bab-8647-3dd8ce9916bc', '830e47e1-8e82-50ff-99c0-bfed0a7971a4', '9384ffcc-901f-5fb3-a9d6-2c1593d7f019', '13ca1b46-61d5-5c25-9d49-8247bcd7769c', '297d044a-a1e9-51db-8f96-68f4de6b3d62', now(), now(), now(), 1),
  ('ddae289b-ad87-5cf7-bd16-ca98d9a7a9c5', '593a1506-cb08-57ab-845a-e6b1503f4dc4', '830e47e1-8e82-50ff-99c0-bfed0a7971a4', '9384ffcc-901f-5fb3-a9d6-2c1593d7f019', '13ca1b46-61d5-5c25-9d49-8247bcd7769c', '297d044a-a1e9-51db-8f96-68f4de6b3d62', now(), now(), now(), 1),
  ('6706879f-f8cf-5b49-9ab5-32ece5fd8e14', '9eab94a3-b02a-538e-b7a6-9e5269a7d5b5', '830e47e1-8e82-50ff-99c0-bfed0a7971a4', '9384ffcc-901f-5fb3-a9d6-2c1593d7f019', '13ca1b46-61d5-5c25-9d49-8247bcd7769c', '297d044a-a1e9-51db-8f96-68f4de6b3d62', now(), now(), now(), 1),
  ('82ebafaa-d1c0-5c6a-826e-4cabc50353e7', '2f1e1acf-2617-5bb8-bb8e-66973fb5d5d6', '830e47e1-8e82-50ff-99c0-bfed0a7971a4', '9384ffcc-901f-5fb3-a9d6-2c1593d7f019', '13ca1b46-61d5-5c25-9d49-8247bcd7769c', '297d044a-a1e9-51db-8f96-68f4de6b3d62', now(), now(), now(), 1),
  ('058708fc-54ab-5e08-bcfa-74d45b0b8f22', '3fdad937-0fe7-59b7-9afe-276fe61154da', '830e47e1-8e82-50ff-99c0-bfed0a7971a4', '9384ffcc-901f-5fb3-a9d6-2c1593d7f019', '13ca1b46-61d5-5c25-9d49-8247bcd7769c', '297d044a-a1e9-51db-8f96-68f4de6b3d62', now(), now(), now(), 1),
  ('e2e02baa-b926-5c51-941f-ae051b6909cd', 'd54f4d6d-8073-5023-acce-76ac8be15c72', '830e47e1-8e82-50ff-99c0-bfed0a7971a4', '9384ffcc-901f-5fb3-a9d6-2c1593d7f019', '13ca1b46-61d5-5c25-9d49-8247bcd7769c', '297d044a-a1e9-51db-8f96-68f4de6b3d62', now(), now(), now(), 1),
  ('acfb9d27-1a45-59aa-bcf0-3ab41d6fb954', 'bc643859-d89d-582e-86fa-fb3f6819ee29', '830e47e1-8e82-50ff-99c0-bfed0a7971a4', 'be676db1-0700-5b0f-892b-232cafd15afc', '13ca1b46-61d5-5c25-9d49-8247bcd7769c', '297d044a-a1e9-51db-8f96-68f4de6b3d62', now(), now(), now(), 1),
  ('5daf7732-61df-5723-8272-e0442affb385', '2485d391-ec1c-5c0e-9888-b043d3f27321', '830e47e1-8e82-50ff-99c0-bfed0a7971a4', 'be676db1-0700-5b0f-892b-232cafd15afc', '13ca1b46-61d5-5c25-9d49-8247bcd7769c', '297d044a-a1e9-51db-8f96-68f4de6b3d62', now(), now(), now(), 1),
  ('bf74d532-44d6-5a9d-981c-8fb019d24b46', '1a7b8230-215a-5cc7-8788-b8b69e5c3721', '830e47e1-8e82-50ff-99c0-bfed0a7971a4', 'be676db1-0700-5b0f-892b-232cafd15afc', '13ca1b46-61d5-5c25-9d49-8247bcd7769c', '297d044a-a1e9-51db-8f96-68f4de6b3d62', now(), now(), now(), 1),
  ('79350e95-ec07-5310-a371-9816be26edae', '25036a8b-fb9d-52c3-82ec-c5ca03179d75', 'a52f851c-e5c2-5a32-b99e-a4993ff5a287', '0fe54eed-1e2f-5885-aba2-fc46f1058cb7', '13ca1b46-61d5-5c25-9d49-8247bcd7769c', '297d044a-a1e9-51db-8f96-68f4de6b3d62', now(), now(), now(), 1),
  ('802edee6-aea4-56d2-aeef-9e9a3acc9eb6', 'f2bef10b-df89-5ac8-a87e-3f6e75e9672a', 'a52f851c-e5c2-5a32-b99e-a4993ff5a287', 'be676db1-0700-5b0f-892b-232cafd15afc', '13ca1b46-61d5-5c25-9d49-8247bcd7769c', '297d044a-a1e9-51db-8f96-68f4de6b3d62', now(), now(), now(), 1)
ON CONFLICT DO NOTHING;

-- Prácticas.
INSERT INTO practice.practices (id, tenant_id, code, name, type_concept_id, admin_user_id, time_zone, status_concept_id, created_at, updated_at, row_version) VALUES
  ('314eeab4-0062-5e4f-b3f1-4e26174daa10', '830e47e1-8e82-50ff-99c0-bfed0a7971a4', 'DEMO_HOSPITAL_PILOTO', 'Hospital Piloto Mantra', 'c0457650-2252-5174-976e-c2d528a81925', 'a9dd40bb-1eb5-5b58-ae2a-06896d8c2810', 'America/La_Paz', 'efb52323-17eb-5282-81b9-1d19d2115a6d', now(), now(), 1),
  ('b248aef6-7047-5128-90bd-e2d75225b5fe', 'a52f851c-e5c2-5a32-b99e-a4993ff5a287', 'DEMO_CONSULTORIO_CESPEDES', 'Consultorio Dra. Paola Céspedes', '7d80e373-124b-5a53-b334-45033b75d313', '25036a8b-fb9d-52c3-82ec-c5ca03179d75', 'America/La_Paz', 'efb52323-17eb-5282-81b9-1d19d2115a6d', now(), now(), 1)
ON CONFLICT DO NOTHING;

-- Interruptor por organización `org_account_mode` (ORGANIZATION = cuenta de organización; PERSON = cuenta personal).
INSERT INTO practice.practice_settings (id, practice_id, setting_key, value_json, category_concept_id, created_at, updated_at, row_version) VALUES
  ('83cc97ec-18ed-550f-966d-da27a88c35f6', '314eeab4-0062-5e4f-b3f1-4e26174daa10', 'org_account_mode', '"ORGANIZATION"'::jsonb, '64f1b3bf-78e2-5904-8a62-811edde0f779', now(), now(), 1),
  ('22ae701d-457c-5e2f-a287-0b503da71f73', '314eeab4-0062-5e4f-b3f1-4e26174daa10', 'demo_dataset', 'true'::jsonb, '64f1b3bf-78e2-5904-8a62-811edde0f779', now(), now(), 1),
  ('c99494a7-fecb-5208-b3c1-499f9fae0464', 'b248aef6-7047-5128-90bd-e2d75225b5fe', 'org_account_mode', '"PERSON"'::jsonb, '64f1b3bf-78e2-5904-8a62-811edde0f779', now(), now(), 1)
ON CONFLICT DO NOTHING;

-- Sedes.
INSERT INTO practice.practice_sites (id, practice_id, code, name, site_type_concept_id, time_zone, status_concept_id, created_at, updated_at, row_version) VALUES
  ('ff4d09cd-e920-57c2-815f-d262dfd9f221', '314eeab4-0062-5e4f-b3f1-4e26174daa10', 'DEMO_SEDE_CENTRAL', 'Sede Central', 'e76551c9-8ec3-566a-b573-101f2c0fbfc1', 'America/La_Paz', '5cfdf9bf-2b30-5c8f-9808-d8e858f11fab', now(), now(), 1),
  ('bf2841a5-e92f-5b2b-b77e-23e11712c554', '314eeab4-0062-5e4f-b3f1-4e26174daa10', 'DEMO_SEDE_NORTE', 'Sede Norte', 'e76551c9-8ec3-566a-b573-101f2c0fbfc1', 'America/La_Paz', '5cfdf9bf-2b30-5c8f-9808-d8e858f11fab', now(), now(), 1),
  ('07a7a206-533d-5827-ab51-14d021f32ea0', 'b248aef6-7047-5128-90bd-e2d75225b5fe', 'DEMO_CONSULTORIO', 'Consultorio Céspedes', '0df1a954-ee01-5fb2-bb91-90b1d838061c', 'America/La_Paz', '5cfdf9bf-2b30-5c8f-9808-d8e858f11fab', now(), now(), 1)
ON CONFLICT DO NOTHING;

-- Jerarquía Sede → Edificio → Piso → Sala/Cama, con ruta materializada (location_path).
INSERT INTO practice.care_spaces (id, practice_site_id, parent_space_id, code, name, space_type_concept_id, capacity, operational_status_concept_id, status_concept_id, fhir_physical_type, location_path, created_at, updated_at, row_version) VALUES
  ('6b1b7b48-0ed5-5f2e-9165-c1aa25e4aa2c', 'ff4d09cd-e920-57c2-815f-d262dfd9f221', NULL, 'DEMO_A', 'Edificio A', '0273c9c6-a093-5a20-9096-19558961fbd8', NULL, '7ce5a926-1c46-56d4-8ca8-679e7429fa1d', '9c27f70c-9472-5bee-92e7-78e209d581c7', 'bu', '/ff4d09cd-e920-57c2-815f-d262dfd9f221/6b1b7b48-0ed5-5f2e-9165-c1aa25e4aa2c/', now(), now(), 1),
  ('3574e5a0-0472-589b-87d8-528556f9baa1', 'ff4d09cd-e920-57c2-815f-d262dfd9f221', '6b1b7b48-0ed5-5f2e-9165-c1aa25e4aa2c', 'DEMO_A_PB', 'Edificio A · Planta baja (Admisión y Emergencias)', 'd8746e07-5bca-5a23-9849-9e5a76f8018b', NULL, '7ce5a926-1c46-56d4-8ca8-679e7429fa1d', '9c27f70c-9472-5bee-92e7-78e209d581c7', 'lvl', '/ff4d09cd-e920-57c2-815f-d262dfd9f221/6b1b7b48-0ed5-5f2e-9165-c1aa25e4aa2c/3574e5a0-0472-589b-87d8-528556f9baa1/', now(), now(), 1),
  ('8eaa9802-4274-5e66-9cc6-f0e79c260b5f', 'ff4d09cd-e920-57c2-815f-d262dfd9f221', '3574e5a0-0472-589b-87d8-528556f9baa1', 'DEMO_A_ADM', 'Admisión', '7641a5f3-760f-5340-ba07-f516f9a7c1de', NULL, '7ce5a926-1c46-56d4-8ca8-679e7429fa1d', '9c27f70c-9472-5bee-92e7-78e209d581c7', 'ro', '/ff4d09cd-e920-57c2-815f-d262dfd9f221/6b1b7b48-0ed5-5f2e-9165-c1aa25e4aa2c/3574e5a0-0472-589b-87d8-528556f9baa1/8eaa9802-4274-5e66-9cc6-f0e79c260b5f/', now(), now(), 1),
  ('d18d3bbf-a5a6-5dc6-9210-0395f1a92b97', 'ff4d09cd-e920-57c2-815f-d262dfd9f221', '3574e5a0-0472-589b-87d8-528556f9baa1', 'DEMO_A_EME', 'Emergencias', '61da384e-2f50-57e6-ba7c-f6c0b11102e7', NULL, '7ce5a926-1c46-56d4-8ca8-679e7429fa1d', '9c27f70c-9472-5bee-92e7-78e209d581c7', 'ro', '/ff4d09cd-e920-57c2-815f-d262dfd9f221/6b1b7b48-0ed5-5f2e-9165-c1aa25e4aa2c/3574e5a0-0472-589b-87d8-528556f9baa1/d18d3bbf-a5a6-5dc6-9210-0395f1a92b97/', now(), now(), 1),
  ('a5b6c244-a0ce-56e2-9d76-cdb2f3f184c1', 'ff4d09cd-e920-57c2-815f-d262dfd9f221', '6b1b7b48-0ed5-5f2e-9165-c1aa25e4aa2c', 'DEMO_A_P1', 'Edificio A · Piso 1 (Consulta externa)', 'd8746e07-5bca-5a23-9849-9e5a76f8018b', NULL, '7ce5a926-1c46-56d4-8ca8-679e7429fa1d', '9c27f70c-9472-5bee-92e7-78e209d581c7', 'lvl', '/ff4d09cd-e920-57c2-815f-d262dfd9f221/6b1b7b48-0ed5-5f2e-9165-c1aa25e4aa2c/a5b6c244-a0ce-56e2-9d76-cdb2f3f184c1/', now(), now(), 1),
  ('829b34c0-3eff-5b83-b655-a3dcb5222baf', 'ff4d09cd-e920-57c2-815f-d262dfd9f221', 'a5b6c244-a0ce-56e2-9d76-cdb2f3f184c1', 'DEMO_A_101', 'Consultorio 101', 'bcc7b209-6dc7-5e9b-808d-1d3575ae9aae', NULL, '7ce5a926-1c46-56d4-8ca8-679e7429fa1d', '9c27f70c-9472-5bee-92e7-78e209d581c7', 'ro', '/ff4d09cd-e920-57c2-815f-d262dfd9f221/6b1b7b48-0ed5-5f2e-9165-c1aa25e4aa2c/a5b6c244-a0ce-56e2-9d76-cdb2f3f184c1/829b34c0-3eff-5b83-b655-a3dcb5222baf/', now(), now(), 1),
  ('51bcce42-cbe2-5cd9-8866-2d2326b42f7e', 'ff4d09cd-e920-57c2-815f-d262dfd9f221', 'a5b6c244-a0ce-56e2-9d76-cdb2f3f184c1', 'DEMO_A_102', 'Consultorio 102', 'bcc7b209-6dc7-5e9b-808d-1d3575ae9aae', NULL, '7ce5a926-1c46-56d4-8ca8-679e7429fa1d', '9c27f70c-9472-5bee-92e7-78e209d581c7', 'ro', '/ff4d09cd-e920-57c2-815f-d262dfd9f221/6b1b7b48-0ed5-5f2e-9165-c1aa25e4aa2c/a5b6c244-a0ce-56e2-9d76-cdb2f3f184c1/51bcce42-cbe2-5cd9-8866-2d2326b42f7e/', now(), now(), 1),
  ('0feafc25-2f9c-50b7-a3c0-af4efd4e7fb1', 'ff4d09cd-e920-57c2-815f-d262dfd9f221', 'a5b6c244-a0ce-56e2-9d76-cdb2f3f184c1', 'DEMO_A_103', 'Consultorio 103', 'bcc7b209-6dc7-5e9b-808d-1d3575ae9aae', NULL, '7ce5a926-1c46-56d4-8ca8-679e7429fa1d', '9c27f70c-9472-5bee-92e7-78e209d581c7', 'ro', '/ff4d09cd-e920-57c2-815f-d262dfd9f221/6b1b7b48-0ed5-5f2e-9165-c1aa25e4aa2c/a5b6c244-a0ce-56e2-9d76-cdb2f3f184c1/0feafc25-2f9c-50b7-a3c0-af4efd4e7fb1/', now(), now(), 1),
  ('6f02480a-7725-54f2-b143-03420f83735b', 'ff4d09cd-e920-57c2-815f-d262dfd9f221', 'a5b6c244-a0ce-56e2-9d76-cdb2f3f184c1', 'DEMO_A_104', 'Consultorio 104', 'bcc7b209-6dc7-5e9b-808d-1d3575ae9aae', NULL, '7ce5a926-1c46-56d4-8ca8-679e7429fa1d', '9c27f70c-9472-5bee-92e7-78e209d581c7', 'ro', '/ff4d09cd-e920-57c2-815f-d262dfd9f221/6b1b7b48-0ed5-5f2e-9165-c1aa25e4aa2c/a5b6c244-a0ce-56e2-9d76-cdb2f3f184c1/6f02480a-7725-54f2-b143-03420f83735b/', now(), now(), 1),
  ('c6ba3db5-3f9a-5cc9-b07a-6eff8a0f3887', 'ff4d09cd-e920-57c2-815f-d262dfd9f221', 'a5b6c244-a0ce-56e2-9d76-cdb2f3f184c1', 'DEMO_A_105', 'Consultorio 105', 'bcc7b209-6dc7-5e9b-808d-1d3575ae9aae', NULL, '7ce5a926-1c46-56d4-8ca8-679e7429fa1d', '9c27f70c-9472-5bee-92e7-78e209d581c7', 'ro', '/ff4d09cd-e920-57c2-815f-d262dfd9f221/6b1b7b48-0ed5-5f2e-9165-c1aa25e4aa2c/a5b6c244-a0ce-56e2-9d76-cdb2f3f184c1/c6ba3db5-3f9a-5cc9-b07a-6eff8a0f3887/', now(), now(), 1),
  ('ac977dc9-ae3c-5f91-b689-1af58f916b59', 'ff4d09cd-e920-57c2-815f-d262dfd9f221', 'a5b6c244-a0ce-56e2-9d76-cdb2f3f184c1', 'DEMO_A_106', 'Consultorio 106', 'bcc7b209-6dc7-5e9b-808d-1d3575ae9aae', NULL, '7ce5a926-1c46-56d4-8ca8-679e7429fa1d', '9c27f70c-9472-5bee-92e7-78e209d581c7', 'ro', '/ff4d09cd-e920-57c2-815f-d262dfd9f221/6b1b7b48-0ed5-5f2e-9165-c1aa25e4aa2c/a5b6c244-a0ce-56e2-9d76-cdb2f3f184c1/ac977dc9-ae3c-5f91-b689-1af58f916b59/', now(), now(), 1),
  ('1e1cdd5e-8e76-511d-9e53-c68bf7c1b338', 'ff4d09cd-e920-57c2-815f-d262dfd9f221', 'a5b6c244-a0ce-56e2-9d76-cdb2f3f184c1', 'DEMO_A_107', 'Consultorio 107', 'bcc7b209-6dc7-5e9b-808d-1d3575ae9aae', NULL, '7ce5a926-1c46-56d4-8ca8-679e7429fa1d', '9c27f70c-9472-5bee-92e7-78e209d581c7', 'ro', '/ff4d09cd-e920-57c2-815f-d262dfd9f221/6b1b7b48-0ed5-5f2e-9165-c1aa25e4aa2c/a5b6c244-a0ce-56e2-9d76-cdb2f3f184c1/1e1cdd5e-8e76-511d-9e53-c68bf7c1b338/', now(), now(), 1),
  ('eda9be18-13c5-5c02-826c-985a01eec549', 'ff4d09cd-e920-57c2-815f-d262dfd9f221', 'a5b6c244-a0ce-56e2-9d76-cdb2f3f184c1', 'DEMO_A_108', 'Consultorio 108', 'bcc7b209-6dc7-5e9b-808d-1d3575ae9aae', NULL, '7ce5a926-1c46-56d4-8ca8-679e7429fa1d', '9c27f70c-9472-5bee-92e7-78e209d581c7', 'ro', '/ff4d09cd-e920-57c2-815f-d262dfd9f221/6b1b7b48-0ed5-5f2e-9165-c1aa25e4aa2c/a5b6c244-a0ce-56e2-9d76-cdb2f3f184c1/eda9be18-13c5-5c02-826c-985a01eec549/', now(), now(), 1),
  ('3b7beccf-e957-5776-be26-ae641fd53b3a', 'ff4d09cd-e920-57c2-815f-d262dfd9f221', '6b1b7b48-0ed5-5f2e-9165-c1aa25e4aa2c', 'DEMO_A_P2', 'Edificio A · Piso 2 (Imagen y laboratorio)', 'd8746e07-5bca-5a23-9849-9e5a76f8018b', NULL, '7ce5a926-1c46-56d4-8ca8-679e7429fa1d', '9c27f70c-9472-5bee-92e7-78e209d581c7', 'lvl', '/ff4d09cd-e920-57c2-815f-d262dfd9f221/6b1b7b48-0ed5-5f2e-9165-c1aa25e4aa2c/3b7beccf-e957-5776-be26-ae641fd53b3a/', now(), now(), 1),
  ('462ffc1f-f086-509d-b26a-487dfdb82b03', 'ff4d09cd-e920-57c2-815f-d262dfd9f221', '3b7beccf-e957-5776-be26-ae641fd53b3a', 'DEMO_A_201', 'Sala de ecografía 201', '61da384e-2f50-57e6-ba7c-f6c0b11102e7', NULL, '7ce5a926-1c46-56d4-8ca8-679e7429fa1d', '9c27f70c-9472-5bee-92e7-78e209d581c7', 'ro', '/ff4d09cd-e920-57c2-815f-d262dfd9f221/6b1b7b48-0ed5-5f2e-9165-c1aa25e4aa2c/3b7beccf-e957-5776-be26-ae641fd53b3a/462ffc1f-f086-509d-b26a-487dfdb82b03/', now(), now(), 1),
  ('0b01b451-d496-5066-9863-df9b53d6d99f', 'ff4d09cd-e920-57c2-815f-d262dfd9f221', '3b7beccf-e957-5776-be26-ae641fd53b3a', 'DEMO_A_202', 'Sala de ecografía 202', '61da384e-2f50-57e6-ba7c-f6c0b11102e7', NULL, '7ce5a926-1c46-56d4-8ca8-679e7429fa1d', '9c27f70c-9472-5bee-92e7-78e209d581c7', 'ro', '/ff4d09cd-e920-57c2-815f-d262dfd9f221/6b1b7b48-0ed5-5f2e-9165-c1aa25e4aa2c/3b7beccf-e957-5776-be26-ae641fd53b3a/0b01b451-d496-5066-9863-df9b53d6d99f/', now(), now(), 1),
  ('948ef27f-8190-51ba-b77a-cfc943b847d5', 'ff4d09cd-e920-57c2-815f-d262dfd9f221', '3b7beccf-e957-5776-be26-ae641fd53b3a', 'DEMO_A_203', 'Sala de rayos X 203', '61da384e-2f50-57e6-ba7c-f6c0b11102e7', NULL, '7ce5a926-1c46-56d4-8ca8-679e7429fa1d', '9c27f70c-9472-5bee-92e7-78e209d581c7', 'ro', '/ff4d09cd-e920-57c2-815f-d262dfd9f221/6b1b7b48-0ed5-5f2e-9165-c1aa25e4aa2c/3b7beccf-e957-5776-be26-ae641fd53b3a/948ef27f-8190-51ba-b77a-cfc943b847d5/', now(), now(), 1),
  ('65a42b85-bf3c-5163-a3bf-5710610a58c5', 'ff4d09cd-e920-57c2-815f-d262dfd9f221', '3b7beccf-e957-5776-be26-ae641fd53b3a', 'DEMO_A_204', 'Sala de tomografía 204', '61da384e-2f50-57e6-ba7c-f6c0b11102e7', NULL, '7ce5a926-1c46-56d4-8ca8-679e7429fa1d', '9c27f70c-9472-5bee-92e7-78e209d581c7', 'ro', '/ff4d09cd-e920-57c2-815f-d262dfd9f221/6b1b7b48-0ed5-5f2e-9165-c1aa25e4aa2c/3b7beccf-e957-5776-be26-ae641fd53b3a/65a42b85-bf3c-5163-a3bf-5710610a58c5/', now(), now(), 1),
  ('452108c0-2f09-5a55-85a9-cb8fd844782e', 'ff4d09cd-e920-57c2-815f-d262dfd9f221', '3b7beccf-e957-5776-be26-ae641fd53b3a', 'DEMO_A_205', 'Toma de muestras 205', '61da384e-2f50-57e6-ba7c-f6c0b11102e7', NULL, '7ce5a926-1c46-56d4-8ca8-679e7429fa1d', '9c27f70c-9472-5bee-92e7-78e209d581c7', 'ro', '/ff4d09cd-e920-57c2-815f-d262dfd9f221/6b1b7b48-0ed5-5f2e-9165-c1aa25e4aa2c/3b7beccf-e957-5776-be26-ae641fd53b3a/452108c0-2f09-5a55-85a9-cb8fd844782e/', now(), now(), 1),
  ('432fce4e-7045-59e4-a263-78a2a075f1f6', 'ff4d09cd-e920-57c2-815f-d262dfd9f221', '6b1b7b48-0ed5-5f2e-9165-c1aa25e4aa2c', 'DEMO_A_P3', 'Edificio A · Piso 3 (Quirófanos)', 'd8746e07-5bca-5a23-9849-9e5a76f8018b', NULL, '7ce5a926-1c46-56d4-8ca8-679e7429fa1d', '9c27f70c-9472-5bee-92e7-78e209d581c7', 'lvl', '/ff4d09cd-e920-57c2-815f-d262dfd9f221/6b1b7b48-0ed5-5f2e-9165-c1aa25e4aa2c/432fce4e-7045-59e4-a263-78a2a075f1f6/', now(), now(), 1),
  ('739b51f1-eb7a-5a6f-a9a6-abe3debd3c40', 'ff4d09cd-e920-57c2-815f-d262dfd9f221', '432fce4e-7045-59e4-a263-78a2a075f1f6', 'DEMO_A_Q1', 'Quirófano Q1', '6e1e85c1-973a-57f5-8f31-92f4cdb8de4d', NULL, '7ce5a926-1c46-56d4-8ca8-679e7429fa1d', '9c27f70c-9472-5bee-92e7-78e209d581c7', 'ro', '/ff4d09cd-e920-57c2-815f-d262dfd9f221/6b1b7b48-0ed5-5f2e-9165-c1aa25e4aa2c/432fce4e-7045-59e4-a263-78a2a075f1f6/739b51f1-eb7a-5a6f-a9a6-abe3debd3c40/', now(), now(), 1),
  ('255f2f59-f581-5047-a6b2-35a070adc9ff', 'ff4d09cd-e920-57c2-815f-d262dfd9f221', '432fce4e-7045-59e4-a263-78a2a075f1f6', 'DEMO_A_Q2', 'Quirófano Q2', '6e1e85c1-973a-57f5-8f31-92f4cdb8de4d', NULL, '7ce5a926-1c46-56d4-8ca8-679e7429fa1d', '9c27f70c-9472-5bee-92e7-78e209d581c7', 'ro', '/ff4d09cd-e920-57c2-815f-d262dfd9f221/6b1b7b48-0ed5-5f2e-9165-c1aa25e4aa2c/432fce4e-7045-59e4-a263-78a2a075f1f6/255f2f59-f581-5047-a6b2-35a070adc9ff/', now(), now(), 1),
  ('6d2adc79-0c3e-58a7-8627-e07049d25a65', 'ff4d09cd-e920-57c2-815f-d262dfd9f221', '432fce4e-7045-59e4-a263-78a2a075f1f6', 'DEMO_A_Q3', 'Quirófano Q3', '6e1e85c1-973a-57f5-8f31-92f4cdb8de4d', NULL, '7ce5a926-1c46-56d4-8ca8-679e7429fa1d', '9c27f70c-9472-5bee-92e7-78e209d581c7', 'ro', '/ff4d09cd-e920-57c2-815f-d262dfd9f221/6b1b7b48-0ed5-5f2e-9165-c1aa25e4aa2c/432fce4e-7045-59e4-a263-78a2a075f1f6/6d2adc79-0c3e-58a7-8627-e07049d25a65/', now(), now(), 1),
  ('9e4fd925-4bdd-5e21-94ab-3d30b83d004b', 'ff4d09cd-e920-57c2-815f-d262dfd9f221', '432fce4e-7045-59e4-a263-78a2a075f1f6', 'DEMO_A_Q4', 'Quirófano Q4', '6e1e85c1-973a-57f5-8f31-92f4cdb8de4d', NULL, '7ce5a926-1c46-56d4-8ca8-679e7429fa1d', '9c27f70c-9472-5bee-92e7-78e209d581c7', 'ro', '/ff4d09cd-e920-57c2-815f-d262dfd9f221/6b1b7b48-0ed5-5f2e-9165-c1aa25e4aa2c/432fce4e-7045-59e4-a263-78a2a075f1f6/9e4fd925-4bdd-5e21-94ab-3d30b83d004b/', now(), now(), 1),
  ('39566e10-f2e2-56ae-8fa4-da815cf3071e', 'ff4d09cd-e920-57c2-815f-d262dfd9f221', '432fce4e-7045-59e4-a263-78a2a075f1f6', 'DEMO_A_REC', 'Sala de recuperación', '7641a5f3-760f-5340-ba07-f516f9a7c1de', NULL, '7ce5a926-1c46-56d4-8ca8-679e7429fa1d', '9c27f70c-9472-5bee-92e7-78e209d581c7', 'ro', '/ff4d09cd-e920-57c2-815f-d262dfd9f221/6b1b7b48-0ed5-5f2e-9165-c1aa25e4aa2c/432fce4e-7045-59e4-a263-78a2a075f1f6/39566e10-f2e2-56ae-8fa4-da815cf3071e/', now(), now(), 1),
  ('05980005-9813-54f1-bb6c-efc86f86812f', 'ff4d09cd-e920-57c2-815f-d262dfd9f221', '6b1b7b48-0ed5-5f2e-9165-c1aa25e4aa2c', 'DEMO_A_P4', 'Edificio A · Piso 4 (Internación)', 'd8746e07-5bca-5a23-9849-9e5a76f8018b', NULL, '7ce5a926-1c46-56d4-8ca8-679e7429fa1d', '9c27f70c-9472-5bee-92e7-78e209d581c7', 'lvl', '/ff4d09cd-e920-57c2-815f-d262dfd9f221/6b1b7b48-0ed5-5f2e-9165-c1aa25e4aa2c/05980005-9813-54f1-bb6c-efc86f86812f/', now(), now(), 1),
  ('f4b59808-daa5-5fe4-96f2-b32c4e972ce2', 'ff4d09cd-e920-57c2-815f-d262dfd9f221', '05980005-9813-54f1-bb6c-efc86f86812f', 'DEMO_A_401', 'Cama 401', 'a05823ae-7bd1-5615-a8e3-7fcef8c185db', 1, '7ce5a926-1c46-56d4-8ca8-679e7429fa1d', '9c27f70c-9472-5bee-92e7-78e209d581c7', 'bd', '/ff4d09cd-e920-57c2-815f-d262dfd9f221/6b1b7b48-0ed5-5f2e-9165-c1aa25e4aa2c/05980005-9813-54f1-bb6c-efc86f86812f/f4b59808-daa5-5fe4-96f2-b32c4e972ce2/', now(), now(), 1),
  ('87dcd491-815e-5a0a-a128-ed92aa0a3e3a', 'ff4d09cd-e920-57c2-815f-d262dfd9f221', '05980005-9813-54f1-bb6c-efc86f86812f', 'DEMO_A_402', 'Cama 402', 'a05823ae-7bd1-5615-a8e3-7fcef8c185db', 1, '7ce5a926-1c46-56d4-8ca8-679e7429fa1d', '9c27f70c-9472-5bee-92e7-78e209d581c7', 'bd', '/ff4d09cd-e920-57c2-815f-d262dfd9f221/6b1b7b48-0ed5-5f2e-9165-c1aa25e4aa2c/05980005-9813-54f1-bb6c-efc86f86812f/87dcd491-815e-5a0a-a128-ed92aa0a3e3a/', now(), now(), 1),
  ('d5fc9f4d-1ae0-5152-b1ee-1adda1784289', 'ff4d09cd-e920-57c2-815f-d262dfd9f221', '05980005-9813-54f1-bb6c-efc86f86812f', 'DEMO_A_403', 'Cama 403', 'a05823ae-7bd1-5615-a8e3-7fcef8c185db', 1, '7ce5a926-1c46-56d4-8ca8-679e7429fa1d', '9c27f70c-9472-5bee-92e7-78e209d581c7', 'bd', '/ff4d09cd-e920-57c2-815f-d262dfd9f221/6b1b7b48-0ed5-5f2e-9165-c1aa25e4aa2c/05980005-9813-54f1-bb6c-efc86f86812f/d5fc9f4d-1ae0-5152-b1ee-1adda1784289/', now(), now(), 1),
  ('82a5b866-68dd-5d78-9fa5-a212ea9eaaab', 'ff4d09cd-e920-57c2-815f-d262dfd9f221', '05980005-9813-54f1-bb6c-efc86f86812f', 'DEMO_A_404', 'Cama 404', 'a05823ae-7bd1-5615-a8e3-7fcef8c185db', 1, '7ce5a926-1c46-56d4-8ca8-679e7429fa1d', '9c27f70c-9472-5bee-92e7-78e209d581c7', 'bd', '/ff4d09cd-e920-57c2-815f-d262dfd9f221/6b1b7b48-0ed5-5f2e-9165-c1aa25e4aa2c/05980005-9813-54f1-bb6c-efc86f86812f/82a5b866-68dd-5d78-9fa5-a212ea9eaaab/', now(), now(), 1),
  ('7f63a870-b110-5ef8-8a86-3ae561895012', 'ff4d09cd-e920-57c2-815f-d262dfd9f221', '05980005-9813-54f1-bb6c-efc86f86812f', 'DEMO_A_405', 'Cama 405', 'a05823ae-7bd1-5615-a8e3-7fcef8c185db', 1, '7ce5a926-1c46-56d4-8ca8-679e7429fa1d', '9c27f70c-9472-5bee-92e7-78e209d581c7', 'bd', '/ff4d09cd-e920-57c2-815f-d262dfd9f221/6b1b7b48-0ed5-5f2e-9165-c1aa25e4aa2c/05980005-9813-54f1-bb6c-efc86f86812f/7f63a870-b110-5ef8-8a86-3ae561895012/', now(), now(), 1),
  ('158f16c2-2f99-5fab-8c27-9e1a69386a05', 'ff4d09cd-e920-57c2-815f-d262dfd9f221', '05980005-9813-54f1-bb6c-efc86f86812f', 'DEMO_A_406', 'Cama 406', 'a05823ae-7bd1-5615-a8e3-7fcef8c185db', 1, '7ce5a926-1c46-56d4-8ca8-679e7429fa1d', '9c27f70c-9472-5bee-92e7-78e209d581c7', 'bd', '/ff4d09cd-e920-57c2-815f-d262dfd9f221/6b1b7b48-0ed5-5f2e-9165-c1aa25e4aa2c/05980005-9813-54f1-bb6c-efc86f86812f/158f16c2-2f99-5fab-8c27-9e1a69386a05/', now(), now(), 1),
  ('ec623ac6-7b8f-564b-8ec6-6c2312ce3c1d', 'ff4d09cd-e920-57c2-815f-d262dfd9f221', '05980005-9813-54f1-bb6c-efc86f86812f', 'DEMO_A_407', 'Cama 407', 'a05823ae-7bd1-5615-a8e3-7fcef8c185db', 1, '7ce5a926-1c46-56d4-8ca8-679e7429fa1d', '9c27f70c-9472-5bee-92e7-78e209d581c7', 'bd', '/ff4d09cd-e920-57c2-815f-d262dfd9f221/6b1b7b48-0ed5-5f2e-9165-c1aa25e4aa2c/05980005-9813-54f1-bb6c-efc86f86812f/ec623ac6-7b8f-564b-8ec6-6c2312ce3c1d/', now(), now(), 1),
  ('245d167b-b840-5a98-8378-c30e35574885', 'ff4d09cd-e920-57c2-815f-d262dfd9f221', '05980005-9813-54f1-bb6c-efc86f86812f', 'DEMO_A_408', 'Cama 408', 'a05823ae-7bd1-5615-a8e3-7fcef8c185db', 1, '7ce5a926-1c46-56d4-8ca8-679e7429fa1d', '9c27f70c-9472-5bee-92e7-78e209d581c7', 'bd', '/ff4d09cd-e920-57c2-815f-d262dfd9f221/6b1b7b48-0ed5-5f2e-9165-c1aa25e4aa2c/05980005-9813-54f1-bb6c-efc86f86812f/245d167b-b840-5a98-8378-c30e35574885/', now(), now(), 1),
  ('f698c4fa-f2f3-5246-ac57-4c0cbdd7c3df', 'ff4d09cd-e920-57c2-815f-d262dfd9f221', '05980005-9813-54f1-bb6c-efc86f86812f', 'DEMO_A_409', 'Cama 409', 'a05823ae-7bd1-5615-a8e3-7fcef8c185db', 1, '7ce5a926-1c46-56d4-8ca8-679e7429fa1d', '9c27f70c-9472-5bee-92e7-78e209d581c7', 'bd', '/ff4d09cd-e920-57c2-815f-d262dfd9f221/6b1b7b48-0ed5-5f2e-9165-c1aa25e4aa2c/05980005-9813-54f1-bb6c-efc86f86812f/f698c4fa-f2f3-5246-ac57-4c0cbdd7c3df/', now(), now(), 1),
  ('15eb7a4a-cc37-541e-add1-32e1b1e05b63', 'ff4d09cd-e920-57c2-815f-d262dfd9f221', '05980005-9813-54f1-bb6c-efc86f86812f', 'DEMO_A_410', 'Cama 410', 'a05823ae-7bd1-5615-a8e3-7fcef8c185db', 1, '7ce5a926-1c46-56d4-8ca8-679e7429fa1d', '9c27f70c-9472-5bee-92e7-78e209d581c7', 'bd', '/ff4d09cd-e920-57c2-815f-d262dfd9f221/6b1b7b48-0ed5-5f2e-9165-c1aa25e4aa2c/05980005-9813-54f1-bb6c-efc86f86812f/15eb7a4a-cc37-541e-add1-32e1b1e05b63/', now(), now(), 1),
  ('434f9578-99c5-5b03-9c34-ae382887dfe5', 'ff4d09cd-e920-57c2-815f-d262dfd9f221', '05980005-9813-54f1-bb6c-efc86f86812f', 'DEMO_A_411', 'Cama 411', 'a05823ae-7bd1-5615-a8e3-7fcef8c185db', 1, '7ce5a926-1c46-56d4-8ca8-679e7429fa1d', '9c27f70c-9472-5bee-92e7-78e209d581c7', 'bd', '/ff4d09cd-e920-57c2-815f-d262dfd9f221/6b1b7b48-0ed5-5f2e-9165-c1aa25e4aa2c/05980005-9813-54f1-bb6c-efc86f86812f/434f9578-99c5-5b03-9c34-ae382887dfe5/', now(), now(), 1),
  ('73a6adab-9098-5d43-94f0-0bdfe576e986', 'ff4d09cd-e920-57c2-815f-d262dfd9f221', '05980005-9813-54f1-bb6c-efc86f86812f', 'DEMO_A_412', 'Cama 412', 'a05823ae-7bd1-5615-a8e3-7fcef8c185db', 1, '7ce5a926-1c46-56d4-8ca8-679e7429fa1d', '9c27f70c-9472-5bee-92e7-78e209d581c7', 'bd', '/ff4d09cd-e920-57c2-815f-d262dfd9f221/6b1b7b48-0ed5-5f2e-9165-c1aa25e4aa2c/05980005-9813-54f1-bb6c-efc86f86812f/73a6adab-9098-5d43-94f0-0bdfe576e986/', now(), now(), 1),
  ('d5ccef93-e1aa-5918-a3c2-8302c7bc7c81', 'ff4d09cd-e920-57c2-815f-d262dfd9f221', '05980005-9813-54f1-bb6c-efc86f86812f', 'DEMO_A_413', 'Cama 413', 'a05823ae-7bd1-5615-a8e3-7fcef8c185db', 1, '7ce5a926-1c46-56d4-8ca8-679e7429fa1d', '9c27f70c-9472-5bee-92e7-78e209d581c7', 'bd', '/ff4d09cd-e920-57c2-815f-d262dfd9f221/6b1b7b48-0ed5-5f2e-9165-c1aa25e4aa2c/05980005-9813-54f1-bb6c-efc86f86812f/d5ccef93-e1aa-5918-a3c2-8302c7bc7c81/', now(), now(), 1),
  ('83adc7b0-a477-52a5-9e32-fa374ae7c7c6', 'ff4d09cd-e920-57c2-815f-d262dfd9f221', '05980005-9813-54f1-bb6c-efc86f86812f', 'DEMO_A_414', 'Cama 414', 'a05823ae-7bd1-5615-a8e3-7fcef8c185db', 1, '7ce5a926-1c46-56d4-8ca8-679e7429fa1d', '9c27f70c-9472-5bee-92e7-78e209d581c7', 'bd', '/ff4d09cd-e920-57c2-815f-d262dfd9f221/6b1b7b48-0ed5-5f2e-9165-c1aa25e4aa2c/05980005-9813-54f1-bb6c-efc86f86812f/83adc7b0-a477-52a5-9e32-fa374ae7c7c6/', now(), now(), 1),
  ('377a4fb1-77b9-5118-9518-4c51b4d39846', 'ff4d09cd-e920-57c2-815f-d262dfd9f221', '05980005-9813-54f1-bb6c-efc86f86812f', 'DEMO_A_415', 'Cama 415', 'a05823ae-7bd1-5615-a8e3-7fcef8c185db', 1, '7ce5a926-1c46-56d4-8ca8-679e7429fa1d', '9c27f70c-9472-5bee-92e7-78e209d581c7', 'bd', '/ff4d09cd-e920-57c2-815f-d262dfd9f221/6b1b7b48-0ed5-5f2e-9165-c1aa25e4aa2c/05980005-9813-54f1-bb6c-efc86f86812f/377a4fb1-77b9-5118-9518-4c51b4d39846/', now(), now(), 1),
  ('a89e11e9-76e2-5a66-8dd1-8b1c90d7288d', 'ff4d09cd-e920-57c2-815f-d262dfd9f221', '05980005-9813-54f1-bb6c-efc86f86812f', 'DEMO_A_416', 'Cama 416', 'a05823ae-7bd1-5615-a8e3-7fcef8c185db', 1, '7ce5a926-1c46-56d4-8ca8-679e7429fa1d', '9c27f70c-9472-5bee-92e7-78e209d581c7', 'bd', '/ff4d09cd-e920-57c2-815f-d262dfd9f221/6b1b7b48-0ed5-5f2e-9165-c1aa25e4aa2c/05980005-9813-54f1-bb6c-efc86f86812f/a89e11e9-76e2-5a66-8dd1-8b1c90d7288d/', now(), now(), 1),
  ('bc57416e-0aa5-58b8-881f-beb209602dad', 'ff4d09cd-e920-57c2-815f-d262dfd9f221', '05980005-9813-54f1-bb6c-efc86f86812f', 'DEMO_A_417', 'Cama 417', 'a05823ae-7bd1-5615-a8e3-7fcef8c185db', 1, '7ce5a926-1c46-56d4-8ca8-679e7429fa1d', '9c27f70c-9472-5bee-92e7-78e209d581c7', 'bd', '/ff4d09cd-e920-57c2-815f-d262dfd9f221/6b1b7b48-0ed5-5f2e-9165-c1aa25e4aa2c/05980005-9813-54f1-bb6c-efc86f86812f/bc57416e-0aa5-58b8-881f-beb209602dad/', now(), now(), 1),
  ('40d942a4-9149-5f18-99e7-0196f7aca1fb', 'ff4d09cd-e920-57c2-815f-d262dfd9f221', '05980005-9813-54f1-bb6c-efc86f86812f', 'DEMO_A_418', 'Cama 418', 'a05823ae-7bd1-5615-a8e3-7fcef8c185db', 1, '7ce5a926-1c46-56d4-8ca8-679e7429fa1d', '9c27f70c-9472-5bee-92e7-78e209d581c7', 'bd', '/ff4d09cd-e920-57c2-815f-d262dfd9f221/6b1b7b48-0ed5-5f2e-9165-c1aa25e4aa2c/05980005-9813-54f1-bb6c-efc86f86812f/40d942a4-9149-5f18-99e7-0196f7aca1fb/', now(), now(), 1),
  ('5aa15ed0-e205-576f-a615-47faa8e40813', 'ff4d09cd-e920-57c2-815f-d262dfd9f221', '05980005-9813-54f1-bb6c-efc86f86812f', 'DEMO_A_419', 'Cama 419', 'a05823ae-7bd1-5615-a8e3-7fcef8c185db', 1, '7ce5a926-1c46-56d4-8ca8-679e7429fa1d', '9c27f70c-9472-5bee-92e7-78e209d581c7', 'bd', '/ff4d09cd-e920-57c2-815f-d262dfd9f221/6b1b7b48-0ed5-5f2e-9165-c1aa25e4aa2c/05980005-9813-54f1-bb6c-efc86f86812f/5aa15ed0-e205-576f-a615-47faa8e40813/', now(), now(), 1),
  ('321854d3-de73-5c2d-8ec1-364c82cc6414', 'ff4d09cd-e920-57c2-815f-d262dfd9f221', '05980005-9813-54f1-bb6c-efc86f86812f', 'DEMO_A_420', 'Cama 420', 'a05823ae-7bd1-5615-a8e3-7fcef8c185db', 1, '7ce5a926-1c46-56d4-8ca8-679e7429fa1d', '9c27f70c-9472-5bee-92e7-78e209d581c7', 'bd', '/ff4d09cd-e920-57c2-815f-d262dfd9f221/6b1b7b48-0ed5-5f2e-9165-c1aa25e4aa2c/05980005-9813-54f1-bb6c-efc86f86812f/321854d3-de73-5c2d-8ec1-364c82cc6414/', now(), now(), 1),
  ('78c846cd-141f-5b19-809d-b9c81bd9874d', 'ff4d09cd-e920-57c2-815f-d262dfd9f221', NULL, 'DEMO_B', 'Edificio B', '0273c9c6-a093-5a20-9096-19558961fbd8', NULL, '7ce5a926-1c46-56d4-8ca8-679e7429fa1d', '9c27f70c-9472-5bee-92e7-78e209d581c7', 'bu', '/ff4d09cd-e920-57c2-815f-d262dfd9f221/78c846cd-141f-5b19-809d-b9c81bd9874d/', now(), now(), 1),
  ('36673b02-ee92-509f-b8e7-4b29bf4a7558', 'ff4d09cd-e920-57c2-815f-d262dfd9f221', '78c846cd-141f-5b19-809d-b9c81bd9874d', 'DEMO_B_P1', 'Edificio B · Piso 1 (Pediatría)', 'd8746e07-5bca-5a23-9849-9e5a76f8018b', NULL, '7ce5a926-1c46-56d4-8ca8-679e7429fa1d', '9c27f70c-9472-5bee-92e7-78e209d581c7', 'lvl', '/ff4d09cd-e920-57c2-815f-d262dfd9f221/78c846cd-141f-5b19-809d-b9c81bd9874d/36673b02-ee92-509f-b8e7-4b29bf4a7558/', now(), now(), 1),
  ('87743826-3354-52ff-91cf-2658482a4a7e', 'ff4d09cd-e920-57c2-815f-d262dfd9f221', '36673b02-ee92-509f-b8e7-4b29bf4a7558', 'DEMO_B_101', 'Consultorio pediátrico B101', 'bcc7b209-6dc7-5e9b-808d-1d3575ae9aae', NULL, '7ce5a926-1c46-56d4-8ca8-679e7429fa1d', '9c27f70c-9472-5bee-92e7-78e209d581c7', 'ro', '/ff4d09cd-e920-57c2-815f-d262dfd9f221/78c846cd-141f-5b19-809d-b9c81bd9874d/36673b02-ee92-509f-b8e7-4b29bf4a7558/87743826-3354-52ff-91cf-2658482a4a7e/', now(), now(), 1),
  ('b8b695a4-36ef-59d1-976a-372df6c8e3e1', 'ff4d09cd-e920-57c2-815f-d262dfd9f221', '36673b02-ee92-509f-b8e7-4b29bf4a7558', 'DEMO_B_102', 'Consultorio pediátrico B102', 'bcc7b209-6dc7-5e9b-808d-1d3575ae9aae', NULL, '7ce5a926-1c46-56d4-8ca8-679e7429fa1d', '9c27f70c-9472-5bee-92e7-78e209d581c7', 'ro', '/ff4d09cd-e920-57c2-815f-d262dfd9f221/78c846cd-141f-5b19-809d-b9c81bd9874d/36673b02-ee92-509f-b8e7-4b29bf4a7558/b8b695a4-36ef-59d1-976a-372df6c8e3e1/', now(), now(), 1),
  ('4b550eee-40da-5e48-9bc3-4475d37fc421', 'ff4d09cd-e920-57c2-815f-d262dfd9f221', '36673b02-ee92-509f-b8e7-4b29bf4a7558', 'DEMO_B_103', 'Consultorio pediátrico B103', 'bcc7b209-6dc7-5e9b-808d-1d3575ae9aae', NULL, '7ce5a926-1c46-56d4-8ca8-679e7429fa1d', '9c27f70c-9472-5bee-92e7-78e209d581c7', 'ro', '/ff4d09cd-e920-57c2-815f-d262dfd9f221/78c846cd-141f-5b19-809d-b9c81bd9874d/36673b02-ee92-509f-b8e7-4b29bf4a7558/4b550eee-40da-5e48-9bc3-4475d37fc421/', now(), now(), 1),
  ('2a8175dc-893b-5d47-bf1d-c70ca168363a', 'ff4d09cd-e920-57c2-815f-d262dfd9f221', '36673b02-ee92-509f-b8e7-4b29bf4a7558', 'DEMO_B_104', 'Consultorio pediátrico B104', 'bcc7b209-6dc7-5e9b-808d-1d3575ae9aae', NULL, '7ce5a926-1c46-56d4-8ca8-679e7429fa1d', '9c27f70c-9472-5bee-92e7-78e209d581c7', 'ro', '/ff4d09cd-e920-57c2-815f-d262dfd9f221/78c846cd-141f-5b19-809d-b9c81bd9874d/36673b02-ee92-509f-b8e7-4b29bf4a7558/2a8175dc-893b-5d47-bf1d-c70ca168363a/', now(), now(), 1),
  ('928212ef-9d29-591e-a236-3aeb63505581', 'ff4d09cd-e920-57c2-815f-d262dfd9f221', '78c846cd-141f-5b19-809d-b9c81bd9874d', 'DEMO_B_P2', 'Edificio B · Piso 2 (Ginecología)', 'd8746e07-5bca-5a23-9849-9e5a76f8018b', NULL, '7ce5a926-1c46-56d4-8ca8-679e7429fa1d', '9c27f70c-9472-5bee-92e7-78e209d581c7', 'lvl', '/ff4d09cd-e920-57c2-815f-d262dfd9f221/78c846cd-141f-5b19-809d-b9c81bd9874d/928212ef-9d29-591e-a236-3aeb63505581/', now(), now(), 1),
  ('6e40ca20-7c68-5796-a884-27fd44b0a89e', 'ff4d09cd-e920-57c2-815f-d262dfd9f221', '928212ef-9d29-591e-a236-3aeb63505581', 'DEMO_B_201', 'Consultorio de ginecología B201', 'bcc7b209-6dc7-5e9b-808d-1d3575ae9aae', NULL, '7ce5a926-1c46-56d4-8ca8-679e7429fa1d', '9c27f70c-9472-5bee-92e7-78e209d581c7', 'ro', '/ff4d09cd-e920-57c2-815f-d262dfd9f221/78c846cd-141f-5b19-809d-b9c81bd9874d/928212ef-9d29-591e-a236-3aeb63505581/6e40ca20-7c68-5796-a884-27fd44b0a89e/', now(), now(), 1),
  ('9b93680e-24d4-5baf-8950-ae8ca5739dc6', 'ff4d09cd-e920-57c2-815f-d262dfd9f221', '928212ef-9d29-591e-a236-3aeb63505581', 'DEMO_B_202', 'Consultorio de ginecología B202', 'bcc7b209-6dc7-5e9b-808d-1d3575ae9aae', NULL, '7ce5a926-1c46-56d4-8ca8-679e7429fa1d', '9c27f70c-9472-5bee-92e7-78e209d581c7', 'ro', '/ff4d09cd-e920-57c2-815f-d262dfd9f221/78c846cd-141f-5b19-809d-b9c81bd9874d/928212ef-9d29-591e-a236-3aeb63505581/9b93680e-24d4-5baf-8950-ae8ca5739dc6/', now(), now(), 1),
  ('f3ced18f-cf1b-5090-8e6d-f6d73bca4a84', 'ff4d09cd-e920-57c2-815f-d262dfd9f221', '928212ef-9d29-591e-a236-3aeb63505581', 'DEMO_B_203', 'Consultorio de ginecología B203', 'bcc7b209-6dc7-5e9b-808d-1d3575ae9aae', NULL, '7ce5a926-1c46-56d4-8ca8-679e7429fa1d', '9c27f70c-9472-5bee-92e7-78e209d581c7', 'ro', '/ff4d09cd-e920-57c2-815f-d262dfd9f221/78c846cd-141f-5b19-809d-b9c81bd9874d/928212ef-9d29-591e-a236-3aeb63505581/f3ced18f-cf1b-5090-8e6d-f6d73bca4a84/', now(), now(), 1),
  ('752011bf-53d4-511d-aa7b-66fa43c6ae42', 'ff4d09cd-e920-57c2-815f-d262dfd9f221', '928212ef-9d29-591e-a236-3aeb63505581', 'DEMO_B_204', 'Sala de ecografía obstétrica B204', '61da384e-2f50-57e6-ba7c-f6c0b11102e7', NULL, '7ce5a926-1c46-56d4-8ca8-679e7429fa1d', '9c27f70c-9472-5bee-92e7-78e209d581c7', 'ro', '/ff4d09cd-e920-57c2-815f-d262dfd9f221/78c846cd-141f-5b19-809d-b9c81bd9874d/928212ef-9d29-591e-a236-3aeb63505581/752011bf-53d4-511d-aa7b-66fa43c6ae42/', now(), now(), 1),
  ('7411dba8-1913-5865-81e0-d4476184e55a', 'bf2841a5-e92f-5b2b-b77e-23e11712c554', NULL, 'DEMO_N_P1', 'Sede Norte · Piso 1 (Consulta externa)', 'd8746e07-5bca-5a23-9849-9e5a76f8018b', NULL, '7ce5a926-1c46-56d4-8ca8-679e7429fa1d', '9c27f70c-9472-5bee-92e7-78e209d581c7', 'lvl', '/bf2841a5-e92f-5b2b-b77e-23e11712c554/7411dba8-1913-5865-81e0-d4476184e55a/', now(), now(), 1),
  ('a0214877-2554-5e6a-bdd8-95ef6107f40b', 'bf2841a5-e92f-5b2b-b77e-23e11712c554', '7411dba8-1913-5865-81e0-d4476184e55a', 'DEMO_N_101', 'Consultorio N101', 'bcc7b209-6dc7-5e9b-808d-1d3575ae9aae', NULL, '7ce5a926-1c46-56d4-8ca8-679e7429fa1d', '9c27f70c-9472-5bee-92e7-78e209d581c7', 'ro', '/bf2841a5-e92f-5b2b-b77e-23e11712c554/7411dba8-1913-5865-81e0-d4476184e55a/a0214877-2554-5e6a-bdd8-95ef6107f40b/', now(), now(), 1),
  ('709a4334-ae78-569c-bc24-755f2be12403', 'bf2841a5-e92f-5b2b-b77e-23e11712c554', '7411dba8-1913-5865-81e0-d4476184e55a', 'DEMO_N_102', 'Consultorio N102', 'bcc7b209-6dc7-5e9b-808d-1d3575ae9aae', NULL, '7ce5a926-1c46-56d4-8ca8-679e7429fa1d', '9c27f70c-9472-5bee-92e7-78e209d581c7', 'ro', '/bf2841a5-e92f-5b2b-b77e-23e11712c554/7411dba8-1913-5865-81e0-d4476184e55a/709a4334-ae78-569c-bc24-755f2be12403/', now(), now(), 1),
  ('79abf7e9-9b95-534e-ad60-9c85c9790bbd', 'bf2841a5-e92f-5b2b-b77e-23e11712c554', '7411dba8-1913-5865-81e0-d4476184e55a', 'DEMO_N_103', 'Consultorio N103', 'bcc7b209-6dc7-5e9b-808d-1d3575ae9aae', NULL, '7ce5a926-1c46-56d4-8ca8-679e7429fa1d', '9c27f70c-9472-5bee-92e7-78e209d581c7', 'ro', '/bf2841a5-e92f-5b2b-b77e-23e11712c554/7411dba8-1913-5865-81e0-d4476184e55a/79abf7e9-9b95-534e-ad60-9c85c9790bbd/', now(), now(), 1),
  ('30eec02e-ff03-518a-a394-b43ae9ee0564', 'bf2841a5-e92f-5b2b-b77e-23e11712c554', '7411dba8-1913-5865-81e0-d4476184e55a', 'DEMO_N_104', 'Consultorio N104', 'bcc7b209-6dc7-5e9b-808d-1d3575ae9aae', NULL, '7ce5a926-1c46-56d4-8ca8-679e7429fa1d', '9c27f70c-9472-5bee-92e7-78e209d581c7', 'ro', '/bf2841a5-e92f-5b2b-b77e-23e11712c554/7411dba8-1913-5865-81e0-d4476184e55a/30eec02e-ff03-518a-a394-b43ae9ee0564/', now(), now(), 1),
  ('75ecd892-e8c2-57a7-97e4-7e4a7d4700a1', '07a7a206-533d-5827-ab51-14d021f32ea0', NULL, 'DEMO_K_1', 'Consultorio de la Dra. Céspedes', 'bcc7b209-6dc7-5e9b-808d-1d3575ae9aae', NULL, '7ce5a926-1c46-56d4-8ca8-679e7429fa1d', '9c27f70c-9472-5bee-92e7-78e209d581c7', 'ro', '/07a7a206-533d-5827-ab51-14d021f32ea0/75ecd892-e8c2-57a7-97e4-7e4a7d4700a1/', now(), now(), 1)
ON CONFLICT DO NOTHING;

-- Servicios a nivel de práctica (sin sede): «Ecografía» es UN servicio para todo el hospital.
INSERT INTO practice.healthcare_services (id, practice_id, practice_site_id, service_concept_id, appointment_required, status_concept_id, created_at, updated_at, row_version) VALUES
  ('a6972272-66d5-52e5-8b97-01abeedb908c', '314eeab4-0062-5e4f-b3f1-4e26174daa10', NULL, 'e970ef04-bed6-55d1-9708-0efdba380208', true, '052058be-3c92-55ff-aefc-97395828be43', now(), now(), 1),
  ('f2cd46e2-48c1-511b-a1b9-d67e25d49ab1', '314eeab4-0062-5e4f-b3f1-4e26174daa10', NULL, '5a3836d9-b3b2-5273-b67d-d315b6f9f9fd', true, '052058be-3c92-55ff-aefc-97395828be43', now(), now(), 1),
  ('73e20b2b-af05-523c-9d6c-1b2ebbff778d', '314eeab4-0062-5e4f-b3f1-4e26174daa10', NULL, 'f30d2eb3-60d2-5d4a-bdae-47343fc00d0f', true, '052058be-3c92-55ff-aefc-97395828be43', now(), now(), 1),
  ('3120a37a-4582-5f7e-863e-e7a75425e935', '314eeab4-0062-5e4f-b3f1-4e26174daa10', NULL, '75b7b274-7e69-55e5-9e23-db05ddab4b08', true, '052058be-3c92-55ff-aefc-97395828be43', now(), now(), 1),
  ('e7f7d45a-16ca-56f8-a208-10c828f3506b', '314eeab4-0062-5e4f-b3f1-4e26174daa10', NULL, 'acf443ba-b6d7-5117-913b-40feeb00d1c0', true, '052058be-3c92-55ff-aefc-97395828be43', now(), now(), 1),
  ('56dc1368-9366-52d5-b5da-09c605bf0382', '314eeab4-0062-5e4f-b3f1-4e26174daa10', NULL, '29c619c6-abf1-551d-a817-d75f69f01d73', true, '052058be-3c92-55ff-aefc-97395828be43', now(), now(), 1),
  ('ba50a56f-f8de-5168-a963-bf81539b5c87', '314eeab4-0062-5e4f-b3f1-4e26174daa10', NULL, 'a22519f1-1eaf-537a-94c3-af190fe5cb0a', true, '052058be-3c92-55ff-aefc-97395828be43', now(), now(), 1),
  ('da47af6a-fc7a-5d56-93cb-7bbe45b26ce5', '314eeab4-0062-5e4f-b3f1-4e26174daa10', NULL, '6cc05c51-c41d-5e9a-a2db-7406966694a6', true, '052058be-3c92-55ff-aefc-97395828be43', now(), now(), 1),
  ('390a39d8-711b-5dc7-8507-19a80ec2d7cc', '314eeab4-0062-5e4f-b3f1-4e26174daa10', NULL, '7908abfd-3a3e-5bbd-86c8-f06451db8793', true, '052058be-3c92-55ff-aefc-97395828be43', now(), now(), 1),
  ('35213505-0794-5a98-bc40-55372bd188fb', '314eeab4-0062-5e4f-b3f1-4e26174daa10', NULL, '14978504-587a-504e-8c54-35e074c8b3c4', true, '052058be-3c92-55ff-aefc-97395828be43', now(), now(), 1),
  ('7ed84e28-46de-59c1-9889-a0f00c03ede5', 'b248aef6-7047-5128-90bd-e2d75225b5fe', NULL, 'c9c90aea-8d91-56bd-8b8c-bc79a91c004a', true, '052058be-3c92-55ff-aefc-97395828be43', now(), now(), 1)
ON CONFLICT DO NOTHING;

-- Vínculo profesional ↔ organización de cada doctor.
INSERT INTO practice.practitioner_role_assignments (id, practitioner_profile_id, practice_id, practice_site_id, healthcare_service_id, role_concept_id, is_primary, valid_from, status_concept_id, created_at, updated_at, row_version) VALUES
  ('f4e4d910-002f-5a42-a3fa-8696220f940b', '96307267-f432-5fd2-9bd0-e609625088ab', '314eeab4-0062-5e4f-b3f1-4e26174daa10', 'ff4d09cd-e920-57c2-815f-d262dfd9f221', 'a6972272-66d5-52e5-8b97-01abeedb908c', '11fbd446-3e81-594d-b450-164d7c496c46', true, current_date, '15fb063e-479c-56e6-b5d1-ebd5a36b62db', now(), now(), 1),
  ('c3e867d0-28d9-526d-bd16-71e4cdb285d2', '2af4ef83-2676-5032-ab17-ffef12c48e47', '314eeab4-0062-5e4f-b3f1-4e26174daa10', 'ff4d09cd-e920-57c2-815f-d262dfd9f221', '73e20b2b-af05-523c-9d6c-1b2ebbff778d', '11fbd446-3e81-594d-b450-164d7c496c46', true, current_date, '15fb063e-479c-56e6-b5d1-ebd5a36b62db', now(), now(), 1),
  ('d487ae98-c6f5-57d1-ac38-b651d303f080', 'fe30dd79-cad3-567e-ac02-8f3ee5f27bf9', '314eeab4-0062-5e4f-b3f1-4e26174daa10', 'ff4d09cd-e920-57c2-815f-d262dfd9f221', 'e7f7d45a-16ca-56f8-a208-10c828f3506b', '11fbd446-3e81-594d-b450-164d7c496c46', true, current_date, '15fb063e-479c-56e6-b5d1-ebd5a36b62db', now(), now(), 1),
  ('223616d5-8cc4-5ea1-9e2e-5b971b001cad', '4a443ffa-92e4-5015-86a5-2d51c726bf76', '314eeab4-0062-5e4f-b3f1-4e26174daa10', 'ff4d09cd-e920-57c2-815f-d262dfd9f221', '56dc1368-9366-52d5-b5da-09c605bf0382', '11fbd446-3e81-594d-b450-164d7c496c46', true, current_date, '15fb063e-479c-56e6-b5d1-ebd5a36b62db', now(), now(), 1),
  ('d52be48f-1b3b-5ba7-8c4a-4e53eb3bed9c', '4e8d2bae-d062-5b9c-8364-c371e9ce3efa', '314eeab4-0062-5e4f-b3f1-4e26174daa10', 'ff4d09cd-e920-57c2-815f-d262dfd9f221', 'ba50a56f-f8de-5168-a963-bf81539b5c87', '11fbd446-3e81-594d-b450-164d7c496c46', true, current_date, '15fb063e-479c-56e6-b5d1-ebd5a36b62db', now(), now(), 1),
  ('30a0f73d-3668-5859-9f78-ade7a0a7cde7', '569fa481-abe1-5b70-ba9e-add5bd4dbf54', '314eeab4-0062-5e4f-b3f1-4e26174daa10', 'ff4d09cd-e920-57c2-815f-d262dfd9f221', 'da47af6a-fc7a-5d56-93cb-7bbe45b26ce5', '11fbd446-3e81-594d-b450-164d7c496c46', true, current_date, '15fb063e-479c-56e6-b5d1-ebd5a36b62db', now(), now(), 1),
  ('4e5d2766-442e-56ae-9663-31f99a869315', '92c8b351-3f6c-5dd8-b14c-7f2b815f4b83', '314eeab4-0062-5e4f-b3f1-4e26174daa10', 'bf2841a5-e92f-5b2b-b77e-23e11712c554', '35213505-0794-5a98-bc40-55372bd188fb', '11fbd446-3e81-594d-b450-164d7c496c46', true, current_date, '15fb063e-479c-56e6-b5d1-ebd5a36b62db', now(), now(), 1),
  ('efe35bb0-3812-59d9-80f8-3f2c3092ac4f', 'aa68f795-8e80-5f57-8d12-27535bd5a146', 'b248aef6-7047-5128-90bd-e2d75225b5fe', '07a7a206-533d-5827-ab51-14d021f32ea0', '7ed84e28-46de-59c1-9889-a0f00c03ede5', '11fbd446-3e81-594d-b450-164d7c496c46', true, current_date, '15fb063e-479c-56e6-b5d1-ebd5a36b62db', now(), now(), 1)
ON CONFLICT DO NOTHING;

-- Dónde atiende cada doctor (A-P3 = piso de quirófanos; A-P4 = asignación fija de internación).
INSERT INTO practice.practitioner_location_assignments (id, tenant_id, practitioner_role_assignment_id, care_space_id, valid_from, status_concept_id, created_at, updated_at, row_version) VALUES
  ('854bb89b-d4ea-512f-bacf-a8fd339b9fe9', '830e47e1-8e82-50ff-99c0-bfed0a7971a4', 'f4e4d910-002f-5a42-a3fa-8696220f940b', '0feafc25-2f9c-50b7-a3c0-af4efd4e7fb1', current_date, '38a1d301-f40d-5b17-a695-5e6d605f8b19', now(), now(), 1),
  ('dc03beb0-1787-5c7a-ac59-5cc8872d6595', '830e47e1-8e82-50ff-99c0-bfed0a7971a4', 'f4e4d910-002f-5a42-a3fa-8696220f940b', '462ffc1f-f086-509d-b26a-487dfdb82b03', current_date, '38a1d301-f40d-5b17-a695-5e6d605f8b19', now(), now(), 1),
  ('0246e255-ef52-5769-9cd1-3e6628b8c216', '830e47e1-8e82-50ff-99c0-bfed0a7971a4', 'c3e867d0-28d9-526d-bd16-71e4cdb285d2', '6e40ca20-7c68-5796-a884-27fd44b0a89e', current_date, '38a1d301-f40d-5b17-a695-5e6d605f8b19', now(), now(), 1),
  ('b7e2718e-5bb4-5f75-bbf1-513d631efafb', '830e47e1-8e82-50ff-99c0-bfed0a7971a4', 'c3e867d0-28d9-526d-bd16-71e4cdb285d2', '752011bf-53d4-511d-aa7b-66fa43c6ae42', current_date, '38a1d301-f40d-5b17-a695-5e6d605f8b19', now(), now(), 1),
  ('9793bfba-7096-5df7-a892-d91b225ec417', '830e47e1-8e82-50ff-99c0-bfed0a7971a4', 'c3e867d0-28d9-526d-bd16-71e4cdb285d2', '432fce4e-7045-59e4-a263-78a2a075f1f6', current_date, '38a1d301-f40d-5b17-a695-5e6d605f8b19', now(), now(), 1),
  ('44e7eb6c-dc31-5c6d-964e-8122127fb634', '830e47e1-8e82-50ff-99c0-bfed0a7971a4', 'd487ae98-c6f5-57d1-ac38-b651d303f080', 'b8b695a4-36ef-59d1-976a-372df6c8e3e1', current_date, '38a1d301-f40d-5b17-a695-5e6d605f8b19', now(), now(), 1),
  ('92acbd0e-130a-510b-810c-64d2c4a83686', '830e47e1-8e82-50ff-99c0-bfed0a7971a4', 'd487ae98-c6f5-57d1-ac38-b651d303f080', '709a4334-ae78-569c-bc24-755f2be12403', current_date, '38a1d301-f40d-5b17-a695-5e6d605f8b19', now(), now(), 1),
  ('dece1957-255f-5520-984f-9759e2237d01', '830e47e1-8e82-50ff-99c0-bfed0a7971a4', '223616d5-8cc4-5ea1-9e2e-5b971b001cad', 'c6ba3db5-3f9a-5cc9-b07a-6eff8a0f3887', current_date, '38a1d301-f40d-5b17-a695-5e6d605f8b19', now(), now(), 1),
  ('2734fa2b-869f-547e-b4c0-e505ae6fb7dd', '830e47e1-8e82-50ff-99c0-bfed0a7971a4', '223616d5-8cc4-5ea1-9e2e-5b971b001cad', '05980005-9813-54f1-bb6c-efc86f86812f', current_date, '38a1d301-f40d-5b17-a695-5e6d605f8b19', now(), now(), 1),
  ('be070a99-137e-5e8f-8fdf-673274d76580', '830e47e1-8e82-50ff-99c0-bfed0a7971a4', 'd52be48f-1b3b-5ba7-8c4a-4e53eb3bed9c', '1e1cdd5e-8e76-511d-9e53-c68bf7c1b338', current_date, '38a1d301-f40d-5b17-a695-5e6d605f8b19', now(), now(), 1),
  ('4be61643-7205-56f8-a9cd-3f7b49468d2d', '830e47e1-8e82-50ff-99c0-bfed0a7971a4', 'd52be48f-1b3b-5ba7-8c4a-4e53eb3bed9c', '432fce4e-7045-59e4-a263-78a2a075f1f6', current_date, '38a1d301-f40d-5b17-a695-5e6d605f8b19', now(), now(), 1),
  ('14e49016-a22a-5303-9866-a4c4981d9708', '830e47e1-8e82-50ff-99c0-bfed0a7971a4', '30a0f73d-3668-5859-9f78-ade7a0a7cde7', '462ffc1f-f086-509d-b26a-487dfdb82b03', current_date, '38a1d301-f40d-5b17-a695-5e6d605f8b19', now(), now(), 1),
  ('70e92f18-7eca-52b6-88bd-f591fd3bc68b', '830e47e1-8e82-50ff-99c0-bfed0a7971a4', '30a0f73d-3668-5859-9f78-ade7a0a7cde7', '65a42b85-bf3c-5163-a3bf-5710610a58c5', current_date, '38a1d301-f40d-5b17-a695-5e6d605f8b19', now(), now(), 1),
  ('23e970f1-39e9-5188-b0dd-97e621627c9d', '830e47e1-8e82-50ff-99c0-bfed0a7971a4', '4e5d2766-442e-56ae-9663-31f99a869315', 'a0214877-2554-5e6a-bdd8-95ef6107f40b', current_date, '38a1d301-f40d-5b17-a695-5e6d605f8b19', now(), now(), 1),
  ('117e39eb-2709-5c0a-8862-1c1116d6b67a', '830e47e1-8e82-50ff-99c0-bfed0a7971a4', '4e5d2766-442e-56ae-9663-31f99a869315', '432fce4e-7045-59e4-a263-78a2a075f1f6', current_date, '38a1d301-f40d-5b17-a695-5e6d605f8b19', now(), now(), 1),
  ('5a89bf03-3207-56c3-9452-c005b835df67', 'a52f851c-e5c2-5a32-b99e-a4993ff5a287', 'efe35bb0-3812-59d9-80f8-3f2c3092ac4f', '75ecd892-e8c2-57a7-97e4-7e4a7d4700a1', current_date, '38a1d301-f40d-5b17-a695-5e6d605f8b19', now(), now(), 1)
ON CONFLICT DO NOTHING;

-- Catálogo de permisos de apoyo (los mismos ids que los seeds de boot: si ya están, no se tocan).
INSERT INTO authz.permissions (id, code, name, resource, action_concept_id, default_scope_concept_id, is_field_level, is_dangerous, state_concept_id, created_at, updated_at, row_version, is_role_restricted, allow_direct_user_grant) VALUES
  ('438c578b-e5ea-5c58-86ed-fcf7da71780e', 'schedule.view', 'Ver la agenda', 'scheduling.appointment', 'ea5aa219-9b0f-538f-9ca5-0e7eb4e715cf', '1b45f74f-f39e-58eb-b29a-86c100efeb67', false, false, '38a1d301-f40d-5b17-a695-5e6d605f8b19', now(), now(), 1, false, false),
  ('7c5a3eeb-ac26-5d5e-a7b0-993955c63a2e', 'schedule.create', 'Crear citas', 'scheduling.appointment', '89c2342b-cec1-5678-b97c-e33c304d5519', '1b45f74f-f39e-58eb-b29a-86c100efeb67', false, false, '38a1d301-f40d-5b17-a695-5e6d605f8b19', now(), now(), 1, false, false),
  ('9246c74e-5181-5a6b-b070-a8eef9887948', 'schedule.reschedule', 'Reprogramar citas', 'scheduling.appointment', '0491c4bb-2c42-5acb-b422-8da33bd0b4a3', '1b45f74f-f39e-58eb-b29a-86c100efeb67', false, false, '38a1d301-f40d-5b17-a695-5e6d605f8b19', now(), now(), 1, false, false),
  ('cd48f1e6-f8ed-5aba-bfbd-aec1829312ab', 'schedule.cancel', 'Cancelar citas', 'scheduling.appointment', '0491c4bb-2c42-5acb-b422-8da33bd0b4a3', '1b45f74f-f39e-58eb-b29a-86c100efeb67', false, false, '38a1d301-f40d-5b17-a695-5e6d605f8b19', now(), now(), 1, false, false),
  ('f69bb091-dd4b-58bf-93ca-0714bddd536b', 'schedule.confirm', 'Confirmar citas', 'scheduling.appointment', '11f6b39b-272e-52c4-9583-3bd153b1e21e', '1b45f74f-f39e-58eb-b29a-86c100efeb67', false, false, '38a1d301-f40d-5b17-a695-5e6d605f8b19', now(), now(), 1, false, false),
  ('062598be-12eb-5eab-acb6-714fe9e8eb1f', 'schedule.check_in', 'Registrar la llegada del paciente', 'scheduling.appointment', '11f6b39b-272e-52c4-9583-3bd153b1e21e', '1b45f74f-f39e-58eb-b29a-86c100efeb67', false, false, '38a1d301-f40d-5b17-a695-5e6d605f8b19', now(), now(), 1, false, false),
  ('9d8b0c5a-1e2c-5f42-8200-1c1d537f7a1c', 'schedule.walk_in', 'Atender paciente sin cita previa', 'scheduling.appointment', '89c2342b-cec1-5678-b97c-e33c304d5519', '1b45f74f-f39e-58eb-b29a-86c100efeb67', false, false, '38a1d301-f40d-5b17-a695-5e6d605f8b19', now(), now(), 1, false, false),
  ('3482e7ed-b143-5b9c-b171-2751b12d8d37', 'schedule.waitlist', 'Gestionar la lista de espera', 'scheduling.waitlist_entry', '0491c4bb-2c42-5acb-b422-8da33bd0b4a3', '1b45f74f-f39e-58eb-b29a-86c100efeb67', false, false, '38a1d301-f40d-5b17-a695-5e6d605f8b19', now(), now(), 1, false, false),
  ('d9c9f910-bc47-5316-8c00-780378806085', 'schedule.send_reminders', 'Enviar recordatorios de cita', 'scheduling.appointment_reminder', '11f6b39b-272e-52c4-9583-3bd153b1e21e', '1b45f74f-f39e-58eb-b29a-86c100efeb67', false, false, '38a1d301-f40d-5b17-a695-5e6d605f8b19', now(), now(), 1, false, false),
  ('1ccc916d-4ded-5155-9e36-1b6a33ede032', 'schedule.block_time', 'Bloquear horarios de la agenda', 'scheduling.availability_exception', '0491c4bb-2c42-5acb-b422-8da33bd0b4a3', '1b45f74f-f39e-58eb-b29a-86c100efeb67', false, false, '38a1d301-f40d-5b17-a695-5e6d605f8b19', now(), now(), 1, false, false),
  ('7e464ef1-7256-55f4-8334-656da444ace4', 'schedule.edit_hours', 'Editar los horarios de atención', 'scheduling.schedule_template', '0491c4bb-2c42-5acb-b422-8da33bd0b4a3', '1b45f74f-f39e-58eb-b29a-86c100efeb67', false, false, '38a1d301-f40d-5b17-a695-5e6d605f8b19', now(), now(), 1, false, false),
  ('7fca105d-bef3-5c11-b347-5cc88e179d23', 'billing.collect', 'Cobrar la atención', 'billing.payment', '11f6b39b-272e-52c4-9583-3bd153b1e21e', '1b45f74f-f39e-58eb-b29a-86c100efeb67', false, false, '38a1d301-f40d-5b17-a695-5e6d605f8b19', now(), now(), 1, false, false),
  ('7f1d095d-cb33-5514-b6f3-ce25fff58d94', 'billing.issue_receipt', 'Emitir comprobantes', 'billing.receipt', '89c2342b-cec1-5678-b97c-e33c304d5519', '1b45f74f-f39e-58eb-b29a-86c100efeb67', false, false, '38a1d301-f40d-5b17-a695-5e6d605f8b19', now(), now(), 1, false, false),
  ('a68e3753-6295-5f35-b261-3142072da22c', 'patient.register', 'Registrar pacientes', 'profiles.patient_profile', '89c2342b-cec1-5678-b97c-e33c304d5519', '1b45f74f-f39e-58eb-b29a-86c100efeb67', false, false, '38a1d301-f40d-5b17-a695-5e6d605f8b19', now(), now(), 1, false, false),
  ('9d3b3416-e19f-54cf-968e-5ed8c655e90a', 'messages.reply_on_behalf', 'Responder mensajes administrativos en nombre del profesional', 'community.direct_message', '89c2342b-cec1-5678-b97c-e33c304d5519', '1b45f74f-f39e-58eb-b29a-86c100efeb67', false, false, '38a1d301-f40d-5b17-a695-5e6d605f8b19', now(), now(), 1, false, false)
ON CONFLICT DO NOTHING;

-- Plantillas de rol de plataforma (tenant NULL).
INSERT INTO delegated_access.role_templates (id, tenant_id, code, name, default_actions_json, status_concept_id, version_number, created_at, updated_at, row_version) VALUES
  ('e6868a49-9408-50e0-8ea8-c3d79ff435f8', NULL, 'SECRETARY', 'Secretaria', '["schedule.view", "schedule.create", "schedule.reschedule", "schedule.cancel", "schedule.confirm", "schedule.check_in", "schedule.walk_in", "schedule.waitlist", "schedule.send_reminders", "patient.register", "messages.reply_on_behalf"]'::jsonb, '6b070aec-a5af-52bc-8462-55be0d26298a', 1, now(), now(), 1),
  ('8575c6d9-8bd2-5977-a80f-b76969071953', NULL, 'MEDICAL_ASSISTANT', 'Asistente médico', '["schedule.view", "schedule.create", "schedule.reschedule", "schedule.cancel", "schedule.confirm", "schedule.check_in", "schedule.walk_in", "schedule.waitlist", "schedule.send_reminders", "patient.register", "messages.reply_on_behalf"]'::jsonb, '6b070aec-a5af-52bc-8462-55be0d26298a', 1, now(), now(), 1),
  ('7986bb01-1a6c-50af-b0c2-0b6bc28d5a65', NULL, 'NURSING', 'Enfermería', '["schedule.view", "schedule.check_in", "schedule.waitlist"]'::jsonb, '6b070aec-a5af-52bc-8462-55be0d26298a', 1, now(), now(), 1),
  ('a210d088-6991-5250-b8c9-299875747d59', NULL, 'FRONT_DESK', 'Recepción', '["schedule.view", "schedule.check_in", "schedule.walk_in", "patient.register"]'::jsonb, '6b070aec-a5af-52bc-8462-55be0d26298a', 1, now(), now(), 1),
  ('6b5c8b0f-87b1-531c-86fd-01b0c1021bc0', NULL, 'BILLING_CASHIER', 'Facturación y caja', '["schedule.view", "billing.collect", "billing.issue_receipt"]'::jsonb, '6b070aec-a5af-52bc-8462-55be0d26298a', 1, now(), now(), 1),
  ('da9a9ff5-16ec-55f0-a56a-44183573326a', NULL, 'CALL_CENTER', 'Central telefónica', '["schedule.view", "schedule.create", "schedule.reschedule", "schedule.cancel"]'::jsonb, '6b070aec-a5af-52bc-8462-55be0d26298a', 1, now(), now(), 1),
  ('105d71e7-338b-579e-9194-65b97372f332', NULL, 'ORG_MANAGEMENT', 'Gestión de la organización', '["schedule.view", "schedule.create", "schedule.reschedule", "schedule.cancel", "schedule.confirm", "schedule.check_in", "schedule.walk_in", "schedule.waitlist", "schedule.send_reminders", "schedule.block_time", "schedule.edit_hours", "patient.register"]'::jsonb, '6b070aec-a5af-52bc-8462-55be0d26298a', 1, now(), now(), 1)
ON CONFLICT DO NOTHING;

-- Conjunto de permisos delegables por organización.
INSERT INTO delegated_access.delegated_permission_sets (id, tenant_id, code, name, delegate_type_concept_id, description, status_concept_id, version_number, created_at, updated_at, row_version) VALUES
  ('0ba62ad0-e22f-553b-9496-14829b7bbf9c', '830e47e1-8e82-50ff-99c0-bfed0a7971a4', 'DEMO_SECRETARY', 'Secretaria (demo)', 'da2c812c-2f0e-5d72-aa00-7cfa9e279fd5', 'Conjunto de permisos de la plantilla SECRETARY para la organización demo.', '38a1d301-f40d-5b17-a695-5e6d605f8b19', 1, now(), now(), 1),
  ('084f3db5-8c8f-58f5-ac1c-1343a811e0fb', 'a52f851c-e5c2-5a32-b99e-a4993ff5a287', 'DEMO_SECRETARY', 'Secretaria (demo)', 'da2c812c-2f0e-5d72-aa00-7cfa9e279fd5', 'Conjunto de permisos de la plantilla SECRETARY para la organización demo.', '38a1d301-f40d-5b17-a695-5e6d605f8b19', 1, now(), now(), 1),
  ('d7cdc136-1d24-5c8d-bcea-13aa04f17ff2', '830e47e1-8e82-50ff-99c0-bfed0a7971a4', 'DEMO_FRONT_DESK', 'Recepción (demo)', 'c4b64a74-4924-5e62-aab0-d21f83ac95d9', 'Conjunto de permisos de la plantilla FRONT_DESK para la organización demo.', '38a1d301-f40d-5b17-a695-5e6d605f8b19', 1, now(), now(), 1),
  ('80e771c4-9220-5e1d-8549-5b192a51857a', '830e47e1-8e82-50ff-99c0-bfed0a7971a4', 'DEMO_CALL_CENTER', 'Central de llamadas (demo)', '87d0ed36-3de2-50fd-9b81-776eb828f520', 'Conjunto de permisos de la plantilla CALL_CENTER para la organización demo.', '38a1d301-f40d-5b17-a695-5e6d605f8b19', 1, now(), now(), 1)
ON CONFLICT DO NOTHING;

-- Acciones del conjunto.
INSERT INTO delegated_access.delegated_permission_set_items (id, delegated_permission_set_id, permission_id, requires_step_up_authentication, created_at) VALUES
  ('79933a80-fe1f-5121-894c-d088e3fe0f28', '0ba62ad0-e22f-553b-9496-14829b7bbf9c', '438c578b-e5ea-5c58-86ed-fcf7da71780e', false, now()),
  ('4562d460-1103-57bc-90d4-fe09c59c3e80', '0ba62ad0-e22f-553b-9496-14829b7bbf9c', '7c5a3eeb-ac26-5d5e-a7b0-993955c63a2e', false, now()),
  ('53046fcd-21ff-597b-9a75-7d1285a00c32', '0ba62ad0-e22f-553b-9496-14829b7bbf9c', '9246c74e-5181-5a6b-b070-a8eef9887948', false, now()),
  ('d6f056ce-3a18-57ca-ab27-88a8f237edd0', '0ba62ad0-e22f-553b-9496-14829b7bbf9c', 'cd48f1e6-f8ed-5aba-bfbd-aec1829312ab', false, now()),
  ('9320b8c2-6266-5aa4-b9c0-a14b83586941', '0ba62ad0-e22f-553b-9496-14829b7bbf9c', 'f69bb091-dd4b-58bf-93ca-0714bddd536b', false, now()),
  ('1a5a8ad0-9f9a-588f-84fa-a956d0885c37', '0ba62ad0-e22f-553b-9496-14829b7bbf9c', '062598be-12eb-5eab-acb6-714fe9e8eb1f', false, now()),
  ('93a5e66d-fa9e-5ead-8d0f-14ac85cc0351', '0ba62ad0-e22f-553b-9496-14829b7bbf9c', '9d8b0c5a-1e2c-5f42-8200-1c1d537f7a1c', false, now()),
  ('b7421045-2d08-59f4-94a9-78c129459a2c', '0ba62ad0-e22f-553b-9496-14829b7bbf9c', '3482e7ed-b143-5b9c-b171-2751b12d8d37', false, now()),
  ('716e21f1-d480-5343-b9ed-453379232e2e', '0ba62ad0-e22f-553b-9496-14829b7bbf9c', 'd9c9f910-bc47-5316-8c00-780378806085', false, now()),
  ('73970a69-a607-5ddf-a019-e89487c4c18b', '0ba62ad0-e22f-553b-9496-14829b7bbf9c', 'a68e3753-6295-5f35-b261-3142072da22c', false, now()),
  ('1c92562b-463d-5ea3-9799-31c6c21452c1', '0ba62ad0-e22f-553b-9496-14829b7bbf9c', '9d3b3416-e19f-54cf-968e-5ed8c655e90a', false, now()),
  ('8d4c28b2-f9bb-5b98-8f0e-4755a3c3b649', '084f3db5-8c8f-58f5-ac1c-1343a811e0fb', '438c578b-e5ea-5c58-86ed-fcf7da71780e', false, now()),
  ('82c797ce-5159-5cd8-836b-539f338a693e', '084f3db5-8c8f-58f5-ac1c-1343a811e0fb', '7c5a3eeb-ac26-5d5e-a7b0-993955c63a2e', false, now()),
  ('f9ac2f6e-e1b4-5ce3-9adb-a55c4abaaf5d', '084f3db5-8c8f-58f5-ac1c-1343a811e0fb', '9246c74e-5181-5a6b-b070-a8eef9887948', false, now()),
  ('e74b0939-4cff-59a2-870d-de72763e2e3d', '084f3db5-8c8f-58f5-ac1c-1343a811e0fb', 'cd48f1e6-f8ed-5aba-bfbd-aec1829312ab', false, now()),
  ('a3b656da-7946-599e-b578-6483958c5b3b', '084f3db5-8c8f-58f5-ac1c-1343a811e0fb', 'f69bb091-dd4b-58bf-93ca-0714bddd536b', false, now()),
  ('d3ac8520-e393-565b-9d35-eaeadbc1cd5b', '084f3db5-8c8f-58f5-ac1c-1343a811e0fb', '062598be-12eb-5eab-acb6-714fe9e8eb1f', false, now()),
  ('1b3d0bf1-7ba0-55a8-a324-73faf950ed2b', '084f3db5-8c8f-58f5-ac1c-1343a811e0fb', '9d8b0c5a-1e2c-5f42-8200-1c1d537f7a1c', false, now()),
  ('8d89656e-15b9-5bb8-a702-499d5bf10790', '084f3db5-8c8f-58f5-ac1c-1343a811e0fb', '3482e7ed-b143-5b9c-b171-2751b12d8d37', false, now()),
  ('f9a04425-be91-503c-9410-1c7350e52708', '084f3db5-8c8f-58f5-ac1c-1343a811e0fb', 'd9c9f910-bc47-5316-8c00-780378806085', false, now()),
  ('4fadd547-8c58-58ab-9972-73099cef7b25', '084f3db5-8c8f-58f5-ac1c-1343a811e0fb', 'a68e3753-6295-5f35-b261-3142072da22c', false, now()),
  ('f57ff4ef-45b6-5bf2-8888-31c4c61c2245', '084f3db5-8c8f-58f5-ac1c-1343a811e0fb', '9d3b3416-e19f-54cf-968e-5ed8c655e90a', false, now())
ON CONFLICT DO NOTHING;

-- Vínculos de apoyo: persona + organización + plantilla + vigencia + recertificación.
INSERT INTO delegated_access.organization_user_assignments (id, tenant_membership_id, assignment_role_concept_id, access_scope_concept_id, valid_from, status_concept_id, created_at, updated_at, row_version, origin_concept_id, owner_kind_concept_id, role_template_id, recertify_every_months, next_recertification_at, tenant_id) VALUES
  ('9f1761b6-e456-5a99-bf11-d14b05077d4f', 'acfb9d27-1a45-59aa-bcf0-3ab41d6fb954', 'dc407af0-7ce8-56b3-9b7b-fe2b68bbb8ec', 'e49e9baa-f3b1-5011-83ee-d1e3017aed36', now(), '38a1d301-f40d-5b17-a695-5e6d605f8b19', now(), now(), 1, 'cdef8f46-a60e-5a84-97e3-37d5007e905d', '6397159b-1477-5551-9950-862b8b8ce122', 'e6868a49-9408-50e0-8ea8-c3d79ff435f8', 6, now() + interval '6 months', '830e47e1-8e82-50ff-99c0-bfed0a7971a4'),
  ('f9e96f37-5a9a-5ccb-aaea-21b880985301', '5daf7732-61df-5723-8272-e0442affb385', '9663275c-312f-5165-bd04-aebe7b3fdf36', 'e49e9baa-f3b1-5011-83ee-d1e3017aed36', now(), '38a1d301-f40d-5b17-a695-5e6d605f8b19', now(), now(), 1, '320e177a-bda6-543f-97e6-d6c30873db41', '6397159b-1477-5551-9950-862b8b8ce122', 'a210d088-6991-5250-b8c9-299875747d59', 12, now() + interval '12 months', '830e47e1-8e82-50ff-99c0-bfed0a7971a4'),
  ('c10fff7f-6b09-5a73-bec6-f96365eb2fb6', 'bf74d532-44d6-5a9d-981c-8fb019d24b46', '2e3e235b-5144-5e08-9141-41a402e3bee1', 'e49e9baa-f3b1-5011-83ee-d1e3017aed36', now(), '38a1d301-f40d-5b17-a695-5e6d605f8b19', now(), now(), 1, 'a36afaec-1203-5ec7-beb3-d1595e264929', '6397159b-1477-5551-9950-862b8b8ce122', 'da9a9ff5-16ec-55f0-a56a-44183573326a', 6, now() + interval '6 months', '830e47e1-8e82-50ff-99c0-bfed0a7971a4'),
  ('fa601b88-ccf6-5360-aea4-52a889a0d5a7', '802edee6-aea4-56d2-aeef-9e9a3acc9eb6', 'dc407af0-7ce8-56b3-9b7b-fe2b68bbb8ec', 'e49e9baa-f3b1-5011-83ee-d1e3017aed36', now(), '38a1d301-f40d-5b17-a695-5e6d605f8b19', now(), now(), 1, 'cdef8f46-a60e-5a84-97e3-37d5007e905d', '17bb2ba1-8ddd-58d8-92d4-d419980e4ff1', 'e6868a49-9408-50e0-8ea8-c3d79ff435f8', 12, now() + interval '12 months', 'a52f851c-e5c2-5a32-b99e-a4993ff5a287')
ON CONFLICT DO NOTHING;

-- D-03 (compuerta de ingreso): estos vínculos son los «existentes» del piloto y quedan como COMPLETOS (onboarding_completed_at = created_at);
-- sin esto, con `onboardingRequired` (por omisión true) la política los cortaría con ONBOARDING_INCOMPLETE si se cargan después de la fecha
-- `onboardingRequiredSince`. La columna nace en el parche v4272 (y en el DDL generado): en una base anterior no existe y no se hace nada
-- (el parche v4272 los completa después: sección «vínculos existentes»).
DO $onboarding$
BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.columns
              WHERE table_schema = 'delegated_access' AND table_name = 'organization_user_assignments'
                AND column_name = 'onboarding_completed_at') THEN
    UPDATE delegated_access.organization_user_assignments
       SET onboarding_completed_at = created_at, updated_at = now()
     WHERE id IN ('9f1761b6-e456-5a99-bf11-d14b05077d4f', 'f9e96f37-5a9a-5ccb-aaea-21b880985301',
                  'c10fff7f-6b09-5a73-bec6-f96365eb2fb6', 'fa601b88-ccf6-5360-aea4-52a889a0d5a7')
       AND onboarding_completed_at IS NULL;
  END IF;
END
$onboarding$;

-- Permisos (uno por fila; varias filas se suman).
INSERT INTO delegated_access.support_scope_grants (id, tenant_id, organization_user_assignment_id, target_kind_concept_id, practitioner_role_assignment_id, healthcare_service_id, care_space_id, practice_site_id, expansion_mode_concept_id, valid_from, status_concept_id, approved_by_user_id, created_at, updated_at, row_version) VALUES
  ('656e1227-25d4-5369-bf7d-7a87b9cfa812', '830e47e1-8e82-50ff-99c0-bfed0a7971a4', '9f1761b6-e456-5a99-bf11-d14b05077d4f', '785d1671-5754-58d3-b1a3-e3cd467b82b7', 'f4e4d910-002f-5a42-a3fa-8696220f940b', NULL, NULL, NULL, 'd9ed1dfe-f5e6-55f3-94f2-2bd60993a536', now(), 'ccfbc54f-4744-53db-ab1f-abe1af31f784', 'a9dd40bb-1eb5-5b58-ae2a-06896d8c2810', now(), now(), 1),
  ('552db38b-e6ef-5b1b-9e4f-fd354ab57b8f', '830e47e1-8e82-50ff-99c0-bfed0a7971a4', '9f1761b6-e456-5a99-bf11-d14b05077d4f', '785d1671-5754-58d3-b1a3-e3cd467b82b7', 'c3e867d0-28d9-526d-bd16-71e4cdb285d2', NULL, NULL, NULL, 'd9ed1dfe-f5e6-55f3-94f2-2bd60993a536', now(), 'ccfbc54f-4744-53db-ab1f-abe1af31f784', 'a9dd40bb-1eb5-5b58-ae2a-06896d8c2810', now(), now(), 1),
  ('758b9ee7-3d31-58d6-b789-42cae36d00f9', '830e47e1-8e82-50ff-99c0-bfed0a7971a4', 'f9e96f37-5a9a-5ccb-aaea-21b880985301', '10510d38-c6cf-5243-9327-5cefc6c3aee5', NULL, NULL, 'a5b6c244-a0ce-56e2-9d76-cdb2f3f184c1', NULL, 'd9ed1dfe-f5e6-55f3-94f2-2bd60993a536', now(), 'ccfbc54f-4744-53db-ab1f-abe1af31f784', 'a9dd40bb-1eb5-5b58-ae2a-06896d8c2810', now(), now(), 1),
  ('0ac0749f-d76d-588b-bafa-037a5e6cad50', '830e47e1-8e82-50ff-99c0-bfed0a7971a4', 'c10fff7f-6b09-5a73-bec6-f96365eb2fb6', '953e4408-5e19-521b-a25a-3d062d788911', NULL, 'da47af6a-fc7a-5d56-93cb-7bbe45b26ce5', NULL, NULL, 'd9ed1dfe-f5e6-55f3-94f2-2bd60993a536', now(), 'ccfbc54f-4744-53db-ab1f-abe1af31f784', 'a9dd40bb-1eb5-5b58-ae2a-06896d8c2810', now(), now(), 1),
  ('2af9f387-d337-5ea7-bedf-716967fd740d', '830e47e1-8e82-50ff-99c0-bfed0a7971a4', 'c10fff7f-6b09-5a73-bec6-f96365eb2fb6', '2ed23be8-884f-5e75-bd63-a1ff92f42e89', 'd487ae98-c6f5-57d1-ac38-b651d303f080', NULL, NULL, 'bf2841a5-e92f-5b2b-b77e-23e11712c554', 'd9ed1dfe-f5e6-55f3-94f2-2bd60993a536', now(), 'ccfbc54f-4744-53db-ab1f-abe1af31f784', 'a9dd40bb-1eb5-5b58-ae2a-06896d8c2810', now(), now(), 1),
  ('dc350c15-4611-5270-95c6-2921c4d79a4c', 'a52f851c-e5c2-5a32-b99e-a4993ff5a287', 'fa601b88-ccf6-5360-aea4-52a889a0d5a7', '785d1671-5754-58d3-b1a3-e3cd467b82b7', 'efe35bb0-3812-59d9-80f8-3f2c3092ac4f', NULL, NULL, NULL, 'd9ed1dfe-f5e6-55f3-94f2-2bd60993a536', now(), 'ccfbc54f-4744-53db-ab1f-abe1af31f784', '25036a8b-fb9d-52c3-82ec-c5ca03179d75', now(), now(), 1)
ON CONFLICT DO NOTHING;

-- Acciones de cada permiso = las de su plantilla por defecto.
INSERT INTO delegated_access.support_grant_actions (id, tenant_id, support_scope_grant_id, permission_id, created_at) VALUES
  ('18d376f6-7e3d-5ac0-9704-1c5fab08c0cd', '830e47e1-8e82-50ff-99c0-bfed0a7971a4', '656e1227-25d4-5369-bf7d-7a87b9cfa812', '438c578b-e5ea-5c58-86ed-fcf7da71780e', now()),
  ('49c3e7d3-b3ff-5280-ad99-345492b7181d', '830e47e1-8e82-50ff-99c0-bfed0a7971a4', '656e1227-25d4-5369-bf7d-7a87b9cfa812', '7c5a3eeb-ac26-5d5e-a7b0-993955c63a2e', now()),
  ('12b2fa60-a205-524a-86fb-635d7539a1a7', '830e47e1-8e82-50ff-99c0-bfed0a7971a4', '656e1227-25d4-5369-bf7d-7a87b9cfa812', '9246c74e-5181-5a6b-b070-a8eef9887948', now()),
  ('7c1085ed-cdac-5d3b-bdf2-9b518e1a63a3', '830e47e1-8e82-50ff-99c0-bfed0a7971a4', '656e1227-25d4-5369-bf7d-7a87b9cfa812', 'cd48f1e6-f8ed-5aba-bfbd-aec1829312ab', now()),
  ('98ca3fb0-4e07-5c57-ba59-cd2fb2193e0a', '830e47e1-8e82-50ff-99c0-bfed0a7971a4', '656e1227-25d4-5369-bf7d-7a87b9cfa812', 'f69bb091-dd4b-58bf-93ca-0714bddd536b', now()),
  ('68a9273d-853c-59b0-a26b-2d3ac9afd09f', '830e47e1-8e82-50ff-99c0-bfed0a7971a4', '656e1227-25d4-5369-bf7d-7a87b9cfa812', '062598be-12eb-5eab-acb6-714fe9e8eb1f', now()),
  ('0f54227c-e55e-5af2-94b3-8f1a14f759df', '830e47e1-8e82-50ff-99c0-bfed0a7971a4', '656e1227-25d4-5369-bf7d-7a87b9cfa812', '9d8b0c5a-1e2c-5f42-8200-1c1d537f7a1c', now()),
  ('c471723d-0265-55c2-a503-019624e24635', '830e47e1-8e82-50ff-99c0-bfed0a7971a4', '656e1227-25d4-5369-bf7d-7a87b9cfa812', '3482e7ed-b143-5b9c-b171-2751b12d8d37', now()),
  ('68ef95d2-fb06-59dd-9da5-467128b3f541', '830e47e1-8e82-50ff-99c0-bfed0a7971a4', '656e1227-25d4-5369-bf7d-7a87b9cfa812', 'd9c9f910-bc47-5316-8c00-780378806085', now()),
  ('61402b8a-9f30-51a6-bca0-423618cd8041', '830e47e1-8e82-50ff-99c0-bfed0a7971a4', '656e1227-25d4-5369-bf7d-7a87b9cfa812', 'a68e3753-6295-5f35-b261-3142072da22c', now()),
  ('eb5abb54-fa04-5cc3-ab17-d4622913a14a', '830e47e1-8e82-50ff-99c0-bfed0a7971a4', '656e1227-25d4-5369-bf7d-7a87b9cfa812', '9d3b3416-e19f-54cf-968e-5ed8c655e90a', now()),
  ('8a830232-a9d3-554a-a462-4207402e5976', '830e47e1-8e82-50ff-99c0-bfed0a7971a4', '552db38b-e6ef-5b1b-9e4f-fd354ab57b8f', '438c578b-e5ea-5c58-86ed-fcf7da71780e', now()),
  ('ea5abd70-00f3-5497-98e0-034adcf442c7', '830e47e1-8e82-50ff-99c0-bfed0a7971a4', '552db38b-e6ef-5b1b-9e4f-fd354ab57b8f', '7c5a3eeb-ac26-5d5e-a7b0-993955c63a2e', now()),
  ('cb866b74-e6ab-5834-950f-47f4b0553bb0', '830e47e1-8e82-50ff-99c0-bfed0a7971a4', '552db38b-e6ef-5b1b-9e4f-fd354ab57b8f', '9246c74e-5181-5a6b-b070-a8eef9887948', now()),
  ('e401b796-1cf6-55f4-bfa2-5b1d7b885bf5', '830e47e1-8e82-50ff-99c0-bfed0a7971a4', '552db38b-e6ef-5b1b-9e4f-fd354ab57b8f', 'cd48f1e6-f8ed-5aba-bfbd-aec1829312ab', now()),
  ('269392af-ce08-5221-9d1d-de5b24021db3', '830e47e1-8e82-50ff-99c0-bfed0a7971a4', '552db38b-e6ef-5b1b-9e4f-fd354ab57b8f', 'f69bb091-dd4b-58bf-93ca-0714bddd536b', now()),
  ('90de1d93-2625-5076-b24c-d7049049c63f', '830e47e1-8e82-50ff-99c0-bfed0a7971a4', '552db38b-e6ef-5b1b-9e4f-fd354ab57b8f', '062598be-12eb-5eab-acb6-714fe9e8eb1f', now()),
  ('9eeaba88-ca2d-5d72-a299-5f430ddd5d76', '830e47e1-8e82-50ff-99c0-bfed0a7971a4', '552db38b-e6ef-5b1b-9e4f-fd354ab57b8f', '9d8b0c5a-1e2c-5f42-8200-1c1d537f7a1c', now()),
  ('2e323110-e087-5aa8-981c-1e4c5982f28b', '830e47e1-8e82-50ff-99c0-bfed0a7971a4', '552db38b-e6ef-5b1b-9e4f-fd354ab57b8f', '3482e7ed-b143-5b9c-b171-2751b12d8d37', now()),
  ('1903b8b4-9548-50dc-a606-c51af6edb58b', '830e47e1-8e82-50ff-99c0-bfed0a7971a4', '552db38b-e6ef-5b1b-9e4f-fd354ab57b8f', 'd9c9f910-bc47-5316-8c00-780378806085', now()),
  ('c7fa27a2-a551-59c4-8440-095e90c902c8', '830e47e1-8e82-50ff-99c0-bfed0a7971a4', '552db38b-e6ef-5b1b-9e4f-fd354ab57b8f', 'a68e3753-6295-5f35-b261-3142072da22c', now()),
  ('2c37025b-0536-5cb9-bbce-cb0a713b99c2', '830e47e1-8e82-50ff-99c0-bfed0a7971a4', '552db38b-e6ef-5b1b-9e4f-fd354ab57b8f', '9d3b3416-e19f-54cf-968e-5ed8c655e90a', now()),
  ('c7f4c5b8-1d3a-5837-8fe8-5d4cd991ede1', '830e47e1-8e82-50ff-99c0-bfed0a7971a4', '758b9ee7-3d31-58d6-b789-42cae36d00f9', '438c578b-e5ea-5c58-86ed-fcf7da71780e', now()),
  ('018407ce-c40a-5b2a-beea-bca77710e11e', '830e47e1-8e82-50ff-99c0-bfed0a7971a4', '758b9ee7-3d31-58d6-b789-42cae36d00f9', '062598be-12eb-5eab-acb6-714fe9e8eb1f', now()),
  ('6835671f-b174-565f-906d-b350d8e1e5cf', '830e47e1-8e82-50ff-99c0-bfed0a7971a4', '758b9ee7-3d31-58d6-b789-42cae36d00f9', '9d8b0c5a-1e2c-5f42-8200-1c1d537f7a1c', now()),
  ('392d2f20-a7d7-5449-96e8-0d71d2847361', '830e47e1-8e82-50ff-99c0-bfed0a7971a4', '758b9ee7-3d31-58d6-b789-42cae36d00f9', 'a68e3753-6295-5f35-b261-3142072da22c', now()),
  ('31441818-17e7-572b-bb0f-4981b532425d', '830e47e1-8e82-50ff-99c0-bfed0a7971a4', '0ac0749f-d76d-588b-bafa-037a5e6cad50', '438c578b-e5ea-5c58-86ed-fcf7da71780e', now()),
  ('faee6afe-5041-5e35-b7b9-9c5cb452802a', '830e47e1-8e82-50ff-99c0-bfed0a7971a4', '0ac0749f-d76d-588b-bafa-037a5e6cad50', '7c5a3eeb-ac26-5d5e-a7b0-993955c63a2e', now()),
  ('191829ae-5c9e-52a0-a883-f4f82e699d0c', '830e47e1-8e82-50ff-99c0-bfed0a7971a4', '0ac0749f-d76d-588b-bafa-037a5e6cad50', '9246c74e-5181-5a6b-b070-a8eef9887948', now()),
  ('bd946c9b-7391-5214-9150-1fcc1c31e3fc', '830e47e1-8e82-50ff-99c0-bfed0a7971a4', '0ac0749f-d76d-588b-bafa-037a5e6cad50', 'cd48f1e6-f8ed-5aba-bfbd-aec1829312ab', now()),
  ('88945c7a-b413-5aa7-a46f-a862f56e70af', '830e47e1-8e82-50ff-99c0-bfed0a7971a4', '2af9f387-d337-5ea7-bedf-716967fd740d', '438c578b-e5ea-5c58-86ed-fcf7da71780e', now()),
  ('0f326822-a61c-5d65-a627-560950d277ae', '830e47e1-8e82-50ff-99c0-bfed0a7971a4', '2af9f387-d337-5ea7-bedf-716967fd740d', '7c5a3eeb-ac26-5d5e-a7b0-993955c63a2e', now()),
  ('54ff8303-7795-5a02-9818-a48a1d4c06da', '830e47e1-8e82-50ff-99c0-bfed0a7971a4', '2af9f387-d337-5ea7-bedf-716967fd740d', '9246c74e-5181-5a6b-b070-a8eef9887948', now()),
  ('4c78a562-5c5d-58a3-bd0f-ce1210d0137b', '830e47e1-8e82-50ff-99c0-bfed0a7971a4', '2af9f387-d337-5ea7-bedf-716967fd740d', 'cd48f1e6-f8ed-5aba-bfbd-aec1829312ab', now()),
  ('1ca51ab2-93df-5af6-ac67-644904a26364', 'a52f851c-e5c2-5a32-b99e-a4993ff5a287', 'dc350c15-4611-5270-95c6-2921c4d79a4c', '438c578b-e5ea-5c58-86ed-fcf7da71780e', now()),
  ('33584e67-1dfb-52a8-b035-a3be0097c5b3', 'a52f851c-e5c2-5a32-b99e-a4993ff5a287', 'dc350c15-4611-5270-95c6-2921c4d79a4c', '7c5a3eeb-ac26-5d5e-a7b0-993955c63a2e', now()),
  ('f6266ccb-0669-55b6-9892-1e2953184932', 'a52f851c-e5c2-5a32-b99e-a4993ff5a287', 'dc350c15-4611-5270-95c6-2921c4d79a4c', '9246c74e-5181-5a6b-b070-a8eef9887948', now()),
  ('87ccd87f-4283-5e64-8497-31b5f031c470', 'a52f851c-e5c2-5a32-b99e-a4993ff5a287', 'dc350c15-4611-5270-95c6-2921c4d79a4c', 'cd48f1e6-f8ed-5aba-bfbd-aec1829312ab', now()),
  ('fbb5f1a5-7ed4-5fc5-9212-7edb5ed9ed0d', 'a52f851c-e5c2-5a32-b99e-a4993ff5a287', 'dc350c15-4611-5270-95c6-2921c4d79a4c', 'f69bb091-dd4b-58bf-93ca-0714bddd536b', now()),
  ('35b97752-fb12-562b-950a-be68548175b7', 'a52f851c-e5c2-5a32-b99e-a4993ff5a287', 'dc350c15-4611-5270-95c6-2921c4d79a4c', '062598be-12eb-5eab-acb6-714fe9e8eb1f', now()),
  ('16971ad3-60c7-5d8b-b813-6824fae227af', 'a52f851c-e5c2-5a32-b99e-a4993ff5a287', 'dc350c15-4611-5270-95c6-2921c4d79a4c', '9d8b0c5a-1e2c-5f42-8200-1c1d537f7a1c', now()),
  ('6f961b56-b76b-52b3-959f-66e1501183d6', 'a52f851c-e5c2-5a32-b99e-a4993ff5a287', 'dc350c15-4611-5270-95c6-2921c4d79a4c', '3482e7ed-b143-5b9c-b171-2751b12d8d37', now()),
  ('125e6db5-02af-57cd-a63e-8c4a1f0aeed1', 'a52f851c-e5c2-5a32-b99e-a4993ff5a287', 'dc350c15-4611-5270-95c6-2921c4d79a4c', 'd9c9f910-bc47-5316-8c00-780378806085', now()),
  ('5078ce4b-aa27-5152-b4a2-9ef7e85cd761', 'a52f851c-e5c2-5a32-b99e-a4993ff5a287', 'dc350c15-4611-5270-95c6-2921c4d79a4c', 'a68e3753-6295-5f35-b261-3142072da22c', now()),
  ('a3e204de-be0f-5795-a413-8b6cd648baf2', 'a52f851c-e5c2-5a32-b99e-a4993ff5a287', 'dc350c15-4611-5270-95c6-2921c4d79a4c', '9d3b3416-e19f-54cf-968e-5ed8c655e90a', now())
ON CONFLICT DO NOTHING;

-- Aceptación del doctor: acepta UNA vez la cláusula de apoyo y, aparte, a cada persona que responde en su nombre (Pérez sí acepta que Ana responda; Rojas no).
-- v4.2.70: support_access_allowed exige esta aceptación del doctor de la cita (falla cerrada), así que TODA persona de apoyo
-- que opera sobre un doctor la necesita: Lucía acepta Pérez/Méndez/Vaca (su ubicación) y Marcos Antelo/Suárez/Rojas (sus permisos); ninguna puede responder en su nombre.
INSERT INTO delegated_access.practitioner_delegate_assignments (id, practitioner_role_assignment_id, delegate_user_assignment_id, delegated_permission_set_id, delegate_role_concept_id, may_view_clinical_content, may_edit_drafts, may_sign_clinical_content, valid_from, status_concept_id, created_at, updated_at, row_version, may_reply_on_behalf, reply_disclosure_concept_id, accepted_at, tenant_id) VALUES
  ('011a9583-44f5-5554-962c-c0acd1402218', 'f4e4d910-002f-5a42-a3fa-8696220f940b', '9f1761b6-e456-5a99-bf11-d14b05077d4f', '0ba62ad0-e22f-553b-9496-14829b7bbf9c', 'afb80bf4-0d35-5088-b4e3-bdba011cf227', false, false, false, now(), '38a1d301-f40d-5b17-a695-5e6d605f8b19', now(), now(), 1, true, '7078aa21-2624-5d9e-beb2-a8bdfa8ad471', now(), '830e47e1-8e82-50ff-99c0-bfed0a7971a4'),
  ('fd3470eb-3847-53d8-ad35-f8edeb212036', 'c3e867d0-28d9-526d-bd16-71e4cdb285d2', '9f1761b6-e456-5a99-bf11-d14b05077d4f', '0ba62ad0-e22f-553b-9496-14829b7bbf9c', 'afb80bf4-0d35-5088-b4e3-bdba011cf227', false, false, false, now(), '38a1d301-f40d-5b17-a695-5e6d605f8b19', now(), now(), 1, false, '7078aa21-2624-5d9e-beb2-a8bdfa8ad471', now(), '830e47e1-8e82-50ff-99c0-bfed0a7971a4'),
  ('4f71d7cc-3a47-5e2a-bf63-304bb3f5413d', 'efe35bb0-3812-59d9-80f8-3f2c3092ac4f', 'fa601b88-ccf6-5360-aea4-52a889a0d5a7', '084f3db5-8c8f-58f5-ac1c-1343a811e0fb', 'afb80bf4-0d35-5088-b4e3-bdba011cf227', false, false, false, now(), '38a1d301-f40d-5b17-a695-5e6d605f8b19', now(), now(), 1, true, '7078aa21-2624-5d9e-beb2-a8bdfa8ad471', now(), 'a52f851c-e5c2-5a32-b99e-a4993ff5a287'),
  ('9aaae7fd-1d8e-5fc4-9360-57f5c5260b2d', 'f4e4d910-002f-5a42-a3fa-8696220f940b', 'f9e96f37-5a9a-5ccb-aaea-21b880985301', 'd7cdc136-1d24-5c8d-bcea-13aa04f17ff2', 'afb80bf4-0d35-5088-b4e3-bdba011cf227', false, false, false, now(), '38a1d301-f40d-5b17-a695-5e6d605f8b19', now(), now(), 1, false, '7078aa21-2624-5d9e-beb2-a8bdfa8ad471', now(), '830e47e1-8e82-50ff-99c0-bfed0a7971a4'),
  ('4a200819-8d8a-5655-8033-661f96621617', '223616d5-8cc4-5ea1-9e2e-5b971b001cad', 'f9e96f37-5a9a-5ccb-aaea-21b880985301', 'd7cdc136-1d24-5c8d-bcea-13aa04f17ff2', 'afb80bf4-0d35-5088-b4e3-bdba011cf227', false, false, false, now(), '38a1d301-f40d-5b17-a695-5e6d605f8b19', now(), now(), 1, false, '7078aa21-2624-5d9e-beb2-a8bdfa8ad471', now(), '830e47e1-8e82-50ff-99c0-bfed0a7971a4'),
  ('0bc88961-af9b-51b7-9893-34a09c9084c6', 'd52be48f-1b3b-5ba7-8c4a-4e53eb3bed9c', 'f9e96f37-5a9a-5ccb-aaea-21b880985301', 'd7cdc136-1d24-5c8d-bcea-13aa04f17ff2', 'afb80bf4-0d35-5088-b4e3-bdba011cf227', false, false, false, now(), '38a1d301-f40d-5b17-a695-5e6d605f8b19', now(), now(), 1, false, '7078aa21-2624-5d9e-beb2-a8bdfa8ad471', now(), '830e47e1-8e82-50ff-99c0-bfed0a7971a4'),
  ('9e3e580c-2627-50a2-9fdd-96437720683d', '30a0f73d-3668-5859-9f78-ade7a0a7cde7', 'c10fff7f-6b09-5a73-bec6-f96365eb2fb6', '80e771c4-9220-5e1d-8549-5b192a51857a', 'afb80bf4-0d35-5088-b4e3-bdba011cf227', false, false, false, now(), '38a1d301-f40d-5b17-a695-5e6d605f8b19', now(), now(), 1, false, '7078aa21-2624-5d9e-beb2-a8bdfa8ad471', now(), '830e47e1-8e82-50ff-99c0-bfed0a7971a4'),
  ('df1c725e-1757-5314-bf01-0c67763009eb', 'd487ae98-c6f5-57d1-ac38-b651d303f080', 'c10fff7f-6b09-5a73-bec6-f96365eb2fb6', '80e771c4-9220-5e1d-8549-5b192a51857a', 'afb80bf4-0d35-5088-b4e3-bdba011cf227', false, false, false, now(), '38a1d301-f40d-5b17-a695-5e6d605f8b19', now(), now(), 1, false, '7078aa21-2624-5d9e-beb2-a8bdfa8ad471', now(), '830e47e1-8e82-50ff-99c0-bfed0a7971a4'),
  ('80e7c73d-4eab-57aa-9349-e691e2f4e68f', 'c3e867d0-28d9-526d-bd16-71e4cdb285d2', 'c10fff7f-6b09-5a73-bec6-f96365eb2fb6', '80e771c4-9220-5e1d-8549-5b192a51857a', 'afb80bf4-0d35-5088-b4e3-bdba011cf227', false, false, false, now(), '38a1d301-f40d-5b17-a695-5e6d605f8b19', now(), now(), 1, false, '7078aa21-2624-5d9e-beb2-a8bdfa8ad471', now(), '830e47e1-8e82-50ff-99c0-bfed0a7971a4')
ON CONFLICT DO NOTHING;

-- Política de sesión del personal del hospital (30 min de inactividad).
INSERT INTO iam.session_policies (id, tenant_id, scope_concept_id, role_code, idle_timeout_minutes, new_device_alert, enforce_ip_rules, require_mfa, status_concept_id, created_at, updated_at, row_version) VALUES
  ('801a5995-c79d-51db-bcb9-43df5ff65407', '830e47e1-8e82-50ff-99c0-bfed0a7971a4', '028a8eb3-49f0-5bd0-a607-8237e4b52406', NULL, 30, true, false, false, '38a1d301-f40d-5b17-a695-5e6d605f8b19', now(), now(), 1)
ON CONFLICT DO NOTHING;

-- Invitación (QR/enlace) vigente para personal de recepción. El hash es ficticio.
INSERT INTO directory.affiliation_invitations (id, tenant_id, kind_concept_id, token_hash, max_uses, uses_count, expires_at, role_template_id, status_concept_id, created_by_user_id, created_at, updated_at, row_version) VALUES
  ('211813aa-9d63-5e6c-8b66-9cc3e3e1d520', '830e47e1-8e82-50ff-99c0-bfed0a7971a4', '41cc4a3e-11bb-5611-ab5b-ff91a4ae9f8f', 'dcac3247e11a0c2b1c1f30dc57a2ae7e22b4c8b0b8c78b36a7ff9d5b8ffd7a00', 10, 0, now() + interval '15 days', 'a210d088-6991-5250-b8c9-299875747d59', 'ba78fe78-e802-5a35-b51e-0d38ceea7aac', 'a9dd40bb-1eb5-5b58-ae2a-06896d8c2810', now(), now(), 1)
ON CONFLICT DO NOTHING;

-- Respuestas rápidas.
INSERT INTO community.reply_templates (id, tenant_id, practitioner_profile_id, category_concept_id, title, body_text, status_concept_id, created_at, updated_at, row_version) VALUES
  ('4ad13015-67c2-56e2-a4ac-781d833b49ea', '830e47e1-8e82-50ff-99c0-bfed0a7971a4', NULL, '5e413313-5202-526a-a3ad-66a901360327', 'Horarios de atención', 'Hola, atendemos de lunes a viernes de 08:00 a 18:00. Para agendar una cita indícanos el día que prefieres.', '38a1d301-f40d-5b17-a695-5e6d605f8b19', now(), now(), 1),
  ('884d536f-0e96-5239-85f9-15261c694b2a', '830e47e1-8e82-50ff-99c0-bfed0a7971a4', NULL, '63928e74-8746-5dae-813e-857a2720c292', 'Preparación para estudios', 'Recuerda llegar 15 minutos antes y traer tu documento y las órdenes de estudio.', '38a1d301-f40d-5b17-a695-5e6d605f8b19', now(), now(), 1),
  ('04886a6c-e917-51e0-bb4f-df35092a6827', '830e47e1-8e82-50ff-99c0-bfed0a7971a4', '96307267-f432-5fd2-9bd0-e609625088ab', '1bf34fbc-455d-5373-bada-632eac6d1176', 'Control de cardiología', 'El control se agenda cada 6 meses. Escríbenos y buscamos el primer horario libre del doctor.', '38a1d301-f40d-5b17-a695-5e6d605f8b19', now(), now(), 1)
ON CONFLICT DO NOTHING;

-- Tabla derivada de accesos: se reconstruye si el parche v4269 ya está aplicado.
-- Sin el parche la función no existe y el refresco queda a cargo del worker de la API.
DO $refresh$
BEGIN
  IF to_regprocedure('delegated_access.refresh_effective_support_access(uuid)') IS NOT NULL THEN
    PERFORM delegated_access.refresh_effective_support_access(NULL);
  END IF;
END
$refresh$;

COMMIT;

\echo == hospital piloto (demo) cargado ==
SELECT (SELECT count(*) FROM practice.care_spaces WHERE code LIKE 'DEMO\_%') AS espacios,
       (SELECT count(*) FROM delegated_access.support_scope_grants WHERE id IN ('656e1227-25d4-5369-bf7d-7a87b9cfa812', '552db38b-e6ef-5b1b-9e4f-fd354ab57b8f', '758b9ee7-3d31-58d6-b789-42cae36d00f9', '0ac0749f-d76d-588b-bafa-037a5e6cad50', '2af9f387-d337-5ea7-bedf-716967fd740d', 'dc350c15-4611-5270-95c6-2921c4d79a4c')) AS permisos_de_apoyo,
       (SELECT count(*) FROM practice.practitioner_location_assignments pla JOIN practice.practitioner_role_assignments pra ON pra.id = pla.practitioner_role_assignment_id WHERE pra.practice_id IN ('314eeab4-0062-5e4f-b3f1-4e26174daa10', 'b248aef6-7047-5128-90bd-e2d75225b5fe')) AS ubicaciones_de_doctores;
