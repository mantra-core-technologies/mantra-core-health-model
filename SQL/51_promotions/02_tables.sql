-- SALUD v4.0.10 · módulo 51 · schema promotions
-- Generado de diagram_51_promotions.puml — NO editar a mano.


CREATE TABLE IF NOT EXISTS "promotions"."loyalty_programs" (
    "id" uuid NOT NULL,
    "tenant_id" uuid NOT NULL,
    "code" varchar NOT NULL,
    "name" varchar NOT NULL,
    "program_type_concept_id" uuid NOT NULL,
    "points_currency_name" varchar,
    "point_to_currency_rate" numeric,
    "currency_concept_id" uuid,
    "expiry_policy_concept_id" uuid,
    "points_expiry_days" integer,
    "state_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_loyalty_programs" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "promotions"."loyalty_tiers" (
    "id" uuid NOT NULL,
    "loyalty_program_id" uuid NOT NULL,
    "code" varchar NOT NULL,
    "name" varchar NOT NULL,
    "min_points" numeric NOT NULL,
    "multiplier" numeric,
    "benefits_json" jsonb,
    "ordinal" integer,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_loyalty_tiers" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "promotions"."loyalty_memberships" (
    "id" uuid NOT NULL,
    "loyalty_program_id" uuid NOT NULL,
    "member_type_concept_id" uuid NOT NULL,
    "member_ref_id" uuid NOT NULL,
    "current_tier_id" uuid,
    "points_balance" numeric,
    "lifetime_points" numeric,
    "enrolled_at" timestamptz,
    "status_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_loyalty_memberships" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "promotions"."points_ledger_entries" (
    "id" uuid NOT NULL,
    "loyalty_membership_id" uuid NOT NULL,
    "direction_concept_id" uuid NOT NULL,
    "points" numeric NOT NULL,
    "reason_concept_id" uuid NOT NULL,
    "balance_after" numeric,
    "source_type" varchar,
    "source_ref_id" uuid,
    "earning_rule_id" uuid,
    "expires_at" timestamptz,
    "idempotency_key" varchar NOT NULL,
    "occurred_at" timestamptz,
    "recorded_at" timestamptz NOT NULL,
    "recorded_by_user_id" uuid,
    CONSTRAINT "pk_points_ledger_entries" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "promotions"."earning_rules" (
    "id" uuid NOT NULL,
    "loyalty_program_id" uuid NOT NULL,
    "code" varchar NOT NULL,
    "name" varchar NOT NULL,
    "event_type_concept_id" uuid NOT NULL,
    "award_type_concept_id" uuid NOT NULL,
    "points_amount" numeric,
    "credit_amount" numeric,
    "currency_concept_id" uuid,
    "condition_json" jsonb,
    "cap_per_period" integer,
    "period_concept_id" uuid,
    "valid_from" timestamptz,
    "valid_to" timestamptz,
    "is_active" boolean NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_earning_rules" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "promotions"."promotions" (
    "id" uuid NOT NULL,
    "tenant_id" uuid NOT NULL,
    "code" varchar NOT NULL,
    "name" varchar NOT NULL,
    "promotion_type_concept_id" uuid NOT NULL,
    "description" text,
    "campaign_ref_id" uuid,
    "priority" integer NOT NULL,
    "stackable" boolean,
    "budget_amount" numeric,
    "currency_concept_id" uuid,
    "total_redemption_limit" integer,
    "per_user_limit" integer,
    "valid_from" timestamptz,
    "valid_to" timestamptz,
    "status_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_promotions" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "promotions"."discount_rules" (
    "id" uuid NOT NULL,
    "promotion_id" uuid NOT NULL,
    "discount_type_concept_id" uuid NOT NULL,
    "percentage" numeric,
    "fixed_amount" numeric,
    "currency_concept_id" uuid,
    "max_discount_amount" numeric,
    "min_purchase_amount" numeric,
    "applies_to_concept_id" uuid,
    "target_filter_json" jsonb,
    "buy_quantity" integer,
    "get_quantity" integer,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_discount_rules" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "promotions"."coupons" (
    "id" uuid NOT NULL,
    "promotion_id" uuid NOT NULL,
    "code" varchar NOT NULL,
    "coupon_type_concept_id" uuid NOT NULL,
    "assigned_member_type_concept_id" uuid,
    "assigned_member_ref_id" uuid,
    "max_redemptions" integer,
    "redemption_count" integer,
    "valid_from" timestamptz,
    "valid_to" timestamptz,
    "status_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_coupons" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "promotions"."redemptions" (
    "id" uuid NOT NULL,
    "promotion_id" uuid NOT NULL,
    "coupon_id" uuid,
    "discount_rule_id" uuid,
    "redeemer_type_concept_id" uuid NOT NULL,
    "redeemer_ref_id" uuid NOT NULL,
    "discount_amount" numeric NOT NULL,
    "currency_concept_id" uuid NOT NULL,
    "order_ref_type" varchar,
    "order_ref_id" uuid,
    "payment_intent_id" uuid,
    "status_concept_id" uuid NOT NULL,
    "redeemed_at" timestamptz,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_redemptions" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "promotions"."referral_programs" (
    "id" uuid NOT NULL,
    "tenant_id" uuid NOT NULL,
    "code" varchar NOT NULL,
    "name" varchar NOT NULL,
    "referrer_award_type_concept_id" uuid NOT NULL,
    "referrer_award_amount" numeric,
    "referee_award_type_concept_id" uuid NOT NULL,
    "referee_award_amount" numeric,
    "currency_concept_id" uuid,
    "qualifying_event_concept_id" uuid,
    "max_referrals_per_user" integer,
    "valid_from" timestamptz,
    "valid_to" timestamptz,
    "state_concept_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_referral_programs" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "promotions"."member_referrals" (
    "id" uuid NOT NULL,
    "referral_program_id" uuid NOT NULL,
    "referrer_user_id" uuid NOT NULL,
    "referral_code" varchar NOT NULL,
    "referee_user_id" uuid,
    "referee_contact" varchar,
    "status_concept_id" uuid NOT NULL,
    "qualified_at" timestamptz,
    "referrer_reward_ledger_id" uuid,
    "referee_reward_ledger_id" uuid,
    "created_at" timestamptz NOT NULL,
    "updated_at" timestamptz NOT NULL,
    "created_by_user_id" uuid,
    "updated_by_user_id" uuid,
    "row_version" integer NOT NULL DEFAULT 1,
    CONSTRAINT "pk_member_referrals" PRIMARY KEY ("id")
);
