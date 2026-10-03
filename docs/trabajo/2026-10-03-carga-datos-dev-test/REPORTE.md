# Reporte — Datos visibles en Dev y Test

- Fecha: 2026-10-03 · Plan: [PLAN.md](./PLAN.md) · Ramas: frontend `mockup`, API `test`, modelo `pablo/seed-catalog-collisions-2026-10-03`
- Peldaño de evidencia alcanzado: `VERIFIED` para carga, persistencia y lecturas HTTP; recorrido visual no disponible en esta sesión.
- Avance: 8 microtareas `HECHO` / 10 = 80 %. Una `A MEDIAS` y una `BLOQUEADO`.

## Completado

| ID | Qué se logró | Comando | Resultado |
|---|---|---|---|
| H1.S1.M1 | Inventario agregado de Dev y Test | `psql` con `count(*)` | Test antes: 63 personas, 8 profesionales, 53 pacientes, 9.060 conceptos y 117 conjuntos; después: 147, 24, 65, 10.740 y 177. Dev conservaba 119 personas, 17 profesionales, 13 pacientes, 10.717 conceptos y 177 conjuntos al inventariar. |
| H1.S1.M2 | Respaldos previos a la carga | `pg_dump -Fc`, `pg_restore --list` | Tres dumps legibles en `/root/alovida-backups/` del servidor: `2026-10-03-dev-before-data.dump`, `2026-10-03-test-before-data.dump`, `2026-10-03-test-after-migration-before-model.dump`. |
| H2.S1.M1 | Paquete del modelo cargado en Test | `load_seeds.py --skip-prod`; verificador de FK | Exit 0, 101.777 insertados, 1.217 existentes; 6.850 relaciones FK inspeccionadas, 0 huérfanas tras reconciliación. |
| H2.S1.M2 | Dev comprobado sin recarga general | verificador de FK y HTTP | 7.069 relaciones FK inspeccionadas, 0 huérfanas; búsquedas públicas con HTTP 200 y resultados. |
| H2.S1.M3 | Colisiones nuevas de conjuntos reconciliadas | `psql -v ON_ERROR_STOP=1 -f salud-db/demo/00-huerfanas-post-carga.sql` | 4 referencias de definición y 4 de versión reapuntadas; 28 miembros y 4 versiones redundantes retirados; 0 huérfanas. Segunda corrida: 0 cambios y 0 huérfanas. |
| H2.S1.M4 | Publicación acotada al demo | `psql -v ON_ERROR_STOP=1 -f runtime/01-conceptos-demo-test-acotado.sql` | Cuatro `UPDATE 16`, incluidos los 16 posts del paquete; se eliminó el `UPDATE` abierto sobre posts ajenos en la fuente del modelo. |
| H3.S1.M1 | API pública y autenticada con datos | `curl` a dominios Dev y Test | HTTP 200 en búsquedas públicas de profesionales, organizaciones, farmacias, unidades diagnósticas y posts; 16 profesionales públicos y 16 posts en ambos. Login de administración HTTP 200 en ambos; Test devuelve 24 profesionales y 65 pacientes, Dev 18 y 13 al cierre de la medición. |
| H3.S1.M3 | Auditoría de conceptos de relleno | `/tmp/audit-placeholders.sql` sobre ambas bases | Test: 5.649 referencias `DEFAULT_*` en 11 esquemas; Dev: 5.633. |

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
HTTPS público Dev y Test: profesionales=16; organizaciones=50; farmacias=50; unidades diagnósticas=50; posts=16 (páginas de 50)
```

Auditoría agregada de 11 esquemas, referencias `DEFAULT_*` (Test / Dev): clínica 992/992; diagnósticos 964/964; ERP 951/951; comunidad 627/627; contabilidad 594/594; seguros 528/528; perfiles 317/301; farmacia 222/222; inventario farmacéutico 176/176; agenda 166/166; facturación 112/112.

## No cubierto

- Inspección visual del navegador y consola.
- Paridad exacta del volumen y contenido del mockup. La rama `mockup` intercepta la API y genera fixtures en memoria; no constituye un volcado importable de base.
- Validación editorial de textos médicos y generación/subida de imágenes; no se ejecutaron esos scripts.
- Restauración de los dumps; sólo se verificó su índice con `pg_restore --list`.

## Desvíos del plan

- Test se redesplegó durante la sesión y ejecutó sus 25 pasos de migración/seed de API antes de cargar el modelo. Se tomó un tercer respaldo entre ambos pasos.
- Se usó un archivo de entorno privado de modo `staging` para el cargador del modelo; el cargador rechaza explícitamente `production`. No se registraron secretos.
- Se reindexaron 8 documentos de profesionales y 8 de organizaciones en OpenSearch omitiendo un campo geográfico opcional inválido.

## Riesgos residuales

- El cargador informó 9 advertencias de calidad: tipos técnicos sintéticos, geodatos opcionales mal formados, variantes Mongo y claves naturales duplicadas. La carga terminó y la comprobación de FK de PostgreSQL dio 0 huérfanas.
- `comprobar-demo.py` en Dev espera 12 pacientes pero la base tiene 13; su aserción está desactualizada.
- Los módulos con `DEFAULT_*` pueden ocultar registros a consultas que filtran por conceptos reales. No hay mapeo seguro para reemplazarlos masivamente sin definir la semántica de cada fila.
- El viejo subdominio SSLIP de Dev devuelve 503. El dominio activo de Dev es `https://app.alovidasalud.com`.

## Decisiones y ambigüedades

- Se interpretó «todos los datos» como catálogos y demo sintética disponible en el modelo, sin copiar datos de producción. El paquete no equivale a todas las pantallas y volúmenes del mockup.
- Se preservaron los cambios locales previos en los worktrees de frontend y API; se hizo `git fetch` de `dev`, `test` y `mockup` según corresponda, sin mezclar ramas divergentes.
- No se ejecutó la carga general sobre Dev porque el paquete ya estaba presente y podía alterar cuentas existentes. La carga de Test fue aditiva.
