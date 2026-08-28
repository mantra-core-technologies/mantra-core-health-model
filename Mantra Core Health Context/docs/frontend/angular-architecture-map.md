# Mapa de arquitectura para Angular — módulos, portales y features

> Fecha: 2026-07-27 · Versión del modelo: SALUD v4.0.7
> Propósito: fuente única para diseñar el árbol de features y rutas de `mantra-core-health`
> (ex `mantra-core-redesa`, renombrado 2026-07-27; nombre de producto provisional)
> sin re-explorar el repositorio.

---

## 0 · Estado real de la superficie HTTP (leer antes que nada)

**Hoy no existen endpoints de dominio.** Este documento describe el modelo y el destino, no una
API en funcionamiento.

| Aspecto | Estado verificado |
|---|---|
| Módulos NestJS registrados en `AppModule` | **57** (+ `LoggingModule`, `OrmModule`) |
| Controllers de dominio | 57 archivos, **todos clases vacías** (`@Controller('iam') export class IamController {}`) |
| Endpoints reales en todo el repo | **1** — `GET /` → `"Hello World!"` (`src/app.controller.ts:8`) |
| Servicios de dominio | 57 archivos, **todos cuerpo vacío** |
| `setGlobalPrefix` / versionado / CORS | **No existen** |
| Swagger / OpenAPI | **No existe** (`@nestjs/swagger` instalado, sin usar) |
| `ValidationPipe` global / DTOs | **No existen** |
| Autenticación (login, JWT, guards) | **No existe** — `@nestjs/jwt`, `passport`, `argon2`, `@casl/ability` instalados y sin usar |

Lo que **sí** existe y es el activo pesado del proyecto: **~1 179 entidades MikroORM** mapeadas
contra 1 173 tablas físicas, con verificación de fidelidad en runtime y en dev-time.

> Consecuencia para Angular: cualquier afirmación funcional sobre datos reales es **BLOCKED**
> hasta que exista el primer endpoint. El trabajo que sí se puede hacer hoy es el sistema de
> diseño, el árbol de rutas, los shells de portal y los componentes dirigidos por metadatos.

---

## 1 · La decisión estructural

**Las features de Angular se mapean a los 17 portales del Módulo 34, no a los 64 módulos del
modelo.** Los módulos son la capa de datos; los portales son la capa de producto. Un módulo
alimenta varios portales (M26 `insurance` aparece en Insurance, Broker, Patient y Pharmacy), y
una sección de portal se sirve de varios módulos.

El modelo declara el frontend **como datos**, no como código:

```
portal_surfaces  →  frontend_routes  →  frontend_page_views  →  ┬─ frontend_view_fields
   (M34)              (ruta Angular)      (pantalla)            ├─ frontend_view_filters
                                                                ├─ frontend_view_sort_options
              read_model_definitions ─────────┘                 ├─ frontend_view_actions
                (contrato de datos versionado)                  ├─ frontend_view_kpis
                                                                └─ frontend_view_states
```

Las 13 tablas de metadatos del M30 más sus 76 proyecciones de lectura son el contrato. Ver
[frontend-view-contracts.md](./frontend-view-contracts.md),
[erp-crm-front-views.md](./erp-crm-front-views.md) y
[v3.8-operational-clinical-views.md](./v3.8-operational-clinical-views.md) — este documento no
repite sus listas, las enlaza.

---

## 2 · Inventario de los 64 módulos

Nombres **literales del `.puml`** (fuente canónica). Columna «Nest» = existe módulo NestJS.
Columna «Prefijo» = valor de `@Controller(...)` hoy registrado.

| NN | Módulo (título canónico del `.puml`) | Dominio | Schema | Ent. | Nest | Prefijo | Portales |
|---|---|---|---|---|---|---|---|
| 00 | SALUD v4.0 — Canonical Platform Architecture and Polyglot Data Module Index | Núcleo y Terminología | `platform` | 0 | — | — | — |
| 01 | Identity & Access — User Accounts and Security | Identidad y Seguridad | `iam` | 22 | ✔ | `iam` | Public, Patient, Hospital |
| 02 | Shared Identifiers, Contacts, Addresses and Files | Núcleo y Terminología | `common` | 14 | ✔ | `common` | transversal |
| 03 | Terminology, Value Sets and Dynamic Catalogs | Núcleo y Terminología | `terminology` | 30 | ✔ | `terminology` | SysAdmin · transversal |
| 04 | Tenants, Organizations, Sites and Directory | Núcleo y Terminología | `directory` | 14 | ✔ | `directory` | SysAdmin, Hospital |
| 05 | Persons, Patients and General Health Workforce | Núcleo y Terminología | `profiles` | 36 | ✔ | `profiles` | Doctor, Hospital, HDC |
| 06 | Authorization, Purpose of Use and Field Masking | Identidad y Seguridad | `authz` | 25 | ✔ | `authz` | transversal (guards) |
| 07 | Privacy Directives, Legal Bases and Consent Evidence | Identidad y Seguridad | `consent` | 20 | ✔ | `consent` | Patient, Ads |
| 08 | Core Clinical Record, Orders and Encounter Logistics | Clínico y Diagnóstico | `clinical` | 42 | ✔ | `clinical` | Doctor, Patient, Hospital, Pharmacy |
| 09 | Dynamic Forms and Extensibility Governance | Clínico y Diagnóstico | `forms` | 33 | ✔ | `forms` | Doctor, OR |
| 10 | Audit, Provenance and Version Histories | Auditoría y Reporting | `audit` | 246 | ✔ | `audit` | SysAdmin, Doctor, HDC |
| 11 | Data Governance and System Operations | Operaciones de Plataforma | `system_ops` | 58 | ✔ | `system-ops` | SysAdmin, Ops, Hospital |
| 12 | External Connectivity and Messaging | Integraciones y Contratos | `integrations` | 20 | ✔ | `integrations` | SysAdmin |
| 13 | Geolocation and Mobile Tracking | Núcleo y Terminología | `geo` | 12 | ✔ | `geo` | Public, Patient |
| 14 | Care Organizations, Sites, Units, Spaces and Workforce | Práctica y Agenda | `practice` | 22 | ✔ | `practice` | Hospital, Doctor, Patient |
| 15 | Versioned Patient Chart, Notes and Documents | Clínico y Diagnóstico | `chart` | 23 | ✔ | `chart` | Doctor, Patient, HDC, OR |
| 16 | General Ledger and Accounting Subledgers | Financiero y ERP | `accounting` | 84 | ✔ | `accounting` | ERP, Payments |
| 17 | Billing, Receivables, Payables and Financial Planning | Financiero y ERP | `billing` | 41 | ✔ | `billing` | ERP, Patient, Insurance, Broker, Payments |
| 18 | Care Coordination, Alerts and Decision Support | Clínico y Diagnóstico | `clinical_ext` | 25 | ✔ | `clinical-ext` | Doctor, OR |
| 19 | Public Profiles, Social Graph, Messaging and Moderation | Marketing y Crecimiento | `community` | 78 | ✔ | `community` | Public, Doctor |
| 20 | Laboratory, Medical Imaging and Clinical Media | Clínico y Diagnóstico | `diagnostics` | 72 | ✔ | `diagnostics` | Diagnostic, Doctor, Patient, OR |
| 21 | Deployment, Data Centers and Regional Topology | Operaciones de Plataforma | `deployment` | 0 | — | — | Ops |
| 22 | Healthcare Organization Specializations | Práctica y Agenda | `organization_extensions` | 10 | ✔ | `organization-extensions` | Hospital |
| 23 | Diagnostic Units, Studies, Specialists and Prices | Clínico y Diagnóstico | `diagnostic_units` | 20 | ✔ | `diagnostic-units` | Diagnostic, Public |
| 24 | Pharmacy Identity, Sites, Catalog and Pricing | Farmacia | `pharmacy` | 18 | ✔ | `pharmacy` | Pharmacy, Public, Doctor, Patient |
| 25 | Pharmacy Inventory, Supply and Dispensing | Farmacia | `pharmacy_inventory` | 38 | ✔ | `pharmacy-inventory` | Pharmacy, ERP, OR |
| 26 | Insurance Networks, Operations, Appeals and Reconciliation | Financiero y ERP | `insurance` | 58 | ✔ | `insurance` | Insurance, Broker, Patient, Pharmacy |
| 27 | Identity Proofing, Assertions and Fraud Controls | Identidad y Seguridad | `identity_assurance` | 22 | ✔ | `identity-assurance` | SysAdmin, Public |
| 28 | User Activity, Consent-Aware Tracking and Analytics | Operaciones de Plataforma | `telemetry` | 28 | ✔ | `telemetry` | Ads, Ops |
| 29 | Delegated Access and Scoped Infrastructure Users | Identidad y Seguridad | `delegated_access` | 14 | ✔ | `delegated-access` | Doctor, Hospital, Patient |
| 30 | Frontend View Contracts, Routes and Read Models | Auditoría y Reporting | `read_models` | 103 | ✔ | `read-models` | **todos** (es el contrato) |
| 31 | Governed Backend-to-Backend Contracts | Integraciones y Contratos | `integration_contracts` | 18 | ✔ | `integration-contracts` | SysAdmin |
| 32 | State Machines and Cross-Domain Workflows | Operaciones de Plataforma | `workflow` | 25 | ✔ | `workflow` | SysAdmin, Diagnostic, Insurance |
| 33 | Concurrency, Constraints and Integrity Matrix | Integraciones y Contratos | `integrity` | 0 | — | — | — |
| 34 | Portal Catalogue, Navigation and UX State Boundaries | Marketing y Crecimiento | `portal_catalog` | 0 | — | — | **define los 17** |
| 35 | Domain Events, Outbox, Queues and Notification Delivery | Integraciones y Contratos | `messaging` | 32 | ✔ | `messaging` | Patient, SysAdmin, CRM, Payments |
| 36 | Quality Assurance Lab and Test Evidence | Clínico y Diagnóstico | `qa_lab` | 26 | ✔ | `qa-lab` | Diagnostic |
| 37 | Shipments, Milestones and Status Timelines | Integraciones y Contratos | `tracking` | 16 | ✔ | `tracking` | Pharmacy, ERP |
| 38 | Internal ERP, Contracts, HR and Organization | Financiero y ERP | `erp` | 103 | ✔ | `erp` | ERP, Hospital, Broker, Pharmacy |
| 39 | Reporting, Dashboards and Scheduled Distribution | Auditoría y Reporting | `reporting` | 24 | ✔ | `reporting` | ERP, SysAdmin |
| 40 | Federated Authentication Providers and Identity Linking | Identidad y Seguridad | `auth_providers` | 19 | ✔ | `auth-providers` | Public |
| 41 | Appointments, Availability, Holds and Waitlists | Práctica y Agenda | `scheduling` | 31 | ✔ | `scheduling` | Patient, Doctor, OR |
| 42 | Payment Gateways, Transactions, Refunds and Payouts | Financiero y ERP | `payments` | 106 | ✔ | `payments` | Payments, Patient, ERP, Broker, Insurance |
| 43 | Advertising, Assets, Delivery, Commerce and Optimization | Marketing y Crecimiento | `ads` | 146 | ✔ | `ads` | Ads |
| 44 | Country Health Environment Context | Núcleo y Terminología | `health_context` | 20 | ✔ | `health-context` | SysAdmin |
| 45 | System Context and Dynamic Enumerations | Núcleo y Terminología | `system_context` | 18 | ✔ | `system-context` | SysAdmin · transversal |
| 46 | Platform Operations, Observability and Releases | Operaciones de Plataforma | `platform_ops` | 76 | ✔ | `platform-ops` | Ops, SysAdmin, Hospital |
| 47 | Medical Education and Continuing Professional Development | Marketing y Crecimiento | `education` | 30 | ✔ | `education` | Education |
| 48 | Automation and Multi-Agent Orchestration | Operaciones de Plataforma | `automation` | 32 | ✔ | `automation` | SysAdmin |
| 49 | Customer and Partner Relationship Management | Marketing y Crecimiento | `crm` | 64 | ✔ | `crm` | CRM, Broker, Ads |
| 50 | Marketing Automation, Journeys and Attribution | Marketing y Crecimiento | `marketing` | 22 | ✔ | `marketing` | CRM |
| 51 | Loyalty, Discounts, Coupons and Referrals | Marketing y Crecimiento | `promotions` | 22 | ✔ | `promotions` | CRM |
| 52 | International Health Data Platform, Interoperability and Longitudinal Record | Datos y NoSQL | `health_data` | 68 | ✔ | `health-data` | HDC, Patient, Doctor |
| 53 | Medical Interventions, Surgery and Perioperative Care | Clínico y Diagnóstico | `procedures_perioperative` | 70 | ✔ | `procedures-perioperative` | OR |
| 54 | Polyglot Storage Governance and Data Placement | Datos y NoSQL | `polyglot_storage` | 40 | ✔ | `polyglot-storage` | HDC, SysAdmin |
| 55 | Document Store for FHIR, Variable Payloads and Versioned Snapshots | Datos y NoSQL | `document_store` | 26 | — | — | HDC (backend) |
| 56 | Redis Runtime Cache, Ephemeral Security and Coordination | Datos y NoSQL | `redis_runtime` | 28 | — | — | backend |
| 57 | Search and Operational Index Projections | Datos y NoSQL | `search_platform` | 26 | — | — | Public, CRM (backend) |
| 58 | High-Volume Time Series and Event Analytics | Datos y NoSQL | `time_series` | 24 | ✔ | `time-series` | Ops, Ads |
| 59 | Vector Search, RAG Evidence and Embedding Governance | Datos y NoSQL | `vector_rag` | 28 | ✔ | `vector-rag` | Doctor, HDC |
| 60 | Object Storage, Medical Media and PACS Catalog | Datos y NoSQL | `object_storage` | 34 | ✔ | `object-storage` | Diagnostic, Doctor, Patient |
| 61 | Graph Projections for Relationships, Referrals and Risk | Datos y NoSQL | `graph_intelligence` | 26 | ✔ | `graph-intelligence` | CRM, HDC |
| 62 | Outbox Projection, Reconciliation and Deletion Propagation | Datos y NoSQL | `cross_store_consistency` | 40 | ✔ | `cross-store-consistency` | backend |
| 63 | Lakehouse, Analytical Data Products and Research Releases | Datos y NoSQL | `lakehouse` | 36 | ✔ | `lakehouse` | HDC, ERP |

### 2.1 · Los 7 módulos sin módulo NestJS — no es deriva

57 de 64 tienen módulo Nest. Los 7 restantes **están correctamente ausentes**; no hay que
«arreglar» el conteo:

- **Documentales, 0 tablas relacionales:** `00 platform`, `21 deployment`, `33 integrity`,
  `34 portal_catalog`. Son diagramas de arquitectura, casos de uso y matrices de integridad.
- **No-Postgres, sin entidades MikroORM:** `55 document_store` (MongoDB), `56 redis_runtime`
  (Redis), `57 search_platform` (OpenSearch). Su acceso irá por adapters, no por el ORM
  (§4 de la guía ORM: los stores especializados entran solo por outbox + workers).

### 2.2 · Los 11 dominios

| Dominio | Módulos | Entidades del modelo |
|---|---|---|
| Núcleo y Terminología | 8 | 144 |
| Identidad y Seguridad | 6 | 122 |
| Clínico y Diagnóstico | 8 | 311 |
| Práctica y Agenda | 3 | 63 |
| Farmacia | 2 | 56 |
| Financiero y ERP | 5 | 392 |
| Integraciones y Contratos | 5 | 86 |
| Auditoría y Reporting | 3 | 373 |
| Operaciones de Plataforma | 6 | 219 |
| Marketing y Crecimiento | 7 | 362 |
| Datos y NoSQL | 11 | 376 |
| **Total** | **64** | **2 504** |

> Los dominios son un eje de **navegación del modelo**, no un eje de producto. No conviene
> derivar de ellos la estructura de Angular: «Datos y NoSQL» no es una pantalla.

### 2.3 · Por qué los conteos no coinciden entre sí

Tres números distintos, los tres correctos:

- **2 504 entidades del modelo** — incluye entidades `<<INDEX_SET>>`, `<<VIEW>>`,
  `<<MATERIALIZED_VIEW>>` y stubs `<<REFERENCE_ONLY>>`. Explica los picos de M10 (246) y
  M43 (146).
- **1 173 tablas físicas** en Postgres (1 147 del DDL + 12 `time_series` + 14 `vector_rag`).
- **1 179 entidades MikroORM** — 6 más que tablas; deriva conocida y documentada aguas arriba
  en los `.puml`/`gen_ddl.py`, no en el ORM.

### 2.4 · Divergencias literales entre capas (para no propagarlas)

Los títulos de las notas del vault difieren del `.puml` en 4 módulos. **La fuente canónica es
el `.puml`**, que es lo que usa la tabla de arriba:

| NN | `.puml` (canónico) | Nota del vault |
|---|---|---|
| 00 | …Canonical Platform **Architecture** and Polyglot Data **Module Index** | …Canonical Platform and Polyglot Data Architecture |
| 05 | Persons, Patients and **General** Health Workforce | Persons, Patients and Health Workforce |
| 30 | Frontend View Contracts, **Routes** and Read Models | Frontend View Contracts and Read Models |
| 34 | Portal Catalogue, **Navigation and UX State Boundaries** | Portal Catalogue and Frontend Navigation |

Además: **M52** es el único módulo cuyo schema (`health_data`) no coincide con el slug del
archivo (`health_data_platform`). **M34** es el único `.puml` sin `(schema: …)` en el título.
Los módulos 54–63 declaran motor en vez de schema (`MongoDB-compatible document collections`,
`Redis keyspaces, streams and sorted sets`, `OpenSearch-compatible indices`, …); su schema
Postgres es el plano de control.

---

## 3 · Los 17 portales del Módulo 34 — el eje del frontend

El M34 declara **17 portales** con **81 secciones** y **13 actores**, más un rectángulo
transversal de estados de UX obligatorios (18 rectángulos en total, uno de ellos no es un
portal).

**Procedencia de cada dato en las tablas que siguen:**
- *Literal del M34*: nombre del portal, código y título de sección, actores.
- *Literal del M30*: nombres de las proyecciones.
- *Inferido* (marcado con «·»): la columna **Módulos**. Se deriva del prefijo de la proyección
  (`patient_*`, `doctor_*`, `erp_*`…) y del texto de la sección. **El modelo no declara esta
  relación como FK** — no la cites como canónica.

### 3.1 · Public Experience — actor: Public Visitor

| Sec. | Título (literal) | Módulos · | Proyecciones (M30) |
|---|---|---|---|
| PUB1 | Provider and service discovery | 19, 23, 24, 13 | `public_provider_directory_v` (MV), `patient_provider_search_v` (MV), `diagnostic_unit_public_catalog_v` (MV), `pharmacy_public_stock_offer_v` (MV) |
| PUB2 | Public profile, prices and reviews | 19, 23, 24 | `public_profile_detail_v` (MV), `public_feed_v` |
| PUB3 | Sign in / registration / recovery | 01, 40, 27 | — |

Único portal totalmente público: es el candidato natural a **prerenderizado SSR**.

### 3.2 · Patient Portal — actor: Patient

| Sec. | Título (literal) | Módulos · | Proyecciones (M30) |
|---|---|---|---|
| PAT1 | Health home dashboard | 08, 41, 17 | `patient_home_dashboard_v` |
| PAT2 | Appointments and availability | 41, 14 | `patient_appointments_v` |
| PAT3 | Timeline, records and results | 15, 20, 52 | `patient_health_timeline_v`, `patient_orders_results_v`, `patient_diagnostic_timeline_v`, `patient_longitudinal_record_v` |
| PAT4 | Medications and orders | 08, 24, 25 | `patient_medication_summary_v` |
| PAT5 | Billing, claims and payments | 17, 26, 42 | `patient_billing_wallet_v`, `payments_debt_checkout_v` |
| PAT6 | Privacy and consent center | 07, 06 | `patient_consent_center_v` |
| PAT7 | Notifications and secure access | 35, 01, 29 | — |

### 3.3 · Doctor Workspace — actor: Doctor

| Sec. | Título (literal) | Módulos · | Proyecciones (M30) |
|---|---|---|---|
| DOC1 | Daily agenda and patient queue | 41, 14 | `doctor_daily_workspace_v` |
| DOC2 | Encounter workspace | 08, 18, 09 | `doctor_patient_summary_v` |
| DOC3 | Versioned notes and chart | 15, 10 | `doctor_note_history_v` |
| DOC4 | Order entry and prescribing | 08, 24, 20 | — |
| DOC5 | Result inbox and acknowledgment | 20, 18 | `doctor_result_inbox_v` |
| DOC6 | Delegates and scope | 29, 06 | — |
| DOC7 | Professional public profile | 19, 05 | `public_profile_detail_v` (MV) |

Es el portal de **mayor densidad de información**: el diseño debe tratarlo como hoja de
evolución, no como dashboard de tarjetas.

### 3.4 · Hospital / Infrastructure — actores: Infrastructure Administrator, Hospital Operator

| Sec. | Título (literal) | Actor | Módulos · | Proyecciones (M30) |
|---|---|---|---|---|
| INF1 | Sites, departments, units and spaces | ambos | 14, 04, 22 | `infrastructure_operations_dashboard_v` |
| INF2 | Bed and capacity board | Hospital | 14, 08 | `hospital_bed_board_v` |
| INF3 | Workforce, shifts and attendance | ambos | 14, 38, 05 | `workforce_shift_board_v` |
| INF4 | Operational incidents and maintenance | Infra | 11, 46 | — |
| INF5 | Delegated users and permissions | Infra | 29, 06, 01 | — |

Único portal con **dos actores de alcance distinto**: INF2 es exclusiva de Hospital Operator;
INF4 e INF5 son exclusivas de Infrastructure Administrator. El shell debe resolver menú por
actor, no mostrar todo y deshabilitar.

### 3.5 · Diagnostic Unit Portal — actor: Diagnostic Unit Operator

| Sec. | Título (literal) | Módulos · | Proyecciones (M30) |
|---|---|---|---|
| DIA1 | Diagnostic worklist | 20, 23 | `diagnostic_worklist_v` |
| DIA2 | Specimens, studies and devices | 20, 60 | `lab_specimen_trace_v`, `imaging_study_viewer_manifest_v` |
| DIA3 | Verification and result release | 20, 32 | `diagnostic_result_release_queue_v` |
| DIA4 | Catalog, specialists and public prices | 23, 17 | `diagnostic_unit_public_catalog_v` (MV) |
| DIA5 | Quality control and evidence | 36 | — |

### 3.6 · Pharmacy Portal — actor: Pharmacy Operator

| Sec. | Título (literal) | Módulos · | Proyecciones (M30) |
|---|---|---|---|
| PHA1 | Catalog, pricing and availability | 24 | `pharmacy_public_stock_offer_v` (MV) |
| PHA2 | Inventory, lots and expiry risk | 25 | `pharmacy_inventory_dashboard_v` |
| PHA3 | Reservations and dispensing queue | 25, 08 | `pharmacy_dispensing_queue_v` |
| PHA4 | Purchasing and stock counts | 25, 38 | — |
| PHA5 | Covered dispensing and reconciliation | 26, 17 | — |

### 3.7 · Insurance Portal — actor: Insurer Administrator

| Sec. | Título (literal) | Módulos · | Proyecciones (M30) |
|---|---|---|---|
| INS1 | Eligibility and coverage | 26 | — |
| INS2 | Authorization queue | 26, 32 | `insurer_authorization_queue_v` |
| INS3 | Claims and adjudication | 26, 17 | — |
| INS4 | Appeals, reversals and reconciliation | 26, 42 | `insurer_claim_reconciliation_v` |
| INS5 | Provider network performance | 26 | `insurer_network_performance_v` (MV) |

### 3.8 · Broker Portal — actor: Broker

| Sec. | Título (literal) | Módulos · | Proyecciones (M30) |
|---|---|---|---|
| BRO1 | Client portfolio | 26, 49 | `broker_portfolio_v` |
| BRO2 | Coverage and renewal pipeline | 26, 49 | — |
| BRO3 | Carrier agreements | 26, 38 | — |
| BRO4 | Commission statements | 17, 42 | `broker_commission_statement_v` |

### 3.9 · ERP / Finance — actor: ERP / Finance User

| Sec. | Título (literal) | Módulos · | Proyecciones (M30) |
|---|---|---|---|
| ERP1 | Financial dashboard | 16, 17 | `erp_financial_summary_v` |
| ERP2 | General ledger and subledgers | 16 | `erp_general_ledger_balance_v`, `erp_journal_line_trace_v` |
| ERP3 | Receivables and payables | 17 | `erp_accounts_receivable_queue_v`, `erp_accounts_payable_queue_v`, `erp_liability_maturity_v` |
| ERP4 | Cash, settlements and reconciliation | 42, 16 | `payments_reconciliation_queue_v` |
| ERP5 | Inventory valuation and procurement | 38, 25 | `erp_inventory_valuation_v` (MV), `erp_procure_to_pay_match_queue_v`, `erp_asset_rollforward_mv` |
| ERP6 | Reports and exports | 39 | `erp_business_partner_360_v`, `erp_contract_lifecycle_queue_v`, `erp_contract_obligation_queue_v` |

### 3.10 · System Administration — actor: System Administrator

| Sec. | Título (literal) | Módulos · | Proyecciones (M30) |
|---|---|---|---|
| ADM1 | Tenant and identity verification | 04, 27 | `system_admin_tenant_list_v`, `system_admin_verification_queue_v` |
| ADM2 | Security and audit operations | 10, 06, 11 | `system_admin_dashboard_v` |
| ADM3 | Integrations and credentials | 12, 31 | `system_admin_integration_health_v`, `adapter_health_summary` (MV) |
| ADM4 | Terminology and dynamic enums | 03, 45 | — |
| ADM5 | Context, automation and workers | 45, 48, 32, 35 | — |
| ADM6 | Platform health and releases | 46 | — |

### 3.11 · Education — actor: Educator / Learner

| Sec. | Título (literal) | Módulos · | Proyecciones (M30) |
|---|---|---|---|
| EDU1 | Course and content administration | 47 | — |
| EDU2 | Enrollment and learning path | 47 | `education_learner_dashboard_v` |
| EDU3 | Assessment, certificate and CME | 47 | — |

### 3.12 · CRM / Marketing — actor: CRM / Marketing User

| Sec. | Título (literal) | Módulos · | Proyecciones (M30) |
|---|---|---|---|
| GRO1 | Accounts, contacts and pipeline | 49 | `crm_pipeline_board_v`, `crm_account_360_v`, `crm_task_queue_v`, `crm_calendar_v`, `crm_case_queue_v`, `crm_opportunity_forecast_v`, `crm_activity_timeline_mv` (MV) |
| GRO2 | Segments, campaigns and journeys | 50, 35 | `marketing_campaign_performance_v` (MV), `campaign_dispatch_summary` (MV), `recipient_delivery_timeline` |
| GRO3 | Attribution, promotions and loyalty | 50, 51 | — |

### 3.13 · Cloud / System Operations — actor: System Administrator

| Sec. | Título (literal) | Módulos · | Proyecciones (M30) |
|---|---|---|---|
| OPS1 | Service health, SLO and error budget | 46 | `ops_service_health_overview_v`, `ops_slo_error_budget_mv` (MV) |
| OPS2 | Incident command and communications | 46, 11 | `ops_incident_command_center_v` |
| OPS3 | Change calendar and readiness reviews | 46 | `ops_change_calendar_v` |
| OPS4 | Runbooks, resilience and capacity | 46, 21 | — |

### 3.14 · Advertising Operations — actor: CRM / Marketing User

| Sec. | Título (literal) | Módulos · | Proyecciones (M30) |
|---|---|---|---|
| ADS1 | Campaign delivery and insights | 43 | `ads_campaign_delivery_dashboard_v` |
| ADS2 | Conversion quality and deduplication | 43, 28 | `ads_conversion_quality_mv` (MV) |
| ADS3 | Lead inbox and CRM delivery | 43, 49 | `ads_lead_inbox_v` |
| ADS4 | Policy review and health-data firewall | 43, 07 | `ads_policy_review_queue_v` |

ADS4 es una **frontera dura**: separa datos de salud del tráfico publicitario. Cualquier
componente compartido entre este portal y los clínicos es un riesgo de fuga.

### 3.15 · Payment Gateway Operations — actor: ERP / Finance User

| Sec. | Título (literal) | Módulos · | Proyecciones (M30) |
|---|---|---|---|
| PAY1 | Debt registration and checkout | 42, 17 | `payments_debt_checkout_v` |
| PAY2 | Callback and status verification | 42, 35 | `payments_gateway_operations_v` |
| PAY3 | Receipts, invoices and cancellation | 42, 17 | — |
| PAY4 | Provider reconciliation | 42, 16 | `payments_reconciliation_queue_v` |

### 3.16 · Health Data Center — actores: System Administrator, Doctor, Patient

| Sec. | Título (literal) | Actor | Módulos · | Proyecciones (M30) |
|---|---|---|---|---|
| HDC1 | Source ingestion and FHIR validation | SysAdmin | 52, 55 | `health_data_ingestion_quality_v` |
| HDC2 | Patient identity resolution | SysAdmin | 52, 05 | — |
| HDC3 | Longitudinal clinical record | Doctor, Patient | 52, 15 | `patient_longitudinal_record_v` |
| HDC4 | Quality, provenance and lineage | SysAdmin | 52, 10, 54 | — |
| HDC5 | Controlled export and de-identification | — | 52, 63, 11 | — |

HDC3 es la única sección compartida entre un actor administrativo y actores clínicos/paciente:
la **misma pantalla con field masks distintos**, no dos pantallas.

### 3.17 · Interventions and Operating Room — actores: Hospital Operator, Doctor

| Sec. | Título (literal) | Actor | Módulos · | Proyecciones (M30) |
|---|---|---|---|---|
| SUR1 | Procedure case and OR schedule | Hospital | 53, 41 | `procedure_case_command_center_v`, `operating_room_schedule_v` |
| SUR2 | Preoperative clearance and safety checklist | Doctor | 53, 09 | — |
| SUR3 | Anesthesia and operative record | Doctor | 53, 15 | — |
| SUR4 | Implants, specimens and complications | Doctor | 53, 20, 25 | — |
| SUR5 | Recovery, follow-up and outcomes | Doctor | 53, 18 | `postoperative_followup_queue_v` |

### 3.18 · Los 9 estados de UX obligatorios (literal del M34)

Aplicados explícitamente a PAT1, DOC1, INF1, DIA1, PHA1, INS1, ERP1, ADM1, SUR1, HDC1, PAY1,
ADS1, OPS1 — es decir, **a la primera sección de cada portal protegido**. Se leen como contrato
para todas.

```
S1  Route authorization pending
S2  Loading / skeleton
S3  Empty with next action
S4  Validation or conflict
S5  Forbidden / purpose denied
S6  Not found without data leakage
S7  Stale data / refresh
S8  Offline / retry
S9  Unexpected error + request ID
```

Distinciones que no son cosméticas: **S1 ≠ S2** (autorizar la ruta ocurre antes de pedir datos
sensibles); **S5 ≠ S6** (prohibido vs. inexistente, y S6 no debe filtrar que el recurso existe);
**S7** exige exponer la antigüedad del dato — relevante porque 14 proyecciones son
materializadas.

### 3.19 · FRONTEND RULES (literal del M34)

```
- Portal names are product surfaces, never blanket database roles.
- Every route binds to permission, tenant/patient scope, purpose of use and field mask.
- Protected routes resolve authentication and role context before requesting sensitive data.
- URL state is used for shareable filters; server state is not duplicated in global stores.
- Lists use specialized picking/projection endpoints and cursor pagination.
- Destructive actions require explicit confirmation, idempotency and conflict handling.
- Responsive designs preserve task priority; mobile never hides required safety information.
- Accessibility, keyboard operation, focus restoration and reduced motion are mandatory.
```

### 3.20 · FRONTEND CONTRACT (literal del M30)

```
- Codes are stable API values; labels and tones are presentation metadata.
- Lists use cursor pagination with deterministic tie-breakers.
- Filters and sort options are allow-listed; raw SQL expressions never come from clients.
- available_actions_json is derived from state + permission + purpose, never trusted on write.
- Loading, skeleton, empty, stale, error, forbidden and offline states are explicit.
- Public projections contain only approved public fields and stable internal media URIs.
- Signed file URLs are generated after authorization and are never persisted in views.
```

---

## 4 · Estructura de features Angular

Stack verificado: **Angular 21 + SSR, yarn**. Sin React, sin Tailwind. Componentes standalone,
estado con `signal()`, tokens como CSS custom properties en `src/styles.css`.

### 4.1 · Árbol de carpetas

```
mantra-core-health/src/app/
├── core/                          # una sola instancia, cargado en app.config.ts
│   ├── auth/                      # sesión, refresh, contexto de rol y tenant
│   ├── authz/                     # permisos, purpose of use, field masks (M06)
│   ├── http/                      # interceptores: correlation-id, errores → S4..S9, idempotencia
│   ├── view-state/                # el tipo ViewState<T> con los 9 estados del M34
│   └── platform/                  # guards de SSR, afterNextRender
│
├── shared/
│   ├── components/                # atomic design (convención 2026-07-29)
│   │   ├── atoms/                 # primitivas: button, input, badge de estado…
│   │   ├── molecules/             # composiciones: campo con label+error, fila de tabla…
│   │   └── organisms/             # bloques: tabla densa, header clínico…
│   ├── directives/  pipes/
│   ├── view-engine/               # componentes dirigidos por metadatos del M30 (§4.3)
│   └── formatting/                # format_mask, tonos, concept labels
│
├── data-access/                   # un cliente por módulo backend, espeja @Controller(...)
│   ├── clinical/  scheduling/  billing/  diagnostics/  pharmacy/ …
│   └── read-models/               # acceso a las proyecciones del M30
│
└── portals/                       # 17 carpetas = 17 portales del M34
    ├── public/                    # PUB1..PUB3   (SSR prerender)
    ├── patient/                   # PAT1..PAT7
    ├── doctor/                    # DOC1..DOC7
    ├── hospital/                  # INF1..INF5
    ├── diagnostic-unit/           # DIA1..DIA5
    ├── pharmacy/                  # PHA1..PHA5
    ├── insurance/                 # INS1..INS5
    ├── broker/                    # BRO1..BRO4
    ├── erp/                       # ERP1..ERP6
    ├── system-admin/              # ADM1..ADM6
    ├── education/                 # EDU1..EDU3
    ├── crm/                       # GRO1..GRO3
    ├── operations/                # OPS1..OPS4
    ├── advertising/               # ADS1..ADS4
    ├── payments-ops/              # PAY1..PAY4
    ├── health-data-center/        # HDC1..HDC5
    └── operating-room/            # SUR1..SUR5
```

Cada portal: un `*-shell.component.ts` (layout, navegación, resolución de rol) más una carpeta
por sección con el código del M34 en el nombre del archivo o en un comentario, para que la
trazabilidad al modelo no se pierda.

**Los 64 módulos aparecen solo bajo `data-access/`.** No hay carpeta por módulo en `portals/`.

### 4.2 · Rutas

`app.routes.ts` (hoy `[]`) queda como un índice de 17 `loadChildren` — uno por portal:

```ts
export const routes: Routes = [
  { path: '', loadChildren: () => import('./portals/public/public.routes') },
  {
    path: 'paciente',
    canMatch: [portalGuard('PATIENT')],
    loadChildren: () => import('./portals/patient/patient.routes'),
  },
  // … 15 portales más
];
```

Y cada portal declara sus secciones como rutas hijas del shell:

```ts
// portals/patient/patient.routes.ts
export default [
  {
    path: '',
    component: PatientShellComponent,
    children: [
      { path: '', pathMatch: 'full', redirectTo: 'inicio' },
      { path: 'inicio',   loadComponent: () => …, data: { section: 'PAT1' } },
      { path: 'turnos',   loadComponent: () => …, data: { section: 'PAT2' } },
      { path: 'historia', loadComponent: () => …, data: { section: 'PAT3' } },
      // …
    ],
  },
] satisfies Routes;
```

Decisiones que fija el modelo, no el gusto:

- **`canMatch` antes que `canActivate`** para el guard de portal: si no matchea, ni se descarga
  el chunk. Es la lectura literal de *«protected routes resolve authentication and role context
  before requesting sensitive data»*.
- **El guard resuelve permiso + tenant/patient scope + purpose of use + field mask** — los 4
  ejes del M34, disponibles en `frontend_routes` (`required_permission_id`,
  `purpose_of_use_concept_id`, `requires_patient_context`, `requires_tenant_context`).
- **Estado de filtros en la URL** (`url_parameter_name` de `frontend_view_filters`), no en un
  store global. La regla del M34 lo pide y además hace los filtros compartibles.
- **`app.routes.server.ts`**: solo el portal `public` es prerenderizable
  (`RenderMode.Prerender`). Todo lo protegido va `RenderMode.Client` o `RenderMode.Server` —
  prerenderizar una ruta con PHI es una fuga.
- **Idioma de las rutas**: paths en castellano de cara al usuario; los **códigos** del M34
  (`PAT1`, `DOC5`) viajan en `data.section` y nunca se traducen — son el vínculo con el modelo.

### 4.3 · Componentes dirigidos por metadatos, no 76 pantallas a mano

El M30 describe cada pantalla como datos. La consecuencia de diseño es que **no se escriben 76
pantallas**: se escribe un motor y se configuran.

| Tabla del M30 | Componente Angular |
|---|---|
| `frontend_page_views` | `<mc-view-host [view]="…">` — resuelve tipo de vista y layout |
| `frontend_view_fields` | columnas / campos; `display_component_concept_id` elige el renderer; `sensitive` + `permission_id` deciden enmascarado; `responsive_priority` decide qué cae primero en móvil |
| `frontend_view_filters` | barra de filtros; `operator_value_set_id` e `input_type_concept_id` definen el control; `url_parameter_name` lo liga a la URL |
| `frontend_view_sort_options` | orden allow-listado, con `stable_tie_breaker_expression` para el cursor |
| `frontend_view_actions` | botones; `confirmation_policy_concept_id` e `idempotency_required` gobiernan el diálogo destructivo |
| `frontend_view_kpis` | tarjetas KPI con `threshold_rules_json` y `drilldown_route_template` |
| `frontend_view_states` | los 9 estados con su copy, ilustración y acción de recuperación |
| `user_view_preferences` | densidad, columnas visibles y page size por usuario |

Reglas que el motor debe honrar:

- **`available_actions_json` orienta la UI, nunca autoriza.** Cada comando se reautoriza en el
  backend. Es la diferencia entre ocultar un botón y prevenir una acción.
- **Códigos vs. labels**: los `*_code` son el contrato estable; `*_label` y `*_tone` son
  presentación. Nunca ramificar lógica sobre un label.
- **Nada de enums de TypeScript inventados**: los conceptos vienen por `*_concept_id` desde
  terminología (M03). Un `type EstadoTurno = 'pendiente' | …` escrito a mano es deriva.
- **Paginación por cursor siempre**, con `stable_cursor_columns_json`. Sin offset.

### 4.4 · Los 9 estados como un tipo, no como `if` sueltos

```ts
// core/view-state/view-state.ts
export type ViewState<T> =
  | { kind: 'authorizing' }                                   // S1
  | { kind: 'loading' }                                       // S2
  | { kind: 'empty'; nextAction?: ActionCode }                // S3
  | { kind: 'conflict'; issues: ValidationIssue[] }           // S4
  | { kind: 'forbidden'; reason: 'permission' | 'purpose' }   // S5
  | { kind: 'notFound' }                                      // S6
  | { kind: 'ready'; data: T; stale?: StaleInfo }             // S7 sobre datos presentes
  | { kind: 'offline'; retry: () => void }                    // S8
  | { kind: 'error'; requestId: string };                     // S9
```

`stale` va dentro de `ready` porque S7 describe datos que **sí se muestran** con una advertencia
de antigüedad — no una pantalla alternativa. El `requestId` de S9 debe salir del correlation-id
del interceptor: es lo que hace accionable el error contra `audit` (M10).

El renderer de estados es un solo componente compartido. Si una pantalla resuelve estados por su
cuenta, se rompe la consistencia que el M34 declara obligatoria.

### 4.5 · Consecuencias de diseño visual que salen del modelo

- **Densidad por portal, no global.** Doctor Workspace y ERP piden densidad de hoja de
  evolución; Patient Portal se lee una vez y admite aire. Un mismo token de densidad para los
  17 portales sería una decisión no tomada.
- **`<<IMMUTABLE>>` / `<<APPEND_ONLY>>` no tienen «editar».** Tienen «registrar corrección». La
  UI de los módulos de auditoría, chart y órdenes debe reflejarlo en el verbo del botón.
- **Todo lo que viene de `*_concept_id` es un selector sobre un value set**, nunca un input
  libre.
- **El color nunca es el único portador de significado** — crítico en tonos clínicos
  (`*_tone` del M30 acompaña siempre a un `*_label`).

---

## 5 · Advertencias para quien ejecute

1. **`portal_surfaces` y `frontend_routes` están seedeados con placeholders sintéticos.** Los
   `portal_code` cargados hoy son `CORE`, `STANDARD`, `EXTENDED`, `RESTRICTED`,
   `INTERNATIONAL`, `DISABLED_TEMPLATE`, `PORTAL_SURFACES_07`…, con
   `default_route = 'core_default_route'` y `route_pattern = 'core_route_pattern'`. **No son
   rutas de producto.** Poblarlos con los 17 portales reales es trabajo pendiente y va en
   `salud-db/gen_seeds.py` — nunca a mano en la base.
2. **Las 76 proyecciones están declaradas en el `.puml` pero no materializadas en `SQL/`.**
   `SQL/30_read_models/02_tables.sql` crea las 13 tablas de metadatos, no las vistas.
3. **No existe un value set poblado de tipos de portal** en terminología: solo un
   `DEFAULT_PORTAL_TYPE` genérico.
4. **No hay auth ni `/me`.** Es el primer bloqueo real: sin resolución de rol y tenant no hay
   guard de portal posible, y sin guard de portal no hay ruta protegida que se pueda construir
   de verdad.
5. **Deriva de conteo menor:** el `.puml` del M30 declara **76** proyecciones
   (`<<VIEW>>` + `<<MATERIALIZED_VIEW>>`); la nota del vault reporta «Vistas: 73» porque
   contabiliza aparte las 3 añadidas en v4.0.1 (`adapter_health_summary`,
   `campaign_dispatch_summary`, `recipient_delivery_timeline`).

---

## 6 · Documentos relacionados

- [frontend-view-contracts.md](./frontend-view-contracts.md) — metadatos de página del M30 y
  principios de consumo.
- [erp-crm-front-views.md](./erp-crm-front-views.md) — las 7 vistas ERP y 6 CRM de v3.7.
- [v3.8-operational-clinical-views.md](./v3.8-operational-clinical-views.md) — vistas de
  System Ops, Ads, Payments, clínico-diagnóstico y quirófano.
- [../architecture/orm-mapping-guide.md](../architecture/orm-mapping-guide.md) — invariantes de
  persistencia que la API debe honrar antes de exponer cualquier endpoint.
- [../architecture/physical-materialization.md](../architecture/physical-materialization.md) —
  estado del build físico.
