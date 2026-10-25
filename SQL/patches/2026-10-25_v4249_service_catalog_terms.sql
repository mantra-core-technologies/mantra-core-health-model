-- ============================================================================
-- SALUD · patch v4.2.49 (billing · carril 22) sobre BD viva
-- Fecha: 2026-10-25
--
-- QUÉ ENTRA. `billing.service_catalog.terms_text` (text NULL): los términos y
-- condiciones propios de un servicio del catálogo. NULL significa «usa los
-- términos por defecto»; el texto legal por defecto lo provee el propietario y
-- no vive en esta columna.
--
-- POR QUÉ NULLABLE Y SIN BACKFILL. Ningún servicio tiene hoy términos propios:
-- inventar un texto para las filas existentes sería fabricar un contrato.
--
-- MODELO. Declarada en `diagram_17_billing.puml`; un rebuild desde cero la trae
-- en el CREATE TABLE de SQL/17_billing/02_tables.sql. Este patch es sólo para
-- bases ya aplicadas. Idempotente.
--
-- DELTAS ESPERADOS: columnas de billing.service_catalog +1 · FKs ±0 · índices ±0
-- ============================================================================
BEGIN;
ALTER TABLE "billing"."service_catalog"
  ADD COLUMN IF NOT EXISTS "terms_text" text;
COMMIT;
