# Correcciones estructurales aplicadas

## Identidad

`iam.users` representa cuentas autenticables. `profiles.persons` representa humanos.
`person_account_links` es opcional y versionado. Los perfiles de paciente y profesional
dependen de una persona, no de una cuenta.

## Custodia clínica

Los agregados clínicos que pueden existir sin `encounter_id` incluyen
`custodian_tenant_id`. Los hijos heredan custodia por constraint y no pueden cruzar
tenants. La aplicación debe combinar RLS, propósito de uso, permisos, privacidad y
emergencia documentada.

## Privacidad y consentimiento

El modelo separa propósito, base legal general, condición especial, directiva de
consentimiento, autorización, consentimiento informado, restricción y objeción.
La decisión de acceso no depende de un único `consent_id`.

## Estados

El módulo 32 declara definición, estados, transiciones, permisos, guards, efectos,
idempotencia y eventos. Los servicios no pueden inventar transiciones fuera del modelo.

## Comunidad

`comments`, `reactions` y `social_follows` son las tablas canónicas. Se eliminaron las
variantes redundantes específicas de posts/topics/perfiles.

## Vistas para frontend

Las vistas se organizan por portal y contienen códigos estables, labels, tonos,
acciones derivadas, metadatos de frescura y proyecciones específicas. No se exponen
modelos ORM ni columnas sensibles innecesarias.
