-- ============================================================================
-- F5 clínico/diagnóstico (M-F5-clin no dejó pruebas versionadas): coherencia sede/espacio/equipo
-- contra la base integrada. Transacción con ROLLBACK. Reutiliza la fixture de M-F5-fin.
--   service_requests.suggested_care_space_id · specimen_collection_events.collection_care_space_id ·
--   imaging_procedure_steps.scheduled_care_space_id / scheduled_equipment_id
-- ============================================================================
\set ON_ERROR_STOP on
BEGIN;
\ir f5_fin_00_fixture.sql
SET LOCAL app.system_context = 'true';

-- inserta una fila rellenando con valores genéricos las columnas NOT NULL que falten
CREATE FUNCTION pg_temp.fx(rel regclass, ov jsonb) RETURNS void LANGUAGE plpgsql AS $f$
DECLARE a record; j jsonb := ov; v jsonb;
BEGIN
  FOR a IN SELECT attname::text n, format_type(atttypid, atttypmod) t FROM pg_attribute
            WHERE attrelid = rel AND attnum > 0 AND NOT attisdropped AND attnotnull AND attgenerated = '' LOOP
    IF NOT (j ? a.n) THEN
      v := CASE WHEN a.t = 'uuid' THEN to_jsonb(gen_random_uuid()::text)
                WHEN a.t IN ('integer','smallint','bigint') THEN to_jsonb(1)
                WHEN a.t LIKE 'timestamp%' THEN to_jsonb(now()::text)
                WHEN a.t = 'date' THEN to_jsonb(current_date::text)
                WHEN a.t = 'boolean' THEN to_jsonb(false)
                WHEN a.t = 'jsonb' THEN '{}'::jsonb
                WHEN a.t LIKE 'numeric%' THEN to_jsonb(1)
                ELSE to_jsonb(md5(random()::text)) END;
      j := j || jsonb_build_object(a.n, v);
    END IF;
  END LOOP;
  EXECUTE format('INSERT INTO %s SELECT * FROM jsonb_populate_record(NULL::%s, $1)', rel, rel) USING j;
END $f$;

-- Los padres que no son objeto de la prueba se insertan sin sus FK (solo para armar el escenario).
ALTER TABLE clinical.service_requests            DISABLE TRIGGER ALL;
ALTER TABLE diagnostics.specimen_collection_events DISABLE TRIGGER ALL;
ALTER TABLE diagnostics.imaging_procedure_steps  DISABLE TRIGGER ALL;
-- ojo: DISABLE TRIGGER ALL apaga también los triggers de coherencia que se prueban; se reactivan
-- solo los de usuario antes de cada caso, y las FK (internas) se dejan apagadas.
ALTER TABLE clinical.service_requests            ENABLE TRIGGER USER;
ALTER TABLE diagnostics.specimen_collection_events ENABLE TRIGGER USER;
ALTER TABLE diagnostics.imaging_procedure_steps  ENABLE TRIGGER USER;
ALTER TABLE diagnostic_units.diagnostic_equipment ENABLE TRIGGER USER;

\set A1S  'a1100000-0000-4000-8000-000000000001'
\set A2S  'a2100000-0000-4000-8000-000000000001'
\set C1   'a1300000-0000-4000-8000-000000000005'
\set A2BED 'a2300000-0000-4000-8000-000000000004'
\set B1BED 'b1300000-0000-4000-8000-000000000003'

-- ---- F5b · orden con punto de toma sugerido
SELECT pg_temp.caso('F5b sugerir un espacio SIN sede sugerida', format($q$SELECT pg_temp.fx('clinical.service_requests', jsonb_build_object('suggested_care_space_id', %L))$q$, :'C1'), '23514');
SELECT pg_temp.caso('F5b espacio de la sede A1 con sede sugerida A1: admitido', format($q$SELECT pg_temp.fx('clinical.service_requests', jsonb_build_object('suggested_care_space_id', %L, 'suggested_practice_site_id', %L))$q$, :'C1', :'A1S'));
SELECT pg_temp.caso('F5b espacio de A1 con sede sugerida A2: el punto no es de esa sede', format($q$SELECT pg_temp.fx('clinical.service_requests', jsonb_build_object('suggested_care_space_id', %L, 'suggested_practice_site_id', %L))$q$, :'C1', :'A2S'), '23503');
-- ---- F5b · toma de muestra
SELECT pg_temp.caso('F5b toma con espacio y SIN sede (la pareja es obligatoria: falla cerrado)', format($q$SELECT pg_temp.fx('diagnostics.specimen_collection_events', jsonb_build_object('collection_care_space_id', %L))$q$, :'C1'), '23514');
SELECT pg_temp.caso('F5b toma con espacio de A1 y sede A1: admitida', format($q$SELECT pg_temp.fx('diagnostics.specimen_collection_events', jsonb_build_object('collection_care_space_id', %L, 'collection_site_id', %L))$q$, :'C1', :'A1S'));
SELECT pg_temp.caso('F5b toma con espacio de A1 y sede A2: rechazada', format($q$SELECT pg_temp.fx('diagnostics.specimen_collection_events', jsonb_build_object('collection_care_space_id', %L, 'collection_site_id', %L))$q$, :'C1', :'A2S'), '23503');
-- ---- F5a · paso de imagen con sala
SELECT pg_temp.caso('F5a paso con sala y SIN equipo (la pareja es obligatoria)', format($q$SELECT pg_temp.fx('diagnostics.imaging_procedure_steps', jsonb_build_object('scheduled_care_space_id', %L))$q$, :'C1'), '23514');
ROLLBACK;
