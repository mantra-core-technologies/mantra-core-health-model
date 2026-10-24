-- v4246 · designaciones ES de las prioridades de la orden de estudio (2026-10-11)
-- El selector de prioridad mostraba «Urgent priority» / «Prioridad urgente». Quedan los
-- nombres cortos que usa la ficha: De rutina · Urgente · Lo antes posible · Inmediata.
-- Idempotente: solo actualiza la designacion ES preferida cuando difiere.
-- Los 88 estudios (clinical:STUDY_*) ya traen su designacion ES desde el seed; aqui
-- solo se corrigen las prioridades, que el seed sembro como «Prioridad urgente».
UPDATE terminology.concept_designations d
   SET value = v.nombre, updated_at = now()
  FROM (VALUES
    ('clinical:SERVICE_REQUEST_PRIORITY_ROUTINE', 'De rutina'),
    ('clinical:SERVICE_REQUEST_PRIORITY_URGENT',  'Urgente'),
    ('clinical:SERVICE_REQUEST_PRIORITY_ASAP',    'Lo antes posible'),
    ('clinical:SERVICE_REQUEST_PRIORITY_STAT',    'Inmediata')
  ) AS v(code, nombre)
  JOIN terminology.catalog_concepts c ON c.code = v.code
 WHERE d.concept_id = c.id
   AND d.language_concept_id = '1e0b7669-d4d8-5c0f-9544-182a5fe60651'
   AND d.preferred = true
   AND d.value IS DISTINCT FROM v.nombre;
