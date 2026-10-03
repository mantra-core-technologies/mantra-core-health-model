BEGIN;

-- 1 · Las definiciones de enum del paquete apuntan a value sets que no se
-- insertaron: ya existia uno con el mismo internal_code, sembrado por la cadena
-- de la API, bajo otro id. Se reapuntan al que si existe.
UPDATE system_context.dynamic_enum_definitions d
SET value_set_id = vs.id, updated_at = now()
FROM terminology.value_sets vs
WHERE vs.internal_code = d.code
  AND d.value_set_id IN ('694953a8-b9c0-5f24-a72b-eb497c3f99df',
                         'ab7a4ca8-9927-5879-9677-927f0a7d7b16');

-- 2 · Y sus versiones apuntan a la version huerfana del value set. Se reapuntan
-- a la version 1.0.0 real del conjunto que corresponde.
UPDATE system_context.dynamic_enum_versions
SET value_set_version_id = 'ca68e5ec-a550-5fd0-9ed4-e2fe05f4abb7'
WHERE value_set_version_id = '7d692ddb-b6d6-558f-ade1-9b96b6b58489';

UPDATE system_context.dynamic_enum_versions
SET value_set_version_id = '2cbe325a-8962-5fbf-8bdf-bb2d18819491'
WHERE value_set_version_id = '2b1eb594-b2aa-51e2-aa26-16477298298a';

-- 3 · Con nadie que las referencie, las versiones duplicadas del paquete se van:
-- cuelgan de value sets inexistentes, y reapuntarlas dejaria dos versiones
-- marcadas is_default sobre el mismo conjunto.
DELETE FROM terminology.value_set_members
WHERE value_set_version_id IN ('7d692ddb-b6d6-558f-ade1-9b96b6b58489',
                               '2b1eb594-b2aa-51e2-aa26-16477298298a');

DELETE FROM terminology.value_set_versions
WHERE id IN ('7d692ddb-b6d6-558f-ade1-9b96b6b58489',
             '2b1eb594-b2aa-51e2-aa26-16477298298a');

-- Los catálogos añadidos después del paquete original pueden producir la misma
-- colisión. Reconciliarlos por código y versión evita otra lista de UUIDs fijos.
-- Sólo se descartan los miembros de la versión huérfana si ambos conjuntos
-- contienen exactamente los mismos códigos de concepto.
CREATE TEMP TABLE seed_orphan_value_set_map ON COMMIT DROP AS
SELECT DISTINCT d.value_set_id AS old_id, vs.id AS new_id,
       ov.id AS old_version_id, cv.id AS new_version_id
FROM system_context.dynamic_enum_definitions d
JOIN terminology.value_set_versions ov ON ov.value_set_id = d.value_set_id
JOIN terminology.value_sets vs ON vs.internal_code = d.code
JOIN terminology.value_set_versions cv ON cv.value_set_id = vs.id
  AND cv.is_default = true AND cv.version = ov.version
WHERE d.value_set_id IS NOT NULL
  AND NOT EXISTS (SELECT 1 FROM terminology.value_sets old WHERE old.id = d.value_set_id);

DO $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM system_context.dynamic_enum_definitions d
    WHERE d.value_set_id IS NOT NULL
      AND NOT EXISTS (SELECT 1 FROM terminology.value_sets vs WHERE vs.id = d.value_set_id)
      AND NOT EXISTS (SELECT 1 FROM seed_orphan_value_set_map m WHERE m.old_id = d.value_set_id)
  ) THEN
    RAISE EXCEPTION 'Hay un value set huérfano sin conjunto y versión canónicos';
  END IF;

  IF EXISTS (
    SELECT 1 FROM seed_orphan_value_set_map m
    WHERE EXISTS (
      SELECT 1 FROM terminology.value_set_members om
      JOIN terminology.catalog_concepts oc ON oc.id = om.concept_id
      WHERE om.value_set_version_id = m.old_version_id
        AND NOT EXISTS (
          SELECT 1 FROM terminology.value_set_members cm
          JOIN terminology.catalog_concepts cc ON cc.id = cm.concept_id
          WHERE cm.value_set_version_id = m.new_version_id AND cc.code = oc.code
        )
    ) OR EXISTS (
      SELECT 1 FROM terminology.value_set_members cm
      JOIN terminology.catalog_concepts cc ON cc.id = cm.concept_id
      WHERE cm.value_set_version_id = m.new_version_id
        AND NOT EXISTS (
          SELECT 1 FROM terminology.value_set_members om
          JOIN terminology.catalog_concepts oc ON oc.id = om.concept_id
          WHERE om.value_set_version_id = m.old_version_id AND oc.code = cc.code
        )
    )
  ) THEN
    RAISE EXCEPTION 'Los miembros del value set huérfano y del canónico difieren';
  END IF;
END $$;

UPDATE system_context.dynamic_enum_definitions d
SET value_set_id = m.new_id, updated_at = now()
FROM seed_orphan_value_set_map m
WHERE d.value_set_id = m.old_id;

UPDATE system_context.dynamic_enum_versions ev
SET value_set_version_id = m.new_version_id
FROM seed_orphan_value_set_map m
WHERE ev.value_set_version_id = m.old_version_id;

DELETE FROM terminology.value_set_members vm
USING seed_orphan_value_set_map m
WHERE vm.value_set_version_id = m.old_version_id;

DELETE FROM terminology.value_set_versions vv
USING seed_orphan_value_set_map m
WHERE vv.id = m.old_version_id;

DO $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM terminology.value_set_versions v
    WHERE NOT EXISTS (SELECT 1 FROM terminology.value_sets vs WHERE vs.id = v.value_set_id)
  ) THEN
    RAISE EXCEPTION 'Quedaron versiones de value set huérfanas';
  END IF;
END $$;

COMMIT;

\echo == verificacion: huerfanas restantes ==
SELECT
  (SELECT count(*) FROM system_context.dynamic_enum_definitions d
     LEFT JOIN terminology.value_sets vs ON vs.id = d.value_set_id
     WHERE d.value_set_id IS NOT NULL AND vs.id IS NULL) AS enums_huerfanos,
  (SELECT count(*) FROM terminology.value_set_versions v
     LEFT JOIN terminology.value_sets vs ON vs.id = v.value_set_id
     WHERE vs.id IS NULL) AS versiones_huerfanas,
  (SELECT count(*) FROM terminology.value_set_members m
     LEFT JOIN terminology.value_set_versions v ON v.id = m.value_set_version_id
     WHERE v.id IS NULL) AS miembros_huerfanos,
  (SELECT count(*) FROM system_context.dynamic_enum_versions ev
     LEFT JOIN terminology.value_set_versions v ON v.id = ev.value_set_version_id
     WHERE ev.value_set_version_id IS NOT NULL AND v.id IS NULL) AS enum_versiones_huerfanas;
