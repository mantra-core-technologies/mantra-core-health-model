-- ============================================================================
-- SALUD · patch (marketing · unicidad del código por tenant) sobre BD viva
-- Fecha: 2026-10-24 · hallazgo MKT-02 (revisión de seguridad del 2026-10-04)
-- Idempotente (IF EXISTS / IF NOT EXISTS). UNA sola pasada. Sin backfill.
--
-- Contexto: el servicio busca duplicados por (tenant_id, code) para segmentos,
-- campañas y journeys, y los DTO y el README declaran el código único POR tenant.
-- El DDL generado, en cambio, creó uq_segments_code, uq_marketing_campaigns_code
-- y uq_journeys_code solo sobre (code): el primer alta de un código ya usado por
-- otra organización pasaba la validación del servicio y la base la rechazaba
-- globalmente. Este patch los reemplaza por índices únicos sobre (tenant_id, code).
-- gen_apply.py no escanea SQL/patches/: no entra en apply_all.sql. El generador
-- (.puml → SQL, repo del modelo) es quien debe emitir los índices definitivos.
--
-- PRECONDICIÓN: ninguna. Pasar de UNIQUE(code) a UNIQUE(tenant_id, code) solo
-- relaja la restricción: toda base que cumplía la anterior cumple la nueva, así
-- que no puede haber duplicados que bloqueen el CREATE. Comprobación de solo
-- lectura (debe devolver 0 filas por tabla):
--   SELECT tenant_id, code, count(*) FROM marketing.segments
--    GROUP BY 1, 2 HAVING count(*) > 1;
--   SELECT tenant_id, code, count(*) FROM marketing.marketing_campaigns
--    GROUP BY 1, 2 HAVING count(*) > 1;
--   SELECT tenant_id, code, count(*) FROM marketing.journeys
--    GROUP BY 1, 2 HAVING count(*) > 1;
--
-- DELTAS ESPERADOS sobre la base viva:
--   tablas +0 · columnas +0 · FKs +0 · índices +0 (3 reemplazados)
-- ============================================================================

BEGIN;

-- Primero el índice nuevo: no hay ventana sin unicidad.
CREATE UNIQUE INDEX IF NOT EXISTS "uq_segments_tenant_id_code" ON "marketing"."segments" ("tenant_id", "code");
CREATE UNIQUE INDEX IF NOT EXISTS "uq_marketing_campaigns_tenant_id_code" ON "marketing"."marketing_campaigns" ("tenant_id", "code");
CREATE UNIQUE INDEX IF NOT EXISTS "uq_journeys_tenant_id_code" ON "marketing"."journeys" ("tenant_id", "code");

DROP INDEX IF EXISTS "marketing"."uq_segments_code";
DROP INDEX IF EXISTS "marketing"."uq_marketing_campaigns_code";
DROP INDEX IF EXISTS "marketing"."uq_journeys_code";

COMMIT;
