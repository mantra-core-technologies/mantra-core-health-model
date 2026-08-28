# SALUD v4.0.1 · módulo 56 redis_runtime · Redis keyspaces (spec)

Redis es schemaless: esto documenta el **diseño de claves** (patrón, tipo, TTL, estructuras y políticas) tal como lo declara el modelo. No es DDL ejecutable.

## `session_cache_entries`

| campo | definición |
|---|---|
| **key** | session:{tenant}:{session_id} |
| **value** | encrypted session projection |
| **user_id** | uuid |
| **session_version** | integer |
| **issued_at** | epoch |
| **expires_at** | epoch |
| **ttl_seconds** | integer |

**Estructuras y políticas:**
- `KEY` key_session: session:{tenant}:{session_id}
- `SET` set_user_sessions: sessions-by-user:{tenant}:{user_id} members=session_id
- `TTL` ttl_session: expires_at-now
- `POLICY` no_key_scan: direct lookup only

## `refresh_family_cache_entries`

| campo | definición |
|---|---|
| **key** | refresh-family:{tenant}:{family_id} |
| **value** | status, current_generation, user_id |
| **revoked_at** | epoch |
| **expires_at** | epoch |
| **ttl_seconds** | integer |

**Estructuras y políticas:**
- `KEY` key_refresh_family: refresh-family:{tenant}:{family_id}
- `SET` set_user_refresh_families: refresh-families:{tenant}:{user_id}
- `TTL` ttl_refresh_family: token-family expiry

## `mfa_challenge_entries`

| campo | definición |
|---|---|
| **key** | mfa:{tenant}:{challenge_id} |
| **value** | user_id, method, hash, attempt_count |
| **expires_at** | epoch |
| **ttl_seconds** | integer |

**Estructuras y políticas:**
- `KEY` key_mfa: mfa:{tenant}:{challenge_id}
- `SET` set_mfa_by_user: mfa-by-user:{tenant}:{user_id}
- `TTL` ttl_mfa: challenge lifetime
- `POLICY` atomic_attempt_increment: Lua or transaction

## `password_reset_entries`

| campo | definición |
|---|---|
| **key** | pwd-reset:{tenant}:{token_hash} |
| **value** | user_id, requested_at, used_at |
| **ttl_seconds** | integer |

**Estructuras y políticas:**
- `KEY` key_password_reset: pwd-reset:{tenant}:{token_hash}
- `TTL` ttl_password_reset: reset-token lifetime
- `POLICY` one_time_use: atomic GETDEL

## `rate_limit_buckets`

| campo | definición |
|---|---|
| **key** | rate:{tenant}:{scope}:{subject}:{window} |
| **value** | counter or token-bucket state |
| **limit** | integer |
| **reset_at** | epoch |
| **ttl_seconds** | integer |

**Estructuras y políticas:**
- `KEY` key_rate_bucket: rate:{tenant}:{scope}:{subject}:{window}
- `ZSET` zset_rate_sliding: rate-events:{tenant}:{scope}:{subject}
- `TTL` ttl_rate_bucket: window plus safety margin
- `POLICY` atomic_bucket_update: Lua

## `idempotency_entries`

| campo | definición |
|---|---|
| **key** | idem:{tenant}:{operation}:{idempotency_key} |
| **value** | request_hash, response_ref, status |
| **locked_until** | epoch |
| **expires_at** | epoch |
| **ttl_seconds** | integer |

**Estructuras y políticas:**
- `KEY` key_idempotency: idem:{tenant}:{operation}:{idempotency_key}
- `TTL` ttl_idempotency: operation-specific retention
- `POLICY` atomic_claim: SET NX with fencing
- `HASH` request_hash_guard: reject same key with different hash

## `authorization_cache_entries`

| campo | definición |
|---|---|
| **key** | authz:{tenant}:{principal}:{resource}:{context_hash} |
| **value** | decision, field_mask, policy_version |
| **expires_at** | epoch |
| **ttl_seconds** | integer |

**Estructuras y políticas:**
- `KEY` key_authz: authz:{tenant}:{principal}:{resource}:{context_hash}
- `SET` set_authz_policy_version: authz-policy:{tenant}:{policy_version}
- `TTL` ttl_authz: short-lived decision cache
- `PUBSUB` invalidate_authz: authz.invalidate.{tenant}

## `availability_cache_entries`

| campo | definición |
|---|---|
| **key** | availability:{tenant}:{resource}:{date} |
| **value** | slot projection |
| **source_version** | bigint |
| **expires_at** | epoch |
| **ttl_seconds** | integer |

**Estructuras y políticas:**
- `KEY` key_availability: availability:{tenant}:{resource}:{date}
- `ZSET` zset_slots: slots:{tenant}:{resource}:{date} score=start_epoch
- `TTL` ttl_availability: short horizon
- `PUBSUB` invalidate_schedule: schedule.invalidate.{tenant}.{resource}

## `distributed_lock_entries`

| campo | definición |
|---|---|
| **key** | lock:{tenant}:{lock_name}:{resource_id} |
| **value** | owner_token, fencing_token |
| **acquired_at** | epoch |
| **expires_at** | epoch |
| **ttl_seconds** | integer |

**Estructuras y políticas:**
- `KEY` key_lock: lock:{tenant}:{lock_name}:{resource_id}
- `COUNTER` fencing_counter: fence:{tenant}:{lock_name}:{resource_id}
- `TTL` ttl_lock: bounded lease
- `POLICY` release_by_owner: compare-and-delete Lua

## `realtime_presence_entries`

| campo | definición |
|---|---|
| **key** | presence:{tenant}:{user_id} |
| **value** | status, connection_ids, last_seen_at |
| **ttl_seconds** | integer |

**Estructuras y políticas:**
- `KEY` key_presence: presence:{tenant}:{user_id}
- `SET` set_online_users: online:{tenant}
- `SET` set_connections: connections:{tenant}:{user_id}
- `TTL` ttl_presence: heartbeat window

## `job_progress_entries`

| campo | definición |
|---|---|
| **key** | job:{tenant}:{job_type}:{job_id} |
| **value** | state, progress, heartbeat, result_ref |
| **expires_at** | epoch |
| **ttl_seconds** | integer |

**Estructuras y políticas:**
- `KEY` key_job_progress: job:{tenant}:{job_type}:{job_id}
- `ZSET` zset_jobs_by_state: jobs:{tenant}:{job_type}:{state} score=updated_epoch
- `TTL` ttl_job_result: configured result window

## `notification_debounce_entries`

| campo | definición |
|---|---|
| **key** | debounce:{tenant}:{recipient}:{template}:{dedup_key} |
| **value** | count, first_event_at, last_event_at |
| **ttl_seconds** | integer |

**Estructuras y políticas:**
- `KEY` key_debounce: debounce:{tenant}:{recipient}:{template}:{dedup_key}
- `ZSET` zset_debounce_due: debounce-due:{tenant} score=flush_epoch
- `TTL` ttl_debounce: flush window plus safety margin

## `cache_invalidation_stream`

| campo | definición |
|---|---|
| **key** | stream:cache-invalidation |
| **entry_id** | stream id |
| **tenant_id** | uuid |
| **dataset_code** | varchar |
| **entity_id** | uuid |
| **version** | bigint |
| **occurred_at** | epoch |

**Estructuras y políticas:**
- `STREAM` stream_cache_invalidation: stream:cache-invalidation
- `GROUP` group_cache_consumers: one group per projection service
- `TRIM` maxlen_cache_stream: approximate bounded history
- `POLICY` idempotent_version_check: ignore older entity versions

## `outbox_delivery_dedup_entries`

| campo | definición |
|---|---|
| **key** | outbox-dedup:{consumer}:{event_id} |
| **value** | processed_at, payload_hash |
| **ttl_seconds** | integer |

**Estructuras y políticas:**
- `KEY` key_outbox_dedup: outbox-dedup:{consumer}:{event_id}
- `TTL` ttl_outbox_dedup: greater than outbox retention
- `POLICY` atomic_mark: SET NX
