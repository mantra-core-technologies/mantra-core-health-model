-- 2026-10-11 · Agenda publicada para los centros diagnósticos sembrados.
-- Sin agenda, "Reservar horario" en Cotizaciones/Mis órdenes dice "Todavía no
-- publicó horarios" y la persona no puede reservar su estudio.
-- Crea, por cada centro activo SIN recurso agendable: el recurso
-- (resource_ref_type = 'diagnostic_units'), una plantilla publicada, reglas de
-- lunes a viernes 08:00-12:00 (cupos de 30 min, capacidad 2) y los cupos de las
-- próximas 8 semanas. Idempotente.
DO $$
DECLARE
  u RECORD;
  res uuid;
  tpl uuid;
  d date;
  t time;
  dow int;
  admin uuid := '00000000-0000-4000-8000-000000000001';
BEGIN
  FOR u IN
    SELECT du.id, du.name, du.tenant_id
      FROM diagnostic_units.diagnostic_units du
     WHERE NOT EXISTS (SELECT 1 FROM scheduling.schedulable_resources r
                        WHERE r.resource_ref_type = 'diagnostic_units' AND r.resource_ref_id = du.id)
       AND EXISTS (SELECT 1 FROM diagnostic_units.diagnostic_study_offerings o WHERE o.diagnostic_unit_id = du.id)
  LOOP
    res := gen_random_uuid(); tpl := gen_random_uuid();
    INSERT INTO scheduling.schedulable_resources
      (id, tenant_id, resource_type_concept_id, resource_ref_type, resource_ref_id, name, time_zone, capacity,
       state_concept_id, created_at, updated_at, created_by_user_id, updated_by_user_id, row_version)
    VALUES (res, u.tenant_id, 'a1df879c-4ac6-5a7e-8548-bc04207e92fa', 'diagnostic_units', u.id,
            'Agenda de ' || u.name, 'America/La_Paz', 2,
            '38a1d301-f40d-5b17-a695-5e6d605f8b19', now(), now(), admin, admin, 1);
    INSERT INTO scheduling.schedule_templates
      (id, resource_id, name, slot_minutes, status_concept_id, created_at, updated_at, created_by_user_id, updated_by_user_id, row_version)
    VALUES (tpl, res, 'Horario de ' || u.name, 30, 'b96b14a3-6a0d-5478-b70f-46b89c715dfe', now(), now(), admin, admin, 1);
    FOR dow IN 1..5 LOOP
      INSERT INTO scheduling.schedule_rules
        (id, schedule_template_id, day_of_week, start_time, end_time, slot_minutes, capacity_per_slot,
         created_at, updated_at, created_by_user_id, updated_by_user_id, row_version)
      VALUES (gen_random_uuid(), tpl, dow, '08:00', '12:00', 30, 2, now(), now(), admin, admin, 1);
    END LOOP;
    FOR d IN SELECT g::date FROM generate_series(current_date + 1, current_date + 56, interval '1 day') g LOOP
      dow := extract(isodow FROM d);
      CONTINUE WHEN dow > 5;
      FOR t IN SELECT x::time FROM generate_series(timestamp '2000-01-01 08:00', timestamp '2000-01-01 11:30', interval '30 minutes') x LOOP
        INSERT INTO scheduling.bookable_slots
          (id, resource_id, schedule_template_id, start_at, end_at, capacity, remaining_capacity, status_concept_id,
           created_at, updated_at, created_by_user_id, updated_by_user_id, row_version)
        VALUES (gen_random_uuid(), res, tpl,
                (d + t) AT TIME ZONE 'America/La_Paz',
                (d + t + interval '30 minutes') AT TIME ZONE 'America/La_Paz',
                2, 2, '10960d55-a26d-51ab-98ef-48b1d64b306b', now(), now(), admin, admin, 1);
      END LOOP;
    END LOOP;
  END LOOP;
END $$;
