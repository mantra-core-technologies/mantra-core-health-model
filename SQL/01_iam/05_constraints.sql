-- SALUD v4.2.83 · schema iam · constraints de integridad (módulo 33)
-- Aplicar DESPUÉS de 04_indexes.sql y de SQL/_integrity/00_integrity_functions.sql.
-- Reglas del módulo 33. Las UK/CHECK/EXCLUDE en prosa quedan como comentario:
-- el modelo no declara su expresión SQL y no se inventa (temperatura-0).
-- CHECK_SQL y EXCLUDE_SQL sí se materializan con la expresión del modelo.


-- ═══ session_policies ═══
-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "iam"."session_policies" DROP CONSTRAINT IF EXISTS "ck_session_policies_idle_timeout";
ALTER TABLE "iam"."session_policies" ADD CONSTRAINT "ck_session_policies_idle_timeout" CHECK (("idle_timeout_minutes" > 0 AND "idle_timeout_minutes" <= 1440));

-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "iam"."session_policies" DROP CONSTRAINT IF EXISTS "ck_session_policies_allowed_hours";
ALTER TABLE "iam"."session_policies" ADD CONSTRAINT "ck_session_policies_allowed_hours" CHECK (("allowed_hours_json" IS NULL OR (jsonb_typeof("allowed_hours_json") = 'object' AND jsonb_path_exists("allowed_hours_json", '$ ? (@.from.type() == "string" && @.from like_regex "^([01][0-9]|2[0-3]):[0-5][0-9]$" && @.to.type() == "string" && @.to like_regex "^([01][0-9]|2[0-3]):[0-5][0-9]$")') AND ("allowed_hours_json" -> 'days' IS NULL OR jsonb_typeof("allowed_hours_json" -> 'days') = 'array') AND NOT jsonb_path_exists("allowed_hours_json", '$.days[*] ? (@.type() != "number" || @ < 0 || @ > 6 || @ != @.floor())') AND ("allowed_hours_json" -> 'timeZone' IS NULL OR jsonb_typeof("allowed_hours_json" -> 'timeZone') IN ('string', 'null'))) IS TRUE));

-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "iam"."session_policies" DROP CONSTRAINT IF EXISTS "ck_session_policies_role_code";
ALTER TABLE "iam"."session_policies" ADD CONSTRAINT "ck_session_policies_role_code" CHECK ((("scope_concept_id" = 'b9137390-37e5-5de6-95cf-fc53860563fe') = ("role_code" IS NOT NULL)));
