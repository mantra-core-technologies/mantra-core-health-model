# ADS — alineación conceptual con Meta

## Capacidades incorporadas

- Conexiones versionadas por Business Manager y Ad Account.
- Identidades publicitarias y asignaciones a anuncios/creativos.
- Datasets de conversión y conexiones browser/server/offline.
- Eventos server-side con `event_name + event_id`, datos de usuario normalizados/hasheados, custom data y reintentos.
- Deduplificación browser/server y snapshots de calidad.
- Formularios de leads, preguntas, respuestas cifradas y delivery a CRM.
- Definiciones de métricas/breakdowns, ejecuciones de Insights y facts normalizados.
- Revisión, violaciones, apelaciones y estados de aprendizaje.
- Sincronización externa con snapshots y checkpoints idempotentes.

## Firewall sanitario obligatorio

Los eventos publicitarios se someten a allowlist, propósito y consentimiento. Se prohíbe enviar diagnósticos, procedimientos, resultados de laboratorio/imágenes, medicamentos, alergias o texto clínico libre. Los eventos bloqueados conservan solamente hashes y rutas de campos para auditoría.

## Fuentes oficiales revisadas

- Conversions API: https://developers.facebook.com/documentation/ads-commerce/conversions-api/
- Deduplicación: https://developers.facebook.com/documentation/ads-commerce/conversions-api/deduplicate-pixel-and-server-events
- Server event parameters: https://developers.facebook.com/documentation/ads-commerce/conversions-api/parameters/server-event
- Marketing API / Insights y Lead Ads: https://developers.facebook.com/docs/marketing-apis/

## Límite de la alineación

El modelo no envía datos por sí mismo. La implementación deberá validar la versión vigente de la API, permisos, términos de plataforma, minimización, consentimiento y restricciones locales antes de activar cualquier evento.
