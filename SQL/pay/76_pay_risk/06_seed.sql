-- SALUD v4.0.10 · perfil pay · módulo 76 · base pay_risk
-- Generado de diagram_76_pay_risk.puml — NO editar a mano.

-- Filas de configuración declaradas por el modelo (SEED_SQL). Idempotentes.

-- Versión 1 = SIN límites: es la ausencia declarada de reglas, no un número inventado. Idempotente.
INSERT INTO risk_rule_sets (version, effective_from, published_by) VALUES (1, '2000-01-01T00:00:00Z', 'system:no-limits') ON CONFLICT (version) DO NOTHING;
