-- Reconciliado al modelo canónico módulo66 (2026-09-13); FK CTI usa profile_id.
-- ============================================================================
-- SALUD · patch v4.2.6 (medical_groups · nuevo módulo 21) sobre una BD viva
-- Fecha: 2026-09-04
-- Idempotente (CREATE SCHEMA/TABLE/INDEX IF NOT EXISTS).
-- UNA sola pasada: no hay backfill (módulo nuevo, cero filas).
--
-- ⚠️ DESVÍO DECLARADO DEL PROCESO CANÓNICO — léase antes de tocar este archivo.
-- `SQL/README.md` es explícito: «el flujo es .puml → SQL/ → BD → ORM, y solo en
-- esa dirección» y todo archivo bajo `SQL/patches/` documentado hasta ahora es
-- la salida de `salud-db/gen_ddl.py` sobre un `.puml` ya actualizado (ver
-- v4.2.2, encabezado). Este entorno de trabajo (worktree aislado del carril
-- FT-21) NO tiene acceso al repositorio que aloja
-- `Mantra Core Health Context/modules/*.puml` ni a `salud-db/gen_ddl.py`: sólo
-- a los tres repos de la aplicación (`wt-pablo-api`, `wt-pablo-front`,
-- `mantra_core_technologies_health_docs`). Por eso este archivo SÍ es DDL
-- escrito a mano, no una salida regenerada — la única excepción a la regla que
-- este carril pudo permitirse sin bloquear la entrega de FT-21 por completo.
-- Queda pendiente que quien mantiene el `.puml` declare `diagram_21_medical_
-- groups.puml` con este mismo contenido y lo audite contra este patch (ver
-- `known_gaps` del carril FT-21). El número de módulo `21` se eligió porque
-- `SQL/` no lo usa (salta de `20_diagnostics` a `22_organization_extensions`).
--
-- QUÉ CIERRA. FT-21 «Corrección de grupo médico»: el grupo médico es un evento
-- de equipo (servicio médico + fecha/lugar + roster con pago por cargo) con
-- ciclo de vida propio (invitación → programada → cambio de horario → notas
-- del ejercicio → cierre inmutable). No existía una tabla equivalente: se
-- buscó en `clinical.encounters`/`encounter_participants` (sin controlador ni
-- servicio — sólo entidades ORM sin capa de aplicación, y con FKs obligatorias
-- a `terminology.catalog_concepts` que este carril no tiene autorización para
-- inventar) y en `community.groups` (grupos de la red social, dominio
-- completamente distinto). Ninguno es reutilizable sin construir la capa de
-- aplicación entera de todos modos — ver `implementation-plan.md` del carril,
-- regla de no-duplicación.
--
-- MODELO:
--   `medical_groups.groups`         — el grupo médico (una fila por solicitud).
--   `medical_groups.group_members`  — el roster: una fila por cargo/función
--                                      invitado, con su pago acordado y el
--                                      estado de la invitación (sirve a la vez
--                                      de "solicitud enviada"/"recibida").
--
-- Delta esperado: +1 schema · +2 tablas · +7 FK (3 intra-schema, 4 cross-schema
-- en `90_fk_deferred`, aplicadas acá mismo por no existir todavía el archivo
-- `90_fk_deferred.sql` propio del módulo) · +9 índices.
-- ============================================================================

BEGIN;

-- ---------------------------------------------------------------------------
-- Fase 1 · schema
-- ---------------------------------------------------------------------------
CREATE SCHEMA IF NOT EXISTS "medical_groups";

-- ---------------------------------------------------------------------------
-- Fase 2 · tablas
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS "medical_groups"."groups" (
    "id" uuid NOT NULL,
    "tenant_id" uuid NOT NULL,
    "practice_id" uuid NOT NULL,
    "service_catalog_id" uuid NOT NULL,
    "requesting_practitioner_id" uuid NOT NULL,
    "patient_profile_id" uuid,
    "condition_id" uuid,
    "scheduled_at" timestamptz NOT NULL,
    "location_text" varchar NOT NULL,
    "notes_text" text,
    "terms_text" text NOT NULL,
    -- PENDING_TEAM: creado, con invitaciones sin responder.
    -- SCHEDULED: todo el roster aceptó (programada).
    -- RESCHEDULE_PENDING: hay una fecha propuesta esperando al creador.
    -- CLOSED: pasó 1 semana de `scheduled_at` — inmutable.
    "status" varchar NOT NULL,
    -- "NOTAS DEL EJERCICIO" (AC-21-14): visibles arriba a la izquierda en la
    -- consulta, editables sólo entre `scheduled_at` y `scheduled_at + 7 días`.
    "exercise_notes_text" text,
    "exercise_notes_updated_at" timestamptz,
    "proposed_reschedule_at" timestamptz,
    "proposed_by_practitioner_id" uuid,
    "closed_at" timestamptz,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_medical_groups_groups" PRIMARY KEY ("id"),
    CONSTRAINT "ck_medical_groups_groups_status" CHECK (
        "status" IN ('PENDING_TEAM', 'SCHEDULED', 'RESCHEDULE_PENDING', 'CLOSED')
    )
);

CREATE TABLE IF NOT EXISTS "medical_groups"."group_members" (
    "id" uuid NOT NULL,
    "group_id" uuid NOT NULL,
    "practitioner_profile_id" uuid NOT NULL,
    -- Cargo/función dentro del grupo (p. ej. "Anestesiólogo"). Texto libre: no
    -- existe todavía un catálogo de cargos quirúrgicos en `terminology` que
    -- este carril pueda referenciar sin inventar códigos (ver known_gaps).
    "role_title" varchar NOT NULL,
    "agreed_payment_amount" numeric NOT NULL,
    "agreed_payment_currency_concept_id" uuid,
    "additional_terms_text" text,
    "is_creator" boolean NOT NULL,
    "invitation_status" varchar NOT NULL,
    "responded_at" timestamptz,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_medical_groups_group_members" PRIMARY KEY ("id"),
    CONSTRAINT "ck_medical_groups_group_members_invitation_status" CHECK (
        "invitation_status" IN ('PENDING', 'ACCEPTED', 'REJECTED')
    ),
    CONSTRAINT "ux_medical_groups_group_members_group_practitioner"
        UNIQUE ("group_id", "practitioner_profile_id")
);

-- ---------------------------------------------------------------------------
-- Fase 3 · FK intra-schema
-- ---------------------------------------------------------------------------
DO $$ BEGIN
    ALTER TABLE "medical_groups"."group_members"
        ADD CONSTRAINT "fk_medical_groups_group_members_group_id"
        FOREIGN KEY ("group_id") REFERENCES "medical_groups"."groups" ("id")
        ON DELETE CASCADE;
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- ---------------------------------------------------------------------------
-- Fase 4 · FK cross-schema (equivalente a 90_fk_deferred; aplicadas ya porque
-- todos los schemas destino existen en cualquier base sobre la que este patch
-- pueda correr).
--
-- Los perfiles se referencian por `profile_id`, NO por `id`: en
-- `profiles.health_practitioner_profiles` y `profiles.patient_profiles` la
-- clave primaria ES `profile_id` (heredan la identidad del perfil base). Con
-- `("id")` esto moría en «column "id" referenced in foreign key constraint does
-- not exist», y como nunca llegó a aplicarse —el bucle de migraciones apuntaba
-- a un directorio inexistente y daba cero vueltas— el error no salió hasta la
-- primera base construida de cero.
-- ---------------------------------------------------------------------------
DO $$ BEGIN
    ALTER TABLE "medical_groups"."groups"
        ADD CONSTRAINT "fk_medical_groups_groups_tenant_id"
        FOREIGN KEY ("tenant_id") REFERENCES "directory"."tenants" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "medical_groups"."groups"
        ADD CONSTRAINT "fk_medical_groups_groups_practice_id"
        FOREIGN KEY ("practice_id") REFERENCES "practice"."practices" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "medical_groups"."groups"
        ADD CONSTRAINT "fk_medical_groups_groups_service_catalog_id"
        FOREIGN KEY ("service_catalog_id") REFERENCES "billing"."service_catalog" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "medical_groups"."groups"
        ADD CONSTRAINT "fk_medical_groups_groups_requesting_practitioner_id"
        FOREIGN KEY ("requesting_practitioner_id")
        REFERENCES "profiles"."health_practitioner_profiles" ("profile_id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "medical_groups"."groups"
        ADD CONSTRAINT "fk_medical_groups_groups_patient_profile_id"
        FOREIGN KEY ("patient_profile_id") REFERENCES "profiles"."patient_profiles" ("profile_id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "medical_groups"."groups"
        ADD CONSTRAINT "fk_medical_groups_groups_condition_id"
        FOREIGN KEY ("condition_id") REFERENCES "clinical"."conditions" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "medical_groups"."groups"
        ADD CONSTRAINT "fk_medical_groups_groups_proposed_by_practitioner_id"
        FOREIGN KEY ("proposed_by_practitioner_id")
        REFERENCES "profiles"."health_practitioner_profiles" ("profile_id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "medical_groups"."groups"
        ADD CONSTRAINT "fk_medical_groups_groups_created_by_user_id"
        FOREIGN KEY ("created_by_user_id") REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "medical_groups"."groups"
        ADD CONSTRAINT "fk_medical_groups_groups_updated_by_user_id"
        FOREIGN KEY ("updated_by_user_id") REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "medical_groups"."group_members"
        ADD CONSTRAINT "fk_medical_groups_group_members_practitioner_profile_id"
        FOREIGN KEY ("practitioner_profile_id")
        REFERENCES "profiles"."health_practitioner_profiles" ("profile_id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "medical_groups"."group_members"
        ADD CONSTRAINT "fk_medical_groups_group_members_currency_concept_id"
        FOREIGN KEY ("agreed_payment_currency_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "medical_groups"."group_members"
        ADD CONSTRAINT "fk_medical_groups_group_members_created_by_user_id"
        FOREIGN KEY ("created_by_user_id") REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "medical_groups"."group_members"
        ADD CONSTRAINT "fk_medical_groups_group_members_updated_by_user_id"
        FOREIGN KEY ("updated_by_user_id") REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- ---------------------------------------------------------------------------
-- Fase 5 · índices
-- ---------------------------------------------------------------------------
CREATE INDEX IF NOT EXISTS "ix_medical_groups_groups_tenant_id"
    ON "medical_groups"."groups" ("tenant_id");
CREATE INDEX IF NOT EXISTS "ix_medical_groups_groups_requesting_practitioner_id"
    ON "medical_groups"."groups" ("requesting_practitioner_id");
CREATE INDEX IF NOT EXISTS "ix_medical_groups_groups_patient_profile_id"
    ON "medical_groups"."groups" ("patient_profile_id");
CREATE INDEX IF NOT EXISTS "ix_medical_groups_groups_service_catalog_id"
    ON "medical_groups"."groups" ("service_catalog_id");
CREATE INDEX IF NOT EXISTS "ix_medical_groups_groups_status"
    ON "medical_groups"."groups" ("status");
CREATE INDEX IF NOT EXISTS "ix_medical_groups_groups_scheduled_at"
    ON "medical_groups"."groups" ("scheduled_at");
CREATE INDEX IF NOT EXISTS "ix_medical_groups_group_members_group_id"
    ON "medical_groups"."group_members" ("group_id");
CREATE INDEX IF NOT EXISTS "ix_medical_groups_group_members_practitioner_profile_id"
    ON "medical_groups"."group_members" ("practitioner_profile_id");
CREATE INDEX IF NOT EXISTS "ix_medical_groups_group_members_invitation_status"
    ON "medical_groups"."group_members" ("invitation_status");

COMMIT;

-- ---------------------------------------------------------------------------
-- Fase 6 · aislamiento por tenant (RLS)
--
-- Este patch NO activa RLS por sí mismo: `patches/2026-08-05_tenant_rls.sql`
-- ya lo hace para TODA tabla con `tenant_id uuid` (barrido dinámico por
-- `information_schema`), así que basta con volver a aplicar ese archivo
-- (es idempotente) después de este para que alcance a `medical_groups.groups`.
-- `medical_groups.group_members` no lleva `tenant_id` propio a propósito —se
-- alcanza siempre a través de `group_id`— así que ese barrido no la toca; el
-- aislamiento de esa tabla lo hace la propia consulta del servicio (siempre
-- filtra por un `group_id` ya resuelto y autorizado), igual que
-- `insurance_claim_lines` respecto de `insurance_claims`.
-- ---------------------------------------------------------------------------

-- ---------------------------------------------------------------------------
-- Fase 7 · comprobación: rompe si el esquema quedó a medias.
-- ---------------------------------------------------------------------------
DO $$
DECLARE
    faltantes text;
BEGIN
    SELECT string_agg(e.objeto, ', ' ORDER BY e.objeto) INTO faltantes
    FROM (VALUES
        ('tabla medical_groups.groups',
            EXISTS (SELECT 1 FROM information_schema.tables
                     WHERE table_schema = 'medical_groups' AND table_name = 'groups')),
        ('tabla medical_groups.group_members',
            EXISTS (SELECT 1 FROM information_schema.tables
                     WHERE table_schema = 'medical_groups' AND table_name = 'group_members')),
        ('fk group_members -> groups',
            EXISTS (SELECT 1 FROM pg_constraint
                     WHERE conname = 'fk_medical_groups_group_members_group_id')),
        ('unique (group_id, practitioner_profile_id)',
            EXISTS (
                SELECT 1
                FROM pg_constraint c
                WHERE c.conrelid = 'medical_groups.group_members'::regclass
                  AND c.contype = 'u'
                  AND c.convalidated
                  AND cardinality(c.conkey) = 2
                  AND ARRAY(
                      SELECT a.attname::text
                      FROM unnest(c.conkey) WITH ORDINALITY AS k(attnum, ord)
                      JOIN pg_attribute a
                        ON a.attrelid = c.conrelid
                       AND a.attnum = k.attnum
                      ORDER BY k.ord
                  ) = ARRAY['group_id', 'practitioner_profile_id']
            ) OR EXISTS (
                SELECT 1
                FROM pg_index i
                WHERE i.indrelid = 'medical_groups.group_members'::regclass
                  AND i.indisunique
                  AND i.indisvalid
                  AND i.indisready
                  AND i.indislive
                  AND i.indpred IS NULL
                  AND i.indexprs IS NULL
                  AND i.indnkeyatts = 2
                  AND i.indnatts = 2
                  AND ARRAY(
                      SELECT a.attname::text
                      FROM unnest(i.indkey) WITH ORDINALITY AS k(attnum, ord)
                      JOIN pg_attribute a
                        ON a.attrelid = i.indrelid
                       AND a.attnum = k.attnum
                      WHERE k.ord <= i.indnkeyatts
                      ORDER BY k.ord
                  ) = ARRAY['group_id', 'practitioner_profile_id']
            ))
    ) AS e(objeto, existe)
    WHERE NOT e.existe;

    IF faltantes IS NOT NULL THEN
        RAISE EXCEPTION 'patch v4.2.6 incompleto - faltan: %', faltantes;
    END IF;

    RAISE NOTICE 'patch v4.2.6 · medical_groups: esquema completo (2 tablas · 13 FK · 9 índices)';
END $$;
