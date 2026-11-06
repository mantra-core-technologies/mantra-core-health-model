-- ============================================================================
-- SALUD · patch v4.2.95 · red clínica del paciente, franja 1: vínculos (módulos 08 clinical y 18 clinical_ext) sobre BD viva
-- Fecha: 2026-11-06
-- Idempotente (ADD COLUMN IF NOT EXISTS / CREATE INDEX IF NOT EXISTS / FK bajo duplicate_object).
-- UNA sola transacción, re-ejecutable. SIN backfill.
--
-- Contexto: el «Recorrido» del expediente pasa a ser una red de nodos por episodio (citas,
-- reconsultas, derivaciones, diagnósticos presuntivo/confirmado/descartado, estudios, medicación).
-- La mayoría de las aristas ya existen (referrals.source_encounter_id, conditions.encounter_id,
-- service_requests.encounter_id, medication_requests.indication_condition_id y
-- replaced_by_request_id…). Este parche agrega SOLO las tres que faltan.
--
-- Contexto de generación: gen_ddl.py ya emite estas columnas, FK e índices en SQL/08_clinical/ y
-- SQL/18_clinical_ext/ desde que diagram_08_clinical.puml y diagram_18_clinical_ext.puml los
-- declaran (las FK salen de aristas etiquetadas, sin nota del vault), así que en un rebuild desde
-- cero este parche es no-op salvo por los COMMENT ON COLUMN, que el generador no expresa.
-- gen_apply.py no escanea SQL/patches/: no entra en apply_all.sql. Las sentencias ALTER/CREATE/FK
-- se copiaron de los archivos generados, no se escribieron a mano.
--
-- QUÉ AGREGA. Tres columnas uuid NULL, cada una con su FK y su índice:
--   clinical.service_requests.reason_condition_id     → clinical.conditions(id)
--       el estudio se pidió para confirmar, descartar o seguir ESE diagnóstico.
--   clinical_ext.referrals.target_encounter_id         → clinical.encounters(id)
--       la atención en la que el destino recibió al paciente derivado.
--   clinical.conditions.replaced_by_condition_id       → clinical.conditions(id)
--       el diagnóstico descartado fue reemplazado por este (diferencial resuelto).
--
-- POR QUÉ NULLABLE Y SIN BACKFILL. Las filas anteriores no declararon estos vínculos y
-- reconstruirlos sería fabricar un dato clínico. Hay órdenes legítimas sin diagnóstico (control,
-- tamizaje), derivaciones sin atención de destino (pendiente, rechazada, externa) y descartes sin
-- reemplazo. Sin ON DELETE: el registro clínico no se borra en cascada.
--
-- LO QUE ESTE PARCHE NO HACE (lo valida la API con 422 y código propio, no la base):
--   - que el registro vinculado sea del MISMO paciente;
--   - que replaced_by_condition_id sólo aparezca en un diagnóstico REFUTED y no se apunte a sí mismo;
--   - que target_encounter_id lo escriba sólo el tenant destino de la derivación.
--   La autorización es la misma que ya protege escribir el recurso padre.
--
-- RLS: ninguna tabla nueva. Las tres tablas ya tienen su aislamiento; una columna nueva lo hereda.
--
-- DELTAS ESPERADOS sobre la base viva:
--   columnas +3 (1 en service_requests, 1 en referrals, 1 en conditions) · FKs +3 · índices +3
--   comentarios de columna +3 · tablas +0 · constraints CHECK +0
--
-- Reversible:
--   ALTER TABLE "clinical"."service_requests" DROP COLUMN IF EXISTS "reason_condition_id";
--   ALTER TABLE "clinical_ext"."referrals"    DROP COLUMN IF EXISTS "target_encounter_id";
--   ALTER TABLE "clinical"."conditions"       DROP COLUMN IF EXISTS "replaced_by_condition_id";
--   (DROP COLUMN se lleva su FK y su índice.)
-- ============================================================================

BEGIN;

-- ---------------------------------------------------------------- A. columnas
ALTER TABLE "clinical"."service_requests"
    ADD COLUMN IF NOT EXISTS "reason_condition_id" uuid;

ALTER TABLE "clinical_ext"."referrals"
    ADD COLUMN IF NOT EXISTS "target_encounter_id" uuid;

ALTER TABLE "clinical"."conditions"
    ADD COLUMN IF NOT EXISTS "replaced_by_condition_id" uuid;

-- ---------------------------------------------------------------------- B. FK
-- intra-schema (SQL/08_clinical/03_fk_intra.sql)
DO $$ BEGIN
    ALTER TABLE "clinical"."conditions"
        ADD CONSTRAINT "fk_conditions_replaced_by_condition_id" FOREIGN KEY ("replaced_by_condition_id")
        REFERENCES "clinical"."conditions" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "clinical"."service_requests"
        ADD CONSTRAINT "fk_service_requests_reason_condition_id" FOREIGN KEY ("reason_condition_id")
        REFERENCES "clinical"."conditions" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- entre schemas (SQL/18_clinical_ext/90_fk_deferred.sql)
-- destino: clinical.encounters (requiere schema clinical)
DO $$ BEGIN
    ALTER TABLE "clinical_ext"."referrals"
        ADD CONSTRAINT "fk_referrals_target_encounter_id" FOREIGN KEY ("target_encounter_id")
        REFERENCES "clinical"."encounters" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- ------------------------------------------------------------------ C. índices
CREATE INDEX IF NOT EXISTS "ix_conditions_replaced_by_condition_id" ON "clinical"."conditions" ("replaced_by_condition_id");

CREATE INDEX IF NOT EXISTS "ix_service_requests_reason_condition_id" ON "clinical"."service_requests" ("reason_condition_id");

CREATE INDEX IF NOT EXISTS "ix_referrals_target_encounter_id" ON "clinical_ext"."referrals" ("target_encounter_id");

-- ------------------------------------------------------ D. significado clínico
COMMENT ON COLUMN "clinical"."service_requests"."reason_condition_id" IS
    'Diagnóstico (clinical.conditions) para el que se pidió el estudio: confirmarlo, descartarlo o seguir su evolución. Opcional: hay órdenes sin diagnóstico registrado (control, tamizaje). Debe ser del mismo paciente (lo valida la API). API: reasonConditionId.';

COMMENT ON COLUMN "clinical_ext"."referrals"."target_encounter_id" IS
    'Atención (clinical.encounters) en la que el destino de la derivación recibió al paciente; cierra el par con source_encounter_id. Vacía mientras la derivación está pendiente, si fue rechazada o si el destino es externo. Sólo la escribe el tenant destino al aceptar o registrar la llegada; debe ser del mismo paciente (lo valida la API). API: targetEncounterId.';

COMMENT ON COLUMN "clinical"."conditions"."replaced_by_condition_id" IS
    'En un diagnóstico descartado (verificación REFUTED), el diagnóstico que lo reemplazó: el diferencial resuelto. Distinto de la propia fila y del mismo paciente (lo valida la API). API: replacedByConditionId.';

COMMIT;
