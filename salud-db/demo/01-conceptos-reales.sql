-- Convierte el esqueleto del mock de seedsGenerales en datos de demostración
-- que el producto sí muestra.
--
-- El mock trae nombres, títulos y textos buenos, pero rellena cada columna
-- `*_concept_id` con conceptos placeholder (`DEFAULT_*`) y deja los perfiles
-- públicos apuntando a un `target_id` que no existe. Como todas las consultas
-- del directorio filtran por el concepto real, nada de eso se ve. Acá se
-- reemplazan esos placeholders por los conceptos que la API efectivamente
-- consulta, y se ata cada perfil público a un profesional de verdad.
--
-- Es idempotente: vuelve a correr sin duplicar nada.

BEGIN;

-- 1 · Especialidades: el paquete las sembró en su propio sistema de códigos
-- (1.0.0-vs_medical_specialty), no en el de la API. `VS_MEDICAL_SPECIALTY` —el
-- conjunto que el filtro del directorio expande— sólo contiene los de la API,
-- así que una especialidad del paquete no acota nada.
UPDATE profiles.practitioner_specialties ps
SET specialty_concept_id = nuevo.id
FROM terminology.catalog_concepts viejo, terminology.catalog_concepts nuevo
WHERE viejo.id = ps.specialty_concept_id
  AND viejo.code_system_version_id = '3d820448-44ba-5201-8443-4eb981bb3fa2'
  AND nuevo.code = 'clinical-forms:specialty:' || viejo.code;

-- 2 · Estado de los profesionales. Los 16 del paquete quedaron con el `ACTIVE`
-- genérico; la API lee `profiles:PRACT_VERIF_*` y `profiles:PRACTICE_*`. Se
-- dejan cuatro sin verificar a propósito: el filtro «sólo verificados» no se
-- puede probar si todos están verificados.
WITH numerados AS (
  SELECT profile_id, row_number() OVER (ORDER BY practitioner_code) AS n
  FROM profiles.health_practitioner_profiles
  WHERE practitioner_code LIKE 'HEALTH_PRACTITIONER_PROFILES_%'
)
UPDATE profiles.health_practitioner_profiles h
SET verification_status_concept_id = CASE WHEN numerados.n <= 12
      THEN '4a2b28d1-28cc-5e84-aeab-0b6d75a9c966'::uuid   -- profiles:PRACT_VERIF_VERIFIED
      ELSE 'ed8371fb-89a7-5bb4-af21-a83710587a20'::uuid   -- profiles:PRACT_VERIF_PENDING
    END,
    practice_status_concept_id = '6e5ec429-d281-5f1d-820c-2327fff172d5'  -- profiles:PRACTICE_ACTIVE
FROM numerados
WHERE h.profile_id = numerados.profile_id;

-- 3 · Perfiles públicos. Se reutilizan las 16 filas del paquete —las
-- publicaciones y reseñas del mock ya cuelgan de sus ids— pero se las ata a un
-- profesional distinto cada una, con su nombre, su título y los conceptos que
-- el directorio consulta.
WITH profesionales AS (
  SELECT h.profile_id, p.display_name, h.professional_title,
         row_number() OVER (ORDER BY h.practitioner_code) AS n
  FROM profiles.health_practitioner_profiles h
  JOIN profiles.persons p ON p.id = h.profile_id
  WHERE h.practitioner_code LIKE 'HEALTH_PRACTITIONER_PROFILES_%'
), vitrinas AS (
  SELECT id, row_number() OVER (ORDER BY slug) AS n
  FROM community.public_profiles
)
UPDATE community.public_profiles pp
SET target_type_concept_id = '45d61ae6-f540-5b5f-90ef-c1f2dcad6e2d',  -- community:PROFILE_TARGET_PRACTITIONER
    target_id              = pro.profile_id,
    display_name           = pro.display_name,
    headline               = pro.professional_title,
    slug                   = regexp_replace(
                               lower(translate(pro.display_name,
                                     'áéíóúÁÉÍÓÚñÑüÜ', 'aeiouAEIOUnNuU')),
                               '[^a-z0-9]+', '-', 'g'),
    visibility_concept_id  = '0006f171-fd25-503d-906e-b77423a5f1d0',  -- community:PROFILE_VISIBILITY_PUBLIC
    status_concept_id      = '38a1d301-f40d-5b17-a695-5e6d605f8b19',  -- ACTIVE (sistema de la API)
    verification_status_concept_id = CASE WHEN pro.n <= 12
                               THEN '38a1d301-f40d-5b17-a695-5e6d605f8b19'::uuid END,
    accepts_reviews        = true,
    comments_default_enabled = true,
    updated_at             = now()
FROM vitrinas, profesionales pro
WHERE pp.id = vitrinas.id AND vitrinas.n = pro.n;

-- 4 · Publicaciones. Mismo problema y misma cura: sin visibilidad pública,
-- estado publicado y moderación aprobada, el muro de inicio queda vacío aunque
-- las 16 filas estén ahí.
UPDATE community.social_posts
SET post_type_concept_id          = '0dd08eed-1323-5b55-a0be-b1a924b1eb09',  -- community:POST_TYPE_TEXT
    visibility_concept_id         = '62221f98-088c-53dc-ab2a-11376f720a57',  -- community:POST_VISIBILITY_PUBLIC
    publication_status_concept_id = 'db373689-6e98-5cbb-925f-a0a8d83091eb',  -- community:PUBLICATION_PUBLISHED
    moderation_status_concept_id  = '7278f10f-d53a-519c-9560-de6a1e573329',  -- community:MODERATION_APPROVED
    published_at = CASE WHEN published_at IS NULL OR published_at > now()
                        THEN now() - interval '1 hour'
                        ELSE published_at END,
    comments_enabled = true,
    updated_at = now();

COMMIT;

\echo == verificacion ==
SELECT count(*) AS vitrinas_publicas FROM community.public_profiles
WHERE visibility_concept_id = '0006f171-fd25-503d-906e-b77423a5f1d0'
  AND status_concept_id = '38a1d301-f40d-5b17-a695-5e6d605f8b19'
  AND target_type_concept_id = '45d61ae6-f540-5b5f-90ef-c1f2dcad6e2d';

SELECT count(*) AS con_especialidad_real FROM profiles.practitioner_specialties ps
JOIN terminology.catalog_concepts cc ON cc.id = ps.specialty_concept_id
WHERE cc.code LIKE 'clinical-forms:specialty:%';

SELECT count(*) AS posts_publicados FROM community.social_posts
WHERE visibility_concept_id = '62221f98-088c-53dc-ab2a-11376f720a57'
  AND publication_status_concept_id = 'db373689-6e98-5cbb-925f-a0a8d83091eb'
  AND published_at <= now();

SELECT slug, display_name, headline FROM community.public_profiles ORDER BY display_name LIMIT 6;
