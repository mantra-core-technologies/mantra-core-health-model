-- ============================================================================
-- SALUD · patch v4.2.7 (community · preferencias del chat y mensaje fijado) sobre BD viva
-- Fecha: 2026-09-09
-- Idempotente (ADD COLUMN IF NOT EXISTS / ADD CONSTRAINT en bloque DO / CREATE INDEX IF NOT EXISTS).
-- UNA sola pasada. Sin backfill: los valores por omisión (false / NULL) ya
-- describen a todas las filas existentes — nadie marcó nada todavía.
--
-- Contexto: gen_ddl.py emite estas columnas en SQL/19_community/ desde que se
-- declararon; en un rebuild desde cero este patch NO hace falta. Existe para
-- una base ya aplicada y poblada. gen_apply.py no escanea SQL/patches/.
--
-- QUÉ CIERRA. F4.4 y F4.6 del plan «Mensajería con la forma de WhatsApp»
-- (mantra-core-health/PLAN-CHAT-WHATSAPP.md). Favoritos, archivados y fijados
-- vivían en `localStorage` del navegador porque `conversation_participants` no
-- tenía dónde guardarlos: se perdían al cambiar de máquina y no los veía
-- ninguna otra pantalla. Y «fijar un mensaje» (la barra de arriba del hilo) no
-- tenía columna en `conversations`.
--
-- POR QUÉ EN `conversation_participants` Y NO EN `conversations`. Favorito,
-- fijado y archivado son de CADA lado: que yo archive la conversación con mi
-- médico no la archiva para él. La fila de participación es exactamente «esta
-- conversación vista por este perfil», así que es su lugar.
--
-- POR QUÉ `pinned_message_id` SÍ VA EN `conversations`. El mensaje fijado es
-- de la conversación, no de un lado: lo ven los dos, como en WhatsApp. Un solo
-- mensaje fijado a la vez (una columna, no una tabla): es lo que pide la
-- pantalla y lo que la barra superior puede mostrar.
--
-- POR QUÉ `archived_at` ES FECHA Y NO BOOLEANO. Porque «desde cuándo» sirve
-- para ordenar la lista de archivados, y NULL ya dice «no archivada» sin
-- necesitar otra columna.
-- ============================================================================

BEGIN;

ALTER TABLE "community"."conversation_participants"
    ADD COLUMN IF NOT EXISTS "is_favorite" boolean NOT NULL DEFAULT false,
    ADD COLUMN IF NOT EXISTS "is_pinned" boolean NOT NULL DEFAULT false,
    ADD COLUMN IF NOT EXISTS "archived_at" timestamptz;

ALTER TABLE "community"."conversations"
    ADD COLUMN IF NOT EXISTS "pinned_message_id" uuid;

DO $$ BEGIN
    ALTER TABLE "community"."conversations"
        ADD CONSTRAINT "fk_conversations_pinned_message_id" FOREIGN KEY ("pinned_message_id")
        REFERENCES "community"."direct_messages" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

CREATE INDEX IF NOT EXISTS "ix_conversation_participants_profile_pinned" ON "community"."conversation_participants" ("participant_profile_id", "is_pinned") WHERE "is_pinned";

CREATE INDEX IF NOT EXISTS "ix_conversations_pinned_message_id" ON "community"."conversations" ("pinned_message_id");

COMMIT;
