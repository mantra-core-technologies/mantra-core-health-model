-- Verificación de la agenda y el chat de piloto (09-agenda-chat-piloto.sql). Solo LEE: corre dentro de una transacción que se deshace.
--
-- Comprueba (falla con una excepción en la primera que no dé lo esperado):
--   V1  8 agendas (una por doctor), 96 cupos de los días 2026-11-04…06 (89 libres + 7 reservados con capacidad 0) y 7 reservas confirmadas que apuntan a su cupo
--   V2  CERO cupos que se pisen en la agenda de un mismo doctor (nadie ofrece dos lugares a la misma hora)
--   V3  TODO id sembrado por 09 es un uuid con versión 5 y variante RFC 4122 (los validadores IsUUID de la API rechazan los ids sacados de md5)
--   V4  el `patientProfileId` de cada conversación se resuelve por `profiles.person_account_links` con la MISMA consulta de la API
--       (SupportInboxRepository.patientContext: usuario → vínculo `profiles:ACCOUNT_LINK_ACTIVE` sin fecha de fin → patient_profiles) y trae el
--       motivo de su cita con ese doctor
--   V5  4 conversaciones directas con 2 participantes y 1 mensaje del paciente cada una; todo participante tiene perfil público activo; el doctor de cada
--       una tiene perfil público de doctor en la organización de la agenda
--   V6  la bandeja de Ana (aceptada por Pérez y Rojas) alcanza esas conversaciones; la de Lucía (Pérez, Méndez y Vaca) también las de Pérez y Méndez
--   V7  los 4 pacientes NO tienen credenciales (no pueden iniciar sesión) y las cuentas están activas
--
-- Requiere 04 y 09 (07 no hace falta, salvo V6, que se omite si faltan las aceptaciones de Ana).
-- Uso:  psql -v ON_ERROR_STOP=1 -d <base> -f salud-db/demo/10-verifica-agenda-chat-piloto.sql

BEGIN;

DO $v$
DECLARE
    hosp constant uuid := '830e47e1-8e82-50ff-99c0-bfed0a7971a4';
    open_slot uuid; booked_slot uuid;
    n integer; m integer; bad text;
    ana uuid; lucia uuid;
BEGIN
    SELECT id INTO open_slot   FROM terminology.catalog_concepts WHERE code = 'SLOT_OPEN'   ORDER BY id LIMIT 1;
    SELECT id INTO booked_slot FROM terminology.catalog_concepts WHERE code = 'SLOT_BOOKED' ORDER BY id LIMIT 1;

    -- V1 ---------------------------------------------------------------------------------------------------
    SELECT count(*) INTO n FROM scheduling.schedulable_resources WHERE name LIKE 'Agenda % (DEMO)';
    IF n <> 8 THEN RAISE EXCEPTION 'V1 FALLÓ: se esperaban 8 agendas del piloto y hay %', n; END IF;
    -- los cupos LIBRES de las 8 agendas son todos de 09 (los de 07 nacen ocupados); los ocupados de 09 son los de sus 7 reservas (siguiente comprobación)
    SELECT count(*) INTO m
      FROM scheduling.bookable_slots s JOIN scheduling.schedulable_resources r ON r.id = s.resource_id
     WHERE r.name LIKE 'Agenda % (DEMO)' AND s.status_concept_id = open_slot AND s.remaining_capacity = 1
       AND s.start_at >= timestamptz '2026-11-04 00:00:00-04' AND s.start_at < timestamptz '2026-11-07 00:00:00-04';
    IF m <> 89 THEN RAISE EXCEPTION 'V1 FALLÓ: se esperaban 89 cupos libres (96 de 09 − 7 reservados) y hay %', m; END IF;
    SELECT count(*) INTO n
      FROM scheduling.appointment_bookings b
      JOIN scheduling.bookable_slots s ON s.id = b.bookable_slot_id
      JOIN profiles.patient_profiles pp ON pp.profile_id = b.patient_profile_id AND pp.patient_code LIKE 'DEMO-PIL-P%'
     WHERE b.status_concept_id = (SELECT id FROM terminology.catalog_concepts WHERE code = 'BOOKING_CONFIRMED' ORDER BY id LIMIT 1)
       AND s.status_concept_id = booked_slot AND s.remaining_capacity = 0 AND b.resource_id = s.resource_id AND b.booked_via_grant_id IS NULL;
    IF n <> 7 THEN RAISE EXCEPTION 'V1 FALLÓ: se esperaban 7 reservas confirmadas de 09 sobre cupos ocupados y hay %', n; END IF;

    -- V1b --------------------------------------------------------------------------------------------------
    -- las 8 agendas nombran la tabla de perfiles como la reconoce la API (PRACTITIONER_PROFILE_TABLES: `health_practitioner_profiles` o
    -- `practitioner_profiles`) y apuntan a un perfil de profesional que existe; con `profiles.health_practitioner_profiles` (nombre calificado)
    -- la política de agenda no encuentra al doctor de la cita y todo da DOCTOR_NOT_ACCEPTED. Precondición: V1 (las 8 agendas cargadas por 09).
    SELECT count(*) INTO n FROM scheduling.schedulable_resources r
     WHERE r.name LIKE 'Agenda % (DEMO)'
       AND (r.resource_ref_type NOT IN ('health_practitioner_profiles', 'practitioner_profiles')
            OR NOT EXISTS (SELECT 1 FROM profiles.health_practitioner_profiles hp WHERE hp.profile_id = r.resource_ref_id));
    IF n <> 0 THEN RAISE EXCEPTION 'V1b FALLÓ: % de las 8 agendas del piloto traen un resource_ref_type que la API no reconoce (debe ser health_practitioner_profiles) o no apuntan a un perfil de profesional', n; END IF;

    -- V2 ---------------------------------------------------------------------------------------------------
    SELECT string_agg(DISTINCT r.name, ', ') INTO bad
      FROM scheduling.bookable_slots a
      JOIN scheduling.bookable_slots b ON b.resource_id = a.resource_id AND b.id < a.id AND tstzrange(a.start_at, a.end_at) && tstzrange(b.start_at, b.end_at)
      JOIN scheduling.schedulable_resources r ON r.id = a.resource_id
     WHERE r.name LIKE 'Agenda % (DEMO)';
    IF bad IS NOT NULL THEN RAISE EXCEPTION 'V2 FALLÓ: cupos que se pisan en la agenda de un mismo doctor: %', bad; END IF;

    -- V3 ---------------------------------------------------------------------------------------------------
    WITH ids AS (
        SELECT 'schedulable_resources' AS t, id FROM scheduling.schedulable_resources WHERE name LIKE 'Agenda % (DEMO)'
        UNION ALL SELECT 'bookable_slots', s.id FROM scheduling.bookable_slots s JOIN scheduling.schedulable_resources r ON r.id = s.resource_id WHERE r.name LIKE 'Agenda % (DEMO)'
        UNION ALL SELECT 'appointment_bookings', b.id FROM scheduling.appointment_bookings b JOIN profiles.patient_profiles pp ON pp.profile_id = b.patient_profile_id WHERE pp.patient_code LIKE 'DEMO-PIL-P%'
        UNION ALL SELECT 'persons', profile_id FROM profiles.patient_profiles WHERE patient_code LIKE 'DEMO-PIL-P%'
        UNION ALL SELECT 'users', l.user_id FROM profiles.person_account_links l JOIN profiles.patient_profiles pp ON pp.profile_id = l.person_id WHERE pp.patient_code LIKE 'DEMO-PIL-P%'
        UNION ALL SELECT 'person_account_links', l.id FROM profiles.person_account_links l JOIN profiles.patient_profiles pp ON pp.profile_id = l.person_id WHERE pp.patient_code LIKE 'DEMO-PIL-P%'
        UNION ALL SELECT 'public_profiles', id FROM community.public_profiles WHERE slug LIKE 'demo-%'
        UNION ALL SELECT 'conversations', c.id FROM community.conversations c JOIN community.conversation_participants p ON p.conversation_id = c.id JOIN community.public_profiles pr ON pr.id = p.participant_profile_id WHERE pr.slug LIKE 'demo-pac-%'
        UNION ALL SELECT 'conversation_participants', p.id FROM community.conversation_participants p JOIN community.public_profiles pr ON pr.id = p.participant_profile_id WHERE pr.slug LIKE 'demo-%'
        UNION ALL SELECT 'direct_messages', m.id FROM community.direct_messages m JOIN community.public_profiles pr ON pr.id = m.sender_profile_id WHERE pr.slug LIKE 'demo-pac-%'
    )
    SELECT string_agg(DISTINCT t, ', ') INTO bad FROM ids
     WHERE id::text !~ '^[0-9a-f]{8}-[0-9a-f]{4}-5[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$';
    IF bad IS NOT NULL THEN RAISE EXCEPTION 'V3 FALLÓ: hay ids que no son uuid versión 5 en: %', bad; END IF;
    SELECT count(*) INTO n FROM scheduling.schedulable_resources WHERE name LIKE 'Agenda % (DEMO)' AND id::text !~ '^[0-9a-f]{8}-[0-9a-f]{4}-5[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$';
    IF n <> 0 THEN RAISE EXCEPTION 'V3 FALLÓ: % agendas con id que no es uuid 5', n; END IF;

    -- V4: la misma consulta que SupportInboxRepository.patientContext (usuario → vínculo ACTIVO sin fin → perfil de paciente) ----------------
    FOR n IN 1..4 LOOP
        DECLARE
            code text := 'DEMO-PIL-P0' || n;
            uid uuid; person uuid; resolved uuid; reason text; doc uuid; pr record;
        BEGIN
            SELECT l.user_id, l.person_id INTO uid, person
              FROM profiles.person_account_links l JOIN profiles.patient_profiles pp ON pp.profile_id = l.person_id
             WHERE pp.patient_code = code;
            IF uid IS NULL THEN RAISE EXCEPTION 'V4 FALLÓ: el paciente % no tiene vínculo cuenta↔persona', code; END IF;
            SELECT l.person_id INTO resolved
              FROM profiles.person_account_links l
              JOIN profiles.patient_profiles pp ON pp.profile_id = l.person_id
             WHERE l.user_id = uid AND l.status_concept_id = '6db29320-acc3-50f6-ac19-cb906aa96209'  -- profiles:ACCOUNT_LINK_ACTIVE
               AND (l.valid_to IS NULL OR l.valid_to > now())
             ORDER BY l.valid_from DESC LIMIT 1;
            IF resolved IS DISTINCT FROM person THEN
                RAISE EXCEPTION 'V4 FALLÓ: el patientProfileId de % no se resuelve (esperado %, resuelto %)', code, person, resolved; END IF;
        END;
    END LOOP;
    -- cada conversación: el doctor de su perfil público y el motivo de la última cita del paciente con ese doctor
    FOR bad IN
        SELECT pat.display_name || ' ↔ ' || doc.display_name
          FROM community.conversations c
          JOIN community.conversation_participants cpp ON cpp.conversation_id = c.id
          JOIN community.public_profiles pat ON pat.id = cpp.participant_profile_id AND pat.slug LIKE 'demo-pac-%'
          JOIN community.conversation_participants cpd ON cpd.conversation_id = c.id
          JOIN community.public_profiles doc ON doc.id = cpd.participant_profile_id AND doc.slug LIKE 'demo-dr%'
         WHERE NOT EXISTS (
             SELECT 1
               FROM profiles.person_account_links l
               JOIN profiles.patient_profiles pp ON pp.profile_id = l.person_id
               JOIN scheduling.appointment_bookings b ON b.tenant_id = c.tenant_id AND b.patient_profile_id = l.person_id AND b.reason_text IS NOT NULL
               JOIN scheduling.schedulable_resources r ON r.id = b.resource_id AND r.resource_ref_id = doc.target_id
              WHERE l.user_id = pat.target_id AND l.status_concept_id = '6db29320-acc3-50f6-ac19-cb906aa96209' AND l.valid_to IS NULL)   -- profiles:ACCOUNT_LINK_ACTIVE
    LOOP
        RAISE EXCEPTION 'V4 FALLÓ: la conversación % no trae el motivo de la cita del paciente con ese doctor', bad;
    END LOOP;

    -- V5 ---------------------------------------------------------------------------------------------------
    SELECT count(DISTINCT c.id) INTO n
      FROM community.conversations c
      JOIN community.conversation_participants p ON p.conversation_id = c.id
      JOIN community.public_profiles pr ON pr.id = p.participant_profile_id AND pr.slug LIKE 'demo-pac-%';
    IF n <> 4 THEN RAISE EXCEPTION 'V5 FALLÓ: se esperaban 4 conversaciones de pacientes del piloto y hay %', n; END IF;
    SELECT count(*) INTO n FROM (
        SELECT c.id FROM community.conversations c
          JOIN community.conversation_participants p ON p.conversation_id = c.id
          JOIN community.public_profiles pr ON pr.id = p.participant_profile_id AND pr.status_concept_id = '38a1d301-f40d-5b17-a695-5e6d605f8b19'
         WHERE c.id IN (SELECT conversation_id FROM community.conversation_participants cp JOIN community.public_profiles x ON x.id = cp.participant_profile_id AND x.slug LIKE 'demo-pac-%')
         GROUP BY c.id HAVING count(*) = 2 AND (SELECT count(*) FROM community.direct_messages dm WHERE dm.conversation_id = c.id) = 1) t;
    IF n <> 4 THEN RAISE EXCEPTION 'V5 FALLÓ: cada conversación debe tener 2 participantes con perfil activo y 1 mensaje (cumplen %)', n; END IF;
    SELECT count(*) INTO n
      FROM community.public_profiles pr
      JOIN scheduling.schedulable_resources r ON r.resource_ref_id = pr.target_id AND r.tenant_id = pr.tenant_id
     WHERE pr.slug LIKE 'demo-dr%';
    IF n <> 8 THEN RAISE EXCEPTION 'V5 FALLÓ: cada doctor con perfil público debe tener su agenda en la misma organización (cumplen % de 8)', n; END IF;

    -- V6 ---------------------------------------------------------------------------------------------------
    SELECT m.user_id INTO ana   FROM directory.tenant_memberships m JOIN iam.users u ON u.id = m.user_id WHERE m.tenant_id = hosp AND u.display_name = 'Ana Gutiérrez';
    SELECT m.user_id INTO lucia FROM directory.tenant_memberships m JOIN iam.users u ON u.id = m.user_id WHERE m.tenant_id = hosp AND u.display_name = 'Lucía Paz';
    -- doctores que aceptaron a la persona (aceptación vigente) y cuya conversación sale en su bandeja
    SELECT count(DISTINCT c.id) INTO n
      FROM community.conversations c
      JOIN community.conversation_participants cpd ON cpd.conversation_id = c.id
      JOIN community.public_profiles doc ON doc.id = cpd.participant_profile_id AND doc.slug LIKE 'demo-dr%'
      JOIN practice.practitioner_role_assignments ra ON ra.practitioner_profile_id = doc.target_id
      JOIN delegated_access.practitioner_delegate_assignments d ON d.practitioner_role_assignment_id = ra.id AND d.accepted_at IS NOT NULL
      JOIN delegated_access.organization_user_assignments a ON a.id = d.delegate_user_assignment_id
      JOIN directory.tenant_memberships mm ON mm.id = a.tenant_membership_id AND mm.user_id = ana
     WHERE c.tenant_id = hosp;
    IF n <> 3 THEN RAISE EXCEPTION 'V6 FALLÓ: la bandeja de Ana debía alcanzar 3 conversaciones (2 de Pérez y 1 de Rojas) y alcanza %', n; END IF;
    SELECT count(DISTINCT c.id) INTO n
      FROM community.conversations c
      JOIN community.conversation_participants cpd ON cpd.conversation_id = c.id
      JOIN community.public_profiles doc ON doc.id = cpd.participant_profile_id AND doc.slug LIKE 'demo-dr%'
      JOIN practice.practitioner_role_assignments ra ON ra.practitioner_profile_id = doc.target_id
      JOIN delegated_access.practitioner_delegate_assignments d ON d.practitioner_role_assignment_id = ra.id AND d.accepted_at IS NOT NULL
      JOIN delegated_access.organization_user_assignments a ON a.id = d.delegate_user_assignment_id
      JOIN directory.tenant_memberships mm ON mm.id = a.tenant_membership_id AND mm.user_id = lucia
     WHERE c.tenant_id = hosp;
    IF n <> 3 THEN RAISE EXCEPTION 'V6 FALLÓ: la bandeja de Lucía debía alcanzar 3 conversaciones (2 de Pérez y 1 de Méndez) y alcanza %', n; END IF;

    -- V7 ---------------------------------------------------------------------------------------------------
    SELECT count(*) INTO n
      FROM profiles.person_account_links l JOIN profiles.patient_profiles pp ON pp.profile_id = l.person_id AND pp.patient_code LIKE 'DEMO-PIL-P%'
      JOIN iam.authentication_credentials c ON c.user_id = l.user_id;
    IF n <> 0 THEN RAISE EXCEPTION 'V7 FALLÓ: % pacientes del piloto tienen credenciales y no deberían poder iniciar sesión', n; END IF;
    SELECT count(*) INTO n
      FROM profiles.person_account_links l JOIN profiles.patient_profiles pp ON pp.profile_id = l.person_id AND pp.patient_code LIKE 'DEMO-PIL-P%'
      JOIN iam.users u ON u.id = l.user_id AND u.status_concept_id = '32dbed9f-cf1f-5c7a-9070-dfb937cf68a1';
    IF n <> 4 THEN RAISE EXCEPTION 'V7 FALLÓ: se esperaban 4 cuentas de pacientes activas y hay %', n; END IF;

    RAISE NOTICE 'OK · agenda y chat de piloto: 8 agendas, 96 cupos (89 libres + 7 reservados) sin pisarse, ids uuid 5, patientProfileId resuelto por person_account_links (4/4), 4 conversaciones y bandeja de Ana/Lucía';
END
$v$;

ROLLBACK;
