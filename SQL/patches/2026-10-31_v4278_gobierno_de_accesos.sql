-- ============================================================================
-- SALUD · patch v4.2.78 (gobierno de accesos: permisos de ultra granularidad y gobierno de usuarios) sobre BD viva
-- Fecha: 2026-11-02
-- Idempotente (CREATE TABLE / INDEX IF NOT EXISTS, ADD COLUMN IF NOT EXISTS, FKs con duplicate_object, CHECK con
-- DROP IF EXISTS + ADD, triggers con DROP IF EXISTS + CREATE, semillas con ON CONFLICT). UNA sola transaccion; se puede volver a correr.
-- Mismo estilo que 2026-10-31_v4275_personal_apoyo.sql, que debe estar aplicado ANTES (orden: v4275 -> v4278).
--
-- Contexto: gen_ddl.py y gen_integrity.py ya emiten TODO lo de las secciones 2-6 en SQL/<NN>_<schema>/ desde que los .puml lo declaran
-- (modulos 06, 29 y la matriz 33), asi que en un rebuild desde cero esas secciones NO hacen falta. Este archivo existe para una base ya
-- aplicada y poblada. Las secciones 7 (semillas de arranque), 8 (funciones y disparadores) y 9 (RLS) NO se derivan de ningun .puml:
-- solo viven aqui (tambien en un rebuild desde cero hay que correr este parche para tenerlas, como el v4275). gen_apply.py no escanea
-- SQL/patches/. Contrato: CONTRATO-GOBIERNO.md (§7 y Anexos A-B).
--
-- QUE AGREGA
--   conceptos       +92 (7 authz, 1 audit, 84 delegated_access) + los existentes que referencian las filas nuevas (INSERT ... ON CONFLICT DO NOTHING;
--                   los mismos ids que deriva la API: si ya arranco, es un no-op)
--   authz.permissions  +8 columnas (sensibilidad, motivo, paso extra, aprobacion, proposito de uso, base legal, clinico, asignable a apoyo)
--   delegated_access   +12 tablas (governance_rules, sod_rules, sod_exceptions, four_eyes_requests, access_review_campaigns,
--                   access_review_items, lifecycle_cases, handover_items, patient_restriction_flags, access_decision_log [WORM],
--                   grant_usage_stats, access_anomalies) y columnas en support_scope_grants (+5: efecto ALLOW/DENY, condicion ABAC v1, motivo,
--                   plantilla de origen), support_grant_actions (+5: condicion, superseded_at), role_templates (+2: condiciones por defecto y
--                   techo) y organization_user_assignments (+9: identidad verificada, suspension, incorporacion, certificacion)
--   vinculos        los vinculos de apoyo EXISTENTES quedan con incorporacion completa (onboarding_completed_at = created_at; D-03) si no tienen
--                   caso de ingreso: la compuerta solo rige para los nuevos
--   semillas        73 permisos atomicos + 7 categorias; los 15 codigos antiguos quedan como ALIAS (misma fila, mismo id) NO asignables a apoyo, con la
--                   sensibilidad de su atomo primario y el motivo/paso extra/aprobacion de sus atomos (v4.2.79); 11 reglas SoD de plataforma; 7 plantillas de rol v2
--                   (paquete en atomos + techo + condiciones por defecto; las v1 quedan RETIRADAS pero existen); rol de sistema SUPPORT_STAFF
--                   (no asignable) con su piso de campos
--   funciones       refresh_effective_support_access se REEMPLAZA: ya no materializa un DENY ni una accion reemplazada (H20; mismo despliegue que
--                   effect_concept_id); integrity.support_tenant_consistency se EXTIENDE; +access_review_reviewer_not_subject, +sod_rules_only_stricter
--   RLS             tenant_isolation en las 11 tablas con tenant_id NOT NULL + sod_rules (+ global_catalog_read para las reglas de plataforma)
--
-- DELTAS ESPERADOS sobre la base viva (una base con v4275 y sin este parche):
--   tablas        +12
--   columnas      +29  (8 en authz.permissions + 21 en delegated_access)
--   FKs           +98
--   indices       +111  (secundarios y unicos parciales; los PK nacen con las tablas)
--   CHECK         +35
--   disparadores  +10: trg_access_review_reviewer_not_subject, trg_sod_rules_only_stricter, trg_forbid_mutation (access_decision_log) y
--                 7 trg_support_tenant_consistency nuevos (los de support_scope_grants y support_grant_actions se recrean)
--   funciones     +2 nuevas y 2 reemplazadas
--   politicas     tenant_isolation en 25 tablas SI la base ya usa RLS, y global_catalog_read en sod_rules
--
-- BACKFILL: effect_concept_id nace en ALLOW para toda concesion existente (NOT NULL DEFAULT) y el resto es NULL; unica excepcion de negocio: la
-- seccion 7b marca como completa la incorporacion (onboarding_completed_at = created_at) de los vinculos existentes sin caso de ingreso (D-03).
-- Los alias ya concedidos siguen vivos, pero heredan las obligaciones de sus atomos y no se pueden conceder de nuevo a apoyo (v4.2.79).
--
-- REVERSA (si hiciera falta; el parche solo agrega, un rollback de la API deja datos inertes):
--   DROP TRIGGER IF EXISTS trg_sod_rules_only_stricter ON "delegated_access"."sod_rules";
--   DROP TRIGGER IF EXISTS trg_access_review_reviewer_not_subject ON "delegated_access"."access_review_items";
--   DROP TRIGGER IF EXISTS trg_support_tenant_consistency ON <access_review_items, handover_items, sod_exceptions, lifecycle_cases,
--     four_eyes_requests, grant_usage_stats, access_anomalies>;   (los de support_scope_grants/support_grant_actions se quedan: son del v4275)
--   DROP FUNCTION IF EXISTS "integrity"."sod_rules_only_stricter"(), "integrity"."access_review_reviewer_not_subject"();
--   volver a correr la seccion 6 del v4275 restituye refresh_effective_support_access y support_tenant_consistency anteriores
--   DROP TABLE IF EXISTS <las 12 tablas nuevas de delegated_access>;
--   ALTER TABLE ... DROP COLUMN IF EXISTS <las columnas de la seccion 2>;  (en authz.permissions: sensitivity_concept_id, requires_reason,
--     requires_step_up, approval_mode_concept_id, purpose_of_use_concept_id, legal_basis_concept_id, touches_clinical_data, support_assignable)
--   DROP POLICY IF EXISTS global_catalog_read ON "delegated_access"."sod_rules";
--   DELETE de las semillas por id (73 permisos atomicos, 7 categorias, 11 reglas SoD, 7 plantillas v2, rol SUPPORT_STAFF y su piso) y
--   UPDATE de las 7 plantillas v1 a su estado ACTIVO si se quiere restituir.
-- ============================================================================

BEGIN;

-- ---- 1. conceptos (92 nuevos + los existentes que las filas nuevas referencian) ----
-- Anclas del catalogo (mismos ids que deriva la API): no-op si ya existen.
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
  ('2a5b8592-dcf4-5643-af29-609b689c5a96', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'authz:SENSITIVITY_LOW', 'Permission sensitivity: low', false, true, now(), now(), 1),  -- authz:SENSITIVITY_LOW
  ('0beaba91-1b4d-5e7b-8ba9-be584245df0a', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'authz:SENSITIVITY_MEDIUM', 'Permission sensitivity: medium', false, true, now(), now(), 1),  -- authz:SENSITIVITY_MEDIUM
  ('e9e9a413-e636-5eb1-8d73-62f67b9c57f3', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'authz:SENSITIVITY_HIGH', 'Permission sensitivity: high', false, true, now(), now(), 1),  -- authz:SENSITIVITY_HIGH
  ('dc8d3a20-6a3f-5d2f-b85f-85475513a93b', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'authz:SENSITIVITY_CRITICAL', 'Permission sensitivity: critical', false, true, now(), now(), 1),  -- authz:SENSITIVITY_CRITICAL
  ('1ec189f8-507a-5fce-9fac-09a584864c04', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'authz:APPROVAL_DOCTOR', 'Approval required from the practitioner', false, true, now(), now(), 1),  -- authz:APPROVAL_DOCTOR
  ('610c6456-d162-539e-b21e-2d19a4a99b88', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'authz:APPROVAL_SECOND_APPROVER', 'Approval required from a second approver (four eyes)', false, true, now(), now(), 1),  -- authz:APPROVAL_SECOND_APPROVER
  ('de62f18e-c56d-5ed2-a2f0-2ce76a2a52f0', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'authz:APPROVAL_SERVICE_HEAD', 'Approval required from the head of the service', false, true, now(), now(), 1),  -- authz:APPROVAL_SERVICE_HEAD
  ('42521499-302b-56b5-ae4a-b3a0d2e6f468', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'audit:LEGAL_BASIS_HEALTHCARE_OPERATIONS', 'Legal basis: healthcare operations', false, true, now(), now(), 1),  -- audit:LEGAL_BASIS_HEALTHCARE_OPERATIONS
  ('2e3f3830-b5cc-5661-902e-9106df223081', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'delegated_access:GOV_RULE_DENY_PERMISSION', 'Governance rule: deny a permission to a role', false, true, now(), now(), 1),  -- delegated_access:GOV_RULE_DENY_PERMISSION
  ('ce906685-7a58-54e7-b4d2-458062c0c303', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'delegated_access:GOV_RULE_CEILING', 'Governance rule: delegation ceiling', false, true, now(), now(), 1),  -- delegated_access:GOV_RULE_CEILING
  ('1b6db045-2cc5-5985-9c89-18b8ac0969be', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'delegated_access:GOV_RULE_REQUIRE_CONDITION', 'Governance rule: mandatory condition', false, true, now(), now(), 1),  -- delegated_access:GOV_RULE_REQUIRE_CONDITION
  ('f2534b4a-a8cc-5fb1-a431-30e1a750274b', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'delegated_access:GOV_RULE_FIELD_FLOOR', 'Governance rule: field visibility floor', false, true, now(), now(), 1),  -- delegated_access:GOV_RULE_FIELD_FLOOR
  ('d317a334-2e99-5361-836c-674cbeec5d26', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'delegated_access:SOD_ACTION_BLOCK', 'SoD action: block', false, true, now(), now(), 1),  -- delegated_access:SOD_ACTION_BLOCK
  ('117ffae4-a53b-5f5a-a927-d625ae57ad67', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'delegated_access:SOD_ACTION_REQUIRE_APPROVAL', 'SoD action: require approval', false, true, now(), now(), 1),  -- delegated_access:SOD_ACTION_REQUIRE_APPROVAL
  ('156a7df4-b47c-52d3-9646-9f201757db51', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'delegated_access:SOD_ACTION_WARN', 'SoD action: warn', false, true, now(), now(), 1),  -- delegated_access:SOD_ACTION_WARN
  ('0fb8d904-8d4c-5ff5-972e-b0968cadc699', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'delegated_access:SOD_SCOPE_PERSON', 'SoD scope: same person', false, true, now(), now(), 1),  -- delegated_access:SOD_SCOPE_PERSON
  ('5959b7b1-6a78-5a16-a856-8bd7b4395a0a', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'delegated_access:SOD_SCOPE_PERSON_OVERLAP', 'SoD scope: same person, overlapping coverage', false, true, now(), now(), 1),  -- delegated_access:SOD_SCOPE_PERSON_OVERLAP
  ('926b5260-3468-5925-9aae-6ebbd4942fea', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'delegated_access:SOD_SCOPE_TRANSACTION', 'SoD scope: same transaction', false, true, now(), now(), 1),  -- delegated_access:SOD_SCOPE_TRANSACTION
  ('a977935a-9073-5113-9644-7df96732e776', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'delegated_access:FOUR_EYES_PENDING', 'Four-eyes request pending', false, true, now(), now(), 1),  -- delegated_access:FOUR_EYES_PENDING
  ('1627143e-d273-5fcb-b289-9e59b8b096f2', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'delegated_access:FOUR_EYES_APPROVED', 'Four-eyes request approved', false, true, now(), now(), 1),  -- delegated_access:FOUR_EYES_APPROVED
  ('de15c53d-1aa0-5709-8ebd-69e9fd323e31', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'delegated_access:FOUR_EYES_REJECTED', 'Four-eyes request rejected', false, true, now(), now(), 1),  -- delegated_access:FOUR_EYES_REJECTED
  ('94e35d5c-9790-5e6d-acaf-ae253e56101f', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'delegated_access:FOUR_EYES_EXPIRED', 'Four-eyes request expired', false, true, now(), now(), 1),  -- delegated_access:FOUR_EYES_EXPIRED
  ('cda80e89-c845-5d7e-aac1-f50bf78ef050', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'delegated_access:FOUR_EYES_CANCELLED', 'Four-eyes request cancelled', false, true, now(), now(), 1),  -- delegated_access:FOUR_EYES_CANCELLED
  ('013d578f-38af-564c-aff1-e36d1fdec6dd', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'delegated_access:FOUR_EYES_EXECUTED', 'Four-eyes request executed', false, true, now(), now(), 1),  -- delegated_access:FOUR_EYES_EXECUTED
  ('201ca117-97ad-58c2-a6d3-803ea412cd2c', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'delegated_access:FOUR_EYES_KIND_ACTION', 'Four-eyes kind: sensitive action', false, true, now(), now(), 1),  -- delegated_access:FOUR_EYES_KIND_ACTION
  ('26a6dc6f-0b9f-5946-9214-e43a7382de68', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'delegated_access:FOUR_EYES_KIND_GRANT_CHANGE', 'Four-eyes kind: grant change above the ceiling', false, true, now(), now(), 1),  -- delegated_access:FOUR_EYES_KIND_GRANT_CHANGE
  ('5b36bf36-7f60-5d20-a2ea-3c7826e8d492', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'delegated_access:FOUR_EYES_KIND_SOD_EXCEPTION', 'Four-eyes kind: SoD exception', false, true, now(), now(), 1),  -- delegated_access:FOUR_EYES_KIND_SOD_EXCEPTION
  ('99b6eaae-af0b-5929-b0f9-666be9ed3a83', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'delegated_access:FOUR_EYES_KIND_REACTIVATION', 'Four-eyes kind: reactivation', false, true, now(), now(), 1),  -- delegated_access:FOUR_EYES_KIND_REACTIVATION
  ('c5dace75-a0b2-5bac-bdda-5b19d7f0aaef', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'delegated_access:FOUR_EYES_KIND_ENGAGEMENT_MOVE', 'Four-eyes kind: engagement move with more privilege', false, true, now(), now(), 1),  -- delegated_access:FOUR_EYES_KIND_ENGAGEMENT_MOVE
  ('969627cf-9dff-5f7d-b6c6-8478414a6822', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'delegated_access:REVIEW_KIND_PERIODIC', 'Access review kind: periodic', false, true, now(), now(), 1),  -- delegated_access:REVIEW_KIND_PERIODIC
  ('9f831109-61d2-54d4-8e67-7ad04ac9a315', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'delegated_access:REVIEW_KIND_RECERTIFICATION', 'Access review kind: recertification', false, true, now(), now(), 1),  -- delegated_access:REVIEW_KIND_RECERTIFICATION
  ('c5759b60-79a6-5ff3-bca5-08d2d68b7387', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'delegated_access:REVIEW_KIND_MOVER', 'Access review kind: after a role/scope change', false, true, now(), now(), 1),  -- delegated_access:REVIEW_KIND_MOVER
  ('0105205a-86d2-538e-8d76-b51f93753d23', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'delegated_access:REVIEW_KIND_TARGETED', 'Access review kind: targeted', false, true, now(), now(), 1),  -- delegated_access:REVIEW_KIND_TARGETED
  ('4c13052c-1c83-571d-b201-40d74c23d430', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'delegated_access:REVIEW_KIND_REMEDIATION', 'Access review kind: remediation (above ceiling / SoD)', false, true, now(), now(), 1),  -- delegated_access:REVIEW_KIND_REMEDIATION
  ('743d9f11-b186-5547-ae3d-cc44d94724bd', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'delegated_access:REVIEW_CAMPAIGN_DRAFT', 'Access review campaign draft', false, true, now(), now(), 1),  -- delegated_access:REVIEW_CAMPAIGN_DRAFT
  ('faa5c9bf-5300-5e43-8829-19a9f0e94fef', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'delegated_access:REVIEW_CAMPAIGN_OPEN', 'Access review campaign open', false, true, now(), now(), 1),  -- delegated_access:REVIEW_CAMPAIGN_OPEN
  ('01114233-ee4d-52d2-beeb-821534f835e6', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'delegated_access:REVIEW_CAMPAIGN_CLOSED', 'Access review campaign closed', false, true, now(), now(), 1),  -- delegated_access:REVIEW_CAMPAIGN_CLOSED
  ('b01bd8d2-99d0-5c44-a77d-2a3093f9695c', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'delegated_access:REVIEW_CAMPAIGN_CANCELLED', 'Access review campaign cancelled', false, true, now(), now(), 1),  -- delegated_access:REVIEW_CAMPAIGN_CANCELLED
  ('55a6db07-19e7-5bb4-978a-3d246492f49d', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'delegated_access:REVIEW_ITEM_PENDING', 'Access review item pending', false, true, now(), now(), 1),  -- delegated_access:REVIEW_ITEM_PENDING
  ('a3896ca4-e2a6-5b1b-a192-6b457ea34586', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'delegated_access:REVIEW_ITEM_CERTIFIED', 'Access review item certified', false, true, now(), now(), 1),  -- delegated_access:REVIEW_ITEM_CERTIFIED
  ('bce72e9a-b3bb-5fab-8e79-85d411ba692c', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'delegated_access:REVIEW_ITEM_REVOKED', 'Access review item revoked', false, true, now(), now(), 1),  -- delegated_access:REVIEW_ITEM_REVOKED
  ('26f790b1-6d77-5286-89d5-0e82a4dcfb81', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'delegated_access:REVIEW_ITEM_ADJUSTED', 'Access review item adjusted', false, true, now(), now(), 1),  -- delegated_access:REVIEW_ITEM_ADJUSTED
  ('c94f52a2-fba0-5d54-a379-e7aa6a8e1144', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'delegated_access:REVIEW_ITEM_AUTO_REVOKED', 'Access review item auto-revoked (not certified)', false, true, now(), now(), 1),  -- delegated_access:REVIEW_ITEM_AUTO_REVOKED
  ('6aacf6b6-9473-5589-b191-90f8d378aa63', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'delegated_access:REVIEW_ITEM_SKIPPED', 'Access review item skipped', false, true, now(), now(), 1),  -- delegated_access:REVIEW_ITEM_SKIPPED
  ('75b09a0e-44df-5830-93d0-6539c00145fd', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'delegated_access:REVIEWER_KIND_DOCTOR_OWNER', 'Reviewer: the practitioner', false, true, now(), now(), 1),  -- delegated_access:REVIEWER_KIND_DOCTOR_OWNER
  ('716540f6-d919-5f7f-8fe9-7f50909b789f', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'delegated_access:REVIEWER_KIND_SERVICE_HEAD', 'Reviewer: head of service', false, true, now(), now(), 1),  -- delegated_access:REVIEWER_KIND_SERVICE_HEAD
  ('7e4272cc-9ebe-575a-bc36-b6983980a68f', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'delegated_access:REVIEWER_KIND_SUPERVISOR', 'Reviewer: supervisor of the account', false, true, now(), now(), 1),  -- delegated_access:REVIEWER_KIND_SUPERVISOR
  ('ca9f26e2-6ed7-5292-b073-b876770c6433', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'delegated_access:REVIEWER_KIND_ADMIN', 'Reviewer: organization administrator', false, true, now(), now(), 1),  -- delegated_access:REVIEWER_KIND_ADMIN
  ('cdc3190b-22f6-5662-8ae0-34c1fb5c2ed2', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'delegated_access:UNCERTIFIED_REVOKE', 'Not certified: revoke', false, true, now(), now(), 1),  -- delegated_access:UNCERTIFIED_REVOKE
  ('36d4dcbd-19f6-51d2-a763-77c4889d8d35', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'delegated_access:UNCERTIFIED_ESCALATE', 'Not certified: escalate only', false, true, now(), now(), 1),  -- delegated_access:UNCERTIFIED_ESCALATE
  ('c2a9a59d-c88c-5e87-9065-1e0e068c479d', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'delegated_access:LIFECYCLE_JOINER', 'Lifecycle case: joiner', false, true, now(), now(), 1),  -- delegated_access:LIFECYCLE_JOINER
  ('57910aca-6dba-56f3-89ae-e60e12cd0752', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'delegated_access:LIFECYCLE_MOVER', 'Lifecycle case: mover', false, true, now(), now(), 1),  -- delegated_access:LIFECYCLE_MOVER
  ('52380372-44ca-5da2-9cf2-df8602006405', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'delegated_access:LIFECYCLE_LEAVER', 'Lifecycle case: leaver', false, true, now(), now(), 1),  -- delegated_access:LIFECYCLE_LEAVER
  ('767afaf6-3161-56ee-8c96-5e9386804fc0', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'delegated_access:LIFECYCLE_SUSPENSION', 'Lifecycle case: suspension', false, true, now(), now(), 1),  -- delegated_access:LIFECYCLE_SUSPENSION
  ('429c40b8-eb46-5d8c-97c3-edf591657254', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'delegated_access:LIFECYCLE_REACTIVATION', 'Lifecycle case: reactivation', false, true, now(), now(), 1),  -- delegated_access:LIFECYCLE_REACTIVATION
  ('4f73e30c-25ba-52ff-969e-862e588cce13', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'delegated_access:LIFECYCLE_OPEN', 'Lifecycle case open', false, true, now(), now(), 1),  -- delegated_access:LIFECYCLE_OPEN
  ('4734035e-72cf-519f-8e27-e6cf25ba557f', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'delegated_access:LIFECYCLE_COMPLETED', 'Lifecycle case completed', false, true, now(), now(), 1),  -- delegated_access:LIFECYCLE_COMPLETED
  ('19fce939-19ff-5c9e-b7b3-5d14ba721ca7', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'delegated_access:LIFECYCLE_CANCELLED', 'Lifecycle case cancelled', false, true, now(), now(), 1),  -- delegated_access:LIFECYCLE_CANCELLED
  ('2e3528d8-17e6-56e8-ac36-f2875c3c1d30', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'delegated_access:HANDOVER_CONVERSATION', 'Handover item: conversation', false, true, now(), now(), 1),  -- delegated_access:HANDOVER_CONVERSATION
  ('a4f162d4-dfbc-5b08-afff-d1be949d0692', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'delegated_access:HANDOVER_WORKFLOW_TASK', 'Handover item: workflow task', false, true, now(), now(), 1),  -- delegated_access:HANDOVER_WORKFLOW_TASK
  ('9705ceb3-0065-5ef3-8279-ba4d8b560406', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'delegated_access:HANDOVER_SUPERVISED_ENGAGEMENT', 'Handover item: supervised account', false, true, now(), now(), 1),  -- delegated_access:HANDOVER_SUPERVISED_ENGAGEMENT
  ('01dc2120-cc99-5743-ba80-ac342e5642e7', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'delegated_access:HANDOVER_PENDING_BOOKING', 'Handover item: pending booking (informative)', false, true, now(), now(), 1),  -- delegated_access:HANDOVER_PENDING_BOOKING
  ('29406164-994b-55ab-bc88-697e22cd1cbc', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'delegated_access:HANDOVER_PENDING', 'Handover pending', false, true, now(), now(), 1),  -- delegated_access:HANDOVER_PENDING
  ('57d9c373-5a94-5fd6-bf9c-bd6a95cb2a91', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'delegated_access:HANDOVER_REASSIGNED', 'Handover reassigned', false, true, now(), now(), 1),  -- delegated_access:HANDOVER_REASSIGNED
  ('30b914c9-ead2-5b3e-9e59-7837726f4d6b', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'delegated_access:HANDOVER_RETURNED_TO_POOL', 'Handover returned to the reception pool', false, true, now(), now(), 1),  -- delegated_access:HANDOVER_RETURNED_TO_POOL
  ('d8858706-8072-5c85-bdba-a4ddbfde549d', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'delegated_access:HANDOVER_CLOSED', 'Handover closed without action', false, true, now(), now(), 1),  -- delegated_access:HANDOVER_CLOSED
  ('971fef05-5343-556d-96ac-851f50adc7de', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'delegated_access:SUSPENSION_MANUAL', 'Suspension reason: manual', false, true, now(), now(), 1),  -- delegated_access:SUSPENSION_MANUAL
  ('3d36501c-449c-53da-bc5a-03e1b261dfd3', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'delegated_access:SUSPENSION_LEAVE', 'Suspension reason: leave of absence', false, true, now(), now(), 1),  -- delegated_access:SUSPENSION_LEAVE
  ('6b7d7624-50f0-57bb-bed7-37f6b095f6d5', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'delegated_access:SUSPENSION_INVESTIGATION', 'Suspension reason: under investigation', false, true, now(), now(), 1),  -- delegated_access:SUSPENSION_INVESTIGATION
  ('a2315bc4-1655-5e68-a29e-fadb56d78490', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'delegated_access:SUSPENSION_INACTIVITY', 'Suspension reason: inactivity', false, true, now(), now(), 1),  -- delegated_access:SUSPENSION_INACTIVITY
  ('a3424a33-1969-5a90-b929-a6d2da19c735', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'delegated_access:SUSPENSION_RECERTIFICATION_LAPSED', 'Suspension reason: recertification lapsed', false, true, now(), now(), 1),  -- delegated_access:SUSPENSION_RECERTIFICATION_LAPSED
  ('e8273ad4-4e98-5dcb-869e-f34019625dbc', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'delegated_access:IDENTITY_METHOD_IN_PERSON', 'Identity verified in person with a document', false, true, now(), now(), 1),  -- delegated_access:IDENTITY_METHOD_IN_PERSON
  ('ec46b4ba-fd91-5ae9-9293-137f79f98637', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'delegated_access:IDENTITY_METHOD_DOCUMENT_UPLOAD', 'Identity verified from an uploaded document', false, true, now(), now(), 1),  -- delegated_access:IDENTITY_METHOD_DOCUMENT_UPLOAD
  ('e80db404-0819-597b-93e8-3fff6b4e8eac', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'delegated_access:IDENTITY_METHOD_PLATFORM', 'Identity already verified by the platform', false, true, now(), now(), 1),  -- delegated_access:IDENTITY_METHOD_PLATFORM
  ('baf4dc8a-ac39-5c94-a176-92e012bd024f', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'delegated_access:PATIENT_FLAG_VIP', 'Patient restriction: VIP', false, true, now(), now(), 1),  -- delegated_access:PATIENT_FLAG_VIP
  ('697c3db6-133e-5d64-a6fb-6b9d4d5342d5', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'delegated_access:PATIENT_FLAG_CONFIDENTIAL', 'Patient restriction: confidential', false, true, now(), now(), 1),  -- delegated_access:PATIENT_FLAG_CONFIDENTIAL
  ('e384ff44-2406-56ea-80f7-f7f37018cc35', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'delegated_access:PATIENT_FLAG_STAFF_RELATIVE', 'Patient restriction: relative of staff', false, true, now(), now(), 1),  -- delegated_access:PATIENT_FLAG_STAFF_RELATIVE
  ('cc971a72-7aff-5474-b0fe-9099b5c69405', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'delegated_access:PATIENT_FLAG_PROTECTED', 'Patient restriction: protected (safety)', false, true, now(), now(), 1),  -- delegated_access:PATIENT_FLAG_PROTECTED
  ('444c2600-a8d7-5adf-b1a8-e6416402c5f6', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'delegated_access:DECISION_EFFECT_PERMIT', 'Access decision: permit', false, true, now(), now(), 1),  -- delegated_access:DECISION_EFFECT_PERMIT
  ('179b3675-742f-552c-b50e-4bba5c79262e', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'delegated_access:DECISION_EFFECT_DENY', 'Access decision: deny', false, true, now(), now(), 1),  -- delegated_access:DECISION_EFFECT_DENY
  ('3a1287bc-836d-5d84-92df-9c92f129f7b5', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'delegated_access:DECISION_EFFECT_CHALLENGE', 'Access decision: challenge (reason, step-up or approval)', false, true, now(), now(), 1),  -- delegated_access:DECISION_EFFECT_CHALLENGE
  ('7f20d407-aa33-5757-a6e0-3ddf9160592d', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'delegated_access:ANOMALY_SEARCH_SPIKE', 'Anomaly: spike of patient searches', false, true, now(), now(), 1),  -- delegated_access:ANOMALY_SEARCH_SPIKE
  ('45046d7b-b2ac-5217-9f20-ad8762fc9b43', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'delegated_access:ANOMALY_CANCEL_SPIKE', 'Anomaly: spike of cancellations', false, true, now(), now(), 1),  -- delegated_access:ANOMALY_CANCEL_SPIKE
  ('a0ad134a-96e5-596d-a508-e6895a75c62d', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'delegated_access:ANOMALY_OFF_HOURS', 'Anomaly: sensitive activity off hours', false, true, now(), now(), 1),  -- delegated_access:ANOMALY_OFF_HOURS
  ('db538591-37bd-554d-bf1d-f6239dddf71e', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'delegated_access:ANOMALY_DENIED_BURST', 'Anomaly: burst of denied attempts', false, true, now(), now(), 1),  -- delegated_access:ANOMALY_DENIED_BURST
  ('5c1ba80a-84be-51ff-b80f-882006bbdacf', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'delegated_access:ANOMALY_BROWSE_PATIENTS', 'Anomaly: many distinct patients viewed', false, true, now(), now(), 1),  -- delegated_access:ANOMALY_BROWSE_PATIENTS
  ('b188b551-f49c-557f-95d0-432e1cfb3214', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'delegated_access:ANOMALY_INACTIVE_ACCOUNT', 'Anomaly: inactive account with live access', false, true, now(), now(), 1),  -- delegated_access:ANOMALY_INACTIVE_ACCOUNT
  ('d1743b44-0500-50b3-b0c2-7ff5156ab25e', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'delegated_access:ANOMALY_PRIVILEGE_CREEP', 'Anomaly: privilege accumulation', false, true, now(), now(), 1),  -- delegated_access:ANOMALY_PRIVILEGE_CREEP
  ('5dc5d5c6-03af-5c50-9841-2559f959a180', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'delegated_access:ANOMALY_OPEN', 'Anomaly open', false, true, now(), now(), 1),  -- delegated_access:ANOMALY_OPEN
  ('b6352476-bd20-5b04-8008-2d363504aee5', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'delegated_access:ANOMALY_ACKNOWLEDGED', 'Anomaly acknowledged', false, true, now(), now(), 1),  -- delegated_access:ANOMALY_ACKNOWLEDGED
  ('1c8f5b91-371b-5967-b8fd-98d08f80ac9c', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'delegated_access:ANOMALY_DISMISSED', 'Anomaly dismissed', false, true, now(), now(), 1),  -- delegated_access:ANOMALY_DISMISSED
  ('ec7ffd73-1272-5e63-b6ec-da5c5d45e334', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'delegated_access:ANOMALY_ESCALATED', 'Anomaly escalated', false, true, now(), now(), 1),  -- delegated_access:ANOMALY_ESCALATED
  ('f61506db-f890-5ee2-b94b-3a0614a1725a', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'authz:ACTION_DELETE', 'Delete', false, true, now(), now(), 1),  -- authz:ACTION_DELETE
  ('3721e545-b640-5765-8268-65b7d1a8e8e9', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'authz:ACTION_APPROVE', 'Approve', false, true, now(), now(), 1),  -- authz:ACTION_APPROVE
  ('366c58bc-ee9e-55ed-8306-7844bad4521b', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'authz:PURPOSE_TREATMENT', 'Treatment', false, true, now(), now(), 1),  -- authz:PURPOSE_TREATMENT
  ('2d7a1066-c15a-5b13-ae77-bdfce86ead96', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'authz:PURPOSE_PAYMENT', 'Payment', false, true, now(), now(), 1),  -- authz:PURPOSE_PAYMENT
  ('394283d3-702b-5748-9900-df62233b6150', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'authz:PURPOSE_OPERATIONS', 'Operations', false, true, now(), now(), 1),  -- authz:PURPOSE_OPERATIONS
  ('6905e0db-1650-5d49-adca-8b2688ac049c', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'authz:EFFECT_ALLOW', 'Allow', false, true, now(), now(), 1),  -- authz:EFFECT_ALLOW
  ('b038e546-a6ba-5848-9cd2-04b02ccb22b0', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'authz:EFFECT_DENY', 'Deny', false, true, now(), now(), 1),  -- authz:EFFECT_DENY
  ('1d9cfe89-1075-54dd-a197-a52d33962533', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'authz:BASE_ROLE_STAFF', 'Staff base role', false, true, now(), now(), 1),  -- authz:BASE_ROLE_STAFF
  ('3b501456-1e56-539b-806c-37286d15df43', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'audit:LEGAL_BASIS_TREATMENT', 'Treatment legal basis', false, true, now(), now(), 1),  -- audit:LEGAL_BASIS_TREATMENT
  ('eb9f5178-755e-590a-82df-9eb68913e1b5', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'audit:LEGAL_BASIS_CONSENT', 'Consent legal basis', false, true, now(), now(), 1),  -- audit:LEGAL_BASIS_CONSENT
  ('3f73e692-c05f-588c-b921-3956bfd35cb5', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'audit:LEGAL_BASIS_LEGAL_OBLIGATION', 'Legal obligation basis', false, true, now(), now(), 1),  -- audit:LEGAL_BASIS_LEGAL_OBLIGATION
  ('38a1d301-f40d-5b17-a695-5e6d605f8b19', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'ACTIVE', 'Active', false, true, now(), now(), 1),  -- state:active
  ('6b070aec-a5af-52bc-8462-55be0d26298a', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'delegated_access:ROLE_TEMPLATE_ACTIVE', 'Role template active', false, true, now(), now(), 1),  -- delegated_access:ROLE_TEMPLATE_ACTIVE
  ('f2889c99-ac92-52a0-94dc-db6fed4edad8', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'delegated_access:ROLE_TEMPLATE_RETIRED', 'Role template retired', false, true, now(), now(), 1),  -- delegated_access:ROLE_TEMPLATE_RETIRED
  ('1b45f74f-f39e-58eb-b29a-86c100efeb67', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'authz:SCOPE_TENANT', 'Tenant scope', false, true, now(), now(), 1),  -- authz:SCOPE_TENANT
  ('ea5aa219-9b0f-538f-9ca5-0e7eb4e715cf', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'authz:ACTION_READ', 'Read', false, true, now(), now(), 1),  -- authz:ACTION_READ
  ('0491c4bb-2c42-5acb-b422-8da33bd0b4a3', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'authz:ACTION_WRITE', 'Write', false, true, now(), now(), 1),  -- authz:ACTION_WRITE
  ('89c2342b-cec1-5678-b97c-e33c304d5519', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'authz:ACTION_CREATE', 'Create', false, true, now(), now(), 1),  -- authz:ACTION_CREATE
  ('11f6b39b-272e-52c4-9583-3bd153b1e21e', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'authz:ACTION_EXECUTE', 'Execute', false, true, now(), now(), 1)  -- authz:ACTION_EXECUTE
ON CONFLICT DO NOTHING;

-- ---- 2. columnas nuevas en tablas existentes (29) ----

ALTER TABLE "authz"."permissions"
    ADD COLUMN IF NOT EXISTS "sensitivity_concept_id" uuid;

ALTER TABLE "authz"."permissions"
    ADD COLUMN IF NOT EXISTS "requires_reason" boolean NOT NULL DEFAULT false;

ALTER TABLE "authz"."permissions"
    ADD COLUMN IF NOT EXISTS "requires_step_up" boolean NOT NULL DEFAULT false;

ALTER TABLE "authz"."permissions"
    ADD COLUMN IF NOT EXISTS "approval_mode_concept_id" uuid;

ALTER TABLE "authz"."permissions"
    ADD COLUMN IF NOT EXISTS "purpose_of_use_concept_id" uuid;

ALTER TABLE "authz"."permissions"
    ADD COLUMN IF NOT EXISTS "legal_basis_concept_id" uuid;

ALTER TABLE "authz"."permissions"
    ADD COLUMN IF NOT EXISTS "touches_clinical_data" boolean NOT NULL DEFAULT false;

ALTER TABLE "authz"."permissions"
    ADD COLUMN IF NOT EXISTS "support_assignable" boolean NOT NULL DEFAULT false;

ALTER TABLE "delegated_access"."organization_user_assignments"
    ADD COLUMN IF NOT EXISTS "identity_verified_at" timestamptz;

ALTER TABLE "delegated_access"."organization_user_assignments"
    ADD COLUMN IF NOT EXISTS "identity_verified_by_user_id" uuid;

ALTER TABLE "delegated_access"."organization_user_assignments"
    ADD COLUMN IF NOT EXISTS "identity_method_concept_id" uuid;

ALTER TABLE "delegated_access"."organization_user_assignments"
    ADD COLUMN IF NOT EXISTS "suspended_at" timestamptz;

ALTER TABLE "delegated_access"."organization_user_assignments"
    ADD COLUMN IF NOT EXISTS "suspension_reason_concept_id" uuid;

ALTER TABLE "delegated_access"."organization_user_assignments"
    ADD COLUMN IF NOT EXISTS "suspension_note_text" text;

ALTER TABLE "delegated_access"."organization_user_assignments"
    ADD COLUMN IF NOT EXISTS "onboarding_completed_at" timestamptz;

ALTER TABLE "delegated_access"."organization_user_assignments"
    ADD COLUMN IF NOT EXISTS "last_certified_at" timestamptz;

ALTER TABLE "delegated_access"."organization_user_assignments"
    ADD COLUMN IF NOT EXISTS "last_active_at" timestamptz;

ALTER TABLE "delegated_access"."role_templates"
    ADD COLUMN IF NOT EXISTS "default_conditions_json" jsonb;

ALTER TABLE "delegated_access"."role_templates"
    ADD COLUMN IF NOT EXISTS "ceiling_actions_json" jsonb;

ALTER TABLE "delegated_access"."support_scope_grants"
    ADD COLUMN IF NOT EXISTS "effect_concept_id" uuid NOT NULL DEFAULT '6905e0db-1650-5d49-adca-8b2688ac049c';

ALTER TABLE "delegated_access"."support_scope_grants"
    ADD COLUMN IF NOT EXISTS "condition_json" jsonb;

ALTER TABLE "delegated_access"."support_scope_grants"
    ADD COLUMN IF NOT EXISTS "condition_schema_version" integer;

ALTER TABLE "delegated_access"."support_scope_grants"
    ADD COLUMN IF NOT EXISTS "reason_text" text;

ALTER TABLE "delegated_access"."support_scope_grants"
    ADD COLUMN IF NOT EXISTS "source_role_template_id" uuid;

ALTER TABLE "delegated_access"."support_grant_actions"
    ADD COLUMN IF NOT EXISTS "condition_json" jsonb;

ALTER TABLE "delegated_access"."support_grant_actions"
    ADD COLUMN IF NOT EXISTS "condition_schema_version" integer;

ALTER TABLE "delegated_access"."support_grant_actions"
    ADD COLUMN IF NOT EXISTS "superseded_at" timestamptz;

ALTER TABLE "delegated_access"."support_grant_actions"
    ADD COLUMN IF NOT EXISTS "updated_at" timestamptz;

ALTER TABLE "delegated_access"."support_grant_actions"
    ADD COLUMN IF NOT EXISTS "updated_by_user_id" uuid;

-- ---- 3. tablas nuevas (12) ----

CREATE TABLE IF NOT EXISTS "delegated_access"."governance_rules" (
    "id" uuid NOT NULL,
    "tenant_id" uuid NOT NULL,
    "rule_kind_concept_id" uuid NOT NULL,
    "role_template_code" varchar,
    "permission_pattern" varchar NOT NULL,
    "rule_json" jsonb,
    "rule_schema_version" integer,
    "message_text" text,
    "status_concept_id" uuid NOT NULL,
    "valid_from" timestamptz,
    "valid_to" timestamptz,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_governance_rules" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "delegated_access"."sod_rules" (
    "id" uuid NOT NULL,
    "tenant_id" uuid,
    "code" varchar NOT NULL,
    "name" varchar NOT NULL,
    "base_rule_id" uuid,
    "atoms_a_json" jsonb NOT NULL,
    "atoms_b_json" jsonb NOT NULL,
    "scope_concept_id" uuid NOT NULL,
    "action_concept_id" uuid NOT NULL,
    "is_hard" boolean NOT NULL DEFAULT false,
    "max_exception_days" integer,
    "rationale_text" text,
    "status_concept_id" uuid NOT NULL,
    "version_number" integer NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_sod_rules" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "delegated_access"."sod_exceptions" (
    "id" uuid NOT NULL,
    "tenant_id" uuid NOT NULL,
    "sod_rule_id" uuid NOT NULL,
    "organization_user_assignment_id" uuid NOT NULL,
    "four_eyes_request_id" uuid NOT NULL,
    "justification_text" text NOT NULL,
    "valid_from" timestamptz NOT NULL,
    "valid_to" timestamptz NOT NULL,
    "status_concept_id" uuid NOT NULL,
    "revoked_at" timestamptz,
    "revoked_by_user_id" uuid,
    "revoke_reason_text" text,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_sod_exceptions" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "delegated_access"."four_eyes_requests" (
    "id" uuid NOT NULL,
    "tenant_id" uuid NOT NULL,
    "kind_concept_id" uuid NOT NULL,
    "requester_user_id" uuid NOT NULL,
    "subject_user_id" uuid,
    "organization_user_assignment_id" uuid,
    "permission_code" varchar,
    "approver_kind_concept_id" uuid NOT NULL,
    "payload_json" jsonb NOT NULL,
    "payload_hash" varchar NOT NULL,
    "payload_schema_version" integer NOT NULL,
    "reason_text" text,
    "status_concept_id" uuid NOT NULL,
    "expires_at" timestamptz NOT NULL,
    "decided_at" timestamptz,
    "decided_by_user_id" uuid,
    "decision_comment_text" text,
    "approved_until" timestamptz,
    "consumed_at" timestamptz,
    "executed_at" timestamptz,
    "execution_result_json" jsonb,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_four_eyes_requests" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "delegated_access"."access_review_campaigns" (
    "id" uuid NOT NULL,
    "tenant_id" uuid NOT NULL,
    "name" varchar NOT NULL,
    "kind_concept_id" uuid NOT NULL,
    "scope_json" jsonb NOT NULL,
    "scope_schema_version" integer NOT NULL,
    "filters_json" jsonb,
    "due_at" timestamptz NOT NULL,
    "grace_days" integer NOT NULL DEFAULT 7,
    "reminder_days_before_json" jsonb NOT NULL DEFAULT '[7,3,1]',
    "escalate_after_days" integer NOT NULL DEFAULT 3,
    "uncertified_action_concept_id" uuid NOT NULL,
    "owner_user_id" uuid,
    "status_concept_id" uuid NOT NULL,
    "launched_at" timestamptz,
    "closed_at" timestamptz,
    "cancelled_at" timestamptz,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_access_review_campaigns" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "delegated_access"."access_review_items" (
    "id" uuid NOT NULL,
    "tenant_id" uuid NOT NULL,
    "access_review_campaign_id" uuid NOT NULL,
    "organization_user_assignment_id" uuid NOT NULL,
    "support_scope_grant_id" uuid,
    "reviewer_user_id" uuid,
    "reviewer_kind_concept_id" uuid NOT NULL,
    "decision_concept_id" uuid NOT NULL DEFAULT '55a6db07-19e7-5bb4-978a-3d246492f49d',
    "decided_at" timestamptz,
    "decided_by_user_id" uuid,
    "decision_comment_text" text,
    "adjustment_json" jsonb,
    "evidence_json" jsonb NOT NULL,
    "evidence_hash" varchar NOT NULL,
    "due_at" timestamptz NOT NULL,
    "reminder_count" integer NOT NULL DEFAULT 0,
    "last_reminded_at" timestamptz,
    "escalated_at" timestamptz,
    "escalated_to_user_id" uuid,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_access_review_items" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "delegated_access"."lifecycle_cases" (
    "id" uuid NOT NULL,
    "tenant_id" uuid NOT NULL,
    "organization_user_assignment_id" uuid NOT NULL,
    "subject_user_id" uuid NOT NULL,
    "kind_concept_id" uuid NOT NULL,
    "status_concept_id" uuid NOT NULL,
    "opened_by_user_id" uuid,
    "opened_at" timestamptz NOT NULL,
    "due_at" timestamptz,
    "completed_at" timestamptz,
    "reason_text" text,
    "checklist_json" jsonb NOT NULL,
    "details_json" jsonb,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_lifecycle_cases" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "delegated_access"."handover_items" (
    "id" uuid NOT NULL,
    "tenant_id" uuid NOT NULL,
    "lifecycle_case_id" uuid NOT NULL,
    "item_kind_concept_id" uuid NOT NULL,
    "source_id" uuid NOT NULL,
    "from_user_id" uuid NOT NULL,
    "to_user_id" uuid,
    "status_concept_id" uuid NOT NULL,
    "summary_text" varchar,
    "reassigned_at" timestamptz,
    "reassigned_by_user_id" uuid,
    "note_text" text,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_handover_items" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "delegated_access"."patient_restriction_flags" (
    "id" uuid NOT NULL,
    "tenant_id" uuid NOT NULL,
    "patient_profile_id" uuid NOT NULL,
    "flag_concept_id" uuid NOT NULL,
    "reason_text" text NOT NULL,
    "status_concept_id" uuid NOT NULL,
    "valid_from" timestamptz NOT NULL,
    "valid_to" timestamptz,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_patient_restriction_flags" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "delegated_access"."access_decision_log" (
    "id" uuid NOT NULL,
    "tenant_id" uuid NOT NULL,
    "user_id" uuid NOT NULL,
    "permission_code" varchar NOT NULL,
    "effect_concept_id" uuid NOT NULL,
    "reason_code" varchar NOT NULL,
    "grant_id" uuid,
    "rule_id" uuid,
    "practitioner_role_assignment_id" uuid,
    "healthcare_service_id" uuid,
    "care_space_id" uuid,
    "patient_profile_id" uuid,
    "approval_id" uuid,
    "correlation_id" uuid,
    "session_id" uuid,
    "ip" inet,
    "detail_json" jsonb,
    "recorded_at" timestamptz NOT NULL,
    "recorded_by_user_id" uuid,
    CONSTRAINT "pk_access_decision_log" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "delegated_access"."grant_usage_stats" (
    "id" uuid NOT NULL,
    "tenant_id" uuid NOT NULL,
    "user_id" uuid NOT NULL,
    "support_scope_grant_id" uuid NOT NULL,
    "permission_code" varchar NOT NULL,
    "bucket_start" timestamptz NOT NULL,
    "permit_count" integer NOT NULL DEFAULT 0,
    "deny_count" integer NOT NULL DEFAULT 0,
    "challenge_count" integer NOT NULL DEFAULT 0,
    "off_hours_count" integer NOT NULL DEFAULT 0,
    "distinct_patients_in_bucket" integer NOT NULL DEFAULT 0,
    "last_used_at" timestamptz,
    "updated_at" timestamptz NOT NULL,
    CONSTRAINT "pk_grant_usage_stats" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "delegated_access"."access_anomalies" (
    "id" uuid NOT NULL,
    "tenant_id" uuid NOT NULL,
    "user_id" uuid NOT NULL,
    "organization_user_assignment_id" uuid,
    "kind_concept_id" uuid NOT NULL,
    "window_start" timestamptz NOT NULL,
    "window_end" timestamptz NOT NULL,
    "observed_value" numeric(12,2) NOT NULL,
    "baseline_value" numeric(12,2),
    "threshold_value" numeric(12,2) NOT NULL,
    "evidence_json" jsonb NOT NULL,
    "status_concept_id" uuid NOT NULL,
    "acknowledged_by_user_id" uuid,
    "acknowledged_at" timestamptz,
    "resolution_comment_text" text,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_access_anomalies" PRIMARY KEY ("id")
);

-- ---- 4. claves foraneas (98) ----

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "authz"."permissions"
        ADD CONSTRAINT "fk_permissions_sensitivity_concept_id" FOREIGN KEY ("sensitivity_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "authz"."permissions"
        ADD CONSTRAINT "fk_permissions_approval_mode_concept_id" FOREIGN KEY ("approval_mode_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "authz"."permissions"
        ADD CONSTRAINT "fk_permissions_purpose_of_use_concept_id" FOREIGN KEY ("purpose_of_use_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "authz"."permissions"
        ADD CONSTRAINT "fk_permissions_legal_basis_concept_id" FOREIGN KEY ("legal_basis_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

DO $$ BEGIN
    ALTER TABLE "delegated_access"."support_scope_grants"
        ADD CONSTRAINT "fk_support_scope_grants_source_role_template_id" FOREIGN KEY ("source_role_template_id")
        REFERENCES "delegated_access"."role_templates" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "delegated_access"."sod_rules"
        ADD CONSTRAINT "fk_sod_rules_base_rule_id" FOREIGN KEY ("base_rule_id")
        REFERENCES "delegated_access"."sod_rules" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "delegated_access"."sod_exceptions"
        ADD CONSTRAINT "fk_sod_exceptions_sod_rule_id" FOREIGN KEY ("sod_rule_id")
        REFERENCES "delegated_access"."sod_rules" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "delegated_access"."sod_exceptions"
        ADD CONSTRAINT "fk_sod_exceptions_organization_user_assignment_id" FOREIGN KEY ("organization_user_assignment_id")
        REFERENCES "delegated_access"."organization_user_assignments" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "delegated_access"."sod_exceptions"
        ADD CONSTRAINT "fk_sod_exceptions_four_eyes_request_id" FOREIGN KEY ("four_eyes_request_id")
        REFERENCES "delegated_access"."four_eyes_requests" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "delegated_access"."four_eyes_requests"
        ADD CONSTRAINT "fk_four_eyes_requests_organization_user_assignment_id" FOREIGN KEY ("organization_user_assignment_id")
        REFERENCES "delegated_access"."organization_user_assignments" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "delegated_access"."access_review_items"
        ADD CONSTRAINT "fk_access_review_items_access_review_campaign_id" FOREIGN KEY ("access_review_campaign_id")
        REFERENCES "delegated_access"."access_review_campaigns" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "delegated_access"."access_review_items"
        ADD CONSTRAINT "fk_access_review_items_organization_user_assignment_id" FOREIGN KEY ("organization_user_assignment_id")
        REFERENCES "delegated_access"."organization_user_assignments" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "delegated_access"."access_review_items"
        ADD CONSTRAINT "fk_access_review_items_support_scope_grant_id" FOREIGN KEY ("support_scope_grant_id")
        REFERENCES "delegated_access"."support_scope_grants" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "delegated_access"."lifecycle_cases"
        ADD CONSTRAINT "fk_lifecycle_cases_organization_user_assignment_id" FOREIGN KEY ("organization_user_assignment_id")
        REFERENCES "delegated_access"."organization_user_assignments" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "delegated_access"."handover_items"
        ADD CONSTRAINT "fk_handover_items_lifecycle_case_id" FOREIGN KEY ("lifecycle_case_id")
        REFERENCES "delegated_access"."lifecycle_cases" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "delegated_access"."access_decision_log"
        ADD CONSTRAINT "fk_access_decision_log_grant_id" FOREIGN KEY ("grant_id")
        REFERENCES "delegated_access"."support_scope_grants" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "delegated_access"."access_decision_log"
        ADD CONSTRAINT "fk_access_decision_log_approval_id" FOREIGN KEY ("approval_id")
        REFERENCES "delegated_access"."four_eyes_requests" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "delegated_access"."grant_usage_stats"
        ADD CONSTRAINT "fk_grant_usage_stats_support_scope_grant_id" FOREIGN KEY ("support_scope_grant_id")
        REFERENCES "delegated_access"."support_scope_grants" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "delegated_access"."access_anomalies"
        ADD CONSTRAINT "fk_access_anomalies_organization_user_assignment_id" FOREIGN KEY ("organization_user_assignment_id")
        REFERENCES "delegated_access"."organization_user_assignments" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "delegated_access"."organization_user_assignments"
        ADD CONSTRAINT "fk_organization_user_assignments_identity_verified_by_user_id" FOREIGN KEY ("identity_verified_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "delegated_access"."organization_user_assignments"
        ADD CONSTRAINT "fk_organization_user_assignments_identity_method_concept_id" FOREIGN KEY ("identity_method_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "delegated_access"."organization_user_assignments"
        ADD CONSTRAINT "fk_organization_user_assignments_suspension_reason_concept_id" FOREIGN KEY ("suspension_reason_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "delegated_access"."support_scope_grants"
        ADD CONSTRAINT "fk_support_scope_grants_effect_concept_id" FOREIGN KEY ("effect_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "delegated_access"."support_grant_actions"
        ADD CONSTRAINT "fk_support_grant_actions_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: directory.tenants (requiere schema directory)
DO $$ BEGIN
    ALTER TABLE "delegated_access"."governance_rules"
        ADD CONSTRAINT "fk_governance_rules_tenant_id" FOREIGN KEY ("tenant_id")
        REFERENCES "directory"."tenants" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "delegated_access"."governance_rules"
        ADD CONSTRAINT "fk_governance_rules_rule_kind_concept_id" FOREIGN KEY ("rule_kind_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "delegated_access"."governance_rules"
        ADD CONSTRAINT "fk_governance_rules_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "delegated_access"."governance_rules"
        ADD CONSTRAINT "fk_governance_rules_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "delegated_access"."governance_rules"
        ADD CONSTRAINT "fk_governance_rules_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: directory.tenants (requiere schema directory)
DO $$ BEGIN
    ALTER TABLE "delegated_access"."sod_rules"
        ADD CONSTRAINT "fk_sod_rules_tenant_id" FOREIGN KEY ("tenant_id")
        REFERENCES "directory"."tenants" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "delegated_access"."sod_rules"
        ADD CONSTRAINT "fk_sod_rules_scope_concept_id" FOREIGN KEY ("scope_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "delegated_access"."sod_rules"
        ADD CONSTRAINT "fk_sod_rules_action_concept_id" FOREIGN KEY ("action_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "delegated_access"."sod_rules"
        ADD CONSTRAINT "fk_sod_rules_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "delegated_access"."sod_rules"
        ADD CONSTRAINT "fk_sod_rules_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "delegated_access"."sod_rules"
        ADD CONSTRAINT "fk_sod_rules_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: directory.tenants (requiere schema directory)
DO $$ BEGIN
    ALTER TABLE "delegated_access"."sod_exceptions"
        ADD CONSTRAINT "fk_sod_exceptions_tenant_id" FOREIGN KEY ("tenant_id")
        REFERENCES "directory"."tenants" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "delegated_access"."sod_exceptions"
        ADD CONSTRAINT "fk_sod_exceptions_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "delegated_access"."sod_exceptions"
        ADD CONSTRAINT "fk_sod_exceptions_revoked_by_user_id" FOREIGN KEY ("revoked_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "delegated_access"."sod_exceptions"
        ADD CONSTRAINT "fk_sod_exceptions_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "delegated_access"."sod_exceptions"
        ADD CONSTRAINT "fk_sod_exceptions_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: directory.tenants (requiere schema directory)
DO $$ BEGIN
    ALTER TABLE "delegated_access"."four_eyes_requests"
        ADD CONSTRAINT "fk_four_eyes_requests_tenant_id" FOREIGN KEY ("tenant_id")
        REFERENCES "directory"."tenants" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "delegated_access"."four_eyes_requests"
        ADD CONSTRAINT "fk_four_eyes_requests_kind_concept_id" FOREIGN KEY ("kind_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "delegated_access"."four_eyes_requests"
        ADD CONSTRAINT "fk_four_eyes_requests_requester_user_id" FOREIGN KEY ("requester_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "delegated_access"."four_eyes_requests"
        ADD CONSTRAINT "fk_four_eyes_requests_subject_user_id" FOREIGN KEY ("subject_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "delegated_access"."four_eyes_requests"
        ADD CONSTRAINT "fk_four_eyes_requests_approver_kind_concept_id" FOREIGN KEY ("approver_kind_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "delegated_access"."four_eyes_requests"
        ADD CONSTRAINT "fk_four_eyes_requests_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "delegated_access"."four_eyes_requests"
        ADD CONSTRAINT "fk_four_eyes_requests_decided_by_user_id" FOREIGN KEY ("decided_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "delegated_access"."four_eyes_requests"
        ADD CONSTRAINT "fk_four_eyes_requests_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "delegated_access"."four_eyes_requests"
        ADD CONSTRAINT "fk_four_eyes_requests_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: directory.tenants (requiere schema directory)
DO $$ BEGIN
    ALTER TABLE "delegated_access"."access_review_campaigns"
        ADD CONSTRAINT "fk_access_review_campaigns_tenant_id" FOREIGN KEY ("tenant_id")
        REFERENCES "directory"."tenants" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "delegated_access"."access_review_campaigns"
        ADD CONSTRAINT "fk_access_review_campaigns_kind_concept_id" FOREIGN KEY ("kind_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "delegated_access"."access_review_campaigns"
        ADD CONSTRAINT "fk_access_review_campaigns_uncertified_action_concept_id" FOREIGN KEY ("uncertified_action_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "delegated_access"."access_review_campaigns"
        ADD CONSTRAINT "fk_access_review_campaigns_owner_user_id" FOREIGN KEY ("owner_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "delegated_access"."access_review_campaigns"
        ADD CONSTRAINT "fk_access_review_campaigns_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "delegated_access"."access_review_campaigns"
        ADD CONSTRAINT "fk_access_review_campaigns_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "delegated_access"."access_review_campaigns"
        ADD CONSTRAINT "fk_access_review_campaigns_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: directory.tenants (requiere schema directory)
DO $$ BEGIN
    ALTER TABLE "delegated_access"."access_review_items"
        ADD CONSTRAINT "fk_access_review_items_tenant_id" FOREIGN KEY ("tenant_id")
        REFERENCES "directory"."tenants" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "delegated_access"."access_review_items"
        ADD CONSTRAINT "fk_access_review_items_reviewer_user_id" FOREIGN KEY ("reviewer_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "delegated_access"."access_review_items"
        ADD CONSTRAINT "fk_access_review_items_reviewer_kind_concept_id" FOREIGN KEY ("reviewer_kind_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "delegated_access"."access_review_items"
        ADD CONSTRAINT "fk_access_review_items_decision_concept_id" FOREIGN KEY ("decision_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "delegated_access"."access_review_items"
        ADD CONSTRAINT "fk_access_review_items_decided_by_user_id" FOREIGN KEY ("decided_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "delegated_access"."access_review_items"
        ADD CONSTRAINT "fk_access_review_items_escalated_to_user_id" FOREIGN KEY ("escalated_to_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "delegated_access"."access_review_items"
        ADD CONSTRAINT "fk_access_review_items_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "delegated_access"."access_review_items"
        ADD CONSTRAINT "fk_access_review_items_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: directory.tenants (requiere schema directory)
DO $$ BEGIN
    ALTER TABLE "delegated_access"."lifecycle_cases"
        ADD CONSTRAINT "fk_lifecycle_cases_tenant_id" FOREIGN KEY ("tenant_id")
        REFERENCES "directory"."tenants" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "delegated_access"."lifecycle_cases"
        ADD CONSTRAINT "fk_lifecycle_cases_subject_user_id" FOREIGN KEY ("subject_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "delegated_access"."lifecycle_cases"
        ADD CONSTRAINT "fk_lifecycle_cases_kind_concept_id" FOREIGN KEY ("kind_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "delegated_access"."lifecycle_cases"
        ADD CONSTRAINT "fk_lifecycle_cases_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "delegated_access"."lifecycle_cases"
        ADD CONSTRAINT "fk_lifecycle_cases_opened_by_user_id" FOREIGN KEY ("opened_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "delegated_access"."lifecycle_cases"
        ADD CONSTRAINT "fk_lifecycle_cases_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "delegated_access"."lifecycle_cases"
        ADD CONSTRAINT "fk_lifecycle_cases_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: directory.tenants (requiere schema directory)
DO $$ BEGIN
    ALTER TABLE "delegated_access"."handover_items"
        ADD CONSTRAINT "fk_handover_items_tenant_id" FOREIGN KEY ("tenant_id")
        REFERENCES "directory"."tenants" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "delegated_access"."handover_items"
        ADD CONSTRAINT "fk_handover_items_item_kind_concept_id" FOREIGN KEY ("item_kind_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "delegated_access"."handover_items"
        ADD CONSTRAINT "fk_handover_items_from_user_id" FOREIGN KEY ("from_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "delegated_access"."handover_items"
        ADD CONSTRAINT "fk_handover_items_to_user_id" FOREIGN KEY ("to_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "delegated_access"."handover_items"
        ADD CONSTRAINT "fk_handover_items_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "delegated_access"."handover_items"
        ADD CONSTRAINT "fk_handover_items_reassigned_by_user_id" FOREIGN KEY ("reassigned_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "delegated_access"."handover_items"
        ADD CONSTRAINT "fk_handover_items_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "delegated_access"."handover_items"
        ADD CONSTRAINT "fk_handover_items_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: directory.tenants (requiere schema directory)
DO $$ BEGIN
    ALTER TABLE "delegated_access"."patient_restriction_flags"
        ADD CONSTRAINT "fk_patient_restriction_flags_tenant_id" FOREIGN KEY ("tenant_id")
        REFERENCES "directory"."tenants" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: profiles.patient_profiles (requiere schema profiles)
DO $$ BEGIN
    ALTER TABLE "delegated_access"."patient_restriction_flags"
        ADD CONSTRAINT "fk_patient_restriction_flags_patient_profile_id" FOREIGN KEY ("patient_profile_id")
        REFERENCES "profiles"."patient_profiles" ("profile_id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "delegated_access"."patient_restriction_flags"
        ADD CONSTRAINT "fk_patient_restriction_flags_flag_concept_id" FOREIGN KEY ("flag_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "delegated_access"."patient_restriction_flags"
        ADD CONSTRAINT "fk_patient_restriction_flags_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "delegated_access"."patient_restriction_flags"
        ADD CONSTRAINT "fk_patient_restriction_flags_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "delegated_access"."patient_restriction_flags"
        ADD CONSTRAINT "fk_patient_restriction_flags_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: directory.tenants (requiere schema directory)
DO $$ BEGIN
    ALTER TABLE "delegated_access"."access_decision_log"
        ADD CONSTRAINT "fk_access_decision_log_tenant_id" FOREIGN KEY ("tenant_id")
        REFERENCES "directory"."tenants" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "delegated_access"."access_decision_log"
        ADD CONSTRAINT "fk_access_decision_log_user_id" FOREIGN KEY ("user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "delegated_access"."access_decision_log"
        ADD CONSTRAINT "fk_access_decision_log_effect_concept_id" FOREIGN KEY ("effect_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "delegated_access"."access_decision_log"
        ADD CONSTRAINT "fk_access_decision_log_recorded_by_user_id" FOREIGN KEY ("recorded_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: directory.tenants (requiere schema directory)
DO $$ BEGIN
    ALTER TABLE "delegated_access"."grant_usage_stats"
        ADD CONSTRAINT "fk_grant_usage_stats_tenant_id" FOREIGN KEY ("tenant_id")
        REFERENCES "directory"."tenants" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "delegated_access"."grant_usage_stats"
        ADD CONSTRAINT "fk_grant_usage_stats_user_id" FOREIGN KEY ("user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: directory.tenants (requiere schema directory)
DO $$ BEGIN
    ALTER TABLE "delegated_access"."access_anomalies"
        ADD CONSTRAINT "fk_access_anomalies_tenant_id" FOREIGN KEY ("tenant_id")
        REFERENCES "directory"."tenants" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "delegated_access"."access_anomalies"
        ADD CONSTRAINT "fk_access_anomalies_user_id" FOREIGN KEY ("user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "delegated_access"."access_anomalies"
        ADD CONSTRAINT "fk_access_anomalies_kind_concept_id" FOREIGN KEY ("kind_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "delegated_access"."access_anomalies"
        ADD CONSTRAINT "fk_access_anomalies_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "delegated_access"."access_anomalies"
        ADD CONSTRAINT "fk_access_anomalies_acknowledged_by_user_id" FOREIGN KEY ("acknowledged_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "delegated_access"."access_anomalies"
        ADD CONSTRAINT "fk_access_anomalies_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "delegated_access"."access_anomalies"
        ADD CONSTRAINT "fk_access_anomalies_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- ---- 5. indices (111) ----

CREATE INDEX IF NOT EXISTS "ix_permissions_sensitivity_concept_id" ON "authz"."permissions" ("sensitivity_concept_id");

CREATE INDEX IF NOT EXISTS "ix_permissions_approval_mode_concept_id" ON "authz"."permissions" ("approval_mode_concept_id");

CREATE INDEX IF NOT EXISTS "ix_permissions_purpose_of_use_concept_id" ON "authz"."permissions" ("purpose_of_use_concept_id");

CREATE INDEX IF NOT EXISTS "ix_permissions_legal_basis_concept_id" ON "authz"."permissions" ("legal_basis_concept_id");

CREATE INDEX IF NOT EXISTS "ix_permissions_support_assignable" ON "authz"."permissions" ("support_assignable") WHERE support_assignable;

CREATE INDEX IF NOT EXISTS "ix_organization_user_assignments_identity_verified_by_user_id" ON "delegated_access"."organization_user_assignments" ("identity_verified_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_organization_user_assignments_identity_method_concept_id" ON "delegated_access"."organization_user_assignments" ("identity_method_concept_id");

CREATE INDEX IF NOT EXISTS "ix_organization_user_assignments_suspension_reason_concept_id" ON "delegated_access"."organization_user_assignments" ("suspension_reason_concept_id");

CREATE INDEX IF NOT EXISTS "ix_organization_user_assignments_supervisor" ON "delegated_access"."organization_user_assignments" ("supervisor_user_id") WHERE supervisor_user_id IS NOT NULL;

CREATE INDEX IF NOT EXISTS "ix_support_scope_grants_effect" ON "delegated_access"."support_scope_grants" ("tenant_id", "effect_concept_id", "status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_support_scope_grants_source_role_template_id" ON "delegated_access"."support_scope_grants" ("source_role_template_id");

CREATE INDEX IF NOT EXISTS "ix_support_grant_actions_updated_by_user_id" ON "delegated_access"."support_grant_actions" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_support_grant_actions_active" ON "delegated_access"."support_grant_actions" ("support_scope_grant_id") WHERE superseded_at IS NULL;

CREATE INDEX IF NOT EXISTS "ix_governance_rules_tenant_id" ON "delegated_access"."governance_rules" ("tenant_id", "status_concept_id");

CREATE UNIQUE INDEX IF NOT EXISTS "uq_governance_rules_active" ON "delegated_access"."governance_rules" ("tenant_id", "rule_kind_concept_id", COALESCE(role_template_code, ''), "permission_pattern") WHERE status_concept_id = '38a1d301-f40d-5b17-a695-5e6d605f8b19';

CREATE INDEX IF NOT EXISTS "ix_governance_rules_rule_kind_concept_id" ON "delegated_access"."governance_rules" ("rule_kind_concept_id");

CREATE INDEX IF NOT EXISTS "ix_governance_rules_status_concept_id" ON "delegated_access"."governance_rules" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_governance_rules_created_by_user_id" ON "delegated_access"."governance_rules" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_governance_rules_updated_by_user_id" ON "delegated_access"."governance_rules" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_sod_rules_tenant_id" ON "delegated_access"."sod_rules" ("tenant_id");

CREATE UNIQUE INDEX IF NOT EXISTS "uq_sod_rules_platform_code_version" ON "delegated_access"."sod_rules" ("code", "version_number") WHERE tenant_id IS NULL;

CREATE UNIQUE INDEX IF NOT EXISTS "uq_sod_rules_tenant_code_version" ON "delegated_access"."sod_rules" ("tenant_id", "code", "version_number") WHERE tenant_id IS NOT NULL;

CREATE INDEX IF NOT EXISTS "ix_sod_rules_base_rule_id" ON "delegated_access"."sod_rules" ("base_rule_id");

CREATE INDEX IF NOT EXISTS "ix_sod_rules_scope_concept_id" ON "delegated_access"."sod_rules" ("scope_concept_id");

CREATE INDEX IF NOT EXISTS "ix_sod_rules_action_concept_id" ON "delegated_access"."sod_rules" ("action_concept_id");

CREATE INDEX IF NOT EXISTS "ix_sod_rules_status_concept_id" ON "delegated_access"."sod_rules" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_sod_rules_created_by_user_id" ON "delegated_access"."sod_rules" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_sod_rules_updated_by_user_id" ON "delegated_access"."sod_rules" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_sod_exceptions_tenant_id" ON "delegated_access"."sod_exceptions" ("tenant_id", "status_concept_id");

CREATE UNIQUE INDEX IF NOT EXISTS "uq_sod_exceptions_active" ON "delegated_access"."sod_exceptions" ("sod_rule_id", "organization_user_assignment_id") WHERE status_concept_id = '38a1d301-f40d-5b17-a695-5e6d605f8b19';

CREATE INDEX IF NOT EXISTS "ix_sod_exceptions_valid_to" ON "delegated_access"."sod_exceptions" ("valid_to") WHERE status_concept_id = '38a1d301-f40d-5b17-a695-5e6d605f8b19';

CREATE INDEX IF NOT EXISTS "ix_sod_exceptions_organization_user_assignment_id" ON "delegated_access"."sod_exceptions" ("organization_user_assignment_id");

CREATE INDEX IF NOT EXISTS "ix_sod_exceptions_four_eyes_request_id" ON "delegated_access"."sod_exceptions" ("four_eyes_request_id");

CREATE INDEX IF NOT EXISTS "ix_sod_exceptions_status_concept_id" ON "delegated_access"."sod_exceptions" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_sod_exceptions_revoked_by_user_id" ON "delegated_access"."sod_exceptions" ("revoked_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_sod_exceptions_created_by_user_id" ON "delegated_access"."sod_exceptions" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_sod_exceptions_updated_by_user_id" ON "delegated_access"."sod_exceptions" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_four_eyes_requests_tenant_id" ON "delegated_access"."four_eyes_requests" ("tenant_id", "status_concept_id", "expires_at");

CREATE INDEX IF NOT EXISTS "ix_four_eyes_requests_requester" ON "delegated_access"."four_eyes_requests" ("requester_user_id", "status_concept_id");

CREATE UNIQUE INDEX IF NOT EXISTS "uq_four_eyes_requests_pending_payload" ON "delegated_access"."four_eyes_requests" ("tenant_id", "kind_concept_id", "requester_user_id", COALESCE(permission_code, ''), "payload_hash") WHERE status_concept_id = 'a977935a-9073-5113-9644-7df96732e776';

CREATE INDEX IF NOT EXISTS "ix_four_eyes_requests_kind_concept_id" ON "delegated_access"."four_eyes_requests" ("kind_concept_id");

CREATE INDEX IF NOT EXISTS "ix_four_eyes_requests_subject_user_id" ON "delegated_access"."four_eyes_requests" ("subject_user_id");

CREATE INDEX IF NOT EXISTS "ix_four_eyes_requests_organization_user_assignment_id" ON "delegated_access"."four_eyes_requests" ("organization_user_assignment_id");

CREATE INDEX IF NOT EXISTS "ix_four_eyes_requests_approver_kind_concept_id" ON "delegated_access"."four_eyes_requests" ("approver_kind_concept_id");

CREATE INDEX IF NOT EXISTS "ix_four_eyes_requests_status_concept_id" ON "delegated_access"."four_eyes_requests" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_four_eyes_requests_decided_by_user_id" ON "delegated_access"."four_eyes_requests" ("decided_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_four_eyes_requests_created_by_user_id" ON "delegated_access"."four_eyes_requests" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_four_eyes_requests_updated_by_user_id" ON "delegated_access"."four_eyes_requests" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_access_review_campaigns_tenant_id" ON "delegated_access"."access_review_campaigns" ("tenant_id", "status_concept_id", "due_at");

CREATE UNIQUE INDEX IF NOT EXISTS "uq_access_review_campaigns_recert_month" ON "delegated_access"."access_review_campaigns" ("tenant_id", "name") WHERE kind_concept_id = '9f831109-61d2-54d4-8e67-7ad04ac9a315' AND status_concept_id IN ('743d9f11-b186-5547-ae3d-cc44d94724bd', 'faa5c9bf-5300-5e43-8829-19a9f0e94fef');

CREATE INDEX IF NOT EXISTS "ix_access_review_campaigns_kind_concept_id" ON "delegated_access"."access_review_campaigns" ("kind_concept_id");

CREATE INDEX IF NOT EXISTS "ix_access_review_campaigns_uncertified_action_concept_id" ON "delegated_access"."access_review_campaigns" ("uncertified_action_concept_id");

CREATE INDEX IF NOT EXISTS "ix_access_review_campaigns_owner_user_id" ON "delegated_access"."access_review_campaigns" ("owner_user_id");

CREATE INDEX IF NOT EXISTS "ix_access_review_campaigns_status_concept_id" ON "delegated_access"."access_review_campaigns" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_access_review_campaigns_created_by_user_id" ON "delegated_access"."access_review_campaigns" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_access_review_campaigns_updated_by_user_id" ON "delegated_access"."access_review_campaigns" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_access_review_items_tenant_id" ON "delegated_access"."access_review_items" ("tenant_id", "decision_concept_id");

CREATE UNIQUE INDEX IF NOT EXISTS "uq_access_review_items_campaign_grant" ON "delegated_access"."access_review_items" ("access_review_campaign_id", "organization_user_assignment_id", COALESCE(support_scope_grant_id, '00000000-0000-0000-0000-000000000000'::uuid));

CREATE INDEX IF NOT EXISTS "ix_access_review_items_reviewer_pending" ON "delegated_access"."access_review_items" ("reviewer_user_id", "due_at") WHERE decision_concept_id = '55a6db07-19e7-5bb4-978a-3d246492f49d';

CREATE INDEX IF NOT EXISTS "ix_access_review_items_organization_user_assignment_id" ON "delegated_access"."access_review_items" ("organization_user_assignment_id");

CREATE INDEX IF NOT EXISTS "ix_access_review_items_reviewer_kind_concept_id" ON "delegated_access"."access_review_items" ("reviewer_kind_concept_id");

CREATE INDEX IF NOT EXISTS "ix_access_review_items_decision_concept_id" ON "delegated_access"."access_review_items" ("decision_concept_id");

CREATE INDEX IF NOT EXISTS "ix_access_review_items_decided_by_user_id" ON "delegated_access"."access_review_items" ("decided_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_access_review_items_escalated_to_user_id" ON "delegated_access"."access_review_items" ("escalated_to_user_id");

CREATE INDEX IF NOT EXISTS "ix_access_review_items_created_by_user_id" ON "delegated_access"."access_review_items" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_access_review_items_updated_by_user_id" ON "delegated_access"."access_review_items" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_lifecycle_cases_tenant_id" ON "delegated_access"."lifecycle_cases" ("tenant_id", "kind_concept_id", "status_concept_id");

CREATE UNIQUE INDEX IF NOT EXISTS "uq_lifecycle_cases_open_joiner" ON "delegated_access"."lifecycle_cases" ("organization_user_assignment_id") WHERE kind_concept_id = 'c2a9a59d-c88c-5e87-9065-1e0e068c479d' AND status_concept_id = '4f73e30c-25ba-52ff-969e-862e588cce13';

CREATE UNIQUE INDEX IF NOT EXISTS "uq_lifecycle_cases_open_suspension" ON "delegated_access"."lifecycle_cases" ("organization_user_assignment_id") WHERE kind_concept_id = '767afaf6-3161-56ee-8c96-5e9386804fc0' AND status_concept_id = '4f73e30c-25ba-52ff-969e-862e588cce13';

CREATE INDEX IF NOT EXISTS "ix_lifecycle_cases_subject_user_id" ON "delegated_access"."lifecycle_cases" ("subject_user_id");

CREATE INDEX IF NOT EXISTS "ix_lifecycle_cases_kind_concept_id" ON "delegated_access"."lifecycle_cases" ("kind_concept_id");

CREATE INDEX IF NOT EXISTS "ix_lifecycle_cases_status_concept_id" ON "delegated_access"."lifecycle_cases" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_lifecycle_cases_opened_by_user_id" ON "delegated_access"."lifecycle_cases" ("opened_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_lifecycle_cases_created_by_user_id" ON "delegated_access"."lifecycle_cases" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_lifecycle_cases_updated_by_user_id" ON "delegated_access"."lifecycle_cases" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_handover_items_tenant_id" ON "delegated_access"."handover_items" ("tenant_id", "status_concept_id");

CREATE UNIQUE INDEX IF NOT EXISTS "uq_handover_items_case_source" ON "delegated_access"."handover_items" ("lifecycle_case_id", "item_kind_concept_id", "source_id");

CREATE INDEX IF NOT EXISTS "ix_handover_items_item_kind_concept_id" ON "delegated_access"."handover_items" ("item_kind_concept_id");

CREATE INDEX IF NOT EXISTS "ix_handover_items_from_user_id" ON "delegated_access"."handover_items" ("from_user_id");

CREATE INDEX IF NOT EXISTS "ix_handover_items_to_user_id" ON "delegated_access"."handover_items" ("to_user_id");

CREATE INDEX IF NOT EXISTS "ix_handover_items_status_concept_id" ON "delegated_access"."handover_items" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_handover_items_reassigned_by_user_id" ON "delegated_access"."handover_items" ("reassigned_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_handover_items_created_by_user_id" ON "delegated_access"."handover_items" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_handover_items_updated_by_user_id" ON "delegated_access"."handover_items" ("updated_by_user_id");

CREATE UNIQUE INDEX IF NOT EXISTS "uq_patient_restriction_flags_active" ON "delegated_access"."patient_restriction_flags" ("tenant_id", "patient_profile_id", "flag_concept_id") WHERE status_concept_id = '38a1d301-f40d-5b17-a695-5e6d605f8b19';

CREATE INDEX IF NOT EXISTS "ix_patient_restriction_flags_lookup" ON "delegated_access"."patient_restriction_flags" ("tenant_id", "patient_profile_id") WHERE status_concept_id = '38a1d301-f40d-5b17-a695-5e6d605f8b19';

CREATE INDEX IF NOT EXISTS "ix_patient_restriction_flags_patient_profile_id" ON "delegated_access"."patient_restriction_flags" ("patient_profile_id");

CREATE INDEX IF NOT EXISTS "ix_patient_restriction_flags_flag_concept_id" ON "delegated_access"."patient_restriction_flags" ("flag_concept_id");

CREATE INDEX IF NOT EXISTS "ix_patient_restriction_flags_status_concept_id" ON "delegated_access"."patient_restriction_flags" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_patient_restriction_flags_created_by_user_id" ON "delegated_access"."patient_restriction_flags" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_patient_restriction_flags_updated_by_user_id" ON "delegated_access"."patient_restriction_flags" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_access_decision_log_tenant_time" ON "delegated_access"."access_decision_log" ("tenant_id", "recorded_at" DESC);

CREATE INDEX IF NOT EXISTS "ix_access_decision_log_user_time" ON "delegated_access"."access_decision_log" ("user_id", "recorded_at" DESC);

CREATE INDEX IF NOT EXISTS "ix_access_decision_log_grant" ON "delegated_access"."access_decision_log" ("grant_id") WHERE grant_id IS NOT NULL;

CREATE INDEX IF NOT EXISTS "ix_access_decision_log_effect" ON "delegated_access"."access_decision_log" ("tenant_id", "effect_concept_id", "recorded_at" DESC);

CREATE INDEX IF NOT EXISTS "ix_access_decision_log_effect_concept_id" ON "delegated_access"."access_decision_log" ("effect_concept_id");

CREATE INDEX IF NOT EXISTS "ix_access_decision_log_approval_id" ON "delegated_access"."access_decision_log" ("approval_id");

CREATE INDEX IF NOT EXISTS "ix_access_decision_log_recorded_by_user_id" ON "delegated_access"."access_decision_log" ("recorded_by_user_id");

CREATE UNIQUE INDEX IF NOT EXISTS "uq_grant_usage_stats_bucket" ON "delegated_access"."grant_usage_stats" ("tenant_id", "support_scope_grant_id", "permission_code", "bucket_start");

CREATE INDEX IF NOT EXISTS "ix_grant_usage_stats_user" ON "delegated_access"."grant_usage_stats" ("tenant_id", "user_id", "bucket_start");

CREATE INDEX IF NOT EXISTS "ix_grant_usage_stats_grant" ON "delegated_access"."grant_usage_stats" ("support_scope_grant_id", "last_used_at");

CREATE INDEX IF NOT EXISTS "ix_grant_usage_stats_user_id" ON "delegated_access"."grant_usage_stats" ("user_id");

CREATE INDEX IF NOT EXISTS "ix_access_anomalies_tenant_id" ON "delegated_access"."access_anomalies" ("tenant_id", "status_concept_id", "created_at" DESC);

CREATE UNIQUE INDEX IF NOT EXISTS "uq_access_anomalies_window" ON "delegated_access"."access_anomalies" ("tenant_id", "user_id", "kind_concept_id", "window_start");

CREATE INDEX IF NOT EXISTS "ix_access_anomalies_user_id" ON "delegated_access"."access_anomalies" ("user_id");

CREATE INDEX IF NOT EXISTS "ix_access_anomalies_organization_user_assignment_id" ON "delegated_access"."access_anomalies" ("organization_user_assignment_id");

CREATE INDEX IF NOT EXISTS "ix_access_anomalies_kind_concept_id" ON "delegated_access"."access_anomalies" ("kind_concept_id");

CREATE INDEX IF NOT EXISTS "ix_access_anomalies_status_concept_id" ON "delegated_access"."access_anomalies" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_access_anomalies_acknowledged_by_user_id" ON "delegated_access"."access_anomalies" ("acknowledged_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_access_anomalies_created_by_user_id" ON "delegated_access"."access_anomalies" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_access_anomalies_updated_by_user_id" ON "delegated_access"."access_anomalies" ("updated_by_user_id");

-- ---- 6. constraints (CHECK y barrera WORM) (35 CHECK + 1 barrera) ----

-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "authz"."permissions" DROP CONSTRAINT IF EXISTS "ck_permissions_approval_needs_sensitivity";
ALTER TABLE "authz"."permissions" ADD CONSTRAINT "ck_permissions_approval_needs_sensitivity" CHECK (("approval_mode_concept_id" IS NULL OR "sensitivity_concept_id" IS NOT NULL));

-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "delegated_access"."support_scope_grants" DROP CONSTRAINT IF EXISTS "ck_support_scope_grants_effect_valid";
ALTER TABLE "delegated_access"."support_scope_grants" ADD CONSTRAINT "ck_support_scope_grants_effect_valid" CHECK (("effect_concept_id" IN ('6905e0db-1650-5d49-adca-8b2688ac049c', 'b038e546-a6ba-5848-9cd2-04b02ccb22b0')));

-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "delegated_access"."support_scope_grants" DROP CONSTRAINT IF EXISTS "ck_support_scope_grants_condition";
ALTER TABLE "delegated_access"."support_scope_grants" ADD CONSTRAINT "ck_support_scope_grants_condition" CHECK ((("condition_json" IS NULL AND "condition_schema_version" IS NULL) OR (jsonb_typeof("condition_json") = 'object' AND "condition_schema_version" IS NOT NULL AND ("condition_json" ->> 'schemaVersion') = ("condition_schema_version")::text AND octet_length("condition_json"::text) <= 8192)));

-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "delegated_access"."support_grant_actions" DROP CONSTRAINT IF EXISTS "ck_support_grant_actions_condition";
ALTER TABLE "delegated_access"."support_grant_actions" ADD CONSTRAINT "ck_support_grant_actions_condition" CHECK ((("condition_json" IS NULL AND "condition_schema_version" IS NULL) OR (jsonb_typeof("condition_json") = 'object' AND "condition_schema_version" IS NOT NULL AND ("condition_json" ->> 'schemaVersion') = ("condition_schema_version")::text AND octet_length("condition_json"::text) <= 8192)));

-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "delegated_access"."role_templates" DROP CONSTRAINT IF EXISTS "ck_role_templates_ceiling_array";
ALTER TABLE "delegated_access"."role_templates" ADD CONSTRAINT "ck_role_templates_ceiling_array" CHECK (("ceiling_actions_json" IS NULL OR jsonb_typeof("ceiling_actions_json") = 'array'));

-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "delegated_access"."role_templates" DROP CONSTRAINT IF EXISTS "ck_role_templates_default_conditions_object";
ALTER TABLE "delegated_access"."role_templates" ADD CONSTRAINT "ck_role_templates_default_conditions_object" CHECK (("default_conditions_json" IS NULL OR jsonb_typeof("default_conditions_json") = 'object'));

-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "delegated_access"."governance_rules" DROP CONSTRAINT IF EXISTS "ck_governance_rules_pattern";
ALTER TABLE "delegated_access"."governance_rules" ADD CONSTRAINT "ck_governance_rules_pattern" CHECK (("permission_pattern" ~ '^([a-z_]+(\.[a-z_]+){2,3}|[a-z_]+(\.[a-z_]+){0,2}\.\*)$'));

-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "delegated_access"."governance_rules" DROP CONSTRAINT IF EXISTS "ck_governance_rules_kind_shape";
ALTER TABLE "delegated_access"."governance_rules" ADD CONSTRAINT "ck_governance_rules_kind_shape" CHECK ((("rule_kind_concept_id" <> 'ce906685-7a58-54e7-b4d2-458062c0c303' OR "role_template_code" IS NOT NULL) AND ("rule_kind_concept_id" <> '1b6db045-2cc5-5985-9c89-18b8ac0969be' OR COALESCE("rule_json" ? 'condition', false)) AND ("rule_kind_concept_id" <> 'f2534b4a-a8cc-5fb1-a431-30e1a750274b' OR COALESCE("rule_json" ->> 'maxVisibility' IN ('PARTIAL', 'REDACT', 'NULLIFY'), false))));

-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "delegated_access"."governance_rules" DROP CONSTRAINT IF EXISTS "ck_governance_rules_valid_period";
ALTER TABLE "delegated_access"."governance_rules" ADD CONSTRAINT "ck_governance_rules_valid_period" CHECK (("valid_from" IS NULL OR "valid_to" IS NULL OR "valid_from" <= "valid_to"));

-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "delegated_access"."sod_rules" DROP CONSTRAINT IF EXISTS "ck_sod_rules_sets";
ALTER TABLE "delegated_access"."sod_rules" ADD CONSTRAINT "ck_sod_rules_sets" CHECK ((jsonb_typeof("atoms_a_json") = 'array' AND jsonb_typeof("atoms_b_json") = 'array'));

-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "delegated_access"."sod_rules" DROP CONSTRAINT IF EXISTS "ck_sod_rules_exception_days";
ALTER TABLE "delegated_access"."sod_rules" ADD CONSTRAINT "ck_sod_rules_exception_days" CHECK (("max_exception_days" IS NULL OR "max_exception_days" BETWEEN 1 AND 180));

-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "delegated_access"."sod_rules" DROP CONSTRAINT IF EXISTS "ck_sod_rules_hard_no_exception";
ALTER TABLE "delegated_access"."sod_rules" ADD CONSTRAINT "ck_sod_rules_hard_no_exception" CHECK ((NOT ("is_hard" AND "max_exception_days" IS NOT NULL)));

-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "delegated_access"."sod_rules" DROP CONSTRAINT IF EXISTS "ck_sod_rules_version_number";
ALTER TABLE "delegated_access"."sod_rules" ADD CONSTRAINT "ck_sod_rules_version_number" CHECK (("version_number" >= 1));

-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "delegated_access"."sod_exceptions" DROP CONSTRAINT IF EXISTS "ck_sod_exceptions_period";
ALTER TABLE "delegated_access"."sod_exceptions" ADD CONSTRAINT "ck_sod_exceptions_period" CHECK (("valid_to" > "valid_from" AND "valid_to" <= "valid_from" + interval '180 days'));

-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "delegated_access"."sod_exceptions" DROP CONSTRAINT IF EXISTS "ck_sod_exceptions_justification";
ALTER TABLE "delegated_access"."sod_exceptions" ADD CONSTRAINT "ck_sod_exceptions_justification" CHECK ((char_length("justification_text") >= 30));

-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "delegated_access"."four_eyes_requests" DROP CONSTRAINT IF EXISTS "ck_four_eyes_requests_not_self";
ALTER TABLE "delegated_access"."four_eyes_requests" ADD CONSTRAINT "ck_four_eyes_requests_not_self" CHECK (("decided_by_user_id" IS NULL OR ("decided_by_user_id" <> "requester_user_id" AND ("subject_user_id" IS NULL OR "decided_by_user_id" <> "subject_user_id"))));

-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "delegated_access"."four_eyes_requests" DROP CONSTRAINT IF EXISTS "ck_four_eyes_requests_hash";
ALTER TABLE "delegated_access"."four_eyes_requests" ADD CONSTRAINT "ck_four_eyes_requests_hash" CHECK (("payload_hash" ~ '^[0-9a-f]{64}$'));

-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "delegated_access"."four_eyes_requests" DROP CONSTRAINT IF EXISTS "ck_four_eyes_requests_expiry";
ALTER TABLE "delegated_access"."four_eyes_requests" ADD CONSTRAINT "ck_four_eyes_requests_expiry" CHECK (("expires_at" > "created_at"));

-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "delegated_access"."four_eyes_requests" DROP CONSTRAINT IF EXISTS "ck_four_eyes_requests_decision";
ALTER TABLE "delegated_access"."four_eyes_requests" ADD CONSTRAINT "ck_four_eyes_requests_decision" CHECK ((("status_concept_id" <> 'a977935a-9073-5113-9644-7df96732e776' OR ("decided_at" IS NULL AND "decided_by_user_id" IS NULL)) AND ("status_concept_id" NOT IN ('1627143e-d273-5fcb-b289-9e59b8b096f2', 'de15c53d-1aa0-5709-8ebd-69e9fd323e31', '013d578f-38af-564c-aff1-e36d1fdec6dd') OR ("decided_at" IS NOT NULL AND "decided_by_user_id" IS NOT NULL))));

-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "delegated_access"."four_eyes_requests" DROP CONSTRAINT IF EXISTS "ck_four_eyes_requests_reject_comment";
ALTER TABLE "delegated_access"."four_eyes_requests" ADD CONSTRAINT "ck_four_eyes_requests_reject_comment" CHECK (("status_concept_id" <> 'de15c53d-1aa0-5709-8ebd-69e9fd323e31' OR COALESCE(char_length("decision_comment_text"), 0) >= 5));

-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "delegated_access"."access_review_campaigns" DROP CONSTRAINT IF EXISTS "ck_access_review_campaigns_grace";
ALTER TABLE "delegated_access"."access_review_campaigns" ADD CONSTRAINT "ck_access_review_campaigns_grace" CHECK (("grace_days" BETWEEN 0 AND 30));

-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "delegated_access"."access_review_campaigns" DROP CONSTRAINT IF EXISTS "ck_access_review_campaigns_escalate";
ALTER TABLE "delegated_access"."access_review_campaigns" ADD CONSTRAINT "ck_access_review_campaigns_escalate" CHECK (("escalate_after_days" BETWEEN 1 AND 30));

-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "delegated_access"."access_review_campaigns" DROP CONSTRAINT IF EXISTS "ck_access_review_campaigns_reminders";
ALTER TABLE "delegated_access"."access_review_campaigns" ADD CONSTRAINT "ck_access_review_campaigns_reminders" CHECK ((jsonb_typeof("reminder_days_before_json") = 'array'));

-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "delegated_access"."access_review_campaigns" DROP CONSTRAINT IF EXISTS "ck_access_review_campaigns_due";
ALTER TABLE "delegated_access"."access_review_campaigns" ADD CONSTRAINT "ck_access_review_campaigns_due" CHECK (("launched_at" IS NULL OR "due_at" > "launched_at"));

-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "delegated_access"."access_review_items" DROP CONSTRAINT IF EXISTS "ck_access_review_items_decided";
ALTER TABLE "delegated_access"."access_review_items" ADD CONSTRAINT "ck_access_review_items_decided" CHECK ((("decision_concept_id" = '55a6db07-19e7-5bb4-978a-3d246492f49d' AND "decided_at" IS NULL) OR ("decision_concept_id" <> '55a6db07-19e7-5bb4-978a-3d246492f49d' AND "decided_at" IS NOT NULL)));

-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "delegated_access"."access_review_items" DROP CONSTRAINT IF EXISTS "ck_access_review_items_comment";
ALTER TABLE "delegated_access"."access_review_items" ADD CONSTRAINT "ck_access_review_items_comment" CHECK (("decision_concept_id" NOT IN ('bce72e9a-b3bb-5fab-8e79-85d411ba692c', '26f790b1-6d77-5286-89d5-0e82a4dcfb81') OR COALESCE(char_length("decision_comment_text"), 0) >= 10));

-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "delegated_access"."access_review_items" DROP CONSTRAINT IF EXISTS "ck_access_review_items_hash";
ALTER TABLE "delegated_access"."access_review_items" ADD CONSTRAINT "ck_access_review_items_hash" CHECK (("evidence_hash" ~ '^[0-9a-f]{64}$'));

-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "delegated_access"."lifecycle_cases" DROP CONSTRAINT IF EXISTS "ck_lifecycle_cases_checklist";
ALTER TABLE "delegated_access"."lifecycle_cases" ADD CONSTRAINT "ck_lifecycle_cases_checklist" CHECK ((jsonb_typeof("checklist_json") = 'array'));

-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "delegated_access"."lifecycle_cases" DROP CONSTRAINT IF EXISTS "ck_lifecycle_cases_completed";
ALTER TABLE "delegated_access"."lifecycle_cases" ADD CONSTRAINT "ck_lifecycle_cases_completed" CHECK (("status_concept_id" <> '4734035e-72cf-519f-8e27-e6cf25ba557f' OR "completed_at" IS NOT NULL));

-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "delegated_access"."handover_items" DROP CONSTRAINT IF EXISTS "ck_handover_items_reassigned";
ALTER TABLE "delegated_access"."handover_items" ADD CONSTRAINT "ck_handover_items_reassigned" CHECK (("status_concept_id" <> '57d9c373-5a94-5fd6-bf9c-bd6a95cb2a91' OR ("to_user_id" IS NOT NULL AND "reassigned_at" IS NOT NULL)));

-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "delegated_access"."handover_items" DROP CONSTRAINT IF EXISTS "ck_handover_items_not_self";
ALTER TABLE "delegated_access"."handover_items" ADD CONSTRAINT "ck_handover_items_not_self" CHECK (("to_user_id" IS NULL OR "to_user_id" <> "from_user_id"));

-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "delegated_access"."patient_restriction_flags" DROP CONSTRAINT IF EXISTS "ck_patient_restriction_flags_reason";
ALTER TABLE "delegated_access"."patient_restriction_flags" ADD CONSTRAINT "ck_patient_restriction_flags_reason" CHECK ((char_length("reason_text") >= 10));

-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "delegated_access"."grant_usage_stats" DROP CONSTRAINT IF EXISTS "ck_grant_usage_stats_counts";
ALTER TABLE "delegated_access"."grant_usage_stats" ADD CONSTRAINT "ck_grant_usage_stats_counts" CHECK (("permit_count" >= 0 AND "deny_count" >= 0 AND "challenge_count" >= 0 AND "off_hours_count" >= 0 AND "distinct_patients_in_bucket" >= 0));

-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "delegated_access"."access_anomalies" DROP CONSTRAINT IF EXISTS "ck_access_anomalies_window";
ALTER TABLE "delegated_access"."access_anomalies" ADD CONSTRAINT "ck_access_anomalies_window" CHECK (("window_end" > "window_start"));

-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "delegated_access"."access_anomalies" DROP CONSTRAINT IF EXISTS "ck_access_anomalies_dismiss_comment";
ALTER TABLE "delegated_access"."access_anomalies" ADD CONSTRAINT "ck_access_anomalies_dismiss_comment" CHECK (("status_concept_id" <> '1c8f5b91-371b-5967-b8fd-98d08f80ac9c' OR COALESCE(char_length("resolution_comment_text"), 0) >= 10));

-- UPDATE_DELETE: forbidden → barrera física (append-only)
REVOKE UPDATE, DELETE ON "delegated_access"."access_decision_log" FROM PUBLIC;
DROP TRIGGER IF EXISTS trg_forbid_mutation ON "delegated_access"."access_decision_log";
CREATE TRIGGER trg_forbid_mutation BEFORE UPDATE OR DELETE ON "delegated_access"."access_decision_log"
    FOR EACH ROW EXECUTE FUNCTION "integrity"."forbid_mutation"();

-- ---- 7. semillas de arranque (mismos ids que gen_seeds.py y que la API) ----
-- (a) categorias de permisos (7)
INSERT INTO authz.permission_categories (id, code, name, ordinal, created_at, updated_at, row_version) VALUES
  ('74102927-61f0-5416-adc3-6ca263a345f8', 'SUPPORT_AGENDA', 'Agenda', 1, now(), now(), 1),
  ('ba719bcb-3bc6-58a4-a0b8-2f8ed236b413', 'SUPPORT_PATIENTS', 'Pacientes', 2, now(), now(), 1),
  ('5141711e-b6ed-5020-9015-408c26c03091', 'SUPPORT_MESSAGING', 'Mensajería', 3, now(), now(), 1),
  ('a7cde8bf-fbf8-5632-9517-7f4a67b94570', 'SUPPORT_BILLING', 'Facturación y caja', 4, now(), now(), 1),
  ('d69897ff-ff51-5675-b8b8-275a5cad1e3d', 'SUPPORT_REPORTS', 'Reportes', 5, now(), now(), 1),
  ('c368a0a0-f783-539d-8c90-d271c6d15664', 'SUPPORT_TEAM', 'Equipo de apoyo', 6, now(), now(), 1),
  ('4956a307-bc81-5b38-a8a5-4143cc416f5c', 'SUPPORT_AUDIT', 'Auditoría y explicación', 7, now(), now(), 1)
ON CONFLICT (id) DO UPDATE SET code = EXCLUDED.code, name = EXCLUDED.name, ordinal = EXCLUDED.ordinal, updated_at = now();

-- (b) los 73 atomos `modulo.recurso.accion[.campo]` con sus metadatos (la fila ya existe si la API arranco: se refresca)
INSERT INTO authz.permissions (id, code, category_id, name, resource, action_concept_id, default_scope_concept_id, is_field_level, is_dangerous,
    state_concept_id, is_role_restricted, allow_direct_user_grant, sensitivity_concept_id, requires_reason, requires_step_up,
    approval_mode_concept_id, purpose_of_use_concept_id, legal_basis_concept_id, touches_clinical_data, support_assignable,
    created_at, updated_at, row_version) VALUES
  ('efeeea20-52a5-5973-a94a-37793ded463a', 'agenda.appointment.view', '74102927-61f0-5416-adc3-6ca263a345f8', 'Ver la agenda (horarios y estado de las citas)', 'agenda.appointment', 'ea5aa219-9b0f-538f-9ca5-0e7eb4e715cf', '1b45f74f-f39e-58eb-b29a-86c100efeb67', false, false, '38a1d301-f40d-5b17-a695-5e6d605f8b19', false, false, '2a5b8592-dcf4-5643-af29-609b689c5a96', false, false, NULL, '366c58bc-ee9e-55ed-8306-7844bad4521b', '3b501456-1e56-539b-806c-37286d15df43', false, true, now(), now(), 1),
  ('44941499-4002-5836-bc41-561f86916a91', 'agenda.appointment.view.patient_name', '74102927-61f0-5416-adc3-6ca263a345f8', 'Ver el nombre del paciente en la cita', 'agenda.appointment', 'ea5aa219-9b0f-538f-9ca5-0e7eb4e715cf', '1b45f74f-f39e-58eb-b29a-86c100efeb67', true, false, '38a1d301-f40d-5b17-a695-5e6d605f8b19', false, false, '0beaba91-1b4d-5e7b-8ba9-be584245df0a', false, false, NULL, '366c58bc-ee9e-55ed-8306-7844bad4521b', '3b501456-1e56-539b-806c-37286d15df43', false, true, now(), now(), 1),
  ('8f8287ca-10e7-53a0-8875-62380e5eb760', 'agenda.appointment.view.patient_phone', '74102927-61f0-5416-adc3-6ca263a345f8', 'Ver el teléfono del paciente en la cita', 'agenda.appointment', 'ea5aa219-9b0f-538f-9ca5-0e7eb4e715cf', '1b45f74f-f39e-58eb-b29a-86c100efeb67', true, false, '38a1d301-f40d-5b17-a695-5e6d605f8b19', false, false, '0beaba91-1b4d-5e7b-8ba9-be584245df0a', false, false, NULL, '366c58bc-ee9e-55ed-8306-7844bad4521b', '3b501456-1e56-539b-806c-37286d15df43', false, true, now(), now(), 1),
  ('054f61ed-6c6c-59d7-9cb3-f71ca38bd70b', 'agenda.appointment.view.patient_document', '74102927-61f0-5416-adc3-6ca263a345f8', 'Ver el documento del paciente en la cita', 'agenda.appointment', 'ea5aa219-9b0f-538f-9ca5-0e7eb4e715cf', '1b45f74f-f39e-58eb-b29a-86c100efeb67', true, true, '38a1d301-f40d-5b17-a695-5e6d605f8b19', false, false, 'e9e9a413-e636-5eb1-8d73-62f67b9c57f3', false, false, NULL, '366c58bc-ee9e-55ed-8306-7844bad4521b', '3b501456-1e56-539b-806c-37286d15df43', false, true, now(), now(), 1),
  ('5ed80082-4016-52bc-912d-19b2a6ad9ea4', 'agenda.appointment.view.reason', '74102927-61f0-5416-adc3-6ca263a345f8', 'Ver el motivo de consulta', 'agenda.appointment', 'ea5aa219-9b0f-538f-9ca5-0e7eb4e715cf', '1b45f74f-f39e-58eb-b29a-86c100efeb67', true, true, '38a1d301-f40d-5b17-a695-5e6d605f8b19', false, false, 'e9e9a413-e636-5eb1-8d73-62f67b9c57f3', false, false, NULL, '366c58bc-ee9e-55ed-8306-7844bad4521b', '3b501456-1e56-539b-806c-37286d15df43', true, true, now(), now(), 1),
  ('76de6c5c-ea44-5df2-adb0-6829c3deceea', 'agenda.appointment.view.insurance', '74102927-61f0-5416-adc3-6ca263a345f8', 'Ver la aseguradora del paciente en la cita', 'agenda.appointment', 'ea5aa219-9b0f-538f-9ca5-0e7eb4e715cf', '1b45f74f-f39e-58eb-b29a-86c100efeb67', true, false, '38a1d301-f40d-5b17-a695-5e6d605f8b19', false, false, '0beaba91-1b4d-5e7b-8ba9-be584245df0a', false, false, NULL, '2d7a1066-c15a-5b13-ae77-bdfce86ead96', '3b501456-1e56-539b-806c-37286d15df43', false, true, now(), now(), 1),
  ('a12067b5-77c5-5659-b5c0-fd8beec2220c', 'agenda.appointment.view.price', '74102927-61f0-5416-adc3-6ca263a345f8', 'Ver el precio de la cita', 'agenda.appointment', 'ea5aa219-9b0f-538f-9ca5-0e7eb4e715cf', '1b45f74f-f39e-58eb-b29a-86c100efeb67', true, false, '38a1d301-f40d-5b17-a695-5e6d605f8b19', false, false, '2a5b8592-dcf4-5643-af29-609b689c5a96', false, false, NULL, '2d7a1066-c15a-5b13-ae77-bdfce86ead96', '3b501456-1e56-539b-806c-37286d15df43', false, true, now(), now(), 1),
  ('dcb281d5-ade2-548e-a600-94049262bc99', 'agenda.appointment.create', '74102927-61f0-5416-adc3-6ca263a345f8', 'Crear citas', 'agenda.appointment', '89c2342b-cec1-5678-b97c-e33c304d5519', '1b45f74f-f39e-58eb-b29a-86c100efeb67', false, false, '38a1d301-f40d-5b17-a695-5e6d605f8b19', false, false, '0beaba91-1b4d-5e7b-8ba9-be584245df0a', false, false, NULL, '366c58bc-ee9e-55ed-8306-7844bad4521b', '3b501456-1e56-539b-806c-37286d15df43', false, true, now(), now(), 1),
  ('f7c0aeff-c4b1-5de6-a07c-0b7822233643', 'agenda.appointment.create.overbook', '74102927-61f0-5416-adc3-6ca263a345f8', 'Crear citas con sobrecupo', 'agenda.appointment', '89c2342b-cec1-5678-b97c-e33c304d5519', '1b45f74f-f39e-58eb-b29a-86c100efeb67', false, true, '38a1d301-f40d-5b17-a695-5e6d605f8b19', false, false, 'e9e9a413-e636-5eb1-8d73-62f67b9c57f3', true, false, '1ec189f8-507a-5fce-9fac-09a584864c04', '366c58bc-ee9e-55ed-8306-7844bad4521b', '3b501456-1e56-539b-806c-37286d15df43', false, true, now(), now(), 1),
  ('672e888a-62f7-5dcb-98be-8a584c9c9e00', 'agenda.appointment.reschedule', '74102927-61f0-5416-adc3-6ca263a345f8', 'Reprogramar citas', 'agenda.appointment', '0491c4bb-2c42-5acb-b422-8da33bd0b4a3', '1b45f74f-f39e-58eb-b29a-86c100efeb67', false, false, '38a1d301-f40d-5b17-a695-5e6d605f8b19', false, false, '0beaba91-1b4d-5e7b-8ba9-be584245df0a', true, false, NULL, '366c58bc-ee9e-55ed-8306-7844bad4521b', '3b501456-1e56-539b-806c-37286d15df43', false, true, now(), now(), 1),
  ('1c4a946d-8915-5423-b5f7-6708c207a3aa', 'agenda.appointment.cancel', '74102927-61f0-5416-adc3-6ca263a345f8', 'Cancelar citas', 'agenda.appointment', '0491c4bb-2c42-5acb-b422-8da33bd0b4a3', '1b45f74f-f39e-58eb-b29a-86c100efeb67', false, false, '38a1d301-f40d-5b17-a695-5e6d605f8b19', false, false, '0beaba91-1b4d-5e7b-8ba9-be584245df0a', true, false, NULL, '366c58bc-ee9e-55ed-8306-7844bad4521b', '3b501456-1e56-539b-806c-37286d15df43', false, true, now(), now(), 1),
  ('f4782b09-e8a1-5922-935d-cfecc88d74f3', 'agenda.appointment.confirm', '74102927-61f0-5416-adc3-6ca263a345f8', 'Confirmar citas', 'agenda.appointment', '11f6b39b-272e-52c4-9583-3bd153b1e21e', '1b45f74f-f39e-58eb-b29a-86c100efeb67', false, false, '38a1d301-f40d-5b17-a695-5e6d605f8b19', false, false, '2a5b8592-dcf4-5643-af29-609b689c5a96', false, false, NULL, '366c58bc-ee9e-55ed-8306-7844bad4521b', '3b501456-1e56-539b-806c-37286d15df43', false, true, now(), now(), 1),
  ('3acf14a6-7c28-528b-9db3-6e9c50b99739', 'agenda.appointment.check_in', '74102927-61f0-5416-adc3-6ca263a345f8', 'Registrar la llegada del paciente', 'agenda.appointment', '11f6b39b-272e-52c4-9583-3bd153b1e21e', '1b45f74f-f39e-58eb-b29a-86c100efeb67', false, false, '38a1d301-f40d-5b17-a695-5e6d605f8b19', false, false, '2a5b8592-dcf4-5643-af29-609b689c5a96', false, false, NULL, '366c58bc-ee9e-55ed-8306-7844bad4521b', '3b501456-1e56-539b-806c-37286d15df43', false, true, now(), now(), 1),
  ('ef46e334-1617-5bcb-9c20-f16826ef248b', 'agenda.appointment.no_show', '74102927-61f0-5416-adc3-6ca263a345f8', 'Marcar al paciente como ausente', 'agenda.appointment', '11f6b39b-272e-52c4-9583-3bd153b1e21e', '1b45f74f-f39e-58eb-b29a-86c100efeb67', false, false, '38a1d301-f40d-5b17-a695-5e6d605f8b19', false, false, '0beaba91-1b4d-5e7b-8ba9-be584245df0a', false, false, NULL, '366c58bc-ee9e-55ed-8306-7844bad4521b', '3b501456-1e56-539b-806c-37286d15df43', false, true, now(), now(), 1),
  ('662896ab-39d9-5fa6-9200-d6fa6fdd1447', 'agenda.appointment.walk_in', '74102927-61f0-5416-adc3-6ca263a345f8', 'Atender a un paciente sin cita previa', 'agenda.appointment', '89c2342b-cec1-5678-b97c-e33c304d5519', '1b45f74f-f39e-58eb-b29a-86c100efeb67', false, false, '38a1d301-f40d-5b17-a695-5e6d605f8b19', false, false, '0beaba91-1b4d-5e7b-8ba9-be584245df0a', false, false, NULL, '366c58bc-ee9e-55ed-8306-7844bad4521b', '3b501456-1e56-539b-806c-37286d15df43', false, true, now(), now(), 1),
  ('04e3b714-1b35-540d-b93b-2908e8a8d068', 'agenda.waitlist.manage', '74102927-61f0-5416-adc3-6ca263a345f8', 'Gestionar la lista de espera', 'agenda.waitlist', '0491c4bb-2c42-5acb-b422-8da33bd0b4a3', '1b45f74f-f39e-58eb-b29a-86c100efeb67', false, false, '38a1d301-f40d-5b17-a695-5e6d605f8b19', false, false, '2a5b8592-dcf4-5643-af29-609b689c5a96', false, false, NULL, '366c58bc-ee9e-55ed-8306-7844bad4521b', '3b501456-1e56-539b-806c-37286d15df43', false, true, now(), now(), 1),
  ('cfac3bbb-b59d-5aa0-9b51-4d09bf5f538a', 'agenda.reminder.send', '74102927-61f0-5416-adc3-6ca263a345f8', 'Enviar recordatorios de cita', 'agenda.reminder', '11f6b39b-272e-52c4-9583-3bd153b1e21e', '1b45f74f-f39e-58eb-b29a-86c100efeb67', false, false, '38a1d301-f40d-5b17-a695-5e6d605f8b19', false, false, '2a5b8592-dcf4-5643-af29-609b689c5a96', false, false, NULL, '366c58bc-ee9e-55ed-8306-7844bad4521b', '3b501456-1e56-539b-806c-37286d15df43', false, true, now(), now(), 1),
  ('e743048f-b7bd-586f-bb3b-b3b47ef4bcf5', 'agenda.block.create', '74102927-61f0-5416-adc3-6ca263a345f8', 'Bloquear horarios de la agenda', 'agenda.block', '89c2342b-cec1-5678-b97c-e33c304d5519', '1b45f74f-f39e-58eb-b29a-86c100efeb67', false, false, '38a1d301-f40d-5b17-a695-5e6d605f8b19', false, false, '0beaba91-1b4d-5e7b-8ba9-be584245df0a', true, false, NULL, '394283d3-702b-5748-9900-df62233b6150', '42521499-302b-56b5-ae4a-b3a0d2e6f468', false, true, now(), now(), 1),
  ('39aa19d5-1fc5-552d-84b8-d23f281dc849', 'agenda.block.remove', '74102927-61f0-5416-adc3-6ca263a345f8', 'Quitar bloqueos de la agenda', 'agenda.block', 'f61506db-f890-5ee2-b94b-3a0614a1725a', '1b45f74f-f39e-58eb-b29a-86c100efeb67', false, false, '38a1d301-f40d-5b17-a695-5e6d605f8b19', false, false, '0beaba91-1b4d-5e7b-8ba9-be584245df0a', false, false, NULL, '394283d3-702b-5748-9900-df62233b6150', '42521499-302b-56b5-ae4a-b3a0d2e6f468', false, true, now(), now(), 1),
  ('378f04dc-abf9-5a86-86c4-3a8447790644', 'agenda.hours.edit', '74102927-61f0-5416-adc3-6ca263a345f8', 'Cambiar los horarios de atención del doctor', 'agenda.hours', '0491c4bb-2c42-5acb-b422-8da33bd0b4a3', '1b45f74f-f39e-58eb-b29a-86c100efeb67', false, true, '38a1d301-f40d-5b17-a695-5e6d605f8b19', false, false, 'e9e9a413-e636-5eb1-8d73-62f67b9c57f3', true, true, '1ec189f8-507a-5fce-9fac-09a584864c04', '394283d3-702b-5748-9900-df62233b6150', '42521499-302b-56b5-ae4a-b3a0d2e6f468', false, true, now(), now(), 1),
  ('53a5479b-dd19-51c4-802b-7359cd8be359', 'patients.search.exact', 'ba719bcb-3bc6-58a4-a0b8-2f8ed236b413', 'Buscar pacientes (búsqueda exacta)', 'patients.search', 'ea5aa219-9b0f-538f-9ca5-0e7eb4e715cf', '1b45f74f-f39e-58eb-b29a-86c100efeb67', false, false, '38a1d301-f40d-5b17-a695-5e6d605f8b19', false, false, '0beaba91-1b4d-5e7b-8ba9-be584245df0a', false, false, NULL, '366c58bc-ee9e-55ed-8306-7844bad4521b', '3b501456-1e56-539b-806c-37286d15df43', false, true, now(), now(), 1),
  ('a1303ccf-446c-527a-b30b-c8e08b77f4b1', 'patients.profile.view_basic', 'ba719bcb-3bc6-58a4-a0b8-2f8ed236b413', 'Ver la ficha básica del paciente (nombre, edad, contacto parcial)', 'patients.profile', 'ea5aa219-9b0f-538f-9ca5-0e7eb4e715cf', '1b45f74f-f39e-58eb-b29a-86c100efeb67', false, false, '38a1d301-f40d-5b17-a695-5e6d605f8b19', false, false, '0beaba91-1b4d-5e7b-8ba9-be584245df0a', false, false, NULL, '366c58bc-ee9e-55ed-8306-7844bad4521b', '3b501456-1e56-539b-806c-37286d15df43', false, true, now(), now(), 1),
  ('1a4b9a3e-7e19-539d-b819-f03b457cbb1d', 'patients.profile.view.phone_full', 'ba719bcb-3bc6-58a4-a0b8-2f8ed236b413', 'Ver el teléfono completo del paciente', 'patients.profile', 'ea5aa219-9b0f-538f-9ca5-0e7eb4e715cf', '1b45f74f-f39e-58eb-b29a-86c100efeb67', true, false, '38a1d301-f40d-5b17-a695-5e6d605f8b19', false, false, '0beaba91-1b4d-5e7b-8ba9-be584245df0a', false, false, NULL, '366c58bc-ee9e-55ed-8306-7844bad4521b', '3b501456-1e56-539b-806c-37286d15df43', false, true, now(), now(), 1),
  ('f21f5d57-4e8a-55ec-bd2f-8dc8eee71361', 'patients.profile.view.document_full', 'ba719bcb-3bc6-58a4-a0b8-2f8ed236b413', 'Ver el documento completo del paciente', 'patients.profile', 'ea5aa219-9b0f-538f-9ca5-0e7eb4e715cf', '1b45f74f-f39e-58eb-b29a-86c100efeb67', true, true, '38a1d301-f40d-5b17-a695-5e6d605f8b19', false, false, 'e9e9a413-e636-5eb1-8d73-62f67b9c57f3', true, false, NULL, '366c58bc-ee9e-55ed-8306-7844bad4521b', '3b501456-1e56-539b-806c-37286d15df43', false, true, now(), now(), 1),
  ('b8159666-5b97-5eed-99c8-95692a72bd7b', 'patients.coverage.view', 'ba719bcb-3bc6-58a4-a0b8-2f8ed236b413', 'Ver la cobertura o seguro vigente del paciente', 'patients.coverage', 'ea5aa219-9b0f-538f-9ca5-0e7eb4e715cf', '1b45f74f-f39e-58eb-b29a-86c100efeb67', false, false, '38a1d301-f40d-5b17-a695-5e6d605f8b19', false, false, '0beaba91-1b4d-5e7b-8ba9-be584245df0a', false, false, NULL, '2d7a1066-c15a-5b13-ae77-bdfce86ead96', '3b501456-1e56-539b-806c-37286d15df43', false, true, now(), now(), 1),
  ('b88c1279-bdf5-5c9c-be82-79702a9df31c', 'patients.profile.register', 'ba719bcb-3bc6-58a4-a0b8-2f8ed236b413', 'Registrar pacientes nuevos', 'patients.profile', '89c2342b-cec1-5678-b97c-e33c304d5519', '1b45f74f-f39e-58eb-b29a-86c100efeb67', false, false, '38a1d301-f40d-5b17-a695-5e6d605f8b19', false, false, '0beaba91-1b4d-5e7b-8ba9-be584245df0a', false, false, NULL, '366c58bc-ee9e-55ed-8306-7844bad4521b', '3b501456-1e56-539b-806c-37286d15df43', false, true, now(), now(), 1),
  ('4833c0f0-16d0-5a8d-a440-c6bcbbe10527', 'patients.guardian.record', 'ba719bcb-3bc6-58a4-a0b8-2f8ed236b413', 'Anotar al representante de un menor (queda pendiente de verificación)', 'patients.guardian', '89c2342b-cec1-5678-b97c-e33c304d5519', '1b45f74f-f39e-58eb-b29a-86c100efeb67', false, false, '38a1d301-f40d-5b17-a695-5e6d605f8b19', false, false, '0beaba91-1b4d-5e7b-8ba9-be584245df0a', false, false, NULL, '366c58bc-ee9e-55ed-8306-7844bad4521b', '3b501456-1e56-539b-806c-37286d15df43', false, true, now(), now(), 1),
  ('7f7275c2-cd3f-5e6a-9bf7-3371f0223896', 'patients.profile.edit_contact', 'ba719bcb-3bc6-58a4-a0b8-2f8ed236b413', 'Corregir datos de contacto del paciente', 'patients.profile', '0491c4bb-2c42-5acb-b422-8da33bd0b4a3', '1b45f74f-f39e-58eb-b29a-86c100efeb67', false, false, '38a1d301-f40d-5b17-a695-5e6d605f8b19', false, false, '0beaba91-1b4d-5e7b-8ba9-be584245df0a', true, false, NULL, '366c58bc-ee9e-55ed-8306-7844bad4521b', '3b501456-1e56-539b-806c-37286d15df43', false, true, now(), now(), 1),
  ('40a94008-6a45-5ec5-b804-70da21395ba5', 'patients.profile.edit_verified', 'ba719bcb-3bc6-58a4-a0b8-2f8ed236b413', 'Corregir datos verificados (nombre, documento, nacimiento)', 'patients.profile', '0491c4bb-2c42-5acb-b422-8da33bd0b4a3', '1b45f74f-f39e-58eb-b29a-86c100efeb67', false, true, '38a1d301-f40d-5b17-a695-5e6d605f8b19', false, false, 'dc8d3a20-6a3f-5d2f-b85f-85475513a93b', true, true, '610c6456-d162-539e-b21e-2d19a4a99b88', '366c58bc-ee9e-55ed-8306-7844bad4521b', '3f73e692-c05f-588c-b921-3956bfd35cb5', false, true, now(), now(), 1),
  ('ec5dc000-461b-522d-9789-5e080d05cf5d', 'patients.profile.merge_request', 'ba719bcb-3bc6-58a4-a0b8-2f8ed236b413', 'Pedir la fusión de fichas duplicadas', 'patients.profile', '11f6b39b-272e-52c4-9583-3bd153b1e21e', '1b45f74f-f39e-58eb-b29a-86c100efeb67', false, true, '38a1d301-f40d-5b17-a695-5e6d605f8b19', false, false, 'e9e9a413-e636-5eb1-8d73-62f67b9c57f3', true, false, '610c6456-d162-539e-b21e-2d19a4a99b88', '366c58bc-ee9e-55ed-8306-7844bad4521b', '3b501456-1e56-539b-806c-37286d15df43', false, true, now(), now(), 1),
  ('bac300b0-094c-51e8-8ecc-b20274418873', 'patients.clinical.request_temporary_access', 'ba719bcb-3bc6-58a4-a0b8-2f8ed236b413', 'Pedir acceso clínico temporal a un paciente', 'patients.clinical', '11f6b39b-272e-52c4-9583-3bd153b1e21e', '1b45f74f-f39e-58eb-b29a-86c100efeb67', false, true, '38a1d301-f40d-5b17-a695-5e6d605f8b19', false, false, 'e9e9a413-e636-5eb1-8d73-62f67b9c57f3', true, true, '1ec189f8-507a-5fce-9fac-09a584864c04', '366c58bc-ee9e-55ed-8306-7844bad4521b', 'eb9f5178-755e-590a-82df-9eb68913e1b5', true, true, now(), now(), 1),
  ('42d19611-205f-5380-b51c-b55738727905', 'messages.inbox.view', '5141711e-b6ed-5020-9015-408c26c03091', 'Ver la bandeja de mensajes del doctor', 'messages.inbox', 'ea5aa219-9b0f-538f-9ca5-0e7eb4e715cf', '1b45f74f-f39e-58eb-b29a-86c100efeb67', false, false, '38a1d301-f40d-5b17-a695-5e6d605f8b19', false, false, '0beaba91-1b4d-5e7b-8ba9-be584245df0a', false, false, NULL, '366c58bc-ee9e-55ed-8306-7844bad4521b', '3b501456-1e56-539b-806c-37286d15df43', false, true, now(), now(), 1),
  ('6b674c45-b9ea-58a2-aaac-deb008d63569', 'messages.conversation.reply_on_behalf', '5141711e-b6ed-5020-9015-408c26c03091', 'Responder mensajes administrativos en nombre del doctor', 'messages.conversation', '89c2342b-cec1-5678-b97c-e33c304d5519', '1b45f74f-f39e-58eb-b29a-86c100efeb67', false, false, '38a1d301-f40d-5b17-a695-5e6d605f8b19', false, false, '0beaba91-1b4d-5e7b-8ba9-be584245df0a', false, false, NULL, '366c58bc-ee9e-55ed-8306-7844bad4521b', '3b501456-1e56-539b-806c-37286d15df43', false, true, now(), now(), 1),
  ('7a76a3cc-8b12-5015-840e-bdca9a2caa6b', 'messages.conversation.assign', '5141711e-b6ed-5020-9015-408c26c03091', 'Asignar conversaciones a una persona del equipo', 'messages.conversation', '0491c4bb-2c42-5acb-b422-8da33bd0b4a3', '1b45f74f-f39e-58eb-b29a-86c100efeb67', false, false, '38a1d301-f40d-5b17-a695-5e6d605f8b19', false, false, '2a5b8592-dcf4-5643-af29-609b689c5a96', false, false, NULL, '394283d3-702b-5748-9900-df62233b6150', '42521499-302b-56b5-ae4a-b3a0d2e6f468', false, true, now(), now(), 1),
  ('bb5f9949-5574-5527-8605-6615e6963066', 'messages.conversation.resolve', '5141711e-b6ed-5020-9015-408c26c03091', 'Marcar conversaciones como resueltas', 'messages.conversation', '0491c4bb-2c42-5acb-b422-8da33bd0b4a3', '1b45f74f-f39e-58eb-b29a-86c100efeb67', false, false, '38a1d301-f40d-5b17-a695-5e6d605f8b19', false, false, '2a5b8592-dcf4-5643-af29-609b689c5a96', false, false, NULL, '394283d3-702b-5748-9900-df62233b6150', '42521499-302b-56b5-ae4a-b3a0d2e6f468', false, true, now(), now(), 1),
  ('5ee0247f-139d-57e1-b662-9584cba0310b', 'messages.note.create_internal', '5141711e-b6ed-5020-9015-408c26c03091', 'Escribir notas internas del equipo', 'messages.note', '89c2342b-cec1-5678-b97c-e33c304d5519', '1b45f74f-f39e-58eb-b29a-86c100efeb67', false, false, '38a1d301-f40d-5b17-a695-5e6d605f8b19', false, false, '2a5b8592-dcf4-5643-af29-609b689c5a96', false, false, NULL, '394283d3-702b-5748-9900-df62233b6150', '42521499-302b-56b5-ae4a-b3a0d2e6f468', false, true, now(), now(), 1),
  ('36c0f0da-72de-5fc2-9649-07d42c69f134', 'messages.template.use', '5141711e-b6ed-5020-9015-408c26c03091', 'Usar respuestas preparadas', 'messages.template', '11f6b39b-272e-52c4-9583-3bd153b1e21e', '1b45f74f-f39e-58eb-b29a-86c100efeb67', false, false, '38a1d301-f40d-5b17-a695-5e6d605f8b19', false, false, '2a5b8592-dcf4-5643-af29-609b689c5a96', false, false, NULL, '394283d3-702b-5748-9900-df62233b6150', '42521499-302b-56b5-ae4a-b3a0d2e6f468', false, true, now(), now(), 1),
  ('47050d94-6b22-5581-a41c-f81980e80179', 'messages.template.manage', '5141711e-b6ed-5020-9015-408c26c03091', 'Administrar respuestas preparadas', 'messages.template', '0491c4bb-2c42-5acb-b422-8da33bd0b4a3', '1b45f74f-f39e-58eb-b29a-86c100efeb67', false, false, '38a1d301-f40d-5b17-a695-5e6d605f8b19', false, false, '0beaba91-1b4d-5e7b-8ba9-be584245df0a', false, false, NULL, '394283d3-702b-5748-9900-df62233b6150', '42521499-302b-56b5-ae4a-b3a0d2e6f468', false, true, now(), now(), 1),
  ('78f0ffc4-3ace-5bb4-9df3-897a53f7e91f', 'messages.attachment.send', '5141711e-b6ed-5020-9015-408c26c03091', 'Enviar archivos adjuntos a pacientes', 'messages.attachment', '89c2342b-cec1-5678-b97c-e33c304d5519', '1b45f74f-f39e-58eb-b29a-86c100efeb67', false, true, '38a1d301-f40d-5b17-a695-5e6d605f8b19', false, false, 'e9e9a413-e636-5eb1-8d73-62f67b9c57f3', false, false, NULL, '366c58bc-ee9e-55ed-8306-7844bad4521b', '3b501456-1e56-539b-806c-37286d15df43', false, true, now(), now(), 1),
  ('0de6aa11-4f86-50c1-9d8c-511db13346b4', 'messages.broadcast.send', '5141711e-b6ed-5020-9015-408c26c03091', 'Enviar mensajes masivos a pacientes', 'messages.broadcast', '11f6b39b-272e-52c4-9583-3bd153b1e21e', '1b45f74f-f39e-58eb-b29a-86c100efeb67', false, true, '38a1d301-f40d-5b17-a695-5e6d605f8b19', false, false, 'e9e9a413-e636-5eb1-8d73-62f67b9c57f3', true, false, '610c6456-d162-539e-b21e-2d19a4a99b88', '394283d3-702b-5748-9900-df62233b6150', '42521499-302b-56b5-ae4a-b3a0d2e6f468', false, true, now(), now(), 1),
  ('f16aed56-f135-5b2e-8538-a4b48b22b351', 'billing.invoice.view', 'a7cde8bf-fbf8-5632-9517-7f4a67b94570', 'Ver cobros y comprobantes emitidos', 'billing.invoice', 'ea5aa219-9b0f-538f-9ca5-0e7eb4e715cf', '1b45f74f-f39e-58eb-b29a-86c100efeb67', false, false, '38a1d301-f40d-5b17-a695-5e6d605f8b19', false, false, '0beaba91-1b4d-5e7b-8ba9-be584245df0a', false, false, NULL, '2d7a1066-c15a-5b13-ae77-bdfce86ead96', '3f73e692-c05f-588c-b921-3956bfd35cb5', false, true, now(), now(), 1),
  ('72274a1f-c418-5bc6-95a8-374531b64fef', 'billing.payment.collect', 'a7cde8bf-fbf8-5632-9517-7f4a67b94570', 'Cobrar la atención', 'billing.payment', '89c2342b-cec1-5678-b97c-e33c304d5519', '1b45f74f-f39e-58eb-b29a-86c100efeb67', false, true, '38a1d301-f40d-5b17-a695-5e6d605f8b19', false, false, 'e9e9a413-e636-5eb1-8d73-62f67b9c57f3', false, false, NULL, '2d7a1066-c15a-5b13-ae77-bdfce86ead96', '3f73e692-c05f-588c-b921-3956bfd35cb5', false, true, now(), now(), 1),
  ('c8887db8-1bf5-5a9f-974d-75eca68d28d7', 'billing.receipt.issue', 'a7cde8bf-fbf8-5632-9517-7f4a67b94570', 'Emitir comprobantes', 'billing.receipt', '89c2342b-cec1-5678-b97c-e33c304d5519', '1b45f74f-f39e-58eb-b29a-86c100efeb67', false, true, '38a1d301-f40d-5b17-a695-5e6d605f8b19', false, false, 'e9e9a413-e636-5eb1-8d73-62f67b9c57f3', false, false, NULL, '2d7a1066-c15a-5b13-ae77-bdfce86ead96', '3f73e692-c05f-588c-b921-3956bfd35cb5', false, true, now(), now(), 1),
  ('004982fe-4f05-55e9-88ba-97d2c816a902', 'billing.receipt.void', 'a7cde8bf-fbf8-5632-9517-7f4a67b94570', 'Anular comprobantes', 'billing.receipt', '0491c4bb-2c42-5acb-b422-8da33bd0b4a3', '1b45f74f-f39e-58eb-b29a-86c100efeb67', false, true, '38a1d301-f40d-5b17-a695-5e6d605f8b19', false, false, 'dc8d3a20-6a3f-5d2f-b85f-85475513a93b', true, true, '610c6456-d162-539e-b21e-2d19a4a99b88', '2d7a1066-c15a-5b13-ae77-bdfce86ead96', '3f73e692-c05f-588c-b921-3956bfd35cb5', false, true, now(), now(), 1),
  ('3406a667-38b9-52d5-890c-130fc059414e', 'billing.payment.refund', 'a7cde8bf-fbf8-5632-9517-7f4a67b94570', 'Devolver pagos', 'billing.payment', '11f6b39b-272e-52c4-9583-3bd153b1e21e', '1b45f74f-f39e-58eb-b29a-86c100efeb67', false, true, '38a1d301-f40d-5b17-a695-5e6d605f8b19', false, false, 'dc8d3a20-6a3f-5d2f-b85f-85475513a93b', true, true, '610c6456-d162-539e-b21e-2d19a4a99b88', '2d7a1066-c15a-5b13-ae77-bdfce86ead96', '3f73e692-c05f-588c-b921-3956bfd35cb5', false, true, now(), now(), 1),
  ('9e470e06-4266-5c83-b991-86b1b3c10842', 'billing.discount.apply', 'a7cde8bf-fbf8-5632-9517-7f4a67b94570', 'Aplicar descuentos', 'billing.discount', '11f6b39b-272e-52c4-9583-3bd153b1e21e', '1b45f74f-f39e-58eb-b29a-86c100efeb67', false, true, '38a1d301-f40d-5b17-a695-5e6d605f8b19', false, false, 'e9e9a413-e636-5eb1-8d73-62f67b9c57f3', true, false, NULL, '2d7a1066-c15a-5b13-ae77-bdfce86ead96', '3f73e692-c05f-588c-b921-3956bfd35cb5', false, true, now(), now(), 1),
  ('c9ab5a01-6f9f-56c7-a143-c11b90d99434', 'billing.cashbox.close', 'a7cde8bf-fbf8-5632-9517-7f4a67b94570', 'Cerrar la caja del día', 'billing.cashbox', '11f6b39b-272e-52c4-9583-3bd153b1e21e', '1b45f74f-f39e-58eb-b29a-86c100efeb67', false, true, '38a1d301-f40d-5b17-a695-5e6d605f8b19', false, false, 'e9e9a413-e636-5eb1-8d73-62f67b9c57f3', false, true, NULL, '2d7a1066-c15a-5b13-ae77-bdfce86ead96', '3f73e692-c05f-588c-b921-3956bfd35cb5', false, true, now(), now(), 1),
  ('e7c33743-ba81-58d9-a2e1-d94db64e7ce7', 'reports.agenda.view', 'd69897ff-ff51-5675-b8b8-275a5cad1e3d', 'Ver reportes de agenda (sin datos de pacientes)', 'reports.agenda', 'ea5aa219-9b0f-538f-9ca5-0e7eb4e715cf', '1b45f74f-f39e-58eb-b29a-86c100efeb67', false, false, '38a1d301-f40d-5b17-a695-5e6d605f8b19', false, false, '2a5b8592-dcf4-5643-af29-609b689c5a96', false, false, NULL, '394283d3-702b-5748-9900-df62233b6150', '42521499-302b-56b5-ae4a-b3a0d2e6f468', false, true, now(), now(), 1),
  ('604f5d03-1d89-5848-8fb2-c1cee28f26c4', 'reports.agenda.export', 'd69897ff-ff51-5675-b8b8-275a5cad1e3d', 'Exportar listados de agenda con pacientes', 'reports.agenda', '11f6b39b-272e-52c4-9583-3bd153b1e21e', '1b45f74f-f39e-58eb-b29a-86c100efeb67', false, true, '38a1d301-f40d-5b17-a695-5e6d605f8b19', false, false, 'e9e9a413-e636-5eb1-8d73-62f67b9c57f3', true, true, NULL, '394283d3-702b-5748-9900-df62233b6150', '42521499-302b-56b5-ae4a-b3a0d2e6f468', false, true, now(), now(), 1),
  ('620da2b5-9ba0-58c1-b22f-ef5b58663996', 'reports.billing.view', 'd69897ff-ff51-5675-b8b8-275a5cad1e3d', 'Ver reportes de caja', 'reports.billing', 'ea5aa219-9b0f-538f-9ca5-0e7eb4e715cf', '1b45f74f-f39e-58eb-b29a-86c100efeb67', false, false, '38a1d301-f40d-5b17-a695-5e6d605f8b19', false, false, '0beaba91-1b4d-5e7b-8ba9-be584245df0a', false, false, NULL, '2d7a1066-c15a-5b13-ae77-bdfce86ead96', '3f73e692-c05f-588c-b921-3956bfd35cb5', false, true, now(), now(), 1),
  ('4f9f5386-d36f-52d3-8321-6723c3031bad', 'reports.billing.export', 'd69897ff-ff51-5675-b8b8-275a5cad1e3d', 'Exportar reportes de caja', 'reports.billing', '11f6b39b-272e-52c4-9583-3bd153b1e21e', '1b45f74f-f39e-58eb-b29a-86c100efeb67', false, true, '38a1d301-f40d-5b17-a695-5e6d605f8b19', false, false, 'e9e9a413-e636-5eb1-8d73-62f67b9c57f3', true, true, NULL, '2d7a1066-c15a-5b13-ae77-bdfce86ead96', '3f73e692-c05f-588c-b921-3956bfd35cb5', false, true, now(), now(), 1),
  ('0f600fde-de44-5b9c-9dd2-120c7913f4ea', 'team.members.view', 'c368a0a0-f783-539d-8c90-d271c6d15664', 'Ver al equipo de apoyo y sus permisos', 'team.members', 'ea5aa219-9b0f-538f-9ca5-0e7eb4e715cf', '1b45f74f-f39e-58eb-b29a-86c100efeb67', false, false, '38a1d301-f40d-5b17-a695-5e6d605f8b19', false, false, '0beaba91-1b4d-5e7b-8ba9-be584245df0a', false, false, NULL, '394283d3-702b-5748-9900-df62233b6150', '42521499-302b-56b5-ae4a-b3a0d2e6f468', false, true, now(), now(), 1),
  ('d293bde0-9b2d-5650-b0b6-7ac2f3bc230f', 'team.invitations.create', 'c368a0a0-f783-539d-8c90-d271c6d15664', 'Invitar personas al equipo (código o QR)', 'team.invitations', '89c2342b-cec1-5678-b97c-e33c304d5519', '1b45f74f-f39e-58eb-b29a-86c100efeb67', false, true, '38a1d301-f40d-5b17-a695-5e6d605f8b19', false, false, 'e9e9a413-e636-5eb1-8d73-62f67b9c57f3', true, false, NULL, '394283d3-702b-5748-9900-df62233b6150', '42521499-302b-56b5-ae4a-b3a0d2e6f468', false, true, now(), now(), 1),
  ('3e298c9e-5e8e-58ad-b1d1-4aa176ba6235', 'team.requests.decide', 'c368a0a0-f783-539d-8c90-d271c6d15664', 'Resolver solicitudes de acceso del equipo', 'team.requests', '3721e545-b640-5765-8268-65b7d1a8e8e9', '1b45f74f-f39e-58eb-b29a-86c100efeb67', false, true, '38a1d301-f40d-5b17-a695-5e6d605f8b19', false, false, 'e9e9a413-e636-5eb1-8d73-62f67b9c57f3', true, false, NULL, '394283d3-702b-5748-9900-df62233b6150', '42521499-302b-56b5-ae4a-b3a0d2e6f468', false, true, now(), now(), 1),
  ('9619ea42-4bb9-52cc-b7a3-7f5ec23a5439', 'team.grants.assign', 'c368a0a0-f783-539d-8c90-d271c6d15664', 'Otorgar permisos al equipo (dentro de su techo)', 'team.grants', '0491c4bb-2c42-5acb-b422-8da33bd0b4a3', '1b45f74f-f39e-58eb-b29a-86c100efeb67', false, true, '38a1d301-f40d-5b17-a695-5e6d605f8b19', false, false, 'e9e9a413-e636-5eb1-8d73-62f67b9c57f3', true, true, NULL, '394283d3-702b-5748-9900-df62233b6150', '42521499-302b-56b5-ae4a-b3a0d2e6f468', false, true, now(), now(), 1),
  ('61db4521-3e45-5210-9113-21282d3209f3', 'team.grants.revoke', 'c368a0a0-f783-539d-8c90-d271c6d15664', 'Quitar permisos del equipo', 'team.grants', 'f61506db-f890-5ee2-b94b-3a0614a1725a', '1b45f74f-f39e-58eb-b29a-86c100efeb67', false, true, '38a1d301-f40d-5b17-a695-5e6d605f8b19', false, false, 'e9e9a413-e636-5eb1-8d73-62f67b9c57f3', true, false, NULL, '394283d3-702b-5748-9900-df62233b6150', '42521499-302b-56b5-ae4a-b3a0d2e6f468', false, true, now(), now(), 1),
  ('d545b48b-53cf-5d15-918a-42a53d3ecc78', 'team.engagement.recertify', 'c368a0a0-f783-539d-8c90-d271c6d15664', 'Confirmar vínculos del equipo (recertificar)', 'team.engagement', '11f6b39b-272e-52c4-9583-3bd153b1e21e', '1b45f74f-f39e-58eb-b29a-86c100efeb67', false, false, '38a1d301-f40d-5b17-a695-5e6d605f8b19', false, false, '0beaba91-1b4d-5e7b-8ba9-be584245df0a', false, false, NULL, '394283d3-702b-5748-9900-df62233b6150', '42521499-302b-56b5-ae4a-b3a0d2e6f468', false, true, now(), now(), 1),
  ('35b0e156-afca-54bd-8858-0ec806f3da35', 'team.engagement.suspend', 'c368a0a0-f783-539d-8c90-d271c6d15664', 'Suspender a una persona del equipo', 'team.engagement', '11f6b39b-272e-52c4-9583-3bd153b1e21e', '1b45f74f-f39e-58eb-b29a-86c100efeb67', false, true, '38a1d301-f40d-5b17-a695-5e6d605f8b19', false, false, 'e9e9a413-e636-5eb1-8d73-62f67b9c57f3', true, false, NULL, '394283d3-702b-5748-9900-df62233b6150', '42521499-302b-56b5-ae4a-b3a0d2e6f468', false, true, now(), now(), 1),
  ('76e88531-20eb-5600-b8e3-cfb8e3f36ad7', 'team.engagement.reactivate', 'c368a0a0-f783-539d-8c90-d271c6d15664', 'Pedir la reactivación de una persona suspendida', 'team.engagement', '11f6b39b-272e-52c4-9583-3bd153b1e21e', '1b45f74f-f39e-58eb-b29a-86c100efeb67', false, true, '38a1d301-f40d-5b17-a695-5e6d605f8b19', false, false, 'e9e9a413-e636-5eb1-8d73-62f67b9c57f3', true, false, '610c6456-d162-539e-b21e-2d19a4a99b88', '394283d3-702b-5748-9900-df62233b6150', '42521499-302b-56b5-ae4a-b3a0d2e6f468', false, true, now(), now(), 1),
  ('7030ec19-4f22-5a18-a61a-6918dbad2274', 'team.engagement.end', 'c368a0a0-f783-539d-8c90-d271c6d15664', 'Dar de baja a una persona del equipo', 'team.engagement', '11f6b39b-272e-52c4-9583-3bd153b1e21e', '1b45f74f-f39e-58eb-b29a-86c100efeb67', false, true, '38a1d301-f40d-5b17-a695-5e6d605f8b19', false, false, 'e9e9a413-e636-5eb1-8d73-62f67b9c57f3', true, false, NULL, '394283d3-702b-5748-9900-df62233b6150', '42521499-302b-56b5-ae4a-b3a0d2e6f468', false, true, now(), now(), 1),
  ('8b2722fe-b1e5-57ac-8fb9-ad7f6ec75def', 'team.handover.execute', 'c368a0a0-f783-539d-8c90-d271c6d15664', 'Reasignar el trabajo de quien se va', 'team.handover', '11f6b39b-272e-52c4-9583-3bd153b1e21e', '1b45f74f-f39e-58eb-b29a-86c100efeb67', false, true, '38a1d301-f40d-5b17-a695-5e6d605f8b19', false, false, 'e9e9a413-e636-5eb1-8d73-62f67b9c57f3', true, false, NULL, '394283d3-702b-5748-9900-df62233b6150', '42521499-302b-56b5-ae4a-b3a0d2e6f468', false, true, now(), now(), 1),
  ('15292618-2c42-52d0-b01d-d56c78bd680a', 'team.campaigns.review', 'c368a0a0-f783-539d-8c90-d271c6d15664', 'Revisar accesos en campañas de certificación', 'team.campaigns', '3721e545-b640-5765-8268-65b7d1a8e8e9', '1b45f74f-f39e-58eb-b29a-86c100efeb67', false, false, '38a1d301-f40d-5b17-a695-5e6d605f8b19', false, false, '0beaba91-1b4d-5e7b-8ba9-be584245df0a', false, false, NULL, '394283d3-702b-5748-9900-df62233b6150', '42521499-302b-56b5-ae4a-b3a0d2e6f468', false, true, now(), now(), 1),
  ('67191dca-dba1-5ec7-8d96-646024a96290', 'team.campaigns.manage', 'c368a0a0-f783-539d-8c90-d271c6d15664', 'Crear y lanzar campañas de certificación', 'team.campaigns', '0491c4bb-2c42-5acb-b422-8da33bd0b4a3', '1b45f74f-f39e-58eb-b29a-86c100efeb67', false, true, '38a1d301-f40d-5b17-a695-5e6d605f8b19', false, false, 'e9e9a413-e636-5eb1-8d73-62f67b9c57f3', true, false, NULL, '394283d3-702b-5748-9900-df62233b6150', '42521499-302b-56b5-ae4a-b3a0d2e6f468', false, true, now(), now(), 1),
  ('a669994d-1f9b-5742-8b2d-5e909c2a1a70', 'team.sod.exception.request', 'c368a0a0-f783-539d-8c90-d271c6d15664', 'Pedir una excepción de separación de funciones', 'team.sod', '89c2342b-cec1-5678-b97c-e33c304d5519', '1b45f74f-f39e-58eb-b29a-86c100efeb67', false, true, '38a1d301-f40d-5b17-a695-5e6d605f8b19', false, false, 'e9e9a413-e636-5eb1-8d73-62f67b9c57f3', true, false, '610c6456-d162-539e-b21e-2d19a4a99b88', '394283d3-702b-5748-9900-df62233b6150', '42521499-302b-56b5-ae4a-b3a0d2e6f468', false, true, now(), now(), 1),
  ('b20e50c1-ac7f-5468-896d-6defda0a4681', 'team.templates.manage', 'c368a0a0-f783-539d-8c90-d271c6d15664', 'Administrar plantillas de rol de la organización', 'team.templates', '0491c4bb-2c42-5acb-b422-8da33bd0b4a3', '1b45f74f-f39e-58eb-b29a-86c100efeb67', false, true, '38a1d301-f40d-5b17-a695-5e6d605f8b19', false, false, 'e9e9a413-e636-5eb1-8d73-62f67b9c57f3', true, true, NULL, '394283d3-702b-5748-9900-df62233b6150', '42521499-302b-56b5-ae4a-b3a0d2e6f468', false, false, now(), now(), 1),
  ('e97fcb81-d554-51e1-a53f-6f4a3874432f', 'team.guardrails.manage', 'c368a0a0-f783-539d-8c90-d271c6d15664', 'Administrar reglas y techos de la organización', 'team.guardrails', '0491c4bb-2c42-5acb-b422-8da33bd0b4a3', '1b45f74f-f39e-58eb-b29a-86c100efeb67', false, true, '38a1d301-f40d-5b17-a695-5e6d605f8b19', false, false, 'dc8d3a20-6a3f-5d2f-b85f-85475513a93b', true, true, NULL, '394283d3-702b-5748-9900-df62233b6150', '42521499-302b-56b5-ae4a-b3a0d2e6f468', false, false, now(), now(), 1),
  ('eff625b4-0370-5446-a021-b3c44764198c', 'team.sod.manage', 'c368a0a0-f783-539d-8c90-d271c6d15664', 'Administrar reglas de separación de funciones', 'team.sod', '0491c4bb-2c42-5acb-b422-8da33bd0b4a3', '1b45f74f-f39e-58eb-b29a-86c100efeb67', false, true, '38a1d301-f40d-5b17-a695-5e6d605f8b19', false, false, 'dc8d3a20-6a3f-5d2f-b85f-85475513a93b', true, true, NULL, '394283d3-702b-5748-9900-df62233b6150', '42521499-302b-56b5-ae4a-b3a0d2e6f468', false, false, now(), now(), 1),
  ('48a8e7b7-2f29-5464-8348-288c123b26dd', 'team.sessionpolicy.manage', 'c368a0a0-f783-539d-8c90-d271c6d15664', 'Administrar políticas de sesión y reglas de red', 'team.sessionpolicy', '0491c4bb-2c42-5acb-b422-8da33bd0b4a3', '1b45f74f-f39e-58eb-b29a-86c100efeb67', false, true, '38a1d301-f40d-5b17-a695-5e6d605f8b19', false, false, 'dc8d3a20-6a3f-5d2f-b85f-85475513a93b', true, true, NULL, '394283d3-702b-5748-9900-df62233b6150', '42521499-302b-56b5-ae4a-b3a0d2e6f468', false, false, now(), now(), 1),
  ('fbe1d36f-310d-557c-b014-5d81414351ca', 'audit.activity.view_team', '4956a307-bc81-5b38-a8a5-4143cc416f5c', 'Ver la actividad del equipo', 'audit.activity', 'ea5aa219-9b0f-538f-9ca5-0e7eb4e715cf', '1b45f74f-f39e-58eb-b29a-86c100efeb67', false, false, '38a1d301-f40d-5b17-a695-5e6d605f8b19', false, false, '0beaba91-1b4d-5e7b-8ba9-be584245df0a', false, false, NULL, '394283d3-702b-5748-9900-df62233b6150', '42521499-302b-56b5-ae4a-b3a0d2e6f468', false, true, now(), now(), 1),
  ('9cff9315-c54a-58d9-af6c-3fecdd636c9a', 'audit.activity.view_org', '4956a307-bc81-5b38-a8a5-4143cc416f5c', 'Ver la actividad de toda la organización', 'audit.activity', 'ea5aa219-9b0f-538f-9ca5-0e7eb4e715cf', '1b45f74f-f39e-58eb-b29a-86c100efeb67', false, true, '38a1d301-f40d-5b17-a695-5e6d605f8b19', false, false, 'e9e9a413-e636-5eb1-8d73-62f67b9c57f3', false, false, NULL, '394283d3-702b-5748-9900-df62233b6150', '42521499-302b-56b5-ae4a-b3a0d2e6f468', false, true, now(), now(), 1),
  ('9b3bf93d-f02b-5dab-9599-b4bdd568937f', 'audit.activity.export', '4956a307-bc81-5b38-a8a5-4143cc416f5c', 'Exportar la actividad', 'audit.activity', '11f6b39b-272e-52c4-9583-3bd153b1e21e', '1b45f74f-f39e-58eb-b29a-86c100efeb67', false, true, '38a1d301-f40d-5b17-a695-5e6d605f8b19', false, false, 'e9e9a413-e636-5eb1-8d73-62f67b9c57f3', true, true, NULL, '394283d3-702b-5748-9900-df62233b6150', '42521499-302b-56b5-ae4a-b3a0d2e6f468', false, true, now(), now(), 1),
  ('9bc38d0f-a05f-5b36-a1f0-6b3f79ca89ad', 'audit.decisions.explain', '4956a307-bc81-5b38-a8a5-4143cc416f5c', 'Explicar y simular permisos', 'audit.decisions', 'ea5aa219-9b0f-538f-9ca5-0e7eb4e715cf', '1b45f74f-f39e-58eb-b29a-86c100efeb67', false, false, '38a1d301-f40d-5b17-a695-5e6d605f8b19', false, false, '0beaba91-1b4d-5e7b-8ba9-be584245df0a', false, false, NULL, '394283d3-702b-5748-9900-df62233b6150', '42521499-302b-56b5-ae4a-b3a0d2e6f468', false, true, now(), now(), 1),
  ('03936799-b89d-5879-9b6d-47851fb3ac15', 'audit.reports.governance.view', '4956a307-bc81-5b38-a8a5-4143cc416f5c', 'Ver los tableros de gobierno de accesos', 'audit.reports', 'ea5aa219-9b0f-538f-9ca5-0e7eb4e715cf', '1b45f74f-f39e-58eb-b29a-86c100efeb67', false, true, '38a1d301-f40d-5b17-a695-5e6d605f8b19', false, false, 'e9e9a413-e636-5eb1-8d73-62f67b9c57f3', false, false, NULL, '394283d3-702b-5748-9900-df62233b6150', '42521499-302b-56b5-ae4a-b3a0d2e6f468', false, true, now(), now(), 1)
ON CONFLICT (id) DO UPDATE SET category_id = EXCLUDED.category_id, name = EXCLUDED.name, resource = EXCLUDED.resource,
    action_concept_id = EXCLUDED.action_concept_id, is_field_level = EXCLUDED.is_field_level, is_dangerous = EXCLUDED.is_dangerous,
    sensitivity_concept_id = EXCLUDED.sensitivity_concept_id, requires_reason = EXCLUDED.requires_reason,
    requires_step_up = EXCLUDED.requires_step_up, approval_mode_concept_id = EXCLUDED.approval_mode_concept_id,
    purpose_of_use_concept_id = EXCLUDED.purpose_of_use_concept_id, legal_basis_concept_id = EXCLUDED.legal_basis_concept_id,
    touches_clinical_data = EXCLUDED.touches_clinical_data, support_assignable = EXCLUDED.support_assignable, updated_at = now();

-- (c) los 15 codigos antiguos siguen (mismo id) como ALIAS: categoria y sensibilidad de su atomo primario y las OBLIGACIONES mas estrictas de
--     los atomos a los que se expanden (motivo, paso extra, aprobacion): un alias no puede saltarse lo que exige su atomo. NO son asignables a
--     personal de apoyo (support_assignable = false): las concesiones nuevas usan el atomo; las filas alias ya creadas siguen vivas
--     (revision de seguridad v4.2.79). En una base recien creada todavia no existen (los siembra la API o la demo): se insertan si faltan y
--     despues se marcan por codigo.
INSERT INTO authz.permissions (id, code, category_id, name, resource, action_concept_id, default_scope_concept_id, is_field_level, is_dangerous,
    state_concept_id, is_role_restricted, allow_direct_user_grant, sensitivity_concept_id, requires_reason, requires_step_up,
    approval_mode_concept_id, purpose_of_use_concept_id, legal_basis_concept_id, touches_clinical_data, support_assignable,
    created_at, updated_at, row_version) VALUES
  ('438c578b-e5ea-5c58-86ed-fcf7da71780e', 'schedule.view', '74102927-61f0-5416-adc3-6ca263a345f8', 'Ver la agenda', 'scheduling.appointment', 'ea5aa219-9b0f-538f-9ca5-0e7eb4e715cf', '1b45f74f-f39e-58eb-b29a-86c100efeb67', false, false, '38a1d301-f40d-5b17-a695-5e6d605f8b19', false, false, '2a5b8592-dcf4-5643-af29-609b689c5a96', false, false, NULL, NULL, NULL, false, false, now(), now(), 1),
  ('7c5a3eeb-ac26-5d5e-a7b0-993955c63a2e', 'schedule.create', '74102927-61f0-5416-adc3-6ca263a345f8', 'Crear citas', 'scheduling.appointment', '89c2342b-cec1-5678-b97c-e33c304d5519', '1b45f74f-f39e-58eb-b29a-86c100efeb67', false, false, '38a1d301-f40d-5b17-a695-5e6d605f8b19', false, false, '0beaba91-1b4d-5e7b-8ba9-be584245df0a', false, false, NULL, NULL, NULL, false, false, now(), now(), 1),
  ('9246c74e-5181-5a6b-b070-a8eef9887948', 'schedule.reschedule', '74102927-61f0-5416-adc3-6ca263a345f8', 'Reprogramar citas', 'scheduling.appointment', '0491c4bb-2c42-5acb-b422-8da33bd0b4a3', '1b45f74f-f39e-58eb-b29a-86c100efeb67', false, false, '38a1d301-f40d-5b17-a695-5e6d605f8b19', false, false, '0beaba91-1b4d-5e7b-8ba9-be584245df0a', true, false, NULL, NULL, NULL, false, false, now(), now(), 1),
  ('cd48f1e6-f8ed-5aba-bfbd-aec1829312ab', 'schedule.cancel', '74102927-61f0-5416-adc3-6ca263a345f8', 'Cancelar citas', 'scheduling.appointment', '0491c4bb-2c42-5acb-b422-8da33bd0b4a3', '1b45f74f-f39e-58eb-b29a-86c100efeb67', false, false, '38a1d301-f40d-5b17-a695-5e6d605f8b19', false, false, '0beaba91-1b4d-5e7b-8ba9-be584245df0a', true, false, NULL, NULL, NULL, false, false, now(), now(), 1),
  ('f69bb091-dd4b-58bf-93ca-0714bddd536b', 'schedule.confirm', '74102927-61f0-5416-adc3-6ca263a345f8', 'Confirmar citas', 'scheduling.appointment', '11f6b39b-272e-52c4-9583-3bd153b1e21e', '1b45f74f-f39e-58eb-b29a-86c100efeb67', false, false, '38a1d301-f40d-5b17-a695-5e6d605f8b19', false, false, '2a5b8592-dcf4-5643-af29-609b689c5a96', false, false, NULL, NULL, NULL, false, false, now(), now(), 1),
  ('062598be-12eb-5eab-acb6-714fe9e8eb1f', 'schedule.check_in', '74102927-61f0-5416-adc3-6ca263a345f8', 'Registrar la llegada del paciente', 'scheduling.appointment', '11f6b39b-272e-52c4-9583-3bd153b1e21e', '1b45f74f-f39e-58eb-b29a-86c100efeb67', false, false, '38a1d301-f40d-5b17-a695-5e6d605f8b19', false, false, '2a5b8592-dcf4-5643-af29-609b689c5a96', false, false, NULL, NULL, NULL, false, false, now(), now(), 1),
  ('9d8b0c5a-1e2c-5f42-8200-1c1d537f7a1c', 'schedule.walk_in', '74102927-61f0-5416-adc3-6ca263a345f8', 'Atender paciente sin cita previa', 'scheduling.appointment', '89c2342b-cec1-5678-b97c-e33c304d5519', '1b45f74f-f39e-58eb-b29a-86c100efeb67', false, false, '38a1d301-f40d-5b17-a695-5e6d605f8b19', false, false, '0beaba91-1b4d-5e7b-8ba9-be584245df0a', false, false, NULL, NULL, NULL, false, false, now(), now(), 1),
  ('3482e7ed-b143-5b9c-b171-2751b12d8d37', 'schedule.waitlist', '74102927-61f0-5416-adc3-6ca263a345f8', 'Gestionar la lista de espera', 'scheduling.waitlist_entry', '0491c4bb-2c42-5acb-b422-8da33bd0b4a3', '1b45f74f-f39e-58eb-b29a-86c100efeb67', false, false, '38a1d301-f40d-5b17-a695-5e6d605f8b19', false, false, '2a5b8592-dcf4-5643-af29-609b689c5a96', false, false, NULL, NULL, NULL, false, false, now(), now(), 1),
  ('d9c9f910-bc47-5316-8c00-780378806085', 'schedule.send_reminders', '74102927-61f0-5416-adc3-6ca263a345f8', 'Enviar recordatorios de cita', 'scheduling.appointment_reminder', '11f6b39b-272e-52c4-9583-3bd153b1e21e', '1b45f74f-f39e-58eb-b29a-86c100efeb67', false, false, '38a1d301-f40d-5b17-a695-5e6d605f8b19', false, false, '2a5b8592-dcf4-5643-af29-609b689c5a96', false, false, NULL, NULL, NULL, false, false, now(), now(), 1),
  ('1ccc916d-4ded-5155-9e36-1b6a33ede032', 'schedule.block_time', '74102927-61f0-5416-adc3-6ca263a345f8', 'Bloquear horarios de la agenda', 'scheduling.availability_exception', '0491c4bb-2c42-5acb-b422-8da33bd0b4a3', '1b45f74f-f39e-58eb-b29a-86c100efeb67', false, false, '38a1d301-f40d-5b17-a695-5e6d605f8b19', false, false, '0beaba91-1b4d-5e7b-8ba9-be584245df0a', true, false, NULL, NULL, NULL, false, false, now(), now(), 1),
  ('7e464ef1-7256-55f4-8334-656da444ace4', 'schedule.edit_hours', '74102927-61f0-5416-adc3-6ca263a345f8', 'Editar los horarios de atención', 'scheduling.schedule_template', '0491c4bb-2c42-5acb-b422-8da33bd0b4a3', '1b45f74f-f39e-58eb-b29a-86c100efeb67', false, false, '38a1d301-f40d-5b17-a695-5e6d605f8b19', false, false, 'e9e9a413-e636-5eb1-8d73-62f67b9c57f3', true, true, '1ec189f8-507a-5fce-9fac-09a584864c04', NULL, NULL, false, false, now(), now(), 1),
  ('7fca105d-bef3-5c11-b347-5cc88e179d23', 'billing.collect', 'a7cde8bf-fbf8-5632-9517-7f4a67b94570', 'Cobrar la atención', 'billing.payment', '11f6b39b-272e-52c4-9583-3bd153b1e21e', '1b45f74f-f39e-58eb-b29a-86c100efeb67', false, false, '38a1d301-f40d-5b17-a695-5e6d605f8b19', false, false, 'e9e9a413-e636-5eb1-8d73-62f67b9c57f3', false, false, NULL, NULL, NULL, false, false, now(), now(), 1),
  ('7f1d095d-cb33-5514-b6f3-ce25fff58d94', 'billing.issue_receipt', 'a7cde8bf-fbf8-5632-9517-7f4a67b94570', 'Emitir comprobantes', 'billing.receipt', '89c2342b-cec1-5678-b97c-e33c304d5519', '1b45f74f-f39e-58eb-b29a-86c100efeb67', false, false, '38a1d301-f40d-5b17-a695-5e6d605f8b19', false, false, 'e9e9a413-e636-5eb1-8d73-62f67b9c57f3', false, false, NULL, NULL, NULL, false, false, now(), now(), 1),
  ('a68e3753-6295-5f35-b261-3142072da22c', 'patient.register', 'ba719bcb-3bc6-58a4-a0b8-2f8ed236b413', 'Registrar pacientes', 'profiles.patient_profile', '89c2342b-cec1-5678-b97c-e33c304d5519', '1b45f74f-f39e-58eb-b29a-86c100efeb67', false, false, '38a1d301-f40d-5b17-a695-5e6d605f8b19', false, false, '0beaba91-1b4d-5e7b-8ba9-be584245df0a', false, false, NULL, NULL, NULL, false, false, now(), now(), 1),
  ('9d3b3416-e19f-54cf-968e-5ed8c655e90a', 'messages.reply_on_behalf', '5141711e-b6ed-5020-9015-408c26c03091', 'Responder mensajes administrativos en nombre del profesional', 'community.direct_message', '89c2342b-cec1-5678-b97c-e33c304d5519', '1b45f74f-f39e-58eb-b29a-86c100efeb67', false, false, '38a1d301-f40d-5b17-a695-5e6d605f8b19', false, false, '0beaba91-1b4d-5e7b-8ba9-be584245df0a', false, false, NULL, NULL, NULL, false, false, now(), now(), 1)
ON CONFLICT DO NOTHING;
UPDATE authz.permissions p
   SET category_id = v.category_id, sensitivity_concept_id = v.sensitivity_concept_id, support_assignable = false,
       requires_reason = v.requires_reason, requires_step_up = v.requires_step_up,
       approval_mode_concept_id = v.approval_mode_concept_id, updated_at = now()
  FROM (VALUES
  ('schedule.view', '74102927-61f0-5416-adc3-6ca263a345f8'::uuid, '2a5b8592-dcf4-5643-af29-609b689c5a96'::uuid, false, false, NULL::uuid),
  ('schedule.create', '74102927-61f0-5416-adc3-6ca263a345f8'::uuid, '0beaba91-1b4d-5e7b-8ba9-be584245df0a'::uuid, false, false, NULL::uuid),
  ('schedule.reschedule', '74102927-61f0-5416-adc3-6ca263a345f8'::uuid, '0beaba91-1b4d-5e7b-8ba9-be584245df0a'::uuid, true, false, NULL::uuid),
  ('schedule.cancel', '74102927-61f0-5416-adc3-6ca263a345f8'::uuid, '0beaba91-1b4d-5e7b-8ba9-be584245df0a'::uuid, true, false, NULL::uuid),
  ('schedule.confirm', '74102927-61f0-5416-adc3-6ca263a345f8'::uuid, '2a5b8592-dcf4-5643-af29-609b689c5a96'::uuid, false, false, NULL::uuid),
  ('schedule.check_in', '74102927-61f0-5416-adc3-6ca263a345f8'::uuid, '2a5b8592-dcf4-5643-af29-609b689c5a96'::uuid, false, false, NULL::uuid),
  ('schedule.walk_in', '74102927-61f0-5416-adc3-6ca263a345f8'::uuid, '0beaba91-1b4d-5e7b-8ba9-be584245df0a'::uuid, false, false, NULL::uuid),
  ('schedule.waitlist', '74102927-61f0-5416-adc3-6ca263a345f8'::uuid, '2a5b8592-dcf4-5643-af29-609b689c5a96'::uuid, false, false, NULL::uuid),
  ('schedule.send_reminders', '74102927-61f0-5416-adc3-6ca263a345f8'::uuid, '2a5b8592-dcf4-5643-af29-609b689c5a96'::uuid, false, false, NULL::uuid),
  ('schedule.block_time', '74102927-61f0-5416-adc3-6ca263a345f8'::uuid, '0beaba91-1b4d-5e7b-8ba9-be584245df0a'::uuid, true, false, NULL::uuid),
  ('schedule.edit_hours', '74102927-61f0-5416-adc3-6ca263a345f8'::uuid, 'e9e9a413-e636-5eb1-8d73-62f67b9c57f3'::uuid, true, true, '1ec189f8-507a-5fce-9fac-09a584864c04'::uuid),
  ('billing.collect', 'a7cde8bf-fbf8-5632-9517-7f4a67b94570'::uuid, 'e9e9a413-e636-5eb1-8d73-62f67b9c57f3'::uuid, false, false, NULL::uuid),
  ('billing.issue_receipt', 'a7cde8bf-fbf8-5632-9517-7f4a67b94570'::uuid, 'e9e9a413-e636-5eb1-8d73-62f67b9c57f3'::uuid, false, false, NULL::uuid),
  ('patient.register', 'ba719bcb-3bc6-58a4-a0b8-2f8ed236b413'::uuid, '0beaba91-1b4d-5e7b-8ba9-be584245df0a'::uuid, false, false, NULL::uuid),
  ('messages.reply_on_behalf', '5141711e-b6ed-5020-9015-408c26c03091'::uuid, '0beaba91-1b4d-5e7b-8ba9-be584245df0a'::uuid, false, false, NULL::uuid)) v(code, category_id, sensitivity_concept_id, requires_reason, requires_step_up, approval_mode_concept_id)
 WHERE p.code = v.code;

-- (d) rol de sistema SUPPORT_STAFF (claim de ejecucion con ambito de organizacion: NO se asigna) y su piso de plataforma de campos
INSERT INTO authz.roles (id, tenant_id, code, name, base_role_concept_id, scope_concept_id, is_system, is_assignable, state_concept_id,
    created_at, updated_at, row_version)
VALUES ('9e83128c-41e4-50fc-b4c3-e829918f71d0', NULL, 'SUPPORT_STAFF', 'Personal de apoyo', '1d9cfe89-1075-54dd-a197-a52d33962533', '1b45f74f-f39e-58eb-b29a-86c100efeb67', true, false, '38a1d301-f40d-5b17-a695-5e6d605f8b19', now(), now(), 1)
ON CONFLICT (id) DO UPDATE SET is_system = true, is_assignable = false, updated_at = now();
INSERT INTO authz.field_permissions (id, role_id, entity, column_name, can_read, can_write, created_at, updated_at, row_version) VALUES
  ('31b541e4-bc81-5ba0-9f3f-53f2648d97ed', '9e83128c-41e4-50fc-b4c3-e829918f71d0', 'clinical.conditions', 'code_concept_id', false, false, now(), now(), 1),
  ('a3d9d6aa-39ad-5fa7-b03d-bbe4d7c38f23', '9e83128c-41e4-50fc-b4c3-e829918f71d0', 'clinical.conditions', 'note_text', false, false, now(), now(), 1),
  ('0f540be4-a8d0-5891-bd25-d90537bed66c', '9e83128c-41e4-50fc-b4c3-e829918f71d0', 'chart.clinical_note_versions', 'subjective_text', false, false, now(), now(), 1),
  ('b6ab2461-45a1-5736-acad-d7aca983e3a5', '9e83128c-41e4-50fc-b4c3-e829918f71d0', 'chart.clinical_note_versions', 'objective_text', false, false, now(), now(), 1),
  ('d2d8adaf-ec1a-540b-bf30-ae9fde0a67ef', '9e83128c-41e4-50fc-b4c3-e829918f71d0', 'chart.clinical_note_versions', 'assessment_text', false, false, now(), now(), 1),
  ('6b0f7b2a-6f1c-55dc-85f4-9d5ddf215e5d', '9e83128c-41e4-50fc-b4c3-e829918f71d0', 'chart.clinical_note_versions', 'plan_text', false, false, now(), now(), 1),
  ('c5912a26-5dc9-5880-a88b-ddcbe2312109', '9e83128c-41e4-50fc-b4c3-e829918f71d0', 'chart.clinical_note_versions', 'entries_json', false, false, now(), now(), 1),
  ('dfead757-9814-538f-aac1-1b377e79dfb1', '9e83128c-41e4-50fc-b4c3-e829918f71d0', 'clinical.observations', 'value_text', false, false, now(), now(), 1),
  ('5ff18ccb-b3c1-54c0-a1ea-a2da7a6fd284', '9e83128c-41e4-50fc-b4c3-e829918f71d0', 'clinical.observations', 'value_decimal', false, false, now(), now(), 1),
  ('30bc5b9c-1459-53c5-bc1e-3093a118bf48', '9e83128c-41e4-50fc-b4c3-e829918f71d0', 'clinical.observations', 'interpretation_concept_id', false, false, now(), now(), 1),
  ('2b9423ac-4177-5b23-8389-68db79b6e089', '9e83128c-41e4-50fc-b4c3-e829918f71d0', 'clinical.medication_requests', 'medication_concept_id', false, false, now(), now(), 1),
  ('05e20146-7d39-5af0-a188-5e0a0beda57c', '9e83128c-41e4-50fc-b4c3-e829918f71d0', 'clinical.medication_requests', 'indication_text', false, false, now(), now(), 1)
ON CONFLICT (id) DO NOTHING;

-- (e) 11 reglas de segregacion de funciones de PLATAFORMA (tenant NULL). Las de alcance TRANSACTION sin atomo usan marcadores `@...`
--     (las impone el servicio al ejecutar, no el otorgamiento).
INSERT INTO delegated_access.sod_rules (id, tenant_id, code, name, atoms_a_json, atoms_b_json, scope_concept_id, action_concept_id, is_hard,
    max_exception_days, rationale_text, status_concept_id, version_number, created_at, updated_at, row_version) VALUES
  ('b25947c7-9ed0-5345-8896-f2088d0186aa', NULL, 'SOD-BILL-01', 'Cobrar y anular', '["billing.payment.collect"]'::jsonb, '["billing.receipt.void"]'::jsonb, '0fb8d904-8d4c-5ff5-972e-b0968cadc699', 'd317a334-2e99-5361-836c-674cbeec5d26', true, NULL, 'Quien cobra no debe poder anular el comprobante de lo que cobró.', '38a1d301-f40d-5b17-a695-5e6d605f8b19', 1, now(), now(), 1),
  ('167e3be5-0125-5522-b737-f1cf0dbdd952', NULL, 'SOD-BILL-02', 'Cobrar y devolver', '["billing.payment.collect"]'::jsonb, '["billing.payment.refund"]'::jsonb, '0fb8d904-8d4c-5ff5-972e-b0968cadc699', 'd317a334-2e99-5361-836c-674cbeec5d26', true, NULL, 'Quien cobra no debe poder devolver el dinero que cobró.', '38a1d301-f40d-5b17-a695-5e6d605f8b19', 1, now(), now(), 1),
  ('091d7679-9a72-5c7d-8c36-d94cedc0d385', NULL, 'SOD-BILL-03', 'Crear citas y emitir comprobantes', '["agenda.appointment.create", "agenda.appointment.walk_in"]'::jsonb, '["billing.receipt.issue"]'::jsonb, '0fb8d904-8d4c-5ff5-972e-b0968cadc699', '117ffae4-a53b-5f5a-a927-d625ae57ad67', false, 90, 'Crear una atención y facturarla en una sola persona permite cobros ficticios; en consultorios pequeños se admite con excepción (D-05).', '38a1d301-f40d-5b17-a695-5e6d605f8b19', 1, now(), now(), 1),
  ('f36f83a9-59da-5bb6-b6b1-0fd487a21f0c', NULL, 'SOD-BILL-04', 'Descontar y cobrar', '["billing.discount.apply"]'::jsonb, '["billing.payment.collect"]'::jsonb, '0fb8d904-8d4c-5ff5-972e-b0968cadc699', '156a7df4-b47c-52d3-9646-9f201757db51', false, NULL, 'Quien aplica descuentos y también cobra puede quedarse con la diferencia: se advierte y aparece en el tablero.', '38a1d301-f40d-5b17-a695-5e6d605f8b19', 1, now(), now(), 1),
  ('19b22747-8186-5e30-91bf-8d01c0fac74a', NULL, 'SOD-BILL-05', 'Emitir y anular el mismo comprobante', '["billing.receipt.issue"]'::jsonb, '["billing.receipt.void"]'::jsonb, '926b5260-3468-5925-9aae-6ebbd4942fea', 'd317a334-2e99-5361-836c-674cbeec5d26', true, NULL, 'Una misma persona no puede emitir y anular un mismo comprobante (lo impone el servicio al ejecutar).', '38a1d301-f40d-5b17-a695-5e6d605f8b19', 1, now(), now(), 1),
  ('ad0a3d50-e98f-56ec-905a-de9fe008f38e', NULL, 'SOD-PAT-01', 'Registrar pacientes y corregir datos verificados', '["patients.profile.register", "patients.guardian.record"]'::jsonb, '["patients.profile.edit_verified"]'::jsonb, '0fb8d904-8d4c-5ff5-972e-b0968cadc699', 'd317a334-2e99-5361-836c-674cbeec5d26', true, NULL, 'Quien registra una identidad no debe poder corregirla después de verificada (cierra el hallazgo N1/N3).', '38a1d301-f40d-5b17-a695-5e6d605f8b19', 1, now(), now(), 1),
  ('4c597985-64bc-5e15-ab5f-fde3fbf4f4d1', NULL, 'SOD-PAT-02', 'Registrar y fusionar fichas', '["patients.profile.register"]'::jsonb, '["patients.profile.merge_request"]'::jsonb, '0fb8d904-8d4c-5ff5-972e-b0968cadc699', '117ffae4-a53b-5f5a-a927-d625ae57ad67', false, 90, 'Registrar y fusionar fichas en una sola persona facilita ocultar duplicados.', '38a1d301-f40d-5b17-a695-5e6d605f8b19', 1, now(), now(), 1),
  ('e9a28b9e-a09e-56d6-ac31-fd9f5035d5e9', NULL, 'SOD-GOV-01', 'Solicitar y aprobar (acceso)', '["@request"]'::jsonb, '["@decide"]'::jsonb, '926b5260-3468-5925-9aae-6ebbd4942fea', 'd317a334-2e99-5361-836c-674cbeec5d26', true, NULL, 'Nadie aprueba su propia solicitud de acceso (generaliza SUPPORT_DECISION_SELF).', '38a1d301-f40d-5b17-a695-5e6d605f8b19', 1, now(), now(), 1),
  ('5ff5d9a4-3b7a-5c8d-b746-873669247e03', NULL, 'SOD-GOV-02', 'Otorgar y certificar', '["team.grants.assign"]'::jsonb, '["team.campaigns.review"]'::jsonb, '926b5260-3468-5925-9aae-6ebbd4942fea', 'd317a334-2e99-5361-836c-674cbeec5d26', true, NULL, 'Quien otorgó o aprobó una concesión no la certifica en la campaña.', '38a1d301-f40d-5b17-a695-5e6d605f8b19', 1, now(), now(), 1),
  ('d003dffd-cd20-5ff4-b3d1-43648214c17f', NULL, 'SOD-GOV-03', 'Administrar el equipo y manejar caja', '["team.grants.assign", "team.requests.decide"]'::jsonb, '["billing.payment.collect", "billing.receipt.issue"]'::jsonb, '0fb8d904-8d4c-5ff5-972e-b0968cadc699', '117ffae4-a53b-5f5a-a927-d625ae57ad67', false, 90, 'Quien reparte permisos no debería manejar dinero con los suyos.', '38a1d301-f40d-5b17-a695-5e6d605f8b19', 1, now(), now(), 1),
  ('1a32689a-98d2-5102-a6ff-337e4110f310', NULL, 'SOD-AUD-01', 'Auditar y operar', '["audit.activity.view_org", "audit.activity.export", "audit.reports.governance.view"]'::jsonb, '["billing.payment.collect", "billing.receipt.void", "agenda.appointment.cancel", "patients.profile.edit_verified"]'::jsonb, '0fb8d904-8d4c-5ff5-972e-b0968cadc699', '117ffae4-a53b-5f5a-a927-d625ae57ad67', false, 90, 'Quien audita la actividad no debe ser quien la produce.', '38a1d301-f40d-5b17-a695-5e6d605f8b19', 1, now(), now(), 1)
ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name, atoms_a_json = EXCLUDED.atoms_a_json, atoms_b_json = EXCLUDED.atoms_b_json,
    scope_concept_id = EXCLUDED.scope_concept_id, action_concept_id = EXCLUDED.action_concept_id, is_hard = EXCLUDED.is_hard,
    max_exception_days = EXCLUDED.max_exception_days, rationale_text = EXCLUDED.rationale_text, updated_at = now();

-- (f) plantillas de rol v2 (paquete por defecto en atomos + techo + condiciones por defecto de `view.reason`, decision D-01). Las v1 quedan
--     RETIRADAS (siguen existiendo: los vinculos ya creados las usan); la version vigente de una plantilla es la mas alta entre las activas.
INSERT INTO delegated_access.role_templates (id, tenant_id, code, name, default_actions_json, default_conditions_json, ceiling_actions_json,
    status_concept_id, version_number, created_at, updated_at, row_version) VALUES
  ('473b58e0-2a4f-5985-98eb-6d5fcc513a23', NULL, 'SECRETARY', 'Secretaria', '["agenda.appointment.view", "agenda.appointment.view.patient_name", "agenda.appointment.view.reason", "agenda.appointment.create", "agenda.appointment.reschedule", "agenda.appointment.cancel", "agenda.appointment.confirm", "agenda.appointment.check_in", "agenda.appointment.walk_in", "agenda.waitlist.manage", "agenda.reminder.send", "patients.search.exact", "patients.profile.view_basic", "patients.profile.register", "patients.guardian.record", "messages.inbox.view", "messages.conversation.reply_on_behalf", "messages.conversation.assign", "messages.note.create_internal", "messages.template.use"]'::jsonb, '{"agenda.appointment.view.reason": {"schemaVersion": 1, "appointment": {"window": {"daysBefore": 1, "daysAfter": 14}}, "fields": {"agenda.appointment.view.reason": {"mask": "PARTIAL"}}}}'::jsonb, '["agenda.appointment.view", "agenda.appointment.view.patient_name", "agenda.appointment.view.patient_phone", "agenda.appointment.view.patient_document", "agenda.appointment.view.reason", "agenda.appointment.view.insurance", "agenda.appointment.view.price", "agenda.appointment.create", "agenda.appointment.create.overbook", "agenda.appointment.reschedule", "agenda.appointment.cancel", "agenda.appointment.confirm", "agenda.appointment.check_in", "agenda.appointment.no_show", "agenda.appointment.walk_in", "agenda.waitlist.manage", "agenda.reminder.send", "agenda.block.create", "agenda.block.remove", "agenda.hours.edit", "patients.search.exact", "patients.profile.view_basic", "patients.profile.view.phone_full", "patients.profile.view.document_full", "patients.coverage.view", "patients.profile.register", "patients.guardian.record", "patients.profile.edit_contact", "patients.profile.merge_request", "patients.clinical.request_temporary_access", "messages.inbox.view", "messages.conversation.reply_on_behalf", "messages.conversation.assign", "messages.conversation.resolve", "messages.note.create_internal", "messages.template.use", "messages.template.manage", "messages.attachment.send", "billing.invoice.view", "billing.payment.collect", "billing.receipt.issue", "reports.agenda.view"]'::jsonb, '6b070aec-a5af-52bc-8462-55be0d26298a', 2, now(), now(), 1),
  ('409ce186-d1ad-5e94-a1ad-21eef9580b92', NULL, 'MEDICAL_ASSISTANT', 'Asistente médico', '["agenda.appointment.view", "agenda.appointment.view.patient_name", "agenda.appointment.view.reason", "agenda.appointment.create", "agenda.appointment.reschedule", "agenda.appointment.cancel", "agenda.appointment.confirm", "agenda.appointment.check_in", "agenda.appointment.walk_in", "agenda.waitlist.manage", "agenda.reminder.send", "patients.search.exact", "patients.profile.view_basic", "patients.profile.register", "patients.guardian.record", "messages.inbox.view", "messages.conversation.reply_on_behalf", "messages.conversation.assign", "messages.note.create_internal", "messages.template.use"]'::jsonb, '{"agenda.appointment.view.reason": {"schemaVersion": 1, "appointment": {"window": {"daysBefore": 1, "daysAfter": 14}}, "fields": {"agenda.appointment.view.reason": {"mask": "PARTIAL"}}}}'::jsonb, '["agenda.appointment.view", "agenda.appointment.view.patient_name", "agenda.appointment.view.patient_phone", "agenda.appointment.view.patient_document", "agenda.appointment.view.reason", "agenda.appointment.view.insurance", "agenda.appointment.view.price", "agenda.appointment.create", "agenda.appointment.create.overbook", "agenda.appointment.reschedule", "agenda.appointment.cancel", "agenda.appointment.confirm", "agenda.appointment.check_in", "agenda.appointment.no_show", "agenda.appointment.walk_in", "agenda.waitlist.manage", "agenda.reminder.send", "agenda.block.create", "agenda.block.remove", "agenda.hours.edit", "patients.search.exact", "patients.profile.view_basic", "patients.profile.view.phone_full", "patients.profile.view.document_full", "patients.coverage.view", "patients.profile.register", "patients.guardian.record", "patients.profile.edit_contact", "patients.profile.merge_request", "patients.clinical.request_temporary_access", "messages.inbox.view", "messages.conversation.reply_on_behalf", "messages.conversation.assign", "messages.conversation.resolve", "messages.note.create_internal", "messages.template.use", "messages.template.manage", "messages.attachment.send", "billing.invoice.view", "billing.payment.collect", "billing.receipt.issue", "reports.agenda.view"]'::jsonb, '6b070aec-a5af-52bc-8462-55be0d26298a', 2, now(), now(), 1),
  ('bb877c7b-6e11-5d8c-a2dd-6b578c8eeb57', NULL, 'NURSING', 'Enfermería', '["agenda.appointment.view", "agenda.appointment.view.patient_name", "agenda.appointment.view.reason", "agenda.appointment.check_in", "agenda.waitlist.manage", "patients.search.exact", "patients.profile.view_basic"]'::jsonb, '{"agenda.appointment.view.reason": {"schemaVersion": 1, "appointment": {"window": {"daysBefore": 1, "daysAfter": 14}}, "fields": {"agenda.appointment.view.reason": {"mask": "PARTIAL"}}}}'::jsonb, '["agenda.appointment.view", "agenda.appointment.view.patient_name", "agenda.appointment.view.patient_phone", "agenda.appointment.view.reason", "agenda.appointment.view.insurance", "agenda.appointment.check_in", "agenda.appointment.no_show", "agenda.appointment.walk_in", "agenda.waitlist.manage", "patients.search.exact", "patients.profile.view_basic", "patients.coverage.view", "patients.clinical.request_temporary_access", "messages.inbox.view", "messages.note.create_internal", "messages.template.use", "reports.agenda.view"]'::jsonb, '6b070aec-a5af-52bc-8462-55be0d26298a', 2, now(), now(), 1),
  ('2b7d9162-b5fb-512c-bfc3-1ed863d704ff', NULL, 'FRONT_DESK', 'Recepción', '["agenda.appointment.view", "agenda.appointment.view.patient_name", "agenda.appointment.check_in", "agenda.appointment.walk_in", "patients.search.exact", "patients.profile.view_basic", "patients.profile.register", "patients.guardian.record"]'::jsonb, NULL::jsonb, '["agenda.appointment.view", "agenda.appointment.view.patient_name", "agenda.appointment.view.patient_phone", "agenda.appointment.view.patient_document", "agenda.appointment.view.insurance", "agenda.appointment.view.price", "agenda.appointment.create", "agenda.appointment.reschedule", "agenda.appointment.cancel", "agenda.appointment.confirm", "agenda.appointment.check_in", "agenda.appointment.no_show", "agenda.appointment.walk_in", "agenda.waitlist.manage", "agenda.reminder.send", "patients.search.exact", "patients.profile.view_basic", "patients.profile.view.phone_full", "patients.profile.view.document_full", "patients.coverage.view", "patients.profile.register", "patients.guardian.record", "patients.profile.edit_contact", "patients.profile.merge_request", "messages.inbox.view", "messages.conversation.reply_on_behalf", "messages.conversation.assign", "messages.conversation.resolve", "messages.note.create_internal", "messages.template.use", "messages.attachment.send", "billing.invoice.view", "billing.payment.collect", "billing.receipt.issue", "reports.agenda.view"]'::jsonb, '6b070aec-a5af-52bc-8462-55be0d26298a', 2, now(), now(), 1),
  ('0856c6ec-216d-5d47-9c24-4f62a46925ee', NULL, 'BILLING_CASHIER', 'Facturación y caja', '["agenda.appointment.view", "agenda.appointment.view.patient_name", "billing.invoice.view", "billing.payment.collect", "billing.receipt.issue"]'::jsonb, NULL::jsonb, '["agenda.appointment.view", "agenda.appointment.view.patient_name", "agenda.appointment.view.insurance", "agenda.appointment.view.price", "patients.search.exact", "patients.profile.view_basic", "patients.coverage.view", "billing.invoice.view", "billing.payment.collect", "billing.receipt.issue", "billing.receipt.void", "billing.payment.refund", "billing.discount.apply", "billing.cashbox.close", "reports.billing.view", "reports.billing.export"]'::jsonb, '6b070aec-a5af-52bc-8462-55be0d26298a', 2, now(), now(), 1),
  ('8c162d64-2b36-57b4-94c7-c034d6c3b26c', NULL, 'CALL_CENTER', 'Central telefónica', '["agenda.appointment.view", "agenda.appointment.view.patient_name", "agenda.appointment.create", "agenda.appointment.reschedule", "agenda.appointment.cancel", "patients.search.exact", "patients.profile.view_basic"]'::jsonb, NULL::jsonb, '["agenda.appointment.view", "agenda.appointment.view.patient_name", "agenda.appointment.view.patient_phone", "agenda.appointment.view.insurance", "agenda.appointment.view.price", "agenda.appointment.create", "agenda.appointment.reschedule", "agenda.appointment.cancel", "agenda.appointment.confirm", "agenda.appointment.no_show", "agenda.waitlist.manage", "agenda.reminder.send", "patients.search.exact", "patients.profile.view_basic", "patients.profile.view.phone_full", "patients.coverage.view", "patients.profile.register", "patients.guardian.record", "patients.profile.edit_contact", "messages.inbox.view", "messages.conversation.reply_on_behalf", "messages.conversation.assign", "messages.conversation.resolve", "messages.note.create_internal", "messages.template.use", "reports.agenda.view"]'::jsonb, '6b070aec-a5af-52bc-8462-55be0d26298a', 2, now(), now(), 1),
  ('ce7f96dd-6f85-5121-a4ca-f5b4877f7267', NULL, 'ORG_MANAGEMENT', 'Gestión de la organización', '["agenda.appointment.view", "agenda.appointment.view.patient_name", "agenda.appointment.create", "agenda.appointment.reschedule", "agenda.appointment.cancel", "agenda.appointment.confirm", "agenda.appointment.check_in", "agenda.appointment.walk_in", "agenda.waitlist.manage", "agenda.reminder.send", "agenda.block.create", "agenda.block.remove", "agenda.hours.edit", "patients.search.exact", "patients.profile.view_basic", "patients.profile.register", "patients.guardian.record", "reports.agenda.view", "team.members.view", "audit.activity.view_team", "audit.decisions.explain"]'::jsonb, NULL::jsonb, '["agenda.appointment.view", "agenda.appointment.view.patient_name", "agenda.appointment.view.patient_phone", "agenda.appointment.view.patient_document", "agenda.appointment.view.reason", "agenda.appointment.view.insurance", "agenda.appointment.view.price", "agenda.appointment.create", "agenda.appointment.create.overbook", "agenda.appointment.reschedule", "agenda.appointment.cancel", "agenda.appointment.confirm", "agenda.appointment.check_in", "agenda.appointment.no_show", "agenda.appointment.walk_in", "agenda.waitlist.manage", "agenda.reminder.send", "agenda.block.create", "agenda.block.remove", "agenda.hours.edit", "patients.search.exact", "patients.profile.view_basic", "patients.profile.view.phone_full", "patients.profile.view.document_full", "patients.coverage.view", "patients.profile.register", "patients.guardian.record", "patients.profile.edit_contact", "patients.profile.edit_verified", "patients.profile.merge_request", "patients.clinical.request_temporary_access", "messages.inbox.view", "messages.conversation.reply_on_behalf", "messages.conversation.assign", "messages.conversation.resolve", "messages.note.create_internal", "messages.template.use", "messages.template.manage", "messages.attachment.send", "messages.broadcast.send", "billing.invoice.view", "billing.payment.collect", "billing.receipt.issue", "billing.receipt.void", "billing.payment.refund", "billing.discount.apply", "billing.cashbox.close", "reports.agenda.view", "reports.agenda.export", "reports.billing.view", "reports.billing.export", "team.members.view", "team.invitations.create", "team.requests.decide", "team.grants.assign", "team.grants.revoke", "team.engagement.recertify", "team.engagement.suspend", "team.engagement.reactivate", "team.engagement.end", "team.handover.execute", "team.campaigns.review", "team.campaigns.manage", "team.sod.exception.request", "audit.activity.view_team", "audit.activity.view_org", "audit.activity.export", "audit.decisions.explain", "audit.reports.governance.view"]'::jsonb, '6b070aec-a5af-52bc-8462-55be0d26298a', 2, now(), now(), 1)
ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name, default_actions_json = EXCLUDED.default_actions_json,
    default_conditions_json = EXCLUDED.default_conditions_json, ceiling_actions_json = EXCLUDED.ceiling_actions_json, updated_at = now();
UPDATE delegated_access.role_templates v1
   SET status_concept_id = 'f2889c99-ac92-52a0-94dc-db6fed4edad8', updated_at = now()
 WHERE v1.tenant_id IS NULL AND v1.version_number = 1 AND v1.status_concept_id = '6b070aec-a5af-52bc-8462-55be0d26298a'
   AND v1.code IN ('SECRETARY', 'MEDICAL_ASSISTANT', 'NURSING', 'FRONT_DESK', 'BILLING_CASHIER', 'CALL_CENTER', 'ORG_MANAGEMENT')
   AND EXISTS (SELECT 1 FROM delegated_access.role_templates v2 WHERE v2.tenant_id IS NULL AND v2.code = v1.code AND v2.version_number = 2);

-- ---- 7b. vinculos existentes: la compuerta de ingreso (D-03) no los corta ----
-- D-03: la compuerta de ingreso solo rige para vinculos NUEVOS; los que ya existian quedan como COMPLETOS. La API deja pasar un vinculo con
-- `onboarding_completed_at` (y, sin ajustes de la organizacion, `onboardingRequired` vale true SIN fecha de corte): sin este UPDATE, la
-- secretaria o el call center de una organizacion ya en marcha quedarian bloqueados con ONBOARDING_INCOMPLETE al instalar este parche.
-- Idempotente y seguro de re-ejecutar: solo toca vinculos SIN fecha de incorporacion y SIN ningun caso de ingreso (JOINER) en
-- `lifecycle_cases`; un vinculo nuevo en curso (con su caso abierto o cancelado) nunca se completa de rebote. Sella con `created_at`
-- (la fecha en que el vinculo ya existia). Corre con el contexto de sistema de la transaccion (RLS FORCE no oculta filas al dueño) y lo devuelve.
DO $legacy_onboarding$
DECLARE
    v_prev text := COALESCE(current_setting('app.system_context', true), '');
    v_n integer;
BEGIN
    PERFORM set_config('app.system_context', 'true', true);
    UPDATE delegated_access.organization_user_assignments a
       SET onboarding_completed_at = a.created_at
     WHERE a.onboarding_completed_at IS NULL
       AND NOT EXISTS (SELECT 1 FROM delegated_access.lifecycle_cases lc
                        WHERE lc.organization_user_assignment_id = a.id
                          AND lc.kind_concept_id = 'c2a9a59d-c88c-5e87-9065-1e0e068c479d');   -- delegated_access:LIFECYCLE_JOINER
    GET DIAGNOSTICS v_n = ROW_COUNT;
    PERFORM set_config('app.system_context', v_prev, true);
    RAISE NOTICE 'v4278: % vinculos existentes marcados como incorporacion completa (onboarding_completed_at = created_at)', v_n;
END
$legacy_onboarding$;

-- ---- 8. funciones y disparadores operativos (no salen de ningun .puml) ----
--
-- Mismo estilo que el v4275 (seccion 6): TODAS las funciones fijan `SET search_path = pg_catalog, pg_temp`, se crean con
-- `REVOKE ALL ... FROM PUBLIC`, no son SECURITY DEFINER y los errores usan SQLSTATE estables:
--   23514 check_violation        padre de otro tenant, revisor = titular del vinculo, regla de la organizacion que afloja a la de plataforma
--   23503 foreign_key_violation  padre inexistente (o que el RLS oculta): falla cerrado
--
-- Si se vuelve a ejecutar el parche v4275 DESPUES de este (p. ej. por un indice unico con duplicados), hay que volver a ejecutar este:
-- el v4275 restituye las versiones anteriores de refresh_effective_support_access y support_tenant_consistency.
--
-- refresh_effective_support_access(p_tenant_id): igual que en el v4275 y, ademas, SOLO materializa concesiones con efecto ALLOW
-- y acciones vigentes (superseded_at IS NULL). Un DENY NO es un permiso: si se materializara, un «no» se leeria como un «si»
-- (H20). El motor de la API (EffectiveSupportAccessService) aplica la misma exclusion en el MISMO despliegue.
CREATE OR REPLACE FUNCTION "delegated_access"."refresh_effective_support_access"(p_tenant_id uuid DEFAULT NULL)
RETURNS integer
LANGUAGE plpgsql
SET search_path = pg_catalog, pg_temp
AS $fn$
DECLARE
    v_now timestamptz := now();
    v_rows integer;
    v_system boolean := COALESCE(current_setting('app.system_context', true), '') = 'true';
    v_ctx text := COALESCE(NULLIF(current_setting('app.current_tenant_id', true), ''), '');
BEGIN
    IF NOT v_system THEN
        IF p_tenant_id IS NULL AND NOT COALESCE(
               (SELECT r.rolsuper OR r.rolbypassrls FROM pg_catalog.pg_roles r WHERE r.rolname = current_user), false) THEN
            RAISE EXCEPTION 'refresh_effective_support_access(NULL) recalcula todas las organizaciones: exige app.system_context = true'
                USING ERRCODE = 'insufficient_privilege';
        END IF;
        IF p_tenant_id IS NOT NULL AND v_ctx <> '' AND v_ctx <> p_tenant_id::text THEN
            RAISE EXCEPTION 'refresh_effective_support_access: el contexto es de otra organizacion'
                USING ERRCODE = 'insufficient_privilege';
        END IF;
    END IF;

    DELETE FROM "delegated_access"."effective_support_access" e
     WHERE p_tenant_id IS NULL OR e."tenant_id" = p_tenant_id;

    INSERT INTO "delegated_access"."effective_support_access"
        ("id", "user_id", "tenant_id", "practitioner_role_assignment_id", "healthcare_service_id",
         "care_space_id", "permission_code", "grant_id", "refreshed_at")
    WITH live AS (
        SELECT g."id" AS grant_id, g."target_kind_concept_id" AS kind,
               g."expansion_mode_concept_id" AS expansion, g."fixed_snapshot_json" AS snapshot,
               g."practitioner_role_assignment_id" AS pra, g."healthcare_service_id" AS svc,
               g."care_space_id" AS space, g."practice_site_id" AS site,
               tm."user_id", tm."tenant_id"
          FROM "delegated_access"."support_scope_grants" g
          JOIN "delegated_access"."organization_user_assignments" a ON a."id" = g."organization_user_assignment_id"
          JOIN "directory"."tenant_memberships" tm ON tm."id" = a."tenant_membership_id"
         WHERE g."status_concept_id" = 'ccfbc54f-4744-53db-ab1f-abe1af31f784'
           AND g."effect_concept_id" = '6905e0db-1650-5d49-adca-8b2688ac049c'   -- v4.2.78: un DENY NUNCA se materializa como permiso
           AND g."tenant_id" = tm."tenant_id"
           AND a."status_concept_id" = '38a1d301-f40d-5b17-a695-5e6d605f8b19'
           AND (g."valid_from" IS NULL OR g."valid_from" <= v_now)
           AND (g."valid_to" IS NULL OR g."valid_to" > v_now)
           AND (a."valid_from" IS NULL OR a."valid_from" <= v_now)
           AND (a."valid_to" IS NULL OR a."valid_to" > v_now)
           AND (a."next_recertification_at" IS NULL OR a."next_recertification_at" + interval '15 days' > v_now)
           AND tm."status_concept_id" = '13ca1b46-61d5-5c25-9d49-8247bcd7769c'
           AND tm."start_date" <= v_now
           AND (tm."end_date" IS NULL OR tm."end_date" > v_now)
           AND (p_tenant_id IS NULL OR tm."tenant_id" = p_tenant_id)
    ),
    -- Espacios dentro de la ubicacion de cada concesion que la usa.
    loc AS (
        SELECT l.grant_id, s."id" AS space_id
          FROM live l
          LEFT JOIN "practice"."care_spaces" root ON root."id" = l.space
          JOIN "practice"."care_spaces" s
            ON (l.space IS NOT NULL AND (s."id" = l.space
                 OR (root."location_path" IS NOT NULL AND s."location_path" LIKE root."location_path" || '%')))
            OR (l.site IS NOT NULL AND s."practice_site_id" = l.site)
         WHERE l.expansion <> '4f47115f-54ad-564f-bcd4-f06a0a0c13cd'
           AND l.kind IN ('10510d38-c6cf-5243-9327-5cefc6c3aee5', '2ed23be8-884f-5e75-bd63-a1ff92f42e89', 'cf017e3e-4c7f-5e2f-a7ca-2f2078eb89b3')
    ),
    dims AS (
        -- DYNAMIC sin ubicacion
        SELECT l.grant_id, l.user_id, l.tenant_id,
               CASE WHEN l.kind IN ('785d1671-5754-58d3-b1a3-e3cd467b82b7', '19ff6b5b-b998-54bb-af93-573b96764a6c') THEN l.pra END AS pra,
               CASE WHEN l.kind IN ('953e4408-5e19-521b-a25a-3d062d788911', '19ff6b5b-b998-54bb-af93-573b96764a6c') THEN l.svc END AS svc,
               NULL::uuid AS space
          FROM live l
         WHERE l.expansion <> '4f47115f-54ad-564f-bcd4-f06a0a0c13cd'
           AND l.kind NOT IN ('10510d38-c6cf-5243-9327-5cefc6c3aee5', '2ed23be8-884f-5e75-bd63-a1ff92f42e89', 'cf017e3e-4c7f-5e2f-a7ca-2f2078eb89b3')
        UNION ALL
        -- DYNAMIC con ubicacion: una fila por espacio
        SELECT l.grant_id, l.user_id, l.tenant_id,
               CASE WHEN l.kind = '2ed23be8-884f-5e75-bd63-a1ff92f42e89' THEN l.pra END,
               CASE WHEN l.kind = 'cf017e3e-4c7f-5e2f-a7ca-2f2078eb89b3' THEN l.svc END,
               loc.space_id
          FROM live l JOIN loc ON loc.grant_id = l.grant_id
        UNION ALL
        -- FIXED: las filas congeladas
        SELECT l.grant_id, l.user_id, l.tenant_id,
               NULLIF(r ->> 'practitionerRoleAssignmentId', '')::uuid,
               NULLIF(r ->> 'healthcareServiceId', '')::uuid,
               NULLIF(r ->> 'careSpaceId', '')::uuid
          FROM live l
          CROSS JOIN LATERAL jsonb_array_elements(COALESCE(l.snapshot -> 'rows', '[]'::jsonb)) r
         WHERE l.expansion = '4f47115f-54ad-564f-bcd4-f06a0a0c13cd'
    )
    SELECT gen_random_uuid(), d.user_id, d.tenant_id, d.pra, d.svc, d.space, p."code", d.grant_id, v_now
      FROM dims d
      JOIN "delegated_access"."support_grant_actions" sga ON sga."support_scope_grant_id" = d.grant_id
        AND sga."superseded_at" IS NULL   -- v4.2.78: las filas de alias reemplazadas por atomos se ignoran
      JOIN "authz"."permissions" p ON p."id" = sga."permission_id";

    GET DIAGNOSTICS v_rows = ROW_COUNT;
    RETURN v_rows;
END
$fn$;

COMMENT ON FUNCTION "delegated_access"."support_access_allowed"(uuid, uuid, varchar, uuid, uuid, uuid) IS
    'Referencia gruesa de SupportAccessPolicy: ignora condiciones, SoD, DENY por regla de organizacion y alias. La verdad es el dominio de la API.';

-- integrity.support_tenant_consistency(): el v4275 la creo para 7 tablas; v4.2.78 la extiende a las tablas de gobierno con tenant_id
--   access_review_items = campana, vinculo y permiso revisado · handover_items = caso de ciclo de vida
--   sod_exceptions      = vinculo, solicitud de cuatro ojos y regla (la de plataforma, tenant NULL, vale)
--   lifecycle_cases / four_eyes_requests / access_anomalies = vinculo (si lo traen) · grant_usage_stats = permiso
--   support_scope_grants.source_role_template_id = plantilla de plataforma (NULL) o de la misma organizacion
-- patient_restriction_flags no tiene padre con tenant (el paciente no pertenece a una organizacion): su ancla es la propia fila.
CREATE OR REPLACE FUNCTION "integrity"."support_tenant_consistency"()
RETURNS trigger
LANGUAGE plpgsql
SET search_path = pg_catalog, pg_temp
AS $fn$
DECLARE
    n jsonb := to_jsonb(NEW);
    v_tenant uuid := (to_jsonb(NEW) ->> 'tenant_id')::uuid;
    v_conv uuid;
    v_parent uuid;
    v_found boolean;
    r record;
BEGIN
    FOR r IN
        SELECT 'el vinculo (organization_user_assignment_id)' AS what,
               (SELECT tm."tenant_id"
                  FROM "delegated_access"."organization_user_assignments" a
                  JOIN "directory"."tenant_memberships" tm ON tm."id" = a."tenant_membership_id"
                 WHERE a."id" = (n ->> 'organization_user_assignment_id')::uuid) AS parent_tenant
         WHERE TG_TABLE_NAME = 'support_scope_grants'
            OR (TG_TABLE_NAME IN ('access_review_items', 'sod_exceptions', 'lifecycle_cases', 'four_eyes_requests', 'access_anomalies')
                AND n ->> 'organization_user_assignment_id' IS NOT NULL)
        UNION ALL
        SELECT 'el doctor (practitioner_role_assignment_id)',
               (SELECT p."tenant_id"
                  FROM "practice"."practitioner_role_assignments" pra
                  JOIN "practice"."practices" p ON p."id" = pra."practice_id"
                 WHERE pra."id" = (n ->> 'practitioner_role_assignment_id')::uuid)
         WHERE TG_TABLE_NAME IN ('support_scope_grants', 'practitioner_location_assignments')
           AND n ->> 'practitioner_role_assignment_id' IS NOT NULL
        UNION ALL
        SELECT 'el servicio (healthcare_service_id)',
               (SELECT p."tenant_id"
                  FROM "practice"."healthcare_services" s
                  JOIN "practice"."practices" p ON p."id" = s."practice_id"
                 WHERE s."id" = (n ->> 'healthcare_service_id')::uuid)
         WHERE TG_TABLE_NAME = 'support_scope_grants'
           AND n ->> 'healthcare_service_id' IS NOT NULL
        UNION ALL
        SELECT 'el espacio (care_space_id)',
               (SELECT p."tenant_id"
                  FROM "practice"."care_spaces" c
                  JOIN "practice"."practice_sites" ps ON ps."id" = c."practice_site_id"
                  JOIN "practice"."practices" p ON p."id" = ps."practice_id"
                 WHERE c."id" = (n ->> 'care_space_id')::uuid)
         WHERE TG_TABLE_NAME IN ('support_scope_grants', 'practitioner_location_assignments')
           AND n ->> 'care_space_id' IS NOT NULL
        UNION ALL
        SELECT 'la sede (practice_site_id)',
               (SELECT p."tenant_id"
                  FROM "practice"."practice_sites" ps
                  JOIN "practice"."practices" p ON p."id" = ps."practice_id"
                 WHERE ps."id" = (n ->> 'practice_site_id')::uuid)
         WHERE TG_TABLE_NAME = 'support_scope_grants'
           AND n ->> 'practice_site_id' IS NOT NULL
        UNION ALL
        SELECT 'el permiso (support_scope_grant_id)',
               (SELECT g."tenant_id" FROM "delegated_access"."support_scope_grants" g
                 WHERE g."id" = (n ->> 'support_scope_grant_id')::uuid)
         WHERE TG_TABLE_NAME IN ('support_grant_actions', 'grant_usage_stats')
        UNION ALL
        SELECT 'la solicitud (engagement_request_id)',
               (SELECT q."tenant_id" FROM "delegated_access"."engagement_requests" q
                 WHERE q."id" = (n ->> 'engagement_request_id')::uuid)
         WHERE TG_TABLE_NAME = 'engagement_request_items'
        UNION ALL
        SELECT 'la invitacion (affiliation_invitation_id)',
               (SELECT i."tenant_id" FROM "directory"."affiliation_invitations" i
                 WHERE i."id" = (n ->> 'affiliation_invitation_id')::uuid)
         WHERE TG_TABLE_NAME = 'affiliation_invitation_uses'
        UNION ALL
        SELECT 'la campana (access_review_campaign_id)',
               (SELECT c."tenant_id" FROM "delegated_access"."access_review_campaigns" c
                 WHERE c."id" = (n ->> 'access_review_campaign_id')::uuid)
         WHERE TG_TABLE_NAME = 'access_review_items'
        UNION ALL
        SELECT 'el permiso revisado (support_scope_grant_id)',
               (SELECT g."tenant_id" FROM "delegated_access"."support_scope_grants" g
                 WHERE g."id" = (n ->> 'support_scope_grant_id')::uuid)
         WHERE TG_TABLE_NAME = 'access_review_items'
           AND n ->> 'support_scope_grant_id' IS NOT NULL
        UNION ALL
        SELECT 'el caso de ciclo de vida (lifecycle_case_id)',
               (SELECT l."tenant_id" FROM "delegated_access"."lifecycle_cases" l
                 WHERE l."id" = (n ->> 'lifecycle_case_id')::uuid)
         WHERE TG_TABLE_NAME = 'handover_items'
        UNION ALL
        SELECT 'la solicitud de cuatro ojos (four_eyes_request_id)',
               (SELECT f."tenant_id" FROM "delegated_access"."four_eyes_requests" f
                 WHERE f."id" = (n ->> 'four_eyes_request_id')::uuid)
         WHERE TG_TABLE_NAME = 'sod_exceptions'
    LOOP
        IF r.parent_tenant IS NULL THEN
            RAISE EXCEPTION '%.%: % no existe o no es de la organizacion del contexto',
                TG_TABLE_SCHEMA, TG_TABLE_NAME, r.what
                USING ERRCODE = 'foreign_key_violation';
        ELSIF r.parent_tenant IS DISTINCT FROM v_tenant THEN
            RAISE EXCEPTION '%.%: tenant_id (%) no coincide con %: su tenant es %',
                TG_TABLE_SCHEMA, TG_TABLE_NAME, v_tenant, r.what, r.parent_tenant
                USING ERRCODE = 'check_violation';
        END IF;
    END LOOP;

    -- v4.2.78: padres que pueden ser de PLATAFORMA (tenant NULL): la regla SoD de una excepcion y la plantilla de origen de
    -- una concesion. Inexistente (o que el RLS oculta) = falla cerrado; de otra organizacion = check_violation.
    IF (TG_TABLE_NAME = 'sod_exceptions') OR (TG_TABLE_NAME = 'support_scope_grants' AND n ->> 'source_role_template_id' IS NOT NULL) THEN
        IF TG_TABLE_NAME = 'sod_exceptions' THEN
            SELECT true, s."tenant_id" INTO v_found, v_parent FROM "delegated_access"."sod_rules" s
             WHERE s."id" = (n ->> 'sod_rule_id')::uuid;
        ELSE
            SELECT true, t."tenant_id" INTO v_found, v_parent FROM "delegated_access"."role_templates" t
             WHERE t."id" = (n ->> 'source_role_template_id')::uuid;
        END IF;
        IF v_found IS NOT TRUE THEN
            RAISE EXCEPTION '%.%: % no existe o no es de la organizacion del contexto', TG_TABLE_SCHEMA, TG_TABLE_NAME,
                CASE WHEN TG_TABLE_NAME = 'sod_exceptions' THEN 'la regla (sod_rule_id)' ELSE 'la plantilla (source_role_template_id)' END
                USING ERRCODE = 'foreign_key_violation';
        ELSIF v_parent IS NOT NULL AND v_parent IS DISTINCT FROM v_tenant THEN
            RAISE EXCEPTION '%.%: tenant_id (%) no coincide con %: su tenant es %', TG_TABLE_SCHEMA, TG_TABLE_NAME, v_tenant,
                CASE WHEN TG_TABLE_NAME = 'sod_exceptions' THEN 'la regla (sod_rule_id)' ELSE 'la plantilla (source_role_template_id)' END, v_parent
                USING ERRCODE = 'check_violation';
        END IF;
    END IF;

    IF TG_TABLE_NAME IN ('conversation_assignments', 'conversation_internal_notes') THEN
        SELECT c."tenant_id" INTO v_conv
          FROM "community"."conversations" c
         WHERE c."id" = (n ->> 'conversation_id')::uuid;
        IF v_conv IS NOT NULL AND v_conv IS DISTINCT FROM v_tenant THEN
            RAISE EXCEPTION '%.%: tenant_id (%) no coincide con la conversacion: su tenant es %',
                TG_TABLE_SCHEMA, TG_TABLE_NAME, v_tenant, v_conv
                USING ERRCODE = 'check_violation';
        END IF;
    END IF;
    RETURN NEW;
END
$fn$;

DROP TRIGGER IF EXISTS trg_support_tenant_consistency ON "delegated_access"."support_scope_grants";
CREATE TRIGGER trg_support_tenant_consistency
    BEFORE INSERT OR UPDATE OF "tenant_id", "organization_user_assignment_id", "practitioner_role_assignment_id",
        "healthcare_service_id", "care_space_id", "practice_site_id", "source_role_template_id"
    ON "delegated_access"."support_scope_grants"
    FOR EACH ROW EXECUTE FUNCTION "integrity"."support_tenant_consistency"();

DROP TRIGGER IF EXISTS trg_support_tenant_consistency ON "delegated_access"."support_grant_actions";
CREATE TRIGGER trg_support_tenant_consistency
    BEFORE INSERT OR UPDATE OF "tenant_id", "support_scope_grant_id"
    ON "delegated_access"."support_grant_actions"
    FOR EACH ROW EXECUTE FUNCTION "integrity"."support_tenant_consistency"();

DROP TRIGGER IF EXISTS trg_support_tenant_consistency ON "delegated_access"."access_review_items";
CREATE TRIGGER trg_support_tenant_consistency
    BEFORE INSERT OR UPDATE OF "tenant_id", "access_review_campaign_id", "organization_user_assignment_id", "support_scope_grant_id"
    ON "delegated_access"."access_review_items"
    FOR EACH ROW EXECUTE FUNCTION "integrity"."support_tenant_consistency"();

DROP TRIGGER IF EXISTS trg_support_tenant_consistency ON "delegated_access"."handover_items";
CREATE TRIGGER trg_support_tenant_consistency
    BEFORE INSERT OR UPDATE OF "tenant_id", "lifecycle_case_id"
    ON "delegated_access"."handover_items"
    FOR EACH ROW EXECUTE FUNCTION "integrity"."support_tenant_consistency"();

DROP TRIGGER IF EXISTS trg_support_tenant_consistency ON "delegated_access"."sod_exceptions";
CREATE TRIGGER trg_support_tenant_consistency
    BEFORE INSERT OR UPDATE OF "tenant_id", "sod_rule_id", "organization_user_assignment_id", "four_eyes_request_id"
    ON "delegated_access"."sod_exceptions"
    FOR EACH ROW EXECUTE FUNCTION "integrity"."support_tenant_consistency"();

DROP TRIGGER IF EXISTS trg_support_tenant_consistency ON "delegated_access"."lifecycle_cases";
CREATE TRIGGER trg_support_tenant_consistency
    BEFORE INSERT OR UPDATE OF "tenant_id", "organization_user_assignment_id"
    ON "delegated_access"."lifecycle_cases"
    FOR EACH ROW EXECUTE FUNCTION "integrity"."support_tenant_consistency"();

DROP TRIGGER IF EXISTS trg_support_tenant_consistency ON "delegated_access"."four_eyes_requests";
CREATE TRIGGER trg_support_tenant_consistency
    BEFORE INSERT OR UPDATE OF "tenant_id", "organization_user_assignment_id"
    ON "delegated_access"."four_eyes_requests"
    FOR EACH ROW EXECUTE FUNCTION "integrity"."support_tenant_consistency"();

DROP TRIGGER IF EXISTS trg_support_tenant_consistency ON "delegated_access"."grant_usage_stats";
CREATE TRIGGER trg_support_tenant_consistency
    BEFORE INSERT OR UPDATE OF "tenant_id", "support_scope_grant_id"
    ON "delegated_access"."grant_usage_stats"
    FOR EACH ROW EXECUTE FUNCTION "integrity"."support_tenant_consistency"();

DROP TRIGGER IF EXISTS trg_support_tenant_consistency ON "delegated_access"."access_anomalies";
CREATE TRIGGER trg_support_tenant_consistency
    BEFORE INSERT OR UPDATE OF "tenant_id", "organization_user_assignment_id"
    ON "delegated_access"."access_anomalies"
    FOR EACH ROW EXECUTE FUNCTION "integrity"."support_tenant_consistency"();

-- integrity.access_review_reviewer_not_subject(): la persona revisada no puede ser quien revisa, quien recibe el escalamiento ni quien
-- decide su propio acceso (separacion de funciones de las campanas, SOD-GOV-02). El titular es el usuario de la membresia del vinculo.
CREATE OR REPLACE FUNCTION "integrity"."access_review_reviewer_not_subject"()
RETURNS trigger
LANGUAGE plpgsql
SET search_path = pg_catalog, pg_temp
AS $fn$
DECLARE
    v_subject uuid;
BEGIN
    SELECT tm."user_id" INTO v_subject
      FROM "delegated_access"."organization_user_assignments" a
      JOIN "directory"."tenant_memberships" tm ON tm."id" = a."tenant_membership_id"
     WHERE a."id" = NEW."organization_user_assignment_id";
    IF v_subject IS NOT NULL AND (NEW."reviewer_user_id" = v_subject OR NEW."escalated_to_user_id" = v_subject
                                  OR NEW."decided_by_user_id" = v_subject) THEN
        RAISE EXCEPTION 'delegated_access.access_review_items: la persona revisada (%) no puede ser revisora, destinataria del escalamiento ni decisora de su propio acceso',
            v_subject USING ERRCODE = 'check_violation';
    END IF;
    RETURN NEW;
END
$fn$;

DROP TRIGGER IF EXISTS trg_access_review_reviewer_not_subject ON "delegated_access"."access_review_items";
CREATE TRIGGER trg_access_review_reviewer_not_subject
    BEFORE INSERT OR UPDATE OF "organization_user_assignment_id", "reviewer_user_id", "escalated_to_user_id", "decided_by_user_id"
    ON "delegated_access"."access_review_items"
    FOR EACH ROW EXECUTE FUNCTION "integrity"."access_review_reviewer_not_subject"();

-- integrity.sod_rules_only_stricter(): una regla de la ORGANIZACION con base_rule_id endurece a la de PLATAFORMA, nunca la afloja:
--   accion no menos estricta (BLOQUEAR > EXIGIR APROBACION > ADVERTIR), sin quitar is_hard y sin alargar los dias de excepcion
--   (dias NULL = sin tope: con base acotada es aflojar); los conjuntos de atomos A y B contienen los de la base (@>) y el
--   alcance es el mismo o mas amplio (PERSONA > PERSONA CON COBERTURA SOLAPADA > TRANSACCION). Revision de seguridad v4.2.79.
-- La base debe ser de plataforma (tenant NULL). Los literales son los ids de delegated_access:SOD_ACTION_* (uuid5 del backend).
CREATE OR REPLACE FUNCTION "integrity"."sod_rules_only_stricter"()
RETURNS trigger
LANGUAGE plpgsql
SET search_path = pg_catalog, pg_temp
AS $fn$
DECLARE
    b record;
    rank_new integer;
    rank_base integer;
    scope_new integer;
    scope_base integer;
BEGIN
    IF NEW."base_rule_id" IS NULL THEN
        RETURN NEW;
    END IF;
    SELECT s."tenant_id", s."action_concept_id", s."is_hard", s."max_exception_days",
           s."atoms_a_json", s."atoms_b_json", s."scope_concept_id" INTO b
      FROM "delegated_access"."sod_rules" s WHERE s."id" = NEW."base_rule_id";
    IF NOT FOUND THEN
        RAISE EXCEPTION 'delegated_access.sod_rules: la regla base (base_rule_id) no existe o no es visible'
            USING ERRCODE = 'foreign_key_violation';
    END IF;
    IF b."tenant_id" IS NOT NULL THEN
        RAISE EXCEPTION 'delegated_access.sod_rules: la regla base debe ser de plataforma (tenant_id NULL)'
            USING ERRCODE = 'check_violation';
    END IF;
    rank_new := CASE NEW."action_concept_id" WHEN 'd317a334-2e99-5361-836c-674cbeec5d26' THEN 3 WHEN '117ffae4-a53b-5f5a-a927-d625ae57ad67' THEN 2 WHEN '156a7df4-b47c-52d3-9646-9f201757db51' THEN 1 ELSE 0 END;
    rank_base := CASE b."action_concept_id" WHEN 'd317a334-2e99-5361-836c-674cbeec5d26' THEN 3 WHEN '117ffae4-a53b-5f5a-a927-d625ae57ad67' THEN 2 WHEN '156a7df4-b47c-52d3-9646-9f201757db51' THEN 1 ELSE 0 END;
    IF rank_new < rank_base THEN
        RAISE EXCEPTION 'delegated_access.sod_rules: una regla de la organizacion no puede ser menos estricta que la de plataforma que endurece'
            USING ERRCODE = 'check_violation';
    END IF;
    IF b."is_hard" AND NOT NEW."is_hard" THEN
        RAISE EXCEPTION 'delegated_access.sod_rules: una regla dura de plataforma no puede dejar de serlo'
            USING ERRCODE = 'check_violation';
    END IF;
    IF b."max_exception_days" IS NOT NULL
       AND (NEW."max_exception_days" IS NULL OR NEW."max_exception_days" > b."max_exception_days") THEN
        RAISE EXCEPTION 'delegated_access.sod_rules: la excepcion de la organizacion no puede durar mas que la de plataforma (% dias)', b."max_exception_days"
            USING ERRCODE = 'check_violation';
    END IF;
    IF NOT (NEW."atoms_a_json" @> b."atoms_a_json" AND NEW."atoms_b_json" @> b."atoms_b_json") THEN
        RAISE EXCEPTION 'delegated_access.sod_rules: una regla de la organizacion no puede quitar atomos de la regla de plataforma que endurece'
            USING ERRCODE = 'check_violation';
    END IF;
    -- alcance: delegated_access:SOD_SCOPE_PERSON (3) > SOD_SCOPE_PERSON_OVERLAP (2) > SOD_SCOPE_TRANSACTION (1); otro valor solo si es el mismo
    scope_new := CASE NEW."scope_concept_id" WHEN '0fb8d904-8d4c-5ff5-972e-b0968cadc699' THEN 3 WHEN '5959b7b1-6a78-5a16-a856-8bd7b4395a0a' THEN 2 WHEN '926b5260-3468-5925-9aae-6ebbd4942fea' THEN 1 ELSE 0 END;
    scope_base := CASE b."scope_concept_id" WHEN '0fb8d904-8d4c-5ff5-972e-b0968cadc699' THEN 3 WHEN '5959b7b1-6a78-5a16-a856-8bd7b4395a0a' THEN 2 WHEN '926b5260-3468-5925-9aae-6ebbd4942fea' THEN 1 ELSE 0 END;
    IF NEW."scope_concept_id" IS DISTINCT FROM b."scope_concept_id"
       AND (scope_new = 0 OR scope_base = 0 OR scope_new < scope_base) THEN
        RAISE EXCEPTION 'delegated_access.sod_rules: una regla de la organizacion no puede tener un alcance mas estrecho que la de plataforma'
            USING ERRCODE = 'check_violation';
    END IF;
    RETURN NEW;
END
$fn$;

DROP TRIGGER IF EXISTS trg_sod_rules_only_stricter ON "delegated_access"."sod_rules";
CREATE TRIGGER trg_sod_rules_only_stricter
    BEFORE INSERT OR UPDATE OF "base_rule_id", "action_concept_id", "is_hard", "max_exception_days",
        "atoms_a_json", "atoms_b_json", "scope_concept_id"
    ON "delegated_access"."sod_rules"
    FOR EACH ROW EXECUTE FUNCTION "integrity"."sod_rules_only_stricter"();

-- Permisos de ejecucion: fuera de PUBLIC; solo el rol de la aplicacion (si la base ya lo tiene) ejecuta lo que llama directamente.
REVOKE ALL ON FUNCTION "delegated_access"."refresh_effective_support_access"(uuid) FROM PUBLIC;
REVOKE ALL ON FUNCTION "integrity"."support_tenant_consistency"() FROM PUBLIC;
REVOKE ALL ON FUNCTION "integrity"."access_review_reviewer_not_subject"() FROM PUBLIC;
REVOKE ALL ON FUNCTION "integrity"."sod_rules_only_stricter"() FROM PUBLIC;
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'mantra_app') THEN
        GRANT EXECUTE ON FUNCTION "delegated_access"."refresh_effective_support_access"(uuid) TO mantra_app;
    END IF;
END $$;

-- ---- 9. RLS (aislamiento por tenant) ----
--
-- Las 13 tablas del personal de apoyo (v4275) + las 11 de gobierno con tenant_id NOT NULL + sod_rules (tenant_id NULL = plataforma).
-- Mismo criterio que el v4275 (v4.2.79: SIEMPRE se crean, ya no solo si la base habia optado por RLS); `2026-08-05_tenant_rls.sql`
-- recorre toda tabla con `tenant_id uuid`, asi que volver a ejecutarlo despues de este parche las cubre igual. Las reglas SoD de
-- PLATAFORMA (tenant_id NULL) las lee todo tenant con la politica de solo lectura `global_catalog_read` (el parche v4251 tiene una
-- lista cerrada, por eso va aqui). access_decision_log: INSERT y SELECT del tenant; el UPDATE/DELETE los frena el disparador WORM.
DO $$
DECLARE
    r record;
BEGIN
    -- v4.2.79 (revision de seguridad A-B1): ya NO se omite en silencio. Antes, en una base sin ninguna politica `tenant_isolation`, este
    -- bloque solo avisaba (NOTICE) y las 25 tablas quedaban ABIERTAS entre organizaciones. Ahora las politicas se crean siempre (fallar
    -- cerrado); el resto del esquema sigue pidiendo 2026-08-05_tenant_rls.sql.
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'tenant_isolation') THEN
        RAISE WARNING 'Esta base no tiene RLS en el resto del esquema (sin politicas tenant_isolation previas): este parche lo activa en las 25 tablas del personal de apoyo y del gobierno; ejecute 2026-08-05_tenant_rls.sql para cubrir el resto';
    END IF;
    FOR r IN SELECT * FROM (VALUES
        ('iam', 'session_policies'), ('directory', 'affiliation_invitations'),
        ('directory', 'affiliation_invitation_uses'), ('practice', 'practitioner_location_assignments'),
        ('community', 'reply_templates'), ('community', 'conversation_assignments'),
        ('community', 'conversation_internal_notes'), ('delegated_access', 'role_templates'),
        ('delegated_access', 'support_scope_grants'), ('delegated_access', 'support_grant_actions'),
        ('delegated_access', 'engagement_requests'), ('delegated_access', 'engagement_request_items'),
        ('delegated_access', 'effective_support_access'), ('delegated_access', 'governance_rules'),
        ('delegated_access', 'sod_exceptions'), ('delegated_access', 'four_eyes_requests'),
        ('delegated_access', 'access_review_campaigns'), ('delegated_access', 'access_review_items'),
        ('delegated_access', 'lifecycle_cases'), ('delegated_access', 'handover_items'),
        ('delegated_access', 'patient_restriction_flags'), ('delegated_access', 'access_decision_log'),
        ('delegated_access', 'grant_usage_stats'), ('delegated_access', 'access_anomalies'),
        ('delegated_access', 'sod_rules')) v(s, t)
    LOOP
        EXECUTE format('ALTER TABLE %I.%I ENABLE ROW LEVEL SECURITY', r.s, r.t);
        EXECUTE format('ALTER TABLE %I.%I FORCE ROW LEVEL SECURITY', r.s, r.t);
        EXECUTE format('DROP POLICY IF EXISTS tenant_isolation ON %I.%I', r.s, r.t);
        EXECUTE format($pol$
        CREATE POLICY tenant_isolation ON %I.%I
          USING (
            tenant_id = NULLIF(current_setting('app.current_tenant_id', true), '')::uuid
            OR current_setting('app.system_context', true) = 'true'
          )
          WITH CHECK (
            tenant_id = NULLIF(current_setting('app.current_tenant_id', true), '')::uuid
            OR current_setting('app.system_context', true) = 'true'
          )
        $pol$, r.s, r.t);
        IF EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'mantra_app') THEN
            -- v4.2.79 (A-B2): la bitacora de decisiones es append-only: la aplicacion solo lee e inserta.
            IF r.t = 'access_decision_log' THEN
                EXECUTE format('GRANT SELECT, INSERT ON %I.%I TO mantra_app', r.s, r.t);
            ELSE
                EXECUTE format('GRANT SELECT, INSERT, UPDATE, DELETE ON %I.%I TO mantra_app', r.s, r.t);
            END IF;
        END IF;
    END LOOP;
END $$;

DROP POLICY IF EXISTS global_catalog_read ON "delegated_access"."role_templates";
CREATE POLICY global_catalog_read ON "delegated_access"."role_templates" FOR SELECT USING (tenant_id IS NULL);
DROP POLICY IF EXISTS global_catalog_read ON "delegated_access"."sod_rules";
CREATE POLICY global_catalog_read ON "delegated_access"."sod_rules" FOR SELECT USING (tenant_id IS NULL);

-- ---- 10. verificacion final ----
DO $$
DECLARE
    v_atoms integer; v_cats integer; v_sod integer; v_tables integer; v_pol integer;
BEGIN
    SELECT count(*) INTO v_atoms FROM authz.permissions WHERE code ~ '^[a-z_]+(\.[a-z_]+){2,3}$';
    SELECT count(*) INTO v_cats FROM authz.permission_categories WHERE code LIKE 'SUPPORT\_%';
    SELECT count(*) INTO v_sod FROM delegated_access.sod_rules WHERE tenant_id IS NULL;
    SELECT count(*) INTO v_tables FROM information_schema.tables WHERE table_schema = 'delegated_access'
       AND table_name IN ('governance_rules', 'sod_rules', 'sod_exceptions', 'four_eyes_requests', 'access_review_campaigns', 'access_review_items', 'lifecycle_cases', 'handover_items', 'patient_restriction_flags', 'access_decision_log', 'grant_usage_stats', 'access_anomalies');
    SELECT count(*) INTO v_pol FROM pg_policies WHERE schemaname = 'delegated_access' AND policyname = 'tenant_isolation'
       AND tablename IN ('governance_rules', 'sod_rules', 'sod_exceptions', 'four_eyes_requests', 'access_review_campaigns', 'access_review_items', 'lifecycle_cases', 'handover_items', 'patient_restriction_flags', 'access_decision_log', 'grant_usage_stats', 'access_anomalies');
    RAISE NOTICE 'v4278: % atomos (73 esperados), % categorias (7), % reglas SoD de plataforma (11), % tablas nuevas (12), % con politica tenant_isolation (12)',
        v_atoms, v_cats, v_sod, v_tables, v_pol;
    -- v4.2.79 (A-B1): las politicas son obligatorias; si falta alguna el parche FALLA en vez de avisar.
    IF v_atoms <> 73 OR v_cats <> 7 OR v_sod <> 11 OR v_tables <> 12 OR v_pol <> 12 THEN
        RAISE EXCEPTION 'v4278: conteos inesperados (atomos %, categorias %, SoD %, tablas %, politicas tenant_isolation %)', v_atoms, v_cats, v_sod, v_tables, v_pol;
    END IF;
END $$;

COMMIT;
