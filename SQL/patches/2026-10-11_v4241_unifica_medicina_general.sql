-- 2026-10-11 · El directorio de médicos mostraba dos filtros «Medicina general»
-- (42) y «Medicina General» (21) porque hay dos conceptos de la misma
-- especialidad: profiles:SPECIALTY_GENERAL (importación de profesionales) y
-- clinical-forms:specialty:MEDICINA_GENERAL (el que usan las plantillas de
-- historia clínica). Se deja el segundo —tiene plantilla— y se re-apuntan las
-- especialidades de profesionales del primero. Idempotente.
UPDATE profiles.practitioner_specialties ps
   SET specialty_concept_id = dst.id, updated_at = now()
  FROM terminology.catalog_concepts src, terminology.catalog_concepts dst
 WHERE src.code = 'profiles:SPECIALTY_GENERAL'
   AND dst.code = 'clinical-forms:specialty:MEDICINA_GENERAL'
   AND ps.specialty_concept_id = src.id
   AND NOT EXISTS (SELECT 1 FROM profiles.practitioner_specialties o
                    WHERE o.practitioner_profile_id = ps.practitioner_profile_id
                      AND o.specialty_concept_id = dst.id);
