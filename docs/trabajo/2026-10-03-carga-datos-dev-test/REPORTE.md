# Reporte — Datos visibles en Dev y Test

- Fecha: 2026-10-03 · Plan: [PLAN.md](./PLAN.md) · Ramas: frontend `mockup`, API `test`, modelo `pablo/seed-catalog-collisions-2026-10-03`
- Peldaño de evidencia alcanzado: `VERIFIED` para carga, persistencia y lecturas HTTP; recorrido visual no disponible en esta sesión.
- Avance: 14 microtareas `HECHO` / 16 = 87,5 %. Una `A MEDIAS` y una `BLOQUEADO`.

## Completado

| ID | Qué se logró | Comando | Resultado |
|---|---|---|---|
| H1.S1.M1 | Inventario agregado de Dev y Test | `psql` con `count(*)` | Test antes: 63 personas, 8 profesionales, 53 pacientes, 9.060 conceptos y 117 conjuntos; después: 147, 24, 65, 10.740 y 177. Dev conservaba 119 personas, 17 profesionales, 13 pacientes, 10.717 conceptos y 177 conjuntos al inventariar. |
| H1.S1.M2 | Respaldos previos a la carga | `pg_dump -Fc`, `pg_restore --list` | Tres dumps legibles en `/root/alovida-backups/` del servidor: `2026-10-03-dev-before-data.dump`, `2026-10-03-test-before-data.dump`, `2026-10-03-test-after-migration-before-model.dump`. |
| H1.S1.M3 | Respaldo del 27/09 comparado en base temporal aislada | `pg_restore --section=pre-data --section=data` y consultas agregadas | Exit 0. Tenía 150 usuarios, 114 personas, 96 pacientes y 18 profesionales; 0 encuentros, 0 perfiles públicos y 0 reservas. Test antes de la fusión tenía 130 usuarios, 175 personas, 65 pacientes, 24 profesionales, 17 encuentros, 15.355 perfiles públicos y 19 reservas. Los 96 IDs de pacientes del respaldo no intersectaban los de Test. |
| H2.S1.M1 | Paquete del modelo cargado en Test | `load_seeds.py --skip-prod`; verificador de FK | Exit 0, 101.777 insertados, 1.217 existentes; 6.850 relaciones FK inspeccionadas, 0 huérfanas tras reconciliación. |
| H2.S1.M2 | Dev comprobado sin recarga general | verificador de FK y HTTP | 7.069 relaciones FK inspeccionadas, 0 huérfanas; búsquedas públicas con HTTP 200 y resultados. |
| H2.S1.M3 | Colisiones nuevas de conjuntos reconciliadas | `psql -v ON_ERROR_STOP=1 -f salud-db/demo/00-huerfanas-post-carga.sql` | 4 referencias de definición y 4 de versión reapuntadas; 28 miembros y 4 versiones redundantes retirados; 0 huérfanas. Segunda corrida: 0 cambios y 0 huérfanas. |
| H2.S1.M4 | Publicación acotada al demo | `psql -v ON_ERROR_STOP=1 -f runtime/01-conceptos-demo-test-acotado.sql` | Cuatro `UPDATE 16`, incluidos los 16 posts del paquete; se eliminó el `UPDATE` abierto sobre posts ajenos en la fuente del modelo. |
| H3.S1.M1 | API pública y autenticada con datos | `curl` a dominios Dev y Test | HTTP 200 en búsquedas públicas de profesionales, organizaciones, farmacias, unidades diagnósticas y posts; 16 profesionales públicos y 16 posts en ambos. Login de administración HTTP 200 en ambos. Tras la recuperación histórica, Test devuelve 42 profesionales y 161 pacientes; Dev devolvía 18 y 13 al medirlo. |
| H3.S1.M3 | Auditoría de conceptos de relleno | `/tmp/audit-placeholders.sql` sobre ambas bases | Test: 5.649 referencias `DEFAULT_*` en 11 esquemas; Dev: 5.633. |
| H4.S1.M1 | Test protegido y respaldo antiguo aislado | `pg_dump -Fc`, `pg_restore --list`, `pg_restore --section=pre-data --section=data` | `2026-10-03-test-before-historical-merge.dump` válido; restauración de datos antiguos exit 0 en base temporal, eliminada tras la fusión. |
| H4.S1.M2 | Dependencias delimitadas | `recuperar_perfiles_test.py --audit` | 11 tablas de cuentas y perfiles; 0 restricciones FK con referencias faltantes. Se excluyeron sesiones, refresh tokens, verificaciones caducadas y eventos de seguridad. |
| H4.S1.M3 | Fusión ensayada sin persistir | `recuperar_perfiles_test.py` | 96/96 pacientes, 18/18 profesionales, 114/114 personas y cuentas en transacción; `ROLLBACK: ensayo completo, Test sin cambios`. |
| H4.S1.M4 | Perfiles sintéticos anteriores recuperados en Test | `recuperar_perfiles_test.py --apply`, luego `--audit` | `COMMIT: fusión aplicada`; 0 filas pendientes en 11 tablas. Añadió 114 usuarios, 114 personas, 96 pacientes, 18 profesionales y dependencias. Tres credenciales con correo sintético ya vigente se omitieron para no duplicar acceso. |
| H4.S1.M5 | Persistencia y API verificadas | verificador FK y HTTP autenticado | 6.872 FKs de 1.305 tablas, 0 huérfanas; login HTTP 200, `/profiles/patients?limit=500` HTTP 200 con 161 items, `/profiles/practitioners?limit=100` HTTP 200 con 42 items. |

## A medias

### H3.S1.M2 — Diferencias con mockup

- Qué anda: el paquete real del modelo se cargó en Test y las vitrinas públicas, las búsquedas y el muro devuelven resultados; Dev ya tenía el paquete.
- Qué no anda: hay 736 conceptos `DEFAULT_*` y miles de referencias en módulos operativos. El mockup genera más volumen de perfiles en memoria que el paquete persistente. `GET /public/directory` devuelve 0 porque falta `read_models.public_provider_directory` en ambas bases; la pantalla actual usa las rutas de búsqueda y perfiles.
- Qué falta exactamente: definir valores de concepto de dominio para cada fixture operativo con su procedencia, ampliar el paquete sintético según el alcance de pantallas requerido y validar cada ruta de producto. Los cuerpos de 16 posts todavía usan relleno; el script disponible de textos contiene consejos médicos que requieren revisión editorial antes de publicarse.
- Dónde quedó: auditoría privada en `/tmp/audit-placeholders.sql` del servidor; fuente del modelo en `salud-db/demo/`; faltantes descritos en este reporte.

## Pendiente

| ID | Estado | Qué lo destraba |
|---|---|---|
| H3.S1.M4 | BLOQUEADO | La sesión del navegador integrado devolvió `[]` al listar navegadores; se necesita una sesión disponible para observar pantallas y red. |

## Evidencia

```text
Test: 101777 inserted; 1217 existing; loader exit 0
Test: verificando 6850 FKs de 1111 tablas cargadas; huérfanos totales: 0
Dev: verificando 7069 FKs de 1151 tablas cargadas; huérfanos totales: 0
Test: enums_huerfanos=0, versiones_huerfanas=0, miembros_huerfanos=0, enum_versiones_huerfanas=0
Segunda corrida de reconciliación: UPDATE 0; UPDATE 0; DELETE 0; DELETE 0
Recuperación histórica: 96/96 pacientes; 18/18 profesionales; 114/114 personas y usuarios; COMMIT
Después de la fusión: verificando 6872 FKs de 1305 tablas cargadas; huérfanos totales: 0
API Test: patients_http 200 count 161 items 161 next_cursor false
HTTPS público Dev y Test: profesionales=16; organizaciones=50; farmacias=50; unidades diagnósticas=50; posts=16 (páginas de 50)
```

Auditoría agregada de 11 esquemas, referencias `DEFAULT_*` (Test / Dev): clínica 992/992; diagnósticos 964/964; ERP 951/951; comunidad 627/627; contabilidad 594/594; seguros 528/528; perfiles 317/301; farmacia 222/222; inventario farmacéutico 176/176; agenda 166/166; facturación 112/112.

## No cubierto

- Inspección visual del navegador y consola.
- Paridad exacta del volumen y contenido del mockup. La rama `mockup` intercepta la API y genera fixtures en memoria; no constituye un volcado importable de base.
- Validación editorial de textos médicos y generación/subida de imágenes; no se ejecutaron esos scripts.
- Restauración de los tres dumps nuevos del 03/10; sólo se verificó su índice con `pg_restore --list`.
- Inicio de sesión de las 3 cuentas históricas cuyas credenciales colisionan con correos sintéticos actuales. Sus perfiles sí están en Test; se conservaron las credenciales vigentes.

## Desvíos del plan

- Test se redesplegó durante la sesión y ejecutó sus 25 pasos de migración/seed de API antes de cargar el modelo. Se tomó un tercer respaldo entre ambos pasos.
- Se usó un archivo de entorno privado de modo `staging` para el cargador del modelo; el cargador rechaza explícitamente `production`. No se registraron secretos.
- Se reindexaron 8 documentos de profesionales y 8 de organizaciones en OpenSearch omitiendo un campo geográfico opcional inválido.
- Se comparó y fusionó un respaldo sintético de Test confirmado por el propietario. La restauración completa en base temporal encontró un índice HNSW incompatible; esquema y datos sin índices se restauraron con exit 0. No se copiaron sesiones ni tokens caducados.

Para repetir la auditoría o recuperación, restaurar primero `/root/backup-full-pre-reset-20260927-202817.dump` en una base temporal llamada `alovida_audit_20260927` con `pg_restore --section=pre-data --section=data`; el script versionado `recuperar_perfiles_test.py` usa esa base como origen, hace ensayo con `ROLLBACK` por defecto y sólo persiste con `--apply`. El respaldo inmediato anterior a la fusión está en `/root/alovida-backups/2026-10-03-test-before-historical-merge.dump`.

## Riesgos residuales

- El cargador informó 9 advertencias de calidad: tipos técnicos sintéticos, geodatos opcionales mal formados, variantes Mongo y claves naturales duplicadas. La carga terminó y la comprobación de FK de PostgreSQL dio 0 huérfanas.
- `comprobar-demo.py` en Dev espera 12 pacientes pero la base tiene 13; su aserción está desactualizada.
- Los módulos con `DEFAULT_*` pueden ocultar registros a consultas que filtran por conceptos reales. No hay mapeo seguro para reemplazarlos masivamente sin definir la semántica de cada fila.
- El viejo subdominio SSLIP de Dev devuelve 503. El dominio activo de Dev es `https://app.alovidasalud.com`.

## Decisiones y ambigüedades

- Se interpretó «todos los datos» como catálogos y demo sintética disponible en el modelo, sin copiar datos de producción. El paquete no equivale a todas las pantallas y volúmenes del mockup.
- El propietario confirmó que el respaldo del 27/09 era sintético de Test y pidió recuperarlo en ese entorno. Se preservaron las filas actuales y se añadieron las históricas faltantes.
- Se preservaron los cambios locales previos en los worktrees de frontend y API; se hizo `git fetch` de `dev`, `test` y `mockup` según corresponda, sin mezclar ramas divergentes.
- No se ejecutó la carga general sobre Dev porque el paquete ya estaba presente y podía alterar cuentas existentes. La carga de Test fue aditiva.
