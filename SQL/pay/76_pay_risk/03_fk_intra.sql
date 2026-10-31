-- SALUD v4.2.68 · módulo 76 · schema pay_risk
-- Generado de diagram_76_pay_risk.puml — NO editar a mano.


DO $$ BEGIN
    ALTER TABLE "risk_assessments"
        ADD CONSTRAINT "fk_risk_assessments_rule_version" FOREIGN KEY ("rule_version")
        REFERENCES "risk_rule_sets" ("version");
EXCEPTION WHEN duplicate_object THEN NULL; END $$;
