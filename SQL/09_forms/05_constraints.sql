-- SALUD v4.2.97 · schema forms · constraints de integridad (módulo 33)
-- Aplicar DESPUÉS de 04_indexes.sql y de SQL/_integrity/00_integrity_functions.sql.
-- Reglas del módulo 33. Las UK/CHECK/EXCLUDE en prosa quedan como comentario:
-- el modelo no declara su expresión SQL y no se inventa (temperatura-0).
-- CHECK_SQL, EXCLUDE_SQL y TRIGGER_SQL sí se materializan con el SQL del modelo.


-- ═══ question_scripts ═══
-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "forms"."question_scripts" DROP CONSTRAINT IF EXISTS "ck_question_scripts_title";
ALTER TABLE "forms"."question_scripts" ADD CONSTRAINT "ck_question_scripts_title" CHECK (char_length(btrim("title")) >= 1 AND char_length("title") <= 160);

-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "forms"."question_scripts" DROP CONSTRAINT IF EXISTS "ck_question_scripts_status";
ALTER TABLE "forms"."question_scripts" ADD CONSTRAINT "ck_question_scripts_status" CHECK ("status" IN ('active', 'archived'));


-- ═══ question_script_items ═══
-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "forms"."question_script_items" DROP CONSTRAINT IF EXISTS "ck_question_script_items_question_text";
ALTER TABLE "forms"."question_script_items" ADD CONSTRAINT "ck_question_script_items_question_text" CHECK (char_length(btrim("question_text")) >= 1 AND char_length("question_text") <= 500);

-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "forms"."question_script_items" DROP CONSTRAINT IF EXISTS "ck_question_script_items_answer_type";
ALTER TABLE "forms"."question_script_items" ADD CONSTRAINT "ck_question_script_items_answer_type" CHECK ("answer_type" IN ('free_text', 'yes_no', 'single_choice', 'multiple_choice', 'number', 'date'));

-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "forms"."question_script_items" DROP CONSTRAINT IF EXISTS "ck_question_script_items_position";
ALTER TABLE "forms"."question_script_items" ADD CONSTRAINT "ck_question_script_items_position" CHECK ("position" >= 0);

-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "forms"."question_script_items" DROP CONSTRAINT IF EXISTS "ck_question_script_items_options";
ALTER TABLE "forms"."question_script_items" ADD CONSTRAINT "ck_question_script_items_options" CHECK (("options" IS NULL OR (jsonb_typeof("options") = 'array' AND NOT jsonb_path_exists("options", '$[*] ? (@.type() != "string" || @ like_regex "^ *$")'))) AND ("answer_type" NOT IN ('single_choice', 'multiple_choice') OR ("options" IS NOT NULL AND jsonb_array_length("options") >= 2)));

-- UNIQUE concreto declarado por el modelo (UNIQUE_SQL).
ALTER TABLE "forms"."question_script_items" DROP CONSTRAINT IF EXISTS "uq_question_script_items_script_position";
ALTER TABLE "forms"."question_script_items" ADD CONSTRAINT "uq_question_script_items_script_position"
    UNIQUE ("script_id", "position") DEFERRABLE INITIALLY IMMEDIATE;


-- ═══ faq_entries ═══
-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "forms"."faq_entries" DROP CONSTRAINT IF EXISTS "ck_faq_entries_question";
ALTER TABLE "forms"."faq_entries" ADD CONSTRAINT "ck_faq_entries_question" CHECK (char_length(btrim("question")) >= 1 AND char_length("question") <= 300);

-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "forms"."faq_entries" DROP CONSTRAINT IF EXISTS "ck_faq_entries_answer";
ALTER TABLE "forms"."faq_entries" ADD CONSTRAINT "ck_faq_entries_answer" CHECK (char_length(btrim("answer")) >= 1 AND char_length("answer") <= 4000);

-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "forms"."faq_entries" DROP CONSTRAINT IF EXISTS "ck_faq_entries_position";
ALTER TABLE "forms"."faq_entries" ADD CONSTRAINT "ck_faq_entries_position" CHECK ("position" >= 0);

-- UNIQUE concreto declarado por el modelo (UNIQUE_SQL).
ALTER TABLE "forms"."faq_entries" DROP CONSTRAINT IF EXISTS "uq_faq_entries_owner_position";
ALTER TABLE "forms"."faq_entries" ADD CONSTRAINT "uq_faq_entries_owner_position"
    UNIQUE ("owner_practitioner_id", "position") DEFERRABLE INITIALLY IMMEDIATE;
