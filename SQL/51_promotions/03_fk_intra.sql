-- SALUD v4.0.10 · módulo 51 · schema promotions
-- Generado de diagram_51_promotions.puml — NO editar a mano.


DO $$ BEGIN
    ALTER TABLE "promotions"."loyalty_tiers"
        ADD CONSTRAINT "fk_loyalty_tiers_loyalty_program_id" FOREIGN KEY ("loyalty_program_id")
        REFERENCES "promotions"."loyalty_programs" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "promotions"."loyalty_memberships"
        ADD CONSTRAINT "fk_loyalty_memberships_loyalty_program_id" FOREIGN KEY ("loyalty_program_id")
        REFERENCES "promotions"."loyalty_programs" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "promotions"."loyalty_memberships"
        ADD CONSTRAINT "fk_loyalty_memberships_current_tier_id" FOREIGN KEY ("current_tier_id")
        REFERENCES "promotions"."loyalty_tiers" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "promotions"."points_ledger_entries"
        ADD CONSTRAINT "fk_points_ledger_entries_loyalty_membership_id" FOREIGN KEY ("loyalty_membership_id")
        REFERENCES "promotions"."loyalty_memberships" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "promotions"."points_ledger_entries"
        ADD CONSTRAINT "fk_points_ledger_entries_earning_rule_id" FOREIGN KEY ("earning_rule_id")
        REFERENCES "promotions"."earning_rules" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "promotions"."earning_rules"
        ADD CONSTRAINT "fk_earning_rules_loyalty_program_id" FOREIGN KEY ("loyalty_program_id")
        REFERENCES "promotions"."loyalty_programs" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "promotions"."discount_rules"
        ADD CONSTRAINT "fk_discount_rules_promotion_id" FOREIGN KEY ("promotion_id")
        REFERENCES "promotions"."promotions" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "promotions"."coupons"
        ADD CONSTRAINT "fk_coupons_promotion_id" FOREIGN KEY ("promotion_id")
        REFERENCES "promotions"."promotions" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "promotions"."redemptions"
        ADD CONSTRAINT "fk_redemptions_promotion_id" FOREIGN KEY ("promotion_id")
        REFERENCES "promotions"."promotions" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "promotions"."redemptions"
        ADD CONSTRAINT "fk_redemptions_coupon_id" FOREIGN KEY ("coupon_id")
        REFERENCES "promotions"."coupons" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "promotions"."redemptions"
        ADD CONSTRAINT "fk_redemptions_discount_rule_id" FOREIGN KEY ("discount_rule_id")
        REFERENCES "promotions"."discount_rules" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "promotions"."member_referrals"
        ADD CONSTRAINT "fk_member_referrals_referral_program_id" FOREIGN KEY ("referral_program_id")
        REFERENCES "promotions"."referral_programs" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "promotions"."member_referrals"
        ADD CONSTRAINT "fk_member_referrals_referrer_reward_ledger_id" FOREIGN KEY ("referrer_reward_ledger_id")
        REFERENCES "promotions"."loyalty_memberships" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE "promotions"."member_referrals"
        ADD CONSTRAINT "fk_member_referrals_referee_reward_ledger_id" FOREIGN KEY ("referee_reward_ledger_id")
        REFERENCES "promotions"."loyalty_memberships" ("id");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;
