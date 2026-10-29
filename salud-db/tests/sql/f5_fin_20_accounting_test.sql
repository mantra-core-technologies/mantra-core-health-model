-- ============================================================================
-- M-F5-fin · prueba de F5f (contabilidad) contra Postgres real:
-- accounting.cost_centers.clinical_unit_id y accounting.infrastructure_items.care_space_id.
-- Requiere …_f5_accounting aplicado. Transacción con ROLLBACK.
-- ============================================================================
\set ON_ERROR_STOP on
BEGIN;
\ir f5_fin_00_fixture.sql

-- ------------------------------------------------------------ centros de costo por unidad
SELECT pg_temp.caso('centro de costo de la práctica A1 enlazado a la unidad de A1',
  $q$UPDATE accounting.cost_centers SET clinical_unit_id = 'a1200000-0000-4000-8000-000000000001' WHERE id = 'a7000000-0000-4000-8000-000000000001'$q$);

SELECT pg_temp.caso('segundo centro de costo ACTIVO para la misma unidad (UNIT_ALREADY_HAS_COST_CENTER)',
  $q$INSERT INTO accounting.cost_centers (id, practice_id, code, name, status_concept_id, clinical_unit_id, created_at, updated_at)
     VALUES (gen_random_uuid(), 'a1000000-0000-4000-8000-000000000001', 'CC-A1-BIS', 'Otro', '38a1d301-f40d-5b17-a695-5e6d605f8b19', 'a1200000-0000-4000-8000-000000000001', now(), now())$q$,
  '23505');

SELECT pg_temp.caso('segundo centro de costo NO activo para la misma unidad (convive con el activo)',
  $q$INSERT INTO accounting.cost_centers (id, practice_id, code, name, status_concept_id, clinical_unit_id, created_at, updated_at)
     VALUES (gen_random_uuid(), 'a1000000-0000-4000-8000-000000000001', 'CC-A1-OLD', 'Histórico', 'c0000000-0000-4000-8000-000000000020', 'a1200000-0000-4000-8000-000000000001', now(), now())$q$);

SELECT pg_temp.caso('centros de costo sin unidad: varios activos sin límite',
  $q$INSERT INTO accounting.cost_centers (id, practice_id, code, name, status_concept_id, created_at, updated_at)
     VALUES (gen_random_uuid(), 'a1000000-0000-4000-8000-000000000001', 'CC-ADM', 'Administración', '38a1d301-f40d-5b17-a695-5e6d605f8b19', now(), now()),
            (gen_random_uuid(), 'a1000000-0000-4000-8000-000000000001', 'CC-ADM2', 'Administración 2', '38a1d301-f40d-5b17-a695-5e6d605f8b19', now(), now())$q$);

SELECT pg_temp.caso('centro de costo de la práctica A2 con una unidad de la práctica A1 (mismo tenant, otra práctica)',
  $q$UPDATE accounting.cost_centers SET clinical_unit_id = 'a1200000-0000-4000-8000-000000000001' WHERE id = 'a7000000-0000-4000-8000-000000000002'$q$,
  '23503');

SELECT pg_temp.caso('centro de costo del tenant B con una unidad del tenant A',
  $q$UPDATE accounting.cost_centers SET clinical_unit_id = 'a1200000-0000-4000-8000-000000000001' WHERE id = 'b7000000-0000-4000-8000-000000000001'$q$,
  '23503');

SELECT pg_temp.caso('centro de costo de A1 con una unidad del tenant B',
  $q$UPDATE accounting.cost_centers SET clinical_unit_id = 'b1200000-0000-4000-8000-000000000001' WHERE id = 'a7000000-0000-4000-8000-000000000001'$q$,
  '23503');

SELECT pg_temp.caso('unidad inexistente',
  $q$UPDATE accounting.cost_centers SET clinical_unit_id = gen_random_uuid() WHERE id = 'a7000000-0000-4000-8000-000000000002'$q$,
  '23503');

SELECT pg_temp.caso('centro de costo de A2 con su propia unidad de A2',
  $q$UPDATE accounting.cost_centers SET clinical_unit_id = 'a2200000-0000-4000-8000-000000000001' WHERE id = 'a7000000-0000-4000-8000-000000000002'$q$);

SELECT pg_temp.caso('mover el centro de costo a otra práctica con la unidad enlazada',
  $q$UPDATE accounting.cost_centers SET practice_id = 'a2000000-0000-4000-8000-000000000001' WHERE id = 'a7000000-0000-4000-8000-000000000001'$q$,
  '23503');

-- ------------------------------------------------------------ activos ubicados en un espacio
SELECT pg_temp.caso('activo de A1 ubicado en una cama de A1',
  $q$INSERT INTO accounting.infrastructure_items (id, practice_id, name, category_concept_id, status_concept_id, location_text, care_space_id, created_at, updated_at)
     VALUES ('e0000000-0000-4000-8000-000000000001', 'a1000000-0000-4000-8000-000000000001', 'Monitor', 'c0000000-0000-4000-8000-000000000020', 'c0000000-0000-4000-8000-000000000020', 'Piso 3 (texto heredado)', 'a1300000-0000-4000-8000-000000000001', now(), now())$q$);

SELECT pg_temp.caso('activo sin ubicación (location_text heredado, care_space_id NULL)',
  $q$INSERT INTO accounting.infrastructure_items (id, practice_id, name, category_concept_id, status_concept_id, location_text, created_at, updated_at)
     VALUES (gen_random_uuid(), 'a1000000-0000-4000-8000-000000000001', 'Camilla', 'c0000000-0000-4000-8000-000000000020', 'c0000000-0000-4000-8000-000000000020', 'Depósito', now(), now())$q$);

SELECT pg_temp.caso('activo de A1 ubicado en un espacio de la práctica A2 (INFRASTRUCTURE_SPACE_PRACTICE_MISMATCH)',
  $q$INSERT INTO accounting.infrastructure_items (id, practice_id, name, category_concept_id, status_concept_id, care_space_id, created_at, updated_at)
     VALUES (gen_random_uuid(), 'a1000000-0000-4000-8000-000000000001', 'Bomba', 'c0000000-0000-4000-8000-000000000020', 'c0000000-0000-4000-8000-000000000020', 'a2300000-0000-4000-8000-000000000004', now(), now())$q$,
  '23503');

SELECT pg_temp.caso('activo de A1 ubicado en un espacio del tenant B',
  $q$UPDATE accounting.infrastructure_items SET care_space_id = 'b1300000-0000-4000-8000-000000000003' WHERE id = 'e0000000-0000-4000-8000-000000000001'$q$,
  '23503');

SELECT pg_temp.caso('espacio inexistente',
  $q$UPDATE accounting.infrastructure_items SET care_space_id = gen_random_uuid() WHERE id = 'e0000000-0000-4000-8000-000000000001'$q$,
  '23503');

SELECT pg_temp.caso('reubicar el activo en otra cama de la misma práctica',
  $q$UPDATE accounting.infrastructure_items SET care_space_id = 'a1300000-0000-4000-8000-000000000002' WHERE id = 'e0000000-0000-4000-8000-000000000001'$q$);

SELECT pg_temp.caso('quitar la ubicación (NULL)',
  $q$UPDATE accounting.infrastructure_items SET care_space_id = NULL WHERE id = 'e0000000-0000-4000-8000-000000000001'$q$);

ROLLBACK;
