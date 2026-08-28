-- ============================================================================
-- SALUD · patch v4.0.7 sobre la BD viva (mantra_redesa_health)
-- Fecha: 2026-07-25 · Idempotente (DROP NOT NULL es no-op si ya es nullable)
--
-- Contexto: `diagram_59_vector_rag.puml` declaraba `* approved_at` y `* retired_at`
-- (NOT NULL) en vector_rag.embedding_model_versions. Es incorrecto: una versión de
-- modelo de embeddings no nace aprobada ni retirada, y el NOT NULL obligaba a sembrar
-- timestamps sin significado solo para poder insertar. Corregido el `.puml` y
-- regenerado el DDL con `python salud-db/gen_nosql.py 59`.
--
-- En un rebuild desde cero el CREATE TABLE regenerado ya declara ambas columnas
-- nullable; este patch existe únicamente para la base ya aplicada y poblada.
-- gen_apply.py no escanea SQL/patches/ (solo directorios NN_schema), así que no
-- entra en apply_all.sql.
--
-- Después de aplicarlo:
--   1. python salud-db/load_seeds.py --skip-prod --refresh   (retired_at → null)
--   2. python salud-db/gen_entities.py 59                   (entidad desde el .puml; ver
--      ADR-0022 — `orm:gen` se retiro en v4.0.10)
-- ============================================================================

ALTER TABLE "vector_rag"."embedding_model_versions"
    ALTER COLUMN "approved_at" DROP NOT NULL,
    ALTER COLUMN "retired_at"  DROP NOT NULL;

-- El seed dejaba retired_at con un timestamp para satisfacer el NOT NULL; una vez
-- nullable, el valor correcto para una versión vigente es null. Solo alcanza a las
-- filas de seed (ids deterministas del paquete), nunca a datos de runtime.
UPDATE "vector_rag"."embedding_model_versions"
   SET "retired_at" = NULL
 WHERE "retired_at" IS NOT NULL;

-- ix_embedding_model_approval (approved_for_phi, retired_at) sigue siendo válido:
-- con retired_at nullable, "modelo vigente" pasa a ser `retired_at IS NULL`, que el
-- índice B-tree resuelve igual. No requiere recrearse.
