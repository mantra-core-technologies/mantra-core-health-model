-- ============================================================================
-- SALUD · patch v4.1.2 (clinical.conditions.clinical_course_concept_id) sobre
-- una BD viva
-- Fecha: 2026-08-20
-- Idempotente (ADD COLUMN / CREATE INDEX IF NOT EXISTS · duplicate_object en la FK)
--
-- Contexto: gen_ddl.py ya emite esta columna en SQL/08_clinical/ desde que el
-- .puml del módulo 08 la declara, así que en un rebuild desde cero este patch
-- NO hace falta. Existe únicamente para una base ya aplicada y poblada.
-- gen_apply.py no escanea SQL/patches/ (solo directorios NN_schema), así que no
-- entra en apply_all.sql.
--
-- Qué cierra: la deriva que dejó el PR #171 de la API (rotulado «Patch v4.0.8 —
-- estado clínico y cronicidad», rótulo que además chocaba con el v4.0.8 real, la
-- promoción REDESA del 2026-07-30). Ese PR agregó `clinicalCourseConceptId` a
-- `clinical/entities/conditions.entity.ts` y dos value sets dinámicos
-- (`condition-clinical-status`, `condition-clinical-course`) al
-- DYNAMIC_ENUM_CATALOG, pero la columna no existía en ninguna de las otras tres
-- capas: ni en el .puml, ni en SQL/, ni en la bóveda. Contra una base
-- reconstruida el ORM proyecta una columna que Postgres no tiene, y toda lectura
-- de `clinical.conditions` falla. Es la categoría `columna-ausente` del
-- verificador de fidelidad de runtime.
--
-- Este archivo es la salida de gen_ddl.py 08, no DDL escrito a mano: la columna
-- se declara en `Mantra Core Health Context/modules/diagram_08_clinical.puml`
-- (entidad `conditions` + su bloque <<INDEX_SET>>) y el destino de la FK en
-- `SALUD/FK/FK clinical.conditions.clinical_course_concept_id.md`.
--
-- Decisión de modelo que este DDL refleja: el curso clínico es un EJE DISTINTO
-- del estado clínico —`clinical_status_concept_id` dice en qué punto del ciclo
-- está la condición; `clinical_course_concept_id` dice si es aguda o crónica— y
-- gobierna qué transiciones son válidas (una condición crónica no pasa a
-- resuelta). Es nullable a propósito: no declarar el curso es un dato legítimo
-- (el catálogo trae `COND_COURSE_UNKNOWN` para eso), no un olvido que convenga
-- rellenar con un valor por omisión. Como todo valor de terminología, viaja por
-- `*_concept_id` contra `terminology.catalog_concepts`, nunca por un enum nativo.
-- ============================================================================

ALTER TABLE "clinical"."conditions"
    ADD COLUMN IF NOT EXISTS "clinical_course_concept_id" uuid;

CREATE INDEX IF NOT EXISTS "ix_conditions_clinical_course_concept_id"
    ON "clinical"."conditions" ("clinical_course_concept_id");

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "clinical"."conditions"
        ADD CONSTRAINT "fk_conditions_clinical_course_concept_id" FOREIGN KEY ("clinical_course_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;
