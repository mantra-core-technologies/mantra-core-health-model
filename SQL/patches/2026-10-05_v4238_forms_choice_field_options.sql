-- ============================================================================
-- SALUD · patch v4.2.38 (forms) sobre BD viva
-- Fecha: 2026-10-05
-- Idempotente (ADD COLUMN IF NOT EXISTS). UNA sola pasada. SIN backfill.
--
-- QUÉ ENTRA. Opciones propias de un campo de elección (`data_type = 'code'`
-- sin `value_set_id`), escritas por quien arma el formulario:
--   forms.dynamic_field_definitions.options      jsonb   lista ordenada de opciones
--   forms.dynamic_field_definitions.multiple     boolean admite varias respuestas
--   forms.dynamic_field_definitions.allow_other  boolean ofrece «Otro» con texto libre
--   forms.dynamic_field_definitions.description  text    ayuda bajo la pregunta
--   forms.field_values.value_code                text    la opción elegida, cuando el
--                                                        campo no tiene value_set_id
-- `value_code` va aparte de `value_concept_id` porque éste es uuid con FK a
-- terminology y no puede guardar una opción tecleada a mano («Ex fumador»).
--
-- POR QUÉ NULLABLE Y SIN BACKFILL. Los campos existentes siguen viviendo de su
-- `value_set_id`; sólo los nuevos campos con opciones propias las llenan.
--
-- RELACIÓN CON D-D (docs/progress/DECISIONS.md). Es la opción (c) de esa
-- propuesta; queda pendiente promoverla o reemplazarla por (a).
--
-- MODELO. Las cinco columnas tienen que declararse también en el `.puml` de
-- forms para un rebuild desde cero.
--
-- DELTAS ESPERADOS: +4 columnas en dynamic_field_definitions, +1 en field_values.
-- ============================================================================

BEGIN;

ALTER TABLE "forms"."dynamic_field_definitions"
    ADD COLUMN IF NOT EXISTS "options" jsonb NULL,
    ADD COLUMN IF NOT EXISTS "multiple" boolean NULL,
    ADD COLUMN IF NOT EXISTS "allow_other" boolean NULL,
    ADD COLUMN IF NOT EXISTS "description" text NULL;

ALTER TABLE "forms"."field_values"
    ADD COLUMN IF NOT EXISTS "value_code" text NULL;

COMMIT;
