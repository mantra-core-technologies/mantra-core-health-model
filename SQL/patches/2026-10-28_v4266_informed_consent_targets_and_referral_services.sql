-- 2026-10-28 · v4266 · Consentimiento informado dirigido y derivación a servicios específicos.
--
-- consent.treatment_informed_consents deja de estar atado sólo a encounter_id +
-- procedure_code_concept_id: se DIRIGE a un objeto clínico (target_type/target_id/target_label:
-- receta, orden de análisis/estudio, derivación, procedimiento o plan de cuidados) y registra
-- los elementos de la información debida (diagnóstico, objetivo, beneficios, riesgos generales
-- y personalizados, alternativas, consecuencias de no aceptar, preguntas del paciente), el
-- consentimiento por representación (con el asentimiento del menor o de la persona con
-- discapacidad), el testigo externo a la plataforma, el profesional que informa, el canal y el
-- idioma de la información, la constancia del derecho a revocar, las excepciones legales (y
-- cuándo se informó a posteriori tras una urgencia) y el motivo de revocación.
--
-- clinical_ext.referrals suma el destino específico (sede de la
-- plataforma → directory.branches, o doctor/organización externa), el servicio pedido, el
-- contenido mínimo de la hoja de referencia, el consentimiento que la cubre
-- (→ consent.treatment_informed_consents) y el cierre del circuito (rechazo, contrarreferencia).
--
-- Todas las columnas son NULLABLE: las filas existentes siguen siendo válidas. Las
-- enumeraciones son varchar + CHECK (un NULL pasa el CHECK). Mismos nombres que el modelo
-- (diagram_07, diagram_18 y diagram_33 v4.2.63), salvo el tipo de derivación de referrals: va en
-- referral_type_concept_id (patch v4265), no en una columna varchar aparte. Idempotente: se puede
-- aplicar N veces.

-- ─── consent.treatment_informed_consents ────────────────────────────────────────────────

ALTER TABLE "consent"."treatment_informed_consents"
    ADD COLUMN IF NOT EXISTS "target_type" varchar(24),
    ADD COLUMN IF NOT EXISTS "target_id" uuid,
    ADD COLUMN IF NOT EXISTS "target_label" varchar(300),
    ADD COLUMN IF NOT EXISTS "diagnosis_text" text,
    ADD COLUMN IF NOT EXISTS "purpose_text" text,
    ADD COLUMN IF NOT EXISTS "benefits_text" text,
    ADD COLUMN IF NOT EXISTS "risks_text" text,
    ADD COLUMN IF NOT EXISTS "personalized_risks_text" text,
    ADD COLUMN IF NOT EXISTS "alternatives_text" text,
    ADD COLUMN IF NOT EXISTS "refusal_consequences_text" text,
    ADD COLUMN IF NOT EXISTS "patient_questions_text" text,
    ADD COLUMN IF NOT EXISTS "granted_by" varchar(24),
    ADD COLUMN IF NOT EXISTS "representative_name" varchar(200),
    ADD COLUMN IF NOT EXISTS "representative_document" varchar(60),
    ADD COLUMN IF NOT EXISTS "representative_relationship" varchar(80),
    ADD COLUMN IF NOT EXISTS "incapacity_reason" text,
    ADD COLUMN IF NOT EXISTS "informed_by_profile_id" uuid,
    ADD COLUMN IF NOT EXISTS "channel" varchar(16),
    ADD COLUMN IF NOT EXISTS "exception_type" varchar(32),
    ADD COLUMN IF NOT EXISTS "exception_justification" text,
    ADD COLUMN IF NOT EXISTS "withdrawal_reason" text,
    ADD COLUMN IF NOT EXISTS "witness_name" varchar(200),
    ADD COLUMN IF NOT EXISTS "witness_document" varchar(60),
    ADD COLUMN IF NOT EXISTS "information_language" varchar(40),
    ADD COLUMN IF NOT EXISTS "assent_obtained" boolean,
    ADD COLUMN IF NOT EXISTS "assent_notes" text,
    ADD COLUMN IF NOT EXISTS "revocation_right_informed" boolean,
    ADD COLUMN IF NOT EXISTS "post_emergency_informed_at" timestamptz;

DO $$ BEGIN
    ALTER TABLE "consent"."treatment_informed_consents"
        ADD CONSTRAINT "ck_treatment_informed_consents_target_type"
        CHECK ("target_type" IN ('MEDICATION_REQUEST','SERVICE_REQUEST','REFERRAL','PROCEDURE','CARE_PLAN'));
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "consent"."treatment_informed_consents"
        ADD CONSTRAINT "ck_treatment_informed_consents_granted_by"
        CHECK ("granted_by" IN ('PATIENT','LEGAL_REPRESENTATIVE','GUARDIAN','SUBSTITUTE_RELATIVE'));
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "consent"."treatment_informed_consents"
        ADD CONSTRAINT "ck_treatment_informed_consents_channel"
        CHECK ("channel" IN ('IN_PERSON','TELEHEALTH'));
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "consent"."treatment_informed_consents"
        ADD CONSTRAINT "ck_treatment_informed_consents_exception_type"
        CHECK ("exception_type" IN ('EMERGENCY','PUBLIC_HEALTH_RISK','PATIENT_WAIVER'));
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

CREATE INDEX IF NOT EXISTS "ix_treatment_informed_consents_target"
    ON "consent"."treatment_informed_consents" ("target_type", "target_id");

CREATE INDEX IF NOT EXISTS "ix_treatment_informed_consents_patient_target"
    ON "consent"."treatment_informed_consents" ("patient_profile_id", "target_type");

-- ─── clinical_ext.referrals ─────────────────────────────────────────────────────────────

ALTER TABLE "clinical_ext"."referrals"
    ADD COLUMN IF NOT EXISTS "target_branch_id" uuid,
    ADD COLUMN IF NOT EXISTS "target_external_name" varchar(200),
    ADD COLUMN IF NOT EXISTS "target_external_contact" varchar(200),
    ADD COLUMN IF NOT EXISTS "requested_service_text" varchar(500),
    ADD COLUMN IF NOT EXISTS "requested_service_concept_id" uuid,
    ADD COLUMN IF NOT EXISTS "diagnosis_text" text,
    ADD COLUMN IF NOT EXISTS "clinical_summary" text,
    ADD COLUMN IF NOT EXISTS "treatment_given_text" text,
    ADD COLUMN IF NOT EXISTS "informed_consent_id" uuid,
    ADD COLUMN IF NOT EXISTS "reject_reason" text,
    ADD COLUMN IF NOT EXISTS "counter_referral_text" text,
    ADD COLUMN IF NOT EXISTS "counter_referral_at" timestamptz;

DO $$ BEGIN
    ALTER TABLE "clinical_ext"."referrals"
        ADD CONSTRAINT "fk_referrals_target_branch_id" FOREIGN KEY ("target_branch_id")
        REFERENCES "directory"."branches" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "clinical_ext"."referrals"
        ADD CONSTRAINT "fk_referrals_requested_service_concept_id" FOREIGN KEY ("requested_service_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "clinical_ext"."referrals"
        ADD CONSTRAINT "fk_referrals_informed_consent_id" FOREIGN KEY ("informed_consent_id")
        REFERENCES "consent"."treatment_informed_consents" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

CREATE INDEX IF NOT EXISTS "ix_referrals_target_branch"
    ON "clinical_ext"."referrals" ("target_branch_id");

CREATE INDEX IF NOT EXISTS "ix_referrals_requested_service_concept_id"
    ON "clinical_ext"."referrals" ("requested_service_concept_id");

CREATE INDEX IF NOT EXISTS "ix_referrals_informed_consent_id"
    ON "clinical_ext"."referrals" ("informed_consent_id");
