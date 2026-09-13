-- ============================================================================
-- SALUD · patch t26 (accounting · automatización de activos y pasivos) sobre BD viva
-- Fecha: 2026-09-05
-- Idempotente (ADD COLUMN IF NOT EXISTS).
-- UNA sola pasada. No hay backfill que hacer: el valor por omisión ya cubre
-- las filas existentes.
--
-- QUÉ CIERRA. FT-26 ("Creación de módulo de activos y pasivos"): "Se puede
-- registrar su avance en ambos casos [automatización encendida o apagada]. La
-- automatización puede estar apagada o encendida." Hasta hoy ni `assets` ni
-- `liabilities` tenían dónde guardar esa preferencia — la depreciación
-- (`AssetService.runDepreciation`) y el pago de cuota
-- (`LiabilityService.payLiability`) sólo se disparaban a mano, sin ningún
-- interruptor que una corrida programada pudiera consultar.
--
-- POR QUÉ SÓLO LA COLUMNA, Y NO EL JOB QUE LA LEE. Este patch abre el dato;
-- no agrega el worker periódico que recorrería `automated = true` para
-- depreciar/pagar solo. Ese worker es infraestructura de scheduling nueva
-- (no existe un patrón equivalente en `src/worker/` para "recorrer por
-- practiceId y accionar"), y construirlo sin un dueño de negocio que defina
-- la cadencia (¿diaria? ¿al cierre de mes?) sería inventar una regla que
-- nadie pidió con esa precisión. Documentado como bloqueo, no como olvido:
-- ver el reporte del carril FT-26.
--
-- POR QUÉ DEFAULT TRUE. Es el valor que el pedido describe como el estado
-- "encendido" — la automatización es la expectativa por omisión, y quien no
-- la quiere la apaga explícitamente.
--
-- DELTAS ESPERADOS sobre la base viva:
--   columnas de accounting.assets        18 → 19
--   columnas de accounting.liabilities   18 → 19
--   FKs                                  ±0
--   índices                              ±0
--   tablas                               ±0
-- ============================================================================

BEGIN;

ALTER TABLE "accounting"."assets"
    ADD COLUMN IF NOT EXISTS "automated" boolean NOT NULL DEFAULT true;

ALTER TABLE "accounting"."liabilities"
    ADD COLUMN IF NOT EXISTS "automated" boolean NOT NULL DEFAULT true;

-- ------------------------------------------------------------ D. verificación
DO $$
DECLARE
    n_assets      integer;
    n_liabilities integer;
BEGIN
    SELECT count(*) INTO n_assets
    FROM information_schema.columns
    WHERE table_schema = 'accounting'
      AND table_name = 'assets'
      AND column_name = 'automated';

    SELECT count(*) INTO n_liabilities
    FROM information_schema.columns
    WHERE table_schema = 'accounting'
      AND table_name = 'liabilities'
      AND column_name = 'automated';

    IF n_assets <> 1 OR n_liabilities <> 1 THEN
        RAISE EXCEPTION
            't26 incompleto: assets.automated=% (esperado 1), liabilities.automated=% (esperado 1)',
            n_assets, n_liabilities;
    END IF;

    RAISE NOTICE 't26 aplicado: 2 columnas (assets.automated, liabilities.automated).';
END $$;

COMMIT;
