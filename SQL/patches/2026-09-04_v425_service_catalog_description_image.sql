-- ============================================================================
-- SALUD · patch v4.2.5 (billing · descripción e imagen del servicio) sobre BD viva
-- Fecha: 2026-09-04
-- Idempotente (ADD COLUMN IF NOT EXISTS / CREATE INDEX IF NOT EXISTS /
-- ADD CONSTRAINT bajo IF NOT EXISTS).
-- UNA sola pasada. No hay backfill, y no debe haberlo — ver más abajo.
--
-- Contexto: gen_ddl.py ya emite estas dos columnas en SQL/17_billing/ desde que
-- el .puml las declara, así que en un rebuild desde cero este patch NO hace
-- falta. Existe únicamente para una base ya aplicada y poblada. gen_apply.py no
-- escanea SQL/patches/ (sólo directorios NN_schema), así que no entra en
-- apply_all.sql.
--
-- QUÉ CIERRA. FT-22-R02: «Servicio predeterminado debe tener descripción e
-- imagen específica». Hasta hoy ninguna de las dos TENÍA DÓNDE VIVIR:
-- `service_catalog` declaraba quince columnas y ninguna era texto largo ni
-- referencia a un archivo. La pantalla de «Mis servicios» lo decía explícito en
-- su documentación —«la tarjeta muestra lo que existe en vez de dejar huecos que
-- sugieran un dato que nadie cargó»—, y esto es lo que le da qué mostrar.
--
-- POR QUÉ LA IMAGEN NO ES UNA COLUMNA DE BYTES NI UNA URL. Todo archivo del
-- producto vive en `common.files`, con su propietario, su tamaño y su tipo. Acá
-- va sólo el identificador, igual que `profiles.persons.photo_file_id`. Una URL
-- suelta sería un archivo sin dueño y sin control de acceso.
--
-- POR QUÉ LAS DOS SON NULLABLE. La mayoría de los servicios de un catálogo no
-- van a tener imagen ni descripción larga: un arancel importado son un código y
-- un nombre. Exigirlas obligaría a inventar contenido para las 4 408 entradas
-- del nomenclador el día que alguien las importe.
--
-- POR QUÉ NO HAY BACKFILL. Sería tentador escribirle una descripción a las filas
-- `CITA_MEDICA` que ya existen. La descripción de un servicio es texto que
-- redacta quien lo ofrece, y un backfill pondría las mismas palabras en la boca
-- de todas las organizaciones sin que ninguna las haya escrito. La API siembra
-- una descripción neutra al crear la práctica; las que ya nacieron se quedan sin
-- ella hasta que su dueño escriba la suya.
--
-- ADVERTENCIA DE ALCANCE — QUIÉN VE LA IMAGEN. `common.files` entrega el
-- contenido a quien subió el archivo o a un rol de revisión. Para que un
-- paciente vea la imagen de un servicio hace falta una decisión de acceso que
-- todavía no se tomó (P-22-8 de la ficha TAREA-22). Este patch abre la columna;
-- no resuelve el permiso.
--
-- LO QUE ESTE PATCH NO TRAE, Y NO ES OLVIDO. Los términos y condiciones del
-- servicio (FT-22-R04/R06/R07). El pedido les exige versión, edición e
-- historial: un texto legal que se sobrescribe sin dejar rastro de qué versión
-- aceptó cada paciente no cubre nada, que es lo contrario de lo que el modal de
-- confirmación promete. Eso es una tabla, no una columna, y está bloqueado
-- (B-2).
--
-- DELTAS ESPERADOS sobre la base viva:
--   columnas de billing.service_catalog  15 → 17
--   FKs                                  +1  (fk_service_catalog_image_file_id)
--   índices                              +1  (ix_service_catalog_image_file_id)
--   tablas                               ±0
-- ============================================================================

BEGIN;

-- ---------------------------------------------------------------- A. columnas
ALTER TABLE "billing"."service_catalog"
    ADD COLUMN IF NOT EXISTS "description_text" text;

ALTER TABLE "billing"."service_catalog"
    ADD COLUMN IF NOT EXISTS "image_file_id" uuid;

-- ------------------------------------------------------------------ B. índice
CREATE INDEX IF NOT EXISTS "ix_service_catalog_image_file_id"
    ON "billing"."service_catalog" ("image_file_id");

-- ---------------------------------------------------------------------- C. FK
DO $$ BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint
        WHERE conname = 'fk_service_catalog_image_file_id'
    ) THEN
        ALTER TABLE "billing"."service_catalog"
            ADD CONSTRAINT "fk_service_catalog_image_file_id"
            FOREIGN KEY ("image_file_id")
            REFERENCES "common"."files" ("id");
    END IF;
END $$;

-- ------------------------------------------------------------ D. verificación
-- Corré esto DENTRO de la transacción, antes del COMMIT. Las tres consultas
-- tienen que devolver lo que dice su comentario; si no, hacé ROLLBACK.
DO $$
DECLARE
    n_columnas integer;
    n_fk       integer;
    n_indices  integer;
BEGIN
    -- 2: las dos columnas nuevas están.
    SELECT count(*) INTO n_columnas
    FROM information_schema.columns
    WHERE table_schema = 'billing'
      AND table_name = 'service_catalog'
      AND column_name IN ('description_text', 'image_file_id');

    -- 1: la FK existe y está validada (no `NOT VALID`).
    SELECT count(*) INTO n_fk
    FROM pg_constraint
    WHERE conname = 'fk_service_catalog_image_file_id'
      AND convalidated;

    -- 1: el índice existe.
    SELECT count(*) INTO n_indices
    FROM pg_indexes
    WHERE schemaname = 'billing'
      AND indexname = 'ix_service_catalog_image_file_id';

    IF n_columnas <> 2 OR n_fk <> 1 OR n_indices <> 1 THEN
        RAISE EXCEPTION
            'v4.2.5 incompleto: columnas=% (esperado 2), fk=% (esperado 1), indices=% (esperado 1)',
            n_columnas, n_fk, n_indices;
    END IF;

    RAISE NOTICE 'v4.2.5 aplicado: 2 columnas, 1 FK validada, 1 índice.';
END $$;

COMMIT;
