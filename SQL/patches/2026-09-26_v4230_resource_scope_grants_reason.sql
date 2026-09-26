-- ============================================================================
-- SALUD · patch v4.2.30 (authz · el motivo de un compartido) sobre BD viva
-- Fecha: 2026-09-26 · carril M7 (cierre del modelo) · cierra CL-50 (anexo B)
-- Idempotente (ADD COLUMN IF NOT EXISTS). UNA sola pasada. Sin backfill.
--
-- Contexto: gen_ddl.py ya emite esta columna en SQL/06_authz/ desde que el
-- .puml la declara, así que en un rebuild desde cero este patch NO hace falta.
-- Existe únicamente para una base ya aplicada y poblada. gen_apply.py no
-- escanea SQL/patches/, así que no entra en apply_all.sql.
--
-- QUÉ CIERRA. CL-50: `POST /diagnostic-results/me/:reportId/shares` aceptaba
-- `reason` y lo descartaba en silencio porque `authz.resource_scope_grants` no
-- tenía dónde guardarlo. El carril de API retiró el campo del DTO para que no
-- mintiera (hoy responde 400) y dejó el pedido: si el producto necesita
-- persistir el motivo de un compartido, hace falta la columna. Esta es.
--
-- POR QUÉ `reason_text text` NULLABLE. Es texto que escribe el paciente al
-- compartir un resultado; no es un catálogo (sin `*_concept_id` inventado) y
-- compartir sin motivo sigue siendo válido. `reason_text` es el nombre que ya
-- usan otras 15 tablas del modelo para un motivo libre.
--
-- POR QUÉ NO HAY BACKFILL. Los grants existentes se crearon sin motivo, que es
-- exactamente lo que dice NULL. `resource_scope_grants` no tiene tabla de
-- historial: el motivo vive en la propia fila.
--
-- DELTAS ESPERADOS sobre la base viva:
--   columnas de authz.resource_scope_grants  +1 (reason_text)
--   FKs ±0 · índices ±0 · tablas ±0
-- ============================================================================

BEGIN;

ALTER TABLE "authz"."resource_scope_grants"
    ADD COLUMN IF NOT EXISTS "reason_text" text;

DO $$
DECLARE
    n_columnas integer;
BEGIN
    SELECT count(*) INTO n_columnas
    FROM information_schema.columns
    WHERE table_schema = 'authz'
      AND table_name = 'resource_scope_grants'
      AND column_name = 'reason_text'
      AND data_type = 'text'
      AND is_nullable = 'YES';

    IF n_columnas <> 1 THEN
        RAISE EXCEPTION
            'v4.2.30 incompleto: columnas=% (esperado 1)', n_columnas;
    END IF;

    RAISE NOTICE 'v4.2.30 aplicado: 1 columna (reason_text).';
END $$;

COMMIT;
