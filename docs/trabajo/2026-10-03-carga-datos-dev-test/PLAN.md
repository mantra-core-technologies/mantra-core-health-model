# Plan — Datos visibles en Dev y Test

- Fecha: 2026-10-03 · Repos afectados: API, modelo y frontend en Contabo · Predecesor: reconstrucción Dev del 2026-10-02
- Resultado observable: Dev y Test conservan sus datos y muestran catálogos, profesionales y datos de demostración cargados por los mecanismos existentes.
- Kill-test: una consulta pública y los conteos de las tablas principales siguen vacíos tras la carga.

## Alcance

- IN: inventario de datos existentes, respaldos, carga aditiva de seeds del modelo donde falten, verificación de integridad y lecturas reales.
- OUT: reinicio destructivo de bases, copia de datos de producción, publicación de credenciales, importación MeSH de 1,4 millones de filas sin dependencia funcional.
- Ambigüedad: «todos los datos» se interpreta como catálogos y demostración sintética del modelo y la profundidad visible del mockup. Confirmar con el propietario cualquier módulo que no tenga importador real.

## H1 — Inventario y respaldo

**CA:** Dado Dev y Test, cuando se inspeccionan, entonces se conocen sus conteos y existe respaldo restaurable antes de escribir.
**DoD:** Consultas agregadas sin PHI y `pg_dump -Fc` con `pg_restore --list` exitoso para cada base.
**Estado:** HECHO

### H1.S1 — Medir y proteger

**CA:** Dado cada entorno, cuando se cuenta su contenido, entonces se documentan las diferencias sin exponer datos personales. **DoD:** Consultas SQL agregadas y lista de respaldos. **Estado:** HECHO

| ID | Microtarea | CA (binario) | DoD (comando de verificación) | Estado |
|---|---|---|---|---|
| H1.S1.M1 | Contar datos base y demo | Conteos por entorno registrados | `psql` con `count(*)` → dos inventarios | HECHO |
| H1.S1.M2 | Respaldar PostgreSQL Dev y Test | Dos dumps legibles | `pg_restore --list` → exit 0 en ambos | HECHO |
| H1.S1.M3 | Comparar respaldo previo al reinicio | Se conoce si contenía más profundidad operativa | `pg_restore --section=pre-data --section=data` en base temporal y `count(*)` agregados; eliminar base temporal | HECHO |

## H2 — Cargar lo faltante

**CA:** Dado el paquete de seeds del modelo, cuando se ejecuta en el entorno correspondiente, entonces agrega filas sin borrar las existentes.
**DoD:** Salida del cargador con resumen, conteos posteriores y segunda ejecución idempotente o comparación equivalente.
**Estado:** HECHO

### H2.S1 — Catálogos y demo

**CA:** Dado un entorno sin el paquete completo, cuando se carga, entonces aparecen catálogos y demo. **DoD:** Comandos de carga y lecturas API. **Estado:** HECHO

| ID | Microtarea | CA (binario) | DoD (comando de verificación) | Estado |
|---|---|---|---|---|
| H2.S1.M1 | Cargar paquete en Test | Carga termina sin errores ni huérfanos | `load_seeds.py --skip-prod` → exit 0 y verificador FK → 0 | HECHO |
| H2.S1.M2 | Comprobar Dev | Datos existentes íntegros y visibles | verificaciones SQL y HTTP → conteos esperados | HECHO |
| H2.S1.M3 | Reconciliar colisiones nuevas de catálogos | Ninguna referencia huérfana tras la carga | `psql -v ON_ERROR_STOP=1 -f salud-db/demo/00-huerfanas-post-carga.sql` → 0 huérfanas; segunda corrida → 0 cambios | HECHO |
| H2.S1.M4 | Acotar publicación del demo | Ningún post ajeno al paquete cambia | `psql -v ON_ERROR_STOP=1 -f runtime/01-conceptos-demo-test-acotado.sql` → `UPDATE 16` para posts | HECHO |

## H3 — Verificar visibilidad

**CA:** Dado ambos entornos cargados, cuando se accede por sus dominios, entonces las pantallas consumen datos de la API real.
**DoD:** Consultas HTTP y recorrido de navegador dirigidos, con reporte de cualquier ruta que permanezca vacía.
**Estado:** A MEDIAS

### H3.S1 — Flujo visible

**CA:** Dado un perfil publicado, cuando se abre el directorio real, entonces aparece. **DoD:** HTTP y navegador sobre Dev y Test. **Estado:** A MEDIAS

| ID | Microtarea | CA (binario) | DoD (comando de verificación) | Estado |
|---|---|---|---|---|
| H3.S1.M1 | Verificar endpoints de ambos entornos | Dev y Test devuelven resultados esperados | `curl` → HTTP 200 y conteos | HECHO |
| H3.S1.M2 | Documentar diferencias con mockup | Los módulos aún vacíos quedan identificados | inventario de fixtures ↔ seeds/APIs | A MEDIAS |
| H3.S1.M3 | Auditar conceptos de relleno | El alcance de `DEFAULT_*` queda cuantificado | SQL de referencias por 11 esquemas → agregados por entorno | HECHO |
| H3.S1.M4 | Recorrer pantallas reales | Directorio y muro se ven poblados | navegador en Dev y Test → capturas y red limpia | BLOQUEADO |

## H4 — Recuperar perfiles sintéticos anteriores en Test

**CA:** Dado el respaldo sintético del 27/09 confirmado por el propietario, cuando se incorporan las filas faltantes, entonces los pacientes antiguos vuelven a Test sin reemplazar los actuales.
**DoD:** Copia previa restaurable, fusión ensayada en transacción revertida, ejecución aditiva y consultas de integridad y API.
**Estado:** HECHO

### H4.S1 — Fusionar el subconjunto de cuentas y perfiles

**CA:** Dado un perfil antiguo, cuando se consulta Test, entonces su persona, cuenta y dependencias necesarias existen. **DoD:** Conteos de IDs de respaldo recuperados y verificador FK → 0 huérfanas. **Estado:** HECHO

| ID | Microtarea | CA (binario) | DoD (comando de verificación) | Estado |
|---|---|---|---|---|
| H4.S1.M1 | Respaldar Test y aislar origen | Dos estados independientes para comparar y volver atrás | `pg_dump -Fc`, `pg_restore --list`, `pg_restore --section=pre-data --section=data` → exit 0 | HECHO |
| H4.S1.M2 | Identificar cierre de dependencias | Sólo se copian filas antiguas requeridas para las cuentas y perfiles | 11 tablas, preflight FK → 0 referencias faltantes | HECHO |
| H4.S1.M3 | Ensayar fusión reversible | La fusión no rompe restricciones ni pisa registros actuales | `recuperar_perfiles_test.py` sin `--apply` → 96/96 pacientes, `ROLLBACK` | HECHO |
| H4.S1.M4 | Aplicar fusión en Test | Los 96 perfiles antiguos están en Test sin perder los existentes | `recuperar_perfiles_test.py --apply` → `COMMIT`; `--audit` → 0 filas pendientes | HECHO |
| H4.S1.M5 | Comprobar lecturas finales | API y base muestran los perfiles recuperados | HTTP autenticado → 161 pacientes, 42 profesionales; FK → 0 huérfanas | HECHO |

## Riesgos y bloqueos previstos

| Riesgo | Impacto | Mitigación |
|---|---|---|
| Colisión de claves naturales entre seeds del modelo y API | Carga parcial | Respaldo, carga por módulo, informe de errores, ninguna limpieza automática |
| Datos sintéticos junto a cuentas existentes en Test | Confusión | Identificar por origen y no reemplazar cuentas actuales |
| Proyección pública no materializada | Respuesta vacía aunque existan perfiles | Verificar la ruta que usa la pantalla y registrar el defecto por separado |
