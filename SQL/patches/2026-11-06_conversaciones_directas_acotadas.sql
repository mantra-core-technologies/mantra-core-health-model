-- ============================================================================
-- SALUD · patch (RLS · conversaciones directas sin tenant, acotadas)
-- Fecha: 2026-11-06
-- Idempotente (DROP POLICY / DROP TRIGGER IF EXISTS antes de crear). Sin DDL de
-- columnas ni backfill. Se aplica DESPUÉS de `2026-11-04_v4287_conversaciones_
-- directas_rls.sql` (orden alfabético de `patches/`), y reemplaza su política.
--
-- Qué había: `conversations_without_tenant` daba SELECT, INSERT, UPDATE y DELETE
-- sobre toda fila con `tenant_id IS NULL`. Eso dejaba dos agujeros que nada en la
-- API necesita:
--   1. Cualquier sesión de tenant podía BORRAR una conversación directa ajena.
--      La API nunca borra conversaciones (no hay `remove`/`nativeDelete` sobre
--      `community.conversations`); la purga de sistema sigue pudiendo, por
--      `tenant_isolation` con `app.system_context`.
--   2. Una conversación DE UN TENANT podía pasarse a `tenant_id NULL`: el UPDATE
--      pasaba el USING de `tenant_isolation` (la fila era del tenant) y el
--      WITH CHECK de `conversations_without_tenant` (la fila nueva es sin
--      tenant), porque las políticas permisivas se combinan con OR. Desde ahí la
--      leía cualquiera.
--
-- Qué queda:
--   - SELECT, INSERT y UPDATE sólo de conversaciones directas sin tenant: sin
--     tenant Y sin grupo. Es lo único que crea `createDirectConversation`, el
--     único camino que escribe conversaciones sin tenant.
--   - Ninguna política de DELETE para filas sin tenant.
--   - Un disparador que impide cambiar `tenant_id` o `group_id` de una
--     conversación ya creada (cierra el punto 2 sea cual sea la política que lo
--     deje pasar). Ningún flujo de la API cambia el dueño de una conversación.
--
-- Qué NO cambia: quién es participante de un hilo lo sigue decidiendo la API
-- (participante activo; si no, 404). La base no sabe qué perfil es de quién:
-- el participante es un `community.public_profiles` con dueño polimórfico
-- (persona, profesional o bandeja de una organización que atiende su personal).
-- Llevar esa regla a la base exige que la sesión declare su usuario y duplicar
-- la lógica de titularidad de `CommunityVisibilityService`: es otra decisión.
--
-- DELTAS ESPERADOS sobre la base viva:
--   política conversations_without_tenant                      −1
--   políticas conversations_direct_{read,insert,update}         +3
--   disparador trg_conversation_owner_is_fixed                  +1
-- ============================================================================

BEGIN;

DO $$
BEGIN
  IF to_regclass('community.conversations') IS NULL THEN
    RAISE EXCEPTION 'conversaciones directas acotadas: falta community.conversations; aplicar antes el modelo base';
  END IF;
END $$;

DROP POLICY IF EXISTS conversations_without_tenant ON community.conversations;

DROP POLICY IF EXISTS conversations_direct_read ON community.conversations;
CREATE POLICY conversations_direct_read ON community.conversations
  FOR SELECT
  USING (tenant_id IS NULL AND group_id IS NULL);

DROP POLICY IF EXISTS conversations_direct_insert ON community.conversations;
CREATE POLICY conversations_direct_insert ON community.conversations
  FOR INSERT
  WITH CHECK (tenant_id IS NULL AND group_id IS NULL);

DROP POLICY IF EXISTS conversations_direct_update ON community.conversations;
CREATE POLICY conversations_direct_update ON community.conversations
  FOR UPDATE
  USING (tenant_id IS NULL AND group_id IS NULL)
  WITH CHECK (tenant_id IS NULL AND group_id IS NULL);

-- El dueño de una conversación (tenant y grupo) se fija al crearla.
CREATE SCHEMA IF NOT EXISTS integrity;
CREATE OR REPLACE FUNCTION integrity.conversation_owner_is_fixed()
RETURNS trigger LANGUAGE plpgsql SET search_path = pg_catalog, public AS $$
BEGIN
  IF NEW.tenant_id IS DISTINCT FROM OLD.tenant_id
     OR NEW.group_id IS DISTINCT FROM OLD.group_id THEN
    RAISE EXCEPTION 'community.conversations: el tenant y el grupo de una conversación no se cambian'
      USING ERRCODE = 'check_violation';
  END IF;
  RETURN NEW;
END $$;
REVOKE ALL ON FUNCTION integrity.conversation_owner_is_fixed() FROM PUBLIC;

DROP TRIGGER IF EXISTS trg_conversation_owner_is_fixed ON community.conversations;
CREATE TRIGGER trg_conversation_owner_is_fixed
  BEFORE UPDATE OF tenant_id, group_id ON community.conversations
  FOR EACH ROW EXECUTE FUNCTION integrity.conversation_owner_is_fixed();

DO $$
DECLARE
  faltan text := '';
  p text;
BEGIN
  FOREACH p IN ARRAY ARRAY['conversations_direct_read', 'conversations_direct_insert',
                           'conversations_direct_update'] LOOP
    IF NOT EXISTS (SELECT 1 FROM pg_policies
                   WHERE schemaname = 'community' AND tablename = 'conversations'
                     AND policyname = p) THEN
      faltan := faltan || ' política:' || p;
    END IF;
  END LOOP;
  IF EXISTS (SELECT 1 FROM pg_policies
             WHERE schemaname = 'community' AND tablename = 'conversations'
               AND policyname = 'conversations_without_tenant') THEN
    faltan := faltan || ' sigue:conversations_without_tenant';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_trigger
                 WHERE tgname = 'trg_conversation_owner_is_fixed' AND NOT tgisinternal) THEN
    faltan := faltan || ' disparador:trg_conversation_owner_is_fixed';
  END IF;
  IF faltan <> '' THEN
    RAISE EXCEPTION 'conversaciones directas acotadas incompleto:%', faltan;
  END IF;
  RAISE NOTICE 'conversaciones directas acotadas: sin DELETE, sólo directas sin grupo, dueño fijo.';
END $$;

COMMIT;
