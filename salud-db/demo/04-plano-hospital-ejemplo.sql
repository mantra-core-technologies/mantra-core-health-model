-- Plano de ejemplo: «Hospital de 2.º nivel» con planta baja, piso 1 y campus (F1c · Plano).
--
-- Para que la API y la web tengan un plano realista que dibujar, filtrar, colorear por estado
-- y probar en 1440 / 768 / 390: 88 espacios (1 edificio, 2 pisos, 9 áreas, 4 salas de internación,
-- 42 locales y 30 camas), 3 lienzos (planta baja 33 figuras, piso 1 51, campus 2),
-- 136 elementos: muros, puertas, ventanas, circulación, escalera, ascensor y anotaciones.
-- Es un EJEMPLO DIDÁCTICO de distribución, no una norma ni una referencia de áreas mínimas:
-- nada de lo que dice acá sale de una norma boliviana.
--
-- CÓMO SE CORRE (después de la carga y de que la API sembró sus conceptos; ver README.md):
--
--   psql -v ON_ERROR_STOP=1 -v site_id=<uuid de una practice_site existente> \
--        -f salud-db/demo/04-plano-hospital-ejemplo.sql
--
-- · El establecimiento (`site_id`) tiene que existir; el tenant sale de él. No crea tenants.
-- · Los conceptos se buscan por código en terminology.catalog_concepts (`practice:LOC_FORM_*`,
--   `practice:SPACE_FN_*`, `practice:SPACE_ACTIVE`, …). Si falta alguno OBLIGATORIO, el script
--   se detiene y lista cuáles: ejecutar antes la siembra de conceptos de la API. Las unidades
--   clínicas y los vínculos espacio↔unidad son opcionales: se omiten (con aviso) si no existe un
--   concepto `practice:UNIT_TYPE_*` o `practice:SPACE_UNIT_ROLE_OWNER`.
-- · Idempotente: los ids son deterministas (md5 de site_id + clave) y todo va con ON CONFLICT
--   DO NOTHING. Volver a correrlo no duplica ni cambia nada.
-- · Deja DOS desvíos a propósito (R-QX2 y R-C3: área declarada ≠ área dibujada) y el umbral
--   `infra.plan.area_tolerance_pct = 10` (valor de demostración) para que la validación del
--   plano muestre advertencias AREA_MISMATCH reales.
--
-- Sistema de coordenadas: metros, x → derecha, y → abajo, origen arriba-izquierda del lienzo.
--   PB y P1: 64 × 26 m, grilla 0,5 m. Edificio de 60 × 20 m entre (2,2) y (62,22).
--   Franja norte y = 2 .. 10,5 · pasillo y = 10,5 .. 13,5 · franja sur y = 13,5 .. 22.
--   CAMPUS: 100 × 70 m (sin ancla: contiene el edificio y el estacionamiento).

BEGIN;
SET LOCAL app.system_context = 'true';

SELECT set_config('plano.site_id', :'site_id', true);

-- ---------------------------------------------------------------- utilidades
CREATE FUNCTION pg_temp.cid(c text, required boolean DEFAULT true) RETURNS uuid
LANGUAGE plpgsql AS $fn$
DECLARE r uuid;
BEGIN
    SELECT id INTO r FROM terminology.catalog_concepts
     WHERE code IN ('practice:' || c, c)
     ORDER BY (code = 'practice:' || c) DESC LIMIT 1;
    IF r IS NULL AND required THEN
        RAISE EXCEPTION 'plano demo: falta el concepto % en terminology.catalog_concepts (¿corrió la siembra de conceptos de la API?)', c;
    END IF;
    RETURN r;
END $fn$;

CREATE FUNCTION pg_temp.did(key text) RETURNS uuid
LANGUAGE sql IMMUTABLE AS $fn$
    SELECT md5(current_setting('plano.site_id') || ':plano-demo:' || key)::uuid
$fn$;

-- ---------------------------------------------------------------- definición
-- (clave, padre, forma, función, lienzo, x, y, ancho, fondo, nombre, unidad, área declarada [NULL = la dibujada])
CREATE TEMP TABLE _sp (
    key text PRIMARY KEY, parent text, form text, fn text, canvas text,
    x numeric, y numeric, w numeric, d numeric, name text, unit text, decl numeric, depth int
) ON COMMIT DROP;

INSERT INTO _sp (key, parent, form, fn, canvas, x, y, w, d, name, unit, decl) VALUES
 -- edificio y pisos (el edificio se dibuja en el campus; los pisos son lienzos, no figuras)
 ('BLD',    NULL,  'BUILDING', 'BUILDING_GENERIC', 'CP',  20, 20, 60, 20, 'Edificio principal', NULL, NULL),
 ('PB',     'BLD', 'LEVEL',    'LEVEL_GENERIC',    NULL,  NULL, NULL, NULL, NULL, 'Planta baja', NULL, NULL),
 ('P1',     'BLD', 'LEVEL',    'LEVEL_GENERIC',    NULL,  NULL, NULL, NULL, NULL, 'Piso 1', NULL, NULL),
 -- PB · franja norte
 ('PB-EME', 'PB', 'AREA', 'AREA_GENERIC', 'PB',  2, 2, 24, 8.5, 'Emergencias', 'EME', NULL),
 ('PB-TRI', 'PB-EME', 'ROOM', 'CONSULTING_ROOM', 'PB',  2, 2, 6, 8.5, 'Triaje', 'EME', NULL),
 ('PB-SHK', 'PB-EME', 'ROOM', 'EMERGENCY_BOX',   'PB',  8, 2, 6, 8.5, 'Sala de reanimación', 'EME', NULL),
 ('PB-BX1', 'PB-EME', 'ROOM', 'EMERGENCY_BOX',   'PB', 14, 2, 4, 8.5, 'Box 1', 'EME', NULL),
 ('PB-BX2', 'PB-EME', 'ROOM', 'EMERGENCY_BOX',   'PB', 18, 2, 4, 8.5, 'Box 2', 'EME', NULL),
 ('PB-BX3', 'PB-EME', 'ROOM', 'EMERGENCY_BOX',   'PB', 22, 2, 4, 8.5, 'Box 3', 'EME', NULL),
 ('PB-CEX', 'PB', 'AREA', 'AREA_GENERIC', 'PB', 26, 2, 20, 8.5, 'Consulta externa', 'CEX', NULL),
 ('PB-C1', 'PB-CEX', 'ROOM', 'CONSULTING_ROOM', 'PB', 26, 2, 4, 8.5, 'Consultorio 1 · Medicina general', 'CEX', NULL),
 ('PB-C2', 'PB-CEX', 'ROOM', 'CONSULTING_ROOM', 'PB', 30, 2, 4, 8.5, 'Consultorio 2 · Pediatría', 'CEX', NULL),
 ('PB-C3', 'PB-CEX', 'ROOM', 'CONSULTING_ROOM', 'PB', 34, 2, 4, 8.5, 'Consultorio 3 · Ginecología', 'CEX', 30),
 ('PB-C4', 'PB-CEX', 'ROOM', 'CONSULTING_ROOM', 'PB', 38, 2, 4, 8.5, 'Consultorio 4 · Cirugía', 'CEX', NULL),
 ('PB-C5', 'PB-CEX', 'ROOM', 'CONSULTING_ROOM', 'PB', 42, 2, 4, 8.5, 'Consultorio 5 · Medicina interna', 'CEX', NULL),
 ('PB-IMG', 'PB', 'AREA', 'AREA_GENERIC', 'PB', 46, 2, 16, 8.5, 'Imagenología', 'IMG', NULL),
 ('PB-RX',  'PB-IMG', 'ROOM', 'IMAGING_ROOM', 'PB', 46, 2, 8, 8.5, 'Sala de rayos X', 'IMG', NULL),
 ('PB-ECO', 'PB-IMG', 'ROOM', 'IMAGING_ROOM', 'PB', 54, 2, 8, 8.5, 'Sala de ecografía', 'IMG', NULL),
 -- PB · franja sur
 ('PB-EOB', 'PB', 'AREA', 'AREA_GENERIC', 'PB',  2, 13.5, 20, 8.5, 'Observación y procedimientos', 'EME', NULL),
 ('PB-OBS', 'PB-EOB', 'ROOM', 'OBSERVATION',    'PB',  2, 13.5, 12, 8.5, 'Observación (4 camas)', 'EME', NULL),
 ('PB-YES', 'PB-EOB', 'ROOM', 'PROCEDURE_ROOM', 'PB', 14, 13.5,  8, 8.5, 'Procedimientos y yeso', 'CIR', NULL),
 ('PB-LAB', 'PB', 'AREA', 'AREA_GENERIC', 'PB', 22, 13.5, 16, 8.5, 'Laboratorio', 'LAB', NULL),
 ('PB-TOM', 'PB-LAB', 'ROOM', 'SAMPLE_COLLECTION', 'PB', 22, 13.5, 6, 8.5, 'Toma de muestras', 'LAB', NULL),
 ('PB-REC', 'PB-LAB', 'ROOM', 'LAB_AREA', 'PB', 28, 13.5, 4, 8.5, 'Recepción de muestras', 'LAB', NULL),
 ('PB-ANL', 'PB-LAB', 'ROOM', 'LAB_AREA', 'PB', 32, 13.5, 6, 8.5, 'Área analítica', 'LAB', NULL),
 ('PB-FAR', 'PB', 'AREA', 'AREA_GENERIC', 'PB', 38, 13.5, 8, 8.5, 'Farmacia', 'FAR', NULL),
 ('PB-FDI', 'PB-FAR', 'ROOM', 'PHARMACY', 'PB', 38, 13.5, 4, 8.5, 'Dispensación', 'FAR', NULL),
 ('PB-FDE', 'PB-FAR', 'ROOM', 'STORAGE',  'PB', 42, 13.5, 4, 8.5, 'Depósito de farmacia', 'FAR', NULL),
 ('PB-ADM', 'PB', 'AREA', 'AREA_GENERIC', 'PB', 46, 13.5, 16, 8.5, 'Admisión y administración', 'ADM', NULL),
 ('PB-ADC', 'PB-ADM', 'ROOM', 'OFFICE_ADMIN', 'PB', 46, 13.5, 5, 8.5, 'Admisión y caja', 'ADM', NULL),
 ('PB-DIR', 'PB-ADM', 'ROOM', 'OFFICE_ADMIN', 'PB', 51, 13.5, 4, 8.5, 'Dirección', 'ADM', NULL),
 ('PB-WAI', 'PB-ADM', 'ROOM', 'WAITING',      'PB', 55, 13.5, 7, 8.5, 'Sala de espera general', 'ADM', NULL),
 -- P1 · franja norte: salas de internación
 ('P1-MED', 'P1', 'WARD', 'WARD_GENERIC', 'P1',  2, 2, 20, 8.5, 'Internación Medicina', 'MED', NULL),
 ('P1-101', 'P1-MED', 'ROOM', 'INPATIENT_ROOM', 'P1',  2, 2, 5, 8.5, 'Habitación 101', 'MED', NULL),
 ('P1-102', 'P1-MED', 'ROOM', 'INPATIENT_ROOM', 'P1',  7, 2, 5, 8.5, 'Habitación 102', 'MED', NULL),
 ('P1-AIS', 'P1-MED', 'ROOM', 'ISOLATION_AIIR', 'P1', 12, 2, 5, 8.5, 'Aislamiento 1 (presión negativa)', 'MED', NULL),
 ('P1-ENM', 'P1-MED', 'ROOM', 'NURSE_STATION', 'P1', 17, 2, 5, 8.5, 'Control de enfermería Medicina', 'MED', NULL),
 ('P1-CIR', 'P1', 'WARD', 'WARD_GENERIC', 'P1', 22, 2, 20, 8.5, 'Internación Cirugía', 'CIR', NULL),
 ('P1-201', 'P1-CIR', 'ROOM', 'INPATIENT_ROOM', 'P1', 22, 2, 5, 8.5, 'Habitación 201', 'CIR', NULL),
 ('P1-202', 'P1-CIR', 'ROOM', 'INPATIENT_ROOM', 'P1', 27, 2, 5, 8.5, 'Habitación 202', 'CIR', NULL),
 ('P1-203', 'P1-CIR', 'ROOM', 'INPATIENT_ROOM', 'P1', 32, 2, 5, 8.5, 'Habitación 203', 'CIR', NULL),
 ('P1-ENC', 'P1-CIR', 'ROOM', 'NURSE_STATION', 'P1', 37, 2, 5, 8.5, 'Control de enfermería Cirugía', 'CIR', NULL),
 ('P1-PED', 'P1', 'WARD', 'WARD_GENERIC', 'P1', 42, 2, 20, 8.5, 'Internación Pediatría', 'PED', NULL),
 ('P1-301', 'P1-PED', 'ROOM', 'INPATIENT_ROOM', 'P1', 42, 2, 5, 8.5, 'Habitación 301', 'PED', NULL),
 ('P1-302', 'P1-PED', 'ROOM', 'INPATIENT_ROOM', 'P1', 47, 2, 5, 8.5, 'Habitación 302', 'PED', NULL),
 ('P1-303', 'P1-PED', 'ROOM', 'INPATIENT_ROOM', 'P1', 52, 2, 5, 8.5, 'Habitación 303', 'PED', NULL),
 ('P1-ENP', 'P1-PED', 'ROOM', 'NURSE_STATION', 'P1', 57, 2, 5, 8.5, 'Control de enfermería Pediatría', 'PED', NULL),
 -- P1 · franja sur
 ('P1-GIN', 'P1', 'WARD', 'WARD_GENERIC', 'P1', 2, 13.5, 20, 8.5, 'Gineco-obstetricia', 'GIN', NULL),
 ('P1-PA1', 'P1-GIN', 'ROOM', 'DELIVERY_ROOM', 'P1',  2, 13.5, 7, 8.5, 'Sala de partos 1', 'GIN', NULL),
 ('P1-PA2', 'P1-GIN', 'ROOM', 'DELIVERY_ROOM', 'P1',  9, 13.5, 7, 8.5, 'Sala de partos 2', 'GIN', NULL),
 ('P1-401', 'P1-GIN', 'ROOM', 'INPATIENT_ROOM', 'P1', 16, 13.5, 6, 8.5, 'Habitación 401 · puerperio', 'GIN', NULL),
 ('P1-AQX', 'P1', 'AREA', 'AREA_GENERIC', 'P1', 22, 13.5, 24, 8.5, 'Bloque quirúrgico', 'QX', NULL),
 ('P1-QX1', 'P1-AQX', 'ROOM', 'OPERATING_ROOM', 'P1', 22, 13.5, 10, 8.5, 'Quirófano 1', 'QX', NULL),
 ('P1-QX2', 'P1-AQX', 'ROOM', 'OPERATING_ROOM', 'P1', 32, 13.5, 10, 8.5, 'Quirófano 2', 'QX', 74),
 ('P1-ESR', 'P1-AQX', 'ROOM', 'STERILIZATION',  'P1', 42, 13.5,  4, 8.5, 'Central de esterilización', 'QX', NULL),
 ('P1-REC', 'P1', 'ROOM', 'RECOVERY_PACU', 'P1', 46, 13.5,  6, 8.5, 'Recuperación posanestésica', 'QX', NULL),
 ('P1-UTI', 'P1', 'ROOM', 'ICU_BAY',       'P1', 52, 13.5, 10, 8.5, 'Terapia intermedia', 'UTI', NULL);

-- camas: (clave de la habitación, cantidad, función de cama)
CREATE TEMP TABLE _bed (room text, n int, fn text) ON COMMIT DROP;
INSERT INTO _bed VALUES
 ('PB-OBS', 4, 'BED_STANDARD'), ('P1-101', 2, 'BED_STANDARD'), ('P1-102', 2, 'BED_STANDARD'), ('P1-AIS', 1, 'BED_STANDARD'),
 ('P1-201', 2, 'BED_STANDARD'), ('P1-202', 2, 'BED_STANDARD'), ('P1-203', 2, 'BED_STANDARD'),
 ('P1-301', 2, 'BED_STANDARD'), ('P1-302', 2, 'BED_STANDARD'), ('P1-303', 2, 'BED_STANDARD'),
 ('P1-401', 2, 'BED_STANDARD'), ('P1-REC', 3, 'BED_STANDARD'), ('P1-UTI', 4, 'BED_ICU');
-- 4 + 2+2+1 + 2+2+2 + 2+2+2 + 2 + 3 + 4 = 30 camas.

WITH RECURSIVE t(key, depth) AS (
    SELECT key, 1 FROM _sp WHERE parent IS NULL
    UNION ALL
    SELECT s.key, t.depth + 1 FROM _sp s JOIN t ON s.parent = t.key
)
UPDATE _sp SET depth = t.depth FROM t WHERE _sp.key = t.key;

-- ---------------------------------------------------------------- unidades clínicas (opcionales)
DO $$
DECLARE
    v_site   uuid := current_setting('plano.site_id')::uuid;
    v_tenant uuid;
    v_unit_type uuid := (SELECT id FROM terminology.catalog_concepts WHERE code LIKE 'practice:UNIT_TYPE%' ORDER BY code LIMIT 1);
    v_active uuid := pg_temp.cid('UNIT_ACTIVE', false);
    v_status uuid;
BEGIN
    SELECT tenant_id INTO v_tenant FROM practice.practice_sites WHERE id = v_site;
    IF v_tenant IS NULL THEN
        RAISE EXCEPTION 'plano demo: la sede % no existe (pasar -v site_id=<uuid de practice_sites>)', v_site;
    END IF;
    v_status := coalesce(v_active, pg_temp.cid('SPACE_ACTIVE'));
    IF v_unit_type IS NULL THEN
        RAISE NOTICE 'plano demo: no hay concepto practice:UNIT_TYPE_*; se omiten las unidades clínicas y los vínculos espacio↔unidad';
        RETURN;
    END IF;
    INSERT INTO practice.clinical_units (id, practice_site_id, tenant_id, code, name, unit_type_concept_id, status_concept_id, created_at, updated_at)
    SELECT pg_temp.did('unit:' || u.code), v_site, v_tenant, 'PLANO-' || u.code, u.name, v_unit_type, v_status, now(), now()
      FROM (VALUES ('EME', 'Emergencias'), ('CEX', 'Consulta externa'), ('IMG', 'Imagenología'), ('LAB', 'Laboratorio'),
                   ('FAR', 'Farmacia'), ('ADM', 'Admisión y administración'), ('MED', 'Medicina interna'), ('CIR', 'Cirugía'),
                   ('PED', 'Pediatría'), ('GIN', 'Gineco-obstetricia'), ('QX', 'Bloque quirúrgico'), ('UTI', 'Terapia intermedia')) AS u(code, name)
    ON CONFLICT (id) DO NOTHING;
END $$;

-- ---------------------------------------------------------------- espacios (árbol físico)
DO $$
DECLARE
    v_site   uuid := current_setting('plano.site_id')::uuid;
    v_tenant uuid;
    v_active uuid := pg_temp.cid('SPACE_ACTIVE');
    lvl      integer;
BEGIN
    SELECT tenant_id INTO v_tenant FROM practice.practice_sites WHERE id = v_site;

    -- por profundidad, para que el padre exista antes que el hijo (la FK compuesta lo exige)
    FOR lvl IN 1..4 LOOP
        INSERT INTO practice.care_spaces (id, practice_site_id, tenant_id, parent_space_id, clinical_unit_id, code, name,
                                          space_type_concept_id, form_concept_id, status_concept_id, area_m2, floor_number,
                                          created_at, updated_at)
        SELECT pg_temp.did('sp:' || s.key), v_site, v_tenant,
               CASE WHEN s.parent IS NULL THEN NULL ELSE pg_temp.did('sp:' || s.parent) END,
               (SELECT cu.id FROM practice.clinical_units cu WHERE cu.id = pg_temp.did('unit:' || s.unit)),
               'PLANO-' || s.key, s.name,
               pg_temp.cid('SPACE_FN_' || s.fn), pg_temp.cid('LOC_FORM_' || s.form), v_active,
               CASE WHEN s.w IS NULL THEN NULL ELSE coalesce(s.decl, s.w * s.d) END,
               CASE WHEN s.key LIKE 'PB%' THEN 0 WHEN s.key LIKE 'P1%' THEN 1 END,
               now(), now()
          FROM _sp s
         WHERE s.depth = lvl
        ON CONFLICT (id) DO NOTHING;
    END LOOP;

    -- camas: forma BED, función BED_STANDARD / BED_ICU, censables
    INSERT INTO practice.care_spaces (id, practice_site_id, tenant_id, parent_space_id, clinical_unit_id, code, name,
                                      space_type_concept_id, form_concept_id, status_concept_id, area_m2, censable, floor_number,
                                      created_at, updated_at)
    SELECT pg_temp.did('bed:' || b.room || ':' || g), v_site, v_tenant, pg_temp.did('sp:' || b.room), r.clinical_unit_id,
           'PLANO-' || b.room || '-C' || g, 'Cama ' || g || ' · ' || r.name,
           pg_temp.cid('SPACE_FN_' || b.fn), pg_temp.cid('LOC_FORM_BED'), v_active, 2.0, true,
           CASE WHEN b.room LIKE 'PB%' THEN 0 ELSE 1 END, now(), now()
      FROM _bed b
      JOIN practice.care_spaces r ON r.id = pg_temp.did('sp:' || b.room)
     CROSS JOIN LATERAL generate_series(1, b.n) AS g
    ON CONFLICT (id) DO NOTHING;
END $$;

-- vínculos espacio↔unidad (dueña), si existe el concepto del rol
INSERT INTO practice.space_unit_assignments (id, tenant_id, care_space_id, clinical_unit_id, role_concept_id, valid_from, created_at, updated_at)
SELECT pg_temp.did('asg:' || cs.id), cs.tenant_id, cs.id, cs.clinical_unit_id, pg_temp.cid('SPACE_UNIT_ROLE_OWNER', false), now(), now(), now()
  FROM practice.care_spaces cs
 WHERE cs.id IN (SELECT pg_temp.did('sp:' || key) FROM _sp WHERE unit IS NOT NULL)
   AND cs.clinical_unit_id IS NOT NULL
   AND pg_temp.cid('SPACE_UNIT_ROLE_OWNER', false) IS NOT NULL
ON CONFLICT (id) DO NOTHING;

-- ---------------------------------------------------------------- lienzos
INSERT INTO practice.floor_plans (id, tenant_id, practice_site_id, anchor_space_id, code, name, width_m, height_m, elevation_m,
                                  north_bearing_deg, grid_size_m, valid_from, created_at, updated_at)
SELECT pg_temp.did('plan:' || p.code), cs.tenant_id, cs.practice_site_id,
       CASE WHEN p.anchor IS NULL THEN NULL ELSE pg_temp.did('sp:' || p.anchor) END,
       'PLANO-' || p.code, p.name, p.w, p.h, p.elev, 0, p.grid, now(), now(), now()
  FROM (VALUES ('PB', 'PB', 'Planta baja', 64, 26, 0.000, 0.5),
               ('P1', 'P1', 'Piso 1', 64, 26, 3.600, 0.5),
               ('CP', NULL, 'Campus', 100, 70, NULL, 1.0)) AS p(code, anchor, name, w, h, elev, grid)
  JOIN practice.care_spaces cs ON cs.id = pg_temp.did('sp:BLD')
ON CONFLICT (id) DO NOTHING;

-- ---------------------------------------------------------------- ubicaciones (geometría de los espacios)
-- Locales, áreas, salas y edificio: rectángulos axiales (rotación 0).
INSERT INTO practice.space_placements (id, tenant_id, floor_plan_id, care_space_id, shape_kind, center_x_m, center_y_m,
                                       width_m, depth_m, rotation_deg, vertices, z_order, created_at, updated_at)
SELECT pg_temp.did('pl:' || s.key), cs.tenant_id, pg_temp.did('plan:' || s.canvas), cs.id, 'RECT',
       s.x + s.w / 2, s.y + s.d / 2, s.w, s.d, 0, '[]'::jsonb,
       CASE WHEN s.form IN ('AREA', 'WARD', 'BUILDING') THEN 0 ELSE 10 END, now(), now()
  FROM _sp s
  JOIN practice.care_spaces cs ON cs.id = pg_temp.did('sp:' || s.key)
 WHERE s.canvas IS NOT NULL
ON CONFLICT (id) DO NOTHING;

-- Camas: 1,0 × 2,0 m, cabecera contra el muro norte, repartidas a lo ancho de la habitación.
INSERT INTO practice.space_placements (id, tenant_id, floor_plan_id, care_space_id, shape_kind, center_x_m, center_y_m,
                                       width_m, depth_m, rotation_deg, vertices, z_order, created_at, updated_at)
SELECT pg_temp.did('plb:' || b.room || ':' || g), cs.tenant_id,
       pg_temp.did('plan:' || r.canvas), cs.id, 'RECT',
       r.x + r.w * g / (b.n + 1.0), r.y + CASE WHEN r.y > 12 THEN r.d - 1.2 ELSE 1.2 END, 1.0, 2.0, 0, '[]'::jsonb, 20, now(), now()
  FROM _bed b
  JOIN _sp r ON r.key = b.room
 CROSS JOIN LATERAL generate_series(1, b.n) AS g
  JOIN practice.care_spaces cs ON cs.id = pg_temp.did('bed:' || b.room || ':' || g)
ON CONFLICT (id) DO NOTHING;

-- Estacionamiento: polígono (trapecio) en el campus. Es una raíz del árbol (sin padre).
DO $$
DECLARE
    v_site   uuid := current_setting('plano.site_id')::uuid;
    v_tenant uuid;
BEGIN
    SELECT tenant_id INTO v_tenant FROM practice.practice_sites WHERE id = v_site;
    INSERT INTO practice.care_spaces (id, practice_site_id, tenant_id, code, name, space_type_concept_id, form_concept_id,
                                      status_concept_id, created_at, updated_at)
    VALUES (pg_temp.did('sp:ESTAC'), v_site, v_tenant, 'PLANO-ESTAC', 'Estacionamiento',
            pg_temp.cid('SPACE_FN_AREA_GENERIC'), pg_temp.cid('LOC_FORM_AREA'), pg_temp.cid('SPACE_ACTIVE'), now(), now())
    ON CONFLICT (id) DO NOTHING;
    INSERT INTO practice.space_placements (id, tenant_id, floor_plan_id, care_space_id, shape_kind, vertices, z_order, created_at, updated_at)
    VALUES (pg_temp.did('pl:ESTAC'), v_tenant, pg_temp.did('plan:CP'), pg_temp.did('sp:ESTAC'), 'POLYGON',
            '[[8,50],[62,50],[56,66],[8,66]]'::jsonb, 0, now(), now())
    ON CONFLICT (id) DO NOTHING;
END $$;

-- ---------------------------------------------------------------- elementos
-- Muro exterior (lazo cerrado) y muro de cada local.
INSERT INTO practice.plan_elements (id, tenant_id, floor_plan_id, kind, vertices, thickness_m, label, z_order, created_at, updated_at)
SELECT pg_temp.did('wall:ext:' || p.code), cs.tenant_id, pg_temp.did('plan:' || p.code), 'WALL',
       '[[2,2],[62,2],[62,22],[2,22],[2,2]]'::jsonb, 0.3, 'Muro exterior', 30, now(), now()
  FROM (VALUES ('PB'), ('P1')) AS p(code)
  JOIN practice.care_spaces cs ON cs.id = pg_temp.did('sp:BLD')
ON CONFLICT (id) DO NOTHING;

INSERT INTO practice.plan_elements (id, tenant_id, floor_plan_id, kind, vertices, thickness_m, label, z_order, created_at, updated_at)
SELECT pg_temp.did('wall:' || s.key), cs.tenant_id, pg_temp.did('plan:' || s.canvas), 'WALL',
       jsonb_build_array(jsonb_build_array(s.x, s.y), jsonb_build_array(s.x + s.w, s.y), jsonb_build_array(s.x + s.w, s.y + s.d),
                         jsonb_build_array(s.x, s.y + s.d), jsonb_build_array(s.x, s.y)),
       0.12, NULL, 30, now(), now()
  FROM _sp s
  JOIN practice.care_spaces cs ON cs.id = pg_temp.did('sp:' || s.key)
 WHERE s.form = 'ROOM' AND s.canvas IN ('PB', 'P1')
ON CONFLICT (id) DO NOTHING;

-- Puertas: una por local, sobre su muro, del lado del pasillo (franja norte → arista inferior;
-- franja sur → arista superior). Lazo: arriba (w) · derecha (d) · abajo (w) · izquierda (d).
INSERT INTO practice.plan_elements (id, tenant_id, floor_plan_id, kind, host_element_id, offset_m, width_m, swing, swing_side,
                                    connects_space_a_id, z_order, created_at, updated_at)
SELECT pg_temp.did('door:' || s.key), cs.tenant_id, pg_temp.did('plan:' || s.canvas), 'DOOR', pg_temp.did('wall:' || s.key),
       CASE WHEN s.y < 10 THEN s.w + s.d + (s.w - dw.w) / 2 ELSE (s.w - dw.w) / 2 END,
       dw.w, CASE WHEN s.fn = 'OPERATING_ROOM' THEN 'DOUBLE' WHEN s.fn = 'WAITING' THEN 'NONE' ELSE 'LEFT' END, 'A',
       cs.id, 40, now(), now()
  FROM _sp s
  JOIN practice.care_spaces cs ON cs.id = pg_temp.did('sp:' || s.key)
 CROSS JOIN LATERAL (SELECT CASE WHEN s.fn IN ('OPERATING_ROOM', 'WAITING') THEN 2.0
                                 WHEN s.fn IN ('INPATIENT_ROOM', 'ISOLATION_AIIR', 'DELIVERY_ROOM', 'OBSERVATION', 'ICU_BAY', 'RECOVERY_PACU') THEN 1.2
                                 ELSE 1.0 END AS w) dw
 WHERE s.form = 'ROOM' AND s.canvas IN ('PB', 'P1') AND s.w >= dw.w + 0.5
ON CONFLICT (id) DO NOTHING;

-- Ventanas en el muro exterior: franja norte sobre la arista superior (de oeste a este) y franja
-- sur sobre la inferior (de este a oeste, porque el lazo la recorre al revés). Ancho 1,6 m.
INSERT INTO practice.plan_elements (id, tenant_id, floor_plan_id, kind, host_element_id, offset_m, width_m, z_order, created_at, updated_at)
SELECT pg_temp.did('win:' || s.key), cs.tenant_id, pg_temp.did('plan:' || s.canvas), 'WINDOW',
       pg_temp.did('wall:ext:' || s.canvas),
       CASE WHEN s.y < 10 THEN (s.x + s.w / 2 - 2) - 0.8 ELSE 60 + 20 + (62 - (s.x + s.w / 2)) - 0.8 END,
       1.6, 35, now(), now()
  FROM _sp s
  JOIN practice.care_spaces cs ON cs.id = pg_temp.did('sp:' || s.key)
 WHERE s.form = 'ROOM' AND s.canvas IN ('PB', 'P1') AND s.fn NOT IN ('STERILIZATION', 'SAMPLE_COLLECTION') AND s.w >= 4
ON CONFLICT (id) DO NOTHING;

-- Circulación, escalera y ascensor (el mismo código vertical en los dos pisos), y rosa de los vientos.
INSERT INTO practice.plan_elements (id, tenant_id, floor_plan_id, kind, vertices, label, vertical_link_code, z_order, created_at, updated_at)
SELECT pg_temp.did(e.k || ':' || p.code), cs.tenant_id, pg_temp.did('plan:' || p.code), e.kind, e.verts::jsonb, e.label, e.link, e.z, now(), now()
  FROM (VALUES ('PB'), ('P1')) AS p(code)
 CROSS JOIN (VALUES
    ('circ', 'CIRCULATION', '[[2,10.5],[54,10.5],[54,13.5],[2,13.5]]', 'Pasillo central', NULL, 5),
    ('elev', 'ELEVATOR',    '[[54,10.5],[58,10.5],[58,13.5],[54,13.5]]', 'Ascensor', 'ASC-1', 15),
    ('stair','STAIRS',      '[[58,10.5],[62,10.5],[62,13.5],[58,13.5]]', 'Escalera A', 'ESC-A', 15)) AS e(k, kind, verts, label, link, z)
  JOIN practice.care_spaces cs ON cs.id = pg_temp.did('sp:BLD')
ON CONFLICT (id) DO NOTHING;

INSERT INTO practice.plan_elements (id, tenant_id, floor_plan_id, kind, vertices, label, z_order, created_at, updated_at)
SELECT pg_temp.did('north:' || p.code), cs.tenant_id, pg_temp.did('plan:' || p.code), 'ANNOTATION', '[[61,24]]'::jsonb, 'N ↑', 60, now(), now()
  FROM (VALUES ('PB'), ('P1'), ('CP')) AS p(code)
  JOIN practice.care_spaces cs ON cs.id = pg_temp.did('sp:BLD')
ON CONFLICT (id) DO NOTHING;
-- (en el campus la anotación cae dentro de los 100 × 70 m del lienzo: 61,24 está dentro)

INSERT INTO practice.plan_elements (id, tenant_id, floor_plan_id, kind, vertices, label, z_order, created_at, updated_at)
SELECT pg_temp.did('road'), cs.tenant_id, pg_temp.did('plan:CP'), 'CIRCULATION',
       '[[0,44],[100,44],[100,48],[0,48]]'::jsonb, 'Calle de acceso', 5, now(), now()
  FROM practice.care_spaces cs WHERE cs.id = pg_temp.did('sp:BLD')
ON CONFLICT (id) DO NOTHING;

-- Umbral de demostración del área (dato de la sede, no una norma).
INSERT INTO practice.practice_settings (id, practice_id, setting_key, value_json, created_at, updated_at)
SELECT pg_temp.did('setting:area-tol'), ps.practice_id, 'infra.plan.area_tolerance_pct', '10'::jsonb, now(), now()
  FROM practice.practice_sites ps
 WHERE ps.id = current_setting('plano.site_id')::uuid
   AND NOT EXISTS (SELECT 1 FROM practice.practice_settings s WHERE s.practice_id = ps.practice_id AND s.setting_key = 'infra.plan.area_tolerance_pct')
ON CONFLICT (id) DO NOTHING;

-- ---------------------------------------------------------------- verificación
DO $$
DECLARE
    n_sp int; n_pl int; n_el int; n_err int;
BEGIN
    SELECT count(*) INTO n_sp FROM practice.care_spaces WHERE code LIKE 'PLANO-%' AND practice_site_id = current_setting('plano.site_id')::uuid;
    SELECT count(*) INTO n_pl FROM practice.space_placements WHERE floor_plan_id IN (pg_temp.did('plan:PB'), pg_temp.did('plan:P1'), pg_temp.did('plan:CP'));
    SELECT count(*) INTO n_el FROM practice.plan_elements WHERE floor_plan_id IN (pg_temp.did('plan:PB'), pg_temp.did('plan:P1'), pg_temp.did('plan:CP'));
    SELECT count(*) INTO n_err FROM (SELECT * FROM practice.plan_validate(pg_temp.did('plan:PB'))
                                     UNION ALL SELECT * FROM practice.plan_validate(pg_temp.did('plan:P1'))
                                     UNION ALL SELECT * FROM practice.plan_validate(pg_temp.did('plan:CP'))) v WHERE v.severity = 'ERROR';
    IF n_err > 0 THEN
        RAISE EXCEPTION 'plano demo: el plano cargado tiene % error(es) de validación', n_err;
    END IF;
    RAISE NOTICE 'plano demo: % espacios, % ubicaciones, % elementos, 0 errores de validación', n_sp, n_pl, n_el;
END $$;

COMMIT;
