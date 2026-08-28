# Vistas frontend añadidas en v3.7

El módulo 30 añade contratos de lectura para que el frontend no consulte tablas operativas
ni modele joins complejos en el navegador.

## ERP

- Business Partner 360.
- Cola de ciclo de vida contractual.
- Cola de obligaciones y vencimientos.
- Matching procure-to-pay.
- Rollforward de activos.
- Maduración de pasivos.
- Trazabilidad de línea de diario.

## CRM

- Cuenta 360.
- Timeline unificado de actividades.
- Bandeja de tareas.
- Calendario de eventos.
- Cola de casos y SLA/milestones.
- Forecast de oportunidades.

Todas las vistas deben aplicar tenant, permisos y masking en backend; `available_actions_json`
se calcula por estado, ownership y autorización, no por lógica del frontend.
