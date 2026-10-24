-- =============================================================================
-- Patch v4249 · common.identifiers — la unicidad por tipo de usuario es sólo de
-- la cédula (C-10 / MD-01). Corrige v4248.
--
-- Por qué: v4248 etiquetó con el tipo de usuario TODAS las filas del titular
-- (también el NIT de facturación) y su índice único no filtraba por tipo de
-- documento. Dos pacientes que facturan al mismo NIT son legítimos: en un entorno
-- con esos datos, la medición de v4248 fallaba o el índice los habría chocado.
-- Además, una persona con perfil de médico y de paciente quedaba como paciente,
-- fuera de la unicidad de médicos: ahora gana médico (rol con matrícula).
--
-- Idempotente: se puede correr dos veces; el índice sólo se rehace si su
-- definición no filtra todavía por la cédula.
-- =============================================================================
BEGIN;

-- 1) El tipo de usuario sólo cuelga de la cédula.
UPDATE common.identifiers
   SET owner_kind_concept_id = NULL
 WHERE owner_kind_concept_id IS NOT NULL
   AND type_concept_id <> '595e7a3d-ba37-5014-9a72-635363b94864';

-- 2) Persona con los dos perfiles: su cédula queda como de médico.
DO $$
DECLARE n integer;
BEGIN
  IF EXISTS (SELECT 1 FROM terminology.catalog_concepts WHERE id = '64e1ccaf-e90d-5255-8af0-9d8362817ea9') THEN
    UPDATE common.identifiers i
       SET owner_kind_concept_id = '64e1ccaf-e90d-5255-8af0-9d8362817ea9'
     WHERE i.type_concept_id = '595e7a3d-ba37-5014-9a72-635363b94864'
       AND i.owner_kind_concept_id = 'ff9ab690-d4ae-5d5e-9784-76d8e9e1ff37'
       AND EXISTS (SELECT 1 FROM profiles.health_practitioner_profiles hp WHERE hp.profile_id = i.owner_id);
    GET DIAGNOSTICS n = ROW_COUNT;
    RAISE NOTICE 'v4249: % cédula(s) de personas con los dos perfiles pasan a médico', n;
  END IF;
END $$;

-- 3) El índice único, sólo para la cédula.
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM pg_indexes
              WHERE schemaname = 'common' AND indexname = 'ux_identifiers_document_owner_kind'
                AND indexdef NOT LIKE '%595e7a3d-ba37-5014-9a72-635363b94864%') THEN
    DROP INDEX common.ux_identifiers_document_owner_kind;
    RAISE NOTICE 'v4249: índice ux_identifiers_document_owner_kind rehecho sólo para la cédula';
  END IF;
END $$;
CREATE UNIQUE INDEX IF NOT EXISTS "ux_identifiers_document_owner_kind" ON "common"."identifiers"
  ("type_concept_id", "value", "issuer_administrative_area_concept_id", "owner_kind_concept_id")
  WHERE state_concept_id = '38a1d301-f40d-5b17-a695-5e6d605f8b19'
    AND type_concept_id = '595e7a3d-ba37-5014-9a72-635363b94864'
    AND owner_kind_concept_id IN ('ff9ab690-d4ae-5d5e-9784-76d8e9e1ff37', '64e1ccaf-e90d-5255-8af0-9d8362817ea9');

COMMIT;
