-- ============================================================================
-- SALUD · patch v4.1.3 (clinical.conditions.{expected_resolution_at,note_text} +
-- clinical.medication_requests.patient_instructions_text) sobre una BD viva
-- Fecha: 2026-08-20
-- Idempotente (ADD COLUMN IF NOT EXISTS; sin índices ni FKs nuevas)
--
-- Contexto: gen_ddl.py ya emite estas tres columnas en SQL/08_clinical/ desde
-- que el .puml del módulo 08 las declara, así que en un rebuild desde cero este
-- patch NO hace falta. Existe únicamente para una base ya aplicada y poblada.
-- gen_apply.py no escanea SQL/patches/ (solo directorios NN_schema), así que no
-- entra en apply_all.sql.
--
-- Qué cierra:
--   1. `expected_resolution_at` — el HUECO DE B-9. El PR #171 de la API metió
--      DOS columnas solo-ORM en `conditions.entity.ts`, y la promoción v4.1.2
--      cubrió una sola (`clinical_course_concept_id`). Con esta ausente, aplicar
--      el patch v4.1.2 NO alcanzaba: el ORM la proyecta en el SELECT y toda
--      lectura de `clinical.conditions` seguía fallando (`columna-ausente`).
--   2. `note_text` — hallazgos y justificación clínica del diagnóstico. El
--      formulario de AloVida ofrecía el campo y lo descartaba en silencio
--      porque no tenía destino en ninguna capa.
--   3. `patient_instructions_text` — indicaciones al paciente impresas en la
--      receta. El interino era concatenarlas dentro de `dose_text`
--      (' — Indicaciones: …'), contaminando la posología que farmacia lee para
--      dispensar. Con columna propia, `dose_text` vuelve a ser solo posología.
--
-- Este archivo es la salida de gen_ddl.py 08, no DDL escrito a mano: las tres
-- columnas se declaran en `Mantra Core Health Context/modules/
-- diagram_08_clinical.puml`. Ninguna es FK ni lleva índice (texto libre y un
-- timestamptz de pronóstico), así que no hay nota `SALUD/FK/` ni entrada de
-- <<INDEX_SET>>, y `orm:catalog` no interviene (el catálogo declara índices y
-- FKs, no columnas). Las tres son NULLABLE a propósito: una condición crónica
-- no tiene resolución esperada, y una nota o instrucción ausente es un dato
-- legítimo, no un olvido que convenga rellenar.
-- ============================================================================

ALTER TABLE "clinical"."conditions"
    ADD COLUMN IF NOT EXISTS "expected_resolution_at" timestamptz;

ALTER TABLE "clinical"."conditions"
    ADD COLUMN IF NOT EXISTS "note_text" text;

ALTER TABLE "clinical"."medication_requests"
    ADD COLUMN IF NOT EXISTS "patient_instructions_text" text;
