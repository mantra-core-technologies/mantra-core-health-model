-- ============================================================================
-- SALUD · patch v4.1.8 (profiles.persons.occupation_* · insurance.insurance_carriers.sigla/address)
-- sobre una BD viva
-- Fecha: 2026-08-22
-- Idempotente (ADD COLUMN / CREATE INDEX IF NOT EXISTS · duplicate_object en la FK)
--
-- Contexto: gen_ddl.py ya emite estas columnas en SQL/05_profiles/ y
-- SQL/26_insurance/ desde que los .puml de los módulos 05 y 26 las declaran, así
-- que en un rebuild desde cero este patch NO hace falta. Existe únicamente para
-- una base ya aplicada y poblada. gen_apply.py no escanea SQL/patches/ (solo
-- directorios NN_schema), así que no entra en apply_all.sql.
--
-- Por qué existe: las cuatro columnas llegaron al ORM el 21/08 (commits ceba7c4d
-- y 880857d6, PR #184) sin pasar por el modelo. Con MikroORM eso no falla al
-- arrancar: falla en el INSERT, y sólo cuando el campo viene con valor — el alta
-- de paciente devolvía 201 mientras nadie tocara el desplegable de ocupación y
-- 500 en cuanto alguien lo elegía. Es el mismo defecto de dirección que B-9 y
-- v4.1.2/v4.1.3, y se cierra igual: promoviendo al modelo, no parchando el ORM.
--
-- OCUPACIÓN — son DOS columnas y no una a propósito. El registro de procesos
-- pide el catálogo con búsqueda por texto y, al final, una entrada libre «para
-- que él pueda detallar la ocupación que no encontró si no está en ese detalle».
-- El concepto gana cuando vienen los dos; el texto libre sólo tiene sentido sin
-- concepto. El value set VS_BO_OCCUPATION (606 entradas COB-2023 del INE) NO lo
-- siembra el paquete del modelo: lo publica la API al arrancar
-- (`src/common/seed/bo-geography-seed.service.ts`). Un solo dueño del conjunto, a
-- propósito — declararlo también en gen_seeds.py repetiría el problema del
-- módulo 64.
--
-- SIGLA Y DIRECCIÓN — cómo se nombra a la compañía en el giro comercial
-- («Alianza Vida»), que casi nunca es su razón social completa, y la dirección
-- de su oficina principal. `regulator_identifier` sigue siendo el registro APS y
-- no se inventa.
--
-- Tipos: `varchar` sin límite, que es lo que emite gen_ddl.py y lo que declaran
-- las entidades (`columnType: 'varchar'`). El patch equivalente que llegó por
-- `docs/model-handoff/2026-08-22_v414_catalogo_boliviano_y_aseguradora.sql`
-- declara `varchar(255)`: aplicá ÉSTE, o una base parchada y una reconstruida
-- quedan con tipos distintos para la misma columna.
--
-- Este archivo es la salida de gen_ddl.py 05 y 26, no DDL escrito a mano: las
-- columnas se declaran en `Mantra Core Health Context/modules/diagram_05_profiles.puml`
-- (entidad `persons` + su bloque <<INDEX_SET>>) y `diagram_26_insurance.puml`
-- (entidad `insurance_carriers`), y el destino de la FK en
-- `SALUD/FK/FK profiles.persons.occupation_concept_id.md`.
-- ============================================================================

-- ---------------------------------------------------------------------------
-- Módulo 05 · profiles.persons
-- ---------------------------------------------------------------------------

ALTER TABLE "profiles"."persons"
    ADD COLUMN IF NOT EXISTS "occupation_concept_id" uuid;

ALTER TABLE "profiles"."persons"
    ADD COLUMN IF NOT EXISTS "occupation_free_text" varchar;

CREATE INDEX IF NOT EXISTS "ix_persons_occupation_concept_id"
    ON "profiles"."persons" ("occupation_concept_id");

DO $$ BEGIN
    ALTER TABLE "profiles"."persons"
        ADD CONSTRAINT "fk_persons_occupation_concept_id" FOREIGN KEY ("occupation_concept_id")
        REFERENCES "terminology"."catalog_concepts" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- ---------------------------------------------------------------------------
-- Módulo 26 · insurance.insurance_carriers
-- ---------------------------------------------------------------------------

ALTER TABLE "insurance"."insurance_carriers"
    ADD COLUMN IF NOT EXISTS "sigla" varchar;

ALTER TABLE "insurance"."insurance_carriers"
    ADD COLUMN IF NOT EXISTS "address" varchar;

-- ---------------------------------------------------------------------------
-- Comprobación: rompe si el esquema quedó a medias.
-- ---------------------------------------------------------------------------

DO $$
DECLARE
    faltantes text;
BEGIN
    SELECT string_agg(esperada.tabla || '.' || esperada.columna, ', ' ORDER BY esperada.columna)
    INTO faltantes
    FROM (VALUES
        ('profiles',  'persons',            'occupation_concept_id'),
        ('profiles',  'persons',            'occupation_free_text'),
        ('insurance', 'insurance_carriers', 'sigla'),
        ('insurance', 'insurance_carriers', 'address')
    ) AS esperada(esquema, tabla, columna)
    WHERE NOT EXISTS (
        SELECT 1 FROM information_schema.columns c
        WHERE c.table_schema = esperada.esquema
          AND c.table_name   = esperada.tabla
          AND c.column_name  = esperada.columna
    );

    IF faltantes IS NOT NULL THEN
        RAISE EXCEPTION 'patch v4.1.8 incompleto — faltan: %', faltantes;
    END IF;
END $$;
