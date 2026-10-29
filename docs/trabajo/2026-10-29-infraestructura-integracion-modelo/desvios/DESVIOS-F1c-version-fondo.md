# Desvíos · F1c — `practice.floor_plans.background_file_version_id` (v4.2.70)

Pedido de la API del plano: fijar la VERSIÓN exacta del archivo de fondo (hoy la API firma la
versión vigente y revalida por contenido, que solo mitiga el TOCTOU del archivo).

## Qué se hizo

- `common.file_versions` **existe** (inmutable, sin `tenant_id`; `file_id` → `files`), así que no se
  inventó ninguna tabla. `floor_plans` gana `background_file_version_id uuid NULL`:
  - `NULL` = sigue la versión vigente del archivo (comportamiento anterior).
  - FK compuesta `fk_floor_plans_background_version (background_file_id, background_file_version_id)
    → common.file_versions (file_id, id)`: la versión es **de ese archivo**. Requiere
    `ux_file_versions_file_id_id UNIQUE (file_id, id)` (nuevo en `common`, sobre una columna ya
    única: no cambia datos).
  - `ck_floor_plans_background_version`: no hay versión sin archivo (con MATCH SIMPLE la FK
    compuesta no lo vería).
  - Tenant: no se pidió `(tenant_id, version_id)` porque `file_versions` no tiene `tenant_id`. El
    tenant queda fijado por la cadena `(tenant_id, background_file_id) → files (tenant_id, id)`
    (ya existente) + `(background_file_id, version) → file_versions (file_id, id)`: la versión es de
    un archivo del tenant del lienzo.
  - Cambiar la versión es cambiar el lienzo: `trg_floor_plans_guard` cuenta `background_file_version_id`
    en `v_meta_changed` (`layout_version` +1 por transacción, como con el resto del fondo).
  - Idempotente (`ADD COLUMN IF NOT EXISTS` también para bases con v4.2.68 ya aplicado) y con
    precondición de aborto (versión sin archivo, inexistente o de otro archivo) que se prueba aparte.
- La FK **simple** `background_file_version_id → file_versions(id)` no la genera `gen_ddl`: el vault
  no tiene la nota `FK practice.floor_plans.background_file_version_id.md` y la columna queda en
  «FK sin destino canónico» (comentada en `90_fk_deferred.sql`). La compuesta ya la hace redundante;
  si se quiere la simple, falta esa nota en el repo de documentación.

## Límites (declarados)

- `common.file_versions` **no tiene RLS ni `tenant_id`**: quien conozca el id de una versión la ve. El
  aislamiento de la imagen depende de `common.files` (RLS forzada) y de la cadena de arriba, no de la
  tabla de versiones.
- El fondo solo fija la versión; que su `malware_scan_status` / `integrity_status` sean aceptables
  sigue siendo de la API.
