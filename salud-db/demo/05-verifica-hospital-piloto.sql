-- Verificación del escenario del Hospital Piloto (04-hospital-piloto.sql): los casos de prueba
-- del diseño de personal de apoyo que se pueden decidir SOLO con la base.
--
-- Requiere el parche SQL/patches/2026-10-30_v4269_personal_apoyo.sql (trae las dos funciones:
-- refresh_effective_support_access y support_access_allowed, implementación de referencia de
-- SupportAccessPolicy). Falla con una excepción en el primer caso que no dé el resultado esperado.
-- Todo corre dentro de una transacción que se DESHACE (ROLLBACK): no deja nada.
--
-- v4.2.70 (revisión de seguridad M5): support_access_allowed FALLA CERRADA. Además de los casos 01-12 trae las
-- comprobaciones NEGATIVAS que la política exige:
--   N1  doctor sin aceptar a la persona (aceptación sin fecha, retirada o vencida) → negado; la de otro doctor no la sustituye
--   N1d responder en nombre del doctor exige may_reply_on_behalf
--   N2  recertificación vencida (next_recertification_at + 15 días) → negado, y refresh_effective_support_access ya no
--       genera filas; dentro de los 15 días de gracia → todavía permitido
--   N3  membresía terminada (estado) o con end_date vencido → negado, y el refresh tampoco genera filas
--   N4  la acción sin doctor → negado;  N5 doctor de OTRA organización → negado
--
-- Fuera de alcance de este script (son reglas de la API, no de la base):
--   09 Ana responde un mensaje de un paciente de Pérez (autora real = Ana; el paciente ve al doctor)
--   10 Ana abre una historia clínica (solo ve el motivo; el resto pide acceso temporal al doctor)
--   13 Ana busca «Juan» (la búsqueda de pacientes es exacta)
--
-- Uso:  psql -v ON_ERROR_STOP=1 -d <base> -f salud-db/demo/05-verifica-hospital-piloto.sql

BEGIN;

SELECT delegated_access.refresh_effective_support_access(NULL) AS filas_derivadas;

DO $verifica$
DECLARE
    hosp  uuid := (SELECT id FROM directory.tenants WHERE code = 'DEMO_HOSPITAL_PILOTO');
    cons  uuid := (SELECT id FROM directory.tenants WHERE code = 'DEMO_CONSULTORIO_CESPEDES');
    u_ana uuid; u_lucia uuid; u_marcos uuid; u_rosa uuid;
    pra_perez uuid; pra_rojas uuid; pra_suarez uuid; pra_mendez uuid; pra_antelo uuid; pra_cespedes uuid;
    s_consulta_card uuid; s_ecocardio uuid; s_eco uuid; s_eco_obst uuid; s_pediatria uuid; s_medint uuid;
    sp_a103 uuid; sp_a201 uuid; sp_a105 uuid; sp_a401 uuid; sp_a101 uuid; sp_b204 uuid; sp_n102 uuid; sp_b102 uuid; sp_k1 uuid;
    oua_ana uuid; oua_lucia uuid; oua_marcos uuid;
    n integer := 0; c integer;
    dead text;

BEGIN
    SELECT user_id INTO u_ana    FROM directory.tenant_memberships m JOIN iam.users u ON u.id = m.user_id WHERE m.tenant_id = hosp AND u.display_name = 'Ana Gutiérrez';
    SELECT user_id INTO u_lucia  FROM directory.tenant_memberships m JOIN iam.users u ON u.id = m.user_id WHERE m.tenant_id = hosp AND u.display_name = 'Lucía Paz';
    SELECT user_id INTO u_marcos FROM directory.tenant_memberships m JOIN iam.users u ON u.id = m.user_id WHERE m.tenant_id = hosp AND u.display_name = 'Marcos Ribera';
    SELECT user_id INTO u_rosa   FROM directory.tenant_memberships m JOIN iam.users u ON u.id = m.user_id WHERE m.tenant_id = cons AND u.display_name = 'Rosa Quiroga';

    SELECT a.id INTO oua_ana    FROM delegated_access.organization_user_assignments a JOIN directory.tenant_memberships m ON m.id = a.tenant_membership_id WHERE m.tenant_id = hosp AND m.user_id = u_ana;
    SELECT a.id INTO oua_lucia  FROM delegated_access.organization_user_assignments a JOIN directory.tenant_memberships m ON m.id = a.tenant_membership_id WHERE m.tenant_id = hosp AND m.user_id = u_lucia;
    SELECT a.id INTO oua_marcos FROM delegated_access.organization_user_assignments a JOIN directory.tenant_memberships m ON m.id = a.tenant_membership_id WHERE m.tenant_id = hosp AND m.user_id = u_marcos;

    SELECT r.id INTO pra_perez    FROM practice.practitioner_role_assignments r JOIN profiles.persons p ON p.id = r.practitioner_profile_id WHERE p.display_name = 'Andrés Pérez';
    SELECT r.id INTO pra_rojas    FROM practice.practitioner_role_assignments r JOIN profiles.persons p ON p.id = r.practitioner_profile_id WHERE p.display_name = 'Valeria Rojas';
    SELECT r.id INTO pra_suarez   FROM practice.practitioner_role_assignments r JOIN profiles.persons p ON p.id = r.practitioner_profile_id WHERE p.display_name = 'Martín Suárez';
    SELECT r.id INTO pra_mendez   FROM practice.practitioner_role_assignments r JOIN profiles.persons p ON p.id = r.practitioner_profile_id WHERE p.display_name = 'Carla Méndez';
    SELECT r.id INTO pra_antelo   FROM practice.practitioner_role_assignments r JOIN profiles.persons p ON p.id = r.practitioner_profile_id WHERE p.display_name = 'Lucía Antelo';
    SELECT r.id INTO pra_cespedes FROM practice.practitioner_role_assignments r JOIN profiles.persons p ON p.id = r.practitioner_profile_id WHERE p.display_name = 'Paola Céspedes';

    -- servicios: se reconocen por el concepto demo que los nombra
    SELECT hs.id INTO s_consulta_card FROM practice.healthcare_services hs JOIN terminology.catalog_concepts c ON c.id = hs.service_concept_id WHERE c.code = 'demo-hospital-piloto:service:CARDIOLOGIA';
    SELECT hs.id INTO s_ecocardio     FROM practice.healthcare_services hs JOIN terminology.catalog_concepts c ON c.id = hs.service_concept_id WHERE c.code = 'demo-hospital-piloto:service:ECOCARDIOGRAMA';
    SELECT hs.id INTO s_eco           FROM practice.healthcare_services hs JOIN terminology.catalog_concepts c ON c.id = hs.service_concept_id WHERE c.code = 'demo-hospital-piloto:service:ECOGRAFIA';
    SELECT hs.id INTO s_eco_obst      FROM practice.healthcare_services hs JOIN terminology.catalog_concepts c ON c.id = hs.service_concept_id WHERE c.code = 'demo-hospital-piloto:service:ECO_OBSTETRICA';
    SELECT hs.id INTO s_pediatria     FROM practice.healthcare_services hs JOIN terminology.catalog_concepts c ON c.id = hs.service_concept_id WHERE c.code = 'demo-hospital-piloto:service:PEDIATRIA';
    SELECT hs.id INTO s_medint        FROM practice.healthcare_services hs JOIN terminology.catalog_concepts c ON c.id = hs.service_concept_id WHERE c.code = 'demo-hospital-piloto:service:MEDICINA_INTERNA';

    SELECT id INTO sp_a103 FROM practice.care_spaces WHERE code = 'DEMO_A_103';
    SELECT id INTO sp_a201 FROM practice.care_spaces WHERE code = 'DEMO_A_201';
    SELECT id INTO sp_a105 FROM practice.care_spaces WHERE code = 'DEMO_A_105';
    SELECT id INTO sp_a401 FROM practice.care_spaces WHERE code = 'DEMO_A_401';
    SELECT id INTO sp_a101 FROM practice.care_spaces WHERE code = 'DEMO_A_101';
    SELECT id INTO sp_b204 FROM practice.care_spaces WHERE code = 'DEMO_B_204';
    SELECT id INTO sp_n102 FROM practice.care_spaces WHERE code = 'DEMO_N_102';
    SELECT id INTO sp_b102 FROM practice.care_spaces WHERE code = 'DEMO_B_102';
    SELECT id INTO sp_k1   FROM practice.care_spaces WHERE code = 'DEMO_K_1';

    -- PRECONDICIÓN (v4.2.72): estos casos suponen el demo SIN USO. Si alguien dio de baja a Ana, Lucía, Marcos o Rosa (por la API o por el front: «terminar
    -- vínculo») el vínculo queda REVOCADO y la membresía terminada, y los casos 01-12 fallarían con un mensaje engañoso («Ana debía poder…»). Se avisa la
    -- causa real: la base está contaminada, no el modelo. Se corrige recargando el demo sobre una base limpia (04 y, si se usa, 07).
    SELECT string_agg(x.quien, ', ' ORDER BY x.quien) INTO dead
      FROM (VALUES ('Ana', u_ana, hosp), ('Lucía', u_lucia, hosp), ('Marcos', u_marcos, hosp), ('Rosa', u_rosa, cons)) AS x(quien, uid, tid)
     WHERE NOT EXISTS (SELECT 1 FROM delegated_access.organization_user_assignments a
                         JOIN directory.tenant_memberships m ON m.id = a.tenant_membership_id
                        WHERE m.user_id = x.uid AND m.tenant_id = x.tid
                          AND a.status_concept_id = '38a1d301-f40d-5b17-a695-5e6d605f8b19'        -- state:active
                          AND m.status_concept_id <> '76d35f5f-5140-55be-9853-ee1dfe6a12fd'       -- directory:MEMBERSHIP_ENDED
                          AND (m.end_date IS NULL OR m.end_date > now()));
    IF dead IS NOT NULL THEN
        RAISE EXCEPTION 'PRECONDICIÓN DEL DEMO NO CUMPLIDA: el vínculo de apoyo de % ya no está vivo (revocado o con membresía terminada). La base fue usada o modificada después de cargar el demo; no es un fallo del modelo. Cargue 04 (y 07) sobre una base limpia y vuelva a correr este script.', dead
            USING ERRCODE = 'invalid_object_definition';
    END IF;

    -- cada caso: (nombre, esperado, resultado)
    n := n + 1;
    IF NOT delegated_access.support_access_allowed(u_ana, hosp, 'schedule.create', pra_perez, s_consulta_card, sp_a103) THEN
        RAISE EXCEPTION 'caso 01 FALLÓ: Ana debía poder crear una cita de Pérez (consulta, A-P1)'; END IF;
    n := n + 1;
    IF NOT delegated_access.support_access_allowed(u_ana, hosp, 'schedule.create', pra_perez, s_ecocardio, sp_a201) THEN
        RAISE EXCEPTION 'caso 02 FALLÓ: Ana debía poder crear un ecocardiograma de Pérez (A-P2)'; END IF;
    n := n + 1;
    IF NOT delegated_access.support_access_allowed(u_lucia, hosp, 'schedule.check_in', pra_mendez, s_medint, sp_a105) THEN
        RAISE EXCEPTION 'caso 03 FALLÓ: Lucía debía poder registrar la llegada de un paciente de Méndez en 105'; END IF;
    n := n + 1;
    IF delegated_access.support_access_allowed(u_lucia, hosp, 'schedule.check_in', pra_mendez, s_medint, sp_a401) THEN
        RAISE EXCEPTION 'caso 04 FALLÓ: Lucía NO debía poder registrar llegadas en A-P4'; END IF;
    n := n + 1;
    IF delegated_access.support_access_allowed(u_lucia, hosp, 'schedule.create', pra_perez, s_consulta_card, sp_a101) THEN
        RAISE EXCEPTION 'caso 05 FALLÓ: Lucía NO debía poder crear citas (su plantilla no tiene schedule.create)'; END IF;
    n := n + 1;
    IF NOT delegated_access.support_access_allowed(u_marcos, hosp, 'schedule.create', pra_antelo, s_eco, sp_a201) THEN
        RAISE EXCEPTION 'caso 06 FALLÓ: Marcos debía poder agendar Ecografía con Antelo en la sala 201'; END IF;
    n := n + 1;
    IF delegated_access.support_access_allowed(u_marcos, hosp, 'schedule.create', pra_rojas, s_eco_obst, sp_b204) THEN
        RAISE EXCEPTION 'caso 07 FALLÓ: Marcos NO debía poder agendar eco obstétrica con Rojas en B204'; END IF;
    n := n + 1;
    IF NOT delegated_access.support_access_allowed(u_marcos, hosp, 'schedule.create', pra_suarez, s_pediatria, sp_n102) THEN
        RAISE EXCEPTION 'caso 08a FALLÓ: Marcos debía poder agendar a Suárez en la Sede Norte'; END IF;
    n := n + 1;
    IF delegated_access.support_access_allowed(u_marcos, hosp, 'schedule.create', pra_suarez, s_pediatria, sp_b102) THEN
        RAISE EXCEPTION 'caso 08b FALLÓ: Marcos NO debía poder agendar a Suárez en el Edificio B'; END IF;
    n := n + 1;
    IF delegated_access.support_access_allowed(u_rosa, hosp, 'schedule.view', pra_cespedes, NULL, sp_k1) THEN
        RAISE EXCEPTION 'caso 11a FALLÓ: Rosa NO debía ver la agenda de Céspedes en el Hospital Piloto'; END IF;
    n := n + 1;
    IF NOT delegated_access.support_access_allowed(u_rosa, cons, 'schedule.view', pra_cespedes, NULL, sp_k1) THEN
        RAISE EXCEPTION 'caso 11b FALLÓ: Rosa SÍ debía ver la agenda de Céspedes en su propio consultorio'; END IF;

    -- ===================== comprobaciones NEGATIVAS (v4.2.70) =====================
    -- N1 · doctor sin aceptar. Ana tiene permiso sobre Pérez y Rojas; la aceptación es por doctor.
    UPDATE delegated_access.practitioner_delegate_assignments SET accepted_at = NULL
     WHERE delegate_user_assignment_id = oua_ana AND practitioner_role_assignment_id = pra_perez;
    n := n + 1;
    IF delegated_access.support_access_allowed(u_ana, hosp, 'schedule.create', pra_perez, s_consulta_card, sp_a103) THEN
        RAISE EXCEPTION 'caso N1a FALLÓ: Ana NO debía poder con Pérez si Pérez no la aceptó (accepted_at NULL)'; END IF;
    n := n + 1;
    IF NOT delegated_access.support_access_allowed(u_ana, hosp, 'schedule.create', pra_rojas, s_eco_obst, sp_b204) THEN
        RAISE EXCEPTION 'caso N1b FALLÓ: la falta de aceptación de Pérez NO debía quitarle a Ana lo de Rojas'; END IF;
    UPDATE delegated_access.practitioner_delegate_assignments SET accepted_at = now()
     WHERE delegate_user_assignment_id = oua_ana AND practitioner_role_assignment_id = pra_perez;
    n := n + 1;
    IF NOT delegated_access.support_access_allowed(u_ana, hosp, 'schedule.create', pra_perez, s_consulta_card, sp_a103) THEN
        RAISE EXCEPTION 'caso N1c FALLÓ: con la aceptación restituida Ana debía volver a poder con Pérez'; END IF;
    -- aceptación retirada (estado revocado) o vencida (valid_to pasado)
    UPDATE delegated_access.practitioner_delegate_assignments SET status_concept_id = '8d56de1d-f25e-54eb-bc54-3ab2fbc70249'
     WHERE delegate_user_assignment_id = oua_ana AND practitioner_role_assignment_id = pra_perez;
    n := n + 1;
    IF delegated_access.support_access_allowed(u_ana, hosp, 'schedule.create', pra_perez, s_consulta_card, sp_a103) THEN
        RAISE EXCEPTION 'caso N1d FALLÓ: una aceptación REVOCADA no debía contar'; END IF;
    UPDATE delegated_access.practitioner_delegate_assignments SET status_concept_id = '38a1d301-f40d-5b17-a695-5e6d605f8b19', valid_to = valid_from   -- vencida (valid_from es anterior a esta transacción; un instante fijo evita rangos invertidos)
     WHERE delegate_user_assignment_id = oua_ana AND practitioner_role_assignment_id = pra_perez;
    n := n + 1;
    IF delegated_access.support_access_allowed(u_ana, hosp, 'schedule.create', pra_perez, s_consulta_card, sp_a103) THEN
        RAISE EXCEPTION 'caso N1e FALLÓ: una aceptación VENCIDA no debía contar'; END IF;
    UPDATE delegated_access.practitioner_delegate_assignments SET valid_to = NULL
     WHERE delegate_user_assignment_id = oua_ana AND practitioner_role_assignment_id = pra_perez;
    -- responder en nombre del doctor: Pérez aceptó que Ana responda; Rojas no (may_reply_on_behalf = false)
    n := n + 1;
    IF NOT delegated_access.support_access_allowed(u_ana, hosp, 'messages.reply_on_behalf', pra_perez) THEN
        RAISE EXCEPTION 'caso N1f FALLÓ: Ana debía poder responder en nombre de Pérez'; END IF;
    n := n + 1;
    IF delegated_access.support_access_allowed(u_ana, hosp, 'messages.reply_on_behalf', pra_rojas) THEN
        RAISE EXCEPTION 'caso N1g FALLÓ: Ana NO debía poder responder en nombre de Rojas (no lo aceptó)'; END IF;

    -- N2 · recertificación vencida (Lucía; vence a los 15 días de gracia)
    UPDATE delegated_access.organization_user_assignments SET next_recertification_at = now() - interval '14 days' WHERE id = oua_lucia;
    n := n + 1;
    IF NOT delegated_access.support_access_allowed(u_lucia, hosp, 'schedule.check_in', pra_mendez, s_medint, sp_a105) THEN
        RAISE EXCEPTION 'caso N2a FALLÓ: a los 14 días de vencida la recertificación Lucía aún está en su gracia de 15'; END IF;
    UPDATE delegated_access.organization_user_assignments SET next_recertification_at = now() - interval '16 days' WHERE id = oua_lucia;
    n := n + 1;
    IF delegated_access.support_access_allowed(u_lucia, hosp, 'schedule.check_in', pra_mendez, s_medint, sp_a105) THEN
        RAISE EXCEPTION 'caso N2b FALLÓ: con la recertificación vencida hace 16 días Lucía NO debía tener acceso (aunque la tabla derivada no se haya refrescado)'; END IF;
    PERFORM delegated_access.refresh_effective_support_access(hosp);
    SELECT count(*) INTO c FROM delegated_access.effective_support_access WHERE user_id = u_lucia AND tenant_id = hosp;
    n := n + 1;
    IF c <> 0 THEN RAISE EXCEPTION 'caso N2c FALLÓ: el refresh no debía dejar filas de Lucía con la recertificación vencida (hay %)', c; END IF;
    UPDATE delegated_access.organization_user_assignments SET next_recertification_at = now() + interval '12 months' WHERE id = oua_lucia;
    PERFORM delegated_access.refresh_effective_support_access(hosp);
    n := n + 1;
    IF NOT delegated_access.support_access_allowed(u_lucia, hosp, 'schedule.check_in', pra_mendez, s_medint, sp_a105) THEN
        RAISE EXCEPTION 'caso N2d FALLÓ: recertificada, Lucía debía recuperar el acceso'; END IF;

    -- N3 · membresía terminada (Marcos): por estado y por end_date
    UPDATE directory.tenant_memberships SET status_concept_id = '76d35f5f-5140-55be-9853-ee1dfe6a12fd'   -- directory:MEMBERSHIP_ENDED
     WHERE user_id = u_marcos AND tenant_id = hosp;
    n := n + 1;
    IF delegated_access.support_access_allowed(u_marcos, hosp, 'schedule.create', pra_antelo, s_eco, sp_a201) THEN
        RAISE EXCEPTION 'caso N3a FALLÓ: con la membresía terminada Marcos NO debía tener acceso (tabla derivada sin refrescar)'; END IF;
    PERFORM delegated_access.refresh_effective_support_access(hosp);
    SELECT count(*) INTO c FROM delegated_access.effective_support_access WHERE user_id = u_marcos AND tenant_id = hosp;
    n := n + 1;
    IF c <> 0 THEN RAISE EXCEPTION 'caso N3b FALLÓ: el refresh no debía dejar filas de Marcos con la membresía terminada (hay %)', c; END IF;
    UPDATE directory.tenant_memberships SET status_concept_id = '13ca1b46-61d5-5c25-9d49-8247bcd7769c', end_date = start_date   -- terminada (end_date <= ahora)
     WHERE user_id = u_marcos AND tenant_id = hosp;
    n := n + 1;
    IF delegated_access.support_access_allowed(u_marcos, hosp, 'schedule.create', pra_antelo, s_eco, sp_a201) THEN
        RAISE EXCEPTION 'caso N3c FALLÓ: con end_date vencido Marcos NO debía tener acceso'; END IF;
    UPDATE directory.tenant_memberships SET end_date = NULL WHERE user_id = u_marcos AND tenant_id = hosp;
    PERFORM delegated_access.refresh_effective_support_access(hosp);
    n := n + 1;
    IF NOT delegated_access.support_access_allowed(u_marcos, hosp, 'schedule.create', pra_antelo, s_eco, sp_a201) THEN
        RAISE EXCEPTION 'caso N3d FALLÓ: restituida la membresía Marcos debía recuperar el acceso'; END IF;

    -- N4 · sin doctor no hay aceptación que comprobar: se niega.  N5 · doctor de OTRA organización.
    n := n + 1;
    IF delegated_access.support_access_allowed(u_marcos, hosp, 'schedule.create', NULL, s_eco, sp_a201) THEN
        RAISE EXCEPTION 'caso N4 FALLÓ: una acción sin doctor NO debía permitirse'; END IF;
    n := n + 1;
    IF delegated_access.support_access_allowed(u_marcos, hosp, 'schedule.create', pra_cespedes, s_eco, sp_a201) THEN
        RAISE EXCEPTION 'caso N5 FALLÓ: el doctor de otra organización (Céspedes) NO debía poder agendarse desde el Hospital Piloto'; END IF;

    -- 12 · fin de vínculo: Ana pierde TODO de inmediato (las citas ya creadas no se tocan: no hay DELETE)
    UPDATE delegated_access.organization_user_assignments
       SET status_concept_id = '8d56de1d-f25e-54eb-bc54-3ab2fbc70249',   -- state:revoked (concepto central de la API)
           valid_to = now(), ended_reason_text = 'verificación de demo'
     WHERE tenant_membership_id = (SELECT id FROM directory.tenant_memberships WHERE user_id = u_ana AND tenant_id = hosp);
    PERFORM delegated_access.refresh_effective_support_access(hosp);
    n := n + 1;
    IF delegated_access.support_access_allowed(u_ana, hosp, 'schedule.create', pra_perez, s_consulta_card, sp_a103) THEN
        RAISE EXCEPTION 'caso 12 FALLÓ: tras el fin del vínculo Ana NO debía tener acceso'; END IF;

    RAISE NOTICE 'OK · % comprobaciones del hospital piloto pasaron', n;
END
$verifica$;

ROLLBACK;
