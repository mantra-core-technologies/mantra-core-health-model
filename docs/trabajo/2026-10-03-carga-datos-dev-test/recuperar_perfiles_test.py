#!/usr/bin/env python3
"""Audita y recupera sólo cuentas/perfiles sintéticos del respaldo de Test 2026-09-27.

Se ejecuta dentro de la red de Test, con las variables POSTGRES_* ya provistas
por el entorno privado. Sin --apply, la transacción se revierte. Nunca imprime
identificadores, nombres, correos, secretos ni contenidos de perfiles.
"""

import argparse
import os
import sys

import psycopg
from psycopg import sql
from psycopg.rows import dict_row


SOURCE_DB = "alovida_audit_20260927"
TARGET_DB = "alovida_health"

# Orden de padres a hijos. Sesiones, refresh tokens, verificaciones y eventos de
# seguridad caducados quedan fuera deliberadamente.
TABLES = (
    ("iam", "users", "id", "user"),
    ("iam", "authentication_credentials", "id", "user_id"),
    ("iam", "user_global_roles", "id", "user_id"),
    ("profiles", "persons", "id", "person"),
    ("profiles", "person_profiles", "id", "person_id"),
    ("profiles", "person_account_links", "id", "person_id"),
    ("profiles", "patient_profiles", "profile_id", "person"),
    ("profiles", "health_practitioner_profiles", "profile_id", "person"),
    ("profiles", "practitioner_languages", "id", "practitioner"),
    ("profiles", "jurisdiction_authorizations", "id", "practitioner"),
    ("profiles", "professional_credentials", "id", "practitioner"),
)


def connect(dbname):
    return psycopg.connect(
        host=os.environ["POSTGRES_HOST"],
        port=os.environ["POSTGRES_PORT"],
        user=os.environ["POSTGRES_USER"],
        password=os.environ["POSTGRES_PASSWORD"],
        dbname=dbname,
        row_factory=dict_row,
    )


def columns(conn, schema, table):
    return [r["column_name"] for r in conn.execute(
        "SELECT column_name FROM information_schema.columns "
        "WHERE table_schema=%s AND table_name=%s ORDER BY ordinal_position",
        (schema, table),
    )]


def rows_for(conn, schema, table, selector, user_ids, person_ids, practitioner_ids):
    table_sql = sql.Identifier(schema, table)
    if selector == "user":
        query = sql.SQL("SELECT * FROM {} WHERE id = ANY(%s)").format(table_sql)
        values = user_ids
    elif selector == "person":
        field = "id" if "id" in columns(conn, schema, table) else "profile_id"
        query = sql.SQL("SELECT * FROM {} WHERE {} = ANY(%s)").format(
            table_sql, sql.Identifier(field)
        )
        values = person_ids
    elif selector == "user_id":
        query = sql.SQL("SELECT * FROM {} WHERE user_id = ANY(%s)").format(table_sql)
        values = user_ids
    elif selector == "person_id":
        query = sql.SQL("SELECT * FROM {} WHERE person_id = ANY(%s)").format(table_sql)
        values = person_ids
    elif selector == "practitioner":
        field = "practitioner_profile_id"
        if field not in columns(conn, schema, table):
            field = "practitioner_id"
        query = sql.SQL("SELECT * FROM {} WHERE {} = ANY(%s)").format(
            table_sql, sql.Identifier(field)
        )
        values = practitioner_ids
    else:
        raise ValueError(selector)
    return conn.execute(query, (list(values),)).fetchall()


def foreign_keys(conn, schema, table):
    return conn.execute(
        """SELECT conname, confrelid::regclass::text AS parent,
                  ARRAY(SELECT a.attname FROM unnest(conkey) WITH ORDINALITY k(num, ord)
                        JOIN pg_attribute a ON a.attrelid=conrelid AND a.attnum=k.num
                        ORDER BY k.ord) AS child_cols,
                  ARRAY(SELECT a.attname FROM unnest(confkey) WITH ORDINALITY k(num, ord)
                        JOIN pg_attribute a ON a.attrelid=confrelid AND a.attnum=k.num
                        ORDER BY k.ord) AS parent_cols
           FROM pg_constraint WHERE contype='f' AND conrelid=%s::regclass""",
        (f"{schema}.{table}",),
    ).fetchall()


def check_dependencies(target, selected):
    future = {(schema, table): rows for schema, table, _pk, _cols, rows in selected}
    cache = {}
    issues = []
    for schema, table, _pk, _cols, rows in selected:
        for fk in foreign_keys(target, schema, table):
            parent_schema, parent_table = fk["parent"].split(".")
            parent_cols = fk["parent_cols"]
            key = (parent_schema, parent_table, tuple(parent_cols))
            if key not in cache:
                query = sql.SQL("SELECT {} FROM {}").format(
                    sql.SQL(", ").join(map(sql.Identifier, parent_cols)),
                    sql.Identifier(parent_schema, parent_table),
                )
                values = {tuple(r[c] for c in parent_cols) for r in target.execute(query)}
                values.update(
                    tuple(r[c] for c in parent_cols)
                    for r in future.get((parent_schema, parent_table), [])
                )
                cache[key] = values
            missing = sum(
                1 for row in rows
                if all(row[c] is not None for c in fk["child_cols"])
                and tuple(row[c] for c in fk["child_cols"]) not in cache[key]
            )
            if missing:
                issues.append((f"{schema}.{table}", fk["conname"], missing))
    for table, constraint, count in issues:
        print(f"FK faltante: {table}.{constraint}: {count}")
    print(f"preflight FK: {len(issues)} restricciones con referencias faltantes")
    return issues


def main():
    args = argparse.ArgumentParser()
    args.add_argument("--apply", action="store_true")
    args.add_argument("--audit", action="store_true")
    opts = args.parse_args()

    with connect(SOURCE_DB) as source, connect(TARGET_DB) as target:
        old_links = source.execute(
            "SELECT person_id, user_id FROM profiles.person_account_links"
        ).fetchall()
        user_ids = {r["user_id"] for r in old_links}
        person_ids = {r["person_id"] for r in old_links}
        practitioner_ids = {r["profile_id"] for r in source.execute(
            "SELECT profile_id FROM profiles.health_practitioner_profiles"
        )}

        assert len(user_ids) == 114 and len(person_ids) == 114
        assert len(practitioner_ids) == 18
        old_patients = {r["profile_id"] for r in source.execute(
            "SELECT profile_id FROM profiles.patient_profiles"
        )}
        assert len(old_patients) == 96

        print("origen: usuarios vinculados=114, personas=114, pacientes=96, profesionales=18")
        selected = []
        for schema, table, pk, selector in TABLES:
            source_rows = rows_for(
                source, schema, table, selector, user_ids, person_ids, practitioner_ids
            )
            source_cols = columns(source, schema, table)
            target_cols = columns(target, schema, table)
            only_old_cols = set(source_cols) - set(target_cols)
            if only_old_cols:
                raise RuntimeError(f"{schema}.{table}: columnas antiguas sin destino: {len(only_old_cols)}")
            existing = {r[pk] for r in target.execute(
                sql.SQL("SELECT {} FROM {}").format(
                    sql.Identifier(pk), sql.Identifier(schema, table)
                )
            )}
            missing = [r for r in source_rows if r[pk] not in existing]
            omitted = 0
            if (schema, table) == ("iam", "authentication_credentials"):
                # El reinicio creó nuevas cuentas con el mismo correo sintético
                # bajo otros IDs. Preservamos la credencial vigente y dejamos
                # la cuenta histórica como perfil consultable sin login duplicado.
                live_subjects = {
                    r["external_subject"] for r in target.execute(
                        "SELECT external_subject FROM iam.authentication_credentials "
                        "WHERE external_subject IS NOT NULL"
                    )
                }
                omitted = sum(r["external_subject"] in live_subjects for r in missing)
                missing = [r for r in missing if r["external_subject"] not in live_subjects]
            print(
                f"{schema}.{table}: origen={len(source_rows)} "
                f"ya={len(source_rows)-len(missing)-omitted} "
                f"faltan={len(missing)} omitidas_por_colision={omitted}"
            )
            selected.append((schema, table, pk, source_cols, missing))

        issues = check_dependencies(target, selected)

        if opts.audit:
            print("auditoría terminada; no se escribieron datos")
            return

        if issues:
            raise RuntimeError("Hay referencias faltantes; no se aplicó nada")

        before = {
            (schema, table): target.execute(
                sql.SQL("SELECT count(*) AS n FROM {}").format(sql.Identifier(schema, table))
            ).fetchone()["n"]
            for schema, table, _pk, _cols, _rows in selected
        }
        try:
            for schema, table, _pk, cols, rows in selected:
                if not rows:
                    continue
                query = sql.SQL("INSERT INTO {} ({}) VALUES ({})").format(
                    sql.Identifier(schema, table),
                    sql.SQL(", ").join(map(sql.Identifier, cols)),
                    sql.SQL(", ").join(sql.Placeholder() for _ in cols),
                )
                values = []
                for row in rows:
                    copy = dict(row)
                    # Dos FKs autorreferentes pueden apuntar a otra fila del
                    # mismo lote; se restauran al terminar de insertar padres.
                    if (schema, table) == ("iam", "users"):
                        copy["created_by_user_id"] = None
                        copy["updated_by_user_id"] = None
                    elif (schema, table) == ("profiles", "persons"):
                        copy["merge_survivor_person_id"] = None
                    values.append(tuple(copy[c] for c in cols))
                with target.cursor() as cursor:
                    cursor.executemany(query, values)
                print(f"insertadas {schema}.{table}: {len(rows)}")

                if (schema, table) == ("iam", "users"):
                    with target.cursor() as cursor:
                        cursor.executemany(
                            "UPDATE iam.users SET created_by_user_id=%s, updated_by_user_id=%s WHERE id=%s",
                            [(r["created_by_user_id"], r["updated_by_user_id"], r["id"]) for r in rows],
                        )
                elif (schema, table) == ("profiles", "persons"):
                    with target.cursor() as cursor:
                        cursor.executemany(
                            "UPDATE profiles.persons SET merge_survivor_person_id=%s WHERE id=%s",
                            [(r["merge_survivor_person_id"], r["id"]) for r in rows],
                        )

            for schema, table, _pk, _cols, rows in selected:
                after = target.execute(
                    sql.SQL("SELECT count(*) AS n FROM {}").format(sql.Identifier(schema, table))
                ).fetchone()["n"]
                if after != before[(schema, table)] + len(rows):
                    raise RuntimeError(f"Conteo inesperado en {schema}.{table}")

            for schema, table, id_set, key in (
                ("profiles", "patient_profiles", old_patients, "profile_id"),
                ("profiles", "health_practitioner_profiles", practitioner_ids, "profile_id"),
                ("profiles", "persons", person_ids, "id"),
                ("iam", "users", user_ids, "id"),
            ):
                found = target.execute(
                    sql.SQL("SELECT count(*) AS n FROM {} WHERE {} = ANY(%s)").format(
                        sql.Identifier(schema, table), sql.Identifier(key)
                    ),
                    (list(id_set),),
                ).fetchone()["n"]
                if found != len(id_set):
                    raise RuntimeError(f"Faltan filas históricas en {schema}.{table}")
                print(f"recuperadas {schema}.{table}: {found}/{len(id_set)}")

            if opts.apply:
                target.commit()
                print("COMMIT: fusión aplicada")
            else:
                target.rollback()
                print("ROLLBACK: ensayo completo, Test sin cambios")
        except psycopg.Error as exc:
            target.rollback()
            constraint = getattr(exc.diag, "constraint_name", None) or "sin_constraint"
            print(f"ERROR SQLSTATE={exc.sqlstate} constraint={constraint}; ROLLBACK")
            sys.exit(1)


if __name__ == "__main__":
    main()
