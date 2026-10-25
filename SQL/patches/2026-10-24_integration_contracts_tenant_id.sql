-- ============================================================================
-- SALUD · patch (integration_contracts · tenant propietario del contrato) sobre BD viva
-- Fecha: 2026-10-24 · hallazgo ICON-01 (revisión de seguridad del 2026-10-04)
-- Idempotente (IF NOT EXISTS / duplicate_object). UNA sola pasada.
--
-- Contexto: integration_contracts.integration_contracts no tenía columna de
-- tenant. El contrato, sus versiones, perfiles de autenticación, suscripciones,
-- intercambios y cursores se cargaban por UUID sin forma de comprobar a qué
-- organización pertenecían: un administrador de un tenant que conociera un UUID
-- ajeno podía publicar o retirar el contrato, rotar credenciales, reintentar
-- intercambios o avanzar cursores de otro tenant. El servicio ahora resuelve
-- cada recurso hijo → contrato → tenant y compara con el tenant activo; para
-- eso el contrato necesita su dueño.
-- gen_apply.py no escanea SQL/patches/: no entra en apply_all.sql. El generador
-- (.puml → SQL, repo del modelo) es quien debe emitir la columna definitiva.
--
-- QUÉ CIERRA.
--   1. integration_contracts.integration_contracts.tenant_id (nullable): tenant
--      propietario; lo fija el alta desde el contexto autenticado.
--   2. Índice por tenant y unicidad (tenant_id, external_provider_id,
--      contract_code) para los contratos con tenant: el servicio ya rechazaba el
--      duplicado, ahora la base también (carrera entre dos altas simultáneas).
--   3. FK hacia directory.tenants (requiere schema directory).
--
-- SIN BACKFILL. Los contratos creados antes de este patch quedan con
-- tenant_id NULL y, por diseño, NINGÚN tenant los alcanza: el servicio responde
-- 404 igual que para un UUID inexistente hasta que un administrador de la
-- plataforma asigne su tenant. No hay forma segura de inferirlo del esquema (el
-- proveedor externo es global y compartido entre organizaciones). Para asignar:
--   UPDATE integration_contracts.integration_contracts
--      SET tenant_id = '<uuid del tenant>'
--    WHERE id = '<uuid del contrato>' AND tenant_id IS NULL;
-- Contratos sin tenant hoy (solo lectura):
--   SELECT id, contract_code, external_provider_id
--     FROM integration_contracts.integration_contracts WHERE tenant_id IS NULL;
--
-- DELTAS ESPERADOS sobre la base viva:
--   tablas +0 · columnas +1 · FKs +1 · índices +2
-- ============================================================================

BEGIN;

ALTER TABLE "integration_contracts"."integration_contracts"
    ADD COLUMN IF NOT EXISTS "tenant_id" uuid;

CREATE INDEX IF NOT EXISTS "ix_integration_contracts_tenant_id" ON "integration_contracts"."integration_contracts" ("tenant_id");

CREATE UNIQUE INDEX IF NOT EXISTS "uq_integration_contracts_tenant_provider_code" ON "integration_contracts"."integration_contracts" ("tenant_id", "external_provider_id", "contract_code") WHERE tenant_id IS NOT NULL;

-- destino: directory.tenants (requiere schema directory)
DO $$ BEGIN
    ALTER TABLE "integration_contracts"."integration_contracts"
        ADD CONSTRAINT "fk_integration_contracts_tenant_id" FOREIGN KEY ("tenant_id")
        REFERENCES "directory"."tenants" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

COMMIT;
