-- Textos de divulgación para las 16 publicaciones del muro.
--
-- El mock trajo nombres y títulos buenos pero dejó el cuerpo en relleno
-- ("Social posts — grupo profesional 04"). Cada texto va con la especialidad de
-- quien firma y respeta la línea del pie del sitio: orienta, no diagnostica.

BEGIN;

UPDATE community.social_posts sp
SET body_text = nuevo.texto, updated_at = now()
FROM (VALUES
  ('b9014ad6-db86-53ef-af42-7e73412e4a56'::uuid, 'Un hemograma alterado no es un diagnóstico: es una pista. Antes de asustarte con un valor fuera de rango, fijate si el laboratorio usa los mismos rangos de referencia que el anterior — cambian entre equipos, y comparar entre laboratorios distintos inventa alarmas que no existen.'),
  ('6d245684-193f-594f-a7d3-c9d9d3d2782f'::uuid, 'Ayunar ocho horas antes de un perfil lipídico sigue siendo lo razonable, pero el agua no rompe el ayuno. Llegar deshidratado sí altera el resultado: concentra la muestra y sube valores que en tu cuerpo no subieron.'),
  ('7394a323-e50d-5df4-8333-54330dba1f3a'::uuid, 'La presión se toma sentado, con la espalda apoyada, el brazo a la altura del corazón y después de cinco minutos quieto. Medida de otra forma, una presión normal puede leerse alta — y una alta, normal.'),
  ('619dc094-3880-5ee6-a105-6f40bd129ebe'::uuid, 'Un dolor de pecho que aparece con el esfuerzo y cede con el reposo merece consulta esta semana, no el mes que viene. Si aparece en reposo, dura más de veinte minutos o viene con sudoración fría, es emergencia.'),
  ('6afc4e5a-3d62-51e8-b77b-c2eee33f545c'::uuid, 'Una hernia que no duele igual conviene operarla programada. La urgencia aparece cuando se atasca, y ahí la cirugía es más grande y la recuperación más larga.'),
  ('e0b899d7-2907-59bc-9201-a32afadd14e7'::uuid, 'El ayuno preoperatorio no es «desde anoche» por costumbre: son ocho horas para sólidos y dos para líquidos claros. Llegar con doce horas sin tomar nada no te hace más seguro, te deshidrata.'),
  ('9dd167ca-f725-5a92-9d31-e922cbccef57'::uuid, 'La hemoglobina glicosilada resume tres meses, no el desayuno de hoy. Sirve para ver si el tratamiento va bien; no reemplaza al control diario de quien usa insulina.'),
  ('82563a84-3029-5380-b22c-e9c30ad5d3a4'::uuid, 'El hipotiroidismo subclínico no siempre se trata. Antes de empezar levotiroxina de por vida, un segundo control a las seis u ocho semanas evita medicar una alteración pasajera.'),
  ('0b7b01cc-21e4-508f-b25e-404550175b94'::uuid, 'La acidez que vuelve apenas se suspende el omeprazol no se resuelve alargando el omeprazol. Antes de cronificar el medicamento vale revisar horarios de comida, peso y alcohol.'),
  ('79c01cdd-7169-54d8-969b-dea1867468b6'::uuid, 'Sangre en las heces no es «sólo hemorroides» hasta que alguien lo miró. Las hemorroides son frecuentes, y justamente por eso tapan otros diagnósticos.'),
  ('ff219baa-019c-575e-a7e9-684469c1b9da'::uuid, 'La intolerancia a la lactosa y la alergia a la proteína de la leche no son lo mismo: distinto estudio, distinto manejo. Confundirlas termina en dietas que nadie necesitaba.'),
  ('344621ca-c97f-5363-9416-1775a63ba53f'::uuid, 'Un mes de diarrea no es una diarrea larga: es otra cosa. Pasadas las cuatro semanas, el estudio que corresponde cambia por completo.'),
  ('89eb9e42-d457-5730-a31a-5f76c8828e8e'::uuid, 'Una radiografía de tórax no descarta todo lo que duele en el pecho, y una tomografía no siempre es «mejor»: cada estudio responde una pregunta distinta. Llevar la pregunta clara en el pedido ahorra estudios.'),
  ('912dc55a-ffe4-5901-bbc7-11944ec7cf98'::uuid, 'Guardá tus imágenes, no sólo el informe. La comparación con el estudio anterior es, muchas veces, más útil que el estudio nuevo.'),
  ('f169a189-ae8c-5809-91b8-14d95f57e8c8'::uuid, 'Hielo las primeras cuarenta y ocho horas, y después calor. Al revés no acelera nada: al principio el frío controla la inflamación, más adelante el calor ayuda a mover.'),
  ('56b58741-3365-5903-998a-5449a7430f95'::uuid, 'Un esguince que sigue hinchado a las tres semanas necesita revisión. No siempre es «que se demora»: puede haber una lesión que el primer examen no mostró.')
) AS nuevo(post_id, texto)
WHERE sp.id = nuevo.post_id;

COMMIT;

\echo == verificacion ==
SELECT count(*) AS con_relleno FROM community.social_posts WHERE body_text LIKE 'Social posts%';
SELECT pp.display_name, left(sp.body_text, 55) AS texto
FROM community.social_posts sp
JOIN community.public_profiles pp ON pp.id = sp.author_public_profile_id
ORDER BY sp.published_at DESC LIMIT 4;
