-- ============================================================================
-- SALUD · patch v4.2.73 (revision de seguridad del gobierno de accesos, ronda 1) sobre BD viva
-- Fecha: 2026-11-03
-- Idempotente (ADD COLUMN IF NOT EXISTS, backfill solo de lo NULL, FKs con duplicate_object, triggers con DROP IF EXISTS + CREATE,
-- politicas con DROP IF EXISTS + CREATE, funciones con CREATE OR REPLACE). UNA sola transaccion; se puede volver a correr.
-- Orden de aplicacion: v4269 -> v4272 -> v4273 (y 2026-08-05_tenant_rls.sql puede ir antes o despues: es idempotente y conserva lo de aqui).
--
-- QUE ARREGLA (ids de REVISION-SEG-GOBIERNO-A.md)
--   A-M1  organization_user_assignments y practitioner_delegate_assignments NO tenian tenant_id ni RLS: con el contexto de OTRA organizacion
--         mantra_app las leia y las actualizaba (evidencia en BD: 9 de 9 filas visibles y 1 de 1 fila ajena actualizada, ver el informe).
--         Ahora llevan tenant_id NOT NULL (FK a directory.tenants, indice), el disparador integrity.support_tenant_consistency verifica que sea
--         el de su membresia, sus nodos de alcance, su set, su vinculo y su doctor, y tienen tenant_isolation + FORCE RLS.
--         care_spaces, healthcare_services, practitioner_role_assignments y community.direct_messages NO se migran aqui (son del modulo practice /
--         community y tienen decenas de puntos de escritura): la API las acota con guardas de servicio (ver el informe).
--   A-B1  el v4269 y el v4272 solo avisaban (NOTICE) si la base no tenia RLS y dejaban sus tablas abiertas: ahora crean las politicas siempre
--         (se corrigieron en esos archivos) y esta seccion 3 las reafirma en las 27 tablas y FALLA si falta alguna.
--   A-B2  access_decision_log (WORM): mantra_app conservaba UPDATE y DELETE (solo el disparador de fila los frenaba) y ningun disparador
--         cubria TRUNCATE. Ahora: REVOKE UPDATE, DELETE, TRUNCATE a PUBLIC y a mantra_app + disparador de sentencia BEFORE TRUNCATE.
--   A-B6  delegated_access.support_access_allowed() (referencia gruesa) ignoraba las concesiones DENY y las acciones reemplazadas: ahora exige
--         efecto ALLOW y accion vigente en la concesion que cubre, y NIEGA si hay una concesion DENY viva del mismo vinculo y permiso que
--         cubra (o pueda cubrir) el objetivo. Sigue siendo una REFERENCIA: no es el PEP (la verdad es SupportAccessPolicy de la API).
--
-- DELTAS ESPERADOS sobre una base con v4269 + v4272
--   columnas       +2 (tenant_id en organization_user_assignments y en practitioner_delegate_assignments)
--   FKs            +2     indices +2     disparadores +2 (trg_support_tenant_consistency) y +1 (trg_forbid_truncate)
--   funciones      +1 (integrity.forbid_truncate) y 2 reemplazadas (support_tenant_consistency, support_access_allowed)
--   politicas      tenant_isolation en +2 tablas (27 en total) ; REVOKE UPDATE, DELETE, TRUNCATE de access_decision_log a mantra_app
--
-- REVERSA (el parche solo endurece):
--   DROP TRIGGER IF EXISTS trg_support_tenant_consistency ON "delegated_access"."organization_user_assignments";
--   DROP TRIGGER IF EXISTS trg_support_tenant_consistency ON "delegated_access"."practitioner_delegate_assignments";
--   DROP TRIGGER IF EXISTS trg_forbid_truncate ON "delegated_access"."access_decision_log"; DROP FUNCTION IF EXISTS "integrity"."forbid_truncate"();
--   ALTER TABLE ... DROP COLUMN IF EXISTS tenant_id (en las 2 tablas; la API de v4.2.73 lo escribe) ; DROP POLICY IF EXISTS tenant_isolation ON esas 2.
--   volver a correr la seccion 8 del v4272 (y la 6 del v4269) restituye support_tenant_consistency y support_access_allowed anteriores.
-- ============================================================================

BEGIN;

-- El parche lee y escribe todas las organizaciones (backfill y verificaciones): contexto de sistema SOLO dentro de esta transaccion.
SELECT set_config('app.system_context', 'true', true);

-- ---- 1. A-M1 · tenant_id en organization_user_assignments y practitioner_delegate_assignments ----
ALTER TABLE "delegated_access"."organization_user_assignments" ADD COLUMN IF NOT EXISTS "tenant_id" uuid;
ALTER TABLE "delegated_access"."practitioner_delegate_assignments" ADD COLUMN IF NOT EXISTS "tenant_id" uuid;

-- Backfill: el tenant de la fila es el de su membresia (vinculo) y el de su set de permisos (delegacion).
UPDATE "delegated_access"."organization_user_assignments" a
   SET "tenant_id" = tm."tenant_id"
  FROM "directory"."tenant_memberships" tm
 WHERE tm."id" = a."tenant_membership_id" AND a."tenant_id" IS NULL;

UPDATE "delegated_access"."practitioner_delegate_assignments" d
   SET "tenant_id" = s."tenant_id"
  FROM "delegated_access"."delegated_permission_sets" s
 WHERE s."id" = d."delegated_permission_set_id" AND d."tenant_id" IS NULL;

-- Una delegacion cuyo vinculo o doctor son de otra organizacion que su set ya era una inconsistencia previa: no se corrige sola, se avisa.
DO $$
DECLARE
    v_bad integer;
BEGIN
    SELECT count(*) INTO v_bad
      FROM "delegated_access"."practitioner_delegate_assignments" d
      LEFT JOIN "delegated_access"."organization_user_assignments" a ON a."id" = d."delegate_user_assignment_id"
      LEFT JOIN "practice"."practitioner_role_assignments" pra ON pra."id" = d."practitioner_role_assignment_id"
      LEFT JOIN "practice"."practices" p ON p."id" = pra."practice_id"
     WHERE a."tenant_id" IS DISTINCT FROM d."tenant_id" OR p."tenant_id" IS DISTINCT FROM d."tenant_id";
    IF v_bad > 0 THEN
        RAISE WARNING 'v4273: % delegacion(es) con vinculo o doctor de OTRA organizacion que su set; conservan el tenant de su set y hay que revisarlas a mano', v_bad;
    END IF;
END $$;

DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM "delegated_access"."organization_user_assignments" WHERE "tenant_id" IS NULL)
       OR EXISTS (SELECT 1 FROM "delegated_access"."practitioner_delegate_assignments" WHERE "tenant_id" IS NULL) THEN
        RAISE EXCEPTION 'v4273: quedan filas sin tenant_id tras el backfill (membresia o set inexistentes): corrija los datos y vuelva a ejecutar';
    END IF;
END $$;

ALTER TABLE "delegated_access"."organization_user_assignments" ALTER COLUMN "tenant_id" SET NOT NULL;
ALTER TABLE "delegated_access"."practitioner_delegate_assignments" ALTER COLUMN "tenant_id" SET NOT NULL;

DO $$ BEGIN
    ALTER TABLE "delegated_access"."organization_user_assignments"
        ADD CONSTRAINT "fk_organization_user_assignments_tenant_id" FOREIGN KEY ("tenant_id")
        REFERENCES "directory"."tenants" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;
DO $$ BEGIN
    ALTER TABLE "delegated_access"."practitioner_delegate_assignments"
        ADD CONSTRAINT "fk_practitioner_delegate_assignments_tenant_id" FOREIGN KEY ("tenant_id")
        REFERENCES "directory"."tenants" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

CREATE INDEX IF NOT EXISTS "ix_organization_user_assignments_tenant_id"
    ON "delegated_access"."organization_user_assignments" ("tenant_id", "status_concept_id");
CREATE INDEX IF NOT EXISTS "ix_practitioner_delegate_assignments_tenant_id"
    ON "delegated_access"."practitioner_delegate_assignments" ("tenant_id", "status_concept_id");

-- ---- 2. A-M1 · disparador de consistencia de tenant (la funcion se REEMPLAZA entera: la del v4272 + las ramas nuevas) ----
-- organization_user_assignments = tenant de la membresia y de cada nodo de alcance (practica, sede, unidad, espacio, diagnostico, farmacia)
-- practitioner_delegate_assignments = tenant del set de permisos, del vinculo de la persona delegada y del doctor
-- Falla cerrado: un padre inexistente o que el RLS le oculta al llamador es foreign_key_violation (23503); de otra organizacion, check_violation (23514).
CREATE OR REPLACE FUNCTION "integrity"."support_tenant_consistency"()
RETURNS trigger
LANGUAGE plpgsql
SET search_path = pg_catalog, pg_temp
AS $fn$
DECLARE
    n jsonb := to_jsonb(NEW);
    v_tenant uuid := (to_jsonb(NEW) ->> 'tenant_id')::uuid;
    v_conv uuid;
    v_parent uuid;
    v_found boolean;
    r record;
BEGIN
    FOR r IN
        -- v4.2.73 (A-M1): organization_user_assignments y practitioner_delegate_assignments llevan tenant_id.
        SELECT 'la membresia (tenant_membership_id)' AS what,
               (SELECT tm."tenant_id" FROM "directory"."tenant_memberships" tm
                 WHERE tm."id" = (n ->> 'tenant_membership_id')::uuid) AS parent_tenant
         WHERE TG_TABLE_NAME = 'organization_user_assignments'
        UNION ALL
        SELECT 'la practica (practice_id)',
               (SELECT p."tenant_id" FROM "practice"."practices" p WHERE p."id" = (n ->> 'practice_id')::uuid)
         WHERE TG_TABLE_NAME = 'organization_user_assignments' AND n ->> 'practice_id' IS NOT NULL
        UNION ALL
        SELECT 'la unidad clinica (clinical_unit_id)',
               (SELECT p."tenant_id"
                  FROM "practice"."clinical_units" u
                  JOIN "practice"."practice_sites" ps ON ps."id" = u."practice_site_id"
                  JOIN "practice"."practices" p ON p."id" = ps."practice_id"
                 WHERE u."id" = (n ->> 'clinical_unit_id')::uuid)
         WHERE TG_TABLE_NAME = 'organization_user_assignments' AND n ->> 'clinical_unit_id' IS NOT NULL
        UNION ALL
        SELECT 'la unidad de diagnostico (diagnostic_unit_id)',
               (SELECT d."tenant_id" FROM "diagnostic_units"."diagnostic_units" d WHERE d."id" = (n ->> 'diagnostic_unit_id')::uuid)
         WHERE TG_TABLE_NAME = 'organization_user_assignments' AND n ->> 'diagnostic_unit_id' IS NOT NULL
        UNION ALL
        SELECT 'la farmacia (pharmacy_id)',
               (SELECT f."tenant_id" FROM "pharmacy"."pharmacies" f WHERE f."id" = (n ->> 'pharmacy_id')::uuid)
         WHERE TG_TABLE_NAME = 'organization_user_assignments' AND n ->> 'pharmacy_id' IS NOT NULL
        UNION ALL
        SELECT 'el set de permisos (delegated_permission_set_id)',
               (SELECT st."tenant_id" FROM "delegated_access"."delegated_permission_sets" st
                 WHERE st."id" = (n ->> 'delegated_permission_set_id')::uuid)
         WHERE TG_TABLE_NAME = 'practitioner_delegate_assignments'
        UNION ALL
        SELECT 'el vinculo de la persona delegada (delegate_user_assignment_id)',
               (SELECT tm."tenant_id"
                  FROM "delegated_access"."organization_user_assignments" a
                  JOIN "directory"."tenant_memberships" tm ON tm."id" = a."tenant_membership_id"
                 WHERE a."id" = (n ->> 'delegate_user_assignment_id')::uuid)
         WHERE TG_TABLE_NAME = 'practitioner_delegate_assignments'
        UNION ALL
        SELECT 'el vinculo (organization_user_assignment_id)',
               (SELECT tm."tenant_id"
                  FROM "delegated_access"."organization_user_assignments" a
                  JOIN "directory"."tenant_memberships" tm ON tm."id" = a."tenant_membership_id"
                 WHERE a."id" = (n ->> 'organization_user_assignment_id')::uuid)
         WHERE TG_TABLE_NAME = 'support_scope_grants'
            OR (TG_TABLE_NAME IN ('access_review_items', 'sod_exceptions', 'lifecycle_cases', 'four_eyes_requests', 'access_anomalies')
                AND n ->> 'organization_user_assignment_id' IS NOT NULL)
        UNION ALL
        SELECT 'el doctor (practitioner_role_assignment_id)',
               (SELECT p."tenant_id"
                  FROM "practice"."practitioner_role_assignments" pra
                  JOIN "practice"."practices" p ON p."id" = pra."practice_id"
                 WHERE pra."id" = (n ->> 'practitioner_role_assignment_id')::uuid)
         WHERE TG_TABLE_NAME IN ('support_scope_grants', 'practitioner_location_assignments', 'practitioner_delegate_assignments')
           AND n ->> 'practitioner_role_assignment_id' IS NOT NULL
        UNION ALL
        SELECT 'el servicio (healthcare_service_id)',
               (SELECT p."tenant_id"
                  FROM "practice"."healthcare_services" s
                  JOIN "practice"."practices" p ON p."id" = s."practice_id"
                 WHERE s."id" = (n ->> 'healthcare_service_id')::uuid)
         WHERE TG_TABLE_NAME = 'support_scope_grants'
           AND n ->> 'healthcare_service_id' IS NOT NULL
        UNION ALL
        SELECT 'el espacio (care_space_id)',
               (SELECT p."tenant_id"
                  FROM "practice"."care_spaces" c
                  JOIN "practice"."practice_sites" ps ON ps."id" = c."practice_site_id"
                  JOIN "practice"."practices" p ON p."id" = ps."practice_id"
                 WHERE c."id" = (n ->> 'care_space_id')::uuid)
         WHERE TG_TABLE_NAME IN ('support_scope_grants', 'practitioner_location_assignments', 'organization_user_assignments')
           AND n ->> 'care_space_id' IS NOT NULL
        UNION ALL
        SELECT 'la sede (practice_site_id)',
               (SELECT p."tenant_id"
                  FROM "practice"."practice_sites" ps
                  JOIN "practice"."practices" p ON p."id" = ps."practice_id"
                 WHERE ps."id" = (n ->> 'practice_site_id')::uuid)
         WHERE TG_TABLE_NAME IN ('support_scope_grants', 'organization_user_assignments')
           AND n ->> 'practice_site_id' IS NOT NULL
        UNION ALL
        SELECT 'el permiso (support_scope_grant_id)',
               (SELECT g."tenant_id" FROM "delegated_access"."support_scope_grants" g
                 WHERE g."id" = (n ->> 'support_scope_grant_id')::uuid)
         WHERE TG_TABLE_NAME IN ('support_grant_actions', 'grant_usage_stats')
        UNION ALL
        SELECT 'la solicitud (engagement_request_id)',
               (SELECT q."tenant_id" FROM "delegated_access"."engagement_requests" q
                 WHERE q."id" = (n ->> 'engagement_request_id')::uuid)
         WHERE TG_TABLE_NAME = 'engagement_request_items'
        UNION ALL
        SELECT 'la invitacion (affiliation_invitation_id)',
               (SELECT i."tenant_id" FROM "directory"."affiliation_invitations" i
                 WHERE i."id" = (n ->> 'affiliation_invitation_id')::uuid)
         WHERE TG_TABLE_NAME = 'affiliation_invitation_uses'
        UNION ALL
        SELECT 'la campana (access_review_campaign_id)',
               (SELECT c."tenant_id" FROM "delegated_access"."access_review_campaigns" c
                 WHERE c."id" = (n ->> 'access_review_campaign_id')::uuid)
         WHERE TG_TABLE_NAME = 'access_review_items'
        UNION ALL
        SELECT 'el permiso revisado (support_scope_grant_id)',
               (SELECT g."tenant_id" FROM "delegated_access"."support_scope_grants" g
                 WHERE g."id" = (n ->> 'support_scope_grant_id')::uuid)
         WHERE TG_TABLE_NAME = 'access_review_items'
           AND n ->> 'support_scope_grant_id' IS NOT NULL
        UNION ALL
        SELECT 'el caso de ciclo de vida (lifecycle_case_id)',
               (SELECT l."tenant_id" FROM "delegated_access"."lifecycle_cases" l
                 WHERE l."id" = (n ->> 'lifecycle_case_id')::uuid)
         WHERE TG_TABLE_NAME = 'handover_items'
        UNION ALL
        SELECT 'la solicitud de cuatro ojos (four_eyes_request_id)',
               (SELECT f."tenant_id" FROM "delegated_access"."four_eyes_requests" f
                 WHERE f."id" = (n ->> 'four_eyes_request_id')::uuid)
         WHERE TG_TABLE_NAME = 'sod_exceptions'
    LOOP
        IF r.parent_tenant IS NULL THEN
            RAISE EXCEPTION '%.%: % no existe o no es de la organizacion del contexto',
                TG_TABLE_SCHEMA, TG_TABLE_NAME, r.what
                USING ERRCODE = 'foreign_key_violation';
        ELSIF r.parent_tenant IS DISTINCT FROM v_tenant THEN
            RAISE EXCEPTION '%.%: tenant_id (%) no coincide con %: su tenant es %',
                TG_TABLE_SCHEMA, TG_TABLE_NAME, v_tenant, r.what, r.parent_tenant
                USING ERRCODE = 'check_violation';
        END IF;
    END LOOP;

    -- v4.2.72: padres que pueden ser de PLATAFORMA (tenant NULL): la regla SoD de una excepcion y la plantilla de origen de
    -- una concesion. Inexistente (o que el RLS oculta) = falla cerrado; de otra organizacion = check_violation.
    IF (TG_TABLE_NAME = 'sod_exceptions') OR (TG_TABLE_NAME = 'support_scope_grants' AND n ->> 'source_role_template_id' IS NOT NULL) THEN
        IF TG_TABLE_NAME = 'sod_exceptions' THEN
            SELECT true, s."tenant_id" INTO v_found, v_parent FROM "delegated_access"."sod_rules" s
             WHERE s."id" = (n ->> 'sod_rule_id')::uuid;
        ELSE
            SELECT true, t."tenant_id" INTO v_found, v_parent FROM "delegated_access"."role_templates" t
             WHERE t."id" = (n ->> 'source_role_template_id')::uuid;
        END IF;
        IF v_found IS NOT TRUE THEN
            RAISE EXCEPTION '%.%: % no existe o no es de la organizacion del contexto', TG_TABLE_SCHEMA, TG_TABLE_NAME,
                CASE WHEN TG_TABLE_NAME = 'sod_exceptions' THEN 'la regla (sod_rule_id)' ELSE 'la plantilla (source_role_template_id)' END
                USING ERRCODE = 'foreign_key_violation';
        ELSIF v_parent IS NOT NULL AND v_parent IS DISTINCT FROM v_tenant THEN
            RAISE EXCEPTION '%.%: tenant_id (%) no coincide con %: su tenant es %', TG_TABLE_SCHEMA, TG_TABLE_NAME, v_tenant,
                CASE WHEN TG_TABLE_NAME = 'sod_exceptions' THEN 'la regla (sod_rule_id)' ELSE 'la plantilla (source_role_template_id)' END, v_parent
                USING ERRCODE = 'check_violation';
        END IF;
    END IF;

    IF TG_TABLE_NAME IN ('conversation_assignments', 'conversation_internal_notes') THEN
        SELECT c."tenant_id" INTO v_conv
          FROM "community"."conversations" c
         WHERE c."id" = (n ->> 'conversation_id')::uuid;
        IF v_conv IS NOT NULL AND v_conv IS DISTINCT FROM v_tenant THEN
            RAISE EXCEPTION '%.%: tenant_id (%) no coincide con la conversacion: su tenant es %',
                TG_TABLE_SCHEMA, TG_TABLE_NAME, v_tenant, v_conv
                USING ERRCODE = 'check_violation';
        END IF;
    END IF;
    RETURN NEW;
END
$fn$;

DROP TRIGGER IF EXISTS trg_support_tenant_consistency ON "delegated_access"."organization_user_assignments";
CREATE TRIGGER trg_support_tenant_consistency
    BEFORE INSERT OR UPDATE OF "tenant_id", "tenant_membership_id", "practice_id", "practice_site_id", "clinical_unit_id",
        "care_space_id", "diagnostic_unit_id", "pharmacy_id"
    ON "delegated_access"."organization_user_assignments"
    FOR EACH ROW EXECUTE FUNCTION "integrity"."support_tenant_consistency"();

DROP TRIGGER IF EXISTS trg_support_tenant_consistency ON "delegated_access"."practitioner_delegate_assignments";
CREATE TRIGGER trg_support_tenant_consistency
    BEFORE INSERT OR UPDATE OF "tenant_id", "delegated_permission_set_id", "delegate_user_assignment_id", "practitioner_role_assignment_id"
    ON "delegated_access"."practitioner_delegate_assignments"
    FOR EACH ROW EXECUTE FUNCTION "integrity"."support_tenant_consistency"();

REVOKE ALL ON FUNCTION "integrity"."support_tenant_consistency"() FROM PUBLIC;

-- ---- 3. A-B1 + A-M1 · RLS en las 27 tablas (las 25 del v4269/v4272 + las 2 nuevas); falla si falta alguna ----
DO $$
DECLARE
    r record;
    v_missing text;
BEGIN
    FOR r IN SELECT * FROM (VALUES
        ('iam', 'session_policies'), ('directory', 'affiliation_invitations'),
        ('directory', 'affiliation_invitation_uses'), ('practice', 'practitioner_location_assignments'),
        ('community', 'reply_templates'), ('community', 'conversation_assignments'),
        ('community', 'conversation_internal_notes'), ('delegated_access', 'role_templates'),
        ('delegated_access', 'support_scope_grants'), ('delegated_access', 'support_grant_actions'),
        ('delegated_access', 'engagement_requests'), ('delegated_access', 'engagement_request_items'),
        ('delegated_access', 'effective_support_access'), ('delegated_access', 'governance_rules'),
        ('delegated_access', 'sod_exceptions'), ('delegated_access', 'four_eyes_requests'),
        ('delegated_access', 'access_review_campaigns'), ('delegated_access', 'access_review_items'),
        ('delegated_access', 'lifecycle_cases'), ('delegated_access', 'handover_items'),
        ('delegated_access', 'patient_restriction_flags'), ('delegated_access', 'access_decision_log'),
        ('delegated_access', 'grant_usage_stats'), ('delegated_access', 'access_anomalies'),
        ('delegated_access', 'sod_rules'),
        ('delegated_access', 'organization_user_assignments'), ('delegated_access', 'practitioner_delegate_assignments')) v(s, t)
    LOOP
        EXECUTE format('ALTER TABLE %I.%I ENABLE ROW LEVEL SECURITY', r.s, r.t);
        EXECUTE format('ALTER TABLE %I.%I FORCE ROW LEVEL SECURITY', r.s, r.t);
        EXECUTE format('DROP POLICY IF EXISTS tenant_isolation ON %I.%I', r.s, r.t);
        EXECUTE format($pol$
        CREATE POLICY tenant_isolation ON %I.%I
          USING (
            tenant_id = NULLIF(current_setting('app.current_tenant_id', true), '')::uuid
            OR current_setting('app.system_context', true) = 'true'
          )
          WITH CHECK (
            tenant_id = NULLIF(current_setting('app.current_tenant_id', true), '')::uuid
            OR current_setting('app.system_context', true) = 'true'
          )
        $pol$, r.s, r.t);
        IF EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'mantra_app') THEN
            IF r.t = 'access_decision_log' THEN
                EXECUTE format('GRANT SELECT, INSERT ON %I.%I TO mantra_app', r.s, r.t);
            ELSE
                EXECUTE format('GRANT SELECT, INSERT, UPDATE, DELETE ON %I.%I TO mantra_app', r.s, r.t);
            END IF;
        END IF;
    END LOOP;

    SELECT string_agg(v.s || '.' || v.t, ', ') INTO v_missing
      FROM (VALUES
        ('iam', 'session_policies'), ('directory', 'affiliation_invitations'),
        ('directory', 'affiliation_invitation_uses'), ('practice', 'practitioner_location_assignments'),
        ('community', 'reply_templates'), ('community', 'conversation_assignments'),
        ('community', 'conversation_internal_notes'), ('delegated_access', 'role_templates'),
        ('delegated_access', 'support_scope_grants'), ('delegated_access', 'support_grant_actions'),
        ('delegated_access', 'engagement_requests'), ('delegated_access', 'engagement_request_items'),
        ('delegated_access', 'effective_support_access'), ('delegated_access', 'governance_rules'),
        ('delegated_access', 'sod_exceptions'), ('delegated_access', 'four_eyes_requests'),
        ('delegated_access', 'access_review_campaigns'), ('delegated_access', 'access_review_items'),
        ('delegated_access', 'lifecycle_cases'), ('delegated_access', 'handover_items'),
        ('delegated_access', 'patient_restriction_flags'), ('delegated_access', 'access_decision_log'),
        ('delegated_access', 'grant_usage_stats'), ('delegated_access', 'access_anomalies'),
        ('delegated_access', 'sod_rules'),
        ('delegated_access', 'organization_user_assignments'), ('delegated_access', 'practitioner_delegate_assignments')) v(s, t)
     WHERE NOT EXISTS (
        SELECT 1 FROM pg_class c JOIN pg_namespace n ON n.oid = c.relnamespace
          JOIN pg_policies p ON p.schemaname = n.nspname AND p.tablename = c.relname AND p.policyname = 'tenant_isolation'
         WHERE n.nspname = v.s AND c.relname = v.t AND c.relrowsecurity AND c.relforcerowsecurity);
    IF v_missing IS NOT NULL THEN
        RAISE EXCEPTION 'v4273: sin RLS forzada + tenant_isolation: %', v_missing;
    END IF;
END $$;

-- ---- 4. A-B2 · access_decision_log: ni UPDATE, ni DELETE, ni TRUNCATE (tampoco para mantra_app) ----
CREATE OR REPLACE FUNCTION "integrity"."forbid_truncate"() RETURNS trigger
LANGUAGE plpgsql AS $$
BEGIN
    RAISE EXCEPTION 'append-only/immutable: TRUNCATE no permitido en %.%',
        TG_TABLE_SCHEMA, TG_TABLE_NAME USING ERRCODE = 'restrict_violation';
END $$;

REVOKE UPDATE, DELETE, TRUNCATE ON "delegated_access"."access_decision_log" FROM PUBLIC;
DROP TRIGGER IF EXISTS trg_forbid_truncate ON "delegated_access"."access_decision_log";
CREATE TRIGGER trg_forbid_truncate BEFORE TRUNCATE ON "delegated_access"."access_decision_log"
    FOR EACH STATEMENT EXECUTE FUNCTION "integrity"."forbid_truncate"();
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'mantra_app') THEN
        REVOKE UPDATE, DELETE, TRUNCATE ON "delegated_access"."access_decision_log" FROM mantra_app;
        GRANT SELECT, INSERT ON "delegated_access"."access_decision_log" TO mantra_app;
    END IF;
END $$;

-- ---- 5. A-B6 · support_access_allowed: ignora DENY y acciones reemplazadas -> ahora las respeta ----
-- REFERENCIA GRUESA, no es un punto de aplicacion (PEP): ignora condiciones (ABAC), SoD, DENY_PERMISSION de las reglas de la organizacion,
-- alias, el alta de ingreso y la ventana horaria. Ninguna vista, politica RLS ni funcion debe usarla para autorizar; la verdad es
-- SupportAccessPolicy (API). Lo que SI hace, y debe seguir haciendo, es no ser MAS permisiva que la tabla derivada:
--   - solo cuenta concesiones con efecto ALLOW y con la accion vigente (superseded_at IS NULL), igual que refresh_effective_support_access;
--   - NIEGA si el mismo vinculo tiene una concesion DENY viva sobre ese permiso cuyo objetivo cubre la accion; una dimension que la accion
--     no trae y que el DENY si acota cuenta como cubierta (falla cerrado: no se puede probar que quede fuera).
CREATE OR REPLACE FUNCTION "delegated_access"."support_access_allowed"(
    p_user_id uuid, p_tenant_id uuid, p_permission_code varchar,
    p_practitioner_role_assignment_id uuid DEFAULT NULL,
    p_healthcare_service_id uuid DEFAULT NULL,
    p_care_space_id uuid DEFAULT NULL)
RETURNS boolean
LANGUAGE sql
STABLE
SET search_path = pg_catalog, pg_temp
AS $fn$
    SELECT COALESCE((
        SELECT true
          FROM "delegated_access"."effective_support_access" e
          JOIN "delegated_access"."support_scope_grants" g
            ON g."id" = e."grant_id" AND g."tenant_id" = e."tenant_id"
          JOIN "delegated_access"."organization_user_assignments" a
            ON a."id" = g."organization_user_assignment_id"
          JOIN "directory"."tenant_memberships" tm
            ON tm."id" = a."tenant_membership_id"
           AND tm."tenant_id" = e."tenant_id" AND tm."user_id" = e."user_id"
          JOIN "practice"."practitioner_role_assignments" qra
            ON qra."id" = p_practitioner_role_assignment_id
          JOIN "practice"."practices" qp
            ON qp."id" = qra."practice_id" AND qp."tenant_id" = p_tenant_id
         WHERE e."user_id" = p_user_id
           AND e."tenant_id" = p_tenant_id
           AND e."permission_code" = p_permission_code
           AND (e."practitioner_role_assignment_id" IS NULL OR e."practitioner_role_assignment_id" = p_practitioner_role_assignment_id)
           AND (e."healthcare_service_id" IS NULL OR e."healthcare_service_id" = p_healthcare_service_id)
           AND (e."care_space_id" IS NULL OR e."care_space_id" = p_care_space_id)
           -- v4.2.73 (A-B6): solo ALLOW, y con la accion vigente en ESA concesion (la derivada puede ir atrasada)
           AND g."effect_concept_id" = '6905e0db-1650-5d49-adca-8b2688ac049c'
           AND EXISTS (
               SELECT 1 FROM "delegated_access"."support_grant_actions" sga
                 JOIN "authz"."permissions" sp ON sp."id" = sga."permission_id"
                WHERE sga."support_scope_grant_id" = g."id" AND sga."superseded_at" IS NULL AND sp."code" = p_permission_code)
           -- vigencia releida de las fuentes
           AND g."status_concept_id" = 'ccfbc54f-4744-53db-ab1f-abe1af31f784'
           AND (g."valid_from" IS NULL OR g."valid_from" <= now())
           AND (g."valid_to" IS NULL OR g."valid_to" > now())
           AND a."status_concept_id" = '38a1d301-f40d-5b17-a695-5e6d605f8b19'
           AND (a."valid_from" IS NULL OR a."valid_from" <= now())
           AND (a."valid_to" IS NULL OR a."valid_to" > now())
           AND (a."next_recertification_at" IS NULL OR a."next_recertification_at" + interval '15 days' > now())
           AND tm."status_concept_id" = '13ca1b46-61d5-5c25-9d49-8247bcd7769c'
           AND tm."start_date" <= now()
           AND (tm."end_date" IS NULL OR tm."end_date" > now())
           -- aceptacion del doctor de la accion
           AND EXISTS (
               SELECT 1
                 FROM "delegated_access"."practitioner_delegate_assignments" d
                 JOIN "practice"."practitioner_role_assignments" dra
                   ON dra."id" = d."practitioner_role_assignment_id"
                WHERE d."delegate_user_assignment_id" = a."id"
                  AND dra."practitioner_profile_id" = qra."practitioner_profile_id"
                  AND d."accepted_at" IS NOT NULL
                  AND d."status_concept_id" = '38a1d301-f40d-5b17-a695-5e6d605f8b19'
                  AND (d."valid_from" IS NULL OR d."valid_from" <= now())
                  AND (d."valid_to" IS NULL OR d."valid_to" > now())
                  AND (p_permission_code <> 'messages.reply_on_behalf' OR d."may_reply_on_behalf")
           )
           -- v4.2.73 (A-B6): un DENY vivo del mismo vinculo sobre este permiso gana siempre
           AND NOT EXISTS (
               SELECT 1
                 FROM "delegated_access"."support_scope_grants" dg
                 JOIN "delegated_access"."support_grant_actions" dga
                   ON dga."support_scope_grant_id" = dg."id" AND dga."superseded_at" IS NULL
                 JOIN "authz"."permissions" dp ON dp."id" = dga."permission_id"
                WHERE dg."organization_user_assignment_id" = a."id"
                  AND dg."tenant_id" = p_tenant_id
                  AND dg."effect_concept_id" = 'b038e546-a6ba-5848-9cd2-04b02ccb22b0'
                  AND dg."status_concept_id" = 'ccfbc54f-4744-53db-ab1f-abe1af31f784'
                  AND (dg."valid_from" IS NULL OR dg."valid_from" <= now())
                  AND (dg."valid_to" IS NULL OR dg."valid_to" > now())
                  AND dp."code" = p_permission_code
                  AND (dg."practitioner_role_assignment_id" IS NULL OR p_practitioner_role_assignment_id IS NULL
                       OR dg."practitioner_role_assignment_id" = p_practitioner_role_assignment_id)
                  AND (dg."healthcare_service_id" IS NULL OR p_healthcare_service_id IS NULL
                       OR dg."healthcare_service_id" = p_healthcare_service_id)
                  AND (dg."care_space_id" IS NULL OR p_care_space_id IS NULL OR dg."care_space_id" = p_care_space_id)
                  AND (dg."practice_site_id" IS NULL OR p_care_space_id IS NULL
                       OR EXISTS (SELECT 1 FROM "practice"."care_spaces" cs
                                   WHERE cs."id" = p_care_space_id AND cs."practice_site_id" = dg."practice_site_id"))
           )
         LIMIT 1
    ), false);
$fn$;

COMMENT ON FUNCTION "delegated_access"."support_access_allowed"(uuid, uuid, varchar, uuid, uuid, uuid) IS
    'REFERENCIA GRUESA, no es un PEP: ignora condiciones (ABAC), SoD, DENY_PERMISSION de las reglas de la organizacion, alias, ingreso y horario. Respeta ALLOW/DENY de las concesiones. No la use para autorizar: la verdad es SupportAccessPolicy (API).';

REVOKE ALL ON FUNCTION "delegated_access"."support_access_allowed"(uuid, uuid, varchar, uuid, uuid, uuid) FROM PUBLIC;
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'mantra_app') THEN
        GRANT EXECUTE ON FUNCTION "delegated_access"."support_access_allowed"(uuid, uuid, varchar, uuid, uuid, uuid) TO mantra_app;
    END IF;
END $$;

-- ---- 6. verificacion final ----
DO $$
DECLARE
    v_trg integer;
BEGIN
    SELECT count(*) INTO v_trg FROM pg_trigger t
     WHERE NOT t.tgisinternal AND t.tgname IN ('trg_support_tenant_consistency')
       AND t.tgrelid IN ('delegated_access.organization_user_assignments'::regclass, 'delegated_access.practitioner_delegate_assignments'::regclass);
    IF v_trg <> 2 THEN RAISE EXCEPTION 'v4273: faltan los disparadores de consistencia de tenant (% de 2)', v_trg; END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgrelid = 'delegated_access.access_decision_log'::regclass AND tgname = 'trg_forbid_truncate') THEN
        RAISE EXCEPTION 'v4273: falta trg_forbid_truncate en access_decision_log';
    END IF;
    IF EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'mantra_app') AND (
           has_table_privilege('mantra_app', 'delegated_access.access_decision_log', 'UPDATE')
        OR has_table_privilege('mantra_app', 'delegated_access.access_decision_log', 'DELETE')
        OR has_table_privilege('mantra_app', 'delegated_access.access_decision_log', 'TRUNCATE')) THEN
        RAISE EXCEPTION 'v4273: mantra_app conserva UPDATE, DELETE o TRUNCATE sobre access_decision_log';
    END IF;
    RAISE NOTICE 'v4273: tenant_id + disparador + RLS en organization_user_assignments y practitioner_delegate_assignments; access_decision_log sin UPDATE/DELETE/TRUNCATE; support_access_allowed respeta DENY';
END $$;

COMMIT;
