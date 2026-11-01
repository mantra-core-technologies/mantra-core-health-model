"""gen_entities fusiona con la entidad que ya existe en la API (api#1246, model#110).

Lo que la entidad declara a mano y el `.puml` no contradice se conserva; lo que el
`.puml` contradice lo decide el `.puml` y queda en el reporte. Una tabla ya mapeada
por otra entidad (otro archivo, otra clase) se actualiza ahí, sin duplicarla.
"""
from contextlib import redirect_stdout
from io import StringIO
from pathlib import Path
import sys
from tempfile import TemporaryDirectory
import unittest
from unittest.mock import patch

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
import gen_ddl
import gen_entities

PUML = """@startuml SALUD_Module_65_fixture
title Module 65 Fixture\\n(schema: fixture)
entity things {
  * id : uuid <<PK>>
  * automated : boolean <<DEFAULT_TRUE>>
  * mode : varchar(12) <<DEFAULT_TEXT:simulated>>
    channel : varchar(16)
  * owner_user_id : uuid <<FK>>
  * issued_on : date
    options : jsonb
    note : varchar
  * code : varchar
  * label : varchar
  * min_hours : integer
  * created_at : timestamptz
}
entity "INDEXES · things" as idxset_things <<INDEX_SET>> {
  PK pk_things : (id) UNIQUE BTREE
  UX ux_things_owner_user_id : (owner_user_id) UNIQUE BTREE
}
@enduml
"""

# Una entidad como las que deja Prettier, con lo que se escribe a mano.
EXISTING = """import { Entity, PrimaryKey, Property } from '@mikro-orm/decorators/legacy';
import { randomUUID } from 'node:crypto';
import type { ThingChannel } from '../thing.enums';

/**
 * Clase documentada a mano.
 */
@Entity({ schema: 'fixture', tableName: 'things' })
export class Things {
  @PrimaryKey({ type: 'uuid' })
  id: string = randomUUID();

  /** En memoria, verdadero hasta que se diga lo contrario. */
  @Property({ fieldName: 'automated', columnType: 'boolean' })
  automated: boolean = true;

  @Property({
    columnType: 'varchar(12)',
    default: 'simulated',
  })
  mode: 'simulated' | 'real' = 'simulated';

  @Property({
    fieldName: 'channel',
    columnType: 'varchar(16)',
    nullable: true,
  })
  channel?: ThingChannel;

  @Property({ fieldName: 'owner_user_id', type: 'uuid', unique: true }) // FK → iam.users
  ownerUserId!: string;

  @Property({ fieldName: 'issued_on', columnType: 'date' })
  issuedOn!: string;

  @Property({ type: 'json', columnType: 'jsonb', nullable: true })
  options?: string[];

  @Property({ columnType: 'varchar', nullable: true })
  note?: string;

  @Property({ columnType: 'varchar', nullable: true })
  code?: string;

  @Property({ columnType: 'varchar', unique: true })
  label!: string;

  @Property({ fieldName: 'min_hours', type: 'integer' })
  minHours: number = 24;

  @Property({ fieldName: 'created_at', columnType: 'timestamptz' })
  createdAt!: Date;

  @Property({ columnType: 'varchar', nullable: true })
  legacy?: string;
}
"""


def fixture_entities(root: Path):
    models = root / 'models'
    models.mkdir()
    (models / 'diagram_65_fixture.puml').write_text(PUML, encoding='utf-8')
    with patch.object(gen_ddl, 'PUML_DIR', models):
        schema, entities, idx, *_ = gen_ddl.parse_module(models / 'diagram_65_fixture.puml')
    return models, schema, entities[0], idx


REGISTRY = {'things': [('fixture', 'things')], 'users': [('iam', 'users')]}


class MergeWithExistingEntityTests(unittest.TestCase):
    def setUp(self):
        self.tmp = TemporaryDirectory()
        self.root = Path(self.tmp.name)
        self.models, self.schema, self.ent, self.idx = fixture_entities(self.root)
        self.report = gen_entities.Report()
        with patch.object(gen_ddl, 'resolve_fk', return_value=None):
            self.out = gen_entities.emit_entity(
                self.schema, self.ent, REGISTRY,
                existing=gen_entities.parse_entity(EXISTING),
                indexes=self.idx['things'], report=self.report)

    def tearDown(self):
        self.tmp.cleanup()

    def test_preserves_initializers_types_imports_and_docs(self):
        out = self.out
        self.assertIn("automated: boolean = true;", out)        # inicializador, no `default:` + `!`
        self.assertIn("mode: 'simulated' | 'real' = 'simulated';", out)   # unión TS
        self.assertIn("channel?: ThingChannel;", out)            # alias importado
        self.assertIn("import type { ThingChannel } from '../thing.enums';", out)
        self.assertIn("issuedOn!: string;", out)                 # fecha como string
        self.assertIn("options?: string[];", out)                # jsonb tipado
        self.assertIn("minHours: number = 24;", out)             # inicializador sin DEFAULT en el .puml
        self.assertIn(" * Clase documentada a mano.", out)
        self.assertIn("/** En memoria, verdadero hasta que se diga lo contrario. */", out)
        self.assertNotIn("default: true", out)                   # el inicializador ya lo da

    def test_unchanged_properties_keep_their_exact_text(self):
        for chunk in ("  @Property({\n    columnType: 'varchar(12)',\n    default: 'simulated',\n  })",
                      "  @Property({\n    fieldName: 'channel',\n    columnType: 'varchar(16)',\n"
                      "    nullable: true,\n  })",
                      "  @Property({ fieldName: 'min_hours', type: 'integer' })",
                      "  @Property({ fieldName: 'automated', columnType: 'boolean' })"):
            self.assertIn(chunk, self.out)

    def test_unique_backed_by_the_model_is_kept(self):
        self.assertIn("@Property({ fieldName: 'owner_user_id', type: 'uuid', unique: true })", self.out)

    def test_optional_column_stays_optional_when_model_is_nullable(self):
        self.assertIn("note?: string;", self.out)

    def test_contradictions_follow_the_model_and_are_reported(self):
        out = self.out
        # code: entidad NULL, .puml NOT NULL
        self.assertIn("@Property({ columnType: 'varchar' })\n  code!: string;", out)
        # label: unique sin UNIQUE en el .puml
        self.assertIn("@Property({ columnType: 'varchar' })\n  label!: string;", out)
        # legacy: la entidad tiene una propiedad sin columna en el .puml
        self.assertNotIn("legacy?: string", out)
        joined = "\n".join(self.report.conflicts)
        self.assertIn("fixture.things.code: nulabilidad — entidad NULL, .puml NOT NULL", joined)
        self.assertIn("fixture.things.label: unique", joined)
        self.assertIn("`legacy`", joined)
        self.assertEqual(len(self.report.conflicts), 3, joined)

    def test_column_type_contradiction_regenerates_the_property(self):
        existing = EXISTING.replace("@Property({ fieldName: 'min_hours', type: 'integer' })",
                                    "@Property({ fieldName: 'min_hours', columnType: 'bigint' })")
        report = gen_entities.Report()
        with patch.object(gen_ddl, 'resolve_fk', return_value=None):
            out = gen_entities.emit_entity(self.schema, self.ent, REGISTRY,
                                           existing=gen_entities.parse_entity(existing),
                                           indexes=self.idx['things'], report=report)
        self.assertIn("@Property({ fieldName: 'min_hours', columnType: 'int' })\n  minHours!: number;", out)
        self.assertTrue(any("min_hours: tipo de columna — entidad bigint, .puml int" in c
                            for c in report.conflicts), report.conflicts)

    def test_uuid_pk_without_initializer_is_respected(self):
        existing = EXISTING.replace("id: string = randomUUID();", "id!: string;")
        with patch.object(gen_ddl, 'resolve_fk', return_value=None):
            out = gen_entities.emit_entity(self.schema, self.ent, REGISTRY,
                                           existing=gen_entities.parse_entity(existing),
                                           indexes=self.idx['things'], report=gen_entities.Report())
        self.assertIn("id!: string;", out)
        self.assertNotIn("randomUUID", out)                      # ni el inicializador ni su import

    def test_new_entity_without_existing_is_unchanged_behaviour(self):
        with patch.object(gen_ddl, 'resolve_fk', return_value=None):
            out = gen_entities.emit_entity(self.schema, self.ent, REGISTRY)
        self.assertIn("automated!: boolean;", out)
        self.assertIn("@Property({ type: 'boolean', default: true })", out)
        self.assertIn("id: string = randomUUID();", out)


class AlreadyMappedTableTests(unittest.TestCase):
    """medical_groups.groups ya vive en `medical_groups.entity.ts` como `MedicalGroups`."""

    PUML = """@startuml SALUD_Module_66_medical_groups
title Module 66 Fixture\\n(schema: medical_groups)
entity groups {
  * id : uuid <<PK>>
  * name : varchar
}
@enduml
"""
    MEDICAL = """import { Entity, PrimaryKey, Property } from '@mikro-orm/decorators/legacy';
import { randomUUID } from 'node:crypto';

@Entity({ schema: 'medical_groups', tableName: 'groups' })
export class MedicalGroups {
  @PrimaryKey({ type: 'uuid' })
  id: string = randomUUID();

  @Property({ columnType: 'text' })
  name!: string;
}
"""

    def test_updates_the_existing_entity_instead_of_creating_another(self):
        with TemporaryDirectory() as directory:
            root = Path(directory)
            models = root / 'models'
            models.mkdir()
            (models / 'diagram_66_medical_groups.puml').write_text(self.PUML, encoding='utf-8')
            out_dir = root / 'src' / 'modules'
            ents = out_dir / 'medical_groups' / 'entities'
            ents.mkdir(parents=True)
            (ents / 'medical_groups.entity.ts').write_text(self.MEDICAL, encoding='utf-8')
            (ents / 'index.ts').write_text("export * from './medical_groups.entity';\n", encoding='utf-8')
            # homónimo en otro schema: sin el índice de tablas mapeadas, la clase se cualificaba
            registry = {'groups': [('community', 'groups'), ('medical_groups', 'groups')]}
            report = gen_entities.Report()
            with patch.object(gen_ddl, 'PUML_DIR', models), \
                 patch.object(gen_entities, 'PUML_DIR', models), \
                 patch.object(gen_entities, 'OUT_DIR', out_dir), \
                 redirect_stdout(StringIO()):
                mapped = gen_entities.scan_mapped_tables(out_dir, report)
                gen_entities.emit_module('66', registry, mapped, report)
                first = {p.name: p.read_text(encoding='utf-8') for p in ents.iterdir()}
                gen_entities.emit_module('66', registry, gen_entities.scan_mapped_tables(out_dir), report)
                second = {p.name: p.read_text(encoding='utf-8') for p in ents.iterdir()}
            self.assertEqual(sorted(first), ['index.ts', 'medical_groups.entity.ts'])
            self.assertIn('export class MedicalGroups {', first['medical_groups.entity.ts'])
            self.assertIn("@Property({ columnType: 'varchar' })", first['medical_groups.entity.ts'])
            self.assertEqual(first['index.ts'], "export * from './medical_groups.entity';\n")
            self.assertEqual(first, second)
            self.assertTrue(any('name: tipo de columna' in c for c in report.conflicts))

    def test_scan_reports_a_table_mapped_twice(self):
        with TemporaryDirectory() as directory:
            out_dir = Path(directory)
            for folder, name in (('medical_groups', 'medical_groups'), ('medical_groups', 'groups')):
                d = out_dir / folder / 'entities'
                d.mkdir(parents=True, exist_ok=True)
                (d / f'{name}.entity.ts').write_text(self.MEDICAL, encoding='utf-8')
            report = gen_entities.Report()
            mapped = gen_entities.scan_mapped_tables(out_dir, report)
            self.assertEqual(mapped[('medical_groups', 'groups')].name, 'groups.entity.ts')
            self.assertEqual(len(report.notes), 1)


class FkCommentFollowsDdlTests(unittest.TestCase):
    def test_labeled_edge_resolves_like_the_ddl(self):
        with TemporaryDirectory() as directory:
            puml = Path(directory) / 'diagram_16_accounting.puml'
            puml.write_text('@startuml x\n(schema: accounting)\nentity simple_accounts {\n  * id : uuid <<PK>>\n}\n'
                            'entity records {\n  * id : uuid <<PK>>\n  * account_id : uuid <<FK>>\n}\n'
                            'records }o--|| simple_accounts : account_id\n@enduml\n', encoding='utf-8')
            registry = {'simple_accounts': [('accounting', 'simple_accounts')],
                        'accounts': [('accounting', 'accounts')]}
            with patch.object(gen_ddl, 'resolve_fk', return_value=None):
                self.assertEqual(gen_entities.fk_comment('accounting', 'records', 'account_id', registry, puml),
                                 '  // FK → accounting.simple_accounts')
                self.assertEqual(gen_entities.fk_comment('accounting', 'records', 'account_id', registry),
                                 '  // FK → accounting.accounts (inferida)')


if __name__ == '__main__':
    unittest.main()
