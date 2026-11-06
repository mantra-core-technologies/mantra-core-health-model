-- ============================================================================
-- SALUD · patch v4.2.96 (clinical · orden registrada por el centro ejecutor) sobre BD viva.
-- Fecha: 2026-11-06
-- Idempotente (ADD COLUMN IF NOT EXISTS, CHECK con DROP IF EXISTS + ADD). UNA sola pasada.
--
-- Contexto. Hasta v4.2.95 una orden de estudio (clinical.service_requests) sólo nacía del médico
-- en la consulta. El laboratorio o centro de imagen no tenía cómo cargar la orden que el paciente
-- trae en papel o pide en el mostrador. Este parche agrega lo que esa orden necesita:
--   registered_by_performer     boolean NOT NULL DEFAULT false
--                               la cargó el propio centro ejecutor. Sólo estas las puede editar el
--                               centro; las de un médico siguen siendo del médico.
--   external_requester_name     varchar(200)  quien firmó la orden en papel (opcional: un estudio a
--                               pedido del paciente no tiene médico).
--   external_requester_license  varchar(64)   su matrícula, si figura.
--
-- CHECK (módulo 33).
--   ck_service_requests_external_requester_only_when_registered: el solicitante externo sólo existe
--     en una orden registrada por el centro.
--   ck_service_requests_registered_by_performer_shape: esa orden no tiene encuentro ni solicitante de
--     la plataforma, y tiene ejecutor y la custodia él mismo (performer_tenant_id = custodian_tenant_id, no NULL).
--
-- POR QUÉ DEFAULT false Y NO NULL. Toda fila existente la creó un solicitante de la plataforma:
-- false es el dato verdadero, no un relleno. Con DEFAULT, los INSERT que no conocen la columna
-- (requisiciones, perioperatorio, semillas) siguen funcionando.
--
-- BLOQUEO. ADD COLUMN con DEFAULT constante no reescribe la tabla en PostgreSQL ≥ 11; los ADD
-- CONSTRAINT la recorren una vez dentro de la transacción.
--
-- RECUPERACIÓN (reversible). Antes de que exista una orden registrada por un centro:
--   BEGIN;
--   ALTER TABLE "clinical"."service_requests" DROP CONSTRAINT IF EXISTS "ck_service_requests_registered_by_performer_shape";
--   ALTER TABLE "clinical"."service_requests" DROP CONSTRAINT IF EXISTS "ck_service_requests_external_requester_only_when_registered";
--   ALTER TABLE "clinical"."service_requests" DROP COLUMN IF EXISTS "external_requester_license", DROP COLUMN IF EXISTS "external_requester_name", DROP COLUMN IF EXISTS "registered_by_performer";
--   COMMIT;
-- Con órdenes ya cargadas, volcar antes esas tres columnas: DROP COLUMN las pierde.
--
-- DELTAS ESPERADOS: columnas de clinical.service_requests 33 → 36; CHECK +2; FK ±0; índices ±0.
-- ============================================================================

BEGIN;

ALTER TABLE "clinical"."service_requests"
    ADD COLUMN IF NOT EXISTS "registered_by_performer" boolean NOT NULL DEFAULT false,
    ADD COLUMN IF NOT EXISTS "external_requester_name" varchar(200),
    ADD COLUMN IF NOT EXISTS "external_requester_license" varchar(64);

ALTER TABLE "clinical"."service_requests" DROP CONSTRAINT IF EXISTS "ck_service_requests_external_requester_only_when_registered";
ALTER TABLE "clinical"."service_requests" ADD CONSTRAINT "ck_service_requests_external_requester_only_when_registered" CHECK (("registered_by_performer" OR ("external_requester_name" IS NULL AND "external_requester_license" IS NULL)));

ALTER TABLE "clinical"."service_requests" DROP CONSTRAINT IF EXISTS "ck_service_requests_registered_by_performer_shape";
ALTER TABLE "clinical"."service_requests" ADD CONSTRAINT "ck_service_requests_registered_by_performer_shape" CHECK ((NOT "registered_by_performer" OR ("encounter_id" IS NULL AND "requester_profile_id" IS NULL AND "performer_tenant_id" IS NOT NULL AND "performer_tenant_id" = "custodian_tenant_id")));

COMMENT ON COLUMN "clinical"."service_requests"."registered_by_performer" IS 'v4.2.96: la orden la cargó el propio centro ejecutor (papel o mostrador); sólo estas las edita el centro.';
COMMENT ON COLUMN "clinical"."service_requests"."external_requester_name" IS 'v4.2.96: quien firmó la orden en papel; sólo en órdenes registradas por el centro.';
COMMENT ON COLUMN "clinical"."service_requests"."external_requester_license" IS 'v4.2.96: matrícula de quien firmó la orden en papel, si figura.';

COMMIT;
