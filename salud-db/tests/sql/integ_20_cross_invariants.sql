-- ============================================================================
-- Integración de infraestructura hospitalaria (F1c–F5): invariantes CRUZADAS contra la base
-- integrada, cada una con su SQLSTATE. Una transacción con ROLLBACK: no deja nada.
--   I1  cama → paciente 1:1 (F3)            I2  quirófano con preparación y limpieza (F4)
--   I3  doble reserva de consultorio (F5d)  I4  doble cobro de la noche (F5e)
--   I5  aislamiento RLS entre tenants, como mantra_app, en tablas de F2/F3/F4/F5/F1c
-- Reutiliza la fixture de M-F5-fin (dos tenants, camas, quirófano, catálogo de servicios).
-- Cada «CASO OK [...] -> SQLSTATE» es una aserción; un «CASO FALLIDO» aborta el script.
-- ============================================================================
\set ON_ERROR_STOP on
BEGIN;
\ir f5_fin_00_fixture.sql

SET LOCAL app.system_context = 'true';
ALTER TABLE terminology.catalog_concepts DISABLE TRIGGER ALL;
INSERT INTO terminology.catalog_concepts (id, code_system_version_id, code, display, created_at, updated_at)
SELECT c.id::uuid, gen_random_uuid(), c.code, c.code, now(), now() FROM (VALUES
  ('63ef5a86-740b-5fc6-8b93-3010ed5067a8', 'LOC_FORM_BED'),
  ('809db700-0627-5fe3-8278-4f038f4475b3', 'LOCATION_ACTIVE'),
  ('8cf00069-81ca-56e1-8e71-9e16333a1f6c', 'LOCATION_COMPLETED'),
  ('cdd86257-4297-5941-8ae8-b95e11439a48', 'LOCATION_RESERVED'),
  ('6fe38139-ad1d-5214-84c1-8c184e4e58fb', 'CASE_SCHEDULED'),
  ('51530fd7-05b1-5c29-80c4-da740ede4d27', 'APPOINTMENT_BOOKED'),
  ('37dded87-7a7a-5a24-86f6-0ef48cccb482', 'APPOINTMENT_CHECKED_IN')) AS c(id, code)
ON CONFLICT (id) DO NOTHING;
ALTER TABLE terminology.catalog_concepts ENABLE TRIGGER ALL;

-- Las camas de la fixture pasan a tener forma «cama»; el quirófano, recambio 15 + 20 minutos.
UPDATE practice.care_spaces SET form_concept_id = '63ef5a86-740b-5fc6-8b93-3010ed5067a8'
 WHERE bed_category_concept_id IS NOT NULL;
UPDATE practice.care_spaces SET prep_minutes = 15, cleanup_minutes = 20 WHERE id = 'a1300000-0000-4000-8000-000000000006';

-- ============================================================ I1 · cama → paciente 1:1
CREATE FUNCTION pg_temp.ubic(enc uuid, espacio uuid, sede uuid, estado uuid, ini timestamptz, fin timestamptz, bed boolean DEFAULT true, tenant uuid DEFAULT NULL)
RETURNS text LANGUAGE sql AS $f$
  SELECT format($q$INSERT INTO clinical.encounter_locations (id, encounter_id, practice_site_id, care_space_id, location_status_concept_id, period_start, period_end, is_bed_assignment, tenant_id, created_at, updated_at)
                   VALUES (gen_random_uuid(), %L, %L, %L, %L, %L, %L, %L, %L, now(), now())$q$, enc, sede, espacio, estado, ini, fin, bed, tenant)
$f$;
\set ACT '809db700-0627-5fe3-8278-4f038f4475b3'
\set COM '8cf00069-81ca-56e1-8e71-9e16333a1f6c'
\set A1S  'a1100000-0000-4000-8000-000000000001'
\set BED1 'a1300000-0000-4000-8000-000000000001'
\set UCI1 'a1300000-0000-4000-8000-000000000002'
SELECT pg_temp.caso('I1 paciente 1 ocupa la cama 301-A', pg_temp.ubic('a5000000-0000-4000-8000-000000000001', :'BED1', :'A1S', :'ACT', '2031-03-01 08:00+00', NULL));
SELECT pg_temp.caso('I1 el paciente 2 NO puede ocupar la misma cama a la vez (cama→1 paciente)',
  pg_temp.ubic('a5000000-0000-4000-8000-000000000002', :'BED1', :'A1S', :'ACT', '2031-03-02 08:00+00', NULL), '23P01');
SELECT pg_temp.caso('I1 el cliente declara is_bed_assignment=false sobre una cama real: la base lo deriva y sigue chocando',
  pg_temp.ubic('a5000000-0000-4000-8000-000000000002', :'BED1', :'A1S', :'ACT', '2031-03-02 08:00+00', NULL, false), '23P01');
SELECT pg_temp.caso('I1 el paciente 1 NO puede estar en dos camas a la vez (paciente→1 cama)',
  pg_temp.ubic('a5000000-0000-4000-8000-000000000001', :'UCI1', :'A1S', :'ACT', '2031-03-03 08:00+00', NULL), '23P01');
SELECT pg_temp.caso('I1 cama de otro tenant en una ubicación del tenant A: FK compuesta (tenant, espacio)',
  pg_temp.ubic('a5000000-0000-4000-8000-000000000003', 'b1300000-0000-4000-8000-000000000003', 'b1100000-0000-4000-8000-000000000001', :'ACT', '2031-03-04 08:00+00', NULL, true, 'a0000000-0000-4000-8000-000000000001'), '23503');
-- traslado en una transacción: cerrar el origen y abrir el destino, en cualquier orden (restricciones diferibles)
SET CONSTRAINTS ALL DEFERRED;
SELECT pg_temp.caso('I1 traslado: se abre el destino ANTES de cerrar el origen, diferido',
  pg_temp.ubic('a5000000-0000-4000-8000-000000000001', :'UCI1', :'A1S', :'ACT', '2031-03-05 08:00+00', NULL));
UPDATE clinical.encounter_locations SET period_end = '2031-03-05 08:00+00', location_status_concept_id = :'COM'
 WHERE encounter_id = 'a5000000-0000-4000-8000-000000000001' AND care_space_id = :'BED1';
SET CONSTRAINTS ALL IMMEDIATE;
SELECT pg_temp.afirmar('I1 tras el traslado el paciente 1 queda con UNA sola ubicación activa',
  $$SELECT count(*)::text FROM clinical.encounter_locations WHERE encounter_id = 'a5000000-0000-4000-8000-000000000001' AND location_status_concept_id = '809db700-0627-5fe3-8278-4f038f4475b3'$$, '1');
SELECT pg_temp.caso('I1 la cama 301-A queda libre para el paciente 2 desde el traslado',
  pg_temp.ubic('a5000000-0000-4000-8000-000000000002', :'BED1', :'A1S', :'ACT', '2031-03-05 09:00+00', NULL));

-- ============================================================ I2 · quirófano con preparación y limpieza
-- Sala A1-QX1 (prep 15 min, limpieza 20 min). Caso 1: 08:00–09:00 → ventana reservada 07:45–09:20.
CREATE FUNCTION pg_temp.caso_qx(n text, ini timestamptz, fin timestamptz, prep int DEFAULT NULL, lim int DEFAULT NULL) RETURNS text LANGUAGE sql AS $f$
  SELECT format($q$INSERT INTO procedures_perioperative.procedure_cases (id, custodian_tenant_id, patient_profile_id, case_number, case_type_concept_id, priority_concept_id, status_concept_id, practice_site_id, operating_room_id, scheduled_start_at, scheduled_end_at, prep_minutes, cleanup_minutes, created_at, updated_at)
                  VALUES (gen_random_uuid(), 'a0000000-0000-4000-8000-000000000001', 'a4000000-0000-4000-8000-000000000001', %L, 'c0000000-0000-4000-8000-000000000020', 'c0000000-0000-4000-8000-000000000020', '6fe38139-ad1d-5214-84c1-8c184e4e58fb', 'a1100000-0000-4000-8000-000000000001', 'a1300000-0000-4000-8000-000000000006', %L, %L, %s, %s, now(), now())$q$,
                 n, ini, fin, coalesce(prep::text, 'NULL'), coalesce(lim::text, 'NULL'))
$f$;
SELECT pg_temp.caso('I2 caso 08:00–09:00 en la sala', pg_temp.caso_qx('INT-1', '2031-04-01 08:00+00', '2031-04-01 09:00+00'));
SELECT pg_temp.caso('I2 un caso que empieza a las 09:10 cae en la LIMPIEZA del anterior (09:00–09:20): rechazado',
  pg_temp.caso_qx('INT-2', '2031-04-01 09:10+00', '2031-04-01 10:00+00'), '23P01');
SELECT pg_temp.caso('I2 un caso que termina a las 07:50 invade la PREPARACIÓN del siguiente (07:45–08:00): rechazado',
  pg_temp.caso_qx('INT-3', '2031-04-01 07:00+00', '2031-04-01 07:50+00'), '23P01');
SELECT pg_temp.caso('I2 empieza a las 09:35 (09:20 libre + su preparación de 15 min): admitido',
  pg_temp.caso_qx('INT-4', '2031-04-01 09:35+00', '2031-04-01 10:30+00'));
SELECT pg_temp.caso('I2 la sala de otro tenant NO es alcanzable: sala de B con custodio A (FK compuesta caso → sala)',
  $$UPDATE procedures_perioperative.procedure_cases SET operating_room_id = 'b1300000-0000-4000-8000-000000000003' WHERE case_number = 'INT-4'$$, '23503');

-- ============================================================ I3 · doble reserva de consultorio
ALTER TABLE clinical.appointments DISABLE TRIGGER ALL;
CREATE FUNCTION pg_temp.cita(espacio uuid, medico uuid, ini timestamptz, fin timestamptz) RETURNS text LANGUAGE sql AS $f$
  SELECT format($q$INSERT INTO clinical.appointments (id, patient_profile_id, practitioner_profile_id, tenant_id, care_space_id, status_concept_id, start_at, end_at, created_at, updated_at)
                   VALUES (gen_random_uuid(), 'a4000000-0000-4000-8000-000000000001', %L, 'a0000000-0000-4000-8000-000000000001', %L, '51530fd7-05b1-5c29-80c4-da740ede4d27', %L, %L, now(), now())$q$, medico, espacio, ini, fin)
$f$;
\set CONS 'a1300000-0000-4000-8000-000000000005'
SELECT pg_temp.caso('I3 cita 10:00–10:30 en el consultorio 1', pg_temp.cita(:'CONS', gen_random_uuid(), '2031-05-01 10:00+00', '2031-05-01 10:30+00'));
SELECT pg_temp.caso('I3 otra cita de OTRO médico 10:15–10:45 en el mismo consultorio: doble reserva rechazada',
  pg_temp.cita(:'CONS', gen_random_uuid(), '2031-05-01 10:15+00', '2031-05-01 10:45+00'), '23P01');
SELECT pg_temp.caso('I3 contigua 10:30–11:00 (intervalo semiabierto): admitida',
  pg_temp.cita(:'CONS', gen_random_uuid(), '2031-05-01 10:30+00', '2031-05-01 11:00+00'));
ALTER TABLE clinical.appointments ENABLE TRIGGER ALL;

-- ============================================================ I4 · doble cobro de la noche
INSERT INTO practice.care_space_category_periods (id, tenant_id, care_space_id, bed_category_concept_id, valid_from, valid_to, created_at, updated_at, row_version)
SELECT gen_random_uuid(), tenant_id, id, bed_category_concept_id, '2026-01-01', NULL, now(), now(), 1 FROM practice.care_spaces WHERE bed_category_concept_id IS NOT NULL;
INSERT INTO billing.space_tariffs (id, tenant_id, practice_id, tariff_kind_concept_id, bed_category_concept_id, care_space_id, service_catalog_id, unit_minutes, minimum_units, unit_price, currency_concept_id, valid_from, valid_to, status_concept_id, created_at, updated_at, row_version)
VALUES ('f1000000-0000-4000-8000-0000000000e1', 'a0000000-0000-4000-8000-000000000001', 'a1000000-0000-4000-8000-000000000001', '1ae01bf6-a061-52ed-aa26-590705cb2202', 'c0000000-0000-4000-8000-000000000001', NULL, 'a6000000-0000-4000-8000-000000000001', NULL, NULL, 100, 'c0000000-0000-4000-8000-000000000010', '2026-01-01', NULL, 'c0000000-0000-4000-8000-000000000020', now(), now(), 1);
CREATE FUNCTION pg_temp.noche(enc uuid, pac uuid, clave text, dia date) RETURNS text LANGUAGE sql AS $f$
  SELECT 'INSERT INTO billing.charge_captures SELECT (jsonb_populate_record(NULL::billing.charge_captures, ' || quote_literal(jsonb_build_object(
    'id', gen_random_uuid(), 'tenant_id', 'a0000000-0000-4000-8000-000000000001', 'practice_id', 'a1000000-0000-4000-8000-000000000001',
    'patient_profile_id', pac, 'encounter_id', enc, 'source_kind_concept_id', '5f84ea44-b0d3-582c-86c1-32c81e422d30', 'source_ref_id', gen_random_uuid(),
    'service_date', dia, 'care_space_id', 'a1300000-0000-4000-8000-000000000001', 'bed_category_concept_id', 'c0000000-0000-4000-8000-000000000001',
    'space_tariff_id', 'f1000000-0000-4000-8000-0000000000e1', 'service_catalog_id', 'a6000000-0000-4000-8000-000000000001', 'minimum_stay_charge', false,
    'quantity', 1, 'unit_price', 100, 'currency_concept_id', 'c0000000-0000-4000-8000-000000000010', 'status_concept_id', '17def99a-0cb5-586c-a440-59d809709c0d',
    'idempotency_key', clave, 'created_at', now(), 'updated_at', now(), 'row_version', 1)::text) || '::jsonb)).*'
$f$;
SELECT pg_temp.caso('I4 cargo de la noche del 2031-06-10 de la cama 301-A', pg_temp.noche('a5000000-0000-4000-8000-000000000001', 'a4000000-0000-4000-8000-000000000001', 'K1', '2031-06-10'));
SELECT pg_temp.caso('I4 el mismo encuentro, la misma noche, otra clave de idempotencia: rechazado',
  pg_temp.noche('a5000000-0000-4000-8000-000000000001', 'a4000000-0000-4000-8000-000000000001', 'K2', '2031-06-10'), '23505');
SELECT pg_temp.caso('I4 OTRO paciente, la MISMA cama y la misma noche: rechazado (cama + noche)',
  pg_temp.noche('a5000000-0000-4000-8000-000000000002', 'a4000000-0000-4000-8000-000000000002', 'K3', '2031-06-10'), '23505');
SELECT pg_temp.caso('I4 la clave de idempotencia repetida: rechazada',
  pg_temp.noche('a5000000-0000-4000-8000-000000000001', 'a4000000-0000-4000-8000-000000000001', 'K1', '2031-06-11'), '23505');
SELECT pg_temp.caso('I4 la noche siguiente sí se puede cobrar', pg_temp.noche('a5000000-0000-4000-8000-000000000001', 'a4000000-0000-4000-8000-000000000001', 'K4', '2031-06-11'));

-- ============================================================ I5 · aislamiento RLS entre tenants (mantra_app)
-- Una fila por tabla de F1c/F2/F3/F4/F5 que el escenario anterior o la fixture dejó en el tenant A:
-- el tenant B (con contexto) no ve NINGUNA fila del A, y sin contexto no ve nada.
CREATE TEMP TABLE _rls (tabla text, filas_a bigint, visto_por_b bigint, visto_sin_contexto bigint);
GRANT ALL ON _rls TO mantra_app;
DO $$
DECLARE
    t text;
    a bigint; b bigint; s bigint;
BEGIN
    FOREACH t IN ARRAY ARRAY['clinical.encounter_locations', 'procedures_perioperative.procedure_cases', 'clinical.appointments',
                             'billing.charge_captures', 'billing.space_tariffs', 'practice.care_space_category_periods',
                             'practice.care_spaces', 'practice.practice_sites', 'practice.clinical_units', 'clinical.encounters'] LOOP
        SET LOCAL ROLE mantra_app;
        PERFORM set_config('app.system_context', 'false', true);
        PERFORM set_config('app.current_tenant_id', 'a0000000-0000-4000-8000-000000000001', true);
        EXECUTE format('SELECT count(*) FROM %s', t) INTO a;
        PERFORM set_config('app.current_tenant_id', 'b0000000-0000-4000-8000-000000000001', true);
        EXECUTE format('SELECT count(*) FROM %s WHERE %I = %L', t,
                       CASE WHEN t = 'procedures_perioperative.procedure_cases' THEN 'custodian_tenant_id' ELSE 'tenant_id' END,
                       'a0000000-0000-4000-8000-000000000001') INTO b;
        PERFORM set_config('app.current_tenant_id', '', true);
        EXECUTE format('SELECT count(*) FROM %s', t) INTO s;
        RESET ROLE;
        INSERT INTO _rls VALUES (t, a, b, s);
    END LOOP;
END $$;
SELECT pg_temp.afirmar('I5 el tenant B no ve ninguna fila del A en ' || tabla, format($q$SELECT visto_por_b::text FROM _rls WHERE tabla = %L$q$, tabla), '0') FROM _rls;
SELECT pg_temp.afirmar('I5 sin contexto de tenant no se ve ninguna fila en ' || tabla, format($q$SELECT visto_sin_contexto::text FROM _rls WHERE tabla = %L$q$, tabla), '0') FROM _rls;
SELECT pg_temp.afirmar('I5 el tenant A ve sus filas en ' || tabla, format($q$SELECT (filas_a > 0)::text FROM _rls WHERE tabla = %L$q$, tabla), 'true') FROM _rls
 WHERE tabla IN ('clinical.encounter_locations', 'procedures_perioperative.procedure_cases', 'clinical.appointments', 'billing.charge_captures', 'billing.space_tariffs',
                 'practice.care_space_category_periods', 'practice.care_spaces', 'practice.practice_sites', 'practice.clinical_units', 'clinical.encounters');

ROLLBACK;
