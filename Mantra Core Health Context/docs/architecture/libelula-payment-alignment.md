# Pasarela de pagos — alineación conceptual con Libélula

## Flujo modelado

`payment_debt -> payment_debt_lines -> registro proveedor -> payment_checkout_session -> redirección/canal -> callback -> verificación -> consulta de estado -> payment_transaction -> recibo/factura -> conciliación`.

## Capacidades incorporadas

- Catálogo de canales y mapping por conexión.
- Registro de deudas, líneas, vencimiento, moneda, saldo y factura asociada.
- Sesión de checkout con token hasheado, URL, expiración e ID externo.
- Catálogo de operaciones del proveedor y attempts redacted con correlación/reintento.
- Endpoints de callback, eventos recibidos, deduplicación y verificación.
- Consulta independiente del estado del pago.
- Cancelación, regeneración de factura, artefactos fiscales y recibos.
- Reconciliación con el registro del proveedor y excepciones.

## Regla de seguridad

Una redirección o callback no cambia por sí sola la deuda a pagada. Deben concordar autenticidad, idempotencia, ID externo, monto, moneda y estado consultado/conciliado antes del efecto contable.

## Fuente oficial revisada

- Guía de integración para empresas v2.145: https://libelula.bo/Libelula%20Manual%20de%20Integraci%C3%B3n%20v2.145.pdf
- Manual anterior v2.7.2: https://libelula.bo/wp-content/uploads/2020/12/Libelula-Manual-de-Integracion-v2.7.2.pdf

## Límite de la alineación

Esto es un modelo proveedor-agnóstico compatible con el flujo documentado. La integración real exige credenciales, endpoints, códigos y contratos actuales entregados por Libélula; no se inventaron secretos ni respuestas no publicadas.
