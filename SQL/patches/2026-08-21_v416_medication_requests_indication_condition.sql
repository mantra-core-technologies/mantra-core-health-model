-- ============================================================================
-- SALUD · patch v4.1.6 (clinical.medication_requests.indication_condition_id)
-- sobre una BD viva
-- Fecha: 2026-08-21
-- Idempotente (ADD COLUMN / CREATE INDEX IF NOT EXISTS · duplicate_object en la FK)
--
-- Contexto: gen_ddl.py ya emite esta columna en SQL/08_clinical/ desde que el
-- .puml del módulo 08 la declara, así que en un rebuild desde cero este patch
-- NO hace falta. Existe únicamente para una base ya aplicada y poblada.
-- gen_apply.py no escanea SQL/patches/ (solo directorios NN_schema), así que no
-- entra en apply_all.sql.
--
-- Qué agrega: el diagnóstico que motiva la prescripción — «para qué es» esta
-- receta. Hasta ahora la única relación entre receta y diagnóstico era compartir
-- el encuentro, que dice CUÁNDO se recetó pero no PARA QUÉ: un paciente con
-- cuatro condiciones activas atendido en una consulta deja cuatro candidatas y
-- ninguna respuesta. Tres lectores necesitan ese dato: el papel impreso (la
-- receta que dice su indicación), la validación farmacológica —dosis máxima y
-- contraindicación dependen de la indicación, no solo del fármaco— y la
-- renovación, que arrastra el motivo del original.
--
-- Nullable a propósito: hay prescripciones legítimas sin condición codificada
-- (sintomática, profilaxis, o receta cargada antes de codificar el diagnóstico).
-- Obligarla bloquearía el acto clínico para completar un dato administrativo, y
-- el modo de falla de eso es peor: se elige cualquier condición para poder
-- guardar, y el dato queda mintiendo.
--
-- Este archivo es la salida de gen_ddl.py 08, no DDL escrito a mano: la columna
-- se declara en `Mantra Core Health Context/modules/diagram_08_clinical.puml`
-- (entidad `medication_requests` + su bloque <<INDEX_SET>>) y el destino de la FK
-- en `SALUD/FK/FK clinical.medication_requests.indication_condition_id.md` — la
-- convención por nombre no lo resuelve, igual que las tres autorreferencias de
-- la receta (replaces / replaced_by / renewed_from).
-- ============================================================================

ALTER TABLE "clinical"."medication_requests"
    ADD COLUMN IF NOT EXISTS "indication_condition_id" uuid;

CREATE INDEX IF NOT EXISTS "ix_medication_requests_indication_condition_id"
    ON "clinical"."medication_requests" ("indication_condition_id");

DO $$ BEGIN
    ALTER TABLE "clinical"."medication_requests"
        ADD CONSTRAINT "fk_medication_requests_indication_condition_id" FOREIGN KEY ("indication_condition_id")
        REFERENCES "clinical"."conditions" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;
