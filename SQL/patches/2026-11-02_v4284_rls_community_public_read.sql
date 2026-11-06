-- Migration patch: Allow public read of active public profiles and groups under RLS.
-- Addresses 404 PUBLIC_DIRECTORY_PROFILE_NOT_FOUND on anonymous directory endpoints
-- where no tenant context or system_context is set.

BEGIN;

DROP POLICY IF EXISTS public_profiles_public_read ON community.public_profiles;
CREATE POLICY public_profiles_public_read ON community.public_profiles
  FOR SELECT
  USING (
    visibility_concept_id = '0006f171-fd25-503d-906e-b77423a5f1d0'
    AND status_concept_id = '38a1d301-f40d-5b17-a695-5e6d605f8b19'
  );

DROP POLICY IF EXISTS groups_public_read ON community.groups;
CREATE POLICY groups_public_read ON community.groups
  FOR SELECT
  USING (
    visibility_concept_id = '9fa6291a-c8be-50b4-94a2-32e19cb1e735'
    AND status_concept_id = '38a1d301-f40d-5b17-a695-5e6d605f8b19'
  );

COMMIT;
