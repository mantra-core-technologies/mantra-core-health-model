# Datos clínicos y resultados — arquitectura de datacenter internacional de salud

## Refuerzo del dominio diagnóstico

La cadena clínica queda explícita:

`ServiceRequest -> accession -> specimen/container -> custody -> work order/test -> analyzer message -> Observation -> DiagnosticReport -> verification -> release/critical notification`.

Para imagen médica:

`ServiceRequest/Procedure -> ImagingStudy -> Series -> Instance -> object location -> ImagingSelection/structured report -> DiagnosticReport`.

Los binarios DICOM permanecen en PACS/object storage. PostgreSQL conserva UIDs, hashes, versiones, cifrado, retención, legal hold, vínculos clínicos y provenance.

## Nuevo módulo 52

Incluye onboarding de fuentes, conexiones, batches/records, recursos canónicos versionados, identificadores, relaciones, bindings al dominio, timeline longitudinal, perfiles FHIR y validación, Master Patient Index con revisión humana, calidad, provenance, lineage, terminología, de-identificación, exports controlados y transformación OMOP.

## Estándares y referencias

- HL7 FHIR R5 Diagnostics: https://hl7.org/fhir/R5/diagnostics-module.html
- ServiceRequest: https://hl7.org/fhir/servicerequest.html
- DiagnosticReport: https://hl7.org/fhir/diagnosticreport.html
- ImagingStudy: https://hl7.org/fhir/imagingstudy.html
- DICOMweb: https://www.dicomstandard.org/using/dicomweb
- ISO 15189:2022: https://www.iso.org/standard/76677.html
- LOINC: https://loinc.org/get-started/what-loinc-is/
- OMOP CDM: https://ohdsi.github.io/CommonDataModel/

## Evaluación

La estructura ya cubre la base de un repositorio internacional interoperable y trazable. La conformidad real dependerá además de perfiles FHIR por país, vocabularios licenciados, reglas de laboratorio, PACS, políticas de privacidad, calidad operativa, ciberseguridad, RLS y pruebas de interoperabilidad.
