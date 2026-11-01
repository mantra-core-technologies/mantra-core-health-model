-- SALUD v4.2.83 · schema observability · constraints de integridad (módulo 33)
-- Aplicar DESPUÉS de 04_indexes.sql y de SQL/_integrity/00_integrity_functions.sql.
-- Reglas del módulo 33. Las UK/CHECK/EXCLUDE en prosa quedan como comentario:
-- el modelo no declara su expresión SQL y no se inventa (temperatura-0).
-- CHECK_SQL y EXCLUDE_SQL sí se materializan con la expresión del modelo.


-- ═══ error_events ═══
--   UPDATE: forbidden
--   RETENTION: 90 days (drop_chunks; DELETE allowed)
-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "observability"."error_events" DROP CONSTRAINT IF EXISTS "ck_error_events_source";
ALTER TABLE "observability"."error_events" ADD CONSTRAINT "ck_error_events_source" CHECK ("source" IN ('api', 'worker', 'web'));

-- UPDATE: forbidden → barrera física parcial (DELETE permitido: retención)
REVOKE UPDATE ON "observability"."error_events" FROM PUBLIC;
DROP TRIGGER IF EXISTS trg_forbid_update ON "observability"."error_events";
CREATE TRIGGER trg_forbid_update BEFORE UPDATE ON "observability"."error_events"
    FOR EACH ROW EXECUTE FUNCTION "integrity"."forbid_mutation"();


-- ═══ http_request_minute_series ═══
--   UPDATE: forbidden
--   RETENTION: 14 days raw (drop_chunks; DELETE allowed)
-- UPDATE: forbidden → barrera física parcial (DELETE permitido: retención)
REVOKE UPDATE ON "observability"."http_request_minute_series" FROM PUBLIC;
DROP TRIGGER IF EXISTS trg_forbid_update ON "observability"."http_request_minute_series";
CREATE TRIGGER trg_forbid_update BEFORE UPDATE ON "observability"."http_request_minute_series"
    FOR EACH ROW EXECUTE FUNCTION "integrity"."forbid_mutation"();


-- ═══ sql_statement_minute_series ═══
--   UPDATE: forbidden
--   RETENTION: 14 days (drop_chunks; DELETE allowed)
-- UPDATE: forbidden → barrera física parcial (DELETE permitido: retención)
REVOKE UPDATE ON "observability"."sql_statement_minute_series" FROM PUBLIC;
DROP TRIGGER IF EXISTS trg_forbid_update ON "observability"."sql_statement_minute_series";
CREATE TRIGGER trg_forbid_update BEFORE UPDATE ON "observability"."sql_statement_minute_series"
    FOR EACH ROW EXECUTE FUNCTION "integrity"."forbid_mutation"();


-- ═══ worker_tick_minute_series ═══
--   UPDATE: forbidden
--   RETENTION: 30 days (drop_chunks; DELETE allowed)
-- UPDATE: forbidden → barrera física parcial (DELETE permitido: retención)
REVOKE UPDATE ON "observability"."worker_tick_minute_series" FROM PUBLIC;
DROP TRIGGER IF EXISTS trg_forbid_update ON "observability"."worker_tick_minute_series";
CREATE TRIGGER trg_forbid_update BEFORE UPDATE ON "observability"."worker_tick_minute_series"
    FOR EACH ROW EXECUTE FUNCTION "integrity"."forbid_mutation"();


-- ═══ slow_request_samples ═══
--   UPDATE: forbidden
--   RETENTION: 30 days (drop_chunks; DELETE allowed)
-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "observability"."slow_request_samples" DROP CONSTRAINT IF EXISTS "ck_slow_request_samples_sampled_because";
ALTER TABLE "observability"."slow_request_samples" ADD CONSTRAINT "ck_slow_request_samples_sampled_because" CHECK ("sampled_because" IN ('slow', 'error', 'random'));

-- UPDATE: forbidden → barrera física parcial (DELETE permitido: retención)
REVOKE UPDATE ON "observability"."slow_request_samples" FROM PUBLIC;
DROP TRIGGER IF EXISTS trg_forbid_update ON "observability"."slow_request_samples";
CREATE TRIGGER trg_forbid_update BEFORE UPDATE ON "observability"."slow_request_samples"
    FOR EACH ROW EXECUTE FUNCTION "integrity"."forbid_mutation"();


-- ═══ dependency_probe_runs ═══
--   UPDATE: forbidden
--   RETENTION: 30 days (drop_chunks; DELETE allowed)
-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "observability"."dependency_probe_runs" DROP CONSTRAINT IF EXISTS "ck_dependency_probe_runs_status";
ALTER TABLE "observability"."dependency_probe_runs" ADD CONSTRAINT "ck_dependency_probe_runs_status" CHECK ("status" IN ('up', 'degraded', 'down', 'not_probed'));

-- UPDATE: forbidden → barrera física parcial (DELETE permitido: retención)
REVOKE UPDATE ON "observability"."dependency_probe_runs" FROM PUBLIC;
DROP TRIGGER IF EXISTS trg_forbid_update ON "observability"."dependency_probe_runs";
CREATE TRIGGER trg_forbid_update BEFORE UPDATE ON "observability"."dependency_probe_runs"
    FOR EACH ROW EXECUTE FUNCTION "integrity"."forbid_mutation"();


-- ═══ alert_evaluations ═══
--   UPDATE: forbidden
--   RETENTION: 400 days (purge job; DELETE allowed)
-- UPDATE: forbidden → barrera física parcial (DELETE permitido: retención)
REVOKE UPDATE ON "observability"."alert_evaluations" FROM PUBLIC;
DROP TRIGGER IF EXISTS trg_forbid_update ON "observability"."alert_evaluations";
CREATE TRIGGER trg_forbid_update BEFORE UPDATE ON "observability"."alert_evaluations"
    FOR EACH ROW EXECUTE FUNCTION "integrity"."forbid_mutation"();


-- ═══ error_groups ═══
-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "observability"."error_groups" DROP CONSTRAINT IF EXISTS "ck_error_groups_source";
ALTER TABLE "observability"."error_groups" ADD CONSTRAINT "ck_error_groups_source" CHECK ("source" IN ('api', 'worker', 'web'));


-- ═══ instances ═══
-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "observability"."instances" DROP CONSTRAINT IF EXISTS "ck_instances_kind";
ALTER TABLE "observability"."instances" ADD CONSTRAINT "ck_instances_kind" CHECK ("kind" IN ('API', 'WORKER'));

-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "observability"."instances" DROP CONSTRAINT IF EXISTS "ck_instances_status";
ALTER TABLE "observability"."instances" ADD CONSTRAINT "ck_instances_status" CHECK ("status" IN ('starting', 'running', 'draining', 'stopped'));
