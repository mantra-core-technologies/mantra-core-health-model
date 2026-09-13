-- SALUD v4.0.10 · módulo 66 · schema medical_groups
-- Generado de diagram_66_medical_groups.puml — NO editar a mano.


CREATE INDEX IF NOT EXISTS "ix_medical_groups_groups_tenant_id" ON "medical_groups"."groups" ("tenant_id");

CREATE INDEX IF NOT EXISTS "ix_medical_groups_groups_requesting_practitioner_id" ON "medical_groups"."groups" ("requesting_practitioner_id");

CREATE INDEX IF NOT EXISTS "ix_medical_groups_groups_patient_profile_id" ON "medical_groups"."groups" ("patient_profile_id");

CREATE INDEX IF NOT EXISTS "ix_medical_groups_groups_service_catalog_id" ON "medical_groups"."groups" ("service_catalog_id");

CREATE INDEX IF NOT EXISTS "ix_medical_groups_groups_status" ON "medical_groups"."groups" ("status");

CREATE INDEX IF NOT EXISTS "ix_medical_groups_groups_scheduled_at" ON "medical_groups"."groups" ("scheduled_at");

CREATE INDEX IF NOT EXISTS "ix_medical_groups_group_members_group_id" ON "medical_groups"."group_members" ("group_id");

CREATE INDEX IF NOT EXISTS "ix_medical_groups_group_members_practitioner_profile_id" ON "medical_groups"."group_members" ("practitioner_profile_id");

CREATE INDEX IF NOT EXISTS "ix_medical_groups_group_members_invitation_status" ON "medical_groups"."group_members" ("invitation_status");

CREATE UNIQUE INDEX IF NOT EXISTS "ux_medical_groups_group_members_group_practitioner" ON "medical_groups"."group_members" ("group_id", "practitioner_profile_id");
