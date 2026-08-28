# PATCH v4.0.1 — Envíos programados · Gobierno "Administración del sitio" · Tracking multicanal

> **Estado en nuestro contexto:** incorporado a nivel de **diseño** en SALUD **v4.0.1**.
> Documento fuente: `PATCH_v4.0_casos_uso_envios_programados_tracking.md` (v1.0.0, 2026-07-19).
>
> ## Nota de reconciliación con el modelo canónico (v4.0)
> El patch fue redactado contra una variante distinta del modelo. Al integrarlo se aplicó:
> - **Base real:** SALUD **v4.0** (64 módulos `diagram_*.puml`). El patch decía "base v3.9 · 760 UC · 60 módulos"; nuestro paquete **no** tiene diagramas de casos de uso (`casos_uso_*.puml`), así que los 37 UC se representan como **notas en el grafo Obsidian**, no como `.puml`.
> - **Normalización de nombres a los canónicos existentes:** `audit.audit_events` → **`audit.audit_log`**; `messaging.outbox_events` → **`messaging.outbox_messages`**. (Coinciden en responsabilidad; no se duplican tablas.)
> - **Entidades nuevas (planned v4.0.1, aún NO materializadas en los ER `diagram_*.puml`):** `authz.service_principals`; `crm.contact_channel_endpoints`; `marketing.campaign_schedules`, `campaign_dispatches`, `campaign_dispatch_recipients`; `messaging.adapter_tracking_capabilities`, `adapter_event_mappings`, `adapter_inbound_events`, `delivery_tracking_events`, `delivery_status_transitions`, `delivery_reconciliation_runs`; `read_models.campaign_dispatch_summary`, `recipient_delivery_timeline`, `adapter_health_summary`; más `*_history` en `audit` y máquinas de estado en `workflow` (32).
> - **Referencias ya coincidentes (sin cambios):** `redis_runtime.idempotency_entries`/`distributed_lock_entries`, `consent.consents`/`privacy_restrictions`, value sets en `system_context` (45), `iam.security_events`.
> - **Materialización en los ER `diagram_*.puml`:** pendiente, como paso posterior explícito (no se editó el modelo canónico para no inventar campos no especificados).
>
> El resto de este documento es el patch original con esos dos nombres ya normalizados.

---


## Envíos programados · Gobierno exclusivo de Administración del sitio · Tracking multicanal

**Tipo de documento:** Patch de casos de uso + plan de implementación (aditivo, no destructivo)
**Versión:** 1.0.0 · **Fecha:** 2026-07-19
**Fuente normativa:** `SALUD_v4.0_plan_correccion_envios_programados_tracking_admin_sitio.md` (v1.0.0)
**Modelo base:** SALUD v3.9 (760 casos de uso, 60 módulos) — este patch **añade** casos de uso; no reescribe los existentes.
**Módulos impactados:** `authz` (06), `crm` (49), `marketing` (50), `messaging` (35), `automation` (48), `audit` (10), `read_models` (30).
**Módulo explícitamente NO reutilizado:** `tracking` (37) — es logística física (envíos, transportistas, hitos). La trazabilidad de **comunicaciones** vive en `messaging`, con proyección analítica a `read_models`/`reporting`. (Ref. plan §1 y §3.2.)

---

## 0. Cómo leer este patch

Cada caso de uso nuevo usa el mismo contrato de detalle que el resto del proyecto SALUD:

- **Endpoint:** ruta REST recomendada (verbo + path). Los administrativos cuelgan de `/site-admin/...`; los de usuario final de `/me/...`; los técnicos de proveedor de `/integrations/...`.
- **Actores:** humanos y de sistema (`<<system>>` = worker / identidad técnica).
- **Precondición:** RLS, MFA, rol, estado previo, consentimiento.
- **Tablas impactadas (misma transacción):** cada una con el **tipo de operación** (INSERT / UPDATE con transición `status_concept_id: X→Y` / UPSERT / soft-delete / append-only) y qué cambia.
- **Concurrencia:** `row_version` optimista, `SELECT … FOR UPDATE`, `SKIP LOCKED`, constraints `UNIQUE`/idempotencia.
- **Eventos / Auditoría:** `messaging.outbox_messages` en la misma tx; `audit.*_history` + `audit.audit_log` (append-only, WORM).
- **Proyección (eventual, vía outbox):** `read_models` / `search_platform` / `time_series`, etc.
- **Fase:** fase de despliegue (§8) en la que se implementa.
- **AC:** criterio(s) de aceptación del plan fuente (§26/§27) que valida el caso.

**Namespace de IDs:** los casos nuevos continúan la numeración de cada módulo (p. ej. `UC-50-13` sigue a `UC-50-12`). Un sufijo `[v4.0]` los marca como parte de este patch. Se integran en los `.puml` existentes `casos_uso_06/10/30/35/48/49/50_*.puml` (ver §10).

---

## 1. Principios heredados del plan v4.0 (no negociables)

1. **Autoridad humana exclusiva.** Solo una sesión humana activa con el rol de sistema `SITE_ADMINISTRATION` (scope `platform`, MFA reciente) puede crear, validar, publicar, programar, iniciar, pausar, reanudar, cancelar o reintentar campañas/envíos. Ni doctor, ni director médico, ni admin de consultorio, ni admin de tenant, ni marketing, ni CRM, ni un `user_permission_grant` directo lo habilitan. (Plan §2.1, §5.)
2. **Separación decisión ↔ ejecución.** Administración del sitio **decide y autoriza**; el worker **ejecuta una orden ya persistida, autorizada e inmutable**. El worker nunca crea campañas, cambia destinatarios/contenido ni adelanta fechas. Toda fila derivada conserva `authorized_by_user_id` (humano) y `authorization_snapshot_json`. (Plan §2.2, §5.7, §5.8.)
3. **Mensajería interna = adaptador oficial.** `INTERNAL_APP_V1` usa la misma cadena canónica (request → delivery → eventos → tracking → auditoría). `in_app_notifications` es **proyección operativa** de la bandeja, no la fuente de verdad. (Plan §2.3, §10.)
4. **Tracking en 3 capas.** (a) evento crudo `adapter_inbound_events`; (b) evento canónico normalizado `delivery_tracking_events`; (c) estado actual derivado `notification_deliveries.status_concept_id`. (Plan §2.4, §8.)
5. **Fuente de verdad.** El historial append-only de eventos manda; los contadores y timestamps son derivados; ningún estado se borra para "actualizar". (Plan §2.5.)

---

## 2. Convenciones transversales aplicables (heredadas del modelo)

Multi-tenant/RLS (`tenant_id`/`custodian_tenant_id`), `row_version` optimista, patrón **outbox** transaccional (`messaging.outbox_messages`), auditoría WORM (`audit.<tabla>_history` + `audit.audit_log`), idempotencia/locks efímeros (`redis_runtime`: `idempotency_entries`, `distributed_lock_entries`), y proyección eventual a `read_models`/`search_platform`/`time_series`. Toda escritura sensible de este patch **exige además** MFA reciente y verificación del rol `SITE_ADMINISTRATION` a nivel de política (`authz.access_policies`).

---

## 3. Supuestos y decisiones pendientes que condicionan estos casos de uso

El plan fuente (§30) deja 12 decisiones para el propietario del sistema. Para no bloquear la especificación, cada caso afectado usa un **default marcado `‹SUPUESTO›`**; deben confirmarse antes de desarrollar y no deben "inventarse" en implementación:

- **Código de rol:** `SITE_ADMINISTRATION` ‹SUPUESTO, plan §2.1›.
- **Quién asigna/revoca el rol:** flujo de seguridad de plataforma con doble control ‹SUPUESTO›.
- **Edad máxima de MFA para acciones peligrosas:** `session_mfa_age ≤ 15 min` ‹SUPUESTO›.
- **`quiet_hours`:** reprograma (no excluye) salvo política explícita ‹SUPUESTO, plan §6.3›.
- **`missed_run_policy` por defecto:** `skip` (nunca `run_all_missed`) ‹SUPUESTO, plan §6.1›.
- **`overlap_policy` por defecto:** `forbid` ‹SUPUESTO›.
- **Alcance de campañas:** global de plataforma con `tenant_id` nullable ‹SUPUESTO, plan §31›.
- **Doble aprobación para gran volumen, retención por país, límites de volumen/frecuencia, exportación de tracking, tipos no-comerciales que usan el motor:** pendientes ‹SUPUESTO›.

---

## 4. Mapa de la cadena gobernada (contexto de los casos de uso)

```text
[UC-06-*] Administración del sitio (rol + permisos protegidos anti-bypass)
      -> [UC-50-13..15] Campaña draft -> validada -> publicada (contenido+audiencia congelados por hash)
      -> [UC-50-16..17] Schedule (timezone, cron/once, ventanas) validado/activado
      -> [UC-48-15] automation_trigger apunta al schedule publicado (fuente única de cron)
      -> [UC-50-18] Dispatch idempotente por ocurrencia (worker, autorización congelada)
      -> [UC-50-19] Snapshot de destinatarios + consentimiento + supresiones (worker)
      -> [UC-49-16] Resolución de endpoint de contacto (con/sin cuenta IAM)
      -> [UC-35-17] notification_request idempotente (destinatario flexible)
      -> [UC-35-18] delivery attempt vía adaptador (INTERNAL_APP_V1 en 1ª entrega)
      -> [UC-35-19] inbound event crudo -> [UC-35-20] evento canónico + transición de estado
      -> [UC-35-24..26] Internal app: bandeja + interacción del usuario
      -> [UC-30-14..16] Read models: summary / timeline / adapter health
      -> [UC-10-14..15] Auditoría de gobierno y de acceso a evento crudo
```

---

## 5. Catálogo de casos de uso nuevos

### 5.1. `authz` (06) — Autoridad exclusiva y anti-bypass

#### UC-06-13 [v4.0] Definir permiso protegido no delegable
- **Endpoint:** `POST /site-admin/authz/permissions/{code}:protect`
- **Actores:** Administración del sitio (seguridad de plataforma)
- **Precondición:** RLS plataforma; MFA ≤ 15 min; migración administrativa explícita (no runtime casual).
- **Tablas impactadas (misma transacción):**
  - `authz.permissions` — UPDATE `is_role_restricted=true`, `required_role_code='SITE_ADMINISTRATION'`, `allow_direct_user_grant=false`; `row_version++` (columnas nuevas, plan §5.5).
  - `authz.permission_categories` — UPSERT categoría `SITE_MESSAGING_GOVERNANCE` (plan §5.2) si no existe.
  - `messaging.outbox_messages` — INSERT (`PermissionProtected`).
  - `audit.audit_log` + `audit.permissions_history` — INSERT (append-only).
- **Concurrencia:** `SELECT … FOR UPDATE` sobre la fila de permiso; `row_version` optimista. El trigger anti-bypass (UC-06-16) queda activo tras esta operación.
- **Proyección:** invalidación de `redis_runtime.authorization_cache_entries` por versión de política.
- **Fase:** 1 · **AC:** §26.3, §27.

#### UC-06-14 [v4.0] Crear rol de sistema `SITE_ADMINISTRATION` y ligar permisos protegidos
- **Endpoint:** `POST /site-admin/authz/roles:seed-system` (migración/seed idempotente, no CRUD)
- **Actores:** Administración del sitio (bootstrap de seguridad) / `<<system>>` migración
- **Precondición:** categoría y permisos protegidos ya creados (UC-06-13); operación idempotente por `code`.
- **Tablas impactadas (misma transacción):**
  - `authz.roles` — UPSERT (`code='SITE_ADMINISTRATION'`, `is_system=true`, `is_assignable=true`, `scope='platform'`, `tenant_id=NULL`).
  - `authz.role_permissions` — INSERT N (solo este rol puede recibir los permisos `site.marketing.*`, `site.messaging.*`; el trigger rechaza ligarlos a otro rol).
  - `authz.permissions` — INSERT los permisos del catálogo (plan §5.3) si el seed los crea aquí.
  - `messaging.outbox_messages` — INSERT (`SystemRoleSeeded`).
  - `audit.audit_log` + `audit.roles_history` — INSERT.
- **Concurrencia:** `UNIQUE(roles.code)`; seed idempotente `ON CONFLICT DO NOTHING`; `row_version`.
- **Fase:** 1 · **AC:** §26.1–26.3.

#### UC-06-15 [v4.0] Asignar el rol `SITE_ADMINISTRATION` a un usuario humano
- **Endpoint:** `POST /site-admin/authz/users/{userId}/roles/site-administration`
- **Actores:** Administración del sitio (con autoridad de asignación) — humano
- **Precondición:** MFA reciente del asignador; motivo obligatorio; vigencia; **no** se hereda de roles clínicos ni de admin de tenant (plan §5.4).
- **Tablas impactadas (misma transacción):**
  - `authz.user_role_assignments` — INSERT (`user_id`, `role_id`, `assigned_by_user_id`, `reason`, `valid_from`, `valid_to`, `mfa_age_at_assignment`).
  - `iam.security_events` — INSERT (`privileged_role_granted`).
  - `messaging.outbox_messages` — INSERT (`SiteAdminRoleAssigned`).
  - `audit.audit_log` + `audit.user_role_assignments_history` — INSERT (con `actor_role_snapshot`, `mfa_age`).
- **Concurrencia:** `UNIQUE(user_id, role_id) WHERE valid_to IS NULL`; `SELECT … FOR UPDATE` sobre asignaciones activas del usuario.
- **Proyección:** invalidar `redis_runtime.authorization_cache_entries` del usuario.
- **Fase:** 1 · **AC:** §26.20, §21.1.

#### UC-06-16 [v4.0] Rechazar bypass por concesión directa (guard de persistencia)
- **Endpoint:** N/A — **invariante de base** (constraint/trigger) evaluado en cualquier intento (`POST /site-admin/authz/users/{id}/permission-grants`, o escritura directa).
- **Actores:** Cualquier actor / `<<system>>` DB
- **Precondición:** el permiso destino tiene `allow_direct_user_grant=false`.
- **Tablas impactadas:**
  - `authz.user_permission_grants` — INSERT **RECHAZADO** por trigger `trg_reject_protected_grant` (RAISE EXCEPTION); la transacción aborta (0 filas).
  - `authz.role_permissions` — INSERT sobre rol ≠ `SITE_ADMINISTRATION` para permiso protegido: **RECHAZADO**.
  - `audit.audit_log` — INSERT (`bypass_attempt_denied`) en tx separada de auditoría del intento (no dentro de la tx abortada; el guard de aplicación registra el 403).
- **Concurrencia:** invariante determinista; no depende de carrera.
- **Fase:** 1 · **AC:** §26.3, §21.1 (grant directo rechazado; rol distinto no puede recibir role_permission protegido).

#### UC-06-17 [v4.0] Provisionar identidad técnica `SITE_MESSAGING_WORKER`
- **Endpoint:** `POST /site-admin/authz/service-principals:seed`
- **Actores:** Administración del sitio / `<<system>>` migración
- **Precondición:** identidad **no humana**, permisos técnicos mínimos acotados a un `campaign_dispatch_id` válido (plan §5.7).
- **Tablas impactadas (misma transacción):**
  - `authz.service_principals` — UPSERT (`code='SITE_MESSAGING_WORKER'`, `is_human=false`).
  - `authz.role_permissions` (o grants técnicos) — INSERT del set acotado: reclamar schedules, crear dispatches desde publicados, materializar recipients autorizados, crear requests, ejecutar attempts, persistir tracking, reconciliar. **NUNCA** crear campañas/plantillas/segmentos ni publicar.
  - `audit.audit_log` — INSERT.
- **Concurrencia:** seed idempotente por `code`.
- **Fase:** 1 · **AC:** §26.19, §21.1 (worker no puede publicar campañas).

#### UC-06-18 [v4.0] Publicar política de acceso "deny-by-default" para recursos de campaña/mensajería
- **Endpoint:** `POST /site-admin/authz/access-policies`
- **Actores:** Administración del sitio
- **Precondición:** recursos objetivo del plan §5.6 (`marketing.campaigns`, `campaign_schedules`, `campaign_dispatches`, `campaign_dispatch_recipients`, `messaging.message_templates`, `provider_channel_configs`, `notification_requests` con `source='marketing'`, `delivery_tracking_events`).
- **Tablas impactadas (misma transacción):**
  - `authz.access_policies` — INSERT (efecto `deny` por defecto; `allow` solo si `authenticated ∧ session_mfa_age≤límite ∧ role_code∋SITE_ADMINISTRATION ∧ role_scope=platform ∧ account_state=active ∧ session_state=active`).
  - `authz.field_permissions` — INSERT (enmascaramiento de endpoints/PII en lectura).
  - `messaging.outbox_messages` — INSERT (`AccessPolicyPublished`).
  - `audit.audit_log` + `audit.access_policies_history` — INSERT.
- **Concurrencia:** versión de política monotónica; invalidación de caché de authz.
- **Fase:** 1 · **AC:** §26.1–26.3, §21.1.

---

### 5.2. `crm` (49) — Endpoints de destinatario polimórficos

#### UC-49-16 [v4.0] Registrar y verificar endpoint de contacto (con o sin cuenta IAM)
- **Endpoint:** `POST /site-admin/crm/contact-endpoints` · `POST /site-admin/crm/contact-endpoints/{id}:verify`
- **Actores:** Administración del sitio / Contacto (auto-verificación por challenge)
- **Precondición:** el destinatario puede ser `contact_id`, `lead_id` o `user_id` (exactamente uno); valor normalizado + cifrado (plan §7.2).
- **Tablas impactadas (misma transacción):**
  - `crm.contact_channel_endpoints` — INSERT (`endpoint_type_concept_id`, `normalized_value` cifrado, `masked_display_value`, `value_hash`, `verification_status=pending`, `deliverability_status`, `state`).
  - En verificación: UPDATE `verification_status: pending→verified`, `verified_at`; `row_version++`.
  - `messaging.outbox_messages` — INSERT (`ContactEndpointRegistered` / `…Verified`).
  - `audit.audit_log` + `audit.contact_channel_endpoints_history` — INSERT.
- **Concurrencia:** `CHECK exactly_one(contact_id, lead_id, user_id)`; `UNIQUE(endpoint_type_concept_id, value_hash, tenant_scope)` para deduplicar; `row_version`.
- **Proyección:** `search_platform` (directorio de contactos, valor enmascarado).
- **Fase:** 3 · **AC:** §26 (contacto sin cuenta IAM puede recibir), §21.3.

#### UC-49-17 [v4.0] Marcar `do_not_contact` / opt-out de un endpoint
- **Endpoint:** `POST /site-admin/crm/contact-endpoints/{id}:do-not-contact` (o `/me/...:unsubscribe`)
- **Actores:** Administración del sitio / Titular del dato
- **Precondición:** afecta la evaluación de elegibilidad de futuros snapshots (UC-50-19).
- **Tablas impactadas (misma transacción):**
  - `crm.contact_channel_endpoints` — UPDATE `do_not_contact=true` (y/o `deliverability_status`, `state`); `row_version++`.
  - `consent.consents` / `consent.privacy_restrictions` — UPSERT restricción de contacto cuando aplique.
  - `messaging.outbox_messages` — INSERT (`DoNotContactSet`).
  - `audit.audit_log` + history — INSERT.
- **Concurrencia:** `row_version`; idempotente por endpoint.
- **Fase:** 3 · **AC:** §26.7, §17.2, §21.3.

---

### 5.3. `marketing` (50) — Campaña, programación, dispatch y audiencia

#### UC-50-13 [v4.0] Crear / editar campaña en `draft` (versionable)
- **Endpoint:** `POST /site-admin/marketing/campaigns` · `PATCH /site-admin/marketing/campaigns/{id}/draft`
- **Actores:** Administración del sitio
- **Precondición:** `access_policy` de UC-06-18 satisfecha; audiencia **no clínica** (sin PHI en reglas de segmentación, plan §17.3).
- **Tablas impactadas (misma transacción):**
  - `marketing.marketing_campaigns` — INSERT/UPDATE `status=draft`, `requires_explicit_publish=true`; objetivo, canal, plantilla, segmento; `row_version++`.
  - `messaging.outbox_messages` — INSERT (`CampaignDrafted`/`CampaignDraftUpdated`).
  - `audit.audit_log` + `audit.marketing_campaigns_history` — INSERT.
- **Concurrencia:** `row_version` optimista; solo `draft` es editable (invariante).
- **Fase:** 3 · **AC:** §26.1.

#### UC-50-14 [v4.0] Validar campaña (pre-publicación)
- **Endpoint:** `POST /site-admin/marketing/campaigns/{id}/validate`
- **Actores:** Administración del sitio
- **Precondición:** checks del plan §13.2 (plantilla publicada, variables resolubles, canal/adaptador activos, sin PHI, consentimiento requerido, timezone, ventana, límites, enlaces, contenido no vacío, fecha futura).
- **Tablas impactadas (misma transacción):**
  - `marketing.marketing_campaigns` — UPDATE `validation_state`; no cambia contenido.
  - `messaging.outbox_messages` — INSERT (`CampaignValidated`).
  - `audit.audit_log` + history — INSERT.
- **Concurrencia:** `row_version`.
- **Fase:** 3 · **AC:** §26.4 (solo publicable si válida).

#### UC-50-15 [v4.0] Publicar campaña (congelar versión + hashes)
- **Endpoint:** `POST /site-admin/marketing/campaigns/{id}/publish`
- **Actores:** Administración del sitio (humano) — requiere MFA reciente
- **Precondición:** campaña validada; publicación crea versión **inmutable** (plan §6.4, §13.3).
- **Tablas impactadas (misma transacción):**
  - `marketing.marketing_campaigns` — UPDATE `published_version`, `published_at`, `published_by_user_id`, `approved_content_hash`, `approved_audience_hash`; `status→published`; `row_version++`.
  - `messaging.outbox_messages` — INSERT (`CampaignPublished`).
  - `audit.audit_log` + `audit.marketing_campaigns_history` — INSERT (con `authorization_snapshot`).
- **Concurrencia:** `SELECT … FOR UPDATE`; una versión publicada no puede editarse (un cambio posterior crea nueva versión y exige re-publicar).
- **Fase:** 3 · **AC:** §26.4, §26.20.

#### UC-50-16 [v4.0] Crear y validar programación (`campaign_schedules`) + fuente única de cron
- **Endpoint:** `POST /site-admin/marketing/campaigns/{id}/schedules` · `POST /site-admin/marketing/schedules/{id}/validate`
- **Actores:** Administración del sitio
- **Precondición:** el schedule solo puede apuntar a una **versión publicada** (UC-50-15); timezone IANA; `exactly_one(campaign_id, journey_id)`.
- **Tablas impactadas (misma transacción):**
  - `marketing.campaign_schedules` — INSERT (`schedule_type_concept_id`, `timezone_name`, `scheduled_once_at`|`cron_expression`|`recurrence_rule_json`, `valid_from/until`, `allowed_weekdays_json`, `allowed_time_window_json`, `missed_run_policy`, `overlap_policy`, `next_run_at` en UTC, `schedule_version`, `published_content_hash`, `published_audience_hash`, `authorized_by_user_id`, `authorization_snapshot_json`, `status=draft→validated`).
  - `automation.automation_triggers` — UPDATE/INSERT `campaign_schedule_id`, `schedule_source_concept_id='campaign_schedule'`, `schedule_cron=NULL` (fuente única; plan §6.1.1). Ver UC-48-15.
  - `messaging.outbox_messages` — INSERT (`CampaignScheduleCreated`).
  - `audit.audit_log` + `audit.campaign_schedules_history` — INSERT.
- **Concurrencia:** `UNIQUE(campaign_id, schedule_version)`; CHECKs de tipo (once→`scheduled_once_at`, cron→`cron_expression`), `valid_until>valid_from`, timezone ∈ catálogo IANA; `row_version`.
- **Proyección:** `read_models` (preview de próximas ocurrencias vía `/occurrence-preview`).
- **Fase:** 2 · **AC:** §26.4, §26.5, §21.2.

#### UC-50-17 [v4.0] Activar / pausar / reanudar / cancelar programación
- **Endpoint:** `POST /site-admin/marketing/schedules/{id}/{activate|pause|resume|cancel}`
- **Actores:** Administración del sitio
- **Precondición:** transición válida de `vs_campaign_schedule_status`.
- **Tablas impactadas (misma transacción):**
  - `marketing.campaign_schedules` — UPDATE `status_concept_id` (draft/validated→scheduled→paused→scheduled→…→cancelled); recalcula/limpia `next_run_at`; `row_version++`.
  - `automation.automation_triggers` — UPDATE estado alineado (habilita/inhabilita reclamación).
  - `messaging.outbox_messages` — INSERT (`CampaignScheduleStateChanged`).
  - `audit.audit_log` + history — INSERT.
- **Concurrencia:** `SELECT … FOR UPDATE`; cancelar es idempotente y no elimina filas.
- **Fase:** 2 · **AC:** §26.6, §21.2.

#### UC-50-18 [v4.0] Generar `campaign_dispatch` idempotente desde schedule vencido (worker)
- **Endpoint:** worker `campaign-scheduler-worker` (sin sesión humana; ejecuta orden autorizada)
- **Actores:** `<<system>>` `SITE_MESSAGING_WORKER`
- **Precondición:** schedule `scheduled` y vigente; autorización congelada del humano que publicó.
- **Tablas impactadas (misma transacción):**
  - `marketing.campaign_dispatches` — INSERT (`occurrence_key`, `planned_at`, `content_template_id/version`, `content_hash`, `audience_definition_hash`, `idempotency_key`, `authorized_by_user_id` = humano, `authorization_snapshot_json`, `status=planned`, contadores en 0).
  - `marketing.campaign_schedules` — UPDATE `next_run_at` (avanza), `last_run_at`, `completed_occurrences++`; aplica `missed_run_policy`; `row_version++`.
  - `messaging.outbox_messages` — INSERT (`marketing.campaign_dispatch.created`) → dispara worker de snapshot y (opcional) workflow de automation.
  - `audit.audit_log` + `audit.campaign_dispatches_history` — INSERT.
- **Concurrencia:** `UNIQUE(idempotency_key)` y `UNIQUE(schedule_id, occurrence_key)` garantizan **una sola ocurrencia** aunque compitan dos workers; reclamación `SELECT … FOR UPDATE SKIP LOCKED`; `redis_runtime.idempotency_entries`.
- **Fase:** 2 · **AC:** §26.6 (una ocurrencia = un dispatch), §21.2 (dos workers → un dispatch; reinicio no duplica).

#### UC-50-19 [v4.0] Congelar audiencia del dispatch (snapshot de destinatarios) (worker)
- **Endpoint:** worker `campaign-audience-snapshot-worker`
- **Actores:** `<<system>>` `SITE_MESSAGING_WORKER`
- **Precondición:** dispatch en `planned`→`snapshotting`; evaluación de consentimiento y do-not-contact **actual** (se repite antes del envío, plan §13.6/§17.1).
- **Tablas impactadas (misma transacción, por lote de destinatarios):**
  - `marketing.campaign_dispatch_recipients` — INSERT N (una fila por `(member_type, member_ref, channel)`, con `recipient_endpoint_id`|`recipient_user_id`, `consent_id`, `consent_status`, `eligibility_status` (eligible/suppressed), `suppression_reason_concept_id`, `snapshot_json`, `idempotency_key`).
  - `crm.contact_channel_endpoints` — READ (resolución/estado do_not_contact) — sin mutación.
  - `consent.consents` / `consent.privacy_restrictions` — READ (evaluación).
  - `marketing.campaign_dispatches` — UPDATE `audience_snapshot_at`, `total_candidates/eligible/suppressed`, `status→ready`; `row_version++`.
  - `messaging.outbox_messages` — INSERT (`DispatchAudienceFrozen`).
  - `audit.audit_log` + history — INSERT.
- **Concurrencia:** `UNIQUE(dispatch_id, member_type, member_ref, channel_id)` y `UNIQUE(recipient.idempotency_key)` evitan duplicados; CHECK `eligibility='suppressed' → suppression_reason NOT NULL`; `SKIP LOCKED` por lote.
- **Proyección:** contadores derivados a `read_models.campaign_dispatch_summary`.
- **Fase:** 3 · **AC:** §26.7 (audiencia exacta + motivos), §21.3.

#### UC-50-20 [v4.0] Pausar / reanudar / cancelar dispatch en ejecución
- **Endpoint:** `POST /site-admin/marketing/dispatches/{id}/{pause|resume|cancel}`
- **Actores:** Administración del sitio
- **Precondición:** cancelación según fase (plan §13.9): detiene nuevos recipients/requests, conserva filas existentes.
- **Tablas impactadas (misma transacción):**
  - `marketing.campaign_dispatches` — UPDATE `status` (running↔paused / →cancelling→cancelled); `row_version++`.
  - `messaging.notification_requests` — UPDATE masivo de requests aún no enviadas `status→cancelled` (los ya aceptados por proveedor se conservan).
  - `messaging.outbox_messages` — INSERT (`DispatchStateChanged` / `RequestsCancelled`).
  - `audit.audit_log` + history — INSERT.
- **Concurrencia:** `SELECT … FOR UPDATE`; invalidación segura de jobs de cola; idempotente.
- **Fase:** 4 · **AC:** §26.6, §21.4.

#### UC-50-21 [v4.0] Reintentar destinatarios fallidos de un dispatch
- **Endpoint:** `POST /site-admin/marketing/dispatches/{id}/retry-failed`
- **Actores:** Administración del sitio
- **Precondición:** solo destinatarios en estado terminal `failed` reintentables (clasificación de error, plan §12.5).
- **Tablas impactadas (misma transacción):**
  - `marketing.campaign_dispatch_recipients` — UPDATE `current_status→retry_wait` para los elegibles.
  - `messaging.notification_requests` — INSERT nuevas requests (nuevo `attempt` lógico) con `idempotency_key` distinto por reintento.
  - `messaging.outbox_messages` — INSERT (`DispatchRetryRequested`).
  - `audit.audit_log` + history — INSERT (`dispatch_retry_requested`).
- **Concurrencia:** idempotencia por `(dispatch_recipient, content_hash, retry_seq)`; no reintenta errores permanentes.
- **Fase:** 5 · **AC:** §21.4, §21.5.

#### UC-50-22 [v4.0] Atribuir touchpoint a una entrega concreta
- **Endpoint:** worker `delivery-projection-worker` (derivado de eventos canónicos)
- **Actores:** `<<system>>`
- **Precondición:** existe evento canónico de interacción (READ/CLICK/REPLIED) para la delivery.
- **Tablas impactadas (misma transacción):**
  - `marketing.marketing_touchpoints` — INSERT/UPDATE con `dispatch_id`, `dispatch_recipient_id`, `notification_request_id`, `notification_delivery_id`, `tracking_event_id` (plan §6.6).
  - `messaging.outbox_messages` — INSERT (`TouchpointAttributed`).
  - `audit.audit_log` — INSERT.
- **Concurrencia:** idempotente por `tracking_event_id`.
- **Proyección:** `read_models` (atribución multi-touch, ver módulo 50 existente).
- **Fase:** 6 · **AC:** §26.12–26.14.

---

### 5.4. `messaging` (35) — Adaptadores, request/delivery y tracking canónico

#### UC-35-14 [v4.0] Registrar adaptador y declarar capacidades de tracking
- **Endpoint:** `POST /site-admin/messaging/adapters` · `GET /site-admin/messaging/adapters/{id}/capabilities`
- **Actores:** Administración del sitio
- **Precondición:** el adaptador declara qué eventos puede producir; no se promete `read` en canales que no lo demuestran (plan §8.4).
- **Tablas impactadas (misma transacción):**
  - `messaging.messaging_providers` — UPSERT (`adapter_code`, `adapter_version`, `is_builtin`, `supports_webhooks/polling/delivery_receipts/read_receipts/click_receipts/reply_receipts`, `provider_time_semantics_concept_id`).
  - `messaging.adapter_tracking_capabilities` — INSERT N (`canonical_event_type_concept_id`, `support_level` ∈ {native, inferred, local_only, unsupported}, `evidence_source`).
  - `messaging.outbox_messages` — INSERT (`AdapterRegistered`).
  - `audit.audit_log` + history — INSERT.
- **Concurrencia:** `UNIQUE(adapter_code, adapter_version)`; `row_version`.
- **Fase:** 4 · **AC:** §27, §29 (capability matrix evita confundir capacidades).

#### UC-35-15 [v4.0] Configurar canal/adaptador (webhook firmado, modo de tracking)
- **Endpoint:** `PATCH /site-admin/messaging/adapters/{id}/configuration` · `POST …/{enable|disable|rotate_credentials}`
- **Actores:** Administración del sitio (rotación de credenciales = acción peligrosa, MFA)
- **Tablas impactadas (misma transacción):**
  - `messaging.provider_channel_configs` — UPDATE `adapter_config_version++`, `webhook_endpoint_key`, `webhook_secret_credential_id` (referencia a secret manager, nunca texto claro), `webhook_signature_scheme_concept_id`, `tracking_mode_concept_id` ∈ {internal_events, webhook, polling, hybrid, none}, `polling_interval_seconds`, `status_mapping_version`, `enabled_at/disabled_at`, `enabled_by/disabled_by_user_id`; `row_version++`.
  - `iam`/secret manager — referencia a credencial (no se persiste el secreto).
  - `messaging.outbox_messages` — INSERT (`AdapterConfigChanged`/`CredentialRotated`).
  - `audit.audit_log` + history — INSERT (`adapter_config_changed`).
- **Concurrencia:** `row_version`; `SELECT … FOR UPDATE`.
- **Fase:** 4 · **AC:** §16.1, §11.3.

#### UC-35-16 [v4.0] Publicar versión de mapping de eventos del adaptador
- **Endpoint:** `POST /site-admin/messaging/adapters/{id}/event-mappings/versions`
- **Actores:** Administración del sitio
- **Precondición:** un mapping publicado es **inmutable**; una corrección crea versión nueva (plan §8.5).
- **Tablas impactadas (misma transacción):**
  - `messaging.adapter_event_mappings` — INSERT N (`mapping_version`, `external_event_code`, `canonical_event_type_concept_id`, `canonical_delivery_status_concept_id`, `terminal`, `success`, `precedence`, `condition_json`, `effective_from/to`).
  - `messaging.outbox_messages` — INSERT (`EventMappingPublished`).
  - `audit.audit_log` + history — INSERT (`event_mapping_published`).
- **Concurrencia:** `UNIQUE(provider_id, channel_id, mapping_version, external_event_code)`; CHECK `precedence≥0`, `effective_to>effective_from`.
- **Fase:** 5 · **AC:** §26.11, §21.5.

#### UC-35-17 [v4.0] Crear `notification_request` idempotente (destinatario flexible)
- **Endpoint:** worker `notification-request-worker` (deriva de recipients elegibles) / `POST /site-admin/messaging/requests` (manual site-admin)
- **Actores:** `<<system>>` / Administración del sitio
- **Precondición:** `source ∈ {marketing_campaign, journey, manual_site_admin}` exige gobierno de Administración del sitio; `IN_APP → recipient_user_id NOT NULL`; canales externos → endpoint verificado.
- **Tablas impactadas (misma transacción):**
  - `messaging.notification_requests` — INSERT (`dispatch_id`, `dispatch_recipient_id`, `recipient_type_concept_id`, `recipient_ref_id`, `recipient_endpoint_id`, `recipient_user_id` **nullable**, `source_concept_id`, `authorized_by_user_id`, `authorization_snapshot_json`, `content_snapshot_json`, `content_hash`, `idempotency_key`, `scheduled_at`, `expires_at`, `status=requested`).
  - `marketing.campaign_dispatch_recipients` — UPDATE `notification_request_id`, `current_status→queued`; `row_version++`.
  - `messaging.delivery_tracking_events` — INSERT (`REQUEST_CREATED`) append-only.
  - `messaging.outbox_messages` — INSERT (`NotificationRequested`) en la misma tx (transactional outbox).
  - `audit.audit_log` + history — INSERT.
- **Concurrencia:** `UNIQUE(notification_requests.idempotency_key)`; CHECK por canal (IN_APP vs externo); `UNIQUE(dispatch_recipient_id)`; `redis_runtime.idempotency_entries`.
- **Fase:** 4 · **AC:** §26.8, §21.4 (dos procesos no crean dos requests).

#### UC-35-18 [v4.0] Ejecutar intento de entrega vía adaptador
- **Endpoint:** worker `notification-delivery-worker`
- **Actores:** `<<system>>` `SITE_MESSAGING_WORKER`
- **Precondición:** request disponible; respeta rate limit; selecciona `provider_channel_config`.
- **Tablas impactadas (misma transacción):**
  - `messaging.notification_deliveries` — INSERT (`notification_request_id`, `attempt_number`, `provider_channel_config_id`, `adapter_code`, `adapter_version`, `started_at`, `status=sending`).
  - `messaging.delivery_tracking_events` — INSERT (`ATTEMPT_STARTED`; luego `ADAPTER_ACCEPTED`|`ADAPTER_REJECTED` según respuesta) append-only.
  - `messaging.notification_requests` — UPDATE `status` (queued→sending→accepted/failed); `row_version++`.
  - `messaging.outbox_messages` — INSERT (`DeliveryAttempted`).
  - `audit.audit_log` + history — INSERT.
- **Concurrencia:** `UNIQUE(notification_request_id, attempt_number)`; reclamación `SELECT … FOR UPDATE SKIP LOCKED`; clasificación de error → retry (backoff+jitter) o DLQ; `redis_runtime.distributed_lock_entries`.
- **Fase:** 4 · **AC:** §21.4 (attempt único; retry solo transitorio; max→DLQ).

#### UC-35-19 [v4.0] Ingerir evento crudo del adaptador (webhook/polling/interno) idempotente
- **Endpoint:** `POST /integrations/messaging/providers/{providerCode}/events` (firmado; sin sesión humana)
- **Actores:** Proveedor externo / `<<system>>` (polling o callback interno)
- **Precondición:** verificación de firma, timestamp y anti-replay; el endpoint técnico **solo** puede crear inbound events (plan §14.6).
- **Tablas impactadas (misma transacción):**
  - `messaging.adapter_inbound_events` `<<LOG>>` — INSERT (`external_event_id`, `external_event_code`, `provider_message_ref`, `payload_json_encrypted`|`payload_storage_ref`, `payload_sha256`, `headers_redacted_json`, `signature_status`, `replay_status`, `received_at`, `provider_occurred_at`, `processing_status=received`).
  - `audit.audit_log` — INSERT (recepción técnica).
- **Concurrencia:** `UNIQUE(provider_id, external_event_id) WHERE external_event_id NOT NULL`; para proveedores sin ID, `UNIQUE(provider_id, payload_sha256, received_time_bucket)`; **nunca** persiste secreto de webhook ni headers de autorización sin redacción.
- **Fase:** 5 · **AC:** §26.10, §21.5 (firma inválida, replay, duplicado).

#### UC-35-20 [v4.0] Normalizar a evento canónico y derivar estado (transición válida)
- **Endpoint:** worker `adapter-event-normalizer-worker`
- **Actores:** `<<system>>`
- **Precondición:** inbound event `received`; existe mapping versionado; se localiza la delivery.
- **Tablas impactadas (misma transacción):**
  - `messaging.delivery_tracking_events` `<<LOG>>` — INSERT (`canonical_event_type_concept_id`, `resulting_status_concept_id`, `source`, `provider_event_id`, `sequence_number`, `occurred_at`, `received_at`, `effective_at`, `precedence`, `is_terminal`, `is_success`, `is_late`, `is_duplicate`) append-only.
  - `messaging.delivery_status_transitions` — READ (valida `from_status + event_type → to_status`, `allow_late_event`, `allow_after_terminal`).
  - `messaging.notification_deliveries` — UPDATE `status_concept_id` (solo si la transición es válida y no retrocede por precedencia), timestamps derivados (`delivered_at`/`seen_at`/`read_at`/…), `last_event_at`, `last_event_id`; `row_version++`.
  - `messaging.adapter_inbound_events` — UPDATE `processing_status→normalized`, `mapping_version`, `delivery_id`.
  - `messaging.outbox_messages` — INSERT (`DeliveryEventNormalized`).
  - `audit.audit_log` — INSERT.
- **Concurrencia:** `UNIQUE(delivery_id, source, provider_event_id) WHERE provider_event_id NOT NULL`; `UNIQUE(delivery_id, canonical_event_type, sequence_number)`; `SELECT … FOR UPDATE` sobre la delivery; el estado nunca retrocede por un evento de menor precedencia.
- **Proyección:** `read_models.recipient_delivery_timeline`, contadores del dispatch, touchpoints (UC-50-22); `time_series` (lag de tracking).
- **Fase:** 5 · **AC:** §26.12–26.13, §21.5 (out-of-order, posterior a terminal, reprocess idempotente).

#### UC-35-21 [v4.0] Tratar evento fuera de orden / tardío / duplicado
- **Endpoint:** parte del normalizer (regla, no endpoint) — `POST /site-admin/messaging/tracking/events/{id}/reprocess` para reproceso manual (peligroso, MFA)
- **Actores:** `<<system>>` / Administración del sitio (reproceso)
- **Precondición:** reglas de precedencia del plan §9.4.
- **Tablas impactadas (misma transacción):**
  - `messaging.delivery_tracking_events` — INSERT con `is_late=true`/`is_duplicate=true` (nunca borra el evento); puede completar una fecha histórica faltante usando `provider_occurred_at` como tiempo de negocio.
  - `messaging.notification_deliveries` — UPDATE solo si la precedencia lo justifica; sin regresión de estado.
  - `messaging.delivery_reconciliation_runs` — INSERT/UPDATE si se detecta discrepancia (para conciliación).
  - `audit.audit_log` — INSERT (`tracking_event_reprocessed` en reproceso manual).
- **Concurrencia:** idempotente; `SELECT … FOR UPDATE`.
- **Fase:** 5 · **AC:** §26.13, §21.5.

#### UC-35-22 [v4.0] Conciliar entregas contra el adaptador (polling / callbacks perdidos)
- **Endpoint:** worker `delivery-reconciliation-worker` · `POST /site-admin/marketing/dispatches/{id}/reconcile`
- **Actores:** `<<system>>` / Administración del sitio
- **Tablas impactadas (misma transacción):**
  - `messaging.delivery_reconciliation_runs` — INSERT (`provider_channel_config_id`, `query_window_from/to`, `status`, contadores `deliveries_checked/events_imported/inconsistencies_found`).
  - `messaging.adapter_inbound_events` — INSERT de eventos faltantes importados por polling.
  - `messaging.delivery_tracking_events` / `notification_deliveries` — INSERT/UPDATE derivados (vía UC-35-20).
  - `messaging.outbox_messages` — INSERT (`ReconciliationCompleted`).
  - `audit.audit_log` — INSERT.
- **Concurrencia:** `SKIP LOCKED`; idempotencia de importación por `external_event_id`.
- **Fase:** 5 · **AC:** §18.3 (divergencia de contadores), §21.5.

#### UC-35-23 [v4.0] Cancelar request / delivery (según capacidad del adaptador)
- **Endpoint:** interno (invocado por UC-50-20) / adaptador `cancel()`
- **Actores:** `<<system>>` / Administración del sitio
- **Tablas impactadas (misma transacción):**
  - `messaging.notification_requests` — UPDATE `status→cancelled`, `cancellation_requested_at`, `cancelled_at` (solo si aún no aceptado).
  - `messaging.delivery_tracking_events` — INSERT (`CANCELLED`); si ya `accepted` y el adaptador no soporta cancelación, se conserva `accepted` y se informa que no puede retirarse.
  - `messaging.outbox_messages` — INSERT (`DeliveryCancelled`).
  - `audit.audit_log` — INSERT.
- **Concurrencia:** `SELECT … FOR UPDATE`; idempotente.
- **Fase:** 5 · **AC:** §13.9, §21.4.

#### UC-35-24 [v4.0] Entregar por `INTERNAL_APP_V1` (adaptador interno)
- **Endpoint:** worker `notification-delivery-worker` (rama internal app)
- **Actores:** `<<system>>`
- **Precondición:** canal `IN_APP`; `recipient_user_id NOT NULL`. `delivered` = notificación persistida y disponible en bandeja (plan §10.3).
- **Tablas impactadas (misma transacción):**
  - `messaging.notification_deliveries` — INSERT (`adapter_code=INTERNAL_APP_V1`, `status→delivered`, `delivered_at`).
  - `messaging.in_app_notifications` — INSERT/UPSERT (`notification_request_id`, `notification_delivery_id`, `dispatch_recipient_id`, `available_at`, `recipient_user_id`).
  - `messaging.delivery_tracking_events` — INSERT (`ATTEMPT_STARTED`, `ADAPTER_ACCEPTED`, `AVAILABLE_IN_INBOX`) append-only.
  - `messaging.outbox_messages` — INSERT (`InAppDelivered`).
  - `audit.audit_log` — INSERT.
- **Concurrencia:** `UNIQUE(in_app_notifications.notification_delivery_id)`; idempotente (crea el ítem de bandeja una sola vez).
- **Proyección:** contador de no leídas (UC-35-26).
- **Fase:** 6 · **AC:** §26.14, §21.6.

#### UC-35-25 [v4.0] Registrar interacción del usuario con su notificación interna
- **Endpoint:** `POST /me/notifications/{id}/{seen|read|dismiss|archive}` · `POST /me/notifications/{id}/actions/{actionCode}`
- **Actores:** Usuario final (destinatario)
- **Precondición:** `in_app_notifications.recipient_user_id = authenticated_user_id` (nunca notificaciones ajenas). No marcar todo como leído al cargar la bandeja.
- **Tablas impactadas (misma transacción):**
  - `messaging.in_app_notifications` — UPDATE `first_seen_at`/`last_seen_at`/`opened_at`/`dismissed_at`/`archived_at` o `action_state_json`; `row_version++`.
  - `messaging.delivery_tracking_events` — INSERT (`SEEN`/`READ`/`ACTION_CLICKED`/`DISMISSED`/`ARCHIVED`) append-only; deriva `notification_deliveries.status` (delivered→seen→read→interacted).
  - `messaging.outbox_messages` — INSERT (`InAppInteraction`).
  - `audit.audit_log` — INSERT.
- **Concurrencia:** idempotente por `(delivery_id, canonical_type)`; evento duplicado no duplica contador.
- **Proyección:** touchpoints (UC-50-22), timeline (UC-30-15).
- **Fase:** 6 · **AC:** §26.15, §21.6.

#### UC-35-26 [v4.0] Conteo de no leídas del usuario (proyección)
- **Endpoint:** `GET /me/notifications` (derivado; no contador mutable)
- **Actores:** Usuario final
- **Tablas impactadas:** READ derivado `messaging.in_app_notifications` (`recipient_user_id ∧ read_at IS NULL ∧ archived_at IS NULL ∧ status active ∧ (expires_at>now OR NULL)`) → proyección en `read_models`; job de reconciliación evita drift.
- **Concurrencia:** conteo consistente por consulta/proyección, no por contador mutable sin reconciliación.
- **Fase:** 6 · **AC:** §21.6 (unread count correcto).

---

### 5.5. `automation` (48) — Fuente única de cron

#### UC-48-15 [v4.0] Vincular trigger de automatización a un schedule publicado
- **Endpoint:** `POST /site-admin/automation/triggers:bind-campaign-schedule`
- **Actores:** Administración del sitio
- **Precondición:** el schedule ya existe y está publicado (UC-50-16); **no debe existir doble cron** para la misma campaña (plan §6.1.1).
- **Tablas impactadas (misma transacción):**
  - `automation.automation_triggers` — UPDATE `campaign_schedule_id`, `schedule_source_concept_id='campaign_schedule'`, `schedule_cron=NULL`; `row_version++`.
  - `messaging.outbox_messages` — INSERT (`TriggerBoundToSchedule`); al vencer, el scheduler de campañas (UC-50-18) crea el dispatch y publica `marketing.campaign_dispatch.created`, que `automation` consume para un workflow **complementario** sin recalcular cron.
  - `automation.workflow_runs` — INSERT con `context_ref_id = campaign_dispatch.id` cuando corre el workflow complementario.
  - `audit.audit_log` + history — INSERT.
- **Concurrencia:** CHECK `schedule_source='campaign_schedule' → campaign_schedule_id NOT NULL AND schedule_cron IS NULL`; el workflow no crea segunda ocurrencia.
- **Fase:** 2 · **AC:** §26.6 (una ocurrencia = un dispatch), §21.2 (no doble worker).

---

### 5.6. `audit` (10) — Gobierno y acceso a evidencia cruda

#### UC-10-14 [v4.0] Registrar acción de gobierno de campaña/mensajería (WORM)
- **Endpoint:** transversal (invocado por cada UC administrativo)
- **Actores:** `<<system>>` (interceptor de auditoría)
- **Tablas impactadas (misma transacción del cambio de negocio):**
  - `audit.audit_log` `<<LOG>>` — INSERT append-only con contenido mínimo del plan §16.2 (`actor_user_id`, `actor_role_snapshot`, `session_id`, `mfa_age`, `source_ip_hash`, `user_agent_redacted`, `tenant_scope`, `resource_type`, `resource_id`, `action` ∈ conjunto §16.1, `reason`, `before_hash`, `after_hash`, `correlation_id`, `occurred_at`).
  - `audit.<tabla>_history` — INSERT de la versión afectada.
- **Concurrencia:** append-only, sin UPDATE/DELETE en runtime; particionado por `occurred_at`; hash-chaining (integridad tamper-evident).
- **Proyección:** `search_platform.audit_event_search_docs`; `time_series` (métricas de acceso).
- **Fase:** 1 (y transversal) · **AC:** §26.20, §16.

#### UC-10-15 [v4.0] Registrar acceso a evento crudo de tracking (visualización de payload)
- **Endpoint:** `GET /site-admin/messaging/tracking/events/{eventId}/raw`
- **Actores:** Administración del sitio (permiso peligroso `site.messaging.tracking.view_raw_event`)
- **Precondición:** MFA reciente; motivo obligatorio; payload redactado de secretos.
- **Tablas impactadas (misma transacción):**
  - `messaging.adapter_inbound_events` — READ (payload cifrado, redacción en respuesta).
  - `audit.audit_log` `<<LOG>>` — INSERT (`raw_tracking_event_viewed`, con `reason`, `mfa_age`, `correlation_id`).
- **Concurrencia:** solo lectura + inserción de auditoría; sin mutación del evento.
- **Fase:** 5 · **AC:** §14.4, §16.1.

---

### 5.7. `read_models` (30) — Proyecciones del panel

#### UC-30-14 [v4.0] Proyectar `campaign_dispatch_summary`
- **Endpoint:** worker `delivery-projection-worker` (refresh por outbox) · `GET /site-admin/messaging/tracking/dispatches/{id}/summary`
- **Actores:** `<<system>>` / Administración del sitio (lectura consent-aware, PII enmascarada)
- **Tablas impactadas:**
  - `read_models.campaign_dispatch_summary` (MV/vista) — REFRESH incremental/`CONCURRENTLY` con contadores derivados (`total_candidates/eligible/suppressed/requests/accepted/delivered/seen/read/interacted/replied/failed/cancelled`, tasas).
  - Fuente: `marketing.campaign_dispatches` + agregación de `delivery_tracking_events`.
- **Concurrencia:** refresh `CONCURRENTLY` (requiere índice UNIQUE); consistencia eventual vía outbox; job de reconciliación de contadores.
- **Fase:** 6/7 · **AC:** §15.1, §18.3.

#### UC-30-15 [v4.0] Proyectar `recipient_delivery_timeline`
- **Endpoint:** `GET /site-admin/messaging/tracking/deliveries/{deliveryId}/events`
- **Actores:** Administración del sitio (lectura enmascarada; raw solo por UC-10-15)
- **Tablas impactadas:**
  - `read_models.recipient_delivery_timeline` (vista) — proyecta identidad enmascarada, endpoint enmascarado, campaña, dispatch, request, intentos, eventos canónicos en orden, estado actual, motivo de fallo, próximo retry, snapshot de consentimiento.
  - Fuente: `delivery_tracking_events` + `notification_deliveries` + `notification_requests` + `campaign_dispatch_recipients`.
- **Concurrencia:** lectura consent-aware con masking heredado de `authz.field_permissions`.
- **Fase:** 6/7 · **AC:** §15.2, §26.16.

#### UC-30-16 [v4.0] Proyectar `adapter_health_summary`
- **Endpoint:** `GET /site-admin/messaging/adapters/{id}` (salud) — deriva de métricas
- **Actores:** `<<system>>` / Administración del sitio
- **Tablas impactadas:**
  - `read_models.adapter_health_summary` (MV) — `last_success_at`, `last_failure_at`, `success_rate_15m/24h`, `p95_latency`, `rate_limited_count`, `webhook_lag`, `unprocessed_inbound_events`, `DLQ count`.
  - Fuente: `notification_deliveries`, `adapter_inbound_events`, `messaging.dead_letter_jobs` + `time_series`.
- **Concurrencia:** refresh periódico; no expone `user_id` como etiqueta de métrica (plan §22.1).
- **Fase:** 7 · **AC:** §15.3, §22.

---

## 6. Taxonomía canónica de tracking (resumen operativo)

**Eventos canónicos** (evidencia, más expresivos que los estados): `REQUEST_CREATED, REQUEST_VALIDATED, REQUEST_SUPPRESSED, REQUEST_SCHEDULED, REQUEST_CANCELLED, REQUEST_EXPIRED, QUEUED, DEQUEUED, ATTEMPT_STARTED, ADAPTER_ACCEPTED, ADAPTER_REJECTED, SENT, DELIVERED, AVAILABLE_IN_INBOX, SEEN, READ, OPENED, ACTION_CLICKED, LINK_CLICKED, REPLIED, BOUNCED_SOFT, BOUNCED_HARD, UNSUBSCRIBED, SPAM_REPORTED, RATE_LIMITED, TEMPORARY_FAILURE, PERMANENT_FAILURE, RETRY_SCHEDULED, DEAD_LETTERED, CANCELLED, EXPIRED, ARCHIVED, DISMISSED`.

**Estados actuales** (acotados, derivados): `requested, scheduled, suppressed, queued, sending, accepted, delivered, seen, read, interacted, replied, retry_wait, failed, cancelled, expired, dead_lettered`.

**Terminales:** `failed, cancelled, expired, dead_lettered`. `delivered/seen/read/interacted` **no** son necesariamente terminales (pueden llegar eventos posteriores). Semántica clave: `accepted` ≠ recibido; `delivered` = evidencia según capacidad del canal; `read` exige acción explícita o recibo confiable; `opened` (email) ≠ `read` universal. (Plan §9.)

**Value sets nuevos a sembrar (dynamic enums, `system_context`):** `vs_campaign_schedule_type`, `vs_missed_run_policy`, `vs_overlap_policy`, `vs_campaign_schedule_status`, estados de `campaign_dispatch`, motivos de supresión, `tracking_mode`, `support_level`, tipos de evento canónico, estados canónicos, transiciones. (Plan §6.1, §20.1.)

---

## 7. Máquinas de estado nuevas (registrar en módulo 32 `workflow`)

- **`campaign_schedule_machine`:** `draft → validated → scheduled → (paused ↔ scheduled) → completed | cancelled | invalid`.
- **`campaign_dispatch_machine`:** `planned → snapshotting → ready → queued → running → (partially_completed) → completed | paused | cancelling → cancelled | failed | expired`.
- **`notification_delivery_machine`:** transiciones gobernadas por `delivery_status_transitions` (ej.: `NULL+REQUEST_CREATED→requested`, `queued+ATTEMPT_STARTED→sending`, `sending+ADAPTER_ACCEPTED→accepted`, `accepted+DELIVERED→delivered`, `delivered+SEEN→seen`, `seen+READ→read`, `read+ACTION_CLICKED→interacted`, `accepted+PERMANENT_FAILURE→failed`, `queued+CANCELLED→cancelled`, `accepted+EXPIRED→expired`), con `allow_late_event` / `allow_after_terminal` y precedencia. (Plan §8.10, §9.4.)

Cada transición: valida guarda → escribe estado + evento en la **misma tx** → outbox; reintento idempotente; compensación por saga cuando aplique (patrón del UC-32-05/08 existente).

---

## 8. Plan de implementación por fases (alineado con el plan fuente §19/§25)

| Fase | Nombre | Casos de uso | Migraciones (§19) | Gate de salida |
|---|---|---|---|---|
| 0 | Confirmación de contrato | — (decisiones §3) | ADRs, matriz de permisos, taxonomía | "Administración del sitio" con código/alcance inequívocos |
| 1 | Seguridad y anti-bypass | UC-06-13..18, UC-10-14 | Fase 1 (rol, permisos protegidos, triggers, service principal, RLS) | Pruebas negativas completas (§21.1) |
| 2 | Programación formal | UC-50-16, UC-50-17, UC-50-18, UC-48-15 | Fase 2 (schedules) + trigger link | Dos workers no crean doble dispatch (§21.2) |
| 3 | Dispatch y audiencia | UC-50-13..15, UC-50-19, UC-49-16..17 | Fases 2–3 (dispatches, recipients, endpoints) | Audiencia reproducible y auditada (§21.3) |
| 4 | Request y delivery | UC-35-14..15, UC-35-17..18, UC-50-20 | Fase 4 (adaptadores) + ext requests/deliveries | ≤1 request por clave de recipient (§21.4) |
| 5 | Tracking base | UC-35-16, UC-35-19..23, UC-10-15, UC-50-21 | Fase 5 (inbound, tracking, transitions, reconciliation) | Duplicados/out-of-order no corrompen estado (§21.5) |
| 6 | Adaptador internal app | UC-35-24..26, UC-50-22, UC-30-14..15 | Fase 6 (in-app ext + endpoints) | Timeline completo campaña→lectura interna (§21.6) |
| 7 | Panel + proyecciones | UC-30-16 + endpoints de consulta | Fase 7 (workers, dashboards) | No autorizados sin acceso por UI ni API |
| 8 | Endurecimiento | (todos) | Fase 8 (RLS, particionado, retención, carga, rollback) | Evidencia de carga y restauración |

**Workers a desplegar (persistentes, separados del API, `SIGTERM`/`SIGINT`, `SELECT … FOR UPDATE SKIP LOCKED`):** `campaign-scheduler-worker`, `campaign-audience-snapshot-worker`, `notification-request-worker`, `notification-delivery-worker`, `adapter-event-normalizer-worker`, `delivery-projection-worker`, `delivery-reconciliation-worker`. (Plan §12.)

**Idempotencia por nivel (plan §12.4):** schedule (`schedule_id + planned_at_norm`), dispatch (`campaign_version + occurrence_key`), recipient (`dispatch + recipient + channel + step`), request (`dispatch_recipient + content_hash`), attempt (`request + attempt_number`), provider send (clave externa), inbound (`provider + external_event_id`), canonical (`delivery + provider_event_id + canonical_type`).

---

## 9. Matriz de trazabilidad (caso de uso → tablas → fase → criterio)

| UC | Tabla(s) principal(es) nuevas/extendidas | Operación clave | Fase | AC |
|---|---|---|---|---|
| UC-06-13 | `authz.permissions` (+cols) | UPDATE protección | 1 | §26.3 |
| UC-06-14 | `authz.roles`, `role_permissions` | INSERT seed | 1 | §26.1–3 |
| UC-06-15 | `authz.user_role_assignments`, `iam.security_events` | INSERT | 1 | §26.20 |
| UC-06-16 | `authz.user_permission_grants`/`role_permissions` | INSERT rechazado | 1 | §26.3 |
| UC-06-17 | `authz.service_principals` | UPSERT | 1 | §26.19 |
| UC-06-18 | `authz.access_policies`, `field_permissions` | INSERT | 1 | §26.1–3 |
| UC-49-16 | `crm.contact_channel_endpoints` | INSERT/UPDATE verify | 3 | contacto sin IAM |
| UC-49-17 | `crm.contact_channel_endpoints`, `consent.*` | UPDATE do_not_contact | 3 | §26.7 |
| UC-50-13 | `marketing.marketing_campaigns` | INSERT/UPDATE draft | 3 | §26.1 |
| UC-50-14 | `marketing.marketing_campaigns` | UPDATE validate | 3 | §26.4 |
| UC-50-15 | `marketing.marketing_campaigns` | UPDATE publish+hash | 3 | §26.4 |
| UC-50-16 | `marketing.campaign_schedules`, `automation.automation_triggers` | INSERT + link | 2 | §26.4–5 |
| UC-50-17 | `marketing.campaign_schedules` | UPDATE estado | 2 | §26.6 |
| UC-50-18 | `marketing.campaign_dispatches`, `campaign_schedules` | INSERT idempotente | 2 | §26.6 |
| UC-50-19 | `marketing.campaign_dispatch_recipients`, `campaign_dispatches` | INSERT N + UPDATE | 3 | §26.7 |
| UC-50-20 | `marketing.campaign_dispatches`, `messaging.notification_requests` | UPDATE cancel | 4 | §26.6 |
| UC-50-21 | `campaign_dispatch_recipients`, `notification_requests` | UPDATE/INSERT retry | 5 | §21.4 |
| UC-50-22 | `marketing.marketing_touchpoints` | INSERT atribución | 6 | §26.12–14 |
| UC-35-14 | `messaging.messaging_providers`, `adapter_tracking_capabilities` | UPSERT/INSERT | 4 | §29 |
| UC-35-15 | `messaging.provider_channel_configs` | UPDATE config | 4 | §16.1 |
| UC-35-16 | `messaging.adapter_event_mappings` | INSERT versión | 5 | §26.11 |
| UC-35-17 | `messaging.notification_requests`, `delivery_tracking_events`, `campaign_dispatch_recipients` | INSERT idempotente | 4 | §26.8 |
| UC-35-18 | `messaging.notification_deliveries`, `delivery_tracking_events` | INSERT attempt | 4 | §21.4 |
| UC-35-19 | `messaging.adapter_inbound_events` | INSERT crudo | 5 | §26.10 |
| UC-35-20 | `messaging.delivery_tracking_events`, `notification_deliveries` | INSERT + transición | 5 | §26.12–13 |
| UC-35-21 | `messaging.delivery_tracking_events` | INSERT late/dup | 5 | §26.13 |
| UC-35-22 | `messaging.delivery_reconciliation_runs` | INSERT run | 5 | §18.3 |
| UC-35-23 | `messaging.notification_requests`/`deliveries` | UPDATE cancel | 5 | §13.9 |
| UC-35-24 | `messaging.in_app_notifications`, `notification_deliveries` | INSERT internal | 6 | §26.14 |
| UC-35-25 | `messaging.in_app_notifications`, `delivery_tracking_events` | UPDATE + INSERT | 6 | §26.15 |
| UC-35-26 | `messaging.in_app_notifications` (proyección) | READ derivado | 6 | §21.6 |
| UC-48-15 | `automation.automation_triggers`, `workflow_runs` | UPDATE bind | 2 | §26.6 |
| UC-10-14 | `audit.audit_log` + `*_history` | INSERT WORM | 1 | §26.20 |
| UC-10-15 | `audit.audit_log` | INSERT acceso raw | 5 | §14.4 |
| UC-30-14 | `read_models.campaign_dispatch_summary` | REFRESH | 6/7 | §15.1 |
| UC-30-15 | `read_models.recipient_delivery_timeline` | vista | 6/7 | §15.2 |
| UC-30-16 | `read_models.adapter_health_summary` | REFRESH | 7 | §15.3 |

---

## 10. Deltas a los diagramas `.puml` (alineado con plan §24)

Aplicar sobre los archivos existentes de este proyecto (`casos_uso_*.puml`) y sobre los diagramas de modelo (`diagram_*.puml`):

- **`casos_uso_06_authz.puml` / `diagram_06_authz.puml`:** añadir `UC-06-13..18`; en el modelo, columnas `permissions.is_role_restricted/required_role_code/allow_direct_user_grant`, rol `SITE_ADMINISTRATION` (seed/nota), tabla `service_principals`, y nota de prohibición de grants directos.
- **`casos_uso_50_marketing.puml` / `diagram_50_marketing.puml`:** añadir `UC-50-13..22`; entidades `campaign_schedules`, `campaign_dispatches`, `campaign_dispatch_recipients`; extensiones de `marketing_campaigns` y `marketing_touchpoints`; boundary de Administración del sitio; estados y constraints.
- **`casos_uso_35_messaging.puml` / `diagram_35_messaging.puml`:** añadir `UC-35-14..26`; entidades `adapter_tracking_capabilities`, `adapter_event_mappings`, `adapter_inbound_events` `<<LOG>>`, `delivery_tracking_events` `<<LOG>>`, `delivery_status_transitions`, `delivery_reconciliation_runs`; extensiones de `messaging_providers`, `provider_channel_configs`, `notification_requests` (destinatario flexible), `notification_deliveries`, `in_app_notifications`; relaciones dispatch→request→delivery→event.
- **`casos_uso_48_automation.puml` / `diagram_48_automation.puml`:** `UC-48-15`; extensión `automation_triggers.campaign_schedule_id` + `schedule_source_concept_id`; nota "worker no cambia contenido/audiencia; approvals ≠ RBAC".
- **`casos_uso_49_crm.puml` / `diagram_49_crm.puml`:** `UC-49-16..17`; entidad `contact_channel_endpoints`.
- **`casos_uso_10_audit.puml` / `diagram_10_audit.puml`:** `UC-10-14..15`; nuevos tipos de evento de gobierno (§16.1) y acceso a tracking crudo.
- **`casos_uso_30_read_models.puml` / `diagram_30_read_models.puml`:** `UC-30-14..16`; vistas `campaign_dispatch_summary`, `recipient_delivery_timeline`, `adapter_health_summary`.
- **`casos_uso_00_INDICE_MAESTRO.puml`:** añadir flujos `M06→M50→M48→M35→M30/M10` y `M49→M35`.

**Nuevos diagramas de comportamiento a crear** (plan §24.8): `activityDiagramScheduledCampaign.puml`, `stateDiagramCampaignSchedule.puml`, `stateDiagramCampaignDispatch.puml`, `stateDiagramNotificationDelivery.puml`, `sequenceDiagramInternalAppDelivery.puml`, `sequenceDiagramExternalAdapterWebhook.puml`, `componentDiagramMessagingAdapters.puml`.

> Si quieres, en un siguiente paso genero directamente estos `.puml` (los 7 nuevos + los deltas insertados en los archivos de casos de uso existentes), con el mismo lint 0-errores.

---

## 11. Pruebas obligatorias por caso de uso (alineado con plan §21)

- **Autorización (UC-06-13..18):** site-admin puede crear/publicar/programar/cancelar; doctor/enfermera/admin-consultorio/admin-tenant → 403; grant directo sobre permiso protegido → rechazo; role_permission protegido a otro rol → rechazo; sin MFA reciente no ve evento crudo; worker no publica.
- **Programación (UC-50-16..18, UC-48-15):** fecha única/cron válido/inválido; DST; pausa/cancel; missed_run=skip; overlap=forbid; dos workers → un dispatch; reinicio no duplica.
- **Audiencia (UC-50-19, UC-49-16..17):** deduplicación; consentimiento válido/revocado; do_not_contact; endpoint no verificado; quiet_hours; contacto sin IAM; recipient snapshot inmutable.
- **Request/delivery (UC-35-17..18, UC-50-20..21):** request idempotente; dos procesos → una request; attempt único; retry solo transitorio; permanente→failed; max→DLQ; cancelación antes/después de accepted según capacidad.
- **Tracking (UC-35-19..23, UC-10-15):** webhook válido/firma inválida/replay/duplicado/sin delivery/mapping inexistente/versionado/out-of-order/posterior-a-terminal; proyección correcta; reprocess idempotente; raw redactado.
- **Internal app (UC-35-24..26):** inbox item una sola vez; delivered al persistir; seen/read/click/dismiss/archive explícitos; no modificar notificación ajena; unread count correcto; duplicado no duplica contador.
- **Rendimiento (Fase 8):** expansión de audiencia grande; backpressure; rate limit; 100 workers sin duplicar; ingestión de webhooks; timeline paginado; `EXPLAIN ANALYZE` de consultas críticas.

---

## 12. Riesgos y rollback (referencia al plan §28/§29)

**Riesgos clave mitigados por diseño:** doble envío (idempotency keys + unique) · bypass por grant directo (permisos protegidos no delegables, UC-06-16) · evento duplicado (`UNIQUE` provider event id/hash) · evento tardío (`is_late` + precedencia) · proveedor sin tracking (capability matrix, `local_only`) · confundir `accepted`/`delivered` (semántica canónica) · PHI (boundary + validación de variables) · contacto sin IAM (endpoint polimórfico) · payload sensible (cifrado + acceso excepcional + retención corta) · timezone (IANA + tests DST) · contadores divergentes (proyección idempotente + reconciliación) · webhook falsificado (firma + timestamp + anti-replay).

**Rollback (expand/contract):** feature flag `SITE_SCHEDULED_CAMPAIGNS_V2`; mantener columnas antiguas (`recipient_address`, `delivery_receipts`, status previos) durante la transición; etapas expand → dual-write controlado → backfill → lectura v2 → validar → dejar de escribir v1 → retirar v1 en release posterior. **Kill switch** global: pausar nuevos dispatches / pausar un adaptador / pausar entregas externas / mantener internal app si se autoriza — sin borrar jobs ni datos.

---

## 13. Definición de terminado (para este patch)

El patch se considera implementable-completo cuando, por cada caso de uso, existan: migración versionada (sin `sync alter`/`force`), seeds boot idempotentes (rol, permisos, canal/adaptador `INTERNAL_APP`, capacidades, eventos/estados/transiciones canónicos, value sets), servicios/workers, adaptador interno de extremo a extremo, tracking en 3 capas, permisos anti-bypass probados, endpoints con guard + policy + validación de dominio, UI administrativa, pruebas negativas y de idempotencia/carga, auditoría, observabilidad (métricas sin `user_id` como label), documentación (ADR/runbook/README por módulo) y plan de rollback. Cualquier entrega que omita uno de estos elementos se presenta como **parcial**, no como capacidad de producción. (Plan §32.)

---

### Anexo A — Casos de uso añadidos por este patch (37 en 7 módulos)

`authz`: UC-06-13, 14, 15, 16, 17, 18 · `crm`: UC-49-16, 17 · `marketing`: UC-50-13, 14, 15, 16, 17, 18, 19, 20, 21, 22 · `messaging`: UC-35-14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26 · `automation`: UC-48-15 · `audit`: UC-10-14, 15 · `read_models`: UC-30-14, 15, 16.

**Total: 37 casos de uso nuevos** que llevan el modelo SALUD de 760 a **797 casos de uso**.
