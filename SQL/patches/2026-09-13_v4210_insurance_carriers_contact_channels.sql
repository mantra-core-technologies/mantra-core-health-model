-- ============================================================================
-- SALUD · patch v4.2.10 (insurance · canales de contacto directo de la aseguradora)
-- Fecha: 2026-09-13
-- Idempotente (ADD COLUMN IF NOT EXISTS + UPDATE ... WHERE ... IS NULL).
-- UNA sola pasada. SÍ hay backfill (sección B) — ver por qué más abajo.
--
-- Contexto: subtarea 2.3. El registro de procesos del stakeholder (MÓDULO
-- ASEGURADORA · 6.2 · ítem 5) pide "una opción para poder llamar mediante
-- Whatsapp directo a la compañía de seguro (la misma compañía nos dará el
-- numero de llamada o call center) y el usuario llamara desde su mismo numero
-- de whatsapp". Brecha §20 "Canal directo con el call center", tarjeta T-23.
--
-- QUÉ ENTRA Y QUÉ NO. Tres columnas nullable en insurance.insurance_carriers:
-- `whatsapp_number` (E.164, lo normaliza la API), `call_center_phone` (tal
-- cual lo publica la compañía — las líneas gratuitas bolivianas son
-- "800-10-xxxx" y no son E.164) y `support_email`. T-23 proponía modelar esto
-- con common.contact_points (polimórfico); se decidió con el negocio el
-- 2026-09-13 seguir columnas propias, más simple para un dato que sólo tiene
-- un dueño posible por fila y sin necesidad de historial de vigencia.
--
-- POR QUÉ SÍ HAY BACKFILL (a diferencia de v4.2.9). Esta tabla NO es
-- <<IMMUTABLE>>: insurance_carriers es un catálogo administrable, se puede
-- UPDATE. Y las 9 aseguradoras bolivianas reales YA existen en toda base
-- viva por DOS sembradores ADD-only con DOS juegos de carrier_code (el boot
-- de la API, prefijo BO_ASEG_*, y el paquete de seeds del modelo, código
-- corto tipo ALIANZA_VIDA): ninguno de los dos actualiza filas existentes,
-- así que sin este backfill esas 9 compañías quedarían sin canales para
-- siempre. Los valores son los publicados en el dominio oficial de cada
-- compañía a la fecha de este patch (regla 70: fuente + fecha citadas por
-- fila; sin publicación confirmada, la columna queda en NULL, nunca
-- inventada). Alianza Vida y Nacional Seguros no pudieron confirmarse en su
-- dominio oficial (el primero resolvió a la aseguradora de generales del
-- mismo grupo, no a la de vida/salud; el segundo devolvió 403 al fetch) y
-- quedan sin backfill: cerrarlo es tarea de quien administre esas dos
-- organizaciones vía el PUT nuevo, no de este patch.
--
-- DELTAS ESPERADOS sobre la base viva:
--   columnas de insurance.insurance_carriers   16 → 19
--   FKs                                        ±0
--   índices                                    ±0
--   tablas                                     ±0
--   filas de insurance_carriers con algún canal no nulo: las 7 compañías
--   confirmadas, contadas UNA VEZ POR CADA carrier_code que tengan (hasta 2)
-- ============================================================================

BEGIN;

-- ---------------------------------------------------------------- A. columnas
ALTER TABLE "insurance"."insurance_carriers"
    ADD COLUMN IF NOT EXISTS "whatsapp_number" varchar;

ALTER TABLE "insurance"."insurance_carriers"
    ADD COLUMN IF NOT EXISTS "call_center_phone" varchar;

ALTER TABLE "insurance"."insurance_carriers"
    ADD COLUMN IF NOT EXISTS "support_email" varchar;

-- ------------------------------------------------------------------ B. backfill
-- Sólo compañías con canal confirmado en su dominio oficial el 2026-09-13.
-- `WHERE ... IS NULL` en las tres a la vez: si alguien ya cargó un canal por
-- el PUT administrable, este patch no lo pisa.

-- BISA Seguros — fuente: https://ayuda.bisaseguros.com (línea de Salud +
-- Contact Center), obtenido 2026-09-13.
UPDATE "insurance"."insurance_carriers"
SET "whatsapp_number" = '+59171545112',
    "call_center_phone" = '800-10-6060'
WHERE "carrier_code" IN ('BO_ASEG_BISA_SEGUROS_Y_REASEGUROS_S_A', 'BISA_SEGUROS')
  AND "whatsapp_number" IS NULL
  AND "call_center_phone" IS NULL
  AND "support_email" IS NULL;

-- Fortaleza Seguros — fuente: https://aseguradorafortaleza.com.bo/contactenos,
-- obtenido 2026-09-13.
UPDATE "insurance"."insurance_carriers"
SET "whatsapp_number" = '+59169200004',
    "call_center_phone" = '800-12-9992'
WHERE "carrier_code" IN ('BO_ASEG_FORTALEZA_SEGUROS_Y_REASEGUROS_S_A', 'FORTALEZA_SEGUROS')
  AND "whatsapp_number" IS NULL
  AND "call_center_phone" IS NULL
  AND "support_email" IS NULL;

-- Crediseguro Personales — fuente: https://www.crediseguro.com.bo,
-- obtenido 2026-09-13. Sin línea gratuita ni correo publicados.
UPDATE "insurance"."insurance_carriers"
SET "whatsapp_number" = '+59178889096'
WHERE "carrier_code" IN ('BO_ASEG_CREDISEGURO_S_A_SEGUROS_PERSONALES', 'CREDISEGURO')
  AND "whatsapp_number" IS NULL
  AND "call_center_phone" IS NULL
  AND "support_email" IS NULL;

-- La Boliviana Ciacruz Seguros Personales — fuente: https://www.lbc.bo/contactanos,
-- obtenido 2026-09-13.
UPDATE "insurance"."insurance_carriers"
SET "whatsapp_number" = '+59171548278',
    "call_center_phone" = '800-10-2727'
WHERE "carrier_code" IN ('BO_ASEG_LA_BOLIVIANA_CIACRUZ_SEGUROS_PERSONALES_S_A', 'LA_BOLIVIANA_CIACRUZ')
  AND "whatsapp_number" IS NULL
  AND "call_center_phone" IS NULL
  AND "support_email" IS NULL;

-- La Vitalicia Seguros y Reaseguros de Vida — fuente: https://lavitalicia.bo/contacto/,
-- obtenido 2026-09-13.
UPDATE "insurance"."insurance_carriers"
SET "whatsapp_number" = '+59177775677',
    "call_center_phone" = '800-10-4142'
WHERE "carrier_code" IN ('BO_ASEG_LA_VITALICIA_SEGUROS_Y_REASEGUROS_DE_VIDA_S_', 'LA_VITALICIA')
  AND "whatsapp_number" IS NULL
  AND "call_center_phone" IS NULL
  AND "support_email" IS NULL;

-- UNIVIDA — fuente: https://www.univida.bo (Contáctenos), obtenido
-- 2026-09-13. Sin WhatsApp de atención al cliente publicado (el único
-- WhatsApp que la compañía difunde es de venta de SOAT, no de reclamos de
-- salud: se descarta a propósito, no es un olvido).
UPDATE "insurance"."insurance_carriers"
SET "call_center_phone" = '800-10-9119'
WHERE "carrier_code" IN ('BO_ASEG_UNIVIDA_S_A', 'UNIVIDA')
  AND "whatsapp_number" IS NULL
  AND "call_center_phone" IS NULL
  AND "support_email" IS NULL;

-- Santa Cruz Vida y Salud — fuente: https://www.santacruzvidaysalud.com.bo/contacto/,
-- obtenido 2026-09-13.
UPDATE "insurance"."insurance_carriers"
SET "whatsapp_number" = '+59172124747',
    "call_center_phone" = '800-12-4747',
    "support_email" = 'consultasSCVS@santacruzfg.com'
WHERE "carrier_code" IN ('BO_ASEG_SANTA_CRUZ_VIDA_Y_SALUD_S_A', 'SANTA_CRUZ_VIDA')
  AND "whatsapp_number" IS NULL
  AND "call_center_phone" IS NULL
  AND "support_email" IS NULL;

-- Alianza Vida y Nacional Seguros Vida y Salud: sin backfill (ver cabecera).

-- ------------------------------------------------------------ D. verificación
-- Corré esto DENTRO de la transacción, antes del COMMIT. La consulta tiene que
-- devolver lo que dice su comentario; si no, hacé ROLLBACK.
DO $$
DECLARE
    n_columnas integer;
    n_con_canal integer;
BEGIN
    -- 3: las tres columnas nuevas están.
    SELECT count(*) INTO n_columnas
    FROM information_schema.columns
    WHERE table_schema = 'insurance'
      AND table_name = 'insurance_carriers'
      AND column_name IN ('whatsapp_number', 'call_center_phone', 'support_email');

    IF n_columnas <> 3 THEN
        RAISE EXCEPTION
            'v4.2.10 incompleto: columnas=% (esperado 3)',
            n_columnas;
    END IF;

    SELECT count(*) INTO n_con_canal
    FROM "insurance"."insurance_carriers"
    WHERE "whatsapp_number" IS NOT NULL
       OR "call_center_phone" IS NOT NULL
       OR "support_email" IS NOT NULL;

    RAISE NOTICE 'v4.2.10 aplicado: 3 columnas nuevas en insurance.insurance_carriers; % fila(s) con algún canal.',
        n_con_canal;
END $$;

COMMIT;
