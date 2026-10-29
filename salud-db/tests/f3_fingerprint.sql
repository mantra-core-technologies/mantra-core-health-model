WITH t(sch, rel) AS (VALUES ('clinical','encounters'),('clinical','encounter_locations'),('clinical','placement_incidents'),('clinical','inpatient_census_days'),('clinical','inpatient_census_entries'),('clinical','inpatient_census_adjustments'),('audit','encounter_locations_history'),('audit','placement_incidents_history')),
oids AS (SELECT c.oid, n.nspname||'.'||c.relname AS name, c.relrowsecurity, c.relforcerowsecurity FROM pg_class c JOIN pg_namespace n ON n.oid=c.relnamespace JOIN t ON t.sch=n.nspname AND t.rel=c.relname),
items AS (
 SELECT 'col '||o.name||' '||a.attname||' '||format_type(a.atttypid,a.atttypmod)||' nn='||a.attnotnull||' def='||coalesce(pg_get_expr(d.adbin,d.adrelid),'') AS x FROM oids o JOIN pg_attribute a ON a.attrelid=o.oid AND a.attnum>0 AND NOT a.attisdropped LEFT JOIN pg_attrdef d ON d.adrelid=a.attrelid AND d.adnum=a.attnum
 UNION ALL SELECT 'con '||o.name||' '||c.conname||' '||pg_get_constraintdef(c.oid)||' v='||c.convalidated||' d='||c.condeferrable||c.condeferred FROM oids o JOIN pg_constraint c ON c.conrelid=o.oid
 UNION ALL SELECT 'idx '||o.name||' '||pg_get_indexdef(i.indexrelid) FROM oids o JOIN pg_index i ON i.indrelid=o.oid
 UNION ALL SELECT 'trg '||o.name||' '||pg_get_triggerdef(tg.oid) FROM oids o JOIN pg_trigger tg ON tg.tgrelid=o.oid AND NOT tg.tgisinternal
 UNION ALL SELECT 'pol '||o.name||' '||p.polname||' '||coalesce(pg_get_expr(p.polqual,p.polrelid),'')||' '||coalesce(pg_get_expr(p.polwithcheck,p.polrelid),'') FROM oids o JOIN pg_policy p ON p.polrelid=o.oid
 UNION ALL SELECT 'rls '||o.name||' '||o.relrowsecurity||o.relforcerowsecurity FROM oids o
 UNION ALL SELECT 'acl '||o.name||' '||coalesce(cl.relacl::text,'') FROM oids o JOIN pg_class cl ON cl.oid=o.oid
 UNION ALL SELECT 'acl-col '||o.name||' '||a.attname||' '||a.attacl::text FROM oids o JOIN pg_attribute a ON a.attrelid=o.oid AND a.attacl IS NOT NULL
 UNION ALL SELECT 'fn '||n.nspname||'.'||p.proname||' '||md5(pg_get_functiondef(p.oid)) FROM pg_proc p JOIN pg_namespace n ON n.oid=p.pronamespace WHERE (n.nspname='clinical' AND p.proname IN ('encounter_locations_fill_tenant','inpatient_census_days_guard_closed','inpatient_census_adjustments_require_closed')) OR (n.nspname='integrity' AND p.proname='forbid_mutation')
)
SELECT count(*) AS items, md5(string_agg(x, E'\n' ORDER BY x)) AS fingerprint FROM items;
