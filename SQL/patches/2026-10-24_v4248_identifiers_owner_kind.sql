-- ============================================================================
-- SALUD · patch v4.2.48 (common · unicidad del documento por tipo de usuario, C-10 / MD-01)
-- Fecha: 2026-10-24 · correcciones del propietario del 2026-10-23 (MD-01, Q-13)
-- Idempotente (IF NOT EXISTS / duplicate_object / UPDATE … WHERE … IS NULL).
--
-- Contexto: gen_ddl.py ya emite la columna, sus índices y su FK en SQL/02_common/
-- desde que diagram_02_common.puml la declara; en un rebuild desde cero este patch
-- sólo hace falta para el relleno (paso 3). Las sentencias DDL se copiaron de los
-- archivos generados.
--
-- QUÉ CIERRA. La unicidad del CI es por (tipo, número, departamento emisor, tipo de
-- usuario): dos médicos no pueden registrarse con el mismo CI y terminación; un
-- médico que además es paciente sí (cada alta crea su persona: la fusión es
-- identidad maestra, no del formulario). Los representantes de organización quedan
-- fuera del índice: una persona puede representar a varias empresas.
--
-- ORDEN DE APLICACIÓN. Los conceptos common:document-holder-kind:* los siembra la API
-- al arrancar. 1) aplicar ANTES de desplegar la API (columna, FK, índices, medición);
-- 2) re-aplicar DESPUÉS del primer arranque: el relleno sólo corre si los conceptos
-- existen, y el índice único se crea recién entonces.
--
-- Conceptos (deterministas, ver concepts.ts):
--   common:document-holder-kind:patient                  ff9ab690-d4ae-5d5e-9784-76d8e9e1ff37
--   common:document-holder-kind:practitioner             64e1ccaf-e90d-5255-8af0-9d8362817ea9
--   common:document-holder-kind:organization-representative bacae3e4-bd70-524f-9b0b-69bbbfddb583
--   state:active                                          38a1d301-f40d-5b17-a695-5e6d605f8b19
-- ============================================================================
BEGIN;

-- 1) 02_tables.sql · 04_indexes.sql · 90_fk_deferred.sql
ALTER TABLE "common"."identifiers" ADD COLUMN IF NOT EXISTS "owner_kind_concept_id" uuid;
CREATE INDEX IF NOT EXISTS "ix_identifiers_owner_kind_concept_id" ON "common"."identifiers" ("owner_kind_concept_id");
DO $$ BEGIN
    ALTER TABLE "common"."identifiers"
        ADD CONSTRAINT "fk_identifiers_owner_kind_concept_id" FOREIGN KEY ("owner_kind_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- 2) Relleno de las filas existentes, sólo si la API ya sembró los conceptos.
--    Médico: la persona tiene perfil profesional y no de paciente. Paciente: tiene
--    perfil de paciente. Lo demás (contactos, representantes previos) queda NULL.
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM terminology.catalog_concepts WHERE id = '64e1ccaf-e90d-5255-8af0-9d8362817ea9')
     AND EXISTS (SELECT 1 FROM terminology.catalog_concepts WHERE id = 'ff9ab690-d4ae-5d5e-9784-76d8e9e1ff37') THEN
    UPDATE common.identifiers i
       SET owner_kind_concept_id = '64e1ccaf-e90d-5255-8af0-9d8362817ea9'
     WHERE i.owner_kind_concept_id IS NULL
       AND EXISTS (SELECT 1 FROM profiles.health_practitioner_profiles hp WHERE hp.profile_id = i.owner_id)
       AND NOT EXISTS (SELECT 1 FROM profiles.patient_profiles pp WHERE pp.profile_id = i.owner_id);
    UPDATE common.identifiers i
       SET owner_kind_concept_id = 'ff9ab690-d4ae-5d5e-9784-76d8e9e1ff37'
     WHERE i.owner_kind_concept_id IS NULL
       AND EXISTS (SELECT 1 FROM profiles.patient_profiles pp WHERE pp.profile_id = i.owner_id);
    RAISE NOTICE 'v4248 relleno: % médico · % paciente · % sin tipo',
      (SELECT count(*) FROM common.identifiers WHERE owner_kind_concept_id = '64e1ccaf-e90d-5255-8af0-9d8362817ea9'),
      (SELECT count(*) FROM common.identifiers WHERE owner_kind_concept_id = 'ff9ab690-d4ae-5d5e-9784-76d8e9e1ff37'),
      (SELECT count(*) FROM common.identifiers WHERE owner_kind_concept_id IS NULL);
  ELSE
    RAISE NOTICE 'v4248: conceptos todavía no sembrados; re-aplicar después del primer arranque de la API';
  END IF;
END $$;

-- 3) Medición de duplicados ANTES del índice único. Si hay, el patch falla con la
--    lista (tipo, valor enmascarado, departamento, tipo de usuario, cuántos): se
--    resuelve a mano en identidad maestra, nunca borrando en silencio.
DO $$
DECLARE dup record; total int := 0;
BEGIN
  FOR dup IN
    SELECT type_concept_id, left(value, 2) || '***' AS valor, issuer_administrative_area_concept_id AS depto,
           owner_kind_concept_id AS tipo, count(*) AS n
      FROM common.identifiers
     WHERE state_concept_id = '38a1d301-f40d-5b17-a695-5e6d605f8b19'
       AND owner_kind_concept_id IN ('ff9ab690-d4ae-5d5e-9784-76d8e9e1ff37', '64e1ccaf-e90d-5255-8af0-9d8362817ea9')
     GROUP BY type_concept_id, value, issuer_administrative_area_concept_id, owner_kind_concept_id
    HAVING count(*) > 1
  LOOP
    total := total + 1;
    RAISE NOTICE 'v4248 duplicado: tipo % · valor % · depto % · usuario % · % filas', dup.type_concept_id, dup.valor, dup.depto, dup.tipo, dup.n;
  END LOOP;
  RAISE NOTICE 'v4248 medición: % documentos duplicados por tipo de usuario', total;
  IF total > 0 THEN
    RAISE EXCEPTION 'v4248: hay % documentos duplicados; resolverlos antes de crear ux_identifiers_document_owner_kind', total;
  END IF;
END $$;

-- 4) 04_indexes.sql
CREATE UNIQUE INDEX IF NOT EXISTS "ux_identifiers_document_owner_kind" ON "common"."identifiers" ("type_concept_id", "value", "issuer_administrative_area_concept_id", "owner_kind_concept_id") WHERE state_concept_id = '38a1d301-f40d-5b17-a695-5e6d605f8b19' AND owner_kind_concept_id IN ('ff9ab690-d4ae-5d5e-9784-76d8e9e1ff37', '64e1ccaf-e90d-5255-8af0-9d8362817ea9');

COMMIT;
