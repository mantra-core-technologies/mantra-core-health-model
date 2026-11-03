"""Parche incremental de plantillas: copia el DDL generado del módulo 16."""
import re

from paths import SQL_DIR

TABLE = 'report_presentation_templates'
TARGET = SQL_DIR / 'patches' / '2026-11-02_v4285_accounting_report_templates.sql'


def generate():
    module = SQL_DIR / '16_accounting'
    tables = (module / '02_tables.sql').read_text(encoding='utf-8')
    table = re.search(
        rf'CREATE TABLE IF NOT EXISTS "accounting"\."{TABLE}" \(.*?\n\);',
        tables, re.S,
    )
    if not table:
        raise ValueError('Regenerar primero el módulo 16 desde el modelo')
    indexes = [line for line in (module / '04_indexes.sql').read_text(encoding='utf-8').splitlines()
               if line.startswith('CREATE ') and f'"accounting"."{TABLE}"' in line]
    fks = [block for block in re.findall(r'DO \$\$ BEGIN.*?END \$\$;',
           (module / '90_fk_deferred.sql').read_text(encoding='utf-8'), re.S)
           if f'"accounting"."{TABLE}"' in block]
    statements = ['-- Generado desde SQL/16_accounting por gen_report_templates_patch.py.',
                  'BEGIN;', table.group(0), *indexes, *fks,
                  "DO $$ BEGIN IF EXISTS (SELECT 1 FROM pg_roles WHERE rolname='mantra_app') THEN "
                  f'GRANT SELECT, INSERT, UPDATE ON "accounting"."{TABLE}" TO mantra_app; '
                  'END IF; END $$;', 'COMMIT;']
    TARGET.write_text('\n\n'.join(statements) + '\n', encoding='utf-8')
    print(f'Generado {TARGET.relative_to(SQL_DIR.parent)}')


if __name__ == '__main__':
    generate()
