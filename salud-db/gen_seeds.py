# -*- coding: utf-8 -*-
"""
gen_seeds.py — Actualiza el paquete `seedsGenerales/` al modelo SALUD v4.0.9.

Se llamaba `gen_seeds_v407.py` hasta v4.0.9 (2026-08-05). El sufijo venía de la
versión del modelo en que se escribió y llevaba tres versiones mintiendo, así que
se retiró: ahora nombra lo que hace, como el resto de los generadores
(`gen_ddl.py`, `gen_entities.py`, `gen_integrity.py`, `gen_nosql.py`,
`gen_apply.py`). Ojo: `MODEL_VERSION` sigue —y debe seguir— en 4.0.7; eso no es
deuda, ver el comentario junto a la constante.

Determinista e idempotente: re-ejecutarlo sobre su propia salida no cambia nada.
La verdad de columnas/tipos/NOT NULL sale del DDL generado (`SQL/<NN>_<schema>/02_tables.sql`),
que a su vez sale de los `.puml`; los códigos de los value sets salen de las notas del vault.
No inventa columnas ni destinos: si un dato no está en esas fuentes, no se emite.

Qué hace (cada fase es independiente e idempotente):

  1. VALUE SETS   — siembra los 33 value sets de los patches v4.0.2–v4.0.6 en el módulo 03
                    (value_sets → value_set_versions → catalog_concepts → concept_designations
                    → value_set_members) y los registra como enums dinámicos en el módulo 45.
  1b.PUENTE       — espeja en el paquete el catálogo de conceptos que el backend materializa
                    al arrancar (TerminologySeedService, namespace propio) y el tenant DEFAULT:
                    las tablas v4.0.8 referencian esos ids y los servicios comparan contra ellos.
  2. TABLAS NUEVAS— boot/mock para las 24 tablas de los patches v4.0.2–v4.0.6 y las 5 de
                    v4.0.8 (ALOVIDA), resolviendo los *_concept_id contra los conceptos
                    sembrados y las FK contra filas del paquete. Incluye la política D-05
                    de firma de recetas (una comodín `signature_required=true` por tenant).
  3. NOT NULL     — rellena columnas NOT NULL sin default ausentes en filas ya existentes
                    (defecto que hacía que `load_seeds.py` saltara grupos enteros de filas y
                    dejara hijas huérfanas → FKs sin crear), y corrige los valores que
                    PostgreSQL rechazaría por tipo.
  3c.VALUE SETS   — reasigna los `*_concept_id` que apuntan fuera del value set que los ata
                    (binding del modelo); las columnas sin binding declarado no se tocan.
  4. UNIQUE       — desambigua claves naturales que colisionan entre boot y mock (mismo `code`
                    con id distinto: el ON CONFLICT DO NOTHING descartaba la fila mock en
                    silencio y sus hijas quedaban huérfanas).
  5. METADATOS    — source_model_version → 4.0.7, record_count/summary, load_order,
                    entity_seed_policies, seed-manifest.json y checksums.json.

Uso:  python salud-db/gen_seeds.py [--dry] [--only <fase>]
      fases: valuesets | backend | tables | notnull | bindings | unique | meta   (por defecto: todas)
"""
from __future__ import annotations

import argparse
import hashlib
import json
import re
import sys
import unicodedata
import uuid
from collections import Counter, OrderedDict
from datetime import datetime, timedelta, timezone
from pathlib import Path

import paths

# `ROOT` es el repositorio del modelo; la bóveda es hermana suya. Ver `paths.py`.
ROOT = paths.MODEL_ROOT
SQL_DIR = paths.SQL_DIR
SEEDS_DIR = paths.SEEDS_DIR
MODULES_DIR = paths.SEEDS_MODULES_DIR
VAULT = paths.VAULT

# MODEL_VERSION entra en la derivación uuid5 de todas las filas ya vivas en la BD:
# NO cambiarla. La versión que el paquete declara hacia afuera es SOURCE_MODEL_VERSION.
# Que diga 4.0.7 con el modelo en 4.0.9 no es un descuido: es el namespace con el que
# se derivaron los ids que la base ya tiene, y moverlo los cambiaría todos.
MODEL_VERSION = "4.0.7"
SOURCE_MODEL_VERSION = "4.0.9"
RELEASE_LABEL = "4.0.9"
SEED_REVISION = "2.6.0-v4.2.30"
# Namespace uuid5 por patch, misma regla que MODEL_VERSION: identifica las filas de las
# 5 tablas ALOVIDA ya sembradas. v4.0.9 no añade uno propio porque no trae tablas que
# sembrar — `iam.email_verifications` y `iam.password_resets` guardan tokens de runtime
# y nacen vacías a propósito.
PATCH_V408 = "4.0.8"
# v4.0.11 — namespace de las filas que nacen con el saneo de la demo (el catálogo de
# laboratorios del módulo 23 y su práctica). Las filas anteriores conservan el suyo.
PATCH_V4011 = "4.0.11"
# v4.1.4 — namespace de las aseguradoras reales que reemplazan a las 12 demo del
# módulo 26 (y de sus tenants, NIT y direcciones). Las filas anteriores conservan el suyo.
PATCH_V414 = "4.1.4"
PATCH_V416 = "4.1.6"   # farmacias reales + su ficha pública
# Directorio oficial de salud de Bolivia (AGEMED 2026, RUES 2026, Overture Places):
# namespace de los uuid5 de sus filas, que van al paquete BOOT.
PATCH_DIRECTORIO = "directorio-oficial-2026-10"

# Mismo namespace que seedsGenerales/tools/generate-deep-seeds.py::stable_uuid.
# El concepto FREE ya insertado en la BD viva se deriva con este esquema:
#   SALUD|4.0.5|boot|42|terminology.catalog_concepts|vs_subscription_plan_tier|FREE
#   → f845c4f2-3f92-5a97-b76b-30f71c0cb43c
NAMESPACE = uuid.UUID("9e475ed5-d2a0-40db-b9ea-319a67158d7a")

# Universo de conceptos del backend (mantra-core-health-api/src/common/constants/concepts.ts,
# SALUD_UUID_NAMESPACE). El runtime deriva sus ids con este namespace y los materializa al
# arrancar (TerminologySeedService, insert-if-missing por id); los servicios comparan los
# `*_concept_id` contra ESOS ids, así que las filas v4.0.8 deben usar exactamente los mismos.
BACKEND_NAMESPACE = uuid.UUID("3f2b6c14-9d5e-5a41-b7c2-0a1e9f4d8b60")


def backend_id(key: str) -> str:
    """Id determinista del backend — espejo de `deterministicId()` de concepts.ts."""
    return str(uuid.uuid5(BACKEND_NAMESPACE, key))

# Anclas del catálogo boot de terminología (módulo 03, ya sembradas).
CODE_SYSTEM_ID = "6750d75b-a410-53a3-8f25-dd1619bad333"           # SALUD_CORE
CODE_SYSTEM_VERSION_ID = "4cbf27de-95c0-5fac-831a-9be6d26cd74c"   # SALUD_CORE 1.0.0
CONCEPT_ACTIVE = "d0f53ea3-7e50-5578-add3-270341b1186c"           # ACTIVE (state raíz)
SEED_USER_ID = "499d0869-90ee-5cdd-9b26-3c32c8518193"             # usuario boot de atribución
LANGUAGE_CONCEPT_ID = "4535601f-316b-52a0-a068-bcc832910077"
DESIGNATION_TYPE_CONCEPT_ID = "1115f950-d892-5413-8019-e6234e2dbac5"
JURISDICTION_CONCEPT_ID = "68c85767-41c5-5734-b220-e7cbd99395f3"

BOOT_BASE = datetime(2026, 7, 24, 8, 0, tzinfo=timezone.utc)
MOCK_BASE = datetime(2026, 7, 24, 12, 0, tzinfo=timezone.utc)

# --- value set → (patch, módulo dueño) -------------------------------------
# El módulo es el que declara el patch como dueño funcional; entra en la derivación
# del uuid5, así que fijarlo mal cambiaría ids ya insertados en la BD.
VS_OWNER = {
    "vs_prestige_award_direction": ("4.0.2", "19"),
    "vs_prestige_award_reason": ("4.0.2", "19"),
    "vs_prestige_level": ("4.0.2", "19"),
    "vs_feedback_category": ("4.0.2", "19"),
    "vs_feedback_severity": ("4.0.2", "19"),
    "vs_feedback_status": ("4.0.2", "19"),
    "vs_feedback_channel": ("4.0.2", "19"),
    "vs_absence_type": ("4.0.2", "41"),
    "vs_absence_approval_status": ("4.0.2", "41"),
    "vs_affiliation_document_type": ("4.0.3", "04"),
    "vs_issuing_authority": ("4.0.3", "04"),
    "vs_affiliation_document_verification_status": ("4.0.3", "04"),
    "vs_partition_strategy": ("4.0.4", "11"),
    "vs_partition_interval": ("4.0.4", "11"),
    "vs_archive_target": ("4.0.4", "11"),
    "vs_legal_representative_role": ("4.0.4", "04"),
    "vs_subscription_plan_tier": ("4.0.5", "42"),
    "vs_plan_feature_key": ("4.0.5", "42"),
    "vs_plan_quota_metric": ("4.0.5", "42"),
    "vs_quota_period": ("4.0.5", "42"),
    "vs_overage_policy": ("4.0.5", "42"),
    "vs_api_key_scope": ("4.0.6", "01"),
    "vs_lockout_reason": ("4.0.6", "01"),
    "vs_break_glass_reason": ("4.0.6", "06"),
    "vs_break_glass_review_outcome": ("4.0.6", "06"),
    "vs_ip_rule_type": ("4.0.6", "06"),
    "vs_key_purpose": ("4.0.6", "11"),
    "vs_encryption_algorithm": ("4.0.6", "11"),
    "vs_key_rotation_event": ("4.0.6", "11"),
    "vs_security_incident_severity": ("4.0.6", "11"),
    "vs_security_incident_category": ("4.0.6", "11"),
    "vs_security_incident_status": ("4.0.6", "11"),
    "vs_breach_regulation": ("4.0.6", "11"),
    # v4.0.11 — el catálogo de especialidades médicas que la Guía usa para agrupar.
    # Dueño funcional: el módulo 05, que declara `practitioner_specialties`.
    "vs_medical_specialty": ("4.0.11", "05"),
    # v4.1.4 — los 9 departamentos de Bolivia: la «extensión» de expedición del
    # carnet (SC, LP…) capturada como dato informativo del registro, y el catálogo
    # que addresses.administrative_area_concept_id nunca tuvo. Dueño funcional: el
    # módulo 02, que declara `identifiers`.
    "vs_administrative_area": ("4.1.4", "02"),
    # v4.1.5 — los 340 municipios, el nivel de detalle que `city` (texto libre)
    # no puede garantizar consistente. Mismo dueño: el módulo 02 declara
    # `addresses`. Sus etiquetas NO están en VS_DISPLAY de más abajo: son 340 y
    # salen del padrón (ver `municipios_display`).
    "vs_bo_municipality": ("4.1.5", "02"),
}

# --- display curado por value set -----------------------------------------
# Por defecto el display de un concepto es `titleize(code)`, y los códigos son
# slugs ASCII (`cardiologia`), así que la etiqueta sale sin tildes. Para los sets
# que el paciente LEE eso no alcanza: la Guía agrupa por especialidad y muestra
# este texto. Acá se declara la forma correcta en castellano; lo no declarado
# sigue saliendo por `titleize` y los otros 33 sets no cambian un byte.
VS_DISPLAY = {
    "vs_medical_specialty": {
        "medicina_general": "Medicina General",
        "medicina_familiar": "Medicina Familiar",
        "medicina_interna": "Medicina Interna",
        "pediatria": "Pediatría",
        "ginecologia_obstetricia": "Ginecología y Obstetricia",
        "cardiologia": "Cardiología",
        "neurologia": "Neurología",
        "dermatologia": "Dermatología",
        "endocrinologia": "Endocrinología",
        "gastroenterologia": "Gastroenterología",
        "neumologia": "Neumología",
        "nefrologia": "Nefrología",
        "urologia": "Urología",
        "traumatologia": "Traumatología y Ortopedia",
        "cirugia_general": "Cirugía General",
        "oftalmologia": "Oftalmología",
        "otorrinolaringologia": "Otorrinolaringología",
        "psiquiatria": "Psiquiatría",
        "psicologia_clinica": "Psicología Clínica",
        "oncologia": "Oncología",
        "hematologia": "Hematología",
        "reumatologia": "Reumatología",
        "infectologia": "Infectología",
        "geriatria": "Geriatría",
        "anestesiologia": "Anestesiología",
        "radiologia": "Radiología e Imagenología",
        "patologia_clinica": "Patología Clínica",
        "medicina_emergencia": "Medicina de Emergencia",
        "medicina_intensiva": "Medicina Intensiva",
        "nutricion": "Nutrición y Dietética",
        "odontologia": "Odontología",
        "fisioterapia": "Fisioterapia y Rehabilitación",
        "enfermeria": "Enfermería",
        "bioquimica_clinica": "Bioquímica Clínica",
        "obstetricia": "Obstetricia",
        "medicina_deportiva": "Medicina Deportiva",
        # --- 18 del SNRM (Ministerio de Salud y Deportes, listado de residencia
        #     médica 2022). Se declaran acá porque `titleize` no pone tildes y
        #     «Anatomia Patologica» no es castellano.
        "anatomia_patologica": "Anatomía Patológica",
        "cirugia_bucomaxilofacial": "Cirugía Bucomaxilofacial",
        "cirugia_pediatrica": "Cirugía Pediátrica",
        "medicina_del_trabajo": "Medicina del Trabajo",
        "medicina_fisica_rehabilitacion": "Medicina Física y Rehabilitación",
        "salud_familiar_comunitaria_intercultural": "Salud Familiar Comunitaria Intercultural",
        "cirugia_oncologica": "Cirugía Oncológica",
        "coloproctologia": "Coloproctología",
        "cardiologia_pediatrica": "Cardiología Pediátrica",
        "infectologia_pediatrica": "Infectología Pediátrica",
        "medicina_del_dolor": "Medicina del Dolor",
        "medicina_materno_fetal": "Medicina Materno Fetal",
        "neonatologia": "Neonatología",
        "neurologia_pediatrica": "Neurología Pediátrica",
        "oncologia_ginecologica": "Oncología Ginecológica",
        "oncologia_pediatrica": "Oncología Pediátrica",
        "ortopedia_pediatrica": "Ortopedia Pediátrica",
        "terapia_intensiva_pediatrica": "Terapia Intensiva Pediátrica",
        # --- 9 odontológicas, del listado del stakeholder del 2026-08-27.
        "endodoncia": "Endodoncia",
        "ortodoncia": "Ortodoncia",
        "periodoncia": "Periodoncia",
        "estetica_dental": "Estética Dental",
        "rehabilitacion_oral": "Rehabilitación Oral",
        "cirugia_oral_maxilofacial": "Cirugía Oral y Maxilofacial",
        "odontopediatria": "Odontopediatría",
        "implantologia_oral": "Implantología Oral",
        "armonizacion_orofacial": "Armonización Orofacial",
    },
    # Los códigos son las siglas de expedición que imprime el carnet (SEGIP);
    # sin este mapa, titleize() produciría «Sc», que no le dice nada a nadie.
    "vs_administrative_area": {
        "sc": "Santa Cruz",
        "lp": "La Paz",
        "cb": "Cochabamba",
        "or": "Oruro",
        "pt": "Potosí",
        "tj": "Tarija",
        "be": "Beni",
        "pa": "Pando",
        "ch": "Chuquisaca",
    },
    # Subtarea 1.2 (2026-09-10): el certificado del SEDES entra a los dos value sets
    # de v4.0.3 que el autorregistro público de organización necesitaba completos.
    # `titleize()` ya producía "Certificado Sedes"/"Sedes" — correcto pero sin la
    # sigla en mayúsculas que usa el resto del dominio salud.
    "vs_affiliation_document_type": {
        "certificado_sedes": "Certificado del SEDES",
        # v4.2.29 (cierre M7): el PDF de radioprotección de imagenología (D-BR09-1).
        "certificado_radioproteccion": "Certificado de radioprotección",
    },
    "vs_issuing_authority": {
        "sedes": "SEDES",
    },
    # Subtarea 1.4 (2026-09-11): las dos gerencias de contacto que el registro de
    # procesos pide junto al representante legal (ASEGURADORA 1.9-1.17). El conjunto
    # sólo nombraba la general; `titleize()` daría "Gerente Marketing", y el rótulo
    # del dominio lleva la preposición.
    "vs_legal_representative_role": {
        "gerente_comercial": "Gerente Comercial",
        "gerente_marketing": "Gerente de Marketing",
    },
}


def municipios_display() -> dict:
    """
    Las etiquetas de los 340 municipios, derivadas del padrón.

    No van escritas en `VS_DISPLAY` como las demás por dos razones. Son 340
    —el value set más grande del modelo tenía 38—, y sobre todo `titleize()` no
    puede reconstruirlas desde el slug: «Nuestra Señora de La Paz» no sale de
    `lp-nuestra_senora_de_la_paz`, porque el slug perdió las tildes y las
    minúsculas de «de».

    El código es `<sigla>-<slug>` y no el nombre solo porque **seis municipios
    se llaman igual en departamentos distintos** (El Puente, Entre Ríos, San
    Javier, San Lorenzo, San Pedro, San Ramón). A esos doce la etiqueta les
    agrega el departamento entre paréntesis: en un desplegable sin filtrar, dos
    «El Puente» a secas son indistinguibles.

    La fuente es `salud-db/data/bo-territorio.json`, el mismo archivo del que se
    derivó la lista de códigos de la nota del vault — y con **esta misma
    función**, que es lo que garantiza que ambas listas coincidan.
    """
    padron = json.loads(
        (ROOT / "salud-db" / "data" / "bo-territorio.json").read_text(encoding="utf-8")
    )
    filas = [
        (dep["departamento"], mun)
        for dep in padron
        for prov in dep["provincias"]
        for mun in prov["municipios"]
    ]
    repetidos = {m for m, n in Counter(m for _, m in filas).items() if n > 1}
    sigla = {v: k for k, v in VS_DISPLAY["vs_administrative_area"].items()}
    out = {}
    for departamento, municipio in filas:
        code = f"{sigla[departamento]}-{slugify(municipio).lower()}"
        out[code] = f"{municipio} ({departamento})" if municipio in repetidos else municipio
    if len(out) != len(filas):
        sys.exit(
            f"padrón: {len(filas)} municipios pero {len(out)} códigos — hay colisión de slug"
        )
    return out


def vs_display(vs_name: str, code: str) -> str:
    """Etiqueta visible de un valor: la curada si existe, si no `titleize`."""
    return VS_DISPLAY.get(vs_name, {}).get(code) or titleize(code)

# --- las 24 tablas nuevas: módulo, sección y value set por columna ----------
# section: "boot" = catálogo/configuración segura en producción · "mock" = dev/test.
NEW_TABLES = OrderedDict([
    # (schema, tabla): dict(module, section, rows, vs={col: vs_name}, notes)
    ("payments.plan_prices", dict(module="42", schema="payments", section="boot")),
    ("payments.plan_features", dict(module="42", schema="payments", section="boot",
                                    vs={"feature_concept_id": "vs_plan_feature_key"})),
    ("payments.plan_quotas", dict(module="42", schema="payments", section="boot",
                                  vs={"metric_concept_id": "vs_plan_quota_metric",
                                      "quota_period_concept_id": "vs_quota_period",
                                      "overage_policy_concept_id": "vs_overage_policy"})),
    ("payments.plan_eligibility_rules", dict(module="42", schema="payments", section="boot")),
    ("payments.subscription_usage_counters", dict(module="42", schema="payments", section="mock",
                                                  vs={"metric_concept_id": "vs_plan_quota_metric"})),
    ("system_ops.partition_specs", dict(module="11", schema="system_ops", section="boot",
                                        vs={"partition_strategy_concept_id": "vs_partition_strategy",
                                            "partition_interval_concept_id": "vs_partition_interval",
                                            "archive_target_concept_id": "vs_archive_target"})),
    ("system_ops.encryption_keys", dict(module="11", schema="system_ops", section="boot",
                                        vs={"key_purpose_concept_id": "vs_key_purpose",
                                            "algorithm_concept_id": "vs_encryption_algorithm"})),
    ("system_ops.key_rotation_events", dict(module="11", schema="system_ops", section="mock",
                                            vs={"event_type_concept_id": "vs_key_rotation_event"})),
    ("system_ops.security_incidents", dict(module="11", schema="system_ops", section="mock",
                                           vs={"severity_concept_id": "vs_security_incident_severity",
                                               "category_concept_id": "vs_security_incident_category",
                                               "status_concept_id": "vs_security_incident_status"})),
    ("system_ops.breach_notifications", dict(module="11", schema="system_ops", section="mock",
                                             vs={"regulation_concept_id": "vs_breach_regulation"})),
    ("directory.tenant_web_configs", dict(module="04", schema="directory", section="boot")),
    ("directory.tenant_affiliation_documents", dict(module="04", schema="directory", section="mock",
                                                    vs={"document_type_concept_id": "vs_affiliation_document_type",
                                                        "issuing_authority_concept_id": "vs_issuing_authority",
                                                        "verification_status_concept_id": "vs_affiliation_document_verification_status"})),
    ("directory.tenant_legal_representatives", dict(module="04", schema="directory", section="mock",
                                                    vs={"representative_role_concept_id": "vs_legal_representative_role"})),
    ("authz.ip_access_rules", dict(module="06", schema="authz", section="boot",
                                   vs={"rule_type_concept_id": "vs_ip_rule_type"})),
    ("authz.break_glass_sessions", dict(module="06", schema="authz", section="mock",
                                        vs={"reason_concept_id": "vs_break_glass_reason",
                                            "review_outcome_concept_id": "vs_break_glass_review_outcome"})),
    ("iam.api_keys", dict(module="01", schema="iam", section="mock")),
    ("iam.api_key_scopes", dict(module="01", schema="iam", section="mock",
                                vs={"scope_concept_id": "vs_api_key_scope"})),
    ("iam.account_lockouts", dict(module="01", schema="iam", section="mock",
                                  vs={"reason_concept_id": "vs_lockout_reason"})),
    ("community.prestige_awards", dict(module="19", schema="community", section="mock",
                                       vs={"direction_concept_id": "vs_prestige_award_direction",
                                           "reason_concept_id": "vs_prestige_award_reason"})),
    ("community.prestige_scores", dict(module="19", schema="community", section="mock",
                                       vs={"level_concept_id": "vs_prestige_level"})),
    ("community.feedback_tickets", dict(module="19", schema="community", section="mock",
                                        vs={"category_concept_id": "vs_feedback_category",
                                            "severity_concept_id": "vs_feedback_severity",
                                            "channel_concept_id": "vs_feedback_channel",
                                            "status_concept_id": "vs_feedback_status"})),
    ("community.feedback_ticket_comments", dict(module="19", schema="community", section="mock")),
    ("community.feedback_ticket_events", dict(module="19", schema="community", section="mock",
                                              vs={"from_status_concept_id": "vs_feedback_status",
                                                  "to_status_concept_id": "vs_feedback_status"})),
    ("scheduling.calendar_absences", dict(module="41", schema="scheduling", section="mock",
                                          vs={"absence_type_concept_id": "vs_absence_type",
                                              "approval_status_concept_id": "vs_absence_approval_status"})),
])

# --- espejo del catálogo de conceptos del backend (v4.0.8) ------------------
# Copia TEXTUAL de concepts.ts / authz.concepts.ts / scheduling.concepts.ts.
# Regla de `code` (TerminologySeedService): los conceptos centrales guardan su código
# FHIR; los de módulo guardan la CLAVE completa, porque catalog_concepts tiene
# UNIQUE (code_system_version_id, code) y varios módulos repiten códigos genéricos.
BACKEND_CONCEPTS = [
    # (clave de derivación, code almacenado, display)
    ("state:active", "ACTIVE", "Active"),
    ("state:pending", "PENDING", "Pending"),
    ("directory:tenant-type:provider", "PROVIDER", "Healthcare provider"),
    ("directory:legal-entity:company", "COMPANY", "Company"),
    # v4.2.21 · la forma societaria real de las aseguradoras (quince de las
    # diecisiete son S.A.) y el estado «sin verificar» con el que nace toda
    # organización que sale de un listado público. Los dos se derivan igual que
    # en el backend (`CONCEPTS.LEGAL_ENTITY_SA`, `DIR.TENANT_UNVERIFIED`); sin
    # espejarlos acá, la fase 2b los reemplazaba por basura.
    ("directory:legal-entity:sa", "SA", "Corporation (S.A.)"),
    # v4.2.22 · lo que necesita una persona de contacto: su tipo de documento,
    # los tres sistemas de contacto y el uso «trabajo». Van acá y no como
    # conceptos del paquete porque el backend ya los acuña con estas claves y
    # los servicios comparan por id (`CONCEPTS.CONTACT_EMAIL`, …).
    ("common:owner-type:person", "OWNER_PERSON", "Person"),
    ("common:id-type:national", "NATIONAL_ID", "National ID"),
    ("common:contact-system:email", "EMAIL", "Email"),
    ("common:contact-system:mobile", "MOBILE", "Mobile phone"),
    ("common:contact-system:phone", "PHONE", "Phone"),
    ("common:contact-use:work", "WORK", "Work"),
    ("profiles:PERSON_ACTIVE", "PERSON_ACTIVE", "Person active"),
    ("directory:TENANT_UNVERIFIED", "DIR_TENANT_UNVERIFIED", "Tenant unverified"),
    ("directory:tenant-status:active", "TENANT_ACTIVE", "Tenant active"),
    ("directory:tenant-verification:verified", "TENANT_VERIFIED", "Tenant verified"),
    ("authz:CARE_REL_TREATING", "authz:CARE_REL_TREATING",
     "Treating practitioner relationship"),
    ("authz:CARE_REL_CONSULTING", "authz:CARE_REL_CONSULTING",
     "Consulting practitioner relationship"),
    ("authz:CARE_REL_EMERGENCY", "authz:CARE_REL_EMERGENCY",
     "Emergency care relationship"),
    ("authz:REPRESENTATION_LEGAL_GUARDIAN", "authz:REPRESENTATION_LEGAL_GUARDIAN",
     "Legal guardian representation"),
    ("authz:REPRESENTATION_PARENT", "authz:REPRESENTATION_PARENT",
     "Parental representation"),
    ("authz:REPRESENTATION_ATTORNEY", "authz:REPRESENTATION_ATTORNEY",
     "Attorney-in-fact (apoderado) representation"),
    ("authz:REPRESENTATION_CURATOR", "authz:REPRESENTATION_CURATOR",
     "Curator representation"),
    ("scheduling:RULE_SCOPE_TENANT", "scheduling:RULE_SCOPE_TENANT",
     "Confirmation rule scope: tenant"),
    ("scheduling:DECISION_AUTO_CONFIRM", "scheduling:DECISION_AUTO_CONFIRM",
     "Auto-confirm booking request"),
    ("scheduling:DECISION_AUTO_REJECT", "scheduling:DECISION_AUTO_REJECT",
     "Auto-reject booking request"),
    ("scheduling:DECISION_MANUAL_REVIEW", "scheduling:DECISION_MANUAL_REVIEW",
     "Route booking request to manual review"),
    # v4.0.11 — los 3 conceptos que referencia el trío de correo de MessagingSeedService
    # (canal EMAIL + proveedor DEFAULT_EMAIL + su config). Son centrales (CONCEPT_DEFS,
    # no MODULE_CONCEPT_SEEDS), así que el code almacenado es el def.code, no la clave.
    ("messaging:channel-type:email", "CHANNEL_EMAIL", "Email channel"),
    ("messaging:provider-type:email", "MSG_PROV_EMAIL", "Email messaging provider"),
    ("messaging:tracking-mode:none", "MSG_TRACK_NONE", "No delivery tracking"),
    # v4.0.11 (bis) — el canal IN_APP tiene el mismo bug que tenía EMAIL, una fila
    # más allá: sus dos conceptos también deben derivarse con la clave del backend,
    # o la fase 2b repuntaría los `*_concept_id` del espejo a un concepto al azar.
    ("messaging:channel-type:in-app", "CHANNEL_IN_APP", "In-app channel"),
    ("messaging:provider-type:in-app", "MSG_PROV_IN_APP", "In-app messaging provider"),
    # v4.1.4 — los conceptos centrales que referencian las aseguradoras reales del
    # builder canónico: el tenant tipo PAYER y el NIT como identificador oficial del
    # tenant. `common:id-type:tax` nace en la API en el mismo cambio (concepts.ts);
    # los otros tres ya existían allá y solo faltaban en el espejo.
    ("directory:tenant-type:payer", "PAYER", "Insurance payer / carrier"),
    ("common:owner-type:tenant", "OWNER_TENANT", "Tenant"),
    ("common:id-type:tax", "TAX_ID", "Tax identification number"),
    ("common:use:official", "OFFICIAL", "Official"),
]

# --- v4.2.29 · catálogos del cierre M7 (CL-25 y jurisdicciones) ---------------
# Conceptos de módulo (chart y profiles): el `code` almacenado es la CLAVE completa, como
# hace TerminologySeedService. Los tres primeros de cada catálogo YA existen en la API
# (`chart.concepts.ts`, `profiles.concepts.ts`); los demás nacen acá con la clave y el
# display en inglés que la API debe declarar tal cual para que los ids coincidan (misma
# regla que SURVEYS_BACKEND_CONCEPTS: ambos lados insertan por id).
# (clave, display en inglés, display en castellano, es_por_defecto)
M7_CATALOGS = [
    {
        "vs": "vs_care_plan_intent", "module": "15",
        "name": "Intención del plan de cuidados",
        "description": ("Qué clase de plan es (`chart.care_plans.intent_concept_id`). Subconjunto "
                        "de CarePlan.intent de HL7 FHIR R4 (request-intent): proposal, plan, order, option."),
        "bindings": [("chart", "care_plans", "intent_concept_id")],
        "concepts": [
            ("chart:CAREPLAN_INTENT_PLAN", "Care plan intent: plan", "Plan", True),
            ("chart:CAREPLAN_INTENT_PROPOSAL", "Care plan intent: proposal", "Propuesta", False),
            ("chart:CAREPLAN_INTENT_ORDER", "Care plan intent: order", "Indicación", False),
            ("chart:CAREPLAN_INTENT_OPTION", "Care plan intent: option", "Opción", False),
        ],
    },
    {
        "vs": "vs_care_plan_activity", "module": "15",
        "name": "Clase de actividad del plan de cuidados",
        "description": ("Qué clase de paso es (`chart.care_plan_activities.activity_concept_id`). "
                        "Lista de producto tomada de las pantallas del plan de cuidados (control, estudio, "
                        "tratamiento, educación, derivación) más la clase general que la API ya usaba por defecto."),
        "bindings": [("chart", "care_plan_activities", "activity_concept_id")],
        "concepts": [
            ("chart:ACTIVITY_DEFAULT", "General care plan activity", "Actividad general", True),
            ("chart:ACTIVITY_CLASS_CONTROL", "Care plan activity: clinical follow-up", "Control clínico", False),
            ("chart:ACTIVITY_CLASS_STUDY", "Care plan activity: study or laboratory", "Estudio o laboratorio", False),
            ("chart:ACTIVITY_CLASS_TREATMENT", "Care plan activity: treatment", "Tratamiento", False),
            ("chart:ACTIVITY_CLASS_EDUCATION", "Care plan activity: patient education", "Educación de la persona", False),
            ("chart:ACTIVITY_CLASS_REFERRAL", "Care plan activity: referral", "Derivación", False),
        ],
    },
    {
        "vs": "vs_document_category", "module": "15",
        "name": "Categoría documental",
        "description": ("Qué clase de papel es (`chart.document_records.category_concept_id`). Lista de "
                        "producto tomada de las pantallas de documentos del expediente más la categoría "
                        "general que la API ya usaba por defecto."),
        "bindings": [("chart", "document_records", "category_concept_id")],
        "concepts": [
            ("chart:DOC_CATEGORY_GENERAL", "General document category", "Documento general", True),
            ("chart:DOC_CATEGORY_REPORT", "Document category: clinical report", "Informe clínico", False),
            ("chart:DOC_CATEGORY_LAB", "Document category: laboratory result", "Resultado de laboratorio", False),
            ("chart:DOC_CATEGORY_IMAGING", "Document category: imaging study", "Estudio de imagen", False),
            ("chart:DOC_CATEGORY_CONSENT", "Document category: informed consent", "Consentimiento informado", False),
            ("chart:DOC_CATEGORY_CERTIFICATE", "Document category: certificate", "Certificado", False),
            ("chart:DOC_CATEGORY_DISCHARGE", "Document category: discharge summary", "Epicrisis o alta", False),
        ],
    },
]


# --- v4.0.11 · los 40 conceptos del módulo 23 -------------------------------
# Espejo literal de `src/modules/diagnostic_units/diagnostic_units.concepts.ts`. Van con la
# regla de los conceptos de módulo, que no es la de los centrales: el `code` almacenado es
# la CLAVE (`diagnostic_units:UNIT_ACTIVE`), no el código humano (`DU_UNIT_ACTIVE`), porque
# `catalog_concepts` tiene UNIQUE(code_system_version_id, code) y varios módulos declaran
# códigos genéricos que chocarían. Los servicios comparan por id (`DUNIT.*`), y ese id sale
# de la clave — por eso el catálogo del paquete tiene que derivarlo igual o el laboratorio
# sembrado queda invisible para su propia lectura.
DIAGNOSTIC_UNITS_BACKEND_CONCEPTS = [
    (key, key, display) for key, display in [
        ("diagnostic_units:UNIT_TYPE_LABORATORY", "Clinical laboratory unit"),
        ("diagnostic_units:UNIT_TYPE_IMAGING", "Diagnostic imaging unit"),
        ("diagnostic_units:OWNERSHIP_PRIVATE", "Privately owned unit"),
        ("diagnostic_units:VERIFICATION_PENDING", "Verification pending"),
        ("diagnostic_units:VERIFICATION_VERIFIED", "Verification verified"),
        ("diagnostic_units:UNIT_ACTIVE", "Diagnostic unit active"),
        ("diagnostic_units:UNIT_RETIRED", "Diagnostic unit retired"),
        ("diagnostic_units:SITE_ROLE_PRIMARY", "Primary operative site"),
        ("diagnostic_units:SITE_ROLE_COLLECTION", "Sample collection site"),
        ("diagnostic_units:SITE_ACTIVE", "Diagnostic unit site active"),
        ("diagnostic_units:SPECIALTY_PATHOLOGY", "Clinical pathology specialty"),
        ("diagnostic_units:STUDY_GENERIC", "Generic diagnostic study"),
        ("diagnostic_units:STUDY_COMPLETE_BLOOD_COUNT", "Complete blood count"),
        ("diagnostic_units:STUDY_GLUCOSE", "Blood glucose test"),
        ("diagnostic_units:STUDY_PCR", "C-reactive protein test"),
        ("diagnostic_units:STUDY_CHEST_XRAY", "Chest X-ray"),
        ("diagnostic_units:STUDY_ABDOMINAL_ULTRASOUND", "Abdominal ultrasound"),
        ("diagnostic_units:MODALITY_LABORATORY", "Laboratory modality"),
        ("diagnostic_units:MODALITY_XRAY", "X-ray modality"),
        ("diagnostic_units:MODALITY_ULTRASOUND", "Ultrasound modality"),
        ("diagnostic_units:COMPONENT_ROLE_PANEL", "Panel component role"),
        ("diagnostic_units:OFFERING_DRAFT", "Study offering draft"),
        ("diagnostic_units:OFFERING_ACTIVE", "Study offering active"),
        ("diagnostic_units:OFFERING_RETIRED", "Study offering retired"),
        ("diagnostic_units:PRICE_SCHEDULE_STANDARD", "Standard public price schedule"),
        ("diagnostic_units:PRICE_SCHEDULE_INSURER", "Insurer price schedule"),
        ("diagnostic_units:CURRENCY_PEN", "Peruvian sol"),
        ("diagnostic_units:CURRENCY_BOB", "Boliviano"),
        ("diagnostic_units:SCHEDULE_ACTIVE", "Price schedule active"),
        ("diagnostic_units:PRICE_ACTIVE", "Study price active"),
        ("diagnostic_units:PRICE_SUPERSEDED", "Study price superseded"),
        ("diagnostic_units:PRICE_RETIRED", "Study price retired"),
        ("diagnostic_units:ACCREDITATION_ISO15189", "ISO 15189 accreditation"),
        ("diagnostic_units:EQUIPMENT_TYPE_ANALYZER", "Automated analyzer equipment"),
        ("diagnostic_units:EQUIPMENT_TYPE_XRAY", "Digital X-ray equipment"),
        ("diagnostic_units:EQUIPMENT_TYPE_ULTRASOUND", "Ultrasound equipment"),
        ("diagnostic_units:EQUIPMENT_OPERATIONAL", "Equipment operational"),
        ("diagnostic_units:EQUIPMENT_MAINTENANCE", "Equipment under maintenance"),
        ("diagnostic_units:ASSIGNMENT_ROLE_SPECIALIST", "Specialist assignment role"),
        ("diagnostic_units:ASSIGNMENT_ACTIVE", "Practitioner assignment active"),
    ]
]
# v4.1.6 · los cinco tipos de ficha pública (community.concepts.ts).
#
# Sin espejarlos acá, cualquier fila del paquete que declare el tipo real de una
# ficha —«esto es una farmacia»— queda con una FK a un concepto que el paquete no
# tiene, y la fase 2b la «repara» apuntándola a un concepto genérico al azar. Es
# lo que le pasaba a las 16 fichas de demostración: nacían con
# `DEFAULT_TARGET_TYPE` y por eso el buscador público no podía clasificar
# ninguna, y devolvía cero en las cinco verticales.
COMMUNITY_PROFILE_TARGET_CONCEPTS = [
    ("community:PROFILE_TARGET_USER", "PROFILE_TARGET_USER", "User public profile"),
    ("community:PROFILE_TARGET_PRACTITIONER", "PROFILE_TARGET_PRACTITIONER",
     "Practitioner public profile"),
    ("community:PROFILE_TARGET_ORGANIZATION", "PROFILE_TARGET_ORGANIZATION",
     "Organization public profile"),
    ("community:PROFILE_TARGET_PHARMACY", "PROFILE_TARGET_PHARMACY",
     "Pharmacy public profile"),
    ("community:PROFILE_TARGET_DIAGNOSTIC_UNIT", "PROFILE_TARGET_DIAGNOSTIC_UNIT",
     "Diagnostic unit public profile"),
    ("community:PROFILE_TARGET_INSURER", "PROFILE_TARGET_INSURER",
     "Insurer public profile"),
    # La visibilidad va en el mismo puente y por el mismo motivo: sin espejarla,
    # la fase 2b repara la FK contra un concepto al azar y la ficha deja de ser
    # pública sin que nadie lo note.
    ("community:PROFILE_VISIBILITY_PUBLIC", "PROFILE_VISIBILITY_PUBLIC",
     "Profile listed on the public directory"),
]

BACKEND_CONCEPTS += COMMUNITY_PROFILE_TARGET_CONCEPTS
BACKEND_CONCEPTS += DIAGNOSTIC_UNITS_BACKEND_CONCEPTS

# --- directorio oficial · conceptos de módulo que sus filas BOOT referencian -----
# Misma regla que los del módulo 23 (code = la CLAVE; los servicios comparan por id).
# Displays literales de `directory.concepts.ts` y `pharmacy.concepts.ts`. Sin el
# espejo, la FK diferida a `catalog_concepts` rechaza la fila al cargar en una base
# donde la app todavía no arrancó.
DIRECTORIO_BACKEND_CONCEPTS = [
    (key, key, display) for key, display in [
        ("directory:TENANT_REGISTRY_LISTED", "Tenant listed in official registry"),
        ("pharmacy:PHARMACY_TYPE_RETAIL", "Retail pharmacy"),
        ("pharmacy:OWNERSHIP_PRIVATE", "Private ownership"),
        ("pharmacy:VERIFICATION_VERIFIED", "Verification verified"),
        ("pharmacy:PHARMACY_ACTIVE", "Pharmacy active"),
        ("pharmacy:LICENSE_TYPE_OPERATING", "Operating license"),
    ]
]
BACKEND_CONCEPTS += DIRECTORIO_BACKEND_CONCEPTS

# --- v4.1.4 · conceptos del módulo 26 usados por aseguradoras y pedidos vinculados ---
# Misma regla que los del módulo 23: el `code` almacenado es la CLAVE de derivación
# (`insurance:VERIFY_VERIFIED`, el NOMBRE de la propiedad en insurance.concepts.ts,
# no su código humano `VERIFICATION_VERIFIED`), porque el id sale de esa clave y los
# servicios comparan por id (`INS.*`).
INSURANCE_BACKEND_CONCEPTS = [
    (key, key, display) for key, display in [
        ("insurance:CARRIER_ACTIVE", "Aseguradora activa"),
        ("insurance:VERIFY_VERIFIED", "Verificado"),
        # v4.2.21: sin él, las 17 aseguradoras del listado —que nacen PENDIENTES,
        # porque nadie presentó documentación— quedaban con un `*_concept_id` que
        # el paquete no conocía, y la fase 2b lo «reparaba» hacia un concepto al
        # azar: se vieron municipios (Cochabamba, Quime) como estado de verificación.
        ("insurance:VERIFY_PENDING", "Verificación pendiente"),
        ("insurance:BILLING_PROVIDER_TYPE_PHARMACY", "Facturador: farmacia"),
        ("insurance:BILLING_PROVIDER_TYPE_DIAGNOSTIC_UNIT", "Facturador: unidad diagnóstica"),
        ("insurance:ELIG_PROVIDER_TYPE_PHARMACY", "Solicitante: farmacia"),
        ("insurance:ELIG_PROVIDER_TYPE_DIAGNOSTIC_UNIT", "Solicitante: unidad diagnóstica"),
    ]
]
BACKEND_CONCEPTS += INSURANCE_BACKEND_CONCEPTS

# Anclas del catálogo del backend (SEED de concepts.ts) — mismos ids y literales.
BACKEND_SEED = dict(
    source_id=backend_id("seed:source:mantra-core"),
    source_code="MANTRA_CORE",
    code_system_id=backend_id("seed:code-system:mantra-core"),
    code_system_internal_code="mantra-core-internal",
    canonical_url="https://mantracore.health/fhir/CodeSystem/internal",
    csv_id=backend_id("seed:code-system-version:mantra-core:1.0.0"),
    version="1.0.0",
    tenant_id=backend_id("seed:tenant:default"),
    tenant_code="DEFAULT",
)

# --- las 5 tablas de la promoción ALOVIDA v4.0.8 -----------------------------
# Claves extra sobre el formato de NEW_TABLES:
#   patch   — deriva la PK bajo su propio patch (las de v4.0.7 siguen intactas).
#   fixed   — overrides constantes (conceptos del backend, NULL explícitos).
#   choices — el valor se elige determinista entre ids del backend.
#   custom  — la puebla un builder canónico, no el bucle genérico.
# El orden importa: patient_legal_representations entra al índice de ids antes de
# que account_activations resuelva su FK nullable legal_representation_id.
NEW_TABLES_V408 = OrderedDict([
    ("authz.care_relationships", dict(
        module="06", schema="authz", section="mock", patch=PATCH_V408,
        fixed={"status_concept_id": backend_id("state:active"),
               "purpose_concept_id": None},
        choices={"relationship_type_concept_id": [
            backend_id("authz:CARE_REL_TREATING"),
            backend_id("authz:CARE_REL_CONSULTING"),
            backend_id("authz:CARE_REL_EMERGENCY")]})),
    ("authz.patient_legal_representations", dict(
        module="06", schema="authz", section="mock", patch=PATCH_V408,
        fixed={"status_concept_id": backend_id("state:active")},
        choices={"representation_type_concept_id": [
            backend_id("authz:REPRESENTATION_LEGAL_GUARDIAN"),
            backend_id("authz:REPRESENTATION_PARENT"),
            backend_id("authz:REPRESENTATION_ATTORNEY"),
            backend_id("authz:REPRESENTATION_CURATOR")]})),
    ("clinical.prescription_signature_policies", dict(
        module="08", schema="clinical", section="boot", custom=True)),
    ("scheduling.booking_confirmation_rules", dict(
        module="41", schema="scheduling", section="mock", patch=PATCH_V408,
        fixed={"scope_type_concept_id": backend_id("scheduling:RULE_SCOPE_TENANT"),
               "scope_id": None, "version": 1, "enabled": True,
               # Forma reconocible por evalCondition() del motor C-11 (hoja field/op/value).
               "condition_json": {"field": "channel", "op": "eq", "value": "PORTAL"}},
        choices={"decision_concept_id": [
            backend_id("scheduling:DECISION_AUTO_CONFIRM"),
            backend_id("scheduling:DECISION_AUTO_REJECT"),
            backend_id("scheduling:DECISION_MANUAL_REVIEW")]})),
    ("iam.account_activations", dict(
        module="01", schema="iam", section="mock", patch=PATCH_V408,
        fixed={"state_concept_id": backend_id("state:pending"),
               "consumed_at": None})),
])
NEW_TABLES.update(NEW_TABLES_V408)

# Catálogo de planes (Arquitectura/subscription-plans-catalog.md). limit None = ilimitado.
PLAN_CATALOG = OrderedDict([
    ("FREE", dict(name="Free", tier="free", is_default=True, monthly=0, yearly=0,
                  features=[], quotas={"profesionales_activos": 2, "citas_por_mes": 100,
                                       "pacientes_activos": 300, "almacenamiento_gb": 1})),
    ("PRO", dict(name="PRO", tier="pro", is_default=False, monthly=29, yearly=290,
                 features=["multi_sede", "agenda_avanzada", "analitica_avanzada",
                           "telemedicina", "soporte_prioritario"],
                 quotas={"profesionales_activos": 10, "citas_por_mes": 2000,
                         "pacientes_activos": 5000, "almacenamiento_gb": 20})),
    ("MAX", dict(name="MAX", tier="max", is_default=False, monthly=99, yearly=990,
                 features=["multi_sede", "agenda_avanzada", "analitica_avanzada", "telemedicina",
                           "soporte_prioritario", "asistente_clinico_ia", "acceso_api",
                           "dominio_personalizado"],
                 quotas={"profesionales_activos": None, "citas_por_mes": None,
                         "pacientes_activos": None, "almacenamiento_gb": 200})),
])
QUOTA_PERIOD = {"citas_por_mes": "mensual", "sms_por_mes": "mensual",
                "campanias_por_mes": "mensual", "llamadas_api_por_dia": "mensual"}


# ============================================================ utilidades

def stable_uuid(*parts) -> str:
    return str(uuid.uuid5(NAMESPACE, "|".join(map(str, parts))))


def slugify(text: str) -> str:
    text = unicodedata.normalize("NFKD", text.upper())
    text = "".join(c for c in text if not unicodedata.combining(c))
    return re.sub(r"[^A-Z0-9]+", "_", text).strip("_")[:64] or "ITEM"


def titleize(code: str) -> str:
    return code.replace("_", " ").strip().title()


# Se resuelve acá y no junto al resto de `VS_DISPLAY` porque depende de
# `slugify`, que se define más abajo que aquel bloque.
VS_DISPLAY["vs_bo_municipality"] = municipios_display()


# Jurisdicciones de Bolivia: la nacional y un SEDES (Servicio Departamental de Salud) por
# departamento. Las siglas y los nombres son los de `vs_administrative_area` (los nueve
# departamentos, en el orden del INE), no se escribe ninguno de nuevo. La nacional y
# Santa Cruz ya existen en la API; los otros ocho nacen acá con la misma forma de clave.
M7_JURISDICTION_ORDER = ["ch", "lp", "cb", "or", "pt", "tj", "sc", "be", "pa"]


def m7_jurisdiction_concepts() -> list:
    out = [("profiles:JURISDICTION_NATIONAL", "National jurisdiction", "Nacional", True)]
    for sigla in M7_JURISDICTION_ORDER:
        nombre = VS_DISPLAY["vs_administrative_area"][sigla]
        if sigla == "sc":  # existe en la API con este display: se espeja textual
            out.append(("profiles:JURISDICTION_SEDES_SANTA_CRUZ",
                        "SEDES — Gobernación Autónoma Departamental de Santa Cruz",
                        "SEDES Santa Cruz", False))
        else:
            out.append(("profiles:JURISDICTION_SEDES_" + slugify(nombre),
                        "SEDES — Servicio Departamental de Salud de " + nombre,
                        "SEDES " + nombre, False))
    return out


M7_CATALOGS.append({
    "vs": "vs_bo_jurisdiction", "module": "05",
    "name": "Jurisdicciones de Bolivia",
    "description": ("Ámbito territorial de una habilitación o de una organización "
                    "(`profiles.jurisdiction_authorizations.jurisdiction_concept_id`, "
                    "`directory.tenants.jurisdiction_concept_id`): la nacional y el SEDES de cada uno de "
                    "los nueve departamentos. Sin enum dinámico propio: la API ya publica `jurisdiction`."),
    "bindings": [],
    "enum": False,
    "concepts": m7_jurisdiction_concepts(),
})

# Espejo de los conceptos de esos catálogos en el paquete (los mismos ids de la API).
_M7_MIRRORED = {key for cat in M7_CATALOGS for key, *_ in cat["concepts"]}
BACKEND_CONCEPTS.extend((key, key, display_en)
                        for cat in M7_CATALOGS
                        for key, display_en, _es, _d in cat["concepts"])


def iso(dt: datetime) -> str:
    return dt.strftime("%Y-%m-%dT%H:%M:%SZ")


def det_time(base: datetime, *parts) -> datetime:
    """Instante determinista derivado de las partes (sin azar, reproducible)."""
    h = int(hashlib.sha256("|".join(map(str, parts)).encode()).hexdigest()[:8], 16)
    return base + timedelta(days=h % 90, minutes=(h >> 8) % 1440)


# ============================================================ DDL (verdad de columnas)

CREATE_RE = re.compile(r'CREATE TABLE IF NOT EXISTS "([a-z0-9_]+)"\."([a-z0-9_]+)" \((.*?)\n\);', re.S)
COL_RE = re.compile(r'^\s*"([a-z0-9_]+)"\s+([^,]+?)(\s+NOT NULL)?\s*,?\s*$')


def ddl_files():
    """Los .sql que declaran tablas: SQL/ por módulo + los stores 58/59, que viven en NoSQL/
    (TimescaleDB y pgvector son extensiones de la misma instancia PostgreSQL)."""
    return (sorted(SQL_DIR.glob("[0-9][0-9]_*/02_tables.sql"))
            + sorted((ROOT / "NoSQL").glob("5[89]_*/*.sql")))


def parse_ddl():
    """{schema.tabla: {col: {"type":…, "not_null":bool, "default":bool}}} desde el DDL."""
    tables = {}
    for f in ddl_files():
        for schema, table, body in CREATE_RE.findall(f.read_text(encoding="utf-8")):
            cols = OrderedDict()
            for line in body.split("\n"):
                if line.strip().startswith("CONSTRAINT") or not line.strip():
                    continue
                m = COL_RE.match(line)
                if not m:
                    continue
                ctype = m.group(2).strip().rstrip(",")
                has_default = "DEFAULT" in ctype.upper()
                ctype = re.split(r"\s+DEFAULT\s+", ctype, flags=re.I)[0].strip()
                cols[m.group(1)] = {"type": ctype, "not_null": bool(m.group(3)),
                                    "default": has_default}
            tables[f"{schema}.{table}"] = cols
    return tables


UNIQUE_RE = re.compile(r'CREATE UNIQUE INDEX IF NOT EXISTS "[^"]+" ON "([a-z0-9_]+)"\."([a-z0-9_]+)" \(([^)]*)\)')


def index_files():
    """Los .sql que declaran índices: SQL/ por módulo + los stores 58/59, que los declaran
    junto a sus tablas en NoSQL/. Sin estos últimos, las UK de time_series y vector_rag son
    invisibles para las fases de desambiguación y la carga falla con 23505."""
    return (sorted(SQL_DIR.glob("[0-9][0-9]_*/04_indexes.sql"))
            + sorted((ROOT / "NoSQL").glob("5[89]_*/*.sql")))


def parse_unique():
    """{schema.tabla: [(col, …)]} de los índices UNIQUE del DDL."""
    uks = {}
    for f in index_files():
        for schema, table, cols in UNIQUE_RE.findall(f.read_text(encoding="utf-8")):
            names = tuple(c.strip().strip('"') for c in cols.split(","))
            uks.setdefault(f"{schema}.{table}", []).append(names)
    return uks


# ============================================================ vault (value sets)

VALUES_RE = re.compile(r"##\s*Valores\s*\n```text\n(.*?)\n```", re.S)


def load_value_sets():
    """{vs_name: {"patch":…, "module":…, "codes":[…]}} leyendo las notas del vault."""
    out = OrderedDict()
    # `v4.*` y no `v4.0.*`: desde v4.1.4 hay value sets en patches de la serie 4.1.
    for note in sorted(VAULT.glob("Patch v4.*/Value sets/vs_*.md")):
        name = note.stem
        if name not in VS_OWNER:
            continue
        m = VALUES_RE.search(note.read_text(encoding="utf-8"))
        if not m:
            sys.exit(f"sin bloque '## Valores': {note}")
        codes = [c.strip() for c in m.group(1).replace("\n", " ").split("·") if c.strip()]
        if not codes:
            sys.exit(f"bloque de valores vacío: {note}")
        patch, module = VS_OWNER[name]
        out[name] = {"patch": patch, "module": module, "codes": codes}
    missing = set(VS_OWNER) - set(out)
    if missing:
        sys.exit(f"value sets declarados pero sin nota en el vault: {sorted(missing)}")
    apply_value_set_extensions(out)
    return out


# Valores que el MODELO agrega a un value set cuya nota vive en el vault, sin editar la
# nota (el vault es otro repositorio y otro ciclo de PR). Cada valor va AL FINAL: el orden
# de la lista es el ordinal que se siembra y correrlo movería el de una base ya poblada.
# La nota del vault debe absorber el valor cuando se promueva; `apply_value_set_extensions`
# lo tolera (no duplica) para que ese día no haya que tocar nada acá.
VS_EXTENSIONS_FILE = paths.DATA_DIR / "value-set-extensions.json"


def apply_value_set_extensions(value_sets: dict) -> None:
    """Agrega a `value_sets` los valores declarados en `value-set-extensions.json`."""
    if not VS_EXTENSIONS_FILE.exists():
        return
    ext = json.loads(VS_EXTENSIONS_FILE.read_text(encoding="utf-8"))
    for name, spec in ext.items():
        if name.startswith("_"):
            continue
        if name not in value_sets:
            sys.exit(f"{VS_EXTENSIONS_FILE.name}: extiende {name}, que no existe en el vault")
        vistos = {c.upper() for c in value_sets[name]["codes"]}
        for code in spec["append"]:
            if code.upper() not in vistos:
                value_sets[name]["codes"].append(code)
                vistos.add(code.upper())


def concept_id(vs_name: str, code: str, vs_meta: dict) -> str:
    """Id determinista de un concepto de value set — esquema ya usado por el patch SQL."""
    return stable_uuid("SALUD", vs_meta["patch"], "boot", vs_meta["module"],
                       "terminology.catalog_concepts", vs_name, code.upper())


# ============================================================ E/S del paquete

def module_path(code: str) -> Path:
    hits = sorted(MODULES_DIR.glob(f"{code}_*.seeds.json"))
    if len(hits) != 1:
        sys.exit(f"módulo {code}: {len(hits)} archivos (esperaba 1)")
    return hits[0]


def load_module(code: str) -> dict:
    return json.loads(module_path(code).read_text(encoding="utf-8"))


def save_module(code: str, doc: dict) -> None:
    module_path(code).write_text(
        json.dumps(doc, ensure_ascii=False, indent=2) + "\n", encoding="utf-8", newline="\n")


def upsert_rows(doc: dict, section: str, entity: str, rows: list, pk: str = "id",
                update: bool = False) -> int:
    """Inserta filas nuevas por PK (idempotente) y las registra en load_order.

    Con `update=True` además REESCRIBE las que ya estaban. Hace falta cuando el
    dueño de la fila es un builder canónico y no el bucle genérico: sin eso, un
    cambio en el builder no llega nunca al paquete —la fila ya existe, se salta—
    y el generador queda mintiendo en silencio. Pasó en v4.2.21: el estado de
    verificación de los tenants de aseguradora siguió mostrando el valor viejo
    tras corregirlo en el builder, y sólo se notó comparando contra la base.
    """
    records = doc[section].setdefault("records", {})
    existing = records.setdefault(entity, [])
    seen = {r.get(pk) for r in existing}
    added = [r for r in rows if r.get(pk) not in seen]
    if update:
        por_pk = {r.get(pk): r for r in rows}
        for indice, fila in enumerate(existing):
            reemplazo = por_pk.get(fila.get(pk))
            if reemplazo is not None:
                existing[indice] = reemplazo
    existing.extend(added)
    order = doc[section].setdefault("load_order", [])
    if entity not in order:
        order.append(entity)
    return len(added)


def replace_rows(doc: dict, section: str, entity: str, rows: list) -> int:
    """Sustituye por completo las filas de una entidad y la deja en `load_order`.

    `upsert_rows` no sirve cuando lo que hay que corregir **es** lo que ya está: sólo agrega
    por PK nueva, así que las filas viejas sobrevivirían junto a las nuevas.
    """
    records = doc[section].setdefault("records", {})
    records[entity] = rows
    order = doc[section].setdefault("load_order", [])
    if entity not in order:
        order.append(entity)
    return len(rows)


def drop_rows(doc: dict, section: str, entity: str, pred) -> int:
    """Quita las filas que cumplen `pred`. Devuelve cuántas se fueron.

    Complementa a `upsert_rows`, que sólo agrega: cuando una fila deja de tener
    dueño —porque cambió la clave con la que se derivaba su id— no hay forma de
    que el paquete se corrija solo. Es idempotente: sobre un paquete ya podado
    devuelve 0.
    """
    records = doc[section].setdefault("records", {})
    filas = records.get(entity)
    if not filas:
        return 0
    quedan = [f for f in filas if not pred(f)]
    records[entity] = quedan
    return len(filas) - len(quedan)


def retire_v414_carrier_rows(docs: dict) -> int:
    """Retira del paquete las aseguradoras de v4.1.4 (códigos `ASEG_*`).

    v4.2.21 movió el tenant de cada aseguradora al código y al id de la API, así
    que las filas viejas quedaron huérfanas: mismo NIT, misma compañía, otro
    uuid. Se van con ellas su identificador, su domicilio y su política de firma
    —las únicas cuatro tablas del paquete que las referencian—, comprobado
    recorriendo los 64 módulos.

    Corre ANTES de `build_id_index()` a propósito: si corriera después, el
    generador podría haber colgado una fila nueva de un tenant que está por
    desaparecer.
    """
    viejos = {t["id"] for t in docs["04"]["mock"]["records"].get("tenants", [])
              if str(t.get("code", "")).startswith("ASEG_")}
    if not viejos:
        return 0
    n = drop_rows(docs["04"], "mock", "tenants", lambda f: f["id"] in viejos)
    for modulo, entidad, col in (("02", "identifiers", "owner_id"),
                                 ("02", "addresses", "owner_id"),
                                 ("08", "prescription_signature_policies", "tenant_id")):
        n += drop_rows(docs[modulo], "mock", entidad,
                       lambda f, c=col: f.get(c) in viejos)
    return n


def ensure_policy(doc: dict, entity: str, ddl_cols: dict, pk: str,
                  uniques: list, stereotype: str, boot: bool, mock: bool) -> None:
    pols = doc["boot"].setdefault("entity_seed_policies", [])
    if any(p.get("entity") == entity for p in pols):
        return
    required = [c for c, m in ddl_cols.items() if m["not_null"] and not m["default"]]
    pols.append(OrderedDict([
        ("entity", entity),
        ("stereotype", stereotype),
        ("boot_seeded", boot),
        ("mock_seeded", mock),
        ("rationale", "Entidad incorporada en la materialización v4.0.7 de los patches "
                      "v4.0.2–v4.0.6; campos obligatorios tomados del DDL generado."),
        ("required_fields", required),
        ("unique_fields", sorted({c for u in uniques for c in u})),
        ("primary_key_fields", [pk]),
    ]))


FK_RE = re.compile(
    r'ALTER TABLE "([a-z0-9_]+)"\."([a-z0-9_]+)"\s*\n\s*ADD CONSTRAINT "[^"]+" FOREIGN KEY \("([a-z0-9_]+)"\)\s*\n\s*REFERENCES "([a-z0-9_]+)"\."([a-z0-9_]+)"')


def parse_fks():
    """{schema.tabla: {col: schema.tabla_destino}} desde el DDL aplicado."""
    fks = {}
    for pat in ("[0-9][0-9]_*/03_fk_intra.sql", "[0-9][0-9]_*/90_fk_deferred.sql"):
        for f in sorted(SQL_DIR.glob(pat)):
            text = f.read_text(encoding="utf-8")
            for s, t, col, ds, dt in FK_RE.findall(text):
                fks.setdefault(f"{s}.{t}", {})[col] = f"{ds}.{dt}"
    return fks


PK_RE = re.compile(r'CONSTRAINT "[^"]+" PRIMARY KEY \("([a-z0-9_]+)"\)')


def parse_pks() -> dict:
    """{schema.tabla: columna PK}. Los subtipos CTI usan `profile_id`, no `id`."""
    pks = {}
    for f in ddl_files():
        for schema, table, body in CREATE_RE.findall(f.read_text(encoding="utf-8")):
            m = PK_RE.search(body)
            if m:
                pks[f"{schema}.{table}"] = m.group(1)
    return pks


_PKS = None


def build_id_index(docs: dict) -> dict:
    """{schema.tabla: [ids]} con todas las PKs presentes en el paquete."""
    global _PKS
    if _PKS is None:
        _PKS = parse_pks()
    idx = {}
    for code, doc in docs.items():
        schema = module_path(code).stem.split("_", 1)[1].replace(".seeds", "")
        for section in ("boot", "mock"):
            for entity, rows in doc.get(section, {}).get("records", {}).items():
                key = f"{schema}.{entity}"
                pk = _PKS.get(key, "id")
                bucket = idx.setdefault(key, [])
                for r in rows:
                    v = r.get(pk) or r.get("id") or r.get("history_id")
                    if isinstance(v, str) and re.fullmatch(r"[0-9a-f-]{36}", v):
                        bucket.append(v)
    return idx


def pick(values: list, *seed):
    """Elección determinista y estable de un elemento (sin azar)."""
    if not values:
        return None
    h = int(hashlib.sha256("|".join(map(str, seed)).encode()).hexdigest()[:8], 16)
    return values[h % len(values)]


# Columnas de texto cuyo dominio lo cierra un CHECK del modelo (`05_constraints.sql`): el
# relleno genérico («Tabla · columna 00») viola el CHECK y load_seeds descarta el grupo
# entero de filas. valor por defecto + valores permitidos. `phase_notnull` también
# repara las filas que ya traían un valor fuera del dominio.
COLUMN_LITERALS = {
    "system_ops.restore_test_runs.objective_status":
        ("NOT_MEASURED", {"PASSED", "FAILED", "NOT_MEASURED"}),
}


class ValueFactory:
    """Genera valores deterministas para una columna, respetando tipo y FK del DDL."""

    def __init__(self, ddl, fks, id_index, concepts_by_vs, generic_concepts):
        self.ddl, self.fks, self.id_index = ddl, fks, id_index
        self.concepts_by_vs = concepts_by_vs
        self.generic_concepts = generic_concepts

    def concept_for(self, table, col, vs_map, seed):
        vs_name = (vs_map or {}).get(col)
        if vs_name:
            codes = self.concepts_by_vs[vs_name]
            return pick(codes, table, col, *seed)
        if col in ("status_concept_id", "state_concept_id"):
            return CONCEPT_ACTIVE
        return pick(self.generic_concepts, table, col, *seed)

    def value(self, table, col, meta, vs_map, seed, section):
        ctype = meta["type"].lower()
        literal = COLUMN_LITERALS.get(f"{table}.{col}")
        if literal is not None:
            return literal[0]
        base = BOOT_BASE if section == "boot" else MOCK_BASE
        when = det_time(base, table, col, *seed)

        if col.endswith("_concept_id"):
            return self.concept_for(table, col, vs_map, seed)
        target = self.fks.get(table, {}).get(col)
        if target:
            return pick(self.id_index.get(target, []), table, col, *seed)
        if ctype.endswith("[]"):
            # columnas array: el paquete original traía el escalar suelto ("BO" en un
            # text[]), que PostgreSQL rechaza con 22P02 malformed array literal
            inner = ctype[:-2].strip()
            item = self.value(table, col, {"type": inner}, vs_map, seed, section)
            return [item] if item is not None else []
        mvec = VECTOR_DIM_RE.match(ctype)
        if mvec:
            # pgvector exige exactamente N floats; embedding disperso determinista.
            dim = int(mvec.group(1))
            h = hashlib.sha256("|".join(map(str, (table, col) + seed)).encode()).hexdigest()
            head = [round((int(h[i * 4:i * 4 + 4], 16) % 1000) / 1000, 3) for i in range(4)]
            return head + [0.0] * (dim - len(head))
        if ctype.startswith("uuid"):
            return stable_uuid("SALUD", MODEL_VERSION, section, table, col, *seed)
        if ctype.startswith(("timestamptz", "timestamp")):
            return iso(when)
        if ctype == "date":
            return when.strftime("%Y-%m-%d")
        if ctype.startswith("bool"):
            return True
        if ctype.startswith(("integer", "int", "smallint", "bigint")):
            if col == "row_version":
                return 1
            h = int(hashlib.sha256("|".join(map(str, (table, col) + seed)).encode()).hexdigest()[:6], 16)
            return h % 100 + 1
        if ctype.startswith("numeric"):
            h = int(hashlib.sha256("|".join(map(str, (table, col) + seed)).encode()).hexdigest()[:6], 16)
            return h % 1000
        if ctype.startswith(("jsonb", "json")):
            return {}
        if ctype.startswith("inet"):
            return "203.0.113.10"
        # texto
        if col in ("code", "internal_code", "key_alias", "ticket_number"):
            return f"{slugify(table.split('.')[1])}_{section.upper()}_{seed[0]:02d}"
        if "cidr" in col:
            return "203.0.113.0/24"
        if col == "domain":
            return f"tenant-{seed[0]:02d}.salud.example.invalid"
        if col.endswith("_url") or col == "canonical_url":
            return f"https://salud.example.invalid/{table.split('.')[1]}/{seed[0]:02d}"
        if "hash" in col:
            return hashlib.sha256(f"{table}|{col}|{seed}".encode()).hexdigest()
        if col in ("name", "display", "display_name", "subject", "title"):
            return f"{titleize(table.split('.')[1])} {seed[0]:02d}"
        return f"{titleize(table.split('.')[1])} · {col.replace('_', ' ')} {seed[0]:02d}"

    def row(self, table, section, index, vs_map=None, overrides=None, pk="id"):
        cols = self.ddl[table]
        overrides = overrides or {}
        out = OrderedDict()
        for col, meta in cols.items():
            if col in overrides:
                out[col] = overrides[col]
                continue
            if col == pk:
                out[col] = stable_uuid("SALUD", MODEL_VERSION, section, table, pk, index)
                continue
            # nullable sin valor propio: se omite para que tome el DEFAULT/NULL de la tabla
            if not meta["not_null"] and col not in (vs_map or {}) and col not in (
                    "created_at", "updated_at", "created_by_user_id", "updated_by_user_id"):
                if not self.fks.get(table, {}).get(col):
                    continue
            v = self.value(table, col, meta, vs_map, (index,), section)
            if v is not None:
                out[col] = v
        for stamp in ("created_at", "updated_at", "recorded_at", "occurred_at"):
            if stamp in cols and stamp not in out:
                out[stamp] = iso(det_time(BOOT_BASE if section == "boot" else MOCK_BASE, table, index))
        for who in ("created_by_user_id", "updated_by_user_id", "recorded_by_user_id"):
            if who in cols and who not in out:
                out[who] = SEED_USER_ID
        if "row_version" in cols:
            out["row_version"] = 1
        return out

# ============================================================ fase 1 · value sets

def vs_ids(vs_name: str, meta: dict) -> tuple:
    p, m = meta["patch"], meta["module"]
    return (stable_uuid("SALUD", p, "boot", m, "terminology.value_sets", vs_name),
            stable_uuid("SALUD", p, "boot", m, "terminology.value_set_versions", vs_name))


def csv_id_for(vs_name: str, meta: dict) -> str:
    """Cada value set del patch estrena su propia versión del code system SALUD_CORE.

    `uq_catalog_concepts_version_code` es (code_system_version_id, code) y varios value
    sets comparten códigos — `baja/media/alta/critica` está en vs_feedback_severity y en
    vs_security_incident_severity. Con una versión por value set los códigos canónicos
    del vault se conservan tal cual, sin renombrarlos para esquivar la UK.
    """
    return stable_uuid("SALUD", meta["patch"], "boot", meta["module"],
                       "terminology.code_system_versions", vs_name)


def phase_valuesets(docs: dict, value_sets: dict) -> dict:
    """Siembra los 33 value sets en el módulo 03 y los registra como enums dinámicos en el 45."""
    doc03, doc45 = docs["03"], docs["45"]
    stats = {"value_sets": 0, "conceptos": 0, "miembros": 0, "enums": 0, "bindings": 0}

    vsets, vversions, concepts, designations, members = [], [], [], [], []
    edefs, evers, eopts, ebinds, csvers = [], [], [], [], []

    for vs_name, meta in value_sets.items():
        vs_id, vsv_id = vs_ids(vs_name, meta)
        csv_id = csv_id_for(vs_name, meta)
        t = det_time(BOOT_BASE, vs_name)
        stamp, stamp2 = iso(t), iso(t + timedelta(minutes=20))
        patch_label = "v" + meta["patch"]

        csvers.append(OrderedDict([
            ("id", csv_id), ("code_system_id", CODE_SYSTEM_ID),
            ("version", "1.0.0-" + vs_name), ("published_at", stamp),
            ("valid_from", stamp), ("valid_to", None),
            ("checksum", hashlib.sha256(
                (vs_name + "|" + "|".join(meta["codes"])).encode()).hexdigest()),
            ("is_default", False), ("state_concept_id", CONCEPT_ACTIVE),
            ("created_at", stamp), ("updated_at", stamp2),
            ("created_by_user_id", SEED_USER_ID), ("updated_by_user_id", SEED_USER_ID),
            ("row_version", 1)]))

        vsets.append(OrderedDict([
            ("id", vs_id), ("internal_code", vs_name.upper()),
            ("name", titleize(vs_name[3:])),
            ("canonical_url", "https://salud.example.invalid/fhir/ValueSet/" + vs_name),
            ("description", "Value set del patch {} (módulo {}); {} conceptos gobernados.".format(
                patch_label, meta["module"], len(meta["codes"]))),
            ("jurisdiction_concept_id", JURISDICTION_CONCEPT_ID),
            ("state_concept_id", CONCEPT_ACTIVE),
            ("created_at", stamp), ("updated_at", stamp2),
            ("created_by_user_id", SEED_USER_ID), ("updated_by_user_id", SEED_USER_ID),
            ("row_version", 1)]))

        vversions.append(OrderedDict([
            ("id", vsv_id), ("value_set_id", vs_id), ("version", "1.0.0"),
            ("valid_from", stamp), ("valid_to", None), ("is_default", True),
            ("state_concept_id", CONCEPT_ACTIVE),
            ("created_at", stamp), ("updated_at", stamp2),
            ("created_by_user_id", SEED_USER_ID), ("updated_by_user_id", SEED_USER_ID),
            ("row_version", 1)]))

        for i, code in enumerate(meta["codes"], start=1):
            cid = concept_id(vs_name, code, meta)
            ct = det_time(BOOT_BASE, vs_name, code)
            cs, cs2 = iso(ct), iso(ct + timedelta(minutes=20))
            concepts.append(OrderedDict([
                ("id", cid), ("code_system_version_id", csv_id),
                ("code", code.upper()), ("display", vs_display(vs_name, code)),
                ("definition", "Valor {} del value set {} (patch {}).".format(
                    code, vs_name, patch_label)),
                ("abstract", False), ("selectable", True),
                ("valid_from", cs), ("valid_to", None), ("replaced_by_concept_id", None),
                ("state_concept_id", CONCEPT_ACTIVE),
                ("created_at", cs), ("updated_at", cs2),
                ("created_by_user_id", SEED_USER_ID), ("updated_by_user_id", SEED_USER_ID),
                ("row_version", 1)]))
            designations.append(OrderedDict([
                ("id", stable_uuid("SALUD", meta["patch"], "boot", meta["module"],
                                   "terminology.concept_designations", vs_name, code.upper())),
                ("concept_id", cid), ("language_concept_id", LANGUAGE_CONCEPT_ID),
                ("designation_type_concept_id", DESIGNATION_TYPE_CONCEPT_ID),
                ("value", vs_display(vs_name, code)), ("preferred", True),
                ("created_at", cs), ("updated_at", cs2),
                ("created_by_user_id", SEED_USER_ID), ("updated_by_user_id", SEED_USER_ID),
                ("row_version", 1)]))
            members.append(OrderedDict([
                ("id", stable_uuid("SALUD", meta["patch"], "boot", meta["module"],
                                   "terminology.value_set_members", vs_name, code.upper())),
                ("value_set_version_id", vsv_id), ("concept_id", cid),
                ("included", True), ("ordinal", i),
                ("created_at", cs), ("updated_at", cs2),
                ("created_by_user_id", SEED_USER_ID), ("updated_by_user_id", SEED_USER_ID),
                ("row_version", 1)]))
            eopts.append(OrderedDict([
                ("id", stable_uuid("SALUD", meta["patch"], "boot", meta["module"],
                                   "system_context.dynamic_enum_options", vs_name, code.upper())),
                ("dynamic_enum_version_id", stable_uuid(
                    "SALUD", meta["patch"], "boot", meta["module"],
                    "system_context.dynamic_enum_versions", vs_name)),
                ("concept_id", cid), ("code", code.upper()),
                ("display", vs_display(vs_name, code)),
                ("ordinal", i), ("is_default", i == 1), ("enabled", True),
                ("metadata_json", {"value_set": vs_name, "patch": patch_label}),
                ("recorded_at", cs), ("recorded_by_user_id", SEED_USER_ID)]))

        ed_id = stable_uuid("SALUD", meta["patch"], "boot", meta["module"],
                            "system_context.dynamic_enum_definitions", vs_name)
        edefs.append(OrderedDict([
            ("id", ed_id), ("code", vs_name.upper()), ("name", titleize(vs_name[3:])),
            ("description", "Enum dinámico del value set {} (patch {}).".format(
                vs_name, patch_label)),
            ("value_set_id", vs_id), ("scope_type_concept_id", CONCEPT_ACTIVE),
            ("tenant_id", None), ("country_concept_id", JURISDICTION_CONCEPT_ID),
            ("selection_mode_concept_id", CONCEPT_ACTIVE),
            ("allow_tenant_extension", False), ("allow_custom_value", False),
            ("status_concept_id", CONCEPT_ACTIVE),
            ("created_at", stamp), ("updated_at", stamp2),
            ("created_by_user_id", SEED_USER_ID), ("updated_by_user_id", SEED_USER_ID),
            ("row_version", 1)]))
        evers.append(OrderedDict([
            ("id", stable_uuid("SALUD", meta["patch"], "boot", meta["module"],
                               "system_context.dynamic_enum_versions", vs_name)),
            ("dynamic_enum_definition_id", ed_id), ("version_number", 1),
            ("value_set_version_id", vsv_id), ("schema_version", "1.0.0"),
            ("cache_token", hashlib.sha256((vs_name + "|1.0.0").encode()).hexdigest()[:32]),
            ("effective_from", stamp), ("effective_to", None),
            ("status_concept_id", CONCEPT_ACTIVE),
            ("recorded_at", stamp), ("recorded_by_user_id", SEED_USER_ID)]))

        # binding: ata el enum a cada columna física que lo consume
        for tkey, cfg in NEW_TABLES.items():
            for col, name in (cfg.get("vs") or {}).items():
                if name != vs_name:
                    continue
                tschema, tname = tkey.split(".")
                ebinds.append(OrderedDict([
                    ("id", stable_uuid("SALUD", meta["patch"], "boot", meta["module"],
                                       "system_context.dynamic_enum_bindings", vs_name, tkey, col)),
                    ("dynamic_enum_definition_id", ed_id),
                    ("target_schema_name", tschema), ("target_entity_name", tname),
                    ("target_field_name", col), ("system_context_id", None),
                    ("required", True), ("fallback_concept_id", None),
                    ("validation_mode_concept_id", CONCEPT_ACTIVE),
                    ("status_concept_id", CONCEPT_ACTIVE),
                    ("created_at", stamp), ("updated_at", stamp2),
                    ("created_by_user_id", SEED_USER_ID), ("updated_by_user_id", SEED_USER_ID),
                    ("row_version", 1)]))

    upsert_rows(doc03, "boot", "code_system_versions", csvers)
    stats["value_sets"] = upsert_rows(doc03, "boot", "value_sets", vsets)
    upsert_rows(doc03, "boot", "value_set_versions", vversions)
    stats["conceptos"] = upsert_rows(doc03, "boot", "catalog_concepts", concepts)
    upsert_rows(doc03, "boot", "concept_designations", designations)
    stats["miembros"] = upsert_rows(doc03, "boot", "value_set_members", members)
    stats["enums"] = upsert_rows(doc45, "boot", "dynamic_enum_definitions", edefs)
    upsert_rows(doc45, "boot", "dynamic_enum_versions", evers)
    upsert_rows(doc45, "boot", "dynamic_enum_options", eopts)
    stats["bindings"] = upsert_rows(doc45, "boot", "dynamic_enum_bindings", ebinds)
    return stats


# ============================================================ fase 1b · puente backend

def phase_backend_bridge(docs) -> dict:
    """Espeja en el paquete las filas que TerminologySeedService materializa al arrancar.

    El backend deriva sus conceptos con BACKEND_NAMESPACE y los servicios comparan los
    `*_concept_id` contra esos ids. Las tablas v4.0.8 los referencian, y la fase 2b
    «repara» hacia un concepto al azar toda FK cuyo destino no exista en el paquete —
    así que la cadena del backend (fuente → sistema → versión → conceptos → tenant
    DEFAULT) tiene que existir también acá. Ambos lados insertan por id y son
    idempotentes entre sí: mismos ids, mismos valores; los timestamps difieren y es
    lo único que `--refresh` reescribe.

    Espejo mínimo a propósito: solo lo que las tablas v4.0.8 referencian más el trío de
    correo de v4.0.11 (abajo). El resto del catálogo del backend (propósito de consent,
    worker de sistema, ~6 000 conceptos de módulo) sigue siendo suyo.

    v4.0.11 — trío de correo (canal EMAIL + proveedor DEFAULT_EMAIL + config): espejo
    byte-idéntico de MessagingSeedService. El bug que cierra: el paquete traía un canal
    con code EMAIL e id PROPIO; la app busca el suyo POR ID, no lo encuentra, inserta y
    choca contra uq_message_channels_code — el seed de mensajería aborta entero y las 5
    escrituras de correo mueren con «Canal no encontrado». Con los mismos ids el seed de
    la app es no-op (encuentra por id) y hay un solo dueño lógico. NO se resuelve con
    INTENTIONALLY_EMPTY: esa constante es solo la allowlist del reporte de cobertura, y
    vaciar la tabla dejaría channel_id NOT NULL sin destino (2b no puede reparar contra
    tabla vacía) o colapsaría uq_message_templates_channel_id_version.
    """
    doc03, doc04 = docs["03"], docs["04"]
    t = det_time(BOOT_BASE, "backend-bridge")
    stamp = iso(t)

    sources = [OrderedDict([
        ("id", BACKEND_SEED["source_id"]), ("code", BACKEND_SEED["source_code"]),
        ("name", "Mantra Core Internal Terminology"),
        ("created_at", stamp), ("updated_at", stamp), ("row_version", 1)])]
    systems = [OrderedDict([
        ("id", BACKEND_SEED["code_system_id"]), ("source_id", BACKEND_SEED["source_id"]),
        ("internal_code", BACKEND_SEED["code_system_internal_code"]),
        ("name", "Mantra Core Internal Code System"),
        ("canonical_url", BACKEND_SEED["canonical_url"]), ("case_sensitive", True),
        ("created_at", stamp), ("updated_at", stamp), ("row_version", 1)])]
    versions = [OrderedDict([
        ("id", BACKEND_SEED["csv_id"]), ("code_system_id", BACKEND_SEED["code_system_id"]),
        ("version", BACKEND_SEED["version"]), ("published_at", stamp), ("is_default", True),
        ("created_at", stamp), ("updated_at", stamp), ("row_version", 1)])]
    # state_concept_id queda ausente (NULL) igual que en el backend: estos conceptos
    # son la raíz del árbol y un estado propio recursaría sobre sí mismos.
    concepts = [OrderedDict([
        ("id", backend_id(key)), ("code_system_version_id", BACKEND_SEED["csv_id"]),
        ("code", code), ("display", display), ("abstract", False), ("selectable", True),
        ("created_at", stamp), ("updated_at", stamp), ("row_version", 1)])
        for key, code, display in BACKEND_CONCEPTS]
    tenants = [OrderedDict([
        ("id", BACKEND_SEED["tenant_id"]), ("code", BACKEND_SEED["tenant_code"]),
        ("tenant_type_concept_id", backend_id("directory:tenant-type:provider")),
        ("legal_name", "Mantra Core Default Tenant"),
        ("legal_entity_type_concept_id", backend_id("directory:legal-entity:company")),
        ("status_concept_id", backend_id("directory:tenant-status:active")),
        ("verification_status_concept_id", backend_id("directory:tenant-verification:verified")),
        ("created_at", stamp), ("updated_at", stamp), ("row_version", 1)])]

    # Los DOS tríos del backend (messaging-seed.service.ts): correo e in-app, mismos
    # ids, mismos valores campo a campo. La app crea con `partial: true`, así que lo no
    # listado allá es NULL. Sin el espejo de IN_APP la campana quedaba muerta con el
    # seed «en verde»: los adapters referencian el canal POR ID CALCULADO
    # (`MESSAGING_SEED.inAppChannelId`) y `findActiveChannelByType` filtra por los
    # conceptos del backend, que la fila legacy del paquete no tenía.
    email_channel_id = backend_id("seed:message-channel:email")
    email_provider_id = backend_id("seed:messaging-provider:email")
    inapp_channel_id = backend_id("seed:message-channel:in-app")
    inapp_provider_id = backend_id("seed:messaging-provider:in-app")
    channels = [OrderedDict([
        ("id", email_channel_id), ("code", "EMAIL"), ("name", "Email"),
        ("channel_type_concept_id", backend_id("messaging:channel-type:email")),
        ("supports_templates", True),
        ("state_concept_id", backend_id("state:active")),
        ("created_at", stamp), ("updated_at", stamp), ("row_version", 1)]),
        OrderedDict([
        ("id", inapp_channel_id), ("code", "IN_APP"), ("name", "In-app"),
        ("channel_type_concept_id", backend_id("messaging:channel-type:in-app")),
        # A propósito: la bandeja renderiza el cuerpo que le llega, no una plantilla.
        ("supports_templates", False),
        ("state_concept_id", backend_id("state:active")),
        ("created_at", stamp), ("updated_at", stamp), ("row_version", 1)])]
    providers = [OrderedDict([
        ("id", email_provider_id), ("code", "DEFAULT_EMAIL"),
        ("name", "Default email provider"),
        ("provider_type_concept_id", backend_id("messaging:provider-type:email")),
        ("state_concept_id", backend_id("state:active")),
        ("adapter_code", "WORKER_DISPATCHED"), ("adapter_version", "1"),
        ("is_builtin", True),
        ("supports_webhooks", False), ("supports_polling", False),
        ("supports_delivery_receipts", False), ("supports_read_receipts", False),
        ("supports_click_receipts", False), ("supports_reply_receipts", False),
        ("created_at", stamp), ("updated_at", stamp), ("row_version", 1)]),
        OrderedDict([
        ("id", inapp_provider_id), ("code", "DEFAULT_IN_APP"),
        ("name", "In-app delivery"),
        ("provider_type_concept_id", backend_id("messaging:provider-type:in-app")),
        ("state_concept_id", backend_id("state:active")),
        # La entrega es directa a la bandeja, no despachada por el worker de correo.
        ("adapter_code", "IN_APP_DIRECT"), ("adapter_version", "1"),
        ("is_builtin", True),
        ("supports_webhooks", False), ("supports_polling", False),
        ("supports_delivery_receipts", False), ("supports_read_receipts", False),
        ("supports_click_receipts", False), ("supports_reply_receipts", False),
        ("created_at", stamp), ("updated_at", stamp), ("row_version", 1)])]
    configs = [OrderedDict([
        ("id", backend_id("seed:provider-channel-config:email")),
        ("provider_id", email_provider_id), ("channel_id", email_channel_id),
        ("tenant_id", BACKEND_SEED["tenant_id"]), ("priority", 1),
        ("state_concept_id", backend_id("state:active")),
        ("adapter_config_version", 1),
        ("tracking_mode_concept_id", backend_id("messaging:tracking-mode:none")),
        ("status_mapping_version", 1), ("enabled_at", stamp),
        ("created_at", stamp), ("updated_at", stamp), ("row_version", 1)]),
        OrderedDict([
        ("id", backend_id("seed:provider-channel-config:in-app")),
        ("provider_id", inapp_provider_id), ("channel_id", inapp_channel_id),
        ("tenant_id", BACKEND_SEED["tenant_id"]), ("priority", 1),
        ("state_concept_id", backend_id("state:active")),
        ("adapter_config_version", 1),
        ("tracking_mode_concept_id", backend_id("messaging:tracking-mode:none")),
        ("status_mapping_version", 1), ("enabled_at", stamp),
        ("created_at", stamp), ("updated_at", stamp), ("row_version", 1)])]

    stats = OrderedDict()
    stats["terminology_sources"] = upsert_rows(doc03, "boot", "terminology_sources", sources)
    stats["code_systems"] = upsert_rows(doc03, "boot", "code_systems", systems)
    stats["code_system_versions"] = upsert_rows(doc03, "boot", "code_system_versions", versions)
    stats["catalog_concepts"] = upsert_rows(doc03, "boot", "catalog_concepts", concepts)
    stats["tenants"] = upsert_rows(doc04, "boot", "tenants", tenants)
    stats["message_channels"] = upsert_rows(docs["35"], "boot", "message_channels", channels)
    stats["messaging_providers"] = upsert_rows(docs["35"], "boot", "messaging_providers", providers)
    stats["provider_channel_configs"] = upsert_rows(
        docs["35"], "boot", "provider_channel_configs", configs)
    return stats


# Las identidades que el backend siembra por id y el paquete traía con id propio. Una
# entrada por clave natural: si el paquete declara ese `code` con OTRO id, la fila legacy
# se retira y toda referencia se repunta al id del backend. `message_channels` y
# `messaging_providers` tienen UNIQUE(code), así que convivir es imposible: uno de los dos
# ids pierde, y tiene que perder el del paquete — los servicios referencian el del backend.
BACKEND_OWNED_ROWS = (
    ("message_channels", "EMAIL", "seed:message-channel:email"),
    ("message_channels", "IN_APP", "seed:message-channel:in-app"),
    ("messaging_providers", "DEFAULT_EMAIL", "seed:messaging-provider:email"),
    ("messaging_providers", "DEFAULT_IN_APP", "seed:messaging-provider:in-app"),
)


def retire_legacy_channels(docs, fks) -> dict:
    """Retira canales y proveedores que el paquete traía con id propio y repunta referencias.

    Sustitución de identidad 1:1 (mismo code, id del backend), NO colapso: cada fila que
    apuntaba al id viejo pasa a apuntar al id del backend y ninguna clave natural cambia
    de forma — uq_message_templates_channel_id_version se preserva porque el reemplazo es
    biyectivo. Idempotente: sin fila legacy no hay nada que retirar ni repuntar.

    Nota sobre la plantilla `DIAGNOSTIC_RESULT_AVAILABLE`, que queda colgando del canal
    in-app canónico aunque éste declare `supports_templates = false`: ninguna restricción
    de la base lo impide y la app no lee plantillas de canales que no las soportan;
    moverla a otro canal o borrarla inventaría semántica que el modelo no pidió.
    """
    retired, repointed = 0, 0
    for entity, natural_code, backend_key in BACKEND_OWNED_ROWS:
        target = "messaging." + entity
        canonical = backend_id(backend_key)
        legacy_ids = set()
        for section in ("boot", "mock"):
            rows = docs["35"].get(section, {}).get("records", {}).get(entity, [])
            for row in list(rows):
                if row.get("code") == natural_code and row.get("id") != canonical:
                    legacy_ids.add(row["id"])
                    rows.remove(row)
        if not legacy_ids:
            continue
        retired += len(legacy_ids)

        for code, doc in docs.items():
            schema = module_path(code).stem.split("_", 1)[1].replace(".seeds", "")
            for section in ("boot", "mock"):
                for child, rows in doc.get(section, {}).get("records", {}).items():
                    tfks = fks.get(f"{schema}.{child}", {})
                    cols = [c for c, dest in tfks.items() if dest == target]
                    for row in rows:
                        for col in cols:
                            if row.get(col) in legacy_ids:
                                row[col] = canonical
                                repointed += 1
    return {"retiradas": retired, "repuntadas": repointed}


# ============================================================ fase 2 · tablas nuevas

PK_OF = {"community.feedback_ticket_events": "history_id"}
ROWS_PER_TABLE = 8


def v408_overrides(cfg: dict, tkey: str, section: str, pk: str, index: int) -> dict:
    """Overrides de una tabla v4.0.8: valores fijos + elecciones + PK bajo su patch.

    Para las tablas v4.0.7 (sin `fixed`/`choices`/`patch`) devuelve {} y el bucle
    genérico se comporta exactamente igual que antes.
    """
    out = dict(cfg.get("fixed", {}))
    for col, ids in (cfg.get("choices") or {}).items():
        out[col] = pick(ids, tkey, col, index)
    if cfg.get("patch"):
        out[pk] = stable_uuid("SALUD", cfg["patch"], section, tkey, pk, index)
    return out


def canonical_signature_policies(docs) -> dict:
    """D-05 (ALOVIDA): una política comodín `signature_required = true` por tenant.

    Cierra el fail-open de la emisión de recetas: con la tabla vacía,
    `isSignatureRequired` devuelve false y la firma no se exige nunca. La política
    por defecto es deliberadamente la más amplia — jurisdicción, tipo de medicamento
    y canal en NULL (comodín) — porque el ajuste jurisdiccional fino es una decisión
    legal PENDIENTE_DE_APROBACIÓN (vault: politica-firma-recetas-d05) y no se inventa
    acá. Además la emisión solo evalúa `medicationType`: una política acotada por
    jurisdicción o canal jamás matchearía.
    """
    table = "clinical.prescription_signature_policies"
    packs = {"boot": [], "mock": []}
    for section, base in (("boot", BOOT_BASE), ("mock", MOCK_BASE)):
        tenant_ids = [r["id"] for r in docs["04"][section]["records"].get("tenants", [])]
        for tenant_id in tenant_ids:
            stamp = iso(det_time(base, table, tenant_id))
            packs[section].append(OrderedDict([
                ("id", stable_uuid("SALUD", PATCH_V408, section, table, "id", tenant_id)),
                ("tenant_id", tenant_id),
                ("jurisdiction_code", None),
                ("medication_type_concept_id", None),
                ("channel_concept_id", None),
                ("signature_required", True),
                ("effective_from", iso(base)),
                ("effective_to", None),
                ("created_at", stamp), ("updated_at", stamp),
                ("created_by_user_id", SEED_USER_ID), ("updated_by_user_id", SEED_USER_ID),
                ("row_version", 1)]))
    return packs


def canonical_plans(vf, doc42, value_sets) -> dict:
    """Los 3 planes reales del catálogo (Free/PRO/MAX) + sus precios, features y quotas."""
    tier_vs = value_sets["vs_subscription_plan_tier"]
    feat_vs = value_sets["vs_plan_feature_key"]
    metric_vs = value_sets["vs_plan_quota_metric"]
    period_vs = value_sets["vs_quota_period"]

    plans, prices, features, quotas, elig = [], [], [], [], []
    plan_ids = {}
    for code, spec in PLAN_CATALOG.items():
        pid = stable_uuid("SALUD", "4.0.5", "boot", "42", "payments.subscription_plans", code)
        plan_ids[code] = pid
        base = vf.row("payments.subscription_plans", "boot", 0, overrides={
            "id": pid, "code": code, "name": spec["name"],
            "tier_concept_id": concept_id("vs_subscription_plan_tier", spec["tier"], tier_vs),
            "is_default": spec["is_default"], "is_public": True,
            "amount": spec["monthly"], "interval_count": 1,
        })
        plans.append(base)

        # uk_plan_prices_plan_currency_interval = (plan, currency, billing_interval, region):
        # cada intervalo necesita su propio billing_interval_concept_id, si no la segunda
        # fila colisiona y el ON CONFLICT DO NOTHING la descarta en silencio.
        for slot, (interval, amount) in enumerate(
                (("mensual", spec["monthly"]), ("anual", spec["yearly"]))):
            prices.append(vf.row("payments.plan_prices", "boot", slot, overrides={
                "id": stable_uuid("SALUD", "4.0.5", "boot", "42",
                                  "payments.plan_prices", code, interval),
                "plan_id": pid, "amount": amount,
                "interval_count": 1 if interval == "mensual" else 12,
                "billing_interval_concept_id": vf.generic_concepts[
                    slot % len(vf.generic_concepts)],
                "tax_included": False,
            }))

        for feat in feat_vs["codes"]:
            features.append(vf.row("payments.plan_features", "boot", 0, overrides={
                "id": stable_uuid("SALUD", "4.0.5", "boot", "42",
                                  "payments.plan_features", code, feat),
                "plan_id": pid,
                "feature_concept_id": concept_id("vs_plan_feature_key", feat, feat_vs),
                "is_enabled": feat in spec["features"],
            }))

        for metric, limit in spec["quotas"].items():
            period = QUOTA_PERIOD.get(metric, "total")
            quotas.append(vf.row("payments.plan_quotas", "boot", 0, overrides={
                "id": stable_uuid("SALUD", "4.0.5", "boot", "42",
                                  "payments.plan_quotas", code, metric),
                "plan_id": pid,
                "metric_concept_id": concept_id("vs_plan_quota_metric", metric, metric_vs),
                "limit_value": limit,   # None = ilimitado (así lo declara el catálogo)
                "quota_period_concept_id": concept_id("vs_quota_period", period, period_vs),
            }))

        elig.append(vf.row("payments.plan_eligibility_rules", "boot", 0, overrides={
            "id": stable_uuid("SALUD", "4.0.5", "boot", "42",
                              "payments.plan_eligibility_rules", code),
            "plan_id": pid, "is_included": True,
            "notes": "Elegible: consultorios y enfermerías (las farmacias quedan excluidas).",
        }))

    return {"subscription_plans": plans, "plan_prices": prices, "plan_features": features,
            "plan_quotas": quotas, "plan_eligibility_rules": elig, "_ids": plan_ids}


# --- v4.0.11 · el directorio de laboratorios --------------------------------
# Seis unidades reales de las tres ciudades donde el producto se demuestra, una por tenant.
#
# Que sea una por tenant es una elección de este paquete de demostración, no un límite del
# modelo: desde el 2026-08-23 la unicidad es `uq_diagnostic_units_tenant_id_code`
# (tenant_id, code), así que una organización puede tener todas las unidades que quiera
# mientras sus códigos no se repitan —un hospital tiene laboratorio, imagen y patología—.
# Antes era UNIQUE sobre `tenant_id` a solas y sí lo prohibía.
DIAGNOSTIC_UNIT_CATALOG = [
    dict(code="LAB_ANDINO_LP", name="Laboratorio Clínico Andino", kind="LABORATORY",
         city="La Paz", lines="Av. 6 de Agosto 2170, Sopocachi",
         postal="LP-SOP-2170", lat=-16.5090, lon=-68.1250,
         home_collection=True, accredited=True),
    dict(code="LAB_ILLIMANI_LP", name="Laboratorio Illimani", kind="LABORATORY",
         city="La Paz", lines="Av. Saavedra 1856, Miraflores",
         postal="LP-MIR-1856", lat=-16.4990, lon=-68.1180,
         home_collection=True, accredited=False),
    dict(code="LAB_CENTRAL_SCZ", name="Laboratorio Central Santa Cruz", kind="LABORATORY",
         city="Santa Cruz de la Sierra", lines="Av. San Martín 455, Equipetrol",
         postal="SCZ-EQP-455", lat=-17.7710, lon=-63.1950,
         home_collection=False, accredited=False),
    dict(code="IMG_EQUIPETROL_SCZ", name="Centro de Imagenología Equipetrol", kind="IMAGING",
         city="Santa Cruz de la Sierra", lines="Av. Beni 320, Equipetrol Norte",
         postal="SCZ-EQP-320", lat=-17.7780, lon=-63.1900,
         home_collection=False, accredited=False),
    dict(code="LAB_TUNARI_CBBA", name="Laboratorio Tunari", kind="LABORATORY",
         city="Cochabamba", lines="Av. Pando 1247, Queru Queru",
         postal="CBB-QQU-1247", lat=-17.3720, lon=-66.1600,
         home_collection=False, accredited=False),
    dict(code="IMG_COCHABAMBA", name="Centro Diagnóstico Cochabamba", kind="IMAGING",
         city="Cochabamba", lines="Av. América 782, Recoleta",
         postal="CBB-REC-782", lat=-17.3940, lon=-66.1570,
         home_collection=False, accredited=False),
]

# La oferta por tipo de unidad. `study` y `modality` son nombres lógicos de los conceptos
# del módulo 23: no se inventa ninguno, sólo se usan los que el backend declara.
DIAGNOSTIC_OFFERINGS = {
    "LABORATORY": [
        dict(code="HEMOGRAMA", name="Hemograma completo", study="STUDY_COMPLETE_BLOOD_COUNT",
             modality="MODALITY_LABORATORY", amount=45, minutes=15, turnaround=240,
             prep="No requiere ayuno.", order=False),
        dict(code="GLUCEMIA", name="Glucemia en ayunas", study="STUDY_GLUCOSE",
             modality="MODALITY_LABORATORY", amount=25, minutes=10, turnaround=180,
             prep="Ayuno de 8 horas.", order=False),
        dict(code="PCR", name="Proteína C reactiva", study="STUDY_PCR",
             modality="MODALITY_LABORATORY", amount=60, minutes=10, turnaround=360,
             prep="No requiere ayuno.", order=True),
    ],
    "IMAGING": [
        dict(code="RX_TORAX", name="Radiografía de tórax", study="STUDY_CHEST_XRAY",
             modality="MODALITY_XRAY", amount=150, minutes=20, turnaround=120,
             prep="Retirar objetos metálicos del torso.", order=True),
        dict(code="ECO_ABDOMINAL", name="Ecografía abdominal", study="STUDY_ABDOMINAL_ULTRASOUND",
             modality="MODALITY_ULTRASOUND", amount=220, minutes=30, turnaround=120,
             prep="Ayuno de 6 horas; concurrir con vejiga llena.", order=True),
    ],
}

# Equipamiento y especialidad declarados por tipo de unidad.
DIAGNOSTIC_EQUIPMENT_BY_KIND = {
    "LABORATORY": [dict(type="EQUIPMENT_TYPE_ANALYZER", modality="MODALITY_LABORATORY",
                        manufacturer="Sysmex", model="XN-550")],
    "IMAGING": [dict(type="EQUIPMENT_TYPE_XRAY", modality="MODALITY_XRAY",
                     manufacturer="Siemens", model="Multix Impact"),
                dict(type="EQUIPMENT_TYPE_ULTRASOUND", modality="MODALITY_ULTRASOUND",
                     manufacturer="Mindray", model="DC-40")],
}
DIAGNOSTIC_SPECIALTY_BY_KIND = {"LABORATORY": "patologia_clinica", "IMAGING": "radiologia"}


def package_concept(docs, vs_internal_code: str, concept_code: str):
    """Concepto de un value set que YA vive en el paquete, por su código.

    Hace falta para los sets base —`vs_currency` entre ellos— que no están en `VS_OWNER`:
    sus conceptos no se derivan acá, vienen del paquete original. Sin esto, el binding del
    vault reasignaría la moneda del tarifario con `pick()` y a un laboratorio boliviano le
    podría tocar USD.
    """
    boot = docs["03"]["boot"]["records"]
    vs_ids_ = {r["id"] for r in boot.get("value_sets", [])
               if (r.get("internal_code") or "").upper() == vs_internal_code.upper()}
    version_ids = {r["id"] for r in boot.get("value_set_versions", [])
                   if r.get("value_set_id") in vs_ids_}
    miembros = {r["concept_id"] for r in boot.get("value_set_members", [])
                if r.get("value_set_version_id") in version_ids}
    for row in boot.get("catalog_concepts", []):
        if row["id"] in miembros and (row.get("code") or "").upper() == concept_code.upper():
            return row["id"]
    return None


def _diagnostic_hosts(docs) -> list:
    """Los (tenant, práctica, sede) sobre los que cuelga una unidad, uno por tenant.

    Se descubren del propio paquete en vez de fijarse a mano: la sede es FK obligatoria de
    `diagnostic_unit_sites` y la práctica es de dónde sale la dirección que se muestra.
    """
    practices = {r["id"]: r for r in docs["14"]["mock"]["records"].get("practices", [])}
    hosts, vistos = [], set()
    for site in docs["14"]["mock"]["records"].get("practice_sites", []):
        practice = practices.get(site.get("practice_id"))
        if practice is None:
            continue
        tenant = practice.get("tenant_id")
        if tenant is None or tenant in vistos:
            continue
        vistos.add(tenant)
        hosts.append(dict(tenant_id=tenant, practice_id=practice["id"],
                          site_id=site["id"], address_id=site.get("address_id")))
    return hosts


def canonical_diagnostic_units(docs, value_sets) -> dict:
    """El directorio de laboratorios del módulo 23, sembrado por el camino canónico.

    Reemplaza —no completa— las 160 filas que el bucle genérico había producido: eran
    sintéticas («Diagnostic units 01»), apuntaban a conceptos del catálogo transversal que
    los servicios del módulo nunca comparan (comparan contra `DUNIT.*`, derivados de la
    clave del backend) y, al declarar varias unidades en el mismo tenant, chocaban contra
    `uq_diagnostic_units_tenant_id` —la clave única de entonces, sobre `tenant_id` a
    solas—. Por eso el directorio se veía vacío aunque el paquete dijera 16 filas por
    tabla. Esa clave ya no existe (desde el 2026-08-23 la unicidad es por tenant **y**
    código), pero el reemplazo se conserva por los otros dos motivos: los datos reales y
    los conceptos correctos.

    Sustituye además a `tools/alovida/seed-diagnostic-units.mjs`, que hacía lo mismo con
    `INSERT` crudos por fuera del paquete: dos dueños del mismo dato con ids distintos es
    exactamente lo que la política de seeds evita.
    """
    packs = {t: [] for t in ("diagnostic_units", "diagnostic_unit_sites",
                             "diagnostic_study_offerings", "diagnostic_price_schedules",
                             "diagnostic_study_prices", "diagnostic_unit_specialties",
                             "diagnostic_equipment", "diagnostic_unit_accreditations")}
    hosts = _diagnostic_hosts(docs)
    vs_meta = value_sets.get("vs_medical_specialty")
    # El modelo ata `*.currency_concept_id` a `vs_currency` (nota del vault): se usa ESE
    # boliviano, no el del módulo, para que el binding no lo reasigne después.
    moneda_bob = package_concept(docs, "VS_CURRENCY", "BOB") or backend_id(
        "diagnostic_units:CURRENCY_BOB")

    def cid(name: str) -> str:
        return backend_id("diagnostic_units:" + name)

    def new_id(table: str, *parts) -> str:
        return stable_uuid("SALUD", PATCH_V4011, "mock", "diagnostic_units." + table,
                           "id", *parts)

    for unit, host in zip(DIAGNOSTIC_UNIT_CATALOG, hosts):
        base = det_time(MOCK_BASE, "diagnostic_units", unit["code"])
        stamp = iso(base)
        unit_id = new_id("diagnostic_units", unit["code"])
        site_id = new_id("diagnostic_unit_sites", unit["code"])

        packs["diagnostic_units"].append(OrderedDict([
            ("id", unit_id), ("tenant_id", host["tenant_id"]),
            ("practice_id", host["practice_id"]),
            ("primary_practice_site_id", host["site_id"]),
            ("code", unit["code"]), ("name", unit["name"]),
            ("diagnostic_unit_type_concept_id", cid("UNIT_TYPE_" + unit["kind"])),
            ("ownership_type_concept_id", cid("OWNERSHIP_PRIVATE")),
            ("public_profile_id", None),
            ("accepts_external_orders", True),
            ("walk_in_available", unit["kind"] == "LABORATORY"),
            ("home_collection_available", unit["home_collection"]),
            # Publicada = verificada y activa: es lo que el directorio filtra para mostrarla.
            ("verification_status_concept_id", cid("VERIFICATION_VERIFIED")),
            ("status_concept_id", cid("UNIT_ACTIVE")),
            ("created_at", stamp), ("updated_at", stamp),
            ("created_by_user_id", SEED_USER_ID), ("updated_by_user_id", SEED_USER_ID),
            ("row_version", 1)]))

        packs["diagnostic_unit_sites"].append(OrderedDict([
            ("id", site_id), ("diagnostic_unit_id", unit_id),
            ("practice_site_id", host["site_id"]),
            ("site_role_concept_id", cid("SITE_ROLE_PRIMARY")),
            ("accession_prefix", unit["code"].split("_")[0]),
            ("sample_collection_available", unit["kind"] == "LABORATORY"),
            ("imaging_available", unit["kind"] == "IMAGING"),
            ("status_concept_id", cid("SITE_ACTIVE")),
            ("created_at", stamp), ("updated_at", stamp),
            ("created_by_user_id", SEED_USER_ID), ("updated_by_user_id", SEED_USER_ID),
            ("row_version", 1)]))

        if vs_meta:
            packs["diagnostic_unit_specialties"].append(OrderedDict([
                ("id", new_id("diagnostic_unit_specialties", unit["code"])),
                ("diagnostic_unit_id", unit_id),
                ("specialty_concept_id", concept_id(
                    "vs_medical_specialty", DIAGNOSTIC_SPECIALTY_BY_KIND[unit["kind"]], vs_meta)),
                ("is_primary", True),
                ("verification_status_concept_id", cid("VERIFICATION_VERIFIED")),
                ("valid_from", base.date().isoformat()), ("valid_to", None),
                ("created_at", stamp), ("updated_at", stamp),
                ("created_by_user_id", SEED_USER_ID), ("updated_by_user_id", SEED_USER_ID),
                ("row_version", 1)]))

        for eq in DIAGNOSTIC_EQUIPMENT_BY_KIND[unit["kind"]]:
            packs["diagnostic_equipment"].append(OrderedDict([
                ("id", new_id("diagnostic_equipment", unit["code"], eq["type"])),
                ("diagnostic_unit_site_id", site_id),
                ("equipment_type_concept_id", cid(eq["type"])),
                ("manufacturer", eq["manufacturer"]), ("model", eq["model"]),
                ("serial_number", "{}-{}".format(unit["code"], eq["model"].replace(" ", "-"))),
                ("modality_concept_id", cid(eq["modality"])),
                ("last_calibration_at", stamp), ("next_calibration_due_at", None),
                ("operational_status_concept_id", cid("EQUIPMENT_OPERATIONAL")),
                ("created_at", stamp), ("updated_at", stamp),
                ("created_by_user_id", SEED_USER_ID), ("updated_by_user_id", SEED_USER_ID),
                ("row_version", 1)]))

        if unit["accredited"]:
            packs["diagnostic_unit_accreditations"].append(OrderedDict([
                ("id", new_id("diagnostic_unit_accreditations", unit["code"])),
                ("diagnostic_unit_id", unit_id), ("diagnostic_unit_site_id", site_id),
                ("accreditation_concept_id", cid("ACCREDITATION_ISO15189")),
                ("accreditation_number", "ISO15189-" + unit["code"]),
                ("issuer_tenant_id", None),
                ("valid_from", base.date().isoformat()), ("valid_to", None),
                ("evidence_file_id", None),
                ("verification_status_concept_id", cid("VERIFICATION_VERIFIED")),
                ("created_at", stamp), ("updated_at", stamp),
                ("created_by_user_id", SEED_USER_ID), ("updated_by_user_id", SEED_USER_ID),
                ("row_version", 1)]))

        # Un tarifario público por unidad. `version_number` es único DENTRO del tarifario
        # (uq_diagnostic_study_prices_price_schedule_id_version_number), así que numera la
        # oferta, no la revisión del precio.
        schedule_id = new_id("diagnostic_price_schedules", unit["code"])
        packs["diagnostic_price_schedules"].append(OrderedDict([
            ("id", schedule_id), ("diagnostic_unit_id", unit_id),
            ("diagnostic_unit_site_id", site_id),
            ("code", "TARIFARIO_" + unit["code"]),
            ("price_schedule_type_concept_id", cid("PRICE_SCHEDULE_STANDARD")),
            ("insurer_tenant_id", None), ("broker_tenant_id", None),
            ("currency_concept_id", moneda_bob),
            ("valid_from", stamp), ("valid_to", None),
            ("public_visibility", True),
            ("status_concept_id", cid("SCHEDULE_ACTIVE")),
            ("created_at", stamp), ("updated_at", stamp),
            ("created_by_user_id", SEED_USER_ID), ("updated_by_user_id", SEED_USER_ID),
            ("row_version", 1)]))

        for numero, oferta in enumerate(DIAGNOSTIC_OFFERINGS[unit["kind"]], start=1):
            offering_id = new_id("diagnostic_study_offerings", unit["code"], oferta["code"])
            packs["diagnostic_study_offerings"].append(OrderedDict([
                ("id", offering_id), ("diagnostic_unit_id", unit_id),
                ("diagnostic_unit_site_id", site_id),
                ("study_code", oferta["code"]),
                ("study_concept_id", cid(oferta["study"])),
                ("modality_concept_id", cid(oferta["modality"])),
                ("body_site_concept_id", None), ("specimen_type_concept_id", None),
                ("display_name", oferta["name"]),
                ("description", "{} en {}.".format(oferta["name"], unit["name"])),
                ("preparation_instructions", oferta["prep"]),
                ("expected_duration_minutes", oferta["minutes"]),
                ("expected_turnaround_minutes", oferta["turnaround"]),
                ("requires_medical_order", oferta["order"]),
                ("requires_prior_authorization", False),
                ("home_collection_eligible", unit["home_collection"]
                    and unit["kind"] == "LABORATORY"),
                ("status_concept_id", cid("OFFERING_ACTIVE")),
                ("created_at", stamp), ("updated_at", stamp),
                ("created_by_user_id", SEED_USER_ID), ("updated_by_user_id", SEED_USER_ID),
                ("row_version", 1)]))
            packs["diagnostic_study_prices"].append(OrderedDict([
                ("id", new_id("diagnostic_study_prices", unit["code"], oferta["code"])),
                ("price_schedule_id", schedule_id),
                ("diagnostic_study_offering_id", offering_id),
                ("version_number", numero),
                ("base_amount", oferta["amount"]), ("patient_amount", oferta["amount"]),
                ("insurer_amount", None), ("tax_amount", None), ("discount_factor", None),
                ("pricing_rule_json", None),
                ("effective_from", stamp), ("effective_to", None),
                ("status_concept_id", cid("PRICE_ACTIVE")),
                ("recorded_at", stamp), ("recorded_by_user_id", SEED_USER_ID)]))

    return packs


def curate_diagnostic_addresses(docs) -> int:
    """Pone la dirección real de cada unidad en la sede que la aloja.

    Las seis direcciones ya existen —son las de las prácticas del mock— y traían el texto
    del bucle genérico («Addresses — identidad del paciente 01»). Se corrige el contenido,
    no la fila: el `id` no se toca, así que ninguna FK se mueve.
    """
    direcciones = {r["id"]: r for r in docs["02"]["mock"]["records"].get("addresses", [])}
    corregidas = 0
    for unit, host in zip(DIAGNOSTIC_UNIT_CATALOG, _diagnostic_hosts(docs)):
        fila = direcciones.get(host.get("address_id"))
        if fila is None:
            continue
        cambios = {"lines": unit["lines"], "city": unit["city"],
                   "postal_code": unit["postal"], "latitude": unit["lat"],
                   "longitude": unit["lon"], "valid_to": None}
        if any(fila.get(k) != v for k, v in cambios.items()):
            fila.update(cambios)
            corregidas += 1
    return corregidas



# --- v4.1.6 · las farmacias reales de Santa Cruz ---------------------------
# Fuente: `RealDataSeeds/LISTA DE FARMACIAS, LABORATORIOS Y ANALISIS MEDICOS.md`,
# planilla del negocio leída el 2026-09-03. El archivo llega en UTF-16 con el
# texto mal decodificado (cp850 sobre latin-1: «Chßvez»); acá va ya corregido.
#
# El NIT va como identificador oficial del tenant en `common.identifiers`
# (TAX_ID), igual que las aseguradoras — no en un campo propio de la farmacia,
# que el modelo no tiene.
#
# Sin dirección ni coordenadas **a propósito**: la planilla no las trae para las
# farmacias (sí para los laboratorios) y no se inventan. Sin lat/lng, «la más
# cercana» no las considera; aparecen en el directorio, que es lo que se pidió.
FARMACIAS_BOLIVIA = [
    dict(code='FARMACORP_SA', nit='1015447026',
         legal_name='Farmacias Corporativas S.A.',
         trade_name='FARMACORP S.A.'),
    dict(code='FARMACIA_CHAVEZ', nit='133795023',
         legal_name='Farmacia Chávez S.A.',
         trade_name='FARMACIA CHAVEZ'),
    dict(code='FARMACIA_HIPERMAXI', nit='1028627025',
         legal_name='HIPERMAXI S.A.',
         trade_name='FARMACIA HIPERMAXI'),
    dict(code='FARMACIA_NOSTAS', nit='364402022',
         legal_name='FARMACIA NOSTAS S.R.L.',
         trade_name='FARMACIA NOSTAS'),
    dict(code='FARMACIA_TELCHI', nit='1015307021',
         legal_name='TELCHI LITEL LTDA.',
         trade_name='FARMACIA TELCHI'),
    dict(code='FARMACIA_ARTESANAL', nit='1012471029',
         legal_name='FARMACIA E IMPORTADORA ARTESANAL S.R.L.',
         trade_name='FARMACIA ARTESANAL'),
    dict(code='FARMACIA_OKINAWA', nit='345298024',
         legal_name='FARMACIA OKINAWA S.R.L.',
         trade_name='FARMACIA OKINAWA'),
]


# --- v4.1.6 · laboratorios y clínicas reales de Santa Cruz ------------------
# Misma fuente y mismo criterio que FARMACIAS_BOLIVIA: planilla del negocio del
# 2026-09-03, con la codificación ya corregida. Los laboratorios y las clínicas
# SÍ traen dirección y teléfono; van como texto porque es lo que la planilla da
# —sin lat/lng, así que la búsqueda por cercanía no los considera—. Los códigos
# van en ASCII: son clave natural y una tilde en un `code` es un problema que
# aparece tres capas más abajo.
LABORATORIOS_BOLIVIA = [
    dict(code='LABORATORIO_IBC', nit='189982028', phone='3371222',
         legal_name='INSTITUTO BIO-CLÍNICO CRUCEÑO LTDA.',
         trade_name='Laboratorio IBC',
         lines='Calle España esquina Andrés Ibáñez N° S/N, Zona Central (Casco Viejo), Santa Cruz de la Sierra'),
    dict(code='LABORATORIO_BIOCELL', nit='3209949014', phone='3546281',
         legal_name='PALACIOS VEGA FLORINDA',
         trade_name='Laboratorio BIO-CELL',
         lines='Av. Cañoto #700, Esquina calle México (1er Anillo)'),
    dict(code='PLEXUS_LABORATORIO', nit='351478025', phone='',
         legal_name='PLEXUS LABORATORIOS S.R.L.',
         trade_name='Plexus Laboratorio',
         lines='Av. Marcelo Terceros Bánzer #24 (Zona Equipetrol)'),
    dict(code='LABORATORIO_DR_ZUNA', nit='1476497010', phone='3441838',
         legal_name='LABORATORIO DR. ZUNA S.R.L.',
         trade_name='Laboratorio Dr. Zuna',
         lines='Av. Alemana #2065 (a dos cuadras del 2do Anillo)'),
    dict(code='LES_ENDOGENETICA', nit='1013877027', phone='3364746',
         legal_name='ENDOGENETICA SANTA CRUZ S.R.L.',
         trade_name='L.E.S. Endogenética',
         lines='Calle Sara N° 439, entre Cuéllar y Seoane'),
    dict(code='LABORATORIO_CLINICO_ANTELO', nit='147446021', phone='3324546',
         legal_name='BARRIOS ANTELO S.R.L.',
         trade_name='Laboratorio Clínico Antelo S.R.L.',
         lines='Calle Libertad N° 402, esquina Florida (Zona Central / Casco Viejo)'),
    dict(code='LABOGEN_SRL', nit='192916023', phone='77506494',
         legal_name='LABORATORIO DE GENÉTICA Y DIAGNÓSTICO MOLECULAR LABOGEN S.R.L.',
         trade_name='LABOGEN S.R.L.',
         lines='Calle Macororó N° 4 (casi Av. Alemana, entre 3er y 4to Anillo)'),
    dict(code='LABORATORIO_MULTIFUNCIONAL', nit='1023211026', phone='3579232',
         legal_name='CLINICA SAN PEDRO S.R.L.',
         trade_name='Laboratorio Multifuncional San Pedro',
         lines='Tercer Anillo Externo #3105 (o N° 37), Radial 15, Zona Alto San Pedro, Santa Cruz de la Sierra'),
    dict(code='LABORATORIO_CATEDRAL', nit='1012539022', phone='3333305',
         legal_name='LABORATORIO CATEDRAL SEC. PAT. CLÍNICA S.R.L.',
         trade_name='Laboratorio Catedral',
         lines='Calle Andrés Ibáñez N° 115 (Zona Central / Casco Viejo)'),
    dict(code='LABORATORIO_OMEGA', nit='', phone='3327610',
         legal_name='LABORATORIO DE ANÁLISIS CLÍNICOS OMEGA S.R.L.',
         trade_name='LABORATORIO OMEGA',
         lines='Av. Cañoto N° 604, esquina calle Cuéllar, Santa Cruz de la Sierra.'),
    dict(code='FUTURE__IMAGENES_MEDICAS', nit='', phone='3143333 / 72193615',
         legal_name='FUTURE S.R.L.',
         trade_name='FUTURE - IMAGENES MEDICAS',
         lines='Av. Cañoto N° 580, Planta Baja (dentro de las instalaciones del Centro Médico Niño Jesús).'),
    dict(code='DIACOR_SA', nit='', phone='3362244',
         legal_name='DIACOR S.A.',
         trade_name='DIACOR S.A.',
         lines='Av. Irala N° 534'),
    dict(code='INSTITUTO_DE_DIAGNOSTICO_M', nit='', phone='3368811 / 77047134',
         legal_name='Instituto de Diagnóstico Médico (IDM)',
         trade_name='Instituto de Diagnóstico Médico (IDM)',
         lines='Av. Landívar N° 456.'),
]

CLINICAS_BOLIVIA = [
    dict(code='CLINICA_LAS_AMERICAS', nit='316258024', phone='800101055',
         legal_name='Clínica Metropolitana de las Américas S.A.',
         trade_name='CLINICA LAS AMERICAS',
         lines='Av. Sexto Anillo esq. Beni # 5100'),
    dict(code='CLINICA_FOIANINI', nit='1028455022', phone='3362211',
         legal_name='Clínica Angel Foianini S.R.L.',
         trade_name='CLINICA FOIANINI',
         lines='Av. Irala # 468 / Calle Chuquisaca # 737'),
    dict(code='CLINICA_UNIVERSITARIO_MART', nit='4010340662', phone='3180060',
         legal_name='Operadora Lativ Administración S.A.',
         trade_name='CLINICA UNIVERSITARIO MARTIN DOCKWEILER',
         lines='Av. Noel Kempff Mercado (3er anillo interno)'),
    dict(code='CLINICA_INCOR', nit='1012499022', phone='3520444',
         legal_name='Clínica Incor S.R.L.',
         trade_name='CLINICA INCOR',
         lines='Av. 26 de Febrero, calle caranda'),
    dict(code='CLINICA_URBARI', nit='1028441025', phone='3534000',
         legal_name='CLINICA URBARÍ S.A.',
         trade_name='CLINICA URBARI',
         lines='Barrio Urbarí, Calle Igmiri # 555'),
    dict(code='CLINICA_NINO_JESUS', nit='1028557028', phone='3366969',
         legal_name='Clínica Privada de Asistencia Médica Niño Jesús S.A.',
         trade_name='CLINICA NIÑO JESUS',
         lines='Av. Cañoto esq. Rafael Peña, primer anillo, zona central'),
    dict(code='CLINICA_NINO_JESUS_II', nit='1028557028', phone='78456019',
         legal_name='Clinica Privada De Asistencia Medica Niño Jesus S.A.',
         trade_name='CLINICA NIÑO JESUS II',
         lines='Calle Ballivián # 747'),
    dict(code='CLINICA_MONTALVO', nit='1012565021', phone='3581919',
         legal_name='Clínica Bioginecológica Montalvo S.R.L.',
         trade_name='CLINICA MONTALVO',
         lines='Barrio Urbarí, Av. Universo # 641.'),
    dict(code='CLINICA_SIRANI', nit='122079029', phone='3352200',
         legal_name='Clinica Medica Sirani Ltda.',
         trade_name='CLINICA SIRANI',
         lines='René Moreno # 667'),
    dict(code='CLINICA_LOURDES', nit='', phone='3325518',
         legal_name='CLINICA LOURDES',
         trade_name='CLINICA LOURDES',
         lines='René Moreno # 352.'),
    dict(code='CLINICA_ITALIA', nit='', phone='67718675',
         legal_name='CLINICA ITALIA',
         trade_name='CLINICA ITALIA',
         lines='Calle Colón Nº 345, entre las calles Pari y Mercado, zona de las siete calles'),
    dict(code='CLINICA_SANTA_MARIA', nit='1453397017', phone='3352002',
         legal_name='CLINICA SANTA MARIA',
         trade_name='CLINICA SANTA MARIA',
         lines='Av. Viedma # 754'),
    dict(code='CLINICA_SAN_PEDRO', nit='1023211026', phone='70090283',
         legal_name='Clínica San Pedro S.R.L.',
         trade_name='CLINICA SAN PEDRO',
         lines='3er Anillo Externo Radial 15, # 37, zona Alto San Pedro'),
    dict(code='CLINICA_COSALUD', nit='148758024', phone='3393960',
         legal_name='Corporación de Salud Cosalud S.R.L.',
         trade_name='CLINICA COSALUD',
         lines='Oruro # 366'),
    dict(code='CLINICA_CRISTO_REY', nit='', phone='3523841',
         legal_name='CLINICA CRISTO REY',
         trade_name='CLINICA CRISTO REY',
         lines='Av. Roca y Coronado calle Chilón # 2025'),
    dict(code='CLINICA_DE_OJOS_SANTA_CRUZ', nit='4035895', phone='3327327',
         legal_name='CLINICA DE OJOS SANTA CRUZ LTDA.',
         trade_name='CLINICA DE OJOS SANTA CRUZ',
         lines='Av. Centenario, Pasillo A. Barbery'),
    dict(code='CLINICA_EL_TROMPILLO', nit='3729982013', phone='3590011',
         legal_name='Clínica Médica Quirúrgica El Trompillo',
         trade_name='CLINICA EL TROMPILLO',
         lines='Barrio El Trompillo, calle Zoilo Flores # 164'),
    dict(code='CLINICA_GRUMEDSO', nit='136935024', phone='3584050',
         legal_name='GRUPO MEDICO SOLIDARIO S.R.L.',
         trade_name='CLINICA GRUMEDSO',
         lines='Av. Moscu 6to. Anillo, Zona de la Cuchilla (frente a la Universidad Evangélica Boliviana'),
    dict(code='CLINICA_KAMIYA', nit='1015047023', phone='3363400',
         legal_name='CLINICA KAMIYA S.R.L.',
         trade_name='CLINICA KAMIYA',
         lines='Av. Monseñor Rivero # 265.'),
    dict(code='CLINICA_MELENDRES', nit='136165029', phone='3520982',
         legal_name='Clínica Médica Melendres S.R.L.',
         trade_name='CLINICA MELENDRES',
         lines='Av. Grigotá # 2450 / 3er. Anillo.'),
    dict(code='CLINICA_SAN_JOSE', nit='1013979025', phone='3521542',
         legal_name='CLINICA SAN JOSE S.R.L.',
         trade_name='CLINICA SAN JOSE',
         lines='Calle Ingavi # 720'),
    dict(code='CLINICA_UNIVERSITARIA_UCEB', nit='1026225020', phone='3221317',
         legal_name='CLINICA UNIVERSITARIA UCEBOL',
         trade_name='CLINICA UNIVERSITARIA UCEBOL',
         lines='Carretera al Norte, Km. 5'),
]

# --- v4.2.21 · las 17 aseguradoras reales de Bolivia ------------------------
# Las diecinueve filas del listado del negocio («LISTA DE ASEGURADORAS», tabla de
# personas y salud + tabla de generales y fianzas) son diecisiete compañías: BISA
# y Fortaleza figuran en las dos mitades con el MISMO NIT, y una empresa con un
# solo NIT es una sola aseguradora. Lo que cambia entre una mitad y otra es el
# ramo, y eso queda en `ramo` / `ofrece_salud`.
#
# **El código es el de la API, y no es decorativo.** `bolivia-insurance-seed.service.ts`
# siembra estas mismas compañías al arrancar, derivando cada id de su código
# (`seed:insurance-carrier:bo:<code>`). Hasta v4.2.20 este paquete usaba códigos
# propios (`ALIANZA_VIDA`) y por lo tanto ids propios: la base terminaba con las
# nueve de salud DOS veces —una fila con sigla, dirección y NIT, otra con esos
# tres campos en NULL— y ninguna consulta que no filtrara por id podía saber
# cuál era cuál. Al compartir código, `backend_id()` (espejo exacto de
# `deterministicId()`) devuelve el MISMO uuid en los dos sembradores: el que
# corra segundo actualiza la fila en vez de duplicarla.
#
# `depto` es el código de vs_administrative_area (v4.1.4) del departamento del
# domicilio. `direccion` es la dirección completa tal como la publica el listado
# —va en `insurance_carriers.address`—; `lines` + `city` son esa misma dirección
# partida para `common.addresses`. El NIT va en los DOS lados a propósito: en
# `regulator_identifier`, que es de donde lo lee el perfil de la organización
# (`directory-read.service.ts`) y donde lo deja el alta pública
# (`payer.regulatorIdentifier`), y como identificador oficial del tenant en
# `common.identifiers` (TAX_ID), que es su lugar semántico.
#
# v4.2.10 (subtarea 2.3): `whatsapp`/`call_center`/`support_email` son los
# canales de contacto directo que la propia compañía publica en su dominio
# oficial, con `source_url` y `obtenido` (regla 70: sin publicación
# confirmada, `None` — nunca un número inventado). Las ocho de generales y
# fianzas entran sin canales: no se buscaron ni se inventan.
# «Termina en S.A.» — mismo criterio que `bolivia-insurance-seed.service.ts`
# para elegir la forma societaria del tenant sin adivinarla.
RAZON_SOCIAL_SA = re.compile(r"\bS\.?A\.?$", re.IGNORECASE)

ASEGURADORAS_BOLIVIA = [
    dict(code="BO_ASEG_ALIANZA_VIDA_S_A",
         nit="1015327022", depto="sc", ramo="PERSONAS", ofrece_salud=True,
         legal_name="Alianza Vida Seguros y Reaseguros S.A.",
         sigla="Alianza Vida S.A.",
         direccion="Mario Gutiérrez Nº 3325, esq. Av. Roca y Coronado, Edificio "
                   "Alianza, Zona Villa Mercedes, Santa Cruz de la Sierra, Bolivia.",
         lines="Mario Gutiérrez Nº 3325, esq. Av. Roca y Coronado, Edificio Alianza, "
               "Zona Villa Mercedes",
         city="Santa Cruz de la Sierra",
         whatsapp=None, call_center=None,
         support_email=None,
         source_url=None,
         obtenido=None),
    dict(code="BO_ASEG_BISA_SEGUROS_Y_REASEGUROS_S_A",
         nit="1020655027", depto="lp", ramo="PERSONAS", ofrece_salud=True,
         legal_name="BISA Seguros y Reaseguros S.A.",
         sigla="BISA Seguros y Reaseguros S.A.",
         direccion="Av. Arce N° 2631, Edificio Multicine, Piso N° 14, zona de San "
                   "Jorge, La Paz, Bolivia",
         lines="Av. Arce N° 2631, Edificio Multicine, Piso N° 14, zona de San Jorge",
         city="La Paz",
         whatsapp="+59171545112", call_center="800-10-6060",
         support_email=None,
         source_url="https://ayuda.bisaseguros.com",
         obtenido="2026-09-13"),
    dict(code="BO_ASEG_FORTALEZA_SEGUROS_Y_REASEGUROS_S_A",
         nit="1028175023", depto="sc", ramo="PERSONAS", ofrece_salud=True,
         legal_name="Compañía de Seguros y Reaseguros Fortaleza S.A.",
         sigla="Fortaleza Seguros y Reaseguros S.A.",
         direccion="Av. Virgen de Cotoca N° 2080, Zona Lazareto, Santa Cruz de la "
                   "Sierra, Bolivia",
         lines="Av. Virgen de Cotoca N° 2080, Zona Lazareto",
         city="Santa Cruz de la Sierra",
         whatsapp="+59169200004", call_center="800-12-9992",
         support_email=None,
         source_url="https://aseguradorafortaleza.com.bo/contactenos",
         obtenido="2026-09-13"),
    dict(code="BO_ASEG_CREDISEGURO_S_A_SEGUROS_PERSONALES",
         nit="191310020", depto="lp", ramo="PERSONAS", ofrece_salud=True,
         legal_name="Crediseguro S.A. Seguros Personales",
         sigla="Crediseguro S.A. Seguros Personales",
         direccion="Av. Hernando Siles esq. calle 10 de Obrajes, Torre Empresarial "
                   "ESIMSA, Piso 9, La Paz, Bolivia.",
         lines="Av. Hernando Siles esq. calle 10 de Obrajes, Torre Empresarial ESIMSA, "
               "Piso 9",
         city="La Paz",
         whatsapp="+59178889096", call_center=None,
         support_email=None,
         source_url="https://www.crediseguro.com.bo",
         obtenido="2026-09-13"),
    dict(code="BO_ASEG_LA_BOLIVIANA_CIACRUZ_SEGUROS_PERSONALES_S_A",
         nit="1006989027", depto="lp", ramo="PERSONAS", ofrece_salud=True,
         legal_name="LA BOLIVIANA CIACRUZ SEGUROS PERSONALES S.A.",
         sigla="LA BOLIVIANA CIACRUZ SEGUROS PERSONALES S.A.",
         direccion="Calle Colón N° 288, Piso 2°, en la ciudad de La Paz, Bolivia.",
         lines="Calle Colón N° 288, Piso 2°",
         city="La Paz",
         whatsapp="+59171548278", call_center="800-10-2727",
         support_email=None,
         source_url="https://www.lbc.bo/contactanos",
         obtenido="2026-09-13"),
    dict(code="BO_ASEG_LA_VITALICIA_SEGUROS_Y_REASEGUROS_DE_VIDA_S_",
         nit="1020687029", depto="lp", ramo="PERSONAS", ofrece_salud=True,
         legal_name="LA VITALICIA SEGUROS Y REASEGUROS DE VIDA S.A.",
         sigla="LA VITALICIA SEGUROS Y REASEGUROS DE VIDA S.A.",
         direccion="Av. 6 de Agosto Nº 2860, Zona San Jorge, La Paz, Bolivia",
         lines="Av. 6 de Agosto Nº 2860, Zona San Jorge",
         city="La Paz",
         whatsapp="+59177775677", call_center="800-10-4142",
         support_email=None,
         source_url="https://lavitalicia.bo/contacto/",
         obtenido="2026-09-13"),
    dict(code="BO_ASEG_NACIONAL_SEGUROS_VIDA_Y_SALUD_S_A",
         nit="1028483024", depto="sc", ramo="PERSONAS", ofrece_salud=True,
         legal_name="Nacional Seguros Vida y Salud S.A.",
         sigla="Nacional Seguros Vida y Salud S.A.",
         direccion="Avenida Cristóbal de Mendoza esquina Avenida Alemana N° 333 "
                   "(Segundo Anillo), Santa Cruz, Bolivia",
         lines="Avenida Cristóbal de Mendoza esquina Avenida Alemana N° 333 (Segundo "
               "Anillo)",
         city="Santa Cruz de la Sierra",
         whatsapp=None, call_center=None,
         support_email=None,
         source_url=None,
         obtenido=None),
    dict(code="BO_ASEG_UNIVIDA_S_A",
         nit="301204024", depto="lp", ramo="PERSONAS", ofrece_salud=True,
         legal_name="Empresa de Seguros y Reaseguros Personales UNIVIDA S.A.",
         sigla="UNIVIDA S.A.",
         direccion="Av. Camacho N° 1485, Edificio La Urbana, Piso 3, La Paz, Bolivia",
         lines="Av. Camacho N° 1485, Edificio La Urbana, Piso 3",
         city="La Paz",
         whatsapp=None, call_center="800-10-9119",
         support_email=None,
         source_url="https://www.univida.bo",
         obtenido="2026-09-13"),
    dict(code="BO_ASEG_SANTA_CRUZ_VIDA_Y_SALUD_S_A",
         nit="370008027", depto="sc", ramo="PERSONAS", ofrece_salud=True,
         legal_name="Santa Cruz Vida y Salud Seguros y Reaseguros Personales S.A.",
         sigla="Santa Cruz Vida y Salud S.A.",
         direccion="Avenida San Martín, Edificio Manzana 40, Torre 2, Piso 13, Zona "
                   "Equipetrol, Santa Cruz de la Sierra, Bolivia.",
         lines="Avenida San Martín, Edificio Manzana 40, Torre 2, Piso 13, Zona "
               "Equipetrol",
         city="Santa Cruz de la Sierra",
         whatsapp="+59172124747", call_center="800-12-4747",
         support_email="consultasSCVS@santacruzfg.com",
         source_url="https://www.santacruzvidaysalud.com.bo/contacto/",
         obtenido="2026-09-13"),
    dict(code="BO_ASEG_ALIANZA_SEGUROS_S_A",
         nit="1020351029", depto="sc", ramo="GENERALES", ofrece_salud=False,
         legal_name="Alianza Compañía de Seguros y Reaseguros S.A.",
         sigla="Alianza Seguros S.A.",
         direccion="Av. Roca y Coronado Nº 1380, Santa Cruz de la Sierra, Bolivia",
         lines="Av. Roca y Coronado Nº 1380",
         city="Santa Cruz de la Sierra",
         whatsapp=None, call_center=None,
         support_email=None,
         source_url=None,
         obtenido=None),
    dict(code="BO_ASEG_CREDISEGURO_S_A_SEGUROS_GENERALES",
         nit="343764028", depto="lp", ramo="GENERALES", ofrece_salud=False,
         legal_name="Crediseguro S.A. Seguros Generales",
         sigla="Crediseguro S.A. Seguros Generales",
         direccion="Avenida Hernando Siles esquina Calle 10 de Obrajes, Torre "
                   "Empresarial ESIMSA, Piso 9, La Paz, Bolivia",
         lines="Avenida Hernando Siles esquina Calle 10 de Obrajes, Torre Empresarial "
               "ESIMSA, Piso 9",
         city="La Paz",
         whatsapp=None, call_center=None,
         support_email=None,
         source_url=None,
         obtenido=None),
    dict(code="BO_ASEG_LA_BOLIVIANA_CIACRUZ_DE_SEGUROS_Y_REASEGUROS",
         nit="1007017028", depto="lp", ramo="GENERALES", ofrece_salud=False,
         legal_name="La Boliviana Ciacruz de Seguros y Reaseguros S.A.",
         sigla="La Boliviana Ciacruz de Seguros y Reaseguros S.A.",
         direccion="Calle Colón N° 288, Edificio La Boliviana Ciacruz (Zona Central), "
                   "La Paz, Bolivia",
         lines="Calle Colón N° 288, Edificio La Boliviana Ciacruz (Zona Central)",
         city="La Paz",
         whatsapp=None, call_center=None,
         support_email=None,
         source_url=None,
         obtenido=None),
    dict(code="BO_ASEG_MERCANTIL_SANTA_CRUZ_SEGUROS_Y_REASEGUROS_GE",
         nit="399309026", depto="lp", ramo="GENERALES", ofrece_salud=False,
         legal_name="Mercantil Santa Cruz Seguros y Reaseguros Generales S.A.",
         sigla="Mercantil Santa Cruz Seguros y Reaseguros Generales S.A.",
         direccion="Av. Camacho N° 1448, Edif. Banco Mercantil Santa Cruz, Piso 11, La "
                   "Paz, Bolivia",
         lines="Av. Camacho N° 1448, Edif. Banco Mercantil Santa Cruz, Piso 11",
         city="La Paz",
         whatsapp=None, call_center=None,
         support_email=None,
         source_url=None,
         obtenido=None),
    dict(code="BO_ASEG_NACIONAL_SEGUROS_PATRIMONIALES_Y_FIANZAS_S_A",
         nit="145776027", depto="sc", ramo="GENERALES", ofrece_salud=False,
         legal_name="Nacional Seguros Patrimoniales y Fianzas S.A.",
         sigla="Nacional Seguros Patrimoniales y Fianzas S.A.",
         direccion="Avenida Cristóbal de Mendoza esquina Avenida Alemana Nº 333 "
                   "(Segundo Anillo), Santa Cruz, Bolivia",
         lines="Avenida Cristóbal de Mendoza esquina Avenida Alemana Nº 333 (Segundo "
               "Anillo)",
         city="Santa Cruz",
         whatsapp=None, call_center=None,
         support_email=None,
         source_url=None,
         obtenido=None),
    dict(code="BO_ASEG_SEGUROS_Y_REASEGUROS_CREDINFORM_INTERNATIONA",
         nit="1006765027", depto="lp", ramo="GENERALES", ofrece_salud=False,
         legal_name="Seguros y Reaseguros Credinform International S.A.",
         sigla="Seguros y Reaseguros Credinform International S.A.",
         direccion="Calle Julio Patiño N° 550, esquina calle 12, Calacoto, La Paz, "
                   "Bolivia",
         lines="Calle Julio Patiño N° 550, esquina calle 12, Calacoto",
         city="La Paz",
         whatsapp=None, call_center=None,
         support_email=None,
         source_url=None,
         obtenido=None),
    dict(code="BO_ASEG_SEGUROS_ILLIMANI_S_A",
         nit="1007165029", depto="lp", ramo="GENERALES", ofrece_salud=False,
         legal_name="Seguros Illimani S.A.",
         sigla="Seguros Illimani S.A.",
         direccion="Calle Loayza N° 233, Edificio Mariscal de Ayacucho, Piso 10, "
                   "Oficinas 1004-1013, La Paz, Bolivia",
         lines="Calle Loayza N° 233, Edificio Mariscal de Ayacucho, Piso 10, Oficinas "
               "1004-1013",
         city="La Paz",
         whatsapp=None, call_center=None,
         support_email=None,
         source_url=None,
         obtenido=None),
    dict(code="BO_ASEG_UNIBIENES_S_A",
         nit="338090023", depto="lp", ramo="GENERALES", ofrece_salud=False,
         legal_name="UNIBIENES Seguros y Reaseguros Patrimoniales S.A.",
         sigla="Unibienes S.A.",
         direccion="Calle 10 de Calacoto, Edificio Emporium N° 7812, Piso 5, Zona Sur, "
                   "La Paz, Bolivia",
         lines="Calle 10 de Calacoto, Edificio Emporium N° 7812, Piso 5, Zona Sur",
         city="La Paz",
         whatsapp=None, call_center=None,
         support_email=None,
         source_url=None,
         obtenido=None),
]

# Las tablas del módulo 26 cuyas filas mock referencian a la aseguradora.
CARRIER_DEPENDENT_TABLES = ("insurance_products", "broker_carrier_agreements",
                            "provider_networks", "insurance_claims",
                            "insurance_reconciliation_batches")


# Las personas de contacto de las aseguradoras: representante legal + 3 gerencias.
# Los nombres, correos, celulares y cédulas son DATOS DE PRUEBA generados con faker
# (semilla fija) por `tools/alovida/generate-carrier-contacts.mjs` del repo de la API
# y versionados en este archivo: el generador tiene que ser determinista, así que
# faker corre una vez y su salida se revisa en el PR como cualquier otro dato.
CARRIER_CONTACTS_FILE = ROOT / "salud-db" / "data" / "carrier-contacts.dataset.json"


def load_carrier_contacts() -> list:
    """Los 68 contactos (17 aseguradoras × 4 roles), o vacío si no está el archivo."""
    if not CARRIER_CONTACTS_FILE.exists():
        return []
    return json.loads(CARRIER_CONTACTS_FILE.read_text(encoding="utf-8"))["datos"]


def canonical_carrier_contacts(docs, value_sets) -> dict:
    """Representante legal y gerencias de cada aseguradora (v4.2.22).

    El listado del negocio trae la COMPAÑÍA —razón social, NIT, domicilio— y nada
    de las personas, que es justo lo que el registro de procesos pide para dar de
    alta una organización: quién la representa legalmente y quiénes son sus
    gerencias general, comercial y de marketing. Sin esas filas, las 17
    aseguradoras quedan a medio cargar: el panel de la organización las muestra
    vacías y no hay a quién escribirle.

    Se materializa exactamente lo mismo que escribe el alta pública
    (`createContactPerson` + `attachRegistrationRepresentatives`), para que una
    aseguradora sembrada y una registrada a mano se lean igual:

    * `profiles.persons` — una persona por contacto. **Sólo `display_name`**, como
      el alta: el formulario pide «nombre completo» en un campo y partirlo sería
      adivinar dónde corta. Las partes están en el dataset por si algún día el
      formulario las pide.
    * `common.contact_points` — su correo y su celular, ambos con uso `WORK`.
    * `common.identifiers` — la cédula, **sólo del representante legal**: es el
      único al que el modelo le reserva `ci_identifier_id`.
    * `directory.tenant_legal_representatives` — el vínculo con la aseguradora,
      con su rol del value set `vs_legal_representative_role`. El representante
      legal es `is_primary`; las gerencias no.

    Lo que NO se siembra: `power_of_attorney_document_id` queda en NULL. El poder
    notariado es un PDF real que alguien sube, y fabricar un archivo para que la
    columna no esté vacía sería inventar documentación (regla 00.7).
    """
    packs = {"persons": [], "contact_points": [], "identifiers": [],
             "tenant_legal_representatives": []}
    contactos = load_carrier_contacts()
    if not contactos:
        return packs
    vs_rol = value_sets.get("vs_legal_representative_role")
    if not vs_rol:
        return packs

    def new_id(table: str, *parts) -> str:
        return stable_uuid("SALUD", PATCH_V414, "mock", table, "id", *parts)

    for contacto in contactos:
        clave = (contacto["carrierCode"], contacto["rol"])
        tenant_id = backend_id("seed:tenant:bo-carrier:" + contacto["carrierCode"])
        base = det_time(MOCK_BASE, "tenant_legal_representatives", *clave)
        stamp = iso(base)
        auditoria = [("created_at", stamp), ("updated_at", stamp),
                     ("created_by_user_id", SEED_USER_ID),
                     ("updated_by_user_id", SEED_USER_ID), ("row_version", 1)]
        person_id = new_id("profiles.persons", *clave)

        packs["persons"].append(OrderedDict([
            ("id", person_id),
            ("person_status_concept_id", backend_id("profiles:PERSON_ACTIVE")),
            ("name", None), ("middle_name", None), ("last_name", None),
            ("mother_last_name", None),
            ("display_name", contacto["nombreCompleto"]),
            ("photo_file_id", None), ("birth_date", None),
            ("administrative_gender_concept_id", None),
            ("sex_at_birth_concept_id", None), ("gender_identity_concept_id", None),
            ("vital_status_concept_id", None), ("deceased_at", None),
            ("nationality_concept_id", None), ("preferred_language_concept_id", None),
            ("occupation_concept_id", None), ("occupation_free_text", None),
            ("work_employer_concept_id", None), ("work_employer_free_text", None),
            ("merge_survivor_person_id", None), ("anonymized_at", None),
            *auditoria]))

        for sistema, valor, orden in (("email", contacto["email"], 1),
                                      ("mobile", contacto["celular"], 2)):
            packs["contact_points"].append(OrderedDict([
                ("id", new_id("common.contact_points", *clave, sistema)),
                ("owner_type_concept_id", backend_id("common:owner-type:person")),
                ("owner_id", person_id),
                ("system_concept_id", backend_id("common:contact-system:" + sistema)),
                ("value", valor),
                ("use_concept_id", backend_id("common:contact-use:work")),
                ("rank", orden), ("verified", False),
                ("valid_from", base.date().isoformat()), ("valid_to", None),
                *auditoria]))

        ci_identifier_id = None
        if contacto["cedula"]:
            ci_identifier_id = new_id("common.identifiers", *clave)
            packs["identifiers"].append(OrderedDict([
                ("id", ci_identifier_id),
                ("owner_type_concept_id", backend_id("common:owner-type:person")),
                ("owner_id", person_id),
                ("use_concept_id", backend_id("common:use:official")),
                ("type_concept_id", backend_id("common:id-type:national")),
                ("system", None), ("value", contacto["cedula"]),
                ("issuer_country_concept_id", JURISDICTION_CONCEPT_ID),
                ("assigner_tenant_id", None),
                ("valid_from", base.date().isoformat()), ("valid_to", None),
                ("state_concept_id", backend_id("state:active")),
                *auditoria]))

        packs["tenant_legal_representatives"].append(OrderedDict([
            ("id", new_id("directory.tenant_legal_representatives", *clave)),
            ("tenant_id", tenant_id), ("person_id", person_id),
            ("representative_role_concept_id",
             concept_id("vs_legal_representative_role", contacto["rol"], vs_rol)),
            ("ci_identifier_id", ci_identifier_id),
            # El poder notariado es un PDF real: no se fabrica uno para llenar
            # la columna.
            ("power_of_attorney_document_id", None),
            ("appointed_at", base.date().isoformat()),
            ("valid_from", base.date().isoformat()), ("valid_to", None),
            # `True` sólo para el representante legal; las gerencias van en NULL,
            # NO en `False`. `uk_tenant_legal_representatives_primary` es
            # `UNIQUE (tenant_id, is_primary)` y no es parcial: tres `False` bajo
            # el mismo tenant la violan igual que tres `True`. La API deja el
            # campo sin poner por esta misma razón; en Postgres cada NULL es
            # distinto y conviven. (El índice debería ser parcial —`WHERE
            # is_primary`— pero eso es un cambio de modelo, no de este carril.)
            ("is_primary", True if contacto["rol"] == "REPRESENTANTE_LEGAL" else None),
            ("status_concept_id", backend_id("state:active")),
            *auditoria]))
    return packs


def canonical_insurance_carriers(docs, value_sets) -> dict:
    """Las aseguradoras reales de Bolivia, sembradas por el camino canónico (v4.1.4).

    Reemplaza —no completa— las 12 filas que el bucle genérico había producido:
    eran sintéticas («Aseguradora Horizonte Salud Demo»), colgaban de tenants mock
    que ni siquiera son aseguradoras (el primero es la clínica privada) y llevaban
    el ACTIVE genérico del catálogo en vez de los conceptos que `insurance-read`
    resuelve (`INS.*`). Mismo molde que `canonical_diagnostic_units` (módulo 23).

    Cada aseguradora es: su tenant PAYER (módulo 04) + la fila de carrier (26) +
    el NIT como identificador oficial del tenant (02, `TAX_ID`) + su domicilio
    (02, con el departamento resuelto contra vs_administrative_area de v4.1.4).

    v4.2.21 — **los ids son los de la API, no los del paquete.** La aseguradora y
    su tenant los siembra también `bolivia-insurance-seed.service.ts` al arrancar,
    derivando el id del código con `deterministicId()`; `backend_id()` es su
    espejo exacto, así que ambos sembradores escriben la MISMA fila y el segundo
    en correr actualiza en vez de duplicar. Los ids propios (`stable_uuid` con
    `PATCH_V414`) se conservan para identificadores y direcciones, que son
    filas de este paquete y de nadie más.

    Dos campos siguen la semántica de la API, no la de v4.1.4, porque son
    visibles y el paquete gana al recargar con `--refresh`:

    * **verificación pendiente** (no «verificada»): nadie presentó documentación
      —los datos salen de un listado público—, y el sello «Verificado» que pinta
      el front lee justo esta columna (`declared-coverages-reader.ts`).
    * **el NIT en `regulator_identifier`**: es de donde lo lee el perfil de la
      organización y donde lo deja el alta pública (`payer.regulatorIdentifier`).
      Dejarlo en `None` —como hacía v4.1.4, con el argumento de que el registro
      del regulador sectorial (APS) es otra cosa— borraba de la vista el único
      identificador que la compañía tiene cargado. Sigue además en
      `common.identifiers` como `TAX_ID`, que es su lugar semántico.
    """
    packs = {"tenants": [], "insurance_carriers": [], "identifiers": [], "addresses": []}
    # Moldes del paquete: conceptos genéricos ya acuñados (residencia de datos,
    # moneda, uso/tipo de dirección) se reutilizan de las filas mock existentes
    # para no acuñar un segundo id para el mismo concepto.
    tenant_molde = docs["04"]["mock"]["records"]["tenants"][0]
    addr_molde = docs["02"]["mock"]["records"]["addresses"][0]
    vs_meta = value_sets.get("vs_administrative_area")

    def new_id(table: str, *parts) -> str:
        return stable_uuid("SALUD", PATCH_V414, "mock", table, "id", *parts)

    for aseg in ASEGURADORAS_BOLIVIA:
        base = det_time(MOCK_BASE, "insurance_carriers", aseg["code"])
        stamp = iso(base)
        tenant_id = backend_id("seed:tenant:bo-carrier:" + aseg["code"])
        auditoria = [("created_at", stamp), ("updated_at", stamp),
                     ("created_by_user_id", SEED_USER_ID),
                     ("updated_by_user_id", SEED_USER_ID), ("row_version", 1)]

        packs["tenants"].append(OrderedDict([
            # El código del tenant ES el de la aseguradora, como lo escribe la
            # API: el prefijo `ASEG_` de v4.1.4 daba un segundo código para la
            # misma organización y el alta pública no podía reclamarla.
            ("id", tenant_id), ("code", aseg["code"]),
            ("tenant_type_concept_id", backend_id("directory:tenant-type:payer")),
            ("legal_name", aseg["legal_name"]), ("trade_name", aseg["sigla"]),
            # La forma societaria se lee de la razón social, no se adivina.
            ("legal_entity_type_concept_id",
             backend_id("directory:legal-entity:sa")
             if RAZON_SOCIAL_SA.search(aseg["legal_name"])
             else backend_id("directory:legal-entity:company")),
            ("status_concept_id", backend_id("directory:tenant-status:active")),
            # Sin verificar: la organización existe porque está en un listado
            # público, no porque alguien la haya dado de alta.
            ("verification_status_concept_id",
             backend_id("directory:TENANT_UNVERIFIED")),
            ("country_concept_id", JURISDICTION_CONCEPT_ID),
            ("jurisdiction_concept_id", JURISDICTION_CONCEPT_ID),
            ("data_residency_region_concept_id",
             tenant_molde["data_residency_region_concept_id"]),
            ("currency_concept_id", tenant_molde["currency_concept_id"]),
            ("time_zone", "America/La_Paz"), ("parent_tenant_id", None),
            *auditoria]))

        packs["insurance_carriers"].append(OrderedDict([
            ("id", backend_id("seed:insurance-carrier:bo:" + aseg["code"])),
            ("tenant_id", tenant_id),
            ("carrier_code", aseg["code"]), ("legal_name", aseg["legal_name"]),
            # Nombre comercial y domicilio, que el listado trae y la fila de
            # aseguradora tiene columna propia para guardar.
            ("sigla", aseg["sigla"]), ("address", aseg["direccion"]),
            # v4.2.10 (subtarea 2.3): canales de contacto directo con fuente
            # pública citada arriba en ASEGURADORAS_BOLIVIA; `None` cuando no
            # se pudo confirmar en el dominio oficial de la compañía.
            ("whatsapp_number", aseg["whatsapp"]),
            ("call_center_phone", aseg["call_center"]),
            ("support_email", aseg["support_email"]),
            ("regulator_identifier", aseg["nit"]),
            ("jurisdiction_concept_id", JURISDICTION_CONCEPT_ID),
            ("public_profile_id", None),
            ("verification_status_concept_id", backend_id("insurance:VERIFY_PENDING")),
            ("status_concept_id", backend_id("insurance:CARRIER_ACTIVE")),
            *auditoria]))

        packs["identifiers"].append(OrderedDict([
            ("id", new_id("common.identifiers", aseg["code"])),
            ("owner_type_concept_id", backend_id("common:owner-type:tenant")),
            ("owner_id", tenant_id),
            ("use_concept_id", backend_id("common:use:official")),
            ("type_concept_id", backend_id("common:id-type:tax")),
            ("system", None), ("value", aseg["nit"]),
            ("issuer_country_concept_id", JURISDICTION_CONCEPT_ID),
            ("assigner_tenant_id", None),
            ("valid_from", base.date().isoformat()), ("valid_to", None),
            ("state_concept_id", backend_id("state:active")),
            *auditoria]))

        packs["addresses"].append(OrderedDict([
            ("id", new_id("common.addresses", aseg["code"])),
            ("owner_type_concept_id", backend_id("common:owner-type:tenant")),
            ("owner_id", tenant_id),
            ("use_concept_id", addr_molde["use_concept_id"]),
            ("type_concept_id", addr_molde["type_concept_id"]),
            ("lines", aseg["lines"]), ("city", aseg["city"]),
            ("administrative_area_concept_id",
             concept_id("vs_administrative_area", aseg["depto"], vs_meta) if vs_meta
             else addr_molde["administrative_area_concept_id"]),
            ("postal_code", None),
            ("country_concept_id", JURISDICTION_CONCEPT_ID),
            ("latitude", None), ("longitude", None),
            ("valid_from", base.date().isoformat()), ("valid_to", None),
            *auditoria]))
    return packs



def build_real_pharmacies(docs, value_sets) -> dict:
    """Las farmacias reales de la planilla, **con su ficha pública**.

    La ficha no es un adorno: el buscador público lee `community.public_profiles`
    y no las tablas de cada vertical, así que una farmacia sin ficha existe en el
    sistema y no aparece en ninguna búsqueda. Es exactamente lo que pasaba con
    las 16 de demostración —las 16 apuntaban a una ficha, pero la ficha no
    apuntaba a ninguna farmacia y su tipo era el marcador `DEFAULT_TARGET_TYPE`,
    porque esa columna no tiene binding declarado en el modelo—.

    Acá el vínculo se declara en los dos sentidos: la farmacia guarda su
    `public_profile_id` y la ficha guarda `target_id` + el tipo real
    (`community:PROFILE_TARGET_PHARMACY`), que es lo que el buscador traduce a
    vertical.

    Los conceptos de tipo, propiedad, moneda y estado salen del molde mock ya
    existente: son los mismos que el módulo usa hoy, y acuñar otros sería
    inventar semántica que nadie pidió.
    """
    packs = {"tenants": [], "pharmacies": [], "identifiers": [], "public_profiles": []}

    tenant_molde = docs["04"]["mock"]["records"]["tenants"][0]
    farm_molde = docs["24"]["mock"]["records"]["pharmacies"][0]
    perfil_molde = docs["19"]["mock"]["records"]["public_profiles"][0]

    def new_id(table: str, *parts) -> str:
        return stable_uuid("SALUD", PATCH_V416, "mock", table, "id", *parts)

    for farm in FARMACIAS_BOLIVIA:
        base = det_time(MOCK_BASE, "pharmacies", farm["code"])
        stamp = iso(base)
        tenant_id = new_id("directory.tenants", farm["code"])
        farmacia_id = new_id("pharmacy.pharmacies", farm["code"])
        perfil_id = new_id("community.public_profiles", farm["code"])
        auditoria = [("created_at", stamp), ("updated_at", stamp),
                     ("created_by_user_id", SEED_USER_ID),
                     ("updated_by_user_id", SEED_USER_ID), ("row_version", 1)]

        packs["tenants"].append(OrderedDict([
            ("id", tenant_id), ("code", "FARM_" + farm["code"]),
            ("tenant_type_concept_id", backend_id("directory:tenant-type:provider")),
            ("legal_name", farm["legal_name"]), ("trade_name", farm["trade_name"]),
            ("legal_entity_type_concept_id", backend_id("directory:legal-entity:company")),
            ("status_concept_id", backend_id("directory:tenant-status:active")),
            ("verification_status_concept_id",
             backend_id("directory:tenant-verification:verified")),
            ("country_concept_id", JURISDICTION_CONCEPT_ID),
            ("jurisdiction_concept_id", JURISDICTION_CONCEPT_ID),
            ("data_residency_region_concept_id",
             tenant_molde["data_residency_region_concept_id"]),
            ("currency_concept_id", tenant_molde["currency_concept_id"]),
            ("time_zone", "America/La_Paz"), ("parent_tenant_id", None),
            *auditoria]))

        packs["pharmacies"].append(OrderedDict([
            ("id", farmacia_id), ("tenant_id", tenant_id),
            ("code", farm["code"]),
            ("legal_name", farm["legal_name"]), ("trade_name", farm["trade_name"]),
            ("pharmacy_type_concept_id", farm_molde["pharmacy_type_concept_id"]),
            ("ownership_type_concept_id", farm_molde["ownership_type_concept_id"]),
            ("public_profile_id", perfil_id),
            ("default_currency_concept_id", farm_molde["default_currency_concept_id"]),
            ("verification_status_concept_id", farm_molde["verification_status_concept_id"]),
            ("status_concept_id", farm_molde["status_concept_id"]),
            *auditoria]))

        packs["identifiers"].append(OrderedDict([
            ("id", new_id("common.identifiers", farm["code"])),
            ("owner_type_concept_id", backend_id("common:owner-type:tenant")),
            ("owner_id", tenant_id),
            ("use_concept_id", backend_id("common:use:official")),
            ("type_concept_id", backend_id("common:id-type:tax")),
            ("system", None), ("value", farm["nit"]),
            ("issuer_country_concept_id", JURISDICTION_CONCEPT_ID),
            ("assigner_tenant_id", None),
            ("valid_from", base.date().isoformat()), ("valid_to", None),
            ("state_concept_id", backend_id("state:active")),
            *auditoria]))

        packs["public_profiles"].append(OrderedDict([
            ("id", perfil_id), ("tenant_id", tenant_id),
            # El tipo REAL, no el marcador: es lo que el buscador traduce a
            # «farmacia» para responder /public/search/pharmacies.
            ("target_type_concept_id", backend_id("community:PROFILE_TARGET_PHARMACY")),
            ("target_id", farmacia_id),
            ("slug", slug_de(farm["trade_name"])),
            ("display_name", farm["trade_name"]),
            ("headline", "Farmacia"),
            ("biography", None),
            ("avatar_file_id", None), ("cover_file_id", None),
            ("verification_status_concept_id",
             perfil_molde["verification_status_concept_id"]),
            # Pública, y no la del molde: el molde trae el marcador
            # `DEFAULT_VISIBILITY` y el buscador exige visibilidad pública
            # explícita. Una ficha creada para el directorio que nace sin ser
            # pública es una ficha que no existe para nadie.
            ("visibility_concept_id", backend_id("community:PROFILE_VISIBILITY_PUBLIC")),
            # El ACTIVE **del backend**, no el del paquete. Hay dos conceptos
            # con ese código —`CONCEPT_ACTIVE` es el ancla del catálogo boot y
            # `backend_id("state:active")` el que siembra la app— y el buscador
            # filtra por el segundo. Con el del paquete la ficha existe, es
            # pública, apunta bien... y no aparece en ninguna búsqueda.
            ("status_concept_id", backend_id("state:active")),
            *[(k, v) for k, v in perfil_molde.items()
              if k not in {"id", "tenant_id", "target_type_concept_id", "target_id",
                           "slug", "display_name", "headline", "biography",
                           "avatar_file_id", "cover_file_id",
                           "verification_status_concept_id", "visibility_concept_id",
                           "status_concept_id",
                           "created_at", "updated_at", "created_by_user_id",
                           "updated_by_user_id", "row_version"}],
            *auditoria]))
    return packs



def build_real_labs_and_clinics(docs) -> dict:
    """Laboratorios y clínicas reales, cada uno con su ficha pública y su dirección.

    Mismo camino que las farmacias, y por el mismo motivo: sin ficha con el tipo
    real, la visibilidad pública y el ACTIVE **del backend**, la entidad existe y
    no aparece en ninguna búsqueda. Los tres desajustes se descubrieron uno por
    uno probando contra la base viva.

    La dirección va como texto, sin coordenadas: la planilla no las trae y no se
    inventan. La consecuencia está asumida y es explícita — «los más cercanos»
    no los considera; aparecen en el directorio, que es lo que se pidió.

    Las clínicas entran como `directory.tenants` y no como una entidad propia: el
    modelo no tiene «clínica», tiene organizaciones que prestan servicios. La
    ficha pública las declara `PROFILE_TARGET_ORGANIZATION`, que es el tipo con
    el que el buscador las agrupa.
    """
    packs = {"tenants": [], "diagnostic_units": [], "identifiers": [],
             "addresses": [], "public_profiles": []}

    tenant_molde = docs["04"]["mock"]["records"]["tenants"][0]
    addr_molde = docs["02"]["mock"]["records"]["addresses"][0]
    unidad_molde = docs["23"]["mock"]["records"]["diagnostic_units"][0]
    perfil_molde = docs["19"]["mock"]["records"]["public_profiles"][0]

    def new_id(table: str, *parts) -> str:
        return stable_uuid("SALUD", PATCH_V416, "mock", table, "id", *parts)

    def comunes(codigo, prefijo, entrada, target_key, target_id, headline):
        base = det_time(MOCK_BASE, prefijo, codigo)
        stamp = iso(base)
        tenant_id = new_id("directory.tenants", prefijo, codigo)
        auditoria = [("created_at", stamp), ("updated_at", stamp),
                     ("created_by_user_id", SEED_USER_ID),
                     ("updated_by_user_id", SEED_USER_ID), ("row_version", 1)]

        packs["tenants"].append(OrderedDict([
            ("id", tenant_id), ("code", prefijo + "_" + codigo),
            ("tenant_type_concept_id", backend_id("directory:tenant-type:provider")),
            ("legal_name", entrada["legal_name"]), ("trade_name", entrada["trade_name"]),
            ("legal_entity_type_concept_id", backend_id("directory:legal-entity:company")),
            ("status_concept_id", backend_id("directory:tenant-status:active")),
            ("verification_status_concept_id",
             backend_id("directory:tenant-verification:verified")),
            ("country_concept_id", JURISDICTION_CONCEPT_ID),
            ("jurisdiction_concept_id", JURISDICTION_CONCEPT_ID),
            ("data_residency_region_concept_id",
             tenant_molde["data_residency_region_concept_id"]),
            ("currency_concept_id", tenant_molde["currency_concept_id"]),
            ("time_zone", "America/La_Paz"), ("parent_tenant_id", None),
            *auditoria]))

        if entrada.get("nit"):
            packs["identifiers"].append(OrderedDict([
                ("id", new_id("common.identifiers", prefijo, codigo)),
                ("owner_type_concept_id", backend_id("common:owner-type:tenant")),
                ("owner_id", tenant_id),
                ("use_concept_id", backend_id("common:use:official")),
                ("type_concept_id", backend_id("common:id-type:tax")),
                ("system", None), ("value", entrada["nit"]),
                ("issuer_country_concept_id", JURISDICTION_CONCEPT_ID),
                ("assigner_tenant_id", None),
                ("valid_from", base.date().isoformat()), ("valid_to", None),
                ("state_concept_id", backend_id("state:active")),
                *auditoria]))

        if entrada.get("lines"):
            packs["addresses"].append(OrderedDict([
                ("id", new_id("common.addresses", prefijo, codigo)),
                ("owner_type_concept_id", backend_id("common:owner-type:tenant")),
                ("owner_id", tenant_id),
                ("use_concept_id", addr_molde["use_concept_id"]),
                ("type_concept_id", addr_molde["type_concept_id"]),
                ("lines", entrada["lines"]), ("city", "Santa Cruz de la Sierra"),
                ("administrative_area_concept_id",
                 addr_molde["administrative_area_concept_id"]),
                ("postal_code", None),
                ("country_concept_id", JURISDICTION_CONCEPT_ID),
                # Sin coordenadas: la planilla no las trae. Es lo que deja a
                # estas sedes fuera de «la más cercana», y está asumido.
                ("latitude", None), ("longitude", None),
                ("valid_from", base.date().isoformat()), ("valid_to", None),
                *auditoria]))

        perfil_id = new_id("community.public_profiles", prefijo, codigo)
        packs["public_profiles"].append(OrderedDict([
            ("id", perfil_id), ("tenant_id", tenant_id),
            ("target_type_concept_id", backend_id(target_key)),
            ("target_id", target_id or tenant_id),
            ("slug", slug_de(entrada["trade_name"])),
            ("display_name", entrada["trade_name"]),
            ("headline", headline),
            ("biography", None),
            ("avatar_file_id", None), ("cover_file_id", None),
            ("verification_status_concept_id",
             perfil_molde["verification_status_concept_id"]),
            ("visibility_concept_id", backend_id("community:PROFILE_VISIBILITY_PUBLIC")),
            ("status_concept_id", backend_id("state:active")),
            *[(k, v) for k, v in perfil_molde.items()
              if k not in {"id", "tenant_id", "target_type_concept_id", "target_id",
                           "slug", "display_name", "headline", "biography",
                           "avatar_file_id", "cover_file_id",
                           "verification_status_concept_id", "visibility_concept_id",
                           "status_concept_id",
                           "created_at", "updated_at", "created_by_user_id",
                           "updated_by_user_id", "row_version"}],
            *auditoria]))
        return tenant_id, perfil_id, auditoria

    for lab in LABORATORIOS_BOLIVIA:
        unidad_id = new_id("diagnostic_units.diagnostic_units", lab["code"])
        tenant_id, perfil_id, auditoria = comunes(
            lab["code"], "LAB", lab,
            "community:PROFILE_TARGET_DIAGNOSTIC_UNIT", unidad_id, "Laboratorio")
        packs["diagnostic_units"].append(OrderedDict([
            ("id", unidad_id), ("tenant_id", tenant_id),
            ("practice_id", unidad_molde["practice_id"]),
            ("primary_practice_site_id", unidad_molde["primary_practice_site_id"]),
            ("code", lab["code"]), ("name", lab["trade_name"]),
            ("diagnostic_unit_type_concept_id",
             unidad_molde["diagnostic_unit_type_concept_id"]),
            ("ownership_type_concept_id", unidad_molde["ownership_type_concept_id"]),
            ("public_profile_id", perfil_id),
            ("accepts_external_orders", True), ("walk_in_available", True),
            ("home_collection_available", False),
            ("verification_status_concept_id",
             unidad_molde["verification_status_concept_id"]),
            ("status_concept_id", unidad_molde["status_concept_id"]),
            *auditoria]))

    for clin in CLINICAS_BOLIVIA:
        comunes(clin["code"], "CLI", clin,
                "community:PROFILE_TARGET_ORGANIZATION", None, "Clínica")

    return packs



# --- directorio oficial de salud de Bolivia (BOOT) --------------------------
# Fuente: `salud-db/data/directorio-oficial/`, que arma `build_directorio_oficial.py`
# desde AGEMED (farmacias vigentes al 01/10/2026), el RUES 2026 (MSyD/SNIS) y
# Overture Places (CDLA-Permissive-2.0 / Apache-2.0 / CC0). Va a BOOT porque es
# dato público y real: el directorio de producción lo necesita y no hay nada de
# demostración en él.
#
# Estados (los del backend, porque son los que el buscador compara):
# - tenant AGEMED y RUES → `DIR_TENANT_REGISTRY_LISTED`: existe porque un padrón
#   oficial lo lista y nadie lo administra todavía. Overture → `DIR_TENANT_UNVERIFIED`.
#   Ninguno se marca «verificado»: AloVida no verificó a nadie.
# - ficha pública → visible y ACTIVE del backend (`state:active`); sin eso no
#   aparece en ninguna búsqueda.
# - el nº de resolución de AGEMED es la licencia de funcionamiento de la farmacia
#   (`pharmacy_licenses`), y el código RUES va en `tenants.code` (`RUES_<código>`).
# - la FARMACIA y su LICENCIA van `VERIFICATION_VERIFIED`: lo que se verifica de una
#   farmacia es su habilitación, y ésta figura en la lista vigente del ente regulador
#   (AGEMED, 01/10/2026). Sin eso el directorio —que sólo muestra verificadas— no
#   las ve. El TENANT sigue «listado en registro oficial»: nadie lo reclamó.
# - laboratorios e imagen de Overture quedan `VERIFICATION_PENDING`: no los verificó
#   nadie, y el buscador de centros exige verificación. Aparecen en la búsqueda
#   pública general por su ficha.

DIRECTORIO_DIR = paths.DATA_DIR / "directorio-oficial"

DIRECTORIO_HEADLINE = {
    "PHARMACY": "Farmacia",
    "LABORATORY": "Laboratorio clínico",
    "IMAGING": "Centro de diagnóstico por imagen",
    "CLINIC": "Consultorio o clínica",
    "DENTAL": "Consultorio odontológico",
}


def _titulo(texto: str) -> str:
    """«FARMACIA SAN JUAN» → «Farmacia San Juan»; respeta lo que ya trae minúsculas."""
    if not texto or texto != texto.upper():
        return texto
    menores = {"de", "del", "la", "las", "los", "y", "e", "el", "en", "para", "por", "con"}
    palabras = texto.lower().split()
    return " ".join(p if i and p in menores else p[:1].upper() + p[1:] for i, p in enumerate(palabras))


def build_official_directory(docs, value_sets) -> dict:
    """El directorio oficial como filas BOOT, cada una con su ficha pública y su dirección."""
    packs = {"tenants": [], "addresses": [], "pharmacies": [], "pharmacy_licenses": [],
             "diagnostic_units": [], "public_profiles": []}
    if not DIRECTORIO_DIR.exists():
        return packs
    leer = lambda nombre: json.loads((DIRECTORIO_DIR / nombre).read_text(encoding="utf-8"))
    registros = ([("AGEMED", r) for r in leer("farmacias-agemed.json")]
                 + [("RUES", r) for r in leer("establecimientos-rues.json")]
                 + [("OVT", r) for r in leer("lugares-overture.json")])

    tenant_molde = docs["04"]["boot"]["records"]["tenants"][0]
    addr_molde = docs["02"]["mock"]["records"]["addresses"][0]
    perfil_molde = docs["19"]["mock"]["records"]["public_profiles"][0]
    vs_dep, vs_mun = value_sets["vs_administrative_area"], value_sets["vs_bo_municipality"]
    municipios = {c.upper() for c in vs_mun["codes"]}
    nombre_municipio = VS_DISPLAY["vs_bo_municipality"]

    def new_id(table: str, *parts) -> str:
        return stable_uuid("SALUD", PATCH_DIRECTORIO, "boot", table, "id", *parts)

    stamp = iso(BOOT_BASE)
    auditoria = [("created_at", stamp), ("updated_at", stamp),
                 ("created_by_user_id", SEED_USER_ID),
                 ("updated_by_user_id", SEED_USER_ID), ("row_version", 1)]

    # Los slugs ocupados por OTRAS fichas. Las del propio directorio se excluyen:
    # en una regeneración ya están en el paquete, y contarlas les agregaría un
    # «-2» a todas (el generador dejaría de ser idempotente).
    propias = {new_id("community.public_profiles", r["id"]) for _, r in registros}
    usados = {r.get("slug") for code in docs for sec in ("boot", "mock")
              for r in docs[code].get(sec, {}).get("records", {}).get("public_profiles", [])
              if r.get("id") not in propias}

    def slug_unico(nombre: str, municipio: str | None, clave: str) -> str:
        base = slug_de(f"{nombre} {municipio or ''}")[:110]
        slug, n = base, 1
        while slug in usados:
            n += 1
            slug = f"{base}-{n}"
        usados.add(slug)
        return slug

    for origen, r in sorted(registros, key=lambda x: (x[0], x[1]["id"])):
        clave = r["id"]
        nombre = _titulo(r["name"])
        tenant_id = new_id("directory.tenants", clave)
        perfil_id = new_id("community.public_profiles", clave)
        listado = "directory:TENANT_REGISTRY_LISTED" if origen in ("AGEMED", "RUES") else "directory:TENANT_UNVERIFIED"
        codigo = {"AGEMED": "AGEMED_" + clave.split("-", 1)[1].upper(),
                  "RUES": "RUES_" + r.get("officialCode", clave),
                  "OVT": "OVT_" + clave.split("-", 1)[1][:32].upper()}[origen]
        packs["tenants"].append(OrderedDict([
            ("id", tenant_id), ("code", codigo),
            ("tenant_type_concept_id", backend_id("directory:tenant-type:provider")),
            ("legal_name", nombre), ("trade_name", nombre),
            ("legal_entity_type_concept_id", backend_id("directory:legal-entity:company")),
            ("status_concept_id", backend_id("directory:tenant-status:active")),
            ("verification_status_concept_id", backend_id(listado)),
            ("country_concept_id", JURISDICTION_CONCEPT_ID),
            ("jurisdiction_concept_id", JURISDICTION_CONCEPT_ID),
            ("data_residency_region_concept_id", tenant_molde["data_residency_region_concept_id"]),
            ("currency_concept_id", tenant_molde["currency_concept_id"]),
            ("time_zone", "America/La_Paz"), ("parent_tenant_id", None),
            *auditoria]))

        mun_code = r.get("municipalityCode")
        mun_code = mun_code if mun_code and mun_code.upper() in municipios else None
        if r.get("address") or mun_code or r.get("latitude") is not None:
            packs["addresses"].append(OrderedDict([
                ("id", new_id("common.addresses", clave)),
                ("owner_type_concept_id", backend_id("common:owner-type:tenant")),
                ("owner_id", tenant_id),
                ("use_concept_id", addr_molde["use_concept_id"]),
                ("type_concept_id", addr_molde["type_concept_id"]),
                ("lines", r.get("address")),
                ("city", nombre_municipio.get(mun_code) if mun_code else r.get("municipalityText")),
                ("administrative_area_concept_id",
                 concept_id("vs_administrative_area", r["department"], vs_dep) if r.get("department") else None),
                ("municipality_concept_id", concept_id("vs_bo_municipality", mun_code, vs_mun) if mun_code else None),
                ("postal_code", None),
                ("country_concept_id", JURISDICTION_CONCEPT_ID),
                ("latitude", r.get("latitude")), ("longitude", r.get("longitude")),
                ("valid_from", BOOT_BASE.date().isoformat()), ("valid_to", None),
                *auditoria]))

        kind = r["kind"]
        if kind == "PHARMACY":
            target_key, target_id = "community:PROFILE_TARGET_PHARMACY", new_id("pharmacy.pharmacies", clave)
            packs["pharmacies"].append(OrderedDict([
                ("id", target_id), ("tenant_id", tenant_id), ("code", codigo),
                ("legal_name", nombre), ("trade_name", nombre),
                ("pharmacy_type_concept_id", backend_id("pharmacy:PHARMACY_TYPE_RETAIL")),
                ("ownership_type_concept_id",
                 backend_id("pharmacy:OWNERSHIP_PRIVATE") if "PRIVADA" in (r.get("subtype") or "").upper() else None),
                ("public_profile_id", perfil_id),
                ("default_currency_concept_id", tenant_molde["currency_concept_id"]),
                ("verification_status_concept_id", backend_id("pharmacy:VERIFICATION_VERIFIED")),
                ("status_concept_id", backend_id("pharmacy:PHARMACY_ACTIVE")),
                *auditoria]))
            if r.get("license"):
                packs["pharmacy_licenses"].append(OrderedDict([
                    ("id", new_id("pharmacy.pharmacy_licenses", clave)),
                    ("pharmacy_id", target_id), ("pharmacy_site_id", None),
                    ("license_type_concept_id", backend_id("pharmacy:LICENSE_TYPE_OPERATING")),
                    ("license_number", r["license"]["number"]),
                    ("issuing_authority_tenant_id", None),
                    ("jurisdiction_concept_id", JURISDICTION_CONCEPT_ID),
                    ("valid_from", None), ("valid_to", None), ("evidence_file_id", None),
                    # La resolución figura en la lista vigente de AGEMED: verificada contra el regulador.
                    ("verification_status_concept_id", backend_id("pharmacy:VERIFICATION_VERIFIED")),
                    *auditoria]))
        elif kind in ("LABORATORY", "IMAGING"):
            target_key, target_id = "community:PROFILE_TARGET_DIAGNOSTIC_UNIT", new_id("diagnostic_units.diagnostic_units", clave)
            packs["diagnostic_units"].append(OrderedDict([
                ("id", target_id), ("tenant_id", tenant_id),
                ("practice_id", None), ("primary_practice_site_id", None),
                ("code", codigo), ("name", nombre),
                ("diagnostic_unit_type_concept_id",
                 backend_id("diagnostic_units:UNIT_TYPE_IMAGING" if kind == "IMAGING" else "diagnostic_units:UNIT_TYPE_LABORATORY")),
                ("ownership_type_concept_id", None),
                ("public_profile_id", perfil_id),
                # La fuente no dice si atiende sin cita, a domicilio u órdenes externas.
                ("accepts_external_orders", None), ("walk_in_available", None), ("home_collection_available", None),
                ("verification_status_concept_id", backend_id("diagnostic_units:VERIFICATION_PENDING")),
                ("status_concept_id", backend_id("diagnostic_units:UNIT_ACTIVE")),
                *auditoria]))
        else:
            target_key, target_id = "community:PROFILE_TARGET_ORGANIZATION", tenant_id

        headline = DIRECTORIO_HEADLINE.get(kind) or " · ".join(
            x for x in (_titulo(r.get("subtype") or ""), r.get("level"), r.get("subsector")) if x)
        packs["public_profiles"].append(OrderedDict([
            ("id", perfil_id), ("tenant_id", tenant_id),
            ("target_type_concept_id", backend_id(target_key)),
            ("target_id", target_id),
            ("slug", slug_unico(nombre, nombre_municipio.get(mun_code) if mun_code else r.get("municipalityText"), clave)),
            ("display_name", nombre),
            ("headline", headline[:200]),
            ("biography", None),
            ("avatar_file_id", None), ("cover_file_id", None),
            ("verification_status_concept_id", backend_id(listado)),
            ("visibility_concept_id", backend_id("community:PROFILE_VISIBILITY_PUBLIC")),
            ("accepts_reviews", perfil_molde.get("accepts_reviews", True)),
            ("comments_default_enabled", perfil_molde.get("comments_default_enabled", True)),
            ("status_concept_id", backend_id("state:active")),
            *auditoria]))
    return packs


def slug_de(nombre: str) -> str:
    """Slug ASCII estable para la ruta corta de la ficha pública."""
    base = unicodedata.normalize("NFKD", nombre).encode("ascii", "ignore").decode().lower()
    limpio = re.sub(r"[^a-z0-9]+", "-", base).strip("-")
    return limpio or "ficha"


def repoint_carrier_references(docs, carrier_ids) -> int:
    """Repunta a las aseguradoras reales las filas del módulo 26 que colgaban de las demo.

    Determinista (índice de fila módulo N), no al azar: la fase 2b repararía estos
    huérfanos igual, pero eligiendo destino con `pick()` — y el reparto quedaría
    distinto en cada regeneración desde cero.
    """
    validos = set(carrier_ids)
    repuntadas = 0
    for entity in CARRIER_DEPENDENT_TABLES:
        for i, row in enumerate(docs["26"]["mock"]["records"].get(entity, [])):
            if row.get("insurance_carrier_id") not in validos:
                row["insurance_carrier_id"] = carrier_ids[i % len(carrier_ids)]
                repuntadas += 1
    return repuntadas


def align_role_states(docs) -> int:
    """Los roles del paquete pasan al ACTIVE del backend, que es el que la app compara.

    `ensureRoleByCode` y `effectiveRoleCodes` filtran por `stateConceptId ==
    CONCEPTS.STATE_ACTIVE` — el ACTIVE **del backend** (`38a1d301-…`), no el del catálogo
    SALUD_CORE (`d0f53ea3-…`) con el que el paquete sembraba `authz.roles`. El síntoma
    medido: el alta asistida del médico moría con 422 «Alguno de los roles indicados no
    existe o no es asignable» porque `PRACTITIONER` existía, activo y asignable… con el
    ACTIVE equivocado, y el guard de la app (`findOne({code})`) lo encontraba por código
    y nunca corregía el estado. Un rol del paquete que la app no pueda ver no es un rol:
    es una fila que bloquea el código por la clave única y no sirve por el filtro.
    """
    canonical = backend_id("state:active")
    aligned = 0
    for section in ("boot", "mock"):
        for row in docs["06"].get(section, {}).get("records", {}).get("roles", []):
            if row.get("state_concept_id") != canonical:
                row["state_concept_id"] = canonical
                aligned += 1
    return aligned


# ============================================================ fase 2d · identidades del mock

# --- v4.0.11 · el elenco de la demo, curado -------------------------------
# El paquete original venía de `seedsGenerales/tools/generate-deep-seeds.py` (herramienta
# muerta) y dejó tres defectos que la analista reportó como si fueran bugs de la Guía:
#   1. `professional_title` con el NOMBRE DE OTRA PERSONA («Ana Lucía Flores» con subtítulo
#      «Dra. Camila Roca — Medicina Familiar»). El título es un cargo, no una firma.
#   2. Cuatro personas bautizadas «(caso 12…15)» por el bucle genérico.
#   3. 16 perfiles profesionales para 12 personas: cuatro `profile_id` repetidos que la PK
#      descartaba al cargar, así que cuatro médicos no existían en ninguna base.
# Se corrige acá, en el generador, y no en el JSON: el JSON es salida.

# Las cuatro personas que el bucle genérico dejó como clon numerado de otra.
CURATED_PERSON_RENAMES = {
    "bbc6e86d-8c32-5d7f-a4b7-d4957a886360": "Patricia Arce Delgado",
    "f5b58396-48cc-5330-8fb4-92005e653f52": "Hugo Salazar Ibáñez",
    "102d8be9-3dee-5822-bc4a-88b9a1ee90b4": "Lucía Fernández Prado",
    "201bc952-659d-5c81-881e-01958b805420": "Marco Terrazas Quispe",
}

# El elenco, en el orden en que el paquete declara los perfiles. Por fila:
#   código original → (código final, titular, cargo, especialidad del value set)
# El titular es explícito —no posicional— justamente porque cuatro filas cambian de dueño:
# a los duplicados se les da una de las cuatro personas que existían sin perfil profesional.
# El cargo concuerda en género con su titular: es texto que el paciente lee.
CURATED_PRACTITIONERS = OrderedDict([
    ("HEALTH_PRACTITIONER_PROFILES_01", dict(
        code="HEALTH_PRACTITIONER_PROFILES_01", owner="8735e28d-0653-534f-ae66-28e41eab576a",
        title="Médica de familia", specialty="medicina_familiar")),
    ("HEALTH_PRACTITIONER_PROFILES_02", dict(
        code="HEALTH_PRACTITIONER_PROFILES_02", owner="ac4ba573-eb80-5309-8d28-2601980b807d",
        title="Cardiólogo", specialty="cardiologia")),
    ("HEALTH_PRACTITIONER_PROFILES_03", dict(
        code="HEALTH_PRACTITIONER_PROFILES_03", owner="72f7e074-ae52-56d2-b3b6-19c01b275033",
        title="Pediatra", specialty="pediatria")),
    ("HEALTH_PRACTITIONER_PROFILES_04", dict(
        code="HEALTH_PRACTITIONER_PROFILES_04", owner="b8c5ba6c-b3e4-5de1-8163-dcf4f95bd1b1",
        title="Cirujano general", specialty="cirugia_general")),
    ("HEALTH_PRACTITIONER_PROFILES_05", dict(
        code="HEALTH_PRACTITIONER_PROFILES_05", owner="10f5acc0-6a19-5bba-a971-761a1553ec2b",
        title="Licenciado en enfermería", specialty="enfermeria")),
    ("HEALTH_PRACTITIONER_PROFILES_06", dict(
        code="HEALTH_PRACTITIONER_PROFILES_06", owner="907f074b-4f6b-57d3-8c7e-e76c34835699",
        title="Radiólogo", specialty="radiologia")),
    ("HEALTH_PRACTITIONER_PROFILES_07", dict(
        code="HEALTH_PRACTITIONER_PROFILES_07", owner="f5b58396-48cc-5330-8fb4-92005e653f52",
        title="Anestesiólogo", specialty="anestesiologia")),
    ("HEALTH_PRACTITIONER_PROFILES_08", dict(
        code="HEALTH_PRACTITIONER_PROFILES_08", owner="102d8be9-3dee-5822-bc4a-88b9a1ee90b4",
        title="Bioquímica clínica", specialty="bioquimica_clinica")),
    ("HEALTH_PRACTITIONER_PROFILES_09", dict(
        code="HEALTH_PRACTITIONER_PROFILES_09", owner="0442dc53-9060-5413-9863-194f4dbde7be",
        title="Médica internista", specialty="medicina_interna")),
    ("HEALTH_PRACTITIONER_PROFILES_10", dict(
        code="HEALTH_PRACTITIONER_PROFILES_10", owner="f1207111-467a-52d8-af08-17a1de8bb5fb",
        title="Traumatólogo", specialty="traumatologia")),
    ("HEALTH_PRACTITIONER_PROFILES_11", dict(
        code="HEALTH_PRACTITIONER_PROFILES_11", owner="201bc952-659d-5c81-881e-01958b805420",
        title="Cardiólogo", specialty="cardiologia")),
    ("HEALTH_PRACTITIONER_PROFILES_12", dict(
        code="HEALTH_PRACTITIONER_PROFILES_12", owner="d978b3e3-ce58-57bf-9c17-bfe88d3802c2",
        title="Gastroenterólogo", specialty="gastroenterologia")),
    # Las cuatro filas que venían duplicando titular. Reciben las personas que el paquete
    # tenía sin perfil profesional, y el código pasa a continuar la serie (13…16) en vez
    # de repetirla con un cero de más (`_012` convivía con `_12`).
    ("HEALTH_PRACTITIONER_PROFILES_012", dict(
        code="HEALTH_PRACTITIONER_PROFILES_13", owner="0b4b1518-1a68-5919-ac58-510e2b687a5e",
        title="Ginecóloga y obstetra", specialty="ginecologia_obstetricia")),
    ("HEALTH_PRACTITIONER_PROFILES_013", dict(
        code="HEALTH_PRACTITIONER_PROFILES_14", owner="7381f103-6c7e-58a4-b2f9-c52def70c616",
        title="Dermatóloga", specialty="dermatologia")),
    ("HEALTH_PRACTITIONER_PROFILES_014", dict(
        code="HEALTH_PRACTITIONER_PROFILES_15", owner="bbc6e86d-8c32-5d7f-a4b7-d4957a886360",
        title="Psiquiatra", specialty="psiquiatria")),
    ("HEALTH_PRACTITIONER_PROFILES_015", dict(
        code="HEALTH_PRACTITIONER_PROFILES_16", owner="3a0dc1aa-6f41-5270-a8d3-15bae71cc6d9",
        title="Endocrinóloga", specialty="endocrinologia")),
])


def phase_curate_identities(docs, value_sets) -> dict:
    """Sanea el elenco del mock: nombres propios, cargos reales y un titular por perfil.

    Es una fase **mutadora**, no aditiva: `upsert_rows` sólo agrega por PK nueva, y lo que
    hay que corregir son filas que ya existen. No toca ningún `id`, así que ninguna PK se
    rederiva y `--refresh` la aplica como UPDATE; lo único que cambia de dueño es
    `profile_id` en las cuatro filas que lo repetían, y su destino son personas que ya
    estaban en el paquete.

    De paso ata cada profesional a su especialidad —el value set nace en v4.0.11— y le abre
    la vigencia: las 16 filas traían `valid_to` con fecha pasada y la lectura descarta las
    no vigentes, así que la Guía agrupaba a los 34 bajo «Sin especialidad registrada».
    """
    doc05 = docs["05"]
    mock = doc05["mock"]["records"]
    stats = OrderedDict()
    vs_meta = value_sets.get("vs_medical_specialty")

    # 1 · personas con nombre propio, no «(caso NN)»
    renamed = 0
    for row in mock.get("persons", []):
        nuevo = CURATED_PERSON_RENAMES.get(row.get("id"))
        if nuevo and row.get("display_name") != nuevo:
            row["display_name"] = nuevo
            renamed += 1
    if renamed:
        stats["profiles.persons.display_name"] = renamed

    # 2 · perfiles: titular único, código correlativo y cargo en vez de firma ajena
    titulares, cargos, codigos = 0, 0, 0
    orden = []                      # (fila, spec) en el orden del paquete, para las hijas
    for row in mock.get("health_practitioner_profiles", []):
        spec = CURATED_PRACTITIONERS.get(row.get("practitioner_code"))
        if spec is None:
            continue
        orden.append((row, spec))
        if row.get("profile_id") != spec["owner"]:
            row["profile_id"] = spec["owner"]
            titulares += 1
        if row.get("practitioner_code") != spec["code"]:
            row["practitioner_code"] = spec["code"]
            codigos += 1
        if row.get("professional_title") != spec["title"]:
            row["professional_title"] = spec["title"]
            cargos += 1
    if titulares:
        stats["profiles.health_practitioner_profiles.profile_id"] = titulares
    if codigos:
        stats["profiles.health_practitioner_profiles.practitioner_code"] = codigos
    if cargos:
        stats["profiles.health_practitioner_profiles.professional_title"] = cargos

    # 3 · una especialidad vigente por profesional, la que dice su cargo
    if vs_meta:
        filas = mock.get("practitioner_specialties", [])
        atadas = 0
        for (perfil, spec), fila in zip(orden, filas):
            cid = concept_id("vs_medical_specialty", spec["specialty"], vs_meta)
            cambios = {"practitioner_profile_id": perfil["profile_id"],
                       "specialty_concept_id": cid, "is_primary": True,
                       "practice_scope_text": spec["title"], "valid_to": None}
            if any(fila.get(k) != v for k, v in cambios.items()):
                fila.update(cambios)
                atadas += 1
        if atadas:
            stats["profiles.practitioner_specialties"] = atadas

    # 4 · el espejo del buscador (módulo 57) repetía los mismos nombres cruzados
    busqueda = docs["57"]["mock"]["records"].get("provider_directory_search_docs", [])
    personas = {r["id"]: r.get("display_name") for r in mock.get("persons", [])}
    espejadas = 0
    for (perfil, spec), fila in zip(orden, busqueda):
        etiqueta = "{} — {}".format(personas.get(perfil["profile_id"], ""),
                                    vs_display("vs_medical_specialty", spec["specialty"]))
        if (fila.get("display_name") != etiqueta
                or fila.get("practitioner_profile_id") != perfil["profile_id"]):
            fila["display_name"] = etiqueta
            fila["practitioner_profile_id"] = perfil["profile_id"]
            espejadas += 1
    if espejadas:
        stats["search_platform.provider_directory_search_docs"] = espejadas
    return stats


def phase_tables(docs, ddl, fks, value_sets, uniques) -> dict:
    """boot/mock de las 24 tablas nuevas, en orden de dependencia."""
    retiradas = retire_v414_carrier_rows(docs)
    id_index = build_id_index(docs)
    generic_concepts = [r["id"] for r in docs["03"]["boot"]["records"]["catalog_concepts"]]
    concepts_by_vs = {n: [concept_id(n, c, m) for c in m["codes"]]
                      for n, m in value_sets.items()}
    vf = ValueFactory(ddl, fks, id_index, concepts_by_vs, generic_concepts)
    stats = OrderedDict()
    if retiradas:
        stats["directory.* (aseguradoras v4.1.4 retiradas)"] = retiradas

    # el catálogo de planes va primero: sus hijas dependen de los 3 planes canónicos
    plan_pack = canonical_plans(vf, docs["42"], value_sets)
    for entity in ("subscription_plans", "plan_prices", "plan_features",
                   "plan_quotas", "plan_eligibility_rules"):
        n = upsert_rows(docs["42"], "boot", entity, plan_pack[entity])
        if n:
            stats["payments." + entity] = n
        id_index.setdefault("payments." + entity, []).extend(
            r["id"] for r in plan_pack[entity])
        if entity != "subscription_plans":
            ensure_policy(docs["42"], entity, ddl["payments." + entity], "id",
                          uniques.get("payments." + entity, []), "RELATIONAL_TABLE", True, False)

    for tkey, cfg in NEW_TABLES.items():
        entity = tkey.split(".")[1]
        if entity in plan_pack or cfg.get("custom"):
            continue
        doc = docs[cfg["module"]]
        section, pk = cfg["section"], PK_OF.get(tkey, "id")
        rows = [vf.row(tkey, section, i, vs_map=cfg.get("vs"),
                       overrides=v408_overrides(cfg, tkey, section, pk, i), pk=pk)
                for i in range(1, ROWS_PER_TABLE + 1)]
        n = upsert_rows(doc, section, entity, rows, pk=pk)
        if n:
            stats[tkey] = n
        id_index.setdefault(tkey, []).extend(r[pk] for r in rows)
        ensure_policy(doc, entity, ddl[tkey], pk, uniques.get(tkey, []),
                      "LOG" if entity.endswith("_events") else "RELATIONAL_TABLE",
                      section == "boot", section == "mock")

    # D-05: la política de firma de recetas va por builder canónico (una comodín
    # `signature_required=true` por tenant del paquete, en boot y mock).
    policy_key = "clinical.prescription_signature_policies"
    policy_pack = canonical_signature_policies(docs)
    for section in ("boot", "mock"):
        n = upsert_rows(docs["08"], section, "prescription_signature_policies",
                        policy_pack[section])
        if n:
            stats[policy_key] = stats.get(policy_key, 0) + n
        id_index.setdefault(policy_key, []).extend(
            r["id"] for r in policy_pack[section])
    ensure_policy(docs["08"], "prescription_signature_policies", ddl[policy_key],
                  "id", uniques.get(policy_key, []), "RELATIONAL_TABLE", True, True)

    # v4.0.11 · el directorio de laboratorios reemplaza lo que produjo el bucle genérico.
    lab_pack = canonical_diagnostic_units(docs, value_sets)
    for entity, rows in lab_pack.items():
        tkey = "diagnostic_units." + entity
        n = replace_rows(docs["23"], "mock", entity, rows)
        if n:
            stats[tkey] = n
        id_index[tkey] = [r["id"] for r in rows]
        ensure_policy(docs["23"], entity, ddl[tkey], "id", uniques.get(tkey, []),
                      "RELATIONAL_TABLE", False, True)
    n = curate_diagnostic_addresses(docs)
    if n:
        stats["common.addresses (dirección de la unidad)"] = n

    # v4.1.4 · las aseguradoras reales de Bolivia reemplazan a las 12 demo del bucle
    # genérico; su tenant, NIT y domicilio se agregan (upsert) a los módulos 04 y 02.
    aseg_pack = canonical_insurance_carriers(docs, value_sets)
    n = replace_rows(docs["26"], "mock", "insurance_carriers",
                     aseg_pack["insurance_carriers"])
    if n:
        stats["insurance.insurance_carriers"] = n
    id_index["insurance.insurance_carriers"] = [
        r["id"] for r in aseg_pack["insurance_carriers"]]
    ensure_policy(docs["26"], "insurance_carriers",
                  ddl["insurance.insurance_carriers"], "id",
                  uniques.get("insurance.insurance_carriers", []),
                  "RELATIONAL_TABLE", False, True)
    for module, entity, tkey in (("04", "tenants", "directory.tenants"),
                                 ("02", "identifiers", "common.identifiers"),
                                 ("02", "addresses", "common.addresses")):
        # `update=True`: el dueño de estas filas es el builder, no el paquete.
        n = upsert_rows(docs[module], "mock", entity, aseg_pack[entity], update=True)
        if n:
            stats[tkey + " (aseguradoras)"] = n
        id_index.setdefault(tkey, []).extend(r["id"] for r in aseg_pack[entity])
    n = repoint_carrier_references(
        docs, [r["id"] for r in aseg_pack["insurance_carriers"]])
    if n:
        stats["insurance.* (insurance_carrier_id repuntadas)"] = n

    # --- v4.2.22 · las personas de contacto de cada aseguradora --------------
    # Va DESPUÉS del bloque de aseguradoras porque cuelga de sus tenants.
    contactos_pack = canonical_carrier_contacts(docs, value_sets)
    for module, entity, tkey in (
            ("05", "persons", "profiles.persons"),
            ("02", "contact_points", "common.contact_points"),
            ("02", "identifiers", "common.identifiers"),
            ("04", "tenant_legal_representatives",
             "directory.tenant_legal_representatives")):
        filas = contactos_pack[entity]
        if not filas:
            continue
        n = upsert_rows(docs[module], "mock", entity, filas, update=True)
        if n:
            stats[tkey + " (contactos de aseguradoras)"] = n
        id_index.setdefault(tkey, []).extend(r["id"] for r in filas)
        ensure_policy(docs[module], entity, ddl[tkey], "id",
                      uniques.get(tkey, []), "RELATIONAL_TABLE", False, True)

    # --- v4.1.6 · farmacias reales, con su ficha pública ---------------------
    farm_pack = build_real_pharmacies(docs, value_sets)
    for module, entity, tkey in (("04", "tenants", "directory.tenants"),
                                 ("02", "identifiers", "common.identifiers"),
                                 ("24", "pharmacies", "pharmacy.pharmacies"),
                                 ("19", "public_profiles", "community.public_profiles")):
        n = upsert_rows(docs[module], "mock", entity, farm_pack[entity])
        if n:
            stats[tkey + " (farmacias reales)"] = n
        id_index.setdefault(tkey, []).extend(r["id"] for r in farm_pack[entity])

    # --- v4.1.6 · laboratorios y clínicas reales ----------------------------
    lab_pack = build_real_labs_and_clinics(docs)
    for module, entity, tkey in (
            ("04", "tenants", "directory.tenants"),
            ("02", "identifiers", "common.identifiers"),
            ("02", "addresses", "common.addresses"),
            ("23", "diagnostic_units", "diagnostic_units.diagnostic_units"),
            ("19", "public_profiles", "community.public_profiles")):
        n = upsert_rows(docs[module], "mock", entity, lab_pack[entity])
        if n:
            stats[tkey + " (labs y clínicas reales)"] = n
        id_index.setdefault(tkey, []).extend(r["id"] for r in lab_pack[entity])
    # --- directorio oficial de salud de Bolivia (BOOT) ----------------------
    dir_pack = build_official_directory(docs, value_sets)
    for module, entity, tkey in (
            ("04", "tenants", "directory.tenants"),
            ("02", "addresses", "common.addresses"),
            ("24", "pharmacies", "pharmacy.pharmacies"),
            ("24", "pharmacy_licenses", "pharmacy.pharmacy_licenses"),
            ("23", "diagnostic_units", "diagnostic_units.diagnostic_units"),
            ("19", "public_profiles", "community.public_profiles")):
        n = upsert_rows(docs[module], "boot", entity, dir_pack[entity], update=True)
        if n:
            stats[tkey + " (directorio oficial)"] = n
        id_index.setdefault(tkey, []).extend(r["id"] for r in dir_pack[entity])
    return stats


# ============================================================ fase 3 · NOT NULL ausentes

def phase_notnull(docs, ddl, fks, value_sets) -> dict:
    """Rellena columnas NOT NULL sin default que faltan en filas ya sembradas.

    Es el defecto que hacía que load_seeds.py saltara el grupo entero de filas
    (insert_records: `missing = required - key_set` → continue) y dejara hijas
    huérfanas, impidiendo crear las FKs.
    """
    id_index = build_id_index(docs)
    generic_concepts = [r["id"] for r in docs["03"]["boot"]["records"]["catalog_concepts"]]
    concepts_by_vs = {n: [concept_id(n, c, m) for c in m["codes"]] for n, m in value_sets.items()}
    vf = ValueFactory(ddl, fks, id_index, concepts_by_vs, generic_concepts)
    fixed = OrderedDict()

    for code, doc in docs.items():
        schema = module_path(code).stem.split("_", 1)[1].replace(".seeds", "")
        for section in ("boot", "mock"):
            for entity, rows in doc.get(section, {}).get("records", {}).items():
                tkey = f"{schema}.{entity}"
                cols = ddl.get(tkey)
                if not cols or not rows:
                    continue
                required = [c for c, m in cols.items()
                            if m["not_null"] and not m["default"] and c in cols]
                for i, row in enumerate(rows):
                    for col in required:
                        lit = COLUMN_LITERALS.get(f"{tkey}.{col}")
                        if lit is not None and row.get(col) not in lit[1]:
                            row[col] = lit[0]
                            fixed[f"{tkey}.{col}"] = fixed.get(f"{tkey}.{col}", 0) + 1
                            continue
                        if col in row and row[col] is not None:
                            continue
                        v = vf.value(tkey, col, cols[col], None, (i,), section)
                        if v is None:
                            continue
                        row[col] = v
                        fixed[f"{tkey}.{col}"] = fixed.get(f"{tkey}.{col}", 0) + 1
    return fixed


# ============================================================ fase 4 · claves naturales

def _rename_mock_text_key(uk, boot_rows, mock_rows) -> int:
    """Sufija `_MOCK` en la fila mock que repite una clave natural de texto del boot."""
    fixed = 0
    taken = {tuple(str(r.get(c)) for c in uk) for r in boot_rows}
    for row in mock_rows:
        key = tuple(str(row.get(c)) for c in uk)
        if any(row.get(c) is None for c in uk) or key not in taken:
            continue
        col = uk[0]
        new, n = f"{row[col]}_MOCK", 2
        while tuple((new if c == col else str(row.get(c))) for c in uk) in taken:
            new, n = f"{row[col]}_MOCK{n}", n + 1
        row[col] = new
        taken.add(tuple((new if c == col else str(row.get(c))) for c in uk))
        fixed += 1
    return fixed


def _repoint_mock_fk_key(uk, fk_col, pool, boot_rows, mock_rows) -> int:
    """Reapunta la FK de la fila mock que repite la clave natural uuid de una boot.

    No se renombra nada: la fila mock pasa a referenciar otro padre libre, que es lo que
    el dato debía decir (una política por dataset, no dos por el mismo).
    """
    fixed = 0
    taken = {tuple(str(r.get(c)) for c in uk) for r in boot_rows}
    used = {r.get(fk_col) for r in boot_rows} | {r.get(fk_col) for r in mock_rows}
    for row in mock_rows:
        key = tuple(str(row.get(c)) for c in uk)
        if any(row.get(c) is None for c in uk) or key not in taken:
            continue
        free = next((p for p in pool if p not in used), None)
        if free is None:
            continue                     # sin padres libres: no se fuerza
        row[fk_col] = free
        used.add(free)
        taken.add(tuple(str(row.get(c)) for c in uk))
        fixed += 1
    return fixed


def phase_unique(docs, ddl, uniques, fks) -> dict:
    """Desambigua claves naturales que colisionan entre boot y mock.

    boot y mock cargan en la MISMA tabla física; el INSERT sin target
    (`ON CONFLICT DO NOTHING`) descartaba en silencio la fila mock que repetía
    el `code` de una boot, y sus hijas quedaban huérfanas en la BD.
    """
    id_index = build_id_index(docs)
    changed = OrderedDict()
    for code, doc in docs.items():
        schema = module_path(code).stem.split("_", 1)[1].replace(".seeds", "")
        for entity in set(doc.get("boot", {}).get("records", {})) | set(
                doc.get("mock", {}).get("records", {})):
            tkey = f"{schema}.{entity}"
            uks = uniques.get(tkey)
            cols = ddl.get(tkey)
            if not uks or not cols:
                continue
            boot_rows = doc.get("boot", {}).get("records", {}).get(entity, [])
            mock_rows = doc.get("mock", {}).get("records", {}).get(entity, [])
            if not boot_rows or not mock_rows:
                continue
            for uk in uks:
                if not all(c in cols for c in uk):
                    continue
                # texto: se sufija. uuid: NO se renombra (rompería la FK de la hija);
                # se reapunta la FK de la fila mock a otro padre.
                if all(cols[c]["type"].lower().startswith(("varchar", "text", "char")) for c in uk):
                    n, col = _rename_mock_text_key(uk, boot_rows, mock_rows), uk[0]
                else:
                    col = next((c for c in uk if fks.get(tkey, {}).get(c)), None)
                    pool = id_index.get(fks[tkey][col], []) if col else []
                    if not col or len(pool) < 2:
                        continue
                    n = _repoint_mock_fk_key(uk, col, pool, boot_rows, mock_rows)
                if n:
                    changed[f"{tkey}.{col}"] = changed.get(f"{tkey}.{col}", 0) + n
    return changed



# ============================================================ anclas y referencias

def assert_anchors(docs) -> None:
    """Las anclas del catálogo boot deben existir en el paquete.

    Sin esta guarda, una constante mal transcrita produce filas con FK irresoluble
    que solo se detectan al cargar la BD.
    """
    ids = {r["id"] for r in docs["03"]["boot"]["records"]["catalog_concepts"]}
    anchors = {"CONCEPT_ACTIVE": CONCEPT_ACTIVE, "LANGUAGE": LANGUAGE_CONCEPT_ID,
               "DESIGNATION_TYPE": DESIGNATION_TYPE_CONCEPT_ID,
               "JURISDICTION": JURISDICTION_CONCEPT_ID}
    bad = {k: v for k, v in anchors.items() if v not in ids}
    if bad:
        sys.exit("anclas inexistentes en el catálogo boot del módulo 03: {}".format(bad))
    versions = {r["id"] for r in docs["03"]["boot"]["records"]["code_system_versions"]}
    if CODE_SYSTEM_VERSION_ID not in versions:
        sys.exit("CODE_SYSTEM_VERSION_ID no existe en code_system_versions")
    users = {r["id"] for r in docs["01"]["boot"]["records"].get("users", [])}
    if users and SEED_USER_ID not in users:
        sys.exit("SEED_USER_ID no existe en el boot de iam.users")


OWNED_ENTITIES = (
    {t.split(".")[1] for t in NEW_TABLES}
    | {"value_sets", "value_set_versions", "value_set_members"}
    | {"dynamic_enum_definitions", "dynamic_enum_versions",
       "dynamic_enum_options", "dynamic_enum_bindings"}
)


def phase_refs(docs, ddl, fks, only_owned: bool = False) -> dict:
    """Repara referencias irresolubles: FK cuyo valor no existe como PK en el paquete.

    Es el defecto de fondo del paquete original: al amplificar filas, el generador viejo
    regeneraba la PK del padre pero dejaba las hijas apuntando al id anterior, y su
    validación lo enmascaraba metiendo todo id roto en una allowlist de "ids externos"
    derivada de los propios datos (por eso el paquete se auto-declaraba PASS).

    Si el padre no tiene ninguna fila en el paquete no se inventa nada: la columna se
    anula si es nullable y, si no, se reporta como pendiente.
    """
    id_index = build_id_index(docs)
    id_sets = {k: set(v) for k, v in id_index.items()}
    repaired, unresolved = OrderedDict(), OrderedDict()
    for code, doc in docs.items():
        schema = module_path(code).stem.split("_", 1)[1].replace(".seeds", "")
        for section in ("boot", "mock"):
            for entity, rows in doc.get(section, {}).get("records", {}).items():
                if only_owned and entity not in OWNED_ENTITIES:
                    continue
                tkey = f"{schema}.{entity}"
                cols, tfks = ddl.get(tkey), fks.get(tkey, {})
                if not cols:
                    continue
                for i, row in enumerate(rows):
                    for col, target in tfks.items():
                        v = row.get(col)
                        if v is None or not isinstance(v, str):
                            continue
                        if v in id_sets.get(target, ()):
                            continue
                        key = f"{tkey}.{col} → {target}"
                        cand = pick(id_index.get(target, []), tkey, col, i)
                        if cand is None:
                            if not cols[col]["not_null"]:
                                row[col] = None
                            unresolved[key] = unresolved.get(key, 0) + 1
                            continue
                        row[col] = cand
                        repaired[key] = repaired.get(key, 0) + 1
    return {"repaired": repaired, "unresolved": unresolved}


# ============================================================ fase 3b · tipos incompatibles

TIME_RE = re.compile(r"^\d{2}:\d{2}(:\d{2})?$")
DATE_RE = re.compile(r"^\d{4}-\d{2}-\d{2}$")
TS_RE = re.compile(r"^\d{4}-\d{2}-\d{2}[T ]\d{2}:\d{2}")
UUID_RE_STR = re.compile(r"^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$", re.I)
VARCHAR_LEN_RE = re.compile(r"^(?:varchar|character varying|char|character)\((\d+)\)$")
VECTOR_DIM_RE = re.compile(r"^vector\((\d+)\)$")


def is_number(value) -> bool:
    return isinstance(value, (int, float)) and not isinstance(value, bool)


def type_ok(value, ctype: str) -> bool:
    """¿El valor es cargable en esa columna? (mismo criterio que aplicaría PostgreSQL)."""
    t = ctype.lower().strip()
    if value is None:
        return True
    if t.endswith("[]"):
        return isinstance(value, list)
    m = VECTOR_DIM_RE.match(t)
    if m:
        # pgvector: literal de N floats. Un texto suelto lo rechaza con 22P02.
        return isinstance(value, list) and len(value) == int(m.group(1)) and all(
            is_number(x) for x in value)
    if t.startswith(("jsonb", "json")):
        return isinstance(value, (dict, list))
    if t.startswith("bool"):
        return isinstance(value, bool)
    if t.startswith(("integer", "int", "smallint", "bigint")):
        return isinstance(value, int) and not isinstance(value, bool)
    if t.startswith(("numeric", "decimal", "double", "real")):
        return isinstance(value, (int, float)) and not isinstance(value, bool)
    if t.startswith("uuid"):
        return isinstance(value, str) and bool(UUID_RE_STR.match(value))
    if t.startswith("time ") or t == "time" or t.startswith("time("):
        return isinstance(value, str) and bool(TIME_RE.match(value))
    if t.startswith("date"):
        return isinstance(value, str) and bool(DATE_RE.match(value))
    if t.startswith(("timestamptz", "timestamp")):
        return isinstance(value, str) and bool(TS_RE.match(value))
    m = VARCHAR_LEN_RE.match(t)
    if m:
        return isinstance(value, str) and len(value) <= int(m.group(1))
    if t.startswith(("varchar", "text", "character")):
        return isinstance(value, str)
    return True


def coerce(value, ctype: str, fallback):
    """Convierte lo convertible; si no, delega en el generador determinista."""
    t = ctype.lower().strip()
    if isinstance(value, str):
        if (t.startswith("time") and not t.startswith("timestamp")) and TS_RE.match(value):
            return value.split("T")[1][:8] if "T" in value else value.split(" ")[1][:8]
        if t.startswith("date") and TS_RE.match(value):
            return value[:10]
        m = VARCHAR_LEN_RE.match(t)
        if m:
            return value[: int(m.group(1))]
    return fallback


def phase_types(docs, ddl, fks, value_sets) -> dict:
    """Corrige valores que PostgreSQL rechazaría por tipo.

    Es la categoría «tipos incompatibles» del paquete original: placeholders de texto
    en columnas boolean, timestamps completos en columnas `time`, textos más largos que
    el `varchar(n)`. `load_seeds.py` los reportaba como aviso y perdía la entidad entera
    (savepoint por entidad), dejando el padre vacío y sus hijas sin FK.
    """
    id_index = build_id_index(docs)
    generic = [r["id"] for r in docs["03"]["boot"]["records"]["catalog_concepts"]]
    by_vs = {n: [concept_id(n, c, m) for c in m["codes"]] for n, m in value_sets.items()}
    vf = ValueFactory(ddl, fks, id_index, by_vs, generic)
    fixed = OrderedDict()
    for code, doc in docs.items():
        schema = module_path(code).stem.split("_", 1)[1].replace(".seeds", "")
        for section in ("boot", "mock"):
            for entity, rows in doc.get(section, {}).get("records", {}).items():
                tkey = f"{schema}.{entity}"
                cols = ddl.get(tkey)
                if not cols:
                    continue
                for i, row in enumerate(rows):
                    for col, meta in cols.items():
                        if col not in row or type_ok(row[col], meta["type"]):
                            continue
                        fb = vf.value(tkey, col, meta, None, (i,), section)
                        new = coerce(row[col], meta["type"], fb)
                        if not type_ok(new, meta["type"]):
                            new = fb if type_ok(fb, meta["type"]) else None
                        if new is None and meta["not_null"]:
                            continue
                        row[col] = new
                        k = f"{tkey}.{col} ({meta['type']})"
                        fixed[k] = fixed.get(k, 0) + 1
    return fixed


# ============================================================ fase 2c · cobertura de tablas

# Tablas relacionales que el paquete original no cubría. Se siembran con el mismo
# mecanismo que las tablas nuevas de los patches (ValueFactory + ensure_policy).
COVERAGE_TABLES = OrderedDict([
    # endpoints de contacto (email/teléfono normalizado): datos personales → mock
    ("crm.contact_channel_endpoints", dict(module="49", schema="crm", section="mock")),
])

# Tablas que deben quedar SIN filas, con el motivo. La fase de cobertura falla si
# aparece una tabla vacía que no esté acá ni en COVERAGE_TABLES: así un hueco nuevo
# se ve en la próxima corrida en vez de descubrirse cargando la base.
# v4.2.30 (cierre M7) — esquemas enteros cuyas filas las escribe el negocio o un worker, no
# el arranque. Se declaran por esquema y no tabla por tabla para que una tabla nueva del
# módulo no reabra el hueco de cobertura sin que nadie lo decida:
#   pharma_lab    31 tablas de visitadores, materiales y farmacovigilancia: datos de un
#                 laboratorio real, sin ningún catálogo de arranque (sus conceptos son de terminología).
#   data_catalog  lo llena el escáner (`worker-data_catalog`, ADR-0024) leyendo la base viva.
#   qa_execution  planes y ejecuciones de una corrida de QA: runtime puro.
INTENTIONALLY_EMPTY_SCHEMAS = {"pharma_lab", "data_catalog", "qa_execution"}

# Las historias de `audit.*` (`<<HISTORY>>`) las escribe el disparador al mutar la fila
# origen; sembrarlas falsearía un historial que nadie produjo.
def is_intentionally_empty(tkey: str) -> bool:
    schema, table = tkey.split(".", 1)
    return (tkey in INTENTIONALLY_EMPTY
            or schema in INTENTIONALLY_EMPTY_SCHEMAS
            or (schema == "audit" and table.endswith("_history")))


INTENTIONALLY_EMPTY = {
    # v4.2.30 — datos que crea un usuario o la app al operar (cotizaciones y cuotas,
    # respuestas automáticas y adjuntos de comentario, campañas y aliados de una
    # aseguradora, grupos médicos y su membresía, el estado de pago de una cita).
    # Sembrarlos daría pagos, campañas y grupos que nadie hizo.
    "billing.quotations",
    "billing.quotation_installments",
    "community.chat_auto_replies",
    "community.comment_media",
    "insurance.insurance_campaigns",
    "insurance.insurance_campaign_partners",
    "medical_groups.groups",
    "medical_groups.group_members",
    "scheduling.appointment_payment_states",
    # v4.0.11 — módulo 64. El catálogo de plantillas lo siembra la propia app al
    # arrancar (`AudioAssetsSeedService`), así que sembrarlo también desde el paquete
    # daría dos dueños del mismo catálogo con ids distintos y la resolución dependería
    # de cuál corrió último. Las otras tres son runtime puro: caché de binarios,
    # bitácora de intentos y contadores de consumo del proveedor.
    "audio_assets.audio_templates",
    "audio_assets.audio_assets",
    "audio_assets.audio_generation_events",
    "audio_assets.audio_generation_usage",
    # stub declarado solo con su PK en el .puml, para que otras tablas lo referencien
    "authz.service_principals",
    # v4.2.1 — la propuesta de sustitución la emite la FARMACIA al revisar un pedido
    # concreto: es una oferta comercial sobre el renglón de alguien, con su precio y su
    # decisión pendiente. Sembrarla daría propuestas que ninguna farmacia hizo, sobre
    # pedidos de gente real, esperando una respuesta que nadie pidió.
    "pharmacy_inventory.pharmacy_order_substitutions",
    # v4.1.7 — los favoritos de prescripción los crea CADA profesional desde su propia
    # receta: son su lista personal, no contenido de arranque. Sembrarlos daría atajos
    # de tipeo que nadie guardó, con el rótulo de otro, en la lista de gente real.
    "clinical_ext.prescription_favorites",
    # v4.0.9 — tokens de un solo uso que emite la app y caducan. Un seed acá no sería
    # dato de arranque sino una credencial de recuperación pregenerada y con hash
    # conocido, viva en cualquier entorno que cargue el paquete.
    "iam.email_verifications",
    "iam.password_resets",
    # runtime: las escribe la app al despachar/entregar, nunca un seed
    "marketing.campaign_dispatches",
    "marketing.campaign_dispatch_recipients",
    "marketing.campaign_schedules",
    "messaging.adapter_event_mappings",
    "messaging.adapter_inbound_events",
    "messaging.adapter_tracking_capabilities",
    "messaging.delivery_reconciliation_runs",
    "messaging.delivery_status_transitions",
    "messaging.delivery_tracking_events",
}


def phase_coverage(docs, ddl, fks, value_sets, uniques) -> dict:
    """Siembra las tablas declaradas en COVERAGE_TABLES y audita las que quedan vacías."""
    id_index = build_id_index(docs)
    generic_concepts = [r["id"] for r in docs["03"]["boot"]["records"]["catalog_concepts"]]
    concepts_by_vs = {n: [concept_id(n, c, m) for c in m["codes"]] for n, m in value_sets.items()}
    vf = ValueFactory(ddl, fks, id_index, concepts_by_vs, generic_concepts)
    stats = OrderedDict()

    for tkey, cfg in COVERAGE_TABLES.items():
        entity, section = tkey.split(".")[1], cfg["section"]
        doc = docs[cfg["module"]]
        rows = [vf.row(tkey, section, i, vs_map=cfg.get("vs"))
                for i in range(1, ROWS_PER_TABLE + 1)]
        n = upsert_rows(doc, section, entity, rows)
        if n:
            stats[tkey] = n
        ensure_policy(doc, entity, ddl[tkey], "id", uniques.get(tkey, []),
                      "RELATIONAL_TABLE", section == "boot", section == "mock")
    return stats


def empty_tables(docs, ddl) -> list:
    """Tablas del DDL sin una sola fila en el paquete."""
    seeded = set()
    for code, doc in docs.items():
        schema = module_path(code).stem.split("_", 1)[1].replace(".seeds", "")
        for section in ("boot", "mock"):
            for entity, rows in doc.get(section, {}).get("records", {}).items():
                if rows:
                    seeded.add(f"{schema}.{entity}")
    return sorted(set(ddl) - seeded)


# ============================================================ fase 3d · nulos del modelo

# Columnas cuyo valor sembrado era un artefacto de un NOT NULL incorrecto del modelo:
# `retired_at` se rellenaba con un timestamp para poder insertar, pero una versión de
# embeddings recién sembrada no nace retirada. Corregido el `.puml` (v4.0.7), el valor
# correcto es null. Solo se vacía si el DDL ya declara la columna nullable.
MODEL_NULLS = {
    ("vector_rag", "embedding_model_versions", "retired_at"),
}


def phase_model_nulls(docs, ddl) -> dict:
    """Vacía las columnas que el modelo dejó nullable y traían un valor sin sentido."""
    emptied = OrderedDict()
    for schema, entity, col in sorted(MODEL_NULLS):
        meta = (ddl.get(f"{schema}.{entity}") or {}).get(col)
        if not meta or meta["not_null"]:
            continue                      # el DDL todavía la exige: no se toca
        code = next((c for c in docs
                     if module_path(c).stem.split("_", 1)[1].replace(".seeds", "") == schema), None)
        if code is None:
            continue
        for section in ("boot", "mock"):
            for row in docs[code].get(section, {}).get("records", {}).get(entity, []):
                if row.get(col) is None:
                    continue
                row[col] = None
                key = f"{schema}.{entity}.{col}"
                emptied[key] = emptied.get(key, 0) + 1
    return emptied


# ============================================================ fase 3c · value sets vinculados

COLUMNS_RE = re.compile(r"##\s*Columnas\s*\n```text\n(.*?)\n```", re.S)


def load_column_bindings(ddl) -> dict:
    """{(schema, entidad, columna): vs_internal_code} desde el bloque `## Columnas` del vault.

    Las 24 tablas nuevas ya traen su binding en NEW_TABLES[…]["vs"], que la fase 1 materializa
    como filas de `system_context.dynamic_enum_bindings`. Este bloque cubre las columnas
    anteriores a los patches: el modelo las declara en la nota del value set, una por línea,
    `schema.tabla.columna` o `*.columna` para todas las tablas que la tengan. El código no
    infiere nada por nombre — sin declaración en el vault, la columna no se ata.

    Las tablas `<<LOG>>` quedan fuera del comodín: guardan el valor que la fila **tuvo**, y
    reescribirlo sería falsear el historial.
    """
    out = {}
    # `v4.*` y no `v4.0.*`: desde v4.1.4 hay value sets en patches de la serie 4.1.
    for note in sorted(VAULT.glob("Patch v4.*/Value sets/*.md")):
        m = COLUMNS_RE.search(note.read_text(encoding="utf-8"))
        if not m:
            continue
        vs_code = re.sub(r"^VS ", "", note.stem).upper()
        for line in (l.strip() for l in m.group(1).splitlines()):
            if not line:
                continue
            head, _, col = line.rpartition(".")
            targets = ([t for t in ddl if col in ddl[t] and not is_log_table(t)]
                       if head == "*" else [head])
            for tkey in targets:
                if tkey in ddl and col in ddl[tkey]:
                    out[tuple(tkey.split(".", 1)) + (col,)] = vs_code
    return out


def is_log_table(tkey: str) -> bool:
    """Tabla de historial/auditoría: `<<LOG>>` en el modelo, inmutable por diseño."""
    schema, table = tkey.split(".", 1)
    return schema == "audit" or table.endswith(("_history", "_log"))


def concepts_by_bound_column(docs, ddl) -> dict:
    """{(schema, entidad, columna): {concept_id…}} — los conceptos legales de cada columna.

    El binding físico sale del propio paquete (`dynamic_enum_bindings`, emitido desde el
    modelo) y de los bloques `## Columnas` del vault; la pertenencia, de `value_set_members`.
    No se infiere ningún binding por nombre de columna: sin binding declarado, no se toca.
    """
    doc03, doc45 = docs["03"], docs["45"]
    boot03 = doc03["boot"]["records"]
    boot45 = doc45["boot"]["records"]

    members_by_version = {}
    for row in boot03.get("value_set_members", []):
        if row.get("included") is False:
            continue
        members_by_version.setdefault(row["value_set_version_id"], set()).add(row["concept_id"])
    members_by_vs = {}
    for row in boot03.get("value_set_versions", []):
        members_by_vs.setdefault(row["value_set_id"], set()).update(
            members_by_version.get(row["id"], ()))
    vs_id_by_code = {row["internal_code"].lower(): row["id"]
                     for row in boot03.get("value_sets", []) if row.get("internal_code")}
    vs_id_by_definition = {row["id"]: row.get("value_set_id")
                           for row in boot45.get("dynamic_enum_definitions", [])}

    out = {}
    for row in boot45.get("dynamic_enum_bindings", []):
        vs_id = vs_id_by_definition.get(row["dynamic_enum_definition_id"])
        concepts = members_by_vs.get(vs_id)
        if concepts:
            out[(row["target_schema_name"], row["target_entity_name"],
                 row["target_field_name"])] = concepts
    for key, vs_code in load_column_bindings(ddl).items():
        concepts = members_by_vs.get(vs_id_by_code.get(vs_code.lower()))
        if concepts:
            out[key] = concepts
    return out


def phase_valueset_binding(docs, ddl) -> dict:
    """Reasigna los `*_concept_id` que apuntan fuera del value set que los ata.

    El defecto: columnas resueltas contra el catálogo genérico en vez de su value set
    (`tier_concept_id` apuntando a DENEGAR o ECDSA_P256). Un valor que ya está dentro del
    set nunca se toca — la fase es reparadora, no normalizadora.
    """
    allowed = concepts_by_bound_column(docs, ddl)
    if not allowed:
        return OrderedDict()
    fixed = OrderedDict()
    for code, doc in docs.items():
        schema = module_path(code).stem.split("_", 1)[1].replace(".seeds", "")
        for section in ("boot", "mock"):
            for entity, rows in doc.get(section, {}).get("records", {}).items():
                for index, row in enumerate(rows):
                    for col, value in row.items():
                        concepts = allowed.get((schema, entity, col))
                        if not concepts or value is None or value in concepts:
                            continue
                        row[col] = pick(sorted(concepts), f"{schema}.{entity}", col, section, index)
                        key = f"{schema}.{entity}.{col}"
                        fixed[key] = fixed.get(key, 0) + 1
    return fixed


def unbound_concept_columns(docs, ddl) -> list:
    """Columnas `*_concept_id` sin binding declarado — no reparables sin inventar el modelo."""
    allowed = concepts_by_bound_column(docs, ddl)
    out = set()
    for tkey, cols in ddl.items():
        schema, entity = tkey.split(".", 1)
        for col in cols:
            if col.endswith("_concept_id") and (schema, entity, col) not in allowed:
                out.add(tkey + "." + col)
    return sorted(out)


# ============================================================ fase 4b · UK compuestas

def _bump(value, i):
    if isinstance(value, bool):
        return value
    if isinstance(value, int):
        return value + i
    if isinstance(value, str):
        return f"{value}_{i:02d}"
    return value


def _pool_from_data(rows, uk, cols, owner_of, id_index):
    """(columna, pool) deducidos del dato: la tabla dueña del uuid que la columna trae.

    Devuelve la columna de la UK con más filas hermanas donde rotar. `(None, [])` si
    ninguna referencia a una tabla del paquete: sin pool, no se toca nada.
    """
    best = (None, [])
    for col in uk:
        if not cols[col]["type"].lower().startswith("uuid"):
            continue
        owners = {owner_of.get(r.get(col)) for r in rows if isinstance(r.get(col), str)}
        owners.discard(None)
        if len(owners) != 1:
            continue                     # ambiguo o sin dueño: no se adivina
        pool = id_index.get(owners.pop(), [])
        if len(pool) > len(best[1]):
            best = (col, pool)
    return best if len(best[1]) >= 2 else (None, [])


def _mintable_uuid_column(uk, cols, tfks, owner_of, rows):
    """Columna uuid de la UK que no referencia nada: ni FK declarada, ni fila del paquete.

    En esas columnas el uuid es un identificador opaco (los stores 58/59 no declaran FKs),
    así que darle un valor propio a cada fila no rompe ninguna referencia — y es lo que la
    UK del modelo exige. Si la columna sí apunta a algo, se devuelve None y no se toca.

    Se recorre la UK de derecha a izquierda, misma convención que las columnas numerables:
    la última es el discriminador (`(session, chunk)` → varían los candidatos de la sesión,
    no la sesión de cada candidato).
    """
    for col in reversed(uk):
        if col in tfks or not cols[col]["type"].lower().startswith("uuid"):
            continue
        if any(owner_of.get(r.get(col)) for r in rows):
            continue
        return col
    return None


def phase_unique_within(docs, ddl, uniques, fks) -> dict:
    """Desambigua claves naturales repetidas DENTRO de una misma sección.

    La amplificación de filas del generador viejo clonaba plantillas sin variar las
    columnas de las UK compuestas (p. ej. `(provider_id, version)`), y el INSERT moría
    con 23505: el savepoint descartaba la entidad completa.

    Cuando la UK es toda de columnas FK (p. ej. `uk_cashier_payment_contexts_session`
    sobre `payment_checkout_session_id`) no hay nada «numerable»: se reapunta la FK a
    otra fila válida del padre, que es lo que el dato mock debería haber hecho — una
    sesión de cobro por contexto, no la misma repetida.

    Los stores 58/59 no declaran FKs (el modelo no las declara y la BD no las tiene),
    así que ahí el padre no se puede deducir del DDL. Se deduce **del propio dato**: el
    uuid que la columna ya trae pertenece a alguna tabla del paquete, y esa tabla es el
    pool sobre el que rotar. No se infiere nada por el nombre de la columna.
    """
    id_index = build_id_index(docs)
    owner_of = {i: tkey for tkey, ids in id_index.items() for i in ids}
    changed = OrderedDict()
    for code, doc in docs.items():
        schema = module_path(code).stem.split("_", 1)[1].replace(".seeds", "")
        for section in ("boot", "mock"):
            for entity, rows in doc.get(section, {}).get("records", {}).items():
                tkey = f"{schema}.{entity}"
                cols, uks = ddl.get(tkey), uniques.get(tkey)
                if not cols or not uks or len(rows) < 2:
                    continue
                for uk in uks:
                    if not all(c in cols for c in uk):
                        continue
                    # se muta una columna que no sea FK (mutarla rompería la referencia)
                    tfks = fks.get(tkey, {})
                    tunable = [c for c in uk
                               if c not in tfks
                               and cols[c]["type"].lower().startswith(
                                   ("varchar", "text", "char", "integer", "int", "smallint", "bigint"))]
                    # sin columna «numerable»: se rota una FK entre las filas del padre
                    fk_col = next((c for c in uk if c in tfks), None)
                    pool = id_index.get(tfks.get(fk_col, ""), []) if fk_col else []
                    mint_col = None
                    if not tunable and len(pool) < 2:
                        # sin FK declarada: el pool sale del uuid que la columna ya trae
                        fk_col, pool = _pool_from_data(rows, uk, cols, owner_of, id_index)
                        if not fk_col:
                            mint_col = _mintable_uuid_column(uk, cols, tfks, owner_of, rows)
                            if not mint_col:
                                continue
                    col = tunable[-1] if tunable else (fk_col or mint_col)
                    seen, taken = set(), set()
                    for row in rows:
                        if any(row.get(c) is None for c in uk):
                            continue
                        key = tuple(str(row.get(c)) for c in uk)
                        if key not in seen:
                            seen.add(key)
                            taken.add(row.get(col))
                            continue
                        if tunable:
                            for n in range(1, 60):
                                row[col] = _bump(row.get(col), n)
                                key = tuple(str(row.get(c)) for c in uk)
                                if key not in seen:
                                    break
                        elif mint_col:
                            row[col] = stable_uuid("SALUD", MODEL_VERSION, "uk", tkey, col,
                                                   row.get("id", ""))
                            key = tuple(str(row.get(c)) for c in uk)
                        else:
                            free = next((p for p in pool if p not in taken), None)
                            if free is None:
                                continue
                            row[col] = free
                            key = tuple(str(row.get(c)) for c in uk)
                        seen.add(key)
                        taken.add(row.get(col))
                        k = f"{tkey}.{col}"
                        changed[k] = changed.get(k, 0) + 1
    return changed


# ============================================================ fase 5 · metadatos

def phase_meta(docs) -> dict:
    """Versión del modelo, conteos, summary y manifest/checksums coherentes."""
    manifest_modules = []
    for code in sorted(docs):
        doc = docs[code]
        doc["module"]["source_model_version"] = SOURCE_MODEL_VERSION
        doc["module"]["requested_release_label"] = RELEASE_LABEL
        doc["module"]["seed_revision"] = SEED_REVISION
        for section in ("boot", "mock"):
            sec = doc.get(section)
            if not sec:
                continue
            records = sec.get("records", {})
            total = sum(len(v) for v in records.values())
            sec["record_count"] = total
            summary = sec.setdefault("summary", {})
            summary["record_count"] = total
            summary["entity_count"] = sum(1 for v in records.values() if v)
    return {"modulos": len(docs)}


def write_all(docs) -> None:
    for code, doc in docs.items():
        save_module(code, doc)


def rebuild_manifest_and_checksums() -> dict:
    manifest_path = SEEDS_DIR / "seed-manifest.json"
    manifest = json.loads(manifest_path.read_text(encoding="utf-8"))
    entries, boot_total, mock_total = [], 0, 0
    for path in sorted(MODULES_DIR.glob("*.seeds.json")):
        doc = json.loads(path.read_text(encoding="utf-8"))
        raw = path.read_bytes()
        boot_n = doc.get("boot", {}).get("record_count", 0)
        mock_n = doc.get("mock", {}).get("record_count", 0)
        boot_total += boot_n
        mock_total += mock_n
        entries.append(OrderedDict([
            ("number", doc["module"]["number"]), ("code", doc["module"]["code"]),
            ("file", "modules/" + path.name),
            ("boot_records", boot_n), ("mock_records", mock_n),
            ("line_count", raw.decode("utf-8").count("\n") + 1),
            ("sha256", hashlib.sha256(raw).hexdigest())]))
    manifest["seed_revision"] = SEED_REVISION
    manifest["source_model_version"] = SOURCE_MODEL_VERSION
    manifest["boot_record_count"] = boot_total
    manifest["mock_record_count"] = mock_total
    manifest["module_count"] = len(entries)
    manifest["modules"] = entries
    manifest_path.write_text(json.dumps(manifest, ensure_ascii=False, indent=2) + "\n",
                             encoding="utf-8", newline="\n")

    checks = {}
    for path in sorted(SEEDS_DIR.rglob("*")):
        if not path.is_file() or path.name in ("checksums.json",):
            continue
        rel = path.relative_to(SEEDS_DIR).as_posix()
        if rel.startswith(("modules/", "schemas/")):
            checks[rel] = hashlib.sha256(path.read_bytes()).hexdigest()
    (SEEDS_DIR / "checksums.json").write_text(
        json.dumps(checks, ensure_ascii=False, indent=2) + "\n", encoding="utf-8", newline="\n")
    return {"boot": boot_total, "mock": mock_total, "archivos_checksum": len(checks)}


# ============================================================ main

# ============================================================ fase 1c · catálogos del cierre M7

PATCH_M7 = "4.2.29"
ISO_3166_FILE = paths.DATA_DIR / "iso-3166-1.json"


def _sort_key_es(text: str) -> str:
    """Orden alfabético en castellano sin depender del locale de la máquina."""
    base = unicodedata.normalize("NFKD", text.lower())
    return "".join(c for c in base if not unicodedata.combining(c))


def phase_m7_catalogs(docs: dict) -> dict:
    """CL-25, jurisdicciones por departamento y los miembros de VS_COUNTRY (ISO 3166-1).

    Los conceptos de los catálogos M7 son conceptos del backend (ids de `backend_id`), los
    inserta `phase_backend_bridge`; acá se crean el value set, su versión, los miembros y, si
    el catálogo lo pide, el enum dinámico con sus bindings (el que sirve a
    `GET /system-context/dynamic-enums?target=…`). Idempotente por id.
    """
    doc03, doc45 = docs["03"], docs["45"]
    stats = {"value_sets": 0, "miembros": 0, "enums": 0, "bindings": 0, "paises": 0}
    for cat in M7_CATALOGS:
        vs_name = cat["vs"]
        meta = {"patch": PATCH_M7, "module": cat["module"]}
        vs_id, vsv_id = vs_ids(vs_name, meta)
        t = det_time(BOOT_BASE, vs_name)
        stamp, stamp2 = iso(t), iso(t + timedelta(minutes=20))
        who = [("created_by_user_id", SEED_USER_ID), ("updated_by_user_id", SEED_USER_ID),
               ("row_version", 1)]
        upsert_rows(doc03, "boot", "value_sets", [OrderedDict([
            ("id", vs_id), ("internal_code", vs_name.upper()), ("name", cat["name"]),
            ("canonical_url", "https://salud.example.invalid/fhir/ValueSet/" + vs_name),
            ("description", cat["description"]),
            ("jurisdiction_concept_id", JURISDICTION_CONCEPT_ID),
            ("state_concept_id", CONCEPT_ACTIVE),
            ("created_at", stamp), ("updated_at", stamp2), *who])])
        upsert_rows(doc03, "boot", "value_set_versions", [OrderedDict([
            ("id", vsv_id), ("value_set_id", vs_id), ("version", "1.0.0"),
            ("valid_from", stamp), ("valid_to", None), ("is_default", True),
            ("state_concept_id", CONCEPT_ACTIVE),
            ("created_at", stamp), ("updated_at", stamp2), *who])])
        stats["value_sets"] += 1
        members, options = [], []
        for i, (key, _en, es, default) in enumerate(cat["concepts"], start=1):
            cid = backend_id(key)
            ct = det_time(BOOT_BASE, vs_name, key)
            cs, cs2 = iso(ct), iso(ct + timedelta(minutes=20))
            members.append(OrderedDict([
                ("id", stable_uuid("SALUD", PATCH_M7, "boot", cat["module"],
                                   "terminology.value_set_members", vs_name, key)),
                ("value_set_version_id", vsv_id), ("concept_id", cid),
                ("included", True), ("ordinal", i),
                ("created_at", cs), ("updated_at", cs2), *who]))
            options.append(OrderedDict([
                ("id", stable_uuid("SALUD", PATCH_M7, "boot", cat["module"],
                                   "system_context.dynamic_enum_options", vs_name, key)),
                ("dynamic_enum_version_id", stable_uuid(
                    "SALUD", PATCH_M7, "boot", cat["module"],
                    "system_context.dynamic_enum_versions", vs_name)),
                ("concept_id", cid), ("code", key), ("display", es),
                ("ordinal", i), ("is_default", bool(default)), ("enabled", True),
                ("metadata_json", {"value_set": vs_name, "patch": "v" + PATCH_M7}),
                ("recorded_at", cs), ("recorded_by_user_id", SEED_USER_ID)]))
        stats["miembros"] += upsert_rows(doc03, "boot", "value_set_members", members)
        if not cat.get("enum", True):
            continue
        ed_id = stable_uuid("SALUD", PATCH_M7, "boot", cat["module"],
                            "system_context.dynamic_enum_definitions", vs_name)
        ev_id = stable_uuid("SALUD", PATCH_M7, "boot", cat["module"],
                            "system_context.dynamic_enum_versions", vs_name)
        stats["enums"] += upsert_rows(doc45, "boot", "dynamic_enum_definitions", [OrderedDict([
            ("id", ed_id), ("code", vs_name.upper()), ("name", cat["name"]),
            ("description", "Enum dinámico del value set {} (patch v{}).".format(vs_name, PATCH_M7)),
            ("value_set_id", vs_id), ("scope_type_concept_id", CONCEPT_ACTIVE),
            ("tenant_id", None), ("country_concept_id", JURISDICTION_CONCEPT_ID),
            ("selection_mode_concept_id", CONCEPT_ACTIVE),
            ("allow_tenant_extension", False), ("allow_custom_value", False),
            ("status_concept_id", CONCEPT_ACTIVE),
            ("created_at", stamp), ("updated_at", stamp2), *who])])
        upsert_rows(doc45, "boot", "dynamic_enum_versions", [OrderedDict([
            ("id", ev_id), ("dynamic_enum_definition_id", ed_id), ("version_number", 1),
            ("value_set_version_id", vsv_id), ("schema_version", "1.0.0"),
            ("cache_token", hashlib.sha256((vs_name + "|1.0.0").encode()).hexdigest()[:32]),
            ("effective_from", stamp), ("effective_to", None),
            ("status_concept_id", CONCEPT_ACTIVE),
            ("recorded_at", stamp), ("recorded_by_user_id", SEED_USER_ID)])])
        upsert_rows(doc45, "boot", "dynamic_enum_options", options)
        binds = [OrderedDict([
            ("id", stable_uuid("SALUD", PATCH_M7, "boot", cat["module"],
                               "system_context.dynamic_enum_bindings", vs_name,
                               schema + "." + entity, col)),
            ("dynamic_enum_definition_id", ed_id),
            ("target_schema_name", schema), ("target_entity_name", entity),
            ("target_field_name", col), ("system_context_id", None),
            ("required", True), ("fallback_concept_id", None),
            ("validation_mode_concept_id", CONCEPT_ACTIVE),
            ("status_concept_id", CONCEPT_ACTIVE),
            ("created_at", stamp), ("updated_at", stamp2), *who])
            for schema, entity, col in cat["bindings"]]
        stats["bindings"] += upsert_rows(doc45, "boot", "dynamic_enum_bindings", binds)
    stats["paises"] = phase_iso_countries(doc03)
    return stats


def phase_iso_countries(doc03: dict) -> int:
    """Los 249 países de ISO 3166-1 como miembros de VS_COUNTRY (antes sólo tenía BOLIVIA).

    El código del concepto es el alpha-2 y la etiqueta el nombre en castellano (CLDR); el
    nombre corto ISO en inglés y los códigos alpha-3 y numérico van en `definition`. Bolivia
    NO se vuelve a crear: ya es el concepto `BOLIVIA` (`JURISDICTION_CONCEPT_ID`), el mismo
    que usan las 15 columnas `country_concept_id`, y duplicarlo dejaría dos conceptos para
    un país. Los conceptos nacen en su propia versión del sistema SALUD_CORE para que los
    alpha-2 (`ES`, `PT`, `EN`…) no choquen con `uq_catalog_concepts_version_code`.
    """
    data = json.loads(ISO_3166_FILE.read_text(encoding="utf-8"))
    boot = doc03["boot"]["records"]
    vs = next((v for v in boot["value_sets"] if v["internal_code"] == "VS_COUNTRY"), None)
    if vs is None:
        sys.exit("VS_COUNTRY no está en el paquete (03_terminology)")
    versions = [v for v in boot["value_set_versions"] if v["value_set_id"] == vs["id"]]
    vsv = next((v for v in versions if v.get("is_default")), versions[0])
    ordinals = [m["ordinal"] for m in boot["value_set_members"]
                if m["value_set_version_id"] == vsv["id"]]
    # Los ordinales ya sembrados de las 249 filas son estables: base = el máximo SIN contar
    # los que esta misma fase agregó, o cada corrida los movería.
    propios = {stable_uuid("SALUD", PATCH_M7, "boot", "03", "terminology.value_set_members",
                           "vs_country", c["alpha2"]) for c in data["countries"]}
    base_ordinal = max((m["ordinal"] for m in boot["value_set_members"]
                        if m["value_set_version_id"] == vsv["id"] and m["id"] not in propios),
                       default=0)
    del ordinals

    csv_id = stable_uuid("SALUD", PATCH_M7, "boot", "03",
                         "terminology.code_system_versions", "vs_country_iso3166")
    t0 = det_time(BOOT_BASE, "vs_country_iso3166")
    upsert_rows(doc03, "boot", "code_system_versions", [OrderedDict([
        ("id", csv_id), ("code_system_id", CODE_SYSTEM_ID),
        ("version", "1.0.0-vs_country-iso3166-1"), ("published_at", iso(t0)),
        ("valid_from", iso(t0)), ("valid_to", None),
        ("checksum", hashlib.sha256("|".join(
            c["alpha2"] for c in data["countries"]).encode()).hexdigest()),
        ("is_default", False), ("state_concept_id", CONCEPT_ACTIVE),
        ("created_at", iso(t0)), ("updated_at", iso(t0 + timedelta(minutes=20))),
        ("created_by_user_id", SEED_USER_ID), ("updated_by_user_id", SEED_USER_ID),
        ("row_version", 1)])])

    concepts, designations, members = [], [], []
    paises = sorted((c for c in data["countries"] if c["alpha2"] != "BO"),
                    key=lambda c: _sort_key_es(c["name_es"]))
    who = [("created_by_user_id", SEED_USER_ID), ("updated_by_user_id", SEED_USER_ID),
           ("row_version", 1)]
    for i, c in enumerate(paises, start=1):
        code = c["alpha2"]
        cid = stable_uuid("SALUD", PATCH_M7, "boot", "03",
                          "terminology.catalog_concepts", "vs_country", code)
        ct = det_time(BOOT_BASE, "vs_country", code)
        cs, cs2 = iso(ct), iso(ct + timedelta(minutes=20))
        concepts.append(OrderedDict([
            ("id", cid), ("code_system_version_id", csv_id), ("code", code),
            ("display", c["name_es"]),
            ("definition", "ISO 3166-1: alpha-2 {} · alpha-3 {} · numérico {}. Nombre ISO: {}."
             .format(code, c["alpha3"], c["numeric"], c["name_en"])),
            ("abstract", False), ("selectable", True),
            ("valid_from", cs), ("valid_to", None), ("replaced_by_concept_id", None),
            ("state_concept_id", CONCEPT_ACTIVE),
            ("created_at", cs), ("updated_at", cs2), *who]))
        designations.append(OrderedDict([
            ("id", stable_uuid("SALUD", PATCH_M7, "boot", "03",
                               "terminology.concept_designations", "vs_country", code)),
            ("concept_id", cid), ("language_concept_id", LANGUAGE_CONCEPT_ID),
            ("designation_type_concept_id", DESIGNATION_TYPE_CONCEPT_ID),
            ("value", c["name_es"]), ("preferred", True),
            ("created_at", cs), ("updated_at", cs2), *who]))
        members.append(OrderedDict([
            ("id", stable_uuid("SALUD", PATCH_M7, "boot", "03",
                               "terminology.value_set_members", "vs_country", code)),
            ("value_set_version_id", vsv["id"]), ("concept_id", cid),
            ("included", True), ("ordinal", base_ordinal + i),
            ("created_at", cs), ("updated_at", cs2), *who]))
    upsert_rows(doc03, "boot", "catalog_concepts", concepts)
    upsert_rows(doc03, "boot", "concept_designations", designations)
    return upsert_rows(doc03, "boot", "value_set_members", members)


def main() -> None:
    try:
        sys.stdout.reconfigure(encoding="utf-8")
    except Exception:
        pass
    ap = argparse.ArgumentParser(description="Actualiza seedsGenerales/ al modelo SALUD v4.0.8")
    ap.add_argument("--dry", action="store_true", help="no escribe; solo informa")
    ap.add_argument("--only",
                    choices=["valuesets", "backend", "tables", "notnull", "bindings", "unique", "meta"],
                    help="ejecuta una sola fase")
    args = ap.parse_args()

    ddl, fks, uniques = parse_ddl(), parse_fks(), parse_unique()
    value_sets = load_value_sets()
    codes = sorted(p.stem.split("_")[0] for p in MODULES_DIR.glob("*.seeds.json"))
    docs = {c: load_module(c) for c in codes}
    assert_anchors(docs)
    run = (lambda f: args.only in (None, f))

    if run("valuesets"):
        s = phase_valuesets(docs, value_sets)
        print("[1] value sets  · {} value sets · {} conceptos · {} miembros · "
              "{} enums dinámicos · {} bindings".format(
                  s["value_sets"], s["conceptos"], s["miembros"], s["enums"], s["bindings"]))
    if run("valuesets"):
        s = phase_m7_catalogs(docs)
        print("[1c] catálogos M7 · {} value sets · {} miembros · {} enums · {} bindings · "
              "{} países ISO 3166-1".format(s["value_sets"], s["miembros"], s["enums"],
                                             s["bindings"], s["paises"]))
    if args.only in (None, "tables", "backend"):
        s = phase_backend_bridge(docs)
        print("[1b] puente backend · {} filas espejadas ({} conceptos)".format(
            sum(s.values()), s["catalog_concepts"]))
    if run("tables"):
        r = retire_legacy_channels(docs, fks)
        print("[1b] canales/proveedores legacy · {} fila(s) retiradas · {} referencias "
              "repuntadas al id del backend".format(r["retiradas"], r["repuntadas"]))
        n = align_role_states(docs)
        print("[1b] roles del paquete · {} estados alineados al ACTIVE del backend".format(n))
        s = phase_tables(docs, ddl, fks, value_sets, uniques)
        print("[2] tablas nuevas · {} entidades pobladas · {} filas".format(
            len(s), sum(s.values())))
        for k, v in s.items():
            print("      {:<48} {:>4}".format(k, v))
        s = phase_curate_identities(docs, value_sets)
        print("[2d] identidades del mock · {} correcciones en {} columnas".format(
            sum(s.values()), len(s)))
        for k, v in s.items():
            print("      {:<62} {:>4}".format(k, v))
        r = phase_refs(docs, ddl, fks)
        print("[2b] referencias · {} reparadas · {} sin destino en el paquete".format(
            sum(r["repaired"].values()), sum(r["unresolved"].values())))
        for k, v in sorted(r["repaired"].items(), key=lambda kv: -kv[1])[:10]:
            print("      {:<62} {:>4}".format(k, v))
        for k, v in sorted(r["unresolved"].items(), key=lambda kv: -kv[1])[:10]:
            print("      SIN DESTINO {:<50} {:>4}".format(k, v))
        s = phase_coverage(docs, ddl, fks, value_sets, uniques)
        vacias = empty_tables(docs, ddl)
        sin_declarar = [t for t in vacias if not is_intentionally_empty(t)]
        print("[2c] cobertura · {} filas sembradas · {} tablas vacías ({} declaradas, "
              "{} SIN DECLARAR)".format(sum(s.values()), len(vacias),
                                        len(vacias) - len(sin_declarar), len(sin_declarar)))
        for t in sin_declarar:
            print("      SIN DECLARAR {:<50}".format(t))
    if run("notnull"):
        s = phase_notnull(docs, ddl, fks, value_sets)
        print("[3] NOT NULL · {} columnas rellenadas en {} pares tabla/columna".format(
            sum(s.values()), len(s)))
        for k, v in sorted(s.items(), key=lambda kv: -kv[1])[:12]:
            print("      {:<48} {:>5}".format(k, v))
    if run("notnull"):
        s = phase_types(docs, ddl, fks, value_sets)
        print("[3b] tipos · {} valores corregidos en {} columnas".format(
            sum(s.values()), len(s)))
        for k, v in sorted(s.items(), key=lambda kv: -kv[1])[:10]:
            print("      {:<62} {:>5}".format(k, v))
    if run("notnull"):
        s = phase_model_nulls(docs, ddl)
        print("[3d] nulos del modelo · {} valores vaciados en {} columnas".format(
            sum(s.values()), len(s)))
        for k, v in s.items():
            print("      {:<62} {:>5}".format(k, v))
    if run("bindings"):
        s = phase_valueset_binding(docs, ddl)
        libres = unbound_concept_columns(docs, ddl)
        print("[3c] value sets · {} concept_id reasignados a su set en {} columnas · "
              "{} columnas sin binding declarado".format(sum(s.values()), len(s), len(libres)))
        for k, v in sorted(s.items(), key=lambda kv: -kv[1])[:10]:
            print("      {:<62} {:>5}".format(k, v))
    if run("unique"):
        s = phase_unique(docs, ddl, uniques, fks)
        print("[4] claves naturales · {} colisiones boot/mock desambiguadas en {} columnas".format(
            sum(s.values()), len(s)))
        for k, v in sorted(s.items(), key=lambda kv: -kv[1])[:12]:
            print("      {:<48} {:>5}".format(k, v))
        s = phase_unique_within(docs, ddl, uniques, fks)
        print("[4b] claves naturales · {} duplicados intra-sección desambiguados "
              "en {} columnas".format(sum(s.values()), len(s)))
        for k, v in sorted(s.items(), key=lambda kv: -kv[1])[:10]:
            print("      {:<48} {:>5}".format(k, v))
    if run("meta"):
        phase_meta(docs)
        print("[5] metadatos · source_model_version={} · seed_revision={}".format(
            SOURCE_MODEL_VERSION, SEED_REVISION))

    if args.dry:
        print("\n--dry: no se escribió nada")
        return
    write_all(docs)
    m = rebuild_manifest_and_checksums()
    print("\nescrito: {} módulos · boot {} · mock {} · checksums {}".format(
        len(docs), m["boot"], m["mock"], m["archivos_checksum"]))


if __name__ == "__main__":
    main()
