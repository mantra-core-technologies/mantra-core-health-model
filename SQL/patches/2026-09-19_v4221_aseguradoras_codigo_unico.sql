-- ============================================================================
-- SALUD · patch v4.2.21 (insurance · un solo código por aseguradora) sobre BD viva
-- Fecha: 2026-09-19
-- Idempotente. UNA sola pasada. NO toca el esquema: sólo datos.
--
-- CONTEXTO. El listado del negocio («LISTA DE ASEGURADORAS», 19 filas / 17
-- compañías) estaba sembrado DOS veces, por dos caminos que no se conocían:
--
--   * `bolivia-insurance-seed.service.ts` (API, al arrancar) las siembra con
--     código `BO_ASEG_*` e id derivado de ese código — las 17, con sigla,
--     dirección y NIT;
--   * `gen_seeds.py` (paquete) sembraba NUEVE de ellas con código propio
--     (`ALIANZA_VIDA`) y, por lo tanto, id propio — sin sigla, sin dirección
--     y sin NIT.
--
-- Resultado en la base: las nueve compañías de salud aparecían dos veces, y
-- ninguna consulta que no filtrara por id podía saber cuál era la buena. El
-- catálogo público (`insurance-catalog.service.ts`) no lo mostraba porque
-- consulta por lista explícita de ids, así que el duplicado vivía escondido.
--
-- v4.2.21 alinea el paquete a los códigos y a los ids de la API (`backend_id()`
-- es el espejo exacto de `deterministicId()`), con lo que los dos sembradores
-- pasan a escribir la MISMA fila. Este patch retira lo que el paquete dejó
-- antes de la reconciliación, que ningún generador puede borrar solo.
--
-- QUÉ ENTRA.
--   A. Repunta a su gemela canónica las filas de negocio que colgaban de las
--      nueve aseguradoras viejas (productos, siniestros, acuerdos de corredor,
--      redes de prestadores, lotes de conciliación y la bitácora de decisiones).
--      Se REPUNTA, no se borra: son filas de negocio y la compañía es la misma.
--   B. Borra las nueve aseguradoras viejas y sus tenants `ASEG_*`, más el
--      identificador, el domicilio y la política de firma que colgaban de ellos.
--      Comprobado contra las 299 FKs que apuntan a `directory.tenants`: NADA
--      MÁS los referencia (0 membresías, 0 usuarios, 0 citas).
--   C. NADA: la aseguradora de demostración `DEMO-opkld` se queda, con el
--      motivo escrito abajo. No es un duplicado y retirarla costaría borrar
--      historial de auditoría.
--   D. Verificación: deja el conteo a la vista y revienta si algo no cuadra.
--
-- QUÉ NO ENTRA. Las 17 filas canónicas no se modifican acá: su sigla, su
-- dirección y su NIT ya están, y el resto (jurisdicción, identificador fiscal
-- en `common.identifiers`, domicilio en `common.addresses`) lo aporta el
-- paquete con `python salud-db/load_seeds.py --only 26 --only 04 --only 02
-- --skip-prod --refresh`, que se corre DESPUÉS de este patch.
-- ============================================================================

BEGIN;

-- ---------------------------------------------------------------------------
-- Mapa viejo → nuevo. Explícito y no por parecido de nombre: dos de las nueve
-- difieren en mayúsculas respecto del listado («La Boliviana Ciacruz Seguros
-- Personales S.A.» vs «LA BOLIVIANA CIACRUZ…»), y emparejar aseguradoras por
-- similitud de razón social es justo lo que este patch viene a evitar.
-- ---------------------------------------------------------------------------
CREATE TEMPORARY TABLE _v4221_mapa (viejo text PRIMARY KEY, nuevo text NOT NULL) ON COMMIT DROP;
INSERT INTO _v4221_mapa (viejo, nuevo) VALUES
  ('ALIANZA_VIDA',         'BO_ASEG_ALIANZA_VIDA_S_A'),
  ('BISA_SEGUROS',         'BO_ASEG_BISA_SEGUROS_Y_REASEGUROS_S_A'),
  ('FORTALEZA_SEGUROS',    'BO_ASEG_FORTALEZA_SEGUROS_Y_REASEGUROS_S_A'),
  ('CREDISEGURO',          'BO_ASEG_CREDISEGURO_S_A_SEGUROS_PERSONALES'),
  ('LA_BOLIVIANA_CIACRUZ', 'BO_ASEG_LA_BOLIVIANA_CIACRUZ_SEGUROS_PERSONALES_S_A'),
  ('LA_VITALICIA',         'BO_ASEG_LA_VITALICIA_SEGUROS_Y_REASEGUROS_DE_VIDA_S_'),
  ('NACIONAL_SEGUROS',     'BO_ASEG_NACIONAL_SEGUROS_VIDA_Y_SALUD_S_A'),
  ('UNIVIDA',              'BO_ASEG_UNIVIDA_S_A'),
  ('SANTA_CRUZ_VIDA',      'BO_ASEG_SANTA_CRUZ_VIDA_Y_SALUD_S_A');

-- Pares de ids resueltos contra la base. Si alguna gemela canónica no existiera
-- —porque la API nunca arrancó contra esta base— el patch se detiene en la
-- sección D antes de borrar nada: repuntar a NULL no es una opción.
CREATE TEMPORARY TABLE _v4221_pares AS
SELECT m.viejo, m.nuevo, v.id AS id_viejo, n.id AS id_nuevo, v.tenant_id AS tenant_viejo
  FROM _v4221_mapa m
  JOIN insurance.insurance_carriers v ON v.carrier_code = m.viejo
  JOIN insurance.insurance_carriers n ON n.carrier_code = m.nuevo;

-- ---------------------------------------------------------------------------
-- A. Repuntar las filas de negocio a la aseguradora canónica.
-- ---------------------------------------------------------------------------
UPDATE insurance.insurance_products t SET insurance_carrier_id = p.id_nuevo
  FROM _v4221_pares p WHERE t.insurance_carrier_id = p.id_viejo;

UPDATE insurance.insurance_claims t SET insurance_carrier_id = p.id_nuevo
  FROM _v4221_pares p WHERE t.insurance_carrier_id = p.id_viejo;

UPDATE insurance.broker_carrier_agreements t SET insurance_carrier_id = p.id_nuevo
  FROM _v4221_pares p WHERE t.insurance_carrier_id = p.id_viejo;

UPDATE insurance.provider_networks t SET insurance_carrier_id = p.id_nuevo
  FROM _v4221_pares p WHERE t.insurance_carrier_id = p.id_viejo;

UPDATE insurance.insurance_reconciliation_batches t SET insurance_carrier_id = p.id_nuevo
  FROM _v4221_pares p WHERE t.insurance_carrier_id = p.id_viejo;

-- La bitácora de accesos es `<<LOG>>`: se repunta porque la compañía es la
-- misma y perder la trazabilidad sería peor que reescribir la referencia.
UPDATE audit.insurance_decision_access_log t SET insurance_carrier_id = p.id_nuevo
  FROM _v4221_pares p WHERE t.insurance_carrier_id = p.id_viejo;

-- ---------------------------------------------------------------------------
-- B. Retirar las nueve filas viejas y lo que colgaba de sus tenants.
-- ---------------------------------------------------------------------------
DELETE FROM insurance.insurance_carriers c
 WHERE c.id IN (SELECT id_viejo FROM _v4221_pares);

DELETE FROM clinical.prescription_signature_policies s
 WHERE s.tenant_id IN (SELECT tenant_viejo FROM _v4221_pares);

DELETE FROM common.identifiers i
 WHERE i.owner_id IN (SELECT tenant_viejo FROM _v4221_pares);

DELETE FROM common.addresses a
 WHERE a.owner_id IN (SELECT tenant_viejo FROM _v4221_pares);

-- El tenant va último: es el padre de todo lo anterior.
DELETE FROM directory.tenants t
 WHERE t.id IN (SELECT tenant_viejo FROM _v4221_pares);

-- ---------------------------------------------------------------------------
-- C. La aseguradora de demostración `DEMO-opkld`: SE QUEDA, y por qué.
--
--    No es un duplicado de ninguna compañía del listado —la dejó una corrida
--    de prueba— y sacarla no es gratis: de sus ocho siniestros cuelgan 16
--    líneas, 6 versiones de adjudicación, 2 disputas y **14 filas de
--    `audit.insurance_claims_history`**, más un plan bajo su producto. Borrar
--    historial de auditoría para retirar una fila cosmética es una decisión
--    del dueño del dato, no de este patch, que existe para desduplicar.
--
--    Si se decide retirarla, el orden es: claim_lines → claim_adjudication_
--    versions → claim_disputes → insurance_claims_history → insurance_claims →
--    insurance_plans → insurance_products → insurance_carriers. Su tenant es
--    `DEFAULT`, el de la plataforma, y NO se borra en ningún caso.
--
-- ---------------------------------------------------------------------------
-- D. Verificación. Revienta la transacción si el resultado no es el esperado.
-- ---------------------------------------------------------------------------
DO $$
DECLARE
  v_total       integer;
  v_canonicas   integer;
  v_sobrantes   integer;
  v_huerfanas   integer;
BEGIN
  SELECT count(*) INTO v_total     FROM insurance.insurance_carriers;
  SELECT count(*) INTO v_canonicas FROM insurance.insurance_carriers
   WHERE carrier_code ~ '^BO_ASEG_';
  SELECT count(*) INTO v_sobrantes FROM insurance.insurance_carriers
   WHERE carrier_code !~ '^BO_';

  IF v_canonicas <> 17 THEN
    RAISE EXCEPTION 'v4.2.21: se esperaban 17 aseguradoras canónicas y hay %', v_canonicas;
  END IF;
  -- Sólo puede sobrevivir la aseguradora de demostración (sección C).
  IF v_sobrantes <> 1 THEN
    RAISE EXCEPTION 'v4.2.21: se esperaba 1 fila no canónica (la demo) y hay %', v_sobrantes;
  END IF;

  -- Ninguna fila de negocio puede haber quedado apuntando a una aseguradora
  -- que ya no existe: las FKs lo impedirían, pero se comprueba igual porque
  -- una FK NOT VALID no lo impediría.
  SELECT count(*) INTO v_huerfanas FROM (
    SELECT insurance_carrier_id FROM insurance.insurance_products
    UNION ALL SELECT insurance_carrier_id FROM insurance.insurance_claims
    UNION ALL SELECT insurance_carrier_id FROM insurance.broker_carrier_agreements
    UNION ALL SELECT insurance_carrier_id FROM insurance.provider_networks
    UNION ALL SELECT insurance_carrier_id FROM insurance.insurance_reconciliation_batches
    UNION ALL SELECT insurance_carrier_id FROM audit.insurance_decision_access_log
  ) r
  WHERE r.insurance_carrier_id IS NOT NULL
    AND NOT EXISTS (SELECT 1 FROM insurance.insurance_carriers c WHERE c.id = r.insurance_carrier_id);
  IF v_huerfanas <> 0 THEN
    RAISE EXCEPTION 'v4.2.21: % referencias a aseguradoras inexistentes', v_huerfanas;
  END IF;

  RAISE NOTICE 'v4.2.21 OK · aseguradoras: % (canónicas 17, resto %)', v_total, v_total - 17;
END $$;

COMMIT;
