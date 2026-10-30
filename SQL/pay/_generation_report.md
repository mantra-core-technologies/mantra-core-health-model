# Reporte de generación — perfil pay (SALUD v4.0.10)

Generado de `Mantra Core Health Context/pay-modules/*.puml` por `salud-db/gen_ddl_pay.py`. Una BASE por módulo; objetos sin calificar. Las FK de una columna salen del generador base (`fk_<tabla>_<col>`); las compuestas, los CHECK, las funciones y los triggers salen de `PAY_EXTRAS`.

| Mód | Base | Tablas | FK (1 col) | FK compuestas | Índices (no PK) | CHECK | Defaults no bool. | Identidades | Funciones | Triggers | Semillas |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 70 | pay_connectors | 13 | 2 | 0 | 18 | 45 | 24 | 0 | 3 | 6 | 0 |
| 71 | pay_edge | 3 | 0 | 0 | 1 | 3 | 4 | 0 | 0 | 0 | 0 |
| 72 | pay_ledger | 9 | 1 | 5 | 11 | 24 | 10 | 0 | 0 | 0 | 0 |
| 73 | pay_merchants | 11 | 6 | 1 | 8 | 25 | 17 | 0 | 1 | 8 | 0 |
| 74 | pay_payments | 11 | 3 | 0 | 12 | 16 | 26 | 0 | 0 | 0 | 0 |
| 75 | pay_qr | 2 | 0 | 0 | 4 | 10 | 3 | 0 | 0 | 0 | 0 |
| 76 | pay_risk | 3 | 1 | 0 | 5 | 17 | 3 | 0 | 1 | 4 | 1 |
| 77 | pay_schedules | 6 | 1 | 0 | 7 | 19 | 13 | 0 | 0 | 0 | 0 |
| 78 | pay_settlement | 16 | 7 | 0 | 13 | 48 | 33 | 2 | 0 | 0 | 0 |
| 79 | pay_vault | 4 | 0 | 0 | 4 | 7 | 6 | 0 | 0 | 0 | 0 |
| 80 | pay_webhooks | 6 | 3 | 0 | 4 | 8 | 12 | 0 | 0 | 0 | 0 |
| 81 | pay_lib | 3 | 0 | 0 | 3 | 1 | 5 | 0 | 0 | 0 | 0 |
| **Σ** | **12** | **87** | **24** | **6** | **90** | **223** | **156** | **2** | **5** | **18** | **1** |
