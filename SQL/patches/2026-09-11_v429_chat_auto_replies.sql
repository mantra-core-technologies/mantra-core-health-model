-- ============================================================================
-- SALUD · patch v4.2.9 (community · respuesta automática del chat, F4.7)
-- Fecha: 2026-09-11
-- Idempotente (CREATE TABLE IF NOT EXISTS / ADD COLUMN IF NOT EXISTS /
-- CREATE INDEX IF NOT EXISTS / ADD CONSTRAINT bajo EXCEPTION duplicate_object).
-- UNA sola pasada. Sin backfill: no hay ninguna configuración viva que migrar.
--
-- Contexto: `gen_ddl.py` ya emite esta tabla y esta columna en
-- SQL/19_community/ desde que `diagram_19_community.puml` las declara, así que
-- en un rebuild desde cero este patch NO hace falta. Existe únicamente para una
-- base ya aplicada y poblada. `gen_apply.py` no escanea SQL/patches/ (sólo
-- directorios NN_schema), así que no entra en apply_all.sql.
--
-- QUÉ CIERRA. El propietario pidió «mensajes predeterminados de respuesta
-- después de inactividad por n tiempo, todo configurable». El frontend ya lo
-- tiene funcionando contra `localStorage` —rama `mockup`, `ChatAutoReply`—
-- porque el modelo no declaraba dónde guardarlo: `conversation_participants`
-- sólo tenía `muted_until`. Guardado en el navegador, la respuesta automática
-- tiene un límite que no se puede disimular: **sólo sale con la aplicación
-- abierta**, y un contestador que exige tener la pestaña abierta no es un
-- contestador. Esta tabla es lo que permite que la evalúe el servidor.
--
-- ADEMÁS cierra una deriva preexistente que apareció al tocar esta tabla: ver
-- el bloque 2b. Las columnas de F4.4 vivían sólo en la entidad ORM.
--
-- LAS DOS PIEZAS
--   1. `community.chat_auto_replies` — la configuración, UNA fila por perfil
--      público (`ux_chat_auto_replies_public_profile_id`). Es una preferencia
--      de la persona, no de una conversación.
--   2. `community.conversation_participants.last_auto_reply_at` — la marca del
--      descanso entre avisos. Vive en la fila del participante QUE RESPONDE,
--      que es exactamente una por (conversación, perfil): una tabla de bitácora
--      aparte diría lo mismo con un join.
--
-- LA REGLA, tal como la evalúa el servidor ante CADA mensaje entrante:
--   responder SI is_active
--          Y el destinatario lleva >= inactivity_minutes sin actividad
--          Y esa conversación no recibió un aviso en las últimas cooldown_hours
--          Y (NOT only_outside_business_hours O ahora cae fuera de [from, to]).
--
-- `business_hours_from > business_hours_to` es legal y significa que la franja
-- cruza la medianoche — el turno noche. Las dos son NULL cuando
-- `only_outside_business_hours` es false.
--
-- SIN CHECK, y no es un olvido: `gen_ddl.py` no tiene mecanismo para emitirlos
-- —ninguna de las 1 172 tablas generadas lleva uno—, así que los rangos de
-- `inactivity_minutes` (1–1440) y `cooldown_hours` (1–168) los hace cumplir la
-- aplicación, en el servicio y en el DTO. Queda registrado acá para el dueño
-- del modelo, como pide 02-CAMBIO-DE-MODELO-REQUERIDO.md.
-- ============================================================================

BEGIN;

-- 1 · La configuración ------------------------------------------------------

CREATE TABLE IF NOT EXISTS "community"."chat_auto_replies" (
    "id" uuid NOT NULL,
    "public_profile_id" uuid NOT NULL,
    "is_active" boolean NOT NULL,
    "inactivity_minutes" integer NOT NULL,
    "body_text" text NOT NULL,
    "cooldown_hours" integer NOT NULL,
    "only_outside_business_hours" boolean NOT NULL,
    "business_hours_from" time,
    "business_hours_to" time,
    "status_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_chat_auto_replies" PRIMARY KEY ("id")
);

-- 2 · La marca del descanso, en el participante que responde ----------------

ALTER TABLE "community"."conversation_participants"
    ADD COLUMN IF NOT EXISTS "last_auto_reply_at" timestamptz;

-- 2b · DERIVA CERRADA DE PASO (F4.4), no pedida pero sí necesaria -----------
--
-- `is_favorite`, `is_pinned` y `archived_at` existían SÓLO en la entidad
-- MikroORM: ni el `.puml` ni `SQL/19_community/` las declaraban. Una base
-- reconstruida desde el modelo no las tenía, y toda escritura del ORM contra
-- ellas moría. Se declaran ahora en el modelo —tipos y obligatoriedad son
-- exactamente los que la entidad ya usaba— y se agregan acá para las bases que
-- ya las tengan por otro camino: `IF NOT EXISTS` las deja como están.
--
-- El `DEFAULT` es obligatorio en estas dos y no contradice la política del
-- modelo, que aplica al DDL generado: acá hay filas vivas, y una columna
-- `NOT NULL` sin default no se puede agregar a una tabla poblada. El default se
-- quita después de rellenar, para que la base quede igual que un rebuild.
ALTER TABLE "community"."conversation_participants"
    ADD COLUMN IF NOT EXISTS "is_favorite" boolean NOT NULL DEFAULT false;
ALTER TABLE "community"."conversation_participants"
    ADD COLUMN IF NOT EXISTS "is_pinned" boolean NOT NULL DEFAULT false;
ALTER TABLE "community"."conversation_participants"
    ADD COLUMN IF NOT EXISTS "archived_at" timestamptz;

ALTER TABLE "community"."conversation_participants"
    ALTER COLUMN "is_favorite" DROP DEFAULT;
ALTER TABLE "community"."conversation_participants"
    ALTER COLUMN "is_pinned" DROP DEFAULT;

-- 3 · Índices ---------------------------------------------------------------

CREATE UNIQUE INDEX IF NOT EXISTS "ux_chat_auto_replies_public_profile_id"
    ON "community"."chat_auto_replies" ("public_profile_id");

CREATE INDEX IF NOT EXISTS "ix_chat_auto_replies_status_concept_id"
    ON "community"."chat_auto_replies" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_chat_auto_replies_created_by_user_id"
    ON "community"."chat_auto_replies" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_chat_auto_replies_updated_by_user_id"
    ON "community"."chat_auto_replies" ("updated_by_user_id");

-- 4 · Claves foráneas -------------------------------------------------------

DO $$ BEGIN
    ALTER TABLE "community"."chat_auto_replies"
        ADD CONSTRAINT "fk_chat_auto_replies_public_profile_id" FOREIGN KEY ("public_profile_id")
        REFERENCES "community"."public_profiles" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "community"."chat_auto_replies"
        ADD CONSTRAINT "fk_chat_auto_replies_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "community"."chat_auto_replies"
        ADD CONSTRAINT "fk_chat_auto_replies_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "community"."chat_auto_replies"
        ADD CONSTRAINT "fk_chat_auto_replies_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

COMMIT;

-- ============================================================================
-- Comprobación (debe devolver 1 tabla, 1 columna, 5 índices y 4 FKs).
-- Cinco y no cuatro: `pg_indexes` cuenta también el índice que Postgres crea
-- solo para la clave primaria (`pk_chat_auto_replies`), además de los 4
-- declarados en el modelo.
--
--   SELECT count(*) FROM information_schema.tables
--    WHERE table_schema = 'community' AND table_name = 'chat_auto_replies';
--
--   SELECT count(*) FROM information_schema.columns
--    WHERE table_schema = 'community' AND table_name = 'conversation_participants'
--      AND column_name = 'last_auto_reply_at';
--
--   SELECT count(*) FROM pg_indexes
--    WHERE schemaname = 'community' AND tablename = 'chat_auto_replies';
--
--   SELECT count(*) FROM pg_constraint
--    WHERE conrelid = '"community"."chat_auto_replies"'::regclass AND contype = 'f';
-- ============================================================================
