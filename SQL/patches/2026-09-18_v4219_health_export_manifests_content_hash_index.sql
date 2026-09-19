-- ============================================================================
-- SALUD · patch v4.2.19 (health_data · portabilidad de seguros) sobre BD viva
-- Fecha: 2026-09-18
-- Idempotente (CREATE INDEX IF NOT EXISTS). UNA sola pasada. SIN backfill.
--
-- Contexto: subtarea 3.3 (portabilidad de póliza e historial de siniestralidad
-- a 1 clic). El registro de procesos del stakeholder (MÓDULO ASEGURADORA ·
-- 6.3, ítem 5) pide que, ante un cambio de compañía, la app entregue toda la
-- siniestralidad del titular "a un clic". Brecha §24 "Portabilidad entre
-- aseguradoras" y tarjeta T-27 ya señalaban que el mecanismo de exportación
-- (`health_data.health_export_jobs` + `health_export_manifests`, con hash de
-- contenido) ya existe y está bien hecho — lo que faltaba era la solicitud
-- del titular y exportar `insurance.*`, que resuelve la API de esta subtarea
-- sin tocar el esquema. Lo único que el modelo necesita es poder BUSCAR el
-- manifiesto por su hash: es lo que el endpoint público de verificación
-- (`GET /public/portability/verify/:manifestHash`) hace en cada llamada, y
-- `content_hash` no tenía índice.
--
-- QUÉ ENTRA. Un solo índice BTREE sobre `health_data.health_export_manifests
-- (content_hash)`. Sin columnas nuevas, sin FKs nuevas, sin backfill.
--
-- POR QUÉ SÓLO UN ÍNDICE. La tabla ya declara todo lo que la portabilidad de
-- seguros necesita: `health_export_jobs.patient_profile_id` liga el
-- certificado al titular, `export_type_concept_id` distingue el tipo de
-- exportación (un concepto dinámico nuevo, sin nota `vs_`, sembrado por la
-- API), y `health_export_manifests.content_hash` YA es el sello SHA-256 del
-- contenido entregado. No hay nada de negocio que declarar en el modelo: el
-- verify público sólo necesita que esa búsqueda no sea un escaneo completo.
--
-- DELTAS ESPERADOS sobre la base viva:
--   columnas de health_data.health_export_manifests   ±0
--   FKs                                                ±0
--   índices                                            +1  (ix_health_export_manifests_content_hash)
--   tablas                                             ±0
-- ============================================================================

BEGIN;

-- ------------------------------------------------------------------ A. índice
CREATE INDEX IF NOT EXISTS "ix_health_export_manifests_content_hash"
    ON "health_data"."health_export_manifests" ("content_hash");

-- ------------------------------------------------------------ B. verificación
-- Corré esto DENTRO de la transacción, antes del COMMIT. La consulta tiene
-- que devolver 1; si no, hacé ROLLBACK.
DO $$
DECLARE
    n_indices integer;
BEGIN
    SELECT count(*) INTO n_indices
    FROM pg_indexes
    WHERE schemaname = 'health_data'
      AND indexname = 'ix_health_export_manifests_content_hash';

    IF n_indices <> 1 THEN
        RAISE EXCEPTION
            'v4.2.19 incompleto: indices=% (esperado 1)',
            n_indices;
    END IF;

    RAISE NOTICE 'v4.2.19 aplicado: 1 índice (ix_health_export_manifests_content_hash).';
END $$;

COMMIT;
