-- ============================================================================
-- SALUD · patch v4.2.91 (chat · reacciones a mensajes directos)
-- Fecha: 2026-11-06
-- Idempotente (IF NOT EXISTS / duplicate_object). Sin backfill.
--
-- Síntoma: en Mensajería, reaccionar a un mensaje con un emoji fallaba siempre
-- contra la API real. El front llamaba a
-- `PUT /community/conversations/:id/messages/:messageId/reaction`, una ruta que
-- sólo respondía la maqueta: la API no la publicaba y el modelo no tenía dónde
-- guardar la reacción.
--
-- Qué agrega: `community.message_reactions`, una fila por (mensaje, perfil) —
-- como WhatsApp, cada persona tiene UNA reacción por mensaje; elegir otro emoji
-- la reemplaza y quitarla borra la fila (`ux_message_reactions_message_profile`
-- lo garantiza en la base, no sólo en la API).
--
-- RLS: igual que `direct_messages` y `message_receipts`, la tabla no tiene
-- `tenant_id` (una conversación directa es entre personas de organizaciones
-- distintas). Quién puede reaccionar lo decide la API: participante activo de
-- la conversación; si no, 404. Los privilegios de `mantra_app` llegan por los
-- DEFAULT PRIVILEGES de `2026-08-05_tenant_rls.sql`.
--
-- DELTAS ESPERADOS sobre la base viva:
--   tablas community.message_reactions                     +1 (0 → 1)
--   índices ux/ix_message_reactions_*                         +3
--   FKs fk_message_reactions_*                                +3
-- ============================================================================

BEGIN;

CREATE TABLE IF NOT EXISTS "community"."message_reactions" (
    "id" uuid NOT NULL,
    "direct_message_id" uuid NOT NULL,
    "profile_id" uuid NOT NULL,
    "emoji" varchar(32) NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    CONSTRAINT "pk_message_reactions" PRIMARY KEY ("id")
);

CREATE UNIQUE INDEX IF NOT EXISTS "ux_message_reactions_message_profile"
    ON "community"."message_reactions" ("direct_message_id", "profile_id");

CREATE INDEX IF NOT EXISTS "ix_message_reactions_profile_id"
    ON "community"."message_reactions" ("profile_id");

CREATE INDEX IF NOT EXISTS "ix_message_reactions_created_by_user_id"
    ON "community"."message_reactions" ("created_by_user_id");

DO $$ BEGIN
    ALTER TABLE "community"."message_reactions"
        ADD CONSTRAINT "fk_message_reactions_direct_message_id" FOREIGN KEY ("direct_message_id")
        REFERENCES "community"."direct_messages" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "community"."message_reactions"
        ADD CONSTRAINT "fk_message_reactions_profile_id" FOREIGN KEY ("profile_id")
        REFERENCES "community"."public_profiles" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "community"."message_reactions"
        ADD CONSTRAINT "fk_message_reactions_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- El rol de runtime existe sólo donde se aplicó 2026-08-05_tenant_rls.sql.
DO $$ BEGIN
    IF EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'mantra_app') THEN
        GRANT SELECT, INSERT, UPDATE, DELETE ON "community"."message_reactions" TO mantra_app;
    END IF;
END $$;

COMMIT;
