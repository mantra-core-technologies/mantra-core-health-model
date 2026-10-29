#!/usr/bin/env python3
"""Infraestructura F4 (quirófanos) contra un Postgres REAL: los dos patches y lo que garantizan.

Se saltan enteras sin SALUD_TEST_PGDATABASE (ver `_f4_pg.py`) o si esa base todavía no tiene aplicados
los patches `…_f4_scheduling.sql` y `…_f4z_periop.sql`. Todo corre en UN psql por escenario con
`BEGIN; … ROLLBACK;`: la base queda como estaba, incluso las pruebas que vuelven a correr los patches.

Los datos que los patches DEBEN rechazar (solape por recambio, referencias entre tenants, check-lists
duplicados…) no se pueden insertar con los patches puestos, así que esas pruebas «rebobinan» dentro de
la transacción el objeto que lo impediría (DROP de la restricción o del trigger), insertan el dato
incompatible y vuelven a correr el patch tal cual (sin su BEGIN/COMMIT): debe abortar con su mensaje.
"""
from __future__ import annotations

import json
import sys
import unittest
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
import _f4_pg as pg  # noqa: E402

DB = pg.database()
SKIP_REASON = "sin SALUD_TEST_PGDATABASE (base con F1 + F1b + F4 aplicados)"
if DB and not pg.patches_applied():
    DB = None
    SKIP_REASON = "la base de SALUD_TEST_PGDATABASE no tiene aplicados los patches de F4"

PC = "procedures_perioperative.procedure_cases"
EV = "procedures_perioperative.operating_room_utilization_events"
SER = "procedures_perioperative.operating_room_block_series"
BLK = "procedures_perioperative.operating_room_blocks"
CHK = "procedures_perioperative.surgical_safety_checklists"
RES = "scheduling.schedulable_resources"
SERH = "audit.operating_room_block_series_history"
BLKH = "audit.operating_room_blocks_history"


def u(prefix: str, n: int) -> str:
    return f"{prefix}0000000-0000-4000-8000-{n:012d}"


def case(i: str, room: str | None, start: str | None, end: str | None, *, status: str = pg.CASE_SCHEDULED,
         tenant: str = pg.T_A, **kw) -> str:
    return pg.fx(PC, id=i, custodian_tenant_id=tenant, patient_profile_id=pg.PATIENT,
                 case_number="N" + i[-6:], case_type_concept_id=pg.CONCEPT_OTHER,
                 priority_concept_id=pg.CONCEPT_OTHER, status_concept_id=status,
                 operating_room_id=room, scheduled_start_at=start, scheduled_end_at=end, **kw)


def try_fx(label: str, table: str, **cols) -> str:
    return pg.try_(label, f"SELECT pg_temp.fx('{table}', $j${json.dumps(cols)}$j$::jsonb)")


def case_cols(i: str, room: str, start: str, end: str, **kw) -> dict:
    return dict(id=i, custodian_tenant_id=kw.pop("tenant", pg.T_A), patient_profile_id=pg.PATIENT,
                case_number="N" + i[-6:], case_type_concept_id=pg.CONCEPT_OTHER,
                priority_concept_id=pg.CONCEPT_OTHER, status_concept_id=kw.pop("status", pg.CASE_SCHEDULED),
                operating_room_id=room, scheduled_start_at=start, scheduled_end_at=end, **kw)


def block_cols(i: str, *, room: str = pg.OR_A1, start: str = "2026-11-09 08:00+00", end: str = "2026-11-09 14:00+00",
               tenant: str = pg.T_A, **kw) -> dict:
    base = dict(id=i, tenant_id=tenant, operating_room_id=room, owner_kind_concept_id=pg.ORB_OWNER_SERVICE,
                clinical_unit_id=pg.UNIT_A1, starts_at=start, ends_at=end, release_at="2026-11-01 00:00+00",
                status_concept_id=pg.ORB_ACTIVE)
    base.update(kw)
    return base


def series_cols(i: str, *, room: str = pg.OR_A1, site: str = pg.SITE_A1, tenant: str = pg.T_A, **kw) -> dict:
    base = dict(id=i, tenant_id=tenant, practice_site_id=site, operating_room_id=room,
                owner_kind_concept_id=pg.ORB_OWNER_SERVICE, clinical_unit_id=pg.UNIT_A1, weekdays=[2],
                start_time="08:00", end_time="14:00", valid_from="2026-11-01", release_hours=72,
                status_concept_id=pg.ORB_ACTIVE)
    base.update(kw)
    return base


def resource_cols(i: str, space: str | None, *, tenant: str = pg.T_A, state: str = pg.STATE_ACTIVE,
                  ref_type: str = "care_spaces", ref_id: str | None = None, **kw) -> dict:
    base = dict(id=i, tenant_id=tenant, resource_type_concept_id=pg.RES_ROOM, resource_ref_type=ref_type,
                resource_ref_id=ref_id or space, name="Quirófano", state_concept_id=state, care_space_id=space)
    base.update(kw)
    return base


def ins(table: str, **cols) -> str:
    return f"SELECT pg_temp.fx('{table}', $j${json.dumps(cols)}$j$::jsonb);"


def as_app(tenant: str) -> str:
    """Pasa a ser el rol de aplicación (sin BYPASSRLS) con el contexto de ese tenant y SIN contexto SYSTEM."""
    return ("SET LOCAL ROLE mantra_app;"
            f"SELECT set_config('app.current_tenant_id', '{tenant}', true);"
            "SELECT set_config('app.system_context', 'false', true);")


def expect(test: unittest.TestCase, result: pg.Result, label: str, sqlstate: str, fragment: str | None = None) -> None:
    labels = result.labels()
    test.assertEqual(result.rc, 0, result.err)
    test.assertIn(label, labels, f"sin resultado para {label}: {result.out!r}")
    got, msg = labels[label]
    test.assertEqual(got, sqlstate, f"{label}: {got}|{msg}")
    if fragment:
        test.assertIn(fragment, msg)


@unittest.skipUnless(DB, SKIP_REASON)
class ReservedWindowTests(unittest.TestCase):
    """INV-38: la sala reserva duración + preparación + limpieza y no admite dos casos solapados."""

    def test_window_uses_the_room_buffers_and_an_explicit_value_wins(self) -> None:
        r = pg.scenario(
            case(u("2", 1), pg.OR_A1, "2026-11-02 08:00+00", "2026-11-02 10:00+00")           # prep 15 / limpieza 20 de la sala
            + case(u("2", 2), pg.OR_A2, "2026-11-02 08:00+00", "2026-11-02 10:00+00")         # sala sin recambio
            + case(u("2", 3), pg.OR_A1, "2026-11-03 08:00+00", "2026-11-03 10:00+00", prep_minutes=0, cleanup_minutes=5)
            + "SELECT 'W|' || right(id::text, 1) || '|' || to_char(reserved_start_at AT TIME ZONE 'UTC', 'HH24:MI')"
              " || '|' || to_char(reserved_end_at AT TIME ZONE 'UTC', 'HH24:MI') FROM " + PC + " ORDER BY id;")
        self.assertEqual(r.rc, 0, r.err)
        w = {l.split("|")[1]: l.split("|")[2:] for l in r.out.splitlines() if l.startswith("W|")}
        self.assertEqual(w["1"], ["07:45", "10:20"])
        self.assertEqual(w["2"], ["08:00", "10:00"])
        self.assertEqual(w["3"], ["08:00", "10:05"])   # valor explícito del caso: gana al del espacio

    def test_overlap_including_prep_and_cleanup_is_rejected_and_touching_is_not(self) -> None:
        a = case(u("2", 1), pg.OR_A1, "2026-11-02 08:00+00", "2026-11-02 10:00+00")   # reserva 07:45–10:20
        r = pg.scenario(
            a
            + try_fx("DENTRO_DE_LA_LIMPIEZA", PC, **case_cols(u("2", 2), pg.OR_A1, "2026-11-02 10:10+00", "2026-11-02 11:00+00"))
            + try_fx("DENTRO_DE_LA_PREPARACION", PC, **case_cols(u("2", 3), pg.OR_A1, "2026-11-02 06:00+00", "2026-11-02 07:50+00"))
            # arranca a las 10:35: su preparación (15 min) empieza a las 10:20, justo cuando termina la limpieza de A
            + try_fx("TOCA_SIN_SOLAPAR", PC, **case_cols(u("2", 4), pg.OR_A1, "2026-11-02 10:35+00", "2026-11-02 11:00+00"))
            + try_fx("OTRA_SALA", PC, **case_cols(u("2", 5), pg.OR_A2, "2026-11-02 10:10+00", "2026-11-02 11:00+00")))
        expect(self, r, "DENTRO_DE_LA_LIMPIEZA", "23P01", "ex_procedure_cases_operating_room_reserved_time")
        expect(self, r, "DENTRO_DE_LA_PREPARACION", "23P01", "ex_procedure_cases_operating_room_reserved_time")
        expect(self, r, "TOCA_SIN_SOLAPAR", "OK")
        expect(self, r, "OTRA_SALA", "OK")

    def test_only_live_statuses_occupy_the_room(self) -> None:
        a = case(u("2", 1), pg.OR_A1, "2026-11-02 08:00+00", "2026-11-02 10:00+00")
        r = pg.scenario(
            a
            + try_fx("CANCELADO", PC, **case_cols(u("2", 2), pg.OR_A1, "2026-11-02 09:00+00", "2026-11-02 09:30+00", status=pg.CASE_CANCELLED))
            + try_fx("LISTO", PC, **case_cols(u("2", 3), pg.OR_A1, "2026-11-02 09:00+00", "2026-11-02 09:30+00", status=pg.CASE_READY))
            + try_fx("EN_CURSO", PC, **case_cols(u("2", 4), pg.OR_A1, "2026-11-02 09:00+00", "2026-11-02 09:30+00", status=pg.CASE_IN_PROGRESS)))
        expect(self, r, "CANCELADO", "OK")
        expect(self, r, "LISTO", "23P01")
        expect(self, r, "EN_CURSO", "23P01")

    def test_reserved_columns_cannot_be_forced_by_the_client(self) -> None:
        a = case(u("2", 1), pg.OR_A1, "2026-11-02 08:00+00", "2026-11-02 10:00+00")
        r = pg.scenario(
            a
            + "UPDATE " + PC + " SET reserved_start_at = '2026-11-02 00:00+00', reserved_end_at = '2026-11-02 23:00+00';"
            + "SELECT 'W|' || to_char(reserved_start_at AT TIME ZONE 'UTC', 'HH24:MI') || '|' || to_char(reserved_end_at AT TIME ZONE 'UTC', 'HH24:MI') FROM " + PC + ";"
            + case(u("2", 2), pg.OR_A2, "2026-11-04 08:00+00", "2026-11-04 09:00+00", reserved_start_at="2026-01-01 00:00+00", reserved_end_at="2026-01-02 00:00+00")
            + "SELECT 'X|' || to_char(reserved_start_at AT TIME ZONE 'UTC', 'HH24:MI') FROM " + PC + " WHERE id = '" + u("2", 2) + "';")
        self.assertEqual(r.rc, 0, r.err)
        self.assertIn("W|07:45|10:20", r.out)
        self.assertIn("X|08:00", r.out)

    def test_window_is_a_photo_unrelated_updates_keep_it_and_changing_inputs_recomputes_it(self) -> None:
        r = pg.scenario(
            case(u("2", 1), pg.OR_A1, "2026-11-02 08:00+00", "2026-11-02 10:00+00")
            + "UPDATE practice.care_spaces SET prep_minutes = 60, cleanup_minutes = 60 WHERE id = '" + pg.OR_A1 + "';"
            + "UPDATE " + PC + " SET urgency_reason_text = 'nota';"          # nada de la ventana cambió
            + "SELECT 'A|' || to_char(reserved_start_at AT TIME ZONE 'UTC', 'HH24:MI') || '|' || to_char(reserved_end_at AT TIME ZONE 'UTC', 'HH24:MI') FROM " + PC + ";"
            + "UPDATE " + PC + " SET scheduled_end_at = '2026-11-02 10:30+00';"   # cambia una entrada: se recalcula con los 60/60 nuevos
            + "SELECT 'B|' || to_char(reserved_start_at AT TIME ZONE 'UTC', 'HH24:MI') || '|' || to_char(reserved_end_at AT TIME ZONE 'UTC', 'HH24:MI') FROM " + PC + ";"
            + "UPDATE " + PC + " SET scheduled_start_at = NULL;"
            + "SELECT 'C|' || coalesce(reserved_start_at::text, 'NULL') FROM " + PC + ";")
        self.assertEqual(r.rc, 0, r.err)
        self.assertIn("A|07:45|10:20", r.out)
        self.assertIn("B|07:00|11:30", r.out)
        self.assertIn("C|NULL", r.out)

    def test_moving_a_case_into_an_occupied_window_or_room_is_rejected(self) -> None:
        r = pg.scenario(
            case(u("2", 1), pg.OR_A1, "2026-11-02 08:00+00", "2026-11-02 10:00+00")
            + case(u("2", 2), pg.OR_A1, "2026-11-02 12:00+00", "2026-11-02 13:00+00")
            + case(u("2", 3), pg.OR_A2, "2026-11-02 08:30+00", "2026-11-02 09:30+00")
            + pg.try_("MOVER_EN_EL_TIEMPO", f"UPDATE {PC} SET scheduled_start_at = '2026-11-02 10:10+00', scheduled_end_at = '2026-11-02 10:50+00' WHERE id = '{u('2', 2)}'")
            + pg.try_("MOVER_DE_SALA", f"UPDATE {PC} SET operating_room_id = '{pg.OR_A1}' WHERE id = '{u('2', 3)}'")
            + pg.try_("MOVER_LIBRE", f"UPDATE {PC} SET scheduled_start_at = '2026-11-02 14:00+00', scheduled_end_at = '2026-11-02 15:00+00' WHERE id = '{u('2', 2)}'"))
        expect(self, r, "MOVER_EN_EL_TIEMPO", "23P01")
        expect(self, r, "MOVER_DE_SALA", "23P01")
        expect(self, r, "MOVER_LIBRE", "OK")

    def test_the_old_window_without_turnover_is_gone_and_the_new_exclude_is_in_place(self) -> None:
        r = pg.scenario("SELECT 'N|' || count(*) FILTER (WHERE conname = 'ex_procedure_cases_operating_room_time'),"
                        " count(*) FILTER (WHERE conname = 'ex_procedure_cases_operating_room_reserved_time' AND contype = 'x')"
                        " FROM pg_constraint WHERE conrelid = '" + PC + "'::regclass;", fixture=False)
        self.assertEqual(r.rc, 0, r.err)
        self.assertIn("N|0|1", r.out.replace(" ", ""))


@unittest.skipUnless(DB, SKIP_REASON)
class SchedulableResourceTests(unittest.TestCase):
    """R0 / INV-40: el recurso ROOM tiene FK real al espacio, del mismo tenant, uno activo por espacio."""

    def test_one_active_resource_per_space_inactive_ones_are_free(self) -> None:
        r = pg.scenario(
            ins(RES, **resource_cols(u("1", 1), pg.OR_A1))
            + try_fx("SEGUNDO_ACTIVO", RES, **resource_cols(u("1", 2), pg.OR_A1))
            + try_fx("OTRO_ESPACIO", RES, **resource_cols(u("1", 3), pg.OR_A2))
            + try_fx("INACTIVO", RES, **resource_cols(u("1", 4), pg.OR_A1, state=pg.CONCEPT_OTHER)))
        expect(self, r, "SEGUNDO_ACTIVO", "23505", "ux_schedulable_resources_care_space_active")
        expect(self, r, "OTRO_ESPACIO", "OK")
        expect(self, r, "INACTIVO", "OK")

    def test_care_space_id_and_ref_type_are_consistent(self) -> None:
        r = pg.scenario(
            try_fx("TIPO_ESPACIOS_SIN_FK", RES, **resource_cols(u("1", 1), None, ref_id=pg.OR_A1))
            + try_fx("FK_DISTINTA_DE_LA_REFERENCIA", RES, **resource_cols(u("1", 2), pg.OR_A1, ref_id=pg.OR_A2))
            + try_fx("FK_EN_RECURSO_QUE_NO_ES_ESPACIO", RES, **resource_cols(u("1", 3), pg.OR_A1, ref_type="health_practitioner_profiles", ref_id=pg.SURGEON))
            + try_fx("PROFESIONAL_SIN_ESPACIO", RES, **resource_cols(u("1", 4), None, ref_type="health_practitioner_profiles", ref_id=pg.SURGEON))
            + try_fx("VALIDO", RES, **resource_cols(u("1", 5), pg.OR_A1)))
        for label in ("TIPO_ESPACIOS_SIN_FK", "FK_DISTINTA_DE_LA_REFERENCIA", "FK_EN_RECURSO_QUE_NO_ES_ESPACIO"):
            expect(self, r, label, "23514", "ck_schedulable_resources_care_space_ref")
        expect(self, r, "PROFESIONAL_SIN_ESPACIO", "OK")
        expect(self, r, "VALIDO", "OK")

    def test_a_resource_cannot_point_at_a_space_of_another_tenant(self) -> None:
        r = pg.scenario(
            try_fx("ESPACIO_AJENO", RES, **resource_cols(u("1", 1), pg.OR_B1, tenant=pg.T_A))
            + try_fx("ESPACIO_PROPIO_DEL_OTRO_TENANT", RES, **resource_cols(u("1", 2), pg.OR_B1, tenant=pg.T_B)))
        expect(self, r, "ESPACIO_AJENO", "23503", "fk_schedulable_resources_tenant_care_space")
        expect(self, r, "ESPACIO_PROPIO_DEL_OTRO_TENANT", "OK")

    def test_a_case_cannot_use_a_resource_block_or_room_of_another_tenant(self) -> None:
        r = pg.scenario(
            ins(RES, **resource_cols(u("1", 1), pg.OR_B1, tenant=pg.T_B))
            + ins(BLK, **block_cols(u("3", 1), room=pg.OR_B1, tenant=pg.T_B, clinical_unit_id=pg.UNIT_B1))
            + try_fx("RECURSO_AJENO", PC, **case_cols(u("2", 1), pg.OR_A1, "2026-11-02 08:00+00", "2026-11-02 10:00+00", schedulable_resource_id=u("1", 1)))
            + try_fx("BLOQUE_AJENO", PC, **case_cols(u("2", 2), pg.OR_A1, "2026-11-02 08:00+00", "2026-11-02 10:00+00", operating_room_block_id=u("3", 1)))
            + try_fx("SALA_AJENA", PC, **case_cols(u("2", 3), pg.OR_B1, "2026-11-02 08:00+00", "2026-11-02 10:00+00"))
            + try_fx("SEDE_AJENA", PC, **case_cols(u("2", 4), pg.OR_A1, "2026-11-02 08:00+00", "2026-11-02 10:00+00", practice_site_id=pg.SITE_B1))
            + try_fx("TODO_PROPIO", PC, **case_cols(u("2", 5), pg.OR_B1, "2026-11-02 08:00+00", "2026-11-02 10:00+00", tenant=pg.T_B,
                                                    schedulable_resource_id=u("1", 1), operating_room_block_id=u("3", 1), practice_site_id=pg.SITE_B1)))
        for label, fk in (("RECURSO_AJENO", "fk_procedure_cases_tenant_resource"), ("BLOQUE_AJENO", "fk_procedure_cases_tenant_block"),
                          ("SALA_AJENA", "fk_procedure_cases_tenant_operating_room"), ("SEDE_AJENA", "fk_procedure_cases_tenant_practice_site")):
            expect(self, r, label, "23503", fk)
        expect(self, r, "TODO_PROPIO", "OK")


@unittest.skipUnless(DB, SKIP_REASON)
class BlockTests(unittest.TestCase):
    """Bloques por servicio o cirujano con liberación (F4.1)."""

    def test_active_blocks_of_a_room_cannot_overlap(self) -> None:
        r = pg.scenario(
            ins(BLK, **block_cols(u("3", 1)))                                                  # 08:00–14:00
            + try_fx("SOLAPADO_ACTIVO", BLK, **block_cols(u("3", 2), start="2026-11-09 13:00+00", end="2026-11-09 16:00+00"))
            + try_fx("TOCA", BLK, **block_cols(u("3", 3), start="2026-11-09 14:00+00", end="2026-11-09 16:00+00"))
            + try_fx("OTRA_SALA", BLK, **block_cols(u("3", 4), room=pg.OR_A2, start="2026-11-09 13:00+00", end="2026-11-09 16:00+00"))
            + try_fx("SOLAPADO_PERO_LIBERADO", BLK, **block_cols(u("3", 5), start="2026-11-09 09:00+00", end="2026-11-09 10:00+00",
                                                                 status_concept_id=pg.ORB_RELEASED, released_at="2026-11-02 00:00+00",
                                                                 released_by_user_id=pg.USER_1, release_reason="no se usa"))
            + try_fx("SOLAPADO_PERO_CANCELADO", BLK, **block_cols(u("3", 6), start="2026-11-09 09:00+00", end="2026-11-09 10:00+00",
                                                                  status_concept_id=pg.ORB_CANCELLED)))
        expect(self, r, "SOLAPADO_ACTIVO", "23P01", "ex_operating_room_blocks_time")
        for label in ("TOCA", "OTRA_SALA", "SOLAPADO_PERO_LIBERADO", "SOLAPADO_PERO_CANCELADO"):
            expect(self, r, label, "OK")

    def test_releasing_a_block_frees_the_time_for_another_one(self) -> None:
        r = pg.scenario(
            ins(BLK, **block_cols(u("3", 1)))
            + try_fx("ANTES", BLK, **block_cols(u("3", 2), start="2026-11-09 09:00+00", end="2026-11-09 10:00+00"))
            + f"UPDATE {BLK} SET status_concept_id = '{pg.ORB_RELEASED}', released_at = '2026-11-02 00:00+00', released_by_user_id = NULL, released_minutes = 360 WHERE id = '{u('3', 1)}';"
            + try_fx("DESPUES", BLK, **block_cols(u("3", 3), start="2026-11-09 09:00+00", end="2026-11-09 10:00+00")))
        expect(self, r, "ANTES", "23P01")
        expect(self, r, "DESPUES", "OK")    # liberación automática: sin usuario ni motivo

    def test_block_checks(self) -> None:
        def b(i, **kw):
            return block_cols(u("3", i), start=f"2026-12-{10 + i:02d} 08:00+00", end=f"2026-12-{10 + i:02d} 14:00+00", **kw)
        r = pg.scenario(
            try_fx("FIN_ANTES_DEL_INICIO", BLK, **b(1, ends_at="2026-12-11 07:00+00"))
            + try_fx("LIBERACION_DESPUES_DEL_INICIO", BLK, **b(2, release_at="2026-12-13 00:00+00"))
            + try_fx("ESTADO_FUERA_DEL_DOMINIO", BLK, **b(3, status_concept_id=pg.CONCEPT_OTHER))
            + try_fx("LIBERADO_SIN_FECHA", BLK, **b(4, status_concept_id=pg.ORB_RELEASED, released_by_user_id=None))
            + try_fx("ACTIVO_CON_FECHA_DE_LIBERACION", BLK, **b(5, released_at="2026-12-01 00:00+00"))
            + try_fx("LIBERADO_POR_PERSONA_SIN_MOTIVO", BLK, **b(6, status_concept_id=pg.ORB_RELEASED, released_at="2026-12-01 00:00+00", released_by_user_id=pg.USER_1))
            + try_fx("LIBERADO_POR_PERSONA_CON_MOTIVO", BLK, **b(7, status_concept_id=pg.ORB_RELEASED, released_at="2026-12-01 00:00+00", released_by_user_id=pg.USER_1, release_reason="cirujano de vacaciones"))
            + try_fx("MINUTOS_NEGATIVOS", BLK, **b(8, released_minutes=-1))
            + try_fx("SERVICIO_SIN_UNIDAD_NI_ESPECIALIDAD", BLK, **b(9, clinical_unit_id=None))
            + try_fx("SERVICIO_CON_ESPECIALIDAD", BLK, **b(10, clinical_unit_id=None, surgical_specialty_concept_id=pg.CONCEPT_SPECIALTY))
            + try_fx("CIRUJANO_SIN_CIRUJANO", BLK, **b(11, owner_kind_concept_id=pg.ORB_OWNER_SURGEON, clinical_unit_id=None))
            + try_fx("CIRUJANO", BLK, **b(12, owner_kind_concept_id=pg.ORB_OWNER_SURGEON, clinical_unit_id=None, surgeon_profile_id=pg.SURGEON))
            + try_fx("DUENO_FUERA_DEL_DOMINIO", BLK, **b(13, owner_kind_concept_id=pg.CONCEPT_OTHER)))
        for label, check in (("FIN_ANTES_DEL_INICIO", "ck_operating_room_blocks_window"), ("LIBERACION_DESPUES_DEL_INICIO", "ck_operating_room_blocks_window"),
                             ("ESTADO_FUERA_DEL_DOMINIO", "ck_operating_room_blocks_status"), ("LIBERADO_SIN_FECHA", "ck_operating_room_blocks_release_state"),
                             ("ACTIVO_CON_FECHA_DE_LIBERACION", "ck_operating_room_blocks_release_state"),
                             ("LIBERADO_POR_PERSONA_SIN_MOTIVO", "ck_operating_room_blocks_release_state"), ("MINUTOS_NEGATIVOS", "ck_operating_room_blocks_release_state"),
                             ("SERVICIO_SIN_UNIDAD_NI_ESPECIALIDAD", "ck_operating_room_blocks_owner"), ("CIRUJANO_SIN_CIRUJANO", "ck_operating_room_blocks_owner"),
                             ("DUENO_FUERA_DEL_DOMINIO", "ck_operating_room_blocks_owner")):
            expect(self, r, label, "23514", check)
        for label in ("LIBERADO_POR_PERSONA_CON_MOTIVO", "SERVICIO_CON_ESPECIALIDAD", "CIRUJANO"):
            expect(self, r, label, "OK")

    def test_series_checks(self) -> None:
        def s(i, **kw):
            return series_cols(u("4", i), **kw)
        r = pg.scenario(
            try_fx("VALIDA", SER, **s(1))
            + try_fx("SIN_DIAS", SER, **s(2, weekdays=[]))
            + try_fx("DIA_FUERA_DE_RANGO", SER, **s(3, weekdays=[7]))
            + try_fx("DOMINGO_Y_SABADO", SER, **s(4, weekdays=[0, 6]))
            + try_fx("FRANJA_INVERTIDA", SER, **s(5, start_time="14:00", end_time="08:00"))
            + try_fx("VIGENCIA_INVERTIDA", SER, **s(6, valid_to="2026-10-01"))
            + try_fx("LIBERACION_NEGATIVA", SER, **s(7, release_hours=-1))
            + try_fx("SERVICIO_SIN_DUENO", SER, **s(8, clinical_unit_id=None))
            + try_fx("CIRUJANO_SIN_PERFIL", SER, **s(9, owner_kind_concept_id=pg.ORB_OWNER_SURGEON, clinical_unit_id=None))
            + try_fx("CIRUJANO", SER, **s(10, owner_kind_concept_id=pg.ORB_OWNER_SURGEON, clinical_unit_id=None, surgeon_profile_id=pg.SURGEON)))
        for label in ("VALIDA", "DOMINGO_Y_SABADO", "CIRUJANO"):
            expect(self, r, label, "OK")
        expect(self, r, "SIN_DIAS", "23514", "ck_operating_room_block_series_schedule")
        expect(self, r, "DIA_FUERA_DE_RANGO", "23514", "ck_operating_room_block_series_schedule")
        expect(self, r, "FRANJA_INVERTIDA", "23514", "ck_operating_room_block_series_schedule")
        expect(self, r, "VIGENCIA_INVERTIDA", "23514", "ck_operating_room_block_series_schedule")
        expect(self, r, "LIBERACION_NEGATIVA", "23514", "ck_operating_room_block_series_schedule")
        expect(self, r, "SERVICIO_SIN_DUENO", "23514", "ck_operating_room_block_series_owner")
        expect(self, r, "CIRUJANO_SIN_PERFIL", "23514", "ck_operating_room_block_series_owner")

    def test_room_site_and_series_room_coherence_and_tenant_isolation(self) -> None:
        r = pg.scenario(
            ins(SER, **series_cols(u("4", 1)))
            + ins(SER, **series_cols(u("4", 9), tenant=pg.T_B, site=pg.SITE_B1, room=pg.OR_B1, clinical_unit_id=pg.UNIT_B1))
            + try_fx("SALA_DE_OTRA_SEDE", SER, **series_cols(u("4", 2), room=pg.OR_A_SITE2))
            + try_fx("SALA_DE_OTRA_SEDE_PERO_SEDE_CORRECTA", SER, **series_cols(u("4", 3), room=pg.OR_A_SITE2, site=pg.SITE_A2))
            + try_fx("BLOQUE_CON_SALA_DISTINTA_A_LA_SERIE", BLK, **block_cols(u("3", 1), room=pg.OR_A2, series_id=u("4", 1)))
            + try_fx("BLOQUE_DE_LA_SERIE", BLK, **block_cols(u("3", 2), series_id=u("4", 1)))
            + try_fx("SERIE_AJENA_CON_TRIGGER", BLK, **block_cols(u("3", 3), room=pg.OR_B1, tenant=pg.T_B, clinical_unit_id=pg.UNIT_B1, series_id=u("4", 1)))
            # sin el trigger de coherencia, la FK compuesta sola ya impide una serie de otro tenant
            + f"ALTER TABLE {BLK} DISABLE TRIGGER trg_or_blocks_series_room;"
            + try_fx("SERIE_AJENA", BLK, **block_cols(u("3", 8), start="2026-11-10 08:00+00", end="2026-11-10 14:00+00", series_id=u("4", 9)))
            + try_fx("SALA_AJENA_EN_BLOQUE", BLK, **block_cols(u("3", 4), room=pg.OR_B1))
            + try_fx("UNIDAD_AJENA_EN_BLOQUE", BLK, **block_cols(u("3", 5), start="2026-11-11 08:00+00", end="2026-11-11 14:00+00", clinical_unit_id=pg.UNIT_B1))
            + try_fx("SEDE_AJENA_EN_SERIE_CON_TRIGGER", SER, **series_cols(u("4", 6), site=pg.SITE_B1))
            + f"ALTER TABLE {SER} DISABLE TRIGGER trg_or_block_series_room_site;"
            + try_fx("SEDE_AJENA_EN_SERIE", SER, **series_cols(u("4", 6), site=pg.SITE_B1))
            + try_fx("UNIDAD_AJENA_EN_SERIE", SER, **series_cols(u("4", 7), clinical_unit_id=pg.UNIT_B1)))
        expect(self, r, "SALA_DE_OTRA_SEDE", "23503", "no pertenece a la sede")
        expect(self, r, "SALA_DE_OTRA_SEDE_PERO_SEDE_CORRECTA", "OK")
        expect(self, r, "BLOQUE_CON_SALA_DISTINTA_A_LA_SERIE", "23503", "usa el quirófano de la serie")
        expect(self, r, "BLOQUE_DE_LA_SERIE", "OK")
        expect(self, r, "SERIE_AJENA_CON_TRIGGER", "23503")
        expect(self, r, "SERIE_AJENA", "23503", "fk_or_blocks_tenant_series")
        expect(self, r, "SALA_AJENA_EN_BLOQUE", "23503", "fk_or_blocks_tenant_room")
        expect(self, r, "UNIDAD_AJENA_EN_BLOQUE", "23503", "fk_or_blocks_tenant_unit")
        expect(self, r, "SEDE_AJENA_EN_SERIE_CON_TRIGGER", "23503")
        expect(self, r, "SEDE_AJENA_EN_SERIE", "23503", "fk_or_block_series_tenant_site")
        expect(self, r, "UNIDAD_AJENA_EN_SERIE", "23503", "fk_or_block_series_tenant_unit")


@unittest.skipUnless(DB, SKIP_REASON)
class UtilizationEventAndChecklistTests(unittest.TestCase):
    def test_event_tenant_is_filled_from_the_room_and_references_stay_in_the_tenant(self) -> None:
        ev = dict(operating_room_id=pg.OR_A1, event_type_concept_id=pg.CONCEPT_EVENT, occurred_at="2026-11-02 08:05+00")
        r = pg.scenario(
            case(u("2", 1), pg.OR_A1, "2026-11-02 08:00+00", "2026-11-02 10:00+00")
            + ins(BLK, **block_cols(u("3", 1)))
            + pg.try_("SIN_TENANT", f"INSERT INTO {EV} (id, operating_room_id, event_type_concept_id, occurred_at, created_at) "
                                    f"VALUES ('{u('5', 1)}', '{pg.OR_A1}', '{pg.CONCEPT_EVENT}', now(), now())")
            + f"SELECT 'T|' || tenant_id FROM {EV};"
            + try_fx("CASO_PROPIO_Y_BLOQUE_PROPIO", EV, id=u("5", 2), tenant_id=pg.T_A, procedure_case_id=u("2", 1), operating_room_block_id=u("3", 1), **ev)
            + try_fx("SALA_AJENA", EV, id=u("5", 3), tenant_id=pg.T_A, **{**ev, "operating_room_id": pg.OR_B1})
            + try_fx("CASO_AJENO", EV, id=u("5", 4), tenant_id=pg.T_B, procedure_case_id=u("2", 1), **{**ev, "operating_room_id": pg.OR_B1})
            + try_fx("BLOQUE_AJENO", EV, id=u("5", 5), tenant_id=pg.T_B, operating_room_block_id=u("3", 1), **{**ev, "operating_room_id": pg.OR_B1})
            + pg.try_("TENANT_EXPLICITAMENTE_NULO", f"INSERT INTO {EV} (id, tenant_id, operating_room_id, event_type_concept_id, occurred_at, created_at) "
                                                    f"VALUES ('{u('5', 6)}', NULL, '{pg.OR_B1}', '{pg.CONCEPT_EVENT}', now(), now())"))
        expect(self, r, "SIN_TENANT", "OK")
        self.assertIn(f"T|{pg.T_A}", r.out)
        expect(self, r, "CASO_PROPIO_Y_BLOQUE_PROPIO", "OK")
        expect(self, r, "SALA_AJENA", "23503", "fk_or_utilization_events_tenant_room")
        expect(self, r, "CASO_AJENO", "23503", "fk_or_utilization_events_tenant_case")
        expect(self, r, "BLOQUE_AJENO", "23503", "fk_or_utilization_events_tenant_block")
        expect(self, r, "TENANT_EXPLICITAMENTE_NULO", "OK")     # NULL explícito: lo completa el trigger desde la sala

    def test_one_checklist_per_type_and_phases_in_order(self) -> None:
        def chk(i, ctype=pg.CONCEPT_CHK_ENTRY, version="2009", **kw):
            return dict(id=u("6", i), procedure_case_id=u("2", 1), checklist_type_concept_id=ctype,
                        checklist_version=version, status_concept_id=pg.CONCEPT_OTHER, **kw)
        r = pg.scenario(
            case(u("2", 1), pg.OR_A1, "2026-11-02 08:00+00", "2026-11-02 10:00+00")
            + ins(CHK, **chk(1))
            + try_fx("OTRA_VERSION_DEL_MISMO_TIPO", CHK, **chk(2, version="2010"))
            + try_fx("OTRO_TIPO", CHK, **chk(3, ctype=pg.CONCEPT_CHK_PAUSE))
            + try_fx("PAUSA_SIN_ENTRADA", CHK, **chk(4, ctype=pg.CONCEPT_OTHER, time_out_completed_at="2026-11-02 08:30+00"))
            + try_fx("SALIDA_SIN_PAUSA", CHK, **chk(5, ctype=pg.CASE_READY, sign_in_completed_at="2026-11-02 08:00+00", sign_out_completed_at="2026-11-02 09:50+00"))
            + try_fx("TRES_FASES", CHK, **chk(6, ctype=pg.CASE_CANCELLED, sign_in_completed_at="2026-11-02 08:00+00",
                                              time_out_completed_at="2026-11-02 08:30+00", sign_out_completed_at="2026-11-02 09:50+00")))
        expect(self, r, "OTRA_VERSION_DEL_MISMO_TIPO", "23505", "ux_surgical_safety_checklists_case_type")
        expect(self, r, "OTRO_TIPO", "OK")
        expect(self, r, "PAUSA_SIN_ENTRADA", "23514", "ck_surgical_safety_checklists_phase_order")
        expect(self, r, "SALIDA_SIN_PAUSA", "23514", "ck_surgical_safety_checklists_phase_order")
        expect(self, r, "TRES_FASES", "OK")


@unittest.skipUnless(DB, SKIP_REASON)
class RowLevelSecurityTests(unittest.TestCase):
    """Las tablas con tenant_id nuevas aíslan por tenant para el rol de aplicación (sin BYPASSRLS)."""

    PREP = (ins(SER, **series_cols(u("4", 1))) + ins(SER, **series_cols(u("4", 2), tenant=pg.T_B, site=pg.SITE_B1, room=pg.OR_B1, clinical_unit_id=pg.UNIT_B1))
            + ins(BLK, **block_cols(u("3", 1))) + ins(BLK, **block_cols(u("3", 2), tenant=pg.T_B, room=pg.OR_B1, clinical_unit_id=pg.UNIT_B1))
            + ins(EV, id=u("5", 1), tenant_id=pg.T_A, operating_room_id=pg.OR_A1, event_type_concept_id=pg.CONCEPT_EVENT, occurred_at="2026-11-02 08:05+00")
            + ins(EV, id=u("5", 2), tenant_id=pg.T_B, operating_room_id=pg.OR_B1, event_type_concept_id=pg.CONCEPT_EVENT, occurred_at="2026-11-02 08:05+00")
            + ins(BLKH, history_id=u("7", 1), operating_room_block_id=u("3", 1), tenant_id=pg.T_A, revision_no=1, operation_concept_id=pg.CONCEPT_OTHER, data_snapshot={})
            + ins(BLKH, history_id=u("7", 2), operating_room_block_id=u("3", 2), tenant_id=pg.T_B, revision_no=1, operation_concept_id=pg.CONCEPT_OTHER, data_snapshot={}))

    def counts(self, tenant: str | None, *, system: bool = False) -> dict[str, int]:
        ctx = (f"SELECT set_config('app.current_tenant_id', '{tenant}', true);" if tenant else "")
        sysctx = "SELECT set_config('app.system_context', 'true', true);" if system else "SELECT set_config('app.system_context', 'false', true);"
        sel = " ".join(f"SELECT 'C|{n}|' || count(*) FROM {t};" for n, t in
                       (("series", SER), ("blocks", BLK), ("events", EV), ("history", BLKH)))
        r = pg.scenario(self.PREP + "SET LOCAL ROLE mantra_app;" + ctx + sysctx + sel)
        self.assertEqual(r.rc, 0, r.err)
        return {l.split("|")[1]: int(l.split("|")[2]) for l in r.out.splitlines() if l.startswith("C|")}

    def test_each_tenant_sees_only_its_own_rows(self) -> None:
        self.assertEqual(self.counts(pg.T_A), {"series": 1, "blocks": 1, "events": 1, "history": 1})
        self.assertEqual(self.counts(pg.T_B), {"series": 1, "blocks": 1, "events": 1, "history": 1})

    def test_no_tenant_context_fails_closed_and_system_context_sees_everything(self) -> None:
        self.assertEqual(self.counts(None), {"series": 0, "blocks": 0, "events": 0, "history": 0})
        self.assertEqual(self.counts(None, system=True), {"series": 2, "blocks": 2, "events": 2, "history": 2})

    def test_cross_tenant_writes_and_reads_by_id_are_blocked(self) -> None:
        stmt_insert = (f"INSERT INTO {BLK} (id, tenant_id, operating_room_id, owner_kind_concept_id, clinical_unit_id, starts_at, ends_at, release_at, "
                       f"status_concept_id, created_at, updated_at, row_version) VALUES ('{u('3', 9)}', '{pg.T_B}', '{pg.OR_B1}', '{pg.ORB_OWNER_SERVICE}', "
                       f"'{pg.UNIT_B1}', now(), now() + interval '1 hour', now(), '{pg.ORB_ACTIVE}', now(), now(), 1)")
        r = pg.scenario(
            self.PREP + as_app(pg.T_A)
            + pg.try_("INSERTAR_EN_OTRO_TENANT", stmt_insert)
            + pg.try_("LEER_POR_ID_AJENO", f"DO $q$ BEGIN IF EXISTS (SELECT 1 FROM {BLK} WHERE id = '{u('3', 2)}') THEN RAISE EXCEPTION 'visible'; END IF; END $q$")
            + f"WITH u AS (UPDATE {BLK} SET release_reason = 'x' WHERE id = '{u('3', 2)}' RETURNING 1) SELECT 'U|' || count(*) FROM u;"
            + f"WITH d AS (DELETE FROM {EV} WHERE id = '{u('5', 2)}' RETURNING 1) SELECT 'D|' || count(*) FROM d;")
        expect(self, r, "INSERTAR_EN_OTRO_TENANT", "42501")
        expect(self, r, "LEER_POR_ID_AJENO", "OK")
        self.assertIn("U|0", r.out)
        self.assertIn("D|0", r.out)

    def test_history_is_insert_only_for_the_application_role(self) -> None:
        r = pg.scenario(
            self.PREP + as_app(pg.T_A)
            + pg.try_("INSERTAR_SIN_TENANT", f"INSERT INTO {BLKH} (history_id, operating_room_block_id, revision_no, operation_concept_id, valid_from, data_snapshot, recorded_at) "
                                             f"VALUES ('{u('7', 3)}', '{u('3', 1)}', 2, '{pg.CONCEPT_OTHER}', now(), '{{}}', now())")
            + f"SELECT 'T|' || tenant_id FROM {BLKH} WHERE history_id = '{u('7', 3)}';"
            + pg.try_("UPDATE_GENERAL", f"UPDATE {BLKH} SET revision_no = 9 WHERE history_id = '{u('7', 1)}'")
            + pg.try_("DELETE", f"DELETE FROM {BLKH} WHERE history_id = '{u('7', 1)}'")
            + pg.try_("TRUNCATE", f"TRUNCATE {BLKH}")
            + pg.try_("CERRAR_VALID_TO", f"UPDATE {BLKH} SET valid_to = now() WHERE history_id = '{u('7', 1)}'")
            + pg.try_("CERRAR_OTRA_VEZ", f"UPDATE {BLKH} SET valid_to = now() + interval '1 day' WHERE history_id = '{u('7', 1)}'")
            + pg.try_("HISTORIA_DE_SERIE_UPDATE", f"UPDATE {SERH} SET revision_no = 9"))
        expect(self, r, "INSERTAR_SIN_TENANT", "OK")
        self.assertIn(f"T|{pg.T_A}", r.out)
        expect(self, r, "UPDATE_GENERAL", "42501")
        expect(self, r, "DELETE", "42501")
        expect(self, r, "TRUNCATE", "42501")
        expect(self, r, "CERRAR_VALID_TO", "OK")
        expect(self, r, "CERRAR_OTRA_VEZ", "23001")
        expect(self, r, "HISTORIA_DE_SERIE_UPDATE", "42501")

    def test_the_owner_cannot_rewrite_or_delete_history_either(self) -> None:
        r = pg.scenario(
            self.PREP
            + pg.try_("OWNER_DELETE", f"DELETE FROM {BLKH} WHERE history_id = '{u('7', 1)}'")
            + pg.try_("OWNER_UPDATE", f"UPDATE {BLKH} SET revision_no = 9 WHERE history_id = '{u('7', 1)}'")
            + pg.try_("OWNER_CIERRA_VALID_TO", f"UPDATE {BLKH} SET valid_to = now() WHERE history_id = '{u('7', 1)}'"))
        expect(self, r, "OWNER_DELETE", "23001")
        expect(self, r, "OWNER_UPDATE", "23001")
        expect(self, r, "OWNER_CIERRA_VALID_TO", "OK")


@unittest.skipUnless(DB, SKIP_REASON)
class PatchReplayTests(unittest.TestCase):
    """Los patches se pueden aplicar N veces y abortan —sin dejar nada a medias— ante datos incompatibles."""

    SCHED = pg.strip_tx(pg.PATCH_SCHEDULING.read_text(encoding="utf-8")) if DB else ""
    PERIOP = pg.strip_tx(pg.PATCH_PERIOP.read_text(encoding="utf-8")) if DB else ""

    def abort(self, setup: str, patch: str, fragment: str, errcode: str | None = None) -> None:
        r = pg.scenario(setup + "\n" + patch + "\nSELECT 'LLEGO_AL_FINAL';")
        self.assertNotEqual(r.rc, 0, "el patch debía abortar y terminó bien")
        self.assertIn(fragment, r.err)
        self.assertNotIn("LLEGO_AL_FINAL", r.out)

    def test_second_and_third_pass_change_nothing(self) -> None:
        snap = pg.SNAPSHOT_SQL.strip().rstrip(";")
        r = pg.scenario(
            f"CREATE TEMP TABLE s0 AS SELECT * FROM ({snap}) q(x);\n"
            + self.SCHED + "\n" + self.PERIOP + "\n" + self.SCHED + "\n" + self.PERIOP + "\n"
            + f"CREATE TEMP TABLE s1 AS SELECT * FROM ({snap}) q(x);\n"
            + "SELECT 'DIFF|' || count(*) FROM (SELECT * FROM s0 EXCEPT SELECT * FROM s1) d;"
            + "SELECT 'CATEGORIAS|' || count(*) FROM s1;", fixture=False)
        self.assertEqual(r.rc, 0, r.err)
        self.assertIn("DIFF|0", r.out)
        self.assertIn("CATEGORIAS|7", r.out)

    def test_overlap_that_only_appears_with_prep_and_cleanup_aborts_the_patch(self) -> None:
        setup = ("ALTER TABLE " + PC + " DROP CONSTRAINT ex_procedure_cases_operating_room_reserved_time;\n"
                 + case(u("2", 1), pg.OR_A1, "2026-11-02 08:00+00", "2026-11-02 10:00+00")
                 + case(u("2", 2), pg.OR_A1, "2026-11-02 10:10+00", "2026-11-02 11:00+00"))
        self.abort(setup, self.PERIOP, "solapan su ventana reservada")

    def test_references_to_another_tenant_abort_the_patch(self) -> None:
        setup = ("ALTER TABLE " + PC + " DROP CONSTRAINT fk_procedure_cases_tenant_operating_room;\n"
                 + case(u("2", 1), pg.OR_B1, "2026-11-02 08:00+00", "2026-11-02 10:00+00"))
        self.abort(setup, self.PERIOP, "OTRO tenant")

    def test_a_checklist_duplicated_by_type_or_out_of_order_aborts_the_patch(self) -> None:
        base = case(u("2", 1), pg.OR_A1, "2026-11-02 08:00+00", "2026-11-02 10:00+00")
        mk = lambda i, v, **kw: ins(CHK, id=u("6", i), procedure_case_id=u("2", 1), checklist_type_concept_id=pg.CONCEPT_CHK_ENTRY,
                                    checklist_version=v, status_concept_id=pg.CONCEPT_OTHER, **kw)
        self.abort("DROP INDEX procedures_perioperative.ux_surgical_safety_checklists_case_type;\n" + base + mk(1, "2009") + mk(2, "2010"),
                   self.PERIOP, "más de un check-list del mismo tipo")
        self.abort("ALTER TABLE " + CHK + " DROP CONSTRAINT ck_surgical_safety_checklists_phase_order;\n" + base
                   + mk(1, "2009", time_out_completed_at="2026-11-02 08:30+00"), self.PERIOP, "fases fuera de orden")

    def test_two_active_resources_for_one_space_abort_the_scheduling_patch(self) -> None:
        setup = ("DROP INDEX scheduling.ux_schedulable_resources_care_space_active;\n"
                 + ins(RES, **resource_cols(u("1", 1), pg.OR_A1)) + ins(RES, **resource_cols(u("1", 2), pg.OR_A1)))
        self.abort(setup, self.SCHED, "más de un recurso agendable ACTIVO")

    def test_unresolvable_room_resources_are_listed_not_touched(self) -> None:
        setup = ("ALTER TABLE " + RES + " DROP CONSTRAINT ck_schedulable_resources_care_space_ref;\n"
                 + ins(RES, **resource_cols(u("1", 1), None, ref_id="99999999-0000-4000-8000-000000000009"))     # espacio inexistente
                 + ins(RES, **resource_cols(u("1", 2), None, ref_id=pg.OR_B1))                                      # espacio de otro tenant
                 + ins(RES, **resource_cols(u("1", 3), None, ref_id=pg.OR_A2, ref_type="practice.care_spaces"))     # alias resoluble
                 + ins(RES, **resource_cols(u("1", 4), None, ref_id=pg.SURGEON, ref_type="health_practitioner_profiles")))  # no es de espacios
        r = pg.scenario(setup + "\n" + self.SCHED + "\n"
                        + f"SELECT 'R|' || right(id::text, 1) || '|' || coalesce(right(care_space_id::text, 2), '-') || '|' || resource_ref_type FROM {RES} ORDER BY id;"
                        + "SELECT 'V|' || convalidated FROM pg_constraint WHERE conname = 'ck_schedulable_resources_care_space_ref';")
        self.assertEqual(r.rc, 0, r.err)
        rows = {l.split("|")[1]: l.split("|")[2:] for l in r.out.splitlines() if l.startswith("R|")}
        self.assertEqual(rows["1"], ["-", "care_spaces"])
        self.assertEqual(rows["2"], ["-", "care_spaces"])
        self.assertEqual(rows["3"], ["c2", "care_spaces"])     # alias → canónico y con FK
        self.assertEqual(rows["4"], ["-", "health_practitioner_profiles"])
        self.assertIn("V|false", r.out)                          # NOT VALID mientras queden heredadas sin resolver
        avisos = " ".join(r.notices())
        self.assertIn("el espacio no existe", avisos)
        self.assertIn("el espacio es de otro tenant", avisos)

    def test_missing_prerequisites_are_reported_by_name(self) -> None:
        self.abort("DROP FUNCTION audit.structure_history_fill_tenant() CASCADE;\n", self.PERIOP, "audit.structure_history_fill_tenant()")
        self.abort("DROP INDEX scheduling.ux_schedulable_resources_tenant_id_id CASCADE;\n",
                   self.PERIOP, "ux_schedulable_resources_tenant_id_id")


if __name__ == "__main__":
    unittest.main()
