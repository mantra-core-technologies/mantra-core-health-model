-- ============================================================================
-- SALUD · patch (delegated_access · compartir temporalmente un estudio o una receta con un token revocable) sobre BD viva
-- Fecha: 2026-10-24 · issue #59 A-12 / PAC-DIAG-012 / DOC-RX-029
-- Idempotente (IF NOT EXISTS / IF EXISTS / duplicate_object). UNA sola pasada. Sin backfill.
-- Contexto: gen_ddl.py y gen_integrity.py ya emiten esto en SQL/<NN>_<schema>/ desde que los
-- .puml lo declaran, así que en un rebuild desde cero este patch NO hace falta. Existe para una
-- base ya aplicada y poblada: un CREATE TABLE IF NOT EXISTS no agrega columnas a una tabla que
-- ya existe. gen_apply.py no escanea SQL/patches/: no entra en apply_all.sql. Las sentencias se
-- copiaron de los archivos generados, no se escribieron a mano.
--
-- QUÉ CIERRA. Dos tablas nuevas: shared_access_links (el acceso: hash del secreto opaco, recurso
-- y alcance, vencimiento, revocación) y shared_access_link_uses (rastro de cada presentación del
-- token; UPDATE prohibido por trigger). En la base solo vive el hash del secreto, nunca el secreto.
-- Solo tablas nuevas: no hay nada que backfillear.
--
-- DELTAS ESPERADOS sobre la base viva:
--   tablas +2 · columnas +0 · NOT NULL quitados 0 · FKs +13 · índices +17 (-0) · constraints +1
-- ============================================================================

BEGIN;

CREATE TABLE IF NOT EXISTS "delegated_access"."shared_access_links" (
    "id" uuid NOT NULL,
    "tenant_id" uuid NOT NULL,
    "patient_profile_id" uuid NOT NULL,
    "resource_type_concept_id" uuid NOT NULL,
    "resource_id" uuid NOT NULL,
    "token_hash" varchar NOT NULL,
    "scope_concept_id" uuid NOT NULL,
    "recipient_kind_concept_id" uuid,
    "recipient_label" varchar,
    "purpose_of_use_concept_id" uuid,
    "expires_at" timestamptz NOT NULL,
    "revoked_at" timestamptz,
    "revoked_by_user_id" uuid,
    "revoke_reason_text" text,
    "status_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_shared_access_links" PRIMARY KEY ("id")
);

-- destino: directory.tenants (requiere schema directory)
DO $$ BEGIN
    ALTER TABLE "delegated_access"."shared_access_links"
        ADD CONSTRAINT "fk_shared_access_links_tenant_id" FOREIGN KEY ("tenant_id")
        REFERENCES "directory"."tenants" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: profiles.patient_profiles (requiere schema profiles)
DO $$ BEGIN
    ALTER TABLE "delegated_access"."shared_access_links"
        ADD CONSTRAINT "fk_shared_access_links_patient_profile_id" FOREIGN KEY ("patient_profile_id")
        REFERENCES "profiles"."patient_profiles" ("profile_id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "delegated_access"."shared_access_links"
        ADD CONSTRAINT "fk_shared_access_links_resource_type_concept_id" FOREIGN KEY ("resource_type_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "delegated_access"."shared_access_links"
        ADD CONSTRAINT "fk_shared_access_links_scope_concept_id" FOREIGN KEY ("scope_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "delegated_access"."shared_access_links"
        ADD CONSTRAINT "fk_shared_access_links_recipient_kind_concept_id" FOREIGN KEY ("recipient_kind_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "delegated_access"."shared_access_links"
        ADD CONSTRAINT "fk_shared_access_links_purpose_of_use_concept_id" FOREIGN KEY ("purpose_of_use_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "delegated_access"."shared_access_links"
        ADD CONSTRAINT "fk_shared_access_links_revoked_by_user_id" FOREIGN KEY ("revoked_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "delegated_access"."shared_access_links"
        ADD CONSTRAINT "fk_shared_access_links_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "delegated_access"."shared_access_links"
        ADD CONSTRAINT "fk_shared_access_links_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "delegated_access"."shared_access_links"
        ADD CONSTRAINT "fk_shared_access_links_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

CREATE UNIQUE INDEX IF NOT EXISTS "uq_shared_access_links_token_hash" ON "delegated_access"."shared_access_links" ("token_hash");

CREATE INDEX IF NOT EXISTS "ix_shared_access_links_tenant_id" ON "delegated_access"."shared_access_links" ("tenant_id");

CREATE INDEX IF NOT EXISTS "ix_shared_access_links_patient_profile_id" ON "delegated_access"."shared_access_links" ("patient_profile_id");

CREATE INDEX IF NOT EXISTS "ix_shared_access_links_resource" ON "delegated_access"."shared_access_links" ("resource_type_concept_id", "resource_id");

CREATE INDEX IF NOT EXISTS "ix_shared_access_links_scope_concept_id" ON "delegated_access"."shared_access_links" ("scope_concept_id");

CREATE INDEX IF NOT EXISTS "ix_shared_access_links_recipient_kind_concept_id" ON "delegated_access"."shared_access_links" ("recipient_kind_concept_id");

CREATE INDEX IF NOT EXISTS "ix_shared_access_links_purpose_of_use_concept_id" ON "delegated_access"."shared_access_links" ("purpose_of_use_concept_id");

CREATE INDEX IF NOT EXISTS "ix_shared_access_links_revoked_by_user_id" ON "delegated_access"."shared_access_links" ("revoked_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_shared_access_links_status_concept_id" ON "delegated_access"."shared_access_links" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_shared_access_links_created_by_user_id" ON "delegated_access"."shared_access_links" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_shared_access_links_updated_by_user_id" ON "delegated_access"."shared_access_links" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_shared_access_links_live_expiry" ON "delegated_access"."shared_access_links" ("expires_at") WHERE revoked_at IS NULL;

CREATE INDEX IF NOT EXISTS "ix_shared_access_links_patient_profile_id_created_at" ON "delegated_access"."shared_access_links" ("patient_profile_id", "created_at" DESC);

CREATE TABLE IF NOT EXISTS "delegated_access"."shared_access_link_uses" (
    "id" uuid NOT NULL,
    "shared_access_link_id" uuid NOT NULL,
    "action_concept_id" uuid NOT NULL,
    "outcome_concept_id" uuid NOT NULL,
    "source_ip" inet,
    "user_agent" varchar,
    "occurred_at" timestamptz NOT NULL,
    "created_at" timestamptz NOT NULL,
    CONSTRAINT "pk_shared_access_link_uses" PRIMARY KEY ("id")
);

DO $$ BEGIN
    ALTER TABLE "delegated_access"."shared_access_link_uses"
        ADD CONSTRAINT "fk_shared_access_link_uses_shared_access_link_id" FOREIGN KEY ("shared_access_link_id")
        REFERENCES "delegated_access"."shared_access_links" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "delegated_access"."shared_access_link_uses"
        ADD CONSTRAINT "fk_shared_access_link_uses_action_concept_id" FOREIGN KEY ("action_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "delegated_access"."shared_access_link_uses"
        ADD CONSTRAINT "fk_shared_access_link_uses_outcome_concept_id" FOREIGN KEY ("outcome_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

CREATE INDEX IF NOT EXISTS "ix_shared_access_link_uses_link_occurred" ON "delegated_access"."shared_access_link_uses" ("shared_access_link_id", "occurred_at" DESC);

CREATE INDEX IF NOT EXISTS "ix_shared_access_link_uses_action_concept_id" ON "delegated_access"."shared_access_link_uses" ("action_concept_id");

CREATE INDEX IF NOT EXISTS "ix_shared_access_link_uses_outcome_concept_id" ON "delegated_access"."shared_access_link_uses" ("outcome_concept_id");

CREATE INDEX IF NOT EXISTS "brin_shared_access_link_uses_occurred_at" ON "delegated_access"."shared_access_link_uses" USING brin ("occurred_at") WITH (pages_per_range=128);

-- ═══ shared_access_link_uses ═══
--   UPDATE: forbidden
-- UPDATE: forbidden → barrera física parcial (DELETE permitido: retención)
REVOKE UPDATE ON "delegated_access"."shared_access_link_uses" FROM PUBLIC;
DROP TRIGGER IF EXISTS trg_forbid_update ON "delegated_access"."shared_access_link_uses";
CREATE TRIGGER trg_forbid_update BEFORE UPDATE ON "delegated_access"."shared_access_link_uses"
    FOR EACH ROW EXECUTE FUNCTION "integrity"."forbid_mutation"();

COMMIT;
