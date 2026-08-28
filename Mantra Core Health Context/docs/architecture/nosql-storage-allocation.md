# Asignación de datos a almacenamiento especializado — SALUD v4.0

## Regla central

PostgreSQL conserva la fuente de verdad transaccional para identidad, pacientes, profesionales, consentimientos, encuentros, observaciones clínicas validadas, procedimientos, inventarios, contratos, contabilidad, pagos, seguros, estados e idempotencia durable.

Los módulos 54–63 agregan stores especializados como proyecciones, documentos originales, caché, búsqueda, series temporales, vectores, archivos, grafos y analítica.

| Módulo | Responsabilidad | Datos principales | No debe decidir |
|---|---|---|---|
| 54 | Gobierno de stores | backends, placements, cifrado, residencia, retención | reglas clínicas/financieras |
| 55 | Documental | FHIR completo, bundles, webhooks, snapshots, contextos, CMS, IA | saldos, stock, estados canónicos |
| 56 | Redis | sesiones, OTP, rate limit, locks, caché, presencia, progreso | evidencia legal o clínica |
| 57 | OpenSearch | directorios, terminología, contenido, contratos, CRM, logs, búsqueda clínica autorizada | autorización definitiva |
| 58 | Series temporales | dispositivos, signos continuos, telemetría, tracking, métricas | observación clínica validada |
| 59 | Vector/RAG | chunks, embeddings, evidencia de recuperación | fuente documental original |
| 60 | Objetos/PACS | DICOM, PDFs, videos, payloads grandes, exportaciones | relaciones y estados de negocio |
| 61 | Grafo | relaciones multi-salto, referrals, fraude, redes | contratos/claims/pagos canónicos |
| 62 | Consistencia | outbox, checkpoints, drift, reparación, eliminación | mutación primaria del dominio |
| 63 | Lakehouse | bronze/silver/gold, data products, investigación | operación online |

## Flujo de escritura

1. La mutación del dominio y el evento outbox se confirman en una transacción PostgreSQL.
2. Un worker persistente consume el evento al menos una vez.
3. El target recibe una escritura idempotente por event id, entity id, version y payload hash.
4. El checkpoint avanza solo después de la escritura durable.
5. Reconciliaciones periódicas detectan faltantes, huérfanos y hashes divergentes.

## Datos clínicos

- Lectura cruda de dispositivo → módulo 58.
- Normalización y control de calidad → módulo 58/52.
- Observación clínicamente validada → PostgreSQL `clinical.observations`.
- Documento FHIR completo original/versionado → módulo 55.
- DICOM y medios binarios → módulo 60.
- Timeline y relaciones canónicas → PostgreSQL módulo 52.

## Prohibiciones

- No hacer dual write directo desde un caso de uso a PostgreSQL y otro store.
- No usar Redis como única copia.
- No enviar PHI cruda a índices de búsqueda o publicidad.
- No mantener embeddings después de eliminar o revocar su fuente.
- No eliminar objetos bajo legal hold o WORM.
