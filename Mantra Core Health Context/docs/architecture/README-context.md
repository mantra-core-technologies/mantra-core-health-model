# Índice de contexto — SALUD v4.0 (paquete PUML + markdown)

Este paquete contiene **solo el modelo por módulo (PlantUML) y los markdown de contexto**,
reajustados en v4.0. Es el insumo para mapear la base de datos y generar el ORM.

## Qué hay acá

- `modules/*.puml` — 64 módulos (schemas / bounded contexts). Fuente de verdad del modelo.
- `docs/architecture/` — contexto de dominio y decisiones (incluye la guía de mapeo ORM).
- `docs/validation/` — reportes de validación (estática/semántica) con inventario real.
- `docs/frontend/` — contratos de vistas para los portales.
- `prompt/` — prompts de generación de código (backend/frontend/general).
- `model-manifest.yaml` — manifiesto de módulos (incluye `design_patches` de v4.0.1).
- `docs/architecture/plan-v4.0.1-scheduled-campaigns-tracking.md` — **Patch 1 (v4.0.1)**: plan maestro normativo de envíos programados / Administración del sitio / tracking.
- `docs/architecture/patch-v4.0.1-scheduled-campaigns-tracking.md` — **Patch 2 (v4.0.1)**: 37 casos de uso derivados del Patch 1.
- `docs/architecture/semantic-data-analysis.md` — **análisis semántico** de la estructura de datos (panorámico + orientado a ORM); complementa `orm-mapping-guide.md`.
- `docs/architecture/physical-materialization.md` — **estado del build**: cómo se materializa el modelo en `SQL/`/`NoSQL/`, historial por versión y cifras verificadas contra la base viva.
- `docs/architecture/ddl-sources.md` — **política de fuente única de DDL** (v4.0.9): por qué el esquema solo puede nacer de los `.puml`, y el verificador que lo hace cumplir.

## Cifras reales (v4.0.10 · recontadas el 2026-08-07)

64 PUML · 52 schemas · **2 671** declaraciones `entity` (**1 245** elementos tipo tabla/store ·
81 vistas/read models · 120 stubs `<<REFERENCE_ONLY>>`) · **6 672** FK · **1 225** index sets.
Reproducibles con `python tools/model_inventory.py`, que es la fuente única, y espejadas en el
bloque `inventory:` de `model-manifest.yaml`.

**Ignorar cualquier cifra heredada** ("2607 / 1212 / 6452 / 1194" de v4.0.1 —las que estaban
acá—, "2519 / 2214 / 24" de v3.9 o "1024 / 54" de v3.7/v3.8): quedaron infladas o congeladas al
evolucionar el modelo. El desglose por módulo de `docs/validation/validation-report.md` también
está congelado en v4.0.1.

## Decisión de ORM

**MikroORM** para la capa relacional PostgreSQL. Guía completa de mapeo (convenciones,
las 3 decisiones de mapeo, stereotypes, frontera con stores NoSQL y verificación de
"casa única" del dato clínico) en `docs/architecture/orm-mapping-guide.md`.

## Documentos con "v3.8" en el nombre

`v3.8-change-report.md`, `standards-source-matrix-v3.8.md` y
`v3.8-operational-clinical-views.md` son **registros históricos** de lo que cambió en v3.8;
se conservan a propósito como trazabilidad, no son contexto obsoleto.

## Estado

Este paquete es el **modelo**, no la implementación. Pero el modelo **ya está materializado**:
`SQL/` declara 1 154 tablas · 7 878 índices · 6 661 FKs, y el stack dev se reconstruyó y
verificó (1 180 tablas · 6 661 FKs · 9 107 índices · huérfanos 0). Ver
`physical-materialization.md` para el estado del build y su evidencia.

Lo que **sigue sin afirmarse**: el render gráfico de PlantUML (no hay runtime/JAR en el
entorno de generación) y la aplicación de la política RLS, que vive como patch fuera de
`apply_all.sql` y no se aplica sola. El límite de evidencia de la validación original está en
el reporte de validación, congelado en v4.0.1.
