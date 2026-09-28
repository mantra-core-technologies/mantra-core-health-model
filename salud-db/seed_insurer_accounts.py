#!/usr/bin/env python3
"""
seed_insurer_accounts.py — Seeder de cuentas de acceso para aseguradoras (ALOVIDA / SALUD v4).

Crea cuentas de operador/administrador en la base de datos para todas las aseguradoras
(privadas y públicas) registradas en `insurance.insurance_carriers` y `directory.tenants`.

Entidades generadas de forma idempotente:
  1. `iam.users`: Cuenta de usuario activa con time_zone America/La_Paz y email verificado.
  2. `iam.authentication_credentials`: Credencial de tipo PASSWORD con hash argon2id.
  3. `iam.user_global_roles`: Rol global USER (Standard user).
  4. `directory.tenant_memberships`: Membresía activa en el tenant de la aseguradora con
     rol `DIR_ROLE_ADMIN` (Tenant admin) y scope `DIR_SCOPE_ALL_TENANT`.

Uso:
  python salud-db/seed_insurer_accounts.py
  python salud-db/seed_insurer_accounts.py --password otraPassword123
  python salud-db/seed_insurer_accounts.py --dry-run
"""
import argparse
import os
import sys
import uuid
from datetime import datetime, timezone
from pathlib import Path

import psycopg

sys.stdout.reconfigure(encoding="utf-8", errors="replace")

# Importar paths canónicos del repositorio de modelo
try:
    import paths
except ImportError:
    sys.path.append(str(Path(__file__).resolve().parent))
    import paths

# Concept IDs canónicos de la plataforma SALUD v4 (ver terminology.catalog_concepts)
CONCEPT_USER_ACTIVE = uuid.UUID("32dbed9f-cf1f-5c7a-9070-dfb937cf68a1")       # USER_ACTIVE
CONCEPT_ACTIVE = uuid.UUID("38a1d301-f40d-5b17-a695-5e6d605f8b19")            # ACTIVE
CONCEPT_METHOD_PASSWORD = uuid.UUID("37da1281-cc62-5032-b598-1eb39dc46060")   # PASSWORD
CONCEPT_HASH_ARGON2ID = uuid.UUID("646c89e7-29d5-5450-a4c6-17817fe55aa9")     # ARGON2ID
CONCEPT_ROLE_USER = uuid.UUID("51f28f0b-95c2-57b1-a53b-2240c7e80731")         # USER (Standard user)
CONCEPT_MEMBERSHIP_ACTIVE = uuid.UUID("13ca1b46-61d5-5c25-9d49-8247bcd7769c") # DIR_MEMBERSHIP_ACTIVE
CONCEPT_ROLE_ADMIN = uuid.UUID("43634daf-8ee6-5e37-891b-3cf44d7a52f9")        # DIR_ROLE_ADMIN
CONCEPT_ROLE_OWNER = uuid.UUID("0fe54eed-1e2f-5885-aba2-fc46f1058cb7")        # DIR_ROLE_OWNER
CONCEPT_SCOPE_ALL_TENANT = uuid.UUID("297d044a-a1e9-51db-8f96-68f4de6b3d62")  # DIR_SCOPE_ALL_TENANT

# Hash Argon2id precalculado y validado para la contraseña '12345678'
# Formato: $argon2id$v=19$m=65536,p=4,t=3$...
DEFAULT_PASSWORD = "12345678"
DEFAULT_ARGON2_HASH = "$argon2id$v=19$m=65536,p=4,t=3$7yAD9OSiPXtT6NGkznwJhw$8o4wjbQHPoPyi3w11i8ZX4PfebO8077H+jOGxr2Xre8"

# Namespace UUIDv5 determinista para generar IDs consistentes y reproducibles
UUID_NAMESPACE_ALOVIDA = uuid.UUID("e806294e-2826-5b87-9bb3-5e744d0840ee")

# Mapeo de carrier_code a email principal y display name
CARRIER_ACCOUNTS = {
    "BO_ASEG_ALIANZA_VIDA_S_A": {
        "email": "acceso@alianza.com",
        "aliases": ["acceso@alianzavida.com"],
        "display_name": "Representante Legal - Alianza Vida S.A.",
    },
    "BO_ASEG_ALIANZA_SEGUROS_S_A": {
        "email": "acceso@alianzagenerales.com",
        "aliases": [],
        "display_name": "Representante Legal - Alianza Seguros Patrimoniales",
    },
    "BO_ASEG_BISA_SEGUROS_Y_REASEGUROS_S_A": {
        "email": "acceso@bisa.com",
        "aliases": ["acceso@bisaseguros.com"],
        "display_name": "Representante Legal - BISA Seguros",
    },
    "BO_ASEG_CREDISEGURO_S_A_SEGUROS_PERSONALES": {
        "email": "acceso@crediseguro.com",
        "aliases": [],
        "display_name": "Representante Legal - Crediseguro Personales",
    },
    "BO_ASEG_CREDISEGURO_S_A_SEGUROS_GENERALES": {
        "email": "acceso@credisegurogenerales.com",
        "aliases": [],
        "display_name": "Representante Legal - Crediseguro Generales",
    },
    "BO_ASEG_FORTALEZA_SEGUROS_Y_REASEGUROS_S_A": {
        "email": "acceso@fortaleza.com",
        "aliases": ["acceso@segurosfortaleza.com"],
        "display_name": "Representante Legal - Fortaleza Seguros",
    },
    "BO_ASEG_LA_BOLIVIANA_CIACRUZ_SEGUROS_PERSONALES_S_A": {
        "email": "acceso@ciacruz.com",
        "aliases": ["acceso@lbc.bo"],
        "display_name": "Representante Legal - La Boliviana Ciacruz Personales",
    },
    "BO_ASEG_LA_BOLIVIANA_CIACRUZ_DE_SEGUROS_Y_REASEGUROS": {
        "email": "acceso@ciacruzgenerales.com",
        "aliases": [],
        "display_name": "Representante Legal - La Boliviana Ciacruz Generales",
    },
    "BO_ASEG_LA_VITALICIA_SEGUROS_Y_REASEGUROS_DE_VIDA_S_": {
        "email": "acceso@lavitalicia.com",
        "aliases": [],
        "display_name": "Representante Legal - La Vitalicia Seguros",
    },
    "BO_ASEG_MERCANTIL_SANTA_CRUZ_SEGUROS_Y_REASEGUROS_GE": {
        "email": "acceso@mercantil.com",
        "aliases": ["acceso@msc.com"],
        "display_name": "Representante Legal - Mercantil Santa Cruz Seguros",
    },
    "BO_ASEG_NACIONAL_SEGUROS_VIDA_Y_SALUD_S_A": {
        "email": "acceso@nacional.com",
        "aliases": ["acceso@nacionalsalud.com"],
        "display_name": "Representante Legal - Nacional Seguros Vida y Salud",
    },
    "BO_ASEG_NACIONAL_SEGUROS_PATRIMONIALES_Y_FIANZAS_S_A": {
        "email": "acceso@nacionalpatrimoniales.com",
        "aliases": [],
        "display_name": "Representante Legal - Nacional Seguros Patrimoniales",
    },
    "BO_ASEG_SANTA_CRUZ_VIDA_Y_SALUD_S_A": {
        "email": "acceso@santacruz.com",
        "aliases": ["consultasSCVS@santacruzfg.com"],
        "display_name": "Representante Legal - Santa Cruz Vida y Salud",
    },
    "BO_ASEG_SEGUROS_ILLIMANI_S_A": {
        "email": "acceso@illimani.com",
        "aliases": [],
        "display_name": "Representante Legal - Seguros Illimani",
    },
    "BO_ASEG_SEGUROS_Y_REASEGUROS_CREDINFORM_INTERNATIONA": {
        "email": "acceso@credinform.com",
        "aliases": [],
        "display_name": "Representante Legal - Credinform International",
    },
    "BO_ASEG_UNIBIENES_S_A": {
        "email": "acceso@unibienes.com",
        "aliases": [],
        "display_name": "Representante Legal - UNIBIENES Seguros",
    },
    "BO_ASEG_UNIVIDA_S_A": {
        "email": "acceso@univida.com",
        "aliases": [],
        "display_name": "Representante Legal - UNIVIDA Seguros",
    },
    "BO_PUB_BANCA_PRIVADA": {
        "email": "acceso@csbp.com.bo",
        "aliases": [],
        "display_name": "Operador Caja de Salud de la Banca Privada (CSBP)",
    },
    "BO_PUB_CAMINOS": {
        "email": "acceso@caminos.gob.bo",
        "aliases": [],
        "display_name": "Operador Caja de Salud de Caminos",
    },
    "BO_PUB_CNS": {
        "email": "acceso@cns.gob.bo",
        "aliases": [],
        "display_name": "Operador Caja Nacional de Salud (CNS)",
    },
    "BO_PUB_CORDES": {
        "email": "acceso@cordes.org.bo",
        "aliases": [],
        "display_name": "Operador Caja de Salud CORDES",
    },
    "BO_PUB_COSSMIL": {
        "email": "acceso@cossmil.mil.bo",
        "aliases": [],
        "display_name": "Operador Corporación del Seguro Social Militar (COSSMIL)",
    },
    "BO_PUB_CPS": {
        "email": "acceso@cps.org.bo",
        "aliases": [],
        "display_name": "Operador Caja Petrolera de Salud (CPS)",
    },
    "BO_PUB_SSU": {
        "email": "acceso@ssu.edu.bo",
        "aliases": [],
        "display_name": "Operador Seguro Social Universitario (SSU)",
    },
    "BO_PUB_SUS": {
        "email": "acceso@minsalud.gob.bo",
        "aliases": [],
        "display_name": "Operador Sistema Único de Salud (SUS)",
    },
    "DEMO-07qj6": {
        "email": "acceso@aseguradorademo.com",
        "aliases": [],
        "display_name": "Operador Aseguradora Demo",
    },
}


def load_db_config():
    """Carga configuración de conexión a Postgres desde el .env de la API o del entorno."""
    cfg = {
        "POSTGRES_HOST": os.environ.get("POSTGRES_HOST"),
        "POSTGRES_PORT": os.environ.get("POSTGRES_PORT"),
        "POSTGRES_USER": os.environ.get("POSTGRES_USER"),
        "POSTGRES_PASSWORD": os.environ.get("POSTGRES_PASSWORD"),
        "POSTGRES_DB": os.environ.get("POSTGRES_DB"),
    }
    if paths.API_ENV_FILE.exists():
        for line in paths.API_ENV_FILE.read_text(encoding="utf-8").splitlines():
            line = line.strip()
            if not line or line.startswith("#") or "=" not in line:
                continue
            k, v = line.split("=", 1)
            k = k.strip()
            v = v.split(" #")[0].strip()
            if not cfg.get(k):
                cfg[k] = v
    return cfg


def seed_accounts(dry_run=False, password=DEFAULT_PASSWORD):
    cfg = load_db_config()
    print("=" * 70)
    print("🏥 ALOVIDA / SALUD v4 — Seeder de Cuentas de Aseguradoras")
    print("=" * 70)
    print(f"  Base de datos: {cfg['POSTGRES_HOST']}:{cfg['POSTGRES_PORT']}/{cfg['POSTGRES_DB']}")
    print(f"  Contraseña común: {password}")
    print(f"  Modo dry-run: {'SÍ (sin cambios)' if dry_run else 'NO (persiste en BD)'}")
    print("-" * 70)

    secret_hash = DEFAULT_ARGON2_HASH
    if password != DEFAULT_PASSWORD:
        try:
            import argon2
            ph = argon2.PasswordHasher(time_cost=3, memory_cost=65536, parallelism=4)
            secret_hash = ph.hash(password)
        except ImportError:
            print("  ⚠️ Advertencia: módulo python argon2 no instalado; usando hash estándar.")

    conn = psycopg.connect(
        host=cfg["POSTGRES_HOST"],
        port=cfg["POSTGRES_PORT"],
        user=cfg["POSTGRES_USER"],
        password=cfg["POSTGRES_PASSWORD"],
        dbname=cfg["POSTGRES_DB"],
    )

    created_accounts = []

    with conn.cursor() as cur:
        # Obtener todas las aseguradoras registradas
        cur.execute("""
            SELECT c.id, c.tenant_id, c.carrier_code, c.legal_name, c.sigla
            FROM insurance.insurance_carriers c
            ORDER BY c.carrier_code;
        """)
        carriers = cur.fetchall()
        print(f"  Total aseguradoras encontradas en base de datos: {len(carriers)}\n")

        for carrier_id, tenant_id, carrier_code, legal_name, sigla in carriers:
            account_info = CARRIER_ACCOUNTS.get(carrier_code)
            if not account_info:
                # Generar email sintético por convención si aparece una nueva aseguradora
                slug = carrier_code.replace("BO_ASEG_", "").replace("BO_PUB_", "").lower().replace("_", "")
                account_info = {
                    "email": f"acceso@{slug}.com",
                    "aliases": [],
                    "display_name": f"Operador {sigla or legal_name}",
                }

            emails_to_seed = [account_info["email"]] + account_info["aliases"]

            for email in emails_to_seed:
                # Generar UUIDs deterministas
                user_id = uuid.uuid5(UUID_NAMESPACE_ALOVIDA, f"iam:user:{email}")
                cred_id = uuid.uuid5(UUID_NAMESPACE_ALOVIDA, f"iam:cred:{email}")
                role_id = uuid.uuid5(UUID_NAMESPACE_ALOVIDA, f"iam:role:{carrier_code}:{email}")
                membership_id = uuid.uuid5(UUID_NAMESPACE_ALOVIDA, f"directory:membership:{carrier_code}:{tenant_id}:{email}")
                now = datetime.now(timezone.utc)

                display_name = account_info["display_name"]

                if not dry_run:
                    # 1. Insertar iam.users
                    cur.execute("""
                        INSERT INTO iam.users (
                            id, status_concept_id, display_name, time_zone,
                            email_verified, phone_verified, created_at, updated_at, row_version
                        ) VALUES (
                            %s, %s, %s, 'America/La_Paz',
                            TRUE, FALSE, %s, %s, 1
                        )
                        ON CONFLICT (id) DO UPDATE SET
                            display_name = EXCLUDED.display_name,
                            status_concept_id = EXCLUDED.status_concept_id,
                            updated_at = EXCLUDED.updated_at;
                    """, (user_id, CONCEPT_USER_ACTIVE, display_name, now, now))

                    # 2. Insertar iam.authentication_credentials
                    cur.execute("""
                        INSERT INTO iam.authentication_credentials (
                            id, user_id, method_concept_id, external_subject,
                            secret_hash, hash_algorithm_concept_id, state_concept_id,
                            created_at, updated_at, row_version
                        ) VALUES (
                            %s, %s, %s, %s,
                            %s, %s, %s,
                            %s, %s, 1
                        )
                        ON CONFLICT (id) DO UPDATE SET
                            secret_hash = EXCLUDED.secret_hash,
                            state_concept_id = EXCLUDED.state_concept_id,
                            updated_at = EXCLUDED.updated_at;
                    """, (
                        cred_id, user_id, CONCEPT_METHOD_PASSWORD, email,
                        secret_hash, CONCEPT_HASH_ARGON2ID, CONCEPT_ACTIVE,
                        now, now
                    ))

                    # 3. Insertar iam.user_global_roles (solo USER, el acceso a aseguradora lo da el tenant)
                    cur.execute("""
                        INSERT INTO iam.user_global_roles (
                            id, user_id, role_concept_id, state_concept_id,
                            created_at, updated_at, row_version
                        ) VALUES (
                            %s, %s, %s, %s,
                            %s, %s, 1
                        )
                        ON CONFLICT (id) DO NOTHING;
                    """, (role_id, user_id, CONCEPT_ROLE_USER, CONCEPT_ACTIVE, now, now))

                    # 4. Insertar directory.tenant_memberships en el tenant de la aseguradora
                    cur.execute("""
                        INSERT INTO directory.tenant_memberships (
                            id, user_id, tenant_id, tenant_role_concept_id,
                            status_concept_id, access_scope_concept_id, start_date,
                            created_at, updated_at, row_version
                        ) VALUES (
                            %s, %s, %s, %s,
                            %s, %s, '2026-01-01',
                            %s, %s, 1
                        )
                        ON CONFLICT (id) DO UPDATE SET
                            tenant_role_concept_id = EXCLUDED.tenant_role_concept_id,
                            status_concept_id = EXCLUDED.status_concept_id,
                            access_scope_concept_id = EXCLUDED.access_scope_concept_id,
                            updated_at = EXCLUDED.updated_at;
                    """, (
                        membership_id, user_id, tenant_id, CONCEPT_ROLE_ADMIN,
                        CONCEPT_MEMBERSHIP_ACTIVE, CONCEPT_SCOPE_ALL_TENANT,
                        now, now
                    ))

                created_accounts.append({
                    "email": email,
                    "password": password,
                    "display_name": display_name,
                    "carrier_code": carrier_code,
                    "carrier_name": sigla or legal_name,
                    "tenant_id": str(tenant_id),
                })

        if not dry_run:
            conn.commit()

    conn.close()

    print(f"✅ Se procesaron exitosamente {len(created_accounts)} cuentas de aseguradora:")
    print(f"{'Email':<32} | {'Contraseña':<10} | {'Aseguradora'}")
    print("-" * 75)
    for acc in created_accounts:
        print(f"{acc['email']:<32} | {acc['password']:<10} | {acc['carrier_name']}")
    print("-" * 75)
    print("✨ Cuentas listas para autenticación y consumo de API / Frontend.")
    return created_accounts


def generate_sql_patch(output_path=None):
    """Genera el script SQL idempotente de migración/patch."""
    if output_path is None:
        output_path = paths.SQL_DIR / "patches" / "2026-09-26_v4231_seed_insurer_accounts.sql"

    sql_lines = [
        "-- SALUD v4.0.10 / ALOVIDA — patch 2026-09-26_v4231_seed_insurer_accounts.sql",
        "-- Seeder de cuentas de acceso para operadores de aseguradoras (PAYER)",
        "-- Idempotente: ON CONFLICT DO NOTHING / UPDATE",
        "",
        "BEGIN;",
        "",
    ]

    for code, info in CARRIER_ACCOUNTS.items():
        emails = [info["email"]] + info["aliases"]
        for email in emails:
            user_id = uuid.uuid5(UUID_NAMESPACE_ALOVIDA, f"iam:user:{email}")
            cred_id = uuid.uuid5(UUID_NAMESPACE_ALOVIDA, f"iam:cred:{email}")
            role_id = uuid.uuid5(UUID_NAMESPACE_ALOVIDA, f"iam:role:{code}:{email}")
            membership_id = uuid.uuid5(UUID_NAMESPACE_ALOVIDA, f"directory:membership:{code}:{email}")
            display_name = info["display_name"].replace("'", "''")

            sql_lines.append(f"-- Cuenta para {code}: {email}")
            sql_lines.append(f"""INSERT INTO iam.users (id, status_concept_id, display_name, time_zone, email_verified, phone_verified, created_at, updated_at, row_version)
VALUES ('{user_id}', '{CONCEPT_USER_ACTIVE}', '{display_name}', 'America/La_Paz', TRUE, FALSE, NOW(), NOW(), 1)
ON CONFLICT (id) DO UPDATE SET display_name = EXCLUDED.display_name, status_concept_id = EXCLUDED.status_concept_id;
""")
            sql_lines.append(f"""INSERT INTO iam.authentication_credentials (id, user_id, method_concept_id, external_subject, secret_hash, hash_algorithm_concept_id, state_concept_id, created_at, updated_at, row_version)
VALUES ('{cred_id}', '{user_id}', '{CONCEPT_METHOD_PASSWORD}', '{email}', '{DEFAULT_ARGON2_HASH}', '{CONCEPT_HASH_ARGON2ID}', '{CONCEPT_ACTIVE}', NOW(), NOW(), 1)
ON CONFLICT (id) DO UPDATE SET secret_hash = EXCLUDED.secret_hash, state_concept_id = EXCLUDED.state_concept_id;
""")
            sql_lines.append(f"""INSERT INTO iam.user_global_roles (id, user_id, role_concept_id, state_concept_id, created_at, updated_at, row_version)
VALUES ('{role_id}', '{user_id}', '{CONCEPT_ROLE_USER}', '{CONCEPT_ACTIVE}', NOW(), NOW(), 1)
ON CONFLICT (id) DO NOTHING;
""")
            sql_lines.append(f"""INSERT INTO directory.tenant_memberships (id, user_id, tenant_id, tenant_role_concept_id, status_concept_id, access_scope_concept_id, start_date, created_at, updated_at, row_version)
SELECT '{membership_id}', '{user_id}', c.tenant_id, '{CONCEPT_ROLE_ADMIN}', '{CONCEPT_MEMBERSHIP_ACTIVE}', '{CONCEPT_SCOPE_ALL_TENANT}', '2026-01-01', NOW(), NOW(), 1
FROM insurance.insurance_carriers c
WHERE c.carrier_code = '{code}'
ON CONFLICT (id) DO NOTHING;
""")

    sql_lines.append("COMMIT;\n")

    output_path = Path(output_path)
    output_path.parent.mkdir(parents=True, exist_ok=True)
    output_path.write_text("\n".join(sql_lines), encoding="utf-8")
    print(f"📄 Patch SQL generado exitosamente en: {output_path}")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Seeder de cuentas de operador para aseguradoras")
    parser.add_argument("--dry-run", action="store_true", help="Simula sin persistir en base de datos")
    parser.add_argument("--password", default=DEFAULT_PASSWORD, help="Contraseña a asignar a todas las cuentas")
    parser.add_argument("--gen-sql", action="store_true", help="Genera el archivo patch SQL en SQL/patches/")
    args = parser.parse_args()

    if args.gen_sql:
        generate_sql_patch()
    else:
        seed_accounts(dry_run=args.dry_run, password=args.password)
        generate_sql_patch()

