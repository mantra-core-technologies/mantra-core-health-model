#!/usr/bin/env python3
"""normalize_padron.py — deja los nombres y los correos del padrón en una sola forma.

## Por qué existe

`markdown_convertidos/` son las planillas del stakeholder pasadas a tablas
markdown, y llegan escritas **enteras en mayúsculas**: «XIOMARA», «CUELLAR
JUSTINIANO», «XIOMARACUELLAR.XCJ@GMAIL.COM». Esas celdas no son un formato
interno que alguien traduzca después: `tools/bolivia-datasets/load_people.py` de
la API las manda tal cual al alta, y `extract_datasets.py` las copia al dataset
de redes de prestadores. El resultado es el nombre que el paciente lee en
pantalla y el correo con el que la persona inicia sesión.

El correo en mayúsculas es además un riesgo concreto y no sólo estético: la
parte local de una dirección es sensible a mayúsculas para la RFC 5321 y el
login normaliza a minúscula, así que una cuenta dada de alta con
«X@GMAIL.COM» puede quedar inalcanzable para su dueño.

Existe como script —y no como una edición hecha a mano una vez— por la misma
razón que `extract_datasets.py`: el stakeholder manda versiones nuevas del
padrón, y lo que hay que poder repetir es la normalización, no recordarla.

## Lo que NO hace

**No agrega acentos.** El padrón dice «MARIA», no «MARÍA», y elegir cuál de las
dos quiso decir es inventar el dato de una persona real. La tilde que ya está se
conserva; la que falta, sigue faltando.

**No toca ninguna otra columna**: ocupación, especialidad, dirección, razón
social y nombre comercial quedan como vinieron. Sólo se normalizan las columnas
que `PADRONES` declara, archivo por archivo.

**No repara filas rotas.** Si una celda trae una coma de más
(«ANTELO DE AGUILERA,, MARISOL»), sale con la coma de más: corregirla es una
decisión sobre el dato, no sobre su forma.

## La regla de las partículas

«ABREGU DE PAZ» es «Abregu de Paz», no «Abregu De Paz»: en castellano la
partícula va en minúscula cuando acompaña al apellido. Pero cuando abre el campo
—el apellido citado solo— se capitaliza: «DEL CARPIO SALCES» es «Del Carpio
Salces». Los artículos (`la`, `las`, `los`) sólo bajan detrás de otra partícula,
para no convertir «LA FUENTE QUEVEDO» en «la Fuente Quevedo».

Las partículas de una sola letra —la `y` y la `e` que unen apellidos— quedan
afuera a propósito: en este padrón una letra suelta es casi siempre una inicial,
y bajarla haría «Juan E Perez» → «Juan e Perez».

## Uso

    python salud-db/normalize_padron.py --dry     # informa, no escribe
    python salud-db/normalize_padron.py           # normaliza en el lugar

Es idempotente: la segunda corrida no cambia ningún byte.
"""

import argparse
import re
import sys
from collections import OrderedDict
from pathlib import Path

import paths

PADRONES_DIR = paths.PADRONES_DIR

# Qué columna de qué archivo es un nombre de persona y cuál un correo. El
# binding es explícito y por nombre exacto de columna: no se infiere nada por
# parecido, porque «NOMBRE COMERCIAL» y «RAZON SOCIAL» también dicen «nombre» y
# no son personas.
PADRONES = OrderedDict([
    ("USUARIO_MEDICOS_1.md", dict(
        nombres=("NOMBRE", "NOMBRE 2", "APELLIDO PATERNO", "APELLIDO MATERNO"),
        correos=("CORREO ELECTRONICO",))),
    ("USUARIO_PACIENTES_1.md", dict(
        nombres=("NOMBRE", "NOMBRE 2", "APELLIDO PATERNO", "APELLIDO MATERNO"),
        correos=("CORREO ELECTRONICO",))),
    ("Alianza_Medicos_Habilitados.md", dict(
        nombres=("Nombre del médico",), correos=())),
    ("Nacional_Seguros_Red_Medica_Bolivia.md", dict(
        nombres=("Médico",), correos=())),
])

PARTICULAS = {"de", "del", "da", "das", "do", "dos", "di", "du",
              "la", "las", "los", "van", "von", "der", "den"}
ARTICULOS = {"la", "las", "los"}

LETRAS = r"A-Za-zÁÉÍÓÚÜÑáéíóúüñ"
PALABRA = re.compile(f"[{LETRAS}]+")
NO_LETRA = re.compile(f"[^{LETRAS}]")


def capitalizar(token: str) -> str:
    """Deja en mayúscula la inicial de cada tramo de letras del token.

    Trabaja por tramos y no sobre el token entero para que la puntuación pegada
    sobreviva con la forma correcta: «CUELLAR,» → «Cuellar,», «JOSE-LUIS» →
    «Jose-Luis», «D'AVILA» → «D'Avila», «J.» → «J.».
    """
    return PALABRA.sub(lambda m: m.group(0)[0].upper() + m.group(0)[1:].lower(), token)


def nombre_propio(valor: str) -> str:
    """Normaliza un nombre de persona respetando las partículas del castellano."""
    tramos = re.split(r"(\s+)", valor.strip())
    salida, anterior = [], None
    for tramo in tramos:
        if not tramo or tramo.isspace():
            salida.append(tramo)
            continue
        nucleo = NO_LETRA.sub("", tramo).lower()
        es_particula = (anterior is not None
                        and nucleo in PARTICULAS
                        and (nucleo not in ARTICULOS or anterior in PARTICULAS))
        salida.append(tramo.lower() if es_particula else capitalizar(tramo))
        anterior = nucleo
    return "".join(salida)


def correo(valor: str) -> str:
    """Una dirección de correo es la misma en cualquier caja: se guarda en minúscula."""
    return valor.strip().lower()


def es_separador(celdas: list[str]) -> bool:
    contenido = [c.strip() for c in celdas[1:-1]]
    return bool(contenido) and all(re.fullmatch(r":?-{3,}:?", c) for c in contenido)


def indices_objetivo(celdas: list[str], spec: dict) -> dict:
    """Posición de celda → función normalizadora, según la cabecera de la tabla."""
    objetivo = {}
    for i, celda in enumerate(celdas):
        titulo = celda.strip()
        if titulo in spec["nombres"]:
            objetivo[i] = nombre_propio
        elif titulo in spec["correos"]:
            objetivo[i] = correo
    return objetivo


def reescribir(celda: str, fn) -> str:
    """Aplica la normalización conservando el relleno de la celda."""
    izq, cuerpo, der = re.fullmatch(r"(\s*)(.*?)(\s*)", celda, re.S).groups()
    return izq + fn(cuerpo) + der if cuerpo else celda


def normalizar_archivo(ruta: Path, spec: dict):
    """Devuelve las líneas ya normalizadas y cuántas celdas cambió cada columna."""
    lineas = ruta.read_text(encoding="utf-8").split("\n")
    columnas = None          # None = todavía no vimos la cabecera de una tabla
    titulos: list[str] = []
    cambios = OrderedDict()
    salida = []
    for linea in lineas:
        if not linea.lstrip().startswith("|"):
            columnas = None
            salida.append(linea)
            continue
        celdas = linea.split("|")
        if es_separador(celdas):
            salida.append(linea)
            continue
        if columnas is None:
            titulos = [c.strip() for c in celdas]
            columnas = indices_objetivo(celdas, spec)
            salida.append(linea)
            continue
        for i, fn in columnas.items():
            if i >= len(celdas):
                continue
            nueva = reescribir(celdas[i], fn)
            if nueva != celdas[i]:
                celdas[i] = nueva
                cambios[titulos[i]] = cambios.get(titulos[i], 0) + 1
        salida.append("|".join(celdas))
    return salida, cambios


def main() -> int:
    try:
        sys.stdout.reconfigure(encoding="utf-8")
    except Exception:
        pass
    ap = argparse.ArgumentParser(
        description="Normaliza nombres y correos de los padrones de markdown_convertidos/")
    ap.add_argument("--dry", action="store_true", help="no escribe; solo informa")
    args = ap.parse_args()

    total = 0
    faltantes = []
    for nombre_archivo, spec in PADRONES.items():
        ruta = PADRONES_DIR / nombre_archivo
        if not ruta.exists():
            faltantes.append(nombre_archivo)
            continue
        original = ruta.read_text(encoding="utf-8")
        salida, cambios = normalizar_archivo(ruta, spec)
        nuevo = "\n".join(salida)
        contadas = sum(cambios.values())
        total += contadas
        print(f"{nombre_archivo}: {'sin cambios' if nuevo == original else str(contadas) + ' celdas'}")
        for columna, veces in cambios.items():
            print(f"    {columna}: {veces}")
        if nuevo != original and not args.dry:
            with open(ruta, "w", encoding="utf-8", newline="\n") as fh:
                fh.write(nuevo)

    if faltantes:
        print("\nNo encontrados en " + str(PADRONES_DIR) + ":")
        for f in faltantes:
            print("    " + f)
        return 1
    print(f"\nTOTAL celdas normalizadas: {total}" + ("  (simulación)" if args.dry else ""))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
