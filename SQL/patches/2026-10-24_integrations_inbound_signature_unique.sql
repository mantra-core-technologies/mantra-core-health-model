-- ============================================================================
-- SALUD · patch (integrations · deduplicación atómica de callbacks entrantes) sobre BD viva
-- Fecha: 2026-10-24 · hallazgo INT-03 (revisión de seguridad del 2026-10-04)
-- Idempotente (IF NOT EXISTS). UNA sola pasada. Sin backfill.
--
-- Contexto: el webhook entrante consulta por (connection_id, signature) y luego
-- inserta. Sin un índice único, dos entregas concurrentes con la misma firma
-- veían ausencia antes del primer commit y ambas se persistían; después las dos
-- entraban a la correlación y producían dos respuestas para el mismo saliente.
-- El servicio ahora serializa por (conexión, firma) con un lock transaccional y
-- trata la violación de este índice como duplicado; este patch lo crea.
-- gen_apply.py no escanea SQL/patches/: no entra en apply_all.sql. El generador
-- (.puml → SQL, repo del modelo) es quien debe emitir el índice definitivo.
--
-- PRECONDICIÓN: no debe haber (connection_id, signature) repetidos con firma no
-- nula; si los hubiera, el CREATE falla y el BEGIN hace rollback de todo el
-- patch. El patch lo comprueba antes y aborta con un mensaje que cuenta los
-- grupos repetidos. Resolver los duplicados (conservar la fila más antigua y
-- repuntar o archivar las demás según el caso) y volver a aplicar. Solo lectura:
--   SELECT connection_id, signature, count(*)
--     FROM integrations.inbound_messages
--    WHERE signature IS NOT NULL
--    GROUP BY 1, 2 HAVING count(*) > 1;
--
-- DELTAS ESPERADOS sobre la base viva:
--   tablas +0 · columnas +0 · FKs +0 · índices +1
-- ============================================================================

BEGIN;

DO $$
DECLARE
    duplicados integer;
BEGIN
    SELECT count(*) INTO duplicados FROM (
        SELECT 1
          FROM "integrations"."inbound_messages"
         WHERE "signature" IS NOT NULL
         GROUP BY "connection_id", "signature"
        HAVING count(*) > 1
    ) d;
    IF duplicados > 0 THEN
        RAISE EXCEPTION 'inbound_messages tiene % par(es) (connection_id, signature) repetido(s): resolverlos antes de crear el índice único', duplicados;
    END IF;
END $$;

CREATE UNIQUE INDEX IF NOT EXISTS "uq_inbound_messages_connection_id_signature" ON "integrations"."inbound_messages" ("connection_id", "signature") WHERE signature IS NOT NULL;

COMMIT;
