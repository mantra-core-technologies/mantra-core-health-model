-- Contacto opcional del profesional en cada sede donde atiende.
-- La columna pertenece a la asignación, no a la sede compartida.
-- Aplicar a bases existentes antes de desplegar la API; un rebuild nuevo
-- ya obtiene la columna de SQL/14_practice/02_tables.sql.
BEGIN;
ALTER TABLE "practice"."practitioner_role_assignments"
  ADD COLUMN IF NOT EXISTS "contact_phone" varchar;
COMMIT;
