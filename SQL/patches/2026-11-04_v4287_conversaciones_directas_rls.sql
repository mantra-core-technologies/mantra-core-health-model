-- ============================================================================
-- SALUD · patch v4.2.87 (RLS · conversaciones directas sin tenant)
-- Fecha: 2026-11-04
-- Idempotente (DROP POLICY IF EXISTS antes de crear). Sin DDL de columnas ni
-- backfill. Se aplica DESPUÉS de `2026-08-05_tenant_rls.sql` (orden alfabético
-- de `patches/`, que es también cronológico).
--
-- Síntoma: con `RLS_ENFORCE=true`, «Chats → buscar a un profesional → abrir»
-- responde 500 («No pudimos abrir la conversación. El problema fue del
-- servidor…»), y la lista de chats sale vacía.
--
-- Causa: `community.conversations` tiene `tenant_id uuid` (nullable), así que
-- `2026-08-05_tenant_rls.sql` le puso `tenant_isolation`. Pero una conversación
-- directa es entre PERSONAS (un paciente y un médico, a menudo de
-- organizaciones distintas): `CommunityMessagingService.createDirectConversation`
-- la crea con `tenant_id` NULL, y es el único camino que crea conversaciones.
-- `NULL = <tenant del request>` no es verdadero, así que:
--   - el INSERT cae en el WITH CHECK: «new row violates row-level security
--     policy for table "conversations"» → 500;
--   - las ya creadas no se ven: la lista vuelve vacía, el hilo da 404 y
--     `findDirectBetween` no reutiliza la existente (vuelve a intentar el INSERT).
--
-- QUÉ ABRE, y qué no:
--   - Sólo las filas con `tenant_id IS NULL` de `community.conversations`: las
--     que no pertenecen a ninguna organización. Una conversación con tenant
--     sigue rigiéndose únicamente por `tenant_isolation` (las políticas
--     permisivas se combinan con OR).
--   - El WITH CHECK exige `tenant_id IS NULL`: no permite escribir ni mover una
--     conversación a un tenant ajeno.
--   - No ensancha lo que ya era legible: los participantes
--     (`conversation_participants`) y los mensajes (`direct_messages`) no tienen
--     `tenant_id` ni RLS. Quién puede leer o escribir en un hilo lo sigue
--     decidiendo la API (participante activo; si no, 404).
--
-- DELTAS ESPERADOS sobre la base viva:
--   políticas `conversations_without_tenant` en community.conversations  +1 (0 → 1)
-- ============================================================================

BEGIN;

DO $$
BEGIN
  IF to_regclass('community.conversations') IS NULL THEN
    RAISE EXCEPTION 'v4.2.87: falta community.conversations; aplicar antes el modelo base';
  END IF;
END $$;

DROP POLICY IF EXISTS conversations_without_tenant ON community.conversations;
CREATE POLICY conversations_without_tenant ON community.conversations
  USING (tenant_id IS NULL)
  WITH CHECK (tenant_id IS NULL);

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies
    WHERE schemaname = 'community'
      AND tablename  = 'conversations'
      AND policyname = 'conversations_without_tenant'
  ) THEN
    RAISE EXCEPTION 'v4.2.87 incompleto: falta la política conversations_without_tenant';
  END IF;
  RAISE NOTICE 'v4.2.87 aplicado: community.conversations sin tenant legible y escribible bajo RLS.';
END $$;

COMMIT;

-- Verificación (como rol de aplicación, con el tenant de un request fijado):
--   BEGIN; SET LOCAL ROLE mantra_app;
--   SELECT set_config('app.current_tenant_id', '<tenant-del-request>', true);
--   INSERT INTO community.conversations (id, conversation_type_concept_id,
--     status_concept_id, created_at, updated_at)
--   VALUES (gen_random_uuid(), gen_random_uuid(), gen_random_uuid(), now(), now()); -- INSERT 0 1
--   INSERT INTO community.conversations (id, tenant_id, conversation_type_concept_id,
--     status_concept_id, created_at, updated_at)
--   VALUES (gen_random_uuid(), '<otro-tenant>', gen_random_uuid(),
--     gen_random_uuid(), now(), now());                                               -- ERROR (RLS)
--   ROLLBACK;
