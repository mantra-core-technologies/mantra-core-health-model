-- ============================================================================
-- SALUD · patch v4.0.8 → v4.0.9 sobre una BD viva · Fecha: 2026-08-05
-- Idempotente (CREATE TABLE / ADD COLUMN / CREATE INDEX ... IF NOT EXISTS)
--
-- Contexto: gen_ddl.py solo emite CREATE TABLE IF NOT EXISTS; en un rebuild desde
-- cero estas tablas, columnas e índices ya vienen en SQL/ y este patch no hace
-- falta. Existe únicamente para una base ya aplicada y poblada en v4.0.8.
-- gen_apply.py no escanea SQL/patches/ (solo directorios NN_schema), así que no
-- entra en apply_all.sql.
--
-- El entorno de referencia `mantra-redesa` NO necesitó este patch: se verificó
-- por reconstrucción completa (rebuild_stack.py → PASS, 1 180 tablas · 6 661 FKs
-- · 9 107 índices). Queda para cualquier otra base que no se pueda reconstruir.
--
-- Promueve al modelo lo que vivía como DDL suelto en
-- mantra-core-health-api/database/SQL/99_migrations/ (ver docs/architecture/
-- ddl-sources.md): 2 tablas, 1 columna y 2 índices únicos PARCIALES.
--
-- IMPORTANTE: aplicar con el rol propietario (mantra). Las FKs van DESPUÉS de las
-- tablas; si la base tiene filas huérfanas el ADD CONSTRAINT falla, que es el
-- comportamiento deseado — no las silencies con NOT VALID.
-- ============================================================================

-- 1. iam.email_verifications --------------------------------------------------
CREATE TABLE IF NOT EXISTS "iam"."email_verifications" (
    "id" uuid NOT NULL,
    "user_id" uuid NOT NULL,
    "email" varchar NOT NULL,
    "token_hash" varchar NOT NULL,
    "state_concept_id" uuid NOT NULL,
    "expires_at" timestamptz NOT NULL,
    "consumed_at" timestamptz,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_email_verifications" PRIMARY KEY ("id")
);

-- 2. iam.password_resets ------------------------------------------------------
CREATE TABLE IF NOT EXISTS "iam"."password_resets" (
    "id" uuid NOT NULL,
    "user_id" uuid NOT NULL,
    "external_subject" varchar NOT NULL,
    "token_hash" varchar NOT NULL,
    "state_concept_id" uuid NOT NULL,
    "expires_at" timestamptz NOT NULL,
    "consumed_at" timestamptz,
    "requested_ip" varchar,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_password_resets" PRIMARY KEY ("id")
);

-- 3. clinical.medication_requests.issue_idempotency_key -----------------------
ALTER TABLE "clinical"."medication_requests"
  ADD COLUMN IF NOT EXISTS "issue_idempotency_key" varchar;

-- 4. Índices ------------------------------------------------------------------
CREATE UNIQUE INDEX IF NOT EXISTS "ux_email_verifications_token_hash"
  ON "iam"."email_verifications" ("token_hash");
CREATE INDEX IF NOT EXISTS "ix_email_verifications_user"
  ON "iam"."email_verifications" ("user_id", "state_concept_id");

CREATE UNIQUE INDEX IF NOT EXISTS "ux_password_resets_token_hash"
  ON "iam"."password_resets" ("token_hash");
CREATE INDEX IF NOT EXISTS "ix_password_resets_user_state"
  ON "iam"."password_resets" ("user_id", "state_concept_id");

-- Idempotencia de la emisión de receta. PARCIAL: las emisiones históricas no
-- traen clave y no se les puede exigir retroactivamente.
CREATE UNIQUE INDEX IF NOT EXISTS "uq_medication_requests_issue_idempotency_key"
  ON "clinical"."medication_requests" ("issue_idempotency_key")
  WHERE issue_idempotency_key IS NOT NULL;

-- Una sola credencial de contraseña VIVA por external_subject. PARCIAL a
-- propósito: una credencial revocada o expirada con el mismo sujeto no debe
-- bloquear un alta nueva. Los concept_id van como UUID literales porque el
-- predicado de un índice parcial debe ser inmutable y Postgres no admite
-- subconsultas; son UUIDv5 deterministas sobre SALUD_UUID_NAMESPACE
-- (CRED_PASSWORD, STATE_ACTIVE, STATE_PENDING).
--
-- Si esta sentencia falla con "could not create unique index", la base YA tiene
-- credenciales de contraseña vivas duplicadas por sujeto: son cuentas dobles
-- creadas por la carrera que este índice cierra. Hay que resolverlas a mano
-- antes de reintentar; no relajes el predicado para que entre.
CREATE UNIQUE INDEX IF NOT EXISTS "ux_authentication_credentials_live_password_subject"
  ON "iam"."authentication_credentials" ("external_subject")
  WHERE method_concept_id = '37da1281-cc62-5032-b598-1eb39dc46060'
    AND external_subject IS NOT NULL
    AND state_concept_id IN (
      '38a1d301-f40d-5b17-a695-5e6d605f8b19',
      '2e38dae4-c0c2-52ff-b1c9-a954ff880a38'
    );

-- 5. Claves foráneas ----------------------------------------------------------
-- Las migraciones originales las declaraban como comentario `-- FK → ...`, es
-- decir sin integridad referencial real. Acá son constraints de verdad.
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_email_verifications_user_id') THEN
    ALTER TABLE "iam"."email_verifications"
      ADD CONSTRAINT "fk_email_verifications_user_id"
      FOREIGN KEY ("user_id") REFERENCES "iam"."users" ("id");
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_email_verifications_created_by_user_id') THEN
    ALTER TABLE "iam"."email_verifications"
      ADD CONSTRAINT "fk_email_verifications_created_by_user_id"
      FOREIGN KEY ("created_by_user_id") REFERENCES "iam"."users" ("id");
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_email_verifications_updated_by_user_id') THEN
    ALTER TABLE "iam"."email_verifications"
      ADD CONSTRAINT "fk_email_verifications_updated_by_user_id"
      FOREIGN KEY ("updated_by_user_id") REFERENCES "iam"."users" ("id");
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_email_verifications_state_concept_id') THEN
    ALTER TABLE "iam"."email_verifications"
      ADD CONSTRAINT "fk_email_verifications_state_concept_id"
      FOREIGN KEY ("state_concept_id") REFERENCES "terminology"."catalog_concepts" ("id");
  END IF;

  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_password_resets_user_id') THEN
    ALTER TABLE "iam"."password_resets"
      ADD CONSTRAINT "fk_password_resets_user_id"
      FOREIGN KEY ("user_id") REFERENCES "iam"."users" ("id");
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_password_resets_created_by_user_id') THEN
    ALTER TABLE "iam"."password_resets"
      ADD CONSTRAINT "fk_password_resets_created_by_user_id"
      FOREIGN KEY ("created_by_user_id") REFERENCES "iam"."users" ("id");
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_password_resets_updated_by_user_id') THEN
    ALTER TABLE "iam"."password_resets"
      ADD CONSTRAINT "fk_password_resets_updated_by_user_id"
      FOREIGN KEY ("updated_by_user_id") REFERENCES "iam"."users" ("id");
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_password_resets_state_concept_id') THEN
    ALTER TABLE "iam"."password_resets"
      ADD CONSTRAINT "fk_password_resets_state_concept_id"
      FOREIGN KEY ("state_concept_id") REFERENCES "terminology"."catalog_concepts" ("id");
  END IF;
END $$;
