-- SALUD v4.0.10 · módulo 51 · schema promotions
-- Generado de diagram_51_promotions.puml — NO editar a mano.


CREATE UNIQUE INDEX IF NOT EXISTS "uq_loyalty_programs_code" ON "promotions"."loyalty_programs" ("code");

CREATE INDEX IF NOT EXISTS "ix_loyalty_programs_tenant_id" ON "promotions"."loyalty_programs" ("tenant_id");

CREATE INDEX IF NOT EXISTS "ix_loyalty_programs_program_type_concept_id" ON "promotions"."loyalty_programs" ("program_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_loyalty_programs_currency_concept_id" ON "promotions"."loyalty_programs" ("currency_concept_id");

CREATE INDEX IF NOT EXISTS "ix_loyalty_programs_expiry_policy_concept_id" ON "promotions"."loyalty_programs" ("expiry_policy_concept_id");

CREATE INDEX IF NOT EXISTS "ix_loyalty_programs_state_concept_id" ON "promotions"."loyalty_programs" ("state_concept_id");

CREATE INDEX IF NOT EXISTS "ix_loyalty_programs_created_by_user_id" ON "promotions"."loyalty_programs" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_loyalty_programs_updated_by_user_id" ON "promotions"."loyalty_programs" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_loyalty_programs_tenant_id_state_concept_id" ON "promotions"."loyalty_programs" ("tenant_id", "state_concept_id", "updated_at" DESC);

CREATE INDEX IF NOT EXISTS "gin_loyalty_programs_search" ON "promotions"."loyalty_programs" USING gin (to_tsvector('simple', (coalesce(name, '') || ' ' || coalesce(code, ''))));

CREATE INDEX IF NOT EXISTS "ix_loyalty_tiers_loyalty_program_id" ON "promotions"."loyalty_tiers" ("loyalty_program_id");

CREATE INDEX IF NOT EXISTS "ix_loyalty_tiers_created_by_user_id" ON "promotions"."loyalty_tiers" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_loyalty_tiers_updated_by_user_id" ON "promotions"."loyalty_tiers" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "gin_loyalty_tiers_search" ON "promotions"."loyalty_tiers" USING gin (to_tsvector('simple', (coalesce(name, '') || ' ' || coalesce(code, ''))));

CREATE INDEX IF NOT EXISTS "ix_loyalty_memberships_loyalty_program_id" ON "promotions"."loyalty_memberships" ("loyalty_program_id");

CREATE INDEX IF NOT EXISTS "ix_loyalty_memberships_member_type_concept_id" ON "promotions"."loyalty_memberships" ("member_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_loyalty_memberships_current_tier_id" ON "promotions"."loyalty_memberships" ("current_tier_id");

CREATE INDEX IF NOT EXISTS "ix_loyalty_memberships_status_concept_id" ON "promotions"."loyalty_memberships" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_loyalty_memberships_created_by_user_id" ON "promotions"."loyalty_memberships" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_loyalty_memberships_updated_by_user_id" ON "promotions"."loyalty_memberships" ("updated_by_user_id");

CREATE UNIQUE INDEX IF NOT EXISTS "uq_points_ledger_entries_idempotency_key" ON "promotions"."points_ledger_entries" ("idempotency_key");

CREATE INDEX IF NOT EXISTS "ix_points_ledger_entries_loyalty_membership_id" ON "promotions"."points_ledger_entries" ("loyalty_membership_id");

CREATE INDEX IF NOT EXISTS "ix_points_ledger_entries_direction_concept_id" ON "promotions"."points_ledger_entries" ("direction_concept_id");

CREATE INDEX IF NOT EXISTS "ix_points_ledger_entries_reason_concept_id" ON "promotions"."points_ledger_entries" ("reason_concept_id");

CREATE INDEX IF NOT EXISTS "ix_points_ledger_entries_earning_rule_id" ON "promotions"."points_ledger_entries" ("earning_rule_id");

CREATE INDEX IF NOT EXISTS "ix_points_ledger_entries_recorded_by_user_id" ON "promotions"."points_ledger_entries" ("recorded_by_user_id");

CREATE INDEX IF NOT EXISTS "brin_points_ledger_entries_recorded_at" ON "promotions"."points_ledger_entries" USING brin ("recorded_at") WITH (pages_per_range=128);

CREATE INDEX IF NOT EXISTS "ix_earning_rules_loyalty_program_id" ON "promotions"."earning_rules" ("loyalty_program_id");

CREATE INDEX IF NOT EXISTS "ix_earning_rules_event_type_concept_id" ON "promotions"."earning_rules" ("event_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_earning_rules_award_type_concept_id" ON "promotions"."earning_rules" ("award_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_earning_rules_currency_concept_id" ON "promotions"."earning_rules" ("currency_concept_id");

CREATE INDEX IF NOT EXISTS "ix_earning_rules_period_concept_id" ON "promotions"."earning_rules" ("period_concept_id");

CREATE INDEX IF NOT EXISTS "ix_earning_rules_created_by_user_id" ON "promotions"."earning_rules" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_earning_rules_updated_by_user_id" ON "promotions"."earning_rules" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "gin_earning_rules_search" ON "promotions"."earning_rules" USING gin (to_tsvector('simple', (coalesce(name, '') || ' ' || coalesce(code, ''))));

CREATE UNIQUE INDEX IF NOT EXISTS "uq_promotions_code" ON "promotions"."promotions" ("code");

CREATE INDEX IF NOT EXISTS "ix_promotions_tenant_id" ON "promotions"."promotions" ("tenant_id");

CREATE INDEX IF NOT EXISTS "ix_promotions_promotion_type_concept_id" ON "promotions"."promotions" ("promotion_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_promotions_currency_concept_id" ON "promotions"."promotions" ("currency_concept_id");

CREATE INDEX IF NOT EXISTS "ix_promotions_status_concept_id" ON "promotions"."promotions" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_promotions_created_by_user_id" ON "promotions"."promotions" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_promotions_updated_by_user_id" ON "promotions"."promotions" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_promotions_tenant_id_status_concept_id" ON "promotions"."promotions" ("tenant_id", "status_concept_id", "updated_at" DESC);

CREATE INDEX IF NOT EXISTS "gin_promotions_search" ON "promotions"."promotions" USING gin (to_tsvector('simple', (coalesce(name, '') || ' ' || coalesce(description, ''))));

CREATE INDEX IF NOT EXISTS "ix_discount_rules_promotion_id" ON "promotions"."discount_rules" ("promotion_id");

CREATE INDEX IF NOT EXISTS "ix_discount_rules_discount_type_concept_id" ON "promotions"."discount_rules" ("discount_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_discount_rules_currency_concept_id" ON "promotions"."discount_rules" ("currency_concept_id");

CREATE INDEX IF NOT EXISTS "ix_discount_rules_applies_to_concept_id" ON "promotions"."discount_rules" ("applies_to_concept_id");

CREATE INDEX IF NOT EXISTS "ix_discount_rules_created_by_user_id" ON "promotions"."discount_rules" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_discount_rules_updated_by_user_id" ON "promotions"."discount_rules" ("updated_by_user_id");

CREATE UNIQUE INDEX IF NOT EXISTS "uq_coupons_code" ON "promotions"."coupons" ("code");

CREATE INDEX IF NOT EXISTS "ix_coupons_promotion_id" ON "promotions"."coupons" ("promotion_id");

CREATE INDEX IF NOT EXISTS "ix_coupons_coupon_type_concept_id" ON "promotions"."coupons" ("coupon_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_coupons_assigned_member_type_concept_id" ON "promotions"."coupons" ("assigned_member_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_coupons_status_concept_id" ON "promotions"."coupons" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_coupons_created_by_user_id" ON "promotions"."coupons" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_coupons_updated_by_user_id" ON "promotions"."coupons" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "gin_coupons_search" ON "promotions"."coupons" USING gin (to_tsvector('simple', (coalesce(code, ''))));

CREATE INDEX IF NOT EXISTS "ix_redemptions_promotion_id" ON "promotions"."redemptions" ("promotion_id");

CREATE INDEX IF NOT EXISTS "ix_redemptions_coupon_id" ON "promotions"."redemptions" ("coupon_id");

CREATE INDEX IF NOT EXISTS "ix_redemptions_discount_rule_id" ON "promotions"."redemptions" ("discount_rule_id");

CREATE INDEX IF NOT EXISTS "ix_redemptions_redeemer_type_concept_id" ON "promotions"."redemptions" ("redeemer_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_redemptions_currency_concept_id" ON "promotions"."redemptions" ("currency_concept_id");

CREATE INDEX IF NOT EXISTS "ix_redemptions_payment_intent_id" ON "promotions"."redemptions" ("payment_intent_id");

CREATE INDEX IF NOT EXISTS "ix_redemptions_status_concept_id" ON "promotions"."redemptions" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_redemptions_created_by_user_id" ON "promotions"."redemptions" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_redemptions_updated_by_user_id" ON "promotions"."redemptions" ("updated_by_user_id");

CREATE UNIQUE INDEX IF NOT EXISTS "uq_referral_programs_code" ON "promotions"."referral_programs" ("code");

CREATE INDEX IF NOT EXISTS "ix_referral_programs_tenant_id" ON "promotions"."referral_programs" ("tenant_id");

CREATE INDEX IF NOT EXISTS "ix_referral_programs_referrer_award_type_concept_id" ON "promotions"."referral_programs" ("referrer_award_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_referral_programs_referee_award_type_concept_id" ON "promotions"."referral_programs" ("referee_award_type_concept_id");

CREATE INDEX IF NOT EXISTS "ix_referral_programs_currency_concept_id" ON "promotions"."referral_programs" ("currency_concept_id");

CREATE INDEX IF NOT EXISTS "ix_referral_programs_qualifying_event_concept_id" ON "promotions"."referral_programs" ("qualifying_event_concept_id");

CREATE INDEX IF NOT EXISTS "ix_referral_programs_state_concept_id" ON "promotions"."referral_programs" ("state_concept_id");

CREATE INDEX IF NOT EXISTS "ix_referral_programs_created_by_user_id" ON "promotions"."referral_programs" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_referral_programs_updated_by_user_id" ON "promotions"."referral_programs" ("updated_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_referral_programs_tenant_id_state_concept_id" ON "promotions"."referral_programs" ("tenant_id", "state_concept_id", "updated_at" DESC);

CREATE INDEX IF NOT EXISTS "gin_referral_programs_search" ON "promotions"."referral_programs" USING gin (to_tsvector('simple', (coalesce(name, '') || ' ' || coalesce(code, ''))));

CREATE UNIQUE INDEX IF NOT EXISTS "uq_member_referrals_referral_code" ON "promotions"."member_referrals" ("referral_code");

CREATE INDEX IF NOT EXISTS "ix_member_referrals_referral_program_id" ON "promotions"."member_referrals" ("referral_program_id");

CREATE INDEX IF NOT EXISTS "ix_member_referrals_referrer_user_id" ON "promotions"."member_referrals" ("referrer_user_id");

CREATE INDEX IF NOT EXISTS "ix_member_referrals_referee_user_id" ON "promotions"."member_referrals" ("referee_user_id");

CREATE INDEX IF NOT EXISTS "ix_member_referrals_status_concept_id" ON "promotions"."member_referrals" ("status_concept_id");

CREATE INDEX IF NOT EXISTS "ix_member_referrals_referrer_reward_ledger_id" ON "promotions"."member_referrals" ("referrer_reward_ledger_id");

CREATE INDEX IF NOT EXISTS "ix_member_referrals_referee_reward_ledger_id" ON "promotions"."member_referrals" ("referee_reward_ledger_id");

CREATE INDEX IF NOT EXISTS "ix_member_referrals_created_by_user_id" ON "promotions"."member_referrals" ("created_by_user_id");

CREATE INDEX IF NOT EXISTS "ix_member_referrals_updated_by_user_id" ON "promotions"."member_referrals" ("updated_by_user_id");
