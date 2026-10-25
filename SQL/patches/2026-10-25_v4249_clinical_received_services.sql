-- ============================================================================
-- SALUD · patch v4.2.49 (clinical · servicios recibidos) sobre BD viva
-- Fecha: 2026-10-25 · pedido: la historia del paciente muestra «Servicios recibidos»
-- y las intervenciones médicas realizadas son un tipo de servicio.
-- Idempotente (IF NOT EXISTS / duplicate_object / ON CONFLICT DO NOTHING).
--
-- Contexto: gen_ddl.py ya emite esta tabla, sus índices y sus FKs en
-- SQL/08_clinical/ desde que el .puml la declara, así que en un rebuild desde
-- cero la parte DDL de este patch NO hace falta. Existe para una base ya aplicada
-- y poblada. gen_apply.py no escanea SQL/patches/: no entra en apply_all.sql.
-- Las sentencias DDL se copiaron de los archivos generados, no se escribieron a mano.
--
-- QUÉ CIERRA. clinical.received_services guarda una fila por servicio que el
-- paciente recibió: una intervención médica realizada (clinical.procedures, con su
-- caso M53 cuando lo hay) o una vacuna aplicada (clinical.immunizations). El tipo
-- es un concepto del value set vs_received_service_type, así que un tipo nuevo no
-- exige migrar. Costo y cobertura NO se copian: la fila apunta, cuando el cobro es
-- inequívoco, a billing.service_catalog, billing.invoice_lines e
-- insurance.insurance_claim_lines, que siguen siendo los dueños del importe.
--
-- ORDEN. Los conceptos del value set los siembra la API al arrancar
-- (TerminologySeedService) o gen_seeds.py/load_seeds.py. El backfill de la parte 2
-- se salta con un aviso mientras esos conceptos no existan: correr el patch otra
-- vez cuando estén. Los ids de los conceptos son uuid5 deterministas (mismo
-- namespace que la API); no dependen de la base.
--
-- RLS: la tabla guarda datos de salud de un paciente, así que este patch le pone la
-- política custodian_tenant_isolation en la parte 3, con el texto exacto de
-- 2026-09-26_v4226_custodian_tenant_rls.sql. Ese patch sigue descubriendo toda tabla
-- con custodian_tenant_id y, si se vuelve a ejecutar, deja la misma política: no hay
-- una ventana en la que la tabla exista con datos y sin aislamiento por tenant.
--
-- DELTAS ESPERADOS sobre la base viva:
--   tablas +1 · FKs +17 · índices +19 (18 declarados + PK) · CHECK +1 · política RLS +1
--   filas: una por cada procedimiento completado, vacuna completada y caso M53
--   completado que no tenga ya su fila; una segunda corrida inserta 0.
-- ============================================================================

BEGIN;

-- ─── Parte 1 · estructura ───────────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS "clinical"."received_services" (
    "id" uuid NOT NULL,
    "custodian_tenant_id" uuid NOT NULL,
    "patient_profile_id" uuid NOT NULL,
    "encounter_id" uuid,
    "service_type_concept_id" uuid NOT NULL,
    "service_concept_id" uuid NOT NULL,
    "status_concept_id" uuid NOT NULL,
    "source_procedure_id" uuid,
    "source_immunization_id" uuid,
    "procedure_case_id" uuid,
    "service_catalog_id" uuid,
    "invoice_line_id" uuid,
    "insurance_claim_line_id" uuid,
    "performer_profile_id" uuid,
    "practice_site_id" uuid,
    "performed_at" timestamptz NOT NULL,
    "outcome_concept_id" uuid,
    "result_text" text,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_received_services" PRIMARY KEY ("id")
);

CREATE INDEX IF NOT EXISTS "ix_received_services_custodian_tenant_id" ON "clinical"."received_services" ("custodian_tenant_id");
CREATE INDEX IF NOT EXISTS "ix_received_services_patient_profile_id" ON "clinical"."received_services" ("patient_profile_id");
CREATE INDEX IF NOT EXISTS "ix_received_services_encounter_id" ON "clinical"."received_services" ("encounter_id");
CREATE INDEX IF NOT EXISTS "ix_received_services_service_type_concept_id" ON "clinical"."received_services" ("service_type_concept_id");
CREATE INDEX IF NOT EXISTS "ix_received_services_service_concept_id" ON "clinical"."received_services" ("service_concept_id");
CREATE INDEX IF NOT EXISTS "ix_received_services_status_concept_id" ON "clinical"."received_services" ("status_concept_id");
CREATE UNIQUE INDEX IF NOT EXISTS "uq_received_services_source_procedure_id" ON "clinical"."received_services" ("source_procedure_id") WHERE source_procedure_id IS NOT NULL;
CREATE UNIQUE INDEX IF NOT EXISTS "uq_received_services_source_immunization_id" ON "clinical"."received_services" ("source_immunization_id") WHERE source_immunization_id IS NOT NULL;
CREATE UNIQUE INDEX IF NOT EXISTS "uq_received_services_procedure_case_id" ON "clinical"."received_services" ("procedure_case_id") WHERE procedure_case_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS "ix_received_services_service_catalog_id" ON "clinical"."received_services" ("service_catalog_id");
CREATE INDEX IF NOT EXISTS "ix_received_services_invoice_line_id" ON "clinical"."received_services" ("invoice_line_id");
CREATE INDEX IF NOT EXISTS "ix_received_services_insurance_claim_line_id" ON "clinical"."received_services" ("insurance_claim_line_id");
CREATE INDEX IF NOT EXISTS "ix_received_services_performer_profile_id" ON "clinical"."received_services" ("performer_profile_id");
CREATE INDEX IF NOT EXISTS "ix_received_services_practice_site_id" ON "clinical"."received_services" ("practice_site_id");
CREATE INDEX IF NOT EXISTS "ix_received_services_outcome_concept_id" ON "clinical"."received_services" ("outcome_concept_id");
CREATE INDEX IF NOT EXISTS "ix_received_services_created_by_user_id" ON "clinical"."received_services" ("created_by_user_id");
CREATE INDEX IF NOT EXISTS "ix_received_services_updated_by_user_id" ON "clinical"."received_services" ("updated_by_user_id");
CREATE INDEX IF NOT EXISTS "ix_received_services_patient_performed_at" ON "clinical"."received_services" ("custodian_tenant_id", "patient_profile_id", "performed_at" DESC);

DO $$ BEGIN
    ALTER TABLE "clinical"."received_services"
        ADD CONSTRAINT "fk_received_services_encounter_id" FOREIGN KEY ("encounter_id")
        REFERENCES "clinical"."encounters" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "clinical"."received_services"
        ADD CONSTRAINT "fk_received_services_source_procedure_id" FOREIGN KEY ("source_procedure_id")
        REFERENCES "clinical"."procedures" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "clinical"."received_services"
        ADD CONSTRAINT "fk_received_services_source_immunization_id" FOREIGN KEY ("source_immunization_id")
        REFERENCES "clinical"."immunizations" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "clinical"."received_services"
        ADD CONSTRAINT "fk_received_services_custodian_tenant_id" FOREIGN KEY ("custodian_tenant_id")
        REFERENCES "directory"."tenants" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "clinical"."received_services"
        ADD CONSTRAINT "fk_received_services_patient_profile_id" FOREIGN KEY ("patient_profile_id")
        REFERENCES "profiles"."patient_profiles" ("profile_id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "clinical"."received_services"
        ADD CONSTRAINT "fk_received_services_service_type_concept_id" FOREIGN KEY ("service_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "clinical"."received_services"
        ADD CONSTRAINT "fk_received_services_service_concept_id" FOREIGN KEY ("service_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "clinical"."received_services"
        ADD CONSTRAINT "fk_received_services_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "clinical"."received_services"
        ADD CONSTRAINT "fk_received_services_procedure_case_id" FOREIGN KEY ("procedure_case_id")
        REFERENCES "procedures_perioperative"."procedure_cases" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "clinical"."received_services"
        ADD CONSTRAINT "fk_received_services_service_catalog_id" FOREIGN KEY ("service_catalog_id")
        REFERENCES "billing"."service_catalog" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "clinical"."received_services"
        ADD CONSTRAINT "fk_received_services_invoice_line_id" FOREIGN KEY ("invoice_line_id")
        REFERENCES "billing"."invoice_lines" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "clinical"."received_services"
        ADD CONSTRAINT "fk_received_services_insurance_claim_line_id" FOREIGN KEY ("insurance_claim_line_id")
        REFERENCES "insurance"."insurance_claim_lines" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "clinical"."received_services"
        ADD CONSTRAINT "fk_received_services_performer_profile_id" FOREIGN KEY ("performer_profile_id")
        REFERENCES "profiles"."health_practitioner_profiles" ("profile_id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "clinical"."received_services"
        ADD CONSTRAINT "fk_received_services_practice_site_id" FOREIGN KEY ("practice_site_id")
        REFERENCES "practice"."practice_sites" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "clinical"."received_services"
        ADD CONSTRAINT "fk_received_services_outcome_concept_id" FOREIGN KEY ("outcome_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "clinical"."received_services"
        ADD CONSTRAINT "fk_received_services_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "clinical"."received_services"
        ADD CONSTRAINT "fk_received_services_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

ALTER TABLE "clinical"."received_services" DROP CONSTRAINT IF EXISTS "ck_received_services_has_source";
ALTER TABLE "clinical"."received_services" ADD CONSTRAINT "ck_received_services_has_source" CHECK (("source_procedure_id" IS NOT NULL OR "source_immunization_id" IS NOT NULL OR "procedure_case_id" IS NOT NULL));

-- ─── Parte 2 · backfill de lo que ya existe ────────────────────────────────

DO $$
DECLARE
    v_intervention  CONSTANT uuid := 'b64df7ce-0143-5707-85f8-30390e48ad77'; -- clinical:RECEIVED_SERVICE_INTERVENTION
    v_vaccination   CONSTANT uuid := 'c21d54c4-0c5e-5563-bd61-d4c1c6cb3bc3'; -- clinical:RECEIVED_SERVICE_VACCINATION
    v_proc_done     CONSTANT uuid := 'a616cad7-0ca6-5b4c-94ab-2411520dee0b'; -- clinical:PROCEDURE_COMPLETED
    v_imm_done      CONSTANT uuid := 'ac2b51f9-25bf-510a-ba37-5733af9de730'; -- clinical:IMMUNIZATION_COMPLETED
    v_case_done     CONSTANT uuid := '973547f6-7478-5878-be3d-e8d3318161ee'; -- periop:case-status:completed
    v_n_proc        integer;
    v_n_imm         integer;
    v_n_case        integer;
BEGIN
    IF (SELECT count(*) FROM terminology.catalog_concepts WHERE id IN (v_intervention, v_vaccination)) < 2 THEN
        RAISE NOTICE 'v4.2.49: faltan los conceptos de vs_received_service_type; backfill omitido. Sembrarlos y volver a correr el patch.';
        RETURN;
    END IF;

    -- Procedimientos completados. El caso M53 que los tiene como primary_procedure_id
    -- se enlaza en la misma fila: un servicio, no dos. Costo/cobertura solo cuando el
    -- procedimiento tiene UN cargo (con varios, la fila no puede apuntar a uno solo y la
    -- API suma los cargos del caso).
    INSERT INTO clinical.received_services (
        id, custodian_tenant_id, patient_profile_id, encounter_id,
        service_type_concept_id, service_concept_id, status_concept_id,
        source_procedure_id, procedure_case_id,
        service_catalog_id, invoice_line_id, insurance_claim_line_id,
        performer_profile_id, practice_site_id, performed_at,
        outcome_concept_id, result_text,
        created_at, updated_at, row_version)
    SELECT gen_random_uuid(), p.custodian_tenant_id, p.patient_profile_id, p.encounter_id,
           v_intervention, p.code_concept_id, p.status_concept_id,
           p.id, pc.id,
           ch.billable_item_id, ch.invoice_line_id, ch.billing_claim_line_id,
           COALESCE(p.performer_profile_id, pc.primary_surgeon_profile_id),
           COALESCE(p.practice_site_id, pc.practice_site_id),
           COALESCE(p.occurrence_end_at, p.performed_at, p.occurrence_start_at, p.recorded_at, p.created_at),
           p.outcome_concept_id, p.note_text,
           p.created_at, p.updated_at, 1
      FROM clinical.procedures p
      LEFT JOIN LATERAL (
            SELECT c.id, c.primary_surgeon_profile_id, c.practice_site_id
              FROM procedures_perioperative.procedure_cases c
             WHERE c.primary_procedure_id = p.id
             ORDER BY c.created_at, c.id
             LIMIT 1) pc ON true
      LEFT JOIN LATERAL (
            SELECT MIN(i.billable_item_id::text)::uuid AS billable_item_id,
                   MIN(i.invoice_line_id::text)::uuid AS invoice_line_id,
                   MIN(i.billing_claim_line_id::text)::uuid AS billing_claim_line_id
              FROM procedures_perioperative.procedure_charge_items i
             WHERE i.procedure_id = p.id OR (pc.id IS NOT NULL AND i.procedure_case_id = pc.id)
            HAVING count(*) = 1) ch ON true
     WHERE p.status_concept_id = v_proc_done
    ON CONFLICT (source_procedure_id) WHERE source_procedure_id IS NOT NULL DO NOTHING;
    GET DIAGNOSTICS v_n_proc = ROW_COUNT;

    -- Vacunas completadas.
    INSERT INTO clinical.received_services (
        id, custodian_tenant_id, patient_profile_id,
        service_type_concept_id, service_concept_id, status_concept_id,
        source_immunization_id, performer_profile_id, performed_at,
        created_at, updated_at, row_version)
    SELECT gen_random_uuid(), i.custodian_tenant_id, i.patient_profile_id,
           v_vaccination, i.vaccine_concept_id, i.status_concept_id,
           i.id, i.administered_by_profile_id, COALESCE(i.administered_at, i.created_at),
           i.created_at, i.updated_at, 1
      FROM clinical.immunizations i
     WHERE i.status_concept_id = v_imm_done
    ON CONFLICT (source_immunization_id) WHERE source_immunization_id IS NOT NULL DO NOTHING;
    GET DIAGNOSTICS v_n_imm = ROW_COUNT;

    -- Casos M53 completados que no tienen procedimiento completado (o no tienen
    -- procedimiento): el caso es el servicio.
    INSERT INTO clinical.received_services (
        id, custodian_tenant_id, patient_profile_id, encounter_id,
        service_type_concept_id, service_concept_id, status_concept_id,
        procedure_case_id, performer_profile_id, practice_site_id, performed_at,
        created_at, updated_at, row_version)
    SELECT gen_random_uuid(), c.custodian_tenant_id, c.patient_profile_id, c.encounter_id,
           v_intervention, c.case_type_concept_id, c.status_concept_id,
           c.id, c.primary_surgeon_profile_id, c.practice_site_id,
           COALESCE(c.actual_end_at, c.actual_start_at, c.scheduled_end_at, c.scheduled_start_at, c.created_at),
           c.created_at, c.updated_at, 1
      FROM procedures_perioperative.procedure_cases c
     WHERE c.status_concept_id = v_case_done
       AND NOT EXISTS (SELECT 1 FROM clinical.received_services r WHERE r.procedure_case_id = c.id)
       AND NOT EXISTS (SELECT 1 FROM clinical.received_services r WHERE r.source_procedure_id = c.primary_procedure_id)
    ON CONFLICT (procedure_case_id) WHERE procedure_case_id IS NOT NULL DO NOTHING;
    GET DIAGNOSTICS v_n_case = ROW_COUNT;

    RAISE NOTICE 'v4.2.49 backfill: % procedimientos, % vacunas, % casos M53', v_n_proc, v_n_imm, v_n_case;
END $$;

-- ─── Parte 3 · aislamiento por tenant ───────────────────────────────────────
-- Después del backfill: con FORCE ROW LEVEL SECURITY el dueño de la tabla también
-- pasaría por la política, y el INSERT de la parte 2 no fija app.current_tenant_id.

ALTER TABLE clinical.received_services ENABLE ROW LEVEL SECURITY;
ALTER TABLE clinical.received_services FORCE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS custodian_tenant_isolation ON clinical.received_services;
CREATE POLICY custodian_tenant_isolation ON clinical.received_services
    USING (
        custodian_tenant_id = NULLIF(current_setting('app.current_tenant_id', true), '')::uuid
        OR current_setting('app.system_context', true) = 'true'
    )
    WITH CHECK (
        custodian_tenant_id = NULLIF(current_setting('app.current_tenant_id', true), '')::uuid
        OR current_setting('app.system_context', true) = 'true'
    );

COMMIT;
