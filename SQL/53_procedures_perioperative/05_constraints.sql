-- SALUD v4.2.82 · schema procedures_perioperative · constraints de integridad (módulo 33)
-- Aplicar DESPUÉS de 04_indexes.sql y de SQL/_integrity/00_integrity_functions.sql.
-- Reglas del módulo 33. Las UK/CHECK/EXCLUDE en prosa quedan como comentario:
-- el modelo no declara su expresión SQL y no se inventa (temperatura-0).
-- CHECK_SQL y EXCLUDE_SQL sí se materializan con la expresión del modelo.

CREATE EXTENSION IF NOT EXISTS btree_gist;  -- requerido por EXCLUDE


-- ═══ procedure_cases ═══
--   EXCLUDE: operating room reserved window overlap (scheduled +/- prep/cleanup)  (en prosa; el módulo 33 no declara su expresión SQL; ver EXCLUDE_SQL abajo)
-- EXCLUDE concreto declarado por el modelo (EXCLUDE_SQL).
ALTER TABLE "procedures_perioperative"."procedure_cases" DROP CONSTRAINT IF EXISTS "ex_procedure_cases_operating_room_time";
ALTER TABLE "procedures_perioperative"."procedure_cases" ADD CONSTRAINT "ex_procedure_cases_operating_room_time"
    EXCLUDE USING gist ("operating_room_id" WITH =, tstzrange("reserved_start_at", "reserved_end_at", '[)') WITH &&) WHERE ("operating_room_id" IS NOT NULL AND "reserved_start_at" IS NOT NULL AND "reserved_end_at" IS NOT NULL AND "status_concept_id" IN ('6fe38139-ad1d-5214-84c1-8c184e4e58fb', 'f6985cd5-f867-5d76-b70c-1138667fd2ab', 'fdc78cc9-eda6-5625-9a26-1bdcec4dc203'));

-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "procedures_perioperative"."procedure_cases" DROP CONSTRAINT IF EXISTS "ck_procedure_cases_buffers";
ALTER TABLE "procedures_perioperative"."procedure_cases" ADD CONSTRAINT "ck_procedure_cases_buffers" CHECK ((COALESCE("prep_minutes", 0) >= 0 AND COALESCE("cleanup_minutes", 0) >= 0));


-- ═══ operating_room_block_series ═══
-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "procedures_perioperative"."operating_room_block_series" DROP CONSTRAINT IF EXISTS "ck_operating_room_block_series_owner";
ALTER TABLE "procedures_perioperative"."operating_room_block_series" ADD CONSTRAINT "ck_operating_room_block_series_owner" CHECK (("owner_kind_concept_id" IN ('6b4fd1e9-892f-572b-9e9b-96b321ecdc26', '48a989b7-6300-516d-9982-8f741aaf0758') AND ("owner_kind_concept_id" <> '6b4fd1e9-892f-572b-9e9b-96b321ecdc26' OR "clinical_unit_id" IS NOT NULL OR "surgical_specialty_concept_id" IS NOT NULL) AND ("owner_kind_concept_id" <> '48a989b7-6300-516d-9982-8f741aaf0758' OR "surgeon_profile_id" IS NOT NULL)));

-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "procedures_perioperative"."operating_room_block_series" DROP CONSTRAINT IF EXISTS "ck_operating_room_block_series_time_order";
ALTER TABLE "procedures_perioperative"."operating_room_block_series" ADD CONSTRAINT "ck_operating_room_block_series_time_order" CHECK (("end_time" > "start_time"));

-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "procedures_perioperative"."operating_room_block_series" DROP CONSTRAINT IF EXISTS "ck_operating_room_block_series_validity";
ALTER TABLE "procedures_perioperative"."operating_room_block_series" ADD CONSTRAINT "ck_operating_room_block_series_validity" CHECK (("valid_to" IS NULL OR "valid_to" >= "valid_from"));

-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "procedures_perioperative"."operating_room_block_series" DROP CONSTRAINT IF EXISTS "ck_operating_room_block_series_weekdays";
ALTER TABLE "procedures_perioperative"."operating_room_block_series" ADD CONSTRAINT "ck_operating_room_block_series_weekdays" CHECK ((cardinality("weekdays") > 0 AND "weekdays" <@ ARRAY[1, 2, 3, 4, 5, 6, 7]::smallint[]));

-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "procedures_perioperative"."operating_room_block_series" DROP CONSTRAINT IF EXISTS "ck_operating_room_block_series_release_hours";
ALTER TABLE "procedures_perioperative"."operating_room_block_series" ADD CONSTRAINT "ck_operating_room_block_series_release_hours" CHECK (("release_hours" >= 0));


-- ═══ operating_room_blocks ═══
--   EXCLUDE: active operating room block time overlap  (en prosa; el módulo 33 no declara su expresión SQL; ver EXCLUDE_SQL abajo)
-- EXCLUDE concreto declarado por el modelo (EXCLUDE_SQL).
ALTER TABLE "procedures_perioperative"."operating_room_blocks" DROP CONSTRAINT IF EXISTS "ex_operating_room_blocks_time";
ALTER TABLE "procedures_perioperative"."operating_room_blocks" ADD CONSTRAINT "ex_operating_room_blocks_time"
    EXCLUDE USING gist ("operating_room_id" WITH =, tstzrange("starts_at", "ends_at", '[)') WITH &&) WHERE ("status_concept_id" = '762dc30b-3e3c-5e1e-8504-5c511fd1d4a8');

-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "procedures_perioperative"."operating_room_blocks" DROP CONSTRAINT IF EXISTS "ck_operating_room_blocks_owner";
ALTER TABLE "procedures_perioperative"."operating_room_blocks" ADD CONSTRAINT "ck_operating_room_blocks_owner" CHECK (("owner_kind_concept_id" IN ('6b4fd1e9-892f-572b-9e9b-96b321ecdc26', '48a989b7-6300-516d-9982-8f741aaf0758') AND ("owner_kind_concept_id" <> '6b4fd1e9-892f-572b-9e9b-96b321ecdc26' OR "clinical_unit_id" IS NOT NULL OR "surgical_specialty_concept_id" IS NOT NULL) AND ("owner_kind_concept_id" <> '48a989b7-6300-516d-9982-8f741aaf0758' OR "surgeon_profile_id" IS NOT NULL)));

-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "procedures_perioperative"."operating_room_blocks" DROP CONSTRAINT IF EXISTS "ck_operating_room_blocks_end_after_start";
ALTER TABLE "procedures_perioperative"."operating_room_blocks" ADD CONSTRAINT "ck_operating_room_blocks_end_after_start" CHECK (("ends_at" > "starts_at"));

-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "procedures_perioperative"."operating_room_blocks" DROP CONSTRAINT IF EXISTS "ck_operating_room_blocks_release_before_start";
ALTER TABLE "procedures_perioperative"."operating_room_blocks" ADD CONSTRAINT "ck_operating_room_blocks_release_before_start" CHECK (("release_at" <= "starts_at"));
