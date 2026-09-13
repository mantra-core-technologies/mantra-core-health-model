-- SALUD v4.0.10 · schema medical_groups · constraints de integridad (módulo 33)
-- Aplicar DESPUÉS de 04_indexes.sql y de SQL/_integrity/00_integrity_functions.sql.
-- Reglas textuales del modelo. Las UK/CHECK/EXCLUDE son SCAFFOLD (completar
-- columnas/expresión exactas contra la tabla): el modelo las declara en prosa.


-- ═══ groups ═══
-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "medical_groups"."groups" DROP CONSTRAINT IF EXISTS "ck_medical_groups_groups_status";
ALTER TABLE "medical_groups"."groups" ADD CONSTRAINT "ck_medical_groups_groups_status" CHECK ("status" IN ('PENDING_TEAM', 'SCHEDULED', 'RESCHEDULE_PENDING', 'CLOSED'));


-- ═══ group_members ═══
-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "medical_groups"."group_members" DROP CONSTRAINT IF EXISTS "ck_medical_groups_group_members_invitation_status";
ALTER TABLE "medical_groups"."group_members" ADD CONSTRAINT "ck_medical_groups_group_members_invitation_status" CHECK ("invitation_status" IN ('PENDING', 'ACCEPTED', 'REJECTED'));
