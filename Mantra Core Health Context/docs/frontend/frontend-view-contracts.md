# Contratos de vistas para frontend

El módulo 30 incorpora metadatos configurables y proyecciones por portal.

## Metadatos de página

- rutas y navegación;
- permisos, propósito y contexto de tenant/paciente;
- read model versionado;
- campos y componentes de presentación;
- filtros allow-list y parámetros URL;
- opciones de ordenamiento con desempate estable;
- acciones permitidas derivadas del estado;
- KPI y drilldowns;
- estados loading, empty, stale, forbidden, offline y error;
- preferencias personales sin alterar reglas de seguridad.

## Principios de consumo

- El frontend consume DTO/proyecciones, no entidades completas.
- Las listas usan cursor pagination y cancelación.
- `available_actions_json` orienta la UI, pero cada comando vuelve a autorizarse.
- Los labels/tonos son datos de presentación; los códigos son contratos estables.
- Un `404` protegido no filtra la existencia de registros fuera del alcance.
- Los archivos usan URI estable; la URL firmada se solicita después de autorizar.
- Las vistas materializadas con PII/PHI mantienen la misma frontera de autorización.
