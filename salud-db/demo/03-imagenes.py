#!/usr/bin/env python3
"""Imágenes de prueba para las vitrinas y las publicaciones del directorio.

Genera un avatar por perfil público y una portada por publicación, las deja en
el árbol de objetos que espera el adaptador S3 de la API
(`<sha256[:2]>/<sha256>`) y escribe las filas de `common.files` y
`common.file_versions` que hacen falta para que `GET /public/media/:id` las
sirva.

No son fotos: son piezas generadas —iniciales sobre un color estable por
persona, y una tarjeta con la especialidad para cada publicación—. Se cambian
por fotos de verdad reemplazando los bytes y el hash, sin tocar el resto.

La guarda de `downloadPublicMedia` exige categoría IMAGE y sensibilidad NORMAL:
un archivo que no las tenga no se sirve al anónimo aunque exista.

Con `--retratos` el avatar deja de ser las iniciales y pasa a ser un retrato
generado por IA —una persona que no existe, así que no hay derecho de imagen de
nadie—. Es la diferencia entre «hay una imagen» y «parece un directorio
médico»: las iniciales sobre color se ven idénticas al placeholder que dibuja
el front cuando no hay foto, y el cambio no se nota.

Uso:  python imagenes.py [--salida DIR] [--retratos]
"""
import argparse
import hashlib
import sys
import time
import urllib.request
import uuid
from io import BytesIO
from pathlib import Path

import psycopg
from PIL import Image, ImageDraw, ImageFont

sys.path.insert(0, "/home/pablo/Documents/GitHub/ALOVIDA/mantra-core-health-model/salud-db")
import load_seeds

# El espacio uuid5 de estos archivos, para que repetir la corrida no duplique nada.
NS = uuid.UUID("6f9b1f7e-4a3a-5c2e-9f1d-2b7c5a0e8d31")

# Paleta sobria y con contraste suficiente sobre blanco: la tarjeta del
# directorio pone el avatar sobre fondo claro, y un color pastel se pierde.
PALETA = [
    (26, 79, 106), (17, 94, 89), (91, 44, 111), (140, 58, 58),
    (46, 86, 52), (122, 78, 25), (52, 63, 122), (110, 42, 87),
]

FUENTES = [
    "/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf",
    "/usr/share/fonts/truetype/liberation/LiberationSans-Bold.ttf",
    "/usr/share/fonts/TTF/DejaVuSans-Bold.ttf",
]


def fuente(tamano):
    for ruta in FUENTES:
        if Path(ruta).exists():
            return ImageFont.truetype(ruta, tamano)
    return ImageFont.load_default()


def iniciales(nombre):
    partes = [p for p in nombre.split() if p and p[0].isalpha()]
    if not partes:
        return "?"
    if len(partes) == 1:
        return partes[0][:2].upper()
    return (partes[0][0] + partes[-1][0]).upper()


def color_de(clave):
    return PALETA[int(hashlib.sha256(clave.encode()).hexdigest(), 16) % len(PALETA)]


def centrar(draw, caja, texto, font, fill):
    x0, y0, x1, y1 = caja
    izq, arriba, der, abajo = draw.textbbox((0, 0), texto, font=font)
    draw.text(
        (x0 + (x1 - x0 - (der - izq)) / 2 - izq,
         y0 + (y1 - y0 - (abajo - arriba)) / 2 - arriba),
        texto, font=font, fill=fill,
    )


def avatar(nombre, clave):
    """Iniciales blancas sobre el color estable de esa persona."""
    lado = 512
    img = Image.new("RGB", (lado, lado), color_de(clave))
    draw = ImageDraw.Draw(img)
    centrar(draw, (0, 0, lado, lado), iniciales(nombre), fuente(200), (255, 255, 255))
    return img


RETRATOS_URL = "https://thispersondoesnotexist.com/random-person.jpeg"


def retrato(intentos=4):
    """Un rostro generado por IA, recortado a 512×512.

    Cada petición devuelve una cara distinta, así que la única forma de repetir
    es que el servicio sirva la misma dos veces seguidas; el llamador compara
    hashes y reintenta.
    """
    for intento in range(1, intentos + 1):
        try:
            peticion = urllib.request.Request(
                RETRATOS_URL, headers={"User-Agent": "alovida-demo-seed/1.0"}
            )
            with urllib.request.urlopen(peticion, timeout=30) as respuesta:
                datos = respuesta.read()
            img = Image.open(BytesIO(datos)).convert("RGB")
            return img.resize((512, 512), Image.LANCZOS)
        except Exception as error:  # red inestable: reintentar, no abortar
            if intento == intentos:
                raise
            print(f"    reintento {intento} tras {error}")
            time.sleep(2 * intento)


def portada(titular, nombre, clave):
    """Tarjeta de la publicación: especialidad grande, autor al pie."""
    ancho, alto = 1200, 630
    base = color_de(clave)
    img = Image.new("RGB", (ancho, alto), base)
    draw = ImageDraw.Draw(img)

    # Un degradado vertical suave para que no sea un rectángulo plano.
    for y in range(alto):
        f = 1 - (y / alto) * 0.35
        draw.line([(0, y), (ancho, y)],
                  fill=tuple(max(0, min(255, int(c * f))) for c in base))

    draw.rectangle([80, 80, 88, alto - 80], fill=(255, 255, 255))
    draw.text((130, 250), titular, font=fuente(64), fill=(255, 255, 255))
    draw.text((130, 350), nombre, font=fuente(34), fill=(226, 232, 240))
    draw.text((130, alto - 130), "AloVida · divulgación", font=fuente(26),
              fill=(186, 205, 214))
    return img


def guardar(img, destino_raiz, formato="PNG"):
    """Deja la imagen bajo `<sha[:2]>/<sha>` y devuelve (hash, bytes, ruta, mime).

    El prefijo de `FILE_STORAGE_S3_PREFIX` NO va acá: se agrega al subir y en
    las filas. Así el árbol local se sube tal cual bajo el prefijo que toque.

    Los retratos van en JPEG y las piezas generadas en PNG: una foto en PNG
    pesa cinco veces más sin verse mejor, y el tipo declarado tiene que ser el
    que la API deduce de los primeros bytes, no el que uno diga.
    """
    buf = BytesIO()
    if formato == "JPEG":
        img.save(buf, format="JPEG", quality=86, optimize=True, progressive=True)
    else:
        img.save(buf, format="PNG", optimize=True)
    datos = buf.getvalue()
    sha = hashlib.sha256(datos).hexdigest()
    ruta = destino_raiz / sha[:2] / sha
    ruta.parent.mkdir(parents=True, exist_ok=True)
    ruta.write_bytes(datos)
    mime = "image/jpeg" if formato == "JPEG" else "image/png"
    return sha, len(datos), ruta, mime


def conceptos(conn):
    codigos = ["IMAGE", "NORMAL", "FILE_ACTIVE", "RETENTION_STD", "S3",
               "REGION_DEFAULT", "SHA256", "ENC_NONE", "SCAN_CLEAN"]
    filas = conn.execute(
        "SELECT code, id FROM terminology.catalog_concepts"
        " WHERE code_system_version_id = %s AND code = ANY(%s)",
        ("ffda3cef-e77a-5002-8709-e79f32e62fb4", codigos),
    ).fetchall()
    mapa = dict(filas)
    faltan = [c for c in codigos if c not in mapa]
    if faltan:
        raise SystemExit(f"faltan conceptos en el catálogo: {faltan}")
    rol = conn.execute(
        "SELECT id FROM terminology.catalog_concepts WHERE code = %s",
        ("community:MEDIA_ROLE_IMAGE",),
    ).fetchone()
    if not rol:
        raise SystemExit("falta el concepto community:MEDIA_ROLE_IMAGE")
    mapa["MEDIA_ROLE_IMAGE"] = rol[0]
    return mapa


def registrar(conn, cc, tenant_id, nombre_original, sha, tamano, bucket,
              prefijo, mime="image/png"):
    """Crea el archivo y su versión. Idempotente por uuid5 sobre el hash.

    `parseOwnedKey` del adaptador S3 vuelve a derivar la clave desde el hash y
    la compara con la guardada, prefijo incluido. Si no coinciden exactamente,
    la imagen sale 404 aunque el objeto esté en el bucket.
    """
    file_id = str(uuid.uuid5(NS, f"file:{sha}"))
    version_id = str(uuid.uuid5(NS, f"version:{sha}"))
    clave = f"{prefijo}/{sha[:2]}/{sha}" if prefijo else f"{sha[:2]}/{sha}"
    conn.execute(
        "INSERT INTO common.files (id, tenant_id, category_concept_id,"
        " original_name, sensitivity_concept_id, lifecycle_status_concept_id,"
        " retention_class_concept_id, created_at, updated_at, row_version)"
        " VALUES (%s,%s,%s,%s,%s,%s,%s, now(), now(), 1)"
        " ON CONFLICT (id) DO NOTHING",
        (file_id, tenant_id, cc["IMAGE"], nombre_original, cc["NORMAL"],
         cc["FILE_ACTIVE"], cc["RETENTION_STD"]),
    )
    conn.execute(
        "INSERT INTO common.file_versions (id, file_id, version_number,"
        " storage_provider_concept_id, storage_region_concept_id,"
        " bucket_or_container, object_key, storage_uri, mime_type, size_bytes,"
        " checksum_algorithm_concept_id, content_hash,"
        " encryption_status_concept_id, malware_scan_status_concept_id,"
        " uploaded_at, recorded_at)"
        " VALUES (%s,%s,1,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s, now(), now())"
        " ON CONFLICT (id) DO NOTHING",
        (version_id, file_id, cc["S3"], cc["REGION_DEFAULT"], bucket,
         clave, f"s3://{bucket}/{clave}", mime, tamano,
         cc["SHA256"], sha, cc["ENC_NONE"], cc["SCAN_CLEAN"]),
    )
    conn.execute(
        "UPDATE common.files SET current_version_id = %s WHERE id = %s",
        (version_id, file_id),
    )
    return file_id


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--salida", default="/tmp/imagenes-alovida")
    parser.add_argument("--retratos", action="store_true",
                        help="usa rostros generados por IA en vez de iniciales")
    args = parser.parse_args()

    cfg = load_seeds.load_config()
    bucket = cfg.get("FILE_STORAGE_S3_BUCKET") or cfg.get(
        "MINIO_BUCKET", "mantra-redesa-health-files")
    prefijo = (cfg.get("FILE_STORAGE_S3_PREFIX") or "uploads").strip("/")
    raiz = Path(args.salida)

    conn = psycopg.connect(
        host=cfg["POSTGRES_HOST"], port=cfg["POSTGRES_PORT"],
        user=cfg["POSTGRES_USER"], password=cfg["POSTGRES_PASSWORD"],
        dbname=cfg["POSTGRES_DB"],
    )
    try:
        cc = conceptos(conn)

        vitrinas = conn.execute(
            "SELECT id, tenant_id, display_name, coalesce(headline, '')"
            "  FROM community.public_profiles ORDER BY display_name"
        ).fetchall()
        vistos = set()
        for pid, tenant, nombre, _titular in vitrinas:
            if args.retratos:
                for _ in range(3):          # un rostro repetido no sirve de avatar
                    sha, tam, _ruta, mime = guardar(retrato(), raiz, "JPEG")
                    if sha not in vistos:
                        break
                    time.sleep(1)
                vistos.add(sha)
                extension = "jpg"
            else:
                sha, tam, _ruta, mime = guardar(avatar(nombre, str(pid)), raiz)
                extension = "png"
            file_id = registrar(conn, cc, tenant, f"avatar-{nombre}.{extension}",
                                sha, tam, bucket, prefijo, mime)
            conn.execute(
                "UPDATE community.public_profiles"
                "   SET avatar_file_id = %s, updated_at = now() WHERE id = %s",
                (file_id, pid),
            )
        print(f"avatares: {len(vitrinas)}")

        publicaciones = conn.execute(
            "SELECT sp.id, pp.tenant_id, pp.display_name,"
            "       coalesce(pp.headline, 'Divulgación')"
            "  FROM community.social_posts sp"
            "  JOIN community.public_profiles pp ON pp.id = sp.author_public_profile_id"
            " ORDER BY sp.published_at"
        ).fetchall()
        for post_id, tenant, nombre, titular in publicaciones:
            sha, tam, _ruta, mime = guardar(portada(titular, nombre, str(post_id)), raiz)
            file_id = registrar(conn, cc, tenant, f"post-{post_id}.png",
                                sha, tam, bucket, prefijo, mime)
            medio_id = str(uuid.uuid5(NS, f"media:{post_id}"))
            conn.execute(
                "INSERT INTO community.post_media (id, post_id, file_id,"
                " media_role_concept_id, alt_text, ordinal, created_at)"
                " VALUES (%s,%s,%s,%s,%s,0, now())"
                " ON CONFLICT (id) DO UPDATE SET file_id = EXCLUDED.file_id,"
                "   media_role_concept_id = EXCLUDED.media_role_concept_id,"
                "   alt_text = EXCLUDED.alt_text",
                (medio_id, post_id, file_id, cc["MEDIA_ROLE_IMAGE"],
                 f"{titular} — {nombre}"),
            )
        print(f"portadas: {len(publicaciones)}")

        conn.commit()
    finally:
        conn.close()

    total = sum(1 for _ in raiz.rglob("*") if _.is_file())
    print(f"objetos en {raiz}: {total}")
    print(f"subilos con:  mc cp --recursive {raiz}/ <alias>/{bucket}/{prefijo}/")


if __name__ == "__main__":
    main()
