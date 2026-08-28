-- ============================================================================
-- SALUD · patch v4.1.8 (diagnostic_units.diagnostic_units · unicidad compuesta)
-- sobre una BD viva
-- Fecha: 2026-08-23
-- Idempotente (DROP INDEX IF EXISTS · CREATE UNIQUE INDEX IF NOT EXISTS)
--
-- Contexto: gen_ddl.py ya emite la clave compuesta en
-- SQL/23_diagnostic_units/04_indexes.sql desde que el .puml del módulo 23 la
-- declara, así que en un rebuild desde cero este patch NO hace falta. Existe
-- únicamente para una base ya aplicada y poblada. gen_apply.py no escanea
-- SQL/patches/ (solo directorios NN_schema), así que no entra en apply_all.sql.
--
-- QUÉ CAMBIA — dos claves únicas sueltas pasan a ser una compuesta:
--
--   uq_diagnostic_units_tenant_id  (tenant_id)  ← una sola unidad por organización
--   uq_diagnostic_units_code       (code)       ← el código, único en TODA la plataforma
--   ────────────────────────────────────────────────────────────────────────────
--   uq_diagnostic_units_tenant_id_code (tenant_id, code)
--
-- Por qué las dos viejas estaban mal. La primera decía que una organización sólo
-- puede tener una unidad de diagnóstico, y un hospital tiene laboratorio, imagen
-- y patología a la vez. La segunda decía que el código es único en toda la
-- plataforma, y dos organizaciones distintas pueden llamar «LAB» a la suya sin
-- que eso sea un conflicto de nadie.
--
-- Lo destapó F-15 en runtime: el alta de unidades resuelve por clave natural
-- (tenant + código) y Postgres respondía
--   there is no unique or exclusion constraint matching the ON CONFLICT specification
-- porque ninguna constraint cubría ese par. La corrección se había aplicado sólo
-- al catálogo del ORM —un archivo generado— y la siguiente corrida de
-- `yarn orm:catalog` la revirtió leyendo la bóveda, que seguía declarando la
-- regla vieja. Ahora nace donde corresponde: nota de bóveda → .puml → gen_ddl.py
-- → este patch → catálogo del ORM.
--
-- MIGRACIÓN SEGURA, sin ventana de riesgo: la regla nueva es estrictamente MENOS
-- restrictiva que las dos que reemplaza. Cualquier fila que satisfacía
-- (tenant_id único) y (code único global) satisface también (tenant_id, code)
-- único, así que la creación del índice no puede fallar por datos existentes ni
-- hace falta deduplicar nada antes.
--
-- ORDEN: primero se crea la nueva y después se borran las viejas. Al revés
-- dejaría una ventana —entre el DROP y el CREATE— en la que dos altas
-- concurrentes podrían insertar el mismo (tenant_id, code).
-- ============================================================================

BEGIN;

CREATE UNIQUE INDEX IF NOT EXISTS "uq_diagnostic_units_tenant_id_code"
  ON "diagnostic_units"."diagnostic_units" ("tenant_id", "code");

DROP INDEX IF EXISTS "diagnostic_units"."uq_diagnostic_units_tenant_id";
DROP INDEX IF EXISTS "diagnostic_units"."uq_diagnostic_units_code";

COMMIT;
