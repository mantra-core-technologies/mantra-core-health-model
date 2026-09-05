-- SALUD · patch v4.2.6 (profiles · role_title deja de ser obligatorio)
-- =============================================================================
-- ALV-007: un vínculo de "atiende en su propio consultorio" no tiene un cargo
-- dentro de una jerarquía, y exigirlo bloqueaba el guardado de la afiliación.
-- Si existe, se sigue usando en perfil/trayectoria; vacío no dibuja hueco.
--
-- Idempotente (DROP NOT NULL no falla si la columna ya es nullable).
-- Sin backfill: las filas existentes con role_title ya cargado no se tocan.
-- =============================================================================

ALTER TABLE "profiles"."practitioner_affiliations"
    ALTER COLUMN "role_title" DROP NOT NULL;
