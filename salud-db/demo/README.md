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
| `00-huerfanas-post-carga.sql` | Reapunta las referencias de conjuntos duplicados al catálogo de la API. Compara versiones y códigos de miembros antes de retirar las versiones huérfanas; falla si difieren. |
| `01-conceptos-reales.sql` | Especialidades al sistema de códigos de la API, estado de los 16 profesionales, perfiles públicos atados a un profesional cada uno y sólo las 16 publicaciones del paquete en estado publicado. |
| `02-textos-publicaciones.sql` | Reemplaza el relleno del cuerpo de las 16 publicaciones por divulgación acorde a la especialidad de quien firma. |
| `03-imagenes.py` | Genera un avatar por vitrina y una portada por publicación, y escribe las filas de `common.files` y `common.file_versions` para que `GET /public/media/:id` las sirva. |

Los cuatro primeros son idempotentes: volver a correrlos no duplica nada.

## Hospital Piloto Mantra (personal de apoyo) — datos 100 % ficticios

Escenario del diseño de «personal de apoyo» (secretaria y otros roles). **No depende** de los tres scripts
de arriba: se puede correr sobre una base recién creada (esquema aplicado) o sobre una con los seeds cargados.
Siembra él mismo los conceptos que usa, con los mismos ids que deriva la API, así que no duplica nada si la API
ya arrancó.

| Script | Qué hace |
|---|---|
| `04-hospital-piloto.sql` | Crea el hospital (cuenta de organización, `org_account_mode = ORGANIZATION`) con Sede Central (Edificio A: PB, P1 consulta 101–108, P2 imagen 201–205, P3 quirófanos Q1–Q4, P4 camas 401–420; Edificio B: P1 pediatría, P2 ginecología + eco obstétrica B204) y Sede Norte (N101–N104); 63 espacios con su `location_path`; 7 doctores con servicio y lugares donde atienden; 4 personas de apoyo con vínculo, plantilla, permisos y aceptación del doctor; y un consultorio privado aparte (Dra. Céspedes + Rosa). Incluye una política de sesión, una invitación vigente y 3 respuestas rápidas. |
| `05-verifica-hospital-piloto.sql` | Decide en SQL los casos de prueba 01–08, 11 y 12 del diseño (Ana, Lucía, Marcos, Rosa) y, desde v4.2.76, 17 comprobaciones NEGATIVAS de la política (doctor sin aceptar —sin fecha, revocada o vencida—, responder sin permiso del doctor, recertificación vencida con y sin refresh y dentro de los 15 días de gracia, membresía terminada por estado y por `end_date`, acción sin doctor, doctor de otra organización). Falla si alguna no da lo esperado. Corre dentro de una transacción que se deshace. Requiere el parche `SQL/patches/2026-10-31_v4275_personal_apoyo.sql` (funciones `refresh_effective_support_access` y `support_access_allowed`). |
| `06-verifica-hardening.sql` | (v4.2.76) Intenta cada violación estructural del endurecimiento y exige el SQLSTATE correcto: `tenant_id` NOT NULL con FK e índice en las 7 tablas hijas; el tenant del hijo = tenant del padre (disparador); la foto FIXED sin filas válidas; los únicos parciales (política de sesión activa, vínculo activo, uso aceptado, membresía activa); el horario y la zona horaria de la política de sesión; `search_path` fijo y sin `EXECUTE` para PUBLIC en las 4 funciones; el refresco global exige contexto de sistema; y, si la base ya usa RLS, que `mantra_app` ve solo su organización; (v4.2.77) `tenant_memberships.origin_concept_id` (uuid NULL + FK + índice) y el único del documento nacional activo de paciente en su forma canónica (5 variantes rechazadas con `23505`; persona de contacto, fila cerrada, otro tipo/estado y otro número pasan). Transacción que se deshace. |

Todas las cuentas demo usan la contraseña `Demo-Apoyo-2026`; el documento de acceso es
`DEMO-<NOMBRE-APELLIDO>` (p. ej. `DEMO-ANA-GUTIERREZ`). No cargar en producción.

### Bandera obligatoria `demo_accounts` (v4.2.76, revisión de seguridad B4)

`04-hospital-piloto.sql` crea 13 cuentas con una contraseña CONOCIDA y el MISMO hash argon2id, incluida la del administrador del
hospital. Por eso **no corre sin una bandera explícita**: sin ella falla con un mensaje claro y SQLSTATE `42501` ANTES de escribir nada
(todo el script es una sola transacción, así que tampoco deja nada aunque se corra sin `ON_ERROR_STOP`). Con ella emite un `WARNING`
con el nombre de la base. Cualquiera de estas formas sirve (valores aceptados: `1`, `true`, `on`, `yes`):

```sh
psql -v ON_ERROR_STOP=1 -v demo_accounts=1 -d <base> -f salud-db/demo/04-hospital-piloto.sql   # variable psql
PGOPTIONS="-c mantra.demo_accounts=1" psql -v ON_ERROR_STOP=1 -d <base> -f salud-db/demo/04-hospital-piloto.sql   # ajuste de sesión
# dentro de una sesión interactiva:  \set demo_accounts 1   y luego   \i salud-db/demo/04-hospital-piloto.sql
```

Sólo en bases de demostración o pruebas. En una base real no hay motivo para pasar la bandera; si alguien la pasó por error, las cuentas
se retiran borrando las filas con `external_subject LIKE 'DEMO-%'` (y sus `users`, `persons` y membresías).

```sh
psql -v ON_ERROR_STOP=1 -v demo_accounts=1 -d <base> -f salud-db/demo/04-hospital-piloto.sql
psql -v ON_ERROR_STOP=1 -d <base> -f salud-db/demo/05-verifica-hospital-piloto.sql
psql -v ON_ERROR_STOP=1 -d <base> -f salud-db/demo/06-verifica-hardening.sql
```

Desde v4.2.76 la demo carga también la ACEPTACIÓN del doctor para toda persona de apoyo (`support_access_allowed` la exige): Lucía
acepta a Pérez, Méndez y Vaca; Marcos a Antelo, Suárez y Rojas; ninguna de las dos puede responder en su nombre. Las filas de las
tablas con `tenant_id` (`support_scope_grants`, `support_grant_actions`, `practitioner_location_assignments`) lo traen: el del hospital o
el del consultorio de la Dra. Céspedes.


### Gobierno de accesos (v4.2.78): piloto extendido y verificación

Extiende el hospital piloto para probar los permisos de ultra granularidad y el gobierno de usuarios (`CONTRATO-GOBIERNO.md` §10). Requiere
**04** y los parches **v4275**, **v4278** y **v4279** (v4.2.79: `tenant_id` en `organization_user_assignments` y `practitioner_delegate_assignments`; los INSERT de 04 y 07 ya lo traen). Usa la misma bandera `demo_accounts` (crea 6 cuentas con la contraseña conocida).

| Script | Qué hace |
|---|---|
| `07-gobierno-hospital-piloto.sql` | Agrega 6 cuentas (Sofía Camacho, jefa de Ecografía; Ricardo Terceros, jefe del Piso 1; Mario Salvatierra, caja; Nora Villarroel, enfermería sin dueño de cuenta; Pablo Mamani, central telefónica que se va y lleva 70 días sin uso; Gonzalo Pinto, segundo administrador de seguridad), 7 pacientes ficticios (3 con bandera VIP / confidencial / familiar de personal; Carmen y Mateo con cobertura, Sandra sin fecha de nacimiento), 13 citas (A1…A12 + la pendiente de Pablo), permisos con condiciones (Ana×Rojas con los 20 átomos del paquete v2, límites y aprobación del doctor; Marcos×Suárez Norte; Sofía y Ricardo con el preajuste «Jefe de servicio»; Mario con tope de monto), una concesión `DENY` de Ana sobre Rojas, 3 reglas de la organización (techo, condición obligatoria, piso de campo), la campaña vencida «Certificación Q4-2026» (6 ítems: 2 certificados, 1 revocado, 3 pendientes ya escalados), un cuatro ojos pendiente (Marcos pide cancelar la cita A4), la excepción SoD de Ricardo (`SOD-GOV-03`, activa hasta el 2026-12-31, aprobada por Gonzalo), uso (Marcos: 18 búsquedas en la última hora) y 2 anomalías abiertas, los casos de ingreso de Mario (completo) y Nora (abierto) y el trabajo que Pablo deja pendiente (3 conversaciones, 2 tareas, 1 cita). Las fechas son **absolutas** y el «hoy» de las pruebas es el martes 2026-11-03 10:30 (America/La_Paz). **Ojo con el reloj real:** Ana vence el 2026-11-23 y la gracia de 15 días termina el 2026-12-08; con la fecha real posterior a eso `05` (caso 01) y la agenda de Ana dejan de dar acceso hasta recertificarla (el demo es de fechas absolutas; fíjese el reloj del escenario o recargue con fechas nuevas). Idempotente. Desde v4.2.78-B7d trae también lo que la API necesita para recorrerlo de punta a punta: agendas con `resource_ref_type = health_practitioner_profiles`
(el nombre calificado `profiles.health_practitioner_profiles` daba `DOCTOR_NOT_ACCEPTED`; 07 y 09 lo normalizan también en una base ya cargada), la cita A4 en **N102** de la Sede Norte
(no en B102: así la cubre el permiso Suárez × Sede Norte de Marcos), el vínculo de Nora creado el 2026-11-03 (posterior a `onboardingRequiredSince`, para que la compuerta de ingreso la
alcance) y Ana con `next_recertification_at = 2026-11-23`. El demo NO trae la regla de red del bucle local (`127.0.0.0/8`): quien llegue por `localhost` con `network.require = ORG_RULES`
(un smoke con supertest, un Playwright contra la API local) la agrega en su propio fixture. |
| `08-verifica-gobierno.sql` | Verifica (con `ROLLBACK`): **G1** 73 átomos en 7 categorías con los conteos del diseño y los 15 antiguos intactos; **G2** 11 reglas SoD (6 duras), 7 plantillas v2 con su techo y el rol `SUPPORT_STAFF`; **G3** las 12 tablas nuevas con `tenant_isolation` (si la base usa RLS); **G4** los CHECK (`23514`: auto-aprobación del cuatro ojos, hash mal formado, excepción SoD a más de 180 días, condición con `schemaVersion` distinto, comentario corto al revocar un ítem, ventana de anomalía invertida…) y los únicos parciales (`23505`); **G5** los disparadores (revisor = titular del vínculo, tenants cruzados, regla de la organización que afloja a la de plataforma); **G6** `access_decision_log` rechaza `UPDATE` y `DELETE`; **G7** `refresh_effective_support_access` **no** materializa una concesión `DENY` ni una acción reemplazada; **G8** funciones con `search_path` fijo y sin `EXECUTE` para `PUBLIC`; **G9** el piloto extendido (solo si 07 está cargado) y, en **G-9y1…4**, las cuatro correcciones de arriba con su precondición (si la API ya usó la base —recertificó a Ana, movió A4—, falla con «PRECONDICIÓN DEL DEMO NO CUMPLIDA» y se recarga 04 → 07 → 09 en una base limpia); **G10** con RLS, `mantra_app` ve solo su organización en las 13 tablas con tenant (las 11 nuevas y los vínculos y delegaciones) y no escribe en otra ni en la plataforma; **G11** (v4.2.79) `tenant_id` + disparador + RLS en los vínculos y las delegaciones, `TRUNCATE` de la bitácora WORM rechazado (`23001`) y sin `UPDATE/DELETE/TRUNCATE` para `mantra_app`, y `support_access_allowed` respeta un `DENY`. |

```sh
psql -v ON_ERROR_STOP=1 -v demo_accounts=1 -d <base> -f salud-db/demo/07-gobierno-hospital-piloto.sql
psql -v ON_ERROR_STOP=1 -d <base> -f salud-db/demo/08-verifica-gobierno.sql
psql -v ON_ERROR_STOP=1 -d <base> -f salud-db/demo/05-verifica-hospital-piloto.sql   # la referencia gruesa sigue dando sus 12 casos y 17 negativos
```

`05` y `06` siguen en verde **después** de `07`: las concesiones de Ana×Rojas y Marcos×Suárez Norte conservan sus filas alias de 04 y reciben
además los átomos (si un permiso trae el alias y el átomo, gana el átomo), y la referencia SQL no sabe de átomos ni de `DENY`. Con una base que
ya usa RLS (`2026-08-05_tenant_rls.sql` aplicado antes del v4278) `06` (H7, H8) y `08` (G3, G10) ejercen el rol `mantra_app` (solo si el rol existe **y** tiene los permisos de `2026-08-05_tenant_rls.sql`; si no, se omiten con un aviso).

### Agenda y chat de piloto (v4.2.78, B7a) y verificaciones de integración

El frontend sembraba la agenda y el chat con scripts sueltos que se perdían al reiniciar; ahora son parte del demo. Requiere **04** y los parches **v4275** y
**v4278** (07 no hace falta; el orden entre 07 y 09 da igual: las 5 agendas que ya trae 07 se reutilizan con el mismo id). Misma bandera `demo_accounts`.

| Script | Qué hace |
|---|---|
| `09-agenda-chat-piloto.sql` | Una agenda por doctor (8, con los 3 que 07 no cubre: Vaca, Flores y la Dra. Céspedes), **96 cupos de 30 minutos** del miércoles 2026-11-04 al viernes 2026-11-06 (89 libres + 7 reservados; a distinto horario por espacio de un mismo doctor, nadie ofrece dos lugares a la misma hora), 7 reservas confirmadas, **4 pacientes con cuenta** (sin credenciales) cuya persona se vincula a su cuenta por `profiles.person_account_links` (`profiles:ACCOUNT_LINK_ACTIVE`, titular, verificado) y tiene su `patient_profiles` —así la bandeja resuelve el `patientProfileId` y el motivo de la cita—, perfiles públicos de chat de los 8 doctores y los 4 pacientes y 4 conversaciones directas con su mensaje. **Todos los ids son uuid5 reales** (versión 5, variante RFC 4122: pasan `IsUUID` de los validadores de la API; los ids sacados de md5 se rechazaban). Idempotente. |
| `10-verifica-agenda-chat-piloto.sql` | Solo lee (`ROLLBACK`): 8 agendas (con `resource_ref_type` que la API reconoce, V1b), 96 cupos sin pisarse, ids uuid 5, `patientProfileId` resuelto con la MISMA consulta de la API (4/4), conversaciones y que la bandeja de Ana y la de Lucía las alcanzan. |
| `11-verifica-onboarding-y-admin.sql` | **A** el administrador del hospital es `SECURITY_ADMIN` (con o sin 07; antes solo traía `USER` y las rutas `/org/*` daban 403 `ROLE_INSUFFICIENT`); **B** los 4 vínculos de 04 están completos (`onboarding_completed_at = created_at`, D-03); **C** 07 deja a Nora incompleta y al resto completo; **D** re-ejecuta el parche v4278 (y después el v4279, que restituye lo que el v4278 pisa) tras simular el estado anterior y comprueba que la sección 7b completa los vínculos existentes y no toca uno con caso de ingreso abierto. Se corre **desde la raíz del repo** (usa `\i` del parche; otra ruta con `-v patch=…`). |

```sh
psql -v ON_ERROR_STOP=1 -v demo_accounts=1 -d <base> -f salud-db/demo/09-agenda-chat-piloto.sql
psql -v ON_ERROR_STOP=1 -d <base> -f salud-db/demo/10-verifica-agenda-chat-piloto.sql
psql -v ON_ERROR_STOP=1 -d <base> -f salud-db/demo/11-verifica-onboarding-y-admin.sql
```

**«Mi 05 o mi 06 fallan» casi siempre es una base usada, no el modelo.** `05` (caso 01) y `06` (H-4h) buscan a Ana Gutiérrez y suponen su vínculo vivo. Si
alguien la dio de baja por la API o por el front («terminar vínculo»), el vínculo queda `REVOCADO` y la membresía terminada: el caso 01 dice «Ana debía poder…» y
H-4h copia un vínculo ya revocado (no choca con el único parcial). Desde v4.2.78 ambos scripts empiezan con una **precondición** que lo dice con todas las letras
(«PRECONDICIÓN DEL DEMO NO CUMPLIDA…») y se arregla recargando 04 (y 07) sobre una base limpia. Las pruebas de integración de la API corren contra una base propia
y limpia por ese motivo.

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

## Alcance

Estos scripts cubren lo que sostiene el directorio público y el muro. Los datos
de farmacia e inventario, facturación, contabilidad, agenda y el resto de los
módulos operativos conservan los conceptos placeholder del mock, y por eso las
consultas del producto no los ven. Para un módulo nuevo el patrón es el mismo:
encontrar el concepto real que la consulta pide y reemplazar el `DEFAULT_*`.
