"""Contracts for explicit model constraints and preservation of deployed schema."""
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
import gen_integrity


class ConcreteIntegrityTests(unittest.TestCase):
    def test_check_preserves_expression_and_rejects_invalid_declarations(self):
        expression = '("inventory_reservation_id" IS NULL OR "service_request_id" IS NULL)'
        sql = gen_integrity.rule_line('insurance', 'insurance_claims', 'CHECK_SQL',
                                      f'ck_order_origin | {expression}')
        self.assertIn(f'CHECK ({expression});', sql)
        self.assertIn('DROP CONSTRAINT IF EXISTS "ck_order_origin"', sql)
        for declaration in ['', 'missing_separator', ' | true', 'ck_empty | ',
                            'invalid-name | true', 'x' * 64 + ' | true']:
            with self.subTest(declaration=declaration), self.assertRaises(ValueError):
                gen_integrity.concrete_check('insurance', 'insurance_claims', declaration)

    def test_qualified_owner_disambiguates_groups(self):
        entries = [{'name': 'medical_groups.groups'}]
        registry = {'groups': [('community', 'groups'), ('medical_groups', 'groups')]}
        gen_integrity.resolve_owners(entries, registry)
        self.assertEqual(entries[0]['owner'], ('medical_groups', 'groups'))
        with self.assertRaises(ValueError):
            gen_integrity.resolve_owners([{'name': 'unknown.groups'}], registry)

    def test_matrix_escapes_separators_and_is_deterministic(self):
        entries = [{'name': 'insurance_claims', 'stereo': 'REFERENCE_ONLY',
                    'owner': ('insurance', 'insurance_claims'),
                    'rules': [('CHECK_SQL', 'ck_origin | "left_id" IS NULL OR "right_id" IS NULL')]}]
        with TemporaryDirectory() as directory:
            root = Path(directory)
            (root / '26_insurance').mkdir()
            (root / '_integrity').mkdir()
            with patch.object(gen_integrity, 'SQL_DIR', root), \
                 patch.object(gen_integrity, 'OUT', root / '_integrity'), redirect_stdout(StringIO()):
                gen_integrity.write_constraints(entries)
                gen_integrity.write_matrix_doc(entries, [], {})
                first = {p.relative_to(root): p.read_bytes() for p in root.rglob('*') if p.is_file()}
                gen_integrity.write_constraints(entries)
                gen_integrity.write_matrix_doc(entries, [], {})
                second = {p.relative_to(root): p.read_bytes() for p in root.rglob('*') if p.is_file()}
            self.assertEqual(first, second)
            matrix = (root / '_integrity/integrity-matrix.md').read_text(encoding='utf-8')
            self.assertIn('ck_origin \\|', matrix)


class ExplicitColumnTests(unittest.TestCase):
    def test_boolean_defaults_are_declared_and_preserved_in_orm(self):
        self.assertIsNone(gen_ddl.boolean_default('boolean', set()))
        for marker, value in [('DEFAULT_TRUE', 'true'), ('DEFAULT_FALSE', 'false')]:
            default = gen_ddl.boolean_default('boolean', {marker})
            column = gen_ddl.Column('automated', 'boolean', True, False, False, False, default)
            self.assertEqual(gen_ddl.column_default(column), ' DEFAULT ' + value)
            self.assertIn('default: ' + value, '\n'.join(gen_entities.emit_property('accounting', 'assets', column, {})))
        for dtype, markers in [('varchar', {'DEFAULT_TRUE'}),
                               ('boolean', {'DEFAULT_TRUE', 'DEFAULT_FALSE'})]:
            with self.assertRaises(ValueError):
                gen_ddl.boolean_default(dtype, markers)

    def test_model_parser_generates_cascade_and_defaults_without_inference(self):
        source = '@startuml SALUD_Module_65_generation_fixture\ntitle Module 65 Fixture\\n(schema: generation_fixture)\nentity parents {\n  * id : uuid <<PK>>\n}\nentity children {\n  * id : uuid <<PK>>\n  * parent_id : uuid <<FK, ON_DELETE_CASCADE>>\n  * is_favorite : boolean <<DEFAULT_FALSE>>\n}\n@enduml\n'
        with TemporaryDirectory() as directory:
            root = Path(directory)
            models = root / 'models'
            models.mkdir()
            (models / 'diagram_65_generation_fixture.puml').write_text(source, encoding='utf-8')
            output = root / 'SQL'
            registry = {'parents': [('generation_fixture', 'parents')],
                        'children': [('generation_fixture', 'children')]}
            with patch.object(gen_ddl, 'PUML_DIR', models), patch.object(gen_ddl, 'OUT_DIR', output), \
                 patch.object(gen_ddl, 'resolve_fk', return_value=('generation_fixture', 'parents')), \
                 redirect_stdout(StringIO()):
                gen_ddl.emit('65', [], registry, {('generation_fixture', 'parents'): 'id'})
                first = {p.relative_to(output): p.read_bytes() for p in output.rglob('*') if p.is_file()}
                gen_ddl.emit('65', [], registry, {('generation_fixture', 'parents'): 'id'})
                second = {p.relative_to(output): p.read_bytes() for p in output.rglob('*') if p.is_file()}
            self.assertEqual(first, second)
            folder = output / '65_generation_fixture'
            self.assertIn('"is_favorite" boolean NOT NULL DEFAULT false', (folder / '02_tables.sql').read_text(encoding='utf-8'))
            self.assertIn('REFERENCES "generation_fixture"."parents" ("id") ON DELETE CASCADE;',
                          (folder / '03_fk_intra.sql').read_text(encoding='utf-8'))


if __name__ == '__main__':
    unittest.main()
