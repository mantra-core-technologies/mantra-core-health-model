-- SALUD v4.0.1 · módulo 58 time_series · TimescaleDB — generado de los .puml

CREATE EXTENSION IF NOT EXISTS timescaledb;

CREATE SCHEMA IF NOT EXISTS "time_series";

CREATE TABLE IF NOT EXISTS "time_series"."device_raw_reading_series" (
    "time" timestamptz NOT NULL,
    "tenant_id" uuid NOT NULL,
    "series_id" varchar NOT NULL,
    "ingestion_id" uuid NOT NULL,
    "source_version" varchar NOT NULL,
    "quality_state" varchar NOT NULL,
    "device_id" uuid NOT NULL,
    "patient_profile_id" uuid,
    "channel_code" varchar NOT NULL,
    "raw_value" jsonb NOT NULL,
    "numeric_value" double precision,
    "unit_code" varchar,
    "device_sequence" bigint,
    "observed_at_device" timestamptz,
    "received_at" timestamptz NOT NULL
);

CREATE TABLE IF NOT EXISTS "time_series"."normalized_vital_series" (
    "time" timestamptz NOT NULL,
    "tenant_id" uuid NOT NULL,
    "series_id" varchar NOT NULL,
    "ingestion_id" uuid NOT NULL,
    "source_version" varchar NOT NULL,
    "quality_state" varchar NOT NULL,
    "patient_profile_id" uuid NOT NULL,
    "observation_code" varchar NOT NULL,
    "numeric_value" double precision NOT NULL,
    "unit_code" varchar NOT NULL,
    "device_id" uuid,
    "encounter_id" uuid,
    "validation_state" varchar NOT NULL,
    "clinically_promoted_observation_id" uuid
);

CREATE TABLE IF NOT EXISTS "time_series"."telemetry_event_series" (
    "time" timestamptz NOT NULL,
    "tenant_id" uuid NOT NULL,
    "series_id" varchar NOT NULL,
    "ingestion_id" uuid NOT NULL,
    "source_version" varchar NOT NULL,
    "quality_state" varchar NOT NULL,
    "user_id" uuid NOT NULL,
    "event_code" varchar NOT NULL,
    "session_id" uuid NOT NULL,
    "application_code" varchar NOT NULL,
    "duration_ms" integer NOT NULL,
    "properties" jsonb
);

CREATE TABLE IF NOT EXISTS "time_series"."location_ping_series" (
    "time" timestamptz NOT NULL,
    "tenant_id" uuid NOT NULL,
    "series_id" varchar NOT NULL,
    "ingestion_id" uuid NOT NULL,
    "source_version" varchar NOT NULL,
    "quality_state" varchar NOT NULL,
    "subject_type" varchar NOT NULL,
    "subject_id" uuid NOT NULL,
    "latitude" double precision NOT NULL,
    "longitude" double precision NOT NULL,
    "altitude_m" double precision,
    "accuracy_m" double precision,
    "speed_mps" double precision,
    "geohash" varchar
);

CREATE TABLE IF NOT EXISTS "time_series"."application_tracking_series" (
    "time" timestamptz NOT NULL,
    "tenant_id" uuid NOT NULL,
    "series_id" varchar NOT NULL,
    "ingestion_id" uuid NOT NULL,
    "source_version" varchar NOT NULL,
    "quality_state" varchar NOT NULL,
    "application_code" varchar NOT NULL,
    "user_id" uuid NOT NULL,
    "event_name" varchar NOT NULL,
    "screen_code" varchar,
    "campaign_id" uuid,
    "properties" jsonb
);

CREATE TABLE IF NOT EXISTS "time_series"."ads_delivery_event_series" (
    "time" timestamptz NOT NULL,
    "tenant_id" uuid NOT NULL,
    "series_id" varchar NOT NULL,
    "ingestion_id" uuid NOT NULL,
    "source_version" varchar NOT NULL,
    "quality_state" varchar NOT NULL,
    "ad_account_id" uuid NOT NULL,
    "campaign_id" uuid NOT NULL,
    "ad_set_id" uuid,
    "ad_id" uuid,
    "event_name" varchar NOT NULL,
    "event_id" varchar NOT NULL,
    "value" double precision,
    "currency_code" char(3),
    "dimensions" jsonb
);

CREATE TABLE IF NOT EXISTS "time_series"."ai_runtime_metric_series" (
    "time" timestamptz NOT NULL,
    "tenant_id" uuid NOT NULL,
    "series_id" varchar NOT NULL,
    "ingestion_id" uuid NOT NULL,
    "source_version" varchar NOT NULL,
    "quality_state" varchar NOT NULL,
    "agent_id" uuid NOT NULL,
    "execution_id" uuid NOT NULL,
    "model_provider" varchar NOT NULL,
    "model_id" varchar NOT NULL,
    "metric_code" varchar NOT NULL,
    "metric_value" double precision NOT NULL,
    "dimensions" jsonb
);

CREATE TABLE IF NOT EXISTS "time_series"."payment_gateway_metric_series" (
    "time" timestamptz NOT NULL,
    "tenant_id" uuid NOT NULL,
    "series_id" varchar NOT NULL,
    "ingestion_id" uuid NOT NULL,
    "source_version" varchar NOT NULL,
    "quality_state" varchar NOT NULL,
    "gateway_id" uuid NOT NULL,
    "operation_code" varchar NOT NULL,
    "metric_code" varchar NOT NULL,
    "metric_value" double precision NOT NULL,
    "payment_transaction_id" uuid,
    "dimensions" jsonb
);

CREATE TABLE IF NOT EXISTS "time_series"."lab_analyzer_event_series" (
    "time" timestamptz NOT NULL,
    "tenant_id" uuid NOT NULL,
    "series_id" varchar NOT NULL,
    "ingestion_id" uuid NOT NULL,
    "source_version" varchar NOT NULL,
    "quality_state" varchar NOT NULL,
    "analyzer_id" uuid NOT NULL,
    "accession_id" uuid NOT NULL,
    "event_code" varchar NOT NULL,
    "test_code" varchar,
    "numeric_value" double precision,
    "unit_code" varchar,
    "details" jsonb
);

CREATE TABLE IF NOT EXISTS "time_series"."ingestion_pipeline_metric_series" (
    "time" timestamptz NOT NULL,
    "tenant_id" uuid NOT NULL,
    "series_id" varchar NOT NULL,
    "ingestion_id" uuid NOT NULL,
    "source_version" varchar NOT NULL,
    "quality_state" varchar NOT NULL,
    "pipeline_code" varchar NOT NULL,
    "batch_id" uuid NOT NULL,
    "stage_code" varchar NOT NULL,
    "metric_code" varchar NOT NULL,
    "metric_value" double precision NOT NULL,
    "details" jsonb
);

CREATE TABLE IF NOT EXISTS "time_series"."service_sli_series" (
    "time" timestamptz NOT NULL,
    "tenant_id" uuid NOT NULL,
    "series_id" varchar NOT NULL,
    "ingestion_id" uuid NOT NULL,
    "source_version" varchar NOT NULL,
    "quality_state" varchar NOT NULL,
    "service_id" uuid NOT NULL,
    "sli_code" varchar NOT NULL,
    "numerator" double precision NOT NULL,
    "denominator" double precision NOT NULL,
    "value" double precision NOT NULL,
    "region_code" varchar,
    "dimensions" jsonb
);

CREATE TABLE IF NOT EXISTS "time_series"."audit_access_metric_series" (
    "time" timestamptz NOT NULL,
    "tenant_id" uuid NOT NULL,
    "series_id" varchar NOT NULL,
    "ingestion_id" uuid NOT NULL,
    "source_version" varchar NOT NULL,
    "quality_state" varchar NOT NULL,
    "actor_type" varchar NOT NULL,
    "actor_id" uuid NOT NULL,
    "action_code" varchar NOT NULL,
    "target_type" varchar NOT NULL,
    "outcome" varchar NOT NULL,
    "count" bigint NOT NULL,
    "dimensions" jsonb
);


-- Hypertables e índices

SELECT create_hypertable('time_series.device_raw_reading_series', 'time', chunk_time_interval => INTERVAL '1 day', if_not_exists => TRUE);
SELECT add_dimension('time_series.device_raw_reading_series', 'tenant_id', number_partitions => 4, if_not_exists => TRUE);
CREATE INDEX IF NOT EXISTS "order_device_raw" ON "time_series"."device_raw_reading_series" ("tenant_id", "device_id", "channel_code", "time" DESC);
CREATE UNIQUE INDEX IF NOT EXISTS "uq_device_sequence" ON "time_series"."device_raw_reading_series" ("tenant_id", "device_id", "channel_code", "device_sequence", "time");
CREATE INDEX IF NOT EXISTS "brin_device_time" ON "time_series"."device_raw_reading_series" USING brin ("time");
SELECT create_hypertable('time_series.normalized_vital_series', 'time', chunk_time_interval => INTERVAL '7 days', if_not_exists => TRUE);
SELECT add_dimension('time_series.normalized_vital_series', 'tenant_id', number_partitions => 4, if_not_exists => TRUE);
CREATE INDEX IF NOT EXISTS "order_vitals_patient_code" ON "time_series"."normalized_vital_series" ("tenant_id", "patient_profile_id", "observation_code", "time" DESC);
CREATE INDEX IF NOT EXISTS "ix_vitals_promoted" ON "time_series"."normalized_vital_series" ("clinically_promoted_observation_id");
SELECT create_hypertable('time_series.telemetry_event_series', 'time', chunk_time_interval => INTERVAL '1 day', if_not_exists => TRUE);
CREATE INDEX IF NOT EXISTS "order_telemetry_user" ON "time_series"."telemetry_event_series" ("tenant_id", "user_id", "time" DESC);
SELECT create_hypertable('time_series.location_ping_series', 'time', chunk_time_interval => INTERVAL '1 day', if_not_exists => TRUE);
CREATE INDEX IF NOT EXISTS "order_location_subject" ON "time_series"."location_ping_series" ("tenant_id", "subject_id", "time" DESC);
SELECT create_hypertable('time_series.application_tracking_series', 'time', chunk_time_interval => INTERVAL '1 day', if_not_exists => TRUE);
CREATE INDEX IF NOT EXISTS "order_tracking_app_event" ON "time_series"."application_tracking_series" ("tenant_id", "application_code", "event_name", "time" DESC);
SELECT create_hypertable('time_series.ads_delivery_event_series', 'time', chunk_time_interval => INTERVAL '1 day', if_not_exists => TRUE);
CREATE INDEX IF NOT EXISTS "order_ads_campaign_event" ON "time_series"."ads_delivery_event_series" ("tenant_id", "campaign_id", "event_name", "time" DESC);
CREATE UNIQUE INDEX IF NOT EXISTS "uq_ads_event" ON "time_series"."ads_delivery_event_series" ("tenant_id", "ad_account_id", "event_id", "event_name", "time");
SELECT create_hypertable('time_series.ai_runtime_metric_series', 'time', chunk_time_interval => INTERVAL '1 day', if_not_exists => TRUE);
CREATE INDEX IF NOT EXISTS "order_ai_agent_metric" ON "time_series"."ai_runtime_metric_series" ("tenant_id", "agent_id", "metric_code", "time" DESC);
SELECT create_hypertable('time_series.payment_gateway_metric_series', 'time', chunk_time_interval => INTERVAL '1 day', if_not_exists => TRUE);
CREATE INDEX IF NOT EXISTS "order_payment_gateway_metric" ON "time_series"."payment_gateway_metric_series" ("tenant_id", "gateway_id", "metric_code", "time" DESC);
SELECT create_hypertable('time_series.lab_analyzer_event_series', 'time', chunk_time_interval => INTERVAL '1 day', if_not_exists => TRUE);
CREATE INDEX IF NOT EXISTS "order_lab_accession" ON "time_series"."lab_analyzer_event_series" ("tenant_id", "accession_id", "time" DESC);
SELECT create_hypertable('time_series.ingestion_pipeline_metric_series', 'time', chunk_time_interval => INTERVAL '1 day', if_not_exists => TRUE);
CREATE INDEX IF NOT EXISTS "order_ingestion_batch_stage" ON "time_series"."ingestion_pipeline_metric_series" ("tenant_id", "batch_id", "stage_code", "time" DESC);
SELECT create_hypertable('time_series.service_sli_series', 'time', chunk_time_interval => INTERVAL '1 day', if_not_exists => TRUE);
CREATE INDEX IF NOT EXISTS "order_sli_service_code" ON "time_series"."service_sli_series" ("service_id", "sli_code", "time" DESC);
SELECT create_hypertable('time_series.audit_access_metric_series', 'time', chunk_time_interval => INTERVAL '1 day', if_not_exists => TRUE);
CREATE INDEX IF NOT EXISTS "order_audit_metric" ON "time_series"."audit_access_metric_series" ("tenant_id", "target_type", "action_code", "time" DESC);

-- Políticas avanzadas (definir intervalos/config concretos):

-- RETENTION retain_device_raw en device_raw_reading_series: policy by tenant and program
-- COMPRESSION compress_device_raw en device_raw_reading_series: segment by tenant_id,device_id,channel_code order by time
-- COMPRESSION compress_vitals en normalized_vital_series: segment by tenant_id,patient_profile_id,observation_code
-- SKIP bloom_telemetry_event en telemetry_event_series: event_code
-- RETENTION retain_telemetry en telemetry_event_series: privacy policy
-- GEO geohash_location en location_ping_series: geohash prefix
-- RETENTION retain_location en location_ping_series: short, consent-governed
-- SKIP bloom_tracking_user en application_tracking_series: user_id
-- RETENTION retain_tracking en application_tracking_series: analytics policy
-- RETENTION retain_ads_event en ads_delivery_event_series: campaign attribution window
-- SKIP bloom_ai_model en ai_runtime_metric_series: model_provider, model_id
-- RETENTION retain_ai_metric en ai_runtime_metric_series: observability policy
-- SKIP bloom_payment_tx en payment_gateway_metric_series: payment_transaction_id
-- RETENTION retain_payment_metric en payment_gateway_metric_series: operational policy
-- SKIP bloom_lab_event en lab_analyzer_event_series: event_code, test_code
-- RETENTION retain_lab_event en lab_analyzer_event_series: laboratory quality policy
-- SKIP bloom_ingestion_metric en ingestion_pipeline_metric_series: metric_code
-- ROLLUP continuous_sli_hourly en service_sli_series: 1 hour aggregate
-- ROLLUP continuous_sli_daily en service_sli_series: 1 day aggregate
-- RETENTION retain_sli_raw en service_sli_series: raw short, aggregates long
-- ROLLUP continuous_audit_daily en audit_access_metric_series: daily counts
-- POLICY no_raw_audit_replacement en audit_access_metric_series: metrics do not replace audit events
