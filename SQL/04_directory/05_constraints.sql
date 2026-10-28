-- SALUD v4.0.10 · schema directory · constraints de integridad (módulo 33)
-- Aplicar DESPUÉS de 04_indexes.sql y de SQL/_integrity/00_integrity_functions.sql.
-- Reglas del módulo 33. Las UK/CHECK/EXCLUDE en prosa quedan como comentario:
-- el modelo no declara su expresión SQL y no se inventa (temperatura-0).
-- CHECK_SQL y EXCLUDE_SQL sí se materializan con la expresión del modelo.


-- ═══ tenant_medical_facilities ═══
-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "directory"."tenant_medical_facilities" DROP CONSTRAINT IF EXISTS "ck_tenant_medical_facilities_tax_identifier_format";
ALTER TABLE "directory"."tenant_medical_facilities" ADD CONSTRAINT "ck_tenant_medical_facilities_tax_identifier_format" CHECK ("tax_identifier_number" ~ '^[0-9][0-9-]{3,19}$');

-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "directory"."tenant_medical_facilities" DROP CONSTRAINT IF EXISTS "ck_tenant_medical_facilities_registration_format";
ALTER TABLE "directory"."tenant_medical_facilities" ADD CONSTRAINT "ck_tenant_medical_facilities_registration_format" CHECK ("health_facility_registration_number" ~ '^[A-Za-z0-9./-]{3,50}$');

-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "directory"."tenant_medical_facilities" DROP CONSTRAINT IF EXISTS "ck_tenant_medical_facilities_director_license";
ALTER TABLE "directory"."tenant_medical_facilities" ADD CONSTRAINT "ck_tenant_medical_facilities_director_license" CHECK (char_length(btrim("medical_director_license_number")) BETWEEN 3 AND 50);


-- ═══ tenant_medical_facility_sites ═══
-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "directory"."tenant_medical_facility_sites" DROP CONSTRAINT IF EXISTS "ck_tenant_medical_facility_sites_kind_ordinal";
ALTER TABLE "directory"."tenant_medical_facility_sites" ADD CONSTRAINT "ck_tenant_medical_facility_sites_kind_ordinal" CHECK (("site_kind" = 'headquarters' AND "ordinal" = 0) OR ("site_kind" = 'branch' AND "ordinal" BETWEEN 1 AND 50));

-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "directory"."tenant_medical_facility_sites" DROP CONSTRAINT IF EXISTS "ck_tenant_medical_facility_sites_address_lines";
ALTER TABLE "directory"."tenant_medical_facility_sites" ADD CONSTRAINT "ck_tenant_medical_facility_sites_address_lines" CHECK (cardinality("address_lines") >= 1);

-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "directory"."tenant_medical_facility_sites" DROP CONSTRAINT IF EXISTS "ck_tenant_medical_facility_sites_geo";
ALTER TABLE "directory"."tenant_medical_facility_sites" ADD CONSTRAINT "ck_tenant_medical_facility_sites_geo" CHECK ((("latitude" IS NULL) = ("longitude" IS NULL)) AND ("latitude" IS NULL OR ("latitude" BETWEEN -90 AND 90 AND "longitude" BETWEEN -180 AND 180)));
