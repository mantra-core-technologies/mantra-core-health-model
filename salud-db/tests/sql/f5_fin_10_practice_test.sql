-- ============================================================================
-- M-F5-fin · prueba de practice.care_space_category_periods contra Postgres real.
-- Requiere los patches …_f5_accounting, …_f5_billing y …_f5_practice aplicados. Todo ocurre
-- dentro de una transacción que termina en ROLLBACK. Cada «CASO OK» es una aserción.
-- ============================================================================
\set ON_ERROR_STOP on
BEGIN;
\ir f5_fin_00_fixture.sql

-- ------------------------------------------------------------ backfill (idéntico al del patch)
-- El patch sólo lo corre una vez sobre camas ya existentes; acá se reejecuta el mismo INSERT.
CREATE TEMP TABLE _backfill_sql AS SELECT $b$
INSERT INTO "practice"."care_space_category_periods"
       ("id", "tenant_id", "care_space_id", "bed_category_concept_id", "valid_from", "valid_to",
        "created_at", "updated_at", "created_by_user_id", "updated_by_user_id", "row_version")
SELECT gen_random_uuid(), cs."tenant_id", cs."id", cs."bed_category_concept_id", cs."created_at", NULL,
       now(), now(), NULL, NULL, 1
  FROM "practice"."care_spaces" cs
 WHERE cs."bed_category_concept_id" IS NOT NULL
   AND NOT EXISTS (SELECT 1 FROM "practice"."care_space_category_periods" p
                    WHERE p."care_space_id" = cs."id");
$b$ AS q;

DO $t$
DECLARE n integer; n2 integer;
BEGIN
    EXECUTE (SELECT q FROM _backfill_sql);
    SELECT count(*) INTO n FROM practice.care_space_category_periods;
    IF n <> 4 THEN RAISE EXCEPTION 'CASO FALLIDO [backfill: una fila por cama con categoría]: % filas (esperadas 4)', n; END IF;
    RAISE NOTICE 'CASO OK [backfill: una fila por cama con categoría (4 camas; el consultorio sin categoría no)] -> 4 filas';
    IF EXISTS (SELECT 1 FROM practice.care_space_category_periods p JOIN practice.care_spaces c ON c.id = p.care_space_id
                WHERE p.valid_from <> c.created_at OR p.valid_to IS NOT NULL OR p.bed_category_concept_id <> c.bed_category_concept_id) THEN
        RAISE EXCEPTION 'CASO FALLIDO [backfill: períodos abiertos desde created_at con la categoría actual]';
    END IF;
    RAISE NOTICE 'CASO OK [backfill: períodos abiertos desde created_at con la categoría actual] -> éxito';
    EXECUTE (SELECT q FROM _backfill_sql);
    SELECT count(*) INTO n2 FROM practice.care_space_category_periods;
    IF n2 <> 4 THEN RAISE EXCEPTION 'CASO FALLIDO [backfill idempotente]: % filas tras reejecutar', n2; END IF;
    RAISE NOTICE 'CASO OK [backfill idempotente: reejecutarlo no duplica] -> 4 filas';
END $t$;

-- ------------------------------------------------------------ vigencias
SELECT pg_temp.caso('período que solapa al abierto de la misma cama',
  $q$INSERT INTO practice.care_space_category_periods (id, tenant_id, care_space_id, bed_category_concept_id, valid_from, valid_to, created_at, updated_at, row_version)
     VALUES (gen_random_uuid(), 'a0000000-0000-4000-8000-000000000001', 'a1300000-0000-4000-8000-000000000001', 'c0000000-0000-4000-8000-000000000002', '2026-06-01 00:00+00', NULL, now(), now(), 1)$q$,
  '23P01');

SELECT pg_temp.caso('cerrar el período abierto (valid_to NULL -> valor)',
  $q$UPDATE practice.care_space_category_periods SET valid_to = '2026-10-28 10:00+00', updated_at = now(), row_version = row_version + 1
      WHERE care_space_id = 'a1300000-0000-4000-8000-000000000001'$q$);

SELECT pg_temp.caso('abrir el período siguiente justo donde cerró el anterior ([) adyacentes)',
  $q$INSERT INTO practice.care_space_category_periods (id, tenant_id, care_space_id, bed_category_concept_id, valid_from, valid_to, created_at, updated_at, row_version)
     VALUES ('d0000000-0000-4000-8000-000000000001', 'a0000000-0000-4000-8000-000000000001', 'a1300000-0000-4000-8000-000000000001', 'c0000000-0000-4000-8000-000000000003', '2026-10-28 10:00+00', NULL, now(), now(), 1)$q$);

DO $t$
DECLARE c uuid;
BEGIN
    -- categoría vigente en cada instante: antes del cambio = compartida, desde el cambio = privada
    SELECT bed_category_concept_id INTO c FROM practice.care_space_category_periods
     WHERE care_space_id = 'a1300000-0000-4000-8000-000000000001' AND valid_from <= '2026-10-28 09:59:59+00' AND (valid_to IS NULL OR '2026-10-28 09:59:59+00' < valid_to);
    IF c <> 'c0000000-0000-4000-8000-000000000001' THEN RAISE EXCEPTION 'CASO FALLIDO [categoría en M anterior al cambio]: %', c; END IF;
    SELECT bed_category_concept_id INTO c FROM practice.care_space_category_periods
     WHERE care_space_id = 'a1300000-0000-4000-8000-000000000001' AND valid_from <= '2026-10-28 10:00:00+00' AND (valid_to IS NULL OR '2026-10-28 10:00:00+00' < valid_to);
    IF c <> 'c0000000-0000-4000-8000-000000000003' THEN RAISE EXCEPTION 'CASO FALLIDO [categoría en el instante exacto del cambio]: %', c; END IF;
    RAISE NOTICE 'CASO OK [la categoría vigente en un instante es una sola, y el cambio rige desde su instante exacto] -> éxito';
END $t$;

SELECT pg_temp.caso('valid_to <= valid_from',
  $q$INSERT INTO practice.care_space_category_periods (id, tenant_id, care_space_id, bed_category_concept_id, valid_from, valid_to, created_at, updated_at, row_version)
     VALUES (gen_random_uuid(), 'a0000000-0000-4000-8000-000000000001', 'a1300000-0000-4000-8000-000000000002', 'c0000000-0000-4000-8000-000000000001', '2027-01-01 00:00+00', '2027-01-01 00:00+00', now(), now(), 1)$q$,
  '23514');

SELECT pg_temp.caso('período de una cama de OTRO tenant (FK compuesta tenant_id, care_space_id)',
  $q$INSERT INTO practice.care_space_category_periods (id, tenant_id, care_space_id, bed_category_concept_id, valid_from, valid_to, created_at, updated_at, row_version)
     VALUES (gen_random_uuid(), 'a0000000-0000-4000-8000-000000000001', 'b1300000-0000-4000-8000-000000000003', 'c0000000-0000-4000-8000-000000000001', '2025-01-01 00:00+00', '2025-06-01 00:00+00', now(), now(), 1)$q$,
  '23503');

SELECT pg_temp.caso('categoría que no es un concepto del catálogo',
  $q$INSERT INTO practice.care_space_category_periods (id, tenant_id, care_space_id, bed_category_concept_id, valid_from, valid_to, created_at, updated_at, row_version)
     VALUES (gen_random_uuid(), 'a0000000-0000-4000-8000-000000000001', 'a1300000-0000-4000-8000-000000000002', 'ffffffff-ffff-4fff-8fff-ffffffffffff', '2025-01-01 00:00+00', '2025-06-01 00:00+00', now(), now(), 1)$q$,
  '23503');

SELECT pg_temp.caso('reescribir la categoría de un período (no se permite: cerrar y abrir otro)',
  $q$UPDATE practice.care_space_category_periods SET bed_category_concept_id = 'c0000000-0000-4000-8000-000000000002'
      WHERE id = 'd0000000-0000-4000-8000-000000000001'$q$,
  '23001');

SELECT pg_temp.caso('mover valid_from de un período',
  $q$UPDATE practice.care_space_category_periods SET valid_from = '2026-01-01 00:00+00'
      WHERE id = 'd0000000-0000-4000-8000-000000000001'$q$,
  '23001');

SELECT pg_temp.caso('reabrir/reescribir un período ya cerrado',
  $q$UPDATE practice.care_space_category_periods SET valid_to = NULL
      WHERE care_space_id = 'a1300000-0000-4000-8000-000000000001' AND valid_to IS NOT NULL$q$,
  '23001');

SELECT pg_temp.caso('borrar un período',
  $q$DELETE FROM practice.care_space_category_periods WHERE id = 'd0000000-0000-4000-8000-000000000001'$q$,
  '23001');

SELECT pg_temp.caso('cerrar un período abierto con valid_to <= valid_from',
  $q$UPDATE practice.care_space_category_periods SET valid_to = '2026-10-28 10:00+00'
      WHERE id = 'd0000000-0000-4000-8000-000000000001'$q$,
  '23514');

-- ------------------------------------------------------------ RLS (rol de aplicación, sin BYPASSRLS)
DO $t$
DECLARE n_a integer; n_b integer; n_none integer;
BEGIN
    SET LOCAL ROLE mantra_app;
    SET LOCAL app.system_context = 'false';
    SET LOCAL app.current_tenant_id = 'a0000000-0000-4000-8000-000000000001';
    SELECT count(*) INTO n_a FROM practice.care_space_category_periods;
    SET LOCAL app.current_tenant_id = 'b0000000-0000-4000-8000-000000000001';
    SELECT count(*) INTO n_b FROM practice.care_space_category_periods;
    SET LOCAL app.current_tenant_id = '';
    SELECT count(*) INTO n_none FROM practice.care_space_category_periods;
    RESET ROLE;
    IF n_a <> 4 OR n_b <> 1 OR n_none <> 0 THEN
        RAISE EXCEPTION 'CASO FALLIDO [RLS lectura]: A ve % (4), B ve % (1), sin tenant ve % (0)', n_a, n_b, n_none;
    END IF;
    RAISE NOTICE 'CASO OK [RLS: el tenant A ve sus 4 períodos, el B su 1, sin tenant fija ninguno] -> éxito';
END $t$;

DO $t$
DECLARE sqlstate_obt text := NULL;
BEGIN
    SET LOCAL ROLE mantra_app;
    SET LOCAL app.system_context = 'false';
    SET LOCAL app.current_tenant_id = 'a0000000-0000-4000-8000-000000000001';
    BEGIN
        -- tenant A intenta escribir un período con tenant_id de B
        INSERT INTO practice.care_space_category_periods (id, tenant_id, care_space_id, bed_category_concept_id, valid_from, created_at, updated_at, row_version)
        VALUES (gen_random_uuid(), 'b0000000-0000-4000-8000-000000000001', 'b1300000-0000-4000-8000-000000000003', 'c0000000-0000-4000-8000-000000000001', '2028-01-01 00:00+00', now(), now(), 1);
    EXCEPTION WHEN OTHERS THEN sqlstate_obt := SQLSTATE;
    END;
    RESET ROLE;
    IF sqlstate_obt IS DISTINCT FROM '42501' THEN RAISE EXCEPTION 'CASO FALLIDO [RLS escritura cruzada]: SQLSTATE=%', coalesce(sqlstate_obt, 'éxito'); END IF;
    RAISE NOTICE 'CASO OK [RLS: el tenant A no puede escribir un período con tenant_id de B] -> 42501';
END $t$;

DO $t$
DECLARE sqlstate_obt text := NULL;
BEGIN
    SET LOCAL ROLE mantra_app;
    SET LOCAL app.system_context = 'false';
    SET LOCAL app.current_tenant_id = 'a0000000-0000-4000-8000-000000000001';
    BEGIN
        DELETE FROM practice.care_space_category_periods WHERE id = 'd0000000-0000-4000-8000-000000000001';
    EXCEPTION WHEN OTHERS THEN sqlstate_obt := SQLSTATE;
    END;
    RESET ROLE;
    IF sqlstate_obt IS DISTINCT FROM '42501' THEN RAISE EXCEPTION 'CASO FALLIDO [mantra_app sin DELETE]: SQLSTATE=%', coalesce(sqlstate_obt, 'éxito'); END IF;
    RAISE NOTICE 'CASO OK [mantra_app no tiene privilegio de DELETE sobre los períodos] -> 42501';
END $t$;

-- ------------------------------------------------------------ el rol de aplicación opera su tenant (trigger de guarda con RLS)
DO $t$
DECLARE n integer;
BEGIN
    SET LOCAL ROLE mantra_app;
    SET LOCAL app.system_context = 'false';
    SET LOCAL app.current_tenant_id = 'a0000000-0000-4000-8000-000000000001';
    -- cambio de categoría de la cama UCI-1 como lo hace PATCH /care-spaces/:id: cerrar y abrir en la misma transacción
    UPDATE practice.care_space_category_periods SET valid_to = '2026-12-31 12:00+00', updated_at = now(), row_version = row_version + 1
     WHERE care_space_id = 'a1300000-0000-4000-8000-000000000002' AND valid_to IS NULL;
    INSERT INTO practice.care_space_category_periods (id, tenant_id, care_space_id, bed_category_concept_id, valid_from, created_at, updated_at, row_version)
    VALUES (gen_random_uuid(), 'a0000000-0000-4000-8000-000000000001', 'a1300000-0000-4000-8000-000000000002', 'c0000000-0000-4000-8000-000000000003', '2026-12-31 12:00+00', now(), now(), 1);
    SELECT count(*) INTO n FROM practice.care_space_category_periods WHERE care_space_id = 'a1300000-0000-4000-8000-000000000002';
    RESET ROLE;
    IF n <> 2 THEN RAISE EXCEPTION 'CASO FALLIDO [mantra_app: cerrar y abrir período]: % períodos', n; END IF;
    RAISE NOTICE 'CASO OK [mantra_app con RLS: cierra el período vigente y abre el siguiente en la misma transacción] -> 2 períodos';
END $t$;

ROLLBACK;
