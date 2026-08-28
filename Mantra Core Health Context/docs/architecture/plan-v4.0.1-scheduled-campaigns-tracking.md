# PLAN maestro v4.0.1 — Envíos programados · Administración del sitio · Tracking multicanal (NORMATIVO)

> **Rol en nuestro contexto:** documento **normativo fuente** incorporado a nivel de **diseño** en SALUD **v4.0.1**.
> Es la fuente de los `§` que referencia [`patch-v4.0.1-scheduled-campaigns-tracking.md`](patch-v4.0.1-scheduled-campaigns-tracking.md) (los 37 casos de uso).
> Archivo fuente: `SALUD_v4.0_plan_correccion_envios_programados_tracking_admin_sitio.md` (v1.0.0, 2026-07-19).
>
> ## Reconciliación con el modelo canónico (v4.0)
> - **Base real:** SALUD **v4.0** (64 módulos). El propio plan (§7) ya advierte que "el modelo entregado todavía identifica algunos artefactos como v3.9"; aquí se fija **v4.0.1** como versión de destino.
> - **Nombres canónicos:** este plan usa `outbox` de forma genérica y no introduce los choques `audit_events`/`outbox_events` del patch; en nuestro modelo la auditoría vive en **`audit.audit_log`** y el outbox en **`messaging.outbox_messages`**.
> - **Entidades nuevas (planned v4.0.1, aún NO materializadas en los ER `diagram_*.puml`):** `marketing.campaign_schedules`, `campaign_dispatches`, `campaign_dispatch_recipients`; `crm.contact_channel_endpoints`; `messaging.adapter_tracking_capabilities`, `adapter_event_mappings`, `adapter_inbound_events`, `delivery_tracking_events`, `delivery_status_transitions`, `delivery_reconciliation_runs`; `authz.service_principals`; read models `campaign_dispatch_summary`, `recipient_delivery_timeline`, `adapter_health_summary`. Extensiones de: `marketing_campaigns`, `campaign_members`, `marketing_touchpoints`, `notification_requests`, `notification_deliveries`, `in_app_notifications`, `messaging_providers`, `provider_channel_configs`, `automation_triggers`.
> - **Materialización en los ER `diagram_*.puml` (§24):** pendiente como paso posterior explícito; no se editó el modelo canónico para no alterar los `.puml` validados.
> - **Representación en el grafo:** las 14 entidades, 9 extensiones, 37 casos de uso, value sets, 7 workers y 3 máquinas de estado se materializan como **notas Obsidian** enlazadas (ver `SALUD/Patch v4.0.1/`).
>
> El resto de este documento es el plan íntegro.

---


**Estado del documento:** Plan de corrección propuesto para aprobación técnica y funcional  
**Versión:** 1.0.0  
**Fecha:** 2026-07-19  
**Ámbito principal:** `marketing`, `messaging`, `automation`, `authz`, `iam`, `audit`, `consent`, `crm` y proyecciones de lectura  
**Fuente revisada:** modelo SALUD v4.0 entregado, cuyo contenido interno todavía identifica algunos artefactos como v3.9  
**Objetivo de seguridad no negociable:** únicamente usuarios humanos pertenecientes a **Administración del sitio** podrán crear, configurar, aprobar, programar, iniciar, pausar, reanudar, cancelar o reintentar campañas y envíos masivos o programados.  
**Objetivo operativo no negociable:** toda notificación deberá disponer de trazabilidad completa desde la campaña hasta el resultado final conocido, usando un modelo canónico independiente del proveedor y extensible por adaptador.  
**Adaptador obligatorio en la primera entrega:** mensajería interna dentro de la aplicación.

---

## 1. Resumen ejecutivo

El modelo actual ya contiene piezas importantes:

- `marketing.marketing_campaigns`, `segments`, `campaign_members`, `journeys` y `journey_steps`.
- `automation.automation_triggers.schedule_cron`, `workflows` y `workflow_runs`.
- `messaging.notification_requests.scheduled_at`, `notification_deliveries`, `delivery_receipts`, colas, outbox, reintentos y dead-letter.
- `messaging.in_app_notifications` para mensajes internos.
- `authz.roles`, `permissions`, `role_permissions`, `user_role_assignments`, `user_permission_grants` y políticas de acceso.
- `audit` para registrar actividad sensible.

Sin embargo, esas piezas no cierran por sí solas un flujo institucional de producción. La primera versión permite representar parcialmente una campaña y una solicitud futura de notificación, pero no define de forma inequívoca:

1. quién puede ordenar el envío;
2. cómo se prohíbe que otro rol obtenga ese privilegio por una concesión directa;
3. cómo se representa una programación recurrente con zona horaria;
4. cómo se congela la audiencia exacta de cada ejecución;
5. cómo se evita enviar dos veces al mismo destinatario;
6. cómo se vincula la campaña con cada solicitud y cada intento de entrega;
7. cómo se normalizan estados diferentes de proveedores distintos;
8. cómo se recibe, valida, deduplica y conserva un evento de tracking;
9. cómo se implementa mensajería interna como un adaptador real, no como un flujo paralelo;
10. cómo se consulta qué ocurrió con una notificación sin reconstruirlo de varias tablas ambiguas.

La corrección propuesta convierte los tres módulos existentes en una única cadena gobernada:

```text
Administración del sitio
        ↓
Campaña y programación aprobadas
        ↓
Ejecución o dispatch inmutable
        ↓
Snapshot de destinatarios y consentimientos
        ↓
Solicitud de notificación idempotente
        ↓
Intento mediante adaptador
        ↓
Eventos de tracking canónicos
        ↓
Estado actual + historial + métricas + auditoría
```

El módulo `tracking` existente no debe reutilizarse para este propósito, porque está orientado a trazabilidad logística de envíos físicos, hitos, transportistas y pruebas de entrega. La trazabilidad de comunicaciones debe permanecer dentro de `messaging`, con proyecciones analíticas hacia `read_models` o `reporting`.

---

## 2. Decisiones normativas del plan

Las siguientes decisiones se consideran parte del objetivo solicitado y deben implementarse sin excepciones funcionales.

### 2.1. Autoridad humana exclusiva

Se define el rol funcional y técnico:

```text
Código propuesto: SITE_ADMINISTRATION
Nombre visible: Administración del sitio
Ámbito: plataforma completa
Tipo: rol de sistema
```

Solo una sesión humana activa con este rol podrá ejecutar operaciones de gobierno de campañas y envíos.

No será suficiente:

- ser doctor;
- ser director médico;
- ser administrador de consultorio;
- ser administrador de tenant;
- ser usuario de marketing;
- ser operador de CRM;
- poseer acceso de lectura a campañas;
- recibir una concesión individual genérica mediante `user_permission_grants`;
- conocer el endpoint;
- enviar una petición directamente sin pasar por el panel.

### 2.2. Separación entre decisión humana y ejecución técnica

La exclusividad anterior no significa que un worker necesite una sesión humana abierta durante cada envío.

La regla correcta será:

- **Administración del sitio decide y autoriza.**
- **El worker ejecuta únicamente una orden previamente persistida, autorizada e inmutable.**
- El worker no puede crear campañas, cambiar destinatarios, modificar contenido aprobado ni adelantar fechas.
- La identidad de servicio del worker tendrá permisos técnicos mínimos y acotados a un `campaign_dispatch_id` válido.
- Toda ejecución técnica conservará la referencia al usuario de Administración del sitio que publicó o programó la campaña.

### 2.3. Mensajería interna como adaptador oficial

`in_app_notifications` no debe funcionar como una excepción desconectada del modelo general.

Debe existir un adaptador incorporado:

```text
provider_code: INTERNAL_APP
channel_code: IN_APP
adapter_code: INTERNAL_APP_V1
```

Este adaptador usará la misma cadena de:

- `notification_requests`;
- `notification_deliveries`;
- eventos normalizados;
- tracking;
- idempotencia;
- auditoría;
- métricas;
- retención.

La tabla `in_app_notifications` será la proyección operativa visible para la bandeja del usuario, pero no reemplazará la solicitud, el intento ni el historial canónico.

### 2.4. Modelo de tracking independiente del proveedor

Cada proveedor o adaptador puede reportar estados distintos. El sistema no debe guardar únicamente un texto externo en `provider_status` y obligar a la aplicación a interpretarlo cada vez.

La base de datos debe distinguir tres capas:

1. **Evento externo o interno crudo:** evidencia exacta recibida.
2. **Evento canónico normalizado:** significado común dentro de SALUD.
3. **Estado actual derivado:** estado operativo más reciente y válido de la entrega.

### 2.5. Fuente de verdad

- El historial append-only de eventos será la fuente de verdad de tracking.
- `notification_deliveries.status_concept_id` será una proyección del estado actual.
- Los contadores de campaña serán derivados, nunca la única evidencia.
- Ningún estado anterior se eliminará para “actualizar” una notificación.

---

## 3. Alcance funcional

### 3.1. Incluido

- Campañas de un solo envío.
- Campañas recurrentes.
- Envíos desde journeys.
- Programación por fecha y hora.
- Programación cron gobernada.
- Zona horaria explícita.
- Ventanas horarias permitidas.
- Pausa, reanudación y cancelación.
- Snapshot de audiencia.
- Evaluación de consentimiento y supresiones.
- Mensajería interna.
- Base extensible para correo, SMS, WhatsApp, push y otros adaptadores.
- Tracking por campaña, ejecución, destinatario, solicitud, entrega, intento y evento.
- Eventos provenientes de webhook, polling, callback interno o acción del usuario.
- Deducción del estado actual.
- Idempotencia y reintentos.
- Auditoría completa.
- Dashboard y endpoints de consulta.
- Seguridad para que únicamente Administración del sitio gobierne el envío.

### 3.2. No incluido en esta corrección

- Implementación real de un proveedor externo específico.
- Compra o negociación de licencias con proveedores.
- Creación de campañas basadas en diagnósticos o datos clínicos.
- Uso de PHI para segmentación de marketing.
- Motor de recomendación clínica.
- Sustitución del módulo logístico `tracking`.
- Diseño visual definitivo del panel; el plan sí define contratos y controles mínimos.
- Envíos realizados desde cuentas personales de médicos.

---

## 4. Diagnóstico de la primera versión

### 4.1. Fortalezas existentes

#### `marketing`

La primera versión ya dispone de:

- segmentos;
- miembros de segmentos;
- campañas;
- miembros de campañas;
- plantillas de contenido;
- journeys;
- pasos de journey;
- enrollments;
- links rastreables;
- touchpoints;
- atribución.

#### `messaging`

Ya dispone de:

- eventos de dominio;
- transactional outbox;
- suscripciones;
- colas;
- jobs;
- dead-letter;
- canales;
- proveedores;
- configuraciones por canal;
- plantillas;
- solicitudes;
- entregas;
- recibos;
- preferencias;
- notificaciones internas.

#### `automation`

Ya dispone de:

- workflows;
- pasos;
- triggers;
- `schedule_cron`;
- ejecuciones;
- trazabilidad de agentes;
- aprobaciones;
- atribución de acciones automatizadas.

#### `authz`

Ya dispone de:

- roles;
- permisos;
- permisos por rol;
- asignaciones de usuario;
- concesiones individuales;
- restricciones por recurso;
- políticas de acceso.

### 4.2. Brechas que deben corregirse

| Brecha | Riesgo | Corrección principal |
|---|---|---|
| `start_at` y `end_at` no constituyen una programación completa | ejecuciones ambiguas o irrepetibles | `campaign_schedules` |
| No existe una corrida explícita de campaña | no se sabe qué ocurrió en cada fecha | `campaign_dispatches` |
| No se congela la audiencia | inconsistencias y falta de evidencia | `campaign_dispatch_recipients` |
| `recipient_user_id` es obligatorio | contactos externos sin usuario no pueden recibir | endpoint de destinatario polimórfico controlado |
| Campaña y solicitud se relacionan débilmente | trazabilidad incompleta | FK directa desde recipient/dispatch a request |
| `delivery_receipts` es demasiado genérica | cada proveedor se interpreta de manera distinta | eventos crudos, mappings y eventos canónicos |
| `in_app_notifications` funciona en paralelo | tracking parcial | adaptador interno integrado |
| Permisos existentes podrían concederse individualmente | bypass de Administración del sitio | permisos protegidos + política no delegable |
| No hay semántica formal de estado | estados contradictorios | máquina de estados canónica |
| No hay control de eventos fuera de orden | regresión de estado | reglas de precedencia y reconciliación |
| No hay ledger de programación | duplicación por reintento | claves idempotentes por ocurrencia |
| No hay endpoint de vista completa | consultas costosas y confusas | read model de tracking |

---

## 5. Modelo de autorización exclusivo

## 5.1. Principio de seguridad

La autorización debe aplicarse en cuatro niveles simultáneos:

1. ocultamiento del panel para usuarios no autorizados;
2. guard o middleware en cada endpoint;
3. validación de dominio dentro del service/caso de uso;
4. restricciones de persistencia y auditoría para impedir bypass por concesiones directas.

La interfaz por sí sola nunca será una barrera de seguridad.

## 5.2. Categoría de permisos

Agregar a `authz.permission_categories`:

```json
{
  "code": "SITE_MESSAGING_GOVERNANCE",
  "name": "Gobierno de campañas y mensajería del sitio",
  "description": "Operaciones sensibles de creación, aprobación, programación, ejecución y seguimiento de comunicaciones institucionales."
}
```

## 5.3. Permisos propuestos

### Gobierno de campañas

```text
site.marketing.campaign.create
site.marketing.campaign.read
site.marketing.campaign.update_draft
site.marketing.campaign.validate
site.marketing.campaign.publish
site.marketing.campaign.schedule
site.marketing.campaign.pause
site.marketing.campaign.resume
site.marketing.campaign.cancel
site.marketing.campaign.clone
site.marketing.campaign.archive
```

### Gobierno de audiencia

```text
site.marketing.segment.create
site.marketing.segment.update
site.marketing.segment.preview
site.marketing.segment.freeze
site.marketing.recipient.suppress
site.marketing.recipient.override_suppression
```

El último permiso debe marcarse como peligroso y requerir motivo auditado. No debe permitir anular ausencia de consentimiento legal.

### Gobierno de plantillas

```text
site.messaging.template.create
site.messaging.template.update_draft
site.messaging.template.publish
site.messaging.template.retire
site.messaging.template.preview
```

### Gobierno de adaptadores

```text
site.messaging.adapter.read
site.messaging.adapter.configure
site.messaging.adapter.enable
site.messaging.adapter.disable
site.messaging.adapter.rotate_credentials
site.messaging.adapter.test_delivery
```

### Operación de envíos

```text
site.messaging.dispatch.create
site.messaging.dispatch.start
site.messaging.dispatch.pause
site.messaging.dispatch.resume
site.messaging.dispatch.cancel
site.messaging.dispatch.retry_failed
site.messaging.dispatch.reconcile
```

### Tracking

```text
site.messaging.tracking.read
site.messaging.tracking.export
site.messaging.tracking.view_raw_event
site.messaging.tracking.reprocess_event
site.messaging.tracking.correct_mapping
```

`view_raw_event`, `reprocess_event` y `correct_mapping` deberán ser peligrosos.

## 5.4. Rol de sistema

Agregar o normalizar `authz.roles`:

```json
{
  "code": "SITE_ADMINISTRATION",
  "name": "Administración del sitio",
  "tenant_id": null,
  "is_system": true,
  "is_assignable": true,
  "scope": "platform"
}
```

### Regla de asignación

- El rol solo podrá asignarse desde un flujo de seguridad de plataforma.
- La asignación debe exigir MFA reciente.
- Debe guardarse `assigned_by_user_id`, motivo y vigencia.
- No se asignará automáticamente a un administrador de tenant.
- No se heredará desde roles clínicos.
- No se derivará de pertenencia a una organización médica.

## 5.5. Permisos protegidos y no delegables

El modelo actual tiene `user_permission_grants`. Sin una restricción adicional, un usuario podría recibir una concesión directa y eludir el rol.

Se debe introducir una de estas dos soluciones. Se recomienda la primera.

### Solución recomendada: atributo de permiso protegido

Agregar a `authz.permissions`:

```text
is_role_restricted : boolean NOT NULL DEFAULT false
required_role_code : varchar NULL
allow_direct_user_grant : boolean NOT NULL DEFAULT true
```

Para todos los permisos de envío:

```text
is_role_restricted = true
required_role_code = 'SITE_ADMINISTRATION'
allow_direct_user_grant = false
```

Agregar constraints o triggers para rechazar:

- inserciones en `user_permission_grants` sobre permisos no delegables;
- `role_permissions` para cualquier rol distinto a `SITE_ADMINISTRATION`;
- cambios que vuelvan delegable un permiso protegido sin una migración administrativa explícita.

### Solución alternativa

Crear una tabla `authz.protected_permission_policies`. Solo debe usarse si no se desea modificar `permissions`.

## 5.6. Política de acceso adicional

Crear una `access_policy` de denegación por defecto para recursos:

```text
marketing.campaigns
marketing.campaign_schedules
marketing.campaign_dispatches
marketing.campaign_dispatch_recipients
messaging.message_templates
messaging.provider_channel_configs
messaging.notification_requests cuando source='marketing'
messaging.delivery_tracking_events
```

La política permitirá mutaciones únicamente cuando:

```text
authenticated = true
session_mfa_age <= límite configurado
role_code contains SITE_ADMINISTRATION
role_scope = platform
account_state = active
session_state = active
```

## 5.7. Identidad técnica de workers

Crear una identidad de servicio, no humana:

```text
service_principal_code: SITE_MESSAGING_WORKER
```

Puede:

- reclamar schedules vencidos;
- crear dispatches desde schedules publicados;
- materializar destinatarios ya autorizados;
- crear requests;
- ejecutar delivery attempts;
- persistir tracking;
- reconciliar eventos.

No puede:

- crear campañas nuevas;
- cambiar contenido;
- cambiar segmento;
- publicar un draft;
- cambiar consentimiento;
- asignar roles;
- modificar configuraciones de adaptadores;
- enviar algo sin `authorized_by_user_id` de Administración del sitio.

## 5.8. Regla de atribución

Todo objeto ejecutable deberá guardar como mínimo:

```text
created_by_user_id
updated_by_user_id
published_by_user_id
scheduled_by_user_id
authorized_by_user_id
cancelled_by_user_id
```

Cuando el worker cree una fila derivada:

- `created_by_user_id` podrá ser la identidad técnica;
- `authorized_by_user_id` deberá ser el usuario humano que autorizó la campaña;
- `authorization_snapshot_json` conservará rol, tenant, sesión y versión de permisos relevantes.

---

## 6. Correcciones al esquema `marketing`

## 6.1. Nueva entidad `campaign_schedules`

### Propósito

Representar una programación formal, versionada y auditable asociada a una campaña o journey.

### Campos propuestos

```text
campaign_schedules
- id uuid PK
- tenant_id uuid FK NULL cuando el alcance sea global
- campaign_id uuid FK NULL
- journey_id uuid FK NULL
- schedule_type_concept_id uuid FK NOT NULL
- timezone_name varchar NOT NULL
- scheduled_once_at timestamptz NULL
- cron_expression varchar NULL
- recurrence_rule_json jsonb NULL
- valid_from timestamptz NOT NULL
- valid_until timestamptz NULL
- allowed_weekdays_json jsonb NULL
- allowed_time_window_json jsonb NULL
- missed_run_policy_concept_id uuid FK NOT NULL
- overlap_policy_concept_id uuid FK NOT NULL
- next_run_at timestamptz NULL
- last_run_at timestamptz NULL
- max_occurrences integer NULL
- completed_occurrences integer NOT NULL DEFAULT 0
- status_concept_id uuid FK NOT NULL
- schedule_version integer NOT NULL
- published_content_hash varchar NOT NULL
- published_audience_hash varchar NOT NULL
- authorized_by_user_id uuid FK NOT NULL
- authorized_at timestamptz NOT NULL
- authorization_snapshot_json jsonb NOT NULL
- created_at timestamptz NOT NULL
- updated_at timestamptz NOT NULL
- created_by_user_id uuid FK NOT NULL
- updated_by_user_id uuid FK NOT NULL
- row_version integer NOT NULL
```

### Constraints

```text
CHECK exactly_one(campaign_id, journey_id)
CHECK schedule_type=once -> scheduled_once_at IS NOT NULL
CHECK schedule_type=cron -> cron_expression IS NOT NULL
CHECK valid_until IS NULL OR valid_until > valid_from
CHECK max_occurrences IS NULL OR max_occurrences > 0
CHECK timezone_name pertenece a catálogo IANA permitido
UNIQUE(campaign_id, schedule_version)
```

### Value sets

```text
vs_campaign_schedule_type {once, cron, recurrence_rule, event_date}
vs_missed_run_policy {skip, run_once_immediately, reschedule_next}
vs_overlap_policy {forbid, skip_new, queue_new}
vs_campaign_schedule_status {draft, validated, scheduled, paused, completed, cancelled, invalid}
```

No se recomienda `run_all_missed`, porque podría producir una ráfaga peligrosa tras una caída prolongada.

## 6.1.1. Fuente única de programación e integración con `automation`

No deben existir dos cron independientes para la misma campaña.

La fuente de verdad para campañas será `marketing.campaign_schedules`. El campo actual `automation.automation_triggers.schedule_cron` continuará disponible para automatizaciones no relacionadas con marketing, pero no duplicará el horario de una campaña.

Para integrar ambos módulos se propone extender `automation_triggers` con:

```text
- campaign_schedule_id uuid FK NULL
- schedule_source_concept_id uuid FK NOT NULL
```

Reglas:

```text
schedule_source='campaign_schedule' -> campaign_schedule_id IS NOT NULL AND schedule_cron IS NULL
schedule_source='native_cron' -> campaign_schedule_id IS NULL AND schedule_cron IS NOT NULL
```

Cuando un schedule de marketing vence:

1. el scheduler de campañas crea el `campaign_dispatch` idempotente;
2. opcionalmente publica un evento de dominio `marketing.campaign_dispatch.created`;
3. `automation` puede consumir ese evento para ejecutar un workflow complementario;
4. el workflow no vuelve a calcular el cron ni crea una segunda ocurrencia;
5. el `workflow_run.context_ref_id` apunta al `campaign_dispatch.id`.

Esta separación evita:

- dos workers compitiendo por la misma fecha;
- horarios divergentes entre `marketing` y `automation`;
- duplicación de envíos;
- dificultad para pausar o cancelar una sola fuente.

## 6.2. Nueva entidad `campaign_dispatches`

### Propósito

Representar cada ejecución concreta de una campaña.

### Campos propuestos

```text
campaign_dispatches
- id uuid PK
- tenant_id uuid FK NULL
- campaign_id uuid FK NOT NULL
- schedule_id uuid FK NULL
- journey_id uuid FK NULL
- journey_step_id uuid FK NULL
- occurrence_key varchar NOT NULL
- planned_at timestamptz NOT NULL
- audience_snapshot_at timestamptz NULL
- started_at timestamptz NULL
- finished_at timestamptz NULL
- status_concept_id uuid FK NOT NULL
- source_concept_id uuid FK NOT NULL
- content_template_id uuid FK NOT NULL
- content_template_version integer NOT NULL
- content_hash varchar NOT NULL
- audience_definition_hash varchar NOT NULL
- total_candidates bigint NOT NULL DEFAULT 0
- total_eligible bigint NOT NULL DEFAULT 0
- total_suppressed bigint NOT NULL DEFAULT 0
- total_requests bigint NOT NULL DEFAULT 0
- total_accepted bigint NOT NULL DEFAULT 0
- total_delivered bigint NOT NULL DEFAULT 0
- total_seen bigint NOT NULL DEFAULT 0
- total_read bigint NOT NULL DEFAULT 0
- total_failed bigint NOT NULL DEFAULT 0
- total_cancelled bigint NOT NULL DEFAULT 0
- idempotency_key varchar NOT NULL
- authorized_by_user_id uuid FK NOT NULL
- authorization_snapshot_json jsonb NOT NULL
- failure_code varchar NULL
- failure_detail text NULL
- created_at timestamptz NOT NULL
- updated_at timestamptz NOT NULL
- created_by_user_id uuid FK NOT NULL
- updated_by_user_id uuid FK NOT NULL
- row_version integer NOT NULL
```

### Constraints

```text
UNIQUE(idempotency_key)
UNIQUE(schedule_id, occurrence_key) WHERE schedule_id IS NOT NULL
CHECK counters >= 0
CHECK total_eligible + total_suppressed <= total_candidates
CHECK finished_at IS NULL OR started_at IS NOT NULL
```

### Estados

```text
planned
snapshotting
ready
queued
running
partially_completed
completed
paused
cancelling
cancelled
failed
expired
```

## 6.3. Nueva entidad `campaign_dispatch_recipients`

### Propósito

Congelar la audiencia real de una ejecución, incluyendo la razón por la que una persona fue incluida o excluida.

### Campos propuestos

```text
campaign_dispatch_recipients
- id uuid PK
- dispatch_id uuid FK NOT NULL
- member_type_concept_id uuid FK NOT NULL
- member_ref_id uuid NOT NULL
- recipient_endpoint_id uuid FK NULL
- recipient_user_id uuid FK NULL
- channel_id uuid FK NOT NULL
- language_concept_id uuid FK NULL
- timezone_name varchar NULL
- consent_id uuid FK NULL
- consent_status_concept_id uuid FK NOT NULL
- preference_snapshot_json jsonb NULL
- eligibility_status_concept_id uuid FK NOT NULL
- suppression_reason_concept_id uuid FK NULL
- suppression_detail varchar NULL
- scheduled_at timestamptz NOT NULL
- notification_request_id uuid FK NULL
- current_delivery_id uuid FK NULL
- current_status_concept_id uuid FK NOT NULL
- idempotency_key varchar NOT NULL
- snapshot_json jsonb NOT NULL
- created_at timestamptz NOT NULL
- updated_at timestamptz NOT NULL
- created_by_user_id uuid FK NOT NULL
- updated_by_user_id uuid FK NOT NULL
- row_version integer NOT NULL
```

### Constraints

```text
UNIQUE(dispatch_id, member_type_concept_id, member_ref_id, channel_id)
UNIQUE(idempotency_key)
CHECK recipient_user_id IS NOT NULL OR recipient_endpoint_id IS NOT NULL
CHECK eligibility='suppressed' -> suppression_reason IS NOT NULL
CHECK eligibility='eligible' -> suppression_reason IS NULL
```

### Motivos de supresión mínimos

```text
no_consent
opted_out
do_not_contact
invalid_endpoint
unverified_endpoint
quiet_hours
frequency_cap
recipient_inactive
duplicate_recipient
campaign_cancelled
legal_hold
content_restriction
```

`quiet_hours` normalmente debe reprogramar, no excluir definitivamente. El comportamiento debe depender de una política explícita.

## 6.4. Extensión de `marketing_campaigns`

Agregar:

```text
- governance_scope_concept_id
- requires_explicit_publish boolean DEFAULT true
- published_version integer NULL
- published_at timestamptz NULL
- published_by_user_id uuid FK NULL
- approved_content_hash varchar NULL
- approved_audience_hash varchar NULL
- cancellation_reason varchar NULL
- cancelled_at timestamptz NULL
- cancelled_by_user_id uuid FK NULL
```

### Invariantes

- Una campaña `draft` puede editarse.
- Una campaña publicada no puede cambiar contenido ni audiencia en sitio.
- Un cambio posterior crea una nueva versión y requiere nueva publicación.
- Un schedule solo puede apuntar a una versión publicada.
- La cancelación no elimina registros.

## 6.5. Extensión de `campaign_members`

No debe utilizarse como evidencia final de una ejecución. Su función seguirá siendo representar pertenencia general a la campaña.

Agregar opcionalmente:

```text
- source_segment_member_id
- first_dispatch_id
- last_dispatch_id
- total_dispatches integer
```

Estos campos son derivados y no sustituyen `campaign_dispatch_recipients`.

## 6.6. Extensión de `marketing_touchpoints`

Agregar referencias directas:

```text
- dispatch_id uuid FK
- dispatch_recipient_id uuid FK
- notification_request_id uuid FK
- notification_delivery_id uuid FK
- tracking_event_id uuid FK
```

Esto permitirá atribuir apertura, lectura, clic, respuesta o conversión a una entrega específica.

---

## 7. Correcciones al esquema `crm` para endpoints de destinatarios

## 7.1. Problema actual

`notification_requests.recipient_user_id` es obligatorio. Esto impide tratar correctamente contactos o leads sin cuenta en IAM.

## 7.2. Nueva entidad `contact_channel_endpoints`

### Propósito

Guardar direcciones de contacto verificadas y gobernadas sin forzar una cuenta de usuario.

```text
contact_channel_endpoints
- id uuid PK
- tenant_id uuid FK NULL
- contact_id uuid FK NULL
- lead_id uuid FK NULL
- user_id uuid FK NULL
- endpoint_type_concept_id uuid FK NOT NULL
- normalized_value varchar NOT NULL
- masked_display_value varchar NOT NULL
- value_hash varchar NOT NULL
- is_primary boolean NOT NULL DEFAULT false
- verification_status_concept_id uuid FK NOT NULL
- verified_at timestamptz NULL
- deliverability_status_concept_id uuid FK NOT NULL
- last_success_at timestamptz NULL
- last_failure_at timestamptz NULL
- do_not_contact boolean NOT NULL DEFAULT false
- valid_from timestamptz NOT NULL
- valid_to timestamptz NULL
- state_concept_id uuid FK NOT NULL
- created_at timestamptz NOT NULL
- updated_at timestamptz NOT NULL
- created_by_user_id uuid FK NOT NULL
- updated_by_user_id uuid FK NOT NULL
- row_version integer NOT NULL
```

### Constraints

```text
CHECK exactly_one(contact_id, lead_id, user_id)
UNIQUE(endpoint_type_concept_id, value_hash, tenant_scope_normalizado)
```

El valor normalizado debe cifrarse o protegerse según sensibilidad. El hash se usa para deduplicación, no como sustituto de cifrado.

## 7.3. Destinatario canónico

`notification_requests` debe aceptar:

```text
recipient_type_concept_id
recipient_ref_id
recipient_endpoint_id
recipient_user_id NULL
recipient_address_encrypted NULL
recipient_address_hash NULL
```

Para `IN_APP`, `recipient_user_id` será obligatorio. Para canales externos, será válido un endpoint verificado.

---

## 8. Correcciones al esquema `messaging`

## 8.1. Objetivo del rediseño

Conservar las tablas útiles existentes y añadir una capa de adaptadores y tracking formal.

## 8.2. Extensión de `messaging_providers`

Agregar:

```text
- adapter_code varchar NOT NULL
- adapter_version varchar NOT NULL
- is_builtin boolean NOT NULL DEFAULT false
- supports_webhooks boolean NOT NULL DEFAULT false
- supports_polling boolean NOT NULL DEFAULT false
- supports_delivery_receipts boolean NOT NULL DEFAULT false
- supports_read_receipts boolean NOT NULL DEFAULT false
- supports_click_receipts boolean NOT NULL DEFAULT false
- supports_reply_receipts boolean NOT NULL DEFAULT false
- provider_time_semantics_concept_id uuid FK NULL
```

### Restricción

```text
UNIQUE(adapter_code, adapter_version)
```

## 8.3. Extensión de `provider_channel_configs`

Agregar:

```text
- adapter_config_version integer NOT NULL
- webhook_endpoint_key varchar NULL
- webhook_secret_credential_id uuid FK NULL
- webhook_signature_scheme_concept_id uuid FK NULL
- tracking_mode_concept_id uuid FK NOT NULL
- polling_interval_seconds integer NULL
- status_mapping_version integer NOT NULL
- enabled_at timestamptz NULL
- disabled_at timestamptz NULL
- enabled_by_user_id uuid FK NULL
- disabled_by_user_id uuid FK NULL
```

### Tracking modes

```text
internal_events
webhook
polling
hybrid
none
```

`none` solo podrá utilizarse si el proveedor no ofrece evidencia adicional. Aun así se registrarán estados locales `queued`, `attempted`, `accepted` o `failed`.

## 8.4. Nueva entidad `adapter_tracking_capabilities`

### Propósito

Declarar qué eventos puede producir un adaptador.

```text
adapter_tracking_capabilities
- id uuid PK
- provider_id uuid FK NOT NULL
- channel_id uuid FK NOT NULL
- canonical_event_type_concept_id uuid FK NOT NULL
- support_level_concept_id uuid FK NOT NULL
- evidence_source_concept_id uuid FK NOT NULL
- notes text NULL
- state_concept_id uuid FK NOT NULL
- created_at timestamptz NOT NULL
- updated_at timestamptz NOT NULL
- created_by_user_id uuid FK NOT NULL
- updated_by_user_id uuid FK NOT NULL
- row_version integer NOT NULL
```

### Support levels

```text
native
inferred
local_only
unsupported
```

Esto evita prometer “leído” en SMS cuando el proveedor no puede demostrarlo.

## 8.5. Nueva entidad `adapter_event_mappings`

### Propósito

Traducir estados del adaptador a eventos canónicos.

```text
adapter_event_mappings
- id uuid PK
- provider_id uuid FK NOT NULL
- channel_id uuid FK NOT NULL
- mapping_version integer NOT NULL
- external_event_code varchar NOT NULL
- canonical_event_type_concept_id uuid FK NOT NULL
- canonical_delivery_status_concept_id uuid FK NOT NULL
- terminal boolean NOT NULL DEFAULT false
- success boolean NULL
- precedence integer NOT NULL
- condition_json jsonb NULL
- effective_from timestamptz NOT NULL
- effective_to timestamptz NULL
- state_concept_id uuid FK NOT NULL
- created_at timestamptz NOT NULL
- updated_at timestamptz NOT NULL
- created_by_user_id uuid FK NOT NULL
- updated_by_user_id uuid FK NOT NULL
- row_version integer NOT NULL
```

### Constraints

```text
UNIQUE(provider_id, channel_id, mapping_version, external_event_code)
CHECK precedence >= 0
CHECK effective_to IS NULL OR effective_to > effective_from
```

Un mapping publicado no debe editarse. Se crea una versión nueva.

## 8.6. Extensión de `notification_requests`

Agregar:

```text
- dispatch_id uuid FK NULL
- dispatch_recipient_id uuid FK NULL
- recipient_type_concept_id uuid FK NOT NULL
- recipient_ref_id uuid NOT NULL
- recipient_endpoint_id uuid FK NULL
- source_concept_id uuid FK NOT NULL
- authorized_by_user_id uuid FK NOT NULL
- authorization_snapshot_json jsonb NOT NULL
- content_snapshot_json jsonb NOT NULL
- content_hash varchar NOT NULL
- idempotency_key varchar NOT NULL
- expires_at timestamptz NULL
- cancellation_requested_at timestamptz NULL
- cancelled_at timestamptz NULL
```

Cambiar:

```text
recipient_user_id: obligatorio -> nullable
```

### Constraints

```text
UNIQUE(idempotency_key)
CHECK channel=IN_APP -> recipient_user_id IS NOT NULL
CHECK channel!=IN_APP -> recipient_endpoint_id IS NOT NULL OR recipient_address_encrypted IS NOT NULL
CHECK scheduled_at < expires_at cuando expires_at no sea NULL
```

### Fuente

```text
marketing_campaign
journey
transactional
system_alert
manual_site_admin
appointment_reminder
```

Las reglas exclusivas de Administración del sitio se aplican a `marketing_campaign`, `journey` y `manual_site_admin`. Las notificaciones transaccionales propias del sistema tendrán permisos técnicos específicos y no se considerarán campañas administrables por médicos.

## 8.7. Extensión de `notification_deliveries`

Agregar:

```text
- provider_channel_config_id uuid FK NOT NULL
- adapter_code varchar NOT NULL
- adapter_version varchar NOT NULL
- started_at timestamptz NULL
- accepted_at timestamptz NULL
- delivered_at timestamptz NULL
- seen_at timestamptz NULL
- read_at timestamptz NULL
- clicked_at timestamptz NULL
- replied_at timestamptz NULL
- bounced_at timestamptz NULL
- failed_at timestamptz NULL
- cancelled_at timestamptz NULL
- expired_at timestamptz NULL
- terminal_at timestamptz NULL
- last_event_at timestamptz NULL
- last_event_id uuid FK NULL
- provider_status_raw varchar NULL
- provider_response_hash varchar NULL
```

Estas fechas son proyecciones convenientes. La evidencia sigue estando en los eventos append-only.

## 8.8. Nueva entidad `adapter_inbound_events`

### Propósito

Guardar la recepción técnica exacta de un webhook, callback, polling o evento interno antes de normalizarlo.

```text
adapter_inbound_events <<LOG>>
- id uuid PK
- provider_id uuid FK NOT NULL
- provider_channel_config_id uuid FK NOT NULL
- channel_id uuid FK NOT NULL
- ingestion_type_concept_id uuid FK NOT NULL
- external_event_id varchar NULL
- external_event_code varchar NOT NULL
- provider_message_ref varchar NULL
- payload_json_encrypted jsonb NULL
- payload_storage_ref varchar NULL
- payload_sha256 varchar NOT NULL
- headers_redacted_json jsonb NULL
- signature_status_concept_id uuid FK NOT NULL
- replay_status_concept_id uuid FK NOT NULL
- received_at timestamptz NOT NULL
- provider_occurred_at timestamptz NULL
- processing_status_concept_id uuid FK NOT NULL
- processing_attempts integer NOT NULL DEFAULT 0
- mapping_version integer NULL
- delivery_id uuid FK NULL
- normalization_error_code varchar NULL
- normalization_error_detail text NULL
- recorded_at timestamptz NOT NULL
```

### Constraints

```text
UNIQUE(provider_id, external_event_id) WHERE external_event_id IS NOT NULL
UNIQUE(provider_id, payload_sha256, received_time_bucket) para proveedores sin ID, según política
```

No se debe guardar un secreto de webhook ni headers de autorización sin redacción.

## 8.9. Nueva entidad `delivery_tracking_events`

### Propósito

Historial canónico e inmutable de lo ocurrido con una entrega.

```text
delivery_tracking_events <<LOG>>
- id uuid PK
- delivery_id uuid FK NOT NULL
- notification_request_id uuid FK NOT NULL
- dispatch_id uuid FK NULL
- dispatch_recipient_id uuid FK NULL
- inbound_event_id uuid FK NULL
- canonical_event_type_concept_id uuid FK NOT NULL
- resulting_status_concept_id uuid FK NOT NULL
- source_concept_id uuid FK NOT NULL
- provider_event_code varchar NULL
- provider_event_id varchar NULL
- provider_message_ref varchar NULL
- sequence_number bigint NULL
- occurred_at timestamptz NOT NULL
- received_at timestamptz NOT NULL
- effective_at timestamptz NOT NULL
- precedence integer NOT NULL
- is_terminal boolean NOT NULL DEFAULT false
- is_success boolean NULL
- is_late boolean NOT NULL DEFAULT false
- is_duplicate boolean NOT NULL DEFAULT false
- metadata_json jsonb NULL
- recorded_at timestamptz NOT NULL
- recorded_by_user_id uuid FK NULL
```

### Constraints

```text
UNIQUE(delivery_id, source_concept_id, provider_event_id) WHERE provider_event_id IS NOT NULL
UNIQUE(delivery_id, canonical_event_type_concept_id, sequence_number) WHERE sequence_number IS NOT NULL
CHECK effective_at <= recorded_at con tolerancia definida para relojes externos
```

## 8.10. Nueva entidad `delivery_status_transitions`

### Propósito

Definir las transiciones válidas de estado canónico.

```text
delivery_status_transitions
- id uuid PK
- from_status_concept_id uuid FK NULL
- event_type_concept_id uuid FK NOT NULL
- to_status_concept_id uuid FK NOT NULL
- channel_type_concept_id uuid FK NULL
- allow_late_event boolean NOT NULL
- allow_after_terminal boolean NOT NULL
- precedence integer NOT NULL
- state_concept_id uuid FK NOT NULL
```

### Ejemplos

```text
NULL + REQUEST_CREATED -> requested
requested + QUEUED -> queued
queued + ATTEMPT_STARTED -> sending
sending + ADAPTER_ACCEPTED -> accepted
accepted + DELIVERED -> delivered
delivered + SEEN -> seen
seen + READ -> read
read + ACTION_CLICKED -> interacted
accepted + PERMANENT_FAILURE -> failed
queued + CANCELLED -> cancelled
accepted + EXPIRED -> expired
```

## 8.11. Revisión de `delivery_receipts`

Se mantendrá para compatibilidad, pero cambiará su función:

- podrá actuar como vista/proyección de `delivery_tracking_events`;
- no deberá ser el único lugar donde se almacena tracking;
- `raw_payload_json` se reemplazará gradualmente por referencia segura al inbound event;
- no se debe duplicar el payload en ambas tablas.

## 8.12. Nueva entidad `delivery_reconciliation_runs`

### Propósito

Registrar procesos de conciliación con proveedores o adaptadores.

```text
delivery_reconciliation_runs
- id uuid PK
- provider_channel_config_id uuid FK NOT NULL
- started_at timestamptz NOT NULL
- finished_at timestamptz NULL
- status_concept_id uuid FK NOT NULL
- query_window_from timestamptz NOT NULL
- query_window_to timestamptz NOT NULL
- deliveries_checked bigint NOT NULL DEFAULT 0
- events_imported bigint NOT NULL DEFAULT 0
- inconsistencies_found bigint NOT NULL DEFAULT 0
- error_detail text NULL
- created_by_user_id uuid FK NOT NULL
- created_at timestamptz NOT NULL
```

Es útil para adaptadores con polling o para resolver callbacks perdidos.

---

## 9. Taxonomía canónica de tracking

## 9.1. Eventos mínimos globales

```text
REQUEST_CREATED
REQUEST_VALIDATED
REQUEST_SUPPRESSED
REQUEST_SCHEDULED
REQUEST_CANCELLED
REQUEST_EXPIRED
QUEUED
DEQUEUED
ATTEMPT_STARTED
ADAPTER_ACCEPTED
ADAPTER_REJECTED
SENT
DELIVERED
AVAILABLE_IN_INBOX
SEEN
READ
OPENED
ACTION_CLICKED
LINK_CLICKED
REPLIED
BOUNCED_SOFT
BOUNCED_HARD
UNSUBSCRIBED
SPAM_REPORTED
RATE_LIMITED
TEMPORARY_FAILURE
PERMANENT_FAILURE
RETRY_SCHEDULED
DEAD_LETTERED
CANCELLED
EXPIRED
ARCHIVED
DISMISSED
```

## 9.2. Estados canónicos actuales

Los eventos son más expresivos que los estados. El estado actual debe mantenerse acotado:

```text
requested
scheduled
suppressed
queued
sending
accepted
delivered
seen
read
interacted
replied
retry_wait
failed
cancelled
expired
dead_lettered
```

## 9.3. Semántica obligatoria

### `accepted`

El adaptador aceptó la solicitud. No significa que el destinatario la recibió.

### `delivered`

El canal o adaptador aportó evidencia de entrega según sus capacidades.

### `seen`

Existe evidencia de que el contenido o ítem fue visible en una interfaz. No siempre equivale a comprensión.

### `read`

El usuario realizó una acción explícita o el canal aportó un recibo de lectura confiable.

### `opened`

Se usa principalmente para canales como correo. No debe equipararse automáticamente a `read` en todos los canales.

### `interacted`

El destinatario accionó un enlace, botón o CTA.

### `replied`

El adaptador registró una respuesta del destinatario.

### `failed`

No habrá más intentos o el error fue permanente.

## 9.4. Eventos fuera de orden

Los proveedores pueden enviar `delivered` después de `read`, o repetir eventos.

Reglas:

1. nunca borrar el evento tardío;
2. marcar `is_late=true`;
3. no retroceder el estado actual por un evento de menor precedencia;
4. permitir que un evento tardío complete una fecha histórica faltante;
5. usar `provider_occurred_at` como tiempo de negocio cuando sea confiable;
6. conservar `received_at` como tiempo de ingreso al sistema;
7. registrar discrepancias para conciliación.

## 9.5. Estados terminales

```text
failed
cancelled
expired
dead_lettered
```

`delivered`, `seen`, `read` e `interacted` no siempre son terminales, porque pueden llegar eventos posteriores.

---

## 10. Adaptador obligatorio `INTERNAL_APP_V1`

## 10.1. Objetivo

Entregar mensajes a la bandeja interna de la aplicación y rastrear su ciclo sin depender de un proveedor externo.

## 10.2. Configuración boot

### Canal

```json
{
  "code": "IN_APP",
  "name": "Mensajería interna",
  "supports_templates": true
}
```

### Proveedor

```json
{
  "code": "INTERNAL_APP",
  "name": "Motor interno de notificaciones SALUD",
  "adapter_code": "INTERNAL_APP_V1",
  "adapter_version": "1.0.0",
  "is_builtin": true,
  "supports_webhooks": false,
  "supports_polling": false,
  "supports_delivery_receipts": true,
  "supports_read_receipts": true,
  "supports_click_receipts": true
}
```

## 10.3. Flujo de entrega interna

```text
notification_request
  -> notification_delivery(attempt=1)
  -> evento ATTEMPT_STARTED
  -> insert/upsert in_app_notifications
  -> evento ADAPTER_ACCEPTED
  -> evento AVAILABLE_IN_INBOX
  -> estado delivery=delivered
```

La entrega interna se considera `delivered` cuando la notificación fue persistida correctamente y está disponible en la bandeja del destinatario.

## 10.4. Eventos generados por el usuario

### Al cargar la bandeja

No debe marcarse todo como leído. Puede registrarse `SEEN` solo cuando el ítem fue realmente incluido en la respuesta visible o confirmado por el cliente con un endpoint explícito.

### Al abrir el detalle

```text
READ
```

### Al pulsar una acción

```text
ACTION_CLICKED
```

Debe incluir:

- identificador de acción;
- recurso relacionado;
- sesión;
- timestamp;
- versión de la notificación.

### Al descartar

```text
DISMISSED
```

### Al archivar

```text
ARCHIVED
```

## 10.5. Extensión de `in_app_notifications`

Agregar:

```text
- notification_request_id uuid FK NOT NULL
- notification_delivery_id uuid FK NOT NULL
- dispatch_recipient_id uuid FK NULL
- available_at timestamptz NOT NULL
- first_seen_at timestamptz NULL
- last_seen_at timestamptz NULL
- opened_at timestamptz NULL
- dismissed_at timestamptz NULL
- archived_at timestamptz NULL
- expires_at timestamptz NULL
- action_state_json jsonb NULL
```

### Constraints

```text
UNIQUE(notification_delivery_id)
CHECK recipient_user_id IS NOT NULL
CHECK read_at IS NULL OR sent_at IS NOT NULL
CHECK archived_at IS NULL OR available_at IS NOT NULL
```

## 10.6. Endpoints de usuario final permitidos

Los usuarios normales no pueden enviar campañas, pero sí interactuar con sus propias notificaciones internas.

```text
GET  /me/notifications
GET  /me/notifications/:id
POST /me/notifications/:id/seen
POST /me/notifications/:id/read
POST /me/notifications/:id/actions/:actionCode
POST /me/notifications/:id/dismiss
POST /me/notifications/:id/archive
```

Cada endpoint verificará:

```text
notification.recipient_user_id = authenticated_user_id
```

No permitirá acceder a notificaciones de otro usuario.

## 10.7. Conteo de no leídas

El conteo será derivado mediante consulta o proyección:

```text
recipient_user_id
AND read_at IS NULL
AND archived_at IS NULL
AND status active
AND expires_at > now o expires_at IS NULL
```

No debe mantenerse como un contador mutable sin reconciliación.

---

## 11. Contrato para futuros adaptadores

## 11.1. Interfaz conceptual

Cada adaptador deberá implementar:

```text
validateConfiguration(config)
validateRecipient(endpoint)
renderPayload(templateSnapshot, recipientSnapshot)
send(deliveryAttempt)
cancel(deliveryAttempt) si el proveedor lo permite
parseInboundEvent(rawEvent)
mapExternalEvent(externalCode, mappingVersion)
queryStatus(providerMessageRef) si soporta polling
healthCheck()
redactForLogs(payload)
```

## 11.2. Resultado de `send`

Debe devolver un contrato canónico:

```json
{
  "accepted": true,
  "providerMessageRef": "...",
  "providerStatus": "...",
  "occurredAt": "...",
  "retryable": false,
  "errorCode": null,
  "safeMetadata": {}
}
```

## 11.3. Reglas de seguridad de adaptadores

- Credenciales solo en secret manager o `provider_credentials`.
- Nunca dentro de `config_json` en texto claro.
- Timeout configurable.
- Circuit breaker cuando corresponda.
- Retry solo para operaciones idempotentes o protegidas por clave.
- Redacción de teléfonos, correos, tokens y payloads.
- Webhooks con firma, timestamp y prevención de replay.
- No copiar PHI salvo propósito explícitamente aprobado.
- Toda versión de mapping debe quedar auditada.

## 11.4. Adaptadores previstos

La base debe permitir, sin implementarlos ahora:

```text
EMAIL
SMS
WHATSAPP
PUSH
WEBHOOK
VOICE
```

No se afirmará que soportan `read`, `open` o `reply` hasta que las capacidades del proveedor específico lo demuestren.

---

## 12. Programación y workers

## 12.1. Workers separados

### `campaign-scheduler-worker`

Responsabilidades:

- reclamar schedules vencidos;
- validar estado publicado;
- calcular ocurrencia;
- crear un dispatch idempotente;
- actualizar `next_run_at`;
- aplicar política de missed run;
- no expandir todavía la audiencia.

### `campaign-audience-snapshot-worker`

Responsabilidades:

- resolver segmento;
- deduplicar miembros;
- resolver endpoints;
- evaluar consentimiento;
- evaluar `do_not_contact`;
- evaluar preferencias y quiet hours;
- crear `campaign_dispatch_recipients`;
- calcular hashes y contadores;
- dejar dispatch en `ready`.

### `notification-request-worker`

Responsabilidades:

- convertir recipients elegibles en requests;
- copiar snapshot de contenido;
- asignar `authorized_by_user_id`;
- crear evento de dominio y outbox en la misma transacción;
- aplicar idempotencia.

### `notification-delivery-worker`

Responsabilidades:

- reclamar request disponible;
- seleccionar provider config;
- respetar rate limit;
- crear attempt;
- invocar adaptador;
- registrar eventos locales;
- programar retry o DLQ.

### `adapter-event-normalizer-worker`

Responsabilidades:

- reclamar inbound events;
- validar mapping;
- localizar delivery;
- crear evento canónico;
- actualizar estado derivado;
- marcar errores no resolubles.

### `delivery-projection-worker`

Responsabilidades:

- actualizar timestamps derivados;
- actualizar recipient status;
- actualizar contadores de dispatch;
- crear touchpoints;
- refrescar read models.

### `delivery-reconciliation-worker`

Responsabilidades:

- consultar adaptadores que soporten polling;
- detectar entregas estancadas;
- importar eventos faltantes;
- registrar inconsistencias.

## 12.2. Ciclo de vida

Todos los workers deberán:

- ejecutarse separados del API;
- permanecer activos;
- manejar `SIGTERM` y `SIGINT`;
- dejar de aceptar trabajo al cerrar;
- completar o liberar locks;
- cerrar conexiones;
- emitir logs y métricas;
- soportar reinicio sin duplicar envíos.

## 12.3. Locks

Usar reclamación tipo:

```text
SELECT ... FOR UPDATE SKIP LOCKED
```

O la primitiva equivalente de la cola elegida.

## 12.4. Idempotencia por nivel

| Nivel | Clave |
|---|---|
| schedule occurrence | `schedule_id + planned_at_normalizado` |
| dispatch | `campaign_version + occurrence_key` |
| recipient | `dispatch + recipient + channel + step` |
| request | `dispatch_recipient + content_hash` |
| attempt | `request + attempt_number` |
| provider send | clave externa estable cuando el proveedor la soporte |
| inbound event | `provider + external_event_id` |
| canonical event | `delivery + provider_event_id + canonical_type` |

## 12.5. Reintentos

Clasificar errores:

```text
retryable: timeout, rate_limit, provider_5xx, transient_network
non_retryable: invalid_recipient, blocked, invalid_template, missing_consent, provider_4xx_permanent
```

Usar backoff con jitter, límites y DLQ.

---

## 13. Flujo completo de negocio

## 13.1. Creación

1. Administración del sitio crea campaña en `draft`.
2. Selecciona objetivo, canal, plantilla y segmento.
3. El sistema guarda cambios auditados.
4. Nadie fuera de Administración del sitio puede acceder a la mutación.

## 13.2. Validación previa

El sistema verifica:

- plantilla publicada;
- variables resolubles;
- canal activo;
- adaptador activo;
- audiencia no clínica;
- ausencia de PHI en reglas de segmentación;
- consentimiento requerido;
- configuración de frecuencia;
- zona horaria;
- ventana horaria;
- límites de volumen;
- enlaces válidos;
- contenido no vacío;
- fecha futura válida.

## 13.3. Publicación

1. Se congela versión de contenido.
2. Se calcula `content_hash`.
3. Se calcula `audience_definition_hash`.
4. Se registra `published_by_user_id`.
5. Se guarda snapshot de autorización.
6. La versión publicada queda inmutable.

## 13.4. Programación

1. Administración del sitio crea schedule.
2. Se valida expresión cron o fecha.
3. Se resuelve la próxima ejecución en la zona horaria indicada.
4. Se persiste `next_run_at` en UTC.
5. Se audita el horario original y la conversión.

## 13.5. Generación de dispatch

1. Worker reclama schedule.
2. Verifica que sigue activo.
3. Crea dispatch con clave idempotente.
4. Avanza `next_run_at`.
5. Publica job de snapshot.

## 13.6. Snapshot de audiencia

1. Se consulta el segmento.
2. Se deduplican miembros.
3. Se resuelven endpoints.
4. Se evalúa consentimiento actual.
5. Se evalúan preferencias actuales.
6. Se aplica quiet hours.
7. Se guarda una fila por destinatario.
8. Se registran elegibles y suprimidos.

La evaluación debe repetirse en el momento del envío para condiciones que pueden cambiar, especialmente consentimiento y do-not-contact.

## 13.7. Solicitud y entrega

1. Se crea `notification_request`.
2. Se crea evento `REQUEST_CREATED`.
3. Se encola mediante outbox.
4. Delivery worker crea intento.
5. Adaptador responde.
6. Se registra `ADAPTER_ACCEPTED` o error.
7. Para internal app, se crea `in_app_notification`.
8. Para proveedores futuros, se espera webhook o polling.

## 13.8. Tracking

1. Ingresa evento crudo.
2. Se valida autenticidad.
3. Se deduplica.
4. Se vincula al delivery.
5. Se aplica mapping versionado.
6. Se crea evento canónico.
7. Se valida transición.
8. Se actualiza estado actual sin perder historia.
9. Se actualizan proyecciones y dashboard.

## 13.9. Cancelación

### Antes del dispatch

- schedule cancelado;
- no se crean nuevas ocurrencias.

### Durante snapshot

- dispatch pasa a `cancelling`;
- se detiene creación de nuevos recipients;
- se conservan filas existentes.

### Requests aún no enviados

- se marcan `cancelled`;
- se elimina o invalida el job de cola de forma segura.

### Request aceptado por proveedor

- se intenta cancelación solo si el adaptador lo soporta;
- de lo contrario se conserva como aceptado y se informa que no puede retirarse.

---

## 14. Endpoints administrativos

Todos los endpoints de esta sección requieren `SITE_ADMINISTRATION` y permiso protegido específico.

## 14.1. Campañas

```text
POST   /site-admin/marketing/campaigns
GET    /site-admin/marketing/campaigns
GET    /site-admin/marketing/campaigns/:campaignId
PATCH  /site-admin/marketing/campaigns/:campaignId/draft
POST   /site-admin/marketing/campaigns/:campaignId/validate
POST   /site-admin/marketing/campaigns/:campaignId/publish
POST   /site-admin/marketing/campaigns/:campaignId/pause
POST   /site-admin/marketing/campaigns/:campaignId/resume
POST   /site-admin/marketing/campaigns/:campaignId/cancel
```

No crear un controller CRUD genérico.

## 14.2. Schedules

```text
POST   /site-admin/marketing/campaigns/:campaignId/schedules
GET    /site-admin/marketing/campaigns/:campaignId/schedules
PATCH  /site-admin/marketing/schedules/:scheduleId/draft
POST   /site-admin/marketing/schedules/:scheduleId/validate
POST   /site-admin/marketing/schedules/:scheduleId/activate
POST   /site-admin/marketing/schedules/:scheduleId/pause
POST   /site-admin/marketing/schedules/:scheduleId/resume
POST   /site-admin/marketing/schedules/:scheduleId/cancel
GET    /site-admin/marketing/schedules/:scheduleId/occurrence-preview
```

## 14.3. Dispatches

```text
GET    /site-admin/marketing/dispatches
GET    /site-admin/marketing/dispatches/:dispatchId
GET    /site-admin/marketing/dispatches/:dispatchId/recipients
POST   /site-admin/marketing/dispatches/:dispatchId/pause
POST   /site-admin/marketing/dispatches/:dispatchId/resume
POST   /site-admin/marketing/dispatches/:dispatchId/cancel
POST   /site-admin/marketing/dispatches/:dispatchId/retry-failed
POST   /site-admin/marketing/dispatches/:dispatchId/reconcile
```

## 14.4. Tracking

```text
GET    /site-admin/messaging/tracking/requests/:requestId
GET    /site-admin/messaging/tracking/deliveries/:deliveryId
GET    /site-admin/messaging/tracking/deliveries/:deliveryId/events
GET    /site-admin/messaging/tracking/dispatches/:dispatchId/summary
GET    /site-admin/messaging/tracking/dispatches/:dispatchId/failures
POST   /site-admin/messaging/tracking/events/:eventId/reprocess
GET    /site-admin/messaging/tracking/events/:eventId/raw
```

El endpoint raw deberá:

- exigir MFA reciente;
- redactar secretos;
- registrar motivo;
- auditar la consulta.

## 14.5. Adaptadores

```text
GET    /site-admin/messaging/adapters
GET    /site-admin/messaging/adapters/:adapterId
PATCH  /site-admin/messaging/adapters/:adapterId/configuration
POST   /site-admin/messaging/adapters/:adapterId/enable
POST   /site-admin/messaging/adapters/:adapterId/disable
POST   /site-admin/messaging/adapters/:adapterId/test-delivery
GET    /site-admin/messaging/adapters/:adapterId/capabilities
GET    /site-admin/messaging/adapters/:adapterId/event-mappings
POST   /site-admin/messaging/adapters/:adapterId/event-mappings/versions
```

## 14.6. Webhooks de proveedor

Los webhooks no usan sesión de Administración del sitio. Son endpoints técnicos autenticados mediante firma:

```text
POST /integrations/messaging/providers/:providerCode/events
```

Solo pueden crear `adapter_inbound_events`. No pueden modificar campañas ni requests directamente.

---

## 15. Read models para el panel

## 15.1. `campaign_dispatch_summary`

Campos:

```text
campaign_id
dispatch_id
planned_at
started_at
finished_at
status
total_candidates
total_eligible
total_suppressed
total_requests
total_accepted
total_delivered
total_seen
total_read
total_interacted
total_replied
total_failed
total_cancelled
delivery_rate
read_rate
interaction_rate
failure_rate
```

## 15.2. `recipient_delivery_timeline`

Debe devolver:

```text
recipient masked identity
endpoint masked
campaign
dispatch
request
delivery attempts
canonical events in order
provider raw status redacted
current status
failure reason
next retry
consent snapshot
```

## 15.3. `adapter_health_summary`

```text
adapter
channel
state
last_success_at
last_failure_at
success_rate_15m
success_rate_24h
p95_latency
rate_limited_count
webhook_lag
unprocessed_inbound_events
DLQ count
```

## 15.4. Privacidad de vistas

- Mostrar correos y teléfonos enmascarados por defecto.
- No mostrar PHI.
- El acceso a payload crudo debe ser excepcional.
- Exportaciones deben incluir watermark, actor y fecha.

---

## 16. Auditoría

## 16.1. Acciones auditables obligatorias

```text
campaign_created
campaign_updated
campaign_validated
campaign_published
campaign_scheduled
campaign_paused
campaign_resumed
campaign_cancelled
schedule_changed
recipient_suppression_overridden
template_published
adapter_config_changed
adapter_enabled
adapter_disabled
credential_rotated
test_delivery_requested
dispatch_retry_requested
tracking_event_reprocessed
raw_tracking_event_viewed
event_mapping_published
site_admin_role_assigned
site_admin_role_revoked
```

## 16.2. Contenido mínimo de auditoría

```text
actor_user_id
actor_role_snapshot
session_id
mfa_age
source_ip hash o formato aprobado
user_agent redacted
tenant_scope
resource_type
resource_id
action
reason
before_hash
after_hash
correlation_id
occurred_at
```

No almacenar secretos ni payloads completos en la auditoría.

## 16.3. Inmutabilidad

- Registros append-only.
- Sin UPDATE o DELETE por runtime.
- Particionado por fecha.
- Retención definida.
- Exportación verificable mediante hash cuando corresponda.

---

## 17. Consentimiento, preferencias y límites éticos

## 17.1. Doble comprobación

El consentimiento se verificará:

1. al congelar la audiencia;
2. inmediatamente antes de crear o ejecutar la request.

Si cambia entre ambos momentos, el destinatario será suprimido.

## 17.2. Orden de evaluación

```text
legal prohibition
consent
unsubscription
do_not_contact
endpoint verification
channel preference
category preference
quiet hours
frequency cap
campaign-specific suppression
```

## 17.3. PHI

Marketing no podrá segmentar por:

- diagnóstico;
- resultado de laboratorio;
- medicación;
- procedimiento;
- embarazo;
- salud mental;
- condición genética;
- cualquier dato clínico sensible.

Si existen comunicaciones asistenciales necesarias, deberán clasificarse como notificación transaccional o clínica bajo reglas separadas, no como marketing.

## 17.4. Plantillas

Las plantillas deberán declarar:

```text
purpose
category
allowed_variables
forbidden_variables
contains_sensitive_content
retention_class
```

---

## 18. Índices, particionado y rendimiento

## 18.1. Índices mínimos

### Schedules

```text
(schedule_status, next_run_at) WHERE status='scheduled'
(campaign_id, schedule_version) UNIQUE
```

### Dispatches

```text
(schedule_id, occurrence_key) UNIQUE
(status, planned_at)
(campaign_id, planned_at DESC)
```

### Dispatch recipients

```text
(dispatch_id, current_status)
(dispatch_id, eligibility_status)
(dispatch_id, member_type, member_ref, channel) UNIQUE
(notification_request_id) UNIQUE WHERE NOT NULL
```

### Requests

```text
(idempotency_key) UNIQUE
(status, scheduled_at) WHERE status IN ('scheduled','queued','retry_wait')
(dispatch_id, status)
(dispatch_recipient_id) UNIQUE
```

### Deliveries

```text
(notification_request_id, attempt_number) UNIQUE
(provider_channel_config_id, status, updated_at)
(provider_message_ref) WHERE NOT NULL
```

### Inbound events

```text
(provider_id, external_event_id) UNIQUE WHERE external_event_id IS NOT NULL
(processing_status, received_at)
(provider_message_ref)
BRIN(received_at)
```

### Tracking events

```text
(delivery_id, effective_at, recorded_at)
(dispatch_id, resulting_status)
(dispatch_recipient_id, effective_at)
BRIN(recorded_at)
```

## 18.2. Particionado

Particionar por tiempo:

- `adapter_inbound_events` por `received_at`;
- `delivery_tracking_events` por `recorded_at`;
- touchpoints por `recorded_at`;
- auditoría por `occurred_at`.

No particionar tablas pequeñas de configuración.

## 18.3. Contadores

Los contadores del dispatch serán derivados mediante eventos o proyecciones idempotentes.

Debe existir job de reconciliación que compare:

```text
contador almacenado
vs
COUNT real por estado
```

---

## 19. Migraciones propuestas

## Fase de migración 1 — autorización

1. Crear categoría de permisos.
2. Crear permisos protegidos.
3. Crear rol `SITE_ADMINISTRATION`.
4. Crear role_permissions.
5. Agregar atributos de no delegación.
6. Crear constraints/triggers anti-bypass.
7. Crear identidad técnica del worker.
8. Probar negativas de permisos.

## Fase de migración 2 — marketing

1. Extender campañas.
2. Crear schedules.
3. Crear dispatches.
4. Crear dispatch recipients.
5. Extender touchpoints.
6. Crear índices.
7. Añadir value sets.

## Fase de migración 3 — destinatarios

1. Crear `contact_channel_endpoints`.
2. Migrar endpoints existentes.
3. Añadir hashes y enmascaramiento.
4. Modificar requests para destinatario flexible.
5. Mantener compatibilidad temporal con `recipient_address`.

## Fase de migración 4 — adaptadores

1. Extender providers.
2. Extender provider configs.
3. Crear capabilities.
4. Crear mappings.
5. Sembrar INTERNAL_APP.

## Fase de migración 5 — tracking

1. Crear inbound events.
2. Crear tracking events.
3. Crear transitions.
4. Crear reconciliation runs.
5. Extender deliveries.
6. Integrar receipts existentes.

## Fase de migración 6 — in-app

1. Extender in-app notifications.
2. Vincular request y delivery.
3. Migrar registros existentes cuando sea posible.
4. Crear endpoints de interacción.
5. Crear read model de no leídas.

## Fase de migración 7 — workers y proyecciones

1. Scheduler.
2. Snapshot worker.
3. Request worker.
4. Delivery worker.
5. Normalizer.
6. Projection worker.
7. Reconciliation worker.
8. Dashboards.

## Fase de migración 8 — endurecimiento

1. RLS.
2. particionado;
3. retención;
4. observabilidad;
5. pruebas de carga;
6. rollback;
7. documentación.

---

## 20. Seeds boot y mock

## 20.1. Boot seeds obligatorios

- rol `SITE_ADMINISTRATION`;
- categoría de permisos;
- permisos protegidos;
- asignaciones role-permission;
- canal `IN_APP`;
- provider `INTERNAL_APP`;
- config interna;
- capacidades internas;
- eventos canónicos;
- estados canónicos;
- transiciones;
- tipos de schedule;
- políticas de overlap y missed run;
- motivos de supresión;
- estados de dispatch;
- fuentes de tracking;
- queues;
- suscripciones de eventos;
- políticas de retención no secretas.

No incluir:

- contraseñas;
- secretos;
- teléfonos reales;
- correos reales;
- usuarios personales reales;
- credenciales de proveedores.

## 20.2. Mock seeds

Crear escenarios:

1. campaña internal app completada;
2. campaña parcialmente entregada;
3. usuario sin consentimiento;
4. endpoint inválido;
5. quiet hours;
6. duplicado evitado;
7. retry transitorio;
8. error permanente;
9. evento fuera de orden;
10. evento duplicado;
11. lectura interna;
12. clic de acción;
13. campaña cancelada;
14. schedule recurrente;
15. intento de acceso por doctor sin rol;
16. intento de bypass mediante grant directo rechazado.

Los mocks deben fallar en producción.

---

## 21. Pruebas obligatorias

## 21.1. Autorización

- Site Administration puede crear draft.
- Site Administration puede publicar.
- Site Administration puede programar.
- Site Administration puede cancelar.
- Doctor recibe 403.
- Enfermera recibe 403.
- Administrador de consultorio recibe 403.
- Administrador de tenant sin rol recibe 403.
- Usuario con permiso directo protegido recibe rechazo de asignación.
- Rol distinto no puede recibir role_permission protegido.
- Sesión sin MFA reciente no puede ver evento crudo.
- Worker no puede publicar campañas.

## 21.2. Programación

- fecha única futura;
- cron válido;
- cron inválido;
- zona horaria con cambio DST;
- schedule pausado;
- schedule cancelado;
- missed run skip;
- overlap prohibido;
- dos workers simultáneos crean un solo dispatch;
- reinicio no duplica ocurrencia.

## 21.3. Audiencia

- deduplicación;
- consentimiento válido;
- consentimiento revocado;
- do-not-contact;
- endpoint no verificado;
- quiet hours;
- usuario sin endpoint;
- contacto sin cuenta IAM;
- recipient snapshot inmutable.

## 21.4. Requests y entregas

- request idempotente;
- dos procesos no crean dos requests;
- attempt number único;
- retry solo transitorio;
- error permanente a failed;
- max attempts a DLQ;
- cancelación antes de send;
- cancelación después de accepted según capacidad.

## 21.5. Tracking

- evento webhook válido;
- firma inválida;
- replay;
- evento duplicado;
- evento sin delivery;
- mapping inexistente;
- mapping versionado;
- out-of-order;
- evento posterior a terminal;
- proyección correcta;
- reprocess idempotente;
- raw payload redacted.

## 21.6. Internal app

- crea inbox item una sola vez;
- delivered al persistir;
- seen explícito;
- read explícito;
- acción clicada;
- dismiss;
- archive;
- usuario no puede modificar notificación ajena;
- unread count correcto;
- evento duplicado no duplica contador.

## 21.7. Rendimiento

- expansión de audiencia grande;
- backpressure;
- rate limit;
- 100 workers reclamando sin duplicar;
- ingestión de webhooks;
- consulta de timeline paginada;
- particiones;
- EXPLAIN ANALYZE de consultas críticas.

---

## 22. Observabilidad

## 22.1. Métricas

```text
campaign_schedules_due_total
campaign_dispatches_created_total
dispatch_recipients_eligible_total
dispatch_recipients_suppressed_total
notification_requests_created_total
delivery_attempts_total
delivery_success_total
delivery_failure_total
delivery_retry_total
delivery_dlq_total
adapter_inbound_events_total
adapter_invalid_signatures_total
adapter_duplicate_events_total
tracking_normalization_failures_total
tracking_event_lag_seconds
internal_notifications_unread_total
```

No usar `user_id` como label de métrica.

## 22.2. Logs

Cada log debe incluir:

```text
correlation_id
campaign_id
dispatch_id
request_id
delivery_id
provider_code
adapter_code
status
safe_error_code
```

No incluir:

- cuerpo completo;
- correo completo;
- teléfono completo;
- token;
- credential;
- PHI.

## 22.3. Alertas

- scheduler atrasado;
- dispatch bloqueado;
- tasa de fallos alta;
- DLQ creciente;
- firmas inválidas;
- eventos sin mapping;
- webhook lag;
- internal app insert failures;
- divergencia de contadores;
- acceso denegado repetido a endpoints administrativos.

---

## 23. Retención y privacidad

Definir políticas explícitas por tipo:

| Tipo | Retención propuesta | Observación |
|---|---:|---|
| campañas y schedules | vida útil + archivo institucional | configuración y gobierno |
| dispatches | prolongada | evidencia operativa |
| recipients snapshot | según política legal | contiene identificadores |
| tracking canónico | prolongada y particionada | evidencia de entrega |
| payload crudo | mínima necesaria | cifrado y acceso excepcional |
| logs | menor que tracking | redacción estricta |
| auditoría | según norma institucional | append-only |

La duración exacta debe aprobarse con legal/compliance. El plan no fija años arbitrarios.

Implementar:

- cifrado en reposo;
- redacción;
- acceso por propósito;
- eliminación o anonimización según política;
- conservación legal cuando exista hold;
- no copiar payloads a múltiples tablas.

---

## 24. Cambios requeridos en los PUML

## 24.1. `diagram_06_authz.puml`

Agregar:

- atributos de permisos protegidos;
- rol `SITE_ADMINISTRATION` como nota/value set/seed contract;
- prohibición de grants directos;
- relación con seguridad de campañas.

## 24.2. `diagram_50_marketing.puml`

Agregar:

- `campaign_schedules`;
- `campaign_dispatches`;
- `campaign_dispatch_recipients`;
- referencias directas de touchpoints;
- estados y constraints;
- boundary de Administración del sitio.

## 24.3. `diagram_35_messaging.puml`

Agregar:

- capabilities;
- mappings;
- inbound events;
- tracking events;
- transitions;
- reconciliation runs;
- destinatario flexible;
- integración formal de internal app;
- relaciones dispatch-request-delivery-event.

## 24.4. `diagram_48_automation.puml`

Ajustar:

- triggers de schedule deben apuntar a un schedule publicado;
- workflow no puede cambiar contenido ni audiencia;
- worker actúa bajo autorización congelada;
- ejecución registra dispatch;
- approvals no sustituyen RBAC.

## 24.5. `diagram_49_crm.puml`

Agregar `contact_channel_endpoints`.

## 24.6. `diagram_10_audit.puml`

Agregar tipos de eventos de gobierno y acceso a tracking crudo.

## 24.7. `diagram_30_read_models.puml`

Agregar vistas de summary, timeline y adapter health.

## 24.8. Diagramas adicionales recomendados

Crear:

```text
activityDiagramScheduledCampaign.puml
stateDiagramCampaignSchedule.puml
stateDiagramCampaignDispatch.puml
stateDiagramNotificationDelivery.puml
sequenceDiagramInternalAppDelivery.puml
sequenceDiagramExternalAdapterWebhook.puml
componentDiagramMessagingAdapters.puml
```

---

## 25. Fases de implementación sucesivas

## Fase 0 — Confirmación del contrato

### Objetivo

Congelar decisiones antes de modificar el modelo.

### Entregables

- ADR de autoridad exclusiva.
- ADR de tracking canónico.
- ADR de internal app adapter.
- matriz de permisos.
- taxonomía de eventos.
- política de retención pendiente de aprobación.

### Gate

No avanzar si “Administración del sitio” no tiene un código y alcance inequívocos.

## Fase 1 — Seguridad y anti-bypass

### Trabajo

- crear rol y permisos;
- marcar permisos protegidos;
- bloquear grants directos;
- guards;
- policy checks;
- MFA en acciones peligrosas;
- auditoría.

### Gate

Pruebas negativas completas.

## Fase 2 — Programación formal

### Trabajo

- schedules;
- estados;
- timezone;
- recurrence;
- idempotency;
- scheduler worker.

### Gate

Dos workers no crean doble dispatch.

## Fase 3 — Dispatch y audiencia

### Trabajo

- dispatch;
- snapshot;
- endpoint resolution;
- consent;
- suppressions;
- counters.

### Gate

La audiencia queda reproducible y auditada.

## Fase 4 — Request y delivery contract

### Trabajo

- recipient flexible;
- vínculos directos;
- content snapshot;
- idempotencia;
- adapter contract.

### Gate

Cada recipient elegible produce como máximo una request por clave.

## Fase 5 — Tracking base

### Trabajo

- inbound;
- mapping;
- events;
- transitions;
- projection;
- reconciliation.

### Gate

Eventos duplicados y fuera de orden no corrompen estado.

## Fase 6 — Internal app adapter

### Trabajo

- provider boot;
- delivery;
- in-app projection;
- user events;
- unread count;
- acciones.

### Gate

Timeline completo desde campaña hasta lectura interna.

## Fase 7 — Panel administrativo

### Trabajo

- campaign views;
- schedule views;
- dispatch views;
- recipient list;
- timeline;
- adapter health;
- exports seguros.

### Gate

Usuarios no autorizados no pueden acceder por UI ni API.

## Fase 8 — Hardening

### Trabajo

- carga;
- observabilidad;
- retención;
- RLS;
- rollback;
- DR;
- runbooks.

### Gate

Evidencia de pruebas y restauración.

---

## 26. Criterios de aceptación funcional

La corrección se acepta únicamente cuando se demuestre lo siguiente:

1. Un doctor sin `SITE_ADMINISTRATION` no puede crear, publicar ni programar.
2. Un administrador de tenant sin `SITE_ADMINISTRATION` tampoco puede hacerlo.
3. No es posible conceder esos permisos por `user_permission_grants`.
4. Solo una campaña publicada puede programarse.
5. Toda programación tiene zona horaria.
6. Cada ocurrencia produce un solo dispatch.
7. Cada dispatch conserva audiencia exacta y motivos de supresión.
8. Cada request está vinculada a dispatch y recipient.
9. Cada delivery conserva adaptador y versión.
10. Cada evento crudo se deduplica.
11. Cada evento externo se normaliza con mapping versionado.
12. El estado actual puede reconstruirse desde eventos.
13. Un evento fuera de orden no retrocede el estado.
14. Internal app genera delivery y tracking.
15. El usuario puede ver y leer solo sus notificaciones.
16. El panel administrativo muestra el timeline completo.
17. Los payloads sensibles están protegidos.
18. Los logs no exponen destinatarios completos.
19. Los workers reinician sin duplicar envíos.
20. La auditoría identifica al administrador humano que autorizó.

---

## 27. Criterios de aceptación técnica

- Migraciones versionadas.
- Sin `sync alter` o `force`.
- Seeds boot JSON idempotentes.
- Mock seeds rechazados en producción.
- Zod para configuración y payloads.
- OpenAPI actualizado.
- Workers persistentes separados.
- Outbox transaccional.
- Retry limitado.
- DLQ.
- Idempotencia concurrente probada.
- Índices verificados con carga representativa.
- Particiones administradas.
- Liveness y readiness.
- Métricas y alertas.
- README por módulo modificado.
- ADRs y runbooks.
- Reporte de pruebas.
- Plan de rollback.

---

## 28. Rollback

## 28.1. Rollback de aplicación

- mantener lectura compatible con columnas anteriores durante la transición;
- usar feature flag `SITE_SCHEDULED_CAMPAIGNS_V2`;
- permitir desactivar scheduler sin eliminar datos;
- permitir volver a UI anterior en modo solo lectura.

## 28.2. Rollback de base

No eliminar de inmediato:

- `recipient_address`;
- `delivery_receipts`;
- campos anteriores de status.

Etapas:

1. expand schema;
2. dual write controlado;
3. backfill;
4. lectura v2;
5. validación;
6. dejar de escribir v1;
7. retirar v1 en release posterior.

## 28.3. Kill switch

Debe existir configuración global para:

```text
pausar nuevos dispatches
pausar un adaptador
pausar todas las entregas externas
mantener internal app si se autoriza
```

El kill switch no debe borrar jobs ni datos.

---

## 29. Riesgos principales y mitigación

| Riesgo | Mitigación |
|---|---|
| Doble envío por concurrencia | idempotency keys y unique constraints |
| Bypass por grant directo | permisos protegidos no delegables |
| Evento duplicado | unique provider event ID/hash |
| Evento tardío | precedencia y `is_late` |
| Provider sin tracking | capability matrix y estados local-only |
| Confundir accepted con delivered | semántica canónica documentada |
| Uso de PHI | boundary y validación de reglas/variables |
| Contacto sin IAM | endpoints polimórficos controlados |
| Payload crudo sensible | cifrado, retención corta y acceso excepcional |
| Worker comprometido | service principal mínimo y dispatch autorizado |
| Schedule incorrecto por timezone | IANA + tests DST |
| Contadores divergentes | proyección idempotente + reconciliación |
| Campaña editada después de programar | versión y hashes inmutables |
| Webhook falsificado | firma, timestamp y replay protection |

---

## 30. Decisiones que deben quedar confirmadas antes del desarrollo

Aunque el objetivo general está definido, estas decisiones requieren aprobación explícita del propietario del sistema:

1. código definitivo del rol “Administración del sitio”;
2. quién puede asignar o revocar ese rol;
3. duración máxima de una sesión MFA para acciones peligrosas;
4. política de retención por país;
5. volumen máximo por campaña;
6. frecuencia máxima por destinatario;
7. comportamiento exacto ante quiet hours;
8. si las campañas de gran volumen requieren doble aprobación;
9. si internal app puede mantenerse activo durante un kill switch externo;
10. alcance global o por tenant de las campañas;
11. qué tipos de notificación no comercial pueden usar el mismo motor;
12. política de exportación de tracking.

Estas decisiones no deben inventarse durante la implementación.

---

## 31. Resultado esperado

Después de ejecutar este plan, el sistema podrá afirmar con evidencia que:

- únicamente Administración del sitio gobierna campañas y envíos programados;
- los workers solo ejecutan órdenes autorizadas;
- la audiencia de cada ejecución es reproducible;
- los envíos son idempotentes;
- mensajería interna está implementada de extremo a extremo;
- futuros adaptadores pueden conectarse sin alterar el modelo central;
- cada proveedor puede tener su propia taxonomía externa;
- SALUD conserva una taxonomía canónica común;
- puede consultarse qué ocurrió con cada notificación;
- se mantiene evidencia cruda, normalizada y derivada;
- consentimiento, privacidad, auditoría y observabilidad forman parte del flujo.

---

## 32. Definición de terminado

El trabajo no se considerará terminado solo porque existan tablas o endpoints.

Debe existir evidencia conjunta de:

```text
modelo corregido
+ migraciones
+ seeds
+ servicios
+ workers
+ adaptador interno
+ tracking
+ permisos anti-bypass
+ UI administrativa
+ pruebas negativas
+ pruebas de idempotencia
+ pruebas de carga
+ auditoría
+ observabilidad
+ documentación
+ rollback
```

Cualquier entrega que omita uno de estos elementos deberá presentarse como parcial y no como capacidad completa de producción.
