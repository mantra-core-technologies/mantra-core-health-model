-- ============================================================================
-- SALUD · patch infraestructura hospitalaria F4 · recurso agendable ligado a espacio (scheduling)
-- Fecha: 2026-10-29 · Contrato: SALUD/Arquitectura/infraestructura-hospitalaria/
--   CONTRATO-F2-F5.md §F4.1 «R0 — recurso agendable ligado a espacio» (repositorio de documentación)
-- Se aplica DESPUÉS de 2026-10-29_infraestructura_f1.sql y …_f1b_seguridad.sql, y ANTES de
-- 2026-10-29_infraestructura_f4_periop.sql (que referencia lo que se crea acá). Idempotente
-- (ADD COLUMN IF NOT EXISTS / CREATE … IF NOT EXISTS / FK con `duplicate_object`): se puede aplicar
-- N veces; la segunda pasada no cambia nada.
--
-- Lo que sí expresan los .puml (columna, índices, FK simple, CHECK) sale de gen_ddl.py /
-- gen_integrity.py (SQL/41_scheduling) y se copió de ahí; lo que el generador no sabe expresar
-- (FK compuesta por tenant, backfill, comprobaciones previas) va solo acá. gen_apply.py no escanea
-- SQL/patches/: este archivo no entra en apply_all.sql.
--
-- QUÉ HACE (scheduling.schedulable_resources, INV-40: el recurso ROOM tiene FK real al espacio).
--   1. care_space_id uuid NULL → practice.care_spaces, más FK compuesta (tenant_id, care_space_id)
--      → care_spaces (tenant_id, id): un recurso no puede apuntar a un espacio de otro tenant.
--   2. Backfill: las filas con resource_ref_type IN ('care_spaces', 'practice.care_spaces') cuya
--      resource_ref_id existe en care_spaces DEL MISMO TENANT pasan a care_space_id = resource_ref_id y
--      resource_ref_type canónico 'care_spaces'. Las que no resuelven (espacio inexistente o de otro
--      tenant) se LISTAN con RAISE NOTICE y no se tocan. Las demás filas (profesionales, equipos) no
--      se tocan.
--   3. ux_schedulable_resources_care_space_active: a lo sumo UN recurso ACTIVO por espacio (UUID
--      literal de state:active, el estado con que la API crea los recursos). Si el backfill produce
--      dos activos para un mismo espacio el patch ABORTA listándolos (no desactiva ninguno).
--   4. ck_schedulable_resources_care_space_ref (idéntico al de SQL/41_scheduling/05_constraints.sql).
--      Si quedaron filas heredadas sin resolver cuyo resource_ref_type es exactamente 'care_spaces'
--      (incumplen el CHECK por no tener care_space_id) el CHECK se crea NOT VALID —rige para toda
--      fila nueva o modificada— y se avisa; sin ellas se valida.
--   5. ux_schedulable_resources_tenant_id_id: destino de la FK compuesta (tenant_id,
--      schedulable_resource_id) de procedure_cases (patch …_f4_periop).
--
-- PRECONDICIONES (abortan sin tocar nada; el BEGIN hace rollback de todo):
--   - practice.care_spaces sin tenant_id / sin ux_care_spaces_tenant_id_id (falta aplicar F1 y F1b).
--   - dos o más recursos ACTIVOS apuntando al mismo espacio tras el backfill.
-- ============================================================================

BEGIN;

-- Igual que F1: el backfill y las comprobaciones leen tablas con RLS forzada.
SET LOCAL app.system_context = 'true';

-- ------------------------------------------------------------- 0. precondiciones de orden
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns
                    WHERE table_schema = 'practice' AND table_name = 'care_spaces' AND column_name = 'tenant_id')
       OR NOT EXISTS (SELECT 1 FROM pg_indexes
                       WHERE schemaname = 'practice' AND indexname = 'ux_care_spaces_tenant_id_id') THEN
        RAISE EXCEPTION 'F4 scheduling: falta practice.care_spaces.tenant_id o ux_care_spaces_tenant_id_id. Aplicar antes 2026-10-29_infraestructura_f1.sql y 2026-10-29_infraestructura_f1b_seguridad.sql.'
            USING ERRCODE = 'undefined_table';
    END IF;
END $$;

-- ------------------------------------------------------------- 1. columna (copiada de 02_tables)
ALTER TABLE "scheduling"."schedulable_resources"
    ADD COLUMN IF NOT EXISTS "care_space_id" uuid;

-- ------------------------------------------------------------- 2. índice (tenant_id, id)
-- (el único parcial va después del backfill: puede fallar si hay dos activos por espacio)
CREATE UNIQUE INDEX IF NOT EXISTS "ux_schedulable_resources_tenant_id_id" ON "scheduling"."schedulable_resources" ("tenant_id", "id");

-- ------------------------------------------------------------- 3. backfill
-- 3a. Las filas que apuntan a un espacio real del mismo tenant: FK real + tipo canónico.
UPDATE "scheduling"."schedulable_resources" r
   SET "care_space_id"      = r."resource_ref_id",
       "resource_ref_type"  = 'care_spaces'
  FROM "practice"."care_spaces" cs
 WHERE r."care_space_id" IS NULL
   AND r."resource_ref_type" IN ('care_spaces', 'practice.care_spaces')
   AND cs."id" = r."resource_ref_id"
   AND cs."tenant_id" = r."tenant_id";

-- 3b. Lo que NO resuelve se lista (RES_ROOM o tipo de referencia a espacios), sin tocarlo.
DO $$
DECLARE
    r record;
    n integer := 0;
BEGIN
    FOR r IN
        SELECT sr."id", sr."tenant_id", sr."name", sr."resource_ref_type", sr."resource_ref_id",
               (SELECT cs."tenant_id" FROM "practice"."care_spaces" cs WHERE cs."id" = sr."resource_ref_id") AS espacio_tenant
          FROM "scheduling"."schedulable_resources" sr
         WHERE sr."care_space_id" IS NULL
           AND (sr."resource_ref_type" IN ('care_spaces', 'practice.care_spaces')
                -- deterministicId('scheduling:resource-type:room') = RES_ROOM
                OR sr."resource_type_concept_id" = '2e3d1a52-5455-5714-a4f2-db0879616235')
         ORDER BY sr."id"
    LOOP
        n := n + 1;
        RAISE NOTICE 'F4 scheduling: recurso % (%, tenant %) no se liga a un espacio: resource_ref_type=%, resource_ref_id=% (%). Queda sin tocar; revisar a mano.',
            r."id", r."name", r."tenant_id", r."resource_ref_type", r."resource_ref_id",
            CASE WHEN r.espacio_tenant IS NULL THEN 'el espacio no existe'
                 WHEN r.espacio_tenant <> r."tenant_id" THEN 'el espacio es de otro tenant'
                 ELSE 'tipo de referencia que no es de espacios' END;
    END LOOP;
    IF n > 0 THEN
        RAISE NOTICE 'F4 scheduling: % recurso(s) ROOM / de espacios quedan sin FK real (ver avisos de arriba).', n;
    END IF;
END $$;

-- ------------------------------------------------------------- 4. precondición del único parcial
DO $$
DECLARE
    n_dup   integer;
    detalle text;
BEGIN
    SELECT count(*), string_agg(format('espacio %s: recursos %s', "care_space_id", ids), '; ')
      INTO n_dup, detalle
      FROM (SELECT "care_space_id", string_agg("id"::text, ', ' ORDER BY "id") AS ids
              FROM "scheduling"."schedulable_resources"
             WHERE "care_space_id" IS NOT NULL
               -- deterministicId('state:active') = CONCEPTS.STATE_ACTIVE
               AND "state_concept_id" = '38a1d301-f40d-5b17-a695-5e6d605f8b19'
             GROUP BY "care_space_id" HAVING count(*) > 1) d;
    IF n_dup > 0 THEN
        RAISE EXCEPTION 'F4 scheduling: % espacio(s) con más de un recurso agendable ACTIVO (%). No se desactiva ninguno solo: dejar uno activo por espacio y volver a aplicar.', n_dup, detalle
            USING ERRCODE = 'unique_violation';
    END IF;
END $$;

-- ------------------------------------------------------------- 5. índices (copiados de 04_indexes)
CREATE INDEX IF NOT EXISTS "ix_schedulable_resources_care_space_id" ON "scheduling"."schedulable_resources" ("care_space_id");

CREATE UNIQUE INDEX IF NOT EXISTS "ux_schedulable_resources_care_space_active" ON "scheduling"."schedulable_resources" ("care_space_id") WHERE care_space_id IS NOT NULL AND state_concept_id = '38a1d301-f40d-5b17-a695-5e6d605f8b19';

-- ------------------------------------------------------------- 6. FK simple (copiada de 90_fk_deferred)
-- destino: practice.care_spaces (requiere schema practice)
DO $$ BEGIN
    ALTER TABLE "scheduling"."schedulable_resources"
        ADD CONSTRAINT "fk_schedulable_resources_care_space_id" FOREIGN KEY ("care_space_id")
        REFERENCES "practice"."care_spaces" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- 6b. FK compuesta (escrita a mano, como las de F1b): MATCH SIMPLE, con care_space_id NULL no exige nada.
DO $$ BEGIN
    ALTER TABLE "scheduling"."schedulable_resources"
        ADD CONSTRAINT "fk_schedulable_resources_tenant_care_space" FOREIGN KEY ("tenant_id", "care_space_id")
        REFERENCES "practice"."care_spaces" ("tenant_id", "id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- ------------------------------------------------------------- 7. CHECK (misma expresión que 05_constraints)
-- care_space_id existe si y sólo si el recurso apunta a la tabla care_spaces, y entonces ES
-- resource_ref_id. (El contrato lo escribe `ref_type <> 'care_spaces' OR care_space_id =
-- resource_ref_id`, que con care_space_id NULL da NULL y pasa; acá se cierra el hueco.)
DO $$
DECLARE
    n_malas integer;
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_constraint
                    WHERE conrelid = 'scheduling.schedulable_resources'::regclass
                      AND conname = 'ck_schedulable_resources_care_space_ref') THEN
        ALTER TABLE "scheduling"."schedulable_resources"
            ADD CONSTRAINT "ck_schedulable_resources_care_space_ref"
            CHECK (("resource_ref_type" = 'care_spaces') = ("care_space_id" IS NOT NULL) AND ("care_space_id" IS NULL OR "care_space_id" = "resource_ref_id"))
            NOT VALID;
    END IF;
    IF NOT (SELECT convalidated FROM pg_constraint
             WHERE conrelid = 'scheduling.schedulable_resources'::regclass
               AND conname = 'ck_schedulable_resources_care_space_ref') THEN
        SELECT count(*) INTO n_malas
          FROM "scheduling"."schedulable_resources"
         WHERE NOT (("resource_ref_type" = 'care_spaces') = ("care_space_id" IS NOT NULL)
                    AND ("care_space_id" IS NULL OR "care_space_id" = "resource_ref_id"));
        IF n_malas = 0 THEN
            ALTER TABLE "scheduling"."schedulable_resources"
                VALIDATE CONSTRAINT "ck_schedulable_resources_care_space_ref";
        ELSE
            RAISE NOTICE 'F4 scheduling: ck_schedulable_resources_care_space_ref queda NOT VALID: % fila(s) heredada(s) con resource_ref_type=''care_spaces'' sin espacio resoluble (ver avisos). Rige para toda fila nueva o modificada; al corregirlas, VALIDATE CONSTRAINT.', n_malas;
        END IF;
    END IF;
END $$;

-- ------------------------------------------------------------- 8. verificación
DO $$
DECLARE
    n_col integer;
    n_idx integer;
    n_fk  integer;
    n_ck  integer;
BEGIN
    SELECT count(*) INTO n_col FROM information_schema.columns
     WHERE table_schema = 'scheduling' AND table_name = 'schedulable_resources' AND column_name = 'care_space_id';

    SELECT count(*) INTO n_idx FROM pg_indexes
     WHERE schemaname = 'scheduling'
       AND indexname IN ('ix_schedulable_resources_care_space_id', 'ux_schedulable_resources_tenant_id_id',
                         'ux_schedulable_resources_care_space_active');

    SELECT count(*) INTO n_fk FROM pg_constraint
     WHERE contype = 'f' AND convalidated
       AND conrelid = 'scheduling.schedulable_resources'::regclass
       AND conname IN ('fk_schedulable_resources_care_space_id', 'fk_schedulable_resources_tenant_care_space');

    SELECT count(*) INTO n_ck FROM pg_constraint
     WHERE contype = 'c' AND conrelid = 'scheduling.schedulable_resources'::regclass
       AND conname = 'ck_schedulable_resources_care_space_ref';

    IF n_col <> 1 OR n_idx <> 3 OR n_fk <> 2 OR n_ck <> 1 THEN
        RAISE EXCEPTION 'F4 scheduling incompleto: columna=% (1), índices=% (3), FK=% (2), CHECK=% (1)',
            n_col, n_idx, n_fk, n_ck;
    END IF;

    RAISE NOTICE 'F4 scheduling aplicado: schedulable_resources.care_space_id con FK real y compuesta por tenant, único parcial por espacio activo y CHECK de coherencia con resource_ref_id.';
END $$;

COMMIT;
