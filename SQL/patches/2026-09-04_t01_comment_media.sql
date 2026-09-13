-- ============================================================================
--  TAREA-01 · adjuntos de comentario (imágenes, stickers y GIFs)
--
--  REQ-01-011: "En cada comentario se debe poder subir imágenes, sticker y
--  gifs." `community.comments` no tenía dónde guardar un adjunto — el equipo
--  lo había dejado documentado como brecha en `public-post-comments.ts`
--  ("hoy no tiene dónde guardarse (no existe `comment_media`)") en vez de
--  simular la función.
--
--  `community.comment_media` es literalmente `community.post_media`
--  (SQL/19_community/02_tables.sql) con `post_id` reemplazado por
--  `comment_id`: mismas columnas, mismo tipo, mismo patrón de FK. No hay
--  `.puml` para esta tabla porque el módulo 19 completo se generó antes de
--  este requisito; ver la nota "el flujo es `.puml` → `SQL/` → BD → ORM" en
--  `database/SQL/README.md`. Hasta que alguien actualice
--  `diagram_19_community.puml` y regenere, este patch es la única fuente de
--  la tabla — igual que los `ALTER` incrementales que ya viven acá.
--
--  Tres roles de medio, no dos: además de `MEDIA_ROLE_IMAGE` (ya existía para
--  `post_media`) se sube el concepto con `MEDIA_ROLE_STICKER` y
--  `MEDIA_ROLE_GIF` en `community.concepts.ts`. El pipeline de subida es el
--  mismo `POST /common/files/upload` que ya usa el resto del sistema — no se
--  agrega proveedor nuevo (regla 60-backend.md #12): un "sticker" es una
--  imagen chica subida con ese rol, y un GIF es un archivo `image/gif`, tipo
--  MIME que `upload-content-type.ts` ya acepta.
--
--  Idempotente: `CREATE TABLE IF NOT EXISTS`, `CREATE INDEX IF NOT EXISTS` y
--  los `ADD CONSTRAINT` envueltos en `DO $$ ... EXCEPTION WHEN
--  duplicate_object THEN NULL; END $$`, igual que el resto de `SQL/`.
--  Ningún `DROP`, ningún `TRUNCATE`, ninguna reescritura de fila existente.
-- ============================================================================

CREATE TABLE IF NOT EXISTS "community"."comment_media" (
    "id" uuid NOT NULL,
    "comment_id" uuid NOT NULL,
    "file_id" uuid NOT NULL,
    "media_role_concept_id" uuid NOT NULL,
    "alt_text" varchar,
    "ordinal" integer,
    "created_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    CONSTRAINT "pk_comment_media" PRIMARY KEY ("id")
);

-- FK intra-schema (comments vive en el mismo schema community).
DO $$ BEGIN
    ALTER TABLE "community"."comment_media"
        ADD CONSTRAINT "fk_comment_media_comment_id" FOREIGN KEY ("comment_id")
        REFERENCES "community"."comments" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- FK cross-schema (equivalentes a las de post_media en 90_fk_deferred.sql).
DO $$ BEGIN
    ALTER TABLE "community"."comment_media"
        ADD CONSTRAINT "fk_comment_media_file_id" FOREIGN KEY ("file_id")
        REFERENCES "common"."files" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "community"."comment_media"
        ADD CONSTRAINT "fk_comment_media_media_role_concept_id" FOREIGN KEY ("media_role_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "community"."comment_media"
        ADD CONSTRAINT "fk_comment_media_created_by_user_id" FOREIGN KEY ("created_by_user_id")
        REFERENCES "iam"."users" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

CREATE INDEX IF NOT EXISTS "ix_comment_media_comment_id" ON "community"."comment_media" ("comment_id");
CREATE INDEX IF NOT EXISTS "ix_comment_media_file_id" ON "community"."comment_media" ("file_id");
CREATE INDEX IF NOT EXISTS "ix_comment_media_media_role_concept_id" ON "community"."comment_media" ("media_role_concept_id");
CREATE INDEX IF NOT EXISTS "ix_comment_media_created_by_user_id" ON "community"."comment_media" ("created_by_user_id");
