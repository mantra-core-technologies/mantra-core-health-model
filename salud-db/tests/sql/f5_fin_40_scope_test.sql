-- ============================================================================
-- M-F5-fin · hallazgos de seguridad (alcance entre tenants e invariante en las dos direcciones).
--  1. únicos de billing.charge_captures acotados por tenant + origen de quirófano = caso del mismo
--     tenant y práctica (billing.charge_source_case_ok, falla cerrado);
--  2. tarifas, cargos, activos y centros de costo no pueden quedar cruzando práctica porque se
--     mueva la sala / unidad / sede padre.
-- Con `-v mutacion=<nombre>` se aplica antes una MUTACIÓN (mutations/<nombre>.sql) que quita el
-- arreglo: la prueba tiene que FALLAR (la usa pytest). Transacción con ROLLBACK.
-- ============================================================================
\set ON_ERROR_STOP on
BEGIN;
\ir f5_fin_00_fixture.sql
\if :{?mutacion}
  \set mutfile 'mutations/' :mutacion '.sql'
  \ir :mutfile
\endif

-- Ayudantes (como en la prueba de billing).
CREATE FUNCTION pg_temp.cargo(over jsonb DEFAULT '{}') RETURNS text LANGUAGE sql AS $f$
  WITH m AS (SELECT jsonb_build_object(
            'id', gen_random_uuid(), 'tenant_id', 'a0000000-0000-4000-8000-000000000001', 'practice_id', 'a1000000-0000-4000-8000-000000000001',
            'patient_profile_id', 'a4000000-0000-4000-8000-000000000001', 'encounter_id', 'a5000000-0000-4000-8000-000000000001',
            'source_kind_concept_id', 'a79361f6-8787-56a5-9a90-a9436d02e217', 'source_ref_id', 'ca000000-0000-4000-8000-000000000001', 'service_date', '2026-12-01',
            'minimum_stay_charge', false, 'quantity', 2, 'status_concept_id', '17def99a-0cb5-586c-a440-59d809709c0d',
            'created_at', now(), 'updated_at', now(), 'row_version', 1) || over AS j)
  SELECT 'INSERT INTO billing.charge_captures SELECT (jsonb_populate_record(NULL::billing.charge_captures, ' ||
         quote_literal((j || CASE WHEN j ? 'idempotency_key' THEN '{}'::jsonb ELSE jsonb_build_object('idempotency_key', 'K:' || gen_random_uuid()) END)::text) || '::jsonb)).*'
    FROM m
$f$;

-- ============================================================ 1. origen del cargo de quirófano
SELECT pg_temp.caso('B cita el caso quirúrgico de A en un cargo propio (tenant B, práctica B1)',
  pg_temp.cargo('{"tenant_id":"b0000000-0000-4000-8000-000000000001","practice_id":"b1000000-0000-4000-8000-000000000001","patient_profile_id":"b4000000-0000-4000-8000-000000000001","encounter_id":"b5000000-0000-4000-8000-000000000001","source_ref_id":"ca000000-0000-4000-8000-000000000001"}'), '23503');
SELECT pg_temp.caso('A cobra su caso aunque B ya lo haya intentado (B no lo bloqueó)', pg_temp.cargo('{"idempotency_key":"ORTIME:ca000000-0000-4000-8000-000000000001"}'));
SELECT pg_temp.caso('caso de otra práctica del mismo tenant (c2 es de A2) en un cargo de A1',
  pg_temp.cargo('{"source_ref_id":"ca000000-0000-4000-8000-000000000002","service_date":"2026-12-02"}'), '23503');
SELECT pg_temp.caso('caso inexistente', pg_temp.cargo('{"source_ref_id":"ffffffff-ffff-4fff-8fff-ffffffffffff","service_date":"2026-12-03"}'), '23503');
SELECT pg_temp.caso('caso sin sede ni sala (falla cerrado)', pg_temp.cargo('{"source_ref_id":"ca000000-0000-4000-8000-000000000005","service_date":"2026-12-04"}'), '23503');
SELECT pg_temp.caso('caso sin sede pero con la sala de operaciones de A1 (se resuelve por la sala)',
  pg_temp.cargo('{"source_ref_id":"ca000000-0000-4000-8000-000000000004","service_date":"2026-12-05"}'));
SELECT pg_temp.caso('B cobra su propio caso', pg_temp.cargo('{"tenant_id":"b0000000-0000-4000-8000-000000000001","practice_id":"b1000000-0000-4000-8000-000000000001","patient_profile_id":"b4000000-0000-4000-8000-000000000001","encounter_id":"b5000000-0000-4000-8000-000000000001","source_ref_id":"ca000000-0000-4000-8000-000000000003"}'));

-- Sin oráculo: el mensaje de «caso de otro tenant» y el de «caso inexistente» son idénticos.
DO $t$
DECLARE m1 text; m2 text;
BEGIN
    BEGIN EXECUTE pg_temp.cargo('{"tenant_id":"b0000000-0000-4000-8000-000000000001","practice_id":"b1000000-0000-4000-8000-000000000001","patient_profile_id":"b4000000-0000-4000-8000-000000000001","encounter_id":"b5000000-0000-4000-8000-000000000001","source_ref_id":"ca000000-0000-4000-8000-000000000001","service_date":"2026-12-06"}');
    EXCEPTION WHEN OTHERS THEN m1 := SQLSTATE || ' ' || SQLERRM; END;
    BEGIN EXECUTE pg_temp.cargo('{"tenant_id":"b0000000-0000-4000-8000-000000000001","practice_id":"b1000000-0000-4000-8000-000000000001","patient_profile_id":"b4000000-0000-4000-8000-000000000001","encounter_id":"b5000000-0000-4000-8000-000000000001","source_ref_id":"ffffffff-ffff-4fff-8fff-ffffffffffff","service_date":"2026-12-06"}');
    EXCEPTION WHEN OTHERS THEN m2 := SQLSTATE || ' ' || SQLERRM; END;
    IF m1 IS NULL OR m1 IS DISTINCT FROM m2 THEN RAISE EXCEPTION 'CASO FALLIDO [mismo error para caso ajeno e inexistente]: "%" vs "%"', m1, m2; END IF;
    RAISE NOTICE 'CASO OK [el error por un caso de otro tenant es idéntico al de un caso inexistente: no delata existencia] -> %', left(m1, 5);
END $t$;

-- Desde la sesión de B (rol de aplicación): ni siquiera puede sondear con el tenant de A.
DO $t$
DECLARE o1 text; o2 text; ok_b boolean; ok_a boolean; ok_sys boolean; ok_none boolean;
BEGIN
    SET LOCAL ROLE mantra_app;
    SET LOCAL app.system_context = 'false';
    SET LOCAL app.current_tenant_id = 'b0000000-0000-4000-8000-000000000001';
    BEGIN EXECUTE pg_temp.cargo('{"source_ref_id":"ca000000-0000-4000-8000-000000000001","service_date":"2026-12-07"}'); EXCEPTION WHEN OTHERS THEN o1 := SQLSTATE; END;
    BEGIN EXECUTE pg_temp.cargo('{"source_ref_id":"ffffffff-ffff-4fff-8fff-ffffffffffff","service_date":"2026-12-07"}'); EXCEPTION WHEN OTHERS THEN o2 := SQLSTATE; END;
    ok_b := billing.charge_source_case_ok('a0000000-0000-4000-8000-000000000001', 'a1000000-0000-4000-8000-000000000001', 'ca000000-0000-4000-8000-000000000001');
    SET LOCAL app.current_tenant_id = 'a0000000-0000-4000-8000-000000000001';
    ok_a := billing.charge_source_case_ok('a0000000-0000-4000-8000-000000000001', 'a1000000-0000-4000-8000-000000000001', 'ca000000-0000-4000-8000-000000000001');
    SET LOCAL app.current_tenant_id = '';
    ok_none := billing.charge_source_case_ok('a0000000-0000-4000-8000-000000000001', 'a1000000-0000-4000-8000-000000000001', 'ca000000-0000-4000-8000-000000000001');
    SET LOCAL app.system_context = 'true';
    ok_sys := billing.charge_source_case_ok('a0000000-0000-4000-8000-000000000001', 'a1000000-0000-4000-8000-000000000001', 'ca000000-0000-4000-8000-000000000001');
    RESET ROLE;
    IF o1 IS DISTINCT FROM '42501' OR o2 IS DISTINCT FROM '42501' THEN RAISE EXCEPTION 'CASO FALLIDO [B con tenant_id de A: mismo rechazo para caso real e inexistente]: % / %', o1, o2; END IF;
    RAISE NOTICE 'CASO OK [sesión de B: insertar con tenant_id de A da 42501 tanto para un caso real como para uno inexistente] -> 42501';
    IF ok_b OR NOT ok_a OR ok_none OR NOT ok_sys THEN RAISE EXCEPTION 'CASO FALLIDO [charge_source_case_ok como oráculo]: B=% A=% sin tenant=% SYSTEM=%', ok_b, ok_a, ok_none, ok_sys; END IF;
    RAISE NOTICE 'CASO OK [charge_source_case_ok: B no puede preguntar por A (false), A sí, SYSTEM sí, sin tenant no] -> éxito';
END $t$;

DO $t$
DECLARE ok boolean;
BEGIN
    -- El contexto de sistema de la lectura se restaura al salir de la función.
    SET LOCAL ROLE mantra_app;
    SET LOCAL app.system_context = 'false';
    SET LOCAL app.current_tenant_id = 'a0000000-0000-4000-8000-000000000001';
    ok := billing.charge_source_case_ok('a0000000-0000-4000-8000-000000000001', 'a1000000-0000-4000-8000-000000000001', 'ca000000-0000-4000-8000-000000000001');
    IF current_setting('app.system_context') <> 'false' THEN RESET ROLE; RAISE EXCEPTION 'CASO FALLIDO [la lectura dejó app.system_context elevado]: %', current_setting('app.system_context'); END IF;
    RESET ROLE;
    RAISE NOTICE 'CASO OK [charge_source_case_ok restaura app.system_context tras leer] -> false';
END $t$;

-- ============================================================ 1b. los únicos llevan tenant_id (defensa en profundidad)
-- Con el trigger de guarda apagado (como si tuviera un bug), el ÍNDICE solo ya impide que el id de un
-- tenant bloquee el de otro: cargos de tenants distintos con el mismo source_ref_id / encuentro / fecha conviven.
ALTER TABLE billing.charge_captures DISABLE TRIGGER trg_charge_captures_guard;
SELECT pg_temp.caso('índice por tenant: otro tenant con el MISMO source_ref_id de quirófano no choca con el de A',
  pg_temp.cargo('{"tenant_id":"b0000000-0000-4000-8000-000000000001","practice_id":"b1000000-0000-4000-8000-000000000001","patient_profile_id":"b4000000-0000-4000-8000-000000000001","encounter_id":"b5000000-0000-4000-8000-000000000001","source_ref_id":"ca000000-0000-4000-8000-000000000001","service_date":"2026-12-08"}'));
SELECT pg_temp.caso('...y A sigue teniendo su cargo del caso (el dentro-del-tenant sigue único)',
  pg_temp.cargo('{"service_date":"2026-12-09"}'), '23505');
SELECT pg_temp.caso('índice por tenant: día-cama de A y de B con el mismo encuentro y fecha conviven',
  pg_temp.cargo('{"source_kind_concept_id":"5f84ea44-b0d3-582c-86c1-32c81e422d30","quantity":1,"care_space_id":"a1300000-0000-4000-8000-000000000001","service_date":"2026-12-10"}'));
SELECT pg_temp.caso('...el de B con el encuentro de A y la misma fecha',
  pg_temp.cargo('{"tenant_id":"b0000000-0000-4000-8000-000000000001","practice_id":"b1000000-0000-4000-8000-000000000001","patient_profile_id":"b4000000-0000-4000-8000-000000000001","source_kind_concept_id":"5f84ea44-b0d3-582c-86c1-32c81e422d30","quantity":1,"care_space_id":"b1300000-0000-4000-8000-000000000003","service_date":"2026-12-10"}'));
ALTER TABLE billing.charge_captures ENABLE TRIGGER trg_charge_captures_guard;
SELECT pg_temp.afirmar('los tres únicos de cargos tienen tenant_id como primera columna',
  $q$SELECT count(*)::text FROM pg_indexes WHERE schemaname = 'billing'
        AND indexname IN ('ux_charge_captures_bed_night', 'ux_charge_captures_encounter_bed_day', 'ux_charge_captures_or_case')
        AND indexdef LIKE '%btree (tenant_id, %'$q$, '3');

-- ============================================================ 2. el invariante «misma práctica» en la otra dirección
-- Dependientes: un activo y un centro de costo en A1, una tarifa propia y un cargo de la cama UCI-1.
INSERT INTO accounting.infrastructure_items (id, practice_id, name, category_concept_id, status_concept_id, care_space_id, created_at, updated_at)
VALUES ('e0000000-0000-4000-8000-000000000001', 'a1000000-0000-4000-8000-000000000001', 'Monitor', 'c0000000-0000-4000-8000-000000000020', 'c0000000-0000-4000-8000-000000000020', 'a1300000-0000-4000-8000-000000000001', now(), now());
UPDATE accounting.cost_centers SET clinical_unit_id = 'a1200000-0000-4000-8000-000000000001' WHERE id = 'a7000000-0000-4000-8000-000000000001';
INSERT INTO billing.space_tariffs (id, tenant_id, practice_id, tariff_kind_concept_id, bed_category_concept_id, care_space_id, service_catalog_id, unit_price, currency_concept_id, valid_from, status_concept_id, created_at, updated_at, row_version)
VALUES ('f1000000-0000-4000-8000-0000000000d1', 'a0000000-0000-4000-8000-000000000001', 'a1000000-0000-4000-8000-000000000001', '1ae01bf6-a061-52ed-aa26-590705cb2202', NULL, 'a1300000-0000-4000-8000-000000000002', 'a6000000-0000-4000-8000-000000000002', 300, 'c0000000-0000-4000-8000-000000000010', '2026-01-01', 'c0000000-0000-4000-8000-000000000020', now(), now(), 1);
SELECT pg_temp.caso('cargo día-cama en la cama UCI-1 (dependiente de facturación)',
  pg_temp.cargo('{"source_kind_concept_id":"5f84ea44-b0d3-582c-86c1-32c81e422d30","source_ref_id":"ca000000-0000-4000-8000-0000000000e1","quantity":1,"care_space_id":"a1300000-0000-4000-8000-000000000002","space_tariff_id":"f1000000-0000-4000-8000-0000000000d1","service_catalog_id":"a6000000-0000-4000-8000-000000000002","unit_price":300,"currency_concept_id":"c0000000-0000-4000-8000-000000000010","bed_category_concept_id":"c0000000-0000-4000-8000-000000000002","service_date":"2026-12-11"}'));

SELECT pg_temp.caso('mover una cama CON activo contable a una sede de OTRA práctica',
  $q$UPDATE practice.care_spaces SET practice_site_id = 'a2100000-0000-4000-8000-000000000001' WHERE id = 'a1300000-0000-4000-8000-000000000001'$q$, '23001');
SELECT pg_temp.caso('mover una cama CON tarifa y cargos de facturación a una sede de OTRA práctica',
  $q$UPDATE practice.care_spaces SET practice_site_id = 'a2100000-0000-4000-8000-000000000001' WHERE id = 'a1300000-0000-4000-8000-000000000002'$q$, '23001');
SELECT pg_temp.caso('mover una cama con dependientes a otra sede de la MISMA práctica (flujo de F1)',
  $q$UPDATE practice.care_spaces SET practice_site_id = 'a1100000-0000-4000-8000-000000000002' WHERE id = 'a1300000-0000-4000-8000-000000000002'$q$);
SELECT pg_temp.caso('mover un espacio SIN dependientes a una sede de otra práctica (flujo de F1)',
  $q$UPDATE practice.care_spaces SET practice_site_id = 'a2100000-0000-4000-8000-000000000001' WHERE id = 'a1300000-0000-4000-8000-000000000005'$q$);
SELECT pg_temp.caso('mover una unidad CON centro de costo a una sede de OTRA práctica',
  $q$UPDATE practice.clinical_units SET practice_site_id = 'a2100000-0000-4000-8000-000000000001' WHERE id = 'a1200000-0000-4000-8000-000000000001'$q$, '23001');
SELECT pg_temp.caso('mover una unidad con centro de costo a otra sede de la MISMA práctica',
  $q$UPDATE practice.clinical_units SET practice_site_id = 'a1100000-0000-4000-8000-000000000002' WHERE id = 'a1200000-0000-4000-8000-000000000001'$q$);
SELECT pg_temp.caso('mover una unidad SIN centro de costo a otra práctica',
  $q$UPDATE practice.clinical_units SET practice_site_id = 'a1100000-0000-4000-8000-000000000001' WHERE id = 'a2200000-0000-4000-8000-000000000001'$q$);
SELECT pg_temp.caso('pasar a otra práctica una sede cuyos espacios tienen activos / tarifas / cargos',
  $q$UPDATE practice.practice_sites SET practice_id = 'a2000000-0000-4000-8000-000000000001' WHERE id = 'a1100000-0000-4000-8000-000000000001'$q$, '23001');
SELECT pg_temp.caso('pasar a otra práctica una sede cuya unidad tiene centro de costo',
  $q$UPDATE practice.practice_sites SET practice_id = 'a2000000-0000-4000-8000-000000000001' WHERE id = 'a1100000-0000-4000-8000-000000000002'$q$, '23001');
SELECT pg_temp.caso('...pero dejar la sede en la misma práctica (UPDATE sin cambio de práctica)',
  $q$UPDATE practice.practice_sites SET practice_id = practice_id, name = 'Sede A1' WHERE id = 'a1100000-0000-4000-8000-000000000001'$q$);

-- El mensaje no revela datos: texto fijo, sin UUID.
DO $t$
DECLARE m text;
BEGIN
    BEGIN
        UPDATE practice.care_spaces SET practice_site_id = 'a2100000-0000-4000-8000-000000000001' WHERE id = 'a1300000-0000-4000-8000-000000000001';
    EXCEPTION WHEN OTHERS THEN m := SQLERRM; END;
    IF m IS NULL OR m ~* '[0-9a-f]{8}-[0-9a-f]{4}-' THEN RAISE EXCEPTION 'CASO FALLIDO [mensaje sin datos]: %', coalesce(m, 'sin error'); END IF;
    RAISE NOTICE 'CASO OK [el mensaje del rechazo no contiene ids ni datos de otras filas] -> %', m;
END $t$;

-- Con el rol de aplicación y RLS: la sesión de A mueve SU espacio; los dependientes se ven aunque el RLS los filtre.
DO $t$
DECLARE o text := NULL; n integer;
BEGIN
    SET LOCAL ROLE mantra_app;
    SET LOCAL app.system_context = 'false';
    SET LOCAL app.current_tenant_id = 'a0000000-0000-4000-8000-000000000001';
    BEGIN
        UPDATE practice.care_spaces SET practice_site_id = 'a2100000-0000-4000-8000-000000000001' WHERE id = 'a1300000-0000-4000-8000-000000000001';
    EXCEPTION WHEN OTHERS THEN o := SQLSTATE; END;
    -- y la sesión de B no ve (ni toca) el espacio de A: 0 filas, el trigger ni corre
    SET LOCAL app.current_tenant_id = 'b0000000-0000-4000-8000-000000000001';
    UPDATE practice.care_spaces SET practice_site_id = 'b1100000-0000-4000-8000-000000000001' WHERE id = 'a1300000-0000-4000-8000-000000000001';
    GET DIAGNOSTICS n = ROW_COUNT;
    RESET ROLE;
    IF o IS DISTINCT FROM '23001' THEN RAISE EXCEPTION 'CASO FALLIDO [mantra_app mueve un espacio con dependientes]: %', coalesce(o, 'éxito'); END IF;
    IF n <> 0 THEN RAISE EXCEPTION 'CASO FALLIDO [B no debería ver el espacio de A]: % filas', n; END IF;
    RAISE NOTICE 'CASO OK [mantra_app con RLS: el rechazo funciona y B no puede tocar el espacio de A] -> 23001 / 0 filas';
END $t$;

ROLLBACK;
