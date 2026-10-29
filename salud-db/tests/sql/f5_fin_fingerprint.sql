-- Huella del catálogo de los objetos de M-F5-fin (solo lectura).
WITH objs AS (
  SELECT 'tabla' k, c.oid::regclass::text n FROM pg_class c WHERE c.oid IN (
    'practice.care_space_category_periods'::regclass, 'billing.space_tariffs'::regclass, 'billing.charge_captures'::regclass,
    'audit.space_tariffs_history'::regclass, 'audit.charge_captures_history'::regclass,
    'accounting.cost_centers'::regclass, 'accounting.infrastructure_items'::regclass, 'billing.service_catalog'::regclass)
), cols AS (
  SELECT 'col' k, table_schema||'.'||table_name||'.'||column_name||':'||data_type||':'||is_nullable||':'||coalesce(column_default,'') n
  FROM information_schema.columns WHERE (table_schema, table_name) IN (('practice','care_space_category_periods'),('billing','space_tariffs'),('billing','charge_captures'),('audit','space_tariffs_history'),('audit','charge_captures_history'),('accounting','cost_centers'),('accounting','infrastructure_items'))
), cons AS (
  SELECT 'con' k, conrelid::regclass::text||'.'||conname||':'||pg_get_constraintdef(oid) n FROM pg_constraint
  WHERE conrelid IN ('practice.care_space_category_periods'::regclass, 'billing.space_tariffs'::regclass, 'billing.charge_captures'::regclass,
    'audit.space_tariffs_history'::regclass, 'audit.charge_captures_history'::regclass, 'accounting.cost_centers'::regclass, 'accounting.infrastructure_items'::regclass, 'billing.service_catalog'::regclass)
), idx AS (
  SELECT 'idx' k, schemaname||'.'||indexname||':'||indexdef n FROM pg_indexes
  WHERE (schemaname, tablename) IN (('practice','care_space_category_periods'),('billing','space_tariffs'),('billing','charge_captures'),('audit','space_tariffs_history'),('audit','charge_captures_history'),('accounting','cost_centers'),('accounting','infrastructure_items'),('billing','service_catalog'))
), trg AS (
  SELECT 'trg' k, tgrelid::regclass::text||'.'||tgname||':'||pg_get_triggerdef(oid) n FROM pg_trigger WHERE NOT tgisinternal
  AND (tgname LIKE 'trg\_%\_dependents' OR tgrelid IN ('practice.care_space_category_periods'::regclass, 'billing.space_tariffs'::regclass, 'billing.charge_captures'::regclass,
    'audit.space_tariffs_history'::regclass, 'audit.charge_captures_history'::regclass, 'accounting.cost_centers'::regclass, 'accounting.infrastructure_items'::regclass))
), fn AS (
  SELECT 'fn' k, p.oid::regprocedure::text||':'||md5(pg_get_functiondef(p.oid)||coalesce(p.proconfig::text,'')) n FROM pg_proc p JOIN pg_namespace s ON s.oid=p.pronamespace
  WHERE p.proname IN ('care_space_category_periods_guard','space_tariffs_guard','charge_captures_guard','cost_centers_assert_unit_practice','infrastructure_items_assert_space_practice',
                      'charge_source_case_ok','care_spaces_guard_billing_practice','practice_sites_guard_billing_practice',
                      'care_spaces_guard_accounting_practice','clinical_units_guard_accounting_practice','practice_sites_guard_accounting_practice')
), pol AS (
  SELECT 'pol' k, schemaname||'.'||tablename||'.'||policyname||':'||coalesce(qual,'')||':'||coalesce(with_check,'') n FROM pg_policies
  WHERE (schemaname, tablename) IN (('practice','care_space_category_periods'),('billing','space_tariffs'),('billing','charge_captures'),('audit','space_tariffs_history'),('audit','charge_captures_history'))
), rls AS (
  SELECT 'rls' k, oid::regclass::text||':'||relrowsecurity||':'||relforcerowsecurity n FROM pg_class
  WHERE oid IN ('practice.care_space_category_periods'::regclass, 'billing.space_tariffs'::regclass, 'billing.charge_captures'::regclass,
    'audit.space_tariffs_history'::regclass, 'audit.charge_captures_history'::regclass)
), acl AS (
  SELECT 'acl' k, oid::regclass::text||':'||coalesce(relacl::text,'') n FROM pg_class
  WHERE oid IN ('practice.care_space_category_periods'::regclass, 'billing.space_tariffs'::regclass, 'billing.charge_captures'::regclass,
    'audit.space_tariffs_history'::regclass, 'audit.charge_captures_history'::regclass)
)
SELECT k, count(*) AS n, md5(string_agg(n, E'\n' ORDER BY n)) AS huella
FROM (SELECT * FROM objs UNION ALL SELECT * FROM cols UNION ALL SELECT * FROM cons UNION ALL SELECT * FROM idx UNION ALL SELECT * FROM trg UNION ALL SELECT * FROM fn UNION ALL SELECT * FROM pol UNION ALL SELECT * FROM rls UNION ALL SELECT * FROM acl) z
GROUP BY k ORDER BY k;
