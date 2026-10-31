-- ============================================================================
-- SALUD · patch v4.2.69 + hardening v4.2.70 + v4.2.71 (personal de apoyo: secretaria y otros roles) sobre BD viva
-- Fecha: 2026-10-30
-- Idempotente (CREATE TABLE / INDEX IF NOT EXISTS, ADD COLUMN IF NOT EXISTS, FKs con
-- duplicate_object, CHECK con DROP IF EXISTS + ADD, triggers con DROP IF EXISTS + CREATE).
-- UNA sola pasada; se puede volver a correr (es lo que hace falta si un indice unico avisa de duplicados).
--
-- Contexto: gen_ddl.py y gen_integrity.py ya emiten TODO lo de las secciones 1-5 en
-- SQL/<NN>_<schema>/ desde que los .puml lo declaran (modulos 01, 04, 14, 19, 29, 41 y la
-- matriz 33), asi que en un rebuild desde cero esas secciones NO hacen falta. Existe para
-- una base ya aplicada y poblada. Las secciones 6 (funciones y disparadores) y 7 (RLS) NO se derivan
-- de ningun .puml: son piezas operativas y solo viven aqui (tambien en un rebuild desde cero hay que
-- correr este parche para tenerlas). gen_apply.py no escanea SQL/patches/.
--
-- QUE AGREGA (Fase 0 + Fase 1 del plan de personal de apoyo)
--   Fase 0  practice.care_spaces (+ fhir_physical_type, location_path: jerarquia de
--           ubicaciones), practice.practitioner_location_assignments, scheduling.bookable_slots y
--           scheduling.appointment_bookings (+ care_space_id, healthcare_service_id),
--           iam.session_policies.
--   Fase 1  delegated_access.role_templates, support_scope_grants, support_grant_actions,
--           engagement_requests, engagement_request_items, effective_support_access (tabla
--           derivada); organization_user_assignments y practitioner_delegate_assignments con las
--           columnas nuevas; directory.affiliation_invitations / _uses;
--           appointment_bookings.booked_via_grant_id.
--   Fase 3 (columnas listas, la usa una ronda posterior)  community.conversation_assignments,
--           conversation_internal_notes, reply_templates y las columnas nuevas de direct_messages.
--
-- HARDENING v4.2.70 (revision de seguridad independiente: M5, M6, M8, A5, M1)
--   tenant_id uuid NOT NULL (+ FK a directory.tenants + indice) en las 7 tablas hijas que no lo tenian, para
--     poder aislarlas con RLS: support_scope_grants, support_grant_actions, engagement_request_items,
--     conversation_assignments, conversation_internal_notes, affiliation_invitation_uses,
--     practitioner_location_assignments (seccion 1/2b/3/4). Un disparador exige que coincida con el tenant
--     del padre (seccion 6) y la seccion 7 les pone la politica tenant_isolation.
--   indices unicos parciales (seccion 4b): una politica de sesion ACTIVA por alcance, un vinculo de apoyo
--     ACTIVO por membresia+plantilla, un uso ACEPTADO por (invitacion, usuario), una membresia ACTIVA por
--     (usuario, organizacion).
--   CHECK ck_support_scope_grants_fixed_snapshot reforzado (FIXED exige filas no vacias con claves validas;
--     una fila {} comodin ya no pasa) y CHECK ck_session_policies_allowed_hours (forma del horario).
--   funciones: search_path fijo, REVOKE ... FROM PUBLIC y GRANT solo a mantra_app; support_access_allowed
--     exige aceptacion del doctor, recertificacion vigente (+15 dias) y membresia vigente (falla cerrada);
--     refresh_effective_support_access respeta recertificacion y estado de la membresia.
--   disparadores: integrity.support_tenant_consistency (tenant del hijo = tenant del padre) y
--     integrity.session_policies_time_zone (zona horaria invalida = rechazada al guardar).
--
-- v4.2.71 (revision de seguridad independiente: N10 y N3; todo aditivo, anulable o con guarda)
--   directory.tenant_memberships.origin_concept_id uuid NULL (+ FK a terminology.catalog_concepts + indice
--     ix_tenant_memberships_origin_concept_id): origen de la membresia (directory:MEMBERSHIP_ORIGIN_OWNER_CREATED,
--     _ADMIN_ADDED, _INVITATION_REDEEMED, _SUPPORT_ENGAGEMENT = existe SOLO por un vinculo de apoyo, _UNKNOWN).
--     Backfill conservador: las filas existentes quedan en NULL (= desconocido). NO se marcan como solo-apoyo:
--     solo la API, al crear la membresia, escribe el origen. (secciones 2, 3 y 4)
--   common.identifiers: unico parcial FUNCIONAL uq_identifiers_national_id_normalized sobre el documento nacional
--     ACTIVO de paciente en su forma canonica (la misma expresion que normalizeNationalId / NORMALIZED_ID de la API).
--     Con guarda (seccion 4c): si ya hay documentos duplicados NO falla; avisa con WARNING y la consulta de
--     diagnostico, y crea el indice NO unico de apoyo ix_identifiers_national_id_normalized (las busquedas por
--     documento usan indice igual). Al corregir los datos y volver a correr el parche se crea el unico y se
--     retira el de apoyo.
--
-- DELTAS ESPERADOS sobre la base viva (una base SIN la primera version de este parche):
--   tablas        +13  (6 en delegated_access, 2 en directory, 1 en practice, 3 en community, 1 en iam)
--   columnas      +21  en tablas existentes (20 de v4.2.69 + tenant_memberships.origin_concept_id de v4.2.71)
--   FKs           +94  (93 + fk_tenant_memberships_origin_concept_id)
--   indices       +109 (103 de la seccion 4, que incluye los PK de las tablas nuevas y ix_tenant_memberships_origin_concept_id,
--                       mas 5 unicos parciales de la 4b y el unico funcional de la 4c; en una base que ya tenia v4.2.69
--                       los dos unicos de session_policies se REEMPLAZAN; con documentos duplicados la 4c deja
--                       el indice de apoyo no unico en vez del unico)
--   CHECK         +15
--   funciones     +4   (refresh_effective_support_access, support_access_allowed, integrity.support_tenant_consistency,
--                       integrity.session_policies_time_zone)
--   disparadores  +8   (7 trg_support_tenant_consistency + trg_session_policies_time_zone)
--   politicas     +1   (global_catalog_read en role_templates) y tenant_isolation en las 13 tablas SI la base ya usa RLS
--
-- SIN BACKFILL de negocio (tampoco origin_concept_id de v4.2.71: NULL = origen desconocido). Las columnas nuevas son anulables (salvo may_reply_on_behalf y disclosure_shown,
-- NOT NULL DEFAULT false: se rellenan solas, y los tenant_id de la seccion 2b, que se derivan del padre).
-- Los vinculos de apoyo anteriores siguen validos con role_template_id NULL; sus columnas de alcance
-- sueltas quedan DEPRECADAS (no se borran). Los CONCEPTOS nuevos (delegated_access:SUPPORT_TARGET_*, etc.) los
-- materializa la API al arrancar (TerminologySeedService) y los espeja seedsGenerales; este patch NO los inserta.
--
-- REVERSA (si hiciera falta):
--   DROP TRIGGER IF EXISTS trg_support_tenant_consistency ON <las 7 tablas>;  (ver seccion 6)
--   DROP TRIGGER IF EXISTS trg_session_policies_time_zone ON "iam"."session_policies";
--   DROP FUNCTION IF EXISTS "integrity"."support_tenant_consistency"(), "integrity"."session_policies_time_zone"();
--   DROP POLICY IF EXISTS global_catalog_read ON "delegated_access"."role_templates";
--   DROP FUNCTION IF EXISTS "delegated_access"."support_access_allowed"(uuid, uuid, varchar, uuid, uuid, uuid);
--   DROP FUNCTION IF EXISTS "delegated_access"."refresh_effective_support_access"(uuid);
--   DROP TABLE IF EXISTS "delegated_access"."effective_support_access", "delegated_access"."engagement_request_items",
--     "delegated_access"."engagement_requests", "delegated_access"."support_grant_actions",
--     "delegated_access"."support_scope_grants", "delegated_access"."role_templates",
--     "directory"."affiliation_invitation_uses", "directory"."affiliation_invitations",
--     "practice"."practitioner_location_assignments", "community"."conversation_assignments",
--     "community"."conversation_internal_notes", "community"."reply_templates", "iam"."session_policies";
--   (y los ALTER TABLE ... DROP COLUMN de la seccion 2, y DROP INDEX de los unicos de la 4b)
--   v4.2.71: DROP INDEX IF EXISTS "common"."uq_identifiers_national_id_normalized", "common"."ix_identifiers_national_id_normalized",
--     "directory"."ix_tenant_memberships_origin_concept_id";
--     ALTER TABLE "directory"."tenant_memberships" DROP CONSTRAINT IF EXISTS "fk_tenant_memberships_origin_concept_id",
--       DROP COLUMN IF EXISTS "origin_concept_id";
-- ============================================================================

BEGIN;

-- ---- 1. tablas nuevas (13) ----

CREATE TABLE IF NOT EXISTS "iam"."session_policies" (
    "id" uuid NOT NULL,
    "tenant_id" uuid NOT NULL,
    "scope_concept_id" uuid NOT NULL,
    "role_code" varchar,
    "idle_timeout_minutes" integer NOT NULL,
    "new_device_alert" boolean NOT NULL,
    "allowed_hours_json" jsonb,
    "enforce_ip_rules" boolean NOT NULL,
    "require_mfa" boolean NOT NULL,
    "status_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_session_policies" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "directory"."affiliation_invitations" (
    "id" uuid NOT NULL,
    "tenant_id" uuid NOT NULL,
    "kind_concept_id" uuid NOT NULL,
    "target_person_id" uuid,
    "token_hash" varchar NOT NULL,
    "max_uses" integer NOT NULL,
    "uses_count" integer NOT NULL,
    "expires_at" timestamptz NOT NULL,
    "role_template_id" uuid,
    "status_concept_id" uuid NOT NULL,
    "created_by_user_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_affiliation_invitations" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "directory"."affiliation_invitation_uses" (
    "id" uuid NOT NULL,
    "tenant_id" uuid NOT NULL,
    "affiliation_invitation_id" uuid NOT NULL,
    "used_by_user_id" uuid NOT NULL,
    "occurred_at" timestamptz NOT NULL,
    "outcome_concept_id" uuid NOT NULL,
    CONSTRAINT "pk_affiliation_invitation_uses" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "practice"."practitioner_location_assignments" (
    "id" uuid NOT NULL,
    "tenant_id" uuid NOT NULL,
    "practitioner_role_assignment_id" uuid NOT NULL,
    "care_space_id" uuid NOT NULL,
    "valid_from" date,
    "valid_to" date,
    "status_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_practitioner_location_assignments" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "community"."conversation_assignments" (
    "id" uuid NOT NULL,
    "tenant_id" uuid NOT NULL,
    "conversation_id" uuid NOT NULL,
    "practitioner_profile_id" uuid NOT NULL,
    "assigned_user_id" uuid,
    "status_concept_id" uuid NOT NULL,
    "sla_due_at" timestamptz,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_conversation_assignments" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "community"."conversation_internal_notes" (
    "id" uuid NOT NULL,
    "tenant_id" uuid NOT NULL,
    "conversation_id" uuid NOT NULL,
    "author_user_id" uuid NOT NULL,
    "body_text" text NOT NULL,
    "created_at" timestamptz NOT NULL,
    CONSTRAINT "pk_conversation_internal_notes" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "community"."reply_templates" (
    "id" uuid NOT NULL,
    "tenant_id" uuid NOT NULL,
    "practitioner_profile_id" uuid,
    "category_concept_id" uuid NOT NULL,
    "title" varchar NOT NULL,
    "body_text" text NOT NULL,
    "status_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_reply_templates" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "delegated_access"."role_templates" (
    "id" uuid NOT NULL,
    "tenant_id" uuid,
    "code" varchar NOT NULL,
    "name" varchar NOT NULL,
    "default_actions_json" jsonb NOT NULL,
    "status_concept_id" uuid NOT NULL,
    "version_number" integer NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_role_templates" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "delegated_access"."support_scope_grants" (
    "id" uuid NOT NULL,
    "tenant_id" uuid NOT NULL,
    "organization_user_assignment_id" uuid NOT NULL,
    "target_kind_concept_id" uuid NOT NULL,
    "practitioner_role_assignment_id" uuid,
    "healthcare_service_id" uuid,
    "care_space_id" uuid,
    "practice_site_id" uuid,
    "expansion_mode_concept_id" uuid NOT NULL,
    "fixed_snapshot_json" jsonb,
    "valid_from" timestamptz,
    "valid_to" timestamptz,
    "status_concept_id" uuid NOT NULL,
    "approved_by_user_id" uuid,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_support_scope_grants" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "delegated_access"."support_grant_actions" (
    "id" uuid NOT NULL,
    "tenant_id" uuid NOT NULL,
    "support_scope_grant_id" uuid NOT NULL,
    "permission_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    CONSTRAINT "pk_support_grant_actions" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "delegated_access"."engagement_requests" (
    "id" uuid NOT NULL,
    "tenant_id" uuid NOT NULL,
    "requester_user_id" uuid NOT NULL,
    "direction_concept_id" uuid NOT NULL,
    "role_template_id" uuid NOT NULL,
    "parent_assignment_id" uuid,
    "message_text" text,
    "status_concept_id" uuid NOT NULL,
    "expires_at" timestamptz NOT NULL,
    "decided_at" timestamptz,
    "decided_by_user_id" uuid,
    "decision_reason_text" text,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_engagement_requests" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "delegated_access"."engagement_request_items" (
    "id" uuid NOT NULL,
    "tenant_id" uuid NOT NULL,
    "engagement_request_id" uuid NOT NULL,
    "target_kind_concept_id" uuid NOT NULL,
    "practitioner_role_assignment_id" uuid,
    "healthcare_service_id" uuid,
    "care_space_id" uuid,
    "practice_site_id" uuid,
    "proposed_actions_json" jsonb NOT NULL,
    "decision_concept_id" uuid NOT NULL,
    "decision_comment_text" text,
    "resulting_grant_id" uuid,
    "created_at" timestamptz NOT NULL,
    CONSTRAINT "pk_engagement_request_items" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "delegated_access"."effective_support_access" (
    "id" uuid NOT NULL,
    "user_id" uuid NOT NULL,
    "tenant_id" uuid NOT NULL,
    "practitioner_role_assignment_id" uuid,
    "healthcare_service_id" uuid,
    "care_space_id" uuid,
    "permission_code" varchar NOT NULL,
    "grant_id" uuid NOT NULL,
    "refreshed_at" timestamptz NOT NULL,
    CONSTRAINT "pk_effective_support_access" PRIMARY KEY ("id")
);



-- ---- 2. columnas nuevas en tablas existentes (21) ----

ALTER TABLE "practice"."care_spaces"
    ADD COLUMN IF NOT EXISTS "fhir_physical_type" varchar;

ALTER TABLE "practice"."care_spaces"
    ADD COLUMN IF NOT EXISTS "location_path" varchar;

ALTER TABLE "community"."direct_messages"
    ADD COLUMN IF NOT EXISTS "authored_by_user_id" uuid;

ALTER TABLE "community"."direct_messages"
    ADD COLUMN IF NOT EXISTS "on_behalf_of_profile_id" uuid;

ALTER TABLE "community"."direct_messages"
    ADD COLUMN IF NOT EXISTS "delegate_assignment_id" uuid;

ALTER TABLE "community"."direct_messages"
    ADD COLUMN IF NOT EXISTS "disclosure_shown" boolean NOT NULL DEFAULT false;

ALTER TABLE "delegated_access"."organization_user_assignments"
    ADD COLUMN IF NOT EXISTS "origin_concept_id" uuid;

ALTER TABLE "delegated_access"."organization_user_assignments"
    ADD COLUMN IF NOT EXISTS "owner_kind_concept_id" uuid;

ALTER TABLE "delegated_access"."organization_user_assignments"
    ADD COLUMN IF NOT EXISTS "role_template_id" uuid;

ALTER TABLE "delegated_access"."organization_user_assignments"
    ADD COLUMN IF NOT EXISTS "recertify_every_months" integer;

ALTER TABLE "delegated_access"."organization_user_assignments"
    ADD COLUMN IF NOT EXISTS "next_recertification_at" timestamptz;

ALTER TABLE "delegated_access"."organization_user_assignments"
    ADD COLUMN IF NOT EXISTS "ended_reason_text" text;

ALTER TABLE "delegated_access"."practitioner_delegate_assignments"
    ADD COLUMN IF NOT EXISTS "may_reply_on_behalf" boolean NOT NULL DEFAULT false;

ALTER TABLE "delegated_access"."practitioner_delegate_assignments"
    ADD COLUMN IF NOT EXISTS "reply_disclosure_concept_id" uuid;

ALTER TABLE "delegated_access"."practitioner_delegate_assignments"
    ADD COLUMN IF NOT EXISTS "accepted_at" timestamptz;

ALTER TABLE "scheduling"."bookable_slots"
    ADD COLUMN IF NOT EXISTS "care_space_id" uuid;

ALTER TABLE "scheduling"."bookable_slots"
    ADD COLUMN IF NOT EXISTS "healthcare_service_id" uuid;

ALTER TABLE "scheduling"."appointment_bookings"
    ADD COLUMN IF NOT EXISTS "care_space_id" uuid;

ALTER TABLE "scheduling"."appointment_bookings"
    ADD COLUMN IF NOT EXISTS "healthcare_service_id" uuid;

ALTER TABLE "scheduling"."appointment_bookings"
    ADD COLUMN IF NOT EXISTS "booked_via_grant_id" uuid;

ALTER TABLE "directory"."tenant_memberships"
    ADD COLUMN IF NOT EXISTS "origin_concept_id" uuid;



-- ---- 2b. tenant_id de las 7 tablas hijas (v4.2.70) en bases que ya corrieron la primera version de este parche ----
--
-- En una base nueva (apply_all.sql) o creada por la seccion 1 de este mismo archivo las columnas ya
-- existen y son NOT NULL: todo esto es un no-op. En una base que aplico el parche v4.2.69 original,
-- la columna se agrega, se rellena desde el padre y se endurece a NOT NULL. Si alguna fila no se puede
-- derivar (p. ej. una asignacion de conversacion cuya conversacion no trae tenant), el parche ABORTA con
-- el nombre de la tabla: hay que asignarle el tenant a mano y volver a ejecutarlo.

ALTER TABLE "delegated_access"."support_scope_grants" ADD COLUMN IF NOT EXISTS "tenant_id" uuid;
ALTER TABLE "delegated_access"."support_grant_actions" ADD COLUMN IF NOT EXISTS "tenant_id" uuid;
ALTER TABLE "delegated_access"."engagement_request_items" ADD COLUMN IF NOT EXISTS "tenant_id" uuid;
ALTER TABLE "community"."conversation_assignments" ADD COLUMN IF NOT EXISTS "tenant_id" uuid;
ALTER TABLE "community"."conversation_internal_notes" ADD COLUMN IF NOT EXISTS "tenant_id" uuid;
ALTER TABLE "directory"."affiliation_invitation_uses" ADD COLUMN IF NOT EXISTS "tenant_id" uuid;
ALTER TABLE "practice"."practitioner_location_assignments" ADD COLUMN IF NOT EXISTS "tenant_id" uuid;

UPDATE "delegated_access"."support_scope_grants" g SET "tenant_id" = tm."tenant_id"
  FROM "delegated_access"."organization_user_assignments" a
  JOIN "directory"."tenant_memberships" tm ON tm."id" = a."tenant_membership_id"
 WHERE g."tenant_id" IS NULL AND a."id" = g."organization_user_assignment_id";

UPDATE "delegated_access"."support_grant_actions" x SET "tenant_id" = g."tenant_id"
  FROM "delegated_access"."support_scope_grants" g
 WHERE x."tenant_id" IS NULL AND g."id" = x."support_scope_grant_id";

UPDATE "delegated_access"."engagement_request_items" x SET "tenant_id" = r."tenant_id"
  FROM "delegated_access"."engagement_requests" r
 WHERE x."tenant_id" IS NULL AND r."id" = x."engagement_request_id";

UPDATE "community"."conversation_assignments" x SET "tenant_id" = c."tenant_id"
  FROM "community"."conversations" c
 WHERE x."tenant_id" IS NULL AND c."id" = x."conversation_id" AND c."tenant_id" IS NOT NULL;

UPDATE "community"."conversation_internal_notes" x SET "tenant_id" = a."tenant_id"
  FROM "community"."conversation_assignments" a
 WHERE x."tenant_id" IS NULL AND a."conversation_id" = x."conversation_id" AND a."tenant_id" IS NOT NULL;

UPDATE "community"."conversation_internal_notes" x SET "tenant_id" = c."tenant_id"
  FROM "community"."conversations" c
 WHERE x."tenant_id" IS NULL AND c."id" = x."conversation_id" AND c."tenant_id" IS NOT NULL;

UPDATE "directory"."affiliation_invitation_uses" u SET "tenant_id" = i."tenant_id"
  FROM "directory"."affiliation_invitations" i
 WHERE u."tenant_id" IS NULL AND i."id" = u."affiliation_invitation_id";

UPDATE "practice"."practitioner_location_assignments" x SET "tenant_id" = p."tenant_id"
  FROM "practice"."practitioner_role_assignments" pra
  JOIN "practice"."practices" p ON p."id" = pra."practice_id"
 WHERE x."tenant_id" IS NULL AND pra."id" = x."practitioner_role_assignment_id";

DO $$
DECLARE
    r record;
    v_nulls bigint;
BEGIN
    FOR r IN SELECT * FROM (VALUES
        ('delegated_access', 'support_scope_grants'), ('delegated_access', 'support_grant_actions'),
        ('delegated_access', 'engagement_request_items'), ('community', 'conversation_assignments'),
        ('community', 'conversation_internal_notes'), ('directory', 'affiliation_invitation_uses'),
        ('practice', 'practitioner_location_assignments')) v(s, t)
    LOOP
        CONTINUE WHEN EXISTS (
            SELECT 1 FROM pg_attribute a
             WHERE a.attrelid = format('%I.%I', r.s, r.t)::regclass AND a.attname = 'tenant_id' AND a.attnotnull);
        EXECUTE format('SELECT count(*) FROM %I.%I WHERE tenant_id IS NULL', r.s, r.t) INTO v_nulls;
        IF v_nulls > 0 THEN
            RAISE EXCEPTION '%.%: % fila(s) sin tenant_id que no se pudieron derivar de su padre; asignalo a mano y vuelve a ejecutar este parche',
                r.s, r.t, v_nulls;
        END IF;
        EXECUTE format('ALTER TABLE %I.%I ALTER COLUMN tenant_id SET NOT NULL', r.s, r.t);
    END LOOP;
END $$;


-- ---- 3. claves foraneas (94) ----

DO $$ BEGIN
    ALTER TABLE "iam"."session_policies"
        ADD CONSTRAINT "fk_session_policies_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

DO $$ BEGIN
    ALTER TABLE "iam"."session_policies"
        ADD CONSTRAINT "fk_session_policies_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: directory.tenants (requiere schema directory)
DO $$ BEGIN
    ALTER TABLE "iam"."session_policies"
        ADD CONSTRAINT "fk_session_policies_tenant_id" FOREIGN KEY ("tenant_id")
        REFERENCES "directory"."tenants" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "iam"."session_policies"
        ADD CONSTRAINT "fk_session_policies_scope_concept_id" FOREIGN KEY ("scope_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "iam"."session_policies"
        ADD CONSTRAINT "fk_session_policies_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

DO $$ BEGIN
    ALTER TABLE "directory"."affiliation_invitations"
        ADD CONSTRAINT "fk_affiliation_invitations_tenant_id" FOREIGN KEY ("tenant_id")
        REFERENCES "directory"."tenants" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "directory"."affiliation_invitation_uses"
        ADD CONSTRAINT "fk_affiliation_invitation_uses_affiliation_invitation_id" FOREIGN KEY ("affiliation_invitation_id")
        REFERENCES "directory"."affiliation_invitations" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "directory"."affiliation_invitations"
        ADD CONSTRAINT "fk_affiliation_invitations_kind_concept_id" FOREIGN KEY ("kind_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: profiles.persons (requiere schema profiles)
DO $$ BEGIN
    ALTER TABLE "directory"."affiliation_invitations"
        ADD CONSTRAINT "fk_affiliation_invitations_target_person_id" FOREIGN KEY ("target_person_id")
        REFERENCES "profiles"."persons" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: delegated_access.role_templates (requiere schema delegated_access)
DO $$ BEGIN
    ALTER TABLE "directory"."affiliation_invitations"
        ADD CONSTRAINT "fk_affiliation_invitations_role_template_id" FOREIGN KEY ("role_template_id")
        REFERENCES "delegated_access"."role_templates" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "directory"."affiliation_invitations"
        ADD CONSTRAINT "fk_affiliation_invitations_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "directory"."affiliation_invitations"
        ADD CONSTRAINT "fk_affiliation_invitations_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "directory"."affiliation_invitations"
        ADD CONSTRAINT "fk_affiliation_invitations_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "directory"."affiliation_invitation_uses"
        ADD CONSTRAINT "fk_affiliation_invitation_uses_used_by_user_id" FOREIGN KEY ("used_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "directory"."affiliation_invitation_uses"
        ADD CONSTRAINT "fk_affiliation_invitation_uses_outcome_concept_id" FOREIGN KEY ("outcome_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

DO $$ BEGIN
    ALTER TABLE "practice"."practitioner_location_assignments"
        ADD CONSTRAINT "fk_practitioner_location_assignments_practitioner_role_7cd3d7ce" FOREIGN KEY ("practitioner_role_assignment_id")
        REFERENCES "practice"."practitioner_role_assignments" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "practice"."practitioner_location_assignments"
        ADD CONSTRAINT "fk_practitioner_location_assignments_care_space_id" FOREIGN KEY ("care_space_id")
        REFERENCES "practice"."care_spaces" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "practice"."practitioner_location_assignments"
        ADD CONSTRAINT "fk_practitioner_location_assignments_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "practice"."practitioner_location_assignments"
        ADD CONSTRAINT "fk_practitioner_location_assignments_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "practice"."practitioner_location_assignments"
        ADD CONSTRAINT "fk_practitioner_location_assignments_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

DO $$ BEGIN
    ALTER TABLE "community"."conversation_assignments"
        ADD CONSTRAINT "fk_conversation_assignments_conversation_id" FOREIGN KEY ("conversation_id")
        REFERENCES "community"."conversations" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "community"."conversation_internal_notes"
        ADD CONSTRAINT "fk_conversation_internal_notes_conversation_id" FOREIGN KEY ("conversation_id")
        REFERENCES "community"."conversations" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "community"."direct_messages"
        ADD CONSTRAINT "fk_direct_messages_authored_by_user_id" FOREIGN KEY ("authored_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: profiles.health_practitioner_profiles (requiere schema profiles)
DO $$ BEGIN
    ALTER TABLE "community"."direct_messages"
        ADD CONSTRAINT "fk_direct_messages_on_behalf_of_profile_id" FOREIGN KEY ("on_behalf_of_profile_id")
        REFERENCES "profiles"."health_practitioner_profiles" ("profile_id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: delegated_access.practitioner_delegate_assignments (requiere schema delegated_access)
DO $$ BEGIN
    ALTER TABLE "community"."direct_messages"
        ADD CONSTRAINT "fk_direct_messages_delegate_assignment_id" FOREIGN KEY ("delegate_assignment_id")
        REFERENCES "delegated_access"."practitioner_delegate_assignments" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: profiles.health_practitioner_profiles (requiere schema profiles)
DO $$ BEGIN
    ALTER TABLE "community"."conversation_assignments"
        ADD CONSTRAINT "fk_conversation_assignments_practitioner_profile_id" FOREIGN KEY ("practitioner_profile_id")
        REFERENCES "profiles"."health_practitioner_profiles" ("profile_id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "community"."conversation_assignments"
        ADD CONSTRAINT "fk_conversation_assignments_assigned_user_id" FOREIGN KEY ("assigned_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "community"."conversation_assignments"
        ADD CONSTRAINT "fk_conversation_assignments_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "community"."conversation_assignments"
        ADD CONSTRAINT "fk_conversation_assignments_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "community"."conversation_assignments"
        ADD CONSTRAINT "fk_conversation_assignments_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "community"."conversation_internal_notes"
        ADD CONSTRAINT "fk_conversation_internal_notes_author_user_id" FOREIGN KEY ("author_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: directory.tenants (requiere schema directory)
DO $$ BEGIN
    ALTER TABLE "community"."reply_templates"
        ADD CONSTRAINT "fk_reply_templates_tenant_id" FOREIGN KEY ("tenant_id")
        REFERENCES "directory"."tenants" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: profiles.health_practitioner_profiles (requiere schema profiles)
DO $$ BEGIN
    ALTER TABLE "community"."reply_templates"
        ADD CONSTRAINT "fk_reply_templates_practitioner_profile_id" FOREIGN KEY ("practitioner_profile_id")
        REFERENCES "profiles"."health_practitioner_profiles" ("profile_id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "community"."reply_templates"
        ADD CONSTRAINT "fk_reply_templates_category_concept_id" FOREIGN KEY ("category_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "community"."reply_templates"
        ADD CONSTRAINT "fk_reply_templates_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "community"."reply_templates"
        ADD CONSTRAINT "fk_reply_templates_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "community"."reply_templates"
        ADD CONSTRAINT "fk_reply_templates_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

DO $$ BEGIN
    ALTER TABLE "delegated_access"."organization_user_assignments"
        ADD CONSTRAINT "fk_organization_user_assignments_role_template_id" FOREIGN KEY ("role_template_id")
        REFERENCES "delegated_access"."role_templates" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "delegated_access"."support_scope_grants"
        ADD CONSTRAINT "fk_support_scope_grants_organization_user_assignment_id" FOREIGN KEY ("organization_user_assignment_id")
        REFERENCES "delegated_access"."organization_user_assignments" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "delegated_access"."support_grant_actions"
        ADD CONSTRAINT "fk_support_grant_actions_support_scope_grant_id" FOREIGN KEY ("support_scope_grant_id")
        REFERENCES "delegated_access"."support_scope_grants" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "delegated_access"."engagement_requests"
        ADD CONSTRAINT "fk_engagement_requests_role_template_id" FOREIGN KEY ("role_template_id")
        REFERENCES "delegated_access"."role_templates" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "delegated_access"."engagement_requests"
        ADD CONSTRAINT "fk_engagement_requests_parent_assignment_id" FOREIGN KEY ("parent_assignment_id")
        REFERENCES "delegated_access"."organization_user_assignments" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "delegated_access"."engagement_request_items"
        ADD CONSTRAINT "fk_engagement_request_items_engagement_request_id" FOREIGN KEY ("engagement_request_id")
        REFERENCES "delegated_access"."engagement_requests" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "delegated_access"."engagement_request_items"
        ADD CONSTRAINT "fk_engagement_request_items_resulting_grant_id" FOREIGN KEY ("resulting_grant_id")
        REFERENCES "delegated_access"."support_scope_grants" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "delegated_access"."effective_support_access"
        ADD CONSTRAINT "fk_effective_support_access_grant_id" FOREIGN KEY ("grant_id")
        REFERENCES "delegated_access"."support_scope_grants" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "delegated_access"."organization_user_assignments"
        ADD CONSTRAINT "fk_organization_user_assignments_origin_concept_id" FOREIGN KEY ("origin_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "delegated_access"."organization_user_assignments"
        ADD CONSTRAINT "fk_organization_user_assignments_owner_kind_concept_id" FOREIGN KEY ("owner_kind_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "delegated_access"."practitioner_delegate_assignments"
        ADD CONSTRAINT "fk_practitioner_delegate_assignments_reply_disclosure__d918f1cb" FOREIGN KEY ("reply_disclosure_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: directory.tenants (requiere schema directory)
DO $$ BEGIN
    ALTER TABLE "delegated_access"."role_templates"
        ADD CONSTRAINT "fk_role_templates_tenant_id" FOREIGN KEY ("tenant_id")
        REFERENCES "directory"."tenants" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "delegated_access"."role_templates"
        ADD CONSTRAINT "fk_role_templates_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "delegated_access"."role_templates"
        ADD CONSTRAINT "fk_role_templates_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "delegated_access"."role_templates"
        ADD CONSTRAINT "fk_role_templates_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "delegated_access"."support_scope_grants"
        ADD CONSTRAINT "fk_support_scope_grants_target_kind_concept_id" FOREIGN KEY ("target_kind_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: practice.practitioner_role_assignments (requiere schema practice)
DO $$ BEGIN
    ALTER TABLE "delegated_access"."support_scope_grants"
        ADD CONSTRAINT "fk_support_scope_grants_practitioner_role_assignment_id" FOREIGN KEY ("practitioner_role_assignment_id")
        REFERENCES "practice"."practitioner_role_assignments" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: practice.healthcare_services (requiere schema practice)
DO $$ BEGIN
    ALTER TABLE "delegated_access"."support_scope_grants"
        ADD CONSTRAINT "fk_support_scope_grants_healthcare_service_id" FOREIGN KEY ("healthcare_service_id")
        REFERENCES "practice"."healthcare_services" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: practice.care_spaces (requiere schema practice)
DO $$ BEGIN
    ALTER TABLE "delegated_access"."support_scope_grants"
        ADD CONSTRAINT "fk_support_scope_grants_care_space_id" FOREIGN KEY ("care_space_id")
        REFERENCES "practice"."care_spaces" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: practice.practice_sites (requiere schema practice)
DO $$ BEGIN
    ALTER TABLE "delegated_access"."support_scope_grants"
        ADD CONSTRAINT "fk_support_scope_grants_practice_site_id" FOREIGN KEY ("practice_site_id")
        REFERENCES "practice"."practice_sites" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "delegated_access"."support_scope_grants"
        ADD CONSTRAINT "fk_support_scope_grants_expansion_mode_concept_id" FOREIGN KEY ("expansion_mode_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "delegated_access"."support_scope_grants"
        ADD CONSTRAINT "fk_support_scope_grants_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "delegated_access"."support_scope_grants"
        ADD CONSTRAINT "fk_support_scope_grants_approved_by_user_id" FOREIGN KEY ("approved_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "delegated_access"."support_scope_grants"
        ADD CONSTRAINT "fk_support_scope_grants_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "delegated_access"."support_scope_grants"
        ADD CONSTRAINT "fk_support_scope_grants_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: authz.permissions (requiere schema authz)
DO $$ BEGIN
    ALTER TABLE "delegated_access"."support_grant_actions"
        ADD CONSTRAINT "fk_support_grant_actions_permission_id" FOREIGN KEY ("permission_id")
        REFERENCES "authz"."permissions" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: directory.tenants (requiere schema directory)
DO $$ BEGIN
    ALTER TABLE "delegated_access"."engagement_requests"
        ADD CONSTRAINT "fk_engagement_requests_tenant_id" FOREIGN KEY ("tenant_id")
        REFERENCES "directory"."tenants" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "delegated_access"."engagement_requests"
        ADD CONSTRAINT "fk_engagement_requests_requester_user_id" FOREIGN KEY ("requester_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "delegated_access"."engagement_requests"
        ADD CONSTRAINT "fk_engagement_requests_direction_concept_id" FOREIGN KEY ("direction_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "delegated_access"."engagement_requests"
        ADD CONSTRAINT "fk_engagement_requests_status_concept_id" FOREIGN KEY ("status_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "delegated_access"."engagement_requests"
        ADD CONSTRAINT "fk_engagement_requests_decided_by_user_id" FOREIGN KEY ("decided_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "delegated_access"."engagement_requests"
        ADD CONSTRAINT "fk_engagement_requests_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "delegated_access"."engagement_requests"
        ADD CONSTRAINT "fk_engagement_requests_updated_by_user_id" FOREIGN KEY ("updated_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "delegated_access"."engagement_request_items"
        ADD CONSTRAINT "fk_engagement_request_items_target_kind_concept_id" FOREIGN KEY ("target_kind_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: practice.practitioner_role_assignments (requiere schema practice)
DO $$ BEGIN
    ALTER TABLE "delegated_access"."engagement_request_items"
        ADD CONSTRAINT "fk_engagement_request_items_practitioner_role_assignment_id" FOREIGN KEY ("practitioner_role_assignment_id")
        REFERENCES "practice"."practitioner_role_assignments" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: practice.healthcare_services (requiere schema practice)
DO $$ BEGIN
    ALTER TABLE "delegated_access"."engagement_request_items"
        ADD CONSTRAINT "fk_engagement_request_items_healthcare_service_id" FOREIGN KEY ("healthcare_service_id")
        REFERENCES "practice"."healthcare_services" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: practice.care_spaces (requiere schema practice)
DO $$ BEGIN
    ALTER TABLE "delegated_access"."engagement_request_items"
        ADD CONSTRAINT "fk_engagement_request_items_care_space_id" FOREIGN KEY ("care_space_id")
        REFERENCES "practice"."care_spaces" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: practice.practice_sites (requiere schema practice)
DO $$ BEGIN
    ALTER TABLE "delegated_access"."engagement_request_items"
        ADD CONSTRAINT "fk_engagement_request_items_practice_site_id" FOREIGN KEY ("practice_site_id")
        REFERENCES "practice"."practice_sites" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "delegated_access"."engagement_request_items"
        ADD CONSTRAINT "fk_engagement_request_items_decision_concept_id" FOREIGN KEY ("decision_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: iam.users (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "delegated_access"."effective_support_access"
        ADD CONSTRAINT "fk_effective_support_access_user_id" FOREIGN KEY ("user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: directory.tenants (requiere schema directory)
DO $$ BEGIN
    ALTER TABLE "delegated_access"."effective_support_access"
        ADD CONSTRAINT "fk_effective_support_access_tenant_id" FOREIGN KEY ("tenant_id")
        REFERENCES "directory"."tenants" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: practice.practitioner_role_assignments (requiere schema practice)
DO $$ BEGIN
    ALTER TABLE "delegated_access"."effective_support_access"
        ADD CONSTRAINT "fk_effective_support_access_practitioner_role_assignment_id" FOREIGN KEY ("practitioner_role_assignment_id")
        REFERENCES "practice"."practitioner_role_assignments" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: practice.healthcare_services (requiere schema practice)
DO $$ BEGIN
    ALTER TABLE "delegated_access"."effective_support_access"
        ADD CONSTRAINT "fk_effective_support_access_healthcare_service_id" FOREIGN KEY ("healthcare_service_id")
        REFERENCES "practice"."healthcare_services" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: practice.care_spaces (requiere schema practice)
DO $$ BEGIN
    ALTER TABLE "delegated_access"."effective_support_access"
        ADD CONSTRAINT "fk_effective_support_access_care_space_id" FOREIGN KEY ("care_space_id")
        REFERENCES "practice"."care_spaces" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: practice.care_spaces (requiere schema practice)
DO $$ BEGIN
    ALTER TABLE "scheduling"."bookable_slots"
        ADD CONSTRAINT "fk_bookable_slots_care_space_id" FOREIGN KEY ("care_space_id")
        REFERENCES "practice"."care_spaces" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: practice.healthcare_services (requiere schema practice)
DO $$ BEGIN
    ALTER TABLE "scheduling"."bookable_slots"
        ADD CONSTRAINT "fk_bookable_slots_healthcare_service_id" FOREIGN KEY ("healthcare_service_id")
        REFERENCES "practice"."healthcare_services" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: practice.care_spaces (requiere schema practice)
DO $$ BEGIN
    ALTER TABLE "scheduling"."appointment_bookings"
        ADD CONSTRAINT "fk_appointment_bookings_care_space_id" FOREIGN KEY ("care_space_id")
        REFERENCES "practice"."care_spaces" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: practice.healthcare_services (requiere schema practice)
DO $$ BEGIN
    ALTER TABLE "scheduling"."appointment_bookings"
        ADD CONSTRAINT "fk_appointment_bookings_healthcare_service_id" FOREIGN KEY ("healthcare_service_id")
        REFERENCES "practice"."healthcare_services" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: delegated_access.support_scope_grants (requiere schema delegated_access)
DO $$ BEGIN
    ALTER TABLE "scheduling"."appointment_bookings"
        ADD CONSTRAINT "fk_appointment_bookings_booked_via_grant_id" FOREIGN KEY ("booked_via_grant_id")
        REFERENCES "delegated_access"."support_scope_grants" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- destino: directory.tenants (requiere schema directory)
DO $$ BEGIN
    ALTER TABLE "delegated_access"."support_scope_grants"
        ADD CONSTRAINT "fk_support_scope_grants_tenant_id" FOREIGN KEY ("tenant_id")
        REFERENCES "directory"."tenants" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: directory.tenants (requiere schema directory)
DO $$ BEGIN
    ALTER TABLE "delegated_access"."support_grant_actions"
        ADD CONSTRAINT "fk_support_grant_actions_tenant_id" FOREIGN KEY ("tenant_id")
        REFERENCES "directory"."tenants" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: directory.tenants (requiere schema directory)
DO $$ BEGIN
    ALTER TABLE "delegated_access"."engagement_request_items"
        ADD CONSTRAINT "fk_engagement_request_items_tenant_id" FOREIGN KEY ("tenant_id")
        REFERENCES "directory"."tenants" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: directory.tenants (requiere schema directory)
DO $$ BEGIN
    ALTER TABLE "community"."conversation_assignments"
        ADD CONSTRAINT "fk_conversation_assignments_tenant_id" FOREIGN KEY ("tenant_id")
        REFERENCES "directory"."tenants" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: directory.tenants (requiere schema directory)
DO $$ BEGIN
    ALTER TABLE "community"."conversation_internal_notes"
        ADD CONSTRAINT "fk_conversation_internal_notes_tenant_id" FOREIGN KEY ("tenant_id")
        REFERENCES "directory"."tenants" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

DO $$ BEGIN
    ALTER TABLE "directory"."affiliation_invitation_uses"
        ADD CONSTRAINT "fk_affiliation_invitation_uses_tenant_id" FOREIGN KEY ("tenant_id")
        REFERENCES "directory"."tenants" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: directory.tenants (requiere schema directory)
DO $$ BEGIN
    ALTER TABLE "practice"."practitioner_location_assignments"
        ADD CONSTRAINT "fk_practitioner_location_assignments_tenant_id" FOREIGN KEY ("tenant_id")
        REFERENCES "directory"."tenants" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "directory"."tenant_memberships"
        ADD CONSTRAINT "fk_tenant_memberships_origin_concept_id" FOREIGN KEY ("origin_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;  -- (inferida por convención)


-- ---- 4. indices (103; los 5 unicos parciales de v4.2.70 van en la 4b y el unico funcional de v4.2.71 en la 4c) ----

CREATE INDEX IF NOT EXISTS "ix_session_policies_tenant_id" ON "iam"."session_policies" ("tenant_id", "status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_session_policies_scope_concept_id" ON "iam"."session_policies" ("scope_concept_id");

CREATE INDEX IF NOT EXISTS "ix_session_policies_status_concept_id" ON "iam"."session_policies" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_session_policies_created_by_user_id" ON "iam"."session_policies" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_session_policies_updated_by_user_id" ON "iam"."session_policies" ("updated_by_user_id");

CREATE UNIQUE INDEX IF NOT EXISTS "uq_affiliation_invitations_token_hash" ON "directory"."affiliation_invitations" ("token_hash");

CREATE INDEX IF NOT EXISTS "ix_affiliation_invitations_tenant_id" ON "directory"."affiliation_invitations" ("tenant_id", "status_concept_id", "expires_at");

CREATE INDEX IF NOT EXISTS "ix_affiliation_invitations_kind_concept_id" ON "directory"."affiliation_invitations" ("kind_concept_id");

CREATE INDEX IF NOT EXISTS "ix_affiliation_invitations_target_person_id" ON "directory"."affiliation_invitations" ("target_person_id");

CREATE INDEX IF NOT EXISTS "ix_affiliation_invitations_role_template_id" ON "directory"."affiliation_invitations" ("role_template_id");

CREATE INDEX IF NOT EXISTS "ix_affiliation_invitations_status_concept_id" ON "directory"."affiliation_invitations" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_affiliation_invitations_created_by_user_id" ON "directory"."affiliation_invitations" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_affiliation_invitations_updated_by_user_id" ON "directory"."affiliation_invitations" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_affiliation_invitation_uses_invitation_occurred" ON "directory"."affiliation_invitation_uses" ("affiliation_invitation_id", "occurred_at" DESC);

CREATE INDEX IF NOT EXISTS "ix_affiliation_invitation_uses_used_by_user_id" ON "directory"."affiliation_invitation_uses" ("used_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_affiliation_invitation_uses_outcome_concept_id" ON "directory"."affiliation_invitation_uses" ("outcome_concept_id");

CREATE INDEX IF NOT EXISTS "brin_affiliation_invitation_uses_occurred_at" ON "directory"."affiliation_invitation_uses" USING brin ("occurred_at") WITH (pages_per_range=128);

CREATE INDEX IF NOT EXISTS "ix_care_spaces_location_path" ON "practice"."care_spaces" (location_path varchar_pattern_ops);

CREATE INDEX IF NOT EXISTS "ix_practitioner_location_assignments_practitioner_role_a_id" ON "practice"."practitioner_location_assignments" ("practitioner_role_assignment_id");

CREATE INDEX IF NOT EXISTS "ix_practitioner_location_assignments_care_space_id" ON "practice"."practitioner_location_assignments" ("care_space_id");

CREATE INDEX IF NOT EXISTS "ix_practitioner_location_assignments_status_concept_id" ON "practice"."practitioner_location_assignments" ("status_concept_id");

CREATE UNIQUE INDEX IF NOT EXISTS "uq_practitioner_location_assignments_current" ON "practice"."practitioner_location_assignments" ("practitioner_role_assignment_id", "care_space_id") WHERE valid_to IS NULL;

CREATE INDEX IF NOT EXISTS "ix_practitioner_location_assignments_created_by_user_id" ON "practice"."practitioner_location_assignments" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_practitioner_location_assignments_updated_by_user_id" ON "practice"."practitioner_location_assignments" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_direct_messages_authored_by_user_id" ON "community"."direct_messages" ("authored_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_direct_messages_on_behalf_of_profile_id" ON "community"."direct_messages" ("on_behalf_of_profile_id");

CREATE INDEX IF NOT EXISTS "ix_direct_messages_delegate_assignment_id" ON "community"."direct_messages" ("delegate_assignment_id");

CREATE UNIQUE INDEX IF NOT EXISTS "uq_conversation_assignments_conversation_id" ON "community"."conversation_assignments" ("conversation_id");

CREATE INDEX IF NOT EXISTS "ix_conversation_assignments_practitioner_profile_id" ON "community"."conversation_assignments" ("practitioner_profile_id", "status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_conversation_assignments_assigned_user_id" ON "community"."conversation_assignments" ("assigned_user_id");

CREATE INDEX IF NOT EXISTS "ix_conversation_assignments_status_concept_id" ON "community"."conversation_assignments" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_conversation_assignments_sla_due_at" ON "community"."conversation_assignments" ("sla_due_at") WHERE sla_due_at IS NOT NULL;

CREATE INDEX IF NOT EXISTS "ix_conversation_assignments_created_by_user_id" ON "community"."conversation_assignments" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_conversation_assignments_updated_by_user_id" ON "community"."conversation_assignments" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_conversation_internal_notes_conversation_created" ON "community"."conversation_internal_notes" ("conversation_id", "created_at" DESC);

CREATE INDEX IF NOT EXISTS "ix_conversation_internal_notes_author_user_id" ON "community"."conversation_internal_notes" ("author_user_id");

CREATE INDEX IF NOT EXISTS "ix_reply_templates_tenant_id" ON "community"."reply_templates" ("tenant_id", "status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_reply_templates_practitioner_profile_id" ON "community"."reply_templates" ("practitioner_profile_id");

CREATE INDEX IF NOT EXISTS "ix_reply_templates_category_concept_id" ON "community"."reply_templates" ("category_concept_id");

CREATE INDEX IF NOT EXISTS "ix_reply_templates_status_concept_id" ON "community"."reply_templates" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_reply_templates_created_by_user_id" ON "community"."reply_templates" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_reply_templates_updated_by_user_id" ON "community"."reply_templates" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_organization_user_assignments_origin_concept_id" ON "delegated_access"."organization_user_assignments" ("origin_concept_id");

CREATE INDEX IF NOT EXISTS "ix_organization_user_assignments_owner_kind_concept_id" ON "delegated_access"."organization_user_assignments" ("owner_kind_concept_id");

CREATE INDEX IF NOT EXISTS "ix_organization_user_assignments_role_template_id" ON "delegated_access"."organization_user_assignments" ("role_template_id");

CREATE INDEX IF NOT EXISTS "ix_organization_user_assignments_next_recertification" ON "delegated_access"."organization_user_assignments" ("next_recertification_at") WHERE next_recertification_at IS NOT NULL;

CREATE INDEX IF NOT EXISTS "ix_practitioner_delegate_assignments_reply_disclosure__69a0ebfe" ON "delegated_access"."practitioner_delegate_assignments" ("reply_disclosure_concept_id");

CREATE INDEX IF NOT EXISTS "ix_role_templates_tenant_id" ON "delegated_access"."role_templates" ("tenant_id");

CREATE INDEX IF NOT EXISTS "ix_role_templates_status_concept_id" ON "delegated_access"."role_templates" ("status_concept_id");

CREATE UNIQUE INDEX IF NOT EXISTS "uq_role_templates_platform_code_version" ON "delegated_access"."role_templates" ("code", "version_number") WHERE tenant_id IS NULL;

CREATE UNIQUE INDEX IF NOT EXISTS "uq_role_templates_tenant_code_version" ON "delegated_access"."role_templates" ("tenant_id", "code", "version_number") WHERE tenant_id IS NOT NULL;

CREATE INDEX IF NOT EXISTS "ix_role_templates_created_by_user_id" ON "delegated_access"."role_templates" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_role_templates_updated_by_user_id" ON "delegated_access"."role_templates" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_support_scope_grants_org_user_assignment_id" ON "delegated_access"."support_scope_grants" ("organization_user_assignment_id", "status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_support_scope_grants_target_kind_concept_id" ON "delegated_access"."support_scope_grants" ("target_kind_concept_id");

CREATE INDEX IF NOT EXISTS "ix_support_scope_grants_practitioner_role_assignment_id" ON "delegated_access"."support_scope_grants" ("practitioner_role_assignment_id");

CREATE INDEX IF NOT EXISTS "ix_support_scope_grants_healthcare_service_id" ON "delegated_access"."support_scope_grants" ("healthcare_service_id");

CREATE INDEX IF NOT EXISTS "ix_support_scope_grants_care_space_id" ON "delegated_access"."support_scope_grants" ("care_space_id");

CREATE INDEX IF NOT EXISTS "ix_support_scope_grants_practice_site_id" ON "delegated_access"."support_scope_grants" ("practice_site_id");

CREATE INDEX IF NOT EXISTS "ix_support_scope_grants_expansion_mode_concept_id" ON "delegated_access"."support_scope_grants" ("expansion_mode_concept_id");

CREATE INDEX IF NOT EXISTS "ix_support_scope_grants_status_concept_id" ON "delegated_access"."support_scope_grants" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_support_scope_grants_approved_by_user_id" ON "delegated_access"."support_scope_grants" ("approved_by_user_id");

CREATE INDEX IF NOT EXISTS "gist_support_scope_grants_effective_period" ON "delegated_access"."support_scope_grants" USING gist (tstzrange(valid_from, valid_to, '[)'));

CREATE INDEX IF NOT EXISTS "ix_support_scope_grants_created_by_user_id" ON "delegated_access"."support_scope_grants" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_support_scope_grants_updated_by_user_id" ON "delegated_access"."support_scope_grants" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_support_grant_actions_permission_id" ON "delegated_access"."support_grant_actions" ("permission_id");

CREATE UNIQUE INDEX IF NOT EXISTS "uq_support_grant_actions_grant_permission" ON "delegated_access"."support_grant_actions" ("support_scope_grant_id", "permission_id");

CREATE INDEX IF NOT EXISTS "ix_engagement_requests_tenant_id" ON "delegated_access"."engagement_requests" ("tenant_id", "status_concept_id", "expires_at");

CREATE INDEX IF NOT EXISTS "ix_engagement_requests_requester_user_id" ON "delegated_access"."engagement_requests" ("requester_user_id");

CREATE INDEX IF NOT EXISTS "ix_engagement_requests_direction_concept_id" ON "delegated_access"."engagement_requests" ("direction_concept_id");

CREATE INDEX IF NOT EXISTS "ix_engagement_requests_role_template_id" ON "delegated_access"."engagement_requests" ("role_template_id");

CREATE INDEX IF NOT EXISTS "ix_engagement_requests_parent_assignment_id" ON "delegated_access"."engagement_requests" ("parent_assignment_id");

CREATE INDEX IF NOT EXISTS "ix_engagement_requests_status_concept_id" ON "delegated_access"."engagement_requests" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_engagement_requests_decided_by_user_id" ON "delegated_access"."engagement_requests" ("decided_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_engagement_requests_created_by_user_id" ON "delegated_access"."engagement_requests" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_engagement_requests_updated_by_user_id" ON "delegated_access"."engagement_requests" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_engagement_request_items_engagement_request_id" ON "delegated_access"."engagement_request_items" ("engagement_request_id");

CREATE INDEX IF NOT EXISTS "ix_engagement_request_items_target_kind_concept_id" ON "delegated_access"."engagement_request_items" ("target_kind_concept_id");

CREATE INDEX IF NOT EXISTS "ix_engagement_request_items_practitioner_role_assign_id" ON "delegated_access"."engagement_request_items" ("practitioner_role_assignment_id");

CREATE INDEX IF NOT EXISTS "ix_engagement_request_items_healthcare_service_id" ON "delegated_access"."engagement_request_items" ("healthcare_service_id");

CREATE INDEX IF NOT EXISTS "ix_engagement_request_items_care_space_id" ON "delegated_access"."engagement_request_items" ("care_space_id");

CREATE INDEX IF NOT EXISTS "ix_engagement_request_items_practice_site_id" ON "delegated_access"."engagement_request_items" ("practice_site_id");

CREATE INDEX IF NOT EXISTS "ix_engagement_request_items_decision_concept_id" ON "delegated_access"."engagement_request_items" ("decision_concept_id");

CREATE INDEX IF NOT EXISTS "ix_engagement_request_items_resulting_grant_id" ON "delegated_access"."engagement_request_items" ("resulting_grant_id");

CREATE INDEX IF NOT EXISTS "ix_effective_support_access_lookup" ON "delegated_access"."effective_support_access" ("user_id", "tenant_id", "permission_code");

CREATE INDEX IF NOT EXISTS "ix_effective_support_access_tenant_id" ON "delegated_access"."effective_support_access" ("tenant_id");

CREATE INDEX IF NOT EXISTS "ix_effective_support_access_grant_id" ON "delegated_access"."effective_support_access" ("grant_id");

CREATE INDEX IF NOT EXISTS "ix_effective_support_access_practitioner_role_assign_id" ON "delegated_access"."effective_support_access" ("practitioner_role_assignment_id");

CREATE INDEX IF NOT EXISTS "ix_effective_support_access_healthcare_service_id" ON "delegated_access"."effective_support_access" ("healthcare_service_id");

CREATE INDEX IF NOT EXISTS "ix_effective_support_access_care_space_id" ON "delegated_access"."effective_support_access" ("care_space_id");

CREATE INDEX IF NOT EXISTS "ix_bookable_slots_care_space_id" ON "scheduling"."bookable_slots" ("care_space_id");

CREATE INDEX IF NOT EXISTS "ix_bookable_slots_healthcare_service_id" ON "scheduling"."bookable_slots" ("healthcare_service_id");

CREATE INDEX IF NOT EXISTS "ix_appointment_bookings_care_space_id" ON "scheduling"."appointment_bookings" ("care_space_id");

CREATE INDEX IF NOT EXISTS "ix_appointment_bookings_healthcare_service_id" ON "scheduling"."appointment_bookings" ("healthcare_service_id");

CREATE INDEX IF NOT EXISTS "ix_appointment_bookings_booked_via_grant_id" ON "scheduling"."appointment_bookings" ("booked_via_grant_id");

CREATE INDEX IF NOT EXISTS "ix_support_scope_grants_tenant_id" ON "delegated_access"."support_scope_grants" ("tenant_id", "status_concept_id");


CREATE INDEX IF NOT EXISTS "ix_support_grant_actions_tenant_id" ON "delegated_access"."support_grant_actions" ("tenant_id");


CREATE INDEX IF NOT EXISTS "ix_engagement_request_items_tenant_id" ON "delegated_access"."engagement_request_items" ("tenant_id");


CREATE INDEX IF NOT EXISTS "ix_conversation_assignments_tenant_id" ON "community"."conversation_assignments" ("tenant_id", "status_concept_id");


CREATE INDEX IF NOT EXISTS "ix_conversation_internal_notes_tenant_id" ON "community"."conversation_internal_notes" ("tenant_id");


CREATE INDEX IF NOT EXISTS "ix_affiliation_invitation_uses_tenant_id" ON "directory"."affiliation_invitation_uses" ("tenant_id");


CREATE INDEX IF NOT EXISTS "ix_practitioner_location_assignments_tenant_id" ON "practice"."practitioner_location_assignments" ("tenant_id", "status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_tenant_memberships_origin_concept_id" ON "directory"."tenant_memberships" ("origin_concept_id");


-- ---- 4b. indices UNICOS parciales (v4.2.70) ----
--
-- Se crean con una guarda: si la base YA tiene datos que los violan, el parche NO falla ni borra nada;
-- avisa con un WARNING (con el nombre del indice y la cantidad de grupos duplicados) y sigue. Se corrige
-- el dato y se vuelve a ejecutar el parche (es idempotente). En una base sin duplicados quedan creados.
--   uq_session_policies_active_tenant_scope(_role)  una politica ACTIVA por (organizacion, alcance[, rol]);
--                                                   las retiradas (state:revoked) no cuentan: el segundo PUT
--                                                   del mismo alcance ya no choca. Reemplazan a los
--                                                   uq_session_policies_tenant_scope(_role), que no miraban el estado.
--   uq_organization_user_assignments_active_template un solo vinculo de apoyo ACTIVO por membresia (persona +
--                                                   organizacion) y plantilla; solo los del modelo nuevo
--                                                   (role_template_id NOT NULL).
--   uq_affiliation_invitation_uses_accepted         una persona se afilia UNA vez por invitacion (solo el uso
--                                                   ACEPTADO; los rechazos se registran cada vez).
--   uq_tenant_memberships_active_user_tenant        una sola membresia ACTIVA por (usuario, organizacion).
DO $$
DECLARE
    r record;
    v_dups bigint;
BEGIN
    FOR r IN SELECT * FROM (VALUES
        ('uq_session_policies_active_tenant_scope', 'iam', 'session_policies',
         '"tenant_id", "scope_concept_id"',
         'role_code IS NULL AND status_concept_id = ''38a1d301-f40d-5b17-a695-5e6d605f8b19'''),
        ('uq_session_policies_active_tenant_scope_role', 'iam', 'session_policies',
         '"tenant_id", "scope_concept_id", "role_code"',
         'role_code IS NOT NULL AND status_concept_id = ''38a1d301-f40d-5b17-a695-5e6d605f8b19'''),
        ('uq_organization_user_assignments_active_template', 'delegated_access', 'organization_user_assignments',
         '"tenant_membership_id", "role_template_id"',
         'role_template_id IS NOT NULL AND status_concept_id = ''38a1d301-f40d-5b17-a695-5e6d605f8b19'''),
        ('uq_affiliation_invitation_uses_accepted', 'directory', 'affiliation_invitation_uses',
         '"affiliation_invitation_id", "used_by_user_id"',
         'outcome_concept_id = ''659f9beb-ad4d-583e-828b-05a808ad08dc'''),
        ('uq_tenant_memberships_active_user_tenant', 'directory', 'tenant_memberships',
         '"user_id", "tenant_id"',
         'status_concept_id = ''13ca1b46-61d5-5c25-9d49-8247bcd7769c''')
    ) v(idx, s, t, cols, pred)
    LOOP
        CONTINUE WHEN to_regclass(format('%I.%I', r.s, r.idx)) IS NOT NULL;
        EXECUTE format('SELECT count(*) FROM (SELECT 1 FROM %I.%I WHERE %s GROUP BY %s HAVING count(*) > 1) d',
                       r.s, r.t, r.pred, r.cols) INTO v_dups;
        IF v_dups > 0 THEN
            RAISE WARNING 'indice % NO creado: % grupo(s) duplicados en %.% (WHERE %). Consulta: SELECT %, count(*) FROM %.% WHERE % GROUP BY % HAVING count(*) > 1',
                r.idx, v_dups, r.s, r.t, r.pred, r.cols, r.s, r.t, r.pred, r.cols;
        ELSE
            EXECUTE format('CREATE UNIQUE INDEX %I ON %I.%I (%s) WHERE %s', r.idx, r.s, r.t, r.cols, r.pred);
        END IF;
    END LOOP;
END $$;

-- Los unicos anteriores de session_policies no incluian el estado: el segundo PUT del mismo alcance los violaba.
-- Se retiran SOLO cuando el reemplazo ya existe (si quedo sin crear por duplicados, el viejo sigue protegiendo).
DO $$
BEGIN
    IF to_regclass('iam.uq_session_policies_active_tenant_scope') IS NOT NULL THEN
        DROP INDEX IF EXISTS "iam"."uq_session_policies_tenant_scope";
    END IF;
    IF to_regclass('iam.uq_session_policies_active_tenant_scope_role') IS NOT NULL THEN
        DROP INDEX IF EXISTS "iam"."uq_session_policies_tenant_scope_role";
    END IF;
END $$;

-- ---- 4c. documento nacional normalizado UNICO (v4.2.71, revision de seguridad N3) ----
--
-- Un documento nacional ACTIVO de paciente no puede repetirse, comparado en su forma canonica: mayusculas, sin
-- puntos, guiones ni espacios y sin ceros a la izquierda ("1234567", "01234567", "1.234.567 " y "1-234-567" son el
-- mismo documento). La expresion es EXACTAMENTE la de la API (normalizeNationalId en profiles/domain/national-id.ts y
-- NORMALIZED_ID en SupportPatientsRepository): si se cambia una, se cambia la otra.
--   WHERE type_concept_id  = common:id-type:national          (595e7a3d-ba37-5014-9a72-635363b94864)
--     AND state_concept_id = state:active                     (38a1d301-f40d-5b17-a695-5e6d605f8b19)
--     AND owner_type_concept_id = common:owner-type:patient   (350a0150-c27c-5241-b5d8-78daa13bed34)
--     AND valid_to IS NULL
--   - Solo OWNER_PATIENT: las personas de contacto (representantes legales y gerencias, OWNER_PERSON) se crean sin
--     buscar duplicado y pueden repetir documento a proposito (createContactPerson).
--   - Solo filas sin cierre (valid_to IS NULL): cambiar el numero del documento cierra la fila vieja (valid_to) y abre
--     otra; las historicas con vigencias superpuestas no cuentan.
-- Con guarda: si la base YA tiene duplicados, el parche NO falla ni borra nada; avisa con un WARNING (cantidad de
-- grupos y la consulta de diagnostico) y crea el indice NO unico de apoyo ix_identifiers_national_id_normalized, que
-- sirve las busquedas por documento normalizado mientras se corrigen los datos. Se corrige y se vuelve a ejecutar
-- el parche (idempotente): crea el unico y retira el de apoyo. En una base nueva (apply_all.sql) el unico ya existe.
-- La creacion toma un bloqueo que impide escribir en common.identifiers mientras dura: en una tabla grande, correrlo
-- en una ventana tranquila.
DO $$
DECLARE
    v_dups bigint;
BEGIN
    IF to_regclass('common.uq_identifiers_national_id_normalized') IS NOT NULL THEN
        DROP INDEX IF EXISTS "common"."ix_identifiers_national_id_normalized";
        RETURN;
    END IF;

    SELECT count(*) INTO v_dups FROM (
        SELECT 1 FROM "common"."identifiers"
         WHERE type_concept_id = '595e7a3d-ba37-5014-9a72-635363b94864'
           AND state_concept_id = '38a1d301-f40d-5b17-a695-5e6d605f8b19'
           AND owner_type_concept_id = '350a0150-c27c-5241-b5d8-78daa13bed34'
           AND valid_to IS NULL
         GROUP BY coalesce(nullif(regexp_replace(upper(regexp_replace(value, '[\s.-]+', '', 'g')), '^0+', ''), ''), '0')
        HAVING count(*) > 1) d;

    IF v_dups > 0 THEN
        RAISE WARNING 'indice uq_identifiers_national_id_normalized NO creado: % documento(s) nacional(es) activo(s) de paciente repetido(s) en common.identifiers (se crea el indice de apoyo no unico ix_identifiers_national_id_normalized). Corrige los duplicados (cierra con valid_to o cambia el estado de las filas sobrantes, o fusiona los pacientes) y vuelve a ejecutar este parche.',
            v_dups
            USING HINT = 'Consulta: SELECT coalesce(nullif(regexp_replace(upper(regexp_replace(value, ''[\s.-]+'', '''', ''g'')), ''^0+'', ''''), ''''), ''0'') AS documento, count(*) AS filas, array_agg(owner_id ORDER BY created_at) AS owners FROM common.identifiers WHERE type_concept_id = ''595e7a3d-ba37-5014-9a72-635363b94864'' AND state_concept_id = ''38a1d301-f40d-5b17-a695-5e6d605f8b19'' AND owner_type_concept_id = ''350a0150-c27c-5241-b5d8-78daa13bed34'' AND valid_to IS NULL GROUP BY 1 HAVING count(*) > 1 ORDER BY 2 DESC';
        CREATE INDEX IF NOT EXISTS "ix_identifiers_national_id_normalized" ON "common"."identifiers"
            (coalesce(nullif(regexp_replace(upper(regexp_replace(value, '[\s.-]+', '', 'g')), '^0+', ''), ''), '0'))
            WHERE type_concept_id = '595e7a3d-ba37-5014-9a72-635363b94864'
              AND state_concept_id = '38a1d301-f40d-5b17-a695-5e6d605f8b19'
              AND owner_type_concept_id = '350a0150-c27c-5241-b5d8-78daa13bed34'
              AND valid_to IS NULL;
    ELSE
        CREATE UNIQUE INDEX "uq_identifiers_national_id_normalized" ON "common"."identifiers"
            (coalesce(nullif(regexp_replace(upper(regexp_replace(value, '[\s.-]+', '', 'g')), '^0+', ''), ''), '0'))
            WHERE type_concept_id = '595e7a3d-ba37-5014-9a72-635363b94864'
              AND state_concept_id = '38a1d301-f40d-5b17-a695-5e6d605f8b19'
              AND owner_type_concept_id = '350a0150-c27c-5241-b5d8-78daa13bed34'
              AND valid_to IS NULL;
        DROP INDEX IF EXISTS "common"."ix_identifiers_national_id_normalized";
    END IF;
END $$;

-- ---- 5. constraints (CHECK) (15) ----

-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "iam"."session_policies" DROP CONSTRAINT IF EXISTS "ck_session_policies_idle_timeout";
ALTER TABLE "iam"."session_policies" ADD CONSTRAINT "ck_session_policies_idle_timeout" CHECK (("idle_timeout_minutes" > 0 AND "idle_timeout_minutes" <= 1440));

-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "iam"."session_policies" DROP CONSTRAINT IF EXISTS "ck_session_policies_role_code";
ALTER TABLE "iam"."session_policies" ADD CONSTRAINT "ck_session_policies_role_code" CHECK ((("scope_concept_id" = 'b9137390-37e5-5de6-95cf-fc53860563fe') = ("role_code" IS NOT NULL)));

-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "directory"."affiliation_invitations" DROP CONSTRAINT IF EXISTS "ck_affiliation_invitations_uses";
ALTER TABLE "directory"."affiliation_invitations" ADD CONSTRAINT "ck_affiliation_invitations_uses" CHECK (("max_uses" >= 1 AND "uses_count" >= 0 AND "uses_count" <= "max_uses"));

-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "practice"."care_spaces" DROP CONSTRAINT IF EXISTS "ck_care_spaces_fhir_physical_type";
ALTER TABLE "practice"."care_spaces" ADD CONSTRAINT "ck_care_spaces_fhir_physical_type" CHECK (("fhir_physical_type" IS NULL OR "fhir_physical_type" IN ('bu', 'lvl', 'wi', 'ro', 'bd', 'si')));

-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "practice"."care_spaces" DROP CONSTRAINT IF EXISTS "ck_care_spaces_location_path";
ALTER TABLE "practice"."care_spaces" ADD CONSTRAINT "ck_care_spaces_location_path" CHECK (("location_path" IS NULL OR "location_path" ~ '^/([0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}/)+$'));

-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "practice"."practitioner_location_assignments" DROP CONSTRAINT IF EXISTS "ck_practitioner_location_assignments_period";
ALTER TABLE "practice"."practitioner_location_assignments" ADD CONSTRAINT "ck_practitioner_location_assignments_period" CHECK (("valid_from" IS NULL OR "valid_to" IS NULL OR "valid_from" <= "valid_to"));

-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "community"."direct_messages" DROP CONSTRAINT IF EXISTS "ck_direct_messages_on_behalf_has_author";
ALTER TABLE "community"."direct_messages" ADD CONSTRAINT "ck_direct_messages_on_behalf_has_author" CHECK (("on_behalf_of_profile_id" IS NULL OR "authored_by_user_id" IS NOT NULL));

-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "delegated_access"."support_scope_grants" DROP CONSTRAINT IF EXISTS "ck_support_scope_grants_target_coherent";
ALTER TABLE "delegated_access"."support_scope_grants" ADD CONSTRAINT "ck_support_scope_grants_target_coherent" CHECK (("target_kind_concept_id" = '785d1671-5754-58d3-b1a3-e3cd467b82b7' AND "practitioner_role_assignment_id" IS NOT NULL AND "healthcare_service_id" IS NULL AND "care_space_id" IS NULL AND "practice_site_id" IS NULL) OR ("target_kind_concept_id" = '953e4408-5e19-521b-a25a-3d062d788911' AND "practitioner_role_assignment_id" IS NULL AND "healthcare_service_id" IS NOT NULL AND "care_space_id" IS NULL AND "practice_site_id" IS NULL) OR ("target_kind_concept_id" = '10510d38-c6cf-5243-9327-5cefc6c3aee5' AND "practitioner_role_assignment_id" IS NULL AND "healthcare_service_id" IS NULL AND num_nonnulls("care_space_id", "practice_site_id") = 1) OR ("target_kind_concept_id" = '19ff6b5b-b998-54bb-af93-573b96764a6c' AND "practitioner_role_assignment_id" IS NOT NULL AND "healthcare_service_id" IS NOT NULL AND "care_space_id" IS NULL AND "practice_site_id" IS NULL) OR ("target_kind_concept_id" = '2ed23be8-884f-5e75-bd63-a1ff92f42e89' AND "practitioner_role_assignment_id" IS NOT NULL AND "healthcare_service_id" IS NULL AND num_nonnulls("care_space_id", "practice_site_id") = 1) OR ("target_kind_concept_id" = 'cf017e3e-4c7f-5e2f-a7ca-2f2078eb89b3' AND "practitioner_role_assignment_id" IS NULL AND "healthcare_service_id" IS NOT NULL AND num_nonnulls("care_space_id", "practice_site_id") = 1) OR ("target_kind_concept_id" = '81f2ac43-a9ba-5043-b455-ed71b2d7e59f' AND "practitioner_role_assignment_id" IS NULL AND "healthcare_service_id" IS NULL AND "care_space_id" IS NULL AND "practice_site_id" IS NULL) OR ("target_kind_concept_id" = '3df7a566-22b8-512d-85a7-4b89604cb26b' AND "practitioner_role_assignment_id" IS NULL AND "healthcare_service_id" IS NULL AND "care_space_id" IS NULL AND "practice_site_id" IS NULL) OR ("target_kind_concept_id" = 'cf4de420-16da-57f8-8c3a-f6ff717fc59e' AND "practitioner_role_assignment_id" IS NULL AND "healthcare_service_id" IS NULL AND "care_space_id" IS NULL AND "practice_site_id" IS NULL) OR ("target_kind_concept_id" = 'b1330928-a076-5348-bffd-154144fadc85' AND "practitioner_role_assignment_id" IS NULL AND "healthcare_service_id" IS NULL AND "care_space_id" IS NULL AND "practice_site_id" IS NULL));

-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "delegated_access"."support_scope_grants" DROP CONSTRAINT IF EXISTS "ck_support_scope_grants_valid_period";
ALTER TABLE "delegated_access"."support_scope_grants" ADD CONSTRAINT "ck_support_scope_grants_valid_period" CHECK (("valid_from" IS NULL OR "valid_to" IS NULL OR "valid_from" <= "valid_to"));

-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "delegated_access"."support_scope_grants" DROP CONSTRAINT IF EXISTS "ck_support_scope_grants_fixed_snapshot";
ALTER TABLE "delegated_access"."support_scope_grants" ADD CONSTRAINT "ck_support_scope_grants_fixed_snapshot" CHECK (("expansion_mode_concept_id" <> '4f47115f-54ad-564f-bcd4-f06a0a0c13cd' OR (jsonb_typeof("fixed_snapshot_json" -> 'rows') = 'array' AND jsonb_array_length("fixed_snapshot_json" -> 'rows') > 0 AND NOT jsonb_path_exists("fixed_snapshot_json", '$.rows[*] ? (@.type() != "object" || exists(@.keyvalue() ? (@.key != "practitionerRoleAssignmentId" && @.key != "practitionerProfileId" && @.key != "healthcareServiceId" && @.key != "careSpaceId" || @.value.type() != "null" && !(@.value.type() == "string" && @.value like_regex "^[0-9a-f]{8}(-[0-9a-f]{4}){3}-[0-9a-f]{12}$"))) || !(exists(@.practitionerRoleAssignmentId ? (@.type() == "string" && @ like_regex "^[0-9a-f]{8}(-[0-9a-f]{4}){3}-[0-9a-f]{12}$")) || exists(@.healthcareServiceId ? (@.type() == "string" && @ like_regex "^[0-9a-f]{8}(-[0-9a-f]{4}){3}-[0-9a-f]{12}$")) || exists(@.careSpaceId ? (@.type() == "string" && @ like_regex "^[0-9a-f]{8}(-[0-9a-f]{4}){3}-[0-9a-f]{12}$"))))')) IS TRUE));

-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "delegated_access"."engagement_request_items" DROP CONSTRAINT IF EXISTS "ck_engagement_request_items_target_coherent";
ALTER TABLE "delegated_access"."engagement_request_items" ADD CONSTRAINT "ck_engagement_request_items_target_coherent" CHECK (("target_kind_concept_id" = '785d1671-5754-58d3-b1a3-e3cd467b82b7' AND "practitioner_role_assignment_id" IS NOT NULL AND "healthcare_service_id" IS NULL AND "care_space_id" IS NULL AND "practice_site_id" IS NULL) OR ("target_kind_concept_id" = '953e4408-5e19-521b-a25a-3d062d788911' AND "practitioner_role_assignment_id" IS NULL AND "healthcare_service_id" IS NOT NULL AND "care_space_id" IS NULL AND "practice_site_id" IS NULL) OR ("target_kind_concept_id" = '10510d38-c6cf-5243-9327-5cefc6c3aee5' AND "practitioner_role_assignment_id" IS NULL AND "healthcare_service_id" IS NULL AND num_nonnulls("care_space_id", "practice_site_id") = 1) OR ("target_kind_concept_id" = '19ff6b5b-b998-54bb-af93-573b96764a6c' AND "practitioner_role_assignment_id" IS NOT NULL AND "healthcare_service_id" IS NOT NULL AND "care_space_id" IS NULL AND "practice_site_id" IS NULL) OR ("target_kind_concept_id" = '2ed23be8-884f-5e75-bd63-a1ff92f42e89' AND "practitioner_role_assignment_id" IS NOT NULL AND "healthcare_service_id" IS NULL AND num_nonnulls("care_space_id", "practice_site_id") = 1) OR ("target_kind_concept_id" = 'cf017e3e-4c7f-5e2f-a7ca-2f2078eb89b3' AND "practitioner_role_assignment_id" IS NULL AND "healthcare_service_id" IS NOT NULL AND num_nonnulls("care_space_id", "practice_site_id") = 1) OR ("target_kind_concept_id" = '81f2ac43-a9ba-5043-b455-ed71b2d7e59f' AND "practitioner_role_assignment_id" IS NULL AND "healthcare_service_id" IS NULL AND "care_space_id" IS NULL AND "practice_site_id" IS NULL) OR ("target_kind_concept_id" = '3df7a566-22b8-512d-85a7-4b89604cb26b' AND "practitioner_role_assignment_id" IS NULL AND "healthcare_service_id" IS NULL AND "care_space_id" IS NULL AND "practice_site_id" IS NULL) OR ("target_kind_concept_id" = 'cf4de420-16da-57f8-8c3a-f6ff717fc59e' AND "practitioner_role_assignment_id" IS NULL AND "healthcare_service_id" IS NULL AND "care_space_id" IS NULL AND "practice_site_id" IS NULL) OR ("target_kind_concept_id" = 'b1330928-a076-5348-bffd-154144fadc85' AND "practitioner_role_assignment_id" IS NULL AND "healthcare_service_id" IS NULL AND "care_space_id" IS NULL AND "practice_site_id" IS NULL));

-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "delegated_access"."engagement_requests" DROP CONSTRAINT IF EXISTS "ck_engagement_requests_expires_after_created";
ALTER TABLE "delegated_access"."engagement_requests" ADD CONSTRAINT "ck_engagement_requests_expires_after_created" CHECK ("expires_at" > "created_at");

-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "delegated_access"."role_templates" DROP CONSTRAINT IF EXISTS "ck_role_templates_version_number";
ALTER TABLE "delegated_access"."role_templates" ADD CONSTRAINT "ck_role_templates_version_number" CHECK ("version_number" >= 1);

-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "delegated_access"."organization_user_assignments" DROP CONSTRAINT IF EXISTS "ck_organization_user_assignments_recertify_months";
ALTER TABLE "delegated_access"."organization_user_assignments" ADD CONSTRAINT "ck_organization_user_assignments_recertify_months" CHECK (("recertify_every_months" IS NULL OR "recertify_every_months" IN (6, 12)));

-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "iam"."session_policies" DROP CONSTRAINT IF EXISTS "ck_session_policies_allowed_hours";
ALTER TABLE "iam"."session_policies" ADD CONSTRAINT "ck_session_policies_allowed_hours" CHECK (("allowed_hours_json" IS NULL OR (jsonb_typeof("allowed_hours_json") = 'object' AND jsonb_path_exists("allowed_hours_json", '$ ? (@.from.type() == "string" && @.from like_regex "^([01][0-9]|2[0-3]):[0-5][0-9]$" && @.to.type() == "string" && @.to like_regex "^([01][0-9]|2[0-3]):[0-5][0-9]$")') AND ("allowed_hours_json" -> 'days' IS NULL OR jsonb_typeof("allowed_hours_json" -> 'days') = 'array') AND NOT jsonb_path_exists("allowed_hours_json", '$.days[*] ? (@.type() != "number" || @ < 0 || @ > 6 || @ != @.floor())') AND ("allowed_hours_json" -> 'timeZone' IS NULL OR jsonb_typeof("allowed_hours_json" -> 'timeZone') IN ('string', 'null'))) IS TRUE));


-- ---- 6. funciones y disparadores operativos (no salen de ningun .puml) ----
--
-- Endurecimiento v4.2.70 (revision de seguridad M5/M8): TODAS las funciones de esta seccion
--   * fijan `SET search_path = pg_catalog, pg_temp` (nada se resuelve por el search_path del llamador),
--   * se crean con `REVOKE ALL ... FROM PUBLIC` y solo se conceden al rol de la aplicacion `mantra_app`
--     (el que define 2026-08-05_tenant_rls.sql) si existe en la base,
--   * no son SECURITY DEFINER: corren con los privilegios y bajo el RLS de quien las llama.
--
-- refresh_effective_support_access(p_tenant_id): reconstruye la tabla derivada
-- delegated_access.effective_support_access. Solo cuentan los permisos VIGENTES:
--   concesion activa y dentro de su vigencia, con el mismo tenant que su vinculo;
--   vinculo activo, dentro de su vigencia y SIN recertificacion vencida
--     (next_recertification_at + 15 dias de gracia < ahora => no hay acceso, aunque el worker de
--     la API todavia no lo haya pasado a suspendido);
--   membresia del tenant ACTIVA (DIR_MEMBERSHIP_ACTIVE), ya iniciada y sin end_date vencido.
-- Fin de vinculo = el vinculo deja de estar activo = sus filas desaparecen en el siguiente refresh
-- (las citas ya creadas NO se tocan).
-- p_tenant_id NULL recalcula TODAS las organizaciones: solo se permite con `app.system_context = 'true'`
-- (la elevacion SYSTEM del RLS) o con un rol que ya se salta el RLS (superusuario / BYPASSRLS). Con un
-- tenant fijado en `app.current_tenant_id`, solo puede recalcular ESE tenant.
--
-- NOTA sobre la ACEPTACION del doctor: la tabla derivada dice lo que la organizacion CONCEDIO; la
-- aceptacion (practitioner_delegate_assignments.accepted_at) es por doctor y por persona y NO se
-- precalcula aqui. La compuerta de decision es support_access_allowed, que la exige en cada llamada.
--
-- Cada fila deja NULL en las dimensiones que el permiso no acota:
--   PRACTITIONER                  (pra,  NULL, NULL)
--   SERVICE                       (NULL, svc,  NULL)
--   PRACTITIONER_SERVICE          (pra,  svc,  NULL)
--   LOCATION                      (NULL, NULL, espacio)   una fila por espacio dentro de la ubicacion
--   PRACTITIONER_LOCATION         (pra,  NULL, espacio)
--   SERVICE_LOCATION              (NULL, svc,  espacio)
--   ALL_PRACTITIONERS/ALL_SERVICES/ALL_LOCATIONS/ALL   (NULL, NULL, NULL)
-- "Dentro de una ubicacion": el espacio cuelga de la ruta materializada location_path del
-- espacio objetivo (care_space_id), o pertenece a la sede (practice_site_id).
-- Expansion FIXED: usa fixed_snapshot_json->'rows' ([{practitionerRoleAssignmentId,
-- healthcareServiceId, careSpaceId}]) en lugar de mirar la organizacion (el CHECK
-- ck_support_scope_grants_fixed_snapshot garantiza que haya filas y que ninguna sea un comodin).
CREATE SCHEMA IF NOT EXISTS "integrity";

CREATE OR REPLACE FUNCTION "delegated_access"."refresh_effective_support_access"(p_tenant_id uuid DEFAULT NULL)
RETURNS integer
LANGUAGE plpgsql
SET search_path = pg_catalog, pg_temp
AS $fn$
DECLARE
    v_now timestamptz := now();
    v_rows integer;
    v_system boolean := COALESCE(current_setting('app.system_context', true), '') = 'true';
    v_ctx text := COALESCE(NULLIF(current_setting('app.current_tenant_id', true), ''), '');
BEGIN
    IF NOT v_system THEN
        IF p_tenant_id IS NULL AND NOT COALESCE(
               (SELECT r.rolsuper OR r.rolbypassrls FROM pg_catalog.pg_roles r WHERE r.rolname = current_user), false) THEN
            RAISE EXCEPTION 'refresh_effective_support_access(NULL) recalcula todas las organizaciones: exige app.system_context = true'
                USING ERRCODE = 'insufficient_privilege';
        END IF;
        IF p_tenant_id IS NOT NULL AND v_ctx <> '' AND v_ctx <> p_tenant_id::text THEN
            RAISE EXCEPTION 'refresh_effective_support_access: el contexto es de otra organizacion'
                USING ERRCODE = 'insufficient_privilege';
        END IF;
    END IF;

    DELETE FROM "delegated_access"."effective_support_access" e
     WHERE p_tenant_id IS NULL OR e."tenant_id" = p_tenant_id;

    INSERT INTO "delegated_access"."effective_support_access"
        ("id", "user_id", "tenant_id", "practitioner_role_assignment_id", "healthcare_service_id",
         "care_space_id", "permission_code", "grant_id", "refreshed_at")
    WITH live AS (
        SELECT g."id" AS grant_id, g."target_kind_concept_id" AS kind,
               g."expansion_mode_concept_id" AS expansion, g."fixed_snapshot_json" AS snapshot,
               g."practitioner_role_assignment_id" AS pra, g."healthcare_service_id" AS svc,
               g."care_space_id" AS space, g."practice_site_id" AS site,
               tm."user_id", tm."tenant_id"
          FROM "delegated_access"."support_scope_grants" g
          JOIN "delegated_access"."organization_user_assignments" a ON a."id" = g."organization_user_assignment_id"
          JOIN "directory"."tenant_memberships" tm ON tm."id" = a."tenant_membership_id"
         WHERE g."status_concept_id" = 'ccfbc54f-4744-53db-ab1f-abe1af31f784'
           AND g."tenant_id" = tm."tenant_id"
           AND a."status_concept_id" = '38a1d301-f40d-5b17-a695-5e6d605f8b19'
           AND (g."valid_from" IS NULL OR g."valid_from" <= v_now)
           AND (g."valid_to" IS NULL OR g."valid_to" > v_now)
           AND (a."valid_from" IS NULL OR a."valid_from" <= v_now)
           AND (a."valid_to" IS NULL OR a."valid_to" > v_now)
           AND (a."next_recertification_at" IS NULL OR a."next_recertification_at" + interval '15 days' > v_now)
           AND tm."status_concept_id" = '13ca1b46-61d5-5c25-9d49-8247bcd7769c'
           AND tm."start_date" <= v_now
           AND (tm."end_date" IS NULL OR tm."end_date" > v_now)
           AND (p_tenant_id IS NULL OR tm."tenant_id" = p_tenant_id)
    ),
    -- Espacios dentro de la ubicacion de cada concesion que la usa.
    loc AS (
        SELECT l.grant_id, s."id" AS space_id
          FROM live l
          LEFT JOIN "practice"."care_spaces" root ON root."id" = l.space
          JOIN "practice"."care_spaces" s
            ON (l.space IS NOT NULL AND (s."id" = l.space
                 OR (root."location_path" IS NOT NULL AND s."location_path" LIKE root."location_path" || '%')))
            OR (l.site IS NOT NULL AND s."practice_site_id" = l.site)
         WHERE l.expansion <> '4f47115f-54ad-564f-bcd4-f06a0a0c13cd'
           AND l.kind IN ('10510d38-c6cf-5243-9327-5cefc6c3aee5', '2ed23be8-884f-5e75-bd63-a1ff92f42e89', 'cf017e3e-4c7f-5e2f-a7ca-2f2078eb89b3')
    ),
    dims AS (
        -- DYNAMIC sin ubicacion
        SELECT l.grant_id, l.user_id, l.tenant_id,
               CASE WHEN l.kind IN ('785d1671-5754-58d3-b1a3-e3cd467b82b7', '19ff6b5b-b998-54bb-af93-573b96764a6c') THEN l.pra END AS pra,
               CASE WHEN l.kind IN ('953e4408-5e19-521b-a25a-3d062d788911', '19ff6b5b-b998-54bb-af93-573b96764a6c') THEN l.svc END AS svc,
               NULL::uuid AS space
          FROM live l
         WHERE l.expansion <> '4f47115f-54ad-564f-bcd4-f06a0a0c13cd'
           AND l.kind NOT IN ('10510d38-c6cf-5243-9327-5cefc6c3aee5', '2ed23be8-884f-5e75-bd63-a1ff92f42e89', 'cf017e3e-4c7f-5e2f-a7ca-2f2078eb89b3')
        UNION ALL
        -- DYNAMIC con ubicacion: una fila por espacio
        SELECT l.grant_id, l.user_id, l.tenant_id,
               CASE WHEN l.kind = '2ed23be8-884f-5e75-bd63-a1ff92f42e89' THEN l.pra END,
               CASE WHEN l.kind = 'cf017e3e-4c7f-5e2f-a7ca-2f2078eb89b3' THEN l.svc END,
               loc.space_id
          FROM live l JOIN loc ON loc.grant_id = l.grant_id
        UNION ALL
        -- FIXED: las filas congeladas
        SELECT l.grant_id, l.user_id, l.tenant_id,
               NULLIF(r ->> 'practitionerRoleAssignmentId', '')::uuid,
               NULLIF(r ->> 'healthcareServiceId', '')::uuid,
               NULLIF(r ->> 'careSpaceId', '')::uuid
          FROM live l
          CROSS JOIN LATERAL jsonb_array_elements(COALESCE(l.snapshot -> 'rows', '[]'::jsonb)) r
         WHERE l.expansion = '4f47115f-54ad-564f-bcd4-f06a0a0c13cd'
    )
    SELECT gen_random_uuid(), d.user_id, d.tenant_id, d.pra, d.svc, d.space, p."code", d.grant_id, v_now
      FROM dims d
      JOIN "delegated_access"."support_grant_actions" sga ON sga."support_scope_grant_id" = d.grant_id
      JOIN "authz"."permissions" p ON p."id" = sga."permission_id";

    GET DIAGNOSTICS v_rows = ROW_COUNT;
    RETURN v_rows;
END
$fn$;

-- support_access_allowed(...): implementacion de referencia de SupportAccessPolicy sobre la tabla
-- derivada. FALLA CERRADA: una accion queda permitida solo si se cumple TODO lo siguiente.
--   1. ALGUNA fila de effective_support_access del usuario en esa organizacion, con ese permiso,
--      coincide en CADA dimension no nula (NULL en la fila = cualquiera; si la accion no trae la
--      dimension, la fila que la exige no la cubre). Varias filas se SUMAN; una fila con dos
--      dimensiones se CRUZA.
--   2. Esa fila sigue vigente AHORA, releyendo las fuentes (la tabla derivada puede ir atrasada):
--      concesion activa y en su vigencia, vinculo activo, en su vigencia y sin recertificacion
--      vencida (next_recertification_at + 15 dias), membresia activa, iniciada y sin terminar.
--   3. La accion trae el doctor (p_practitioner_role_assignment_id), que es de ESTA organizacion, y
--      ese doctor ACEPTO a la persona: existe un practitioner_delegate_assignments del vinculo con
--      accepted_at, activo, vigente y para el mismo perfil profesional. Para
--      `messages.reply_on_behalf` ademas exige may_reply_on_behalf.
-- Sin doctor no hay aceptacion que comprobar y la respuesta es false (igual que la politica de la API).
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
         LIMIT 1
    ), false);
$fn$;

-- integrity.support_tenant_consistency(): el tenant_id de las tablas hijas del personal de apoyo
-- (RLS) debe ser el de su padre. Un CHECK no puede consultar otra tabla, de ahi el disparador:
--   support_scope_grants             = tenant del vinculo (organization_user_assignments ->
--                                      tenant_memberships) Y de cada objetivo que traiga (doctor,
--                                      servicio, espacio, sede; via practices.tenant_id)
--   support_grant_actions            = tenant del permiso
--   engagement_request_items         = tenant de la solicitud
--   affiliation_invitation_uses      = tenant de la invitacion
--   practitioner_location_assignments= tenant del doctor y del espacio
--   conversation_assignments / conversation_internal_notes = tenant de la conversacion SI la conversacion
--                                      trae tenant (suele ser NULL: entonces el ancla es la propia fila)
-- Falla cerrado: un padre que no existe o que el RLS le oculta al llamador cuenta como "otra
-- organizacion" (foreign_key_violation); un padre de otro tenant es check_violation.
CREATE OR REPLACE FUNCTION "integrity"."support_tenant_consistency"()
RETURNS trigger
LANGUAGE plpgsql
SET search_path = pg_catalog, pg_temp
AS $fn$
DECLARE
    n jsonb := to_jsonb(NEW);
    v_tenant uuid := (to_jsonb(NEW) ->> 'tenant_id')::uuid;
    v_conv uuid;
    r record;
BEGIN
    FOR r IN
        SELECT 'el vinculo (organization_user_assignment_id)' AS what,
               (SELECT tm."tenant_id"
                  FROM "delegated_access"."organization_user_assignments" a
                  JOIN "directory"."tenant_memberships" tm ON tm."id" = a."tenant_membership_id"
                 WHERE a."id" = (n ->> 'organization_user_assignment_id')::uuid) AS parent_tenant
         WHERE TG_TABLE_NAME = 'support_scope_grants'
        UNION ALL
        SELECT 'el doctor (practitioner_role_assignment_id)',
               (SELECT p."tenant_id"
                  FROM "practice"."practitioner_role_assignments" pra
                  JOIN "practice"."practices" p ON p."id" = pra."practice_id"
                 WHERE pra."id" = (n ->> 'practitioner_role_assignment_id')::uuid)
         WHERE TG_TABLE_NAME IN ('support_scope_grants', 'practitioner_location_assignments')
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
         WHERE TG_TABLE_NAME IN ('support_scope_grants', 'practitioner_location_assignments')
           AND n ->> 'care_space_id' IS NOT NULL
        UNION ALL
        SELECT 'la sede (practice_site_id)',
               (SELECT p."tenant_id"
                  FROM "practice"."practice_sites" ps
                  JOIN "practice"."practices" p ON p."id" = ps."practice_id"
                 WHERE ps."id" = (n ->> 'practice_site_id')::uuid)
         WHERE TG_TABLE_NAME = 'support_scope_grants'
           AND n ->> 'practice_site_id' IS NOT NULL
        UNION ALL
        SELECT 'el permiso (support_scope_grant_id)',
               (SELECT g."tenant_id" FROM "delegated_access"."support_scope_grants" g
                 WHERE g."id" = (n ->> 'support_scope_grant_id')::uuid)
         WHERE TG_TABLE_NAME = 'support_grant_actions'
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

DROP TRIGGER IF EXISTS trg_support_tenant_consistency ON "delegated_access"."support_scope_grants";
CREATE TRIGGER trg_support_tenant_consistency
    BEFORE INSERT OR UPDATE OF "tenant_id", "organization_user_assignment_id", "practitioner_role_assignment_id",
        "healthcare_service_id", "care_space_id", "practice_site_id"
    ON "delegated_access"."support_scope_grants"
    FOR EACH ROW EXECUTE FUNCTION "integrity"."support_tenant_consistency"();

DROP TRIGGER IF EXISTS trg_support_tenant_consistency ON "delegated_access"."support_grant_actions";
CREATE TRIGGER trg_support_tenant_consistency
    BEFORE INSERT OR UPDATE OF "tenant_id", "support_scope_grant_id"
    ON "delegated_access"."support_grant_actions"
    FOR EACH ROW EXECUTE FUNCTION "integrity"."support_tenant_consistency"();

DROP TRIGGER IF EXISTS trg_support_tenant_consistency ON "delegated_access"."engagement_request_items";
CREATE TRIGGER trg_support_tenant_consistency
    BEFORE INSERT OR UPDATE OF "tenant_id", "engagement_request_id"
    ON "delegated_access"."engagement_request_items"
    FOR EACH ROW EXECUTE FUNCTION "integrity"."support_tenant_consistency"();

DROP TRIGGER IF EXISTS trg_support_tenant_consistency ON "directory"."affiliation_invitation_uses";
CREATE TRIGGER trg_support_tenant_consistency
    BEFORE INSERT OR UPDATE OF "tenant_id", "affiliation_invitation_id"
    ON "directory"."affiliation_invitation_uses"
    FOR EACH ROW EXECUTE FUNCTION "integrity"."support_tenant_consistency"();

DROP TRIGGER IF EXISTS trg_support_tenant_consistency ON "practice"."practitioner_location_assignments";
CREATE TRIGGER trg_support_tenant_consistency
    BEFORE INSERT OR UPDATE OF "tenant_id", "practitioner_role_assignment_id", "care_space_id"
    ON "practice"."practitioner_location_assignments"
    FOR EACH ROW EXECUTE FUNCTION "integrity"."support_tenant_consistency"();

DROP TRIGGER IF EXISTS trg_support_tenant_consistency ON "community"."conversation_assignments";
CREATE TRIGGER trg_support_tenant_consistency
    BEFORE INSERT OR UPDATE OF "tenant_id", "conversation_id"
    ON "community"."conversation_assignments"
    FOR EACH ROW EXECUTE FUNCTION "integrity"."support_tenant_consistency"();

DROP TRIGGER IF EXISTS trg_support_tenant_consistency ON "community"."conversation_internal_notes";
CREATE TRIGGER trg_support_tenant_consistency
    BEFORE INSERT OR UPDATE OF "tenant_id", "conversation_id"
    ON "community"."conversation_internal_notes"
    FOR EACH ROW EXECUTE FUNCTION "integrity"."support_tenant_consistency"();

-- integrity.session_policies_time_zone(): allowed_hours_json.timeZone debe ser una zona que PostgreSQL
-- conozca. Una zona invalida hace que la API lance RangeError en el login y el refresco de TODOS los
-- miembros de la organizacion (revision A5), asi que se rechaza al guardar la politica. Un CHECK no
-- puede consultar pg_timezone_names (el resto de la forma del JSON lo valida
-- ck_session_policies_allowed_hours). La API debe validar ademas con Intl.supportedValuesOf('timeZone').
CREATE OR REPLACE FUNCTION "integrity"."session_policies_time_zone"()
RETURNS trigger
LANGUAGE plpgsql
SET search_path = pg_catalog, pg_temp
AS $fn$
DECLARE
    v_tz text := NEW."allowed_hours_json" ->> 'timeZone';
BEGIN
    IF v_tz IS NOT NULL AND NOT EXISTS (SELECT 1 FROM pg_catalog.pg_timezone_names z WHERE z.name = v_tz) THEN
        RAISE EXCEPTION 'iam.session_policies: timeZone invalida en allowed_hours_json: %', v_tz
            USING ERRCODE = 'check_violation';
    END IF;
    RETURN NEW;
END
$fn$;

DROP TRIGGER IF EXISTS trg_session_policies_time_zone ON "iam"."session_policies";
CREATE TRIGGER trg_session_policies_time_zone
    BEFORE INSERT OR UPDATE OF "allowed_hours_json"
    ON "iam"."session_policies"
    FOR EACH ROW EXECUTE FUNCTION "integrity"."session_policies_time_zone"();

-- Permisos de ejecucion: fuera de PUBLIC; solo el rol de la aplicacion (si la base ya lo tiene).
REVOKE ALL ON FUNCTION "delegated_access"."refresh_effective_support_access"(uuid) FROM PUBLIC;
REVOKE ALL ON FUNCTION "delegated_access"."support_access_allowed"(uuid, uuid, varchar, uuid, uuid, uuid) FROM PUBLIC;
REVOKE ALL ON FUNCTION "integrity"."support_tenant_consistency"() FROM PUBLIC;
REVOKE ALL ON FUNCTION "integrity"."session_policies_time_zone"() FROM PUBLIC;
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'mantra_app') THEN
        GRANT EXECUTE ON FUNCTION "delegated_access"."refresh_effective_support_access"(uuid) TO mantra_app;
        GRANT EXECUTE ON FUNCTION "delegated_access"."support_access_allowed"(uuid, uuid, varchar, uuid, uuid, uuid) TO mantra_app;
    END IF;
END $$;

-- ---- 7. RLS (aislamiento por tenant) ----
--
-- Las 13 tablas del personal de apoyo con tenant_id (v4.2.70 agrego el de 7 que no lo tenian):
--   iam.session_policies, directory.affiliation_invitations, directory.affiliation_invitation_uses,
--   practice.practitioner_location_assignments, community.reply_templates, community.conversation_assignments,
--   community.conversation_internal_notes, delegated_access.role_templates, support_scope_grants,
--   support_grant_actions, engagement_requests, engagement_request_items, effective_support_access.
-- `2026-08-05_tenant_rls.sql` recorre TODA tabla con `tenant_id uuid` y es idempotente, asi que volver a
-- ejecutarlo despues de este parche las cubre igual (verificado). Este bloque hace lo mismo SOLO para
-- estas 13 SIEMPRE (v4.2.73, A-B1: antes solo si la base ya habia optado por RLS y, si no, quedaban abiertas con un aviso).
-- Misma politica que la global: falla cerrada sin `app.current_tenant_id`, con la elevacion explicita
-- `app.system_context`. Las plantillas de rol de PLATAFORMA (tenant_id NULL) las lee todo tenant con la
-- politica de solo lectura `global_catalog_read` (el parche v4251 tiene una lista cerrada, por eso va aqui).
DO $$
DECLARE
    r record;
BEGIN
    -- v4.2.73 (revision de seguridad A-B1): ya NO se omite en silencio. Antes, en una base sin ninguna politica `tenant_isolation`, este
    -- bloque solo avisaba y las tablas del personal de apoyo quedaban ABIERTAS entre organizaciones. Ahora las politicas se crean siempre
    -- (fallar cerrado); el resto del esquema sigue pidiendo 2026-08-05_tenant_rls.sql.
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'tenant_isolation') THEN
        RAISE WARNING 'Esta base no tiene RLS en el resto del esquema (sin politicas tenant_isolation previas): este parche lo activa en las 13 tablas del personal de apoyo; ejecute 2026-08-05_tenant_rls.sql para cubrir el resto';
    END IF;
    FOR r IN SELECT * FROM (VALUES
        ('iam', 'session_policies'), ('directory', 'affiliation_invitations'),
        ('directory', 'affiliation_invitation_uses'), ('practice', 'practitioner_location_assignments'),
        ('community', 'reply_templates'), ('community', 'conversation_assignments'),
        ('community', 'conversation_internal_notes'), ('delegated_access', 'role_templates'),
        ('delegated_access', 'support_scope_grants'), ('delegated_access', 'support_grant_actions'),
        ('delegated_access', 'engagement_requests'), ('delegated_access', 'engagement_request_items'),
        ('delegated_access', 'effective_support_access')) v(s, t)
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
            EXECUTE format('GRANT SELECT, INSERT, UPDATE, DELETE ON %I.%I TO mantra_app', r.s, r.t);
        END IF;
    END LOOP;
END $$;

DROP POLICY IF EXISTS global_catalog_read ON "delegated_access"."role_templates";
CREATE POLICY global_catalog_read ON "delegated_access"."role_templates" FOR SELECT USING (tenant_id IS NULL);

COMMIT;
