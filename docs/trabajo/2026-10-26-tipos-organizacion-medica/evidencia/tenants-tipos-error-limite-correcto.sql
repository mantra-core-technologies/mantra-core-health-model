-- Evidencia: tipos de organización médica en directory.tenants (base alovida_model).
-- Uso: psql -h localhost -U postgres -d alovida_model -X -f tenants-tipos-error-limite-correcto.sql
-- Todo dentro de UNA transacción que termina en ROLLBACK; los casos de error van en SAVEPOINT.
\set ON_ERROR_STOP off
\set VERBOSITY default
\pset footer off
BEGIN;

-- Ids del backend (uuid5 con el namespace de concepts.ts)
\set t_hospital     '''2f68ad79-452a-5cba-aa7f-96f8fa2610ab'''
\set t_clinic       '''420eddfc-a569-5b2e-b720-7d7de91cb874'''
\set t_office       '''1b191a91-244e-5965-8bc5-e6e07f1d0cb6'''
\set t_nursing      '''11fbdf9e-2b4f-59af-8e6e-b05be58a33b3'''
\set t_other        '''51966f39-c661-5926-914d-d30683f583ef'''
\set le_company     '''f13fb5a6-e3b9-5d5d-bf90-f551a17b40c0'''
\set st_active      '''4d38ec64-227a-599d-8924-21424d9a8986'''
\set vf_unverified  '''a6eb3028-c24e-5144-8565-3c70d03bfead'''

-- Texto hexadecimal determinista de n caracteres (no comprimible por pglz).
CREATE FUNCTION pg_temp.hex(n int) RETURNS text LANGUAGE sql IMMUTABLE AS
$$ SELECT left(string_agg(md5('alovida-' || i), '' ORDER BY i), n) FROM generate_series(1, n/32 + 1) i $$;

\echo
\echo '=== 0 · Catálogo: los cinco tipos institucionales existen con el id de la API ==='
SELECT c.id, c.code, c.display
  FROM terminology.catalog_concepts c
 WHERE c.id IN (:t_hospital, :t_clinic, :t_office, :t_nursing, :t_other)
 ORDER BY c.code;

\echo
\echo '=== 1 · ERROR ==='
\echo '--- 1a · tenant_type_concept_id que no existe en el catálogo -> FK'
SAVEPOINT e;
INSERT INTO directory.tenants (id, code, tenant_type_concept_id, legal_name,
       legal_entity_type_concept_id, status_concept_id, verification_status_concept_id, created_at, updated_at)
VALUES (gen_random_uuid(), 'EVID_ERR_FK', '00000000-0000-5000-8000-000000000000', 'Tipo inexistente',
       :le_company, :st_active, :vf_unverified, now(), now());
ROLLBACK TO SAVEPOINT e;

\echo '--- 1b · tenant_type_concept_id NULL -> NOT NULL'
SAVEPOINT e;
INSERT INTO directory.tenants (id, code, tenant_type_concept_id, legal_name,
       legal_entity_type_concept_id, status_concept_id, verification_status_concept_id, created_at, updated_at)
VALUES (gen_random_uuid(), 'EVID_ERR_NULL_TYPE', NULL, 'Sin tipo',
       :le_company, :st_active, :vf_unverified, now(), now());
ROLLBACK TO SAVEPOINT e;

\echo '--- 1c · code NULL -> NOT NULL'
SAVEPOINT e;
INSERT INTO directory.tenants (id, code, tenant_type_concept_id, legal_name,
       legal_entity_type_concept_id, status_concept_id, verification_status_concept_id, created_at, updated_at)
VALUES (gen_random_uuid(), NULL, :t_clinic, 'Sin código',
       :le_company, :st_active, :vf_unverified, now(), now());
ROLLBACK TO SAVEPOINT e;

\echo '--- 1d · legal_name NULL -> NOT NULL'
SAVEPOINT e;
INSERT INTO directory.tenants (id, code, tenant_type_concept_id, legal_name,
       legal_entity_type_concept_id, status_concept_id, verification_status_concept_id, created_at, updated_at)
VALUES (gen_random_uuid(), 'EVID_ERR_NULL_NAME', :t_clinic, NULL,
       :le_company, :st_active, :vf_unverified, now(), now());
ROLLBACK TO SAVEPOINT e;

\echo '--- 1e · un concepto que EXISTE pero no es tipo de tenant (state:active) -> la base lo ACEPTA (solo hay FK, no CHECK ni value set)'
SAVEPOINT e;
INSERT INTO directory.tenants (id, code, tenant_type_concept_id, legal_name,
       legal_entity_type_concept_id, status_concept_id, verification_status_concept_id, created_at, updated_at)
VALUES (gen_random_uuid(), 'EVID_ERR_WRONG_SET', '38a1d301-f40d-5b17-a695-5e6d605f8b19', 'Tipo de otro catálogo',
       :le_company, :st_active, :vf_unverified, now(), now())
RETURNING code, tenant_type_concept_id;
ROLLBACK TO SAVEPOINT e;

\echo
\echo '=== 2 · LÍMITE ==='
\echo '--- 2a · el .puml declara code y legal_name como varchar SIN largo: el tope de code lo pone el índice único btree (2704 B por entrada)'
SELECT character_maximum_length AS max_len, column_name
  FROM information_schema.columns
 WHERE table_schema = 'directory' AND table_name = 'tenants' AND column_name IN ('code', 'legal_name', 'trade_name')
 ORDER BY column_name;

\echo '--- 2b · code de 2692 caracteres (tope exacto) -> aceptado'
SAVEPOINT e;
INSERT INTO directory.tenants (id, code, tenant_type_concept_id, legal_name,
       legal_entity_type_concept_id, status_concept_id, verification_status_concept_id, created_at, updated_at)
VALUES (gen_random_uuid(), pg_temp.hex(2692), :t_clinic, 'Código en el tope',
       :le_company, :st_active, :vf_unverified, now(), now())
RETURNING length(code) AS code_len, octet_length(code) AS code_bytes;
ROLLBACK TO SAVEPOINT e;

\echo '--- 2c · code de 2693 caracteres (+1) -> rechazado por uq_tenants_code'
SAVEPOINT e;
INSERT INTO directory.tenants (id, code, tenant_type_concept_id, legal_name,
       legal_entity_type_concept_id, status_concept_id, verification_status_concept_id, created_at, updated_at)
VALUES (gen_random_uuid(), pg_temp.hex(2693), :t_clinic, 'Código uno sobre el tope',
       :le_company, :st_active, :vf_unverified, now(), now());
ROLLBACK TO SAVEPOINT e;

\echo '--- 2d · legal_name de 10000 caracteres -> aceptado (sin índice ni largo declarado)'
SAVEPOINT e;
INSERT INTO directory.tenants (id, code, tenant_type_concept_id, legal_name,
       legal_entity_type_concept_id, status_concept_id, verification_status_concept_id, created_at, updated_at)
VALUES (gen_random_uuid(), 'EVID_LIM_NAME', :t_clinic, pg_temp.hex(10000),
       :le_company, :st_active, :vf_unverified, now(), now())
RETURNING code, length(legal_name) AS legal_name_len;
ROLLBACK TO SAVEPOINT e;

\echo '--- 2e · code y legal_name vacíos ('''') -> aceptados (no hay CHECK de longitud mínima)'
SAVEPOINT e;
INSERT INTO directory.tenants (id, code, tenant_type_concept_id, legal_name,
       legal_entity_type_concept_id, status_concept_id, verification_status_concept_id, created_at, updated_at)
VALUES (gen_random_uuid(), '', :t_clinic, '',
       :le_company, :st_active, :vf_unverified, now(), now())
RETURNING quote_literal(code) AS code, quote_literal(legal_name) AS legal_name;
ROLLBACK TO SAVEPOINT e;

\echo '--- 2f · unicidad de code: el segundo EVID_DUP -> 23505; EVID_DUP vs evid_dup conviven (la unicidad distingue mayúsculas)'
SAVEPOINT e;
INSERT INTO directory.tenants (id, code, tenant_type_concept_id, legal_name,
       legal_entity_type_concept_id, status_concept_id, verification_status_concept_id, created_at, updated_at)
VALUES (gen_random_uuid(), 'EVID_DUP', :t_hospital, 'Primero', :le_company, :st_active, :vf_unverified, now(), now()),
       (gen_random_uuid(), 'evid_dup', :t_hospital, 'Minúsculas', :le_company, :st_active, :vf_unverified, now(), now())
RETURNING code;
SAVEPOINT dup;
INSERT INTO directory.tenants (id, code, tenant_type_concept_id, legal_name,
       legal_entity_type_concept_id, status_concept_id, verification_status_concept_id, created_at, updated_at)
VALUES (gen_random_uuid(), 'EVID_DUP', :t_clinic, 'Duplicado', :le_company, :st_active, :vf_unverified, now(), now());
ROLLBACK TO SAVEPOINT e;

\echo
\echo '=== 3 · CORRECTO · un tenant por cada tipo institucional, leído con el join al concepto ==='
INSERT INTO directory.tenants (id, code, tenant_type_concept_id, legal_name, trade_name,
       legal_entity_type_concept_id, status_concept_id, verification_status_concept_id, created_at, updated_at)
VALUES (gen_random_uuid(), 'EVID_OK_HOSPITAL',       :t_hospital, 'Hospital Evidencia S.A.',        'Hospital Evidencia',   :le_company, :st_active, :vf_unverified, now(), now()),
       (gen_random_uuid(), 'EVID_OK_CLINIC',         :t_clinic,   'Clínica Evidencia S.R.L.',       'Clínica Evidencia',    :le_company, :st_active, :vf_unverified, now(), now()),
       (gen_random_uuid(), 'EVID_OK_MEDICAL_OFFICE', :t_office,   'Consultorio Evidencia',          'Consultorio Evidencia',:le_company, :st_active, :vf_unverified, now(), now()),
       (gen_random_uuid(), 'EVID_OK_NURSING',        :t_nursing,  'Enfermería Evidencia',           'Enfermería Evidencia', :le_company, :st_active, :vf_unverified, now(), now()),
       (gen_random_uuid(), 'EVID_OK_HEALTH_OTHER',   :t_other,    'Institución de Salud Evidencia', 'Otra Evidencia',       :le_company, :st_active, :vf_unverified, now(), now());

SELECT t.code AS tenant_code, t.trade_name, c.code AS type_code, c.display AS type_display, c.id AS type_concept_id
  FROM directory.tenants t
  JOIN terminology.catalog_concepts c ON c.id = t.tenant_type_concept_id
 WHERE t.code LIKE 'EVID_OK_%'
 ORDER BY t.code;

ROLLBACK;

\echo
\echo '=== Después del ROLLBACK: no quedó nada ==='
SELECT count(*) AS evid_rows_left FROM directory.tenants WHERE code LIKE 'EVID_%' OR code = '' OR length(code) > 2000;
