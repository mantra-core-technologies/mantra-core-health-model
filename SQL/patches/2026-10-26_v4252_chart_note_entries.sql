-- ============================================================================
-- SALUD · patch v4.2.52 (chart · filas campo/valor de la nota médica) sobre BD viva
-- Fecha: 2026-10-26 · pendiente P39 (carril C1 «nota médica clave/valor»)
-- Idempotente (ADD COLUMN IF NOT EXISTS). Una sola sentencia, sin backfill.
--
-- Contexto: gen_ddl.py ya emite esta columna en SQL/15_chart/02_tables.sql desde
-- que diagram_15_chart.puml la declara, así que en un rebuild desde cero este
-- patch NO hace falta. Existe para una base ya aplicada y poblada.
-- gen_apply.py no escanea SQL/patches/: no entra en apply_all.sql.
-- La sentencia se copió de la columna generada, no se escribió a mano.
--
-- QUÉ CIERRA. La nota médica del encuentro (ADR-0016 del frontend) es una tabla
-- de filas `{ label, value }` —«Presión arterial: 120/80»— más el texto libre
-- de siempre. Las filas viajan como un arreglo JSON en la VERSIÓN de la nota
-- (`chart.clinical_note_versions`), no en una tabla hija:
--   * la versión es inmutable (<<IMMUTABLE>>): corregir crea otra versión con
--     sus propias filas, igual que los cinco textos SOAP que ya viven ahí;
--   * las filas no se consultan ni se indexan por separado, sólo se leen junto
--     con la versión; una tabla hija agregaría joins y un orden que mantener.
-- La forma y los límites (cantidad, longitud, sin HTML) los valida la API en el
-- borde (CreateNoteDto / AddVersionDto); la base guarda lo validado.
--
-- POR QUÉ NO HAY BACKFILL. Ninguna versión existente tiene filas: las notas
-- previas son SOAP puro y siguen leyéndose igual (`entries_json` NULL).
--
-- DELTAS ESPERADOS sobre la base viva:
--   columnas de chart.clinical_note_versions  19 → 20
--   tablas ±0 · FKs ±0 · índices ±0
-- ============================================================================

BEGIN;

ALTER TABLE "chart"."clinical_note_versions"
    ADD COLUMN IF NOT EXISTS "entries_json" jsonb;

COMMIT;
