-- ============================================================================
-- SALUD · patch v4.2.29 (profiles · la ciudad del título) sobre BD viva
-- Fecha: 2026-09-26 · carril M7 (cierre del modelo) · cierra ID-10 (anexo A)
-- Idempotente (ADD COLUMN IF NOT EXISTS). UNA sola pasada. Sin backfill.
--
-- Contexto: gen_ddl.py ya emite esta columna en SQL/05_profiles/ desde que el
-- .puml la declara, así que en un rebuild desde cero este patch NO hace falta.
-- Existe únicamente para una base ya aplicada y poblada. gen_apply.py no
-- escanea SQL/patches/, así que no entra en apply_all.sql.
--
-- QUÉ CIERRA. ID-10: el formulario de alta del médico pregunta universidad,
-- país y CIUDAD del título, y descarta la ciudad porque
-- `profiles.professional_credentials` sólo tenía `issuing_institution_text` y
-- `issuing_country_concept_id`. Mandar la ciudad dentro de otro campo habría
-- sido inventar un dato; sacarla del formulario contradice el pedido del
-- dueño (D-BR08-1 del carril M7). Esta columna es el lugar que faltaba.
--
-- POR QUÉ ES TEXTO LIBRE Y NULLABLE. La ciudad del título no es un catálogo:
-- se declara junto con la universidad (ya texto libre) y puede estar fuera de
-- Bolivia, donde no existe el padrón de municipios que sí gobierna
-- `common.addresses`. Es opcional porque el país y la institución también lo
-- son: el título se declara y se verifica después.
--
-- POR QUÉ NO HAY BACKFILL. Ninguna fila viva tiene este dato: recién se agrega
-- dónde guardarlo.
--
-- DELTAS ESPERADOS sobre la base viva:
--   columnas de profiles.professional_credentials  +1 (issuing_city_text)
--   FKs ±0 · índices ±0 · tablas ±0
-- ============================================================================

BEGIN;

ALTER TABLE "profiles"."professional_credentials"
    ADD COLUMN IF NOT EXISTS "issuing_city_text" varchar;

DO $$
DECLARE
    n_columnas integer;
BEGIN
    SELECT count(*) INTO n_columnas
    FROM information_schema.columns
    WHERE table_schema = 'profiles'
      AND table_name = 'professional_credentials'
      AND column_name = 'issuing_city_text'
      AND data_type = 'character varying'
      AND is_nullable = 'YES';

    IF n_columnas <> 1 THEN
        RAISE EXCEPTION
            'v4.2.29 incompleto: columnas=% (esperado 1)', n_columnas;
    END IF;

    RAISE NOTICE 'v4.2.29 aplicado: 1 columna (issuing_city_text).';
END $$;

COMMIT;
