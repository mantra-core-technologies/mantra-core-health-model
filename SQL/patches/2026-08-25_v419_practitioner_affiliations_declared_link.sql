-- ============================================================================
-- SALUD · patch v4.1.9 (profiles.practitioner_affiliations · vínculo declarado,
-- establecimiento del padrón, motivo de la decisión y unicidad parcial)
-- sobre una BD viva
-- Fecha: 2026-08-25
-- Idempotente (ADD COLUMN / CREATE INDEX IF NOT EXISTS · DROP INDEX IF EXISTS ·
-- duplicate_object en la FK · backfill acotado por estado de origen)
--
-- Contexto: gen_ddl.py ya emite estas columnas e índices en SQL/05_profiles/
-- desde que el .puml del módulo 05 los declara, así que en un rebuild desde cero
-- este patch NO hace falta. Existe únicamente para una base ya aplicada y
-- poblada. gen_apply.py no escanea SQL/patches/ (solo directorios NN_schema),
-- así que no entra en apply_all.sql.
--
-- QUÉ CIERRA — H-3 de `SALUD/Arquitectura/alovida-prompts-correcciones.md`: el
-- vínculo médico-organización era texto libre sin ciclo de aprobación. Decisión
-- de producto del 2026-08-25:
--
--   * `health_facility_concept_id` (nullable, FK a terminology.catalog_concepts):
--     la institución como concepto de VS_BO_HEALTH_FACILITY (503 establecimientos
--     del padrón del SEDES). Ese conjunto lo publica la API al arrancar
--     (`src/common/seed/bolivia-facilities-seed.service.ts`), NO el paquete del
--     modelo: un solo dueño, como VS_BO_OCCUPATION. Convive con
--     `organization_name` -el padrón cubre Santa Cruz- y NO se migra ningún
--     nombre a concepto: se probó contra las filas vivas y «Hospital Obrero N.º 1»
--     da nueve candidatos, con dos de las tres filas en La Paz. Se llena hacia
--     adelante, cuando el profesional elige de la lista.
--   * `decision_reason_text` (nullable): por qué se rechazó o se revocó, escrito
--     por quien decidió y leído por el profesional. Hoy el motivo del rechazo
--     viaja sólo al registro estructurado y se pierde. Cubre rechazo y revocación
--     con una sola columna, para no renombrarla cuando exista el endpoint de
--     revocación. Texto libre a propósito: categorizar motivos que ninguna
--     organización pidió todavía sería inventarlos.
--   * `status_concept_id` pasa de «estado del registro» (ACTIVE/RETRACTED) a
--     «estado de aprobación» con cinco valores: PENDING · DECLARED · APPROVED ·
--     REJECTED · REVOKED (conjunto dinámico `practitioner-affiliation-status`,
--     dueño la API). Regla: aprobado sólo si alguien aprobó; pendiente si hay a
--     quién preguntarle (OWNER/ADMIN en la organización); declarado si no hay
--     nadie -sin ese estado, los médicos de hospitales públicos, que nunca van
--     a registrarse, quedaban bloqueados para siempre-.
--   * Unicidad: `uq_practitioner_affiliation_same` (único total por
--     organization_name) se reemplaza por DOS únicos PARCIALES. Postgres
--     considera cada NULL distinto de los demás, así que un único total que
--     incluyera la columna del establecimiento no acotaría nada de las filas de
--     texto libre (probado: admitió tres duplicados). Con establecimiento manda
--     el concepto; sin él, el nombre. Los predicados son complementarios.
--
-- MIGRACIÓN SEGURA: al aplicar este patch todas las filas tienen
-- `health_facility_concept_id` NULL, así que el índice parcial por nombre es
-- equivalente al total que reemplaza y no puede fallar por datos existentes.
-- ORDEN: primero se crean los nuevos y después se borra el viejo - al revés
-- dejaría una ventana en la que dos altas concurrentes podrían duplicar (misma
-- razón que `2026-08-23_v418_diagnostic_units_unicidad_tenant_codigo.sql`).
--
-- BACKFILL (sección C) - los conceptos nuevos los siembra la API al arrancar
-- (`SeedBootstrapService`, paso «catálogo de conceptos»), NO este archivo ni
-- gen_seeds.py. Por eso el patch se corre en DOS pasadas sobre una base con
-- filas:
--   1.ª  antes de arrancar la API con el código de v4.1.9 → aplica A y B; C
--        aborta con un mensaje claro si hay filas por migrar, y D se omite sola.
--   2.ª  después de arrancarla una vez → A y B no hacen nada, C migra, D
--        reconcilia el conjunto y E comprueba.
-- Correlo con `psql -v ON_ERROR_STOP=1 -f`. Con `rebuild_stack.py --yes` nada de
-- esto hace falta: la tabla nace vacía y los conjuntos se siembran de cero.
--
-- Mapeo del backfill, y por qué NO es «ACTIVE → APPROVED»: las filas que hoy
-- están en `profiles:AFFILIATION_ACTIVE` las aprobó `estadoInicial()` sin que
-- nadie de la organización las mirara. Escribir APPROVED fabricaría un hecho que
-- no ocurrió; van a DECLARED, que es exactamente lo que son.
--   profiles:AFFILIATION_ACTIVE            → profiles:AFFILIATION_DECLARED
--   state:pending (CONCEPTS.STATE_PENDING) → profiles:AFFILIATION_PENDING
--   profiles:AFFILIATION_RETRACTED         → profiles:AFFILIATION_REJECTED
--
-- ORDEN DE DESPLIEGUE: la 2.ª pasada va DESPUÉS del cambio de la API que repunta
-- `ESTADO_DEL_VINCULO` (carril MAC-VINCULO). Antes de eso, `visiblesDeTerceros`
-- sólo muestra AFFILIATION_ACTIVE y las filas migradas desaparecerían del perfil
-- público hasta que ese cambio se despliegue.
--
-- Los uuid de abajo son UUIDv5 deterministas (RFC 4122 §4.3) sobre el namespace
-- 3f2b6c14-9d5e-5a41-b7c2-0a1e9f4d8b60 de `src/common/constants/concepts.ts`, y
-- se reproducen con `uuid.uuid5(...)` de Python; el mismo mecanismo con el que se
-- escribió el predicado de `ux_authentication_credentials_live_password_subject`
-- en v4.0.9. Cada uso los verifica además por `code` contra
-- terminology.catalog_concepts, así que un id equivocado aborta en vez de migrar
-- a un concepto que no es.
--
-- Este archivo es la salida de gen_ddl.py 05 (secciones A y B), no DDL escrito a
-- mano: columnas e índices se declaran en
-- `Mantra Core Health Context/modules/diagram_05_profiles.puml` (entidad
-- `practitioner_affiliations` + su bloque <<INDEX_SET>>) y el destino de la FK en
-- `SALUD/FK/FK profiles.practitioner_affiliations.health_facility_concept_id.md`.
--
-- Delta esperado sobre los conteos canónicos: +0 tablas · +1 FK · +2 índices
-- (+1 IX, +2 UX, -1 UK).
-- ============================================================================

-- ---------------------------------------------------------------------------
-- A · Columnas, índice de la FK y FK
--     (de SQL/05_profiles/02_tables.sql, 04_indexes.sql y 90_fk_deferred.sql)
-- ---------------------------------------------------------------------------

ALTER TABLE "profiles"."practitioner_affiliations"
    ADD COLUMN IF NOT EXISTS "health_facility_concept_id" uuid;

ALTER TABLE "profiles"."practitioner_affiliations"
    ADD COLUMN IF NOT EXISTS "decision_reason_text" varchar;

CREATE INDEX IF NOT EXISTS "ix_practitioner_affiliations_health_facility_concept_id"
    ON "profiles"."practitioner_affiliations" ("health_facility_concept_id");

-- destino: terminology.catalog_concepts (requiere schema terminology)
DO $$ BEGIN
    ALTER TABLE "profiles"."practitioner_affiliations"
        ADD CONSTRAINT "fk_practitioner_affiliations_health_facility_concept_id" FOREIGN KEY ("health_facility_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- ---------------------------------------------------------------------------
-- B · Unicidad: los dos parciales nuevos primero, el total viejo después.
-- ---------------------------------------------------------------------------

BEGIN;

CREATE UNIQUE INDEX IF NOT EXISTS "ux_practitioner_affiliations_same_health_facility"
    ON "profiles"."practitioner_affiliations" ("practitioner_profile_id", "health_facility_concept_id", "role_title", "start_date")
    WHERE health_facility_concept_id IS NOT NULL;

CREATE UNIQUE INDEX IF NOT EXISTS "ux_practitioner_affiliations_same_organization_name"
    ON "profiles"."practitioner_affiliations" ("practitioner_profile_id", "organization_name", "role_title", "start_date")
    WHERE health_facility_concept_id IS NULL;

DROP INDEX IF EXISTS "profiles"."uq_practitioner_affiliation_same";

COMMIT;

-- ---------------------------------------------------------------------------
-- C · Backfill del estado. Idempotente: la segunda corrida no encuentra filas.
-- ---------------------------------------------------------------------------

DO $$
DECLARE
    c_active    CONSTANT uuid := 'f581c24c-71bd-51b7-928b-7ea67da84baa'; -- profiles:AFFILIATION_ACTIVE
    c_retracted CONSTANT uuid := 'beb9a542-572e-5692-bf06-10d6fc27a778'; -- profiles:AFFILIATION_RETRACTED
    c_state_pnd CONSTANT uuid := '2e38dae4-c0c2-52ff-b1c9-a954ff880a38'; -- state:pending (code PENDING)
    c_pending   CONSTANT uuid := 'b017c79f-b711-573a-ae7a-2436e2cba511'; -- profiles:AFFILIATION_PENDING
    c_declared  CONSTANT uuid := 'f9c2cb64-5d75-5237-bd64-4d75fa7f94f7'; -- profiles:AFFILIATION_DECLARED
    c_rejected  CONSTANT uuid := '86da7e35-50ac-5d16-b7c2-d9277dcfdca0'; -- profiles:AFFILIATION_REJECTED
    n_legacy    integer;
    faltantes   text;
    n_upd       integer;
BEGIN
    SELECT count(*) INTO n_legacy
      FROM "profiles"."practitioner_affiliations"
     WHERE status_concept_id IN (c_active, c_retracted, c_state_pnd);

    IF n_legacy = 0 THEN
        RAISE NOTICE 'patch v4.1.9 · C: 0 filas en estados previos - nada que migrar';
        RETURN;
    END IF;

    -- Los tres destinos tienen que existir con su código esperado. Si no, la API
    -- todavía no arrancó con el código de v4.1.9 y migrar dejaría las filas
    -- apuntando a conceptos inexistentes.
    SELECT string_agg(e.code, ', ' ORDER BY e.code) INTO faltantes
      FROM (VALUES (c_pending,  'profiles:AFFILIATION_PENDING'),
                   (c_declared, 'profiles:AFFILIATION_DECLARED'),
                   (c_rejected, 'profiles:AFFILIATION_REJECTED')) AS e(id, code)
     WHERE NOT EXISTS (SELECT 1 FROM "terminology"."catalog_concepts" cc
                        WHERE cc.id = e.id AND cc.code = e.code);

    IF faltantes IS NOT NULL THEN
        RAISE EXCEPTION 'patch v4.1.9 · C: hay % filas por migrar y faltan los conceptos [%] en terminology.catalog_concepts. Los siembra la API al arrancar con el código de v4.1.9. Arrancala una vez y volvé a correr este patch: A y B ya quedaron aplicadas y son idempotentes.',
            n_legacy, faltantes;
    END IF;

    UPDATE "profiles"."practitioner_affiliations"
       SET status_concept_id = c_declared, updated_at = now()
     WHERE status_concept_id = c_active;
    GET DIAGNOSTICS n_upd = ROW_COUNT;
    RAISE NOTICE 'patch v4.1.9 · C: AFFILIATION_ACTIVE → DECLARED: % filas', n_upd;

    UPDATE "profiles"."practitioner_affiliations"
       SET status_concept_id = c_pending, updated_at = now()
     WHERE status_concept_id = c_state_pnd;
    GET DIAGNOSTICS n_upd = ROW_COUNT;
    RAISE NOTICE 'patch v4.1.9 · C: state:pending → PENDING: % filas', n_upd;

    UPDATE "profiles"."practitioner_affiliations"
       SET status_concept_id = c_rejected, updated_at = now()
     WHERE status_concept_id = c_retracted;
    GET DIAGNOSTICS n_upd = ROW_COUNT;
    RAISE NOTICE 'patch v4.1.9 · C: AFFILIATION_RETRACTED → REJECTED: % filas', n_upd;
END $$;

-- ---------------------------------------------------------------------------
-- D · La escalera de `tenant-verification-status` en una base YA sembrada.
--
-- `DynamicEnumSeedService.run()` inserta por id y no toca lo que ya existe: al
-- agregar los dos peldaños nuevos crea sus opciones y sus miembros, pero deja el
-- `ordinal` de los dos viejos como estaba -UNVERIFIED 0 y VERIFIED 1- así que
-- VERIFIED queda empatado con el peldaño «del padrón» y la escalera se ofrece
-- desordenada. Tampoco reescribe el `cache_token` de la versión publicada, que
-- es lo que le dice al cliente que el conjunto cambió.
--
-- El token no se puede predecir desde acá: los tokens de esta base no se
-- reproducen con la fórmula que hoy tiene el código (los escribió un build
-- anterior), así que esta sección escribe uno propio, determinista y derivado del
-- contenido. Cualquier valor distinto del anterior cumple su función, que es
-- invalidar la caché del cliente.
--
-- Sólo actúa cuando las cuatro opciones ya existen (o sea, tras el arranque de la
-- API con el código de v4.1.9). En un rebuild desde cero el seed las escribe bien
-- de entrada y esta sección no cambia nada.
-- ---------------------------------------------------------------------------

DO $$
DECLARE
    v_enum_version CONSTANT uuid := '0053a55d-2157-5965-b1ee-206c92c91696'; -- enumVersionId('tenant-verification-status')
    v_vs_version   CONSTANT uuid := 'f5aaea25-bfa3-5453-b27d-329f4d3eeb00'; -- valueSetVersionId('tenant-verification-status')
    escalera       CONSTANT uuid[] := ARRAY[
        'a6eb3028-c24e-5144-8565-3c70d03bfead'::uuid, -- directory:TENANT_UNVERIFIED
        'd4b76620-22a3-52ae-8e11-ed7315485dbd'::uuid, -- directory:TENANT_REGISTRY_LISTED
        'e81d654b-129c-595f-8bce-7c1886bbc9c1'::uuid, -- directory:TENANT_CLAIMED
        '205bce05-3eb5-5785-8aa0-6120227dc4a5'::uuid  -- directory:tenant-verification:verified
    ];
    token_nuevo    text;
    presentes      integer;
BEGIN
    SELECT count(*) INTO presentes
      FROM "system_context"."dynamic_enum_options"
     WHERE dynamic_enum_version_id = v_enum_version AND concept_id = ANY (escalera);

    IF presentes < 4 THEN
        RAISE NOTICE 'patch v4.1.9 · D: tenant-verification-status tiene %/4 opciones - la API todavía no sembró los peldaños nuevos; sección omitida (se completa al volver a correr el patch tras arrancarla)', presentes;
        RETURN;
    END IF;

    UPDATE "system_context"."dynamic_enum_options" o
       SET ordinal = x.ord - 1
      FROM unnest(escalera) WITH ORDINALITY AS x(concept_id, ord)
     WHERE o.dynamic_enum_version_id = v_enum_version
       AND o.concept_id = x.concept_id
       AND o.ordinal IS DISTINCT FROM x.ord - 1;

    UPDATE "terminology"."value_set_members" m
       SET ordinal = x.ord - 1, updated_at = now()
      FROM unnest(escalera) WITH ORDINALITY AS x(concept_id, ord)
     WHERE m.value_set_version_id = v_vs_version
       AND m.concept_id = x.concept_id
       AND m.ordinal IS DISTINCT FROM x.ord - 1;

    token_nuevo := left(md5('tenant-verification-status ' || array_to_string(escalera, ',')), 16);

    UPDATE "system_context"."dynamic_enum_versions"
       SET cache_token = token_nuevo
     WHERE id = v_enum_version AND cache_token IS DISTINCT FROM token_nuevo;

    RAISE NOTICE 'patch v4.1.9 · D: escalera reordenada (0..3) y cache_token = %', token_nuevo;
END $$;

-- ---------------------------------------------------------------------------
-- E · Comprobación: rompe si el esquema quedó a medias.
-- ---------------------------------------------------------------------------

DO $$
DECLARE
    faltantes text;
BEGIN
    SELECT string_agg(e.objeto, ', ' ORDER BY e.objeto) INTO faltantes
    FROM (VALUES
        ('columna practitioner_affiliations.health_facility_concept_id',
            EXISTS (SELECT 1 FROM information_schema.columns
                     WHERE table_schema = 'profiles' AND table_name = 'practitioner_affiliations'
                       AND column_name = 'health_facility_concept_id')),
        ('columna practitioner_affiliations.decision_reason_text',
            EXISTS (SELECT 1 FROM information_schema.columns
                     WHERE table_schema = 'profiles' AND table_name = 'practitioner_affiliations'
                       AND column_name = 'decision_reason_text')),
        ('índice ix_practitioner_affiliations_health_facility_concept_id',
            EXISTS (SELECT 1 FROM pg_indexes WHERE schemaname = 'profiles'
                       AND indexname = 'ix_practitioner_affiliations_health_facility_concept_id')),
        ('índice ux_practitioner_affiliations_same_health_facility',
            EXISTS (SELECT 1 FROM pg_indexes WHERE schemaname = 'profiles'
                       AND indexname = 'ux_practitioner_affiliations_same_health_facility')),
        ('índice ux_practitioner_affiliations_same_organization_name',
            EXISTS (SELECT 1 FROM pg_indexes WHERE schemaname = 'profiles'
                       AND indexname = 'ux_practitioner_affiliations_same_organization_name')),
        ('FK fk_practitioner_affiliations_health_facility_concept_id',
            EXISTS (SELECT 1 FROM pg_constraint
                     WHERE conname = 'fk_practitioner_affiliations_health_facility_concept_id'))
    ) AS e(objeto, existe)
    WHERE NOT e.existe;

    IF faltantes IS NOT NULL THEN
        RAISE EXCEPTION 'patch v4.1.9 incompleto - faltan: %', faltantes;
    END IF;

    IF EXISTS (SELECT 1 FROM pg_indexes WHERE schemaname = 'profiles'
                 AND indexname = 'uq_practitioner_affiliation_same') THEN
        RAISE EXCEPTION 'patch v4.1.9 incompleto - uq_practitioner_affiliation_same sigue existiendo';
    END IF;

    IF EXISTS (SELECT 1 FROM "profiles"."practitioner_affiliations"
                WHERE status_concept_id IN ('f581c24c-71bd-51b7-928b-7ea67da84baa',
                                            'beb9a542-572e-5692-bf06-10d6fc27a778',
                                            '2e38dae4-c0c2-52ff-b1c9-a954ff880a38')) THEN
        RAISE EXCEPTION 'patch v4.1.9 incompleto - quedan filas en estados previos (ACTIVE/RETRACTED/state:pending); corré la sección C tras arrancar la API con el código de v4.1.9';
    END IF;

    RAISE NOTICE 'patch v4.1.9 · E: esquema completo y sin filas en estados previos';
END $$;
