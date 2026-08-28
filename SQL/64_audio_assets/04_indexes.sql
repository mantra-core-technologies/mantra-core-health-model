-- SALUD v4.0.10 · módulo 64 · schema audio_assets
-- Generado de diagram_64_audio_assets.puml — NO editar a mano.


CREATE UNIQUE INDEX IF NOT EXISTS "uq_audio_templates_key_version" ON "audio_assets"."audio_templates" ("template_key", "version");

CREATE UNIQUE INDEX IF NOT EXISTS "uq_audio_assets_asset_key" ON "audio_assets"."audio_assets" ("asset_key");

CREATE INDEX IF NOT EXISTS "ix_audio_assets_template_status" ON "audio_assets"."audio_assets" ("template_key", "template_version", "generation_status");

CREATE INDEX IF NOT EXISTS "ix_audio_assets_last_used_at" ON "audio_assets"."audio_assets" ("last_used_at");

CREATE INDEX IF NOT EXISTS "ix_audio_assets_synthesis_reuse" ON "audio_assets"."audio_assets" ("rendered_text_hash", "provider", "provider_model", "voice_version", "generation_status");

CREATE INDEX IF NOT EXISTS "ix_audio_assets_tenant_reuse" ON "audio_assets"."audio_assets" ("tenant_id", "rendered_text_hash", "generation_status");

CREATE INDEX IF NOT EXISTS "ix_audio_assets_tenant_id" ON "audio_assets"."audio_assets" ("tenant_id");

CREATE INDEX IF NOT EXISTS "ix_audio_generation_events_asset_created" ON "audio_assets"."audio_generation_events" ("asset_key", "created_at" DESC);

CREATE INDEX IF NOT EXISTS "ix_audio_generation_events_template_created" ON "audio_assets"."audio_generation_events" ("template_key", "created_at" DESC);

CREATE UNIQUE INDEX IF NOT EXISTS "uq_audio_generation_usage_period_provider" ON "audio_assets"."audio_generation_usage" ("period_key", "provider");
