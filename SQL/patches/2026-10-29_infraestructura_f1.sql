-- ============================================================================
-- SALUD · patch v4.2.67 (infraestructura hospitalaria F1 · establecimiento regulado,
-- árbol físico FHIR Location, vínculo espacio↔unidad y capacidad declarada) sobre BD viva
-- Fecha: 2026-10-29 · Contrato: SALUD/Arquitectura/infraestructura-hospitalaria/
--   CONTRATO-F0-F1.md §1 (repositorio de documentación)
-- Idempotente (ADD COLUMN IF NOT EXISTS / CREATE … IF NOT EXISTS / FK con
-- `duplicate_object` / DROP POLICY IF EXISTS). Se puede aplicar N veces.
--
-- Contexto: gen_ddl.py ya emite todo esto en SQL/14_practice/ y SQL/10_audit/ desde
-- que los .puml lo declaran, así que en un rebuild desde cero el DDL ya viene en el
-- CREATE TABLE y este patch sólo agrega el RLS (y no cambia nada más). Existe para una
-- base ya aplicada y poblada: un CREATE TABLE IF NOT EXISTS no agrega columnas a una
-- tabla que ya existe. gen_apply.py no escanea SQL/patches/: no entra en apply_all.sql.
-- Las sentencias de columnas, tablas, FKs e índices se copiaron de los archivos
-- generados, no se escribieron a mano. Lo escrito a mano: la precondición, el backfill
-- de `tenant_id`, el SET NOT NULL, el RLS y la verificación final.
--
-- QUÉ CIERRA.
--   A. practice.practice_sites (el ESTABLECIMIENTO regulado): `tenant_id` (backfill desde
--      practices.tenant_id, después NOT NULL) y los datos regulatorios de Bolivia:
--      snis_code (único cuando existe), subsector, nivel de atención, tipología, ente
--      gestor, red de salud, SEDES y municipio.
--   B. practice.clinical_units (árbol ORGANIZATIVO): `tenant_id` (backfill desde la sede),
--      description, valid_from, valid_to.
--   C. practice.care_spaces (árbol FÍSICO = FHIR Location): `tenant_id` (backfill desde la
--      sede), form_concept_id (FORMA; `space_type_concept_id` pasa a ser la FUNCIÓN),
--      description, piso, m², asepsia, presión, renovaciones/h, validación HVAC,
--      restricción de sexo y edad, categoría de cama, censable, GLN y vigencia.
--      Único (practice_site_id, code): el código es inmutable y no se reutiliza.
--   D. Tablas nuevas en `practice`: space_unit_assignments, site_declared_capacities,
--      space_form_parent_rules, facility_typology_rules. Las habilitaciones NO son tabla
--      nueva: viven en organization_extensions.facility_licenses (ver el patch f1b).
--   E. RLS `tenant_isolation` (texto exacto de 2026-08-05_tenant_rls.sql) en las cinco
--      tablas con `tenant_id`: practice_sites, clinical_units, care_spaces,
--      space_unit_assignments, site_declared_capacities. Las dos tablas de reglas son
--      catálogos globales sin tenant y quedan sin RLS.
--
-- REVISIÓN 2026-10-29 (antes de mergear). La primera versión de este patch creaba también
-- practice.site_licenses y audit.site_licenses_history; duplicaban
-- organization_extensions.facility_licenses y se quitaron de aquí. Una base que ya aplicó
-- la versión anterior las limpia con 2026-10-29_infraestructura_f1b_seguridad.sql, que
-- además endurece el aislamiento por tenant de todo lo que este patch agrega.
--
-- LO QUE ESTE PATCH NO HACE.
--   - No siembra conceptos (LOC_FORM_*, SPACE_FN_*, LIC_*, CAP_*, …) ni las reglas
--     padre→hijo / de tipología: sus ids los deriva la API (`practice.concepts.ts`).
--   - No completa `care_spaces.form_concept_id`: queda NULL en las filas existentes y la
--     API hace el backfill a LOC_FORM_ROOM, porque el uuid del concepto es de la API.
--   - `clinical_units.tenant_id` y `care_spaces.tenant_id` quedan NULLables acá; el NOT NULL,
--     las FK compuestas (tenant_id, x_id) y el resto del endurecimiento vienen en
--     2026-10-29_infraestructura_f1b_seguridad.sql, que se aplica justo después.
--   - No borra ni renombra nada.
--
-- PRECONDICIÓN. El índice único (practice_site_id, code) de care_spaces falla si hoy hay
-- dos espacios con el mismo código en la misma sede. El patch lo comprueba antes y aborta
-- con la lista; el BEGIN hace rollback de todo. NO se borra ni se renombra ningún dato:
-- resolver los duplicados a mano y volver a aplicar. Consulta para el operador:
--
--   SELECT practice_site_id, code, count(*), array_agg(id)
--     FROM practice.care_spaces GROUP BY 1, 2 HAVING count(*) > 1;
--
-- DELTAS ESPERADOS sobre la base viva (antes de este patch):
--   columnas  +29  (practice_sites 9 · clinical_units 4 · care_spaces 16)
--   tablas     +4  (en practice)
--   FKs       +33
--   índices   +39  (35 declarados, 2 de ellos únicos, + 4 PK de las tablas nuevas)
--   políticas RLS +5 (tenant_isolation)
-- ============================================================================

BEGIN;

-- El backfill lee practices y escribe sedes/unidades/espacios, tablas con RLS forzada
-- desde 2026-08-05_tenant_rls.sql. El rol dueño la sortea si es superusuario; si no lo
-- es, esto abre el contexto SYSTEM sólo para esta transacción (SET LOCAL).
SET LOCAL app.system_context = 'true';

-- ------------------------------------------------------------- 0. precondición
DO $$
DECLARE
    n_dup   integer;
    detalle text;
BEGIN
    SELECT count(*), string_agg(format('sede %s · código %L (%s filas)', practice_site_id, code, n), '; ')
      INTO n_dup, detalle
      FROM (SELECT practice_site_id, code, count(*) AS n
              FROM "practice"."care_spaces"
             GROUP BY practice_site_id, code
            HAVING count(*) > 1
             ORDER BY practice_site_id, code
             LIMIT 50) d;
    IF n_dup > 0 THEN
        RAISE EXCEPTION 'practice.care_spaces tiene % código(s) repetido(s) en la misma sede; no se crea ux_care_spaces_site_code y no se toca ningún dato. Resolverlos a mano (decidir qué espacio conserva el código) y volver a aplicar. Detalle: %', n_dup, detalle
            USING ERRCODE = 'unique_violation';
    END IF;
END $$;

-- ------------------------------------------------------------- A-C. columnas

ALTER TABLE "practice"."practice_sites"
    ADD COLUMN IF NOT EXISTS "tenant_id" uuid;  -- NOT NULL tras el backfill

ALTER TABLE "practice"."practice_sites"
    ADD COLUMN IF NOT EXISTS "snis_code" varchar;

ALTER TABLE "practice"."practice_sites"
    ADD COLUMN IF NOT EXISTS "subsector_concept_id" uuid;

ALTER TABLE "practice"."practice_sites"
    ADD COLUMN IF NOT EXISTS "care_level_concept_id" uuid;

ALTER TABLE "practice"."practice_sites"
    ADD COLUMN IF NOT EXISTS "facility_typology_concept_id" uuid;

ALTER TABLE "practice"."practice_sites"
    ADD COLUMN IF NOT EXISTS "managing_entity_name" varchar;

ALTER TABLE "practice"."practice_sites"
    ADD COLUMN IF NOT EXISTS "health_network_name" varchar;

ALTER TABLE "practice"."practice_sites"
    ADD COLUMN IF NOT EXISTS "sedes_department_concept_id" uuid;

ALTER TABLE "practice"."practice_sites"
    ADD COLUMN IF NOT EXISTS "municipality_name" varchar;

ALTER TABLE "practice"."clinical_units"
    ADD COLUMN IF NOT EXISTS "tenant_id" uuid;

ALTER TABLE "practice"."clinical_units"
    ADD COLUMN IF NOT EXISTS "description" varchar;

ALTER TABLE "practice"."clinical_units"
    ADD COLUMN IF NOT EXISTS "valid_from" timestamptz;

ALTER TABLE "practice"."clinical_units"
    ADD COLUMN IF NOT EXISTS "valid_to" timestamptz;

ALTER TABLE "practice"."care_spaces"
    ADD COLUMN IF NOT EXISTS "tenant_id" uuid;

ALTER TABLE "practice"."care_spaces"
    ADD COLUMN IF NOT EXISTS "form_concept_id" uuid;

ALTER TABLE "practice"."care_spaces"
    ADD COLUMN IF NOT EXISTS "description" varchar;

ALTER TABLE "practice"."care_spaces"
    ADD COLUMN IF NOT EXISTS "floor_number" integer;

ALTER TABLE "practice"."care_spaces"
    ADD COLUMN IF NOT EXISTS "area_m2" numeric(10,2);

ALTER TABLE "practice"."care_spaces"
    ADD COLUMN IF NOT EXISTS "asepsis_concept_id" uuid;

ALTER TABLE "practice"."care_spaces"
    ADD COLUMN IF NOT EXISTS "pressure_concept_id" uuid;

ALTER TABLE "practice"."care_spaces"
    ADD COLUMN IF NOT EXISTS "air_changes_per_hour" numeric(6,2);

ALTER TABLE "practice"."care_spaces"
    ADD COLUMN IF NOT EXISTS "hvac_validated_on" date;

ALTER TABLE "practice"."care_spaces"
    ADD COLUMN IF NOT EXISTS "sex_restriction_concept_id" uuid;

ALTER TABLE "practice"."care_spaces"
    ADD COLUMN IF NOT EXISTS "age_group_concept_id" uuid;

ALTER TABLE "practice"."care_spaces"
    ADD COLUMN IF NOT EXISTS "bed_category_concept_id" uuid;

ALTER TABLE "practice"."care_spaces"
    ADD COLUMN IF NOT EXISTS "censable" boolean;

ALTER TABLE "practice"."care_spaces"
    ADD COLUMN IF NOT EXISTS "gln" varchar(13);

ALTER TABLE "practice"."care_spaces"
    ADD COLUMN IF NOT EXISTS "valid_from" timestamptz;

ALTER TABLE "practice"."care_spaces"
    ADD COLUMN IF NOT EXISTS "valid_to" timestamptz;

-- ------------------------------------------------------------- backfill de tenant_id
-- La sede hereda el tenant de su práctica; unidades y espacios, el de su sede. Sólo se
-- completan las filas con NULL: una segunda pasada no cambia nada.
UPDATE "practice"."practice_sites" ps
   SET "tenant_id" = p."tenant_id"
  FROM "practice"."practices" p
 WHERE p."id" = ps."practice_id"
   AND ps."tenant_id" IS NULL;

UPDATE "practice"."clinical_units" cu
   SET "tenant_id" = ps."tenant_id"
  FROM "practice"."practice_sites" ps
 WHERE ps."id" = cu."practice_site_id"
   AND cu."tenant_id" IS NULL;

UPDATE "practice"."care_spaces" cs
   SET "tenant_id" = ps."tenant_id"
  FROM "practice"."practice_sites" ps
 WHERE ps."id" = cs."practice_site_id"
   AND cs."tenant_id" IS NULL;

-- Una fila con tenant distinto al de su sede rompería el aislamiento: se aborta en vez de
-- corregirla, porque decidir cuál de los dos es el correcto no le toca al patch.
DO $$
DECLARE
    n_sin  integer;
    n_cruz integer;
BEGIN
    SELECT count(*) INTO n_sin FROM "practice"."practice_sites" WHERE "tenant_id" IS NULL;
    IF n_sin > 0 THEN
        RAISE EXCEPTION 'practice.practice_sites: % sede(s) sin tenant tras el backfill (¿practice_id huérfano?)', n_sin;
    END IF;

    SELECT (SELECT count(*) FROM "practice"."clinical_units" cu
              JOIN "practice"."practice_sites" ps ON ps."id" = cu."practice_site_id"
             WHERE cu."tenant_id" IS DISTINCT FROM ps."tenant_id")
         + (SELECT count(*) FROM "practice"."care_spaces" cs
              JOIN "practice"."practice_sites" ps ON ps."id" = cs."practice_site_id"
             WHERE cs."tenant_id" IS DISTINCT FROM ps."tenant_id")
      INTO n_cruz;
    IF n_cruz > 0 THEN
        RAISE EXCEPTION 'practice: % unidad(es)/espacio(s) con tenant_id distinto al de su sede; revisar a mano', n_cruz;
    END IF;
END $$;

ALTER TABLE "practice"."practice_sites" ALTER COLUMN "tenant_id" SET NOT NULL;

-- ------------------------------------------------------------- D. tablas nuevas
CREATE TABLE IF NOT EXISTS "practice"."space_unit_assignments" (
    "id" uuid NOT NULL,
    "tenant_id" uuid NOT NULL,
    "care_space_id" uuid NOT NULL,
    "clinical_unit_id" uuid NOT NULL,
    "role_concept_id" uuid NOT NULL,
    "valid_from" timestamptz NOT NULL,
    "valid_to" timestamptz,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_space_unit_assignments" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "practice"."site_declared_capacities" (
    "id" uuid NOT NULL,
    "tenant_id" uuid NOT NULL,
    "practice_site_id" uuid NOT NULL,
    "capacity_kind_concept_id" uuid NOT NULL,
    "quantity" integer NOT NULL,
    "as_of" date NOT NULL,
    "resolution_number" varchar,
    "valid_to" date,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_site_declared_capacities" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "practice"."space_form_parent_rules" (
    "parent_form_concept_id" uuid NOT NULL,
    "child_form_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_space_form_parent_rules" PRIMARY KEY ("parent_form_concept_id", "child_form_concept_id")
);

CREATE TABLE IF NOT EXISTS "practice"."facility_typology_rules" (
    "typology_concept_id" uuid NOT NULL,
    "space_function_concept_id" uuid NOT NULL,
    "rule_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_facility_typology_rules" PRIMARY KEY ("typology_concept_id", "space_function_concept_id")
);

-- ------------------------------------------------------------- FKs (copiadas de 03_fk_intra y 90_fk_deferred)
DO $$ BEGIN
    ALTER TABLE "practice"."space_unit_assignments"
        ADD CONSTRAINT "fk_space_unit_assignments_care_space_id" FOREIGN KEY ("care_space_id")
        REFERENCES "practice"."care_spaces" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "practice"."space_unit_assignments"
        ADD CONSTRAINT "fk_space_unit_assignments_clinical_unit_id" FOREIGN KEY ("clinical_unit_id")
        REFERENCES "practice"."clinical_units" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "practice"."site_declared_capacities"
        ADD CONSTRAINT "fk_site_declared_capacities_practice_site_id" FOREIGN KEY ("practice_site_id")
        REFERENCES "practice"."practice_sites" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: directory.tenants (requiere schema directory)
DO $$ BEGIN
    ALTER TABLE "practice"."practice_sites"
        ADD CONSTRAINT "fk_practice_sites_tenant_id" FOREIGN KEY ("tenant_id")
        REFERENCES "directory"."tenants" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "practice"."practice_sites"
        ADD CONSTRAINT "fk_practice_sites_subsector_concept_id" FOREIGN KEY ("subsector_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "practice"."practice_sites"
        ADD CONSTRAINT "fk_practice_sites_care_level_concept_id" FOREIGN KEY ("care_level_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "practice"."practice_sites"
        ADD CONSTRAINT "fk_practice_sites_facility_typology_concept_id" FOREIGN KEY ("facility_typology_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "practice"."practice_sites"
        ADD CONSTRAINT "fk_practice_sites_sedes_department_concept_id" FOREIGN KEY ("sedes_department_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: directory.tenants (requiere schema directory)
DO $$ BEGIN
    ALTER TABLE "practice"."clinical_units"
        ADD CONSTRAINT "fk_clinical_units_tenant_id" FOREIGN KEY ("tenant_id")
        REFERENCES "directory"."tenants" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: directory.tenants (requiere schema directory)
DO $$ BEGIN
    ALTER TABLE "practice"."care_spaces"
        ADD CONSTRAINT "fk_care_spaces_tenant_id" FOREIGN KEY ("tenant_id")
        REFERENCES "directory"."tenants" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "practice"."care_spaces"
        ADD CONSTRAINT "fk_care_spaces_form_concept_id" FOREIGN KEY ("form_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "practice"."care_spaces"
        ADD CONSTRAINT "fk_care_spaces_asepsis_concept_id" FOREIGN KEY ("asepsis_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "practice"."care_spaces"
        ADD CONSTRAINT "fk_care_spaces_pressure_concept_id" FOREIGN KEY ("pressure_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "practice"."care_spaces"
        ADD CONSTRAINT "fk_care_spaces_sex_restriction_concept_id" FOREIGN KEY ("sex_restriction_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "practice"."care_spaces"
        ADD CONSTRAINT "fk_care_spaces_age_group_concept_id" FOREIGN KEY ("age_group_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "practice"."care_spaces"
        ADD CONSTRAINT "fk_care_spaces_bed_category_concept_id" FOREIGN KEY ("bed_category_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: directory.tenants (requiere schema directory)
DO $$ BEGIN
    ALTER TABLE "practice"."space_unit_assignments"
        ADD CONSTRAINT "fk_space_unit_assignments_tenant_id" FOREIGN KEY ("tenant_id")
        REFERENCES "directory"."tenants" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "practice"."space_unit_assignments"
        ADD CONSTRAINT "fk_space_unit_assignments_role_concept_id" FOREIGN KEY ("role_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "practice"."space_unit_assignments"
        ADD CONSTRAINT "fk_space_unit_assignments_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "practice"."space_unit_assignments"
        ADD CONSTRAINT "fk_space_unit_assignments_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: directory.tenants (requiere schema directory)
DO $$ BEGIN
    ALTER TABLE "practice"."site_declared_capacities"
        ADD CONSTRAINT "fk_site_declared_capacities_tenant_id" FOREIGN KEY ("tenant_id")
        REFERENCES "directory"."tenants" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "practice"."site_declared_capacities"
        ADD CONSTRAINT "fk_site_declared_capacities_capacity_kind_concept_id" FOREIGN KEY ("capacity_kind_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "practice"."site_declared_capacities"
        ADD CONSTRAINT "fk_site_declared_capacities_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "practice"."site_declared_capacities"
        ADD CONSTRAINT "fk_site_declared_capacities_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "practice"."space_form_parent_rules"
        ADD CONSTRAINT "fk_space_form_parent_rules_parent_form_concept_id" FOREIGN KEY ("parent_form_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "practice"."space_form_parent_rules"
        ADD CONSTRAINT "fk_space_form_parent_rules_child_form_concept_id" FOREIGN KEY ("child_form_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "practice"."space_form_parent_rules"
        ADD CONSTRAINT "fk_space_form_parent_rules_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "practice"."space_form_parent_rules"
        ADD CONSTRAINT "fk_space_form_parent_rules_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "practice"."facility_typology_rules"
        ADD CONSTRAINT "fk_facility_typology_rules_typology_concept_id" FOREIGN KEY ("typology_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "practice"."facility_typology_rules"
        ADD CONSTRAINT "fk_facility_typology_rules_space_function_concept_id" FOREIGN KEY ("space_function_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "practice"."facility_typology_rules"
        ADD CONSTRAINT "fk_facility_typology_rules_rule_concept_id" FOREIGN KEY ("rule_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "practice"."facility_typology_rules"
        ADD CONSTRAINT "fk_facility_typology_rules_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "practice"."facility_typology_rules"
        ADD CONSTRAINT "fk_facility_typology_rules_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- ------------------------------------------------------------- índices (copiados de 04_indexes)
CREATE INDEX IF NOT EXISTS "ix_practice_sites_tenant_id" ON "practice"."practice_sites" ("tenant_id");

CREATE INDEX IF NOT EXISTS "ix_practice_sites_subsector_concept_id" ON "practice"."practice_sites" ("subsector_concept_id");

CREATE INDEX IF NOT EXISTS "ix_practice_sites_care_level_concept_id" ON "practice"."practice_sites" ("care_level_concept_id");

CREATE INDEX IF NOT EXISTS "ix_practice_sites_facility_typology_concept_id" ON "practice"."practice_sites" ("facility_typology_concept_id");

CREATE INDEX IF NOT EXISTS "ix_practice_sites_sedes_department_concept_id" ON "practice"."practice_sites" ("sedes_department_concept_id");

CREATE UNIQUE INDEX IF NOT EXISTS "ux_practice_sites_snis_code" ON "practice"."practice_sites" ("snis_code") WHERE snis_code IS NOT NULL;

CREATE INDEX IF NOT EXISTS "ix_clinical_units_tenant_id" ON "practice"."clinical_units" ("tenant_id");

CREATE INDEX IF NOT EXISTS "ix_care_spaces_tenant_id" ON "practice"."care_spaces" ("tenant_id");

CREATE INDEX IF NOT EXISTS "ix_care_spaces_form_concept_id" ON "practice"."care_spaces" ("form_concept_id");

CREATE INDEX IF NOT EXISTS "ix_care_spaces_asepsis_concept_id" ON "practice"."care_spaces" ("asepsis_concept_id");

CREATE INDEX IF NOT EXISTS "ix_care_spaces_pressure_concept_id" ON "practice"."care_spaces" ("pressure_concept_id");

CREATE INDEX IF NOT EXISTS "ix_care_spaces_sex_restriction_concept_id" ON "practice"."care_spaces" ("sex_restriction_concept_id");

CREATE INDEX IF NOT EXISTS "ix_care_spaces_age_group_concept_id" ON "practice"."care_spaces" ("age_group_concept_id");

CREATE INDEX IF NOT EXISTS "ix_care_spaces_bed_category_concept_id" ON "practice"."care_spaces" ("bed_category_concept_id");

CREATE UNIQUE INDEX IF NOT EXISTS "ux_care_spaces_site_code" ON "practice"."care_spaces" ("practice_site_id", "code");

CREATE INDEX IF NOT EXISTS "ix_space_unit_assignments_tenant_id" ON "practice"."space_unit_assignments" ("tenant_id");

CREATE INDEX IF NOT EXISTS "ix_space_unit_assignments_care_space_id" ON "practice"."space_unit_assignments" ("care_space_id");

CREATE INDEX IF NOT EXISTS "ix_space_unit_assignments_clinical_unit_id" ON "practice"."space_unit_assignments" ("clinical_unit_id");

CREATE INDEX IF NOT EXISTS "ix_space_unit_assignments_role_concept_id" ON "practice"."space_unit_assignments" ("role_concept_id");

CREATE INDEX IF NOT EXISTS "ix_space_unit_assignments_created_by_user_id" ON "practice"."space_unit_assignments" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_space_unit_assignments_updated_by_user_id" ON "practice"."space_unit_assignments" ("updated_by_user_id");

CREATE UNIQUE INDEX IF NOT EXISTS "ux_space_unit_assignments_current" ON "practice"."space_unit_assignments" ("care_space_id", "clinical_unit_id") WHERE valid_to IS NULL;

CREATE INDEX IF NOT EXISTS "ix_site_declared_capacities_tenant_id" ON "practice"."site_declared_capacities" ("tenant_id");

CREATE INDEX IF NOT EXISTS "ix_site_declared_capacities_practice_site_id" ON "practice"."site_declared_capacities" ("practice_site_id");

CREATE INDEX IF NOT EXISTS "ix_site_declared_capacities_capacity_kind_concept_id" ON "practice"."site_declared_capacities" ("capacity_kind_concept_id");

CREATE INDEX IF NOT EXISTS "ix_site_declared_capacities_created_by_user_id" ON "practice"."site_declared_capacities" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_site_declared_capacities_updated_by_user_id" ON "practice"."site_declared_capacities" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_site_declared_capacities_site_kind_as_of" ON "practice"."site_declared_capacities" ("practice_site_id", "capacity_kind_concept_id", "as_of" DESC);

CREATE INDEX IF NOT EXISTS "ix_space_form_parent_rules_child_form_concept_id" ON "practice"."space_form_parent_rules" ("child_form_concept_id");

CREATE INDEX IF NOT EXISTS "ix_space_form_parent_rules_created_by_user_id" ON "practice"."space_form_parent_rules" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_space_form_parent_rules_updated_by_user_id" ON "practice"."space_form_parent_rules" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_facility_typology_rules_space_function_concept_id" ON "practice"."facility_typology_rules" ("space_function_concept_id");

CREATE INDEX IF NOT EXISTS "ix_facility_typology_rules_rule_concept_id" ON "practice"."facility_typology_rules" ("rule_concept_id");

CREATE INDEX IF NOT EXISTS "ix_facility_typology_rules_created_by_user_id" ON "practice"."facility_typology_rules" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_facility_typology_rules_updated_by_user_id" ON "practice"."facility_typology_rules" ("updated_by_user_id");

-- ------------------------------------------------------------- E. RLS
-- Texto exacto de la política de 2026-08-05_tenant_rls.sql. Ese patch descubre toda tabla
-- con `tenant_id` y, si se vuelve a ejecutar, deja la misma política: no hay ventana en
-- la que una de estas tablas exista sin aislamiento por tenant. Los GRANT cubren el caso
-- en que las tablas nuevas las cree un rol distinto del que fijó los DEFAULT PRIVILEGES.
DO $$
DECLARE
    t text;
    tablas text[] := ARRAY[
        'practice.practice_sites',
        'practice.clinical_units',
        'practice.care_spaces',
        'practice.space_unit_assignments',
        'practice.site_declared_capacities'
    ];
    nuevas text[] := ARRAY[
        'practice.space_unit_assignments',
        'practice.site_declared_capacities',
        'practice.space_form_parent_rules',
        'practice.facility_typology_rules'
    ];
BEGIN
    IF EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'mantra_app') THEN
        FOREACH t IN ARRAY nuevas LOOP
            EXECUTE format('GRANT SELECT, INSERT, UPDATE, DELETE ON %s TO mantra_app', t);
        END LOOP;
    END IF;

    FOREACH t IN ARRAY tablas LOOP
        EXECUTE format('ALTER TABLE %s ENABLE ROW LEVEL SECURITY', t);
        EXECUTE format('ALTER TABLE %s FORCE ROW LEVEL SECURITY', t);
        EXECUTE format('DROP POLICY IF EXISTS tenant_isolation ON %s', t);
        EXECUTE format($pol$
        CREATE POLICY tenant_isolation ON %s
          USING (
            tenant_id = NULLIF(
              current_setting('app.current_tenant_id', true),
              ''
            )::uuid
            OR current_setting('app.system_context', true) = 'true'
          )
          WITH CHECK (
            tenant_id = NULLIF(
              current_setting('app.current_tenant_id', true),
              ''
            )::uuid
            OR current_setting('app.system_context', true) = 'true'
          )
        $pol$, t);
    END LOOP;
END $$;

-- ------------------------------------------------------------- verificación
DO $$
DECLARE
    n_columnas integer;
    n_tablas   integer;
    n_fk       integer;
    n_ux       integer;
    n_rls      integer;
    n_nn       integer;
BEGIN
    SELECT count(*) INTO n_columnas
      FROM information_schema.columns
     WHERE table_schema = 'practice'
       AND (table_name, column_name) IN (
            ('practice_sites', 'tenant_id'), ('practice_sites', 'snis_code'),
            ('practice_sites', 'subsector_concept_id'), ('practice_sites', 'care_level_concept_id'),
            ('practice_sites', 'facility_typology_concept_id'), ('practice_sites', 'managing_entity_name'),
            ('practice_sites', 'health_network_name'), ('practice_sites', 'sedes_department_concept_id'),
            ('practice_sites', 'municipality_name'),
            ('clinical_units', 'tenant_id'), ('clinical_units', 'description'),
            ('clinical_units', 'valid_from'), ('clinical_units', 'valid_to'),
            ('care_spaces', 'tenant_id'), ('care_spaces', 'form_concept_id'),
            ('care_spaces', 'description'), ('care_spaces', 'floor_number'),
            ('care_spaces', 'area_m2'), ('care_spaces', 'asepsis_concept_id'),
            ('care_spaces', 'pressure_concept_id'), ('care_spaces', 'air_changes_per_hour'),
            ('care_spaces', 'hvac_validated_on'), ('care_spaces', 'sex_restriction_concept_id'),
            ('care_spaces', 'age_group_concept_id'), ('care_spaces', 'bed_category_concept_id'),
            ('care_spaces', 'censable'), ('care_spaces', 'gln'),
            ('care_spaces', 'valid_from'), ('care_spaces', 'valid_to'));

    SELECT count(*) INTO n_tablas
      FROM information_schema.tables
     WHERE (table_schema, table_name) IN (
            ('practice', 'space_unit_assignments'), ('practice', 'site_declared_capacities'),
            ('practice', 'space_form_parent_rules'), ('practice', 'facility_typology_rules'));

    SELECT count(*) INTO n_fk
      FROM pg_constraint
     WHERE contype = 'f' AND convalidated
       AND conname = ANY (ARRAY[
            'fk_practice_sites_tenant_id', 'fk_practice_sites_subsector_concept_id',
            'fk_practice_sites_care_level_concept_id', 'fk_practice_sites_facility_typology_concept_id',
            'fk_practice_sites_sedes_department_concept_id',
            'fk_clinical_units_tenant_id',
            'fk_care_spaces_tenant_id', 'fk_care_spaces_form_concept_id',
            'fk_care_spaces_asepsis_concept_id', 'fk_care_spaces_pressure_concept_id',
            'fk_care_spaces_sex_restriction_concept_id', 'fk_care_spaces_age_group_concept_id',
            'fk_care_spaces_bed_category_concept_id'])
        OR (contype = 'f' AND convalidated AND array_length(conkey, 1) = 1 AND (  -- las compuestas son de f1b
               conname LIKE 'fk\_space\_unit\_assignments\_%'
            OR conname LIKE 'fk\_site\_declared\_capacities\_%'
            OR conname LIKE 'fk\_space\_form\_parent\_rules\_%'
            OR conname LIKE 'fk\_facility\_typology\_rules\_%'));

    SELECT count(*) INTO n_ux
      FROM pg_indexes
     WHERE schemaname = 'practice'
       AND indexname IN ('ux_practice_sites_snis_code', 'ux_care_spaces_site_code',
                         'ux_space_unit_assignments_current');

    SELECT count(*) INTO n_rls
      FROM pg_class c JOIN pg_namespace n ON n.oid = c.relnamespace
      JOIN pg_policies p ON p.schemaname = n.nspname AND p.tablename = c.relname
                        AND p.policyname = 'tenant_isolation'
     WHERE n.nspname = 'practice'
       AND c.relname IN ('practice_sites', 'clinical_units', 'care_spaces',
                         'space_unit_assignments', 'site_declared_capacities')
       AND c.relrowsecurity AND c.relforcerowsecurity;

    SELECT count(*) INTO n_nn
      FROM information_schema.columns
     WHERE table_schema = 'practice' AND table_name = 'practice_sites'
       AND column_name = 'tenant_id' AND is_nullable = 'NO';

    IF n_columnas <> 29 OR n_tablas <> 4 OR n_fk <> 33 OR n_ux <> 3 OR n_rls <> 5 OR n_nn <> 1 THEN
        RAISE EXCEPTION
            'v4.2.67 incompleto: columnas=% (29), tablas=% (4), fk=% (33), únicos=% (3), rls=% (5), practice_sites.tenant_id NOT NULL=% (1)',
            n_columnas, n_tablas, n_fk, n_ux, n_rls, n_nn;
    END IF;

    RAISE NOTICE 'v4.2.67 aplicado: 29 columnas, 4 tablas, 33 FKs validadas, 3 únicos, 5 tablas con RLS.';
END $$;

COMMIT;
