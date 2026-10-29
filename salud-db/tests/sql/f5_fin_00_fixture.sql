-- ============================================================================
-- Fixture común de las pruebas SQL de M-F5-fin (se incluye con \ir dentro de una transacción
-- que cada prueba cierra con ROLLBACK; no deja nada en la base).
--
-- Dos tenants (A y B). En el tenant A, dos prácticas (A1 y A2) para probar «mismo tenant,
-- otra práctica». Los padres se insertan con los triggers de FK de SUS tablas apagados
-- (ALTER TABLE … DISABLE TRIGGER ALL, sólo superusuario, revertido por el ROLLBACK): lo que
-- se prueba son las tablas de M-F5-fin, no la cadena de dependencias de directory/iam/profiles.
-- Las FK de las tablas M-F5-fin hacia esos padres SÍ están activas.
-- ============================================================================
SET LOCAL app.system_context = 'true';
SET LOCAL TIME ZONE 'UTC';

ALTER TABLE terminology.catalog_concepts DISABLE TRIGGER ALL;
ALTER TABLE directory.tenants            DISABLE TRIGGER ALL;
ALTER TABLE practice.practices           DISABLE TRIGGER ALL;
ALTER TABLE practice.practice_sites      DISABLE TRIGGER ALL;
ALTER TABLE practice.clinical_units      DISABLE TRIGGER ALL;
ALTER TABLE practice.care_spaces         DISABLE TRIGGER ALL;
ALTER TABLE profiles.patient_profiles    DISABLE TRIGGER ALL;
ALTER TABLE clinical.encounters          DISABLE TRIGGER ALL;
ALTER TABLE clinical.encounter_locations DISABLE TRIGGER ALL;
ALTER TABLE billing.service_catalog      DISABLE TRIGGER ALL;
ALTER TABLE billing.invoices             DISABLE TRIGGER ALL;
ALTER TABLE billing.invoice_lines        DISABLE TRIGGER ALL;
ALTER TABLE accounting.cost_centers      DISABLE TRIGGER ALL;
ALTER TABLE accounting.infrastructure_items DISABLE TRIGGER ALL;

-- Conceptos (los UUID de billing son los de deterministicId('billing:<NOMBRE>'); state:active, el de la API).
INSERT INTO terminology.catalog_concepts (id, code_system_version_id, code, display, created_at, updated_at)
SELECT c.id::uuid, gen_random_uuid(), c.code, c.code, now(), now()
  FROM (VALUES
    ('1ae01bf6-a061-52ed-aa26-590705cb2202', 'TARIFF_BED_DAY'),
    ('25eb53f6-8006-5959-bee9-65b16117bc9b', 'TARIFF_OR_TIME'),
    ('5f84ea44-b0d3-582c-86c1-32c81e422d30', 'CHG_SRC_BED_DAY'),
    ('a79361f6-8787-56a5-9a90-a9436d02e217', 'CHG_SRC_OR_TIME'),
    ('17def99a-0cb5-586c-a440-59d809709c0d', 'CHG_PENDING'),
    ('9af061be-6a80-51ed-bcbd-52533037c272', 'CHG_INVOICED'),
    ('f2f59654-d912-5eeb-b619-814e50a3c4d0', 'CHG_VOIDED'),
    ('38a1d301-f40d-5b17-a695-5e6d605f8b19', 'ACTIVE'),
    ('c0000000-0000-4000-8000-000000000001', 'BED_CAT_SHARED'),
    ('c0000000-0000-4000-8000-000000000002', 'BED_CAT_ICU'),
    ('c0000000-0000-4000-8000-000000000003', 'BED_CAT_PRIVATE'),
    ('c0000000-0000-4000-8000-000000000010', 'BOB'),
    ('c0000000-0000-4000-8000-000000000011', 'USD'),
    ('c0000000-0000-4000-8000-000000000020', 'GENERIC_STATUS')
  ) AS c(id, code);

-- Tenants A y B
INSERT INTO directory.tenants (id, code, tenant_type_concept_id, legal_name, legal_entity_type_concept_id,
                               status_concept_id, verification_status_concept_id, created_at, updated_at)
VALUES ('a0000000-0000-4000-8000-000000000001', 'TA', 'c0000000-0000-4000-8000-000000000020', 'Tenant A', 'c0000000-0000-4000-8000-000000000020', 'c0000000-0000-4000-8000-000000000020', 'c0000000-0000-4000-8000-000000000020', now(), now()),
       ('b0000000-0000-4000-8000-000000000001', 'TB', 'c0000000-0000-4000-8000-000000000020', 'Tenant B', 'c0000000-0000-4000-8000-000000000020', 'c0000000-0000-4000-8000-000000000020', 'c0000000-0000-4000-8000-000000000020', now(), now());

-- Prácticas: A1 y A2 (tenant A), B1 (tenant B)
INSERT INTO practice.practices (id, tenant_id, code, name, type_concept_id, admin_user_id, status_concept_id, time_zone, created_at, updated_at)
VALUES ('a1000000-0000-4000-8000-000000000001', 'a0000000-0000-4000-8000-000000000001', 'A1', 'Hospital A1', 'c0000000-0000-4000-8000-000000000020', gen_random_uuid(), 'c0000000-0000-4000-8000-000000000020', 'America/La_Paz', now(), now()),
       ('a2000000-0000-4000-8000-000000000001', 'a0000000-0000-4000-8000-000000000001', 'A2', 'Clínica A2',  'c0000000-0000-4000-8000-000000000020', gen_random_uuid(), 'c0000000-0000-4000-8000-000000000020', 'America/La_Paz', now(), now()),
       ('b1000000-0000-4000-8000-000000000001', 'b0000000-0000-4000-8000-000000000001', 'B1', 'Hospital B1', 'c0000000-0000-4000-8000-000000000020', gen_random_uuid(), 'c0000000-0000-4000-8000-000000000020', 'America/La_Paz', now(), now());

INSERT INTO practice.practice_sites (id, practice_id, tenant_id, code, name, site_type_concept_id, status_concept_id, created_at, updated_at)
VALUES ('a1100000-0000-4000-8000-000000000001', 'a1000000-0000-4000-8000-000000000001', 'a0000000-0000-4000-8000-000000000001', 'A1-S', 'Sede A1', 'c0000000-0000-4000-8000-000000000020', 'c0000000-0000-4000-8000-000000000020', now(), now()),
       ('a2100000-0000-4000-8000-000000000001', 'a2000000-0000-4000-8000-000000000001', 'a0000000-0000-4000-8000-000000000001', 'A2-S', 'Sede A2', 'c0000000-0000-4000-8000-000000000020', 'c0000000-0000-4000-8000-000000000020', now(), now()),
       ('b1100000-0000-4000-8000-000000000001', 'b1000000-0000-4000-8000-000000000001', 'b0000000-0000-4000-8000-000000000001', 'B1-S', 'Sede B1', 'c0000000-0000-4000-8000-000000000020', 'c0000000-0000-4000-8000-000000000020', now(), now());

-- Unidades clínicas: UA1 (práctica A1), UA2 (práctica A2), UB1 (tenant B)
INSERT INTO practice.clinical_units (id, practice_site_id, tenant_id, code, name, unit_type_concept_id, status_concept_id, created_at, updated_at)
VALUES ('a1200000-0000-4000-8000-000000000001', 'a1100000-0000-4000-8000-000000000001', 'a0000000-0000-4000-8000-000000000001', 'UA1', 'Internación A1', 'c0000000-0000-4000-8000-000000000020', 'c0000000-0000-4000-8000-000000000020', now(), now()),
       ('a2200000-0000-4000-8000-000000000001', 'a2100000-0000-4000-8000-000000000001', 'a0000000-0000-4000-8000-000000000001', 'UA2', 'Internación A2', 'c0000000-0000-4000-8000-000000000020', 'c0000000-0000-4000-8000-000000000020', now(), now()),
       ('b1200000-0000-4000-8000-000000000001', 'b1100000-0000-4000-8000-000000000001', 'b0000000-0000-4000-8000-000000000001', 'UB1', 'Internación B1', 'c0000000-0000-4000-8000-000000000020', 'c0000000-0000-4000-8000-000000000020', now(), now());

-- Camas: S1 (compartida) y S2 (UCI) en A1; S4 en A2 (otra práctica del tenant A); S3 en B1.
-- S5: espacio SIN categoría (consultorio) en A1.
INSERT INTO practice.care_spaces (id, practice_site_id, tenant_id, code, name, space_type_concept_id, status_concept_id,
                                  bed_category_concept_id, created_at, updated_at)
VALUES ('a1300000-0000-4000-8000-000000000001', 'a1100000-0000-4000-8000-000000000001', 'a0000000-0000-4000-8000-000000000001', 'A1-301A', 'Cama 301-A', 'c0000000-0000-4000-8000-000000000020', 'c0000000-0000-4000-8000-000000000020', 'c0000000-0000-4000-8000-000000000001', '2026-01-01 00:00+00', now()),
       ('a1300000-0000-4000-8000-000000000002', 'a1100000-0000-4000-8000-000000000001', 'a0000000-0000-4000-8000-000000000001', 'A1-UCI1', 'Cama UCI-1', 'c0000000-0000-4000-8000-000000000020', 'c0000000-0000-4000-8000-000000000020', 'c0000000-0000-4000-8000-000000000002', '2026-01-01 00:00+00', now()),
       ('a1300000-0000-4000-8000-000000000005', 'a1100000-0000-4000-8000-000000000001', 'a0000000-0000-4000-8000-000000000001', 'A1-C1', 'Consultorio 1', 'c0000000-0000-4000-8000-000000000020', 'c0000000-0000-4000-8000-000000000020', NULL, '2026-01-01 00:00+00', now()),
       ('a2300000-0000-4000-8000-000000000004', 'a2100000-0000-4000-8000-000000000001', 'a0000000-0000-4000-8000-000000000001', 'A2-101', 'Cama 101', 'c0000000-0000-4000-8000-000000000020', 'c0000000-0000-4000-8000-000000000020', 'c0000000-0000-4000-8000-000000000001', '2026-01-01 00:00+00', now()),
       ('b1300000-0000-4000-8000-000000000003', 'b1100000-0000-4000-8000-000000000001', 'b0000000-0000-4000-8000-000000000001', 'B1-201', 'Cama 201', 'c0000000-0000-4000-8000-000000000020', 'c0000000-0000-4000-8000-000000000020', 'c0000000-0000-4000-8000-000000000001', '2026-01-01 00:00+00', now());

-- Pacientes y encuentros: a5…01..05 (tenant A, pacientes PA..PA5) y b5…01 (tenant B, paciente PB)
INSERT INTO profiles.patient_profiles (profile_id, patient_code, created_at, updated_at)
VALUES ('a4000000-0000-4000-8000-000000000001', 'PA',  now(), now()),
       ('a4000000-0000-4000-8000-000000000002', 'PA2', now(), now()),
       ('a4000000-0000-4000-8000-000000000003', 'PA3', now(), now()),
       ('a4000000-0000-4000-8000-000000000004', 'PA4', now(), now()),
       ('a4000000-0000-4000-8000-000000000005', 'PA5', now(), now()),
       ('b4000000-0000-4000-8000-000000000001', 'PB',  now(), now());

INSERT INTO clinical.encounters (id, patient_profile_id, tenant_id, status_concept_id, created_at, updated_at)
VALUES ('a5000000-0000-4000-8000-000000000001', 'a4000000-0000-4000-8000-000000000001', 'a0000000-0000-4000-8000-000000000001', 'c0000000-0000-4000-8000-000000000020', now(), now()),
       ('a5000000-0000-4000-8000-000000000002', 'a4000000-0000-4000-8000-000000000002', 'a0000000-0000-4000-8000-000000000001', 'c0000000-0000-4000-8000-000000000020', now(), now()),
       ('a5000000-0000-4000-8000-000000000003', 'a4000000-0000-4000-8000-000000000003', 'a0000000-0000-4000-8000-000000000001', 'c0000000-0000-4000-8000-000000000020', now(), now()),
       ('a5000000-0000-4000-8000-000000000004', 'a4000000-0000-4000-8000-000000000004', 'a0000000-0000-4000-8000-000000000001', 'c0000000-0000-4000-8000-000000000020', now(), now()),
       ('a5000000-0000-4000-8000-000000000005', 'a4000000-0000-4000-8000-000000000005', 'a0000000-0000-4000-8000-000000000001', 'c0000000-0000-4000-8000-000000000020', now(), now()),
       ('b5000000-0000-4000-8000-000000000001', 'b4000000-0000-4000-8000-000000000001', 'b0000000-0000-4000-8000-000000000001', 'c0000000-0000-4000-8000-000000000020', now(), now());

-- Catálogo de servicios: SC_BED (A1, día-cama), SC_ICU (A1), SC_OR (A1), SC_A2 (otra práctica del tenant A), SC_B (tenant B)
INSERT INTO billing.service_catalog (id, practice_id, code, name, default_price, is_active, created_at, updated_at)
VALUES ('a6000000-0000-4000-8000-000000000001', 'a1000000-0000-4000-8000-000000000001', 'DC-COMP', 'Día-cama compartida', 0, true, now(), now()),
       ('a6000000-0000-4000-8000-000000000002', 'a1000000-0000-4000-8000-000000000001', 'DC-UCI',  'Día-cama UCI',        0, true, now(), now()),
       ('a6000000-0000-4000-8000-000000000003', 'a1000000-0000-4000-8000-000000000001', 'QX',      'Uso de quirófano',    0, true, now(), now()),
       ('a6000000-0000-4000-8000-000000000004', 'a2000000-0000-4000-8000-000000000001', 'DC-A2',   'Día-cama A2',         0, true, now(), now()),
       ('b6000000-0000-4000-8000-000000000001', 'b1000000-0000-4000-8000-000000000001', 'DC-B',    'Día-cama B',          0, true, now(), now());

-- Centros de costo: CC_A1 (A1), CC_A2 (A2), CC_B1 (B1)
INSERT INTO accounting.cost_centers (id, practice_id, code, name, status_concept_id, created_at, updated_at)
VALUES ('a7000000-0000-4000-8000-000000000001', 'a1000000-0000-4000-8000-000000000001', 'CC-A1', 'Internación A1', '38a1d301-f40d-5b17-a695-5e6d605f8b19', now(), now()),
       ('a7000000-0000-4000-8000-000000000002', 'a2000000-0000-4000-8000-000000000001', 'CC-A2', 'Internación A2', '38a1d301-f40d-5b17-a695-5e6d605f8b19', now(), now()),
       ('b7000000-0000-4000-8000-000000000001', 'b1000000-0000-4000-8000-000000000001', 'CC-B1', 'Internación B1', '38a1d301-f40d-5b17-a695-5e6d605f8b19', now(), now());

-- Facturas y líneas: PA en A1 (…01), PA2 en A1 (…02), PA en A2 (…03), PA5 en A1 (…04).
INSERT INTO billing.invoices (id, practice_id, invoice_number, patient_profile_id, issue_date, status_concept_id, created_at, updated_at)
VALUES ('a8000000-0000-4000-8000-000000000001', 'a1000000-0000-4000-8000-000000000001', 'F-A1-1', 'a4000000-0000-4000-8000-000000000001', '2026-10-30', 'c0000000-0000-4000-8000-000000000020', now(), now()),
       ('a8000000-0000-4000-8000-000000000002', 'a1000000-0000-4000-8000-000000000001', 'F-A1-2', 'a4000000-0000-4000-8000-000000000002', '2026-10-30', 'c0000000-0000-4000-8000-000000000020', now(), now()),
       ('a8000000-0000-4000-8000-000000000003', 'a2000000-0000-4000-8000-000000000001', 'F-A2-1', 'a4000000-0000-4000-8000-000000000001', '2026-10-30', 'c0000000-0000-4000-8000-000000000020', now(), now()),
       ('a8000000-0000-4000-8000-000000000004', 'a1000000-0000-4000-8000-000000000001', 'F-A1-5', 'a4000000-0000-4000-8000-000000000005', '2026-10-30', 'c0000000-0000-4000-8000-000000000020', now(), now());
INSERT INTO billing.invoice_lines (id, invoice_id, quantity, unit_price, created_at, updated_at)
VALUES ('a9000000-0000-4000-8000-000000000001', 'a8000000-0000-4000-8000-000000000001', 1, 0, now(), now()),
       ('a9000000-0000-4000-8000-000000000002', 'a8000000-0000-4000-8000-000000000002', 1, 0, now(), now()),
       ('a9000000-0000-4000-8000-000000000003', 'a8000000-0000-4000-8000-000000000003', 1, 0, now(), now()),
       ('a9000000-0000-4000-8000-000000000004', 'a8000000-0000-4000-8000-000000000004', 1, 0, now(), now());

ALTER TABLE terminology.catalog_concepts ENABLE TRIGGER ALL;
ALTER TABLE directory.tenants            ENABLE TRIGGER ALL;
ALTER TABLE practice.practices           ENABLE TRIGGER ALL;
ALTER TABLE practice.practice_sites      ENABLE TRIGGER ALL;
ALTER TABLE practice.clinical_units      ENABLE TRIGGER ALL;
ALTER TABLE practice.care_spaces         ENABLE TRIGGER ALL;
ALTER TABLE profiles.patient_profiles    ENABLE TRIGGER ALL;
ALTER TABLE clinical.encounters          ENABLE TRIGGER ALL;
ALTER TABLE clinical.encounter_locations ENABLE TRIGGER ALL;
ALTER TABLE billing.service_catalog      ENABLE TRIGGER ALL;
ALTER TABLE billing.invoices             ENABLE TRIGGER ALL;
ALTER TABLE billing.invoice_lines        ENABLE TRIGGER ALL;
ALTER TABLE accounting.cost_centers      ENABLE TRIGGER ALL;
ALTER TABLE accounting.infrastructure_items ENABLE TRIGGER ALL;

-- Ayudante de pruebas: ejecuta una sentencia en un subtransacción y comprueba el SQLSTATE
-- (NULL = tiene que salir bien). Cuenta los casos aprobados para que pytest los lea.
CREATE OR REPLACE FUNCTION pg_temp.caso(etiqueta text, sentencia text, esperado text DEFAULT NULL)
RETURNS void LANGUAGE plpgsql AS $f$
DECLARE
    obtenido text := NULL;
    detalle  text := NULL;
BEGIN
    BEGIN
        EXECUTE sentencia;
    EXCEPTION WHEN OTHERS THEN
        obtenido := SQLSTATE;
        detalle  := SQLERRM;
    END;
    IF obtenido IS DISTINCT FROM esperado THEN
        RAISE EXCEPTION 'CASO FALLIDO [%]: esperado=% obtenido=% (%)', etiqueta, coalesce(esperado, 'éxito'), coalesce(obtenido, 'éxito'), coalesce(detalle, '');
    END IF;
    RAISE NOTICE 'CASO OK [%] -> %', etiqueta, coalesce(esperado, 'éxito');
END $f$;

-- Afirma el valor (como texto) de una consulta escalar.
CREATE OR REPLACE FUNCTION pg_temp.afirmar(etiqueta text, consulta text, esperado text)
RETURNS void LANGUAGE plpgsql AS $f$
DECLARE
    obtenido text;
BEGIN
    EXECUTE consulta INTO obtenido;
    IF obtenido IS DISTINCT FROM esperado THEN
        RAISE EXCEPTION 'CASO FALLIDO [%]: esperado=% obtenido=%', etiqueta, esperado, coalesce(obtenido, 'NULL');
    END IF;
    RAISE NOTICE 'CASO OK [%] -> %', etiqueta, esperado;
END $f$;
