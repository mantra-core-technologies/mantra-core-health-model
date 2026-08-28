-- =============================================================================
-- SEED DE DESARROLLO: vademécum mínimo de medicamentos
-- =============================================================================
-- ALCANCE REAL (leer antes de usar): son 17 medicamentos, 59 designaciones, 155
-- propiedades y 5 interacciones, TIPEADOS A MANO en los VALUES de este archivo.
-- Sirven para tener datos con los que ejercer el módulo en desarrollo.
--
-- NO son un vademécum clínico ni datos verificados contra una fuente. El commit
-- que los introdujo los describía como «calidad real, datos clínicos
-- verificados» y el encabezado anterior decía estar «basado en el índice ATC de
-- la OMS y enriquecido con RxNorm / SNOMED CT»: este archivo no descarga nada de
-- la OMS, RxNorm ni SNOMED CT, y su `source` se autodeclara 'Mantra Vademécum'.
-- Las tres filas de `terminology_sources` son etiquetas con URL, no procedencia.
-- Prohibido usarlo para decisión clínica o en producción.
--
-- El catálogo de terminología REAL (~460k conceptos) sí viene de APIs oficiales
-- y lo cargan los importadores de `mantra-core-health-api/tools/terminology-import/`.
--
-- Vive en SQL/patches/ —fuera de apply_all.sql— porque no se deriva de los
-- `.puml` ni lo consume `load_seeds.py`, que solo lee `*.seeds.json`. Se aplica a
-- mano cuando se lo necesita. Antes vivía en `mantra-core-health-api/database/`,
-- convirtiendo al repositorio de la API en una segunda fuente de verdad del DDL.
--
-- Idempotente: usa UUIDs DETERMINISTAS (md5('mantra:vademecum:'||clave)::uuid)
-- y `ON CONFLICT DO NOTHING`. Re-ejecutar no falla ni duplica.
--
-- Notas de resolución contra la BD real:
--   * data_type es el enum USER-DEFINED terminology.technical_data_type; su
--     valor 'json' representa datos jsonb, que es lo que usamos en value_json.
--   * language_concept_id EN = 9907bae2-1a46-5346-8d92-4d1d5ca3ec7b (English),
--     ES = 1e0b7669-d4d8-5c0f-9544-182a5fe60651 (Spanish). Las designaciones de
--     MARCA quedan con language_concept_id NULL (nombre comercial, neutro).
--   * severity_concept_id de interacciones usa conceptos clinical_ext existentes:
--     mayor = clinical_ext:SEVERITY_HIGH   (75edc384-8721-57f6-b56e-f198dca56a4c),
--     moderada = clinical_ext:SEVERITY_MODERATE (f1c07d34-a212-52a6-932a-8e52c0ceabf6).
--   * state_concept_id se deja NULL (patrón de las filas de seed internas).
-- =============================================================================

BEGIN;

-- -----------------------------------------------------------------------------
-- 1) Fuentes de terminología
-- -----------------------------------------------------------------------------
INSERT INTO terminology.terminology_sources
  (id, code, name, owner, official_url, license, created_at, updated_at, row_version)
VALUES
  (md5('mantra:vademecum:source:WHO_ATC')::uuid, 'WHO_ATC',
   'WHO ATC/DDD Index',
   'WHO Collaborating Centre for Drug Statistics Methodology',
   'https://www.whocc.no/atc_ddd_index/',
   'Use subject to WHOCC terms', now(), now(), 1),
  (md5('mantra:vademecum:source:RXNORM')::uuid, 'RXNORM',
   'RxNorm (NLM)',
   'U.S. National Library of Medicine',
   'https://www.nlm.nih.gov/research/umls/rxnorm/',
   'Public domain (UMLS Metathesaurus license applies to some sources)',
   now(), now(), 1),
  (md5('mantra:vademecum:source:SNOMED_CT')::uuid, 'SNOMED_CT',
   'SNOMED CT',
   'SNOMED International',
   'https://www.snomed.org/',
   'SNOMED CT Affiliate License', now(), now(), 1)
ON CONFLICT (code) DO NOTHING;

-- -----------------------------------------------------------------------------
-- 2) Sistema de códigos + versión (catálogo ATC de medicamentos)
-- -----------------------------------------------------------------------------
INSERT INTO terminology.code_systems
  (id, source_id, internal_code, name, canonical_url,
   case_sensitive, supports_composition, created_at, updated_at, row_version)
SELECT md5('mantra:vademecum:cs:vademecum')::uuid, ts.id, 'vademecum',
       'Mantra Vademécum (ATC-based medication catalog)',
       'https://mantracore.health/fhir/CodeSystem/vademecum',
       true, false, now(), now(), 1
FROM terminology.terminology_sources ts
WHERE ts.code = 'WHO_ATC'
ON CONFLICT (internal_code) DO NOTHING;

INSERT INTO terminology.code_system_versions
  (id, code_system_id, version, published_at, is_default,
   created_at, updated_at, row_version)
SELECT md5('mantra:vademecum:csv:2026.1')::uuid, cs.id, '2026.1',
       now(), true, now(), now(), 1
FROM terminology.code_systems cs
WHERE cs.internal_code = 'vademecum'
ON CONFLICT (code_system_id, version) DO NOTHING;

-- -----------------------------------------------------------------------------
-- 3) Conceptos (un concepto por medicamento; code = ATC, display = genérico EN)
-- -----------------------------------------------------------------------------
INSERT INTO terminology.catalog_concepts
  (id, code_system_version_id, code, display, definition,
   abstract, selectable, state_concept_id, created_at, updated_at, row_version)
SELECT md5('mantra:vademecum:concept:' || v.code)::uuid,
       csv.id, v.code, v.display, v.definition,
       false, true, NULL, now(), now(), 1
FROM (VALUES
  ('J01XA01', 'Vancomycin',   'Glycopeptide antibiotic active against Gram-positive bacteria including MRSA.'),
  ('J01CA04', 'Amoxicillin',  'Aminopenicillin (broad-spectrum beta-lactam) antibiotic.'),
  ('N02BE01', 'Paracetamol',  'Analgesic and antipyretic agent (acetaminophen).'),
  ('M01AE01', 'Ibuprofen',    'Non-steroidal anti-inflammatory drug (NSAID).'),
  ('A10BA02', 'Metformin',    'Biguanide oral antihyperglycemic agent.'),
  ('A02BC01', 'Omeprazole',   'Proton pump inhibitor (PPI).'),
  ('C10AA05', 'Atorvastatin', 'HMG-CoA reductase inhibitor (statin).'),
  ('C08CA01', 'Amlodipine',   'Dihydropyridine calcium channel blocker.'),
  ('C09CA01', 'Losartan',     'Angiotensin II receptor blocker (ARB).'),
  ('J01FA10', 'Azithromycin', 'Macrolide antibiotic.'),
  ('J01DD04', 'Ceftriaxone',  'Third-generation cephalosporin antibiotic.'),
  ('J01MA02', 'Ciprofloxacin','Fluoroquinolone antibiotic.'),
  ('J01GB03', 'Gentamicin',   'Aminoglycoside antibiotic.'),
  ('C03CA01', 'Furosemide',   'Loop diuretic.'),
  ('B01AA03', 'Warfarin',     'Coumarin oral anticoagulant (vitamin K antagonist).'),
  ('B01AB05', 'Enoxaparin',   'Low-molecular-weight heparin anticoagulant.'),
  ('R03AC02', 'Salbutamol',   'Short-acting beta-2 adrenergic agonist (albuterol).')
) AS v(code, display, definition)
CROSS JOIN (
  SELECT csv2.id
  FROM terminology.code_system_versions csv2
  JOIN terminology.code_systems cs ON cs.id = csv2.code_system_id
  WHERE cs.internal_code = 'vademecum' AND csv2.version = '2026.1'
) csv
ON CONFLICT (code_system_version_id, code) DO NOTHING;

-- -----------------------------------------------------------------------------
-- 4) Designaciones: EN (preferred), ES y nombres de marca (language NULL)
-- -----------------------------------------------------------------------------
INSERT INTO terminology.concept_designations
  (id, concept_id, language_concept_id, designation_type_concept_id,
   value, preferred, created_at, updated_at, row_version)
SELECT md5('mantra:vademecum:designation:' || d.code || ':' || d.lang || ':' || d.value)::uuid,
       cc.id,
       NULLIF(d.lang_id, '')::uuid,
       NULL,
       d.value,
       d.preferred,
       now(), now(), 1
FROM (VALUES
  -- code, lang tag, language_concept_id (''=NULL for brands), value, preferred
  ('J01XA01','EN','9907bae2-1a46-5346-8d92-4d1d5ca3ec7b','Vancomycin',   true),
  ('J01XA01','ES','1e0b7669-d4d8-5c0f-9544-182a5fe60651','Vancomicina',  false),
  ('J01XA01','BRAND','','Vancocin', false),

  ('J01CA04','EN','9907bae2-1a46-5346-8d92-4d1d5ca3ec7b','Amoxicillin',  true),
  ('J01CA04','ES','1e0b7669-d4d8-5c0f-9544-182a5fe60651','Amoxicilina',  false),
  ('J01CA04','BRAND','','Amoxil', false),
  ('J01CA04','BRAND','','Trimox', false),

  ('N02BE01','EN','9907bae2-1a46-5346-8d92-4d1d5ca3ec7b','Paracetamol',  true),
  ('N02BE01','ES','1e0b7669-d4d8-5c0f-9544-182a5fe60651','Paracetamol',  false),
  ('N02BE01','BRAND','','Tylenol', false),
  ('N02BE01','BRAND','','Panadol', false),

  ('M01AE01','EN','9907bae2-1a46-5346-8d92-4d1d5ca3ec7b','Ibuprofen',    true),
  ('M01AE01','ES','1e0b7669-d4d8-5c0f-9544-182a5fe60651','Ibuprofeno',   false),
  ('M01AE01','BRAND','','Advil', false),
  ('M01AE01','BRAND','','Motrin', false),

  ('A10BA02','EN','9907bae2-1a46-5346-8d92-4d1d5ca3ec7b','Metformin',    true),
  ('A10BA02','ES','1e0b7669-d4d8-5c0f-9544-182a5fe60651','Metformina',   false),
  ('A10BA02','BRAND','','Glucophage', false),

  ('A02BC01','EN','9907bae2-1a46-5346-8d92-4d1d5ca3ec7b','Omeprazole',   true),
  ('A02BC01','ES','1e0b7669-d4d8-5c0f-9544-182a5fe60651','Omeprazol',    false),
  ('A02BC01','BRAND','','Prilosec', false),
  ('A02BC01','BRAND','','Losec', false),

  ('C10AA05','EN','9907bae2-1a46-5346-8d92-4d1d5ca3ec7b','Atorvastatin', true),
  ('C10AA05','ES','1e0b7669-d4d8-5c0f-9544-182a5fe60651','Atorvastatina',false),
  ('C10AA05','BRAND','','Lipitor', false),

  ('C08CA01','EN','9907bae2-1a46-5346-8d92-4d1d5ca3ec7b','Amlodipine',   true),
  ('C08CA01','ES','1e0b7669-d4d8-5c0f-9544-182a5fe60651','Amlodipino',   false),
  ('C08CA01','BRAND','','Norvasc', false),

  ('C09CA01','EN','9907bae2-1a46-5346-8d92-4d1d5ca3ec7b','Losartan',     true),
  ('C09CA01','ES','1e0b7669-d4d8-5c0f-9544-182a5fe60651','Losartán',     false),
  ('C09CA01','BRAND','','Cozaar', false),

  ('J01FA10','EN','9907bae2-1a46-5346-8d92-4d1d5ca3ec7b','Azithromycin', true),
  ('J01FA10','ES','1e0b7669-d4d8-5c0f-9544-182a5fe60651','Azitromicina', false),
  ('J01FA10','BRAND','','Zithromax', false),
  ('J01FA10','BRAND','','Zmax', false),

  ('J01DD04','EN','9907bae2-1a46-5346-8d92-4d1d5ca3ec7b','Ceftriaxone',  true),
  ('J01DD04','ES','1e0b7669-d4d8-5c0f-9544-182a5fe60651','Ceftriaxona',  false),
  ('J01DD04','BRAND','','Rocephin', false),

  ('J01MA02','EN','9907bae2-1a46-5346-8d92-4d1d5ca3ec7b','Ciprofloxacin',true),
  ('J01MA02','ES','1e0b7669-d4d8-5c0f-9544-182a5fe60651','Ciprofloxacino',false),
  ('J01MA02','BRAND','','Cipro', false),

  ('J01GB03','EN','9907bae2-1a46-5346-8d92-4d1d5ca3ec7b','Gentamicin',   true),
  ('J01GB03','ES','1e0b7669-d4d8-5c0f-9544-182a5fe60651','Gentamicina',  false),
  ('J01GB03','BRAND','','Garamycin', false),

  ('C03CA01','EN','9907bae2-1a46-5346-8d92-4d1d5ca3ec7b','Furosemide',   true),
  ('C03CA01','ES','1e0b7669-d4d8-5c0f-9544-182a5fe60651','Furosemida',   false),
  ('C03CA01','BRAND','','Lasix', false),

  ('B01AA03','EN','9907bae2-1a46-5346-8d92-4d1d5ca3ec7b','Warfarin',     true),
  ('B01AA03','ES','1e0b7669-d4d8-5c0f-9544-182a5fe60651','Warfarina',    false),
  ('B01AA03','BRAND','','Coumadin', false),
  ('B01AA03','BRAND','','Jantoven', false),

  ('B01AB05','EN','9907bae2-1a46-5346-8d92-4d1d5ca3ec7b','Enoxaparin',   true),
  ('B01AB05','ES','1e0b7669-d4d8-5c0f-9544-182a5fe60651','Enoxaparina',  false),
  ('B01AB05','BRAND','','Lovenox', false),
  ('B01AB05','BRAND','','Clexane', false),

  ('R03AC02','EN','9907bae2-1a46-5346-8d92-4d1d5ca3ec7b','Salbutamol',   true),
  ('R03AC02','ES','1e0b7669-d4d8-5c0f-9544-182a5fe60651','Albuterol',    false),
  ('R03AC02','BRAND','','Ventolin', false),
  ('R03AC02','BRAND','','ProAir', false)
) AS d(code, lang, lang_id, value, preferred)
JOIN terminology.catalog_concepts cc
  ON cc.code = d.code
 AND cc.code_system_version_id = (
   SELECT csv2.id FROM terminology.code_system_versions csv2
   JOIN terminology.code_systems cs ON cs.id = csv2.code_system_id
   WHERE cs.internal_code = 'vademecum' AND csv2.version = '2026.1'
 )
ON CONFLICT (id) DO NOTHING;

-- -----------------------------------------------------------------------------
-- 5) Propiedades clínicas (value_json jsonb, data_type = 'json')
-- -----------------------------------------------------------------------------
INSERT INTO terminology.concept_properties
  (id, concept_id, property_code, data_type, value_json,
   created_at, updated_at, row_version)
SELECT md5('mantra:vademecum:property:' || p.code || ':' || p.property_code)::uuid,
       cc.id, p.property_code,
       'json'::terminology.technical_data_type,
       p.value_json::jsonb,
       now(), now(), 1
FROM (VALUES
  -- ===================== VANCOMYCIN (most complete) =====================
  ('J01XA01','rxnorm_cui','"11124"'),
  ('J01XA01','snomed_code','"372735009"'),
  ('J01XA01','atc_route_variants','{"intravenous":"J01XA01","oral":"A07AA09","ophthalmic":"S01AA28"}'),
  ('J01XA01','therapeutic_class','"Glycopeptide antibiotic"'),
  ('J01XA01','dose_forms','["powder for solution for infusion","oral capsule","oral solution"]'),
  ('J01XA01','strengths','["500 mg","750 mg","1 g","1.25 g","1.5 g","1.75 g","2 g"]'),
  ('J01XA01','routes','["intravenous","oral","ophthalmic"]'),
  ('J01XA01','indications','["Serious Gram-positive infections including MRSA (IV)","Clostridioides difficile colitis (oral)"]'),
  ('J01XA01','contraindications','["Hypersensitivity to glycopeptides"]'),
  ('J01XA01','adverse_effects','["Nephrotoxicity","Ototoxicity","Red man / infusion reaction","Neutropenia"]'),
  ('J01XA01','monitoring','["Trough serum levels","Serum creatinine"]'),

  -- ===================== AMOXICILLIN =====================
  ('J01CA04','rxnorm_cui','"723"'),
  ('J01CA04','therapeutic_class','"Penicillin / aminopenicillin"'),
  ('J01CA04','dose_forms','["oral capsule","oral tablet","powder for oral suspension"]'),
  ('J01CA04','strengths','["250 mg","500 mg","875 mg"]'),
  ('J01CA04','routes','["oral"]'),
  ('J01CA04','indications','["Respiratory tract infections","Otitis media","Urinary tract infections","Helicobacter pylori eradication"]'),
  ('J01CA04','contraindications','["Hypersensitivity to penicillins"]'),
  ('J01CA04','adverse_effects','["Diarrhea","Rash","Nausea","Hypersensitivity reactions"]'),
  ('J01CA04','monitoring','["Signs of hypersensitivity","Renal function in impairment"]'),

  -- ===================== PARACETAMOL =====================
  ('N02BE01','rxnorm_cui','"161"'),
  ('N02BE01','therapeutic_class','"Analgesic / antipyretic"'),
  ('N02BE01','dose_forms','["oral tablet","oral suspension","suppository","solution for infusion"]'),
  ('N02BE01','strengths','["500 mg","650 mg","1 g"]'),
  ('N02BE01','routes','["oral","rectal","intravenous"]'),
  ('N02BE01','indications','["Mild to moderate pain","Fever"]'),
  ('N02BE01','contraindications','["Severe hepatic impairment","Hypersensitivity to paracetamol"]'),
  ('N02BE01','adverse_effects','["Hepatotoxicity in overdose","Rare skin reactions"]'),
  ('N02BE01','monitoring','["Total daily dose","Liver function in high-risk patients"]'),

  -- ===================== IBUPROFEN =====================
  ('M01AE01','rxnorm_cui','"5640"'),
  ('M01AE01','therapeutic_class','"NSAID"'),
  ('M01AE01','dose_forms','["oral tablet","oral suspension","solution for infusion"]'),
  ('M01AE01','strengths','["200 mg","400 mg","600 mg","800 mg"]'),
  ('M01AE01','routes','["oral","intravenous"]'),
  ('M01AE01','indications','["Pain","Inflammation","Fever"]'),
  ('M01AE01','contraindications','["Active GI bleeding","Severe heart failure","Third trimester of pregnancy"]'),
  ('M01AE01','adverse_effects','["GI bleeding","Renal impairment","Hypertension","Cardiovascular risk"]'),
  ('M01AE01','monitoring','["Renal function","Blood pressure","GI symptoms"]'),

  -- ===================== METFORMIN =====================
  ('A10BA02','rxnorm_cui','"6809"'),
  ('A10BA02','therapeutic_class','"Biguanide antidiabetic"'),
  ('A10BA02','dose_forms','["oral tablet","extended-release tablet"]'),
  ('A10BA02','strengths','["500 mg","850 mg","1000 mg"]'),
  ('A10BA02','routes','["oral"]'),
  ('A10BA02','indications','["Type 2 diabetes mellitus"]'),
  ('A10BA02','contraindications','["eGFR below 30 mL/min/1.73m2","Metabolic acidosis"]'),
  ('A10BA02','adverse_effects','["GI upset","Lactic acidosis (rare)","Vitamin B12 deficiency"]'),
  ('A10BA02','monitoring','["Renal function","HbA1c","Vitamin B12 (long-term)"]'),

  -- ===================== OMEPRAZOLE =====================
  ('A02BC01','rxnorm_cui','"7646"'),
  ('A02BC01','therapeutic_class','"Proton pump inhibitor"'),
  ('A02BC01','dose_forms','["delayed-release capsule","oral tablet","powder for injection"]'),
  ('A02BC01','strengths','["10 mg","20 mg","40 mg"]'),
  ('A02BC01','routes','["oral","intravenous"]'),
  ('A02BC01','indications','["GERD","Peptic ulcer disease","Zollinger-Ellison syndrome"]'),
  ('A02BC01','contraindications','["Hypersensitivity to PPIs","Concomitant rilpivirine"]'),
  ('A02BC01','adverse_effects','["Headache","Diarrhea","Hypomagnesemia","Increased fracture risk (long-term)"]'),
  ('A02BC01','monitoring','["Magnesium (long-term)","Reassess need periodically"]'),

  -- ===================== ATORVASTATIN =====================
  ('C10AA05','rxnorm_cui','"83367"'),
  ('C10AA05','therapeutic_class','"Statin (HMG-CoA reductase inhibitor)"'),
  ('C10AA05','dose_forms','["oral tablet"]'),
  ('C10AA05','strengths','["10 mg","20 mg","40 mg","80 mg"]'),
  ('C10AA05','routes','["oral"]'),
  ('C10AA05','indications','["Hypercholesterolemia","Cardiovascular risk reduction"]'),
  ('C10AA05','contraindications','["Active liver disease","Pregnancy","Breastfeeding"]'),
  ('C10AA05','adverse_effects','["Myalgia","Rhabdomyolysis (rare)","Transaminase elevation"]'),
  ('C10AA05','monitoring','["Lipid panel","Liver enzymes","Creatine kinase if symptomatic"]'),

  -- ===================== AMLODIPINE =====================
  ('C08CA01','rxnorm_cui','"17767"'),
  ('C08CA01','therapeutic_class','"Dihydropyridine calcium channel blocker"'),
  ('C08CA01','dose_forms','["oral tablet"]'),
  ('C08CA01','strengths','["2.5 mg","5 mg","10 mg"]'),
  ('C08CA01','routes','["oral"]'),
  ('C08CA01','indications','["Hypertension","Chronic stable angina"]'),
  ('C08CA01','contraindications','["Cardiogenic shock","Severe aortic stenosis"]'),
  ('C08CA01','adverse_effects','["Peripheral edema","Flushing","Headache","Dizziness"]'),
  ('C08CA01','monitoring','["Blood pressure","Edema"]'),

  -- ===================== LOSARTAN =====================
  ('C09CA01','rxnorm_cui','"52175"'),
  ('C09CA01','therapeutic_class','"Angiotensin II receptor blocker (ARB)"'),
  ('C09CA01','dose_forms','["oral tablet"]'),
  ('C09CA01','strengths','["25 mg","50 mg","100 mg"]'),
  ('C09CA01','routes','["oral"]'),
  ('C09CA01','indications','["Hypertension","Diabetic nephropathy","Heart failure"]'),
  ('C09CA01','contraindications','["Pregnancy","Bilateral renal artery stenosis","Concomitant aliskiren in diabetes"]'),
  ('C09CA01','adverse_effects','["Hyperkalemia","Hypotension","Dizziness","Renal impairment"]'),
  ('C09CA01','monitoring','["Serum potassium","Renal function","Blood pressure"]'),

  -- ===================== AZITHROMYCIN =====================
  ('J01FA10','rxnorm_cui','"18631"'),
  ('J01FA10','therapeutic_class','"Macrolide antibiotic"'),
  ('J01FA10','dose_forms','["oral tablet","powder for oral suspension","powder for injection"]'),
  ('J01FA10','strengths','["250 mg","500 mg","600 mg"]'),
  ('J01FA10','routes','["oral","intravenous"]'),
  ('J01FA10','indications','["Community-acquired pneumonia","Pharyngitis","Chlamydial infections"]'),
  ('J01FA10','contraindications','["Hypersensitivity to macrolides","History of cholestatic jaundice with azithromycin"]'),
  ('J01FA10','adverse_effects','["QT prolongation","Diarrhea","Nausea","Hepatotoxicity"]'),
  ('J01FA10','monitoring','["QT interval in at-risk patients","Liver function"]'),

  -- ===================== CEFTRIAXONE =====================
  ('J01DD04','rxnorm_cui','"2193"'),
  ('J01DD04','therapeutic_class','"Third-generation cephalosporin"'),
  ('J01DD04','dose_forms','["powder for solution for injection"]'),
  ('J01DD04','strengths','["250 mg","500 mg","1 g","2 g"]'),
  ('J01DD04','routes','["intravenous","intramuscular"]'),
  ('J01DD04','indications','["Meningitis","Community-acquired pneumonia","Gonorrhea","Sepsis"]'),
  ('J01DD04','contraindications','["Hypersensitivity to cephalosporins","Neonates with hyperbilirubinemia","Concomitant IV calcium in neonates"]'),
  ('J01DD04','adverse_effects','["Diarrhea","Rash","Biliary pseudolithiasis","Hypersensitivity"]'),
  ('J01DD04','monitoring','["Signs of hypersensitivity","Renal and hepatic function"]'),

  -- ===================== CIPROFLOXACIN =====================
  ('J01MA02','rxnorm_cui','"2551"'),
  ('J01MA02','therapeutic_class','"Fluoroquinolone antibiotic"'),
  ('J01MA02','dose_forms','["oral tablet","oral suspension","solution for infusion"]'),
  ('J01MA02','strengths','["250 mg","500 mg","750 mg"]'),
  ('J01MA02','routes','["oral","intravenous"]'),
  ('J01MA02','indications','["Urinary tract infections","Intra-abdominal infections","Bone and joint infections"]'),
  ('J01MA02','contraindications','["Hypersensitivity to fluoroquinolones","Concomitant tizanidine"]'),
  ('J01MA02','adverse_effects','["Tendon rupture","QT prolongation","CNS effects","GI upset"]'),
  ('J01MA02','monitoring','["QT interval in at-risk patients","Tendon symptoms","Blood glucose"]'),

  -- ===================== GENTAMICIN =====================
  ('J01GB03','rxnorm_cui','"4815"'),
  ('J01GB03','therapeutic_class','"Aminoglycoside antibiotic"'),
  ('J01GB03','dose_forms','["solution for injection"]'),
  ('J01GB03','strengths','["40 mg/mL","80 mg","120 mg"]'),
  ('J01GB03','routes','["intravenous","intramuscular"]'),
  ('J01GB03','indications','["Serious Gram-negative infections","Sepsis","Synergy in Gram-positive endocarditis"]'),
  ('J01GB03','contraindications','["Hypersensitivity to aminoglycosides","Myasthenia gravis"]'),
  ('J01GB03','adverse_effects','["Nephrotoxicity","Ototoxicity","Neuromuscular blockade"]'),
  ('J01GB03','monitoring','["Peak and trough levels","Serum creatinine","Audiometry if prolonged"]'),

  -- ===================== FUROSEMIDE =====================
  ('C03CA01','rxnorm_cui','"4603"'),
  ('C03CA01','therapeutic_class','"Loop diuretic"'),
  ('C03CA01','dose_forms','["oral tablet","oral solution","solution for injection"]'),
  ('C03CA01','strengths','["20 mg","40 mg","80 mg","10 mg/mL"]'),
  ('C03CA01','routes','["oral","intravenous","intramuscular"]'),
  ('C03CA01','indications','["Edema","Heart failure","Hypertension"]'),
  ('C03CA01','contraindications','["Anuria","Severe hypokalemia","Severe hyponatremia"]'),
  ('C03CA01','adverse_effects','["Hypokalemia","Dehydration","Ototoxicity","Hyperuricemia"]'),
  ('C03CA01','monitoring','["Electrolytes","Renal function","Fluid balance"]'),

  -- ===================== WARFARIN =====================
  ('B01AA03','rxnorm_cui','"11289"'),
  ('B01AA03','therapeutic_class','"Coumarin anticoagulant (vitamin K antagonist)"'),
  ('B01AA03','dose_forms','["oral tablet"]'),
  ('B01AA03','strengths','["1 mg","2 mg","2.5 mg","5 mg","10 mg"]'),
  ('B01AA03','routes','["oral"]'),
  ('B01AA03','indications','["Atrial fibrillation","Venous thromboembolism","Mechanical heart valves"]'),
  ('B01AA03','contraindications','["Active bleeding","Pregnancy","Severe hepatic disease"]'),
  ('B01AA03','adverse_effects','["Bleeding","Skin necrosis","Purple toe syndrome"]'),
  ('B01AA03','monitoring','["INR","Signs of bleeding"]'),

  -- ===================== ENOXAPARIN =====================
  ('B01AB05','rxnorm_cui','"67108"'),
  ('B01AB05','therapeutic_class','"Low-molecular-weight heparin"'),
  ('B01AB05','dose_forms','["prefilled syringe solution for injection"]'),
  ('B01AB05','strengths','["40 mg","60 mg","80 mg","100 mg"]'),
  ('B01AB05','routes','["subcutaneous","intravenous"]'),
  ('B01AB05','indications','["VTE prophylaxis","Treatment of DVT and PE","Acute coronary syndromes"]'),
  ('B01AB05','contraindications','["Active major bleeding","History of heparin-induced thrombocytopenia"]'),
  ('B01AB05','adverse_effects','["Bleeding","Thrombocytopenia","Injection site hematoma"]'),
  ('B01AB05','monitoring','["Platelet count","Anti-Xa levels in select patients","Renal function"]'),

  -- ===================== SALBUTAMOL =====================
  ('R03AC02','rxnorm_cui','"435"'),
  ('R03AC02','therapeutic_class','"Short-acting beta-2 agonist"'),
  ('R03AC02','dose_forms','["metered-dose inhaler","solution for nebulization","oral tablet"]'),
  ('R03AC02','strengths','["100 mcg/actuation","2.5 mg/2.5 mL","5 mg/mL"]'),
  ('R03AC02','routes','["inhalation","oral"]'),
  ('R03AC02','indications','["Asthma","COPD bronchospasm","Exercise-induced bronchospasm"]'),
  ('R03AC02','contraindications','["Hypersensitivity to salbutamol"]'),
  ('R03AC02','adverse_effects','["Tremor","Tachycardia","Palpitations","Hypokalemia"]'),
  ('R03AC02','monitoring','["Heart rate","Serum potassium in high doses","Symptom control"]')
) AS p(code, property_code, value_json)
JOIN terminology.catalog_concepts cc
  ON cc.code = p.code
 AND cc.code_system_version_id = (
   SELECT csv2.id FROM terminology.code_system_versions csv2
   JOIN terminology.code_systems cs ON cs.id = csv2.code_system_id
   WHERE cs.internal_code = 'vademecum' AND csv2.version = '2026.1'
 )
ON CONFLICT (id) DO NOTHING;

-- -----------------------------------------------------------------------------
-- 6) Interacciones farmacológicas
-- -----------------------------------------------------------------------------
INSERT INTO clinical_ext.drug_interactions
  (id, substance_a_concept_id, substance_b_concept_id, severity_concept_id,
   mechanism_text, management_text, evidence_level_concept_id,
   source, source_version, created_at, updated_at, row_version)
SELECT md5('mantra:vademecum:interaction:' || i.a || ':' || i.b)::uuid,
       ca.id, cb.id, i.severity_id::uuid,
       i.mechanism, i.management, NULL,
       'Mantra Vademécum', '2026.1', now(), now(), 1
FROM (VALUES
  ('B01AA03','J01MA02','75edc384-8721-57f6-b56e-f198dca56a4c',
   'Ciprofloxacin inhibits CYP1A2 and displaces warfarin, potentiating anticoagulant effect.',
   'Monitor INR closely; anticipate warfarin dose reduction.'),
  ('B01AA03','J01CA04','f1c07d34-a212-52a6-932a-8e52c0ceabf6',
   'Amoxicillin may alter gut flora that synthesize vitamin K, enhancing warfarin effect.',
   'Monitor INR during and after the antibiotic course.'),
  ('J01XA01','J01GB03','75edc384-8721-57f6-b56e-f198dca56a4c',
   'Additive nephrotoxicity and ototoxicity from concurrent glycopeptide and aminoglycoside.',
   'Avoid combination if possible; monitor renal function and drug levels; consider audiometry.'),
  ('C03CA01','J01GB03','75edc384-8721-57f6-b56e-f198dca56a4c',
   'Loop diuretic potentiates aminoglycoside oto- and nephrotoxicity.',
   'Avoid concurrent use where feasible; monitor hearing, renal function and hydration.'),
  ('B01AA03','J01FA10','f1c07d34-a212-52a6-932a-8e52c0ceabf6',
   'Azithromycin may potentiate warfarin anticoagulant effect, raising INR.',
   'Monitor INR closely during co-administration.')
) AS i(a, b, severity_id, mechanism, management)
JOIN terminology.catalog_concepts ca
  ON ca.code = i.a
 AND ca.code_system_version_id = (
   SELECT csv2.id FROM terminology.code_system_versions csv2
   JOIN terminology.code_systems cs ON cs.id = csv2.code_system_id
   WHERE cs.internal_code = 'vademecum' AND csv2.version = '2026.1'
 )
JOIN terminology.catalog_concepts cb
  ON cb.code = i.b
 AND cb.code_system_version_id = (
   SELECT csv2.id FROM terminology.code_system_versions csv2
   JOIN terminology.code_systems cs ON cs.id = csv2.code_system_id
   WHERE cs.internal_code = 'vademecum' AND csv2.version = '2026.1'
 )
ON CONFLICT (id) DO NOTHING;

COMMIT;
