-- SALUD v4.0.10 · tipos compartidos (aplicar PRIMERO, antes de cualquier tabla)
-- 'technical_data_type' es el único enum nativo permitido por el modelo
-- (doc: semantic-data-analysis §3.2). Usado en módulos 03/09/30/39/44.
-- Vocabulario: el que declara y usa la aplicación en forms/dto
-- (TECHNICAL_DATA_TYPES). Antes el enum se creaba vacío y toda escritura
-- de un tipo real fallaba con 'invalid input value for enum'.

CREATE SCHEMA IF NOT EXISTS "terminology";

DO $$ BEGIN
    CREATE TYPE "terminology"."technical_data_type" AS ENUM ('string', 'text', 'integer', 'decimal', 'boolean', 'date', 'datetime', 'time', 'uuid', 'json', 'binary', 'reference', 'code');
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

-- Idempotente para bases ya creadas (incluidas las que quedaron con el enum vacío).
ALTER TYPE "terminology"."technical_data_type" ADD VALUE IF NOT EXISTS 'string';
ALTER TYPE "terminology"."technical_data_type" ADD VALUE IF NOT EXISTS 'text';
ALTER TYPE "terminology"."technical_data_type" ADD VALUE IF NOT EXISTS 'integer';
ALTER TYPE "terminology"."technical_data_type" ADD VALUE IF NOT EXISTS 'decimal';
ALTER TYPE "terminology"."technical_data_type" ADD VALUE IF NOT EXISTS 'boolean';
ALTER TYPE "terminology"."technical_data_type" ADD VALUE IF NOT EXISTS 'date';
ALTER TYPE "terminology"."technical_data_type" ADD VALUE IF NOT EXISTS 'datetime';
ALTER TYPE "terminology"."technical_data_type" ADD VALUE IF NOT EXISTS 'time';
ALTER TYPE "terminology"."technical_data_type" ADD VALUE IF NOT EXISTS 'uuid';
ALTER TYPE "terminology"."technical_data_type" ADD VALUE IF NOT EXISTS 'json';
ALTER TYPE "terminology"."technical_data_type" ADD VALUE IF NOT EXISTS 'binary';
ALTER TYPE "terminology"."technical_data_type" ADD VALUE IF NOT EXISTS 'reference';
ALTER TYPE "terminology"."technical_data_type" ADD VALUE IF NOT EXISTS 'code';
