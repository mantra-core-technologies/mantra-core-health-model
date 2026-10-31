-- Verificación del GOBIERNO DE ACCESOS v4.2.78 (permisos de ultra granularidad + gobierno de usuarios).
--
-- Requiere: el esquema (apply_all + apply_deferred), los parches SQL/patches/2026-10-31_v4275_personal_apoyo.sql y
-- SQL/patches/2026-10-31_v4278_gobierno_de_accesos.sql, y los datos de 04-hospital-piloto.sql (corrido con -v demo_accounts=1).
-- Las comprobaciones G9 del piloto extendido solo corren si 07-gobierno-hospital-piloto.sql también se aplicó.
-- Cada comprobación INTENTA la violación y exige que la base la rechace con el SQLSTATE esperado (o que lo legítimo pase).
-- Falla con una excepción «G-xx FALLÓ» en la primera que no. Todo corre dentro de una transacción que se DESHACE (ROLLBACK).
--
--   G1  catálogo: 73 átomos en 7 categorías con los conteos del diseño; los 15 códigos antiguos siguen y quedan marcados
--   G2  11 reglas SoD de plataforma, plantillas v2 con su techo, rol de sistema SUPPORT_STAFF
--   G3  las 12 tablas nuevas existen con RLS por tenant (si la base ya usa RLS)
--   G4  CHECK (23514): auto-aprobación del cuatro ojos, hash mal formado, excepción SoD a más de 180 días, condición con
--       schemaVersion distinto, comentario corto al revocar un ítem, ventana de anomalía invertida y demás reglas de forma
--   G5  disparadores (23514/23503): revisor = titular del vínculo, tenant distinto entre ítem y campaña, regla de la
--       organización que afloja a la de plataforma, plantilla de otra organización
--   G6  access_decision_log es WORM: rechaza UPDATE y DELETE (23001)
--   G7  refresh_effective_support_access NO materializa una concesión DENY ni una acción reemplazada (superseded)
--   G8  las funciones nuevas: search_path fijo, sin SECURITY DEFINER y sin EXECUTE para PUBLIC
--   G9  piloto extendido (07): personas, pacientes, citas, campaña, cuatro ojos, excepción SoD, uso y anomalías, y (G-9y1…4) las correcciones que el smoke
--       y el recorrido real de la API necesitan: tabla de perfiles de las agendas, A4 en N102, Nora posterior a la compuerta de ingreso y Ana con recertificación el 2026-11-23
--   G10 con RLS: mantra_app ve solo su organización en las tablas nuevas y no escribe en otra ni en la plataforma
--   G11 (v4.2.79, revisión de seguridad ronda 1): tenant_id + disparador + RLS en organization_user_assignments y practitioner_delegate_assignments (A-M1);
--       access_decision_log sin UPDATE/DELETE/TRUNCATE ni para mantra_app (A-B2); support_access_allowed respeta un DENY (A-B6). Requiere el parche v4279.
--
-- support_access_allowed sigue dando los 12 casos del contrato y los 17 negativos: corra 05-verifica-hospital-piloto.sql después.
--
-- Uso:  psql -v ON_ERROR_STOP=1 -d <base> -f salud-db/demo/08-verifica-gobierno.sql

BEGIN;

CREATE FUNCTION pg_temp.must_fail(p_label text, p_state text, p_sql text) RETURNS void LANGUAGE plpgsql AS $f$
BEGIN
    BEGIN
        EXECUTE p_sql;
    EXCEPTION WHEN OTHERS THEN
        IF SQLSTATE = p_state THEN RETURN; END IF;
        RAISE EXCEPTION 'G-% FALLÓ: se esperaba SQLSTATE % y llegó % (%)', p_label, p_state, SQLSTATE, SQLERRM;
    END;
    RAISE EXCEPTION 'G-% FALLÓ: la sentencia debía ser rechazada con SQLSTATE %', p_label, p_state;
END
$f$;

CREATE FUNCTION pg_temp.must_pass(p_label text, p_sql text) RETURNS void LANGUAGE plpgsql AS $f$
BEGIN
    EXECUTE p_sql;
EXCEPTION WHEN OTHERS THEN
    RAISE EXCEPTION 'G-% FALLÓ: la sentencia legítima fue rechazada (SQLSTATE %: %)', p_label, SQLSTATE, SQLERRM;
END
$f$;

-- Los SELECT pg_temp.must_* devuelven una fila vacía por comprobación: se descartan (los avisos siguen saliendo).
\o /dev/null

-- ---------------------------------------------------------------- G1 · catálogo de átomos
DO $g1$
DECLARE n integer; r record;
BEGIN
    SELECT count(*) INTO n FROM authz.permissions p WHERE p.code ~ '^[a-z_]+(\.[a-z_]+){2,3}$';
    IF n <> 73 THEN RAISE EXCEPTION 'G-1a FALLÓ: se esperaban 73 átomos y hay %', n; END IF;
    SELECT count(*) INTO n FROM authz.permission_categories WHERE code LIKE 'SUPPORT\_%';
    IF n <> 7 THEN RAISE EXCEPTION 'G-1b FALLÓ: se esperaban 7 categorías SUPPORT_* y hay %', n; END IF;
    FOR r IN SELECT * FROM (VALUES
        ('SUPPORT_AGENDA', 20), ('SUPPORT_PATIENTS', 11), ('SUPPORT_MESSAGING', 9), ('SUPPORT_BILLING', 7),
        ('SUPPORT_REPORTS', 4), ('SUPPORT_TEAM', 17), ('SUPPORT_AUDIT', 5)) v(cat, expected)
    LOOP
        SELECT count(*) INTO n FROM authz.permissions p JOIN authz.permission_categories c ON c.id = p.category_id
         WHERE c.code = r.cat AND p.code ~ '^[a-z_]+(\.[a-z_]+){2,3}$';
        IF n <> r.expected THEN RAISE EXCEPTION 'G-1c FALLÓ: la categoría % debía tener % átomos y tiene %', r.cat, r.expected, n; END IF;
    END LOOP;
    FOR r IN SELECT * FROM (VALUES
        ('authz:SENSITIVITY_LOW', 11), ('authz:SENSITIVITY_MEDIUM', 27), ('authz:SENSITIVITY_HIGH', 29), ('authz:SENSITIVITY_CRITICAL', 6)) v(code, expected)
    LOOP
        SELECT count(*) INTO n FROM authz.permissions p JOIN terminology.catalog_concepts c ON c.id = p.sensitivity_concept_id
         WHERE c.code = r.code AND p.code ~ '^[a-z_]+(\.[a-z_]+){2,3}$';
        IF n <> r.expected THEN RAISE EXCEPTION 'G-1d FALLÓ: sensibilidad % esperaba % y hay %', r.code, r.expected, n; END IF;
    END LOOP;
    SELECT count(*) INTO n FROM authz.permissions WHERE code ~ '^[a-z_]+(\.[a-z_]+){2,3}$' AND requires_reason;
    IF n <> 31 THEN RAISE EXCEPTION 'G-1e FALLÓ: con motivo se esperaban 31 y hay %', n; END IF;
    SELECT count(*) INTO n FROM authz.permissions WHERE code ~ '^[a-z_]+(\.[a-z_]+){2,3}$' AND requires_step_up;
    IF n <> 14 THEN RAISE EXCEPTION 'G-1f FALLÓ: con paso extra se esperaban 14 y hay %', n; END IF;
    SELECT count(*) INTO n FROM authz.permissions p JOIN terminology.catalog_concepts c ON c.id = p.approval_mode_concept_id
     WHERE c.code = 'authz:APPROVAL_DOCTOR' AND p.code ~ '^[a-z_]+(\.[a-z_]+){2,3}$';
    IF n <> 3 THEN RAISE EXCEPTION 'G-1g FALLÓ: con aprobación del doctor se esperaban 3 y hay %', n; END IF;
    SELECT count(*) INTO n FROM authz.permissions p JOIN terminology.catalog_concepts c ON c.id = p.approval_mode_concept_id
     WHERE c.code = 'authz:APPROVAL_SECOND_APPROVER' AND p.code ~ '^[a-z_]+(\.[a-z_]+){2,3}$';
    IF n <> 7 THEN RAISE EXCEPTION 'G-1h FALLÓ: con segundo aprobador se esperaban 7 y hay %', n; END IF;
    SELECT count(*) INTO n FROM authz.permissions WHERE code ~ '^[a-z_]+(\.[a-z_]+){2,3}$' AND is_field_level;
    IF n <> 8 THEN RAISE EXCEPTION 'G-1i FALLÓ: de campo se esperaban 8 y hay %', n; END IF;
    SELECT count(*) INTO n FROM authz.permissions WHERE code ~ '^[a-z_]+(\.[a-z_]+){2,3}$' AND touches_clinical_data;
    IF n <> 2 THEN RAISE EXCEPTION 'G-1j FALLÓ: clínicos se esperaban 2 y hay %', n; END IF;
    SELECT count(*) INTO n FROM authz.permissions WHERE code ~ '^[a-z_]+(\.[a-z_]+){2,3}$' AND NOT support_assignable;
    IF n <> 4 THEN RAISE EXCEPTION 'G-1k FALLÓ: no asignables a apoyo se esperaban 4 y hay %', n; END IF;
    -- ningún átomo con aprobación queda sin sensibilidad (ck_permissions_approval_needs_sensitivity)
    SELECT count(*) INTO n FROM authz.permissions WHERE code ~ '^[a-z_]+(\.[a-z_]+){2,3}$'
       AND (sensitivity_concept_id IS NULL OR purpose_of_use_concept_id IS NULL OR legal_basis_concept_id IS NULL);
    IF n <> 0 THEN RAISE EXCEPTION 'G-1l FALLÓ: % átomos sin sensibilidad, propósito o base legal', n; END IF;
    -- los 15 códigos antiguos siguen (mismos ids): NO asignables a apoyo, con sensibilidad y con las obligaciones de sus átomos (v4.2.79)
    SELECT count(*) INTO n FROM authz.permissions
     WHERE code IN ('schedule.view', 'schedule.create', 'schedule.reschedule', 'schedule.cancel', 'schedule.confirm',
                    'schedule.check_in', 'schedule.walk_in', 'schedule.waitlist', 'schedule.send_reminders',
                    'schedule.block_time', 'schedule.edit_hours', 'billing.collect', 'billing.issue_receipt',
                    'patient.register', 'messages.reply_on_behalf')
       AND NOT support_assignable AND sensitivity_concept_id IS NOT NULL;
    IF n <> 15 THEN RAISE EXCEPTION 'G-1m FALLÓ: los 15 códigos antiguos no asignables y con sensibilidad son % (esperados 15)', n; END IF;
    -- ningún alias pide menos que los átomos a los que se expande (motivo, paso extra, aprobación)
    SELECT count(*) INTO n FROM authz.permissions p
     WHERE (p.code, p.requires_reason, p.requires_step_up, p.approval_mode_concept_id IS NOT NULL) NOT IN (
           ('schedule.view', false, false, false), ('schedule.create', false, false, false), ('schedule.reschedule', true, false, false),
           ('schedule.cancel', true, false, false), ('schedule.confirm', false, false, false), ('schedule.check_in', false, false, false),
           ('schedule.walk_in', false, false, false), ('schedule.waitlist', false, false, false), ('schedule.send_reminders', false, false, false),
           ('schedule.block_time', true, false, false), ('schedule.edit_hours', true, true, true), ('billing.collect', false, false, false),
           ('billing.issue_receipt', false, false, false), ('patient.register', false, false, false), ('messages.reply_on_behalf', false, false, false))
       AND p.code IN ('schedule.view', 'schedule.create', 'schedule.reschedule', 'schedule.cancel', 'schedule.confirm',
                      'schedule.check_in', 'schedule.walk_in', 'schedule.waitlist', 'schedule.send_reminders',
                      'schedule.block_time', 'schedule.edit_hours', 'billing.collect', 'billing.issue_receipt',
                      'patient.register', 'messages.reply_on_behalf');
    IF n <> 0 THEN RAISE EXCEPTION 'G-1m2 FALLÓ: % alias con obligaciones distintas de las de sus átomos', n; END IF;
    IF (SELECT id FROM authz.permissions WHERE code = 'schedule.view') <> '438c578b-e5ea-5c58-86ed-fcf7da71780e' THEN
        RAISE EXCEPTION 'G-1n FALLÓ: el id de schedule.view cambió'; END IF;
    IF (SELECT id FROM authz.permissions WHERE code = 'agenda.appointment.view') <> 'efeeea20-52a5-5973-a94a-37793ded463a' THEN
        RAISE EXCEPTION 'G-1o FALLÓ: el id de agenda.appointment.view no es el del Anexo A'; END IF;
    RAISE NOTICE 'G1 OK · 73 átomos en 7 categorías (sensibilidad 11/27/29/6, motivo 31, paso extra 14, aprobación 3+7, campo 8, clínicos 2, no asignables 4); los 15 antiguos con las obligaciones de sus átomos';
END
$g1$;

-- ---------------------------------------------------------------- G2 · SoD de plataforma, plantillas v2, rol de sistema
DO $g2$
DECLARE n integer; r record;
BEGIN
    SELECT count(*) INTO n FROM delegated_access.sod_rules WHERE tenant_id IS NULL;
    IF n <> 11 THEN RAISE EXCEPTION 'G-2a FALLÓ: se esperaban 11 reglas SoD de plataforma y hay %', n; END IF;
    SELECT count(*) INTO n FROM delegated_access.sod_rules WHERE tenant_id IS NULL AND is_hard;
    IF n <> 6 THEN RAISE EXCEPTION 'G-2b FALLÓ: sin excepción posible se esperaban 6 y hay %', n; END IF;
    SELECT count(*) INTO n FROM delegated_access.sod_rules s JOIN terminology.catalog_concepts c ON c.id = s.action_concept_id
     WHERE s.tenant_id IS NULL AND c.code = 'delegated_access:SOD_ACTION_BLOCK';
    IF n <> 6 THEN RAISE EXCEPTION 'G-2c FALLÓ: BLOQUEAR esperaba 6 y hay %', n; END IF;
    SELECT count(*) INTO n FROM delegated_access.sod_rules s JOIN terminology.catalog_concepts c ON c.id = s.action_concept_id
     WHERE s.tenant_id IS NULL AND c.code = 'delegated_access:SOD_ACTION_REQUIRE_APPROVAL' AND s.max_exception_days = 90;
    IF n <> 4 THEN RAISE EXCEPTION 'G-2d FALLÓ: EXIGIR APROBACIÓN con 90 días esperaba 4 y hay %', n; END IF;
    IF (SELECT count(*) FROM delegated_access.sod_rules WHERE tenant_id IS NULL AND code = 'SOD-BILL-05'
          AND scope_concept_id = (SELECT id FROM terminology.catalog_concepts WHERE code = 'delegated_access:SOD_SCOPE_TRANSACTION')) <> 1 THEN
        RAISE EXCEPTION 'G-2e FALLÓ: SOD-BILL-05 debe ser de alcance TRANSACTION'; END IF;
    -- SOD-BILL-01: cobrar y anular
    IF NOT EXISTS (SELECT 1 FROM delegated_access.sod_rules WHERE code = 'SOD-BILL-01' AND tenant_id IS NULL
                      AND atoms_a_json = '["billing.payment.collect"]'::jsonb AND atoms_b_json = '["billing.receipt.void"]'::jsonb AND is_hard) THEN
        RAISE EXCEPTION 'G-2f FALLÓ: SOD-BILL-01 no es cobrar/anular duro'; END IF;
    -- las 7 plantillas v2 con su paquete (átomos) y su techo
    FOR r IN SELECT * FROM (VALUES
        ('SECRETARY', 20), ('MEDICAL_ASSISTANT', 20), ('NURSING', 7), ('FRONT_DESK', 8), ('BILLING_CASHIER', 5),
        ('CALL_CENTER', 7), ('ORG_MANAGEMENT', 21)) v(code, expected)
    LOOP
        SELECT jsonb_array_length(default_actions_json) INTO n FROM delegated_access.role_templates
         WHERE tenant_id IS NULL AND code = r.code AND version_number = 2;
        IF n IS DISTINCT FROM r.expected THEN
            RAISE EXCEPTION 'G-2g FALLÓ: la plantilla % v2 debía traer % átomos y trae %', r.code, r.expected, n; END IF;
        IF NOT EXISTS (SELECT 1 FROM delegated_access.role_templates WHERE tenant_id IS NULL AND code = r.code AND version_number = 2
                          AND jsonb_typeof(ceiling_actions_json) = 'array') THEN
            RAISE EXCEPTION 'G-2h FALLÓ: la plantilla % v2 no trae techo', r.code; END IF;
        -- todo paquete cabe en su techo
        IF EXISTS (SELECT 1 FROM delegated_access.role_templates t, jsonb_array_elements_text(t.default_actions_json) a(code)
                    WHERE t.tenant_id IS NULL AND t.code = r.code AND t.version_number = 2
                      AND NOT (t.ceiling_actions_json ? a.code)) THEN
            RAISE EXCEPTION 'G-2i FALLÓ: el paquete de % v2 no cabe en su techo', r.code; END IF;
        -- las v1 siguen existiendo con sus 15 códigos antiguos
        IF NOT EXISTS (SELECT 1 FROM delegated_access.role_templates WHERE tenant_id IS NULL AND code = r.code AND version_number = 1) THEN
            RAISE EXCEPTION 'G-2j FALLÓ: la plantilla % v1 desapareció', r.code; END IF;
    END LOOP;
    -- ningún techo de plantilla incluye los 4 team.* de seguridad
    IF EXISTS (SELECT 1 FROM delegated_access.role_templates t
                WHERE t.tenant_id IS NULL AND t.version_number = 2
                  AND (t.ceiling_actions_json ? 'team.templates.manage' OR t.ceiling_actions_json ? 'team.guardrails.manage'
                       OR t.ceiling_actions_json ? 'team.sod.manage' OR t.ceiling_actions_json ? 'team.sessionpolicy.manage')) THEN
        RAISE EXCEPTION 'G-2k FALLÓ: un techo incluye un permiso de seguridad no asignable'; END IF;
    -- rol de sistema no asignable
    IF NOT EXISTS (SELECT 1 FROM authz.roles WHERE code = 'SUPPORT_STAFF' AND tenant_id IS NULL AND is_system AND NOT is_assignable) THEN
        RAISE EXCEPTION 'G-2l FALLÓ: falta el rol de sistema SUPPORT_STAFF (is_assignable = false)'; END IF;
    RAISE NOTICE 'G2 OK · 11 reglas SoD (6 duras), 7 plantillas v2 con su techo y rol SUPPORT_STAFF';
END
$g2$;

-- Datos del hospital piloto, como variables psql.
SELECT
  (SELECT id FROM directory.tenants WHERE code = 'DEMO_HOSPITAL_PILOTO') AS hosp,
  (SELECT id FROM directory.tenants WHERE code = 'DEMO_CONSULTORIO_CESPEDES') AS cons,
  (SELECT m.user_id FROM directory.tenant_memberships m JOIN iam.users u ON u.id = m.user_id
    WHERE u.display_name = 'Ana Gutiérrez') AS u_ana,
  (SELECT m.user_id FROM directory.tenant_memberships m JOIN iam.users u ON u.id = m.user_id
    WHERE u.display_name = 'Marcos Ribera') AS u_marcos,
  (SELECT m.user_id FROM directory.tenant_memberships m JOIN iam.users u ON u.id = m.user_id
    WHERE u.display_name = 'Administrador Hospital Piloto') AS u_admin,
  (SELECT a.id FROM delegated_access.organization_user_assignments a
     JOIN directory.tenant_memberships m ON m.id = a.tenant_membership_id
     JOIN iam.users u ON u.id = m.user_id WHERE u.display_name = 'Ana Gutiérrez') AS oua_ana,
  (SELECT a.id FROM delegated_access.organization_user_assignments a
     JOIN directory.tenant_memberships m ON m.id = a.tenant_membership_id
     JOIN iam.users u ON u.id = m.user_id WHERE u.display_name = 'Marcos Ribera') AS oua_marcos,
  (SELECT r.id FROM practice.practitioner_role_assignments r JOIN profiles.persons p ON p.id = r.practitioner_profile_id
    WHERE p.display_name = 'Andrés Pérez') AS pra_perez,
  (SELECT r.id FROM practice.practitioner_role_assignments r JOIN profiles.persons p ON p.id = r.practitioner_profile_id
    WHERE p.display_name = 'Paola Céspedes') AS pra_cespedes,
  (SELECT id FROM delegated_access.role_templates WHERE tenant_id IS NULL AND code = 'SECRETARY' AND version_number = 2) AS tpl_secretary_v2,
  (SELECT id FROM authz.permissions WHERE code = 'agenda.appointment.view.reason') AS perm_reason,
  (SELECT id FROM authz.permissions WHERE code = 'agenda.appointment.view') AS perm_view,
  (SELECT id FROM authz.permissions WHERE code = 'agenda.appointment.cancel') AS perm_cancel,
  (SELECT id FROM delegated_access.sod_rules WHERE code = 'SOD-BILL-01' AND tenant_id IS NULL) AS sod_bill_01,
  (SELECT id FROM delegated_access.sod_rules WHERE code = 'SOD-BILL-03' AND tenant_id IS NULL) AS sod_bill_03,
  (SELECT id FROM delegated_access.sod_rules WHERE code = 'SOD-BILL-04' AND tenant_id IS NULL) AS sod_bill_04,
  EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'mantra_app')
    AND has_schema_privilege('mantra_app', 'delegated_access', 'USAGE') AND has_schema_privilege('mantra_app', 'directory', 'USAGE')
    AND has_schema_privilege('mantra_app', 'practice', 'USAGE') AS has_app,   -- v4.2.79: el rol existe pero sin los GRANT de 2026-08-05_tenant_rls.sql no sirve para probar
  COALESCE((SELECT c.relrowsecurity FROM pg_class c WHERE c.oid = 'delegated_access.support_scope_grants'::regclass), false) AS rls_on,
  EXISTS (SELECT 1 FROM iam.users WHERE display_name = 'Sofía Camacho') AS pilot_gov
\gset

-- ---------------------------------------------------------------- G3 · 12 tablas con RLS por tenant
DO $g3$
DECLARE r record; n integer := 0; rls boolean;
BEGIN
    FOR r IN SELECT * FROM (VALUES
        ('governance_rules'), ('sod_rules'), ('sod_exceptions'), ('four_eyes_requests'), ('access_review_campaigns'),
        ('access_review_items'), ('lifecycle_cases'), ('handover_items'), ('patient_restriction_flags'),
        ('access_decision_log'), ('grant_usage_stats'), ('access_anomalies')) v(t)
    LOOP
        IF to_regclass(format('delegated_access.%I', r.t)) IS NULL THEN
            RAISE EXCEPTION 'G-3a FALLÓ: falta la tabla delegated_access.%', r.t; END IF;
        n := n + 1;
    END LOOP;
    SELECT COALESCE((SELECT c.relrowsecurity FROM pg_class c WHERE c.oid = 'delegated_access.support_scope_grants'::regclass), false) INTO rls;
    IF NOT rls THEN
        RAISE NOTICE 'G3 OMITIDA (políticas) · % tablas existen; la base no usa RLS todavía (ejecutar 2026-08-05_tenant_rls.sql y volver a correr el parche v4278)', n;
        RETURN;
    END IF;
    FOR r IN SELECT * FROM (VALUES
        ('governance_rules'), ('sod_rules'), ('sod_exceptions'), ('four_eyes_requests'), ('access_review_campaigns'),
        ('access_review_items'), ('lifecycle_cases'), ('handover_items'), ('patient_restriction_flags'),
        ('access_decision_log'), ('grant_usage_stats'), ('access_anomalies')) v(t)
    LOOP
        IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE schemaname = 'delegated_access' AND tablename = r.t AND policyname = 'tenant_isolation') THEN
            RAISE EXCEPTION 'G-3b FALLÓ: % sin política tenant_isolation', r.t; END IF;
        IF NOT (SELECT c.relrowsecurity AND c.relforcerowsecurity FROM pg_class c WHERE c.oid = format('delegated_access.%I', r.t)::regclass) THEN
            RAISE EXCEPTION 'G-3c FALLÓ: % sin RLS forzado', r.t; END IF;
    END LOOP;
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE schemaname = 'delegated_access' AND tablename = 'sod_rules' AND policyname = 'global_catalog_read') THEN
        RAISE EXCEPTION 'G-3d FALLÓ: sod_rules sin global_catalog_read (las reglas de plataforma no las lee ningún tenant)'; END IF;
    RAISE NOTICE 'G3 OK · 12 tablas con tenant_isolation + RLS forzado y global_catalog_read en sod_rules';
END
$g3$;

-- ---------------------------------------------------------------- G4 · CHECK
-- cuatro ojos: la auto-aprobación es imposible A NIVEL DE BASE DE DATOS (23514)
SELECT pg_temp.must_fail('4a', '23514', format($q$
  INSERT INTO delegated_access.four_eyes_requests (id, tenant_id, kind_concept_id, requester_user_id, approver_kind_concept_id, payload_json, payload_hash,
    payload_schema_version, status_concept_id, expires_at, decided_at, decided_by_user_id, created_at, updated_at)
  VALUES (gen_random_uuid(), %L, 'c5dace75-a0b2-5bac-bdda-5b19d7f0aaef', %L, '610c6456-d162-539e-b21e-2d19a4a99b88', '{}'::jsonb, repeat('a', 64), 1,
    '1627143e-d273-5fcb-b289-9e59b8b096f2', now() + interval '1 hour', now(), %L, now(), now())$q$, :'hosp', :'u_ana', :'u_ana'));
SELECT pg_temp.must_fail('4a2', '23514', format($q$
  INSERT INTO delegated_access.four_eyes_requests (id, tenant_id, kind_concept_id, requester_user_id, subject_user_id, approver_kind_concept_id, payload_json, payload_hash,
    payload_schema_version, status_concept_id, expires_at, decided_at, decided_by_user_id, created_at, updated_at)
  VALUES (gen_random_uuid(), %L, 'c5dace75-a0b2-5bac-bdda-5b19d7f0aaef', %L, %L, '610c6456-d162-539e-b21e-2d19a4a99b88', '{}'::jsonb, repeat('a', 64), 1,
    '1627143e-d273-5fcb-b289-9e59b8b096f2', now() + interval '1 hour', now(), %L, now(), now())$q$, :'hosp', :'u_admin', :'u_ana', :'u_ana'));  -- tampoco la persona sobre la que se decide
SELECT pg_temp.must_fail('4b', '23514', format($q$
  INSERT INTO delegated_access.four_eyes_requests (id, tenant_id, kind_concept_id, requester_user_id, approver_kind_concept_id, payload_json, payload_hash,
    payload_schema_version, status_concept_id, expires_at, created_at, updated_at)
  VALUES (gen_random_uuid(), %L, 'c5dace75-a0b2-5bac-bdda-5b19d7f0aaef', %L, '610c6456-d162-539e-b21e-2d19a4a99b88', '{}'::jsonb, 'NO-ES-SHA256', 1,
    'a977935a-9073-5113-9644-7df96732e776', now() + interval '1 hour', now(), now())$q$, :'hosp', :'u_ana'));
SELECT pg_temp.must_fail('4c', '23514', format($q$
  INSERT INTO delegated_access.four_eyes_requests (id, tenant_id, kind_concept_id, requester_user_id, approver_kind_concept_id, payload_json, payload_hash,
    payload_schema_version, status_concept_id, expires_at, created_at, updated_at)
  VALUES (gen_random_uuid(), %L, 'c5dace75-a0b2-5bac-bdda-5b19d7f0aaef', %L, '610c6456-d162-539e-b21e-2d19a4a99b88', '{}'::jsonb, repeat('b', 64), 1,
    'a977935a-9073-5113-9644-7df96732e776', now() - interval '1 hour', now(), now())$q$, :'hosp', :'u_ana'));   -- vence antes de nacer
SELECT pg_temp.must_fail('4d', '23514', format($q$
  INSERT INTO delegated_access.four_eyes_requests (id, tenant_id, kind_concept_id, requester_user_id, approver_kind_concept_id, payload_json, payload_hash,
    payload_schema_version, status_concept_id, expires_at, decided_at, decided_by_user_id, decision_comment_text, created_at, updated_at)
  VALUES (gen_random_uuid(), %L, 'c5dace75-a0b2-5bac-bdda-5b19d7f0aaef', %L, '610c6456-d162-539e-b21e-2d19a4a99b88', '{}'::jsonb, repeat('c', 64), 1,
    'de15c53d-1aa0-5709-8ebd-69e9fd323e31', now() + interval '1 hour', now(), %L, 'no', now(), now())$q$, :'hosp', :'u_ana', :'u_admin'));  -- rechazo con comentario corto
SELECT pg_temp.must_fail('4e', '23514', format($q$
  INSERT INTO delegated_access.four_eyes_requests (id, tenant_id, kind_concept_id, requester_user_id, approver_kind_concept_id, payload_json, payload_hash,
    payload_schema_version, status_concept_id, expires_at, decided_by_user_id, created_at, updated_at)
  VALUES (gen_random_uuid(), %L, 'c5dace75-a0b2-5bac-bdda-5b19d7f0aaef', %L, '610c6456-d162-539e-b21e-2d19a4a99b88', '{}'::jsonb, repeat('d', 64), 1,
    'a977935a-9073-5113-9644-7df96732e776', now() + interval '1 hour', %L, now(), now())$q$, :'hosp', :'u_ana', :'u_admin'));  -- pendiente que ya trae decisor
SELECT pg_temp.must_pass('4f', format($q$
  INSERT INTO delegated_access.four_eyes_requests (id, tenant_id, kind_concept_id, requester_user_id, approver_kind_concept_id, payload_json, payload_hash,
    payload_schema_version, status_concept_id, expires_at, created_at, updated_at)
  VALUES (gen_random_uuid(), %L, 'c5dace75-a0b2-5bac-bdda-5b19d7f0aaef', %L, '610c6456-d162-539e-b21e-2d19a4a99b88', '{}'::jsonb, repeat('e', 64), 1,
    'a977935a-9073-5113-9644-7df96732e776', now() + interval '1 hour', now(), now())$q$, :'hosp', :'u_ana'));
SELECT pg_temp.must_fail('4g', '23505', format($q$
  INSERT INTO delegated_access.four_eyes_requests (id, tenant_id, kind_concept_id, requester_user_id, approver_kind_concept_id, payload_json, payload_hash,
    payload_schema_version, status_concept_id, expires_at, created_at, updated_at)
  VALUES (gen_random_uuid(), %L, 'c5dace75-a0b2-5bac-bdda-5b19d7f0aaef', %L, '610c6456-d162-539e-b21e-2d19a4a99b88', '{}'::jsonb, repeat('e', 64), 1,
    'a977935a-9073-5113-9644-7df96732e776', now() + interval '1 hour', now(), now())$q$, :'hosp', :'u_ana'));   -- la misma solicitud pendiente dos veces

-- excepción SoD: a más de 180 días, con justificación corta; una legítima pasa
SELECT pg_temp.must_pass('4h0', format($q$
  INSERT INTO delegated_access.four_eyes_requests (id, tenant_id, kind_concept_id, requester_user_id, approver_kind_concept_id, payload_json, payload_hash,
    payload_schema_version, status_concept_id, expires_at, decided_at, decided_by_user_id, created_at, updated_at)
  VALUES ('00000000-0000-0000-0000-0000000000a1', %L, '5b36bf36-7f60-5d20-a2ea-3c7826e8d492', %L, '610c6456-d162-539e-b21e-2d19a4a99b88', '{}'::jsonb, repeat('f', 64), 1,
    '1627143e-d273-5fcb-b289-9e59b8b096f2', now() + interval '1 hour', now(), %L, now(), now())$q$, :'hosp', :'u_admin', :'u_ana'));
SELECT pg_temp.must_fail('4h', '23514', format($q$
  INSERT INTO delegated_access.sod_exceptions (id, tenant_id, sod_rule_id, organization_user_assignment_id, four_eyes_request_id, justification_text,
    valid_from, valid_to, status_concept_id, created_at, updated_at)
  VALUES (gen_random_uuid(), %L, %L, %L, '00000000-0000-0000-0000-0000000000a1', repeat('x', 40), now(), now() + interval '181 days',
    '38a1d301-f40d-5b17-a695-5e6d605f8b19', now(), now())$q$, :'hosp', :'sod_bill_04', :'oua_ana'));
SELECT pg_temp.must_fail('4i', '23514', format($q$
  INSERT INTO delegated_access.sod_exceptions (id, tenant_id, sod_rule_id, organization_user_assignment_id, four_eyes_request_id, justification_text,
    valid_from, valid_to, status_concept_id, created_at, updated_at)
  VALUES (gen_random_uuid(), %L, %L, %L, '00000000-0000-0000-0000-0000000000a1', 'corta', now(), now() + interval '30 days',
    '38a1d301-f40d-5b17-a695-5e6d605f8b19', now(), now())$q$, :'hosp', :'sod_bill_04', :'oua_ana'));
SELECT pg_temp.must_pass('4j', format($q$
  INSERT INTO delegated_access.sod_exceptions (id, tenant_id, sod_rule_id, organization_user_assignment_id, four_eyes_request_id, justification_text,
    valid_from, valid_to, status_concept_id, created_at, updated_at)
  VALUES (gen_random_uuid(), %L, %L, %L, '00000000-0000-0000-0000-0000000000a1', repeat('x', 40), now(), now() + interval '180 days',
    '38a1d301-f40d-5b17-a695-5e6d605f8b19', now(), now())$q$, :'hosp', :'sod_bill_04', :'oua_ana'));

-- condición por concesión: la versión del JSON debe coincidir con la columna
SELECT pg_temp.must_fail('4k', '23514', format($q$
  INSERT INTO delegated_access.support_scope_grants (id, tenant_id, organization_user_assignment_id, target_kind_concept_id, expansion_mode_concept_id,
    status_concept_id, condition_json, condition_schema_version, created_at, updated_at)
  VALUES (gen_random_uuid(), %L, %L, 'b1330928-a076-5348-bffd-154144fadc85', 'd9ed1dfe-f5e6-55f3-94f2-2bd60993a536',
    'ccfbc54f-4744-53db-ab1f-abe1af31f784', '{"schemaVersion": 1}'::jsonb, 2, now(), now())$q$, :'hosp', :'oua_ana'));
SELECT pg_temp.must_fail('4k2', '23514', format($q$
  INSERT INTO delegated_access.support_scope_grants (id, tenant_id, organization_user_assignment_id, target_kind_concept_id, expansion_mode_concept_id,
    status_concept_id, condition_json, created_at, updated_at)
  VALUES (gen_random_uuid(), %L, %L, 'b1330928-a076-5348-bffd-154144fadc85', 'd9ed1dfe-f5e6-55f3-94f2-2bd60993a536',
    'ccfbc54f-4744-53db-ab1f-abe1af31f784', '{"schemaVersion": 1}'::jsonb, now(), now())$q$, :'hosp', :'oua_ana'));   -- condición sin versión
SELECT pg_temp.must_fail('4k3', '23514', format($q$
  INSERT INTO delegated_access.support_scope_grants (id, tenant_id, organization_user_assignment_id, target_kind_concept_id, expansion_mode_concept_id,
    status_concept_id, condition_json, condition_schema_version, created_at, updated_at)
  VALUES (gen_random_uuid(), %L, %L, 'b1330928-a076-5348-bffd-154144fadc85', 'd9ed1dfe-f5e6-55f3-94f2-2bd60993a536',
    'ccfbc54f-4744-53db-ab1f-abe1af31f784', to_jsonb(ARRAY[1]), 1, now(), now())$q$, :'hosp', :'oua_ana'));    -- la condición es un objeto
SELECT pg_temp.must_fail('4k4', '23514', format($q$
  INSERT INTO delegated_access.support_scope_grants (id, tenant_id, organization_user_assignment_id, target_kind_concept_id, expansion_mode_concept_id,
    status_concept_id, condition_json, condition_schema_version, created_at, updated_at)
  VALUES (gen_random_uuid(), %L, %L, 'b1330928-a076-5348-bffd-154144fadc85', 'd9ed1dfe-f5e6-55f3-94f2-2bd60993a536',
    'ccfbc54f-4744-53db-ab1f-abe1af31f784', jsonb_build_object('schemaVersion', 1, 'pad', repeat('x', 9000)), 1, now(), now())$q$, :'hosp', :'oua_ana'));   -- más de 8 KiB
SELECT pg_temp.must_fail('4l', '23514', format($q$
  INSERT INTO delegated_access.support_scope_grants (id, tenant_id, organization_user_assignment_id, target_kind_concept_id, expansion_mode_concept_id,
    status_concept_id, effect_concept_id, created_at, updated_at)
  VALUES (gen_random_uuid(), %L, %L, 'b1330928-a076-5348-bffd-154144fadc85', 'd9ed1dfe-f5e6-55f3-94f2-2bd60993a536',
    'ccfbc54f-4744-53db-ab1f-abe1af31f784', 'ccfbc54f-4744-53db-ab1f-abe1af31f784', now(), now())$q$, :'hosp', :'oua_ana'));    -- efecto que no es allow/deny
SELECT pg_temp.must_pass('4m', format($q$
  INSERT INTO delegated_access.support_scope_grants (id, tenant_id, organization_user_assignment_id, target_kind_concept_id, expansion_mode_concept_id,
    status_concept_id, condition_json, condition_schema_version, reason_text, created_at, updated_at)
  VALUES (gen_random_uuid(), %L, %L, 'b1330928-a076-5348-bffd-154144fadc85', 'd9ed1dfe-f5e6-55f3-94f2-2bd60993a536',
    'ccfbc54f-4744-53db-ab1f-abe1af31f784', '{"schemaVersion": 1, "time": {"windows": []}}'::jsonb, 1, 'prueba de verificación', now(), now())$q$, :'hosp', :'oua_ana'));
-- el efecto por defecto de una concesión que no lo declara es ALLOW (lo que el código anterior inserta)
DO $g4m$
BEGIN
    IF (SELECT column_default FROM information_schema.columns WHERE table_schema = 'delegated_access' AND table_name = 'support_scope_grants'
           AND column_name = 'effect_concept_id') NOT LIKE '%6905e0db-1650-5d49-adca-8b2688ac049c%' THEN
        RAISE EXCEPTION 'G-4m FALLÓ: el efecto por defecto de support_scope_grants no es ALLOW'; END IF;
END
$g4m$;

-- reglas de la organización (L1)
SELECT pg_temp.must_fail('4n', '23514', format($q$
  INSERT INTO delegated_access.governance_rules (id, tenant_id, rule_kind_concept_id, permission_pattern, status_concept_id, created_at, updated_at)
  VALUES (gen_random_uuid(), %L, '2e3f3830-b5cc-5661-902e-9106df223081', 'billing', '38a1d301-f40d-5b17-a695-5e6d605f8b19', now(), now())$q$, :'hosp'));   -- patrón mal formado
SELECT pg_temp.must_fail('4o', '23514', format($q$
  INSERT INTO delegated_access.governance_rules (id, tenant_id, rule_kind_concept_id, permission_pattern, status_concept_id, created_at, updated_at)
  VALUES (gen_random_uuid(), %L, 'ce906685-7a58-54e7-b4d2-458062c0c303', 'billing.*', '38a1d301-f40d-5b17-a695-5e6d605f8b19', now(), now())$q$, :'hosp'));   -- techo sin plantilla
SELECT pg_temp.must_fail('4p', '23514', format($q$
  INSERT INTO delegated_access.governance_rules (id, tenant_id, rule_kind_concept_id, permission_pattern, rule_json, rule_schema_version, status_concept_id, created_at, updated_at)
  VALUES (gen_random_uuid(), %L, 'f2534b4a-a8cc-5fb1-a431-30e1a750274b', 'agenda.appointment.view.patient_document', '{"maxVisibility": "FULL"}'::jsonb, 1,
    '38a1d301-f40d-5b17-a695-5e6d605f8b19', now(), now())$q$, :'hosp'));   -- piso de campo con visibilidad inválida
SELECT pg_temp.must_fail('4q', '23514', format($q$
  INSERT INTO delegated_access.governance_rules (id, tenant_id, rule_kind_concept_id, permission_pattern, rule_json, status_concept_id, valid_from, valid_to, created_at, updated_at)
  VALUES (gen_random_uuid(), %L, '1b6db045-2cc5-5985-9c89-18b8ac0969be', 'billing.*', '{"condition": {}}'::jsonb,
    '38a1d301-f40d-5b17-a695-5e6d605f8b19', now(), now() - interval '1 day', now(), now())$q$, :'hosp'));   -- vigencia invertida
SELECT pg_temp.must_pass('4r', format($q$
  INSERT INTO delegated_access.governance_rules (id, tenant_id, rule_kind_concept_id, permission_pattern, role_template_code, status_concept_id, message_text, created_at, updated_at)
  VALUES ('00000000-0000-0000-0000-0000000000b1', %L, 'ce906685-7a58-54e7-b4d2-458062c0c303', 'agenda.hours.*', 'FRONT_DESK',
    '38a1d301-f40d-5b17-a695-5e6d605f8b19', 'prueba', now(), now())$q$, :'hosp'));
SELECT pg_temp.must_fail('4s', '23505', format($q$
  INSERT INTO delegated_access.governance_rules (id, tenant_id, rule_kind_concept_id, permission_pattern, role_template_code, status_concept_id, created_at, updated_at)
  VALUES (gen_random_uuid(), %L, 'ce906685-7a58-54e7-b4d2-458062c0c303', 'agenda.hours.*', 'FRONT_DESK', '38a1d301-f40d-5b17-a695-5e6d605f8b19', now(), now())$q$, :'hosp'));   -- la misma regla activa dos veces

-- reglas SoD
SELECT pg_temp.must_fail('4t', '23514', $q$
  INSERT INTO delegated_access.sod_rules (id, code, name, atoms_a_json, atoms_b_json, scope_concept_id, action_concept_id, is_hard, max_exception_days, status_concept_id, version_number, created_at, updated_at)
  VALUES (gen_random_uuid(), 'T-1', 'prueba', '[]'::jsonb, '[]'::jsonb, '0fb8d904-8d4c-5ff5-972e-b0968cadc699', 'd317a334-2e99-5361-836c-674cbeec5d26',
    true, 30, '38a1d301-f40d-5b17-a695-5e6d605f8b19', 1, now(), now())$q$);   -- una regla dura no admite excepción
SELECT pg_temp.must_fail('4u', '23514', $q$
  INSERT INTO delegated_access.sod_rules (id, code, name, atoms_a_json, atoms_b_json, scope_concept_id, action_concept_id, is_hard, max_exception_days, status_concept_id, version_number, created_at, updated_at)
  VALUES (gen_random_uuid(), 'T-2', 'prueba', '[]'::jsonb, '{}'::jsonb, '0fb8d904-8d4c-5ff5-972e-b0968cadc699', 'd317a334-2e99-5361-836c-674cbeec5d26',
    false, NULL, '38a1d301-f40d-5b17-a695-5e6d605f8b19', 1, now(), now())$q$);   -- los conjuntos son arreglos
SELECT pg_temp.must_fail('4v', '23514', $q$
  INSERT INTO delegated_access.sod_rules (id, code, name, atoms_a_json, atoms_b_json, scope_concept_id, action_concept_id, is_hard, max_exception_days, status_concept_id, version_number, created_at, updated_at)
  VALUES (gen_random_uuid(), 'T-3', 'prueba', '[]'::jsonb, '[]'::jsonb, '0fb8d904-8d4c-5ff5-972e-b0968cadc699', '117ffae4-a53b-5f5a-a927-d625ae57ad67',
    false, 181, '38a1d301-f40d-5b17-a695-5e6d605f8b19', 1, now(), now())$q$);   -- excepción de más de 180 días

-- ítems de campaña, campañas, ciclo de vida, traspaso, banderas, anomalías, uso
SELECT pg_temp.must_pass('4w0', format($q$
  INSERT INTO delegated_access.access_review_campaigns (id, tenant_id, name, kind_concept_id, scope_json, scope_schema_version, due_at,
    uncertified_action_concept_id, status_concept_id, created_at, updated_at)
  VALUES ('00000000-0000-0000-0000-0000000000c1', %L, 'G-4 campaña de prueba', '969627cf-9dff-5f7d-b6c6-8478414a6822', '{}'::jsonb, 1, now() + interval '14 days',
    'cdc3190b-22f6-5662-8ae0-34c1fb5c2ed2', '743d9f11-b186-5547-ae3d-cc44d94724bd', now(), now())$q$, :'hosp'));
SELECT pg_temp.must_fail('4w', '23514', format($q$
  INSERT INTO delegated_access.access_review_campaigns (id, tenant_id, name, kind_concept_id, scope_json, scope_schema_version, due_at, grace_days,
    uncertified_action_concept_id, status_concept_id, created_at, updated_at)
  VALUES (gen_random_uuid(), %L, 'gracia 31', '969627cf-9dff-5f7d-b6c6-8478414a6822', '{}'::jsonb, 1, now() + interval '14 days', 31,
    'cdc3190b-22f6-5662-8ae0-34c1fb5c2ed2', '743d9f11-b186-5547-ae3d-cc44d94724bd', now(), now())$q$, :'hosp'));
SELECT pg_temp.must_fail('4x', '23514', format($q$
  INSERT INTO delegated_access.access_review_campaigns (id, tenant_id, name, kind_concept_id, scope_json, scope_schema_version, due_at, launched_at,
    uncertified_action_concept_id, status_concept_id, created_at, updated_at)
  VALUES (gen_random_uuid(), %L, 'vence antes de lanzar', '969627cf-9dff-5f7d-b6c6-8478414a6822', '{}'::jsonb, 1, now() - interval '1 day', now(),
    'cdc3190b-22f6-5662-8ae0-34c1fb5c2ed2', '743d9f11-b186-5547-ae3d-cc44d94724bd', now(), now())$q$, :'hosp'));
-- comentario corto al revocar un ítem (23514) y hash mal formado (23514)
SELECT pg_temp.must_fail('4y', '23514', format($q$
  INSERT INTO delegated_access.access_review_items (id, tenant_id, access_review_campaign_id, organization_user_assignment_id, reviewer_user_id,
    reviewer_kind_concept_id, decision_concept_id, decided_at, decided_by_user_id, decision_comment_text, evidence_json, evidence_hash, due_at, created_at, updated_at)
  VALUES (gen_random_uuid(), %L, '00000000-0000-0000-0000-0000000000c1', %L, %L, '7e4272cc-9ebe-575a-bc36-b6983980a68f',
    'bce72e9a-b3bb-5fab-8e79-85d411ba692c', now(), %L, 'corto', '{}'::jsonb, repeat('a', 64), now() + interval '7 days', now(), now())$q$,
  :'hosp', :'oua_ana', :'u_admin', :'u_admin'));
SELECT pg_temp.must_fail('4z', '23514', format($q$
  INSERT INTO delegated_access.access_review_items (id, tenant_id, access_review_campaign_id, organization_user_assignment_id, reviewer_user_id,
    reviewer_kind_concept_id, evidence_json, evidence_hash, due_at, created_at, updated_at)
  VALUES (gen_random_uuid(), %L, '00000000-0000-0000-0000-0000000000c1', %L, %L, '7e4272cc-9ebe-575a-bc36-b6983980a68f', '{}'::jsonb, 'xyz',
    now() + interval '7 days', now(), now())$q$, :'hosp', :'oua_ana', :'u_admin'));
SELECT pg_temp.must_fail('4za', '23514', format($q$
  INSERT INTO delegated_access.access_review_items (id, tenant_id, access_review_campaign_id, organization_user_assignment_id, reviewer_user_id,
    reviewer_kind_concept_id, decision_concept_id, evidence_json, evidence_hash, due_at, created_at, updated_at)
  VALUES (gen_random_uuid(), %L, '00000000-0000-0000-0000-0000000000c1', %L, %L, '7e4272cc-9ebe-575a-bc36-b6983980a68f',
    'a3896ca4-e2a6-5b1b-a192-6b457ea34586', '{}'::jsonb, repeat('a', 64), now() + interval '7 days', now(), now())$q$, :'hosp', :'oua_ana', :'u_admin'));  -- certificado sin fecha de decisión
SELECT pg_temp.must_pass('4zb', format($q$
  INSERT INTO delegated_access.access_review_items (id, tenant_id, access_review_campaign_id, organization_user_assignment_id, reviewer_user_id,
    reviewer_kind_concept_id, evidence_json, evidence_hash, due_at, created_at, updated_at)
  VALUES ('00000000-0000-0000-0000-0000000000d1', %L, '00000000-0000-0000-0000-0000000000c1', %L, %L, '7e4272cc-9ebe-575a-bc36-b6983980a68f', '{}'::jsonb,
    repeat('a', 64), now() + interval '7 days', now(), now())$q$, :'hosp', :'oua_ana', :'u_admin'));
-- el estado por defecto del ítem es PENDIENTE
DO $g4d$
BEGIN
    IF (SELECT decision_concept_id FROM delegated_access.access_review_items WHERE id = '00000000-0000-0000-0000-0000000000d1')
         <> '55a6db07-19e7-5bb4-978a-3d246492f49d' THEN RAISE EXCEPTION 'G-4zb FALLÓ: un ítem nuevo no nace PENDIENTE'; END IF;
END
$g4d$;
-- un ítem por (campaña, vínculo, concesión): el de vínculo (concesión NULL) tampoco se repite
SELECT pg_temp.must_fail('4zc', '23505', format($q$
  INSERT INTO delegated_access.access_review_items (id, tenant_id, access_review_campaign_id, organization_user_assignment_id, reviewer_user_id,
    reviewer_kind_concept_id, evidence_json, evidence_hash, due_at, created_at, updated_at)
  VALUES (gen_random_uuid(), %L, '00000000-0000-0000-0000-0000000000c1', %L, %L, '7e4272cc-9ebe-575a-bc36-b6983980a68f', '{}'::jsonb,
    repeat('a', 64), now() + interval '7 days', now(), now())$q$, :'hosp', :'oua_ana', :'u_admin'));

SELECT pg_temp.must_fail('4zd', '23514', format($q$
  INSERT INTO delegated_access.lifecycle_cases (id, tenant_id, organization_user_assignment_id, subject_user_id, kind_concept_id, status_concept_id, opened_at, checklist_json, created_at, updated_at)
  VALUES (gen_random_uuid(), %L, %L, %L, 'c2a9a59d-c88c-5e87-9065-1e0e068c479d', '4734035e-72cf-519f-8e27-e6cf25ba557f', now(), '[]'::jsonb, now(), now())$q$,
  :'hosp', :'oua_ana', :'u_ana'));   -- completado sin fecha de cierre
SELECT pg_temp.must_fail('4ze', '23514', format($q$
  INSERT INTO delegated_access.lifecycle_cases (id, tenant_id, organization_user_assignment_id, subject_user_id, kind_concept_id, status_concept_id, opened_at, checklist_json, created_at, updated_at)
  VALUES (gen_random_uuid(), %L, %L, %L, 'c2a9a59d-c88c-5e87-9065-1e0e068c479d', '4f73e30c-25ba-52ff-969e-862e588cce13', now(), '{}'::jsonb, now(), now())$q$,
  :'hosp', :'oua_ana', :'u_ana'));   -- la lista de pasos es un arreglo
SELECT pg_temp.must_pass('4zf', format($q$
  INSERT INTO delegated_access.lifecycle_cases (id, tenant_id, organization_user_assignment_id, subject_user_id, kind_concept_id, status_concept_id, opened_at, checklist_json, created_at, updated_at)
  VALUES ('00000000-0000-0000-0000-0000000000e1', %L, %L, %L, 'c2a9a59d-c88c-5e87-9065-1e0e068c479d', '4f73e30c-25ba-52ff-969e-862e588cce13', now(), '[]'::jsonb, now(), now())$q$,
  :'hosp', :'oua_ana', :'u_ana'));
SELECT pg_temp.must_fail('4zg', '23505', format($q$
  INSERT INTO delegated_access.lifecycle_cases (id, tenant_id, organization_user_assignment_id, subject_user_id, kind_concept_id, status_concept_id, opened_at, checklist_json, created_at, updated_at)
  VALUES (gen_random_uuid(), %L, %L, %L, 'c2a9a59d-c88c-5e87-9065-1e0e068c479d', '4f73e30c-25ba-52ff-969e-862e588cce13', now(), '[]'::jsonb, now(), now())$q$,
  :'hosp', :'oua_ana', :'u_ana'));   -- un solo ingreso abierto por vínculo

SELECT pg_temp.must_fail('4zh', '23514', format($q$
  INSERT INTO delegated_access.handover_items (id, tenant_id, lifecycle_case_id, item_kind_concept_id, source_id, from_user_id, to_user_id, status_concept_id, created_at, updated_at)
  VALUES (gen_random_uuid(), %L, '00000000-0000-0000-0000-0000000000e1', '2e3528d8-17e6-56e8-ac36-f2875c3c1d30', gen_random_uuid(), %L, %L,
    '57d9c373-5a94-5fd6-bf9c-bd6a95cb2a91', now(), now())$q$, :'hosp', :'u_ana', :'u_ana'));   -- no se reasigna a la misma persona
SELECT pg_temp.must_fail('4zi', '23514', format($q$
  INSERT INTO delegated_access.handover_items (id, tenant_id, lifecycle_case_id, item_kind_concept_id, source_id, from_user_id, status_concept_id, created_at, updated_at)
  VALUES (gen_random_uuid(), %L, '00000000-0000-0000-0000-0000000000e1', '2e3528d8-17e6-56e8-ac36-f2875c3c1d30', gen_random_uuid(), %L,
    '57d9c373-5a94-5fd6-bf9c-bd6a95cb2a91', now(), now())$q$, :'hosp', :'u_ana'));   -- reasignado sin destino
SELECT pg_temp.must_pass('4zj', format($q$
  INSERT INTO delegated_access.handover_items (id, tenant_id, lifecycle_case_id, item_kind_concept_id, source_id, from_user_id, to_user_id, status_concept_id, reassigned_at, created_at, updated_at)
  VALUES (gen_random_uuid(), %L, '00000000-0000-0000-0000-0000000000e1', '2e3528d8-17e6-56e8-ac36-f2875c3c1d30', '00000000-0000-0000-0000-0000000000f1', %L, %L,
    '57d9c373-5a94-5fd6-bf9c-bd6a95cb2a91', now(), now(), now())$q$, :'hosp', :'u_ana', :'u_admin'));
SELECT pg_temp.must_fail('4zk', '23505', format($q$
  INSERT INTO delegated_access.handover_items (id, tenant_id, lifecycle_case_id, item_kind_concept_id, source_id, from_user_id, status_concept_id, created_at, updated_at)
  VALUES (gen_random_uuid(), %L, '00000000-0000-0000-0000-0000000000e1', '2e3528d8-17e6-56e8-ac36-f2875c3c1d30', '00000000-0000-0000-0000-0000000000f1', %L,
    '29406164-994b-55ab-bc88-697e22cd1cbc', now(), now())$q$, :'hosp', :'u_ana'));   -- el mismo elemento no entra dos veces al traspaso

SELECT pg_temp.must_fail('4zl', '23514', format($q$
  INSERT INTO delegated_access.access_anomalies (id, tenant_id, user_id, kind_concept_id, window_start, window_end, observed_value, threshold_value, evidence_json,
    status_concept_id, created_at, updated_at)
  VALUES (gen_random_uuid(), %L, %L, '7f20d407-aa33-5757-a6e0-3ddf9160592d', now(), now() - interval '1 hour', 18, 12, '{}'::jsonb,
    '5dc5d5c6-03af-5c50-9841-2559f959a180', now(), now())$q$, :'hosp', :'u_ana'));   -- ventana invertida
SELECT pg_temp.must_fail('4zm', '23514', format($q$
  INSERT INTO delegated_access.access_anomalies (id, tenant_id, user_id, kind_concept_id, window_start, window_end, observed_value, threshold_value, evidence_json,
    status_concept_id, resolution_comment_text, created_at, updated_at)
  VALUES (gen_random_uuid(), %L, %L, '7f20d407-aa33-5757-a6e0-3ddf9160592d', now() - interval '1 hour', now(), 18, 12, '{}'::jsonb,
    '1c8f5b91-371b-5967-b8fd-98d08f80ac9c', 'ok', now(), now())$q$, :'hosp', :'u_ana'));   -- descartada con comentario corto
SELECT pg_temp.must_pass('4zn', format($q$
  INSERT INTO delegated_access.access_anomalies (id, tenant_id, user_id, kind_concept_id, window_start, window_end, observed_value, threshold_value, evidence_json,
    status_concept_id, created_at, updated_at)
  VALUES (gen_random_uuid(), %L, %L, '7f20d407-aa33-5757-a6e0-3ddf9160592d', now() - interval '1 hour', now(), 18, 12, '{}'::jsonb,
    '5dc5d5c6-03af-5c50-9841-2559f959a180', now(), now())$q$, :'hosp', :'u_ana'));
SELECT pg_temp.must_fail('4zo', '23505', format($q$
  INSERT INTO delegated_access.access_anomalies (id, tenant_id, user_id, kind_concept_id, window_start, window_end, observed_value, threshold_value, evidence_json,
    status_concept_id, created_at, updated_at)
  SELECT gen_random_uuid(), tenant_id, user_id, kind_concept_id, window_start, window_end + interval '1 minute', 19, threshold_value, '{}'::jsonb, status_concept_id, now(), now()
    FROM delegated_access.access_anomalies WHERE tenant_id = %L AND user_id = %L LIMIT 1$q$, :'hosp', :'u_ana'));   -- el barrido es idempotente: misma ventana, un solo registro

SELECT pg_temp.must_fail('4zp', '23514', format($q$
  INSERT INTO delegated_access.grant_usage_stats (id, tenant_id, user_id, support_scope_grant_id, permission_code, bucket_start, permit_count, updated_at)
  SELECT gen_random_uuid(), %L, %L, g.id, 'agenda.appointment.cancel', date_trunc('hour', now()), -1, now()
    FROM delegated_access.support_scope_grants g WHERE g.organization_user_assignment_id = %L LIMIT 1$q$, :'hosp', :'u_ana', :'oua_ana'));   -- contadores no negativos
SELECT pg_temp.must_pass('4zq0', $q$
  INSERT INTO profiles.patient_profiles (profile_id, patient_code, created_at, updated_at)
  SELECT id, 'G-TEST-1', now(), now() FROM profiles.persons WHERE display_name = 'Ana Gutiérrez'
  ON CONFLICT DO NOTHING$q$);   -- un paciente para las comprobaciones de banderas (se deshace con el ROLLBACK)
SELECT pg_temp.must_fail('4zq', '23514', format($q$
  INSERT INTO delegated_access.patient_restriction_flags (id, tenant_id, patient_profile_id, flag_concept_id, reason_text, status_concept_id, valid_from, created_at, updated_at)
  SELECT gen_random_uuid(), %L, pp.profile_id, 'baf4dc8a-ac39-5c94-a176-92e012bd024f', 'corto', '38a1d301-f40d-5b17-a695-5e6d605f8b19', now(), now(), now()
    FROM profiles.patient_profiles pp LIMIT 1$q$, :'hosp'));   -- el motivo de una bandera tiene al menos 10 caracteres

-- columnas nuevas de permisos y plantillas
SELECT pg_temp.must_fail('4zr', '23514', $q$
  UPDATE authz.permissions SET approval_mode_concept_id = '610c6456-d162-539e-b21e-2d19a4a99b88', sensitivity_concept_id = NULL
   WHERE code = 'schedule.view'$q$);   -- no se pide aprobación a un permiso sin sensibilidad
SELECT pg_temp.must_fail('4zs', '23514', $q$
  UPDATE delegated_access.role_templates SET ceiling_actions_json = '{"a": 1}'::jsonb WHERE tenant_id IS NULL AND code = 'SECRETARY' AND version_number = 2$q$);
SELECT pg_temp.must_pass('4zt', $q$
  UPDATE delegated_access.role_templates SET ceiling_actions_json = ceiling_actions_json WHERE tenant_id IS NULL AND code = 'SECRETARY' AND version_number = 2$q$);
DO $g4$ BEGIN RAISE NOTICE 'G4 OK · los CHECK de las tablas nuevas rechazan lo inválido con 23514 (y 23505 en los únicos parciales) y aceptan lo legítimo'; END $g4$;

-- ---------------------------------------------------------------- G5 · disparadores
-- revisor = titular del vínculo (la persona revisada no se revisa a sí misma): reviewer, escalado y decisor
SELECT pg_temp.must_fail('5a', '23514', format($q$
  INSERT INTO delegated_access.access_review_items (id, tenant_id, access_review_campaign_id, organization_user_assignment_id, reviewer_user_id,
    reviewer_kind_concept_id, evidence_json, evidence_hash, due_at, created_at, updated_at)
  VALUES (gen_random_uuid(), %L, '00000000-0000-0000-0000-0000000000c1', %L, %L, '7e4272cc-9ebe-575a-bc36-b6983980a68f', '{}'::jsonb,
    repeat('a', 64), now() + interval '7 days', now(), now())$q$, :'hosp', :'oua_marcos', :'u_marcos'));
SELECT pg_temp.must_fail('5b', '23514', format($q$
  INSERT INTO delegated_access.access_review_items (id, tenant_id, access_review_campaign_id, organization_user_assignment_id, reviewer_user_id,
    escalated_to_user_id, escalated_at, reviewer_kind_concept_id, evidence_json, evidence_hash, due_at, created_at, updated_at)
  VALUES (gen_random_uuid(), %L, '00000000-0000-0000-0000-0000000000c1', %L, %L, %L, now(), '7e4272cc-9ebe-575a-bc36-b6983980a68f', '{}'::jsonb,
    repeat('a', 64), now() + interval '7 days', now(), now())$q$, :'hosp', :'oua_marcos', :'u_admin', :'u_marcos'));
SELECT pg_temp.must_fail('5c', '23514', format($q$
  INSERT INTO delegated_access.access_review_items (id, tenant_id, access_review_campaign_id, organization_user_assignment_id, reviewer_user_id,
    reviewer_kind_concept_id, decision_concept_id, decided_at, decided_by_user_id, evidence_json, evidence_hash, due_at, created_at, updated_at)
  VALUES (gen_random_uuid(), %L, '00000000-0000-0000-0000-0000000000c1', %L, %L, '7e4272cc-9ebe-575a-bc36-b6983980a68f',
    'a3896ca4-e2a6-5b1b-a192-6b457ea34586', now(), %L, '{}'::jsonb, repeat('a', 64), now() + interval '7 days', now(), now())$q$,
  :'hosp', :'oua_marcos', :'u_admin', :'u_marcos'));   -- tampoco decide quien es el sujeto
SELECT pg_temp.must_pass('5d', format($q$
  INSERT INTO delegated_access.access_review_items (id, tenant_id, access_review_campaign_id, organization_user_assignment_id, reviewer_user_id,
    reviewer_kind_concept_id, evidence_json, evidence_hash, due_at, created_at, updated_at)
  VALUES (gen_random_uuid(), %L, '00000000-0000-0000-0000-0000000000c1', %L, %L, '7e4272cc-9ebe-575a-bc36-b6983980a68f', '{}'::jsonb,
    repeat('a', 64), now() + interval '7 days', now(), now())$q$, :'hosp', :'oua_marcos', :'u_admin'));
-- tenant del ítem distinto del de su campaña (23514) o del de su vínculo; padre inexistente falla cerrado (23503)
SELECT pg_temp.must_fail('5e', '23514', format($q$
  INSERT INTO delegated_access.access_review_items (id, tenant_id, access_review_campaign_id, organization_user_assignment_id, reviewer_user_id,
    reviewer_kind_concept_id, evidence_json, evidence_hash, due_at, created_at, updated_at)
  VALUES (gen_random_uuid(), %L, '00000000-0000-0000-0000-0000000000c1', %L, %L, '7e4272cc-9ebe-575a-bc36-b6983980a68f', '{}'::jsonb,
    repeat('a', 64), now() + interval '7 days', now(), now())$q$, :'cons', :'oua_ana', :'u_admin'));
SELECT pg_temp.must_fail('5f', '23503', format($q$
  INSERT INTO delegated_access.access_review_items (id, tenant_id, access_review_campaign_id, organization_user_assignment_id, reviewer_user_id,
    reviewer_kind_concept_id, evidence_json, evidence_hash, due_at, created_at, updated_at)
  VALUES (gen_random_uuid(), %L, gen_random_uuid(), %L, %L, '7e4272cc-9ebe-575a-bc36-b6983980a68f', '{}'::jsonb,
    repeat('a', 64), now() + interval '7 days', now(), now())$q$, :'hosp', :'oua_ana', :'u_admin'));
-- traspaso, ciclo de vida, cuatro ojos, excepción SoD y uso: el tenant es el del padre
SELECT pg_temp.must_fail('5g', '23514', format($q$
  INSERT INTO delegated_access.handover_items (id, tenant_id, lifecycle_case_id, item_kind_concept_id, source_id, from_user_id, status_concept_id, created_at, updated_at)
  VALUES (gen_random_uuid(), %L, '00000000-0000-0000-0000-0000000000e1', '2e3528d8-17e6-56e8-ac36-f2875c3c1d30', gen_random_uuid(), %L,
    '29406164-994b-55ab-bc88-697e22cd1cbc', now(), now())$q$, :'cons', :'u_ana'));
SELECT pg_temp.must_fail('5h', '23514', format($q$
  INSERT INTO delegated_access.lifecycle_cases (id, tenant_id, organization_user_assignment_id, subject_user_id, kind_concept_id, status_concept_id, opened_at, checklist_json, created_at, updated_at)
  VALUES (gen_random_uuid(), %L, %L, %L, '52380372-44ca-5da2-9cf2-df8602006405', '4f73e30c-25ba-52ff-969e-862e588cce13', now(), '[]'::jsonb, now(), now())$q$,
  :'cons', :'oua_ana', :'u_ana'));
SELECT pg_temp.must_fail('5i', '23514', format($q$
  INSERT INTO delegated_access.four_eyes_requests (id, tenant_id, kind_concept_id, requester_user_id, organization_user_assignment_id, approver_kind_concept_id,
    payload_json, payload_hash, payload_schema_version, status_concept_id, expires_at, created_at, updated_at)
  VALUES (gen_random_uuid(), %L, 'c5dace75-a0b2-5bac-bdda-5b19d7f0aaef', %L, %L, '610c6456-d162-539e-b21e-2d19a4a99b88', '{}'::jsonb, repeat('9', 64), 1,
    'a977935a-9073-5113-9644-7df96732e776', now() + interval '1 hour', now(), now())$q$, :'cons', :'u_admin', :'oua_ana'));
SELECT pg_temp.must_fail('5j', '23514', format($q$
  INSERT INTO delegated_access.sod_exceptions (id, tenant_id, sod_rule_id, organization_user_assignment_id, four_eyes_request_id, justification_text,
    valid_from, valid_to, status_concept_id, created_at, updated_at)
  VALUES (gen_random_uuid(), %L, %L, %L, '00000000-0000-0000-0000-0000000000a1', repeat('x', 40), now(), now() + interval '10 days',
    '38a1d301-f40d-5b17-a695-5e6d605f8b19', now(), now())$q$, :'cons', :'sod_bill_01', :'oua_ana'));
SELECT pg_temp.must_fail('5k', '23514', format($q$
  INSERT INTO delegated_access.grant_usage_stats (id, tenant_id, user_id, support_scope_grant_id, permission_code, bucket_start, updated_at)
  SELECT gen_random_uuid(), %L, %L, g.id, 'agenda.appointment.cancel', date_trunc('hour', now()), now()
    FROM delegated_access.support_scope_grants g WHERE g.organization_user_assignment_id = %L LIMIT 1$q$, :'cons', :'u_ana', :'oua_ana'));
-- una concesión no puede nacer de una plantilla de OTRA organización (la de plataforma, tenant NULL, sí)
SELECT pg_temp.must_pass('5l', format($q$
  INSERT INTO delegated_access.support_scope_grants (id, tenant_id, organization_user_assignment_id, target_kind_concept_id, expansion_mode_concept_id,
    status_concept_id, source_role_template_id, created_at, updated_at)
  VALUES (gen_random_uuid(), %L, %L, 'b1330928-a076-5348-bffd-154144fadc85', 'd9ed1dfe-f5e6-55f3-94f2-2bd60993a536',
    'ccfbc54f-4744-53db-ab1f-abe1af31f784', %L, now(), now())$q$, :'hosp', :'oua_ana', :'tpl_secretary_v2'));
SELECT pg_temp.must_fail('5m', '23503', format($q$
  INSERT INTO delegated_access.support_scope_grants (id, tenant_id, organization_user_assignment_id, target_kind_concept_id, expansion_mode_concept_id,
    status_concept_id, source_role_template_id, created_at, updated_at)
  VALUES (gen_random_uuid(), %L, %L, 'b1330928-a076-5348-bffd-154144fadc85', 'd9ed1dfe-f5e6-55f3-94f2-2bd60993a536',
    'ccfbc54f-4744-53db-ab1f-abe1af31f784', gen_random_uuid(), now(), now())$q$, :'hosp', :'oua_ana'));   -- plantilla inexistente: FK
-- regla de la organización que AFLOJA a la de plataforma: menos estricta o sin el sello de «dura»
SELECT pg_temp.must_fail('5n', '23514', format($q$
  INSERT INTO delegated_access.sod_rules (id, tenant_id, code, name, base_rule_id, atoms_a_json, atoms_b_json, scope_concept_id, action_concept_id, is_hard,
    status_concept_id, version_number, created_at, updated_at)
  VALUES (gen_random_uuid(), %L, 'ORG-AFLOJA-1', 'afloja', %L, '["billing.payment.collect"]'::jsonb, '["billing.receipt.void"]'::jsonb,
    '0fb8d904-8d4c-5ff5-972e-b0968cadc699', '156a7df4-b47c-52d3-9646-9f201757db51', true,
    '38a1d301-f40d-5b17-a695-5e6d605f8b19', 1, now(), now())$q$, :'hosp', :'sod_bill_01'));   -- BLOQUEAR -> ADVERTIR
SELECT pg_temp.must_fail('5o', '23514', format($q$
  INSERT INTO delegated_access.sod_rules (id, tenant_id, code, name, base_rule_id, atoms_a_json, atoms_b_json, scope_concept_id, action_concept_id, is_hard,
    status_concept_id, version_number, created_at, updated_at)
  VALUES (gen_random_uuid(), %L, 'ORG-AFLOJA-2', 'afloja', %L, '["billing.payment.collect"]'::jsonb, '["billing.receipt.void"]'::jsonb,
    '0fb8d904-8d4c-5ff5-972e-b0968cadc699', 'd317a334-2e99-5361-836c-674cbeec5d26', false,
    '38a1d301-f40d-5b17-a695-5e6d605f8b19', 1, now(), now())$q$, :'hosp', :'sod_bill_01'));   -- misma acción pero sin «dura»
SELECT pg_temp.must_fail('5p', '23514', format($q$
  INSERT INTO delegated_access.sod_rules (id, tenant_id, code, name, base_rule_id, atoms_a_json, atoms_b_json, scope_concept_id, action_concept_id, is_hard,
    max_exception_days, status_concept_id, version_number, created_at, updated_at)
  VALUES (gen_random_uuid(), %L, 'ORG-AFLOJA-3', 'afloja', %L, '["agenda.appointment.create"]'::jsonb, '["billing.receipt.issue"]'::jsonb,
    '0fb8d904-8d4c-5ff5-972e-b0968cadc699', '117ffae4-a53b-5f5a-a927-d625ae57ad67', false, 120,
    '38a1d301-f40d-5b17-a695-5e6d605f8b19', 1, now(), now())$q$, :'hosp', :'sod_bill_03'));   -- la excepcion no puede durar mas (120 > 90 dias)
SELECT pg_temp.must_fail('5p2', '23514', format($q$
  INSERT INTO delegated_access.sod_rules (id, tenant_id, code, name, base_rule_id, atoms_a_json, atoms_b_json, scope_concept_id, action_concept_id, is_hard,
    status_concept_id, version_number, created_at, updated_at)
  VALUES (gen_random_uuid(), %L, 'ORG-AFLOJA-4', 'afloja', %L, '["agenda.appointment.create"]'::jsonb, '["billing.receipt.issue"]'::jsonb,
    '0fb8d904-8d4c-5ff5-972e-b0968cadc699', '156a7df4-b47c-52d3-9646-9f201757db51', false,
    '38a1d301-f40d-5b17-a695-5e6d605f8b19', 1, now(), now())$q$, :'hosp', :'sod_bill_03'));   -- EXIGIR APROBACION -> ADVERTIR
SELECT pg_temp.must_pass('5q', format($q$
  INSERT INTO delegated_access.sod_rules (id, tenant_id, code, name, base_rule_id, atoms_a_json, atoms_b_json, scope_concept_id, action_concept_id, is_hard,
    status_concept_id, version_number, created_at, updated_at)
  VALUES (gen_random_uuid(), %L, 'ORG-ENDURECE-1', 'endurece', %L, '["billing.discount.apply"]'::jsonb, '["billing.payment.collect"]'::jsonb,
    '0fb8d904-8d4c-5ff5-972e-b0968cadc699', 'd317a334-2e99-5361-836c-674cbeec5d26', true,
    '38a1d301-f40d-5b17-a695-5e6d605f8b19', 1, now(), now())$q$, :'hosp', :'sod_bill_04'));   -- ADVERTIR -> BLOQUEAR (duro): endurecer sí
SELECT pg_temp.must_fail('5p3', '23514', format($q$
  INSERT INTO delegated_access.sod_rules (id, tenant_id, code, name, base_rule_id, atoms_a_json, atoms_b_json, scope_concept_id, action_concept_id, is_hard,
    status_concept_id, version_number, created_at, updated_at)
  SELECT gen_random_uuid(), %L, 'ORG-BASE-AJENA', 'base de otra organizacion', s.id, '[]'::jsonb, '[]'::jsonb,
    '0fb8d904-8d4c-5ff5-972e-b0968cadc699', 'd317a334-2e99-5361-836c-674cbeec5d26', true, '38a1d301-f40d-5b17-a695-5e6d605f8b19', 1, now(), now()
    FROM delegated_access.sod_rules s WHERE s.tenant_id = %L LIMIT 1$q$, :'cons', :'hosp'));   -- la base debe ser de plataforma: una regla de la organizacion (5q) no sirve de base a la de otra
SELECT pg_temp.must_pass('5q2', format($q$
  INSERT INTO delegated_access.sod_rules (id, tenant_id, code, name, base_rule_id, atoms_a_json, atoms_b_json, scope_concept_id, action_concept_id, is_hard,
    status_concept_id, version_number, created_at, updated_at)
  VALUES (gen_random_uuid(), %L, 'ORG-IGUAL-1', 'igual de estricta', %L, '["billing.payment.collect"]'::jsonb, '["billing.receipt.void"]'::jsonb,
    '0fb8d904-8d4c-5ff5-972e-b0968cadc699', 'd317a334-2e99-5361-836c-674cbeec5d26', true,
    '38a1d301-f40d-5b17-a695-5e6d605f8b19', 1, now(), now())$q$, :'hosp', :'sod_bill_01'));   -- igual de estricta que la dura de plataforma: pasa
SELECT pg_temp.must_fail('5r', '23514', format($q$
  UPDATE delegated_access.sod_rules SET action_concept_id = '156a7df4-b47c-52d3-9646-9f201757db51', is_hard = false
   WHERE tenant_id = %L AND code = 'ORG-IGUAL-1'$q$, :'hosp'));   -- ni editandola despues para aflojarla
DO $g5$ BEGIN RAISE NOTICE 'G5 OK · los disparadores rechazan revisor = titular, tenants cruzados y reglas que aflojan a la de plataforma'; END $g5$;

-- ---------------------------------------------------------------- G6 · access_decision_log es WORM
SELECT pg_temp.must_pass('6a', format($q$
  INSERT INTO delegated_access.access_decision_log (id, tenant_id, user_id, permission_code, effect_concept_id, reason_code, recorded_at)
  VALUES ('00000000-0000-0000-0000-0000000000f9', %L, %L, 'agenda.appointment.cancel', '179b3675-742f-552c-b50e-4bba5c79262e', 'TIME_WINDOW', now())$q$, :'hosp', :'u_ana'));
SELECT pg_temp.must_fail('6b', '23001', $q$UPDATE delegated_access.access_decision_log SET reason_code = 'OTRO' WHERE id = '00000000-0000-0000-0000-0000000000f9'$q$);
SELECT pg_temp.must_fail('6c', '23001', $q$DELETE FROM delegated_access.access_decision_log WHERE id = '00000000-0000-0000-0000-0000000000f9'$q$);
DO $g6$
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'delegated_access' AND table_name = 'access_decision_log'
                  AND column_name IN ('updated_at', 'row_version')) THEN RAISE EXCEPTION 'G-6d FALLÓ: una tabla WORM no lleva updated_at ni row_version'; END IF;
    RAISE NOTICE 'G6 OK · access_decision_log rechaza UPDATE y DELETE (restrict_violation)';
END
$g6$;

-- ---------------------------------------------------------------- G7 · un DENY (o una acción reemplazada) NUNCA se materializa
-- Ana ya tiene concesiones ALLOW de 04. Se agregan: (1) una DENY sobre Pérez con un átomo, (2) una ALLOW con una acción vigente y otra
-- reemplazada por normalize-legacy (superseded_at). refresh_effective_support_access debe generar filas SOLO de lo vigente y ALLOW.
INSERT INTO delegated_access.support_scope_grants (id, tenant_id, organization_user_assignment_id, target_kind_concept_id, practitioner_role_assignment_id,
    expansion_mode_concept_id, status_concept_id, effect_concept_id, reason_text, created_at, updated_at)
VALUES ('00000000-0000-0000-0000-000000000071', :'hosp', :'oua_ana', '785d1671-5754-58d3-b1a3-e3cd467b82b7', :'pra_perez',
        'd9ed1dfe-f5e6-55f3-94f2-2bd60993a536', 'ccfbc54f-4744-53db-ab1f-abe1af31f784', 'b038e546-a6ba-5848-9cd2-04b02ccb22b0',
        'G7 · negar el motivo de consulta', now(), now()),
       ('00000000-0000-0000-0000-000000000072', :'hosp', :'oua_ana', '785d1671-5754-58d3-b1a3-e3cd467b82b7', :'pra_perez',
        'd9ed1dfe-f5e6-55f3-94f2-2bd60993a536', 'ccfbc54f-4744-53db-ab1f-abe1af31f784', '6905e0db-1650-5d49-adca-8b2688ac049c',
        'G7 · concesión con una acción reemplazada', now(), now());
INSERT INTO delegated_access.support_grant_actions (id, tenant_id, support_scope_grant_id, permission_id, created_at, superseded_at)
VALUES ('00000000-0000-0000-0000-000000000081', :'hosp', '00000000-0000-0000-0000-000000000071', :'perm_reason', now(), NULL),
       ('00000000-0000-0000-0000-000000000082', :'hosp', '00000000-0000-0000-0000-000000000071', :'perm_view', now(), NULL),
       ('00000000-0000-0000-0000-000000000083', :'hosp', '00000000-0000-0000-0000-000000000072', :'perm_cancel', now(), NULL),
       ('00000000-0000-0000-0000-000000000084', :'hosp', '00000000-0000-0000-0000-000000000072', :'perm_reason', now(), now());
SELECT delegated_access.refresh_effective_support_access(NULL);
DO $g7$
DECLARE n integer;
BEGIN
    SELECT count(*) INTO n FROM delegated_access.effective_support_access WHERE grant_id = '00000000-0000-0000-0000-000000000071';
    IF n <> 0 THEN RAISE EXCEPTION 'G-7a FALLÓ: una concesión DENY se materializó como permiso (% filas en effective_support_access)', n; END IF;
    SELECT count(*) INTO n FROM delegated_access.effective_support_access e
      JOIN delegated_access.support_scope_grants g ON g.id = e.grant_id
     WHERE g.effect_concept_id <> '6905e0db-1650-5d49-adca-8b2688ac049c';
    IF n <> 0 THEN RAISE EXCEPTION 'G-7b FALLÓ: % filas derivadas vienen de una concesión que no es ALLOW', n; END IF;
    SELECT count(*) INTO n FROM delegated_access.effective_support_access e WHERE e.grant_id = '00000000-0000-0000-0000-000000000072';
    IF n <> 1 THEN RAISE EXCEPTION 'G-7c FALLÓ: la concesión con una acción reemplazada debía dar 1 fila (solo la vigente) y dio %', n; END IF;
    IF NOT EXISTS (SELECT 1 FROM delegated_access.effective_support_access e WHERE e.grant_id = '00000000-0000-0000-0000-000000000072'
                      AND e.permission_code = 'agenda.appointment.cancel') THEN
        RAISE EXCEPTION 'G-7d FALLÓ: la acción vigente (cancelar) no se materializó'; END IF;
    IF EXISTS (SELECT 1 FROM delegated_access.effective_support_access e WHERE e.grant_id = '00000000-0000-0000-0000-000000000072'
                  AND e.permission_code = 'agenda.appointment.view.reason') THEN
        RAISE EXCEPTION 'G-7e FALLÓ: una acción reemplazada (superseded) se materializó'; END IF;
    -- lo ya existente de Ana sigue materializado (el filtro no vació la tabla)
    SELECT count(*) INTO n FROM delegated_access.effective_support_access e JOIN directory.tenant_memberships m ON m.user_id = e.user_id AND m.tenant_id = e.tenant_id
     JOIN iam.users u ON u.id = m.user_id WHERE u.display_name = 'Ana Gutiérrez' AND e.permission_code = 'schedule.view';
    IF n < 1 THEN RAISE EXCEPTION 'G-7f FALLÓ: las concesiones ALLOW de Ana ya no se materializan'; END IF;
    -- la referencia SQL no sabe de DENY: no los resta ni los suma (el motor de la API es la verdad); sigue permitiendo lo suyo
    RAISE NOTICE 'G7 OK · un DENY y una acción reemplazada nunca se materializan en effective_support_access; las ALLOW siguen igual';
END
$g7$;

-- ---------------------------------------------------------------- G8 · funciones nuevas
DO $g8$
DECLARE r record; n integer := 0;
BEGIN
    FOR r IN SELECT p.oid, p.proname, n.nspname, p.prosecdef, p.proconfig
               FROM pg_proc p JOIN pg_namespace n ON n.oid = p.pronamespace
              WHERE (n.nspname, p.proname) IN (('delegated_access', 'refresh_effective_support_access'),
                    ('integrity', 'support_tenant_consistency'), ('integrity', 'access_review_reviewer_not_subject'),
                    ('integrity', 'sod_rules_only_stricter'))
    LOOP
        IF r.prosecdef THEN RAISE EXCEPTION 'G-8a FALLÓ: %.% es SECURITY DEFINER', r.nspname, r.proname; END IF;
        IF r.proconfig IS NULL OR NOT EXISTS (SELECT 1 FROM unnest(r.proconfig) c WHERE c LIKE 'search_path=%pg_catalog%') THEN
            RAISE EXCEPTION 'G-8b FALLÓ: %.% no fija el search_path', r.nspname, r.proname; END IF;
        IF has_function_privilege('public', r.oid, 'EXECUTE') THEN
            RAISE EXCEPTION 'G-8c FALLÓ: %.% tiene EXECUTE para PUBLIC', r.nspname, r.proname; END IF;
        n := n + 1;
    END LOOP;
    IF n <> 4 THEN RAISE EXCEPTION 'G-8d FALLÓ: se esperaban 4 funciones y hay %', n; END IF;
    RAISE NOTICE 'G8 OK · 4 funciones con search_path fijo, sin SECURITY DEFINER y sin EXECUTE para PUBLIC';
END
$g8$;

-- ---------------------------------------------------------------- G9 · piloto extendido (07-gobierno-hospital-piloto.sql)
\if :pilot_gov
DO $g9$
DECLARE
    hosp uuid := (SELECT id FROM directory.tenants WHERE code = 'DEMO_HOSPITAL_PILOTO');
    n integer; r record;
    u_ricardo uuid; u_mario uuid; u_gonzalo uuid; u_marcos uuid; u_pablo uuid; u_nora uuid; u_admin uuid;
BEGIN
    SELECT id INTO u_ricardo FROM iam.users WHERE display_name = 'Ricardo Terceros';
    SELECT id INTO u_mario   FROM iam.users WHERE display_name = 'Mario Salvatierra';
    SELECT id INTO u_gonzalo FROM iam.users WHERE display_name = 'Gonzalo Pinto';
    SELECT id INTO u_marcos  FROM iam.users WHERE display_name = 'Marcos Ribera';
    SELECT id INTO u_pablo   FROM iam.users WHERE display_name = 'Pablo Mamani';
    SELECT id INTO u_nora    FROM iam.users WHERE display_name = 'Nora Villarroel';
    SELECT id INTO u_admin   FROM iam.users WHERE display_name = 'Administrador Hospital Piloto';
    -- personas: 6 cuentas nuevas, con ids del contrato; los dos administradores de seguridad
    IF (SELECT id FROM iam.users WHERE display_name = 'Sofía Camacho') <> '161a6e07-9098-52d4-82e9-d0485c5646a2' THEN
        RAISE EXCEPTION 'G-9a FALLÓ: el id de Sofía Camacho no es el del contrato'; END IF;
    SELECT count(*) INTO n FROM iam.users WHERE display_name IN ('Sofía Camacho', 'Ricardo Terceros', 'Mario Salvatierra', 'Nora Villarroel', 'Pablo Mamani', 'Gonzalo Pinto');
    IF n <> 6 THEN RAISE EXCEPTION 'G-9b FALLÓ: se esperaban 6 cuentas nuevas y hay %', n; END IF;
    SELECT count(*) INTO n FROM iam.user_global_roles g
     WHERE g.role_concept_id = '77b476d1-0600-54ba-9176-3670ab769435' AND g.user_id IN (u_gonzalo, u_admin);   -- iam:role:security-admin
    IF n <> 2 THEN RAISE EXCEPTION 'G-9c FALLÓ: Gonzalo y el administrador deben ser SECURITY_ADMIN (hay %)', n; END IF;
    -- pacientes: 7, tres con bandera; Sandra sin fecha de nacimiento; las citas no pasaron por una concesión
    SELECT count(*) INTO n FROM profiles.patient_profiles WHERE patient_code LIKE 'DEMO-GOV-P%';
    IF n <> 7 THEN RAISE EXCEPTION 'G-9d FALLÓ: se esperaban 7 pacientes ficticios y hay %', n; END IF;
    SELECT count(*) INTO n FROM delegated_access.patient_restriction_flags f JOIN terminology.catalog_concepts c ON c.id = f.flag_concept_id
     WHERE f.tenant_id = hosp AND c.code IN ('delegated_access:PATIENT_FLAG_VIP', 'delegated_access:PATIENT_FLAG_CONFIDENTIAL', 'delegated_access:PATIENT_FLAG_STAFF_RELATIVE');
    IF n <> 3 THEN RAISE EXCEPTION 'G-9e FALLÓ: se esperaban 3 banderas y hay %', n; END IF;
    IF (SELECT birth_date FROM profiles.persons WHERE display_name = 'Sandra Vargas') IS NOT NULL THEN RAISE EXCEPTION 'G-9f FALLÓ: Sandra no debe tener fecha de nacimiento'; END IF;
    IF (SELECT count(*) FROM insurance.patient_coverages c JOIN profiles.persons p ON p.id = c.patient_profile_id
         WHERE p.display_name IN ('Carmen Ortuño', 'Mateo Rivera')) <> 2
       OR EXISTS (SELECT 1 FROM insurance.patient_coverages c JOIN profiles.persons p ON p.id = c.patient_profile_id WHERE p.display_name = 'Luis Choque') THEN
        RAISE EXCEPTION 'G-9g FALLÓ: Carmen y Mateo con cobertura y Luis sin ella'; END IF;
    SELECT count(*) INTO n FROM scheduling.appointment_bookings b WHERE b.tenant_id = hosp AND b.booked_via_grant_id IS NULL
       AND b.patient_profile_id IN (SELECT profile_id FROM profiles.patient_profiles WHERE patient_code LIKE 'DEMO-GOV-P%');
    IF n <> 13 THEN RAISE EXCEPTION 'G-9h FALLÓ: se esperaban 13 citas (A1-A12 + la pendiente de Pablo) y hay %', n; END IF;
    -- campaña vencida: 6 ítems = 2 certificados, 1 revocado, 3 pendientes ya escalados; evidencia sellada
    SELECT count(*) INTO n FROM delegated_access.access_review_items i JOIN delegated_access.access_review_campaigns c ON c.id = i.access_review_campaign_id
     WHERE c.name = 'Certificación Q4-2026' AND c.tenant_id = hosp;
    IF n <> 6 THEN RAISE EXCEPTION 'G-9i FALLÓ: la campaña Q4-2026 debe tener 6 ítems y tiene %', n; END IF;
    FOR r IN SELECT * FROM (VALUES ('delegated_access:REVIEW_ITEM_CERTIFIED', 2), ('delegated_access:REVIEW_ITEM_REVOKED', 1), ('delegated_access:REVIEW_ITEM_PENDING', 3)) v(code, expected) LOOP
        SELECT count(*) INTO n FROM delegated_access.access_review_items i JOIN terminology.catalog_concepts d ON d.id = i.decision_concept_id
         JOIN delegated_access.access_review_campaigns c ON c.id = i.access_review_campaign_id WHERE c.name = 'Certificación Q4-2026' AND d.code = r.code;
        IF n <> r.expected THEN RAISE EXCEPTION 'G-9j FALLÓ: ítems % esperados %, hay %', r.code, r.expected, n; END IF;
    END LOOP;
    IF EXISTS (SELECT 1 FROM delegated_access.access_review_items i JOIN delegated_access.access_review_campaigns c ON c.id = i.access_review_campaign_id
                WHERE c.name = 'Certificación Q4-2026' AND i.decision_concept_id = '55a6db07-19e7-5bb4-978a-3d246492f49d'
                  AND (i.due_at <> timestamptz '2026-10-30 18:00:00-04' OR i.escalated_at IS NULL OR i.escalated_to_user_id IS NULL)) THEN
        RAISE EXCEPTION 'G-9k FALLÓ: los pendientes deben estar vencidos (2026-10-30) y escalados'; END IF;
    -- el ítem revocado apunta a un permiso realmente REVOCADO (no hay una campaña que diga una cosa y una concesión viva otra)
    IF NOT EXISTS (SELECT 1 FROM delegated_access.access_review_items i JOIN delegated_access.support_scope_grants g ON g.id = i.support_scope_grant_id
                    WHERE i.decision_concept_id = 'bce72e9a-b3bb-5fab-8e79-85d411ba692c' AND g.status_concept_id = '5cf6ef7d-3f5f-5864-93c8-eba9a9cd8af6') THEN
        RAISE EXCEPTION 'G-9l FALLÓ: el ítem REVOCADO debe apuntar a una concesión revocada'; END IF;
    -- cuatro ojos pendiente de Marcos (aprueba el doctor) y excepción SoD de Ricardo aprobada por OTRA persona
    IF (SELECT count(*) FROM delegated_access.four_eyes_requests WHERE tenant_id = hosp AND requester_user_id = u_marcos AND permission_code = 'agenda.appointment.cancel'
          AND status_concept_id = 'a977935a-9073-5113-9644-7df96732e776' AND approver_kind_concept_id = '1ec189f8-507a-5fce-9fac-09a584864c04') <> 1 THEN
        RAISE EXCEPTION 'G-9m FALLÓ: falta el cuatro ojos pendiente de Marcos (cancelar A4, aprobador: el doctor)'; END IF;
    IF NOT EXISTS (SELECT 1 FROM delegated_access.sod_exceptions x JOIN delegated_access.sod_rules s ON s.id = x.sod_rule_id JOIN delegated_access.four_eyes_requests f ON f.id = x.four_eyes_request_id
                    WHERE s.code = 'SOD-GOV-03' AND x.status_concept_id = '38a1d301-f40d-5b17-a695-5e6d605f8b19' AND x.valid_to = timestamptz '2026-12-31 23:59:59-04'
                      AND f.decided_by_user_id = u_gonzalo AND f.requester_user_id = u_admin AND f.decided_by_user_id <> f.requester_user_id) THEN
        RAISE EXCEPTION 'G-9n FALLÓ: la excepción SoD-GOV-03 de Ricardo (activa hasta 2026-12-31, aprobada por Gonzalo) no está'; END IF;
    -- Ricardo SÍ tiene el conflicto SOD-GOV-03 (administra el equipo y cobra) y su excepción lo cubre; Mario NO puede anular todavía
    IF NOT EXISTS (SELECT 1 FROM delegated_access.support_scope_grants g JOIN delegated_access.organization_user_assignments a ON a.id = g.organization_user_assignment_id
                     JOIN directory.tenant_memberships m ON m.id = a.tenant_membership_id JOIN delegated_access.support_grant_actions x ON x.support_scope_grant_id = g.id
                     JOIN authz.permissions p ON p.id = x.permission_id WHERE m.user_id = u_ricardo AND p.code = 'billing.payment.collect' AND x.superseded_at IS NULL)
       OR NOT EXISTS (SELECT 1 FROM delegated_access.support_scope_grants g JOIN delegated_access.organization_user_assignments a ON a.id = g.organization_user_assignment_id
                     JOIN directory.tenant_memberships m ON m.id = a.tenant_membership_id JOIN delegated_access.support_grant_actions x ON x.support_scope_grant_id = g.id
                     JOIN authz.permissions p ON p.id = x.permission_id WHERE m.user_id = u_ricardo AND p.code = 'team.grants.assign' AND x.superseded_at IS NULL) THEN
        RAISE EXCEPTION 'G-9o FALLÓ: Ricardo debe tener team.grants.assign y billing.payment.collect (el hallazgo SOD-GOV-03)'; END IF;
    IF EXISTS (SELECT 1 FROM delegated_access.support_scope_grants g JOIN delegated_access.organization_user_assignments a ON a.id = g.organization_user_assignment_id
                 JOIN directory.tenant_memberships m ON m.id = a.tenant_membership_id JOIN delegated_access.support_grant_actions x ON x.support_scope_grant_id = g.id
                 JOIN authz.permissions p ON p.id = x.permission_id WHERE m.user_id = u_mario AND p.code = 'billing.receipt.void') THEN
        RAISE EXCEPTION 'G-9p FALLÓ: Mario no debe tener billing.receipt.void (la prueba de SoD lo agrega)'; END IF;
    -- uso y anomalías
    IF (SELECT sum(permit_count) FROM delegated_access.grant_usage_stats WHERE tenant_id = hosp AND user_id = u_marcos AND permission_code = 'patients.search.exact') <> 18 THEN
        RAISE EXCEPTION 'G-9q FALLÓ: Marcos debe tener 18 búsquedas en la última hora'; END IF;
    SELECT count(*) INTO n FROM delegated_access.access_anomalies a JOIN terminology.catalog_concepts c ON c.id = a.kind_concept_id
     WHERE a.tenant_id = hosp AND a.status_concept_id = '5dc5d5c6-03af-5c50-9841-2559f959a180' AND a.user_id IN (u_marcos, u_pablo)
       AND c.code IN ('delegated_access:ANOMALY_SEARCH_SPIKE', 'delegated_access:ANOMALY_INACTIVE_ACCOUNT');
    IF n <> 2 THEN RAISE EXCEPTION 'G-9r FALLÓ: se esperaban 2 anomalías abiertas y hay %', n; END IF;
    -- ciclo de vida
    IF NOT EXISTS (SELECT 1 FROM delegated_access.lifecycle_cases l WHERE l.subject_user_id = u_mario AND l.kind_concept_id = 'c2a9a59d-c88c-5e87-9065-1e0e068c479d' AND l.status_concept_id = '4734035e-72cf-519f-8e27-e6cf25ba557f')
       OR NOT EXISTS (SELECT 1 FROM delegated_access.lifecycle_cases l WHERE l.subject_user_id = u_nora AND l.kind_concept_id = 'c2a9a59d-c88c-5e87-9065-1e0e068c479d' AND l.status_concept_id = '4f73e30c-25ba-52ff-969e-862e588cce13') THEN
        RAISE EXCEPTION 'G-9s FALLÓ: ingreso de Mario completo e ingreso de Nora abierto'; END IF;
    IF (SELECT supervisor_user_id FROM delegated_access.organization_user_assignments a JOIN directory.tenant_memberships m ON m.id = a.tenant_membership_id WHERE m.user_id = u_nora) IS NOT NULL THEN
        RAISE EXCEPTION 'G-9t FALLÓ: Nora no debe tener dueño de cuenta'; END IF;
    -- reglas de la organización, ajustes y red
    SELECT count(*) INTO n FROM delegated_access.governance_rules gr JOIN terminology.catalog_concepts c ON c.id = gr.rule_kind_concept_id
     WHERE gr.tenant_id = hosp AND gr.permission_pattern IN ('billing.*', 'agenda.appointment.view.patient_document') AND c.code IN ('delegated_access:GOV_RULE_CEILING', 'delegated_access:GOV_RULE_REQUIRE_CONDITION', 'delegated_access:GOV_RULE_FIELD_FLOOR');
    IF n <> 3 THEN RAISE EXCEPTION 'G-9u FALLÓ: se esperaban 3 reglas de la organización y hay %', n; END IF;
    IF NOT EXISTS (SELECT 1 FROM practice.practice_settings s JOIN practice.practices p ON p.id = s.practice_id
                    WHERE p.tenant_id = hosp AND s.setting_key = 'support.governance' AND (s.value_json ->> 'creepThreshold')::int = 15
                      AND (s.value_json ->> 'inactivityDays')::int = 45 AND (s.value_json ->> 'onboardingRequired')::boolean) THEN
        RAISE EXCEPTION 'G-9v FALLÓ: falta el ajuste support.governance del hospital'; END IF;
    IF NOT EXISTS (SELECT 1 FROM authz.ip_access_rules WHERE tenant_id = hosp AND cidr = '192.0.2.0/24') THEN RAISE EXCEPTION 'G-9w FALLÓ: falta la regla de red ALLOW 192.0.2.0/24'; END IF;
    -- Ana: la DENY sobre Rojas existe y NO se materializa; los átomos con condiciones se SUMARON a las filas alias (las filas alias siguen vivas)
    IF NOT EXISTS (SELECT 1 FROM delegated_access.support_scope_grants g WHERE g.tenant_id = hosp AND g.effect_concept_id = 'b038e546-a6ba-5848-9cd2-04b02ccb22b0'
                      AND g.reason_text LIKE 'Negar el motivo de consulta%' AND g.condition_json -> 'patients' -> 'flags' ? 'anyOf') THEN
        RAISE EXCEPTION 'G-9x FALLÓ: falta la concesión DENY de Ana sobre Rojas'; END IF;
    PERFORM delegated_access.refresh_effective_support_access(hosp);
    IF EXISTS (SELECT 1 FROM delegated_access.effective_support_access e JOIN delegated_access.support_scope_grants g ON g.id = e.grant_id
                WHERE e.tenant_id = hosp AND g.effect_concept_id = 'b038e546-a6ba-5848-9cd2-04b02ccb22b0') THEN
        RAISE EXCEPTION 'G-9y FALLÓ: la DENY de Ana sobre Rojas se materializó como permiso'; END IF;
    SELECT count(*) INTO n FROM delegated_access.support_grant_actions x JOIN authz.permissions p ON p.id = x.permission_id
     WHERE x.support_scope_grant_id = (SELECT id FROM delegated_access.support_scope_grants WHERE reason_text LIKE 'Paquete v2 de secretaría con condiciones%')
       AND p.code ~ '^[a-z_]+(\.[a-z_]+){2,3}$';
    IF n <> 20 THEN RAISE EXCEPTION 'G-9z FALLÓ: Ana×Rojas debe traer los 20 átomos del paquete v2 de secretaría (hay %)', n; END IF;
    IF (SELECT count(*) FROM delegated_access.support_grant_actions x WHERE x.support_scope_grant_id = (SELECT id FROM delegated_access.support_scope_grants WHERE reason_text LIKE 'Paquete v2 de secretaría con condiciones%')
          AND x.condition_json IS NOT NULL) <> 2 THEN RAISE EXCEPTION 'G-9z2 FALLÓ: Ana×Rojas lleva condiciones en view.reason y cancel'; END IF;
    -- el trabajo que Pablo deja pendiente: 3 conversaciones, 2 tareas abiertas y 1 cita creada por él; sin uso hace 70 días
    IF (SELECT count(*) FROM community.conversation_assignments WHERE tenant_id = hosp AND assigned_user_id = u_pablo) <> 3
       OR (SELECT count(*) FROM workflow.workflow_tasks WHERE assigned_user_id = u_pablo AND status_concept_id = '4778c049-011c-5e91-9bd6-1e6bf8a0a42c') <> 2
       OR (SELECT count(*) FROM scheduling.appointment_bookings WHERE tenant_id = hosp AND booked_by_user_id = u_pablo
              AND status_concept_id = 'de6bce1b-8b85-5edb-bea0-3994b5245d27') <> 1 THEN   -- scheduling:BOOKING_PENDING_CONFIRMATION (lo que busca el traspaso)
        RAISE EXCEPTION 'G-9z3 FALLÓ: Pablo debe dejar 3 conversaciones, 2 tareas y 1 cita PENDIENTE DE CONFIRMAR'; END IF;
    IF (SELECT last_active_at FROM delegated_access.organization_user_assignments a JOIN directory.tenant_memberships m ON m.id = a.tenant_membership_id WHERE m.user_id = u_pablo)
         > timestamptz '2026-11-03 10:30:00-04' - interval '60 days' THEN RAISE EXCEPTION 'G-9z4 FALLÓ: Pablo debe llevar más de 60 días sin uso'; END IF;
    -- aceptaciones del doctor de las 5 personas nuevas
    SELECT count(*) INTO n FROM delegated_access.practitioner_delegate_assignments d JOIN delegated_access.organization_user_assignments a ON a.id = d.delegate_user_assignment_id
      JOIN directory.tenant_memberships m ON m.id = a.tenant_membership_id
     WHERE m.user_id IN (SELECT id FROM iam.users WHERE display_name IN ('Sofía Camacho', 'Ricardo Terceros', 'Mario Salvatierra', 'Nora Villarroel', 'Pablo Mamani')) AND d.accepted_at IS NOT NULL;
    IF n <> 13 THEN RAISE EXCEPTION 'G-9z5 FALLÓ: se esperaban 13 aceptaciones del doctor (2+3+5+1+2) y hay %', n; END IF;
    -- G-9y · correcciones del demo para el smoke y el recorrido real de la API (B7d). Cada una dice qué precondición exige: si la base ya se USÓ
    -- (la API recertificó a Ana, movió la cita A4, etc.) falla con «PRECONDICIÓN DEL DEMO NO CUMPLIDA» y se arregla recargando 04 → 07 → 09 en una base limpia.
    -- (1) las agendas nombran la tabla de perfiles como la reconoce la API (PRACTITIONER_PROFILE_TABLES); con el nombre calificado
    --     `profiles.health_practitioner_profiles` la política de agenda no encuentra al doctor de la cita y todo da DOCTOR_NOT_ACCEPTED
    SELECT count(*) INTO n FROM scheduling.schedulable_resources WHERE tenant_id = hosp AND name LIKE 'Agenda % (DEMO)';
    IF n < 5 THEN RAISE EXCEPTION 'G-9y1 PRECONDICIÓN DEL DEMO NO CUMPLIDA: se esperaban al menos las 5 agendas de 07 y hay %', n; END IF;
    SELECT count(*) INTO n FROM scheduling.schedulable_resources rs
     WHERE rs.tenant_id = hosp AND rs.name LIKE 'Agenda % (DEMO)'
       AND (rs.resource_ref_type NOT IN ('health_practitioner_profiles', 'practitioner_profiles')
            OR NOT EXISTS (SELECT 1 FROM profiles.health_practitioner_profiles hp WHERE hp.profile_id = rs.resource_ref_id));
    IF n <> 0 THEN RAISE EXCEPTION 'G-9y1 FALLÓ: % agendas del piloto con resource_ref_type que la API no reconoce (usar health_practitioner_profiles) o que no apuntan a un perfil de profesional', n; END IF;
    -- (2) A4 (Mateo con Suárez, mañana 09:00) en N102 de la Sede Norte: el único lugar que cubre el permiso «Suárez × Sede Norte» de Marcos
    --     (caso 08 del contrato: Suárez en el Edificio B queda negado). Reserva Y cupo deben estar en el mismo espacio.
    SELECT count(*) INTO n
      FROM scheduling.appointment_bookings b
      JOIN scheduling.bookable_slots s ON s.id = b.bookable_slot_id
      JOIN practice.care_spaces cs ON cs.id = b.care_space_id
      JOIN delegated_access.support_scope_grants g ON g.id = '2af9f387-d337-5ea7-bedf-716967fd740d' AND g.practice_site_id = cs.practice_site_id
     WHERE b.id = '02d06e6c-3f9f-5a58-bc4c-362aeb6c6861'
       AND b.care_space_id = '709a4334-ae78-569c-bc24-755f2be12403' AND s.care_space_id = b.care_space_id;
    IF n <> 1 THEN RAISE EXCEPTION 'G-9y2 FALLÓ: la cita A4 (y su cupo) debe estar en el consultorio N102 de la Sede Norte, que cubre el permiso Suárez × Sede Norte de Marcos'; END IF;
    -- (3) el vínculo de Nora es POSTERIOR a `onboardingRequiredSince`, y por eso la compuerta de ingreso la alcanza (L-06, caso 35)
    SELECT count(*) INTO n
      FROM delegated_access.organization_user_assignments a
      JOIN directory.tenant_memberships m ON m.id = a.tenant_membership_id AND m.tenant_id = hosp AND m.user_id = u_nora
      JOIN practice.practice_settings ps ON ps.setting_key = 'support.governance' AND ps.practice_id = '314eeab4-0062-5e4f-b3f1-4e26174daa10'
     WHERE a.onboarding_completed_at IS NULL
       AND a.created_at >= (ps.value_json ->> 'onboardingRequiredSince')::timestamptz;
    IF n <> 1 THEN RAISE EXCEPTION 'G-9y3 FALLÓ: el vínculo de Nora debe tener created_at >= onboardingRequiredSince y la incorporación sin terminar (precondición: Nora sin completar; si la API la completó, recargue 07 en una base limpia)'; END IF;
    -- (4) K-04 (caso 28): Ana vence su recertificación el 2026-11-23
    IF (SELECT a.next_recertification_at FROM delegated_access.organization_user_assignments a WHERE a.id = '9f1761b6-e456-5a99-bf11-d14b05077d4f')
         IS DISTINCT FROM timestamptz '2026-11-23 10:00:00-04' THEN
        RAISE EXCEPTION 'G-9y4 FALLÓ: Ana debe tener next_recertification_at = 2026-11-23 10:00 (America/La_Paz); precondición: nadie la recertificó (si la API lo hizo, recargue 04 → 07 en una base limpia)'; END IF;
    RAISE NOTICE 'G9 OK · piloto extendido: 6 cuentas, 7 pacientes (3 con bandera), 13 citas, campaña Q4-2026 (2/1/3), cuatro ojos pendiente, excepción SoD, uso, 2 anomalías, ciclo de vida, reglas L1 y las 4 correcciones del demo (agendas con tabla reconocida por la API, A4 en N102, Nora posterior a la compuerta, Ana vence el 2026-11-23)';
END
$g9$;
\else
\echo G9 OMITIDA · el piloto de gobierno (07-gobierno-hospital-piloto.sql) no está cargado
\endif

-- ---------------------------------------------------------------- G10 · RLS de las tablas nuevas con el rol de la aplicación
\if :rls_on
\if :has_app
CREATE FUNCTION pg_temp.count_as_app(p_table text, p_tenant text) RETURNS integer LANGUAGE plpgsql AS $f$
DECLARE n integer;
BEGIN
    PERFORM set_config('app.current_tenant_id', p_tenant, true);
    SET LOCAL ROLE mantra_app;
    EXECUTE format('SELECT count(*) FROM delegated_access.%I', p_table) INTO n;
    RESET ROLE;
    PERFORM set_config('app.current_tenant_id', '', true);
    RETURN n;
END
$f$;
CREATE FUNCTION pg_temp.as_app_state(p_label text, p_state text, p_tenant text, p_sql text) RETURNS void LANGUAGE plpgsql AS $f$
BEGIN
    PERFORM set_config('app.current_tenant_id', p_tenant, true);
    SET LOCAL ROLE mantra_app;
    BEGIN
        EXECUTE p_sql;
    EXCEPTION WHEN OTHERS THEN
        RESET ROLE;
        PERFORM set_config('app.current_tenant_id', '', true);
        IF SQLSTATE = p_state THEN RETURN; END IF;
        RAISE EXCEPTION 'G-% FALLÓ: se esperaba SQLSTATE % y llegó % (%)', p_label, p_state, SQLSTATE, SQLERRM;
    END;
    RESET ROLE;
    PERFORM set_config('app.current_tenant_id', '', true);
    RAISE EXCEPTION 'G-% FALLÓ: debía rechazarse con SQLSTATE %', p_label, p_state;
END
$f$;
DO $g10$
DECLARE
    hosp text := (SELECT id::text FROM directory.tenants WHERE code = 'DEMO_HOSPITAL_PILOTO');
    cons text := (SELECT id::text FROM directory.tenants WHERE code = 'DEMO_CONSULTORIO_CESPEDES');
    r record; total integer; n_h integer; n_c integer;
BEGIN
    FOR r IN SELECT t FROM (VALUES ('governance_rules'), ('sod_exceptions'), ('four_eyes_requests'), ('access_review_campaigns'), ('access_review_items'),
                                   ('lifecycle_cases'), ('handover_items'), ('patient_restriction_flags'), ('access_decision_log'), ('grant_usage_stats'),
                                   ('access_anomalies'), ('organization_user_assignments'), ('practitioner_delegate_assignments')) v(t)
    LOOP
        EXECUTE format('SELECT count(*) FROM delegated_access.%I', r.t) INTO total;
        EXECUTE format('SELECT count(*) FROM delegated_access.%I WHERE tenant_id = %L', r.t, hosp) INTO n_h;
        EXECUTE format('SELECT count(*) FROM delegated_access.%I WHERE tenant_id = %L', r.t, cons) INTO n_c;
        IF pg_temp.count_as_app(r.t, hosp) <> n_h THEN RAISE EXCEPTION 'G-10a FALLÓ: % — con el contexto del hospital mantra_app no ve exactamente sus % filas', r.t, n_h; END IF;
        IF pg_temp.count_as_app(r.t, cons) <> n_c THEN RAISE EXCEPTION 'G-10b FALLÓ: % — con el contexto del consultorio mantra_app no ve exactamente sus % filas', r.t, n_c; END IF;
        IF pg_temp.count_as_app(r.t, '') <> 0 THEN RAISE EXCEPTION 'G-10c FALLÓ: % — sin contexto de organización mantra_app debe ver 0 filas (falla cerrada)', r.t; END IF;
    END LOOP;
    -- las reglas SoD de PLATAFORMA (tenant NULL) las ve cualquier organización; sin contexto, solo las de plataforma; las de otra organización, nunca
    IF pg_temp.count_as_app('sod_rules', cons) < 11 THEN RAISE EXCEPTION 'G-10d FALLÓ: el consultorio debe ver las 11 reglas SoD de plataforma'; END IF;
    IF EXISTS (SELECT 1 FROM delegated_access.sod_rules WHERE tenant_id = hosp::uuid) AND
       pg_temp.count_as_app('sod_rules', cons) <> (SELECT count(*) FROM delegated_access.sod_rules WHERE tenant_id IS NULL OR tenant_id = cons::uuid) THEN
        RAISE EXCEPTION 'G-10e FALLÓ: el consultorio ve reglas SoD de otra organización'; END IF;
    -- escribir en otra organización (o una regla de plataforma) lo rechaza la política (42501)
    PERFORM pg_temp.as_app_state('10f', '42501', cons, format($q$
      INSERT INTO delegated_access.governance_rules (id, tenant_id, rule_kind_concept_id, permission_pattern, status_concept_id, created_at, updated_at)
      VALUES (gen_random_uuid(), %L, '2e3f3830-b5cc-5661-902e-9106df223081', 'billing.*', '38a1d301-f40d-5b17-a695-5e6d605f8b19', now(), now())$q$, hosp));
    PERFORM pg_temp.as_app_state('10g', '42501', cons, $q$
      INSERT INTO delegated_access.sod_rules (id, tenant_id, code, name, atoms_a_json, atoms_b_json, scope_concept_id, action_concept_id, status_concept_id, version_number, created_at, updated_at)
      VALUES (gen_random_uuid(), NULL, 'PLATAFORMA-FALSA', 'una organizacion no escribe reglas de plataforma', '[]'::jsonb, '[]'::jsonb,
        '0fb8d904-8d4c-5ff5-972e-b0968cadc699', '156a7df4-b47c-52d3-9646-9f201757db51', '38a1d301-f40d-5b17-a695-5e6d605f8b19', 1, now(), now())$q$);
    RAISE NOTICE 'G10 OK · con RLS, mantra_app ve solo su organización en las 11 tablas con tenant, ve las reglas SoD de plataforma y no escribe en otra organización ni en la plataforma';
END
$g10$;
\else
\echo G10 OMITIDA · no existe el rol mantra_app
\endif
\else
\echo G10 OMITIDA · la base no usa RLS todavía
\endif

-- ---------------------------------------------------------------- G11 · revisión de seguridad ronda 1 (v4.2.79)
-- A-M1: tenant_id NOT NULL con FK en las dos tablas que colgaban solo de la membresía / del set
DO $g11a$
DECLARE r record;
BEGIN
    FOR r IN SELECT t FROM (VALUES ('organization_user_assignments'), ('practitioner_delegate_assignments')) v(t) LOOP
        IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'delegated_access' AND table_name = r.t
                          AND column_name = 'tenant_id' AND is_nullable = 'NO' AND data_type = 'uuid') THEN
            RAISE EXCEPTION 'G-11a FALLÓ: % sin tenant_id uuid NOT NULL (¿falta el parche v4279?)', r.t; END IF;
        IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conrelid = format('delegated_access.%I', r.t)::regclass AND contype = 'f'
                          AND confrelid = 'directory.tenants'::regclass) THEN
            RAISE EXCEPTION 'G-11b FALLÓ: % sin FK de tenant_id a directory.tenants', r.t; END IF;
        IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgrelid = format('delegated_access.%I', r.t)::regclass AND tgname = 'trg_support_tenant_consistency') THEN
            RAISE EXCEPTION 'G-11c FALLÓ: % sin disparador de consistencia de tenant', r.t; END IF;
        IF NOT (SELECT c.relrowsecurity AND c.relforcerowsecurity FROM pg_class c WHERE c.oid = format('delegated_access.%I', r.t)::regclass)
           OR NOT EXISTS (SELECT 1 FROM pg_policies WHERE schemaname = 'delegated_access' AND tablename = r.t AND policyname = 'tenant_isolation') THEN
            RAISE EXCEPTION 'G-11d FALLÓ: % sin RLS forzado + tenant_isolation', r.t; END IF;
    END LOOP;
END
$g11a$;
-- el tenant del vínculo debe ser el de su membresía: otro tenant = 23514
SELECT pg_temp.must_fail('11e', '23514', format($q$
  INSERT INTO delegated_access.organization_user_assignments (id, tenant_id, tenant_membership_id, assignment_role_concept_id, access_scope_concept_id, status_concept_id, created_at, updated_at)
  SELECT gen_random_uuid(), t.id, a.tenant_membership_id, a.assignment_role_concept_id, a.access_scope_concept_id, a.status_concept_id, now(), now()
    FROM delegated_access.organization_user_assignments a, directory.tenants t
   WHERE a.id = '9f1761b6-e456-5a99-bf11-d14b05077d4f' AND t.code = 'DEMO_CONSULTORIO_CESPEDES'$q$));
-- un nodo de alcance de otra organización (sede del consultorio en un vínculo del hospital) = 23514
SELECT pg_temp.must_fail('11f', '23514', format($q$
  INSERT INTO delegated_access.organization_user_assignments (id, tenant_id, tenant_membership_id, assignment_role_concept_id, access_scope_concept_id, status_concept_id, practice_site_id, created_at, updated_at)
  SELECT gen_random_uuid(), a.tenant_id, a.tenant_membership_id, a.assignment_role_concept_id, a.access_scope_concept_id, a.status_concept_id,
         (SELECT ps.id FROM practice.practice_sites ps JOIN practice.practices p ON p.id = ps.practice_id JOIN directory.tenants t ON t.id = p.tenant_id
           WHERE t.code = 'DEMO_CONSULTORIO_CESPEDES' LIMIT 1), now(), now()
    FROM delegated_access.organization_user_assignments a WHERE a.id = '9f1761b6-e456-5a99-bf11-d14b05077d4f'$q$));
-- la delegación debe ser del tenant de su set (y de su vínculo y su doctor): otro tenant = 23514
SELECT pg_temp.must_fail('11g', '23514', format($q$
  INSERT INTO delegated_access.practitioner_delegate_assignments (id, tenant_id, practitioner_role_assignment_id, delegate_user_assignment_id, delegated_permission_set_id,
    delegate_role_concept_id, status_concept_id, created_at, updated_at)
  SELECT gen_random_uuid(), t.id, d.practitioner_role_assignment_id, d.delegate_user_assignment_id, d.delegated_permission_set_id, d.delegate_role_concept_id,
         d.status_concept_id, now(), now()
    FROM delegated_access.practitioner_delegate_assignments d, directory.tenants t
   WHERE d.id = '011a9583-44f5-5554-962c-c0acd1402218' AND t.code = 'DEMO_CONSULTORIO_CESPEDES'$q$));
-- A-B2: la bitácora WORM tampoco admite TRUNCATE (23001), ni siquiera de su dueño
SELECT pg_temp.must_fail('11h', '23001', 'TRUNCATE delegated_access.access_decision_log');
DO $g11b$
BEGIN
    IF EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'mantra_app') AND (
           has_table_privilege('mantra_app', 'delegated_access.access_decision_log', 'UPDATE')
        OR has_table_privilege('mantra_app', 'delegated_access.access_decision_log', 'DELETE')
        OR has_table_privilege('mantra_app', 'delegated_access.access_decision_log', 'TRUNCATE')) THEN
        RAISE EXCEPTION 'G-11i FALLÓ: mantra_app conserva UPDATE, DELETE o TRUNCATE sobre access_decision_log'; END IF;
END
$g11b$;
-- A-B6: support_access_allowed respeta un DENY vivo (y una concesión pasada a DENY sin refrescar la derivada). Solo si el piloto base está cargado.
DO $g11c$
DECLARE
    hosp uuid := (SELECT id FROM directory.tenants WHERE code = 'DEMO_HOSPITAL_PILOTO');
    ana uuid := (SELECT m.user_id FROM delegated_access.organization_user_assignments a JOIN directory.tenant_memberships m ON m.id = a.tenant_membership_id
                  WHERE a.id = '9f1761b6-e456-5a99-bf11-d14b05077d4f');
    perez uuid := 'f4e4d910-002f-5a42-a3fa-8696220f940b';
    before boolean; after_deny boolean; after_flip boolean; g uuid;
BEGIN
    IF hosp IS NULL OR ana IS NULL THEN RAISE NOTICE 'G11c OMITIDA · el piloto base (04) no está cargado'; RETURN; END IF;
    PERFORM set_config('app.system_context', 'true', true);
    before := delegated_access.support_access_allowed(ana, hosp, 'schedule.walk_in', perez);
    IF before IS NOT TRUE THEN RAISE NOTICE 'G11c OMITIDA · Ana no tiene schedule.walk_in sobre Pérez en esta base'; RETURN; END IF;
    g := gen_random_uuid();
    INSERT INTO delegated_access.support_scope_grants (id, tenant_id, organization_user_assignment_id, target_kind_concept_id, practitioner_role_assignment_id,
        expansion_mode_concept_id, valid_from, status_concept_id, created_at, updated_at, effect_concept_id)
    SELECT g, tenant_id, organization_user_assignment_id, target_kind_concept_id, practitioner_role_assignment_id, expansion_mode_concept_id,
           now() - interval '1 minute', status_concept_id, now(), now(), 'b038e546-a6ba-5848-9cd2-04b02ccb22b0'
      FROM delegated_access.support_scope_grants WHERE id = '656e1227-25d4-5369-bf7d-7a87b9cfa812';
    INSERT INTO delegated_access.support_grant_actions (id, tenant_id, support_scope_grant_id, permission_id, created_at)
    SELECT gen_random_uuid(), hosp, g, id, now() FROM authz.permissions WHERE code = 'schedule.walk_in';
    after_deny := delegated_access.support_access_allowed(ana, hosp, 'schedule.walk_in', perez);
    IF after_deny THEN RAISE EXCEPTION 'G-11j FALLÓ: support_access_allowed ignora una concesión DENY viva'; END IF;
    DELETE FROM delegated_access.support_grant_actions WHERE support_scope_grant_id = g;
    DELETE FROM delegated_access.support_scope_grants WHERE id = g;
    UPDATE delegated_access.support_scope_grants SET effect_concept_id = 'b038e546-a6ba-5848-9cd2-04b02ccb22b0' WHERE id = '656e1227-25d4-5369-bf7d-7a87b9cfa812';
    after_flip := delegated_access.support_access_allowed(ana, hosp, 'schedule.walk_in', perez);
    IF after_flip THEN RAISE EXCEPTION 'G-11k FALLÓ: support_access_allowed permite una concesión que ya es DENY (derivada sin refrescar)'; END IF;
    RAISE NOTICE 'G11 OK · tenant_id + disparador + RLS en las 2 tablas, TRUNCATE y privilegios de la bitácora WORM, DENY respetado por la referencia';
END
$g11c$;

ROLLBACK;
