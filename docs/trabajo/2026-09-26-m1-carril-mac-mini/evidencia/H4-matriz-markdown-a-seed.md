# H4 — Matriz: los 12 markdown → seed → tabla → conteo real

> Medido regenerando `tools/bolivia-datasets/extract_datasets.py` (API) contra
> `mantra-core-health-model/markdown_convertidos` y **byte-diffeando** contra los 5
> `.dataset.json` ya comitidos: **0 diferencias en los 5**. No hay deriva hoy.
> Comando: `python3 tools/bolivia-datasets/extract_datasets.py --fuente <model>/markdown_convertidos --salida /tmp/check`

| # | Archivo `.md` | Filas de tabla | ¿Llega a la API? | Camino real | Filas en destino |
|---|---|---:|---|---|---:|
| 1 | `LISTADO_DE_ASEGURADORAS_1.md` | 25 | **Sí** | `extract_datasets.py` → `insurance-carriers.dataset.json` → `bolivia-insurance.catalog.ts` → `BoliviaInsuranceSeedService` | 17 aseguradoras |
| 2 | `LISTA_DE_CLINICAS_PRIVADAS_1.md` | 23 | **Sí** — corrige el hallazgo de la Ola 0, que decía que no | `extract_datasets.py` → **fusionado en** `health-facilities.dataset.json` (`tipo=CLINICA_PRIVADA`) → `bolivia-facilities.catalog.ts` → `BoliviaFacilitiesSeedService` | 22 (de 642 totales) |
| 3 | `LISTA_DE_HOSPITAL_DE_TERCER_SEGUNDO_NIVEL_Y_CAJAS_1.md` | 20 | **Sí** — ídem, corrige la Ola 0 | mismo camino, `tipo=HOSPITAL` / `CAJA_SALUD` | 10 + 7 |
| 4 | `LISTA_DE_HOSPITAL_DE_PRIMER_NIVEL_SANTA_CRUZ_1.md` | 465 | **Sí** | mismo camino, `tipo=CENTRO_SALUD` | 464 |
| 5 | `LISTA_DE_FARMACIAS__LABORATORIOS_Y_ANALISIS_MEDICOS.md` | 23 | **Sí** — corrige la Ola 0 | mismo camino, `tipo=FARMACIA` / `LABORATORIO` / `IMAGEN` | 7 + 10 + 3 |
| 6 | `Arancel_Honorarios_Medicos_Santa_Cruz_2025_3_columnas.md` | 4771 | **Sí** | `extract_datasets.py` → `fee-schedule.dataset.json.datos.honorariosMedicos` → `bolivia-fee-schedule.catalog.ts` → `BoliviaFeeScheduleSeedService` | 4295 |
| 7 | `LISTADO_ARANCEL_ODONTOLOGICO_2026_1.md` | 137 | **Sí** — corrige la Ola 0, que decía que no | mismo camino, `fee-schedule.dataset.json.datos.arancelOdontologico` | 113 |
| 8 | `Alianza_Medicos_Habilitados.md` | 672 | **A medias** | `extract_datasets.py` → `provider-networks.dataset.json.datos.redes[0].profesionales` — **el JSON existe y está al día, pero ningún seed service lo consume todavía** (`grep` de `provider-networks.dataset` en `src/common/seed/**/*.ts` → 0 resultados) | 454 personas distintas, con sus sedes |
| 9 | `Nacional_Seguros_Red_Medica_Bolivia.md` | 746 | **A medias** — mismo hueco | mismo dataset, `redes[1]` | 507 personas distintas |
| 10 | `LISTA_DE_ESPECIALIDADES_ODONTOLOGICAS.md` | 11 | **Sin confirmar** — no se le encontró código propio; puede estar implícito en `observed-specialties.dataset.json` (148 filas, «especialidades que aparecen en las redes y el arancel, para contrastar contra VS_MEDICAL_SPECIALTY»), que sí tiene seed. No se verificó si las 10 especialidades odontológicas del archivo están representadas ahí | — |
| 11 | `USUARIO_MEDICOS_1.md` | 171 (13 con persona) | **No** | sólo `tools/bolivia-datasets/load_people.py`, script manual que nadie corre en el despliegue | 0 |
| 12 | `USUARIO_PACIENTES_1.md` | 166 (92 con persona) | **No** | ídem | 0 |

## El hueco real, medido con precisión

No son "7 listas sin llegar" como decía la verificación de la Ola 0 (eso fue **DISCOVERED**, sin
regenerar). Con el generador corrido de verdad:

- **9 de 12 llegan hoy**, incluidas 3 que se creía que no (clínicas, hospitales 2.º/3.er nivel,
  farmacias/laboratorios: los tres viven **fusionados** en `health-facilities.dataset.json` con un
  campo `tipo` discriminador) y una más (arancel odontológico, fusionado en `fee-schedule`).
- **El hueco real son 3 archivos**: los dos padrones de personas (sin seed, sólo script manual) y
  el directorio de médicos de las aseguradoras (con dataset **extraído y al día**, pero **sin
  ningún seed que lo materialice** en `directory.tenants`/cuentas). Es exactamente el trabajo que
  el reparto ya le asignó a M2 (C1 y C2) — este hallazgo lo **confirma y lo acota**: C2 no tiene
  que escribir el extractor (ya existe y está probado), sólo el seed service que lo consuma.
- **Un archivo queda sin confirmar** (especialidades odontológicas): se registra como ambigüedad,
  no se asume.

## No cubierto

- No se contó filas por tabla en la base viva del VPS (sin acceso SSH). El conteo de «filas en
  destino» es el tamaño del dataset JSON generado, no una consulta a Postgres.
- No se verificó si las 10 especialidades odontológicas del archivo 10 están representadas en
  `observed-specialties.dataset.json` — queda como ambigüedad Q-05.
