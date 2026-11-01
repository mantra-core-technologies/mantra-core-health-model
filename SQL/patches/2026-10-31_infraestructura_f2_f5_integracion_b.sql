-- ============================================================================
-- SALUD · patch de integración F2–F5 (b): puntos de toma sin lectura entre tenants
-- Fecha: 2026-10-31 · Contrato: SALUD/Arquitectura/infraestructura-hospitalaria/
--   CONTRATO-F2-F5.md §0.1 y §6.2 (el integrador del modelo) — repositorio de documentación
-- Idempotente (CREATE OR REPLACE / DROP TRIGGER IF EXISTS + CREATE). Se puede aplicar N veces.
-- Va DESPUÉS de 2026-10-31_infraestructura_f2_f5_integracion.sql (reemplaza dos de sus
-- funciones; no lo reescribe) y aborta con mensaje si falta.
--
-- Origen: revisión de seguridad del patch de integración. Las dos funciones de punto de toma
-- eran SECURITY DEFINER y leían practice.care_spaces sin RLS:
--   · cualquier tenant podía sondear espacios de otros tenants (un id ajeno pasaba o fallaba
--     según su sede) y autocompletar collection_site_id / suggested_practice_site_id con la
--     sede de un espacio ajeno, y
--   · los dos mensajes distintos («no existe» / «no es de la sede») eran un oráculo.
--
-- QUÉ CAMBIA.
--   1. diagnostics.specimen_collection_events_assert_collection_point() → SECURITY INVOKER.
--      Lee care_spaces bajo el RLS de quien escribe: un espacio que no ve se rechaza igual que
--      uno inexistente (23503), mismo criterio que trg_imaging_procedure_steps_room_tenant.
--      La sede sólo se autocompleta desde un espacio visible.
--   2. clinical.service_requests_assert_collection_point() sigue SECURITY DEFINER (el punto
--      puede ser de un ejecutor de otro tenant, que bajo RLS el que ordena no ve), pero la
--      búsqueda queda limitada a:
--        a. espacios del tenant que ordena (custodian_tenant_id), o
--        b. espacios de un tenant con una afiliación ACTIVA y vigente con el que ordena en
--           organization_extensions.organization_affiliations (en cualquiera de las dos
--           direcciones primary/participating; estado organization_extensions:AFFILIATION_ACTIVE
--           = a0586b44-2194-5341-87c9-901bf67d30d3, el que escribe UC-22-07 de la API;
--           valid_from <= now() < valid_to, NULL = abierto) y, si la orden fija
--           performer_tenant_id, ese tenant tiene que ser el ejecutor.
--      Vale también con app.system_context = 'true'.
--      Fuera de contexto SYSTEM, además, custodian_tenant_id tiene que ser
--      app.current_tenant_id: si no, el trigger (que corre antes del WITH CHECK del RLS)
--      sería un oráculo sobre los espacios del tenant que se pone de custodio.
--      El trigger se dispara también con UPDATE OF custodian_tenant_id, performer_tenant_id
--      (la regla depende de ellos).
--   3. Un único mensaje por trigger para todos los rechazos (inexistente, no visible, sin
--      relación, otra sede, custodio ajeno), sin DETAIL ni HINT. ERRCODE 23503.
--
-- ABORTA (RAISE EXCEPTION, sin cambios) si:
--   1. Falta el patch de integración (sus dos triggers de punto de toma).
--   2. Hay órdenes con un punto de toma que la regla nueva rechazaría (lista hasta 20).
--
-- DELTAS ESPERADOS (primera aplicación): funciones reemplazadas 2 (una pasa a INVOKER) ·
-- trigger trg_service_requests_collection_point recreado con 4 columnas en UPDATE OF.
-- ============================================================================

BEGIN;

SET LOCAL lock_timeout = '10s';

-- ------------------------------------------------------------- 0. precondiciones
DO $$
DECLARE
    n       integer;
    detalle text;
BEGIN
    SELECT count(*) INTO n FROM pg_trigger
     WHERE NOT tgisinternal
       AND tgname IN ('trg_service_requests_collection_point', 'trg_specimen_collection_events_collection_point');
    IF n <> 2 OR to_regclass('organization_extensions.organization_affiliations') IS NULL THEN
        RAISE EXCEPTION 'Integración F2–F5 (b): falta 2026-10-31_infraestructura_f2_f5_integracion.sql o organization_extensions.organization_affiliations. Aplicalo antes.';
    END IF;

    SELECT count(*), string_agg(x, '; ') INTO n, detalle FROM (
        SELECT 'service_requests ' || sr."id" || ' → espacio ' || sr."suggested_care_space_id" AS x
          FROM "clinical"."service_requests" sr
          LEFT JOIN "practice"."care_spaces" cs ON cs."id" = sr."suggested_care_space_id"
         WHERE sr."suggested_care_space_id" IS NOT NULL
           AND NOT (
                cs."id" IS NOT NULL
            AND (sr."suggested_practice_site_id" IS NULL OR sr."suggested_practice_site_id" = cs."practice_site_id")
            AND (cs."tenant_id" = sr."custodian_tenant_id"
                 OR ((sr."performer_tenant_id" IS NULL OR sr."performer_tenant_id" = cs."tenant_id")
                     AND EXISTS (
                        SELECT 1 FROM "organization_extensions"."organization_affiliations" oa
                         WHERE oa."status_concept_id" = 'a0586b44-2194-5341-87c9-901bf67d30d3'::uuid
                           AND (oa."valid_from" IS NULL OR oa."valid_from" <= now())
                           AND (oa."valid_to" IS NULL OR oa."valid_to" > now())
                           AND ((oa."primary_tenant_id" = sr."custodian_tenant_id" AND oa."participating_tenant_id" = cs."tenant_id")
                             OR (oa."participating_tenant_id" = sr."custodian_tenant_id" AND oa."primary_tenant_id" = cs."tenant_id")))))
           )
         LIMIT 20
    ) q;
    IF n > 0 THEN
        RAISE EXCEPTION 'Integración F2–F5 (b): % orden(es) con punto de toma fuera de la regla nueva; corregilas antes de aplicar: %', n, detalle;
    END IF;
END $$;

-- ------------------------------------------------------------- 1. toma de muestra: INVOKER
CREATE OR REPLACE FUNCTION "diagnostics"."specimen_collection_events_assert_collection_point"() RETURNS trigger
LANGUAGE plpgsql SECURITY INVOKER SET search_path = pg_catalog, pg_temp AS $fn$
DECLARE
    sede uuid;
BEGIN
    IF NEW."collection_care_space_id" IS NULL THEN
        RETURN NEW;
    END IF;
    -- Bajo el RLS de quien escribe: un espacio de otro tenant no aparece.
    SELECT cs."practice_site_id" INTO sede FROM "practice"."care_spaces" cs WHERE cs."id" = NEW."collection_care_space_id";
    IF sede IS NULL OR (NEW."collection_site_id" IS NOT NULL AND NEW."collection_site_id" <> sede) THEN
        RAISE EXCEPTION 'specimen_collection_events.collection_care_space_id: punto de toma no válido'
            USING ERRCODE = 'foreign_key_violation';
    END IF;
    IF NEW."collection_site_id" IS NULL THEN
        NEW."collection_site_id" := sede;
    END IF;
    RETURN NEW;
END $fn$;

DROP TRIGGER IF EXISTS "trg_specimen_collection_events_collection_point" ON "diagnostics"."specimen_collection_events";
CREATE TRIGGER "trg_specimen_collection_events_collection_point"
    BEFORE INSERT OR UPDATE OF "collection_care_space_id", "collection_site_id" ON "diagnostics"."specimen_collection_events"
    FOR EACH ROW EXECUTE FUNCTION "diagnostics"."specimen_collection_events_assert_collection_point"();

-- ------------------------------------------------------------- 2. orden: DEFINER acotado
-- DEFINER imprescindible: el punto del ejecutor externo es de otro tenant y bajo RLS el que
-- ordena no lo ve. La búsqueda sólo devuelve espacios del que ordena o de un tenant afiliado
-- (y, si se fijó, del ejecutor de la orden); search_path fijo; no escribe otra tabla.
CREATE OR REPLACE FUNCTION "clinical"."service_requests_assert_collection_point"() RETURNS trigger
LANGUAGE plpgsql SECURITY DEFINER SET search_path = pg_catalog, pg_temp AS $fn$
DECLARE
    sede uuid;
BEGIN
    IF NEW."suggested_care_space_id" IS NULL THEN
        RETURN NEW;
    END IF;
    IF current_setting('app.system_context', true) IS DISTINCT FROM 'true'
       AND NEW."custodian_tenant_id" IS DISTINCT FROM NULLIF(current_setting('app.current_tenant_id', true), '')::uuid THEN
        RAISE EXCEPTION 'service_requests.suggested_care_space_id: punto de toma no válido'
            USING ERRCODE = 'foreign_key_violation';
    END IF;
    SELECT cs."practice_site_id" INTO sede
      FROM "practice"."care_spaces" cs
     WHERE cs."id" = NEW."suggested_care_space_id"
       AND (cs."tenant_id" = NEW."custodian_tenant_id"
            OR ((NEW."performer_tenant_id" IS NULL OR NEW."performer_tenant_id" = cs."tenant_id")
                AND EXISTS (
                    SELECT 1 FROM "organization_extensions"."organization_affiliations" oa
                     WHERE oa."status_concept_id" = 'a0586b44-2194-5341-87c9-901bf67d30d3'::uuid
                       AND (oa."valid_from" IS NULL OR oa."valid_from" <= now())
                       AND (oa."valid_to" IS NULL OR oa."valid_to" > now())
                       AND ((oa."primary_tenant_id" = NEW."custodian_tenant_id" AND oa."participating_tenant_id" = cs."tenant_id")
                         OR (oa."participating_tenant_id" = NEW."custodian_tenant_id" AND oa."primary_tenant_id" = cs."tenant_id")))));
    IF sede IS NULL OR (NEW."suggested_practice_site_id" IS NOT NULL AND NEW."suggested_practice_site_id" <> sede) THEN
        RAISE EXCEPTION 'service_requests.suggested_care_space_id: punto de toma no válido'
            USING ERRCODE = 'foreign_key_violation';
    END IF;
    IF NEW."suggested_practice_site_id" IS NULL THEN
        NEW."suggested_practice_site_id" := sede;
    END IF;
    RETURN NEW;
END $fn$;

REVOKE ALL ON FUNCTION "clinical"."service_requests_assert_collection_point"() FROM PUBLIC;

DROP TRIGGER IF EXISTS "trg_service_requests_collection_point" ON "clinical"."service_requests";
CREATE TRIGGER "trg_service_requests_collection_point"
    BEFORE INSERT OR UPDATE OF "suggested_care_space_id", "suggested_practice_site_id", "custodian_tenant_id", "performer_tenant_id"
    ON "clinical"."service_requests"
    FOR EACH ROW EXECUTE FUNCTION "clinical"."service_requests_assert_collection_point"();

-- ------------------------------------------------------------- verificación
DO $$
DECLARE
    sd_sr  boolean;
    sd_sce boolean;
    n_trg  integer;
    n_col  integer;
BEGIN
    SELECT prosecdef INTO sd_sr  FROM pg_proc WHERE oid = 'clinical.service_requests_assert_collection_point()'::regprocedure;
    SELECT prosecdef INTO sd_sce FROM pg_proc WHERE oid = 'diagnostics.specimen_collection_events_assert_collection_point()'::regprocedure;
    SELECT count(*) INTO n_trg FROM pg_trigger
     WHERE NOT tgisinternal AND tgenabled <> 'D'
       AND tgname IN ('trg_service_requests_collection_point', 'trg_specimen_collection_events_collection_point');
    SELECT cardinality(tgattr::int2[]) INTO n_col FROM pg_trigger
     WHERE tgname = 'trg_service_requests_collection_point' AND tgrelid = 'clinical.service_requests'::regclass;
    IF sd_sr IS NOT TRUE OR sd_sce IS NOT FALSE OR n_trg <> 2 OR n_col <> 4 THEN
        RAISE EXCEPTION 'Integración F2–F5 (b) incompleta: service_requests DEFINER=% (t), specimen DEFINER=% (f), triggers=% (2), columnas UPDATE OF=% (4)',
            sd_sr, sd_sce, n_trg, n_col;
    END IF;
    RAISE NOTICE 'Integración F2–F5 (b) aplicada: specimen_collection_events INVOKER; service_requests DEFINER acotado a custodio/afiliados; mensaje único.';
END $$;

COMMIT;
