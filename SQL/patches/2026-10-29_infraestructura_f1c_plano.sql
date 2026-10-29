-- ============================================================================
-- SALUD · patch v4.2.68 (infraestructura hospitalaria F1c · PLANO de planta)
-- + v4.2.70: practice.floor_plans.background_file_version_id (versión exacta del fondo)
-- Fecha: 2026-10-29 · Contrato: SALUD/Arquitectura/infraestructura-hospitalaria/
--   CONTRATO-PLANO.md (repositorio de documentación) §1 y §2
-- Se aplica DESPUÉS de 2026-10-29_infraestructura_f1.sql y de ..._f1b_seguridad.sql
-- (usa practice.care_spaces con tenant_id NOT NULL, su UNIQUE (tenant_id, id) y las
-- funciones audit.structure_history_fill_tenant / structure_history_close_only de F1b).
-- Idempotente: CREATE … IF NOT EXISTS / OR REPLACE / DROP … IF EXISTS / FK y CHECK con
-- `duplicate_object`. Se puede aplicar N veces; la segunda pasada no cambia nada.
--
-- QUÉ AGREGA. Un plano de planta (layout «tipo arquitectónico») por encima del árbol
-- físico, sin tocar el árbol: la jerarquía, el código y la forma de un espacio no cambian
-- porque se mueva su dibujo (CONTRATO-PLANO §2).
--
--   practice.floor_plans      LIENZO: un piso, una zona o el campus. Coordenadas en METROS
--                             reales (x → derecha, y → abajo, origen arriba-izquierda),
--                             grilla, norte, imagen de fondo calibrada, vigencia y
--                             `layout_version` (If-Match del layout; +1 por transacción).
--   practice.space_placements GEOMETRÍA de un espacio en SU lienzo: rectángulo rotable
--                             (RECT) o polígono simple (POLYGON). UN lienzo por espacio.
--   practice.plan_elements    ELEMENTOS de lienzo: muros, puertas, ventanas, aberturas,
--                             escaleras, ascensores, circulación, columnas, anotaciones.
--   audit.floor_plans_history · space_placements_history · plan_elements_history
--                             Historia con tenant_id, SOLO INSERCIÓN (+ cierre de valid_to),
--                             igual que F1b.
--
-- LO QUE LA BASE GARANTIZA (aunque la API tenga un bug o haya dos transacciones):
--   · Tenant: FK compuestas (tenant_id, x_id) → el padre es del MISMO tenant (también la
--     imagen de fondo: common.files gana UNIQUE (tenant_id, id)); RLS tenant_isolation en las 6 tablas.
--   · Versión del fondo (v4.2.70): floor_plans.background_file_version_id fija la versión EXACTA
--     de common.file_versions (inmutable) que se dibuja, para que un reemplazo del archivo no
--     cambie el plano en silencio. NULL = sigue la versión vigente del archivo. La base exige
--     que la versión sea DE ESE archivo (FK compuesta (background_file_id,
--     background_file_version_id) → file_versions (file_id, id); file_versions no tiene
--     tenant_id: el tenant lo fija la FK compuesta (tenant_id, background_file_id) → files) y
--     que no haya versión sin archivo (CHECK; con MATCH SIMPLE la FK compuesta no lo vería).
--   · Geometría válida: 3..64 vértices finitos, polígono SIMPLE (sin cruces ni giros sobre
--     sí mismo, área > 0), rectángulos con ancho/fondo > 0 y rotación en [0,360).
--   · Dentro del lienzo (con la tolerancia de contacto del lienzo).
--   · Los hermanos NO se solapan: EXCLUDE gist sobre el contorno de contacto, por
--     (lienzo, hermandad). «Hermano» = mismo padre en el árbol físico. Dos locales que
--     comparten pared (se tocan) NO se solapan; ese margen es floor_plans.contact_tolerance_m
--     (dato, no constante).
--   · Hijo dentro de la geometría del padre y padre ya ubicado en el MISMO lienzo (o ser
--     el ancla del lienzo): restricción diferida al COMMIT (permite cargar en cualquier orden).
--   · Un espacio, un solo lugar: UNIQUE (care_space_id).
--   · Mover/redimensionar no toca care_spaces: estas tablas no escriben en el árbol.
--   · Mover un espacio de padre en el árbol revalida su dibujo (y el de sus descendientes).
--   · layout_version: +1 por transacción que cambie el lienzo, la geometría o los elementos.
--
-- LO QUE QUEDA EN LA API (necesita catálogos o datos de otros agregados): forma del ancla
-- (LEVEL/BUILDING/WING/AREA/WARD), espacios clausurados, `area_m2` declarada vs calculada
-- (vista practice.v_floor_plan_spaces; umbral practice_settings `infra.plan.area_tolerance_pct`),
-- permisos, escritura de historia y outbox.
--
-- gen_ddl.py NO sabe expresar: tipos geométricos (polygon, box), EXCLUDE, triggers, RLS,
-- FK compuestas ni vistas. Esas piezas viven sólo acá. Lo demás (tablas, columnas de tipo
-- SQL, FK simples, índices) está también en diagram_14_practice.puml / diagram_10_audit.puml
-- y el integrador lo regenera; este patch lo repite con CREATE … IF NOT EXISTS.
--
-- PRECONDICIONES (abortan sin tocar nada; el BEGIN hace rollback de todo):
--   - F1b aplicado (care_spaces con ux_care_spaces_tenant_id_id y funciones de historia).
--   - si ya hay filas y falta el EXCLUDE: ningún par de hermanos solapados.
-- ============================================================================

BEGIN;

-- Igual que F1/F1b: las comprobaciones leen tablas con RLS forzada.
SET LOCAL app.system_context = 'true';

CREATE EXTENSION IF NOT EXISTS btree_gist;  -- requerido por EXCLUDE (uuid WITH =)

-- ------------------------------------------------------------- 0. precondiciones
DO $$
BEGIN
    IF to_regclass('practice.care_spaces') IS NULL
       OR to_regclass('practice.ux_care_spaces_tenant_id_id') IS NULL THEN
        RAISE EXCEPTION 'F1c requiere F1b (practice.care_spaces con UNIQUE (tenant_id, id)). Aplicar 2026-10-29_infraestructura_f1b_seguridad.sql primero.';
    END IF;
    IF to_regprocedure('audit.structure_history_fill_tenant()') IS NULL
       OR to_regprocedure('audit.structure_history_close_only()') IS NULL THEN
        RAISE EXCEPTION 'F1c requiere las funciones de historia de F1b (audit.structure_history_fill_tenant / structure_history_close_only).';
    END IF;
END $$;

-- ------------------------------------------------------------- 1. funciones de geometría
-- Todas IMMUTABLE y con search_path fijo: se usan en CHECK, en el cálculo de columnas
-- derivadas y en el EXCLUDE. Los vértices son jsonb `[[x,y],…]` en metros.

CREATE OR REPLACE FUNCTION practice.plan_vertices_ok(v jsonb, min_n integer, max_n integer)
RETURNS boolean
LANGUAGE plpgsql IMMUTABLE PARALLEL SAFE
SET search_path = pg_catalog, pg_temp
AS $fn$
DECLARE
    p jsonb;
BEGIN
    IF v IS NULL OR jsonb_typeof(v) <> 'array' THEN
        RETURN false;
    END IF;
    IF jsonb_array_length(v) < min_n OR jsonb_array_length(v) > max_n THEN
        RETURN false;
    END IF;
    FOR p IN SELECT e FROM jsonb_array_elements(v) AS e LOOP
        IF jsonb_typeof(p) <> 'array' OR jsonb_array_length(p) <> 2
           OR jsonb_typeof(p -> 0) <> 'number' OR jsonb_typeof(p -> 1) <> 'number' THEN
            RETURN false;
        END IF;
        IF abs((p ->> 0)::numeric) > 100000 OR abs((p ->> 1)::numeric) > 100000 THEN
            RETURN false;
        END IF;
    END LOOP;
    RETURN true;
END $fn$;

CREATE OR REPLACE FUNCTION practice.plan_xs(v jsonb) RETURNS double precision[]
LANGUAGE sql IMMUTABLE PARALLEL SAFE SET search_path = pg_catalog, pg_temp
AS $fn$
    SELECT coalesce(array_agg((e.value ->> 0)::float8 ORDER BY e.ordinality), '{}'::float8[])
      FROM jsonb_array_elements(v) WITH ORDINALITY AS e(value, ordinality)
$fn$;

CREATE OR REPLACE FUNCTION practice.plan_ys(v jsonb) RETURNS double precision[]
LANGUAGE sql IMMUTABLE PARALLEL SAFE SET search_path = pg_catalog, pg_temp
AS $fn$
    SELECT coalesce(array_agg((e.value ->> 1)::float8 ORDER BY e.ordinality), '{}'::float8[])
      FROM jsonb_array_elements(v) WITH ORDINALITY AS e(value, ordinality)
$fn$;

CREATE OR REPLACE FUNCTION practice.plan_orient(ax float8, ay float8, bx float8, by float8, cx float8, cy float8)
RETURNS integer
LANGUAGE sql IMMUTABLE PARALLEL SAFE SET search_path = pg_catalog, pg_temp
AS $fn$
    SELECT CASE WHEN abs((bx - ax) * (cy - ay) - (by - ay) * (cx - ax)) < 1e-9 THEN 0
                WHEN (bx - ax) * (cy - ay) - (by - ay) * (cx - ax) > 0 THEN 1
                ELSE -1 END
$fn$;

CREATE OR REPLACE FUNCTION practice.plan_on_segment(ax float8, ay float8, bx float8, by float8, px float8, py float8)
RETURNS boolean
LANGUAGE sql IMMUTABLE PARALLEL SAFE SET search_path = pg_catalog, pg_temp
AS $fn$
    SELECT px >= least(ax, bx) - 1e-9 AND px <= greatest(ax, bx) + 1e-9
       AND py >= least(ay, by) - 1e-9 AND py <= greatest(ay, by) + 1e-9
$fn$;

-- Dos segmentos se cortan o se tocan (cuenta el contacto).
CREATE OR REPLACE FUNCTION practice.plan_seg_intersect(
    ax float8, ay float8, bx float8, by float8, cx float8, cy float8, dx float8, dy float8)
RETURNS boolean
LANGUAGE plpgsql IMMUTABLE PARALLEL SAFE
SET search_path = pg_catalog, pg_temp
AS $fn$
DECLARE
    o1 integer := practice.plan_orient(ax, ay, bx, by, cx, cy);
    o2 integer := practice.plan_orient(ax, ay, bx, by, dx, dy);
    o3 integer := practice.plan_orient(cx, cy, dx, dy, ax, ay);
    o4 integer := practice.plan_orient(cx, cy, dx, dy, bx, by);
BEGIN
    IF o1 <> o2 AND o3 <> o4 THEN RETURN true; END IF;
    IF o1 = 0 AND practice.plan_on_segment(ax, ay, bx, by, cx, cy) THEN RETURN true; END IF;
    IF o2 = 0 AND practice.plan_on_segment(ax, ay, bx, by, dx, dy) THEN RETURN true; END IF;
    IF o3 = 0 AND practice.plan_on_segment(cx, cy, dx, dy, ax, ay) THEN RETURN true; END IF;
    IF o4 = 0 AND practice.plan_on_segment(cx, cy, dx, dy, bx, by) THEN RETURN true; END IF;
    RETURN false;
END $fn$;

-- Área por la fórmula del cordón (shoelace), en m². Sin signo.
CREATE OR REPLACE FUNCTION practice.plan_polygon_area(v jsonb) RETURNS numeric
LANGUAGE sql IMMUTABLE PARALLEL SAFE SET search_path = pg_catalog, pg_temp
AS $fn$
    WITH p AS (
        SELECT (e.value ->> 0)::numeric AS x, (e.value ->> 1)::numeric AS y, e.ordinality AS o
          FROM jsonb_array_elements(v) WITH ORDINALITY AS e(value, ordinality)
    ), q AS (
        SELECT x, y,
               lead(x, 1, (SELECT x FROM p WHERE o = 1)) OVER (ORDER BY o) AS nx,
               lead(y, 1, (SELECT y FROM p WHERE o = 1)) OVER (ORDER BY o) AS ny
          FROM p
    )
    SELECT abs(sum(x * ny - nx * y)) / 2 FROM q
$fn$;

-- Longitud de una polilínea abierta, en m.
CREATE OR REPLACE FUNCTION practice.plan_polyline_length(v jsonb) RETURNS numeric
LANGUAGE sql IMMUTABLE PARALLEL SAFE SET search_path = pg_catalog, pg_temp
AS $fn$
    WITH p AS (
        SELECT (e.value ->> 0)::numeric AS x, (e.value ->> 1)::numeric AS y, e.ordinality AS o
          FROM jsonb_array_elements(v) WITH ORDINALITY AS e(value, ordinality)
    ), q AS (
        SELECT x, y, lead(x) OVER (ORDER BY o) AS nx, lead(y) OVER (ORDER BY o) AS ny FROM p
    )
    SELECT coalesce(sum(sqrt((nx - x) ^ 2 + (ny - y) ^ 2)), 0) FROM q WHERE nx IS NOT NULL
$fn$;

-- Polígono SIMPLE: 3..64 vértices, sin vértices consecutivos repetidos, sin aristas que se
-- crucen o se toquen (salvo las contiguas en su vértice común), sin giros de 180°, área > 0.
CREATE OR REPLACE FUNCTION practice.plan_polygon_is_simple(v jsonb) RETURNS boolean
LANGUAGE plpgsql IMMUTABLE PARALLEL SAFE
SET search_path = pg_catalog, pg_temp
AS $fn$
DECLARE
    xs float8[];
    ys float8[];
    n  integer;
    i  integer;
    j  integer;
    i2 integer;
    j2 integer;
BEGIN
    IF NOT practice.plan_vertices_ok(v, 3, 64) THEN
        RETURN false;
    END IF;
    xs := practice.plan_xs(v);
    ys := practice.plan_ys(v);
    n := cardinality(xs);
    IF practice.plan_polygon_area(v) < 0.000001 THEN
        RETURN false;
    END IF;
    FOR i IN 1..n LOOP
        i2 := i % n + 1;
        IF xs[i] = xs[i2] AND ys[i] = ys[i2] THEN
            RETURN false;
        END IF;
    END LOOP;
    FOR i IN 1..n - 1 LOOP
        i2 := i % n + 1;
        FOR j IN i + 1..n LOOP
            j2 := j % n + 1;
            IF j = i2 THEN
                -- aristas i (i→i2) y j (j→j2) comparten el vértice j: no pueden volver sobre sí
                IF practice.plan_orient(xs[i], ys[i], xs[j], ys[j], xs[j2], ys[j2]) = 0
                   AND (xs[i] - xs[j]) * (xs[j2] - xs[j]) + (ys[i] - ys[j]) * (ys[j2] - ys[j]) > 0 THEN
                    RETURN false;
                END IF;
            ELSIF j2 = i THEN
                -- aristas j (j→i) e i (i→i2) comparten el vértice i
                IF practice.plan_orient(xs[j], ys[j], xs[i], ys[i], xs[i2], ys[i2]) = 0
                   AND (xs[j] - xs[i]) * (xs[i2] - xs[i]) + (ys[j] - ys[i]) * (ys[i2] - ys[i]) > 0 THEN
                    RETURN false;
                END IF;
            ELSIF practice.plan_seg_intersect(xs[i], ys[i], xs[i2], ys[i2], xs[j], ys[j], xs[j2], ys[j2]) THEN
                RETURN false;
            END IF;
        END LOOP;
    END LOOP;
    RETURN true;
END $fn$;

-- Rectángulo rotable → 4 vértices. (cx,cy) = centro; w = ancho local (eje x), d = fondo
-- local (eje y); rot en grados, SENTIDO HORARIO en pantalla (y hacia abajo), como SVG rotate().
CREATE OR REPLACE FUNCTION practice.plan_rect_vertices(cx numeric, cy numeric, w numeric, d numeric, rot numeric)
RETURNS jsonb
LANGUAGE sql IMMUTABLE PARALLEL SAFE SET search_path = pg_catalog, pg_temp
AS $fn$
    SELECT jsonb_agg(jsonb_build_array(
               round((cx::float8 + c.lx::float8 * cos(q.r) - c.ly::float8 * sin(q.r))::numeric, 3),
               round((cy::float8 + c.lx::float8 * sin(q.r) + c.ly::float8 * cos(q.r))::numeric, 3))
           ORDER BY c.o)
      FROM (VALUES (1, -w / 2, -d / 2), (2, w / 2, -d / 2), (3, w / 2, d / 2), (4, -w / 2, d / 2)) AS c(o, lx, ly),
           LATERAL (SELECT radians(rot::float8) AS r) AS q
$fn$;

CREATE OR REPLACE FUNCTION practice.plan_vertices_to_polygon(v jsonb) RETURNS polygon
LANGUAGE sql IMMUTABLE PARALLEL SAFE SET search_path = pg_catalog, pg_temp
AS $fn$
    SELECT ('(' || string_agg('(' || (e.value ->> 0) || ',' || (e.value ->> 1) || ')', ',' ORDER BY e.ordinality) || ')')::polygon
      FROM jsonb_array_elements(v) WITH ORDINALITY AS e(value, ordinality)
$fn$;

CREATE OR REPLACE FUNCTION practice.plan_vertices_bbox(v jsonb) RETURNS box
LANGUAGE sql IMMUTABLE PARALLEL SAFE SET search_path = pg_catalog, pg_temp
AS $fn$
    SELECT box(point(min((e.value ->> 0)::float8), min((e.value ->> 1)::float8)),
               point(max((e.value ->> 0)::float8), max((e.value ->> 1)::float8)))
      FROM jsonb_array_elements(v) AS e
$fn$;

-- Contorno de contacto: la figura achicada hacia el centro de su caja envolvente para que
-- dos locales que comparten pared (se tocan) no cuenten como solapados. Aproximación
-- deliberada y documentada: acota el margen a ~tol en el lado corto. tol = 0 → sin achicar.
CREATE OR REPLACE FUNCTION practice.plan_shrink_vertices(v jsonb, tol numeric) RETURNS jsonb
LANGUAGE sql IMMUTABLE PARALLEL SAFE SET search_path = pg_catalog, pg_temp
AS $fn$
    WITH p AS (
        SELECT (e.value ->> 0)::numeric AS x, (e.value ->> 1)::numeric AS y, e.ordinality AS o
          FROM jsonb_array_elements(v) WITH ORDINALITY AS e(value, ordinality)
    ), b AS (
        SELECT (min(x) + max(x)) / 2 AS mx, (min(y) + max(y)) / 2 AS my,
               CASE WHEN tol <= 0 THEN 1::numeric
                    ELSE greatest(0.5::numeric, 1 - tol / greatest(0.001::numeric, least(max(x) - min(x), max(y) - min(y)) / 2))
               END AS s
          FROM p
    )
    SELECT jsonb_agg(jsonb_build_array(round(b.mx + (p.x - b.mx) * b.s, 6), round(b.my + (p.y - b.my) * b.s, 6)) ORDER BY p.o)
      FROM p, b
$fn$;

-- ------------------------------------------------------------- 2. tablas
CREATE TABLE IF NOT EXISTS "practice"."floor_plans" (
    "id" uuid NOT NULL,
    "tenant_id" uuid NOT NULL,
    "practice_site_id" uuid NOT NULL,
    "anchor_space_id" uuid,
    "code" varchar NOT NULL,
    "name" varchar NOT NULL,
    "width_m" numeric(10,3) NOT NULL,
    "height_m" numeric(10,3) NOT NULL,
    "elevation_m" numeric(8,3),
    "north_bearing_deg" numeric(6,3) NOT NULL DEFAULT 0,
    "grid_size_m" numeric(6,3) NOT NULL DEFAULT 0.5,
    "snap_to_grid" boolean NOT NULL DEFAULT true,
    "contact_tolerance_m" numeric(5,3) NOT NULL DEFAULT 0.010,
    "background_file_id" uuid,
    "background_file_version_id" uuid,
    "background_scale_m_per_px" numeric(12,6),
    "background_offset_x_m" numeric(10,3) NOT NULL DEFAULT 0,
    "background_offset_y_m" numeric(10,3) NOT NULL DEFAULT 0,
    "background_rotation_deg" numeric(6,3) NOT NULL DEFAULT 0,
    "background_opacity" numeric(3,2) NOT NULL DEFAULT 0.50,
    "layout_version" integer NOT NULL DEFAULT 1,
    "layout_version_txid" bigint,
    "layout_changed_at" timestamptz,
    "valid_from" timestamptz NOT NULL DEFAULT now(),
    "valid_to" timestamptz,
    "created_at" timestamptz NOT NULL DEFAULT now(),
    "updated_at" timestamptz NOT NULL DEFAULT now(),
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_floor_plans" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "practice"."space_placements" (
    "id" uuid NOT NULL,
    "tenant_id" uuid NOT NULL,
    "floor_plan_id" uuid NOT NULL,
    "care_space_id" uuid NOT NULL,
    "sibling_group_id" uuid,
    "shape_kind" varchar(8) NOT NULL,
    "center_x_m" numeric(10,3),
    "center_y_m" numeric(10,3),
    "width_m" numeric(10,3),
    "depth_m" numeric(10,3),
    "rotation_deg" numeric(6,3),
    "vertices" jsonb NOT NULL,
    "area_calc_m2" numeric(12,3),
    "z_order" integer NOT NULL DEFAULT 0,
    "locked" boolean NOT NULL DEFAULT false,
    "created_at" timestamptz NOT NULL DEFAULT now(),
    "updated_at" timestamptz NOT NULL DEFAULT now(),
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_space_placements" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "practice"."plan_elements" (
    "id" uuid NOT NULL,
    "tenant_id" uuid NOT NULL,
    "floor_plan_id" uuid NOT NULL,
    "kind" varchar(12) NOT NULL,
    "vertices" jsonb,
    "thickness_m" numeric(6,3),
    "host_element_id" uuid,
    "offset_m" numeric(8,3),
    "width_m" numeric(6,3),
    "swing" varchar(8),
    "swing_side" varchar(5),
    "label" varchar(120),
    "vertical_link_code" varchar(40),
    "connects_space_a_id" uuid,
    "connects_space_b_id" uuid,
    "z_order" integer NOT NULL DEFAULT 0,
    "created_at" timestamptz NOT NULL DEFAULT now(),
    "updated_at" timestamptz NOT NULL DEFAULT now(),
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_plan_elements" PRIMARY KEY ("id")
);

-- Columnas que gen_ddl.py no sabe emitir (tipos geométricos nativos). Las llena SIEMPRE el
-- trigger de derivación; el CHECK las exige no nulas (no NOT NULL para poder agregarlas a
-- una tabla que el generador ya creó, aunque esté vacía).
ALTER TABLE "practice"."space_placements" ADD COLUMN IF NOT EXISTS "outline" polygon;
ALTER TABLE "practice"."space_placements" ADD COLUMN IF NOT EXISTS "overlap_outline" polygon;
ALTER TABLE "practice"."space_placements" ADD COLUMN IF NOT EXISTS "bbox" box;
ALTER TABLE "practice"."plan_elements" ADD COLUMN IF NOT EXISTS "bbox" box;

-- v4.2.70: en una base donde floor_plans ya existía (v4.2.68), la columna se agrega acá.
ALTER TABLE "practice"."floor_plans" ADD COLUMN IF NOT EXISTS "background_file_version_id" uuid;

-- DEFAULTs que gen_ddl.py no sabe expresar (sólo emite row_version, booleanos y texto): si el
-- generador creó las tablas primero, sin esto quedarían sin ellos. SET DEFAULT es idempotente.
DO $$
DECLARE
    r record;
BEGIN
    FOR r IN
        SELECT * FROM (VALUES
            ('practice.floor_plans', 'north_bearing_deg', '0'),
            ('practice.floor_plans', 'grid_size_m', '0.5'),
            ('practice.floor_plans', 'contact_tolerance_m', '0.010'),
            ('practice.floor_plans', 'background_offset_x_m', '0'),
            ('practice.floor_plans', 'background_offset_y_m', '0'),
            ('practice.floor_plans', 'background_rotation_deg', '0'),
            ('practice.floor_plans', 'background_opacity', '0.50'),
            ('practice.floor_plans', 'layout_version', '1'),
            ('practice.floor_plans', 'valid_from', 'now()'),
            ('practice.floor_plans', 'created_at', 'now()'),
            ('practice.floor_plans', 'updated_at', 'now()'),
            ('practice.space_placements', 'z_order', '0'),
            ('practice.space_placements', 'created_at', 'now()'),
            ('practice.space_placements', 'updated_at', 'now()'),
            ('practice.plan_elements', 'z_order', '0'),
            ('practice.plan_elements', 'created_at', 'now()'),
            ('practice.plan_elements', 'updated_at', 'now()')
        ) AS v(tabla, columna, valor)
    LOOP
        EXECUTE format('ALTER TABLE %s ALTER COLUMN %I SET DEFAULT %s', r.tabla, r.columna, r.valor);
    END LOOP;
END $$;
ALTER TABLE "practice"."floor_plans" ALTER COLUMN "snap_to_grid" SET DEFAULT true;
ALTER TABLE "practice"."space_placements" ALTER COLUMN "locked" SET DEFAULT false;

-- Historia: una por tabla, sin FK a la fila de origen (placements y elementos se pueden
-- borrar y su historia debe sobrevivir), con tenant_id y RLS como F1b.
CREATE TABLE IF NOT EXISTS "audit"."floor_plans_history" (
    "history_id" uuid NOT NULL,
    "floor_plan_id" uuid NOT NULL,
    "revision_no" integer NOT NULL,
    "operation_concept_id" uuid NOT NULL,
    "valid_from" timestamptz NOT NULL,
    "valid_to" timestamptz,
    "data_snapshot" jsonb NOT NULL,
    "changed_by_user_id" uuid,
    "change_reason_concept_id" uuid,
    "recorded_at" timestamptz NOT NULL,
    "tenant_id" uuid NOT NULL,
    CONSTRAINT "pk_floor_plans_history" PRIMARY KEY ("history_id")
);

CREATE TABLE IF NOT EXISTS "audit"."space_placements_history" (
    "history_id" uuid NOT NULL,
    "space_placement_id" uuid NOT NULL,
    "revision_no" integer NOT NULL,
    "operation_concept_id" uuid NOT NULL,
    "valid_from" timestamptz NOT NULL,
    "valid_to" timestamptz,
    "data_snapshot" jsonb NOT NULL,
    "changed_by_user_id" uuid,
    "change_reason_concept_id" uuid,
    "recorded_at" timestamptz NOT NULL,
    "tenant_id" uuid NOT NULL,
    CONSTRAINT "pk_space_placements_history" PRIMARY KEY ("history_id")
);

CREATE TABLE IF NOT EXISTS "audit"."plan_elements_history" (
    "history_id" uuid NOT NULL,
    "plan_element_id" uuid NOT NULL,
    "revision_no" integer NOT NULL,
    "operation_concept_id" uuid NOT NULL,
    "valid_from" timestamptz NOT NULL,
    "valid_to" timestamptz,
    "data_snapshot" jsonb NOT NULL,
    "changed_by_user_id" uuid,
    "change_reason_concept_id" uuid,
    "recorded_at" timestamptz NOT NULL,
    "tenant_id" uuid NOT NULL,
    CONSTRAINT "pk_plan_elements_history" PRIMARY KEY ("history_id")
);

-- ------------------------------------------------------------- 3. índices
CREATE UNIQUE INDEX IF NOT EXISTS "ux_floor_plans_tenant_id_id" ON "practice"."floor_plans" ("tenant_id", "id");
CREATE UNIQUE INDEX IF NOT EXISTS "ux_floor_plans_site_code" ON "practice"."floor_plans" ("practice_site_id", "code");
-- Un lienzo VIGENTE por ancla; y un solo lienzo de campus (sin ancla) vigente por sede.
CREATE UNIQUE INDEX IF NOT EXISTS "ux_floor_plans_anchor_current" ON "practice"."floor_plans" ("anchor_space_id") WHERE anchor_space_id IS NOT NULL AND valid_to IS NULL;
CREATE UNIQUE INDEX IF NOT EXISTS "ux_floor_plans_site_campus_current" ON "practice"."floor_plans" ("practice_site_id") WHERE anchor_space_id IS NULL AND valid_to IS NULL;
CREATE INDEX IF NOT EXISTS "ix_floor_plans_tenant_id" ON "practice"."floor_plans" ("tenant_id");
CREATE INDEX IF NOT EXISTS "ix_floor_plans_practice_site_id" ON "practice"."floor_plans" ("practice_site_id");
CREATE INDEX IF NOT EXISTS "ix_floor_plans_anchor_space_id" ON "practice"."floor_plans" ("anchor_space_id");
CREATE INDEX IF NOT EXISTS "ix_floor_plans_background_file_id" ON "practice"."floor_plans" ("background_file_id");
CREATE INDEX IF NOT EXISTS "ix_floor_plans_background_file_version_id" ON "practice"."floor_plans" ("background_file_version_id");
CREATE INDEX IF NOT EXISTS "ix_floor_plans_created_by_user_id" ON "practice"."floor_plans" ("created_by_user_id");
CREATE INDEX IF NOT EXISTS "ix_floor_plans_updated_by_user_id" ON "practice"."floor_plans" ("updated_by_user_id");

CREATE UNIQUE INDEX IF NOT EXISTS "ux_space_placements_tenant_id_id" ON "practice"."space_placements" ("tenant_id", "id");
CREATE UNIQUE INDEX IF NOT EXISTS "ux_space_placements_care_space" ON "practice"."space_placements" ("care_space_id");
CREATE INDEX IF NOT EXISTS "ix_space_placements_tenant_id" ON "practice"."space_placements" ("tenant_id");
CREATE INDEX IF NOT EXISTS "ix_space_placements_floor_plan_id" ON "practice"."space_placements" ("floor_plan_id");
CREATE INDEX IF NOT EXISTS "ix_space_placements_sibling_group_id" ON "practice"."space_placements" ("sibling_group_id");
CREATE INDEX IF NOT EXISTS "ix_space_placements_created_by_user_id" ON "practice"."space_placements" ("created_by_user_id");
CREATE INDEX IF NOT EXISTS "ix_space_placements_updated_by_user_id" ON "practice"."space_placements" ("updated_by_user_id");
-- Carga por ventana (viewport) y paginada: caja envolvente dentro del lienzo.
CREATE INDEX IF NOT EXISTS "gist_space_placements_plan_bbox" ON "practice"."space_placements" USING gist ("floor_plan_id", "bbox");

CREATE UNIQUE INDEX IF NOT EXISTS "ux_plan_elements_tenant_id_id" ON "practice"."plan_elements" ("tenant_id", "id");
CREATE INDEX IF NOT EXISTS "ix_plan_elements_tenant_id" ON "practice"."plan_elements" ("tenant_id");
CREATE INDEX IF NOT EXISTS "ix_plan_elements_floor_plan_id" ON "practice"."plan_elements" ("floor_plan_id");
CREATE INDEX IF NOT EXISTS "ix_plan_elements_host_element_id" ON "practice"."plan_elements" ("host_element_id");
CREATE INDEX IF NOT EXISTS "ix_plan_elements_connects_space_a_id" ON "practice"."plan_elements" ("connects_space_a_id");
CREATE INDEX IF NOT EXISTS "ix_plan_elements_connects_space_b_id" ON "practice"."plan_elements" ("connects_space_b_id");
CREATE INDEX IF NOT EXISTS "ix_plan_elements_created_by_user_id" ON "practice"."plan_elements" ("created_by_user_id");
CREATE INDEX IF NOT EXISTS "ix_plan_elements_updated_by_user_id" ON "practice"."plan_elements" ("updated_by_user_id");
CREATE INDEX IF NOT EXISTS "ix_plan_elements_vertical_link" ON "practice"."plan_elements" ("vertical_link_code") WHERE vertical_link_code IS NOT NULL;
CREATE INDEX IF NOT EXISTS "gist_plan_elements_plan_bbox" ON "practice"."plan_elements" USING gist ("floor_plan_id", "bbox");

CREATE INDEX IF NOT EXISTS "ix_floor_plans_history_floor_plan_id" ON "audit"."floor_plans_history" ("floor_plan_id");
CREATE INDEX IF NOT EXISTS "ix_floor_plans_history_operation_concept_id" ON "audit"."floor_plans_history" ("operation_concept_id");
CREATE INDEX IF NOT EXISTS "ix_floor_plans_history_changed_by_user_id" ON "audit"."floor_plans_history" ("changed_by_user_id");
CREATE INDEX IF NOT EXISTS "ix_floor_plans_history_change_reason_concept_id" ON "audit"."floor_plans_history" ("change_reason_concept_id");
CREATE INDEX IF NOT EXISTS "brin_floor_plans_history_recorded_at" ON "audit"."floor_plans_history" USING brin ("recorded_at") WITH (pages_per_range=128);
CREATE INDEX IF NOT EXISTS "ix_floor_plans_history_tenant_id" ON "audit"."floor_plans_history" ("tenant_id");

CREATE INDEX IF NOT EXISTS "ix_space_placements_history_space_placement_id" ON "audit"."space_placements_history" ("space_placement_id");
CREATE INDEX IF NOT EXISTS "ix_space_placements_history_operation_concept_id" ON "audit"."space_placements_history" ("operation_concept_id");
CREATE INDEX IF NOT EXISTS "ix_space_placements_history_changed_by_user_id" ON "audit"."space_placements_history" ("changed_by_user_id");
CREATE INDEX IF NOT EXISTS "ix_space_placements_history_change_reason_concept_id" ON "audit"."space_placements_history" ("change_reason_concept_id");
CREATE INDEX IF NOT EXISTS "brin_space_placements_history_recorded_at" ON "audit"."space_placements_history" USING brin ("recorded_at") WITH (pages_per_range=128);
CREATE INDEX IF NOT EXISTS "ix_space_placements_history_tenant_id" ON "audit"."space_placements_history" ("tenant_id");

CREATE INDEX IF NOT EXISTS "ix_plan_elements_history_plan_element_id" ON "audit"."plan_elements_history" ("plan_element_id");
CREATE INDEX IF NOT EXISTS "ix_plan_elements_history_operation_concept_id" ON "audit"."plan_elements_history" ("operation_concept_id");
CREATE INDEX IF NOT EXISTS "ix_plan_elements_history_changed_by_user_id" ON "audit"."plan_elements_history" ("changed_by_user_id");
CREATE INDEX IF NOT EXISTS "ix_plan_elements_history_change_reason_concept_id" ON "audit"."plan_elements_history" ("change_reason_concept_id");
CREATE INDEX IF NOT EXISTS "brin_plan_elements_history_recorded_at" ON "audit"."plan_elements_history" USING brin ("recorded_at") WITH (pages_per_range=128);
CREATE INDEX IF NOT EXISTS "ix_plan_elements_history_tenant_id" ON "audit"."plan_elements_history" ("tenant_id");

-- ------------------------------------------------------------- 4. FK simples y compuestas
-- La imagen de fondo es un archivo de common.files. Una FK simple se verifica SIN RLS: un lienzo
-- podría apuntar al archivo de OTRO tenant y exponerlo en el visor (IDOR). common.files ya trae
-- tenant_id NOT NULL; sólo le falta el UNIQUE (tenant_id, id) que exige la FK compuesta. Es un
-- índice único sobre una columna que ya es única (id): no puede fallar ni cambia datos.
CREATE UNIQUE INDEX IF NOT EXISTS "ux_files_tenant_id_id" ON "common"."files" ("tenant_id", "id");
-- v4.2.70: destino de la FK compuesta hacia la versión (la versión es DE ese archivo). Único
-- sobre una columna que ya es única (id): no puede fallar ni cambia datos.
CREATE UNIQUE INDEX IF NOT EXISTS "ux_file_versions_file_id_id" ON "common"."file_versions" ("file_id", "id");

-- Precondición: ningún lienzo existente puede apuntar a un archivo de otro tenant (o inexistente).
-- Un patch no decide cuál de los dos tenants es el correcto: lista y aborta.
DO $$
DECLARE
    n_cruce bigint;
BEGIN
    SELECT count(*) INTO n_cruce
      FROM practice.floor_plans fp
     WHERE fp.background_file_id IS NOT NULL
       AND NOT EXISTS (SELECT 1 FROM common.files f WHERE f.id = fp.background_file_id AND f.tenant_id = fp.tenant_id);
    IF n_cruce > 0 THEN
        RAISE EXCEPTION 'F1c: % lienzo(s) con background_file_id de otro tenant o inexistente; corregirlos a mano y volver a aplicar.', n_cruce
            USING ERRCODE = 'foreign_key_violation';
    END IF;
END $$;

-- v4.2.70, precondición: la versión fijada debe ser de ESE archivo (y no haber versión sin
-- archivo). La columna es nueva, así que esto solo puede fallar al reaplicar sobre datos que
-- alguien escribió con las restricciones apagadas; no se decide cuál de los dos está mal.
DO $$
DECLARE
    n_mal bigint;
    ejemplo text;
BEGIN
    SELECT count(*), min(fp.id::text) INTO n_mal, ejemplo
      FROM practice.floor_plans fp
     WHERE fp.background_file_version_id IS NOT NULL
       AND (fp.background_file_id IS NULL
            OR NOT EXISTS (SELECT 1 FROM common.file_versions v
                            WHERE v.id = fp.background_file_version_id AND v.file_id = fp.background_file_id));
    IF n_mal > 0 THEN
        RAISE EXCEPTION 'F1c: % lienzo(s) con background_file_version_id sin archivo, inexistente o de otro archivo (p. ej. %); corregirlos a mano y volver a aplicar.', n_mal, ejemplo
            USING ERRCODE = 'foreign_key_violation';
    END IF;
END $$;

-- Compuestas (tenant_id, x_id) → padre (tenant_id, id): el padre es del MISMO tenant.
-- MATCH SIMPLE: con x_id NULL no se exige nada (ancla opcional, host opcional…).
DO $$
DECLARE
    r record;
BEGIN
    FOR r IN
        SELECT * FROM (VALUES
            ('practice.floor_plans',      'fk_floor_plans_tenant_site',        'practice_site_id',    'practice.practice_sites'),
            ('practice.floor_plans',      'fk_floor_plans_tenant_anchor',      'anchor_space_id',     'practice.care_spaces'),
            ('practice.floor_plans',      'fk_floor_plans_tenant_background',  'background_file_id',  'common.files'),
            ('practice.space_placements', 'fk_space_placements_tenant_plan',   'floor_plan_id',       'practice.floor_plans'),
            ('practice.space_placements', 'fk_space_placements_tenant_space',  'care_space_id',       'practice.care_spaces'),
            ('practice.plan_elements',    'fk_plan_elements_tenant_plan',      'floor_plan_id',       'practice.floor_plans'),
            ('practice.plan_elements',    'fk_plan_elements_tenant_host',      'host_element_id',     'practice.plan_elements'),
            ('practice.plan_elements',    'fk_plan_elements_tenant_space_a',   'connects_space_a_id', 'practice.care_spaces'),
            ('practice.plan_elements',    'fk_plan_elements_tenant_space_b',   'connects_space_b_id', 'practice.care_spaces')
        ) AS v(hijo, nombre, columna, padre)
    LOOP
        BEGIN
            EXECUTE format('ALTER TABLE %s ADD CONSTRAINT %I FOREIGN KEY ("tenant_id", %I) REFERENCES %s ("tenant_id", "id")',
                           r.hijo, r.nombre, r.columna, r.padre);
        EXCEPTION WHEN duplicate_object THEN NULL;
        END;
    END LOOP;
END $$;

-- v4.2.70: la versión es DE ese archivo. MATCH SIMPLE: con la versión NULL (sigue la vigente)
-- no se exige nada; la versión sin archivo la rechaza ck_floor_plans_background_version.
DO $$ BEGIN
    ALTER TABLE "practice"."floor_plans" ADD CONSTRAINT "fk_floor_plans_background_version"
        FOREIGN KEY ("background_file_id", "background_file_version_id")
        REFERENCES "common"."file_versions" ("file_id", "id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- Simples (las que genera gen_ddl.py).
DO $$
DECLARE
    r record;
BEGIN
    FOR r IN
        SELECT * FROM (VALUES
            ('practice.floor_plans',      'fk_floor_plans_tenant_id',                       'tenant_id',          'directory.tenants'),
            ('practice.floor_plans',      'fk_floor_plans_practice_site_id',                'practice_site_id',   'practice.practice_sites'),
            ('practice.floor_plans',      'fk_floor_plans_anchor_space_id',                 'anchor_space_id',    'practice.care_spaces'),
            ('practice.floor_plans',      'fk_floor_plans_background_file_id',              'background_file_id', 'common.files'),
            ('practice.floor_plans',      'fk_floor_plans_created_by_user_id',              'created_by_user_id', 'iam.users'),
            ('practice.floor_plans',      'fk_floor_plans_updated_by_user_id',              'updated_by_user_id', 'iam.users'),
            ('practice.space_placements', 'fk_space_placements_tenant_id',                  'tenant_id',          'directory.tenants'),
            ('practice.space_placements', 'fk_space_placements_floor_plan_id',              'floor_plan_id',      'practice.floor_plans'),
            ('practice.space_placements', 'fk_space_placements_care_space_id',              'care_space_id',      'practice.care_spaces'),
            ('practice.space_placements', 'fk_space_placements_created_by_user_id',         'created_by_user_id', 'iam.users'),
            ('practice.space_placements', 'fk_space_placements_updated_by_user_id',         'updated_by_user_id', 'iam.users'),
            ('practice.plan_elements',    'fk_plan_elements_tenant_id',                     'tenant_id',          'directory.tenants'),
            ('practice.plan_elements',    'fk_plan_elements_floor_plan_id',                 'floor_plan_id',      'practice.floor_plans'),
            ('practice.plan_elements',    'fk_plan_elements_host_element_id',               'host_element_id',    'practice.plan_elements'),
            ('practice.plan_elements',    'fk_plan_elements_connects_space_a_id',           'connects_space_a_id','practice.care_spaces'),
            ('practice.plan_elements',    'fk_plan_elements_connects_space_b_id',           'connects_space_b_id','practice.care_spaces'),
            ('practice.plan_elements',    'fk_plan_elements_created_by_user_id',            'created_by_user_id', 'iam.users'),
            ('practice.plan_elements',    'fk_plan_elements_updated_by_user_id',            'updated_by_user_id', 'iam.users'),
            ('audit.floor_plans_history',      'fk_floor_plans_history_tenant_id',          'tenant_id',          'directory.tenants'),
            ('audit.floor_plans_history',      'fk_floor_plans_history_operation_concept_id','operation_concept_id','terminology.catalog_concepts'),
            ('audit.floor_plans_history',      'fk_floor_plans_history_changed_by_user_id', 'changed_by_user_id', 'iam.users'),
            ('audit.floor_plans_history',      'fk_floor_plans_history_change_reason_concept_id','change_reason_concept_id','terminology.catalog_concepts'),
            ('audit.space_placements_history', 'fk_space_placements_history_tenant_id',     'tenant_id',          'directory.tenants'),
            ('audit.space_placements_history', 'fk_space_placements_history_operation_concept_id','operation_concept_id','terminology.catalog_concepts'),
            ('audit.space_placements_history', 'fk_space_placements_history_changed_by_user_id','changed_by_user_id','iam.users'),
            ('audit.space_placements_history', 'fk_space_placements_history_change_reason_concept_id','change_reason_concept_id','terminology.catalog_concepts'),
            ('audit.plan_elements_history',    'fk_plan_elements_history_tenant_id',        'tenant_id',          'directory.tenants'),
            ('audit.plan_elements_history',    'fk_plan_elements_history_operation_concept_id','operation_concept_id','terminology.catalog_concepts'),
            ('audit.plan_elements_history',    'fk_plan_elements_history_changed_by_user_id','changed_by_user_id','iam.users'),
            ('audit.plan_elements_history',    'fk_plan_elements_history_change_reason_concept_id','change_reason_concept_id','terminology.catalog_concepts')
        ) AS v(hijo, nombre, columna, padre)
    LOOP
        BEGIN
            EXECUTE format('ALTER TABLE %s ADD CONSTRAINT %I FOREIGN KEY (%I) REFERENCES %s ("id")',
                           r.hijo, r.nombre, r.columna, r.padre);
        EXCEPTION WHEN duplicate_object THEN NULL;
        END;
    END LOOP;
END $$;

-- ------------------------------------------------------------- 5. CHECK de geometría válida
DO $$
DECLARE
    r record;
BEGIN
    FOR r IN
        SELECT * FROM (VALUES
            -- lienzo
            ('practice.floor_plans', 'ck_floor_plans_size',
             'width_m BETWEEN 1 AND 5000 AND height_m BETWEEN 1 AND 5000'),
            ('practice.floor_plans', 'ck_floor_plans_north',
             'north_bearing_deg >= 0 AND north_bearing_deg < 360'),
            ('practice.floor_plans', 'ck_floor_plans_grid',
             'grid_size_m BETWEEN 0.01 AND 10'),
            ('practice.floor_plans', 'ck_floor_plans_contact_tolerance',
             'contact_tolerance_m >= 0 AND contact_tolerance_m <= 0.100'),
            ('practice.floor_plans', 'ck_floor_plans_background',
             'background_file_id IS NULL OR (background_scale_m_per_px IS NOT NULL AND background_scale_m_per_px > 0)'),
            ('practice.floor_plans', 'ck_floor_plans_background_version',
             'background_file_version_id IS NULL OR background_file_id IS NOT NULL'),
            ('practice.floor_plans', 'ck_floor_plans_background_opacity',
             'background_opacity BETWEEN 0 AND 1 AND background_rotation_deg >= 0 AND background_rotation_deg < 360'),
            ('practice.floor_plans', 'ck_floor_plans_validity',
             'valid_to IS NULL OR valid_to > valid_from'),
            ('practice.floor_plans', 'ck_floor_plans_code',
             $c$btrim(code) <> '' AND btrim(name) <> ''$c$),
            -- ubicación de un espacio
            ('practice.space_placements', 'ck_space_placements_shape_kind',
             $c$shape_kind IN ('RECT', 'POLYGON')$c$),
            ('practice.space_placements', 'ck_space_placements_shape_params',
             $c$(shape_kind = 'RECT' AND center_x_m IS NOT NULL AND center_y_m IS NOT NULL AND width_m IS NOT NULL
                 AND depth_m IS NOT NULL AND rotation_deg IS NOT NULL)
                OR (shape_kind = 'POLYGON' AND center_x_m IS NULL AND center_y_m IS NULL AND width_m IS NULL
                 AND depth_m IS NULL AND rotation_deg IS NULL)$c$),
            ('practice.space_placements', 'ck_space_placements_rect_size',
             'width_m IS NULL OR (width_m BETWEEN 0.05 AND 1000 AND depth_m BETWEEN 0.05 AND 1000)'),
            ('practice.space_placements', 'ck_space_placements_rotation',
             'rotation_deg IS NULL OR (rotation_deg >= 0 AND rotation_deg < 360)'),
            ('practice.space_placements', 'ck_space_placements_vertices_simple',
             'practice.plan_polygon_is_simple(vertices)'),
            ('practice.space_placements', 'ck_space_placements_derived',
             'outline IS NOT NULL AND overlap_outline IS NOT NULL AND bbox IS NOT NULL AND area_calc_m2 IS NOT NULL AND sibling_group_id IS NOT NULL'),
            ('practice.space_placements', 'ck_space_placements_z_order',
             'z_order BETWEEN -1000 AND 1000'),
            -- elementos
            ('practice.plan_elements', 'ck_plan_elements_kind',
             $c$kind IN ('WALL', 'DOOR', 'WINDOW', 'OPENING', 'STAIRS', 'ELEVATOR', 'CIRCULATION', 'COLUMN', 'ANNOTATION')$c$),
            ('practice.plan_elements', 'ck_plan_elements_geometry_by_kind',
             $c$(kind = 'WALL' AND practice.plan_vertices_ok(vertices, 2, 64) AND thickness_m IS NOT NULL
                 AND host_element_id IS NULL AND offset_m IS NULL AND width_m IS NULL)
                OR (kind IN ('DOOR', 'WINDOW', 'OPENING') AND vertices IS NULL AND host_element_id IS NOT NULL
                 AND offset_m IS NOT NULL AND width_m IS NOT NULL AND thickness_m IS NULL)
                OR (kind IN ('STAIRS', 'ELEVATOR', 'CIRCULATION', 'COLUMN') AND practice.plan_polygon_is_simple(vertices)
                 AND host_element_id IS NULL AND offset_m IS NULL AND width_m IS NULL AND thickness_m IS NULL)
                OR (kind = 'ANNOTATION' AND practice.plan_vertices_ok(vertices, 1, 1) AND label IS NOT NULL
                 AND host_element_id IS NULL AND offset_m IS NULL AND width_m IS NULL AND thickness_m IS NULL)$c$),
            ('practice.plan_elements', 'ck_plan_elements_dimensions',
             '(thickness_m IS NULL OR thickness_m BETWEEN 0.02 AND 2) AND (offset_m IS NULL OR offset_m >= 0) AND (width_m IS NULL OR width_m BETWEEN 0.3 AND 20)'),
            ('practice.plan_elements', 'ck_plan_elements_swing',
             $c$(swing IS NULL OR (kind = 'DOOR' AND swing IN ('LEFT', 'RIGHT', 'DOUBLE', 'SLIDING', 'NONE')))
                AND (swing_side IS NULL OR (kind = 'DOOR' AND swing_side IN ('A', 'B')))$c$),
            ('practice.plan_elements', 'ck_plan_elements_derived',
             $c$(kind IN ('DOOR', 'WINDOW', 'OPENING') AND bbox IS NULL) OR (kind NOT IN ('DOOR', 'WINDOW', 'OPENING') AND bbox IS NOT NULL)$c$),
            ('practice.plan_elements', 'ck_plan_elements_vertical_link',
             $c$vertical_link_code IS NULL OR kind IN ('STAIRS', 'ELEVATOR')$c$),
            ('practice.plan_elements', 'ck_plan_elements_connects',
             $c$(connects_space_a_id IS NULL AND connects_space_b_id IS NULL) OR kind IN ('DOOR', 'OPENING')$c$),
            ('practice.plan_elements', 'ck_plan_elements_z_order',
             'z_order BETWEEN -1000 AND 1000')
        ) AS v(tabla, nombre, expr)
    LOOP
        BEGIN
            EXECUTE format('ALTER TABLE %s ADD CONSTRAINT %I CHECK (%s)', r.tabla, r.nombre, r.expr);
        EXCEPTION WHEN duplicate_object THEN NULL;
        END;
    END LOOP;
END $$;

-- ------------------------------------------------------------- 6. EXCLUDE: hermanos sin solape
-- Precondición: con filas previas y sin la restricción, ningún par de hermanos solapados
-- (un patch no decide cuál de los dos locales está mal).
DO $$
DECLARE
    n_solapes bigint;
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'ex_space_placements_no_overlap') THEN
        SELECT count(*) INTO n_solapes
          FROM practice.space_placements a
          JOIN practice.space_placements b
            ON a.floor_plan_id = b.floor_plan_id AND a.sibling_group_id = b.sibling_group_id AND a.id < b.id
           AND a.overlap_outline && b.overlap_outline;
        IF n_solapes > 0 THEN
            RAISE EXCEPTION 'F1c: % par(es) de espacios hermanos solapados en el mismo lienzo; corregir la geometría a mano y volver a aplicar.', n_solapes
                USING ERRCODE = 'exclusion_violation';
        END IF;
    END IF;
END $$;

-- DEFERRABLE INITIALLY IMMEDIATE: un PATCH de layout que intercambia dos locales pone
-- `SET CONSTRAINTS ex_space_placements_no_overlap DEFERRED` dentro de su transacción
-- (mismo criterio que el intercambio A17 de F3).
DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'ex_space_placements_no_overlap') THEN
        ALTER TABLE "practice"."space_placements"
            ADD CONSTRAINT "ex_space_placements_no_overlap"
            EXCLUDE USING gist ("floor_plan_id" WITH =, "sibling_group_id" WITH =, "overlap_outline" WITH &&)
            DEFERRABLE INITIALLY IMMEDIATE;
    END IF;
END $$;

-- ------------------------------------------------------------- 7. triggers
-- 7a. Derivación y reglas locales de una ubicación (BEFORE INSERT/UPDATE).
CREATE OR REPLACE FUNCTION practice.space_placements_derive()
RETURNS trigger
LANGUAGE plpgsql
SET search_path = pg_catalog, pg_temp
AS $fn$
DECLARE
    v_plan  record;
    v_space record;
    v_bb    box;
    v_tol   numeric;
BEGIN
    SELECT fp.practice_site_id, fp.anchor_space_id, fp.width_m, fp.height_m, fp.contact_tolerance_m, fp.valid_to
      INTO v_plan
      FROM practice.floor_plans fp
     WHERE fp.id = NEW.floor_plan_id AND fp.tenant_id = NEW.tenant_id;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'PLAN_NOT_FOUND: el lienzo no existe en el tenant'
            USING ERRCODE = 'foreign_key_violation', CONSTRAINT = 'fk_space_placements_tenant_plan';
    END IF;

    SELECT cs.practice_site_id, cs.parent_space_id
      INTO v_space
      FROM practice.care_spaces cs
     WHERE cs.id = NEW.care_space_id AND cs.tenant_id = NEW.tenant_id;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'PLAN_SPACE_NOT_FOUND: el espacio no existe en el tenant'
            USING ERRCODE = 'foreign_key_violation', CONSTRAINT = 'fk_space_placements_tenant_space';
    END IF;

    IF v_space.practice_site_id <> v_plan.practice_site_id THEN
        RAISE EXCEPTION 'PLAN_SPACE_OTHER_SITE: el espacio es de otro establecimiento que el lienzo'
            USING ERRCODE = 'check_violation', CONSTRAINT = 'trg_space_placements_derive';
    END IF;

    IF TG_OP = 'INSERT' AND v_plan.valid_to IS NOT NULL AND v_plan.valid_to <= now() THEN
        RAISE EXCEPTION 'PLAN_RETIRED: el lienzo está clausurado, no admite espacios nuevos'
            USING ERRCODE = 'check_violation', CONSTRAINT = 'trg_space_placements_derive';
    END IF;

    -- Geometría canónica: el servidor es la autoridad de los datos derivados.
    IF NEW.shape_kind = 'RECT' AND NEW.center_x_m IS NOT NULL AND NEW.center_y_m IS NOT NULL
       AND NEW.width_m IS NOT NULL AND NEW.depth_m IS NOT NULL AND NEW.rotation_deg IS NOT NULL THEN
        NEW.vertices := practice.plan_rect_vertices(NEW.center_x_m, NEW.center_y_m, NEW.width_m, NEW.depth_m, NEW.rotation_deg);
    END IF;
    IF NOT practice.plan_polygon_is_simple(NEW.vertices) THEN
        RAISE EXCEPTION 'PLAN_GEOMETRY_INVALID: la figura no es un polígono simple de 3 a 64 vértices con área > 0'
            USING ERRCODE = 'check_violation', CONSTRAINT = 'ck_space_placements_vertices_simple';
    END IF;

    v_tol := v_plan.contact_tolerance_m;
    NEW.outline := practice.plan_vertices_to_polygon(NEW.vertices);
    NEW.overlap_outline := practice.plan_vertices_to_polygon(practice.plan_shrink_vertices(NEW.vertices, v_tol));
    NEW.bbox := practice.plan_vertices_bbox(NEW.vertices);
    NEW.area_calc_m2 := round(practice.plan_polygon_area(NEW.vertices), 3);
    NEW.sibling_group_id := coalesce(v_space.parent_space_id, v_space.practice_site_id);

    v_bb := NEW.bbox;
    IF (v_bb[1])[0] < -v_tol OR (v_bb[1])[1] < -v_tol
       OR (v_bb[0])[0] > v_plan.width_m + v_tol OR (v_bb[0])[1] > v_plan.height_m + v_tol THEN
        RAISE EXCEPTION 'PLAN_OUT_OF_BOUNDS: la figura sale del lienzo (% x % m)', v_plan.width_m, v_plan.height_m
            USING ERRCODE = 'check_violation', CONSTRAINT = 'trg_space_placements_derive';
    END IF;
    RETURN NEW;
END $fn$;

DROP TRIGGER IF EXISTS "trg_space_placements_derive" ON "practice"."space_placements";
CREATE TRIGGER "trg_space_placements_derive"
    BEFORE INSERT OR UPDATE ON "practice"."space_placements"
    FOR EACH ROW EXECUTE FUNCTION practice.space_placements_derive();

-- 7b. Árbol en el plano (DIFERIDO al COMMIT): el padre ya está ubicado en el MISMO lienzo
-- (o es su ancla; sin ancla sólo entran las raíces) y el hijo cae DENTRO del padre. Se
-- comprueba por la fila y por sus hijos, para que mover un padre también revise a los suyos.
-- La API hace `SET CONSTRAINTS ALL IMMEDIATE` antes de responder para devolver el error por
-- elemento dentro de su transacción.
CREATE OR REPLACE FUNCTION practice.space_placements_assert_tree()
RETURNS trigger
LANGUAGE plpgsql
SET search_path = pg_catalog, pg_temp
AS $fn$
DECLARE
    v_row    record;
    v_plan   record;
    v_parent uuid;
    v_pout   polygon;
    c        record;
BEGIN
    SELECT sp.* INTO v_row FROM practice.space_placements sp WHERE sp.id = NEW.id;
    IF NOT FOUND THEN
        RETURN NULL;  -- la fila se borró antes del COMMIT
    END IF;
    SELECT fp.anchor_space_id INTO v_plan FROM practice.floor_plans fp WHERE fp.id = v_row.floor_plan_id;
    SELECT cs.parent_space_id INTO v_parent FROM practice.care_spaces cs WHERE cs.id = v_row.care_space_id;

    IF v_parent IS NULL THEN
        IF v_plan.anchor_space_id IS NOT NULL THEN
            RAISE EXCEPTION 'PLAN_PARENT_NOT_PLACED: el espacio % no tiene padre y el lienzo está anclado a un espacio', v_row.care_space_id
                USING ERRCODE = 'check_violation', CONSTRAINT = 'ck_plan_parent_placed';
        END IF;
    ELSIF v_parent IS DISTINCT FROM v_plan.anchor_space_id THEN
        SELECT p.outline INTO v_pout
          FROM practice.space_placements p
         WHERE p.care_space_id = v_parent AND p.floor_plan_id = v_row.floor_plan_id;
        IF NOT FOUND THEN
            RAISE EXCEPTION 'PLAN_PARENT_NOT_PLACED: el padre % del espacio % no está ubicado en este lienzo', v_parent, v_row.care_space_id
                USING ERRCODE = 'check_violation', CONSTRAINT = 'ck_plan_parent_placed';
        END IF;
        IF NOT (v_pout @> v_row.overlap_outline) THEN
            RAISE EXCEPTION 'PLAN_CHILD_OUTSIDE_PARENT: el espacio % no cabe dentro de su padre %', v_row.care_space_id, v_parent
                USING ERRCODE = 'check_violation', CONSTRAINT = 'ck_plan_child_inside_parent';
        END IF;
    END IF;

    FOR c IN
        SELECT cp.care_space_id
          FROM practice.space_placements cp
          JOIN practice.care_spaces cs ON cs.id = cp.care_space_id
         WHERE cp.floor_plan_id = v_row.floor_plan_id
           AND cs.parent_space_id = v_row.care_space_id
           AND NOT (v_row.outline @> cp.overlap_outline)
    LOOP
        RAISE EXCEPTION 'PLAN_CHILD_OUTSIDE_PARENT: el espacio % no cabe dentro de su padre %', c.care_space_id, v_row.care_space_id
            USING ERRCODE = 'check_violation', CONSTRAINT = 'ck_plan_child_inside_parent';
    END LOOP;
    RETURN NULL;
END $fn$;

DROP TRIGGER IF EXISTS "trg_space_placements_assert_tree" ON "practice"."space_placements";
CREATE CONSTRAINT TRIGGER "trg_space_placements_assert_tree"
    AFTER INSERT OR UPDATE ON "practice"."space_placements"
    DEFERRABLE INITIALLY DEFERRED
    FOR EACH ROW EXECUTE FUNCTION practice.space_placements_assert_tree();

-- 7c. Quitar un padre del plano no deja hijos huérfanos (DIFERIDO).
CREATE OR REPLACE FUNCTION practice.space_placements_assert_no_orphans()
RETURNS trigger
LANGUAGE plpgsql
SET search_path = pg_catalog, pg_temp
AS $fn$
DECLARE
    c record;
BEGIN
    IF EXISTS (SELECT 1 FROM practice.space_placements p WHERE p.care_space_id = OLD.care_space_id) THEN
        RETURN NULL;
    END IF;
    FOR c IN
        SELECT cp.care_space_id
          FROM practice.space_placements cp
          JOIN practice.care_spaces cs ON cs.id = cp.care_space_id
         WHERE cp.floor_plan_id = OLD.floor_plan_id AND cs.parent_space_id = OLD.care_space_id
         LIMIT 1
    LOOP
        RAISE EXCEPTION 'PLAN_HAS_PLACED_CHILDREN: el espacio % tiene hijos ubicados en el lienzo; quitarlos primero', OLD.care_space_id
            USING ERRCODE = 'restrict_violation', CONSTRAINT = 'ck_plan_parent_placed';
    END LOOP;
    RETURN NULL;
END $fn$;

DROP TRIGGER IF EXISTS "trg_space_placements_assert_no_orphans" ON "practice"."space_placements";
CREATE CONSTRAINT TRIGGER "trg_space_placements_assert_no_orphans"
    AFTER DELETE ON "practice"."space_placements"
    DEFERRABLE INITIALLY DEFERRED
    FOR EACH ROW EXECUTE FUNCTION practice.space_placements_assert_no_orphans();

-- 7d. Mover un espacio en el ÁRBOL revalida su dibujo y el de sus descendientes: el trigger
-- de derivación recalcula `sibling_group_id` y el diferido revisa padre y contención. Si el
-- dibujo deja de ser válido, el `move` del árbol falla (la API lo devuelve como
-- 409 SPACE_MOVE_BREAKS_PLAN y pide sacar el dibujo antes de mover).
CREATE OR REPLACE FUNCTION practice.care_spaces_revalidate_placements()
RETURNS trigger
LANGUAGE plpgsql
SET search_path = pg_catalog, pg_temp
AS $fn$
BEGIN
    UPDATE practice.space_placements sp
       SET sibling_group_id = sp.sibling_group_id
     WHERE sp.care_space_id IN (
            WITH RECURSIVE d(id) AS (
                SELECT NEW.id
                UNION ALL
                SELECT c.id FROM practice.care_spaces c JOIN d ON c.parent_space_id = d.id
            )
            SELECT id FROM d);
    RETURN NULL;
END $fn$;

DROP TRIGGER IF EXISTS "trg_care_spaces_revalidate_placements" ON "practice"."care_spaces";
CREATE TRIGGER "trg_care_spaces_revalidate_placements"
    AFTER UPDATE OF parent_space_id ON "practice"."care_spaces"
    FOR EACH ROW
    WHEN (OLD.parent_space_id IS DISTINCT FROM NEW.parent_space_id)
    EXECUTE FUNCTION practice.care_spaces_revalidate_placements();

-- 7e. Elementos: derivación, anfitrión (muro) y límites.
CREATE OR REPLACE FUNCTION practice.plan_elements_derive()
RETURNS trigger
LANGUAGE plpgsql
SET search_path = pg_catalog, pg_temp
AS $fn$
DECLARE
    v_plan record;
    v_host record;
    v_bb   box;
    v_sp   uuid;
BEGIN
    SELECT fp.practice_site_id, fp.width_m, fp.height_m, fp.contact_tolerance_m, fp.valid_to
      INTO v_plan
      FROM practice.floor_plans fp
     WHERE fp.id = NEW.floor_plan_id AND fp.tenant_id = NEW.tenant_id;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'PLAN_NOT_FOUND: el lienzo no existe en el tenant'
            USING ERRCODE = 'foreign_key_violation', CONSTRAINT = 'fk_plan_elements_tenant_plan';
    END IF;
    IF TG_OP = 'INSERT' AND v_plan.valid_to IS NOT NULL AND v_plan.valid_to <= now() THEN
        RAISE EXCEPTION 'PLAN_RETIRED: el lienzo está clausurado, no admite elementos nuevos'
            USING ERRCODE = 'check_violation', CONSTRAINT = 'trg_plan_elements_derive';
    END IF;

    IF NEW.kind IN ('DOOR', 'WINDOW', 'OPENING') THEN
        SELECT e.kind, e.vertices, e.floor_plan_id INTO v_host
          FROM practice.plan_elements e
         WHERE e.id = NEW.host_element_id AND e.tenant_id = NEW.tenant_id;
        IF NOT FOUND OR v_host.floor_plan_id <> NEW.floor_plan_id OR v_host.kind <> 'WALL' THEN
            RAISE EXCEPTION 'PLAN_HOST_NOT_WALL: la puerta, ventana o abertura debe estar sobre un muro del mismo lienzo'
                USING ERRCODE = 'check_violation', CONSTRAINT = 'trg_plan_elements_derive';
        END IF;
        IF NEW.offset_m + NEW.width_m > practice.plan_polyline_length(v_host.vertices) + 0.001 THEN
            RAISE EXCEPTION 'PLAN_OPENING_OUTSIDE_WALL: la abertura (desplazamiento % + ancho % m) excede el largo del muro', NEW.offset_m, NEW.width_m
                USING ERRCODE = 'check_violation', CONSTRAINT = 'trg_plan_elements_derive';
        END IF;
        NEW.bbox := NULL;
    ELSE
        NEW.bbox := practice.plan_vertices_bbox(NEW.vertices);
        v_bb := NEW.bbox;
        IF (v_bb[1])[0] < -v_plan.contact_tolerance_m OR (v_bb[1])[1] < -v_plan.contact_tolerance_m
           OR (v_bb[0])[0] > v_plan.width_m + v_plan.contact_tolerance_m
           OR (v_bb[0])[1] > v_plan.height_m + v_plan.contact_tolerance_m THEN
            RAISE EXCEPTION 'PLAN_OUT_OF_BOUNDS: el elemento sale del lienzo (% x % m)', v_plan.width_m, v_plan.height_m
                USING ERRCODE = 'check_violation', CONSTRAINT = 'trg_plan_elements_derive';
        END IF;
    END IF;

    FOREACH v_sp IN ARRAY ARRAY[NEW.connects_space_a_id, NEW.connects_space_b_id] LOOP
        IF v_sp IS NOT NULL AND NOT EXISTS (
               SELECT 1 FROM practice.care_spaces cs
                WHERE cs.id = v_sp AND cs.tenant_id = NEW.tenant_id AND cs.practice_site_id = v_plan.practice_site_id) THEN
            RAISE EXCEPTION 'PLAN_CONNECT_SPACE_OTHER_SITE: el espacio conectado no es del establecimiento del lienzo'
                USING ERRCODE = 'check_violation', CONSTRAINT = 'trg_plan_elements_derive';
        END IF;
    END LOOP;
    RETURN NEW;
END $fn$;

DROP TRIGGER IF EXISTS "trg_plan_elements_derive" ON "practice"."plan_elements";
CREATE TRIGGER "trg_plan_elements_derive"
    BEFORE INSERT OR UPDATE ON "practice"."plan_elements"
    FOR EACH ROW EXECUTE FUNCTION practice.plan_elements_derive();

-- 7f. Acortar un muro no deja aberturas colgando (DIFERIDO).
CREATE OR REPLACE FUNCTION practice.plan_elements_assert_hosted_fit()
RETURNS trigger
LANGUAGE plpgsql
SET search_path = pg_catalog, pg_temp
AS $fn$
DECLARE
    v_len numeric;
    c record;
BEGIN
    SELECT practice.plan_polyline_length(e.vertices) INTO v_len FROM practice.plan_elements e WHERE e.id = NEW.id;
    IF v_len IS NULL THEN
        RETURN NULL;
    END IF;
    FOR c IN
        SELECT h.id FROM practice.plan_elements h
         WHERE h.host_element_id = NEW.id AND h.offset_m + h.width_m > v_len + 0.001
         LIMIT 1
    LOOP
        RAISE EXCEPTION 'PLAN_OPENING_OUTSIDE_WALL: la abertura % ya no cabe en el muro acortado', c.id
            USING ERRCODE = 'check_violation', CONSTRAINT = 'trg_plan_elements_derive';
    END LOOP;
    RETURN NULL;
END $fn$;

DROP TRIGGER IF EXISTS "trg_plan_elements_assert_hosted_fit" ON "practice"."plan_elements";
CREATE CONSTRAINT TRIGGER "trg_plan_elements_assert_hosted_fit"
    AFTER UPDATE OF vertices ON "practice"."plan_elements"
    DEFERRABLE INITIALLY DEFERRED
    FOR EACH ROW
    WHEN (NEW.kind = 'WALL')
    EXECUTE FUNCTION practice.plan_elements_assert_hosted_fit();

-- 7g. Lienzo: ancla y sede inmutables, no achicar por debajo del contenido, cambio de
-- tolerancia → se recalcula el contorno de contacto, y `layout_version` sólo lo mueve la base.
CREATE OR REPLACE FUNCTION practice.floor_plans_guard()
RETURNS trigger
LANGUAGE plpgsql
SET search_path = pg_catalog, pg_temp
AS $fn$
DECLARE
    v_meta_changed boolean;
BEGIN
    IF NEW.tenant_id <> OLD.tenant_id OR NEW.practice_site_id <> OLD.practice_site_id
       OR NEW.anchor_space_id IS DISTINCT FROM OLD.anchor_space_id THEN
        RAISE EXCEPTION 'PLAN_ANCHOR_IMMUTABLE: la sede y el ancla de un lienzo no se cambian; clausurarlo y crear otro'
            USING ERRCODE = 'check_violation', CONSTRAINT = 'trg_floor_plans_guard';
    END IF;

    -- layout_version / txid / changed_at: sólo el trigger de sentencia (profundidad > 1).
    IF pg_trigger_depth() = 1 THEN
        NEW.layout_version := OLD.layout_version;
        NEW.layout_version_txid := OLD.layout_version_txid;
        NEW.layout_changed_at := OLD.layout_changed_at;
    END IF;

    IF NEW.width_m < OLD.width_m OR NEW.height_m < OLD.height_m THEN
        IF EXISTS (SELECT 1 FROM practice.space_placements p
                    WHERE p.floor_plan_id = NEW.id
                      AND ((p.bbox[0])[0] > NEW.width_m + NEW.contact_tolerance_m OR (p.bbox[0])[1] > NEW.height_m + NEW.contact_tolerance_m))
           OR EXISTS (SELECT 1 FROM practice.plan_elements e
                       WHERE e.floor_plan_id = NEW.id AND e.bbox IS NOT NULL
                         AND ((e.bbox[0])[0] > NEW.width_m + NEW.contact_tolerance_m OR (e.bbox[0])[1] > NEW.height_m + NEW.contact_tolerance_m)) THEN
            RAISE EXCEPTION 'PLAN_BOUNDS_EXCLUDE_CONTENT: el lienzo achicado dejaría espacios o elementos fuera'
                USING ERRCODE = 'check_violation', CONSTRAINT = 'trg_floor_plans_guard';
        END IF;
    END IF;

    v_meta_changed := NEW.width_m IS DISTINCT FROM OLD.width_m OR NEW.height_m IS DISTINCT FROM OLD.height_m
        OR NEW.elevation_m IS DISTINCT FROM OLD.elevation_m OR NEW.north_bearing_deg IS DISTINCT FROM OLD.north_bearing_deg
        OR NEW.grid_size_m IS DISTINCT FROM OLD.grid_size_m OR NEW.snap_to_grid IS DISTINCT FROM OLD.snap_to_grid
        OR NEW.contact_tolerance_m IS DISTINCT FROM OLD.contact_tolerance_m
        OR NEW.background_file_id IS DISTINCT FROM OLD.background_file_id
        OR NEW.background_file_version_id IS DISTINCT FROM OLD.background_file_version_id
        OR NEW.background_scale_m_per_px IS DISTINCT FROM OLD.background_scale_m_per_px
        OR NEW.background_offset_x_m IS DISTINCT FROM OLD.background_offset_x_m
        OR NEW.background_offset_y_m IS DISTINCT FROM OLD.background_offset_y_m
        OR NEW.background_rotation_deg IS DISTINCT FROM OLD.background_rotation_deg
        OR NEW.background_opacity IS DISTINCT FROM OLD.background_opacity;
    IF pg_trigger_depth() = 1 AND v_meta_changed AND OLD.layout_version_txid IS DISTINCT FROM txid_current() THEN
        NEW.layout_version := OLD.layout_version + 1;
        NEW.layout_version_txid := txid_current();
        NEW.layout_changed_at := clock_timestamp();
    END IF;
    RETURN NEW;
END $fn$;

DROP TRIGGER IF EXISTS "trg_floor_plans_guard" ON "practice"."floor_plans";
CREATE TRIGGER "trg_floor_plans_guard"
    BEFORE UPDATE ON "practice"."floor_plans"
    FOR EACH ROW EXECUTE FUNCTION practice.floor_plans_guard();

CREATE OR REPLACE FUNCTION practice.floor_plans_recompute_contact()
RETURNS trigger
LANGUAGE plpgsql
SET search_path = pg_catalog, pg_temp
AS $fn$
BEGIN
    UPDATE practice.space_placements sp
       SET sibling_group_id = sp.sibling_group_id
     WHERE sp.floor_plan_id = NEW.id;
    RETURN NULL;
END $fn$;

DROP TRIGGER IF EXISTS "trg_floor_plans_recompute_contact" ON "practice"."floor_plans";
CREATE TRIGGER "trg_floor_plans_recompute_contact"
    AFTER UPDATE OF contact_tolerance_m ON "practice"."floor_plans"
    FOR EACH ROW
    WHEN (OLD.contact_tolerance_m IS DISTINCT FROM NEW.contact_tolerance_m)
    EXECUTE FUNCTION practice.floor_plans_recompute_contact();

-- 7h. layout_version: +1 por TRANSACCIÓN que cambie ubicaciones o elementos (trigger de
-- sentencia con tablas de transición). Un PUT/PATCH de layout con N sentencias sube la
-- versión una sola vez: el cliente guarda el valor devuelto y lo manda en el siguiente If-Match.
CREATE OR REPLACE FUNCTION practice.plan_bump_layout_ins() RETURNS trigger
LANGUAGE plpgsql SET search_path = pg_catalog, pg_temp
AS $fn$
BEGIN
    UPDATE practice.floor_plans fp
       SET layout_version = fp.layout_version + 1, layout_version_txid = txid_current(), layout_changed_at = clock_timestamp()
     WHERE fp.id IN (SELECT DISTINCT floor_plan_id FROM new_rows)
       AND fp.layout_version_txid IS DISTINCT FROM txid_current();
    RETURN NULL;
END $fn$;

CREATE OR REPLACE FUNCTION practice.plan_bump_layout_upd() RETURNS trigger
LANGUAGE plpgsql SET search_path = pg_catalog, pg_temp
AS $fn$
BEGIN
    UPDATE practice.floor_plans fp
       SET layout_version = fp.layout_version + 1, layout_version_txid = txid_current(), layout_changed_at = clock_timestamp()
     WHERE fp.id IN (SELECT floor_plan_id FROM new_rows UNION SELECT floor_plan_id FROM old_rows)
       AND fp.layout_version_txid IS DISTINCT FROM txid_current();
    RETURN NULL;
END $fn$;

CREATE OR REPLACE FUNCTION practice.plan_bump_layout_del() RETURNS trigger
LANGUAGE plpgsql SET search_path = pg_catalog, pg_temp
AS $fn$
BEGIN
    UPDATE practice.floor_plans fp
       SET layout_version = fp.layout_version + 1, layout_version_txid = txid_current(), layout_changed_at = clock_timestamp()
     WHERE fp.id IN (SELECT DISTINCT floor_plan_id FROM old_rows)
       AND fp.layout_version_txid IS DISTINCT FROM txid_current();
    RETURN NULL;
END $fn$;

DO $$
DECLARE
    t text;
BEGIN
    FOREACH t IN ARRAY ARRAY['space_placements', 'plan_elements'] LOOP
        EXECUTE format('DROP TRIGGER IF EXISTS trg_%s_bump_ins ON practice.%I', t, t);
        EXECUTE format('CREATE TRIGGER trg_%s_bump_ins AFTER INSERT ON practice.%I REFERENCING NEW TABLE AS new_rows FOR EACH STATEMENT EXECUTE FUNCTION practice.plan_bump_layout_ins()', t, t);
        EXECUTE format('DROP TRIGGER IF EXISTS trg_%s_bump_upd ON practice.%I', t, t);
        EXECUTE format('CREATE TRIGGER trg_%s_bump_upd AFTER UPDATE ON practice.%I REFERENCING OLD TABLE AS old_rows NEW TABLE AS new_rows FOR EACH STATEMENT EXECUTE FUNCTION practice.plan_bump_layout_upd()', t, t);
        EXECUTE format('DROP TRIGGER IF EXISTS trg_%s_bump_del ON practice.%I', t, t);
        EXECUTE format('CREATE TRIGGER trg_%s_bump_del AFTER DELETE ON practice.%I REFERENCING OLD TABLE AS old_rows FOR EACH STATEMENT EXECUTE FUNCTION practice.plan_bump_layout_del()', t, t);
    END LOOP;
END $$;

-- 7i. Historia: tenant por defecto desde el origen y «sólo inserción + cierre de valid_to»
-- (las funciones son las de F1b). La API escribe la historia ANTES de borrar una ubicación o
-- un elemento: el trigger de tenant lee la fila de origen.
DO $$
DECLARE
    r record;
BEGIN
    FOR r IN
        SELECT * FROM (VALUES
            ('floor_plans_history',      'practice.floor_plans',      'floor_plan_id'),
            ('space_placements_history', 'practice.space_placements', 'space_placement_id'),
            ('plan_elements_history',    'practice.plan_elements',    'plan_element_id')
        ) AS v(historia, origen, columna)
    LOOP
        EXECUTE format('DROP TRIGGER IF EXISTS trg_fill_tenant ON "audit".%I', r.historia);
        EXECUTE format('CREATE TRIGGER trg_fill_tenant BEFORE INSERT ON "audit".%I FOR EACH ROW EXECUTE FUNCTION "audit"."structure_history_fill_tenant"(%L, %L)',
                       r.historia, r.origen, r.columna);
        EXECUTE format('DROP TRIGGER IF EXISTS trg_close_only ON "audit".%I', r.historia);
        EXECUTE format('CREATE TRIGGER trg_close_only BEFORE UPDATE OR DELETE ON "audit".%I FOR EACH ROW EXECUTE FUNCTION "audit"."structure_history_close_only"()',
                       r.historia);
    END LOOP;
END $$;

-- ------------------------------------------------------------- 8. vista y funciones de consulta
-- Geometría + datos de identidad del espacio + área calculada frente a la declarada. El
-- estado operativo (F2) NO va acá: lo une la API (el plano casi en tiempo real no es una vista).
-- `tolerance_pct` sale de practice_settings `infra.plan.area_tolerance_pct`; sin umbral
-- configurado no hay veredicto (`within_tolerance` NULL): ninguna cifra es una norma.
CREATE OR REPLACE VIEW practice.v_floor_plan_spaces
WITH (security_invoker = true) AS
SELECT sp.id                AS placement_id,
       sp.tenant_id,
       sp.floor_plan_id,
       fp.code              AS plan_code,
       sp.care_space_id,
       cs.practice_site_id,
       cs.code,
       cs.name,
       cs.parent_space_id,
       cs.clinical_unit_id,
       cs.form_concept_id,
       cs.space_type_concept_id AS function_concept_id,
       cs.status_concept_id,
       sp.shape_kind,
       sp.bbox,
       sp.z_order,
       sp.locked,
       cs.area_m2           AS area_declared_m2,
       sp.area_calc_m2,
       CASE WHEN cs.area_m2 > 0 THEN round((sp.area_calc_m2 - cs.area_m2) / cs.area_m2 * 100, 2) END AS deviation_pct,
       tol.tolerance_pct,
       CASE WHEN tol.tolerance_pct IS NULL OR cs.area_m2 IS NULL OR cs.area_m2 <= 0 THEN NULL
            ELSE abs((sp.area_calc_m2 - cs.area_m2) / cs.area_m2 * 100) <= tol.tolerance_pct END AS within_tolerance
  FROM practice.space_placements sp
  JOIN practice.floor_plans fp ON fp.id = sp.floor_plan_id
  JOIN practice.care_spaces cs ON cs.id = sp.care_space_id
  JOIN practice.practice_sites ps ON ps.id = cs.practice_site_id
  LEFT JOIN LATERAL (
        SELECT CASE WHEN jsonb_typeof(s.value_json) = 'number' THEN (s.value_json #>> '{}')::numeric END AS tolerance_pct
          FROM practice.practice_settings s
         WHERE s.practice_id = ps.practice_id AND s.setting_key = 'infra.plan.area_tolerance_pct'
         LIMIT 1) tol ON true;

-- Auditoría completa de un lienzo (la usa GET /floor-plans/:id/validation). Devuelve
-- problemas, no excepciones: ERROR = rompe una invariante, WARNING = a revisar.
CREATE OR REPLACE FUNCTION practice.plan_validate(p_plan uuid)
RETURNS TABLE (severity text, code text, subject_id uuid, other_id uuid, detail text)
LANGUAGE sql STABLE
SET search_path = pg_catalog, pg_temp
AS $fn$
    -- hermanos solapados
    SELECT 'ERROR'::text, 'SIBLING_OVERLAP'::text, a.care_space_id, b.care_space_id,
           'los espacios comparten superficie dentro de la tolerancia de contacto'::text
      FROM practice.space_placements a
      JOIN practice.space_placements b
        ON a.floor_plan_id = b.floor_plan_id AND a.sibling_group_id = b.sibling_group_id AND a.id < b.id
       AND a.overlap_outline && b.overlap_outline
     WHERE a.floor_plan_id = p_plan
    UNION ALL
    -- hijo fuera del padre ubicado en el mismo lienzo
    SELECT 'ERROR', 'CHILD_OUTSIDE_PARENT', c.care_space_id, cs.parent_space_id,
           'el espacio no cabe dentro de la geometría de su padre'
      FROM practice.space_placements c
      JOIN practice.care_spaces cs ON cs.id = c.care_space_id
      JOIN practice.space_placements p ON p.care_space_id = cs.parent_space_id AND p.floor_plan_id = c.floor_plan_id
     WHERE c.floor_plan_id = p_plan AND NOT (p.outline @> c.overlap_outline)
    UNION ALL
    -- fuera del lienzo
    SELECT 'ERROR', 'OUT_OF_BOUNDS', sp.care_space_id, NULL::uuid,
           'la caja envolvente sale del lienzo'
      FROM practice.space_placements sp
      JOIN practice.floor_plans fp ON fp.id = sp.floor_plan_id
     WHERE sp.floor_plan_id = p_plan
       AND ((sp.bbox[1])[0] < -fp.contact_tolerance_m OR (sp.bbox[1])[1] < -fp.contact_tolerance_m
         OR (sp.bbox[0])[0] > fp.width_m + fp.contact_tolerance_m OR (sp.bbox[0])[1] > fp.height_m + fp.contact_tolerance_m)
    UNION ALL
    -- área calculada fuera del umbral configurado
    SELECT 'WARNING', 'AREA_MISMATCH', v.care_space_id, NULL::uuid,
           format('declarada %s m², calculada %s m² (%s %%, umbral %s %%)', v.area_declared_m2, v.area_calc_m2, v.deviation_pct, v.tolerance_pct)
      FROM practice.v_floor_plan_spaces v
     WHERE v.floor_plan_id = p_plan AND v.within_tolerance = false
$fn$;

-- Espacios del alcance del lienzo que todavía no tienen lugar en ningún plano (paleta del
-- editor). Alcance = descendientes del ancla; sin ancla, toda la sede.
CREATE OR REPLACE FUNCTION practice.plan_unplaced_spaces(p_plan uuid)
RETURNS TABLE (care_space_id uuid, code text, name text, parent_space_id uuid, form_concept_id uuid,
               function_concept_id uuid, status_concept_id uuid, depth integer)
LANGUAGE sql STABLE
SET search_path = pg_catalog, pg_temp
AS $fn$
    WITH RECURSIVE fp AS (
        SELECT id, practice_site_id, anchor_space_id FROM practice.floor_plans WHERE id = p_plan
    ), d(id, depth) AS (
        SELECT cs.id, 1
          FROM practice.care_spaces cs, fp
         WHERE cs.practice_site_id = fp.practice_site_id
           AND ((fp.anchor_space_id IS NULL AND cs.parent_space_id IS NULL) OR cs.parent_space_id = fp.anchor_space_id)
        UNION ALL
        SELECT c.id, d.depth + 1
          FROM practice.care_spaces c JOIN d ON c.parent_space_id = d.id
    )
    SELECT cs.id, cs.code::text, cs.name::text, cs.parent_space_id, cs.form_concept_id,
           cs.space_type_concept_id, cs.status_concept_id, d.depth
      FROM d
      JOIN practice.care_spaces cs ON cs.id = d.id
     WHERE NOT EXISTS (SELECT 1 FROM practice.space_placements sp WHERE sp.care_space_id = cs.id)
     ORDER BY d.depth, cs.code
$fn$;

-- ------------------------------------------------------------- 9. privilegios y RLS
-- Texto exacto de la política de 2026-08-05_tenant_rls.sql. Lienzos: sin DELETE (se
-- clausuran con valid_to, como el resto de la estructura). Ubicaciones y elementos: DML
-- completo (editar un plano es quitar y poner figuras; la historia conserva cada versión).
-- Historia: SELECT, INSERT y UPDATE sólo de valid_to.
DO $$
DECLARE
    t text;
    base_plena text[] := ARRAY['practice.space_placements', 'practice.plan_elements'];
    base_sin_delete text[] := ARRAY['practice.floor_plans'];
    historias text[] := ARRAY['audit.floor_plans_history', 'audit.space_placements_history', 'audit.plan_elements_history'];
    todas text[] := ARRAY['practice.floor_plans', 'practice.space_placements', 'practice.plan_elements',
                          'audit.floor_plans_history', 'audit.space_placements_history', 'audit.plan_elements_history'];
BEGIN
    IF EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'mantra_app') THEN
        FOREACH t IN ARRAY base_plena LOOP
            EXECUTE format('GRANT SELECT, INSERT, UPDATE, DELETE ON %s TO mantra_app', t);
        END LOOP;
        FOREACH t IN ARRAY base_sin_delete LOOP
            EXECUTE format('REVOKE DELETE, TRUNCATE ON %s FROM mantra_app', t);
            EXECUTE format('GRANT SELECT, INSERT, UPDATE ON %s TO mantra_app', t);
        END LOOP;
        FOREACH t IN ARRAY historias LOOP
            EXECUTE format('REVOKE UPDATE, DELETE, TRUNCATE ON %s FROM mantra_app', t);
            EXECUTE format('GRANT SELECT, INSERT ON %s TO mantra_app', t);
            EXECUTE format('GRANT UPDATE ("valid_to") ON %s TO mantra_app', t);
        END LOOP;
        GRANT SELECT ON practice.v_floor_plan_spaces TO mantra_app;
    END IF;

    FOREACH t IN ARRAY todas LOOP
        EXECUTE format('ALTER TABLE %s ENABLE ROW LEVEL SECURITY', t);
        EXECUTE format('ALTER TABLE %s FORCE ROW LEVEL SECURITY', t);
        EXECUTE format('DROP POLICY IF EXISTS tenant_isolation ON %s', t);
        EXECUTE format($pol$
        CREATE POLICY tenant_isolation ON %s
          USING (
            tenant_id = NULLIF(
              current_setting('app.current_tenant_id', true),
              ''
            )::uuid
            OR current_setting('app.system_context', true) = 'true'
          )
          WITH CHECK (
            tenant_id = NULLIF(
              current_setting('app.current_tenant_id', true),
              ''
            )::uuid
            OR current_setting('app.system_context', true) = 'true'
          )
        $pol$, t);
    END LOOP;
END $$;

COMMENT ON TABLE practice.floor_plans IS 'F1c · Lienzo del plano de planta (piso, zona o campus). Metros reales; layout_version = If-Match del layout.';
COMMENT ON TABLE practice.space_placements IS 'F1c · Geometría de un espacio en su lienzo (RECT rotable o POLYGON simple). Un lugar por espacio. No toca el árbol físico.';
COMMENT ON TABLE practice.plan_elements IS 'F1c · Elementos de lienzo: muros, puertas, ventanas, aberturas, escaleras, ascensores, circulación, columnas, anotaciones.';
COMMENT ON COLUMN practice.space_placements.overlap_outline IS 'Contorno achicado por contact_tolerance_m: lo que usa el EXCLUDE para que dos locales que comparten pared no cuenten como solapados.';
COMMENT ON COLUMN practice.floor_plans.contact_tolerance_m IS 'Margen de contacto en metros (dato configurable por lienzo, 0..0.100). No es una norma.';

-- ------------------------------------------------------------- 10. verificación
DO $$
DECLARE
    n_tab  integer;
    n_geo  integer;
    n_fkc  integer;
    n_ck   integer;
    n_ex   integer;
    n_trg  integer;
    n_rls  integer;
    n_fn   integer;
    n_upd  integer := 0;
BEGIN
    SELECT count(*) INTO n_tab FROM pg_class c JOIN pg_namespace n ON n.oid = c.relnamespace
     WHERE c.relkind = 'r' AND (n.nspname, c.relname) IN (('practice','floor_plans'), ('practice','space_placements'),
            ('practice','plan_elements'), ('audit','floor_plans_history'), ('audit','space_placements_history'),
            ('audit','plan_elements_history'));

    SELECT count(*) INTO n_geo FROM information_schema.columns
     WHERE (table_schema, table_name, column_name) IN (('practice','space_placements','outline'),
            ('practice','space_placements','overlap_outline'), ('practice','space_placements','bbox'),
            ('practice','plan_elements','bbox'));

    SELECT count(*) INTO n_fkc FROM pg_constraint
     WHERE contype = 'f' AND convalidated AND array_length(conkey, 1) = 2
       AND conname IN ('fk_floor_plans_tenant_site', 'fk_floor_plans_tenant_anchor', 'fk_floor_plans_tenant_background', 'fk_floor_plans_background_version', 'fk_space_placements_tenant_plan',
            'fk_space_placements_tenant_space', 'fk_plan_elements_tenant_plan', 'fk_plan_elements_tenant_host',
            'fk_plan_elements_tenant_space_a', 'fk_plan_elements_tenant_space_b');

    SELECT count(*) INTO n_ck FROM pg_constraint
     WHERE contype = 'c' AND convalidated AND conname LIKE ANY (ARRAY['ck_floor_plans_%', 'ck_space_placements_%', 'ck_plan_elements_%']);

    SELECT count(*) INTO n_ex FROM pg_constraint
     WHERE contype = 'x' AND conname = 'ex_space_placements_no_overlap' AND condeferrable AND NOT condeferred;

    SELECT count(*) INTO n_trg FROM pg_trigger
     WHERE NOT tgisinternal AND tgname IN ('trg_space_placements_derive', 'trg_space_placements_assert_tree',
            'trg_space_placements_assert_no_orphans', 'trg_care_spaces_revalidate_placements', 'trg_plan_elements_derive',
            'trg_plan_elements_assert_hosted_fit', 'trg_floor_plans_guard', 'trg_floor_plans_recompute_contact',
            'trg_space_placements_bump_ins', 'trg_space_placements_bump_upd', 'trg_space_placements_bump_del',
            'trg_plan_elements_bump_ins', 'trg_plan_elements_bump_upd', 'trg_plan_elements_bump_del');
    -- + 3 × (trg_fill_tenant + trg_close_only) de las historias nuevas
    n_trg := n_trg + (SELECT count(*) FROM pg_trigger t JOIN pg_class c ON c.oid = t.tgrelid JOIN pg_namespace n ON n.oid = c.relnamespace
                       WHERE NOT t.tgisinternal AND n.nspname = 'audit'
                         AND c.relname IN ('floor_plans_history', 'space_placements_history', 'plan_elements_history')
                         AND t.tgname IN ('trg_fill_tenant', 'trg_close_only'));

    SELECT count(*) INTO n_rls
      FROM pg_class c JOIN pg_namespace n ON n.oid = c.relnamespace
      JOIN pg_policies p ON p.schemaname = n.nspname AND p.tablename = c.relname AND p.policyname = 'tenant_isolation'
     WHERE c.relrowsecurity AND c.relforcerowsecurity
       AND (n.nspname, c.relname) IN (('practice','floor_plans'), ('practice','space_placements'), ('practice','plan_elements'),
            ('audit','floor_plans_history'), ('audit','space_placements_history'), ('audit','plan_elements_history'));

    SELECT count(*) INTO n_fn FROM pg_proc p JOIN pg_namespace n ON n.oid = p.pronamespace
     WHERE n.nspname = 'practice' AND p.proname IN ('plan_vertices_ok', 'plan_polygon_is_simple', 'plan_polygon_area',
            'plan_polyline_length', 'plan_rect_vertices', 'plan_vertices_to_polygon', 'plan_vertices_bbox',
            'plan_shrink_vertices', 'plan_validate', 'plan_unplaced_spaces');

    IF EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'mantra_app') THEN
        SELECT count(*) INTO n_upd FROM unnest(ARRAY['audit.floor_plans_history', 'audit.space_placements_history',
                'audit.plan_elements_history']) t
         WHERE has_table_privilege('mantra_app', t, 'UPDATE') OR has_table_privilege('mantra_app', t, 'DELETE');
        IF has_table_privilege('mantra_app', 'practice.floor_plans', 'DELETE') THEN
            n_upd := n_upd + 1;
        END IF;
    END IF;

    IF n_tab <> 6 OR n_geo <> 4 OR n_fkc <> 10 OR n_ck <> 24 OR n_ex <> 1 OR n_trg <> 20 OR n_rls <> 6 OR n_fn <> 10 OR n_upd <> 0 THEN
        RAISE EXCEPTION
            'v4.2.68 incompleto: tablas=% (6), columnas geométricas=% (4), FK compuestas=% (10), CHECK=% (24), EXCLUDE=% (1), triggers=% (20), RLS=% (6), funciones=% (10), privilegios de más=% (0)',
            n_tab, n_geo, n_fkc, n_ck, n_ex, n_trg, n_rls, n_fn, n_upd;
    END IF;

    RAISE NOTICE 'v4.2.68 aplicado: 3 tablas de plano + 3 historias, 10 FK compuestas (9 por tenant + versión del fondo), EXCLUDE de hermanos sin solape, % CHECK de geometría, RLS en 6 tablas.', n_ck;
END $$;

COMMIT;
