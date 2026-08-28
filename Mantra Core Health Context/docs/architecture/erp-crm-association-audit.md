# Auditoría de asociaciones ERP, finanzas, contratos y CRM — SALUD v3.7

## Hallazgo principal

El modelo v3.6 contenía varias claves foráneas importantes, pero algunas no estaban
representadas visualmente y no existía una cadena completa desde el contrato/documento
operativo hasta el asiento, la línea contable y el objeto económico afectado.

## Patrón financiero adoptado

La relación no se coloca únicamente en `journal_transactions` porque un asiento puede
contener muchas líneas y afectar simultáneamente activos, pasivos, business partners,
centros de costo, proyectos y contratos. La asociación correcta vive en la línea mediante
`journal_entry_assignments`, equivalente conceptual a una persistencia universal de
partidas con dimensiones de GL, activos, controlling y rentabilidad.

Cadena objetivo:

```text
Business Partner
→ Contract / Sales Order / Purchase Order
→ Goods Receipt / Service Entry / Invoice / Bill
→ Payment / Clearing
→ Journal Transaction
→ Ledger Entry
→ Journal Entry Assignment
→ Asset / Liability / Contract / Project / Cost Center / Profit Center / Bank Account
```

## Benchmark SAP utilizado

- Universal Journal: persistencia común de partidas para General Ledger, Profit Center,
  Fixed Asset Accounting, Material Ledger, Controlling y Profitability Analysis.
- Business Partner: una misma contraparte puede asumir roles de cliente y proveedor.
- Enterprise Contract Management: repositorio y ciclo de vida legal con documentos,
  aprobaciones, equipos/responsabilidades, obligaciones, enmiendas y renovaciones.
- Contract and Lease Management: los contratos de arrendamiento producen activo por
  derecho de uso, pasivo de arrendamiento, cash flows y valuaciones.
- Invoice Verification: asociación de factura con orden y recepción para matching de dos
  o tres vías.

## Benchmark Salesforce utilizado

Salesforce separa Task y Event como actividades y usa relaciones WHO/WHAT; las relaciones
adicionales permiten participantes múltiples e invitados. SALUD conserva una entidad padre
`crm_activities` y agrega subtipos y `crm_activity_relations` con referencias explícitas a
cuenta, contacto, lead, oportunidad, contrato, partnership y caso.

## Constraints requeridos en migraciones

- `journal_entry_assignments`: UNIQUE(`ledger_entry_id`) y coherencia tenant.
- `crm_activity_relations`: exactamente una referencia concreta no nula por fila.
- `contract_object_assignments`: exactamente un objeto asignado por fila.
- `contract_payment_schedules`: la dirección define si debe generarse factura o bill.
- `lease_accounting_links`: activo RoU y pasivo pertenecen al mismo tenant/contrato.
- `invoice_match_items`: no aceptar factura cuando la tolerancia se excede sin aprobación.
- `open_items.outstanding_amount >= 0` y clearing acumulado no superior al saldo.
- Asientos publicados, asset/liability postings y clearing son append-only.
