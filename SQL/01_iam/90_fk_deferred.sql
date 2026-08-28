-- SALUD v4.0.10 · módulo 01 · schema iam
-- Generado de diagram_01_iam.puml — NO editar a mano.


-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "iam"."users"
        ADD CONSTRAINT "fk_users_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "iam"."users"
        ADD CONSTRAINT "fk_users_preferred_language_concept_id" FOREIGN KEY ("preferred_language_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "iam"."users"
        ADD CONSTRAINT "fk_users_residence_country_concept_id" FOREIGN KEY ("residence_country_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "iam"."users"
        ADD CONSTRAINT "fk_users_data_residency_region_concept_id" FOREIGN KEY ("data_residency_region_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "iam"."users"
        ADD CONSTRAINT "fk_users_mfa_status_concept_id" FOREIGN KEY ("mfa_status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "iam"."users"
        ADD CONSTRAINT "fk_users_legal_basis_concept_id" FOREIGN KEY ("legal_basis_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "iam"."account_activations"
        ADD CONSTRAINT "fk_account_activations_state_concept_id" FOREIGN KEY ("state_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: authz.patient_legal_representations (requiere schema authz)
DO $$ BEGIN
    ALTER TABLE "iam"."account_activations"
        ADD CONSTRAINT "fk_account_activations_legal_representation_id" FOREIGN KEY ("legal_representation_id")
        REFERENCES "authz"."patient_legal_representations" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "iam"."email_verifications"
        ADD CONSTRAINT "fk_email_verifications_state_concept_id" FOREIGN KEY ("state_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "iam"."password_resets"
        ADD CONSTRAINT "fk_password_resets_state_concept_id" FOREIGN KEY ("state_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "iam"."authentication_credentials"
        ADD CONSTRAINT "fk_authentication_credentials_method_concept_id" FOREIGN KEY ("method_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "iam"."authentication_credentials"
        ADD CONSTRAINT "fk_authentication_credentials_hash_algorithm_concept_id" FOREIGN KEY ("hash_algorithm_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "iam"."authentication_credentials"
        ADD CONSTRAINT "fk_authentication_credentials_state_concept_id" FOREIGN KEY ("state_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "iam"."mfa_factors"
        ADD CONSTRAINT "fk_mfa_factors_factor_type_concept_id" FOREIGN KEY ("factor_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "iam"."mfa_factors"
        ADD CONSTRAINT "fk_mfa_factors_state_concept_id" FOREIGN KEY ("state_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "iam"."devices"
        ADD CONSTRAINT "fk_devices_platform_concept_id" FOREIGN KEY ("platform_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "iam"."sessions"
        ADD CONSTRAINT "fk_sessions_state_concept_id" FOREIGN KEY ("state_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "iam"."refresh_tokens"
        ADD CONSTRAINT "fk_refresh_tokens_state_concept_id" FOREIGN KEY ("state_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "iam"."user_global_roles"
        ADD CONSTRAINT "fk_user_global_roles_role_concept_id" FOREIGN KEY ("role_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "iam"."user_global_roles"
        ADD CONSTRAINT "fk_user_global_roles_state_concept_id" FOREIGN KEY ("state_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "iam"."security_events"
        ADD CONSTRAINT "fk_security_events_event_type_concept_id" FOREIGN KEY ("event_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "iam"."security_events"
        ADD CONSTRAINT "fk_security_events_outcome_concept_id" FOREIGN KEY ("outcome_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: directory.tenants (requiere schema directory)
DO $$ BEGIN
    ALTER TABLE "iam"."api_keys"
        ADD CONSTRAINT "fk_api_keys_tenant_id" FOREIGN KEY ("tenant_id")
        REFERENCES "directory"."tenants" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "iam"."api_keys"
        ADD CONSTRAINT "fk_api_keys_hash_algorithm_concept_id" FOREIGN KEY ("hash_algorithm_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: authz.service_principals (requiere schema authz)
DO $$ BEGIN
    ALTER TABLE "iam"."api_keys"
        ADD CONSTRAINT "fk_api_keys_service_principal_id" FOREIGN KEY ("service_principal_id")
        REFERENCES "authz"."service_principals" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: authz.ip_access_rules (requiere schema authz)
DO $$ BEGIN
    ALTER TABLE "iam"."api_keys"
        ADD CONSTRAINT "fk_api_keys_ip_access_rule_id" FOREIGN KEY ("ip_access_rule_id")
        REFERENCES "authz"."ip_access_rules" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "iam"."api_keys"
        ADD CONSTRAINT "fk_api_keys_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "iam"."api_key_scopes"
        ADD CONSTRAINT "fk_api_key_scopes_scope_concept_id" FOREIGN KEY ("scope_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: directory.tenants (requiere schema directory)
DO $$ BEGIN
    ALTER TABLE "iam"."account_lockouts"
        ADD CONSTRAINT "fk_account_lockouts_tenant_id" FOREIGN KEY ("tenant_id")
        REFERENCES "directory"."tenants" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "iam"."account_lockouts"
        ADD CONSTRAINT "fk_account_lockouts_reason_concept_id" FOREIGN KEY ("reason_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "iam"."account_lockouts"
        ADD CONSTRAINT "fk_account_lockouts_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;
