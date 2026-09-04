# Datos de demostración: de la carga cruda a pantallas que muestran algo

`load_seeds.py` deja la base llena y las pantallas vacías. Estos tres scripts son
el tramo que falta, y se corren **en orden, después** de la carga.

## Por qué hacen falta

El mock de `seedsGenerales` es válido contra el esquema pero no contra el
dominio. Trae nombres y títulos buenos —Mariana Céspedes Arce, médica de
familia— y textos de relleno; lo que no trae es un solo `*_concept_id` correcto:
los rellena con 736 conceptos placeholder `DEFAULT_*` cuyo display literal es
«Catalog concepts — Terminology». Como cada consulta del producto filtra por el
concepto **real** (`community:PROFILE_VISIBILITY_PUBLIC`, `ACTIVE`,
`profiles:PRACTICE_ACTIVE`), esas filas existen y no se ven. El directorio
público quedaba vacío con 16 profesionales cargados.

A eso se suma que los dos paquetes de siembra usan esquemas de uuid5 distintos:
cargar el paquete sobre una base ya sembrada por la cadena de la API duplica
conceptos y deja huérfanas, porque la carga corre con
`session_replication_role = replica` y sin FKs que la frenen.

## Los scripts

| Script | Qué arregla |
|---|---|
| `00-huerfanas-post-carga.sql` | Las 4 filas que la carga deja apuntando a `value_sets` que no insertó, porque ya existía uno con el mismo `internal_code` bajo otro id. |
| `01-conceptos-reales.sql` | Especialidades al sistema de códigos de la API, estado de los 16 profesionales, perfiles públicos atados a un profesional cada uno, publicaciones en estado publicado. |
| `02-textos-publicaciones.sql` | Reemplaza el relleno del cuerpo de las 16 publicaciones por divulgación acorde a la especialidad de quien firma. |
| `03-imagenes.py` | Genera un avatar por vitrina y una portada por publicación, y escribe las filas de `common.files` y `common.file_versions` para que `GET /public/media/:id` las sirva. |

Los cuatro son idempotentes: volver a correrlos no duplica nada.

## Las dos trampas de las imágenes

**MinIO tiene que estar arriba y el bucket creado.** La API corre con
`FILE_STORAGE_ADAPTER=s3` apuntando a `minio:9000`; si el contenedor está
parado —o si está arriba pero sin el bucket— no hay imagen que suba ni se
sirva, y el síntoma es un avatar vacío, no un error visible.

**La clave del objeto lleva el prefijo de `FILE_STORAGE_S3_PREFIX`.**
`parseOwnedKey` del adaptador vuelve a derivar la clave desde el hash del
contenido y la compara con la guardada. Si la fila dice `3c/3cc4…` y el
adaptador espera `p5-media/3c/3cc4…`, la respuesta es 404 aunque el objeto esté
en el bucket. El generador ya lo contempla; al subir hay que respetarlo.

## Cómo se corren

```sh
for f in 00-huerfanas-post-carga 01-conceptos-reales 02-textos-publicaciones; do
  docker cp "salud-db/demo/$f.sql" mantra-redesa-postgres-1:/tmp/
  docker exec mantra-redesa-postgres-1 \
    psql -U mantra -d mantra_redesa_health -v ON_ERROR_STOP=1 -f "/tmp/$f.sql"
done
docker exec mantra-redesa-postgres-1 psql -U mantra -d mantra_redesa_health -c ANALYZE
```

Y las imágenes, que necesitan Pillow y MinIO arriba:

```sh
python salud-db/demo/03-imagenes.py            # genera y registra; imprime dónde quedaron
docker cp /tmp/imagenes-alovida mantra-redesa-minio-1:/tmp/imgs
docker exec mantra-redesa-minio-1 sh -c \
  'mc alias set local http://127.0.0.1:9000 $MINIO_ROOT_USER $MINIO_ROOT_PASSWORD &&
   mc cp --recursive /tmp/imgs/ local/mantra-redesa-health-files/p5-media/'
```

## Lo que queda sin cubrir

Sólo se arregló lo que sostiene el directorio público y el muro. Siguen con
conceptos placeholder, y por lo tanto invisibles para el producto, los datos de
farmacia e inventario, facturación, contabilidad, agenda y el resto de los
módulos operativos. El mismo patrón sirve para arreglarlos: encontrar el
concepto real que la consulta pide y reemplazar el `DEFAULT_*`.
