-- SALUD v4.0.10 · schema accounting · constraints de integridad (módulo 33)
-- Aplicar DESPUÉS de 04_indexes.sql y de SQL/_integrity/00_integrity_functions.sql.
-- Reglas del módulo 33. Las UK/CHECK/EXCLUDE en prosa quedan como comentario:
-- el modelo no declara su expresión SQL y no se inventa (temperatura-0).
-- CHECK_SQL y EXCLUDE_SQL sí se materializan con la expresión del modelo.


-- ═══ practitioner_simple_accounts ═══
-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "accounting"."practitioner_simple_accounts" DROP CONSTRAINT IF EXISTS "ck_practitioner_simple_accounts_class";
ALTER TABLE "accounting"."practitioner_simple_accounts" ADD CONSTRAINT "ck_practitioner_simple_accounts_class" CHECK ("account_class" IN ('ASSET', 'LIABILITY', 'EQUITY', 'INCOME', 'EXPENSE'));


-- ═══ practitioner_simple_records ═══
-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "accounting"."practitioner_simple_records" DROP CONSTRAINT IF EXISTS "ck_practitioner_simple_records_kind";
ALTER TABLE "accounting"."practitioner_simple_records" ADD CONSTRAINT "ck_practitioner_simple_records_kind" CHECK ("kind" IN ('EXPENSE', 'ASSET', 'DEBT'));

-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "accounting"."practitioner_simple_records" DROP CONSTRAINT IF EXISTS "ck_practitioner_simple_records_amount";
ALTER TABLE "accounting"."practitioner_simple_records" ADD CONSTRAINT "ck_practitioner_simple_records_amount" CHECK ("amount" > 0);


-- ═══ practitioner_simple_transactions ═══
-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "accounting"."practitioner_simple_transactions" DROP CONSTRAINT IF EXISTS "ck_practitioner_simple_transactions_distinct";
ALTER TABLE "accounting"."practitioner_simple_transactions" ADD CONSTRAINT "ck_practitioner_simple_transactions_distinct" CHECK ("debit_account_id" <> "credit_account_id");

-- CHECK concreto declarado por el modelo (CHECK_SQL).
ALTER TABLE "accounting"."practitioner_simple_transactions" DROP CONSTRAINT IF EXISTS "ck_practitioner_simple_transactions_amount";
ALTER TABLE "accounting"."practitioner_simple_transactions" ADD CONSTRAINT "ck_practitioner_simple_transactions_amount" CHECK ("amount" > 0);
