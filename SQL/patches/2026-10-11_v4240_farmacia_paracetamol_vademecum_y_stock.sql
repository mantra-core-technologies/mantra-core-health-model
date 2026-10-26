-- 2026-10-11 · "Dónde comprar mi receta" necesita (a) que el producto de farmacia
-- apunte al medicamento del vademécum que receta el médico y (b) existencias en
-- las sucursales. Sin (a) la pantalla dice "Sin producto publicado"; sin (b) la
-- disponibilidad no ofrece ninguna sede. Idempotente.
-- (a) Paracetamol → clinical:MEDICATION_PARACETAMOL.
UPDATE pharmacy.pharmacy_products p
   SET medication_concept_id = c.id, updated_at = now()
  FROM terminology.catalog_concepts c
 WHERE c.code = 'clinical:MEDICATION_PARACETAMOL'
   AND p.medication_concept_id IS NULL
   AND lower(p.generic_name) = 'paracetamol';

-- (b) 100 unidades de cada producto con precio vigente, en cada ubicación de
-- inventario de las sucursales de SU farmacia, donde no haya posición todavía.
INSERT INTO pharmacy_inventory.inventory_stock_positions
  (id, inventory_location_id, pharmacy_product_id, on_hand_quantity, reserved_quantity,
   quarantine_quantity, available_quantity, last_ledger_sequence, updated_at, row_version)
SELECT gen_random_uuid(), l.id, p.id, 100, 0, 0, 100, 0, now(), 1
  FROM pharmacy_inventory.inventory_locations l
  JOIN pharmacy.pharmacy_sites s ON s.id = l.pharmacy_site_id
  JOIN pharmacy.pharmacy_products p ON p.pharmacy_id = s.pharmacy_id
 WHERE EXISTS (SELECT 1 FROM pharmacy.pharmacy_product_prices pr WHERE pr.pharmacy_product_id = p.id)
   AND NOT EXISTS (SELECT 1 FROM pharmacy_inventory.inventory_stock_positions sp
                    WHERE sp.inventory_location_id = l.id AND sp.pharmacy_product_id = p.id);
