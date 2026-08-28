-- SALUD v4.0.10 · módulo 64 · schema audio_assets
-- Generado de diagram_64_audio_assets.puml — NO editar a mano.


-- destino: directory.tenants (requiere schema directory)
DO $$ BEGIN
    ALTER TABLE "audio_assets"."audio_assets"
        ADD CONSTRAINT "fk_audio_assets_tenant_id" FOREIGN KEY ("tenant_id")
        REFERENCES "directory"."tenants" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;
