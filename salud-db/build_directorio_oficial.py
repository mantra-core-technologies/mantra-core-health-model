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

# Overture recomienda descartar lo de confianza baja; 0,6 deja fuera lo dudoso.
CONFIANZA_MINIMA = 0.6

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
        self.nombre: dict[str, str] = {}
        for dep in data:
            sigla = DEPARTAMENTOS[fold(dep["departamento"])]
            for prov in dep["provincias"]:
                for mun in prov["municipios"]:
                    # Mismo código que `municipios_display()` de gen_seeds.py.
                    self.por_dep.setdefault(sigla, {})[slug(mun)] = f"{sigla}-{slugify(mun).lower()}"
                    self.nombre[f"{sigla}-{slugify(mun).lower()}"] = mun

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


class Geo:
    """Punto → (departamento, municipio) con los límites de geoBoundaries BOL ADM1/ADM3
    (GeoBolivia, dominio público). Punto en polígono por paridad de cruces, sin
    dependencias; cada polígono lleva su rectángulo para descartar rápido."""

    ISO_DEP = {"BO-B": "be", "BO-C": "cb", "BO-H": "ch", "BO-L": "lp", "BO-N": "pa", "BO-O": "or", "BO-P": "pt", "BO-S": "sc", "BO-T": "tj"}

    def __init__(self, carpeta: Path) -> None:
        self.deps = [(self.ISO_DEP[f["properties"]["shapeISO"]], *self._partes(f)) for f in self._leer(carpeta / "geoBoundaries-BOL-ADM1_simplified.geojson")]
        self.muns = [(f["properties"]["shapeName"], *self._partes(f)) for f in self._leer(carpeta / "geoBoundaries-BOL-ADM3_simplified.geojson")]

    @staticmethod
    def _leer(path: Path) -> list[dict]:
        return json.loads(path.read_text(encoding="utf-8"))["features"]

    @staticmethod
    def _partes(feature: dict):
        g = feature["geometry"]
        polys = g["coordinates"] if g["type"] == "MultiPolygon" else [g["coordinates"]]
        xs = [x for poly in polys for x, _ in poly[0]]
        ys = [y for poly in polys for _, y in poly[0]]
        return (min(xs), max(xs), min(ys), max(ys)), polys

    @staticmethod
    def _en_anillo(x: float, y: float, anillo) -> bool:
        dentro = False
        j = len(anillo) - 1
        for i in range(len(anillo)):
            xi, yi = anillo[i]
            xj, yj = anillo[j]
            if (yi > y) != (yj > y) and x < (xj - xi) * (y - yi) / ((yj - yi) or 1e-12) + xi:
                dentro = not dentro
            j = i
        return dentro

    def _buscar(self, capas, lat: float, lon: float):
        for nombre, (x0, x1, y0, y1), polys in capas:
            if not (x0 <= lon <= x1 and y0 <= lat <= y1):
                continue
            for poly in polys:
                if self._en_anillo(lon, lat, poly[0]) and not any(self._en_anillo(lon, lat, h) for h in poly[1:]):
                    return nombre
        return None

    def ubicar(self, lat: float | None, lon: float | None) -> tuple[str | None, str | None]:
        if lat is None or lon is None:
            return None, None
        return self._buscar(self.deps, lat, lon), self._buscar(self.muns, lat, lon)


# --- 1 · AGEMED -------------------------------------------------------------------

def leer_agemed(path: Path, padron: Padron, geo: Geo, repetidas: Counter) -> list[dict]:
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
        coordenada = "fuente" if lat is not None else None
        dep_punto, mun_punto = geo.ubicar(lat, lon)
        if lat is not None and sigla and dep_punto and dep_punto != sigla:
            # Coordenada en otro departamento que el declarado: no se muestra un
            # pin en el lugar equivocado. El texto de la dirección queda.
            lat = lon = None
            coordenada = "descartada: cae fuera del departamento declarado"
        elif mun is None and mun_punto and sigla == dep_punto:
            mun, como = padron.codigo(sigla, mun_punto)
            como = f"coordenadas ({como})" if mun else como
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
            "coordinateNote": coordenada,
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


# --- 3 · Overture Places (todo lo que ni AGEMED ni el RUES cubren) ------------------

IMAGEN = re.compile(r"\b(IMAGEN|IMAGENES|IMAGENOLOGI|RAYOS X|RX\b|ECOGRAF|TOMOGRAF|RESONANCIA|RADIOLOG|MAMOGRAF|DENSITOMETR|ULTRASONIDO|DIAGNOSTICO POR IMAGEN)")
LABORATORIO = re.compile(r"\b(LABORATORIO|LAB\b|ANALISIS CLINICO|BIOQUIMIC)")

# Lugares que Overture pone en salud y no lo son: laboratorios de ingeniería o de
# alimentos, y comercios de insumos (la categoría «imagen o laboratorio» los mezcla).
NO_ES_SALUD = re.compile(r"\b(HIDRAULIC|SUELOS|MATERIALES|CONCRETO|ALIMENTOS|AGUAS?\b|IMPORTACION|IMPORTADORA|DISTRIBUIDORA|INSUMOS|FERRETERIA|VETERINAR|MASCOTA)")

BASICA_KIND = {
    "hospital": "CLINIC", "health_care": "CLINIC", "medical_service": "CLINIC", "specialized_health_care": "CLINIC",
    "primary_care_or_general_clinic": "CLINIC", "pediatric_clinic": "CLINIC", "specialized_medical_facility": "CLINIC",
    "behavioral_or_mental_health_clinic": "CLINIC", "vision_or_eye_care_clinic": "CLINIC", "dental_clinic": "DENTAL",
}


def clasificar_overture(row: dict) -> tuple[str, str]:
    """Tipo del lugar y la regla que lo decidió (queda en el registro)."""
    nombre = fold(row["name"])
    if row["basic_category"] == "diagnostics_imaging_or_lab_service":
        if row["category"] in ("radiology", "diagnostic_imaging"):
            return "IMAGING", f"categoría Overture {row['category']}"
        if row["category"] == "laboratory_testing":
            return "LABORATORY", "categoría Overture laboratory_testing"
        if IMAGEN.search(nombre):
            return "IMAGING", "categoría Overture de diagnóstico + nombre de imagen"
        if LABORATORIO.search(nombre):
            return "LABORATORY", "categoría Overture de diagnóstico + nombre de laboratorio"
        return "CLINIC", "categoría Overture de diagnóstico sin modalidad en el nombre"
    if row["basic_category"] != "dental_clinic" and IMAGEN.search(nombre):
        return "IMAGING", f"categoría Overture {row['basic_category']} + nombre de imagen"
    if row["basic_category"] != "dental_clinic" and LABORATORIO.search(nombre):
        return "LABORATORY", f"categoría Overture {row['basic_category']} + nombre de laboratorio"
    return BASICA_KIND[row["basic_category"]], f"categoría Overture {row['basic_category']}"


def leer_overture(path: Path, padron: Padron, geo: Geo, oficiales: set[tuple[str, str]], excluidos: Counter) -> list[dict]:
    out = []
    for linea in path.read_text(encoding="utf-8").splitlines():
        r = json.loads(linea)
        if not r["name"]:
            excluidos["overture sin nombre"] += 1
            continue
        if NO_ES_SALUD.search(fold(r["name"])):
            excluidos["overture que no es un servicio de salud (nombre)"] += 1
            continue
        if r["confidence"] is None or r["confidence"] < CONFIANZA_MINIMA:
            excluidos[f"overture con confianza < {CONFIANZA_MINIMA}"] += 1
            continue
        if r["operating_status"] not in (None, "open"):
            excluidos[f"overture {r['operating_status']}"] += 1
            continue
        lat, lon = coord(r["lat"], r["lon"])
        sigla, mun_geo = geo.ubicar(lat, lon)
        if sigla is None:
            excluidos["overture fuera de Bolivia por coordenada"] += 1
            continue
        if (sigla, fold(r["name"])) in oficiales:
            excluidos["ya está en RUES o AGEMED (mismo nombre y departamento)"] += 1
            continue
        mun, como = padron.codigo(sigla, mun_geo)
        kind, regla = clasificar_overture(r)
        direccion = next((a.get("freeform") for a in (r["addresses"] or []) if a.get("freeform")), None)
        licencias = sorted({f"{x['dataset']} ({x['license']})" for x in (r["sources"] or []) if x.get("license")})
        out.append({
            "id": "ovt-" + r["id"],
            "kind": kind,
            "kindRule": regla,
            "name": r["name"].strip(),
            "subtype": r["category"] or r["basic_category"],
            "address": direccion,
            "department": sigla,
            "municipalityCode": mun,
            "municipalityText": mun_geo,
            "municipalityMatch": f"coordenadas ({como})" if mun else "sin-cruce",
            "latitude": lat,
            "longitude": lon,
            "phone": (r["phones"] or [None])[0],
            "website": (r["websites"] or [None])[0],
            "confidence": round(r["confidence"], 3),
            "sourcePlaceId": r["id"],
            "sourceLicenses": licencias,
            "source": "overture",
        })
    return out


def coordenadas_para_rues(establecimientos: list[dict], lugares: list[dict]) -> int:
    """Un establecimiento del RUES toma la coordenada de un lugar de Overture sólo si
    tienen EXACTAMENTE el mismo nombre (plegado) en el mismo municipio y el nombre
    es único en los dos lados. Lo demás queda sin coordenada."""
    clave = lambda e: (e["municipalityCode"], fold(e["name"]))
    rues = Counter(clave(e) for e in establecimientos if e["municipalityCode"])
    ovt = Counter(clave(l) for l in lugares if l["municipalityCode"] and l["latitude"] is not None)
    por_clave = {clave(l): l for l in lugares if ovt[clave(l)] == 1}
    n = 0
    for e in establecimientos:
        k = clave(e)
        if e["municipalityCode"] and rues[k] == 1 and k in por_clave:
            l = por_clave[k]
            e["latitude"], e["longitude"] = l["latitude"], l["longitude"]
            e["coordinateNote"] = f"de Overture {l['sourcePlaceId']}: mismo nombre en el mismo municipio"
            n += 1
    return n


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("--sources", required=True, type=Path, help="carpeta bolivia-sources/")
    ap.add_argument("--overture-release", default="2026-09-23.1")
    a = ap.parse_args()
    src = a.sources
    archivos = {
        "agemed": src / "agemed" / "2026-10" / "farmacias_nacional.xlsx",
        "rues": src / "snis" / "rues_estructura_2026.json",
        "overture": src / "overture" / f"salud-bolivia-{a.overture_release}.jsonl",
        "adm1": src / "geo" / "geoBoundaries-BOL-ADM1_simplified.geojson",
        "adm3": src / "geo" / "geoBoundaries-BOL-ADM3_simplified.geojson",
    }
    for nombre, p in archivos.items():
        if not p.exists():
            sys.exit(f"falta la fuente {nombre}: {p}")
    padron = Padron()
    geo = Geo(src / "geo")
    repetidas: Counter = Counter()
    excluidos: Counter = Counter()
    farmacias = leer_agemed(archivos["agemed"], padron, geo, repetidas)
    establecimientos = leer_rues(archivos["rues"], padron)
    oficiales = {(e["department"], fold(e["name"])) for e in farmacias + establecimientos}
    lugares = leer_overture(archivos["overture"], padron, geo, oficiales, excluidos)
    rues_con_coordenada = coordenadas_para_rues(establecimientos, lugares)
    for fila in farmacias + establecimientos + lugares:
        # El nombre del padrón, tal como lo muestra la app (`vs_bo_municipality`).
        fila["municipalityName"] = padron.nombre.get(fila["municipalityCode"]) if fila["municipalityCode"] else None

    OUT.mkdir(parents=True, exist_ok=True)
    viejo = OUT / "lugares-comunitarios.json"
    if viejo.exists():
        viejo.unlink()
    salidas = {"farmacias-agemed.json": farmacias, "establecimientos-rues.json": establecimientos, "lugares-overture.json": lugares}
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
            "comoSeCruzoElMunicipio": dict(Counter(f["municipalityMatch"] for f in filas)),
            "municipiosSinCruce": dict(Counter(f"{f['department']}:{f['municipalityText']}" for f in filas if not f["municipalityCode"]).most_common(40)),
        }

    manifest = {
        "generadoPor": "salud-db/build_directorio_oficial.py",
        "fuentes": {
            "agemed": {"archivo": archivos["agemed"].name, "url": "https://www.agemed.gob.bo/archivos_vigilancia/farmacias/farmacias_nacional.xlsx", "actualizacion": "2026-10-01", "sha256": sha256(archivos["agemed"]), "licencia": LICENCIAS["agemed"]},
            "rues": {"archivo": archivos["rues"].name, "url": "https://estadisticas.minsalud.gob.bo/Reportes_Dinamicos/Estructura_2026.aspx", "sha256": sha256(archivos["rues"]), "licencia": LICENCIAS["rues"]},
            "overture": {"archivo": archivos["overture"].name, "version": a.overture_release, "extraidoCon": "salud-db/extract_overture_salud.py", "sha256": sha256(archivos["overture"]), "licencia": "CDLA-Permissive-2.0 / Apache-2.0 / CC0-1.0 según sources[].license de cada lugar", "confianzaMinima": CONFIANZA_MINIMA},
            "limites": {"archivos": [archivos["adm1"].name, archivos["adm3"].name], "url": "https://www.geoboundaries.org (gbOpen BOL, de GeoBolivia)", "licencia": "dominio público"},
        },
        "farmacias": resumen(farmacias),
        "establecimientos": {**resumen(establecimientos), "coordenadaTomadaDeOverture": rues_con_coordenada},
        "lugaresOverture": resumen(lugares),
        "overtureExcluidos": dict(excluidos.most_common()),
        "repetidasEnLaFuenteFusionadas": dict(repetidas),
        "noUsado": "El CSV del observatorio que entregó el propietario: su parte AGEMED la reemplaza la lista vigente de AGEMED, su parte SNIS el RUES 2026, su parte Overture la extracción nacional de Overture, y su parte OSM/Geofabrik es ODbL (no se usa).",
    }
    (OUT / "manifest.json").write_text(json.dumps(manifest, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print(json.dumps({k: v for k, v in manifest.items() if k != "fuentes"}, ensure_ascii=False, indent=1)[:8000])


if __name__ == "__main__":
    main()
