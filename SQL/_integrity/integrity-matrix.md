# Matriz de integridad y concurrencia — SALUD v4.0.10 (módulo 33)

El módulo 33 (`integrity`) **no posee tablas**: es una matriz de verificación cross-dominio. Cada regla se implementa en la **migración de la tabla dueña** (su módulo) y se repite aquí como checklist. Extraído fielmente del `.puml`.

## Política transaccional

```
  TRANSACTION POLICY
  - Use READ COMMITTED plus explicit row locks for narrow stock mutations.
  - Use SERIALIZABLE for cross-row invariants that cannot be safely locked by a
    deterministic key; retry the full transaction on SQLSTATE 40001.
  - Keep external API calls outside database lock windows. Persist intent/outbox,
    then reconcile asynchronous results with idempotency.
  - SKIP LOCKED is valid for workers and queues, not for business availability.
```

## Compuertas físicas de base de datos

```
  PHYSICAL DATABASE GATES
  Named CHECK/UNIQUE/EXCLUDE/FK constraints, partial unique indexes, immutable
  triggers, partitioning plans, index evidence and concurrency tests are required
  before migrations are approved. Application validation is never the only guard.
```

## Matriz por módulo dueño

### Módulo 10 · `audit`

| Tabla | Estereotipo | Reglas declaradas |
|-------|-------------|-------------------|
| `audit_log` | `IMMUTABLE, REFERENCE_ONLY` | **UPDATE_DELETE** forbidden |
| `data_access_log` | `APPEND_ONLY, REFERENCE_ONLY` | **UPDATE** forbidden; **DELETE** retention purge only (UC-10-09) |

### Módulo 08 · `clinical`

| Tabla | Estereotipo | Reglas declaradas |
|-------|-------------|-------------------|
| `appointments` | `REFERENCE_ONLY` | **EXCLUDE** practitioner/location time overlap; **LOCK** reservation confirmation transaction |

### Módulo 29 · `delegated_access`

| Tabla | Estereotipo | Reglas declaradas |
|-------|-------------|-------------------|
| `practitioner_delegate_assignments` | `REFERENCE_ONLY` | **EXCLUDE** incompatible overlapping assignments; **CHECK** signature permission requires authorized role |

### Módulo 23 · `diagnostic_units`

| Tabla | Estereotipo | Reglas declaradas |
|-------|-------------|-------------------|
| `diagnostic_study_prices` | `VERSIONED, REFERENCE_ONLY` | **UK** schedule + offering + version; **EXCLUDE** no overlapping active effective periods; **CHECK** amounts >= 0 |

### Módulo 27 · `identity_assurance`

| Tabla | Estereotipo | Reglas declaradas |
|-------|-------------|-------------------|
| `identity_verification_attempts` | `REFERENCE_ONLY` | **UK** case + endpoint + attempt number; **UK** endpoint + idempotency key; **RETRY** bounded policy only |

### Módulo 26 · `insurance`

| Tabla | Estereotipo | Reglas declaradas |
|-------|-------------|-------------------|
| `patient_coverages` | `REFERENCE_ONLY` | **UK** insurer + member identifier + effective period; **EXCLUDE** conflicting primary coverage periods |
| `claim_adjudication_versions` | `IMMUTABLE, REFERENCE_ONLY` | **UK** claim + adjudication version; **UPDATE_DELETE** forbidden |
| `claim_appeal_decisions` | `IMMUTABLE, REFERENCE_ONLY` | **UK** dispute + decision version; **UPDATE_DELETE** forbidden |
| `claim_reversals` | `IMMUTABLE, REFERENCE_ONLY` | **UK** claim + idempotency_key; **UPDATE_DELETE** forbidden |
| `coordination_of_benefits` | `VERSIONED, REFERENCE_ONLY` | **UK** patient + determination version; **EXCLUDE** overlapping active COB periods |

### Módulo 25 · `pharmacy_inventory`

| Tabla | Estereotipo | Reglas declaradas |
|-------|-------------|-------------------|
| `inventory_stock_positions` | `REFERENCE_ONLY` | **PK** id; **UK** location + product + lot; **CHECK** quantities >= 0; **LOCK** SELECT FOR UPDATE; **VERSION** row_version |
| `inventory_ledger_entries` | `IMMUTABLE, REFERENCE_ONLY` | **UK** pharmacy + idempotency_key; **UK** pharmacy + ledger_sequence; **CHECK** non-zero delta; **UPDATE_DELETE** forbidden |
| `inventory_reservations` | `REFERENCE_ONLY` | **UK** pharmacy + idempotency_key; **EXCLUDE** active allocation overlap when required; **WORKER** expiration release |

### Módulo 28 · `telemetry`

| Tabla | Estereotipo | Reglas declaradas |
|-------|-------------|-------------------|
| `user_activity_events` | `APPEND_ONLY, REFERENCE_ONLY` | **UK** event schema + event idempotency key; **PARTITION** received_at; **RETENTION** purpose-specific |

## Relaciones de integridad declaradas

- `inventory_stock_positions` → `inventory_ledger_entries` — atomic projection
- `inventory_reservations` → `inventory_ledger_entries` — reserve/release
- `patient_coverages` → `claim_adjudication_versions` — adjudication basis
- `identity_verification_attempts` → `practitioner_delegate_assignments` — verified actor

## Cómo se materializa

- **`SQL/_integrity/00_integrity_functions.sql`** — schema `integrity` + `forbid_mutation()` (guarda de inmutabilidad).
- **`SQL/<NN>_<schema>/05_constraints.sql`** — por módulo dueño: guarda concreta para `UPDATE_DELETE: forbidden`; UK/CHECK/EXCLUDE como scaffold TODO (completar la expresión exacta contra la tabla, ya que el modelo las declara en prosa).
- **Concurrencia** (`LOCK`/`SERIALIZABLE`/`SKIP LOCKED`/outbox) → capa de servicio (MikroORM Unit of Work + retry en `SQLSTATE 40001`), ver orm-mapping-guide §0.
