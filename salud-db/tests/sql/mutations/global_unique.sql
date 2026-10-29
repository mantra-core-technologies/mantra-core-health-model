-- MUTACIÓN del hallazgo 1: vuelve a los únicos GLOBALES (sin tenant_id) de la versión anterior.
DROP INDEX billing.ux_charge_captures_bed_night;
DROP INDEX billing.ux_charge_captures_encounter_bed_day;
DROP INDEX billing.ux_charge_captures_or_case;
CREATE UNIQUE INDEX ux_charge_captures_bed_night ON billing.charge_captures (care_space_id, service_date)
  WHERE source_kind_concept_id = '5f84ea44-b0d3-582c-86c1-32c81e422d30' AND minimum_stay_charge = false AND status_concept_id <> 'f2f59654-d912-5eeb-b619-814e50a3c4d0';
CREATE UNIQUE INDEX ux_charge_captures_encounter_bed_day ON billing.charge_captures (encounter_id, service_date)
  WHERE source_kind_concept_id = '5f84ea44-b0d3-582c-86c1-32c81e422d30' AND status_concept_id <> 'f2f59654-d912-5eeb-b619-814e50a3c4d0';
CREATE UNIQUE INDEX ux_charge_captures_or_case ON billing.charge_captures (source_ref_id)
  WHERE source_kind_concept_id = 'a79361f6-8787-56a5-9a90-a9436d02e217' AND status_concept_id <> 'f2f59654-d912-5eeb-b619-814e50a3c4d0';
