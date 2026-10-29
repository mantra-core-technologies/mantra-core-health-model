-- ============================================================================
-- Barrido automático de la integración de infraestructura hospitalaria (F1c–F5).
-- Solo lee el catálogo; no escribe. Devuelve una fila por hallazgo: «HALLAZGO|<regla>|<objeto>».
-- Un barrido limpio no devuelve ninguna. pytest (test_integracion_infraestructura.py) exige 0.
--
-- Tablas nuevas de la integración (no hay otra fuente: son las 26 que el catálogo de metadata
-- ganó respecto de v4.2.67b) y las tablas que ganaron tenant_id con este trabajo.
-- Reglas:
--   R1  toda tabla con tenant_id tiene RLS habilitada y FORZADA y la política tenant_isolation
--   R2  toda FK simple de una tabla con tenant_id hacia un padre que también tiene tenant_id
--       (o custodian_tenant_id) tiene su par compuesta (tenant_id, columna) → (tenant, id)
--       [las FK a directory.tenants, iam.users y catálogos globales no cuentan: sin tenant]
--   R3  cada tabla *_history nueva tiene tenant_id NOT NULL
--   R4  mantra_app no tiene DELETE ni TRUNCATE sobre las tablas de historia / rastro nuevas
-- ============================================================================
\pset format unaligned
\pset tuples_only on
CREATE TEMP TABLE _nuevas (schema_name text, table_name text, es_historia boolean DEFAULT false, es_rastro boolean DEFAULT false);
INSERT INTO _nuevas (schema_name, table_name, es_historia, es_rastro) VALUES
  ('audit','care_space_blocks_history',true,false),('audit','charge_captures_history',true,false),
  ('audit','cleaning_orders_history',true,false),('audit','encounter_locations_history',true,false),
  ('audit','floor_plans_history',true,false),('audit','operating_room_block_series_history',true,false),
  ('audit','operating_room_blocks_history',true,false),('audit','placement_incidents_history',true,false),
  ('audit','plan_elements_history',true,false),('audit','space_placements_history',true,false),
  ('audit','space_tariffs_history',true,false),
  ('billing','charge_captures',false,false),('billing','space_tariffs',false,false),
  ('clinical','inpatient_census_adjustments',false,true),('clinical','inpatient_census_days',false,false),
  ('clinical','inpatient_census_entries',false,true),('clinical','placement_incidents',false,false),
  ('practice','care_space_blocks',false,false),('practice','care_space_category_periods',false,false),
  ('practice','care_space_status_events',false,true),('practice','cleaning_orders',false,false),
  ('practice','floor_plans',false,false),('practice','plan_elements',false,false),
  ('practice','space_placements',false,false),
  ('procedures_perioperative','operating_room_block_series',false,false),
  ('procedures_perioperative','operating_room_blocks',false,false);
-- tablas existentes que ganaron tenant_id / aislamiento en este trabajo
INSERT INTO _nuevas (schema_name, table_name) VALUES
  ('clinical','encounter_locations'),('scheduling','schedule_templates'),('scheduling','availability_exceptions'),
  ('procedures_perioperative','operating_room_utilization_events'),('scheduling','schedulable_resources');

-- todas existen
SELECT 'HALLAZGO|R0 tabla ausente|' || n.schema_name || '.' || n.table_name
  FROM _nuevas n WHERE to_regclass(format('%I.%I', n.schema_name, n.table_name)) IS NULL;

-- R1
SELECT 'HALLAZGO|R1 sin tenant_id|' || n.schema_name || '.' || n.table_name
  FROM _nuevas n WHERE to_regclass(format('%I.%I', n.schema_name, n.table_name)) IS NOT NULL
   AND NOT EXISTS (SELECT 1 FROM information_schema.columns c WHERE c.table_schema = n.schema_name AND c.table_name = n.table_name AND c.column_name = 'tenant_id');
SELECT 'HALLAZGO|R1 sin RLS forzada o sin política tenant_isolation|' || n.schema_name || '.' || n.table_name
  FROM _nuevas n JOIN pg_class c ON c.oid = to_regclass(format('%I.%I', n.schema_name, n.table_name))
 WHERE EXISTS (SELECT 1 FROM information_schema.columns k WHERE k.table_schema = n.schema_name AND k.table_name = n.table_name AND k.column_name = 'tenant_id')
   AND (NOT c.relrowsecurity OR NOT c.relforcerowsecurity
        OR NOT EXISTS (SELECT 1 FROM pg_policies p WHERE p.schemaname = n.schema_name AND p.tablename = n.table_name AND p.policyname = 'tenant_isolation'));
-- el barrido general: TODA tabla con tenant_id (no solo las nuevas) tiene RLS forzada
SELECT 'HALLAZGO|R1 tabla con tenant_id sin RLS forzada|' || ns.nspname || '.' || c.relname
  FROM pg_class c JOIN pg_namespace ns ON ns.oid = c.relnamespace
  JOIN pg_attribute a ON a.attrelid = c.oid AND a.attname = 'tenant_id' AND NOT a.attisdropped
 WHERE c.relkind IN ('r','p') AND ns.nspname NOT IN ('pg_catalog','information_schema') AND ns.nspname NOT LIKE '_timescaledb%'
   AND ns.nspname NOT LIKE 'timescaledb%' AND ns.nspname <> 'vector_rag' AND NOT c.relispartition
   AND (NOT c.relrowsecurity OR NOT c.relforcerowsecurity)
 ORDER BY 1;

-- R1b: la política tenant_isolation de cada tabla nueva es EXACTAMENTE la canónica (la de practice.care_spaces):
--      mismo USING y mismo WITH CHECK, FOR ALL, permisiva. Una política «parecida» que filtre otra columna
--      o deje pasar NULL sería un agujero que R1 no vería.
SELECT 'HALLAZGO|R1b política distinta de la canónica|' || n.schema_name || '.' || n.table_name
  FROM _nuevas n
  JOIN pg_policies p ON p.schemaname = n.schema_name AND p.tablename = n.table_name AND p.policyname = 'tenant_isolation'
  CROSS JOIN (SELECT qual, with_check FROM pg_policies WHERE schemaname = 'practice' AND tablename = 'care_spaces' AND policyname = 'tenant_isolation') ref
 WHERE p.cmd <> 'ALL' OR p.permissive <> 'PERMISSIVE'
    OR p.qual IS DISTINCT FROM ref.qual OR p.with_check IS DISTINCT FROM ref.with_check;

-- R2: FK simples hacia padres con tenant sin su compuesta
WITH fk AS (
  SELECT co.oid, co.conrelid, co.confrelid, co.conkey[1] AS col, cn.nspname AS hijo_s, cl.relname AS hijo, pn.nspname AS padre_s, pl.relname AS padre
    FROM pg_constraint co
    JOIN pg_class cl ON cl.oid = co.conrelid JOIN pg_namespace cn ON cn.oid = cl.relnamespace
    JOIN pg_class pl ON pl.oid = co.confrelid JOIN pg_namespace pn ON pn.oid = pl.relnamespace
   WHERE co.contype = 'f' AND array_length(co.conkey, 1) = 1
), cand AS (
  SELECT fk.*, a.attname AS colname,
         (SELECT attname FROM pg_attribute WHERE attrelid = fk.confrelid AND attname IN ('tenant_id','custodian_tenant_id') AND NOT attisdropped ORDER BY attname DESC LIMIT 1) AS padre_tenant_col
    FROM fk JOIN pg_attribute a ON a.attrelid = fk.conrelid AND a.attnum = fk.col
   WHERE EXISTS (SELECT 1 FROM _nuevas n WHERE n.schema_name = fk.hijo_s AND n.table_name = fk.hijo)
     AND EXISTS (SELECT 1 FROM pg_attribute t WHERE t.attrelid = fk.conrelid AND t.attname = 'tenant_id' AND NOT t.attisdropped)
     AND (fk.padre_s, fk.padre) NOT IN (('directory','tenants'),('iam','users'),('terminology','catalog_concepts'))
     AND a.attname <> 'tenant_id'
)
SELECT 'HALLAZGO|R2 FK sin par compuesta (tenant)|' || c.hijo_s || '.' || c.hijo || '.' || c.colname || ' → ' || c.padre_s || '.' || c.padre
  FROM cand c
 WHERE c.padre_tenant_col IS NOT NULL
   AND NOT EXISTS (
     SELECT 1 FROM pg_constraint k
      WHERE k.contype = 'f' AND k.conrelid = c.conrelid AND k.confrelid = c.confrelid AND array_length(k.conkey, 1) = 2
        AND (SELECT attname FROM pg_attribute WHERE attrelid = k.conrelid AND attnum = k.conkey[1]) = 'tenant_id'
        AND (SELECT attname FROM pg_attribute WHERE attrelid = k.conrelid AND attnum = k.conkey[2]) = c.colname)
 ORDER BY 1;

-- R3
SELECT 'HALLAZGO|R3 historia sin tenant_id NOT NULL|' || n.schema_name || '.' || n.table_name
  FROM _nuevas n WHERE n.es_historia
   AND NOT EXISTS (SELECT 1 FROM information_schema.columns c WHERE c.table_schema = n.schema_name AND c.table_name = n.table_name AND c.column_name = 'tenant_id' AND c.is_nullable = 'NO');

-- R4
SELECT 'HALLAZGO|R4 mantra_app puede borrar o truncar|' || n.schema_name || '.' || n.table_name || ' (' || p.privilege_type || ')'
  FROM _nuevas n JOIN information_schema.role_table_grants p ON p.table_schema = n.schema_name AND p.table_name = n.table_name AND p.grantee = 'mantra_app'
 WHERE (n.es_historia OR n.es_rastro) AND p.privilege_type IN ('DELETE','TRUNCATE');
