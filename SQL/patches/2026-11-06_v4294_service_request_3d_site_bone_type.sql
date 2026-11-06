-- ============================================================================
-- SALUD · patch v4.2.94 (clinical · marca 3D del cuerpo y tipo de hueso en la orden de estudio)
-- sobre BD viva. Fecha: 2026-11-06
-- Idempotente (ADD COLUMN / CREATE INDEX IF NOT EXISTS, FK bajo guarda, CHECK con
-- DROP IF EXISTS + ADD, semillas con ON CONFLICT / NOT EXISTS). UNA sola pasada. SIN backfill.
--
-- Contexto. v4.2.82 ya dio a clinical.service_requests la muestra (laboratorio) y, para imagen,
-- la modalidad, la parte del cuerpo, la lateralidad y el contraste. Falta lo que devuelve el
-- visor 3D del cuerpo al marcar la parte y el dato anatómico del hueso:
--   body_structure_uberon  varchar(64)  id de estructura UBERON elegido en el 3D ("UBERON:0002495").
--   body_mesh_id           varchar(64)  id de malla FMA/BP del GLB que se tocó.
--   bone_type_concept_id   uuid         tipo de hueso (value set `bone-type`): largo, corto, plano,
--                                       irregular, sesamoideo. FK → terminology.catalog_concepts.
-- Las dos primeras son referencia de texto SIN FK (UBERON y las mallas no son un catálogo del
-- modelo); su formato lo valida la API. El tipo de hueso lo ELIGE el médico: no se deriva de la
-- región ni se pre-rellena (no hay fuente que relacione región con tipo de hueso).
--
-- CHECK.
--   ck_service_requests_specimen_xor_imaging  (REDEFINIDO): la muestra de laboratorio excluye
--     también la marca 3D y el tipo de hueso, además de lo que ya excluía.
--   ck_service_requests_bone_type_requires_location  (NUEVO): el tipo de hueso exige una
--     ubicación (body_site_concept_id o body_structure_uberon).
--
-- SEMILLAS (catálogo INTERNO con equivalencia externa). Los cinco conceptos de `bone-type` se
-- siembran con el id que deriva la API de la clave (deterministicId('clinical:BONE_TYPE_*'), mismo
-- esquema que el patch 2026-10-31_secretaria_iniciador_vinculos.sql) y `code` = la clave, como
-- hace TerminologySeedService: el seed de la API es insert-if-missing por id, así que ambos
-- lados convergen sin duplicar. Cada concepto lleva su procedencia en terminology.concept_properties
-- (property_code `provenance`, JSON): clase UBERON y xref FMA, release, URL, SHA-256, licencia
-- y fecha de verificación. NO se siembra aquí el value set / enum dinámico `bone-type` ni sus
-- miembros: los materializa la API desde DYNAMIC_ENUM_CATALOG (igual que specimen-type).
--
-- POR QUÉ NULLABLE Y SIN BACKFILL. Una orden anterior no declaró región 3D ni tipo de hueso;
-- reconstruirlos sería fabricar un dato clínico.
--
-- BLOQUEO. Las tres columnas son NULL y el CHECK redefinido es verdadero para toda fila existente;
-- aun así ADD CONSTRAINT / CREATE INDEX recorren la tabla dentro de la transacción (convención de
-- los parches de este directorio). service_requests es la tabla de órdenes, de tamaño acotado;
-- si en otra base fuera muy grande, correr los CREATE INDEX con CONCURRENTLY fuera de transacción.
--
-- RECUPERACIÓN (reversible). Antes de que exista un dato en las columnas nuevas, basta:
--   BEGIN;
--   ALTER TABLE "clinical"."service_requests" DROP CONSTRAINT IF EXISTS "ck_service_requests_bone_type_requires_location";
--   ALTER TABLE "clinical"."service_requests" DROP CONSTRAINT IF EXISTS "ck_service_requests_specimen_xor_imaging";
--   ALTER TABLE "clinical"."service_requests" ADD CONSTRAINT "ck_service_requests_specimen_xor_imaging"
--     CHECK (("specimen_type_concept_id" IS NULL OR ("modality_concept_id" IS NULL AND "body_site_concept_id" IS NULL AND "laterality_concept_id" IS NULL AND "contrast_concept_id" IS NULL)));
--   DROP INDEX IF EXISTS "clinical"."ix_service_requests_bone_type_concept_id";
--   DROP INDEX IF EXISTS "clinical"."ix_service_requests_body_structure_uberon";
--   ALTER TABLE "clinical"."service_requests" DROP CONSTRAINT IF EXISTS "fk_service_requests_bone_type_concept_id";
--   ALTER TABLE "clinical"."service_requests" DROP COLUMN IF EXISTS "bone_type_concept_id", DROP COLUMN IF EXISTS "body_mesh_id", DROP COLUMN IF EXISTS "body_structure_uberon";
--   COMMIT;
-- (Las semillas de terminología se dejan: son inertes sin la columna.) Si ya hay órdenes con
-- datos en las columnas, hacer antes un volcado de esas tres columnas: DROP COLUMN los pierde.
--
-- DELTAS ESPERADOS sobre la base viva:
--   columnas de clinical.service_requests   29 → 32
--   FKs                                      +1  (fk_service_requests_bone_type_concept_id)
--   índices                                  +2  (ix_service_requests_bone_type_concept_id, ix_service_requests_body_structure_uberon)
--   CHECK                                    +1 nuevo, 1 redefinido
--   terminology.catalog_concepts             +5  (clinical:BONE_TYPE_*; 0 si la API ya los sembró)
--   terminology.concept_properties           +5  (provenance)
--   tablas                                   ±0
-- ============================================================================

BEGIN;

-- ---------------------------------------------------------------- A. columnas
ALTER TABLE "clinical"."service_requests"
    ADD COLUMN IF NOT EXISTS "body_structure_uberon" varchar(64),
    ADD COLUMN IF NOT EXISTS "body_mesh_id" varchar(64),
    ADD COLUMN IF NOT EXISTS "bone_type_concept_id" uuid;

-- ------------------------------------------------------------------ B. índices
CREATE INDEX IF NOT EXISTS "ix_service_requests_bone_type_concept_id" ON "clinical"."service_requests" ("bone_type_concept_id");
CREATE INDEX IF NOT EXISTS "ix_service_requests_body_structure_uberon" ON "clinical"."service_requests" ("body_structure_uberon");

-- ---------------------------------------------------------------------- C. FK
-- Una sola por columna; el nombre es el que emite gen_ddl.py.
DO $$ BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint c
          JOIN pg_attribute a ON a.attrelid = c.conrelid AND a.attnum = ANY (c.conkey)
         WHERE c.conrelid = 'clinical.service_requests'::regclass AND c.contype = 'f'
           AND a.attname = 'bone_type_concept_id'
           AND c.confrelid = 'terminology.catalog_concepts'::regclass) THEN
        ALTER TABLE "clinical"."service_requests"
            ADD CONSTRAINT "fk_service_requests_bone_type_concept_id" FOREIGN KEY ("bone_type_concept_id")
            REFERENCES "terminology"."catalog_concepts" ("id");
    END IF;
END $$;

-- ------------------------------------------------------------------- D. CHECK
ALTER TABLE "clinical"."service_requests" DROP CONSTRAINT IF EXISTS "ck_service_requests_specimen_xor_imaging";
ALTER TABLE "clinical"."service_requests" ADD CONSTRAINT "ck_service_requests_specimen_xor_imaging"
    CHECK (("specimen_type_concept_id" IS NULL OR ("modality_concept_id" IS NULL AND "body_site_concept_id" IS NULL AND "laterality_concept_id" IS NULL AND "contrast_concept_id" IS NULL AND "body_structure_uberon" IS NULL AND "body_mesh_id" IS NULL AND "bone_type_concept_id" IS NULL)));
ALTER TABLE "clinical"."service_requests" DROP CONSTRAINT IF EXISTS "ck_service_requests_bone_type_requires_location";
ALTER TABLE "clinical"."service_requests" ADD CONSTRAINT "ck_service_requests_bone_type_requires_location"
    CHECK (("bone_type_concept_id" IS NULL OR "body_site_concept_id" IS NOT NULL OR "body_structure_uberon" IS NOT NULL));

-- ------------------------------------------------- E. semillas · tipo de hueso
-- E.1 cadena de terminología de la API (mismos ids que SEED de concepts.ts); no pisa nada.
INSERT INTO terminology.terminology_sources (id, code, name, created_at, updated_at, row_version)
VALUES ('d94cf414-ad1b-59b9-afe2-903641f26011', 'MANTRA_CORE', 'Mantra Core Internal Terminology', now(), now(), 1)
ON CONFLICT DO NOTHING;
INSERT INTO terminology.code_systems (id, source_id, internal_code, name, canonical_url, case_sensitive, created_at, updated_at, row_version)
VALUES ('7d025a87-9c81-5c5c-9432-daf84d6fee8a', 'd94cf414-ad1b-59b9-afe2-903641f26011', 'mantra-core-internal',
        'Mantra Core Internal Code System', 'https://mantracore.health/fhir/CodeSystem/internal', true, now(), now(), 1)
ON CONFLICT DO NOTHING;
INSERT INTO terminology.code_system_versions (id, code_system_id, version, published_at, is_default, created_at, updated_at, row_version)
VALUES ('ffda3cef-e77a-5002-8709-e79f32e62fb4', '7d025a87-9c81-5c5c-9432-daf84d6fee8a', '1.0.0', now(), true, now(), now(), 1)
ON CONFLICT DO NOTHING;

-- E.2 los cinco conceptos (id = uuid5(HEALTH_UUID_NAMESPACE, clave); code = clave).
INSERT INTO terminology.catalog_concepts (id, code_system_version_id, code, display, abstract, selectable, created_at, updated_at, row_version) VALUES
  ('c5977762-07fa-55dd-8c0e-fc5358ac72ec', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'clinical:BONE_TYPE_LONG', 'Long bone', false, true, now(), now(), 1),  -- clinical:BONE_TYPE_LONG
  ('f02120f7-c5d1-5747-8dcc-f2ade3d18cd4', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'clinical:BONE_TYPE_SHORT', 'Short bone', false, true, now(), now(), 1),  -- clinical:BONE_TYPE_SHORT
  ('bc930351-dbba-5ac5-bf01-d78909c21559', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'clinical:BONE_TYPE_FLAT', 'Flat bone', false, true, now(), now(), 1),  -- clinical:BONE_TYPE_FLAT
  ('043dfefa-d354-515e-b618-cc79a2bf1aab', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'clinical:BONE_TYPE_IRREGULAR', 'Irregular bone', false, true, now(), now(), 1),  -- clinical:BONE_TYPE_IRREGULAR
  ('27274b9b-5495-5cce-8fa7-3be82a22b7d2', 'ffda3cef-e77a-5002-8709-e79f32e62fb4', 'clinical:BONE_TYPE_SESAMOID', 'Sesamoid bone', false, true, now(), now(), 1)  -- clinical:BONE_TYPE_SESAMOID
ON CONFLICT DO NOTHING;

-- E.3 procedencia por concepto. Sin UNIQUE (concept_id, property_code) en la tabla: el id es
-- determinista y además se guarda con NOT EXISTS, así que la segunda corrida no inserta nada.
INSERT INTO terminology.concept_properties (id, concept_id, property_code, data_type, value_json, created_at, updated_at, row_version)
SELECT v.id, v.concept_id, v.property_code, v.data_type, v.value_json, v.created_at, v.updated_at, v.row_version
FROM (VALUES
  ('950d7854-8cc2-560e-a075-19948bfad3a8'::uuid, 'c5977762-07fa-55dd-8c0e-fc5358ac72ec'::uuid, 'provenance', 'json'::"terminology"."technical_data_type", '{"authority": "UBERON", "catalog_kind": "internal", "fma_id": "FMA:7474", "license": "CC-BY 3.0", "license_url": "https://creativecommons.org/licenses/by/3.0/", "note": "Catálogo interno de cinco clases de forma ósea; cada código propio equivale a la clase UBERON homónima. El médico elige el tipo; no se deriva de la región.", "release": "2026-10-01", "sha256": "d4751a15d7551a8414caee2628c62bf68301d567caf54ccfa3eef383ae7cbb61", "source": "Uberon, an integrative multi-species anatomy ontology (Mungall CJ et al., Genome Biol 2012;13(1):R5, doi:10.1186/gb-2012-13-1-r5)", "uberon_id": "UBERON:0002495", "uberon_label": "long bone", "url": "https://github.com/obophenotype/uberon/releases/download/v2026-10-01/uberon.obo", "verified_against": "mantra-core-health/public/anatomy-atlas-3d/catalog/structures-*.json (derivado de la release UBERON 2026-10-01; data/anatomy-ontology/provenance.json)", "verified_on": "2026-11-06"}'::jsonb, now(), now(), 1),  -- clinical:BONE_TYPE_LONG
  ('946b7ab2-35c0-5aa3-a8ab-221ed71bce4e'::uuid, 'f02120f7-c5d1-5747-8dcc-f2ade3d18cd4'::uuid, 'provenance', 'json'::"terminology"."technical_data_type", '{"authority": "UBERON", "catalog_kind": "internal", "fma_id": "FMA:7475", "license": "CC-BY 3.0", "license_url": "https://creativecommons.org/licenses/by/3.0/", "note": "Catálogo interno de cinco clases de forma ósea; cada código propio equivale a la clase UBERON homónima. El médico elige el tipo; no se deriva de la región.", "release": "2026-10-01", "sha256": "d4751a15d7551a8414caee2628c62bf68301d567caf54ccfa3eef383ae7cbb61", "source": "Uberon, an integrative multi-species anatomy ontology (Mungall CJ et al., Genome Biol 2012;13(1):R5, doi:10.1186/gb-2012-13-1-r5)", "uberon_id": "UBERON:0013630", "uberon_label": "short bone", "url": "https://github.com/obophenotype/uberon/releases/download/v2026-10-01/uberon.obo", "verified_against": "mantra-core-health/public/anatomy-atlas-3d/catalog/structures-*.json (derivado de la release UBERON 2026-10-01; data/anatomy-ontology/provenance.json)", "verified_on": "2026-11-06"}'::jsonb, now(), now(), 1),  -- clinical:BONE_TYPE_SHORT
  ('71b47667-cd10-57c2-9374-1893e136e942'::uuid, 'bc930351-dbba-5ac5-bf01-d78909c21559'::uuid, 'provenance', 'json'::"terminology"."technical_data_type", '{"authority": "UBERON", "catalog_kind": "internal", "fma_id": "FMA:7476", "license": "CC-BY 3.0", "license_url": "https://creativecommons.org/licenses/by/3.0/", "note": "Catálogo interno de cinco clases de forma ósea; cada código propio equivale a la clase UBERON homónima. El médico elige el tipo; no se deriva de la región.", "release": "2026-10-01", "sha256": "d4751a15d7551a8414caee2628c62bf68301d567caf54ccfa3eef383ae7cbb61", "source": "Uberon, an integrative multi-species anatomy ontology (Mungall CJ et al., Genome Biol 2012;13(1):R5, doi:10.1186/gb-2012-13-1-r5)", "uberon_id": "UBERON:0010428", "uberon_label": "flat bone", "url": "https://github.com/obophenotype/uberon/releases/download/v2026-10-01/uberon.obo", "verified_against": "mantra-core-health/public/anatomy-atlas-3d/catalog/structures-*.json (derivado de la release UBERON 2026-10-01; data/anatomy-ontology/provenance.json)", "verified_on": "2026-11-06"}'::jsonb, now(), now(), 1),  -- clinical:BONE_TYPE_FLAT
  ('aa0c78a9-070b-56c1-9f29-29e868b394fd'::uuid, '043dfefa-d354-515e-b618-cc79a2bf1aab'::uuid, 'provenance', 'json'::"terminology"."technical_data_type", '{"authority": "UBERON", "catalog_kind": "internal", "fma_id": "FMA:7477", "license": "CC-BY 3.0", "license_url": "https://creativecommons.org/licenses/by/3.0/", "note": "Catálogo interno de cinco clases de forma ósea; cada código propio equivale a la clase UBERON homónima. El médico elige el tipo; no se deriva de la región.", "release": "2026-10-01", "sha256": "d4751a15d7551a8414caee2628c62bf68301d567caf54ccfa3eef383ae7cbb61", "source": "Uberon, an integrative multi-species anatomy ontology (Mungall CJ et al., Genome Biol 2012;13(1):R5, doi:10.1186/gb-2012-13-1-r5)", "uberon_id": "UBERON:0008001", "uberon_label": "irregular bone", "url": "https://github.com/obophenotype/uberon/releases/download/v2026-10-01/uberon.obo", "verified_against": "mantra-core-health/public/anatomy-atlas-3d/catalog/structures-*.json (derivado de la release UBERON 2026-10-01; data/anatomy-ontology/provenance.json)", "verified_on": "2026-11-06"}'::jsonb, now(), now(), 1),  -- clinical:BONE_TYPE_IRREGULAR
  ('f22e2529-087b-556b-bafe-738401ec1f4c'::uuid, '27274b9b-5495-5cce-8fa7-3be82a22b7d2'::uuid, 'provenance', 'json'::"terminology"."technical_data_type", '{"authority": "UBERON", "catalog_kind": "internal", "fma_id": "FMA:32672", "license": "CC-BY 3.0", "license_url": "https://creativecommons.org/licenses/by/3.0/", "note": "Catálogo interno de cinco clases de forma ósea; cada código propio equivale a la clase UBERON homónima. El médico elige el tipo; no se deriva de la región.", "release": "2026-10-01", "sha256": "d4751a15d7551a8414caee2628c62bf68301d567caf54ccfa3eef383ae7cbb61", "source": "Uberon, an integrative multi-species anatomy ontology (Mungall CJ et al., Genome Biol 2012;13(1):R5, doi:10.1186/gb-2012-13-1-r5)", "uberon_id": "UBERON:0001479", "uberon_label": "sesamoid bone", "url": "https://github.com/obophenotype/uberon/releases/download/v2026-10-01/uberon.obo", "verified_against": "mantra-core-health/public/anatomy-atlas-3d/catalog/structures-*.json (derivado de la release UBERON 2026-10-01; data/anatomy-ontology/provenance.json)", "verified_on": "2026-11-06"}'::jsonb, now(), now(), 1)  -- clinical:BONE_TYPE_SESAMOID
) AS v(id, concept_id, property_code, data_type, value_json, created_at, updated_at, row_version)
WHERE NOT EXISTS (
    SELECT 1 FROM terminology.concept_properties p
     WHERE p.id = v.id OR (p.concept_id = v.concept_id AND p.property_code = v.property_code));

-- ------------------------------------------------------------ F. verificación
DO $$
DECLARE
    faltan text := '';
    c text;
    n integer;
BEGIN
    FOREACH c IN ARRAY ARRAY['body_structure_uberon','body_mesh_id','bone_type_concept_id']
    LOOP
        IF NOT EXISTS (SELECT 1 FROM information_schema.columns
                       WHERE table_schema = 'clinical' AND table_name = 'service_requests' AND column_name = c) THEN
            faltan := faltan || ' columna:' || c;
        END IF;
    END LOOP;
    IF (SELECT count(*) FROM pg_constraint c
          JOIN pg_attribute a ON a.attrelid = c.conrelid AND a.attnum = ANY (c.conkey)
         WHERE c.conrelid = 'clinical.service_requests'::regclass AND c.contype = 'f' AND c.convalidated
           AND a.attname = 'bone_type_concept_id') <> 1 THEN
        faltan := faltan || ' fk:bone_type_concept_id(1 validada)';
    END IF;
    FOREACH c IN ARRAY ARRAY['ix_service_requests_bone_type_concept_id','ix_service_requests_body_structure_uberon']
    LOOP
        IF to_regclass('clinical.' || c) IS NULL THEN
            faltan := faltan || ' indice:' || c;
        END IF;
    END LOOP;
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'ck_service_requests_bone_type_requires_location' AND convalidated) THEN
        faltan := faltan || ' check:ck_service_requests_bone_type_requires_location';
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'ck_service_requests_specimen_xor_imaging' AND convalidated
                   AND pg_get_constraintdef(oid) LIKE '%bone_type_concept_id%' AND pg_get_constraintdef(oid) LIKE '%body_mesh_id%'
                   AND pg_get_constraintdef(oid) LIKE '%body_structure_uberon%') THEN
        faltan := faltan || ' check:ck_service_requests_specimen_xor_imaging(ampliado)';
    END IF;
    SELECT count(*) INTO n FROM terminology.catalog_concepts WHERE code LIKE 'clinical:BONE_TYPE\_%';
    IF n <> 5 THEN faltan := faltan || ' conceptos:bone-type(' || n || ' de 5)'; END IF;
    SELECT count(*) INTO n FROM terminology.concept_properties p
      JOIN terminology.catalog_concepts k ON k.id = p.concept_id
     WHERE k.code LIKE 'clinical:BONE_TYPE\_%' AND p.property_code = 'provenance';
    IF n <> 5 THEN faltan := faltan || ' procedencia:bone-type(' || n || ' de 5)'; END IF;
    IF faltan <> '' THEN
        RAISE EXCEPTION 'v4.2.94 incompleto:%', faltan;
    END IF;
    RAISE NOTICE 'v4.2.94 aplicado: marca 3D y tipo de hueso en clinical.service_requests; 5 conceptos bone-type con procedencia.';
END $$;

COMMIT;
