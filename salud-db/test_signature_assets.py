import unittest

from gen_ddl import resolve_fk_convention


class SignatureAssetsForeignKeys(unittest.TestCase):
    def test_image_file_suffix_resolves_existing_common_files(self):
        registry = {"files": {("common", "files")}}
        for column in ("signature_file_id", "seal_file_id", "photo_file_id"):
            self.assertEqual(
                resolve_fk_convention("profiles", "health_practitioner_profiles", column, registry),
                ("common", "files"),
            )

    def test_missing_file_table_is_not_invented(self):
        self.assertIsNone(resolve_fk_convention("profiles", "profile", "signature_file_id", {}))

    def test_unrelated_signature_identifier_is_not_an_image(self):
        self.assertIsNone(resolve_fk_convention("profiles", "profile", "signature_id", {}))


if __name__ == "__main__":
    unittest.main()
