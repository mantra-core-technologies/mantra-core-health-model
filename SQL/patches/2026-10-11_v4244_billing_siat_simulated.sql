-- 2026-10-11 · v4244 · Facturación SIAT SIMULADA (rutas /billing/simulated/*).
--
-- La factura FISCAL simulada (CUF/CUFD/XML ficticios y deterministas) cuelga de la
-- factura/cuenta por cobrar REAL (billing.invoices). Nada de esto es un documento
-- tributario válido: cada fila declara simulated = true y la tabla lo exige.
-- Idempotente: se puede aplicar N veces.

CREATE TABLE IF NOT EXISTS "billing"."siat_simulated_invoices" (
    "id"                  uuid          NOT NULL DEFAULT gen_random_uuid(),
    "invoice_id"          uuid          NOT NULL,           -- billing.invoices (la cuenta por cobrar)
    "encounter_id"        uuid,                             -- clinical.encounters (el cobro de la consulta)
    "practice_id"         uuid          NOT NULL,           -- practice.practices (el emisor)
    "patient_profile_id"  uuid          NOT NULL,
    "issuer_nit"          varchar(20)   NOT NULL,           -- NIT SINTÉTICO
    "invoice_number"      integer       NOT NULL,           -- correlativo del emisor
    "cuf"                 varchar(200)  NOT NULL,
    "cufd"                varchar(200)  NOT NULL,
    "issued_at_text"      varchar(23)   NOT NULL,           -- fechaEmision del XML, sin zona (yyyy-MM-ddTHH:mm:ss.SSS)
    "cabecera"            jsonb         NOT NULL,
    "detalle"             jsonb         NOT NULL,
    "xml"                 text          NOT NULL,
    "hash_archivo"        varchar(64)   NOT NULL,
    "compressed_bytes"    integer       NOT NULL,
    "status"              varchar(12)   NOT NULL,           -- VALIDATED | OBSERVED | REJECTED | ANNULLED
    "status_at_reception" varchar(12)   NOT NULL,
    "siat_response"       jsonb         NOT NULL,
    "events"              jsonb         NOT NULL DEFAULT '[]'::jsonb,
    "simulated"           boolean       NOT NULL DEFAULT true,
    "created_at"          timestamptz   NOT NULL DEFAULT now(),
    "updated_at"          timestamptz   NOT NULL DEFAULT now(),
    "created_by_user_id"  uuid,
    "updated_by_user_id"  uuid,
    "row_version"         integer       NOT NULL DEFAULT 1,
    CONSTRAINT "pk_siat_simulated_invoices" PRIMARY KEY ("id"),
    CONSTRAINT "ck_siat_simulated_invoices_simulated" CHECK ("simulated" = true),
    CONSTRAINT "ck_siat_simulated_invoices_status" CHECK ("status" IN ('VALIDATED','OBSERVED','REJECTED','ANNULLED'))
);

CREATE TABLE IF NOT EXISTS "billing"."siat_simulated_outbox" (
    "id"                  uuid          NOT NULL DEFAULT gen_random_uuid(),
    "siat_invoice_id"     uuid          NOT NULL,
    "to_email"            varchar(320)  NOT NULL,
    "attachments"         jsonb         NOT NULL DEFAULT '[]'::jsonb,
    "status"              varchar(24)   NOT NULL DEFAULT 'NOT_SENT_SIMULATED',
    "queued_at"           timestamptz   NOT NULL DEFAULT now(),
    "created_by_user_id"  uuid,
    CONSTRAINT "pk_siat_simulated_outbox" PRIMARY KEY ("id"),
    CONSTRAINT "ck_siat_simulated_outbox_status" CHECK ("status" = 'NOT_SENT_SIMULATED')
);

DO $$ BEGIN
    ALTER TABLE "billing"."siat_simulated_invoices"
        ADD CONSTRAINT "fk_siat_simulated_invoices_invoice_id" FOREIGN KEY ("invoice_id")
        REFERENCES "billing"."invoices" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "billing"."siat_simulated_invoices"
        ADD CONSTRAINT "fk_siat_simulated_invoices_practice_id" FOREIGN KEY ("practice_id")
        REFERENCES "practice"."practices" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "billing"."siat_simulated_outbox"
        ADD CONSTRAINT "fk_siat_simulated_outbox_siat_invoice_id" FOREIGN KEY ("siat_invoice_id")
        REFERENCES "billing"."siat_simulated_invoices" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

CREATE INDEX IF NOT EXISTS "ix_siat_simulated_invoices_invoice_id" ON "billing"."siat_simulated_invoices" ("invoice_id");
CREATE INDEX IF NOT EXISTS "ix_siat_simulated_invoices_encounter_id" ON "billing"."siat_simulated_invoices" ("encounter_id");
CREATE INDEX IF NOT EXISTS "ix_siat_simulated_invoices_patient_profile_id" ON "billing"."siat_simulated_invoices" ("patient_profile_id");
-- El correlativo no se repite por emisor; una recepción rechazada no consume número.
CREATE UNIQUE INDEX IF NOT EXISTS "uk_siat_simulated_invoices_practice_number"
    ON "billing"."siat_simulated_invoices" ("practice_id", "invoice_number") WHERE "status" <> 'REJECTED';
CREATE INDEX IF NOT EXISTS "ix_siat_simulated_outbox_siat_invoice_id" ON "billing"."siat_simulated_outbox" ("siat_invoice_id");
