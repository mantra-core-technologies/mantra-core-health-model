-- SALUD v4.0.10 / ALOVIDA — patch 2026-09-26_v4231_seed_insurer_accounts.sql
-- Seeder de cuentas de acceso para operadores de aseguradoras (PAYER)
-- Idempotente: ON CONFLICT DO NOTHING / UPDATE

BEGIN;

-- Cuenta para BO_ASEG_ALIANZA_VIDA_S_A: acceso@alianza.com
INSERT INTO iam.users (id, status_concept_id, display_name, time_zone, email_verified, phone_verified, created_at, updated_at, row_version)
VALUES ('2ca8c8aa-b379-573a-be22-78f3a4152fe4', '32dbed9f-cf1f-5c7a-9070-dfb937cf68a1', 'Operador Alianza Vida S.A.', 'America/La_Paz', TRUE, FALSE, NOW(), NOW(), 1)
ON CONFLICT (id) DO UPDATE SET display_name = EXCLUDED.display_name, status_concept_id = EXCLUDED.status_concept_id;

INSERT INTO iam.authentication_credentials (id, user_id, method_concept_id, external_subject, secret_hash, hash_algorithm_concept_id, state_concept_id, created_at, updated_at, row_version)
VALUES ('0f76e348-94ed-575f-8e55-1f3b5947e409', '2ca8c8aa-b379-573a-be22-78f3a4152fe4', '37da1281-cc62-5032-b598-1eb39dc46060', 'acceso@alianza.com', '$argon2id$v=19$m=65536,p=4,t=3$7yAD9OSiPXtT6NGkznwJhw$8o4wjbQHPoPyi3w11i8ZX4PfebO8077H+jOGxr2Xre8', '646c89e7-29d5-5450-a4c6-17817fe55aa9', '38a1d301-f40d-5b17-a695-5e6d605f8b19', NOW(), NOW(), 1)
ON CONFLICT (id) DO UPDATE SET secret_hash = EXCLUDED.secret_hash, state_concept_id = EXCLUDED.state_concept_id;

INSERT INTO iam.user_global_roles (id, user_id, role_concept_id, state_concept_id, created_at, updated_at, row_version)
VALUES ('abd1d3af-cc8b-5743-a2a0-97a3812bbe81', '2ca8c8aa-b379-573a-be22-78f3a4152fe4', '51f28f0b-95c2-57b1-a53b-2240c7e80731', '38a1d301-f40d-5b17-a695-5e6d605f8b19', NOW(), NOW(), 1)
ON CONFLICT (id) DO NOTHING;

INSERT INTO directory.tenant_memberships (id, user_id, tenant_id, tenant_role_concept_id, status_concept_id, access_scope_concept_id, start_date, created_at, updated_at, row_version)
SELECT '648aacde-8716-5fc3-ad08-e5f254d00b46', '2ca8c8aa-b379-573a-be22-78f3a4152fe4', c.tenant_id, '43634daf-8ee6-5e37-891b-3cf44d7a52f9', '13ca1b46-61d5-5c25-9d49-8247bcd7769c', '297d044a-a1e9-51db-8f96-68f4de6b3d62', '2026-01-01', NOW(), NOW(), 1
FROM insurance.insurance_carriers c
WHERE c.carrier_code = 'BO_ASEG_ALIANZA_VIDA_S_A'
ON CONFLICT (id) DO NOTHING;

-- Cuenta para BO_ASEG_ALIANZA_VIDA_S_A: acceso@alianzavida.com
INSERT INTO iam.users (id, status_concept_id, display_name, time_zone, email_verified, phone_verified, created_at, updated_at, row_version)
VALUES ('64aa05fa-beb5-55db-83db-864616b162a1', '32dbed9f-cf1f-5c7a-9070-dfb937cf68a1', 'Operador Alianza Vida S.A.', 'America/La_Paz', TRUE, FALSE, NOW(), NOW(), 1)
ON CONFLICT (id) DO UPDATE SET display_name = EXCLUDED.display_name, status_concept_id = EXCLUDED.status_concept_id;

INSERT INTO iam.authentication_credentials (id, user_id, method_concept_id, external_subject, secret_hash, hash_algorithm_concept_id, state_concept_id, created_at, updated_at, row_version)
VALUES ('870670dd-6df6-521a-b584-3a4f19808624', '64aa05fa-beb5-55db-83db-864616b162a1', '37da1281-cc62-5032-b598-1eb39dc46060', 'acceso@alianzavida.com', '$argon2id$v=19$m=65536,p=4,t=3$7yAD9OSiPXtT6NGkznwJhw$8o4wjbQHPoPyi3w11i8ZX4PfebO8077H+jOGxr2Xre8', '646c89e7-29d5-5450-a4c6-17817fe55aa9', '38a1d301-f40d-5b17-a695-5e6d605f8b19', NOW(), NOW(), 1)
ON CONFLICT (id) DO UPDATE SET secret_hash = EXCLUDED.secret_hash, state_concept_id = EXCLUDED.state_concept_id;

INSERT INTO iam.user_global_roles (id, user_id, role_concept_id, state_concept_id, created_at, updated_at, row_version)
VALUES ('975b01ca-811f-53d3-934a-69ded9c56820', '64aa05fa-beb5-55db-83db-864616b162a1', '51f28f0b-95c2-57b1-a53b-2240c7e80731', '38a1d301-f40d-5b17-a695-5e6d605f8b19', NOW(), NOW(), 1)
ON CONFLICT (id) DO NOTHING;

INSERT INTO directory.tenant_memberships (id, user_id, tenant_id, tenant_role_concept_id, status_concept_id, access_scope_concept_id, start_date, created_at, updated_at, row_version)
SELECT '7531efd1-a516-5294-90cb-79ba8375fd44', '64aa05fa-beb5-55db-83db-864616b162a1', c.tenant_id, '43634daf-8ee6-5e37-891b-3cf44d7a52f9', '13ca1b46-61d5-5c25-9d49-8247bcd7769c', '297d044a-a1e9-51db-8f96-68f4de6b3d62', '2026-01-01', NOW(), NOW(), 1
FROM insurance.insurance_carriers c
WHERE c.carrier_code = 'BO_ASEG_ALIANZA_VIDA_S_A'
ON CONFLICT (id) DO NOTHING;

-- Cuenta para BO_ASEG_ALIANZA_SEGUROS_S_A: acceso@alianzagenerales.com
INSERT INTO iam.users (id, status_concept_id, display_name, time_zone, email_verified, phone_verified, created_at, updated_at, row_version)
VALUES ('5f0c78c8-4b09-5017-bf83-59ff3835eab4', '32dbed9f-cf1f-5c7a-9070-dfb937cf68a1', 'Operador Alianza Seguros Patrimoniales', 'America/La_Paz', TRUE, FALSE, NOW(), NOW(), 1)
ON CONFLICT (id) DO UPDATE SET display_name = EXCLUDED.display_name, status_concept_id = EXCLUDED.status_concept_id;

INSERT INTO iam.authentication_credentials (id, user_id, method_concept_id, external_subject, secret_hash, hash_algorithm_concept_id, state_concept_id, created_at, updated_at, row_version)
VALUES ('665e6cf7-f421-5ccb-9b0a-de3a49a4d2c3', '5f0c78c8-4b09-5017-bf83-59ff3835eab4', '37da1281-cc62-5032-b598-1eb39dc46060', 'acceso@alianzagenerales.com', '$argon2id$v=19$m=65536,p=4,t=3$7yAD9OSiPXtT6NGkznwJhw$8o4wjbQHPoPyi3w11i8ZX4PfebO8077H+jOGxr2Xre8', '646c89e7-29d5-5450-a4c6-17817fe55aa9', '38a1d301-f40d-5b17-a695-5e6d605f8b19', NOW(), NOW(), 1)
ON CONFLICT (id) DO UPDATE SET secret_hash = EXCLUDED.secret_hash, state_concept_id = EXCLUDED.state_concept_id;

INSERT INTO iam.user_global_roles (id, user_id, role_concept_id, state_concept_id, created_at, updated_at, row_version)
VALUES ('3dfb3f81-0aff-58d4-9bd1-c95fd6fe7c95', '5f0c78c8-4b09-5017-bf83-59ff3835eab4', '51f28f0b-95c2-57b1-a53b-2240c7e80731', '38a1d301-f40d-5b17-a695-5e6d605f8b19', NOW(), NOW(), 1)
ON CONFLICT (id) DO NOTHING;

INSERT INTO directory.tenant_memberships (id, user_id, tenant_id, tenant_role_concept_id, status_concept_id, access_scope_concept_id, start_date, created_at, updated_at, row_version)
SELECT '843f42af-3c08-53e0-9b53-04f88667cc1c', '5f0c78c8-4b09-5017-bf83-59ff3835eab4', c.tenant_id, '43634daf-8ee6-5e37-891b-3cf44d7a52f9', '13ca1b46-61d5-5c25-9d49-8247bcd7769c', '297d044a-a1e9-51db-8f96-68f4de6b3d62', '2026-01-01', NOW(), NOW(), 1
FROM insurance.insurance_carriers c
WHERE c.carrier_code = 'BO_ASEG_ALIANZA_SEGUROS_S_A'
ON CONFLICT (id) DO NOTHING;

-- Cuenta para BO_ASEG_BISA_SEGUROS_Y_REASEGUROS_S_A: acceso@bisa.com
INSERT INTO iam.users (id, status_concept_id, display_name, time_zone, email_verified, phone_verified, created_at, updated_at, row_version)
VALUES ('b02e26fc-e6d2-5388-a137-a672286c8bf8', '32dbed9f-cf1f-5c7a-9070-dfb937cf68a1', 'Operador BISA Seguros', 'America/La_Paz', TRUE, FALSE, NOW(), NOW(), 1)
ON CONFLICT (id) DO UPDATE SET display_name = EXCLUDED.display_name, status_concept_id = EXCLUDED.status_concept_id;

INSERT INTO iam.authentication_credentials (id, user_id, method_concept_id, external_subject, secret_hash, hash_algorithm_concept_id, state_concept_id, created_at, updated_at, row_version)
VALUES ('0a4bcd67-d114-5dec-9cbf-59d86eac7639', 'b02e26fc-e6d2-5388-a137-a672286c8bf8', '37da1281-cc62-5032-b598-1eb39dc46060', 'acceso@bisa.com', '$argon2id$v=19$m=65536,p=4,t=3$7yAD9OSiPXtT6NGkznwJhw$8o4wjbQHPoPyi3w11i8ZX4PfebO8077H+jOGxr2Xre8', '646c89e7-29d5-5450-a4c6-17817fe55aa9', '38a1d301-f40d-5b17-a695-5e6d605f8b19', NOW(), NOW(), 1)
ON CONFLICT (id) DO UPDATE SET secret_hash = EXCLUDED.secret_hash, state_concept_id = EXCLUDED.state_concept_id;

INSERT INTO iam.user_global_roles (id, user_id, role_concept_id, state_concept_id, created_at, updated_at, row_version)
VALUES ('d6a8c7a7-bdf5-5cb5-a9dc-40f928800973', 'b02e26fc-e6d2-5388-a137-a672286c8bf8', '51f28f0b-95c2-57b1-a53b-2240c7e80731', '38a1d301-f40d-5b17-a695-5e6d605f8b19', NOW(), NOW(), 1)
ON CONFLICT (id) DO NOTHING;

INSERT INTO directory.tenant_memberships (id, user_id, tenant_id, tenant_role_concept_id, status_concept_id, access_scope_concept_id, start_date, created_at, updated_at, row_version)
SELECT '58b7fd13-bd2c-5c1c-980e-e8719a590f84', 'b02e26fc-e6d2-5388-a137-a672286c8bf8', c.tenant_id, '43634daf-8ee6-5e37-891b-3cf44d7a52f9', '13ca1b46-61d5-5c25-9d49-8247bcd7769c', '297d044a-a1e9-51db-8f96-68f4de6b3d62', '2026-01-01', NOW(), NOW(), 1
FROM insurance.insurance_carriers c
WHERE c.carrier_code = 'BO_ASEG_BISA_SEGUROS_Y_REASEGUROS_S_A'
ON CONFLICT (id) DO NOTHING;

-- Cuenta para BO_ASEG_BISA_SEGUROS_Y_REASEGUROS_S_A: acceso@bisaseguros.com
INSERT INTO iam.users (id, status_concept_id, display_name, time_zone, email_verified, phone_verified, created_at, updated_at, row_version)
VALUES ('51322efc-cb9c-5e57-9065-a918d9b9cb60', '32dbed9f-cf1f-5c7a-9070-dfb937cf68a1', 'Operador BISA Seguros', 'America/La_Paz', TRUE, FALSE, NOW(), NOW(), 1)
ON CONFLICT (id) DO UPDATE SET display_name = EXCLUDED.display_name, status_concept_id = EXCLUDED.status_concept_id;

INSERT INTO iam.authentication_credentials (id, user_id, method_concept_id, external_subject, secret_hash, hash_algorithm_concept_id, state_concept_id, created_at, updated_at, row_version)
VALUES ('a508e640-2e3e-54c8-8f96-c5a28776e636', '51322efc-cb9c-5e57-9065-a918d9b9cb60', '37da1281-cc62-5032-b598-1eb39dc46060', 'acceso@bisaseguros.com', '$argon2id$v=19$m=65536,p=4,t=3$7yAD9OSiPXtT6NGkznwJhw$8o4wjbQHPoPyi3w11i8ZX4PfebO8077H+jOGxr2Xre8', '646c89e7-29d5-5450-a4c6-17817fe55aa9', '38a1d301-f40d-5b17-a695-5e6d605f8b19', NOW(), NOW(), 1)
ON CONFLICT (id) DO UPDATE SET secret_hash = EXCLUDED.secret_hash, state_concept_id = EXCLUDED.state_concept_id;

INSERT INTO iam.user_global_roles (id, user_id, role_concept_id, state_concept_id, created_at, updated_at, row_version)
VALUES ('3e921421-63be-509d-a4a9-cb97f1332cb8', '51322efc-cb9c-5e57-9065-a918d9b9cb60', '51f28f0b-95c2-57b1-a53b-2240c7e80731', '38a1d301-f40d-5b17-a695-5e6d605f8b19', NOW(), NOW(), 1)
ON CONFLICT (id) DO NOTHING;

INSERT INTO directory.tenant_memberships (id, user_id, tenant_id, tenant_role_concept_id, status_concept_id, access_scope_concept_id, start_date, created_at, updated_at, row_version)
SELECT '71259d36-efb4-5161-8b12-ee65fd40f08f', '51322efc-cb9c-5e57-9065-a918d9b9cb60', c.tenant_id, '43634daf-8ee6-5e37-891b-3cf44d7a52f9', '13ca1b46-61d5-5c25-9d49-8247bcd7769c', '297d044a-a1e9-51db-8f96-68f4de6b3d62', '2026-01-01', NOW(), NOW(), 1
FROM insurance.insurance_carriers c
WHERE c.carrier_code = 'BO_ASEG_BISA_SEGUROS_Y_REASEGUROS_S_A'
ON CONFLICT (id) DO NOTHING;

-- Cuenta para BO_ASEG_CREDISEGURO_S_A_SEGUROS_PERSONALES: acceso@crediseguro.com
INSERT INTO iam.users (id, status_concept_id, display_name, time_zone, email_verified, phone_verified, created_at, updated_at, row_version)
VALUES ('01dac2c0-dff7-5c85-9131-d01e60e293df', '32dbed9f-cf1f-5c7a-9070-dfb937cf68a1', 'Operador Crediseguro Personales', 'America/La_Paz', TRUE, FALSE, NOW(), NOW(), 1)
ON CONFLICT (id) DO UPDATE SET display_name = EXCLUDED.display_name, status_concept_id = EXCLUDED.status_concept_id;

INSERT INTO iam.authentication_credentials (id, user_id, method_concept_id, external_subject, secret_hash, hash_algorithm_concept_id, state_concept_id, created_at, updated_at, row_version)
VALUES ('e14e0eeb-0c80-5847-8a91-0f6559f29f00', '01dac2c0-dff7-5c85-9131-d01e60e293df', '37da1281-cc62-5032-b598-1eb39dc46060', 'acceso@crediseguro.com', '$argon2id$v=19$m=65536,p=4,t=3$7yAD9OSiPXtT6NGkznwJhw$8o4wjbQHPoPyi3w11i8ZX4PfebO8077H+jOGxr2Xre8', '646c89e7-29d5-5450-a4c6-17817fe55aa9', '38a1d301-f40d-5b17-a695-5e6d605f8b19', NOW(), NOW(), 1)
ON CONFLICT (id) DO UPDATE SET secret_hash = EXCLUDED.secret_hash, state_concept_id = EXCLUDED.state_concept_id;

INSERT INTO iam.user_global_roles (id, user_id, role_concept_id, state_concept_id, created_at, updated_at, row_version)
VALUES ('34fb18ce-629c-57e7-8150-bca5668e5f28', '01dac2c0-dff7-5c85-9131-d01e60e293df', '51f28f0b-95c2-57b1-a53b-2240c7e80731', '38a1d301-f40d-5b17-a695-5e6d605f8b19', NOW(), NOW(), 1)
ON CONFLICT (id) DO NOTHING;

INSERT INTO directory.tenant_memberships (id, user_id, tenant_id, tenant_role_concept_id, status_concept_id, access_scope_concept_id, start_date, created_at, updated_at, row_version)
SELECT '3bc79a60-fd70-5462-a09c-42b13eaffb99', '01dac2c0-dff7-5c85-9131-d01e60e293df', c.tenant_id, '43634daf-8ee6-5e37-891b-3cf44d7a52f9', '13ca1b46-61d5-5c25-9d49-8247bcd7769c', '297d044a-a1e9-51db-8f96-68f4de6b3d62', '2026-01-01', NOW(), NOW(), 1
FROM insurance.insurance_carriers c
WHERE c.carrier_code = 'BO_ASEG_CREDISEGURO_S_A_SEGUROS_PERSONALES'
ON CONFLICT (id) DO NOTHING;

-- Cuenta para BO_ASEG_CREDISEGURO_S_A_SEGUROS_GENERALES: acceso@credisegurogenerales.com
INSERT INTO iam.users (id, status_concept_id, display_name, time_zone, email_verified, phone_verified, created_at, updated_at, row_version)
VALUES ('2c57e8dd-7909-5b60-90a7-fa982740290c', '32dbed9f-cf1f-5c7a-9070-dfb937cf68a1', 'Operador Crediseguro Generales', 'America/La_Paz', TRUE, FALSE, NOW(), NOW(), 1)
ON CONFLICT (id) DO UPDATE SET display_name = EXCLUDED.display_name, status_concept_id = EXCLUDED.status_concept_id;

INSERT INTO iam.authentication_credentials (id, user_id, method_concept_id, external_subject, secret_hash, hash_algorithm_concept_id, state_concept_id, created_at, updated_at, row_version)
VALUES ('14efc8b1-e32c-5e29-97a9-05a1417aa333', '2c57e8dd-7909-5b60-90a7-fa982740290c', '37da1281-cc62-5032-b598-1eb39dc46060', 'acceso@credisegurogenerales.com', '$argon2id$v=19$m=65536,p=4,t=3$7yAD9OSiPXtT6NGkznwJhw$8o4wjbQHPoPyi3w11i8ZX4PfebO8077H+jOGxr2Xre8', '646c89e7-29d5-5450-a4c6-17817fe55aa9', '38a1d301-f40d-5b17-a695-5e6d605f8b19', NOW(), NOW(), 1)
ON CONFLICT (id) DO UPDATE SET secret_hash = EXCLUDED.secret_hash, state_concept_id = EXCLUDED.state_concept_id;

INSERT INTO iam.user_global_roles (id, user_id, role_concept_id, state_concept_id, created_at, updated_at, row_version)
VALUES ('fcf17860-e8b9-56b9-ad4e-d3352776f634', '2c57e8dd-7909-5b60-90a7-fa982740290c', '51f28f0b-95c2-57b1-a53b-2240c7e80731', '38a1d301-f40d-5b17-a695-5e6d605f8b19', NOW(), NOW(), 1)
ON CONFLICT (id) DO NOTHING;

INSERT INTO directory.tenant_memberships (id, user_id, tenant_id, tenant_role_concept_id, status_concept_id, access_scope_concept_id, start_date, created_at, updated_at, row_version)
SELECT '012a3aab-af0a-5c3c-bb3c-f838f74d01cb', '2c57e8dd-7909-5b60-90a7-fa982740290c', c.tenant_id, '43634daf-8ee6-5e37-891b-3cf44d7a52f9', '13ca1b46-61d5-5c25-9d49-8247bcd7769c', '297d044a-a1e9-51db-8f96-68f4de6b3d62', '2026-01-01', NOW(), NOW(), 1
FROM insurance.insurance_carriers c
WHERE c.carrier_code = 'BO_ASEG_CREDISEGURO_S_A_SEGUROS_GENERALES'
ON CONFLICT (id) DO NOTHING;

-- Cuenta para BO_ASEG_FORTALEZA_SEGUROS_Y_REASEGUROS_S_A: acceso@fortaleza.com
INSERT INTO iam.users (id, status_concept_id, display_name, time_zone, email_verified, phone_verified, created_at, updated_at, row_version)
VALUES ('7930f84f-717a-59a5-a7b8-973a63b6f210', '32dbed9f-cf1f-5c7a-9070-dfb937cf68a1', 'Operador Fortaleza Seguros', 'America/La_Paz', TRUE, FALSE, NOW(), NOW(), 1)
ON CONFLICT (id) DO UPDATE SET display_name = EXCLUDED.display_name, status_concept_id = EXCLUDED.status_concept_id;

INSERT INTO iam.authentication_credentials (id, user_id, method_concept_id, external_subject, secret_hash, hash_algorithm_concept_id, state_concept_id, created_at, updated_at, row_version)
VALUES ('d04655d1-17dd-5543-a6e0-a1862905bf21', '7930f84f-717a-59a5-a7b8-973a63b6f210', '37da1281-cc62-5032-b598-1eb39dc46060', 'acceso@fortaleza.com', '$argon2id$v=19$m=65536,p=4,t=3$7yAD9OSiPXtT6NGkznwJhw$8o4wjbQHPoPyi3w11i8ZX4PfebO8077H+jOGxr2Xre8', '646c89e7-29d5-5450-a4c6-17817fe55aa9', '38a1d301-f40d-5b17-a695-5e6d605f8b19', NOW(), NOW(), 1)
ON CONFLICT (id) DO UPDATE SET secret_hash = EXCLUDED.secret_hash, state_concept_id = EXCLUDED.state_concept_id;

INSERT INTO iam.user_global_roles (id, user_id, role_concept_id, state_concept_id, created_at, updated_at, row_version)
VALUES ('4ce79bd7-2299-5b24-ac00-ac0d9e50d7ea', '7930f84f-717a-59a5-a7b8-973a63b6f210', '51f28f0b-95c2-57b1-a53b-2240c7e80731', '38a1d301-f40d-5b17-a695-5e6d605f8b19', NOW(), NOW(), 1)
ON CONFLICT (id) DO NOTHING;

INSERT INTO directory.tenant_memberships (id, user_id, tenant_id, tenant_role_concept_id, status_concept_id, access_scope_concept_id, start_date, created_at, updated_at, row_version)
SELECT 'ccb4b9ff-73f6-5eae-8972-cb760cae0cdf', '7930f84f-717a-59a5-a7b8-973a63b6f210', c.tenant_id, '43634daf-8ee6-5e37-891b-3cf44d7a52f9', '13ca1b46-61d5-5c25-9d49-8247bcd7769c', '297d044a-a1e9-51db-8f96-68f4de6b3d62', '2026-01-01', NOW(), NOW(), 1
FROM insurance.insurance_carriers c
WHERE c.carrier_code = 'BO_ASEG_FORTALEZA_SEGUROS_Y_REASEGUROS_S_A'
ON CONFLICT (id) DO NOTHING;

-- Cuenta para BO_ASEG_FORTALEZA_SEGUROS_Y_REASEGUROS_S_A: acceso@segurosfortaleza.com
INSERT INTO iam.users (id, status_concept_id, display_name, time_zone, email_verified, phone_verified, created_at, updated_at, row_version)
VALUES ('d904e373-a03f-5b18-b9f5-e399a5b3b380', '32dbed9f-cf1f-5c7a-9070-dfb937cf68a1', 'Operador Fortaleza Seguros', 'America/La_Paz', TRUE, FALSE, NOW(), NOW(), 1)
ON CONFLICT (id) DO UPDATE SET display_name = EXCLUDED.display_name, status_concept_id = EXCLUDED.status_concept_id;

INSERT INTO iam.authentication_credentials (id, user_id, method_concept_id, external_subject, secret_hash, hash_algorithm_concept_id, state_concept_id, created_at, updated_at, row_version)
VALUES ('f16f67c8-999a-5b82-a57d-e4101afa36c1', 'd904e373-a03f-5b18-b9f5-e399a5b3b380', '37da1281-cc62-5032-b598-1eb39dc46060', 'acceso@segurosfortaleza.com', '$argon2id$v=19$m=65536,p=4,t=3$7yAD9OSiPXtT6NGkznwJhw$8o4wjbQHPoPyi3w11i8ZX4PfebO8077H+jOGxr2Xre8', '646c89e7-29d5-5450-a4c6-17817fe55aa9', '38a1d301-f40d-5b17-a695-5e6d605f8b19', NOW(), NOW(), 1)
ON CONFLICT (id) DO UPDATE SET secret_hash = EXCLUDED.secret_hash, state_concept_id = EXCLUDED.state_concept_id;

INSERT INTO iam.user_global_roles (id, user_id, role_concept_id, state_concept_id, created_at, updated_at, row_version)
VALUES ('35ce5273-d6ca-57cc-a376-06a52e244b28', 'd904e373-a03f-5b18-b9f5-e399a5b3b380', '51f28f0b-95c2-57b1-a53b-2240c7e80731', '38a1d301-f40d-5b17-a695-5e6d605f8b19', NOW(), NOW(), 1)
ON CONFLICT (id) DO NOTHING;

INSERT INTO directory.tenant_memberships (id, user_id, tenant_id, tenant_role_concept_id, status_concept_id, access_scope_concept_id, start_date, created_at, updated_at, row_version)
SELECT '5eeeb332-b750-558f-b32d-d481bf6ebd73', 'd904e373-a03f-5b18-b9f5-e399a5b3b380', c.tenant_id, '43634daf-8ee6-5e37-891b-3cf44d7a52f9', '13ca1b46-61d5-5c25-9d49-8247bcd7769c', '297d044a-a1e9-51db-8f96-68f4de6b3d62', '2026-01-01', NOW(), NOW(), 1
FROM insurance.insurance_carriers c
WHERE c.carrier_code = 'BO_ASEG_FORTALEZA_SEGUROS_Y_REASEGUROS_S_A'
ON CONFLICT (id) DO NOTHING;

-- Cuenta para BO_ASEG_LA_BOLIVIANA_CIACRUZ_SEGUROS_PERSONALES_S_A: acceso@ciacruz.com
INSERT INTO iam.users (id, status_concept_id, display_name, time_zone, email_verified, phone_verified, created_at, updated_at, row_version)
VALUES ('e8413b56-9a53-505d-ba1b-0160f93ab326', '32dbed9f-cf1f-5c7a-9070-dfb937cf68a1', 'Operador La Boliviana Ciacruz Personales', 'America/La_Paz', TRUE, FALSE, NOW(), NOW(), 1)
ON CONFLICT (id) DO UPDATE SET display_name = EXCLUDED.display_name, status_concept_id = EXCLUDED.status_concept_id;

INSERT INTO iam.authentication_credentials (id, user_id, method_concept_id, external_subject, secret_hash, hash_algorithm_concept_id, state_concept_id, created_at, updated_at, row_version)
VALUES ('50c410f9-577c-5575-be50-b19ea5c4eaed', 'e8413b56-9a53-505d-ba1b-0160f93ab326', '37da1281-cc62-5032-b598-1eb39dc46060', 'acceso@ciacruz.com', '$argon2id$v=19$m=65536,p=4,t=3$7yAD9OSiPXtT6NGkznwJhw$8o4wjbQHPoPyi3w11i8ZX4PfebO8077H+jOGxr2Xre8', '646c89e7-29d5-5450-a4c6-17817fe55aa9', '38a1d301-f40d-5b17-a695-5e6d605f8b19', NOW(), NOW(), 1)
ON CONFLICT (id) DO UPDATE SET secret_hash = EXCLUDED.secret_hash, state_concept_id = EXCLUDED.state_concept_id;

INSERT INTO iam.user_global_roles (id, user_id, role_concept_id, state_concept_id, created_at, updated_at, row_version)
VALUES ('b69e5e4a-efc2-56d9-ad5b-810f95947fe0', 'e8413b56-9a53-505d-ba1b-0160f93ab326', '51f28f0b-95c2-57b1-a53b-2240c7e80731', '38a1d301-f40d-5b17-a695-5e6d605f8b19', NOW(), NOW(), 1)
ON CONFLICT (id) DO NOTHING;

INSERT INTO directory.tenant_memberships (id, user_id, tenant_id, tenant_role_concept_id, status_concept_id, access_scope_concept_id, start_date, created_at, updated_at, row_version)
SELECT '7a0fd57c-0bd4-50f0-bd93-4ae2ce757181', 'e8413b56-9a53-505d-ba1b-0160f93ab326', c.tenant_id, '43634daf-8ee6-5e37-891b-3cf44d7a52f9', '13ca1b46-61d5-5c25-9d49-8247bcd7769c', '297d044a-a1e9-51db-8f96-68f4de6b3d62', '2026-01-01', NOW(), NOW(), 1
FROM insurance.insurance_carriers c
WHERE c.carrier_code = 'BO_ASEG_LA_BOLIVIANA_CIACRUZ_SEGUROS_PERSONALES_S_A'
ON CONFLICT (id) DO NOTHING;

-- Cuenta para BO_ASEG_LA_BOLIVIANA_CIACRUZ_SEGUROS_PERSONALES_S_A: acceso@lbc.bo
INSERT INTO iam.users (id, status_concept_id, display_name, time_zone, email_verified, phone_verified, created_at, updated_at, row_version)
VALUES ('816074ed-9d6e-5533-8c90-be9620c75fa5', '32dbed9f-cf1f-5c7a-9070-dfb937cf68a1', 'Operador La Boliviana Ciacruz Personales', 'America/La_Paz', TRUE, FALSE, NOW(), NOW(), 1)
ON CONFLICT (id) DO UPDATE SET display_name = EXCLUDED.display_name, status_concept_id = EXCLUDED.status_concept_id;

INSERT INTO iam.authentication_credentials (id, user_id, method_concept_id, external_subject, secret_hash, hash_algorithm_concept_id, state_concept_id, created_at, updated_at, row_version)
VALUES ('8ee1e217-4a6a-5816-a13f-9eebe8e16b8b', '816074ed-9d6e-5533-8c90-be9620c75fa5', '37da1281-cc62-5032-b598-1eb39dc46060', 'acceso@lbc.bo', '$argon2id$v=19$m=65536,p=4,t=3$7yAD9OSiPXtT6NGkznwJhw$8o4wjbQHPoPyi3w11i8ZX4PfebO8077H+jOGxr2Xre8', '646c89e7-29d5-5450-a4c6-17817fe55aa9', '38a1d301-f40d-5b17-a695-5e6d605f8b19', NOW(), NOW(), 1)
ON CONFLICT (id) DO UPDATE SET secret_hash = EXCLUDED.secret_hash, state_concept_id = EXCLUDED.state_concept_id;

INSERT INTO iam.user_global_roles (id, user_id, role_concept_id, state_concept_id, created_at, updated_at, row_version)
VALUES ('11470532-fc3f-5e52-a6bc-7fd34b888355', '816074ed-9d6e-5533-8c90-be9620c75fa5', '51f28f0b-95c2-57b1-a53b-2240c7e80731', '38a1d301-f40d-5b17-a695-5e6d605f8b19', NOW(), NOW(), 1)
ON CONFLICT (id) DO NOTHING;

INSERT INTO directory.tenant_memberships (id, user_id, tenant_id, tenant_role_concept_id, status_concept_id, access_scope_concept_id, start_date, created_at, updated_at, row_version)
SELECT 'ad27edfc-7699-5f4d-a19d-f1bd6fc62396', '816074ed-9d6e-5533-8c90-be9620c75fa5', c.tenant_id, '43634daf-8ee6-5e37-891b-3cf44d7a52f9', '13ca1b46-61d5-5c25-9d49-8247bcd7769c', '297d044a-a1e9-51db-8f96-68f4de6b3d62', '2026-01-01', NOW(), NOW(), 1
FROM insurance.insurance_carriers c
WHERE c.carrier_code = 'BO_ASEG_LA_BOLIVIANA_CIACRUZ_SEGUROS_PERSONALES_S_A'
ON CONFLICT (id) DO NOTHING;

-- Cuenta para BO_ASEG_LA_BOLIVIANA_CIACRUZ_DE_SEGUROS_Y_REASEGUROS: acceso@ciacruzgenerales.com
INSERT INTO iam.users (id, status_concept_id, display_name, time_zone, email_verified, phone_verified, created_at, updated_at, row_version)
VALUES ('3a4f004f-c6f9-584a-9ad3-ff9a65d0c130', '32dbed9f-cf1f-5c7a-9070-dfb937cf68a1', 'Operador La Boliviana Ciacruz Generales', 'America/La_Paz', TRUE, FALSE, NOW(), NOW(), 1)
ON CONFLICT (id) DO UPDATE SET display_name = EXCLUDED.display_name, status_concept_id = EXCLUDED.status_concept_id;

INSERT INTO iam.authentication_credentials (id, user_id, method_concept_id, external_subject, secret_hash, hash_algorithm_concept_id, state_concept_id, created_at, updated_at, row_version)
VALUES ('23242359-ebfa-5e55-88a9-9c6b39e0169c', '3a4f004f-c6f9-584a-9ad3-ff9a65d0c130', '37da1281-cc62-5032-b598-1eb39dc46060', 'acceso@ciacruzgenerales.com', '$argon2id$v=19$m=65536,p=4,t=3$7yAD9OSiPXtT6NGkznwJhw$8o4wjbQHPoPyi3w11i8ZX4PfebO8077H+jOGxr2Xre8', '646c89e7-29d5-5450-a4c6-17817fe55aa9', '38a1d301-f40d-5b17-a695-5e6d605f8b19', NOW(), NOW(), 1)
ON CONFLICT (id) DO UPDATE SET secret_hash = EXCLUDED.secret_hash, state_concept_id = EXCLUDED.state_concept_id;

INSERT INTO iam.user_global_roles (id, user_id, role_concept_id, state_concept_id, created_at, updated_at, row_version)
VALUES ('730f41eb-36b2-555b-9053-10c769c39b30', '3a4f004f-c6f9-584a-9ad3-ff9a65d0c130', '51f28f0b-95c2-57b1-a53b-2240c7e80731', '38a1d301-f40d-5b17-a695-5e6d605f8b19', NOW(), NOW(), 1)
ON CONFLICT (id) DO NOTHING;

INSERT INTO directory.tenant_memberships (id, user_id, tenant_id, tenant_role_concept_id, status_concept_id, access_scope_concept_id, start_date, created_at, updated_at, row_version)
SELECT '2d79503d-6c49-553f-8125-d90fe9b02c5a', '3a4f004f-c6f9-584a-9ad3-ff9a65d0c130', c.tenant_id, '43634daf-8ee6-5e37-891b-3cf44d7a52f9', '13ca1b46-61d5-5c25-9d49-8247bcd7769c', '297d044a-a1e9-51db-8f96-68f4de6b3d62', '2026-01-01', NOW(), NOW(), 1
FROM insurance.insurance_carriers c
WHERE c.carrier_code = 'BO_ASEG_LA_BOLIVIANA_CIACRUZ_DE_SEGUROS_Y_REASEGUROS'
ON CONFLICT (id) DO NOTHING;

-- Cuenta para BO_ASEG_LA_VITALICIA_SEGUROS_Y_REASEGUROS_DE_VIDA_S_: acceso@lavitalicia.com
INSERT INTO iam.users (id, status_concept_id, display_name, time_zone, email_verified, phone_verified, created_at, updated_at, row_version)
VALUES ('dae75ab0-5db1-58ed-a519-2b8a7ea8152d', '32dbed9f-cf1f-5c7a-9070-dfb937cf68a1', 'Operador La Vitalicia Seguros', 'America/La_Paz', TRUE, FALSE, NOW(), NOW(), 1)
ON CONFLICT (id) DO UPDATE SET display_name = EXCLUDED.display_name, status_concept_id = EXCLUDED.status_concept_id;

INSERT INTO iam.authentication_credentials (id, user_id, method_concept_id, external_subject, secret_hash, hash_algorithm_concept_id, state_concept_id, created_at, updated_at, row_version)
VALUES ('2dafcb89-7046-5a2b-9545-d21db0f52230', 'dae75ab0-5db1-58ed-a519-2b8a7ea8152d', '37da1281-cc62-5032-b598-1eb39dc46060', 'acceso@lavitalicia.com', '$argon2id$v=19$m=65536,p=4,t=3$7yAD9OSiPXtT6NGkznwJhw$8o4wjbQHPoPyi3w11i8ZX4PfebO8077H+jOGxr2Xre8', '646c89e7-29d5-5450-a4c6-17817fe55aa9', '38a1d301-f40d-5b17-a695-5e6d605f8b19', NOW(), NOW(), 1)
ON CONFLICT (id) DO UPDATE SET secret_hash = EXCLUDED.secret_hash, state_concept_id = EXCLUDED.state_concept_id;

INSERT INTO iam.user_global_roles (id, user_id, role_concept_id, state_concept_id, created_at, updated_at, row_version)
VALUES ('d057f748-8044-594b-9341-cb38fa63ff38', 'dae75ab0-5db1-58ed-a519-2b8a7ea8152d', '51f28f0b-95c2-57b1-a53b-2240c7e80731', '38a1d301-f40d-5b17-a695-5e6d605f8b19', NOW(), NOW(), 1)
ON CONFLICT (id) DO NOTHING;

INSERT INTO directory.tenant_memberships (id, user_id, tenant_id, tenant_role_concept_id, status_concept_id, access_scope_concept_id, start_date, created_at, updated_at, row_version)
SELECT '9e631549-14f4-5715-a5d2-4ba650f3556d', 'dae75ab0-5db1-58ed-a519-2b8a7ea8152d', c.tenant_id, '43634daf-8ee6-5e37-891b-3cf44d7a52f9', '13ca1b46-61d5-5c25-9d49-8247bcd7769c', '297d044a-a1e9-51db-8f96-68f4de6b3d62', '2026-01-01', NOW(), NOW(), 1
FROM insurance.insurance_carriers c
WHERE c.carrier_code = 'BO_ASEG_LA_VITALICIA_SEGUROS_Y_REASEGUROS_DE_VIDA_S_'
ON CONFLICT (id) DO NOTHING;

-- Cuenta para BO_ASEG_MERCANTIL_SANTA_CRUZ_SEGUROS_Y_REASEGUROS_GE: acceso@mercantil.com
INSERT INTO iam.users (id, status_concept_id, display_name, time_zone, email_verified, phone_verified, created_at, updated_at, row_version)
VALUES ('3031eb53-d8c0-546f-82c5-332d1d33e831', '32dbed9f-cf1f-5c7a-9070-dfb937cf68a1', 'Operador Mercantil Santa Cruz Seguros', 'America/La_Paz', TRUE, FALSE, NOW(), NOW(), 1)
ON CONFLICT (id) DO UPDATE SET display_name = EXCLUDED.display_name, status_concept_id = EXCLUDED.status_concept_id;

INSERT INTO iam.authentication_credentials (id, user_id, method_concept_id, external_subject, secret_hash, hash_algorithm_concept_id, state_concept_id, created_at, updated_at, row_version)
VALUES ('53283aaf-7273-54f5-9d7d-669f2c10d508', '3031eb53-d8c0-546f-82c5-332d1d33e831', '37da1281-cc62-5032-b598-1eb39dc46060', 'acceso@mercantil.com', '$argon2id$v=19$m=65536,p=4,t=3$7yAD9OSiPXtT6NGkznwJhw$8o4wjbQHPoPyi3w11i8ZX4PfebO8077H+jOGxr2Xre8', '646c89e7-29d5-5450-a4c6-17817fe55aa9', '38a1d301-f40d-5b17-a695-5e6d605f8b19', NOW(), NOW(), 1)
ON CONFLICT (id) DO UPDATE SET secret_hash = EXCLUDED.secret_hash, state_concept_id = EXCLUDED.state_concept_id;

INSERT INTO iam.user_global_roles (id, user_id, role_concept_id, state_concept_id, created_at, updated_at, row_version)
VALUES ('38e61803-e66c-5e32-8e91-1dd1b4230818', '3031eb53-d8c0-546f-82c5-332d1d33e831', '51f28f0b-95c2-57b1-a53b-2240c7e80731', '38a1d301-f40d-5b17-a695-5e6d605f8b19', NOW(), NOW(), 1)
ON CONFLICT (id) DO NOTHING;

INSERT INTO directory.tenant_memberships (id, user_id, tenant_id, tenant_role_concept_id, status_concept_id, access_scope_concept_id, start_date, created_at, updated_at, row_version)
SELECT '1fdf4943-4c3d-5794-b9d2-c4b91418afc5', '3031eb53-d8c0-546f-82c5-332d1d33e831', c.tenant_id, '43634daf-8ee6-5e37-891b-3cf44d7a52f9', '13ca1b46-61d5-5c25-9d49-8247bcd7769c', '297d044a-a1e9-51db-8f96-68f4de6b3d62', '2026-01-01', NOW(), NOW(), 1
FROM insurance.insurance_carriers c
WHERE c.carrier_code = 'BO_ASEG_MERCANTIL_SANTA_CRUZ_SEGUROS_Y_REASEGUROS_GE'
ON CONFLICT (id) DO NOTHING;

-- Cuenta para BO_ASEG_MERCANTIL_SANTA_CRUZ_SEGUROS_Y_REASEGUROS_GE: acceso@msc.com
INSERT INTO iam.users (id, status_concept_id, display_name, time_zone, email_verified, phone_verified, created_at, updated_at, row_version)
VALUES ('f1e62a3e-f4bf-50c3-87de-08be812d4dd3', '32dbed9f-cf1f-5c7a-9070-dfb937cf68a1', 'Operador Mercantil Santa Cruz Seguros', 'America/La_Paz', TRUE, FALSE, NOW(), NOW(), 1)
ON CONFLICT (id) DO UPDATE SET display_name = EXCLUDED.display_name, status_concept_id = EXCLUDED.status_concept_id;

INSERT INTO iam.authentication_credentials (id, user_id, method_concept_id, external_subject, secret_hash, hash_algorithm_concept_id, state_concept_id, created_at, updated_at, row_version)
VALUES ('aed9f4e6-c743-5741-8747-998091ff5509', 'f1e62a3e-f4bf-50c3-87de-08be812d4dd3', '37da1281-cc62-5032-b598-1eb39dc46060', 'acceso@msc.com', '$argon2id$v=19$m=65536,p=4,t=3$7yAD9OSiPXtT6NGkznwJhw$8o4wjbQHPoPyi3w11i8ZX4PfebO8077H+jOGxr2Xre8', '646c89e7-29d5-5450-a4c6-17817fe55aa9', '38a1d301-f40d-5b17-a695-5e6d605f8b19', NOW(), NOW(), 1)
ON CONFLICT (id) DO UPDATE SET secret_hash = EXCLUDED.secret_hash, state_concept_id = EXCLUDED.state_concept_id;

INSERT INTO iam.user_global_roles (id, user_id, role_concept_id, state_concept_id, created_at, updated_at, row_version)
VALUES ('9d637d0d-e847-5f2d-95eb-3ba62b79edf6', 'f1e62a3e-f4bf-50c3-87de-08be812d4dd3', '51f28f0b-95c2-57b1-a53b-2240c7e80731', '38a1d301-f40d-5b17-a695-5e6d605f8b19', NOW(), NOW(), 1)
ON CONFLICT (id) DO NOTHING;

INSERT INTO directory.tenant_memberships (id, user_id, tenant_id, tenant_role_concept_id, status_concept_id, access_scope_concept_id, start_date, created_at, updated_at, row_version)
SELECT '36adccbe-dacf-5550-8504-a2423d0b6b20', 'f1e62a3e-f4bf-50c3-87de-08be812d4dd3', c.tenant_id, '43634daf-8ee6-5e37-891b-3cf44d7a52f9', '13ca1b46-61d5-5c25-9d49-8247bcd7769c', '297d044a-a1e9-51db-8f96-68f4de6b3d62', '2026-01-01', NOW(), NOW(), 1
FROM insurance.insurance_carriers c
WHERE c.carrier_code = 'BO_ASEG_MERCANTIL_SANTA_CRUZ_SEGUROS_Y_REASEGUROS_GE'
ON CONFLICT (id) DO NOTHING;

-- Cuenta para BO_ASEG_NACIONAL_SEGUROS_VIDA_Y_SALUD_S_A: acceso@nacional.com
INSERT INTO iam.users (id, status_concept_id, display_name, time_zone, email_verified, phone_verified, created_at, updated_at, row_version)
VALUES ('1327eb3e-8d5c-525b-8713-6c782bb67344', '32dbed9f-cf1f-5c7a-9070-dfb937cf68a1', 'Operador Nacional Seguros Vida y Salud', 'America/La_Paz', TRUE, FALSE, NOW(), NOW(), 1)
ON CONFLICT (id) DO UPDATE SET display_name = EXCLUDED.display_name, status_concept_id = EXCLUDED.status_concept_id;

INSERT INTO iam.authentication_credentials (id, user_id, method_concept_id, external_subject, secret_hash, hash_algorithm_concept_id, state_concept_id, created_at, updated_at, row_version)
VALUES ('a17022fc-9b78-58be-8ff7-042e88fa6e9d', '1327eb3e-8d5c-525b-8713-6c782bb67344', '37da1281-cc62-5032-b598-1eb39dc46060', 'acceso@nacional.com', '$argon2id$v=19$m=65536,p=4,t=3$7yAD9OSiPXtT6NGkznwJhw$8o4wjbQHPoPyi3w11i8ZX4PfebO8077H+jOGxr2Xre8', '646c89e7-29d5-5450-a4c6-17817fe55aa9', '38a1d301-f40d-5b17-a695-5e6d605f8b19', NOW(), NOW(), 1)
ON CONFLICT (id) DO UPDATE SET secret_hash = EXCLUDED.secret_hash, state_concept_id = EXCLUDED.state_concept_id;

INSERT INTO iam.user_global_roles (id, user_id, role_concept_id, state_concept_id, created_at, updated_at, row_version)
VALUES ('82a12314-57d2-55c2-962c-f2fa8c92747b', '1327eb3e-8d5c-525b-8713-6c782bb67344', '51f28f0b-95c2-57b1-a53b-2240c7e80731', '38a1d301-f40d-5b17-a695-5e6d605f8b19', NOW(), NOW(), 1)
ON CONFLICT (id) DO NOTHING;

INSERT INTO directory.tenant_memberships (id, user_id, tenant_id, tenant_role_concept_id, status_concept_id, access_scope_concept_id, start_date, created_at, updated_at, row_version)
SELECT '2887db66-970b-5949-8d3a-6edfd98b2301', '1327eb3e-8d5c-525b-8713-6c782bb67344', c.tenant_id, '43634daf-8ee6-5e37-891b-3cf44d7a52f9', '13ca1b46-61d5-5c25-9d49-8247bcd7769c', '297d044a-a1e9-51db-8f96-68f4de6b3d62', '2026-01-01', NOW(), NOW(), 1
FROM insurance.insurance_carriers c
WHERE c.carrier_code = 'BO_ASEG_NACIONAL_SEGUROS_VIDA_Y_SALUD_S_A'
ON CONFLICT (id) DO NOTHING;

-- Cuenta para BO_ASEG_NACIONAL_SEGUROS_VIDA_Y_SALUD_S_A: acceso@nacionalsalud.com
INSERT INTO iam.users (id, status_concept_id, display_name, time_zone, email_verified, phone_verified, created_at, updated_at, row_version)
VALUES ('0127ce63-611c-517b-b35a-324a9bf90d3a', '32dbed9f-cf1f-5c7a-9070-dfb937cf68a1', 'Operador Nacional Seguros Vida y Salud', 'America/La_Paz', TRUE, FALSE, NOW(), NOW(), 1)
ON CONFLICT (id) DO UPDATE SET display_name = EXCLUDED.display_name, status_concept_id = EXCLUDED.status_concept_id;

INSERT INTO iam.authentication_credentials (id, user_id, method_concept_id, external_subject, secret_hash, hash_algorithm_concept_id, state_concept_id, created_at, updated_at, row_version)
VALUES ('9f94fd5d-2922-556e-8b65-70372f0cc120', '0127ce63-611c-517b-b35a-324a9bf90d3a', '37da1281-cc62-5032-b598-1eb39dc46060', 'acceso@nacionalsalud.com', '$argon2id$v=19$m=65536,p=4,t=3$7yAD9OSiPXtT6NGkznwJhw$8o4wjbQHPoPyi3w11i8ZX4PfebO8077H+jOGxr2Xre8', '646c89e7-29d5-5450-a4c6-17817fe55aa9', '38a1d301-f40d-5b17-a695-5e6d605f8b19', NOW(), NOW(), 1)
ON CONFLICT (id) DO UPDATE SET secret_hash = EXCLUDED.secret_hash, state_concept_id = EXCLUDED.state_concept_id;

INSERT INTO iam.user_global_roles (id, user_id, role_concept_id, state_concept_id, created_at, updated_at, row_version)
VALUES ('bda1bc99-75d1-5e72-a78d-c7d40fe19250', '0127ce63-611c-517b-b35a-324a9bf90d3a', '51f28f0b-95c2-57b1-a53b-2240c7e80731', '38a1d301-f40d-5b17-a695-5e6d605f8b19', NOW(), NOW(), 1)
ON CONFLICT (id) DO NOTHING;

INSERT INTO directory.tenant_memberships (id, user_id, tenant_id, tenant_role_concept_id, status_concept_id, access_scope_concept_id, start_date, created_at, updated_at, row_version)
SELECT '258272f0-4954-590a-bd16-e12a5756f110', '0127ce63-611c-517b-b35a-324a9bf90d3a', c.tenant_id, '43634daf-8ee6-5e37-891b-3cf44d7a52f9', '13ca1b46-61d5-5c25-9d49-8247bcd7769c', '297d044a-a1e9-51db-8f96-68f4de6b3d62', '2026-01-01', NOW(), NOW(), 1
FROM insurance.insurance_carriers c
WHERE c.carrier_code = 'BO_ASEG_NACIONAL_SEGUROS_VIDA_Y_SALUD_S_A'
ON CONFLICT (id) DO NOTHING;

-- Cuenta para BO_ASEG_NACIONAL_SEGUROS_PATRIMONIALES_Y_FIANZAS_S_A: acceso@nacionalpatrimoniales.com
INSERT INTO iam.users (id, status_concept_id, display_name, time_zone, email_verified, phone_verified, created_at, updated_at, row_version)
VALUES ('9fbbdeb0-323b-5173-8294-eae7b57b974b', '32dbed9f-cf1f-5c7a-9070-dfb937cf68a1', 'Operador Nacional Seguros Patrimoniales', 'America/La_Paz', TRUE, FALSE, NOW(), NOW(), 1)
ON CONFLICT (id) DO UPDATE SET display_name = EXCLUDED.display_name, status_concept_id = EXCLUDED.status_concept_id;

INSERT INTO iam.authentication_credentials (id, user_id, method_concept_id, external_subject, secret_hash, hash_algorithm_concept_id, state_concept_id, created_at, updated_at, row_version)
VALUES ('1d9ef6ce-016a-54e8-9e0a-bd972d87c2b7', '9fbbdeb0-323b-5173-8294-eae7b57b974b', '37da1281-cc62-5032-b598-1eb39dc46060', 'acceso@nacionalpatrimoniales.com', '$argon2id$v=19$m=65536,p=4,t=3$7yAD9OSiPXtT6NGkznwJhw$8o4wjbQHPoPyi3w11i8ZX4PfebO8077H+jOGxr2Xre8', '646c89e7-29d5-5450-a4c6-17817fe55aa9', '38a1d301-f40d-5b17-a695-5e6d605f8b19', NOW(), NOW(), 1)
ON CONFLICT (id) DO UPDATE SET secret_hash = EXCLUDED.secret_hash, state_concept_id = EXCLUDED.state_concept_id;

INSERT INTO iam.user_global_roles (id, user_id, role_concept_id, state_concept_id, created_at, updated_at, row_version)
VALUES ('1d839c54-7a0f-58e2-a743-8cf87fb480a5', '9fbbdeb0-323b-5173-8294-eae7b57b974b', '51f28f0b-95c2-57b1-a53b-2240c7e80731', '38a1d301-f40d-5b17-a695-5e6d605f8b19', NOW(), NOW(), 1)
ON CONFLICT (id) DO NOTHING;

INSERT INTO directory.tenant_memberships (id, user_id, tenant_id, tenant_role_concept_id, status_concept_id, access_scope_concept_id, start_date, created_at, updated_at, row_version)
SELECT 'd1561b23-5c9b-5bc4-aaf3-d9c12dad7d68', '9fbbdeb0-323b-5173-8294-eae7b57b974b', c.tenant_id, '43634daf-8ee6-5e37-891b-3cf44d7a52f9', '13ca1b46-61d5-5c25-9d49-8247bcd7769c', '297d044a-a1e9-51db-8f96-68f4de6b3d62', '2026-01-01', NOW(), NOW(), 1
FROM insurance.insurance_carriers c
WHERE c.carrier_code = 'BO_ASEG_NACIONAL_SEGUROS_PATRIMONIALES_Y_FIANZAS_S_A'
ON CONFLICT (id) DO NOTHING;

-- Cuenta para BO_ASEG_SANTA_CRUZ_VIDA_Y_SALUD_S_A: acceso@santacruz.com
INSERT INTO iam.users (id, status_concept_id, display_name, time_zone, email_verified, phone_verified, created_at, updated_at, row_version)
VALUES ('b55bcbcc-43dc-5f4c-a3ce-d081dcfd26bd', '32dbed9f-cf1f-5c7a-9070-dfb937cf68a1', 'Operador Santa Cruz Vida y Salud', 'America/La_Paz', TRUE, FALSE, NOW(), NOW(), 1)
ON CONFLICT (id) DO UPDATE SET display_name = EXCLUDED.display_name, status_concept_id = EXCLUDED.status_concept_id;

INSERT INTO iam.authentication_credentials (id, user_id, method_concept_id, external_subject, secret_hash, hash_algorithm_concept_id, state_concept_id, created_at, updated_at, row_version)
VALUES ('eb827456-6035-5f56-9163-34670ba48f8c', 'b55bcbcc-43dc-5f4c-a3ce-d081dcfd26bd', '37da1281-cc62-5032-b598-1eb39dc46060', 'acceso@santacruz.com', '$argon2id$v=19$m=65536,p=4,t=3$7yAD9OSiPXtT6NGkznwJhw$8o4wjbQHPoPyi3w11i8ZX4PfebO8077H+jOGxr2Xre8', '646c89e7-29d5-5450-a4c6-17817fe55aa9', '38a1d301-f40d-5b17-a695-5e6d605f8b19', NOW(), NOW(), 1)
ON CONFLICT (id) DO UPDATE SET secret_hash = EXCLUDED.secret_hash, state_concept_id = EXCLUDED.state_concept_id;

INSERT INTO iam.user_global_roles (id, user_id, role_concept_id, state_concept_id, created_at, updated_at, row_version)
VALUES ('a2dea806-6851-5950-8a0f-71aa73c39cf8', 'b55bcbcc-43dc-5f4c-a3ce-d081dcfd26bd', '51f28f0b-95c2-57b1-a53b-2240c7e80731', '38a1d301-f40d-5b17-a695-5e6d605f8b19', NOW(), NOW(), 1)
ON CONFLICT (id) DO NOTHING;

INSERT INTO directory.tenant_memberships (id, user_id, tenant_id, tenant_role_concept_id, status_concept_id, access_scope_concept_id, start_date, created_at, updated_at, row_version)
SELECT 'c2e6cd93-afb2-53e9-8756-58936479cda9', 'b55bcbcc-43dc-5f4c-a3ce-d081dcfd26bd', c.tenant_id, '43634daf-8ee6-5e37-891b-3cf44d7a52f9', '13ca1b46-61d5-5c25-9d49-8247bcd7769c', '297d044a-a1e9-51db-8f96-68f4de6b3d62', '2026-01-01', NOW(), NOW(), 1
FROM insurance.insurance_carriers c
WHERE c.carrier_code = 'BO_ASEG_SANTA_CRUZ_VIDA_Y_SALUD_S_A'
ON CONFLICT (id) DO NOTHING;

-- Cuenta para BO_ASEG_SANTA_CRUZ_VIDA_Y_SALUD_S_A: consultasSCVS@santacruzfg.com
INSERT INTO iam.users (id, status_concept_id, display_name, time_zone, email_verified, phone_verified, created_at, updated_at, row_version)
VALUES ('eceb6865-be41-50ee-b6cd-e0df13ba33fa', '32dbed9f-cf1f-5c7a-9070-dfb937cf68a1', 'Operador Santa Cruz Vida y Salud', 'America/La_Paz', TRUE, FALSE, NOW(), NOW(), 1)
ON CONFLICT (id) DO UPDATE SET display_name = EXCLUDED.display_name, status_concept_id = EXCLUDED.status_concept_id;

INSERT INTO iam.authentication_credentials (id, user_id, method_concept_id, external_subject, secret_hash, hash_algorithm_concept_id, state_concept_id, created_at, updated_at, row_version)
VALUES ('47a01d6c-5383-5e95-8ca8-9884c8140623', 'eceb6865-be41-50ee-b6cd-e0df13ba33fa', '37da1281-cc62-5032-b598-1eb39dc46060', 'consultasSCVS@santacruzfg.com', '$argon2id$v=19$m=65536,p=4,t=3$7yAD9OSiPXtT6NGkznwJhw$8o4wjbQHPoPyi3w11i8ZX4PfebO8077H+jOGxr2Xre8', '646c89e7-29d5-5450-a4c6-17817fe55aa9', '38a1d301-f40d-5b17-a695-5e6d605f8b19', NOW(), NOW(), 1)
ON CONFLICT (id) DO UPDATE SET secret_hash = EXCLUDED.secret_hash, state_concept_id = EXCLUDED.state_concept_id;

INSERT INTO iam.user_global_roles (id, user_id, role_concept_id, state_concept_id, created_at, updated_at, row_version)
VALUES ('59011b93-4aba-5e9c-99d5-7f7379aa2307', 'eceb6865-be41-50ee-b6cd-e0df13ba33fa', '51f28f0b-95c2-57b1-a53b-2240c7e80731', '38a1d301-f40d-5b17-a695-5e6d605f8b19', NOW(), NOW(), 1)
ON CONFLICT (id) DO NOTHING;

INSERT INTO directory.tenant_memberships (id, user_id, tenant_id, tenant_role_concept_id, status_concept_id, access_scope_concept_id, start_date, created_at, updated_at, row_version)
SELECT '614e759d-43f6-5c39-81d4-530c0c7e72d8', 'eceb6865-be41-50ee-b6cd-e0df13ba33fa', c.tenant_id, '43634daf-8ee6-5e37-891b-3cf44d7a52f9', '13ca1b46-61d5-5c25-9d49-8247bcd7769c', '297d044a-a1e9-51db-8f96-68f4de6b3d62', '2026-01-01', NOW(), NOW(), 1
FROM insurance.insurance_carriers c
WHERE c.carrier_code = 'BO_ASEG_SANTA_CRUZ_VIDA_Y_SALUD_S_A'
ON CONFLICT (id) DO NOTHING;

-- Cuenta para BO_ASEG_SEGUROS_ILLIMANI_S_A: acceso@illimani.com
INSERT INTO iam.users (id, status_concept_id, display_name, time_zone, email_verified, phone_verified, created_at, updated_at, row_version)
VALUES ('11203252-99d5-5eed-b998-3067cc6cb417', '32dbed9f-cf1f-5c7a-9070-dfb937cf68a1', 'Operador Seguros Illimani', 'America/La_Paz', TRUE, FALSE, NOW(), NOW(), 1)
ON CONFLICT (id) DO UPDATE SET display_name = EXCLUDED.display_name, status_concept_id = EXCLUDED.status_concept_id;

INSERT INTO iam.authentication_credentials (id, user_id, method_concept_id, external_subject, secret_hash, hash_algorithm_concept_id, state_concept_id, created_at, updated_at, row_version)
VALUES ('3891312f-a3ba-5748-8b44-628419482339', '11203252-99d5-5eed-b998-3067cc6cb417', '37da1281-cc62-5032-b598-1eb39dc46060', 'acceso@illimani.com', '$argon2id$v=19$m=65536,p=4,t=3$7yAD9OSiPXtT6NGkznwJhw$8o4wjbQHPoPyi3w11i8ZX4PfebO8077H+jOGxr2Xre8', '646c89e7-29d5-5450-a4c6-17817fe55aa9', '38a1d301-f40d-5b17-a695-5e6d605f8b19', NOW(), NOW(), 1)
ON CONFLICT (id) DO UPDATE SET secret_hash = EXCLUDED.secret_hash, state_concept_id = EXCLUDED.state_concept_id;

INSERT INTO iam.user_global_roles (id, user_id, role_concept_id, state_concept_id, created_at, updated_at, row_version)
VALUES ('a8f56b15-e982-54c6-8517-0c0ceb0c60f8', '11203252-99d5-5eed-b998-3067cc6cb417', '51f28f0b-95c2-57b1-a53b-2240c7e80731', '38a1d301-f40d-5b17-a695-5e6d605f8b19', NOW(), NOW(), 1)
ON CONFLICT (id) DO NOTHING;

INSERT INTO directory.tenant_memberships (id, user_id, tenant_id, tenant_role_concept_id, status_concept_id, access_scope_concept_id, start_date, created_at, updated_at, row_version)
SELECT 'b73487fa-fe2f-531b-a335-b45be2b8b505', '11203252-99d5-5eed-b998-3067cc6cb417', c.tenant_id, '43634daf-8ee6-5e37-891b-3cf44d7a52f9', '13ca1b46-61d5-5c25-9d49-8247bcd7769c', '297d044a-a1e9-51db-8f96-68f4de6b3d62', '2026-01-01', NOW(), NOW(), 1
FROM insurance.insurance_carriers c
WHERE c.carrier_code = 'BO_ASEG_SEGUROS_ILLIMANI_S_A'
ON CONFLICT (id) DO NOTHING;

-- Cuenta para BO_ASEG_SEGUROS_Y_REASEGUROS_CREDINFORM_INTERNATIONA: acceso@credinform.com
INSERT INTO iam.users (id, status_concept_id, display_name, time_zone, email_verified, phone_verified, created_at, updated_at, row_version)
VALUES ('fd9930dc-6ae6-5722-8cee-322c9795dd94', '32dbed9f-cf1f-5c7a-9070-dfb937cf68a1', 'Operador Credinform International', 'America/La_Paz', TRUE, FALSE, NOW(), NOW(), 1)
ON CONFLICT (id) DO UPDATE SET display_name = EXCLUDED.display_name, status_concept_id = EXCLUDED.status_concept_id;

INSERT INTO iam.authentication_credentials (id, user_id, method_concept_id, external_subject, secret_hash, hash_algorithm_concept_id, state_concept_id, created_at, updated_at, row_version)
VALUES ('c112f065-8208-5b67-bf14-07cd6c543735', 'fd9930dc-6ae6-5722-8cee-322c9795dd94', '37da1281-cc62-5032-b598-1eb39dc46060', 'acceso@credinform.com', '$argon2id$v=19$m=65536,p=4,t=3$7yAD9OSiPXtT6NGkznwJhw$8o4wjbQHPoPyi3w11i8ZX4PfebO8077H+jOGxr2Xre8', '646c89e7-29d5-5450-a4c6-17817fe55aa9', '38a1d301-f40d-5b17-a695-5e6d605f8b19', NOW(), NOW(), 1)
ON CONFLICT (id) DO UPDATE SET secret_hash = EXCLUDED.secret_hash, state_concept_id = EXCLUDED.state_concept_id;

INSERT INTO iam.user_global_roles (id, user_id, role_concept_id, state_concept_id, created_at, updated_at, row_version)
VALUES ('c832747a-b0c5-5a55-80cf-1a1e1685d708', 'fd9930dc-6ae6-5722-8cee-322c9795dd94', '51f28f0b-95c2-57b1-a53b-2240c7e80731', '38a1d301-f40d-5b17-a695-5e6d605f8b19', NOW(), NOW(), 1)
ON CONFLICT (id) DO NOTHING;

INSERT INTO directory.tenant_memberships (id, user_id, tenant_id, tenant_role_concept_id, status_concept_id, access_scope_concept_id, start_date, created_at, updated_at, row_version)
SELECT '0efe643f-6e8e-5629-b442-5b7356641cad', 'fd9930dc-6ae6-5722-8cee-322c9795dd94', c.tenant_id, '43634daf-8ee6-5e37-891b-3cf44d7a52f9', '13ca1b46-61d5-5c25-9d49-8247bcd7769c', '297d044a-a1e9-51db-8f96-68f4de6b3d62', '2026-01-01', NOW(), NOW(), 1
FROM insurance.insurance_carriers c
WHERE c.carrier_code = 'BO_ASEG_SEGUROS_Y_REASEGUROS_CREDINFORM_INTERNATIONA'
ON CONFLICT (id) DO NOTHING;

-- Cuenta para BO_ASEG_UNIBIENES_S_A: acceso@unibienes.com
INSERT INTO iam.users (id, status_concept_id, display_name, time_zone, email_verified, phone_verified, created_at, updated_at, row_version)
VALUES ('1e289549-c3ea-581f-b234-cc55ee71c9ba', '32dbed9f-cf1f-5c7a-9070-dfb937cf68a1', 'Operador UNIBIENES Seguros', 'America/La_Paz', TRUE, FALSE, NOW(), NOW(), 1)
ON CONFLICT (id) DO UPDATE SET display_name = EXCLUDED.display_name, status_concept_id = EXCLUDED.status_concept_id;

INSERT INTO iam.authentication_credentials (id, user_id, method_concept_id, external_subject, secret_hash, hash_algorithm_concept_id, state_concept_id, created_at, updated_at, row_version)
VALUES ('4c2f0c1a-c7e1-56b9-bc16-57e91ce4802d', '1e289549-c3ea-581f-b234-cc55ee71c9ba', '37da1281-cc62-5032-b598-1eb39dc46060', 'acceso@unibienes.com', '$argon2id$v=19$m=65536,p=4,t=3$7yAD9OSiPXtT6NGkznwJhw$8o4wjbQHPoPyi3w11i8ZX4PfebO8077H+jOGxr2Xre8', '646c89e7-29d5-5450-a4c6-17817fe55aa9', '38a1d301-f40d-5b17-a695-5e6d605f8b19', NOW(), NOW(), 1)
ON CONFLICT (id) DO UPDATE SET secret_hash = EXCLUDED.secret_hash, state_concept_id = EXCLUDED.state_concept_id;

INSERT INTO iam.user_global_roles (id, user_id, role_concept_id, state_concept_id, created_at, updated_at, row_version)
VALUES ('63279476-b4b5-585e-9f03-7aee99d06dc9', '1e289549-c3ea-581f-b234-cc55ee71c9ba', '51f28f0b-95c2-57b1-a53b-2240c7e80731', '38a1d301-f40d-5b17-a695-5e6d605f8b19', NOW(), NOW(), 1)
ON CONFLICT (id) DO NOTHING;

INSERT INTO directory.tenant_memberships (id, user_id, tenant_id, tenant_role_concept_id, status_concept_id, access_scope_concept_id, start_date, created_at, updated_at, row_version)
SELECT '70f3d9bd-02e1-5e28-8af3-08364016b53e', '1e289549-c3ea-581f-b234-cc55ee71c9ba', c.tenant_id, '43634daf-8ee6-5e37-891b-3cf44d7a52f9', '13ca1b46-61d5-5c25-9d49-8247bcd7769c', '297d044a-a1e9-51db-8f96-68f4de6b3d62', '2026-01-01', NOW(), NOW(), 1
FROM insurance.insurance_carriers c
WHERE c.carrier_code = 'BO_ASEG_UNIBIENES_S_A'
ON CONFLICT (id) DO NOTHING;

-- Cuenta para BO_ASEG_UNIVIDA_S_A: acceso@univida.com
INSERT INTO iam.users (id, status_concept_id, display_name, time_zone, email_verified, phone_verified, created_at, updated_at, row_version)
VALUES ('47d37221-bb88-543c-bfb8-8efd43561f1d', '32dbed9f-cf1f-5c7a-9070-dfb937cf68a1', 'Operador UNIVIDA Seguros', 'America/La_Paz', TRUE, FALSE, NOW(), NOW(), 1)
ON CONFLICT (id) DO UPDATE SET display_name = EXCLUDED.display_name, status_concept_id = EXCLUDED.status_concept_id;

INSERT INTO iam.authentication_credentials (id, user_id, method_concept_id, external_subject, secret_hash, hash_algorithm_concept_id, state_concept_id, created_at, updated_at, row_version)
VALUES ('305f65cd-a450-5f34-b29e-0701fb4a3217', '47d37221-bb88-543c-bfb8-8efd43561f1d', '37da1281-cc62-5032-b598-1eb39dc46060', 'acceso@univida.com', '$argon2id$v=19$m=65536,p=4,t=3$7yAD9OSiPXtT6NGkznwJhw$8o4wjbQHPoPyi3w11i8ZX4PfebO8077H+jOGxr2Xre8', '646c89e7-29d5-5450-a4c6-17817fe55aa9', '38a1d301-f40d-5b17-a695-5e6d605f8b19', NOW(), NOW(), 1)
ON CONFLICT (id) DO UPDATE SET secret_hash = EXCLUDED.secret_hash, state_concept_id = EXCLUDED.state_concept_id;

INSERT INTO iam.user_global_roles (id, user_id, role_concept_id, state_concept_id, created_at, updated_at, row_version)
VALUES ('b969e8f8-01a0-55c6-a3a0-e564dc875250', '47d37221-bb88-543c-bfb8-8efd43561f1d', '51f28f0b-95c2-57b1-a53b-2240c7e80731', '38a1d301-f40d-5b17-a695-5e6d605f8b19', NOW(), NOW(), 1)
ON CONFLICT (id) DO NOTHING;

INSERT INTO directory.tenant_memberships (id, user_id, tenant_id, tenant_role_concept_id, status_concept_id, access_scope_concept_id, start_date, created_at, updated_at, row_version)
SELECT '4ab48126-0524-5337-85b4-93f954aaa751', '47d37221-bb88-543c-bfb8-8efd43561f1d', c.tenant_id, '43634daf-8ee6-5e37-891b-3cf44d7a52f9', '13ca1b46-61d5-5c25-9d49-8247bcd7769c', '297d044a-a1e9-51db-8f96-68f4de6b3d62', '2026-01-01', NOW(), NOW(), 1
FROM insurance.insurance_carriers c
WHERE c.carrier_code = 'BO_ASEG_UNIVIDA_S_A'
ON CONFLICT (id) DO NOTHING;

-- Cuenta para BO_PUB_BANCA_PRIVADA: acceso@csbp.com.bo
INSERT INTO iam.users (id, status_concept_id, display_name, time_zone, email_verified, phone_verified, created_at, updated_at, row_version)
VALUES ('5fb4afe9-9e1e-53d5-8b67-2c922bf86c95', '32dbed9f-cf1f-5c7a-9070-dfb937cf68a1', 'Operador Caja de Salud de la Banca Privada (CSBP)', 'America/La_Paz', TRUE, FALSE, NOW(), NOW(), 1)
ON CONFLICT (id) DO UPDATE SET display_name = EXCLUDED.display_name, status_concept_id = EXCLUDED.status_concept_id;

INSERT INTO iam.authentication_credentials (id, user_id, method_concept_id, external_subject, secret_hash, hash_algorithm_concept_id, state_concept_id, created_at, updated_at, row_version)
VALUES ('d564a354-ec2f-5f9b-9364-23cd19742a4e', '5fb4afe9-9e1e-53d5-8b67-2c922bf86c95', '37da1281-cc62-5032-b598-1eb39dc46060', 'acceso@csbp.com.bo', '$argon2id$v=19$m=65536,p=4,t=3$7yAD9OSiPXtT6NGkznwJhw$8o4wjbQHPoPyi3w11i8ZX4PfebO8077H+jOGxr2Xre8', '646c89e7-29d5-5450-a4c6-17817fe55aa9', '38a1d301-f40d-5b17-a695-5e6d605f8b19', NOW(), NOW(), 1)
ON CONFLICT (id) DO UPDATE SET secret_hash = EXCLUDED.secret_hash, state_concept_id = EXCLUDED.state_concept_id;

INSERT INTO iam.user_global_roles (id, user_id, role_concept_id, state_concept_id, created_at, updated_at, row_version)
VALUES ('5edfdcf0-f3ba-568b-acc0-0facf864631e', '5fb4afe9-9e1e-53d5-8b67-2c922bf86c95', '51f28f0b-95c2-57b1-a53b-2240c7e80731', '38a1d301-f40d-5b17-a695-5e6d605f8b19', NOW(), NOW(), 1)
ON CONFLICT (id) DO NOTHING;

INSERT INTO directory.tenant_memberships (id, user_id, tenant_id, tenant_role_concept_id, status_concept_id, access_scope_concept_id, start_date, created_at, updated_at, row_version)
SELECT 'd6d06e05-20b7-5c44-ae98-d38274f55a64', '5fb4afe9-9e1e-53d5-8b67-2c922bf86c95', c.tenant_id, '43634daf-8ee6-5e37-891b-3cf44d7a52f9', '13ca1b46-61d5-5c25-9d49-8247bcd7769c', '297d044a-a1e9-51db-8f96-68f4de6b3d62', '2026-01-01', NOW(), NOW(), 1
FROM insurance.insurance_carriers c
WHERE c.carrier_code = 'BO_PUB_BANCA_PRIVADA'
ON CONFLICT (id) DO NOTHING;

-- Cuenta para BO_PUB_CAMINOS: acceso@caminos.gob.bo
INSERT INTO iam.users (id, status_concept_id, display_name, time_zone, email_verified, phone_verified, created_at, updated_at, row_version)
VALUES ('fbcf0ffa-6ac8-5971-9b21-15eb91538f66', '32dbed9f-cf1f-5c7a-9070-dfb937cf68a1', 'Operador Caja de Salud de Caminos', 'America/La_Paz', TRUE, FALSE, NOW(), NOW(), 1)
ON CONFLICT (id) DO UPDATE SET display_name = EXCLUDED.display_name, status_concept_id = EXCLUDED.status_concept_id;

INSERT INTO iam.authentication_credentials (id, user_id, method_concept_id, external_subject, secret_hash, hash_algorithm_concept_id, state_concept_id, created_at, updated_at, row_version)
VALUES ('e40c47d1-8318-59d9-9c37-5a6670f82111', 'fbcf0ffa-6ac8-5971-9b21-15eb91538f66', '37da1281-cc62-5032-b598-1eb39dc46060', 'acceso@caminos.gob.bo', '$argon2id$v=19$m=65536,p=4,t=3$7yAD9OSiPXtT6NGkznwJhw$8o4wjbQHPoPyi3w11i8ZX4PfebO8077H+jOGxr2Xre8', '646c89e7-29d5-5450-a4c6-17817fe55aa9', '38a1d301-f40d-5b17-a695-5e6d605f8b19', NOW(), NOW(), 1)
ON CONFLICT (id) DO UPDATE SET secret_hash = EXCLUDED.secret_hash, state_concept_id = EXCLUDED.state_concept_id;

INSERT INTO iam.user_global_roles (id, user_id, role_concept_id, state_concept_id, created_at, updated_at, row_version)
VALUES ('6f73ae99-37dd-5ed1-bc2c-ac6e9d87a8fc', 'fbcf0ffa-6ac8-5971-9b21-15eb91538f66', '51f28f0b-95c2-57b1-a53b-2240c7e80731', '38a1d301-f40d-5b17-a695-5e6d605f8b19', NOW(), NOW(), 1)
ON CONFLICT (id) DO NOTHING;

INSERT INTO directory.tenant_memberships (id, user_id, tenant_id, tenant_role_concept_id, status_concept_id, access_scope_concept_id, start_date, created_at, updated_at, row_version)
SELECT '93f955fc-e5b7-5c40-a07c-e8e502719c87', 'fbcf0ffa-6ac8-5971-9b21-15eb91538f66', c.tenant_id, '43634daf-8ee6-5e37-891b-3cf44d7a52f9', '13ca1b46-61d5-5c25-9d49-8247bcd7769c', '297d044a-a1e9-51db-8f96-68f4de6b3d62', '2026-01-01', NOW(), NOW(), 1
FROM insurance.insurance_carriers c
WHERE c.carrier_code = 'BO_PUB_CAMINOS'
ON CONFLICT (id) DO NOTHING;

-- Cuenta para BO_PUB_CNS: acceso@cns.gob.bo
INSERT INTO iam.users (id, status_concept_id, display_name, time_zone, email_verified, phone_verified, created_at, updated_at, row_version)
VALUES ('33a2868d-4887-58d6-8183-62929c83cdfc', '32dbed9f-cf1f-5c7a-9070-dfb937cf68a1', 'Operador Caja Nacional de Salud (CNS)', 'America/La_Paz', TRUE, FALSE, NOW(), NOW(), 1)
ON CONFLICT (id) DO UPDATE SET display_name = EXCLUDED.display_name, status_concept_id = EXCLUDED.status_concept_id;

INSERT INTO iam.authentication_credentials (id, user_id, method_concept_id, external_subject, secret_hash, hash_algorithm_concept_id, state_concept_id, created_at, updated_at, row_version)
VALUES ('084a7ded-860a-5ff0-bcc8-4b3ea5cbb758', '33a2868d-4887-58d6-8183-62929c83cdfc', '37da1281-cc62-5032-b598-1eb39dc46060', 'acceso@cns.gob.bo', '$argon2id$v=19$m=65536,p=4,t=3$7yAD9OSiPXtT6NGkznwJhw$8o4wjbQHPoPyi3w11i8ZX4PfebO8077H+jOGxr2Xre8', '646c89e7-29d5-5450-a4c6-17817fe55aa9', '38a1d301-f40d-5b17-a695-5e6d605f8b19', NOW(), NOW(), 1)
ON CONFLICT (id) DO UPDATE SET secret_hash = EXCLUDED.secret_hash, state_concept_id = EXCLUDED.state_concept_id;

INSERT INTO iam.user_global_roles (id, user_id, role_concept_id, state_concept_id, created_at, updated_at, row_version)
VALUES ('f9572329-05bd-5c27-bafa-1bb0eadbf4ca', '33a2868d-4887-58d6-8183-62929c83cdfc', '51f28f0b-95c2-57b1-a53b-2240c7e80731', '38a1d301-f40d-5b17-a695-5e6d605f8b19', NOW(), NOW(), 1)
ON CONFLICT (id) DO NOTHING;

INSERT INTO directory.tenant_memberships (id, user_id, tenant_id, tenant_role_concept_id, status_concept_id, access_scope_concept_id, start_date, created_at, updated_at, row_version)
SELECT '7c3d241d-88a7-5066-8567-018f662bdbe7', '33a2868d-4887-58d6-8183-62929c83cdfc', c.tenant_id, '43634daf-8ee6-5e37-891b-3cf44d7a52f9', '13ca1b46-61d5-5c25-9d49-8247bcd7769c', '297d044a-a1e9-51db-8f96-68f4de6b3d62', '2026-01-01', NOW(), NOW(), 1
FROM insurance.insurance_carriers c
WHERE c.carrier_code = 'BO_PUB_CNS'
ON CONFLICT (id) DO NOTHING;

-- Cuenta para BO_PUB_CORDES: acceso@cordes.org.bo
INSERT INTO iam.users (id, status_concept_id, display_name, time_zone, email_verified, phone_verified, created_at, updated_at, row_version)
VALUES ('8c6cc300-f135-51f1-97e1-532c4310c1dd', '32dbed9f-cf1f-5c7a-9070-dfb937cf68a1', 'Operador Caja de Salud CORDES', 'America/La_Paz', TRUE, FALSE, NOW(), NOW(), 1)
ON CONFLICT (id) DO UPDATE SET display_name = EXCLUDED.display_name, status_concept_id = EXCLUDED.status_concept_id;

INSERT INTO iam.authentication_credentials (id, user_id, method_concept_id, external_subject, secret_hash, hash_algorithm_concept_id, state_concept_id, created_at, updated_at, row_version)
VALUES ('12319187-8220-5137-a172-98a8b2f14281', '8c6cc300-f135-51f1-97e1-532c4310c1dd', '37da1281-cc62-5032-b598-1eb39dc46060', 'acceso@cordes.org.bo', '$argon2id$v=19$m=65536,p=4,t=3$7yAD9OSiPXtT6NGkznwJhw$8o4wjbQHPoPyi3w11i8ZX4PfebO8077H+jOGxr2Xre8', '646c89e7-29d5-5450-a4c6-17817fe55aa9', '38a1d301-f40d-5b17-a695-5e6d605f8b19', NOW(), NOW(), 1)
ON CONFLICT (id) DO UPDATE SET secret_hash = EXCLUDED.secret_hash, state_concept_id = EXCLUDED.state_concept_id;

INSERT INTO iam.user_global_roles (id, user_id, role_concept_id, state_concept_id, created_at, updated_at, row_version)
VALUES ('cf66bb07-9e5b-548a-b944-64266d41436f', '8c6cc300-f135-51f1-97e1-532c4310c1dd', '51f28f0b-95c2-57b1-a53b-2240c7e80731', '38a1d301-f40d-5b17-a695-5e6d605f8b19', NOW(), NOW(), 1)
ON CONFLICT (id) DO NOTHING;

INSERT INTO directory.tenant_memberships (id, user_id, tenant_id, tenant_role_concept_id, status_concept_id, access_scope_concept_id, start_date, created_at, updated_at, row_version)
SELECT 'd32142e4-8b17-5039-bf6e-e79d3b00b796', '8c6cc300-f135-51f1-97e1-532c4310c1dd', c.tenant_id, '43634daf-8ee6-5e37-891b-3cf44d7a52f9', '13ca1b46-61d5-5c25-9d49-8247bcd7769c', '297d044a-a1e9-51db-8f96-68f4de6b3d62', '2026-01-01', NOW(), NOW(), 1
FROM insurance.insurance_carriers c
WHERE c.carrier_code = 'BO_PUB_CORDES'
ON CONFLICT (id) DO NOTHING;

-- Cuenta para BO_PUB_COSSMIL: acceso@cossmil.mil.bo
INSERT INTO iam.users (id, status_concept_id, display_name, time_zone, email_verified, phone_verified, created_at, updated_at, row_version)
VALUES ('4318cc0c-d341-5580-a0b2-78223173a3dd', '32dbed9f-cf1f-5c7a-9070-dfb937cf68a1', 'Operador Corporación del Seguro Social Militar (COSSMIL)', 'America/La_Paz', TRUE, FALSE, NOW(), NOW(), 1)
ON CONFLICT (id) DO UPDATE SET display_name = EXCLUDED.display_name, status_concept_id = EXCLUDED.status_concept_id;

INSERT INTO iam.authentication_credentials (id, user_id, method_concept_id, external_subject, secret_hash, hash_algorithm_concept_id, state_concept_id, created_at, updated_at, row_version)
VALUES ('3a248ff9-04d9-5d4b-993e-759af288ba52', '4318cc0c-d341-5580-a0b2-78223173a3dd', '37da1281-cc62-5032-b598-1eb39dc46060', 'acceso@cossmil.mil.bo', '$argon2id$v=19$m=65536,p=4,t=3$7yAD9OSiPXtT6NGkznwJhw$8o4wjbQHPoPyi3w11i8ZX4PfebO8077H+jOGxr2Xre8', '646c89e7-29d5-5450-a4c6-17817fe55aa9', '38a1d301-f40d-5b17-a695-5e6d605f8b19', NOW(), NOW(), 1)
ON CONFLICT (id) DO UPDATE SET secret_hash = EXCLUDED.secret_hash, state_concept_id = EXCLUDED.state_concept_id;

INSERT INTO iam.user_global_roles (id, user_id, role_concept_id, state_concept_id, created_at, updated_at, row_version)
VALUES ('96308e9b-4b48-5976-a0e4-7607d5ad57bc', '4318cc0c-d341-5580-a0b2-78223173a3dd', '51f28f0b-95c2-57b1-a53b-2240c7e80731', '38a1d301-f40d-5b17-a695-5e6d605f8b19', NOW(), NOW(), 1)
ON CONFLICT (id) DO NOTHING;

INSERT INTO directory.tenant_memberships (id, user_id, tenant_id, tenant_role_concept_id, status_concept_id, access_scope_concept_id, start_date, created_at, updated_at, row_version)
SELECT '7764bb2a-3d9e-5d36-aebb-c91df745a147', '4318cc0c-d341-5580-a0b2-78223173a3dd', c.tenant_id, '43634daf-8ee6-5e37-891b-3cf44d7a52f9', '13ca1b46-61d5-5c25-9d49-8247bcd7769c', '297d044a-a1e9-51db-8f96-68f4de6b3d62', '2026-01-01', NOW(), NOW(), 1
FROM insurance.insurance_carriers c
WHERE c.carrier_code = 'BO_PUB_COSSMIL'
ON CONFLICT (id) DO NOTHING;

-- Cuenta para BO_PUB_CPS: acceso@cps.org.bo
INSERT INTO iam.users (id, status_concept_id, display_name, time_zone, email_verified, phone_verified, created_at, updated_at, row_version)
VALUES ('74079695-1577-5edb-8057-f80c9f75936c', '32dbed9f-cf1f-5c7a-9070-dfb937cf68a1', 'Operador Caja Petrolera de Salud (CPS)', 'America/La_Paz', TRUE, FALSE, NOW(), NOW(), 1)
ON CONFLICT (id) DO UPDATE SET display_name = EXCLUDED.display_name, status_concept_id = EXCLUDED.status_concept_id;

INSERT INTO iam.authentication_credentials (id, user_id, method_concept_id, external_subject, secret_hash, hash_algorithm_concept_id, state_concept_id, created_at, updated_at, row_version)
VALUES ('bd5c5ff6-7622-5528-ba27-1699a2dd7486', '74079695-1577-5edb-8057-f80c9f75936c', '37da1281-cc62-5032-b598-1eb39dc46060', 'acceso@cps.org.bo', '$argon2id$v=19$m=65536,p=4,t=3$7yAD9OSiPXtT6NGkznwJhw$8o4wjbQHPoPyi3w11i8ZX4PfebO8077H+jOGxr2Xre8', '646c89e7-29d5-5450-a4c6-17817fe55aa9', '38a1d301-f40d-5b17-a695-5e6d605f8b19', NOW(), NOW(), 1)
ON CONFLICT (id) DO UPDATE SET secret_hash = EXCLUDED.secret_hash, state_concept_id = EXCLUDED.state_concept_id;

INSERT INTO iam.user_global_roles (id, user_id, role_concept_id, state_concept_id, created_at, updated_at, row_version)
VALUES ('c1b5eed7-6d01-586a-948d-d4b5f24d9034', '74079695-1577-5edb-8057-f80c9f75936c', '51f28f0b-95c2-57b1-a53b-2240c7e80731', '38a1d301-f40d-5b17-a695-5e6d605f8b19', NOW(), NOW(), 1)
ON CONFLICT (id) DO NOTHING;

INSERT INTO directory.tenant_memberships (id, user_id, tenant_id, tenant_role_concept_id, status_concept_id, access_scope_concept_id, start_date, created_at, updated_at, row_version)
SELECT '5af3d1c1-c680-5c64-9e3e-49f1ceb9d9c3', '74079695-1577-5edb-8057-f80c9f75936c', c.tenant_id, '43634daf-8ee6-5e37-891b-3cf44d7a52f9', '13ca1b46-61d5-5c25-9d49-8247bcd7769c', '297d044a-a1e9-51db-8f96-68f4de6b3d62', '2026-01-01', NOW(), NOW(), 1
FROM insurance.insurance_carriers c
WHERE c.carrier_code = 'BO_PUB_CPS'
ON CONFLICT (id) DO NOTHING;

-- Cuenta para BO_PUB_SSU: acceso@ssu.edu.bo
INSERT INTO iam.users (id, status_concept_id, display_name, time_zone, email_verified, phone_verified, created_at, updated_at, row_version)
VALUES ('09794530-8efc-52b0-976f-28f0cfb2d91d', '32dbed9f-cf1f-5c7a-9070-dfb937cf68a1', 'Operador Seguro Social Universitario (SSU)', 'America/La_Paz', TRUE, FALSE, NOW(), NOW(), 1)
ON CONFLICT (id) DO UPDATE SET display_name = EXCLUDED.display_name, status_concept_id = EXCLUDED.status_concept_id;

INSERT INTO iam.authentication_credentials (id, user_id, method_concept_id, external_subject, secret_hash, hash_algorithm_concept_id, state_concept_id, created_at, updated_at, row_version)
VALUES ('468058ef-bcd4-55cb-808b-f532e4d7db46', '09794530-8efc-52b0-976f-28f0cfb2d91d', '37da1281-cc62-5032-b598-1eb39dc46060', 'acceso@ssu.edu.bo', '$argon2id$v=19$m=65536,p=4,t=3$7yAD9OSiPXtT6NGkznwJhw$8o4wjbQHPoPyi3w11i8ZX4PfebO8077H+jOGxr2Xre8', '646c89e7-29d5-5450-a4c6-17817fe55aa9', '38a1d301-f40d-5b17-a695-5e6d605f8b19', NOW(), NOW(), 1)
ON CONFLICT (id) DO UPDATE SET secret_hash = EXCLUDED.secret_hash, state_concept_id = EXCLUDED.state_concept_id;

INSERT INTO iam.user_global_roles (id, user_id, role_concept_id, state_concept_id, created_at, updated_at, row_version)
VALUES ('74e71243-c985-5c52-a326-def21eb04b97', '09794530-8efc-52b0-976f-28f0cfb2d91d', '51f28f0b-95c2-57b1-a53b-2240c7e80731', '38a1d301-f40d-5b17-a695-5e6d605f8b19', NOW(), NOW(), 1)
ON CONFLICT (id) DO NOTHING;

INSERT INTO directory.tenant_memberships (id, user_id, tenant_id, tenant_role_concept_id, status_concept_id, access_scope_concept_id, start_date, created_at, updated_at, row_version)
SELECT '2eb89a4d-2022-5f83-be51-8e8081a47efc', '09794530-8efc-52b0-976f-28f0cfb2d91d', c.tenant_id, '43634daf-8ee6-5e37-891b-3cf44d7a52f9', '13ca1b46-61d5-5c25-9d49-8247bcd7769c', '297d044a-a1e9-51db-8f96-68f4de6b3d62', '2026-01-01', NOW(), NOW(), 1
FROM insurance.insurance_carriers c
WHERE c.carrier_code = 'BO_PUB_SSU'
ON CONFLICT (id) DO NOTHING;

-- Cuenta para BO_PUB_SUS: acceso@minsalud.gob.bo
INSERT INTO iam.users (id, status_concept_id, display_name, time_zone, email_verified, phone_verified, created_at, updated_at, row_version)
VALUES ('22aba550-fbac-5ec1-b7ef-88b8f90b0ab8', '32dbed9f-cf1f-5c7a-9070-dfb937cf68a1', 'Operador Sistema Único de Salud (SUS)', 'America/La_Paz', TRUE, FALSE, NOW(), NOW(), 1)
ON CONFLICT (id) DO UPDATE SET display_name = EXCLUDED.display_name, status_concept_id = EXCLUDED.status_concept_id;

INSERT INTO iam.authentication_credentials (id, user_id, method_concept_id, external_subject, secret_hash, hash_algorithm_concept_id, state_concept_id, created_at, updated_at, row_version)
VALUES ('30453024-a574-56ad-a730-49bc7b5f0d2b', '22aba550-fbac-5ec1-b7ef-88b8f90b0ab8', '37da1281-cc62-5032-b598-1eb39dc46060', 'acceso@minsalud.gob.bo', '$argon2id$v=19$m=65536,p=4,t=3$7yAD9OSiPXtT6NGkznwJhw$8o4wjbQHPoPyi3w11i8ZX4PfebO8077H+jOGxr2Xre8', '646c89e7-29d5-5450-a4c6-17817fe55aa9', '38a1d301-f40d-5b17-a695-5e6d605f8b19', NOW(), NOW(), 1)
ON CONFLICT (id) DO UPDATE SET secret_hash = EXCLUDED.secret_hash, state_concept_id = EXCLUDED.state_concept_id;

INSERT INTO iam.user_global_roles (id, user_id, role_concept_id, state_concept_id, created_at, updated_at, row_version)
VALUES ('ad7cf164-5460-543e-9608-4d694609d1b7', '22aba550-fbac-5ec1-b7ef-88b8f90b0ab8', '51f28f0b-95c2-57b1-a53b-2240c7e80731', '38a1d301-f40d-5b17-a695-5e6d605f8b19', NOW(), NOW(), 1)
ON CONFLICT (id) DO NOTHING;

INSERT INTO directory.tenant_memberships (id, user_id, tenant_id, tenant_role_concept_id, status_concept_id, access_scope_concept_id, start_date, created_at, updated_at, row_version)
SELECT 'd8795a9e-29f9-5f73-b14c-59621651e65d', '22aba550-fbac-5ec1-b7ef-88b8f90b0ab8', c.tenant_id, '43634daf-8ee6-5e37-891b-3cf44d7a52f9', '13ca1b46-61d5-5c25-9d49-8247bcd7769c', '297d044a-a1e9-51db-8f96-68f4de6b3d62', '2026-01-01', NOW(), NOW(), 1
FROM insurance.insurance_carriers c
WHERE c.carrier_code = 'BO_PUB_SUS'
ON CONFLICT (id) DO NOTHING;

-- Cuenta para DEMO-07qj6: acceso@aseguradorademo.com
INSERT INTO iam.users (id, status_concept_id, display_name, time_zone, email_verified, phone_verified, created_at, updated_at, row_version)
VALUES ('a4dfada6-6ffd-5d56-8a7d-75a2708a9512', '32dbed9f-cf1f-5c7a-9070-dfb937cf68a1', 'Operador Aseguradora Demo', 'America/La_Paz', TRUE, FALSE, NOW(), NOW(), 1)
ON CONFLICT (id) DO UPDATE SET display_name = EXCLUDED.display_name, status_concept_id = EXCLUDED.status_concept_id;

INSERT INTO iam.authentication_credentials (id, user_id, method_concept_id, external_subject, secret_hash, hash_algorithm_concept_id, state_concept_id, created_at, updated_at, row_version)
VALUES ('0a853a86-89da-5c7a-83d3-c3ce80d2a55e', 'a4dfada6-6ffd-5d56-8a7d-75a2708a9512', '37da1281-cc62-5032-b598-1eb39dc46060', 'acceso@aseguradorademo.com', '$argon2id$v=19$m=65536,p=4,t=3$7yAD9OSiPXtT6NGkznwJhw$8o4wjbQHPoPyi3w11i8ZX4PfebO8077H+jOGxr2Xre8', '646c89e7-29d5-5450-a4c6-17817fe55aa9', '38a1d301-f40d-5b17-a695-5e6d605f8b19', NOW(), NOW(), 1)
ON CONFLICT (id) DO UPDATE SET secret_hash = EXCLUDED.secret_hash, state_concept_id = EXCLUDED.state_concept_id;

INSERT INTO iam.user_global_roles (id, user_id, role_concept_id, state_concept_id, created_at, updated_at, row_version)
VALUES ('5244caa2-6d72-5544-b1fc-1bc10379e205', 'a4dfada6-6ffd-5d56-8a7d-75a2708a9512', '51f28f0b-95c2-57b1-a53b-2240c7e80731', '38a1d301-f40d-5b17-a695-5e6d605f8b19', NOW(), NOW(), 1)
ON CONFLICT (id) DO NOTHING;

INSERT INTO directory.tenant_memberships (id, user_id, tenant_id, tenant_role_concept_id, status_concept_id, access_scope_concept_id, start_date, created_at, updated_at, row_version)
SELECT 'e6118414-e69f-56c4-8b3e-8787da6699e7', 'a4dfada6-6ffd-5d56-8a7d-75a2708a9512', c.tenant_id, '43634daf-8ee6-5e37-891b-3cf44d7a52f9', '13ca1b46-61d5-5c25-9d49-8247bcd7769c', '297d044a-a1e9-51db-8f96-68f4de6b3d62', '2026-01-01', NOW(), NOW(), 1
FROM insurance.insurance_carriers c
WHERE c.carrier_code = 'DEMO-07qj6'
ON CONFLICT (id) DO NOTHING;

COMMIT;
