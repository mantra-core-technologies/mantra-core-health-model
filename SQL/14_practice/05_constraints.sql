-- SALUD v4.2.68 · schema practice · constraints de integridad (módulo 33)
-- Aplicar DESPUÉS de 04_indexes.sql y de SQL/_integrity/00_integrity_functions.sql.
-- Reglas del módulo 33. Las UK/CHECK/EXCLUDE en prosa quedan como comentario:
-- el modelo no declara su expresión SQL y no se inventa (temperatura-0).
-- CHECK_SQL y EXCLUDE_SQL sí se materializan con la expresión del modelo.

CREATE EXTENSION IF NOT EXISTS btree_gist;  -- requerido por EXCLUDE


-- ═══ care_spaces ═══
-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "practice"."care_spaces" DROP CONSTRAINT IF EXISTS "ck_care_spaces_buffers";
ALTER TABLE "practice"."care_spaces" ADD CONSTRAINT "ck_care_spaces_buffers" CHECK ((COALESCE("prep_minutes", 0) >= 0 AND COALESCE("cleanup_minutes", 0) >= 0));


-- ═══ care_space_status_events ═══
--   UPDATE_DELETE: forbidden
-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "practice"."care_space_status_events" DROP CONSTRAINT IF EXISTS "ck_care_space_status_events_v2_0116_code";
ALTER TABLE "practice"."care_space_status_events" ADD CONSTRAINT "ck_care_space_status_events_v2_0116_code" CHECK ("v2_0116_code" IN ('C','H','I','K','O','U','R'));

-- UPDATE_DELETE: forbidden → barrera física (append-only)
REVOKE UPDATE, DELETE ON "practice"."care_space_status_events" FROM PUBLIC;
DROP TRIGGER IF EXISTS trg_forbid_mutation ON "practice"."care_space_status_events";
CREATE TRIGGER trg_forbid_mutation BEFORE UPDATE OR DELETE ON "practice"."care_space_status_events"
    FOR EACH ROW EXECUTE FUNCTION "integrity"."forbid_mutation"();


-- ═══ care_space_blocks ═══
--   EXCLUDE: one non-cancelled block per space and time  (en prosa; el módulo 33 no declara su expresión SQL; ver EXCLUDE_SQL abajo)
-- EXCLUDE concreto declarado por el modelo (EXCLUDE_SQL).
ALTER TABLE "practice"."care_space_blocks" DROP CONSTRAINT IF EXISTS "ex_care_space_blocks_time";
ALTER TABLE "practice"."care_space_blocks" ADD CONSTRAINT "ex_care_space_blocks_time"
    EXCLUDE USING gist ("care_space_id" WITH =, tstzrange("starts_at", "ended_at", '[)') WITH &&) WHERE ("cancelled_at" IS NULL);

-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "practice"."care_space_blocks" DROP CONSTRAINT IF EXISTS "ck_care_space_blocks_maintenance_eta";
ALTER TABLE "practice"."care_space_blocks" ADD CONSTRAINT "ck_care_space_blocks_maintenance_eta" CHECK (("kind_concept_id" <> 'b0516b50-47c6-5fdb-b1e7-6ae060fbb4c0' OR "expected_end_at" IS NOT NULL));

-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "practice"."care_space_blocks" DROP CONSTRAINT IF EXISTS "ck_care_space_blocks_end_after_start";
ALTER TABLE "practice"."care_space_blocks" ADD CONSTRAINT "ck_care_space_blocks_end_after_start" CHECK ((("ended_at" IS NULL OR "ended_at" > "starts_at") AND ("expected_end_at" IS NULL OR "expected_end_at" > "starts_at")));


-- ═══ cleaning_orders ═══
-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "practice"."cleaning_orders" DROP CONSTRAINT IF EXISTS "ck_cleaning_orders_inspector_differs";
ALTER TABLE "practice"."cleaning_orders" ADD CONSTRAINT "ck_cleaning_orders_inspector_differs" CHECK (("inspected_by_user_id" IS NULL OR "inspected_by_user_id" <> "finished_by_user_id"));


-- ═══ care_space_category_periods ═══
--   EXCLUDE: one bed category per space and time  (en prosa; el módulo 33 no declara su expresión SQL; ver EXCLUDE_SQL abajo)
-- EXCLUDE concreto declarado por el modelo (EXCLUDE_SQL).
ALTER TABLE "practice"."care_space_category_periods" DROP CONSTRAINT IF EXISTS "ex_care_space_category_periods_validity";
ALTER TABLE "practice"."care_space_category_periods" ADD CONSTRAINT "ex_care_space_category_periods_validity"
    EXCLUDE USING gist ("care_space_id" WITH =, tstzrange("valid_from", "valid_to", '[)') WITH &&);

-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "practice"."care_space_category_periods" DROP CONSTRAINT IF EXISTS "ck_care_space_category_periods_valid_period";
ALTER TABLE "practice"."care_space_category_periods" ADD CONSTRAINT "ck_care_space_category_periods_valid_period" CHECK (("valid_to" IS NULL OR "valid_to" > "valid_from"));
