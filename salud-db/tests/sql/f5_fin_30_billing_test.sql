-- ============================================================================
-- M-F5-fin · prueba de F5e (facturación día-cama y quirófano por tiempo) contra Postgres real.
-- Requiere …_f5_accounting, …_f5_billing y …_f5_practice aplicados. Transacción con ROLLBACK.
--
-- La regla de medianoche (D7) la implementa el SERVICIO de la API, no la base. Acá se usa una
-- CONSULTA DE REFERENCIA (la misma que documenta DESVIOS-M-F5-fin.md) para demostrar que el
-- modelo admite una generación idempotente desde la ocupación y que el doble cobro de la misma
-- noche es imposible aunque el servicio se ejecute dos veces o dos servicios compitan.
-- ============================================================================
\set ON_ERROR_STOP on
BEGIN;
\ir f5_fin_00_fixture.sql

-- Períodos de categoría de las camas (lo que dejó el backfill de F5 prácticas).
INSERT INTO practice.care_space_category_periods (id, tenant_id, care_space_id, bed_category_concept_id, valid_from, valid_to, created_at, updated_at, row_version)
SELECT gen_random_uuid(), tenant_id, id, bed_category_concept_id, created_at, NULL, now(), now(), 1
  FROM practice.care_spaces WHERE bed_category_concept_id IS NOT NULL;

-- Ayudantes: una tarifa y un cargo «base» sobreescribibles con un jsonb.
CREATE FUNCTION pg_temp.tarifa(over jsonb DEFAULT '{}') RETURNS text LANGUAGE sql AS $f$
  SELECT 'INSERT INTO billing.space_tariffs SELECT (jsonb_populate_record(NULL::billing.space_tariffs, ' ||
         quote_literal((jsonb_build_object(
            'id', gen_random_uuid(), 'tenant_id', 'a0000000-0000-4000-8000-000000000001', 'practice_id', 'a1000000-0000-4000-8000-000000000001',
            'tariff_kind_concept_id', '1ae01bf6-a061-52ed-aa26-590705cb2202', 'bed_category_concept_id', 'c0000000-0000-4000-8000-000000000003',
            'service_catalog_id', 'a6000000-0000-4000-8000-000000000001', 'unit_price', 150, 'currency_concept_id', 'c0000000-0000-4000-8000-000000000010',
            'valid_from', '2030-01-01', 'status_concept_id', 'c0000000-0000-4000-8000-000000000020',
            'created_at', now(), 'updated_at', now(), 'row_version', 1) || over)::text) || '::jsonb)).*'
$f$;

CREATE FUNCTION pg_temp.cargo(over jsonb DEFAULT '{}') RETURNS text LANGUAGE sql AS $f$
  WITH m AS (SELECT jsonb_build_object(
            'id', gen_random_uuid(), 'tenant_id', 'a0000000-0000-4000-8000-000000000001', 'practice_id', 'a1000000-0000-4000-8000-000000000001',
            'patient_profile_id', 'a4000000-0000-4000-8000-000000000001', 'encounter_id', 'a5000000-0000-4000-8000-000000000001',
            'source_kind_concept_id', '5f84ea44-b0d3-582c-86c1-32c81e422d30', 'source_ref_id', gen_random_uuid(), 'service_date', '2026-12-01',
            'care_space_id', 'a1300000-0000-4000-8000-000000000001', 'bed_category_concept_id', 'c0000000-0000-4000-8000-000000000001',
            'space_tariff_id', 'f1000000-0000-4000-8000-000000000011', 'service_catalog_id', 'a6000000-0000-4000-8000-000000000001',
            'minimum_stay_charge', false, 'quantity', 1, 'unit_price', 120, 'currency_concept_id', 'c0000000-0000-4000-8000-000000000010',
            'status_concept_id', '17def99a-0cb5-586c-a440-59d809709c0d',
            'created_at', now(), 'updated_at', now(), 'row_version', 1) || over AS j)
  SELECT 'INSERT INTO billing.charge_captures SELECT (jsonb_populate_record(NULL::billing.charge_captures, ' ||
         quote_literal((j || CASE WHEN j ? 'idempotency_key' THEN '{}'::jsonb
                                  ELSE jsonb_build_object('idempotency_key', 'K:' || gen_random_uuid()) END)::text) || '::jsonb)).*'
    FROM m
$f$;

-- ============================================================ A. tarifas versionadas
INSERT INTO billing.space_tariffs (id, tenant_id, practice_id, tariff_kind_concept_id, bed_category_concept_id, care_space_id, service_catalog_id,
                                   unit_minutes, minimum_units, unit_price, currency_concept_id, valid_from, valid_to, status_concept_id, created_at, updated_at, row_version)
VALUES ('f1000000-0000-4000-8000-000000000001', 'a0000000-0000-4000-8000-000000000001', 'a1000000-0000-4000-8000-000000000001', '1ae01bf6-a061-52ed-aa26-590705cb2202', 'c0000000-0000-4000-8000-000000000001', NULL, 'a6000000-0000-4000-8000-000000000001', NULL, NULL, 100, 'c0000000-0000-4000-8000-000000000010', '2026-01-01', NULL, 'c0000000-0000-4000-8000-000000000020', now(), now(), 1),
       ('f1000000-0000-4000-8000-000000000002', 'a0000000-0000-4000-8000-000000000001', 'a1000000-0000-4000-8000-000000000001', '1ae01bf6-a061-52ed-aa26-590705cb2202', 'c0000000-0000-4000-8000-000000000002', NULL, 'a6000000-0000-4000-8000-000000000002', NULL, NULL, 300, 'c0000000-0000-4000-8000-000000000010', '2026-01-01', NULL, 'c0000000-0000-4000-8000-000000000020', now(), now(), 1),
       ('f1000000-0000-4000-8000-000000000003', 'a0000000-0000-4000-8000-000000000001', 'a1000000-0000-4000-8000-000000000001', '25eb53f6-8006-5959-bee9-65b16117bc9b', NULL, NULL, 'a6000000-0000-4000-8000-000000000003', 30, 1, 80, 'c0000000-0000-4000-8000-000000000010', '2026-01-01', NULL, 'c0000000-0000-4000-8000-000000000020', now(), now(), 1);

SELECT pg_temp.caso('tarifa que solapa a otra de la misma clase (práctica, tipo, categoría, sala)',
  pg_temp.tarifa('{"bed_category_concept_id":"c0000000-0000-4000-8000-000000000001","valid_from":"2026-06-01"}'), '23P01');
SELECT pg_temp.caso('dos tarifas generales de quirófano solapadas (los NULL de categoría y sala también chocan)',
  pg_temp.tarifa('{"tariff_kind_concept_id":"25eb53f6-8006-5959-bee9-65b16117bc9b","bed_category_concept_id":null,"unit_minutes":15,"valid_from":"2026-06-01","service_catalog_id":"a6000000-0000-4000-8000-000000000003"}'), '23P01');
SELECT pg_temp.caso('misma categoría pero otra clase (día-cama de una sala propia) NO choca con la de categoría',
  pg_temp.tarifa('{"bed_category_concept_id":null,"care_space_id":"a1300000-0000-4000-8000-000000000001","valid_from":"2040-01-01"}'));
SELECT pg_temp.caso('quirófano por tiempo sin unidad de minutos (TARIFF_OR_TIME ⇒ unit_minutes > 0)',
  pg_temp.tarifa('{"tariff_kind_concept_id":"25eb53f6-8006-5959-bee9-65b16117bc9b","bed_category_concept_id":null,"unit_minutes":null,"service_catalog_id":"a6000000-0000-4000-8000-000000000003"}'), '23514');
SELECT pg_temp.caso('quirófano por tiempo con unidad 0',
  pg_temp.tarifa('{"tariff_kind_concept_id":"25eb53f6-8006-5959-bee9-65b16117bc9b","bed_category_concept_id":null,"unit_minutes":0,"service_catalog_id":"a6000000-0000-4000-8000-000000000003"}'), '23514');
SELECT pg_temp.caso('día-cama con unidad de minutos (sin fracciones de día)',
  pg_temp.tarifa('{"unit_minutes":30}'), '23514');
SELECT pg_temp.caso('día-cama sin categoría ni sala (no hay tarifa «por defecto»)',
  pg_temp.tarifa('{"bed_category_concept_id":null}'), '23514');
SELECT pg_temp.caso('quirófano con categoría de cama',
  pg_temp.tarifa('{"tariff_kind_concept_id":"25eb53f6-8006-5959-bee9-65b16117bc9b","unit_minutes":30,"service_catalog_id":"a6000000-0000-4000-8000-000000000003","valid_from":"2031-01-01"}'), '23514');
SELECT pg_temp.caso('tipo de tarifa que no es TARIFF_BED_DAY ni TARIFF_OR_TIME',
  pg_temp.tarifa('{"tariff_kind_concept_id":"c0000000-0000-4000-8000-000000000020"}'), '23514');
SELECT pg_temp.caso('precio negativo', pg_temp.tarifa('{"unit_price":-1}'), '23514');
SELECT pg_temp.caso('valid_to <= valid_from', pg_temp.tarifa('{"valid_from":"2032-01-01","valid_to":"2032-01-01"}'), '23514');
SELECT pg_temp.caso('mínimo de unidades 0', pg_temp.tarifa('{"tariff_kind_concept_id":"25eb53f6-8006-5959-bee9-65b16117bc9b","bed_category_concept_id":null,"unit_minutes":15,"minimum_units":0,"service_catalog_id":"a6000000-0000-4000-8000-000000000003","valid_from":"2033-01-01"}'), '23514');
SELECT pg_temp.caso('tarifa de la práctica A1 con tenant_id de B (FK compuesta tenant_id, practice_id)',
  pg_temp.tarifa('{"tenant_id":"b0000000-0000-4000-8000-000000000001"}'), '23503');
SELECT pg_temp.caso('tarifa que toma un servicio del catálogo de OTRA práctica (TARIFF_SERVICE_NOT_IN_PRACTICE)',
  pg_temp.tarifa('{"service_catalog_id":"a6000000-0000-4000-8000-000000000004"}'), '23503');
SELECT pg_temp.caso('tarifa que toma un servicio de otro tenant',
  pg_temp.tarifa('{"service_catalog_id":"b6000000-0000-4000-8000-000000000001"}'), '23503');
SELECT pg_temp.caso('tarifa propia de una sala de otra práctica del mismo tenant',
  pg_temp.tarifa('{"bed_category_concept_id":null,"care_space_id":"a2300000-0000-4000-8000-000000000004"}'), '23503');
SELECT pg_temp.caso('tarifa propia de una sala de otro tenant',
  pg_temp.tarifa('{"bed_category_concept_id":null,"care_space_id":"b1300000-0000-4000-8000-000000000003"}'), '23503');
SELECT pg_temp.caso('moneda que no es un concepto', pg_temp.tarifa('{"currency_concept_id":"ffffffff-ffff-4fff-8fff-ffffffffffff"}'), '23503');
SELECT pg_temp.caso('borrar una tarifa', $q$DELETE FROM billing.space_tariffs WHERE id = 'f1000000-0000-4000-8000-000000000001'$q$, '23001');

-- ============================================================ B. generación desde la ocupación
-- Consulta de referencia de la regla de medianoche (D7). Para cada período de ocupación de una
-- cama censable (con categoría): por cada medianoche local M con inicio <= M < fin se devenga UN
-- día-cama con service_date = fecha(M) - 1, la categoría que la cama tenía EN M
-- (care_space_category_periods) y la tarifa vigente en service_date (la de la sala manda sobre la
-- de la categoría). Sin tarifa: el cargo queda PENDING sin precio. ON CONFLICT DO NOTHING es lo
-- que vuelve idempotente al job.
CREATE TEMP TABLE _gen (nombre text PRIMARY KEY, sql text NOT NULL);
INSERT INTO _gen VALUES ('medianoche', $g$
INSERT INTO billing.charge_captures
       (id, tenant_id, practice_id, patient_profile_id, encounter_id, source_kind_concept_id, source_ref_id, service_date,
        care_space_id, bed_category_concept_id, space_tariff_id, service_catalog_id, minimum_stay_charge, quantity,
        unit_price, currency_concept_id, cost_center_id, status_concept_id, invoice_line_id, void_reason,
        idempotency_key, created_at, updated_at, row_version)
SELECT gen_random_uuid(), e.tenant_id, pr.id, e.patient_profile_id, e.id,
       '5f84ea44-b0d3-582c-86c1-32c81e422d30'::uuid, el.id, m.d - 1,
       cs.id, cp.bed_category_concept_id, st.id, st.service_catalog_id, false, 1,
       st.unit_price, st.currency_concept_id, NULL, '17def99a-0cb5-586c-a440-59d809709c0d'::uuid, NULL, NULL,
       'BEDDAY:' || e.id || ':' || (m.d - 1), now(), now(), 1
  FROM clinical.encounter_locations el
  JOIN clinical.encounters e            ON e.id = el.encounter_id
  JOIN practice.care_spaces cs          ON cs.id = el.care_space_id AND cs.bed_category_concept_id IS NOT NULL
  JOIN practice.practice_sites ps       ON ps.id = cs.practice_site_id
  JOIN practice.practices pr            ON pr.id = ps.practice_id
 CROSS JOIN LATERAL generate_series((el.period_start AT TIME ZONE pr.time_zone)::date + 1,
                                    (el.period_end AT TIME ZONE pr.time_zone)::date, interval '1 day') AS g(d0)
 CROSS JOIN LATERAL (SELECT g.d0::date AS d, g.d0::date::timestamp AT TIME ZONE pr.time_zone AS inst) m
  JOIN practice.care_space_category_periods cp
       ON cp.care_space_id = cs.id AND cp.valid_from <= m.inst AND (cp.valid_to IS NULL OR m.inst < cp.valid_to)
  LEFT JOIN LATERAL (SELECT t.* FROM billing.space_tariffs t
                      WHERE t.practice_id = pr.id AND t.tariff_kind_concept_id = '1ae01bf6-a061-52ed-aa26-590705cb2202'
                        AND (t.care_space_id = cs.id OR (t.care_space_id IS NULL AND t.bed_category_concept_id = cp.bed_category_concept_id))
                        AND t.valid_from <= m.d - 1 AND (t.valid_to IS NULL OR m.d - 1 < t.valid_to)
                      ORDER BY (t.care_space_id IS NOT NULL) DESC LIMIT 1) st ON true
 WHERE el.period_start <= m.inst AND m.inst < el.period_end
ON CONFLICT DO NOTHING
$g$);
-- Estancia SIN ninguna medianoche en todo el encuentro: un día mínimo (billing.bed_day_min_one),
-- en la primera cama, con service_date = fecha local del ingreso. minimum_stay_charge = true.
INSERT INTO _gen VALUES ('minimo', $g$
INSERT INTO billing.charge_captures
       (id, tenant_id, practice_id, patient_profile_id, encounter_id, source_kind_concept_id, source_ref_id, service_date,
        care_space_id, bed_category_concept_id, space_tariff_id, service_catalog_id, minimum_stay_charge, quantity,
        unit_price, currency_concept_id, cost_center_id, status_concept_id, invoice_line_id, void_reason,
        idempotency_key, created_at, updated_at, row_version)
SELECT gen_random_uuid(), e.tenant_id, pr.id, e.patient_profile_id, e.id,
       '5f84ea44-b0d3-582c-86c1-32c81e422d30'::uuid, el.id, (el.period_start AT TIME ZONE pr.time_zone)::date,
       cs.id, cp.bed_category_concept_id, st.id, st.service_catalog_id, true, 1,
       st.unit_price, st.currency_concept_id, NULL, '17def99a-0cb5-586c-a440-59d809709c0d'::uuid, NULL, NULL,
       'BEDDAY:' || e.id || ':' || (el.period_start AT TIME ZONE pr.time_zone)::date, now(), now(), 1
  FROM clinical.encounter_locations el
  JOIN clinical.encounters e      ON e.id = el.encounter_id
  JOIN practice.care_spaces cs    ON cs.id = el.care_space_id AND cs.bed_category_concept_id IS NOT NULL
  JOIN practice.practice_sites ps ON ps.id = cs.practice_site_id
  JOIN practice.practices pr      ON pr.id = ps.practice_id
  JOIN practice.care_space_category_periods cp
       ON cp.care_space_id = cs.id AND cp.valid_from <= el.period_start AND (cp.valid_to IS NULL OR el.period_start < cp.valid_to)
  LEFT JOIN LATERAL (SELECT t.* FROM billing.space_tariffs t
                      WHERE t.practice_id = pr.id AND t.tariff_kind_concept_id = '1ae01bf6-a061-52ed-aa26-590705cb2202'
                        AND (t.care_space_id = cs.id OR (t.care_space_id IS NULL AND t.bed_category_concept_id = cp.bed_category_concept_id))
                        AND t.valid_from <= (el.period_start AT TIME ZONE pr.time_zone)::date
                        AND (t.valid_to IS NULL OR (el.period_start AT TIME ZONE pr.time_zone)::date < t.valid_to)
                      ORDER BY (t.care_space_id IS NOT NULL) DESC LIMIT 1) st ON true
 WHERE el.period_start = (SELECT min(x.period_start) FROM clinical.encounter_locations x WHERE x.encounter_id = e.id)
   AND NOT EXISTS (SELECT 1
                     FROM clinical.encounter_locations x
                    CROSS JOIN LATERAL generate_series((x.period_start AT TIME ZONE pr.time_zone)::date + 1,
                                                       (x.period_end AT TIME ZONE pr.time_zone)::date, interval '1 day') g(d0)
                    WHERE x.encounter_id = e.id AND x.period_start <= g.d0::date::timestamp AT TIME ZONE pr.time_zone
                      AND g.d0::date::timestamp AT TIME ZONE pr.time_zone < x.period_end)
ON CONFLICT DO NOTHING
$g$);

-- B.1 Ejemplo del contrato: ingreso 27/10 15:00 en cama compartida, traslado a UCI 28/10 10:00,
-- egreso 30/10 09:00 (hora local de La Paz, UTC-4) => exactamente 3 días-cama:
-- 27 (compartida) y 28 y 29 (UCI). El día del egreso (30) no se cobra.
INSERT INTO clinical.encounter_locations (id, encounter_id, practice_site_id, care_space_id, location_status_concept_id, period_start, period_end, created_at, updated_at, row_version)
VALUES ('10000000-0000-4000-8000-000000000001', 'a5000000-0000-4000-8000-000000000001', 'a1100000-0000-4000-8000-000000000001', 'a1300000-0000-4000-8000-000000000001', 'c0000000-0000-4000-8000-000000000020', '2026-10-27 15:00-04', '2026-10-28 10:00-04', now(), now(), 1),
       ('10000000-0000-4000-8000-000000000002', 'a5000000-0000-4000-8000-000000000001', 'a1100000-0000-4000-8000-000000000001', 'a1300000-0000-4000-8000-000000000002', 'c0000000-0000-4000-8000-000000000020', '2026-10-28 10:00-04', '2026-10-30 09:00-04', now(), now(), 1);

SELECT pg_temp.caso('1.ª ejecución del job: genera los días-cama del ejemplo', (SELECT sql FROM _gen WHERE nombre = 'medianoche'));
SELECT pg_temp.afirmar('ejemplo del contrato: exactamente 3 días-cama',
  $q$SELECT count(*) FROM billing.charge_captures WHERE encounter_id = 'a5000000-0000-4000-8000-000000000001'$q$, '3');
SELECT pg_temp.afirmar('fechas de servicio 27, 28 y 29 (el día del egreso, 30, no se cobra)',
  $q$SELECT string_agg(service_date::text, ',' ORDER BY service_date) FROM billing.charge_captures WHERE encounter_id = 'a5000000-0000-4000-8000-000000000001'$q$,
  '2026-10-27,2026-10-28,2026-10-29');
SELECT pg_temp.afirmar('categorías: 27 compartida; 28 y 29 UCI (el traslado cambia la tarifa desde la medianoche siguiente)',
  $q$SELECT string_agg(c.code, ',' ORDER BY k.service_date) FROM billing.charge_captures k JOIN terminology.catalog_concepts c ON c.id = k.bed_category_concept_id WHERE k.encounter_id = 'a5000000-0000-4000-8000-000000000001'$q$,
  'BED_CAT_SHARED,BED_CAT_ICU,BED_CAT_ICU');
SELECT pg_temp.afirmar('precios foto: 100, 300, 300',
  $q$SELECT string_agg(unit_price::int::text, ',' ORDER BY service_date) FROM billing.charge_captures WHERE encounter_id = 'a5000000-0000-4000-8000-000000000001'$q$,
  '100,300,300');
SELECT pg_temp.caso('2.ª ejecución del job (idempotente): no falla', (SELECT sql FROM _gen WHERE nombre = 'medianoche'));
SELECT pg_temp.afirmar('re-ejecutar el job no duplica cargos: siguen siendo 3',
  $q$SELECT count(*) FROM billing.charge_captures WHERE encounter_id = 'a5000000-0000-4000-8000-000000000001'$q$, '3');

-- B.2 Cambiar la tarifa con vigencia futura no altera cargos pasados.
SELECT pg_temp.caso('cerrar la tarifa compartida el 2026-11-01', $q$UPDATE billing.space_tariffs SET valid_to = '2026-11-01' WHERE id = 'f1000000-0000-4000-8000-000000000001'$q$);
SELECT pg_temp.caso('abrir la tarifa nueva (120) desde 2026-11-01, adyacente [)', pg_temp.tarifa('{"id":"f1000000-0000-4000-8000-000000000011","bed_category_concept_id":"c0000000-0000-4000-8000-000000000001","unit_price":120,"valid_from":"2026-11-01"}'));
SELECT pg_temp.caso('re-ejecutar el job tras el cambio de tarifa', (SELECT sql FROM _gen WHERE nombre = 'medianoche'));
SELECT pg_temp.afirmar('los cargos pasados conservan su precio foto (100, 300, 300)',
  $q$SELECT string_agg(unit_price::int::text, ',' ORDER BY service_date) FROM billing.charge_captures WHERE encounter_id = 'a5000000-0000-4000-8000-000000000001'$q$,
  '100,300,300');
SELECT pg_temp.afirmar('y siguen siendo 3 (la tarifa nueva no genera cargos nuevos por sí sola)',
  $q$SELECT count(*) FROM billing.charge_captures WHERE encounter_id = 'a5000000-0000-4000-8000-000000000001'$q$, '3');
SELECT pg_temp.caso('reescribir el precio de una tarifa que ya tiene cargos', $q$UPDATE billing.space_tariffs SET unit_price = 1 WHERE id = 'f1000000-0000-4000-8000-000000000001'$q$, '23001');
SELECT pg_temp.caso('adelantar valid_to de una tarifa antes de una fecha ya devengada con ella', $q$UPDATE billing.space_tariffs SET valid_to = '2026-10-27' WHERE id = 'f1000000-0000-4000-8000-000000000001'$q$, '23514');

-- B.3 Cambio de categoría de una cama entre noches (cerrar y abrir el período).
-- La cama 301-A pasa a PRIVADA desde 2026-11-10 10:00 La Paz (a media mañana: la medianoche del 10 sigue siendo COMPARTIDA). Estancia 2026-11-08 20:00 -> 2026-11-12 08:00.
SELECT pg_temp.caso('cerrar el período vigente de la cama 301-A', $q$UPDATE practice.care_space_category_periods SET valid_to = '2026-11-10 10:00-04' WHERE care_space_id = 'a1300000-0000-4000-8000-000000000001' AND valid_to IS NULL$q$);
SELECT pg_temp.caso('abrir el período PRIVADA justo en ese instante (10:00)', $q$INSERT INTO practice.care_space_category_periods (id, tenant_id, care_space_id, bed_category_concept_id, valid_from, created_at, updated_at, row_version) VALUES (gen_random_uuid(), 'a0000000-0000-4000-8000-000000000001', 'a1300000-0000-4000-8000-000000000001', 'c0000000-0000-4000-8000-000000000003', '2026-11-10 10:00-04', now(), now(), 1)$q$);
SELECT pg_temp.caso('tarifa PRIVADA (150) desde 2026-01-01', pg_temp.tarifa('{"id":"f1000000-0000-4000-8000-000000000012","bed_category_concept_id":"c0000000-0000-4000-8000-000000000003","unit_price":150,"valid_from":"2026-01-01","service_catalog_id":"a6000000-0000-4000-8000-000000000001"}'));
INSERT INTO clinical.encounter_locations (id, encounter_id, practice_site_id, care_space_id, location_status_concept_id, period_start, period_end, created_at, updated_at, row_version)
VALUES ('10000000-0000-4000-8000-000000000003', 'a5000000-0000-4000-8000-000000000002', 'a1100000-0000-4000-8000-000000000001', 'a1300000-0000-4000-8000-000000000001', 'c0000000-0000-4000-8000-000000000020', '2026-11-08 20:00-04', '2026-11-12 08:00-04', now(), now(), 1);
SELECT pg_temp.caso('job sobre la estancia que cruza el cambio de categoría', (SELECT sql FROM _gen WHERE nombre = 'medianoche'));
SELECT pg_temp.afirmar('medianoches 09, 10, 11 y 12 de nov => servicios 8, 9, 10 y 11 (la medianoche 12 devenga la noche del 11)',
  $q$SELECT string_agg(service_date::text, ',' ORDER BY service_date) FROM billing.charge_captures WHERE encounter_id = 'a5000000-0000-4000-8000-000000000002'$q$,
  '2026-11-08,2026-11-09,2026-11-10,2026-11-11');
SELECT pg_temp.afirmar('la categoría cobrada es la vigente en CADA medianoche: compartida en las del 9 y 10 (el cambio fue el 10 a las 10:00), privada en las del 11 y 12',
  $q$SELECT string_agg(c.code, ',' ORDER BY k.service_date) FROM billing.charge_captures k JOIN terminology.catalog_concepts c ON c.id = k.bed_category_concept_id WHERE k.encounter_id = 'a5000000-0000-4000-8000-000000000002'$q$,
  'BED_CAT_SHARED,BED_CAT_SHARED,BED_CAT_PRIVATE,BED_CAT_PRIVATE');
SELECT pg_temp.afirmar('precios: 120, 120 (compartida, tarifa nueva desde el 1/11), 150, 150 (privada)',
  $q$SELECT string_agg(unit_price::int::text, ',' ORDER BY service_date) FROM billing.charge_captures WHERE encounter_id = 'a5000000-0000-4000-8000-000000000002'$q$,
  '120,120,150,150');

-- B.4 Ingreso y egreso el mismo día (sin medianoche): un día mínimo; no choca con la noche de otro paciente.
-- Supuesto documentado: billing.bed_day_min_one = true por defecto. EA2 (encuentro a5…02) ya tiene noches en nov;
-- se usa otro paciente: se agrega un 4.º encuentro en el tenant A.
INSERT INTO clinical.encounter_locations (id, encounter_id, practice_site_id, care_space_id, location_status_concept_id, period_start, period_end, created_at, updated_at, row_version)
VALUES ('10000000-0000-4000-8000-000000000004', 'a5000000-0000-4000-8000-000000000003', 'a1100000-0000-4000-8000-000000000001', 'a1300000-0000-4000-8000-000000000002', 'c0000000-0000-4000-8000-000000000020', '2026-12-02 08:00-04', '2026-12-02 18:00-04', now(), now(), 1),
       ('10000000-0000-4000-8000-000000000005', 'a5000000-0000-4000-8000-000000000001', 'a1100000-0000-4000-8000-000000000001', 'a1300000-0000-4000-8000-000000000002', 'c0000000-0000-4000-8000-000000000020', '2026-12-02 19:00-04', '2026-12-03 09:00-04', now(), now(), 1);
SELECT pg_temp.caso('job de medianoche (el paciente de la noche del 2/12 en la misma cama UCI)', (SELECT sql FROM _gen WHERE nombre = 'medianoche'));
SELECT pg_temp.caso('job de mínimo (el de las 08:00-18:00 no cruza ninguna medianoche)', (SELECT sql FROM _gen WHERE nombre = 'minimo'));
SELECT pg_temp.afirmar('el paciente de la noche del 2/12 tiene su día-cama (servicio 2/12)',
  $q$SELECT count(*) FROM billing.charge_captures WHERE encounter_id = 'a5000000-0000-4000-8000-000000000001' AND service_date = '2026-12-02' AND NOT minimum_stay_charge$q$, '1');
SELECT pg_temp.afirmar('el paciente de las 08:00-18:00 tiene UN día mínimo el 2/12 en la MISMA cama y la misma fecha',
  $q$SELECT count(*) FROM billing.charge_captures WHERE encounter_id = 'a5000000-0000-4000-8000-000000000003' AND service_date = '2026-12-02' AND minimum_stay_charge AND care_space_id = 'a1300000-0000-4000-8000-000000000002'$q$, '1');
SELECT pg_temp.afirmar('esa cama tiene 2 cargos el 2/12: la noche y el mínimo',
  $q$SELECT count(*) FROM billing.charge_captures WHERE care_space_id = 'a1300000-0000-4000-8000-000000000002' AND service_date = '2026-12-02'$q$, '2');
SELECT pg_temp.caso('re-ejecutar ambos jobs', (SELECT sql FROM _gen WHERE nombre = 'medianoche'));
SELECT pg_temp.caso('re-ejecutar ambos jobs (mínimo)', (SELECT sql FROM _gen WHERE nombre = 'minimo'));
SELECT pg_temp.afirmar('sigue habiendo 2 cargos en esa cama el 2/12',
  $q$SELECT count(*) FROM billing.charge_captures WHERE care_space_id = 'a1300000-0000-4000-8000-000000000002' AND service_date = '2026-12-02'$q$, '2');

-- B.5 Permiso de salida con cama retenida: el período de ocupación NO se corta, así que la cama retenida
-- devenga las medianoches del permiso (supuesto documentado). Estancia 2027-01-05 10:00 -> 2027-01-09 10:00
-- con permiso 06 al 08: un único período => 4 medianoches (6, 7, 8, 9) => servicios 5, 6, 7, 8.
INSERT INTO clinical.encounter_locations (id, encounter_id, practice_site_id, care_space_id, location_status_concept_id, period_start, period_end, created_at, updated_at, row_version)
VALUES ('10000000-0000-4000-8000-000000000006', 'a5000000-0000-4000-8000-000000000004', 'a1100000-0000-4000-8000-000000000001', 'a2300000-0000-4000-8000-000000000004', 'c0000000-0000-4000-8000-000000000020', '2027-01-05 10:00-04', '2027-01-09 10:00-04', now(), now(), 1);
-- (la cama 101 es de la práctica A2: se usa la cama 301-A de A1 libre en enero)
UPDATE clinical.encounter_locations SET care_space_id = 'a1300000-0000-4000-8000-000000000001' WHERE id = '10000000-0000-4000-8000-000000000006';
SELECT pg_temp.caso('job sobre la estancia con permiso de salida (cama retenida)', (SELECT sql FROM _gen WHERE nombre = 'medianoche'));
SELECT pg_temp.afirmar('la cama retenida durante el permiso devenga 4 noches',
  $q$SELECT string_agg(service_date::text, ',' ORDER BY service_date) FROM billing.charge_captures WHERE encounter_id = 'a5000000-0000-4000-8000-000000000004'$q$,
  '2027-01-05,2027-01-06,2027-01-07,2027-01-08');

-- B.6 Sin tarifa vigente: se devenga PENDING sin precio (no se inventa).
INSERT INTO clinical.encounter_locations (id, encounter_id, practice_site_id, care_space_id, location_status_concept_id, period_start, period_end, created_at, updated_at, row_version)
VALUES ('10000000-0000-4000-8000-000000000007', 'a5000000-0000-4000-8000-000000000005', 'a1100000-0000-4000-8000-000000000001', 'a1300000-0000-4000-8000-000000000002', 'c0000000-0000-4000-8000-000000000020', '2025-06-10 20:00-04', '2025-06-11 08:00-04', now(), now(), 1);
SELECT pg_temp.caso('job con una noche anterior a toda tarifa vigente (2025)', (SELECT sql FROM _gen WHERE nombre = 'medianoche'));
-- la cama UCI tiene período de categoría sólo desde 2026-01-01: sin período tampoco hay categoría => no hay cargo (error de configuración)
SELECT pg_temp.afirmar('una cama sin categoría vigente en esa medianoche no genera cargo por defecto',
  $q$SELECT count(*) FROM billing.charge_captures WHERE encounter_id = 'a5000000-0000-4000-8000-000000000005'$q$, '0');
-- período anterior para esa cama (2025), pero sin ninguna tarifa de 2025
INSERT INTO practice.care_space_category_periods (id, tenant_id, care_space_id, bed_category_concept_id, valid_from, valid_to, created_at, updated_at, row_version)
VALUES (gen_random_uuid(), 'a0000000-0000-4000-8000-000000000001', 'a1300000-0000-4000-8000-000000000002', 'c0000000-0000-4000-8000-000000000002', '2025-01-01 00:00-04', '2026-01-01 00:00+00', now(), now(), 1);
SELECT pg_temp.caso('job: la categoría ya existe pero no hay tarifa de 2025', (SELECT sql FROM _gen WHERE nombre = 'medianoche'));
SELECT pg_temp.afirmar('queda un cargo PENDING SIN precio, sin tarifa ni servicio (alerta tariff_missing en la API)',
  $q$SELECT count(*) FROM billing.charge_captures WHERE encounter_id = 'a5000000-0000-4000-8000-000000000005' AND unit_price IS NULL AND space_tariff_id IS NULL AND service_catalog_id IS NULL AND status_concept_id = '17def99a-0cb5-586c-a440-59d809709c0d'$q$, '1');
SELECT pg_temp.caso('facturar un cargo sin precio (tarifa faltante)',
  $q$UPDATE billing.charge_captures SET status_concept_id = '9af061be-6a80-51ed-bcbd-52533037c272', invoice_line_id = 'a9000000-0000-4000-8000-000000000004' WHERE encounter_id = 'a5000000-0000-4000-8000-000000000005'$q$, '23514');

-- B.7 Quirófano por tiempo: caso de 95 min con unidad de 30 => 4 unidades (max(mínimo, ceil(95/30))).
SELECT pg_temp.afirmar('unidades de quirófano: max(minimum_units, ceil(95 / 30)) = 4',
  $q$SELECT greatest(minimum_units, ceil(95::numeric / unit_minutes))::int FROM billing.space_tariffs WHERE id = 'f1000000-0000-4000-8000-000000000003'$q$, '4');
SELECT pg_temp.caso('cargo de quirófano: 4 unidades a 80 con la tarifa OR vigente',
  pg_temp.cargo('{"id":"c1000000-0000-4000-8000-000000000001","source_kind_concept_id":"a79361f6-8787-56a5-9a90-a9436d02e217","source_ref_id":"cccccccc-0000-4000-8000-000000000001","service_date":"2026-11-20","care_space_id":null,"bed_category_concept_id":null,"space_tariff_id":"f1000000-0000-4000-8000-000000000003","service_catalog_id":"a6000000-0000-4000-8000-000000000003","quantity":4,"unit_price":80,"idempotency_key":"ORTIME:cccccccc-0000-4000-8000-000000000001"}'));
SELECT pg_temp.caso('segundo cargo de quirófano para el MISMO caso (un cargo por caso)',
  pg_temp.cargo('{"source_kind_concept_id":"a79361f6-8787-56a5-9a90-a9436d02e217","source_ref_id":"cccccccc-0000-4000-8000-000000000001","service_date":"2026-11-20","care_space_id":null,"bed_category_concept_id":null,"space_tariff_id":"f1000000-0000-4000-8000-000000000003","service_catalog_id":"a6000000-0000-4000-8000-000000000003","quantity":4,"unit_price":80}'), '23505');
SELECT pg_temp.caso('cargo de quirófano con tarifa de día-cama (tipo equivocado)',
  pg_temp.cargo('{"source_kind_concept_id":"a79361f6-8787-56a5-9a90-a9436d02e217","care_space_id":null,"bed_category_concept_id":null,"space_tariff_id":"f1000000-0000-4000-8000-000000000002","service_catalog_id":"a6000000-0000-4000-8000-000000000002","quantity":2,"unit_price":300,"service_date":"2026-11-21"}'), '23514');

-- ============================================================ C. doble cobro imposible
SELECT pg_temp.afirmar('base de la sección: 3 (ejemplo) + 4 (cambio de categoría) + 2 (2/12: noche + mínimo) + 4 (permiso) + 1 (sin tarifa) + 1 (quirófano) = 15 cargos',
  $q$SELECT count(*) FROM billing.charge_captures$q$, '15');
SELECT pg_temp.caso('misma clave de idempotencia dos veces',
  pg_temp.cargo('{"idempotency_key":"BEDDAY:a5000000-0000-4000-8000-000000000001:2026-10-27","service_date":"2030-02-01"}'), '23505');
SELECT pg_temp.caso('mismo encuentro y misma noche con otra clave',
  pg_temp.cargo('{"encounter_id":"a5000000-0000-4000-8000-000000000001","service_date":"2026-10-27","care_space_id":"a1300000-0000-4000-8000-000000000002","space_tariff_id":"f1000000-0000-4000-8000-000000000002","bed_category_concept_id":"c0000000-0000-4000-8000-000000000002","service_catalog_id":"a6000000-0000-4000-8000-000000000002","unit_price":300}'), '23505');
SELECT pg_temp.caso('otra persona en la MISMA cama la MISMA noche (cama + noche única)',
  pg_temp.cargo('{"encounter_id":"a5000000-0000-4000-8000-000000000002","patient_profile_id":"a4000000-0000-4000-8000-000000000002","service_date":"2026-10-28","care_space_id":"a1300000-0000-4000-8000-000000000002","space_tariff_id":"f1000000-0000-4000-8000-000000000002","bed_category_concept_id":"c0000000-0000-4000-8000-000000000002","service_catalog_id":"a6000000-0000-4000-8000-000000000002","unit_price":300}'), '23505');
SELECT pg_temp.caso('el mínimo de un día duplicado para el mismo encuentro y fecha',
  pg_temp.cargo('{"encounter_id":"a5000000-0000-4000-8000-000000000003","patient_profile_id":"a4000000-0000-4000-8000-000000000003","service_date":"2026-12-02","minimum_stay_charge":true,"care_space_id":"a1300000-0000-4000-8000-000000000002","space_tariff_id":"f1000000-0000-4000-8000-000000000002","bed_category_concept_id":"c0000000-0000-4000-8000-000000000002","service_catalog_id":"a6000000-0000-4000-8000-000000000002","unit_price":300}'), '23505');
SELECT pg_temp.caso('anular libera la noche: se anula el cargo del 27/10', $q$UPDATE billing.charge_captures SET status_concept_id = 'f2f59654-d912-5eeb-b619-814e50a3c4d0', void_reason = 'traslado cancelado' WHERE encounter_id = 'a5000000-0000-4000-8000-000000000001' AND service_date = '2026-10-27'$q$);
SELECT pg_temp.caso('...y se puede devengar de nuevo esa noche con una clave nueva (corrección: cargo nuevo)',
  pg_temp.cargo('{"encounter_id":"a5000000-0000-4000-8000-000000000001","service_date":"2026-10-27","space_tariff_id":"f1000000-0000-4000-8000-000000000001","unit_price":100,"idempotency_key":"BEDDAY:a5000000-0000-4000-8000-000000000001:2026-10-27:r2"}'));
SELECT pg_temp.caso('...pero reutilizar la clave del cargo anulado sigue prohibido (la clave identifica el hecho)',
  pg_temp.cargo('{"encounter_id":"a5000000-0000-4000-8000-000000000001","service_date":"2030-03-03","idempotency_key":"BEDDAY:a5000000-0000-4000-8000-000000000001:2026-10-27"}'), '23505');
SELECT pg_temp.caso('día-cama de 0,5 días', pg_temp.cargo('{"quantity":0.5,"service_date":"2030-04-01"}'), '23514');
SELECT pg_temp.caso('día-cama de 2 días en un solo cargo', pg_temp.cargo('{"quantity":2,"service_date":"2030-04-02"}'), '23514');
SELECT pg_temp.caso('cantidad 0', pg_temp.cargo('{"quantity":0,"service_date":"2030-04-03"}'), '23514');
SELECT pg_temp.caso('día-cama sin cama', pg_temp.cargo('{"care_space_id":null,"space_tariff_id":null,"unit_price":null,"service_catalog_id":null,"bed_category_concept_id":null,"service_date":"2030-04-04"}'), '23514');
SELECT pg_temp.caso('clave de idempotencia en blanco', pg_temp.cargo('{"idempotency_key":"   ","service_date":"2030-04-05"}'), '23514');
SELECT pg_temp.caso('mínimo marcado en un cargo de quirófano', pg_temp.cargo('{"source_kind_concept_id":"a79361f6-8787-56a5-9a90-a9436d02e217","minimum_stay_charge":true,"care_space_id":null,"space_tariff_id":null,"unit_price":null,"service_catalog_id":null,"bed_category_concept_id":null,"service_date":"2030-04-06"}'), '23514');
SELECT pg_temp.caso('origen que no es CHG_SRC_*', pg_temp.cargo('{"source_kind_concept_id":"c0000000-0000-4000-8000-000000000020","service_date":"2030-04-07"}'), '23514');
SELECT pg_temp.caso('estado que no es CHG_*', pg_temp.cargo('{"status_concept_id":"c0000000-0000-4000-8000-000000000020","service_date":"2030-04-08"}'), '23514');
SELECT pg_temp.caso('pendiente con línea de factura', pg_temp.cargo('{"invoice_line_id":"a9000000-0000-4000-8000-000000000001","service_date":"2030-04-09"}'), '23514');
SELECT pg_temp.caso('anulado sin motivo', pg_temp.cargo('{"status_concept_id":"f2f59654-d912-5eeb-b619-814e50a3c4d0","service_date":"2030-04-10"}'), '23514');
SELECT pg_temp.caso('motivo de anulación en un cargo que no está anulado', pg_temp.cargo('{"void_reason":"x","service_date":"2030-04-11"}'), '23514');
SELECT pg_temp.caso('precio sin tarifa (la foto exige su tarifa)', pg_temp.cargo('{"space_tariff_id":null,"service_date":"2030-04-12"}'), '23514');

-- ============================================================ D. coherencia con la tarifa y con las referencias
SELECT pg_temp.caso('precio distinto al de la tarifa', pg_temp.cargo('{"unit_price":99,"service_date":"2030-05-01"}'), '23514');
SELECT pg_temp.caso('servicio distinto al de la tarifa', pg_temp.cargo('{"service_catalog_id":"a6000000-0000-4000-8000-000000000002","service_date":"2030-05-02"}'), '23514');
SELECT pg_temp.caso('moneda distinta a la de la tarifa', pg_temp.cargo('{"currency_concept_id":"c0000000-0000-4000-8000-000000000011","service_date":"2030-05-03"}'), '23514');
SELECT pg_temp.caso('tarifa que aún no estaba vigente en la fecha de servicio', pg_temp.cargo('{"service_date":"2025-12-31","space_tariff_id":"f1000000-0000-4000-8000-000000000001","unit_price":100}'), '23514');
SELECT pg_temp.caso('tarifa ya cerrada en la fecha de servicio (la compartida cerró el 2026-11-01)', pg_temp.cargo('{"service_date":"2026-11-01","space_tariff_id":"f1000000-0000-4000-8000-000000000001","unit_price":100}'), '23514');
SELECT pg_temp.caso('tarifa de UCI en una cama compartida (categoría distinta)',
  pg_temp.cargo('{"space_tariff_id":"f1000000-0000-4000-8000-000000000002","service_catalog_id":"a6000000-0000-4000-8000-000000000002","unit_price":300,"service_date":"2030-05-05"}'), '23514');
SELECT pg_temp.caso('encuentro de OTRO tenant', pg_temp.cargo('{"encounter_id":"b5000000-0000-4000-8000-000000000001","service_date":"2030-05-06"}'), '23503');
SELECT pg_temp.caso('encuentro de otro paciente del mismo tenant', pg_temp.cargo('{"encounter_id":"a5000000-0000-4000-8000-000000000002","service_date":"2030-05-07"}'), '23503');
SELECT pg_temp.caso('cama de OTRO tenant (FK compuesta)', pg_temp.cargo('{"care_space_id":"b1300000-0000-4000-8000-000000000003","service_date":"2030-05-08"}'), '23503');
SELECT pg_temp.caso('cama de OTRA práctica del mismo tenant', pg_temp.cargo('{"care_space_id":"a2300000-0000-4000-8000-000000000004","service_date":"2030-05-09"}'), '23503');
SELECT pg_temp.caso('práctica A1 con tenant B (FK compuesta tenant_id, practice_id)', pg_temp.cargo('{"tenant_id":"b0000000-0000-4000-8000-000000000001","service_date":"2030-05-10"}'), '23503');
SELECT pg_temp.caso('centro de costo de OTRA práctica (FK compuesta practice_id, cost_center_id)', pg_temp.cargo('{"cost_center_id":"a7000000-0000-4000-8000-000000000002","service_date":"2030-05-11"}'), '23503');
SELECT pg_temp.caso('centro de costo de otro tenant', pg_temp.cargo('{"cost_center_id":"b7000000-0000-4000-8000-000000000001","service_date":"2030-05-12"}'), '23503');
SELECT pg_temp.caso('centro de costo de la misma práctica', pg_temp.cargo('{"cost_center_id":"a7000000-0000-4000-8000-000000000001","service_date":"2030-05-13"}'));
SELECT pg_temp.caso('tarifa de OTRA práctica (FK compuesta practice_id, space_tariff_id)', pg_temp.tarifa('{"id":"f1000000-0000-4000-8000-0000000000a1","practice_id":"a2000000-0000-4000-8000-000000000001","service_catalog_id":"a6000000-0000-4000-8000-000000000004","bed_category_concept_id":"c0000000-0000-4000-8000-000000000001","valid_from":"2026-01-01"}'));
SELECT pg_temp.caso('cargo de A1 que cita una tarifa de A2', pg_temp.cargo('{"space_tariff_id":"f1000000-0000-4000-8000-0000000000a1","service_catalog_id":"a6000000-0000-4000-8000-000000000004","unit_price":150,"service_date":"2030-05-14"}'), '23503');

-- ============================================================ E. un cargo emitido no se edita
SELECT pg_temp.caso('cargo base de la sección E', pg_temp.cargo('{"id":"c1000000-0000-4000-8000-000000000002","service_date":"2030-06-01","idempotency_key":"E-1"}'));
SELECT pg_temp.caso('recalcular un PENDIENTE (otra cantidad de un cargo de quirófano) es válido',
  $q$UPDATE billing.charge_captures SET cost_center_id = 'a7000000-0000-4000-8000-000000000001' WHERE id = 'c1000000-0000-4000-8000-000000000002'$q$);
SELECT pg_temp.caso('cambiar la identidad (fecha de servicio) de un pendiente', $q$UPDATE billing.charge_captures SET service_date = '2030-06-02' WHERE id = 'c1000000-0000-4000-8000-000000000002'$q$, '23001');
SELECT pg_temp.caso('cambiar el paciente de un pendiente', $q$UPDATE billing.charge_captures SET patient_profile_id = 'a4000000-0000-4000-8000-000000000002' WHERE id = 'c1000000-0000-4000-8000-000000000002'$q$, '23001');
SELECT pg_temp.caso('cambiar la clave de idempotencia', $q$UPDATE billing.charge_captures SET idempotency_key = 'otra' WHERE id = 'c1000000-0000-4000-8000-000000000002'$q$, '23001');
SELECT pg_temp.caso('facturar con una línea de factura de OTRO paciente', $q$UPDATE billing.charge_captures SET status_concept_id = '9af061be-6a80-51ed-bcbd-52533037c272', invoice_line_id = 'a9000000-0000-4000-8000-000000000002' WHERE id = 'c1000000-0000-4000-8000-000000000002'$q$, '23503');
SELECT pg_temp.caso('facturar con una línea de factura de OTRA práctica', $q$UPDATE billing.charge_captures SET status_concept_id = '9af061be-6a80-51ed-bcbd-52533037c272', invoice_line_id = 'a9000000-0000-4000-8000-000000000003' WHERE id = 'c1000000-0000-4000-8000-000000000002'$q$, '23503');
SELECT pg_temp.caso('facturar sin línea de factura', $q$UPDATE billing.charge_captures SET status_concept_id = '9af061be-6a80-51ed-bcbd-52533037c272' WHERE id = 'c1000000-0000-4000-8000-000000000002'$q$, '23514');
SELECT pg_temp.caso('facturar al mismo tiempo que se cambia el precio', $q$UPDATE billing.charge_captures SET status_concept_id = '9af061be-6a80-51ed-bcbd-52533037c272', invoice_line_id = 'a9000000-0000-4000-8000-000000000001', quantity = 3 WHERE id = 'c1000000-0000-4000-8000-000000000002'$q$, '23001');
SELECT pg_temp.caso('PENDIENTE -> EMITIDO con su línea de factura (CHARGE_ALREADY_INVOICED se ve en la 2.ª)', $q$UPDATE billing.charge_captures SET status_concept_id = '9af061be-6a80-51ed-bcbd-52533037c272', invoice_line_id = 'a9000000-0000-4000-8000-000000000001' WHERE id = 'c1000000-0000-4000-8000-000000000002'$q$);
SELECT pg_temp.caso('editar el precio de un cargo EMITIDO', $q$UPDATE billing.charge_captures SET unit_price = 1 WHERE id = 'c1000000-0000-4000-8000-000000000002'$q$, '23001');
SELECT pg_temp.caso('editar la cantidad de un cargo EMITIDO', $q$UPDATE billing.charge_captures SET quantity = 2 WHERE id = 'c1000000-0000-4000-8000-000000000002'$q$, '23001');
SELECT pg_temp.caso('quitar la línea a un cargo EMITIDO', $q$UPDATE billing.charge_captures SET invoice_line_id = NULL WHERE id = 'c1000000-0000-4000-8000-000000000002'$q$, '23001');
SELECT pg_temp.caso('devolver un EMITIDO a PENDIENTE', $q$UPDATE billing.charge_captures SET status_concept_id = '17def99a-0cb5-586c-a440-59d809709c0d', invoice_line_id = NULL WHERE id = 'c1000000-0000-4000-8000-000000000002'$q$, '23001');
SELECT pg_temp.caso('borrar un cargo emitido', $q$DELETE FROM billing.charge_captures WHERE id = 'c1000000-0000-4000-8000-000000000002'$q$, '23001');
SELECT pg_temp.caso('anular un EMITIDO sin motivo (nota de crédito exige motivo)', $q$UPDATE billing.charge_captures SET status_concept_id = 'f2f59654-d912-5eeb-b619-814e50a3c4d0' WHERE id = 'c1000000-0000-4000-8000-000000000002'$q$, '23514');
SELECT pg_temp.caso('anular un EMITIDO con motivo (conserva su línea)', $q$UPDATE billing.charge_captures SET status_concept_id = 'f2f59654-d912-5eeb-b619-814e50a3c4d0', void_reason = 'nota de crédito 001' WHERE id = 'c1000000-0000-4000-8000-000000000002'$q$);
SELECT pg_temp.caso('modificar un cargo ANULADO (terminal)', $q$UPDATE billing.charge_captures SET void_reason = 'otro motivo' WHERE id = 'c1000000-0000-4000-8000-000000000002'$q$, '23001');
SELECT pg_temp.caso('revivir un cargo ANULADO', $q$UPDATE billing.charge_captures SET status_concept_id = '17def99a-0cb5-586c-a440-59d809709c0d', void_reason = NULL, invoice_line_id = NULL WHERE id = 'c1000000-0000-4000-8000-000000000002'$q$, '23001');

-- ============================================================ F. historia (solo inserción + cierre de valid_to)
INSERT INTO audit.charge_captures_history (history_id, charge_capture_id, revision_no, operation_concept_id, valid_from, data_snapshot, recorded_at, tenant_id)
VALUES ('b0000000-0000-4000-8000-000000000001', 'c1000000-0000-4000-8000-000000000002', 1, 'c0000000-0000-4000-8000-000000000020', now(), '{"x":1}', now(), 'a0000000-0000-4000-8000-000000000001');
SELECT pg_temp.caso('historia de un cargo sin tenant_id: el trigger lo completa desde el origen',
  $q$INSERT INTO audit.charge_captures_history (history_id, charge_capture_id, revision_no, operation_concept_id, valid_from, data_snapshot, recorded_at)
     VALUES ('b0000000-0000-4000-8000-000000000002', 'c1000000-0000-4000-8000-000000000002', 2, 'c0000000-0000-4000-8000-000000000020', now(), '{"x":2}', now())$q$);
SELECT pg_temp.afirmar('...y el tenant completado es el del cargo de origen',
  $q$SELECT tenant_id::text FROM audit.charge_captures_history WHERE history_id = 'b0000000-0000-4000-8000-000000000002'$q$, 'a0000000-0000-4000-8000-000000000001');
SELECT pg_temp.caso('historia con tenant distinto al del cargo (FK compuesta al origen)',
  $q$INSERT INTO audit.charge_captures_history (history_id, charge_capture_id, revision_no, operation_concept_id, valid_from, data_snapshot, recorded_at, tenant_id)
     VALUES (gen_random_uuid(), 'c1000000-0000-4000-8000-000000000002', 3, 'c0000000-0000-4000-8000-000000000020', now(), '{"x":3}', now(), 'b0000000-0000-4000-8000-000000000001')$q$, '23503');
SELECT pg_temp.caso('cerrar valid_to de la revisión vigente (SCD-2)', $q$UPDATE audit.charge_captures_history SET valid_to = now() + interval '1 minute' WHERE history_id = 'b0000000-0000-4000-8000-000000000001'$q$);
SELECT pg_temp.caso('cerrar dos veces', $q$UPDATE audit.charge_captures_history SET valid_to = now() + interval '2 minute' WHERE history_id = 'b0000000-0000-4000-8000-000000000001'$q$, '23001');
SELECT pg_temp.caso('reescribir el snapshot', $q$UPDATE audit.charge_captures_history SET data_snapshot = '{"x":9}' WHERE history_id = 'b0000000-0000-4000-8000-000000000001'$q$, '23001');
SELECT pg_temp.caso('borrar historia', $q$DELETE FROM audit.charge_captures_history WHERE history_id = 'b0000000-0000-4000-8000-000000000001'$q$, '23001');
SELECT pg_temp.caso('historia de una tarifa',
  $q$INSERT INTO audit.space_tariffs_history (history_id, space_tariff_id, revision_no, operation_concept_id, valid_from, data_snapshot, recorded_at, tenant_id)
     VALUES (gen_random_uuid(), 'f1000000-0000-4000-8000-000000000001', 1, 'c0000000-0000-4000-8000-000000000020', now(), '{"x":1}', now(), 'a0000000-0000-4000-8000-000000000001')$q$);

-- ============================================================ G. RLS entre tenants (rol de aplicación, sin BYPASSRLS)
-- B emite un cargo propio para comparar.
INSERT INTO billing.space_tariffs (id, tenant_id, practice_id, tariff_kind_concept_id, bed_category_concept_id, service_catalog_id, unit_price, currency_concept_id, valid_from, status_concept_id, created_at, updated_at, row_version)
VALUES ('f1000000-0000-4000-8000-0000000000b1', 'b0000000-0000-4000-8000-000000000001', 'b1000000-0000-4000-8000-000000000001', '1ae01bf6-a061-52ed-aa26-590705cb2202', 'c0000000-0000-4000-8000-000000000001', 'b6000000-0000-4000-8000-000000000001', 90, 'c0000000-0000-4000-8000-000000000010', '2026-01-01', 'c0000000-0000-4000-8000-000000000020', now(), now(), 1);
SELECT pg_temp.caso('cargo del tenant B',
  pg_temp.cargo('{"tenant_id":"b0000000-0000-4000-8000-000000000001","practice_id":"b1000000-0000-4000-8000-000000000001","patient_profile_id":"b4000000-0000-4000-8000-000000000001","encounter_id":"b5000000-0000-4000-8000-000000000001","care_space_id":"b1300000-0000-4000-8000-000000000003","space_tariff_id":"f1000000-0000-4000-8000-0000000000b1","service_catalog_id":"b6000000-0000-4000-8000-000000000001","unit_price":90,"service_date":"2026-12-15"}'));

CREATE TEMP TABLE _rls (clave text PRIMARY KEY, valor integer);
GRANT ALL ON _rls TO mantra_app;
DO $t$
DECLARE tot_k integer; tot_t integer; tot_h integer; tot_p integer; k_a integer; k_b integer; k_none integer; t_a integer; t_b integer; h_a integer; h_b integer; h_none integer;
BEGIN
    SELECT count(*) INTO tot_k FROM billing.charge_captures;
    SELECT count(*) INTO tot_t FROM billing.space_tariffs;
    SELECT count(*) INTO tot_h FROM audit.charge_captures_history;
    SET LOCAL ROLE mantra_app;
    SET LOCAL app.system_context = 'false';
    SET LOCAL app.current_tenant_id = 'a0000000-0000-4000-8000-000000000001';
    SELECT count(*) INTO k_a FROM billing.charge_captures;
    SELECT count(*) INTO t_a FROM billing.space_tariffs;
    SELECT count(*) INTO h_a FROM audit.charge_captures_history;
    SET LOCAL app.current_tenant_id = 'b0000000-0000-4000-8000-000000000001';
    SELECT count(*) INTO k_b FROM billing.charge_captures;
    SELECT count(*) INTO t_b FROM billing.space_tariffs;
    SELECT count(*) INTO h_b FROM audit.charge_captures_history;
    SET LOCAL app.current_tenant_id = '';
    SELECT count(*) INTO k_none FROM billing.charge_captures;
    SELECT count(*) INTO h_none FROM audit.charge_captures_history;
    RESET ROLE;
    IF k_b <> 1 OR k_a + k_b <> tot_k OR k_none <> 0 THEN RAISE EXCEPTION 'CASO FALLIDO [RLS charge_captures]: A=% B=% sin tenant=% total=%', k_a, k_b, k_none, tot_k; END IF;
    IF t_b <> 1 OR t_a + t_b <> tot_t THEN RAISE EXCEPTION 'CASO FALLIDO [RLS space_tariffs]: A=% B=% total=%', t_a, t_b, tot_t; END IF;
    IF h_a <> tot_h OR h_b <> 0 OR h_none <> 0 THEN RAISE EXCEPTION 'CASO FALLIDO [RLS historia]: A=% B=% sin tenant=% total=%', h_a, h_b, h_none, tot_h; END IF;
    RAISE NOTICE 'CASO OK [RLS: cada tenant ve sólo sus cargos (A=%, B=1), sus tarifas (A=%, B=1) y su historia; sin tenant fijado no ve nada] -> éxito', k_a, t_a;
END $t$;

DO $t$
DECLARE r text;
BEGIN
    SET LOCAL ROLE mantra_app;
    SET LOCAL app.system_context = 'false';
    SET LOCAL app.current_tenant_id = 'a0000000-0000-4000-8000-000000000001';
    -- A no puede leer, actualizar ni anular un cargo de B (no lo ve: 0 filas)
    UPDATE billing.charge_captures SET cost_center_id = NULL WHERE tenant_id = 'b0000000-0000-4000-8000-000000000001';
    GET DIAGNOSTICS r = ROW_COUNT;
    RESET ROLE;
    IF r::int <> 0 THEN RAISE EXCEPTION 'CASO FALLIDO [RLS UPDATE cruzado]: tocó % filas', r; END IF;
    RAISE NOTICE 'CASO OK [RLS: A no puede actualizar cargos de B (0 filas afectadas)] -> 0 filas';
END $t$;

DO $t$
DECLARE o1 text := NULL; o2 text := NULL; o3 text := NULL;
BEGIN
    SET LOCAL ROLE mantra_app;
    SET LOCAL app.system_context = 'false';
    SET LOCAL app.current_tenant_id = 'a0000000-0000-4000-8000-000000000001';
    BEGIN
        INSERT INTO billing.charge_captures SELECT (jsonb_populate_record(NULL::billing.charge_captures, jsonb_build_object(
          'id', gen_random_uuid(), 'tenant_id', 'b0000000-0000-4000-8000-000000000001', 'practice_id', 'b1000000-0000-4000-8000-000000000001',
          'patient_profile_id', 'b4000000-0000-4000-8000-000000000001', 'encounter_id', 'b5000000-0000-4000-8000-000000000001',
          'source_kind_concept_id', '5f84ea44-b0d3-582c-86c1-32c81e422d30', 'source_ref_id', gen_random_uuid(), 'service_date', '2031-01-01',
          'care_space_id', 'b1300000-0000-4000-8000-000000000003', 'minimum_stay_charge', false, 'quantity', 1,
          'status_concept_id', '17def99a-0cb5-586c-a440-59d809709c0d', 'idempotency_key', 'cross-1', 'created_at', now(), 'updated_at', now(), 'row_version', 1))).*;
    EXCEPTION WHEN OTHERS THEN o1 := SQLSTATE; END;
    BEGIN
        DELETE FROM billing.charge_captures WHERE tenant_id = 'a0000000-0000-4000-8000-000000000001';
    EXCEPTION WHEN OTHERS THEN o2 := SQLSTATE; END;
    BEGIN
        UPDATE audit.charge_captures_history SET data_snapshot = '{}' WHERE tenant_id = 'a0000000-0000-4000-8000-000000000001';
    EXCEPTION WHEN OTHERS THEN o3 := SQLSTATE; END;
    RESET ROLE;
    -- El trigger de guarda (BEFORE) ya no ve el encuentro de B bajo RLS y responde 23503; si no
    -- estuviera, la política WITH CHECK respondería 42501. Cualquiera de los dos es rechazo.
    IF o1 IS NULL OR o1 NOT IN ('42501', '23503') THEN RAISE EXCEPTION 'CASO FALLIDO [RLS INSERT con tenant de B]: SQLSTATE=%', coalesce(o1, 'éxito'); END IF;
    RAISE NOTICE 'CASO OK [RLS: A no puede insertar un cargo con tenant_id de B] -> %', o1;
    IF o2 IS DISTINCT FROM '42501' THEN RAISE EXCEPTION 'CASO FALLIDO [DELETE sobre charge_captures]: SQLSTATE=%', coalesce(o2, 'éxito'); END IF;
    RAISE NOTICE 'CASO OK [mantra_app no tiene privilegio de DELETE sobre los cargos] -> 42501';
    IF o3 IS DISTINCT FROM '42501' THEN RAISE EXCEPTION 'CASO FALLIDO [UPDATE de columnas de la historia]: SQLSTATE=%', coalesce(o3, 'éxito'); END IF;
    RAISE NOTICE 'CASO OK [mantra_app sólo puede actualizar valid_to de la historia] -> 42501';
END $t$;

-- ============================================================ H. el rol de aplicación opera su tenant de punta a punta
-- (los triggers de guarda son SECURITY INVOKER: tienen que funcionar CON RLS y sin superusuario)
DO $t$
DECLARE
    k uuid := 'c1000000-0000-4000-8000-0000000000c1';
    n integer;
BEGIN
    SET LOCAL ROLE mantra_app;
    SET LOCAL app.system_context = 'false';
    SET LOCAL app.current_tenant_id = 'a0000000-0000-4000-8000-000000000001';
    -- tarifa propia de la cama UCI-1 (2027), cargo pendiente, facturarlo, anularlo, historia
    INSERT INTO billing.space_tariffs (id, tenant_id, practice_id, tariff_kind_concept_id, bed_category_concept_id, care_space_id, service_catalog_id, unit_price, currency_concept_id,
                                       valid_from, status_concept_id, created_at, updated_at, row_version)
    VALUES ('f1000000-0000-4000-8000-0000000000c1', 'a0000000-0000-4000-8000-000000000001', 'a1000000-0000-4000-8000-000000000001', '1ae01bf6-a061-52ed-aa26-590705cb2202',
            NULL, 'a1300000-0000-4000-8000-000000000002', 'a6000000-0000-4000-8000-000000000002', 130, 'c0000000-0000-4000-8000-000000000010', '2027-06-01', 'c0000000-0000-4000-8000-000000000020', now(), now(), 1);
    INSERT INTO billing.charge_captures (id, tenant_id, practice_id, patient_profile_id, encounter_id, source_kind_concept_id, source_ref_id, service_date, care_space_id,
                                         bed_category_concept_id, space_tariff_id, service_catalog_id, minimum_stay_charge, quantity, unit_price, currency_concept_id,
                                         cost_center_id, status_concept_id, idempotency_key, created_at, updated_at, row_version)
    VALUES (k, 'a0000000-0000-4000-8000-000000000001', 'a1000000-0000-4000-8000-000000000001', 'a4000000-0000-4000-8000-000000000001', 'a5000000-0000-4000-8000-000000000001',
            '5f84ea44-b0d3-582c-86c1-32c81e422d30', gen_random_uuid(), '2027-06-02', 'a1300000-0000-4000-8000-000000000002', 'c0000000-0000-4000-8000-000000000002',
            'f1000000-0000-4000-8000-0000000000c1', 'a6000000-0000-4000-8000-000000000002', false, 1, 130, 'c0000000-0000-4000-8000-000000000010',
            'a7000000-0000-4000-8000-000000000001', '17def99a-0cb5-586c-a440-59d809709c0d', 'BEDDAY:app:2027-06-02', now(), now(), 1);
    UPDATE billing.charge_captures SET status_concept_id = '9af061be-6a80-51ed-bcbd-52533037c272', invoice_line_id = 'a9000000-0000-4000-8000-000000000001', updated_at = now(), row_version = row_version + 1 WHERE id = k;
    INSERT INTO audit.charge_captures_history (history_id, charge_capture_id, revision_no, operation_concept_id, valid_from, data_snapshot, recorded_at)
    VALUES (gen_random_uuid(), k, 1, 'c0000000-0000-4000-8000-000000000020', now(), '{"estado":"INVOICED"}', now());
    UPDATE audit.charge_captures_history SET valid_to = now() + interval '1 minute' WHERE charge_capture_id = k;
    UPDATE billing.charge_captures SET status_concept_id = 'f2f59654-d912-5eeb-b619-814e50a3c4d0', void_reason = 'nota de crédito', updated_at = now(), row_version = row_version + 1 WHERE id = k;
    SELECT count(*) INTO n FROM billing.charge_captures WHERE id = k AND status_concept_id = 'f2f59654-d912-5eeb-b619-814e50a3c4d0';
    RESET ROLE;
    IF n <> 1 THEN RAISE EXCEPTION 'CASO FALLIDO [mantra_app: ciclo completo de un cargo]: n=%', n; END IF;
    RAISE NOTICE 'CASO OK [mantra_app con RLS: crea tarifa y cargo, lo factura, escribe y cierra su historia y lo anula] -> éxito';
END $t$;

ROLLBACK;
