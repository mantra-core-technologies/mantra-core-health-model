-- v4.2.13 — la versión de precio es por producto, no por lista completa.
-- El único uq_pharmacy_product_prices_pharmacy_price_list_id_vers_7ebb36be
-- sólo cubría (pharmacy_price_list_id, version_number): el servicio calcula
-- la próxima versión por (lista, producto) -- PharmacyPricingService.maxVersionNumber --
-- así que el segundo producto de cualquier lista con más de un producto choca
-- con la versión 1 del primero. Ampliar la clave para incluir
-- pharmacy_product_id no puede romper filas existentes: toda fila válida bajo
-- la clave vieja (más estricta) sigue siendo válida bajo la nueva.
BEGIN;

DROP INDEX IF EXISTS "pharmacy"."uq_pharmacy_product_prices_pharmacy_price_list_id_vers_7ebb36be";

CREATE UNIQUE INDEX IF NOT EXISTS "uq_pharmacy_product_prices_pharmacy_price_list_id_vers_7ebb36be"
  ON "pharmacy"."pharmacy_product_prices" ("pharmacy_price_list_id", "pharmacy_product_id", "version_number");

COMMIT;
