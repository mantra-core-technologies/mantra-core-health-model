-- v4.2.38 · clinical.medication_requests.indication_text (2026-10-11)
-- El front envía `indicationText` (motivo de la receta en texto libre) al
-- prescribir sin diagnóstico codificado. La entidad ya declaraba la columna
-- (pendiente en el modelo, §«Pedidos a M1»), pero el esquema no la tenía y la
-- lectura/escritura de recetas fallaba. Aditivo, anulable, idempotente.
-- indication_text excluye a indication_condition_id (gana el concepto; lo
-- aplica el servicio).
ALTER TABLE "clinical"."medication_requests"
    ADD COLUMN IF NOT EXISTS "indication_text" varchar(200);
