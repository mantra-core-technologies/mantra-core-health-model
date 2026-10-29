-- MUTACIÓN del hallazgo 2: se quitan los triggers sobre las tablas padre (invariante de una sola dirección).
DROP TRIGGER trg_care_spaces_billing_dependents ON practice.care_spaces;
DROP TRIGGER trg_practice_sites_billing_dependents ON practice.practice_sites;
DROP TRIGGER trg_care_spaces_accounting_dependents ON practice.care_spaces;
DROP TRIGGER trg_clinical_units_accounting_dependents ON practice.clinical_units;
DROP TRIGGER trg_practice_sites_accounting_dependents ON practice.practice_sites;
