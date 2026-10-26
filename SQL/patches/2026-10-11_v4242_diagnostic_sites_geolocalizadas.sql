-- 2026-10-11 · Sedes de centros diagnósticos con dirección geolocalizada.
-- Sin coordenadas, "Cotizaciones" no puede comparar distancia entre centros.
-- Idempotente: sólo crea la dirección de las sedes que no tienen una.
-- Coordenadas de referencia en Santa Cruz de la Sierra (datos de demo/local).
DO $$
DECLARE
  s RECORD;
  addr uuid;
  n int := 0;
  lats numeric[] := ARRAY[-17.7833,-17.7640,-17.8050,-17.7490,-17.8200];
  lngs numeric[] := ARRAY[-63.1821,-63.1960,-63.1700,-63.2050,-63.1530];
  tpl RECORD;
BEGIN
  SELECT owner_type_concept_id, use_concept_id, type_concept_id, country_concept_id
    INTO tpl FROM common.addresses
   WHERE owner_type_concept_id='b882f9dc-07fb-5498-930d-69e74a00c7da' LIMIT 1;
  IF NOT FOUND THEN RETURN; END IF;
  FOR s IN
    SELECT DISTINCT ps.id AS ps_id, ps.name
      FROM diagnostic_units.diagnostic_unit_sites dus
      JOIN practice.practice_sites ps ON ps.id = dus.practice_site_id
     WHERE ps.address_id IS NULL
  LOOP
    addr := gen_random_uuid();
    INSERT INTO common.addresses (id, owner_type_concept_id, owner_id, use_concept_id, type_concept_id,
                                  lines, city, country_concept_id, latitude, longitude, created_at, updated_at)
    VALUES (addr, tpl.owner_type_concept_id, s.ps_id, tpl.use_concept_id, tpl.type_concept_id,
            s.name, 'Santa Cruz de la Sierra', tpl.country_concept_id,
            lats[1 + n % 5], lngs[1 + n % 5], now(), now());
    UPDATE practice.practice_sites SET address_id = addr WHERE id = s.ps_id;
    n := n + 1;
  END LOOP;
END $$;
