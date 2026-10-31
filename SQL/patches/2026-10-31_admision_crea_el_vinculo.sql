-- ============================================================================
-- SALUD · patch «Admisión crea el vínculo» (huella de ingreso · schema clinical)
-- sobre BD viva
-- Fecha: 2026-10-31 · Decisión del usuario registrada en CONTRATO-F2-F5.md «Desvíos»
--   (API-F2F5) del repositorio de documentación.
-- Requiere: 2026-10-29_infraestructura_f1b_seguridad.sql (UNIQUE (tenant_id, id) de
--   practice.practice_sites) y 2026-10-29_infraestructura_f3_clinical.sql (UNIQUE (tenant_id, id)
--   de clinical.encounters y la función clinical.assert_patient_matches_encounter()).
-- Idempotente (CREATE … IF NOT EXISTS / FK con `duplicate_object` / DROP … IF EXISTS antes de
-- cada trigger y política). Se puede aplicar N veces; la segunda pasada no cambia nada.
--
-- Contexto: gen_ddl.py y gen_integrity.py emiten la tabla, sus FKs, índices y la guarda
-- append-only en SQL/08_clinical/ desde que diagram_08 y diagram_33 la declaran; esas
-- sentencias se copiaron de los archivos generados. Lo escrito a mano: las FK compuestas por
-- tenant, el trigger de paciente del encuentro, privilegios, RLS y la verificación final.
--
-- QUÉ CIERRA.
--   clinical.patient_admission_footprints: la huella de un paciente en el tenant que deja un
--   INGRESO auditado (POST /clinical/admissions) cuando el paciente no tenía huella propia
--   (emergencia, derivación, traslado). Una por tenant y paciente (UNIQUE), append-only
--   (forbid_mutation). La lee la regla de huella de authz; no depende de que el paciente
--   tenga cuenta (es por persona, se vincula sola cuando la active).
--   Aislamiento: FK compuestas (tenant_id, encounter_id) → encounters y (tenant_id,
--   practice_site_id) → practice_sites; el paciente tiene que ser el del encuentro (trigger
--   clinical.assert_patient_matches_encounter de F3); RLS tenant_isolation.
--
-- LO QUE ESTE PATCH NO HACE.
--   - No siembra conceptos (ADM_ORIGIN_*, IDV_*): los siembra la API (clinical.concepts.ts).
--   - No crea historia: la tabla es append-only.
--   - No toca filas existentes (la tabla es nueva).
--
-- DELTAS ESPERADOS sobre la base viva (antes de este patch):
--   tablas +1 · FKs +10 (8 generadas + 2 compuestas) · índices +9 (8 + PK) · triggers +2
--   · políticas RLS +1
-- ============================================================================

BEGIN;

-- ------------------------------------------------------------- tabla (copiada de 02_tables)
CREATE TABLE IF NOT EXISTS "clinical"."patient_admission_footprints" (
    "id" uuid NOT NULL,
    "tenant_id" uuid NOT NULL,
    "patient_profile_id" uuid NOT NULL,
    "encounter_id" uuid NOT NULL,
    "practice_site_id" uuid NOT NULL,
    "admission_origin_concept_id" uuid NOT NULL,
    "identity_verification_method_concept_id" uuid NOT NULL,
    "identity_document_reference" varchar(64) NOT NULL,
    "referral_id" uuid,
    "recorded_by_user_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    CONSTRAINT "pk_patient_admission_footprints" PRIMARY KEY ("id")
);

-- ------------------------------------------------------------- FKs (copiadas de 03_fk_intra / 90_fk_deferred)
DO $$ BEGIN
    ALTER TABLE "clinical"."patient_admission_footprints"
        ADD CONSTRAINT "fk_patient_admission_footprints_encounter_id" FOREIGN KEY ("encounter_id")
        REFERENCES "clinical"."encounters" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "clinical"."patient_admission_footprints"
        ADD CONSTRAINT "fk_patient_admission_footprints_tenant_id" FOREIGN KEY ("tenant_id")
        REFERENCES "directory"."tenants" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "clinical"."patient_admission_footprints"
        ADD CONSTRAINT "fk_patient_admission_footprints_patient_profile_id" FOREIGN KEY ("patient_profile_id")
        REFERENCES "profiles"."patient_profiles" ("profile_id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "clinical"."patient_admission_footprints"
        ADD CONSTRAINT "fk_patient_admission_footprints_practice_site_id" FOREIGN KEY ("practice_site_id")
        REFERENCES "practice"."practice_sites" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "clinical"."patient_admission_footprints"
        ADD CONSTRAINT "fk_patient_admission_footprints_admission_origin_concept_id" FOREIGN KEY ("admission_origin_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

DO $$ BEGIN
    ALTER TABLE "clinical"."patient_admission_footprints"
        ADD CONSTRAINT "fk_patient_admission_footprints_identity_verification__4ddbb04f" FOREIGN KEY ("identity_verification_method_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

DO $$ BEGIN
    ALTER TABLE "clinical"."patient_admission_footprints"
        ADD CONSTRAINT "fk_patient_admission_footprints_referral_id" FOREIGN KEY ("referral_id")
        REFERENCES "clinical_ext"."referrals" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "clinical"."patient_admission_footprints"
        ADD CONSTRAINT "fk_patient_admission_footprints_recorded_by_user_id" FOREIGN KEY ("recorded_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- ------------------------------------------------------------- índices (copiados de 04_indexes)
CREATE UNIQUE INDEX IF NOT EXISTS "ux_patient_admission_footprints_tenant_patient" ON "clinical"."patient_admission_footprints" ("tenant_id", "patient_profile_id");

CREATE INDEX IF NOT EXISTS "ix_patient_admission_footprints_patient_profile_id" ON "clinical"."patient_admission_footprints" ("patient_profile_id");

CREATE INDEX IF NOT EXISTS "ix_patient_admission_footprints_encounter_id" ON "clinical"."patient_admission_footprints" ("encounter_id");

CREATE INDEX IF NOT EXISTS "ix_patient_admission_footprints_practice_site_id" ON "clinical"."patient_admission_footprints" ("practice_site_id");

CREATE INDEX IF NOT EXISTS "ix_patient_admission_footprints_admission_origin_concept_id" ON "clinical"."patient_admission_footprints" ("admission_origin_concept_id");

CREATE INDEX IF NOT EXISTS "ix_patient_admission_footprints_identity_verification__51230394" ON "clinical"."patient_admission_footprints" ("identity_verification_method_concept_id");

CREATE INDEX IF NOT EXISTS "ix_patient_admission_footprints_referral_id" ON "clinical"."patient_admission_footprints" ("referral_id");

CREATE INDEX IF NOT EXISTS "ix_patient_admission_footprints_recorded_by_user_id" ON "clinical"."patient_admission_footprints" ("recorded_by_user_id");

-- ------------------------------------------------------------- FKs compuestas por tenant (a mano)
DO $$ BEGIN
    ALTER TABLE "clinical"."patient_admission_footprints"
        ADD CONSTRAINT "fk_patient_admission_footprints_tenant_encounter"
        FOREIGN KEY ("tenant_id", "encounter_id") REFERENCES "clinical"."encounters" ("tenant_id", "id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "clinical"."patient_admission_footprints"
        ADD CONSTRAINT "fk_patient_admission_footprints_tenant_site"
        FOREIGN KEY ("tenant_id", "practice_site_id") REFERENCES "practice"."practice_sites" ("tenant_id", "id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- El paciente no tiene tenant: tiene que ser el del encuentro (función de F3).
DROP TRIGGER IF EXISTS trg_patient_matches_encounter ON "clinical"."patient_admission_footprints";
CREATE TRIGGER trg_patient_matches_encounter BEFORE INSERT
    ON "clinical"."patient_admission_footprints"
    FOR EACH ROW EXECUTE FUNCTION "clinical"."assert_patient_matches_encounter"();

-- ------------------------------------------------------------- guarda append-only (copiada de 05_constraints)
REVOKE UPDATE, DELETE ON "clinical"."patient_admission_footprints" FROM PUBLIC;
DROP TRIGGER IF EXISTS trg_forbid_mutation ON "clinical"."patient_admission_footprints";
CREATE TRIGGER trg_forbid_mutation BEFORE UPDATE OR DELETE ON "clinical"."patient_admission_footprints"
    FOR EACH ROW EXECUTE FUNCTION "integrity"."forbid_mutation"();

-- ------------------------------------------------------------- privilegios y RLS
-- Texto exacto de la política de 2026-08-05_tenant_rls.sql.
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'mantra_app') THEN
        EXECUTE 'GRANT SELECT, INSERT ON "clinical"."patient_admission_footprints" TO mantra_app';
        EXECUTE 'REVOKE UPDATE, DELETE, TRUNCATE ON "clinical"."patient_admission_footprints" FROM mantra_app';
    END IF;
    ALTER TABLE "clinical"."patient_admission_footprints" ENABLE ROW LEVEL SECURITY;
    ALTER TABLE "clinical"."patient_admission_footprints" FORCE ROW LEVEL SECURITY;
    DROP POLICY IF EXISTS tenant_isolation ON "clinical"."patient_admission_footprints";
    CREATE POLICY tenant_isolation ON "clinical"."patient_admission_footprints"
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
      );
END $$;

-- ------------------------------------------------------------- verificación
DO $$
DECLARE
    n_fk  int;
    n_ix  int;
    n_trg int;
    n_rls int;
BEGIN
    SELECT count(*) INTO n_fk FROM pg_constraint
     WHERE contype = 'f' AND conrelid = '"clinical"."patient_admission_footprints"'::regclass;
    SELECT count(*) INTO n_ix FROM pg_indexes
     WHERE schemaname = 'clinical' AND tablename = 'patient_admission_footprints';
    SELECT count(*) INTO n_trg FROM pg_trigger
     WHERE NOT tgisinternal AND tgrelid = '"clinical"."patient_admission_footprints"'::regclass
       AND tgname IN ('trg_forbid_mutation', 'trg_patient_matches_encounter');
    SELECT count(*) INTO n_rls FROM pg_policies
     WHERE schemaname = 'clinical' AND tablename = 'patient_admission_footprints' AND policyname = 'tenant_isolation';
    IF n_fk <> 10 OR n_ix <> 9 OR n_trg <> 2 OR n_rls <> 1 THEN
        RAISE EXCEPTION 'patient_admission_footprints: FKs % (esperadas 10), índices % (9), triggers % (2), RLS % (1)',
            n_fk, n_ix, n_trg, n_rls;
    END IF;
END $$;

COMMIT;
