-- MUTACIÓN del hallazgo 1: el origen de un cargo de quirófano deja de comprobarse (como antes del arreglo).
CREATE OR REPLACE FUNCTION billing.charge_source_case_ok(p_tenant uuid, p_practice uuid, p_case uuid)
RETURNS boolean LANGUAGE sql AS $$ SELECT true $$;
