# Intervenciones médicas, operaciones y perioperatorio

## Corrección del núcleo clínico

`clinical.procedures` conserva sus campos anteriores y añade solicitud origen, procedimiento padre, categoría, razón de estado, ubicación, recorder, outcome, rango temporal, follow-up y reporte operatorio.

## Nuevo módulo 53

Modela:

- caso y número operatorio;
- diagnósticos y equipo;
- ubicaciones, estados y milestones;
- evaluación y riesgo preoperatorio;
- órdenes previas;
- checklist de seguridad por fases y respuestas inmutables;
- plan y eventos de anestesia;
- pasos y hallazgos operatorios;
- sitios corporales, performers, equipos, implantes y UDI/lot/serial;
- medicamentos, especímenes y complicaciones;
- reporte operatorio versionado y firmado;
- PACU, órdenes posteriores, seguimiento y outcomes;
- cancelaciones, cargos, utilización de quirófano y esterilidad.

## Fuentes

- HL7 FHIR R5 ServiceRequest/Procedure: https://hl7.org/fhir/servicerequest.html
- FHIR diagnostics/workflow relationships: https://hl7.org/fhir/R5/diagnostics-module.html
- WHO Surgical Safety Checklist: https://www.who.int/teams/integrated-health-services/patient-safety/research/safe-surgery/tool-and-resources

## Regla de seguridad clínica

Los checks obligatorios no se sobrescriben: se registran respuestas inmutables y cualquier excepción exige motivo. Las transiciones que bloquean o permiten la cirugía deberán configurarse en el módulo workflow y validarse en backend.
