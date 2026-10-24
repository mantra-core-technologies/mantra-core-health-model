
## insurance.insurance_claims
  - id
  - insurance_carrier_id  -> insurance.insurance_carriers
  - patient_coverage_id  -> insurance.patient_coverages
  - billing_provider_type_concept_id  -> terminology.catalog_concepts
  - billing_provider_entity_id
  - claim_identifier
  - status_concept_id  -> terminology.catalog_concepts
  - created_at
  - updated_at

## insurance.insurance_claim_lines
  - id
  - insurance_claim_id  -> insurance.insurance_claims
  - line_sequence
  - created_at

## billing.invoices
  - id
  - practice_id  -> practice.practices
  - invoice_number
  - patient_profile_id  -> profiles.patient_profiles
  - issue_date
  - status_concept_id  -> terminology.catalog_concepts
  - created_at
  - updated_at

## billing.invoice_lines
  - id
  - invoice_id  -> billing.invoices
  - quantity
  - unit_price
  - created_at
  - updated_at

## insurance.insurance_carriers
  - id
  - tenant_id  -> directory.tenants
  - carrier_code
  - legal_name
  - verification_status_concept_id  -> terminology.catalog_concepts
  - status_concept_id  -> terminology.catalog_concepts
  - created_at
  - updated_at

## insurance.patient_coverages
  - id
  - patient_profile_id  -> profiles.patient_profiles
  - insurance_plan_id  -> insurance.insurance_plans
  - member_identifier
  - verification_status_concept_id  -> terminology.catalog_concepts
  - status_concept_id  -> terminology.catalog_concepts
  - created_at
  - updated_at

## terminology.catalog_concepts
  - id
  - code_system_version_id  -> terminology.code_system_versions
  - code
  - display
  - created_at
  - updated_at

## practice.practices
  - id
  - tenant_id  -> directory.tenants
  - code
  - name
  - type_concept_id  -> terminology.catalog_concepts
  - admin_user_id  -> iam.users
  - status_concept_id  -> terminology.catalog_concepts
  - created_at
  - updated_at

## profiles.patient_profiles
  - profile_id  -> profiles.persons
  - patient_code
  - created_at
  - updated_at

## directory.tenants
  - id
  - code
  - tenant_type_concept_id  -> terminology.catalog_concepts
  - legal_name
  - legal_entity_type_concept_id  -> terminology.catalog_concepts
  - status_concept_id  -> terminology.catalog_concepts
  - verification_status_concept_id  -> terminology.catalog_concepts
  - created_at
  - updated_at

## insurance.insurance_plans
  - id
  - insurance_product_id  -> insurance.insurance_products
  - plan_code
  - name
  - status_concept_id  -> terminology.catalog_concepts
  - created_at
  - updated_at

## terminology.code_system_versions
  - id
  - code_system_id  -> terminology.code_systems
  - version
  - created_at
  - updated_at

## iam.users
  - id
  - status_concept_id  -> terminology.catalog_concepts
  - display_name
  - created_at
  - updated_at

## profiles.persons
  - id
  - person_status_concept_id  -> terminology.catalog_concepts
  - created_at
  - updated_at

## insurance.insurance_products
  - id
  - insurance_carrier_id  -> insurance.insurance_carriers
  - product_code
  - name
  - product_type_concept_id  -> terminology.catalog_concepts
  - status_concept_id  -> terminology.catalog_concepts
  - created_at
  - updated_at

## terminology.code_systems
  - id
  - source_id  -> terminology.terminology_sources
  - internal_code
  - name
  - canonical_url
  - created_at
  - updated_at

## terminology.terminology_sources
  - id
  - code
  - name
  - created_at
  - updated_at

TABLAS EN LA CADENA: 17
