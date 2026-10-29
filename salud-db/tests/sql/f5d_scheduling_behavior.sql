-- ============================================================================
-- Prueba de comportamiento del patch 2026-10-29_infraestructura_f5_scheduling.sql
-- (F5d · agenda de consultorios y salas) contra un Postgres REAL con el patch ya aplicado.
--
-- Uso (base descartable, NUNCA `alovida`; ver docs en DESVIOS-M-F5-sched.md):
--   psql -h localhost -p 5433 -U mantra -d m_f5sched -v ON_ERROR_STOP=1 \
--        -f salud-db/tests/sql/f5d_scheduling_behavior.sql
-- Sale con código 3 si alguna comprobación falla. Todo corre dentro de una transacción
-- que termina en ROLLBACK: no deja datos. Requiere superusuario (usa
-- session_replication_role para sembrar los padres sin armar toda la cadena de FK) y
-- el rol mantra_app de 2026-08-05_tenant_rls.sql para las pruebas de RLS.
--
-- Cada comprobación inserta una fila PASS/FAIL en la tabla temporal t_results. Una
-- comprobación «debe fallar» exige el SQLSTATE exacto (y, si se pide, el nombre de la
-- restricción): un fallo por otra causa es FAIL, no PASS.
-- ============================================================================
\set ON_ERROR_STOP on
\pset pager off

BEGIN;

CREATE TEMP TABLE t_results (n serial, grupo text, etiqueta text, ok boolean, detalle text);

-- Debe FALLAR con `want_state` (y, si no es NULL, con la restricción `want_con`).
CREATE FUNCTION pg_temp.debe_fallar(grupo text, etiqueta text, stmt text, want_state text, want_con text DEFAULT NULL)
RETURNS void LANGUAGE plpgsql AS $f$
DECLARE
    st text; cn text; msg text;
BEGIN
    BEGIN
        EXECUTE stmt;
        INSERT INTO t_results(grupo, etiqueta, ok, detalle) VALUES (grupo, etiqueta, false, 'no falló (se esperaba ' || want_state || ')');
        RETURN;
    EXCEPTION WHEN OTHERS THEN
        GET STACKED DIAGNOSTICS cn = CONSTRAINT_NAME, msg = MESSAGE_TEXT;
        st := SQLSTATE;
    END;
    INSERT INTO t_results(grupo, etiqueta, ok, detalle)
    VALUES (grupo, etiqueta, st = want_state AND (want_con IS NULL OR cn = want_con),
            format('SQLSTATE=%s constraint=%s :: %s', st, coalesce(cn, '-'), left(msg, 160)));
END $f$;

-- Debe FUNCIONAR.
CREATE FUNCTION pg_temp.debe_pasar(grupo text, etiqueta text, stmt text)
RETURNS void LANGUAGE plpgsql AS $f$
DECLARE
    st text; msg text;
BEGIN
    BEGIN
        EXECUTE stmt;
    EXCEPTION WHEN OTHERS THEN
        GET STACKED DIAGNOSTICS msg = MESSAGE_TEXT;
        INSERT INTO t_results(grupo, etiqueta, ok, detalle) VALUES (grupo, etiqueta, false, format('falló SQLSTATE=%s :: %s', SQLSTATE, left(msg, 160)));
        RETURN;
    END;
    INSERT INTO t_results(grupo, etiqueta, ok, detalle) VALUES (grupo, etiqueta, true, 'ok');
END $f$;

-- Igual que debe_fallar pero ejecutando como `mantra_app` (sujeto a RLS) con el tenant dado
-- (NULL ≡ sin GUC, 'system' ≡ app.system_context=true).
CREATE FUNCTION pg_temp.debe_fallar_como(grupo text, etiqueta text, tenant text, stmt text, want_state text)
RETURNS void LANGUAGE plpgsql AS $f$
DECLARE
    st text; msg text;
BEGIN
    SET LOCAL ROLE mantra_app;
    PERFORM set_config('app.current_tenant_id', CASE WHEN tenant = 'system' THEN '' ELSE coalesce(tenant, '') END, true);
    PERFORM set_config('app.system_context', CASE WHEN tenant = 'system' THEN 'true' ELSE 'false' END, true);
    BEGIN
        EXECUTE stmt;
        st := NULL;
    EXCEPTION WHEN OTHERS THEN
        GET STACKED DIAGNOSTICS msg = MESSAGE_TEXT;
        st := SQLSTATE;
    END;
    RESET ROLE;
    PERFORM set_config('app.current_tenant_id', '', true);
    PERFORM set_config('app.system_context', 'false', true);
    INSERT INTO t_results(grupo, etiqueta, ok, detalle)
    VALUES (grupo, etiqueta, st IS NOT DISTINCT FROM want_state, format('SQLSTATE=%s :: %s', coalesce(st, 'sin error'), left(coalesce(msg, ''), 160)));
END $f$;

-- Cuenta filas visibles (consulta `SELECT count(*) …`) como mantra_app.
CREATE FUNCTION pg_temp.contar_como(grupo text, etiqueta text, tenant text, consulta text, esperado bigint)
RETURNS void LANGUAGE plpgsql AS $f$
DECLARE
    n bigint;
BEGIN
    SET LOCAL ROLE mantra_app;
    PERFORM set_config('app.current_tenant_id', CASE WHEN tenant = 'system' THEN '' ELSE coalesce(tenant, '') END, true);
    PERFORM set_config('app.system_context', CASE WHEN tenant = 'system' THEN 'true' ELSE 'false' END, true);
    EXECUTE consulta INTO n;
    RESET ROLE;
    PERFORM set_config('app.current_tenant_id', '', true);
    PERFORM set_config('app.system_context', 'false', true);
    INSERT INTO t_results(grupo, etiqueta, ok, detalle) VALUES (grupo, etiqueta, n = esperado, format('visibles=%s esperado=%s', n, esperado));
END $f$;

-- ------------------------------------------------------------------ fixtures
-- Los padres se siembran con las FK desactivadas (no es lo que se prueba) y con valores
-- de concepto sueltos; las filas que SÍ se prueban se insertan con las FK activas.
SET LOCAL session_replication_role = replica;

-- tenants T1 / T2
INSERT INTO directory.tenants (id, code, tenant_type_concept_id, legal_name, legal_entity_type_concept_id, status_concept_id, verification_status_concept_id, created_at, updated_at)
VALUES ('11111111-0000-4000-8000-000000000001', 'F5D-T1', gen_random_uuid(), 'Tenant F5D 1', gen_random_uuid(), gen_random_uuid(), gen_random_uuid(), now(), now()),
       ('22222222-0000-4000-8000-000000000002', 'F5D-T2', gen_random_uuid(), 'Tenant F5D 2', gen_random_uuid(), gen_random_uuid(), gen_random_uuid(), now(), now());

INSERT INTO practice.practices (id, tenant_id, code, name, type_concept_id, admin_user_id, status_concept_id, created_at, updated_at)
VALUES ('11111111-0000-4000-8000-0000000000a1', '11111111-0000-4000-8000-000000000001', 'F5D-P1', 'Práctica 1', gen_random_uuid(), gen_random_uuid(), gen_random_uuid(), now(), now()),
       ('22222222-0000-4000-8000-0000000000a2', '22222222-0000-4000-8000-000000000002', 'F5D-P2', 'Práctica 2', gen_random_uuid(), gen_random_uuid(), gen_random_uuid(), now(), now());

INSERT INTO practice.practice_sites (id, practice_id, code, name, site_type_concept_id, status_concept_id, created_at, updated_at, tenant_id)
VALUES ('11111111-0000-4000-8000-0000000000b1', '11111111-0000-4000-8000-0000000000a1', 'F5D-S1', 'Sede 1', gen_random_uuid(), gen_random_uuid(), now(), now(), '11111111-0000-4000-8000-000000000001'),
       ('22222222-0000-4000-8000-0000000000b2', '22222222-0000-4000-8000-0000000000a2', 'F5D-S2', 'Sede 2', gen_random_uuid(), gen_random_uuid(), now(), now(), '22222222-0000-4000-8000-000000000002');

-- consultorios: C1A y C1B (tenant 1), C2 (tenant 2)
INSERT INTO practice.care_spaces (id, practice_site_id, code, name, space_type_concept_id, status_concept_id, created_at, updated_at, tenant_id)
VALUES ('11111111-0000-4000-8000-0000000000c1', '11111111-0000-4000-8000-0000000000b1', 'CON-1', 'Consultorio 1', gen_random_uuid(), gen_random_uuid(), now(), now(), '11111111-0000-4000-8000-000000000001'),
       ('11111111-0000-4000-8000-0000000000c2', '11111111-0000-4000-8000-0000000000b1', 'CON-2', 'Consultorio 2', gen_random_uuid(), gen_random_uuid(), now(), now(), '11111111-0000-4000-8000-000000000001'),
       ('22222222-0000-4000-8000-0000000000c3', '22222222-0000-4000-8000-0000000000b2', 'CON-3', 'Consultorio 3', gen_random_uuid(), gen_random_uuid(), now(), now(), '22222222-0000-4000-8000-000000000002');

-- conceptos (sólo importan los ids; los dos de estado son los UUID literales del EXCLUDE)
INSERT INTO terminology.catalog_concepts (id, code_system_version_id, code, display, created_at, updated_at)
VALUES ('51530fd7-05b1-5c29-80c4-da740ede4d27', gen_random_uuid(), 'F5D_BOOKED',    'BOOKED',    now(), now()),
       ('37dded87-7a7a-5a24-86f6-0ef48cccb482', gen_random_uuid(), 'F5D_CHECKED',   'CHECKED_IN', now(), now()),
       ('99999999-0000-4000-8000-000000000001', gen_random_uuid(), 'F5D_CANCELLED', 'CANCELLED', now(), now()),
       ('99999999-0000-4000-8000-000000000002', gen_random_uuid(), 'F5D_OTHER',     'OTRO',      now(), now());

-- recursos agendables R1 (tenant 1) y R2 (tenant 2). Referencia a profesionales (no a care_spaces):
-- así el fixture vale con o sin el CHECK de M-F4 sobre resource_ref_type = 'care_spaces'.
INSERT INTO scheduling.schedulable_resources (id, tenant_id, resource_type_concept_id, resource_ref_type, resource_ref_id, name, state_concept_id, created_at, updated_at)
VALUES ('11111111-0000-4000-8000-0000000000d1', '11111111-0000-4000-8000-000000000001', gen_random_uuid(), 'practitioners', '55555555-0000-4000-8000-000000000001', 'Recurso 1', gen_random_uuid(), now(), now()),
       ('22222222-0000-4000-8000-0000000000d2', '22222222-0000-4000-8000-000000000002', gen_random_uuid(), 'practitioners', '55555555-0000-4000-8000-000000000002', 'Recurso 2', gen_random_uuid(), now(), now());

-- paciente y dos profesionales
INSERT INTO profiles.patient_profiles (profile_id, patient_code, created_at, updated_at)
VALUES ('33333333-0000-4000-8000-000000000001', 'F5D-PAC', now(), now());
INSERT INTO profiles.health_practitioner_profiles (profile_id, practitioner_code, practitioner_category_concept_id, verification_status_concept_id, practice_status_concept_id, created_at, updated_at)
VALUES ('44444444-0000-4000-8000-000000000001', 'F5D-MED1', gen_random_uuid(), gen_random_uuid(), gen_random_uuid(), now(), now()),
       ('44444444-0000-4000-8000-000000000002', 'F5D-MED2', gen_random_uuid(), gen_random_uuid(), gen_random_uuid(), now(), now());

SET LOCAL session_replication_role = origin;

-- ------------------------------------------------------------------ A. solape de consultorio (EXCLUDE)
CREATE FUNCTION pg_temp.cita(id uuid, medico uuid, espacio uuid, estado uuid, ini text, fin text, tenant uuid DEFAULT '11111111-0000-4000-8000-000000000001')
RETURNS text LANGUAGE sql AS $f$
    SELECT format($q$INSERT INTO clinical.appointments (id, patient_profile_id, practitioner_profile_id, tenant_id, care_space_id, status_concept_id, start_at, end_at, created_at, updated_at)
                     VALUES (%L, '33333333-0000-4000-8000-000000000001', %L, %L, %L, %L, %L, %s, now(), now())$q$,
                  id, medico, tenant, espacio, estado, ini::timestamptz, CASE WHEN fin IS NULL THEN 'NULL' ELSE quote_literal(fin::timestamptz) END)
$f$;

SELECT pg_temp.debe_pasar('A-solape', 'A1 cita 14:00-14:30 en CON-1 (médico 1) entra',
    pg_temp.cita('a0000000-0000-4000-8000-000000000001', '44444444-0000-4000-8000-000000000001', '11111111-0000-4000-8000-0000000000c1', '51530fd7-05b1-5c29-80c4-da740ede4d27', '2030-01-07 14:00-04', '2030-01-07 14:30-04'));

SELECT pg_temp.debe_fallar('A-solape', 'A2 cita 14:15-14:45 en CON-1 de OTRO médico: 23P01 ex_appointments_care_space_time',
    pg_temp.cita('a0000000-0000-4000-8000-000000000002', '44444444-0000-4000-8000-000000000002', '11111111-0000-4000-8000-0000000000c1', '51530fd7-05b1-5c29-80c4-da740ede4d27', '2030-01-07 14:15-04', '2030-01-07 14:45-04'),
    '23P01', 'ex_appointments_care_space_time');

SELECT pg_temp.debe_pasar('A-solape', 'A3 cita 14:30-15:00 en CON-1 (contigua, rango [) ) entra',
    pg_temp.cita('a0000000-0000-4000-8000-000000000003', '44444444-0000-4000-8000-000000000002', '11111111-0000-4000-8000-0000000000c1', '51530fd7-05b1-5c29-80c4-da740ede4d27', '2030-01-07 14:30-04', '2030-01-07 15:00-04'));

SELECT pg_temp.debe_pasar('A-solape', 'A4 cita 14:15-14:45 en CON-2 (otro consultorio, sin médico) entra',
    pg_temp.cita('a0000000-0000-4000-8000-000000000004', NULL, '11111111-0000-4000-8000-0000000000c2', '51530fd7-05b1-5c29-80c4-da740ede4d27', '2030-01-07 14:15-04', '2030-01-07 14:45-04'));

SELECT pg_temp.debe_fallar('A-solape', 'A5 cita CHECKED_IN 14:40-14:50 en CON-1 contra A3: 23P01',
    pg_temp.cita('a0000000-0000-4000-8000-000000000005', NULL, '11111111-0000-4000-8000-0000000000c1', '37dded87-7a7a-5a24-86f6-0ef48cccb482', '2030-01-07 14:40-04', '2030-01-07 14:50-04'),
    '23P01', 'ex_appointments_care_space_time');

SELECT pg_temp.debe_pasar('A-solape', 'A6 cita CANCELADA 14:00-14:30 en CON-1 no cuenta como reserva',
    pg_temp.cita('a0000000-0000-4000-8000-000000000006', NULL, '11111111-0000-4000-8000-0000000000c1', '99999999-0000-4000-8000-000000000001', '2030-01-07 14:00-04', '2030-01-07 14:30-04'));

SELECT pg_temp.debe_fallar('A-solape', 'A6b reactivar esa cita a BOOKED la solapa con A1: 23P01 (UPDATE)',
    $$UPDATE clinical.appointments SET status_concept_id = '51530fd7-05b1-5c29-80c4-da740ede4d27' WHERE id = 'a0000000-0000-4000-8000-000000000006'$$,
    '23P01', 'ex_appointments_care_space_time');

SELECT pg_temp.debe_pasar('A-solape', 'A7 cita sin hora de fin (end_at NULL) en CON-1 queda fuera del predicado',
    pg_temp.cita('a0000000-0000-4000-8000-000000000007', NULL, '11111111-0000-4000-8000-0000000000c1', '51530fd7-05b1-5c29-80c4-da740ede4d27', '2030-01-07 14:10-04', NULL));

SELECT pg_temp.debe_pasar('A-solape', 'A8 cita sin consultorio (care_space_id NULL) solapada en el tiempo entra',
    pg_temp.cita('a0000000-0000-4000-8000-000000000008', NULL, NULL, '51530fd7-05b1-5c29-80c4-da740ede4d27', '2030-01-07 14:00-04', '2030-01-07 14:30-04'));

SELECT pg_temp.debe_fallar('A-solape', 'A9 mismo médico en dos consultorios a la vez sigue cayendo en ex_appointments_practitioner_time (regla vieja intacta)',
    pg_temp.cita('a0000000-0000-4000-8000-000000000009', '44444444-0000-4000-8000-000000000001', '11111111-0000-4000-8000-0000000000c2', '51530fd7-05b1-5c29-80c4-da740ede4d27', '2030-01-07 13:55-04', '2030-01-07 14:05-04'),
    '23P01', 'ex_appointments_practitioner_time');

SELECT pg_temp.debe_fallar('A-tenant', 'A10 cita del tenant 1 en el consultorio del tenant 2: 23503 FK compuesta (tenant_id, care_space_id)',
    pg_temp.cita('a0000000-0000-4000-8000-000000000010', NULL, '22222222-0000-4000-8000-0000000000c3', '51530fd7-05b1-5c29-80c4-da740ede4d27', '2030-02-01 10:00-04', '2030-02-01 10:30-04'),
    '23503', 'fk_appointments_tenant_care_space');

-- ------------------------------------------------------------------ B. plantillas (horario por espacio)
SELECT pg_temp.debe_pasar('B-plantilla', 'B1 plantilla con consultorio y SIN tenant_id: el trigger lo completa con el del recurso',
    $$INSERT INTO scheduling.schedule_templates (id, resource_id, care_space_id, name, status_concept_id, created_at, updated_at)
      VALUES ('b0000000-0000-4000-8000-000000000001', '11111111-0000-4000-8000-0000000000d1', '11111111-0000-4000-8000-0000000000c1', 'Plantilla T1', '99999999-0000-4000-8000-000000000002', now(), now())$$);

INSERT INTO t_results(grupo, etiqueta, ok, detalle)
SELECT 'B-plantilla', 'B1b tenant_id quedó = tenant del recurso', tenant_id = '11111111-0000-4000-8000-000000000001', 'tenant_id=' || tenant_id
  FROM scheduling.schedule_templates WHERE id = 'b0000000-0000-4000-8000-000000000001';

SELECT pg_temp.debe_pasar('B-plantilla', 'B2 plantilla SIN consultorio (care_space_id NULL) entra',
    $$INSERT INTO scheduling.schedule_templates (id, resource_id, name, status_concept_id, created_at, updated_at)
      VALUES ('b0000000-0000-4000-8000-000000000002', '11111111-0000-4000-8000-0000000000d1', 'Plantilla sin espacio', '99999999-0000-4000-8000-000000000002', now(), now())$$);

SELECT pg_temp.debe_fallar('B-tenant', 'B3 plantilla del tenant 1 sobre el recurso del tenant 2: 23503 FK compuesta (tenant_id, resource_id)',
    $$INSERT INTO scheduling.schedule_templates (id, tenant_id, resource_id, name, status_concept_id, created_at, updated_at)
      VALUES ('b0000000-0000-4000-8000-000000000003', '11111111-0000-4000-8000-000000000001', '22222222-0000-4000-8000-0000000000d2', 'Cruce recurso', '99999999-0000-4000-8000-000000000002', now(), now())$$,
    '23503', 'fk_schedule_templates_tenant_resource');

SELECT pg_temp.debe_fallar('B-tenant', 'B4 plantilla del tenant 1 en el consultorio del tenant 2: 23503 FK compuesta (tenant_id, care_space_id)',
    $$INSERT INTO scheduling.schedule_templates (id, tenant_id, resource_id, care_space_id, name, status_concept_id, created_at, updated_at)
      VALUES ('b0000000-0000-4000-8000-000000000004', '11111111-0000-4000-8000-000000000001', '11111111-0000-4000-8000-0000000000d1', '22222222-0000-4000-8000-0000000000c3', 'Cruce espacio', '99999999-0000-4000-8000-000000000002', now(), now())$$,
    '23503', 'fk_schedule_templates_tenant_care_space');

SELECT pg_temp.debe_fallar('B-tenant', 'B5 mover una plantilla existente al consultorio del otro tenant (UPDATE): 23503',
    $$UPDATE scheduling.schedule_templates SET care_space_id = '22222222-0000-4000-8000-0000000000c3' WHERE id = 'b0000000-0000-4000-8000-000000000001'$$,
    '23503', 'fk_schedule_templates_tenant_care_space');

SELECT pg_temp.debe_fallar('B-tenant', 'B6 plantilla con un resource_id inexistente y sin tenant: 23503 (trigger)',
    $$INSERT INTO scheduling.schedule_templates (id, resource_id, name, status_concept_id, created_at, updated_at)
      VALUES ('b0000000-0000-4000-8000-000000000006', 'ffffffff-0000-4000-8000-000000000000', 'Huérfana', '99999999-0000-4000-8000-000000000002', now(), now())$$,
    '23503');

SELECT pg_temp.debe_fallar('B-tenant', 'B7 plantilla con consultorio inexistente: 23503 (FK simple)',
    $$INSERT INTO scheduling.schedule_templates (id, resource_id, care_space_id, name, status_concept_id, created_at, updated_at)
      VALUES ('b0000000-0000-4000-8000-000000000007', '11111111-0000-4000-8000-0000000000d1', 'ffffffff-0000-4000-8000-000000000001', 'Espacio fantasma', '99999999-0000-4000-8000-000000000002', now(), now())$$,
    '23503');

-- plantilla del tenant 2 para las pruebas de RLS
INSERT INTO scheduling.schedule_templates (id, resource_id, care_space_id, name, status_concept_id, created_at, updated_at)
VALUES ('b0000000-0000-4000-8000-0000000000f2', '22222222-0000-4000-8000-0000000000d2', '22222222-0000-4000-8000-0000000000c3', 'Plantilla T2', '99999999-0000-4000-8000-000000000002', now(), now());

-- ------------------------------------------------------------------ C. excepciones (origen)
SELECT pg_temp.debe_pasar('C-excepcion', 'C1 excepción manual (sin origen) y SIN tenant_id: trigger completa el tenant',
    $$INSERT INTO scheduling.availability_exceptions (id, resource_id, exception_type_concept_id, start_at, end_at, created_at, updated_at)
      VALUES ('c0000000-0000-4000-8000-000000000001', '11111111-0000-4000-8000-0000000000d1', '99999999-0000-4000-8000-000000000002', '2030-03-01 08:00-04', '2030-03-01 12:00-04', now(), now())$$);

INSERT INTO t_results(grupo, etiqueta, ok, detalle)
SELECT 'C-excepcion', 'C1b tenant_id de la excepción = tenant del recurso', tenant_id = '11111111-0000-4000-8000-000000000001', 'tenant_id=' || tenant_id
  FROM scheduling.availability_exceptions WHERE id = 'c0000000-0000-4000-8000-000000000001';

SELECT pg_temp.debe_pasar('C-excepcion', 'C2 excepción con origen (bloqueo de espacio) y referencia al espacio entra',
    $$INSERT INTO scheduling.availability_exceptions (id, resource_id, exception_type_concept_id, start_at, end_at, source_kind_concept_id, source_ref_id, created_at, updated_at)
      VALUES ('c0000000-0000-4000-8000-000000000002', '11111111-0000-4000-8000-0000000000d1', '99999999-0000-4000-8000-000000000002', '2030-03-02 08:00-04', '2030-03-02 12:00-04', '99999999-0000-4000-8000-000000000002', '11111111-0000-4000-8000-0000000000c1', now(), now())$$);

SELECT pg_temp.debe_fallar('C-excepcion', 'C3 referencia de origen SIN origen: 23514 ck_availability_exceptions_source_ref_needs_kind',
    $$INSERT INTO scheduling.availability_exceptions (id, resource_id, exception_type_concept_id, start_at, end_at, source_ref_id, created_at, updated_at)
      VALUES ('c0000000-0000-4000-8000-000000000003', '11111111-0000-4000-8000-0000000000d1', '99999999-0000-4000-8000-000000000002', '2030-03-03 08:00-04', '2030-03-03 12:00-04', '11111111-0000-4000-8000-0000000000c1', now(), now())$$,
    '23514', 'ck_availability_exceptions_source_ref_needs_kind');

SELECT pg_temp.debe_fallar('C-tenant', 'C4 excepción del tenant 1 sobre el recurso del tenant 2: 23503 FK compuesta',
    $$INSERT INTO scheduling.availability_exceptions (id, tenant_id, resource_id, exception_type_concept_id, start_at, end_at, created_at, updated_at)
      VALUES ('c0000000-0000-4000-8000-000000000004', '11111111-0000-4000-8000-000000000001', '22222222-0000-4000-8000-0000000000d2', '99999999-0000-4000-8000-000000000002', '2030-03-04 08:00-04', '2030-03-04 12:00-04', now(), now())$$,
    '23503', 'fk_availability_exceptions_tenant_resource');

INSERT INTO scheduling.availability_exceptions (id, resource_id, exception_type_concept_id, start_at, end_at, created_at, updated_at)
VALUES ('c0000000-0000-4000-8000-0000000000f2', '22222222-0000-4000-8000-0000000000d2', '99999999-0000-4000-8000-000000000002', '2030-03-05 08:00-04', '2030-03-05 12:00-04', now(), now());

-- ------------------------------------------------------------------ D. RLS entre tenants (rol mantra_app)
SELECT pg_temp.contar_como('D-RLS', 'D1 como tenant 1 ve exactamente 2 plantillas (B1, B2) y ninguna del tenant 2', '11111111-0000-4000-8000-000000000001',
    $$SELECT count(*) FROM scheduling.schedule_templates$$, 2);
SELECT pg_temp.contar_como('D-RLS', 'D2 como tenant 2 ve 1 plantilla (la suya)', '22222222-0000-4000-8000-000000000002',
    $$SELECT count(*) FROM scheduling.schedule_templates$$, 1);
SELECT pg_temp.contar_como('D-RLS', 'D3 SIN tenant en el contexto: 0 plantillas (falla cerrado)', NULL,
    $$SELECT count(*) FROM scheduling.schedule_templates$$, 0);
SELECT pg_temp.contar_como('D-RLS', 'D4 contexto SYSTEM: ve las 3 plantillas', 'system',
    $$SELECT count(*) FROM scheduling.schedule_templates$$, 3);
SELECT pg_temp.contar_como('D-RLS', 'D5 como tenant 1 ve 2 excepciones (C1, C2), no la del tenant 2', '11111111-0000-4000-8000-000000000001',
    $$SELECT count(*) FROM scheduling.availability_exceptions$$, 2);
SELECT pg_temp.contar_como('D-RLS', 'D6 como tenant 2 ve 1 excepción (la suya)', '22222222-0000-4000-8000-000000000002',
    $$SELECT count(*) FROM scheduling.availability_exceptions$$, 1);
SELECT pg_temp.contar_como('D-RLS', 'D7 SIN tenant: 0 excepciones', NULL,
    $$SELECT count(*) FROM scheduling.availability_exceptions$$, 0);

SELECT pg_temp.debe_fallar_como('D-RLS', 'D8 como tenant 1, INSERT de plantilla con tenant_id del tenant 2: 42501 (WITH CHECK)', '11111111-0000-4000-8000-000000000001',
    $$INSERT INTO scheduling.schedule_templates (id, tenant_id, resource_id, name, status_concept_id, created_at, updated_at)
      VALUES ('b0000000-0000-4000-8000-000000000009', '22222222-0000-4000-8000-000000000002', '22222222-0000-4000-8000-0000000000d2', 'Intruso', '99999999-0000-4000-8000-000000000002', now(), now())$$,
    '42501');

SELECT pg_temp.debe_fallar_como('D-RLS', 'D9 como tenant 1, INSERT de plantilla sobre el recurso del tenant 2 sin tenant_id: 23503 (el trigger no lo ve)', '11111111-0000-4000-8000-000000000001',
    $$INSERT INTO scheduling.schedule_templates (id, resource_id, name, status_concept_id, created_at, updated_at)
      VALUES ('b0000000-0000-4000-8000-000000000010', '22222222-0000-4000-8000-0000000000d2', 'Intruso sin tenant', '99999999-0000-4000-8000-000000000002', now(), now())$$,
    '23503');

SELECT pg_temp.debe_pasar('D-RLS', 'D10 el UPDATE de una fila ajena como tenant 1 no toca nada (0 filas)',
    $x$DO $b$ DECLARE n int; BEGIN
        SET LOCAL ROLE mantra_app;
        PERFORM set_config('app.current_tenant_id', '11111111-0000-4000-8000-000000000001', true);
        UPDATE scheduling.schedule_templates SET name = 'hackeada' WHERE id = 'b0000000-0000-4000-8000-0000000000f2';
        GET DIAGNOSTICS n = ROW_COUNT;
        RESET ROLE;
        PERFORM set_config('app.current_tenant_id', '', true);
        IF n <> 0 THEN RAISE EXCEPTION 'actualizó % fila(s) ajena(s)', n; END IF;
    END $b$$x$);

INSERT INTO t_results(grupo, etiqueta, ok, detalle)
SELECT 'D-RLS', 'D10b la plantilla del tenant 2 conserva su nombre', name = 'Plantilla T2', 'name=' || name
  FROM scheduling.schedule_templates WHERE id = 'b0000000-0000-4000-8000-0000000000f2';

SELECT pg_temp.debe_pasar('D-RLS', 'D11 como tenant 1 una plantilla propia válida (tenant omitido) entra y recibe tenant 1',
    $x$DO $b$ DECLARE t uuid; BEGIN
        SET LOCAL ROLE mantra_app;
        PERFORM set_config('app.current_tenant_id', '11111111-0000-4000-8000-000000000001', true);
        INSERT INTO scheduling.schedule_templates (id, resource_id, care_space_id, name, status_concept_id, created_at, updated_at)
        VALUES ('b0000000-0000-4000-8000-000000000012', '11111111-0000-4000-8000-0000000000d1', '11111111-0000-4000-8000-0000000000c2', 'Propia', '99999999-0000-4000-8000-000000000002', now(), now())
        RETURNING tenant_id INTO t;
        RESET ROLE;
        PERFORM set_config('app.current_tenant_id', '', true);
        IF t <> '11111111-0000-4000-8000-000000000001' THEN RAISE EXCEPTION 'tenant_id=%', t; END IF;
    END $b$$x$);

SELECT pg_temp.debe_fallar_como('D-RLS', 'D12 como tenant 1, cita en el consultorio del tenant 2: 23503 (la FK compuesta ignora RLS)', '11111111-0000-4000-8000-000000000001',
    pg_temp.cita('a0000000-0000-4000-8000-000000000013', NULL, '22222222-0000-4000-8000-0000000000c3', '51530fd7-05b1-5c29-80c4-da740ede4d27', '2030-02-02 10:00-04', '2030-02-02 10:30-04'),
    '23503');

SELECT pg_temp.debe_fallar_como('D-RLS', 'D13 como tenant 1 (mantra_app), cita solapada con A1 en CON-1: 23P01', '11111111-0000-4000-8000-000000000001',
    pg_temp.cita('a0000000-0000-4000-8000-000000000014', NULL, '11111111-0000-4000-8000-0000000000c1', '51530fd7-05b1-5c29-80c4-da740ede4d27', '2030-01-07 14:05-04', '2030-01-07 14:20-04'),
    '23P01');

-- ------------------------------------------------------------------ resultado
SELECT grupo, etiqueta, CASE WHEN ok THEN 'PASS' ELSE 'FAIL' END AS resultado, detalle FROM t_results ORDER BY n;
SELECT count(*) FILTER (WHERE ok) AS pass, count(*) FILTER (WHERE NOT ok) AS fail, count(*) AS total FROM t_results;

DO $$
DECLARE
    n_fail integer;
BEGIN
    SELECT count(*) INTO n_fail FROM t_results WHERE NOT ok;
    IF n_fail > 0 THEN
        RAISE EXCEPTION 'F5d: % comprobación(es) fallaron', n_fail USING ERRCODE = 'P0003';
    END IF;
END $$;

ROLLBACK;
