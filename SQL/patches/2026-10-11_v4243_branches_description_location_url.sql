-- ============================================================================
-- SALUD · patch v4.2.6 (directory.branches · descripción y enlace de ubicación)
-- Fecha: 2026-10-11 · Idempotente (ADD COLUMN IF NOT EXISTS)
--
-- Cierra la parte de base de datos de P54 (carga masiva de sucursales) y del
-- alta pública de farmacia (P50): la sucursal declarada en el alta o subida en
-- lote trae un texto de descripción y el enlace de mapa tal como se pegó.
-- Ambas columnas son opcionales; sin backfill.
-- ============================================================================
ALTER TABLE directory.branches ADD COLUMN IF NOT EXISTS description text;
ALTER TABLE directory.branches ADD COLUMN IF NOT EXISTS location_url varchar(2000);
