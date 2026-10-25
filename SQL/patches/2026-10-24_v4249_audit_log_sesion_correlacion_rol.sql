-- ============================================================================
-- SALUD · patch (audit · session_id, correlation_id y rol congelado en audit_log) sobre BD viva
-- Fecha: 2026-10-24 · issue #54 CAN-AUDIT-001 / C-19
-- Idempotente (IF NOT EXISTS / IF EXISTS / duplicate_object). UNA sola pasada. Sin backfill.
-- Contexto: gen_ddl.py y gen_integrity.py ya emiten esto en SQL/<NN>_<schema>/ desde que los
-- .puml lo declaran, así que en un rebuild desde cero este patch NO hace falta. Existe para una
-- base ya aplicada y poblada: un CREATE TABLE IF NOT EXISTS no agrega columnas a una tabla que
-- ya existe. gen_apply.py no escanea SQL/patches/: no entra en apply_all.sql. Las sentencias se
-- copiaron de los archivos generados, no se escribieron a mano.
--
-- QUÉ CIERRA. audit.audit_log gana tres columnas nullable de la auditoría canónica:
--   - session_id (FK a iam.sessions): la sesión que actuó;
--   - correlation_id (uuid): ata las filas de una misma operación, p. ej. el conjunto de lecturas
--     que habilitó una sesión de emergencia (authz.break_glass_sessions);
--   - actor_role_snapshot (varchar): el rol con el que actuó el usuario, congelado.
-- Más sus dos índices (el de correlation_id es parcial: solo las filas que lo traen).
--
-- audit_log es WORM (UPDATE y DELETE prohibidos por trigger): las filas anteriores NO se pueden
-- completar y quedan con los tres campos en NULL. ADD COLUMN no es un UPDATE y no lo dispara.
-- SIN BACKFILL.
--
-- DELTAS ESPERADOS sobre la base viva:
--   tablas +0 · columnas +3 · NOT NULL quitados 0 · FKs +1 · índices +2 (-0) · constraints +0
-- ============================================================================

BEGIN;

ALTER TABLE "audit"."audit_log"
    ADD COLUMN IF NOT EXISTS "session_id" uuid;

ALTER TABLE "audit"."audit_log"
    ADD COLUMN IF NOT EXISTS "correlation_id" uuid;

ALTER TABLE "audit"."audit_log"
    ADD COLUMN IF NOT EXISTS "actor_role_snapshot" varchar;

-- destino: iam.sessions (requiere schema iam)
DO $$ BEGIN
    ALTER TABLE "audit"."audit_log"
        ADD CONSTRAINT "fk_audit_log_session_id" FOREIGN KEY ("session_id")
        REFERENCES "iam"."sessions" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

CREATE INDEX IF NOT EXISTS "ix_audit_log_session_id" ON "audit"."audit_log" ("session_id");

CREATE INDEX IF NOT EXISTS "ix_audit_log_correlation_id" ON "audit"."audit_log" ("correlation_id") WHERE correlation_id IS NOT NULL;

COMMIT;
