#!/usr/bin/env python3
"""Directorio oficial de salud de Bolivia: farmacias, establecimientos, laboratorios e imagen.

Une tres fuentes en un formato normalizado y con procedencia por registro, que
después consume `gen_seeds.py` (`build_official_directory`):

1. **AGEMED** — «Lista de establecimientos farmacéuticos» nacional
   (`archivos_vigilancia/farmacias/farmacias_nacional.xlsx`, actualizada al
   01/10/2026): nombre, tipo, dirección, departamento, municipio, coordenadas,
   teléfono y **nº de resolución** de habilitación. Los nombres de los regentes
   farmacéuticos NO se copian: el directorio no los necesita (minimización).
2. **RUES 2026** — Registro Único de Establecimientos de Salud, Ministerio de
   Salud y Deportes / SNIS, reporte «Estructura de Establecimientos Gestión
   2026» (extraído del reporte dinámico, `rues_estructura_2026.json`): código
   oficial, nombre, SEDES, provincia, municipio, red, tipo, nivel, subsector,
   institución, ámbito y camas. No publica coordenadas.
3. **Observatorio de lugares** (CSV que entregó el propietario): sólo lo que ni
   AGEMED ni el RUES cubren —centros de imagen, laboratorios privados,
   consultorios, clínicas, odontología—, y sólo de fuentes con licencia que
   permite el uso: Overture Maps (CDLA-Permissive-2.0) con confianza ≥ 0,6 y
   Foursquare Open Source Places (Apache-2.0). Las filas de OpenStreetMap y
   Geofabrik (ODbL, que obliga a liberar la base derivada) quedan fuera hasta
   que el propietario decida; se cuentan en el manifiesto.

Reglas: nada se inventa. Coordenada fuera de Bolivia → null. Municipio que no
cruza con el padrón `bo-territorio.json` por su nombre (o por un alias
declarado en `MUNICIPIO_ALIAS`) → null, con el texto de la fuente guardado.

Uso:
    python salud-db/build_directorio_oficial.py --sources <bolivia-sources>
Salida: `salud-db/data/directorio-oficial/*.json` + `manifest.json`.
"""
from __future__ import annotations

import argparse
import csv
import hashlib
import json
import re
import sys
import unicodedata
from collections import Counter
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
OUT = ROOT / "salud-db" / "data" / "directorio-oficial"

# Código del departamento: el de `vs_administrative_area` en `gen_seeds.py`
# (minúsculas; Pando es `pa`).
DEPARTAMENTOS = {
    "CHUQUISACA": "ch", "LA PAZ": "lp", "COCHABAMBA": "cb", "ORURO": "or", "POTOSI": "pt",
    "TARIJA": "tj", "SANTA CRUZ": "sc", "BENI": "be", "PANDO": "pa",
}
# Ciudades del observatorio → departamento.
CIUDAD_DEPARTAMENTO = {
    "Santa Cruz de la Sierra": "sc", "Cochabamba": "cb", "El Alto": "lp", "Oruro": "or",
    "Tarija": "tj", "Sucre": "ch", "Trinidad": "be", "Potosí": "pt", "La Paz": "lp", "Cobija": "pa",
}
# Rectángulo de Bolivia (con margen): una coordenada fuera no es de un establecimiento boliviano.
BBOX = (-23.0, -9.6, -69.7, -57.4)  # lat_min, lat_max, lon_min, lon_max

# Diferencias de escritura entre las fuentes y el padrón: `<dep>:<texto plegado de
# la fuente>` → nombre EXACTO del padrón. Sólo variantes de escritura o la capital
# que da nombre al municipio; lo dudoso (Calcha K, Catavi, Río Verde, Redención
# Pampa, los TIOC posteriores al padrón) queda sin cruce a propósito.
MUNICIPIO_ALIAS: dict[str, str] = {
    "lp:LA PAZ": "Nuestra Señora de La Paz",            # nombre oficial del municipio
    "lp:PUERTO MAYOR DE CARABUCO": "Puerto Carabuco",
    "lp:SICASICA VILLA AROMA": "Sica Sica",
    "lp:JESUS DE MACHAKA": "Jesús de Machaca",
    "lp:TIAHUANACU": "Tiahuanaco",
    "lp:VILLA LIBERTAD LICOMA": "Licoma Pampa",
    "tj:VILLAMONTES": "Villa Montes",
    "cb:SIPESIPE": "Sipe Sipe",
    "cb:IVIRGARZAMA": "Puerto Villarroel",               # Ivirgarzama es la capital del municipio
    "cb:VILLA GUALBERTO VILLARROEL": "Cuchumuela",       # nombre oficial del municipio de Cuchumuela
    "ch:MUYUPAMPA": "Villa Vaca Guzmán",                 # el RUES escribe «VILLA VACA GUZMÁN (MUYUPAMPA)»
    "ch:ALCALA": "Villa Alcalá",
    "sc:ASCENCION DE GUARAYOS": "Ascensión de Guarayos",
    "sc:PAMPAGRANDE": "Pampa Grande",
    "sc:MOROMORO": "Moro Moro",
    "or:TOTORA": "San Pedro de Totora",                  # la de Oruro (AGEMED)
    "or:TOTORA ORR": "San Pedro de Totora",              # la de Oruro (RUES)
    "or:PARIA": "Soracachi",                             # AGEMED escribe «SORACACHI (PARIA)»
    "or:YUNGUYO DE LITORAL": "Yunguyo del Litoral",
    "pt:VITICHE": "Vitichi",
    "pt:CHARKI": "Chaquí",
    "pt:CHUQUIHUTA AYLLU JUCUMANI": "Chuquihuta",
    "pt:URMIRI": "Belén de Urmiri",
    "pa:SENA": "El Sena",
}

LICENCIAS = {
    "agemed": "Información pública del Estado (AGEMED, Ministerio de Salud y Deportes de Bolivia); se cita la fuente.",
    "rues": "Información pública del Estado (Ministerio de Salud y Deportes / SNIS, Bolivia); se cita la fuente.",
    "overture": "CDLA-Permissive-2.0 (Overture Maps Foundation)",
    "fsq": "Apache-2.0 (Foursquare Open Source Places)",
}


def fold(text: str | None) -> str:
    """Mayúsculas sin tildes ni signos, espacios simples: para comparar nombres."""
    t = unicodedata.normalize("NFKD", str(text or "")).encode("ascii", "ignore").decode()
    return re.sub(r"\s+", " ", re.sub(r"[^A-Za-z0-9 ]", " ", t)).strip().upper()


def slugify(text: str) -> str:
    """Copia exacta de `slugify` de `gen_seeds.py`: el código de municipio sale de acá."""
    text = unicodedata.normalize("NFKD", text.upper())
    text = "".join(c for c in text if not unicodedata.combining(c))
    return re.sub(r"[^A-Z0-9]+", "_", text).strip("_")[:64] or "ITEM"


def slug(text: str) -> str:
    return slugify(text).lower()


def sha256(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def coord(lat, lon):
    try:
        la, lo = float(str(lat).replace(",", ".")), float(str(lon).replace(",", "."))
    except (TypeError, ValueError):
        return None, None
    if BBOX[0] <= la <= BBOX[1] and BBOX[2] <= lo <= BBOX[3]:
        return round(la, 7), round(lo, 7)
    return None, None


def stable_id(*parts) -> str:
    return hashlib.sha1("|".join(str(p) for p in parts).encode()).hexdigest()[:16]


class Padron:
    """Municipios del padrón con el mismo código que `gen_seeds.py`: `<sigla>-<slug>`."""

    def __init__(self) -> None:
        data = json.loads((ROOT / "salud-db" / "data" / "bo-territorio.json").read_text(encoding="utf-8"))
        self.por_dep: dict[str, dict[str, str]] = {}
        for dep in data:
            sigla = DEPARTAMENTOS[fold(dep["departamento"])]
            for prov in dep["provincias"]:
                for mun in prov["municipios"]:
                    # Mismo código que `municipios_display()` de gen_seeds.py.
                    self.por_dep.setdefault(sigla, {})[slug(mun)] = f"{sigla}-{slugify(mun).lower()}"

    SIGLAS_EN_PARENTESIS = {"SCZ", "TJA", "TRJ", "BEN", "CBB", "ORR", "PTS", "LPZ", "CHQ", "PND", "TJ", "LP", "SC", "CB"}

    def _variantes(self, texto: str) -> list[str]:
        """El nombre tal cual y las variantes que arma su aclaración entre paréntesis."""
        crudo = str(texto).strip().strip("_")
        dentro = " ".join(re.findall(r"\(([^)]*)\)", crudo))
        fuera = re.sub(r"\([^)]*\)", " ", crudo)
        dentro = " ".join(p for p in re.split(r"[\s.,-]+", fold(dentro)) if p and p not in self.SIGLAS_EN_PARENTESIS and p not in ("DE", "DEL"))
        fuera = fold(fuera).replace("GRAL ", "GENERAL ")
        candidatos = [fuera, dentro, f"{fuera} {dentro}".strip(), f"{fuera} DE {dentro}".strip()]
        return [c for c in dict.fromkeys(candidatos) if c]

    def codigo(self, sigla: str | None, municipio: str | None) -> tuple[str | None, str]:
        """Código del padrón y CÓMO se cruzó; `None, "sin-cruce"` si ninguna regla lo resuelve."""
        if not sigla or not municipio or fold(municipio) in ("", "NONE", "NO DEFINIDO"):
            return None, "sin-dato"
        dep = self.por_dep.get(sigla, {})
        alias = MUNICIPIO_ALIAS.get(f"{sigla}:{fold(municipio)}")
        if alias is not None:
            return dep[slug(alias)], "alias"
        variantes = self._variantes(municipio)
        for v in variantes:
            if slug(v) in dep:
                return dep[slug(v)], "nombre"
        nombres = {k.upper().replace("_", " "): codigo for k, codigo in dep.items()}
        for v in variantes:
            prefijo = [c for n, c in nombres.items() if n.startswith(v + " ")]
            if len(prefijo) == 1:
                return prefijo[0], "prefijo-unico"
        for v in variantes:
            sufijo = [c for n, c in nombres.items() if v.endswith(" " + n)]
            if len(sufijo) == 1:
                return sufijo[0], "sufijo-unico"
        return None, "sin-cruce"


# --- 1 · AGEMED -------------------------------------------------------------------

def leer_agemed(path: Path, padron: Padron, repetidas: Counter) -> list[dict]:
    import openpyxl

    ws = openpyxl.load_workbook(path, read_only=True, data_only=True).worksheets[0]
    filas = [r for r in ws.iter_rows(values_only=True) if any(c not in (None, "") for c in r)]
    # El encabezado llega con la codificación rota («RESOLUCIÃ“N»): se busca por prefijo.
    cab = [fold(str(c) if c is not None else "") for c in filas[1]]

    def indice(prefijo: str) -> int:
        for i, nombre in enumerate(cab):
            if nombre.startswith(prefijo):
                return i
        sys.exit(f"AGEMED: no está la columna «{prefijo}…»; encabezado: {cab}")

    idx = {p: indice(p) for p in ("NOMBRE DE LA FARMACIA", "TIPO", "DIRECCION", "DEPARTAMENTO", "MUNICIPIO", "LATITUD", "LONGITUD", "TELEFONO", "NO DE RESOLUCI")}
    col = lambda r, nombre: (str(r[idx[nombre]]).strip() if r[idx[nombre]] not in (None, "") else None)
    out, vistos = [], set()
    for r in filas[2:]:
        nombre = col(r, "NOMBRE DE LA FARMACIA")
        if not nombre:
            continue
        sigla = DEPARTAMENTOS.get(fold(col(r, "DEPARTAMENTO")))
        mun_texto = col(r, "MUNICIPIO")
        mun, como = padron.codigo(sigla, mun_texto)
        lat, lon = coord(col(r, "LATITUD"), col(r, "LONGITUD"))
        resolucion = col(r, "NO DE RESOLUCI")
        telefono = col(r, "TELEFONO")
        fid = "agemed-" + stable_id(resolucion, fold(nombre), sigla, fold(mun_texto), fold(col(r, "DIRECCION")))
        # La planilla repite algunas farmacias (mismo nº de resolución, nombre y
        # dirección; a veces con otra coordenada): vale la primera aparición.
        if fid in vistos:
            repetidas["agemed"] += 1
            continue
        vistos.add(fid)
        out.append({
            "id": fid,
            "kind": "PHARMACY",
            "name": nombre,
            "subtype": col(r, "TIPO"),
            "address": col(r, "DIRECCION"),
            "department": sigla,
            "municipalityCode": mun,
            "municipalityText": mun_texto,
            "municipalityMatch": como,
            "latitude": lat,
            "longitude": lon,
            "phone": telefono if telefono and telefono not in ("0",) else None,
            "license": {"number": resolucion, "authority": "AGEMED"} if resolucion else None,
            "source": "agemed",
        })
    return out


# --- 2 · RUES ---------------------------------------------------------------------

def leer_rues(path: Path, padron: Padron) -> list[dict]:
    data = json.loads(path.read_text(encoding="utf-8"))
    C = data["columns"]
    out = []
    for r in data["rows"]:
        v = dict(zip(C, r))
        sigla = DEPARTAMENTOS.get(fold(v["SEDES"]))
        mun, como = padron.codigo(sigla, v["MUNICIPIO"])
        out.append({
            "id": "rues-" + v["COD_ESTABL"],
            "kind": "HEALTH_FACILITY",
            "name": v["ESTABLECIMIENTO"].strip(),
            "subtype": v["TIPO"].strip(),
            "level": v["NIVEL"].strip(),
            "subsector": v["SUBSECTOR"].strip(),
            "institution": v["INSTITUCION"].strip(),
            "setting": {"U": "URBAN", "R": "RURAL"}.get(v["AMBITO"].strip()),
            "beds": int(v["CAMAS"]) if str(v["CAMAS"]).isdigit() else None,
            "network": v["RED_ESTABL"].strip(),
            "province": v["PROVINCIA"].strip().strip("_"),
            "department": sigla,
            "municipalityCode": mun,
            "municipalityText": v["MUNICIPIO"].strip(),
            "municipalityIneCode": v["COD_MUNICIPIO"],
            "municipalityMatch": como,
            "latitude": None,
            "longitude": None,
            "officialCode": v["COD_ESTABL"],
            "source": "rues",
        })
    return out


# --- 3 · Observatorio (sólo lo que ni AGEMED ni RUES cubren) ------------------------

FAMILIA_KIND = {
    "DIAGNOSTICO_IMAGEN": "IMAGING", "OV_RADIOLOGY": "IMAGING",
    "LABORATORIO_CLINICO": "LABORATORY", "OV_LABORATORY_TESTING": "LABORATORY",
    "HOSPITAL": "CLINIC", "CLINICA": "CLINIC", "CLINICA_PRIVADA": "CLINIC", "CONSULTORIO_MEDICO": "CLINIC",
    "POLICONSULTORIO": "CLINIC", "OV_MEDICAL_SERVICE_ORGANIZATION": "CLINIC", "OV_HEALTH_CARE": "CLINIC",
    "OV_EMERGENCY_DEPARTMENT": "CLINIC", "OV_SURGERY_CENTER": "CLINIC", "CENTRO_DIALISIS": "CLINIC",
    "OFTALMOLOGIA": "CLINIC", "FISIOTERAPIA_REHABILITACION": "CLINIC", "PSICOLOGIA_SALUD_MENTAL": "CLINIC",
    "ODONTOLOGIA": "DENTAL", "CONSULTORIO_ODONTOLOGICO": "DENTAL", "OV_GENERAL_DENTISTRY": "DENTAL",
    "OV_COSMETIC_DENTISTRY": "DENTAL", "OV_ORTHODONTICS": "DENTAL", "OV_PEDIATRIC_DENTISTRY": "DENTAL",
    "OV_ENDODONTICS": "DENTAL", "OV_PERIODONTICS": "DENTAL", "OV_ORAL_AND_MAXILLOFACIAL_SURGERY": "DENTAL",
}
# Consultorios de especialidad médica de Overture (`OV_<ESPECIALIDAD>`): también son consultorios.
OV_ESPECIALIDADES = {
    "OV_OBSTETRICS_AND_GYNECOLOGY", "OV_SURGERY", "OV_PLASTIC_AND_RECONSTRUCTIVE_SURGERY", "OV_DERMATOLOGY",
    "OV_UROLOGY", "OV_ORTHOPEDICS", "OV_CARDIOLOGY", "OV_EAR_NOSE_AND_THROAT", "OV_ENDOCRINOLOGY",
    "OV_PEDIATRIC_CLINIC", "OV_VISION_OR_EYE_CARE_CLINIC", "OV_NEUROLOGY", "OV_ONCOLOGY", "OV_GASTROENTEROLOGY",
    "OV_PULMONOLOGY", "OV_INTERNAL_MEDICINE", "OV_RHEUMATOLOGY", "OV_FAMILY_PRACTICE", "OV_FERTILITY_CLINIC",
    "OV_NEPHROLOGY", "OV_REPRODUCTIVE_PERINATAL_AND_WOMENS_CARE", "OV_INFECTIOUS_DISEASE", "OV_ALLERGY_AND_IMMUNOLOGY",
    "OV_ANESTHESIOLOGY", "OV_PROCTOLOGY", "OV_PSYCHOLOGY", "OV_AUDIOLOGY", "OV_PODIATRY", "OV_OCCUPATIONAL_THERAPY",
}
FAMILIA_KIND.update({f: "CLINIC" for f in OV_ESPECIALIDADES})


def origen(id_de_lugar: str) -> str:
    return id_de_lugar.split(":")[0] if ":" in id_de_lugar else "overture"  # GERS id (uuid) = Overture


def leer_observatorio(carpeta: Path, padron: Padron, nombres_oficiales: set[tuple[str, str]]) -> tuple[list[dict], Counter]:
    excluidos: Counter = Counter()
    out, vistos = [], set()
    for f in sorted(carpeta.glob("observatorio-lugares*.csv")):
        for r in csv.DictReader(f.open(encoding="utf-8")):
            kind = FAMILIA_KIND.get(r["familia"])
            if kind is None:
                excluidos[f"familia {r['familia']}"] += 1
                continue
            o = origen(r["id_de_lugar"])
            if o not in ("overture", "fsq"):
                excluidos[f"licencia u origen {o}"] += 1
                continue
            conf = float(r["confianza"]) if r["confianza"] else None
            if o == "overture" and (conf is None or conf < 0.6):
                excluidos["overture con confianza < 0,6"] += 1
                continue
            sigla = CIUDAD_DEPARTAMENTO.get(r["ciudad"])
            if (sigla, fold(r["nombre"])) in nombres_oficiales:
                excluidos["ya está en RUES o AGEMED (mismo nombre y departamento)"] += 1
                continue
            if r["id_de_lugar"] in vistos:
                continue
            vistos.add(r["id_de_lugar"])
            mun, como = padron.codigo(sigla, r["ciudad"])
            lat, lon = coord(r["latitud"], r["longitud"])
            out.append({
                "id": "obs-" + stable_id(r["id_de_lugar"]),
                "kind": kind,
                "name": r["nombre"].strip(),
                "subtype": r["familia"],
                "address": r["direccion"].strip() or None,
                "department": sigla,
                "municipalityCode": mun,
                "municipalityText": r["ciudad"],
                "municipalityMatch": como,
                "latitude": lat,
                "longitude": lon,
                "sourcePlaceId": r["id_de_lugar"],
                "confidence": conf,
                "source": o,
            })
    return out, excluidos


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("--sources", required=True, type=Path, help="carpeta bolivia-sources/")
    a = ap.parse_args()
    src = a.sources
    archivos = {
        "agemed": src / "agemed" / "2026-10" / "farmacias_nacional.xlsx",
        "rues": src / "snis" / "rues_estructura_2026.json",
    }
    for nombre, p in archivos.items():
        if not p.exists():
            sys.exit(f"falta la fuente {nombre}: {p}")
    padron = Padron()
    repetidas: Counter = Counter()
    farmacias = leer_agemed(archivos["agemed"], padron, repetidas)
    establecimientos = leer_rues(archivos["rues"], padron)
    oficiales = {(e["department"], fold(e["name"])) for e in farmacias + establecimientos}
    lugares, excluidos = leer_observatorio(src / "observatorio", padron, oficiales)

    OUT.mkdir(parents=True, exist_ok=True)
    salidas = {"farmacias-agemed.json": farmacias, "establecimientos-rues.json": establecimientos, "lugares-comunitarios.json": lugares}
    for nombre, filas in salidas.items():
        ids = [f["id"] for f in filas]
        dup = [i for i, n in Counter(ids).items() if n > 1]
        if dup:
            sys.exit(f"{nombre}: ids repetidos {dup[:5]}")
        (OUT / nombre).write_text(json.dumps(filas, ensure_ascii=False, indent=0) + "\n", encoding="utf-8")

    def resumen(filas):
        return {
            "filas": len(filas),
            "porDepartamento": dict(sorted(Counter(f["department"] or "?" for f in filas).items())),
            "porTipo": dict(Counter(f["kind"] for f in filas)),
            "conCoordenadas": sum(1 for f in filas if f["latitude"] is not None),
            "municipioCruzado": sum(1 for f in filas if f["municipalityCode"]),
            "municipiosSinCruce": dict(Counter(f"{f['department']}:{f['municipalityText']}" for f in filas if not f["municipalityCode"]).most_common(40)),
        }

    manifest = {
        "generadoPor": "salud-db/build_directorio_oficial.py",
        "fuentes": {
            "agemed": {"archivo": archivos["agemed"].name, "url": "https://www.agemed.gob.bo/archivos_vigilancia/farmacias/farmacias_nacional.xlsx", "actualizacion": "2026-10-01", "sha256": sha256(archivos["agemed"]), "licencia": LICENCIAS["agemed"]},
            "rues": {"archivo": archivos["rues"].name, "url": "https://estadisticas.minsalud.gob.bo/Reportes_Dinamicos/Estructura_2026.aspx", "sha256": sha256(archivos["rues"]), "licencia": LICENCIAS["rues"]},
            "observatorio": {"archivos": sorted(p.name for p in (src / "observatorio").glob("*.csv")), "licencias": {k: LICENCIAS[k] for k in ("overture", "fsq")}},
        },
        "farmacias": resumen(farmacias),
        "establecimientos": resumen(establecimientos),
        "lugaresComunitarios": resumen(lugares),
        "observatorioExcluidos": dict(excluidos.most_common()),
        "repetidasEnLaFuenteFusionadas": dict(repetidas),
    }
    (OUT / "manifest.json").write_text(json.dumps(manifest, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print(json.dumps({k: v for k, v in manifest.items() if k != "fuentes"}, ensure_ascii=False, indent=1)[:6000])


if __name__ == "__main__":
    main()
