-- Verificación del ENDURECIMIENTO v4.2.70 del personal de apoyo (revisión de seguridad M1, M5, M6, M8, A5).
--
-- Requiere: el esquema (apply_all + apply_deferred), el parche SQL/patches/2026-10-30_v4269_personal_apoyo.sql y los datos
-- de 04-hospital-piloto.sql (corrido con -v demo_accounts=1). Cada comprobación INTENTA la violación y exige que la base la
-- rechace con el SQLSTATE esperado (o que lo legítimo pase). Falla con una excepción «H-xx FALLÓ» en la primera que no.
-- Todo corre dentro de una transacción que se DESHACE (ROLLBACK): no deja nada.
--
--   H1  tenant_id NOT NULL + FK a directory.tenants + índice en las 7 tablas hijas
--   H2  el tenant del hijo debe ser el del padre (disparador integrity.support_tenant_consistency)
--   H3  un permiso FIXED exige foto con filas no vacías y claves válidas (M6)
--   H4  índices únicos parciales: política de sesión activa, vínculo activo, uso aceptado, membresía activa (A5/M1)
--   H5  horario de la política de sesión: forma (CHECK) y zona horaria (disparador) (A5)
--   H6  funciones: search_path fijo y sin EXECUTE para PUBLIC (M8)
--   H7  refresh_effective_support_access: NULL (todas las organizaciones) y tenant ajeno exigen contexto de sistema (M8)
--   H8  con RLS activo, el rol de la aplicación no cruza organizaciones (solo si la base ya usa RLS)
--   H9  v4.2.71 · tenant_memberships.origin_concept_id: columna uuid NULL + FK al catálogo + índice (N10)
--   H10 v4.2.71 · documento nacional ACTIVO de paciente único en su forma canónica; lo que debe poder repetirse, pasa (N3)
--
-- Uso:  psql -v ON_ERROR_STOP=1 -d <base> -f salud-db/demo/06-verifica-hardening.sql

BEGIN;

CREATE FUNCTION pg_temp.must_fail(p_label text, p_state text, p_sql text) RETURNS void LANGUAGE plpgsql AS $f$
BEGIN
    BEGIN
        EXECUTE p_sql;
    EXCEPTION WHEN OTHERS THEN
        IF SQLSTATE = p_state THEN RETURN; END IF;
        RAISE EXCEPTION 'H-% FALLÓ: se esperaba SQLSTATE % y llegó % (%)', p_label, p_state, SQLSTATE, SQLERRM;
    END;
    RAISE EXCEPTION 'H-% FALLÓ: la sentencia debía ser rechazada con SQLSTATE %', p_label, p_state;
END
$f$;

CREATE FUNCTION pg_temp.must_pass(p_label text, p_sql text) RETURNS void LANGUAGE plpgsql AS $f$
BEGIN
    EXECUTE p_sql;
EXCEPTION WHEN OTHERS THEN
    RAISE EXCEPTION 'H-% FALLÓ: la sentencia legítima fue rechazada (SQLSTATE %: %)', p_label, SQLSTATE, SQLERRM;
END
$f$;

-- Los SELECT pg_temp.must_* devuelven una fila vacía por comprobación: se descartan (los \echo y los avisos siguen saliendo).
\o /dev/null

-- Datos del hospital piloto y del consultorio, como variables psql.
SELECT
  (SELECT id FROM directory.tenants WHERE code = 'DEMO_HOSPITAL_PILOTO') AS hosp,
  (SELECT id FROM directory.tenants WHERE code = 'DEMO_CONSULTORIO_CESPEDES') AS cons,
  (SELECT m.user_id FROM directory.tenant_memberships m JOIN iam.users u ON u.id = m.user_id
    WHERE u.display_name = 'Ana Gutiérrez') AS u_ana,
  (SELECT m.user_id FROM directory.tenant_memberships m JOIN iam.users u ON u.id = m.user_id
    WHERE u.display_name = 'Marcos Ribera') AS u_marcos,
  (SELECT a.id FROM delegated_access.organization_user_assignments a
     JOIN directory.tenant_memberships m ON m.id = a.tenant_membership_id
     JOIN iam.users u ON u.id = m.user_id WHERE u.display_name = 'Ana Gutiérrez') AS oua_ana,
  (SELECT r.id FROM practice.practitioner_role_assignments r JOIN profiles.persons p ON p.id = r.practitioner_profile_id
    WHERE p.display_name = 'Andrés Pérez') AS pra_perez,
  (SELECT r.practitioner_profile_id FROM practice.practitioner_role_assignments r JOIN profiles.persons p ON p.id = r.practitioner_profile_id
    WHERE p.display_name = 'Andrés Pérez') AS prof_perez,
  (SELECT r.id FROM practice.practitioner_role_assignments r JOIN profiles.persons p ON p.id = r.practitioner_profile_id
    WHERE p.display_name = 'Paola Céspedes') AS pra_cespedes,
  (SELECT id FROM practice.care_spaces WHERE code = 'DEMO_A_108') AS sp_hosp,
  (SELECT id FROM practice.care_spaces WHERE code = 'DEMO_K_1') AS sp_cons,
  (SELECT id FROM authz.permissions WHERE code = 'schedule.view') AS perm_view,
  (SELECT id FROM delegated_access.role_templates WHERE tenant_id IS NULL AND code = 'SECRETARY' AND version_number = 1) AS tpl_secretary,
  (SELECT id FROM directory.affiliation_invitations WHERE tenant_id = (SELECT id FROM directory.tenants WHERE code = 'DEMO_HOSPITAL_PILOTO') LIMIT 1) AS inv_hosp,
  EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'mantra_app')
    AND has_schema_privilege('mantra_app', 'delegated_access', 'USAGE') AND has_schema_privilege('mantra_app', 'directory', 'USAGE')
    AND has_schema_privilege('mantra_app', 'practice', 'USAGE') AS has_app,   -- v4.2.73: el rol existe pero sin los GRANT de 2026-08-05_tenant_rls.sql no sirve para probar
  COALESCE((SELECT c.relrowsecurity FROM pg_class c WHERE c.oid = 'delegated_access.support_scope_grants'::regclass), false) AS rls_on
\gset

-- ---------------------------------------------------------------- H0 (precondición)
-- Los controles H-4h y las altas de H2 copian el vínculo de Ana: si alguien lo dio de baja (REVOCADO, membresía terminada) por la API o el front,
-- la copia nace «revocada» y el único parcial no se viola, o la comprobación falla con un mensaje engañoso. La causa es una base contaminada, no el modelo.
DO $h0$
DECLARE dead text;
BEGIN
    SELECT string_agg(x.quien, ', ' ORDER BY x.quien) INTO dead
      FROM (VALUES ('Ana Gutiérrez'), ('Marcos Ribera')) AS x(quien)
     WHERE NOT EXISTS (SELECT 1 FROM iam.users u
                         JOIN directory.tenant_memberships m ON m.user_id = u.id
                         JOIN delegated_access.organization_user_assignments a ON a.tenant_membership_id = m.id
                        WHERE u.display_name = x.quien
                          AND a.status_concept_id = '38a1d301-f40d-5b17-a695-5e6d605f8b19'        -- state:active
                          AND m.status_concept_id <> '76d35f5f-5140-55be-9853-ee1dfe6a12fd'       -- directory:MEMBERSHIP_ENDED
                          AND (m.end_date IS NULL OR m.end_date > now()));
    IF dead IS NOT NULL THEN
        RAISE EXCEPTION 'PRECONDICIÓN DEL DEMO NO CUMPLIDA: el vínculo de apoyo de % ya no está vivo (revocado o con membresía terminada). La base fue usada o modificada después de cargar el demo; no es un fallo del modelo. Cargue 04 (y 07) sobre una base limpia y vuelva a correr este script.', dead
            USING ERRCODE = 'invalid_object_definition';
    END IF;
END
$h0$;

-- ---------------------------------------------------------------- H1
DO $h1$
DECLARE r record; n integer := 0;
BEGIN
    FOR r IN SELECT * FROM (VALUES
        ('delegated_access', 'support_scope_grants'), ('delegated_access', 'support_grant_actions'),
        ('delegated_access', 'engagement_request_items'), ('community', 'conversation_assignments'),
        ('community', 'conversation_internal_notes'), ('directory', 'affiliation_invitation_uses'),
        ('practice', 'practitioner_location_assignments')) v(s, t)
    LOOP
        IF NOT EXISTS (SELECT 1 FROM information_schema.columns c WHERE c.table_schema = r.s AND c.table_name = r.t
                          AND c.column_name = 'tenant_id' AND c.data_type = 'uuid' AND c.is_nullable = 'NO') THEN
            RAISE EXCEPTION 'H-1a FALLÓ: %.% no tiene tenant_id uuid NOT NULL', r.s, r.t; END IF;
        IF NOT EXISTS (SELECT 1 FROM pg_constraint k WHERE k.conrelid = format('%I.%I', r.s, r.t)::regclass AND k.contype = 'f'
                          AND k.confrelid = 'directory.tenants'::regclass
                          AND k.conkey = ARRAY[(SELECT attnum FROM pg_attribute WHERE attrelid = k.conrelid AND attname = 'tenant_id')]) THEN
            RAISE EXCEPTION 'H-1b FALLÓ: %.% no tiene FK de tenant_id a directory.tenants', r.s, r.t; END IF;
        IF NOT EXISTS (SELECT 1 FROM pg_index i WHERE i.indrelid = format('%I.%I', r.s, r.t)::regclass
                          AND i.indkey[0] = (SELECT attnum FROM pg_attribute WHERE attrelid = i.indrelid AND attname = 'tenant_id')) THEN
            RAISE EXCEPTION 'H-1c FALLÓ: %.% no tiene un índice que empiece por tenant_id', r.s, r.t; END IF;
        n := n + 1;
    END LOOP;
    RAISE NOTICE 'H1 OK · % tablas con tenant_id NOT NULL + FK + índice', n;
END
$h1$;

-- ---------------------------------------------------------------- H2 · tenant del hijo = tenant del padre
-- permiso (support_scope_grants): el tenant del vínculo y de cada objetivo
SELECT pg_temp.must_fail('2a', '23514', format($q$
  INSERT INTO delegated_access.support_scope_grants (id, tenant_id, organization_user_assignment_id, target_kind_concept_id, expansion_mode_concept_id,
    status_concept_id, created_at, updated_at)
  VALUES (gen_random_uuid(), %L, %L, 'b1330928-a076-5348-bffd-154144fadc85', 'd9ed1dfe-f5e6-55f3-94f2-2bd60993a536',
    'ccfbc54f-4744-53db-ab1f-abe1af31f784', now(), now())$q$, :'cons', :'oua_ana'));
SELECT pg_temp.must_fail('2b', '23514', format($q$
  INSERT INTO delegated_access.support_scope_grants (id, tenant_id, organization_user_assignment_id, target_kind_concept_id, practitioner_role_assignment_id,
    expansion_mode_concept_id, status_concept_id, created_at, updated_at)
  VALUES (gen_random_uuid(), %L, %L, '785d1671-5754-58d3-b1a3-e3cd467b82b7', %L, 'd9ed1dfe-f5e6-55f3-94f2-2bd60993a536',
    'ccfbc54f-4744-53db-ab1f-abe1af31f784', now(), now())$q$, :'hosp', :'oua_ana', :'pra_cespedes'));
SELECT pg_temp.must_fail('2c', '23514', format($q$
  INSERT INTO delegated_access.support_scope_grants (id, tenant_id, organization_user_assignment_id, target_kind_concept_id, care_space_id,
    expansion_mode_concept_id, status_concept_id, created_at, updated_at)
  VALUES (gen_random_uuid(), %L, %L, '10510d38-c6cf-5243-9327-5cefc6c3aee5', %L, 'd9ed1dfe-f5e6-55f3-94f2-2bd60993a536',
    'ccfbc54f-4744-53db-ab1f-abe1af31f784', now(), now())$q$, :'hosp', :'oua_ana', :'sp_cons'));
SELECT pg_temp.must_fail('2c2', '23503', format($q$
  INSERT INTO delegated_access.support_scope_grants (id, tenant_id, organization_user_assignment_id, target_kind_concept_id, expansion_mode_concept_id,
    status_concept_id, created_at, updated_at)
  VALUES (gen_random_uuid(), %L, gen_random_uuid(), 'b1330928-a076-5348-bffd-154144fadc85', 'd9ed1dfe-f5e6-55f3-94f2-2bd60993a536',
    'ccfbc54f-4744-53db-ab1f-abe1af31f784', now(), now())$q$, :'hosp'));   -- vínculo inexistente: falla cerrada, no pasa en silencio
SELECT pg_temp.must_pass('2d', format($q$
  INSERT INTO delegated_access.support_scope_grants (id, tenant_id, organization_user_assignment_id, target_kind_concept_id, expansion_mode_concept_id,
    status_concept_id, created_at, updated_at)
  VALUES ('0b0b0b0b-0000-4000-8000-000000000001', %L, %L, 'b1330928-a076-5348-bffd-154144fadc85', 'd9ed1dfe-f5e6-55f3-94f2-2bd60993a536',
    'ccfbc54f-4744-53db-ab1f-abe1af31f784', now(), now())$q$, :'hosp', :'oua_ana'));
-- acciones del permiso
SELECT pg_temp.must_fail('2e', '23514', format($q$
  INSERT INTO delegated_access.support_grant_actions (id, tenant_id, support_scope_grant_id, permission_id, created_at)
  VALUES (gen_random_uuid(), %L, '0b0b0b0b-0000-4000-8000-000000000001', %L, now())$q$, :'cons', :'perm_view'));
SELECT pg_temp.must_pass('2f', format($q$
  INSERT INTO delegated_access.support_grant_actions (id, tenant_id, support_scope_grant_id, permission_id, created_at)
  VALUES (gen_random_uuid(), %L, '0b0b0b0b-0000-4000-8000-000000000001', %L, now())$q$, :'hosp', :'perm_view'));
-- solicitud y sus líneas
SELECT pg_temp.must_pass('2g', format($q$
  INSERT INTO delegated_access.engagement_requests (id, tenant_id, requester_user_id, direction_concept_id, role_template_id, status_concept_id,
    expires_at, created_at, updated_at)
  VALUES ('0b0b0b0b-0000-4000-8000-000000000002', %L, %L, '48d72179-b75d-5f3e-9586-9013246ed0c4', %L, '0aedb9a7-2bca-51ae-a086-c234e61782f6',
    now() + interval '15 days', now(), now())$q$, :'hosp', :'u_marcos', :'tpl_secretary'));
SELECT pg_temp.must_fail('2h', '23514', format($q$
  INSERT INTO delegated_access.engagement_request_items (id, tenant_id, engagement_request_id, target_kind_concept_id, proposed_actions_json,
    decision_concept_id, created_at)
  VALUES (gen_random_uuid(), %L, '0b0b0b0b-0000-4000-8000-000000000002', 'b1330928-a076-5348-bffd-154144fadc85', '[]'::jsonb,
    'f906bb33-2a72-58a1-bfca-c08ad585ba1a', now())$q$, :'cons'));
SELECT pg_temp.must_pass('2i', format($q$
  INSERT INTO delegated_access.engagement_request_items (id, tenant_id, engagement_request_id, target_kind_concept_id, proposed_actions_json,
    decision_concept_id, created_at)
  VALUES (gen_random_uuid(), %L, '0b0b0b0b-0000-4000-8000-000000000002', 'b1330928-a076-5348-bffd-154144fadc85', '[]'::jsonb,
    'f906bb33-2a72-58a1-bfca-c08ad585ba1a', now())$q$, :'hosp'));
-- usos de invitación
SELECT pg_temp.must_fail('2j', '23514', format($q$
  INSERT INTO directory.affiliation_invitation_uses (id, tenant_id, affiliation_invitation_id, used_by_user_id, occurred_at, outcome_concept_id)
  VALUES (gen_random_uuid(), %L, %L, %L, now(), 'efa1442f-e0b5-5541-8090-2bdec97598e5')$q$, :'cons', :'inv_hosp', :'u_marcos'));
-- ubicaciones de doctores
SELECT pg_temp.must_fail('2k', '23514', format($q$
  INSERT INTO practice.practitioner_location_assignments (id, tenant_id, practitioner_role_assignment_id, care_space_id, status_concept_id, created_at, updated_at)
  VALUES (gen_random_uuid(), %L, %L, %L, '38a1d301-f40d-5b17-a695-5e6d605f8b19', now(), now())$q$, :'hosp', :'pra_cespedes', :'sp_hosp'));
SELECT pg_temp.must_fail('2l', '23514', format($q$
  INSERT INTO practice.practitioner_location_assignments (id, tenant_id, practitioner_role_assignment_id, care_space_id, status_concept_id, created_at, updated_at)
  VALUES (gen_random_uuid(), %L, %L, %L, '38a1d301-f40d-5b17-a695-5e6d605f8b19', now(), now())$q$, :'hosp', :'pra_perez', :'sp_cons'));
SELECT pg_temp.must_pass('2m', format($q$
  INSERT INTO practice.practitioner_location_assignments (id, tenant_id, practitioner_role_assignment_id, care_space_id, status_concept_id, created_at, updated_at)
  VALUES (gen_random_uuid(), %L, %L, %L, '38a1d301-f40d-5b17-a695-5e6d605f8b19', now(), now())$q$, :'hosp', :'pra_perez', :'sp_hosp'));
-- bandeja de mensajes: una conversación CON tenant fija el de sus hijas; una SIN tenant deja la ancla a la fila
INSERT INTO community.conversations (id, tenant_id, conversation_type_concept_id, status_concept_id, created_at, updated_at)
VALUES ('0b0b0b0b-0000-4000-8000-0000000000c1', :'hosp', '38a1d301-f40d-5b17-a695-5e6d605f8b19', '38a1d301-f40d-5b17-a695-5e6d605f8b19', now(), now()),
       ('0b0b0b0b-0000-4000-8000-0000000000c2', NULL,    '38a1d301-f40d-5b17-a695-5e6d605f8b19', '38a1d301-f40d-5b17-a695-5e6d605f8b19', now(), now());
SELECT pg_temp.must_fail('2n', '23514', format($q$
  INSERT INTO community.conversation_assignments (id, tenant_id, conversation_id, practitioner_profile_id, status_concept_id, created_at, updated_at)
  VALUES (gen_random_uuid(), %L, '0b0b0b0b-0000-4000-8000-0000000000c1', %L, '0c2c8c70-2e98-55d1-82c4-764218621f8d', now(), now())$q$, :'cons', :'prof_perez'));
SELECT pg_temp.must_pass('2o', format($q$
  INSERT INTO community.conversation_assignments (id, tenant_id, conversation_id, practitioner_profile_id, status_concept_id, created_at, updated_at)
  VALUES (gen_random_uuid(), %L, '0b0b0b0b-0000-4000-8000-0000000000c1', %L, '0c2c8c70-2e98-55d1-82c4-764218621f8d', now(), now())$q$, :'hosp', :'prof_perez'));
SELECT pg_temp.must_pass('2p', format($q$
  INSERT INTO community.conversation_assignments (id, tenant_id, conversation_id, practitioner_profile_id, status_concept_id, created_at, updated_at)
  VALUES (gen_random_uuid(), %L, '0b0b0b0b-0000-4000-8000-0000000000c2', %L, '0c2c8c70-2e98-55d1-82c4-764218621f8d', now(), now())$q$, :'cons', :'prof_perez'));
SELECT pg_temp.must_fail('2q', '23514', format($q$
  INSERT INTO community.conversation_internal_notes (id, tenant_id, conversation_id, author_user_id, body_text, created_at)
  VALUES (gen_random_uuid(), %L, '0b0b0b0b-0000-4000-8000-0000000000c1', %L, 'nota', now())$q$, :'cons', :'u_ana'));
SELECT pg_temp.must_pass('2r', format($q$
  INSERT INTO community.conversation_internal_notes (id, tenant_id, conversation_id, author_user_id, body_text, created_at)
  VALUES (gen_random_uuid(), %L, '0b0b0b0b-0000-4000-8000-0000000000c1', %L, 'nota', now())$q$, :'hosp', :'u_ana'));
-- un UPDATE que cambia el tenant también se revisa
SELECT pg_temp.must_fail('2s', '23514', format($q$UPDATE delegated_access.support_grant_actions SET tenant_id = %L WHERE support_scope_grant_id = '0b0b0b0b-0000-4000-8000-000000000001'$q$, :'cons'));
\echo H2 OK · el tenant del hijo debe ser el del padre (12 rechazos y 8 altas legítimas)

-- ---------------------------------------------------------------- H3 · FIXED exige foto con filas válidas (M6)
SELECT pg_temp.must_fail('3a', '23514', $q$UPDATE delegated_access.support_scope_grants SET expansion_mode_concept_id = '4f47115f-54ad-564f-bcd4-f06a0a0c13cd', fixed_snapshot_json = NULL WHERE id = '0b0b0b0b-0000-4000-8000-000000000001'$q$);
SELECT pg_temp.must_fail('3b', '23514', $q$UPDATE delegated_access.support_scope_grants SET expansion_mode_concept_id = '4f47115f-54ad-564f-bcd4-f06a0a0c13cd', fixed_snapshot_json = '{}' WHERE id = '0b0b0b0b-0000-4000-8000-000000000001'$q$);
SELECT pg_temp.must_fail('3c', '23514', $q$UPDATE delegated_access.support_scope_grants SET expansion_mode_concept_id = '4f47115f-54ad-564f-bcd4-f06a0a0c13cd', fixed_snapshot_json = '{"rows":[]}' WHERE id = '0b0b0b0b-0000-4000-8000-000000000001'$q$);
SELECT pg_temp.must_fail('3d', '23514', $q$UPDATE delegated_access.support_scope_grants SET expansion_mode_concept_id = '4f47115f-54ad-564f-bcd4-f06a0a0c13cd', fixed_snapshot_json = '{"rows":[{}]}' WHERE id = '0b0b0b0b-0000-4000-8000-000000000001'$q$);
SELECT pg_temp.must_fail('3e', '23514', $q$UPDATE delegated_access.support_scope_grants SET expansion_mode_concept_id = '4f47115f-54ad-564f-bcd4-f06a0a0c13cd', fixed_snapshot_json = '{"rows":[{"careSpaceId":"no-es-uuid"}]}' WHERE id = '0b0b0b0b-0000-4000-8000-000000000001'$q$);
SELECT pg_temp.must_fail('3f', '23514', $q$UPDATE delegated_access.support_scope_grants SET expansion_mode_concept_id = '4f47115f-54ad-564f-bcd4-f06a0a0c13cd', fixed_snapshot_json = '{"rows":[{"careSpaceId":"0b0b0b0b-0000-4000-8000-0000000000aa"},{}]}' WHERE id = '0b0b0b0b-0000-4000-8000-000000000001'$q$);
SELECT pg_temp.must_fail('3g', '23514', $q$UPDATE delegated_access.support_scope_grants SET expansion_mode_concept_id = '4f47115f-54ad-564f-bcd4-f06a0a0c13cd', fixed_snapshot_json = '{"rows":[{"practitionerProfileId":"0b0b0b0b-0000-4000-8000-0000000000aa"}]}' WHERE id = '0b0b0b0b-0000-4000-8000-000000000001'$q$);
SELECT pg_temp.must_fail('3h', '23514', $q$UPDATE delegated_access.support_scope_grants SET expansion_mode_concept_id = '4f47115f-54ad-564f-bcd4-f06a0a0c13cd', fixed_snapshot_json = '{"rows":[{"careSpaceId":"0b0b0b0b-0000-4000-8000-0000000000aa","otraClave":1}]}' WHERE id = '0b0b0b0b-0000-4000-8000-000000000001'$q$);
SELECT pg_temp.must_pass('3i', $q$UPDATE delegated_access.support_scope_grants SET expansion_mode_concept_id = '4f47115f-54ad-564f-bcd4-f06a0a0c13cd',
  fixed_snapshot_json = '{"rows":[{"practitionerRoleAssignmentId":"0b0b0b0b-0000-4000-8000-0000000000aa","practitionerProfileId":"0b0b0b0b-0000-4000-8000-0000000000ab","healthcareServiceId":null},{"careSpaceId":"0b0b0b0b-0000-4000-8000-0000000000ac"}]}'
  WHERE id = '0b0b0b0b-0000-4000-8000-000000000001'$q$);
\echo H3 OK · FIXED rechaza foto nula, vacía, de filas vacías o con claves/valores inválidos y acepta la bien formada

-- ---------------------------------------------------------------- H4 · únicos parciales
-- política de sesión: una ACTIVA por (organización, alcance[, rol]); las retiradas no cuentan (A5)
SELECT pg_temp.must_fail('4a', '23505', format($q$
  INSERT INTO iam.session_policies (id, tenant_id, scope_concept_id, idle_timeout_minutes, new_device_alert, enforce_ip_rules, require_mfa, status_concept_id, created_at, updated_at)
  VALUES (gen_random_uuid(), %L, '028a8eb3-49f0-5bd0-a607-8237e4b52406', 20, false, false, false, '38a1d301-f40d-5b17-a695-5e6d605f8b19', now(), now())$q$, :'hosp'));
UPDATE iam.session_policies SET status_concept_id = '8d56de1d-f25e-54eb-bc54-3ab2fbc70249'
 WHERE tenant_id = :'hosp' AND scope_concept_id = '028a8eb3-49f0-5bd0-a607-8237e4b52406';   -- el PUT «retira» la fila anterior
SELECT pg_temp.must_pass('4b', format($q$
  INSERT INTO iam.session_policies (id, tenant_id, scope_concept_id, idle_timeout_minutes, new_device_alert, enforce_ip_rules, require_mfa, status_concept_id, created_at, updated_at)
  VALUES (gen_random_uuid(), %L, '028a8eb3-49f0-5bd0-a607-8237e4b52406', 20, false, false, false, '38a1d301-f40d-5b17-a695-5e6d605f8b19', now(), now())$q$, :'hosp'));
SELECT pg_temp.must_pass('4c', format($q$
  INSERT INTO iam.session_policies (id, tenant_id, scope_concept_id, idle_timeout_minutes, new_device_alert, enforce_ip_rules, require_mfa, status_concept_id, created_at, updated_at)
  VALUES (gen_random_uuid(), %L, '028a8eb3-49f0-5bd0-a607-8237e4b52406', 25, false, false, false, '8d56de1d-f25e-54eb-bc54-3ab2fbc70249', now(), now())$q$, :'hosp'));   -- otra retirada: historial
SELECT pg_temp.must_pass('4d', format($q$
  INSERT INTO iam.session_policies (id, tenant_id, scope_concept_id, role_code, idle_timeout_minutes, new_device_alert, enforce_ip_rules, require_mfa, status_concept_id, created_at, updated_at)
  VALUES (gen_random_uuid(), %L, 'b9137390-37e5-5de6-95cf-fc53860563fe', 'H4_ROL', 20, false, false, false, '38a1d301-f40d-5b17-a695-5e6d605f8b19', now(), now())$q$, :'hosp'));
SELECT pg_temp.must_fail('4e', '23505', format($q$
  INSERT INTO iam.session_policies (id, tenant_id, scope_concept_id, role_code, idle_timeout_minutes, new_device_alert, enforce_ip_rules, require_mfa, status_concept_id, created_at, updated_at)
  VALUES (gen_random_uuid(), %L, 'b9137390-37e5-5de6-95cf-fc53860563fe', 'H4_ROL', 30, false, false, false, '38a1d301-f40d-5b17-a695-5e6d605f8b19', now(), now())$q$, :'hosp'));
SELECT pg_temp.must_pass('4f', format($q$
  INSERT INTO iam.session_policies (id, tenant_id, scope_concept_id, role_code, idle_timeout_minutes, new_device_alert, enforce_ip_rules, require_mfa, status_concept_id, created_at, updated_at)
  VALUES (gen_random_uuid(), %L, 'b9137390-37e5-5de6-95cf-fc53860563fe', 'H4_ROL', 30, false, false, false, '8d56de1d-f25e-54eb-bc54-3ab2fbc70249', now(), now())$q$, :'hosp'));
DO $h4g$ BEGIN
    IF to_regclass('iam.uq_session_policies_tenant_scope') IS NOT NULL OR to_regclass('iam.uq_session_policies_tenant_scope_role') IS NOT NULL THEN
        RAISE EXCEPTION 'H-4g FALLÓ: siguen los únicos antiguos de session_policies (sin estado)'; END IF;
END $h4g$;
-- un solo vínculo de apoyo ACTIVO por membresía + plantilla
SELECT pg_temp.must_fail('4h', '23505', format($q$
  INSERT INTO delegated_access.organization_user_assignments (id, tenant_id, tenant_membership_id, assignment_role_concept_id, access_scope_concept_id, status_concept_id,
    created_at, updated_at, role_template_id)
  SELECT gen_random_uuid(), tenant_id, tenant_membership_id, assignment_role_concept_id, access_scope_concept_id, status_concept_id, now(), now(), role_template_id
    FROM delegated_access.organization_user_assignments WHERE id = %L$q$, :'oua_ana'));
SELECT pg_temp.must_pass('4i', format($q$
  INSERT INTO delegated_access.organization_user_assignments (id, tenant_id, tenant_membership_id, assignment_role_concept_id, access_scope_concept_id, status_concept_id,
    created_at, updated_at, role_template_id)
  SELECT gen_random_uuid(), tenant_id, tenant_membership_id, assignment_role_concept_id, access_scope_concept_id, '8d56de1d-f25e-54eb-bc54-3ab2fbc70249', now(), now(), role_template_id
    FROM delegated_access.organization_user_assignments WHERE id = %L$q$, :'oua_ana'));   -- uno REVOCADO no cuenta
SELECT pg_temp.must_pass('4j', format($q$
  INSERT INTO delegated_access.organization_user_assignments (id, tenant_id, tenant_membership_id, assignment_role_concept_id, access_scope_concept_id, status_concept_id,
    created_at, updated_at)
  SELECT gen_random_uuid(), tenant_id, tenant_membership_id, assignment_role_concept_id, access_scope_concept_id, status_concept_id, now(), now()
    FROM delegated_access.organization_user_assignments WHERE id = %L$q$, :'oua_ana'));   -- heredado, sin plantilla: puede repetirse
-- un uso ACEPTADO por (invitación, usuario); los rechazos se registran cada vez
SELECT pg_temp.must_pass('4k', format($q$
  INSERT INTO directory.affiliation_invitation_uses (id, tenant_id, affiliation_invitation_id, used_by_user_id, occurred_at, outcome_concept_id)
  VALUES (gen_random_uuid(), %L, %L, %L, now(), '659f9beb-ad4d-583e-828b-05a808ad08dc')$q$, :'hosp', :'inv_hosp', :'u_marcos'));
SELECT pg_temp.must_fail('4l', '23505', format($q$
  INSERT INTO directory.affiliation_invitation_uses (id, tenant_id, affiliation_invitation_id, used_by_user_id, occurred_at, outcome_concept_id)
  VALUES (gen_random_uuid(), %L, %L, %L, now(), '659f9beb-ad4d-583e-828b-05a808ad08dc')$q$, :'hosp', :'inv_hosp', :'u_marcos'));
SELECT pg_temp.must_pass('4m', format($q$
  INSERT INTO directory.affiliation_invitation_uses (id, tenant_id, affiliation_invitation_id, used_by_user_id, occurred_at, outcome_concept_id)
  VALUES (gen_random_uuid(), %L, %L, %L, now(), 'ea71ebf5-2886-5a88-a142-91f3b8edb8dd'), (gen_random_uuid(), %L, %L, %L, now(), 'ea71ebf5-2886-5a88-a142-91f3b8edb8dd')$q$,
         :'hosp', :'inv_hosp', :'u_marcos', :'hosp', :'inv_hosp', :'u_marcos'));
-- una membresía ACTIVA por (usuario, organización); las terminadas no cuentan
SELECT pg_temp.must_fail('4n', '23505', format($q$
  INSERT INTO directory.tenant_memberships (id, user_id, tenant_id, tenant_role_concept_id, status_concept_id, access_scope_concept_id, start_date, created_at, updated_at)
  SELECT gen_random_uuid(), user_id, tenant_id, tenant_role_concept_id, status_concept_id, access_scope_concept_id, now(), now(), now()
    FROM directory.tenant_memberships WHERE user_id = %L AND tenant_id = %L$q$, :'u_ana', :'hosp'));
SELECT pg_temp.must_pass('4o', format($q$
  INSERT INTO directory.tenant_memberships (id, user_id, tenant_id, tenant_role_concept_id, status_concept_id, access_scope_concept_id, start_date, end_date, created_at, updated_at)
  SELECT gen_random_uuid(), user_id, tenant_id, tenant_role_concept_id, '76d35f5f-5140-55be-9853-ee1dfe6a12fd', access_scope_concept_id, now(), now(), now(), now()
    FROM directory.tenant_memberships WHERE user_id = %L AND tenant_id = %L$q$, :'u_ana', :'hosp'));
\echo H4 OK · únicos parciales: política activa, vínculo activo, uso aceptado, membresía activa

-- ---------------------------------------------------------------- H5 · horario de la política de sesión
SELECT pg_temp.must_fail('5a', '23514', format($q$
  INSERT INTO iam.session_policies (id, tenant_id, scope_concept_id, role_code, idle_timeout_minutes, new_device_alert, allowed_hours_json, enforce_ip_rules, require_mfa, status_concept_id, created_at, updated_at)
  VALUES (gen_random_uuid(), %L, 'b9137390-37e5-5de6-95cf-fc53860563fe', 'H5_A', 20, false, '{"from":"8:00","to":"18:00"}', false, false, '38a1d301-f40d-5b17-a695-5e6d605f8b19', now(), now())$q$, :'hosp'));
SELECT pg_temp.must_fail('5b', '23514', format($q$
  INSERT INTO iam.session_policies (id, tenant_id, scope_concept_id, role_code, idle_timeout_minutes, new_device_alert, allowed_hours_json, enforce_ip_rules, require_mfa, status_concept_id, created_at, updated_at)
  VALUES (gen_random_uuid(), %L, 'b9137390-37e5-5de6-95cf-fc53860563fe', 'H5_B', 20, false, '{"from":"08:00","to":"18:00","days":[1,9]}', false, false, '38a1d301-f40d-5b17-a695-5e6d605f8b19', now(), now())$q$, :'hosp'));
SELECT pg_temp.must_fail('5c', '23514', format($q$
  INSERT INTO iam.session_policies (id, tenant_id, scope_concept_id, role_code, idle_timeout_minutes, new_device_alert, allowed_hours_json, enforce_ip_rules, require_mfa, status_concept_id, created_at, updated_at)
  VALUES (gen_random_uuid(), %L, 'b9137390-37e5-5de6-95cf-fc53860563fe', 'H5_C', 20, false, '{"from":"08:00","to":"18:00","timeZone":"Mars/Olympus"}', false, false, '38a1d301-f40d-5b17-a695-5e6d605f8b19', now(), now())$q$, :'hosp'));
SELECT pg_temp.must_pass('5d', format($q$
  INSERT INTO iam.session_policies (id, tenant_id, scope_concept_id, role_code, idle_timeout_minutes, new_device_alert, allowed_hours_json, enforce_ip_rules, require_mfa, status_concept_id, created_at, updated_at)
  VALUES (gen_random_uuid(), %L, 'b9137390-37e5-5de6-95cf-fc53860563fe', 'H5_D', 20, false, '{"from":"22:00","to":"06:00","days":[1,2,3,4,5],"timeZone":"America/La_Paz"}', false, false, '38a1d301-f40d-5b17-a695-5e6d605f8b19', now(), now())$q$, :'hosp'));
SELECT pg_temp.must_fail('5e', '23514', $q$UPDATE iam.session_policies SET allowed_hours_json = '{"from":"08:00","to":"18:00","timeZone":"No/Existe"}' WHERE role_code = 'H5_D'$q$);
\echo H5 OK · el horario inválido o con zona horaria desconocida se rechaza al guardar

-- ---------------------------------------------------------------- H6 · funciones endurecidas
DO $h6$
DECLARE r record; n integer := 0;
BEGIN
    FOR r IN SELECT p.oid, p.oid::regprocedure AS sig, p.proconfig, p.proacl, p.proowner
               FROM pg_proc p JOIN pg_namespace s ON s.oid = p.pronamespace
              WHERE (s.nspname, p.proname) IN (('delegated_access', 'refresh_effective_support_access'), ('delegated_access', 'support_access_allowed'),
                                               ('integrity', 'support_tenant_consistency'), ('integrity', 'session_policies_time_zone'))
    LOOP
        IF r.proconfig IS NULL OR NOT ('search_path=pg_catalog, pg_temp' = ANY (r.proconfig)) THEN
            RAISE EXCEPTION 'H-6a FALLÓ: % no fija search_path = pg_catalog, pg_temp', r.sig; END IF;
        IF EXISTS (SELECT 1 FROM aclexplode(COALESCE(r.proacl, acldefault('f', r.proowner))) a WHERE a.grantee = 0 AND a.privilege_type = 'EXECUTE') THEN
            RAISE EXCEPTION 'H-6b FALLÓ: % tiene EXECUTE para PUBLIC', r.sig; END IF;
        IF (SELECT prosecdef FROM pg_proc WHERE oid = r.oid) THEN
            RAISE EXCEPTION 'H-6c FALLÓ: % es SECURITY DEFINER', r.sig; END IF;
        n := n + 1;
    END LOOP;
    IF n <> 4 THEN RAISE EXCEPTION 'H-6d FALLÓ: se esperaban 4 funciones y hay %', n; END IF;
    IF EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'mantra_app') THEN
        IF NOT has_function_privilege('mantra_app', 'delegated_access.refresh_effective_support_access(uuid)', 'EXECUTE')
           OR NOT has_function_privilege('mantra_app', 'delegated_access.support_access_allowed(uuid,uuid,varchar,uuid,uuid,uuid)', 'EXECUTE') THEN
            RAISE EXCEPTION 'H-6e FALLÓ: mantra_app debe poder ejecutar las dos funciones de apoyo'; END IF;
    END IF;
    RAISE NOTICE 'H6 OK · 4 funciones con search_path fijo, sin EXECUTE para PUBLIC y sin SECURITY DEFINER';
END
$h6$;

-- ---------------------------------------------------------------- H9 · origen de la membresía (v4.2.71, N10)
DO $h9$
DECLARE c record;
BEGIN
    SELECT data_type, is_nullable, column_default INTO c FROM information_schema.columns
     WHERE table_schema = 'directory' AND table_name = 'tenant_memberships' AND column_name = 'origin_concept_id';
    IF NOT FOUND THEN RAISE EXCEPTION 'H-9a FALLÓ: no existe directory.tenant_memberships.origin_concept_id'; END IF;
    IF c.data_type <> 'uuid' OR c.is_nullable <> 'YES' OR c.column_default IS NOT NULL THEN
        RAISE EXCEPTION 'H-9b FALLÓ: origin_concept_id debe ser uuid NULL sin valor por defecto (es %, anulable %, defecto %)', c.data_type, c.is_nullable, c.column_default;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_tenant_memberships_origin_concept_id' AND contype = 'f'
                      AND confrelid = 'terminology.catalog_concepts'::regclass) THEN
        RAISE EXCEPTION 'H-9c FALLÓ: falta la FK fk_tenant_memberships_origin_concept_id al catálogo de conceptos';
    END IF;
    IF to_regclass('directory.ix_tenant_memberships_origin_concept_id') IS NULL THEN
        RAISE EXCEPTION 'H-9d FALLÓ: falta el índice ix_tenant_memberships_origin_concept_id';
    END IF;
END
$h9$;
-- un origen que no es un concepto del catálogo se rechaza; NULL (= desconocido) es válido
SELECT pg_temp.must_fail('9e', '23503', $q$UPDATE directory.tenant_memberships SET origin_concept_id = gen_random_uuid()
  WHERE id = (SELECT id FROM directory.tenant_memberships ORDER BY id LIMIT 1)$q$);
SELECT pg_temp.must_pass('9f', $q$UPDATE directory.tenant_memberships SET origin_concept_id = NULL
  WHERE id = (SELECT id FROM directory.tenant_memberships ORDER BY id LIMIT 1)$q$);
\echo H9 OK · origin_concept_id: uuid NULL + FK al catálogo + índice; un origen inexistente se rechaza (23503) y NULL es válido

-- ---------------------------------------------------------------- H10 · documento nacional único y normalizado (v4.2.71, N3)
-- Las FK a los conceptos del catálogo no se comprueban acá (los conceptos los siembra la API): solo la unicidad.
SET LOCAL session_replication_role = replica;
SELECT pg_temp.must_pass('10a', $q$INSERT INTO common.identifiers (id, owner_type_concept_id, owner_id, type_concept_id, value, state_concept_id, created_at, updated_at)
  VALUES ('00000000-0000-4000-8000-0000000a0001', '350a0150-c27c-5241-b5d8-78daa13bed34', '00000000-0000-4000-8000-0000000b0001',
          '595e7a3d-ba37-5014-9a72-635363b94864', '4.567.890-a', '38a1d301-f40d-5b17-a695-5e6d605f8b19', now(), now())$q$);
-- la misma persona escrita de otra forma (ceros, puntos, guiones, espacios, minúsculas): 23505
SELECT pg_temp.must_fail('10b', '23505', format($q$INSERT INTO common.identifiers (id, owner_type_concept_id, owner_id, type_concept_id, value, state_concept_id, created_at, updated_at)
  VALUES (gen_random_uuid(), '350a0150-c27c-5241-b5d8-78daa13bed34', gen_random_uuid(), '595e7a3d-ba37-5014-9a72-635363b94864', %L,
          '38a1d301-f40d-5b17-a695-5e6d605f8b19', now(), now())$q$, v))
  FROM unnest(ARRAY['4567890A', '04567890a', '4567890-A', ' 4.567.890 A ', '004567890-a']) AS v;
-- lo que SÍ puede repetirse: persona de contacto (OWNER_PERSON), fila cerrada (valid_to), otro tipo de documento, otro estado, otro número
SELECT pg_temp.must_pass('10c', $q$INSERT INTO common.identifiers (id, owner_type_concept_id, owner_id, type_concept_id, value, state_concept_id, created_at, updated_at)
  VALUES (gen_random_uuid(), 'ba41c786-6a8f-5d33-9214-74ec76a678eb', gen_random_uuid(), '595e7a3d-ba37-5014-9a72-635363b94864', '4567890A',
          '38a1d301-f40d-5b17-a695-5e6d605f8b19', now(), now())$q$);
SELECT pg_temp.must_pass('10d', $q$INSERT INTO common.identifiers (id, owner_type_concept_id, owner_id, type_concept_id, value, state_concept_id, valid_to, created_at, updated_at)
  VALUES (gen_random_uuid(), '350a0150-c27c-5241-b5d8-78daa13bed34', gen_random_uuid(), '595e7a3d-ba37-5014-9a72-635363b94864', '4567890A',
          '38a1d301-f40d-5b17-a695-5e6d605f8b19', current_date - 1, now(), now())$q$);
SELECT pg_temp.must_pass('10e', $q$INSERT INTO common.identifiers (id, owner_type_concept_id, owner_id, type_concept_id, value, state_concept_id, created_at, updated_at)
  VALUES (gen_random_uuid(), '350a0150-c27c-5241-b5d8-78daa13bed34', gen_random_uuid(), gen_random_uuid(), '4567890A',
          '38a1d301-f40d-5b17-a695-5e6d605f8b19', now(), now())$q$);
SELECT pg_temp.must_pass('10f', $q$INSERT INTO common.identifiers (id, owner_type_concept_id, owner_id, type_concept_id, value, state_concept_id, created_at, updated_at)
  VALUES (gen_random_uuid(), '350a0150-c27c-5241-b5d8-78daa13bed34', gen_random_uuid(), '595e7a3d-ba37-5014-9a72-635363b94864', '4567890A',
          gen_random_uuid(), now(), now())$q$);
SELECT pg_temp.must_pass('10g', $q$INSERT INTO common.identifiers (id, owner_type_concept_id, owner_id, type_concept_id, value, state_concept_id, created_at, updated_at)
  VALUES (gen_random_uuid(), '350a0150-c27c-5241-b5d8-78daa13bed34', gen_random_uuid(), '595e7a3d-ba37-5014-9a72-635363b94864', '4567891A',
          '38a1d301-f40d-5b17-a695-5e6d605f8b19', now(), now())$q$);
-- cambio de número como lo hace la API: se CIERRA la fila vieja (valid_to) y luego se abre la nueva con el mismo canónico
SELECT pg_temp.must_fail('10h', '23505', $q$INSERT INTO common.identifiers (id, owner_type_concept_id, owner_id, type_concept_id, value, state_concept_id, created_at, updated_at)
  VALUES (gen_random_uuid(), '350a0150-c27c-5241-b5d8-78daa13bed34', '00000000-0000-4000-8000-0000000b0001', '595e7a3d-ba37-5014-9a72-635363b94864',
          '4567890A', '38a1d301-f40d-5b17-a695-5e6d605f8b19', now(), now())$q$);
SELECT pg_temp.must_pass('10i', $q$UPDATE common.identifiers SET valid_to = current_date WHERE id = '00000000-0000-4000-8000-0000000a0001'$q$);
SELECT pg_temp.must_pass('10j', $q$INSERT INTO common.identifiers (id, owner_type_concept_id, owner_id, type_concept_id, value, state_concept_id, created_at, updated_at)
  VALUES (gen_random_uuid(), '350a0150-c27c-5241-b5d8-78daa13bed34', '00000000-0000-4000-8000-0000000b0001', '595e7a3d-ba37-5014-9a72-635363b94864',
          '4567890A', '38a1d301-f40d-5b17-a695-5e6d605f8b19', now(), now())$q$);
SET LOCAL session_replication_role = origin;
\echo H10 OK · documento nacional activo de paciente único y normalizado (5 variantes rechazadas) y lo legítimo pasa

-- ---------------------------------------------------------------- H7 · el refresco global exige contexto de sistema
\if :has_app
CREATE FUNCTION pg_temp.as_app(p_label text, p_state text, p_sql text) RETURNS void LANGUAGE plpgsql AS $f$
BEGIN
    SET LOCAL ROLE mantra_app;
    BEGIN
        EXECUTE p_sql;
    EXCEPTION WHEN OTHERS THEN
        RESET ROLE;
        IF SQLSTATE = p_state THEN RETURN; END IF;
        RAISE EXCEPTION 'H-% FALLÓ: se esperaba SQLSTATE % y llegó % (%)', p_label, p_state, SQLSTATE, SQLERRM;
    END;
    RESET ROLE;
    RAISE EXCEPTION 'H-% FALLÓ: debía rechazarse con SQLSTATE %', p_label, p_state;
END
$f$;
SELECT pg_temp.as_app('7a', '42501', 'SELECT delegated_access.refresh_effective_support_access(NULL)');
SELECT set_config('app.current_tenant_id', :'cons', true);
SELECT pg_temp.as_app('7b', '42501', format('SELECT delegated_access.refresh_effective_support_access(%L)', :'hosp'));
SELECT set_config('app.current_tenant_id', '', true);
\echo H7 OK · mantra_app no puede recalcular todas las organizaciones ni una ajena
\else
\echo H7 OMITIDA · no existe el rol mantra_app (ejecutar 2026-08-05_tenant_rls.sql)
\endif

-- ---------------------------------------------------------------- H8 · RLS: el rol de la aplicación no cruza organizaciones
\if :rls_on
\if :has_app
CREATE FUNCTION pg_temp.visible_grants(p_tenant text) RETURNS integer LANGUAGE plpgsql AS $f$
DECLARE n integer;
BEGIN
    PERFORM set_config('app.current_tenant_id', p_tenant, true);
    SET LOCAL ROLE mantra_app;
    SELECT count(*) INTO n FROM delegated_access.support_scope_grants;
    RESET ROLE;
    PERFORM set_config('app.current_tenant_id', '', true);
    RETURN n;
END
$f$;
DO $h8$
DECLARE hosp text := (SELECT id::text FROM directory.tenants WHERE code = 'DEMO_HOSPITAL_PILOTO');
        cons text := (SELECT id::text FROM directory.tenants WHERE code = 'DEMO_CONSULTORIO_CESPEDES');
        total integer; n_h integer; n_c integer; n_none integer;
BEGIN
    SELECT count(*) INTO total FROM delegated_access.support_scope_grants;                       -- superusuario/dueño: ve todo
    SELECT count(*) INTO n_h FROM delegated_access.support_scope_grants WHERE tenant_id = hosp::uuid;
    SELECT count(*) INTO n_c FROM delegated_access.support_scope_grants WHERE tenant_id = cons::uuid;
    IF pg_temp.visible_grants(hosp) <> n_h THEN RAISE EXCEPTION 'H-8a FALLÓ: con el contexto del hospital mantra_app no ve exactamente sus % permisos', n_h; END IF;
    IF pg_temp.visible_grants(cons) <> n_c THEN RAISE EXCEPTION 'H-8b FALLÓ: con el contexto del consultorio mantra_app no ve exactamente sus % permisos', n_c; END IF;
    IF pg_temp.visible_grants('') <> 0 THEN RAISE EXCEPTION 'H-8c FALLÓ: sin contexto de organización mantra_app debe ver 0 filas (falla cerrada)'; END IF;
    IF n_h + n_c = total AND n_h > 0 AND n_c > 0 THEN
        RAISE NOTICE 'H8 OK · mantra_app ve % (hospital), % (consultorio) y 0 sin contexto; el total real es %', n_h, n_c, total;
    ELSE
        RAISE EXCEPTION 'H-8d FALLÓ: el reparto de permisos por organización no cuadra (% + % <> %)', n_h, n_c, total;
    END IF;
END
$h8$;
\else
\echo H8 OMITIDA · no existe el rol mantra_app
\endif
\else
\echo H8 OMITIDA · la base no usa RLS todavía (ejecutar 2026-08-05_tenant_rls.sql)
\endif

\o
ROLLBACK;
