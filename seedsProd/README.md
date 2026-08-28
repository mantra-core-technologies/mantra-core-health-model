# SALUD v4.0 - Medical Terminology Corpus v6.1 (CLEAN, self-contained)

Pruned from corpus v6 (MeSH 2026) to keep only what SALUD Module 03 actually uses.
Self-contained: concepts, designations and relationships are all included here.
Rename this `clean/` folder and hand it to the team as-is.

## Volume (clean)
- Total rows: 1,441,367   (v6 was 3,222,403)
- catalog_concepts: 355,237  (unchanged)
- concept_designations: 996,321  (unchanged)
- concept_relationships kept: 89,790  (Is-a / pharmacological action / see-related)
- value_set_rules (intensional): 4

## Removed vs v6 and why
- concept_relationships 'Allows qualifier' (633,885): MeSH indexing combinatorics, unused by the EHR.
- value_set_members (710,452): replaced by 4 intensional value_set_rules
  (whole code-system / record_type = descriptor|supplemental|qualifier).
- concept_maps (436,703): MeSH supplemental->descriptor maps, niche for a clinical EHR.

## Attribution
Courtesy of the U.S. National Library of Medicine (MeSH 2026). Licensed content
(SNOMED CT, LOINC, RxNorm, ICD-11, MedDRA, CPT) remains excluded.
