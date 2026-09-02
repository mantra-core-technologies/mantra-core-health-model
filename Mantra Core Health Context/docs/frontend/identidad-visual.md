<!-- Espejo plano de Mantra Core Health Vault/SALUD/Arquitectura/identidad-visual.md.
     Los dos archivos se actualizan JUNTOS (convención de CLAUDE.md).
     La versión del vault es la que tiene los wikilinks al grafo. -->
# Identidad visual — Sistema de Diseño REDSAT y marca corporativa

> Espejo plano: `Mantra Core Health Context/docs/frontend/identidad-visual.md`.
> **Los dos se actualizan juntos** (convención de `CLAUDE.md`). Esta versión del vault es la que
> lleva los wikilinks al grafo.

> Dos sistemas distintos, y no hay que confundirlos:
> **Mantra Core Technologies** es la empresa padre y tiene su propia identidad (Parte 1,
> extraída del portafolio corporativo). El **sistema médico** que desarrolla es un producto
> aparte, cuya identidad es el **Sistema de Diseño REDSAT v1.0** (Parte 2 en adelante).

> **INFO** — Adopción del Sistema de Diseño REDSAT (2026-07-29)
> El diseñador (Mateo Ribera Caballero, Área Comercial) entregó `REDSAT_Sistema_de_Diseno.html`
> (raíz del repo): la traducción del **Manual de Identidad Corporativa REDSAT v1.0 — julio 2026**
> a sistema de producto digital. Se adoptó como **identidad oficial** con estas decisiones:
> 1. **Reemplazo total** del sistema anterior (que ya compartía los mismos 6 colores de marca).
> 2. **Tipografía Opción A**: Poppins (display) + Inter (cuerpo y datos). Las alternativas del
>    documento (Sora, Plus Jakarta Sans, Manrope) quedaron descartadas.
> 3. **El hex del manual manda**: si un par no llega al umbral WCAG, no se ajusta el tono — se
>    registra como excepción (Parte 8) y se avisa al diseñador.
> 4. **Solo tokens, sin renombrar**: la UI sigue diciendo *Mantra Core Health* hasta que la marca
>    REDSAT se confirme como nombre de producto. Repos y paquetes no se tocan.
>
> El HTML del diseñador queda como **spec viva de componentes** (botones, inputs, badges,
> modales, tablas, header/sidebar): no se portan a Angular/Flutter hasta que existan pantallas.

---

# Parte 1 · La marca corporativa (Mantra Core Technologies)

Contexto, no especificación de producto. Extraído de `Portafolio Mantra.pdf` (raíz del repo,
122,6 MB, 9 páginas, `%PDF-1.5`, íntegramente RGB).

> **NOTE** — Cómo se obtuvieron estos datos
> No hay lector de PDF ni poppler en el entorno y el archivo supera el límite de extracción de
> texto. Los valores **no están leídos a ojo**: salen de los operadores de color `rg`/`RG` de
> los content streams (la mayoría sin comprimir; los 107 `FlateDecode` inflados con `zlib` en
> deflate crudo) y del texto `Tj`/`TJ` de la página «PALETA DE COLOR».

Tipografías vivas: `LEDLIGHT` y `MyriadPro-Regular`; el resto del texto está vectorizado.

## 1.1 · Paleta declarada — 12 colores

| Hex | RGB | Lectura | Usos en el doc |
|---|---|---|---|
| `#8A6FA8` | 138, 111, 168 | violeta apagado | 2 |
| `#538CA2` | 83, 140, 162 | azul acero | 2 |
| `#525E8E` | 82, 94, 142 | índigo | 64 |
| `#B53C3D` | 181, 60, 61 | rojo ladrillo | 2 |
| `#A69790` | 166, 151, 144 | topo / greige | 2 |
| `#B86B39` | 184, 107, 57 | terracota | 2 |
| `#EAC2BB` | 234, 194, 187 | rosa empolvado | 2 |
| `#E8E1D6` | 232, 225, 214 | hueso | 2 |
| `#6E827A` | 110, 130, 122 | salvia | 2 |
| `#5C756D` | 92, 117, 109 | verde pizarra | 2 |
| `#000000` | 0, 0, 0 | negro | 6 |
| `#FFFFFF` | 255, 255, 255 | blanco | 376 |

## 1.2 · Paleta realmente aplicada — la rampa de azul

Concentrada en tres content streams enormes (2,1 MB · 1,2 MB · 840 KB): la ilustración
vectorial de marca.

| Hex | RGB | Usos |
|---|---|---|
| `#1E2B44` | 30, 43, 68 | 3 077 |
| `#3F4E72` | 63, 78, 114 | 2 173 |
| `#35425E` | 53, 66, 94 | 1 319 |
| `#233259` | 35, 50, 89 | 766 |
| `#525E8E` | 82, 94, 142 | 64 |
| `#12223A` | 18, 34, 58 | 12 |

## 1.3 · Hallazgos

> **WARNING** — La paleta declarada y la aplicada casi no se solapan
> Los diez tonos cromáticos de la página normativa aparecen **exactamente dos veces cada uno**
> — su propio swatch y nada más. Lo que viste la marca en las 9 páginas es la rampa de azul,
> que **no figura en la página de paleta**. `#525E8E` es el único puente.

Erratas del portafolio:

- **`#B86B39`** — hex y swatch coinciden en 184, 107, **57**; el rótulo RGB impreso dice **87**
  (que sería `#B86B57`). Manda el swatch.
- Declara `#000000` pero compone su propio texto en **`#1D1D1B`**. El negro puro está declarado
  y no usado.
- `#5C756D` se pinta como `#5D766D`: ±1 por redondeo de float, no es error.

## 1.4 · Relación con el producto

El azul corporativo `#1E2B44` (H 217°) y el **Azul Petróleo** `#0B557E` (H 201°) de REDSAT son
primos: ambos azules profundos, el del producto algo más cian y mucho más saturado. Hay
continuidad de familia sin que el producto herede la paleta de la empresa. **Ninguno de los
12 colores de la Parte 1 se usa en el sistema médico.**

---

# Parte 2 · Paleta REDSAT — familia de marca y rampas

Los **seis colores de marca** son los mismos del manual original — la continuidad es total:

| Color | Hex | Rol declarado |
|---|---|---|
| **Azul Petróleo** | `#0B557E` | Color de marca. Estructura, confianza. Isotipo monocromático — el ámbar nunca entra en el logotipo. |
| **Aguamarina** | `#4FB3A9` | Acento de vida. Estados activos, acción. |
| **Menta Claro** | `#9FD8D0` | Aire y respiro. Líneas suaves, fondos secundarios. |
| **Ámbar Arena** | `#E4A96B` | Único acento cálido, racionado: **nunca más del 10 % de una pantalla, un solo punto de acción**. |
| **Gris Salvia** | `#CDD9D5` | Neutro calmo. Divisores decorativos (no delimita controles — Parte 8). |
| **Marfil** | `#F6F3ED` | Superficie cálida en claro; **tinta principal en oscuro**. |

> El propio documento lo dice: *«una paleta de tres decisiones, no de veinte colores compitiendo
> por atención»* — sin rojo-cruz ni verde-hospital, azul petróleo saturado (no celeste de stock),
> y un solo cálido deliberadamente racionado.

## 2.1 · Rampas extendidas 50–900

Lo nuevo de REDSAT: cada familia se expande a 10 escalones (el **500 es la base** del manual,
salvo en marfil donde la base es el 500 y los 600–900 son tintas derivadas). Valores literales
del HTML (`:root`, líneas 11–121) — **no se recalculan, se copian**:

| Rampa | 50 | 100 | 200 | 300 | 400 | **500** | 600 | 700 | 800 | 900 |
|---|---|---|---|---|---|---|---|---|---|---|
| **azul** | `#D9E5EB` | `#C2D5DF` | `#95B5C7` | `#6795AF` | `#397596` | `#0B557E` | `#0B4768` | `#0B3953` | `#0A2B3D` | `#0A1C27` |
| **aqua** | `#E4F3F2` | `#D3ECEA` | `#B2DEDA` | `#91D0C9` | `#70C1B9` | `#4FB3A9` | `#41928A` | `#33706C` | `#254F4D` | `#162D2F` |
| **menta** | `#F0F9F8` | `#E7F5F3` | `#D5EEEB` | `#C3E7E2` | `#B1DFD9` | `#9FD8D0` | `#80AFA9` | `#628683` | `#435D5C` | `#253436` |
| **ámbar** | `#FBF2E8` | `#F8EADA` | `#F3DABE` | `#EEC9A3` | `#E9B987` | `#E4A96B` | `#B78A59` | `#8B6A47` | `#5E4B35` | `#312C24` |
| **salvia** | `#F7F9F9` | `#F3F6F5` | `#E9EEED` | `#E0E7E5` | `#D6E0DD` | `#CDD9D5` | `#A5B0AD` | `#7D8786` | `#555D5E` | `#2D3437` |
| **marfil** | `#FEFDFC` | `#FDFCFB` | `#FBFAF7` | `#F9F8F4` | `#F8F5F0` | `#F6F3ED` | `#C6C4C1` | `#959694` | `#656768` | `#34393B` |
| **neutral** | `#E1E2E2` | `#CCCDCD` | `#A2A4A4` | `#787B7B` | `#4E5151` | `#242828` | `#1E2324` | `#181D1F` | `#12181A` | `#0D1216` |

## 2.2 · Rampas semánticas — la escala de estados que antes no existía

REDSAT llena el hueco más grande del sistema anterior (que declaraba explícitamente «sin estados
semánticos»). Cuatro familias, también 50–900:

| Rampa | 50 | 100 | 200 | 300 | 400 | **500** | 600 | 700 | 800 | 900 |
|---|---|---|---|---|---|---|---|---|---|---|
| **success** | `#DFEDE9` | `#CBE2DB` | `#A4CCC0` | `#7DB7A5` | `#55A189` | `#2E8B6E` | `#27725C` | `#1F5949` | `#183F37` | `#102624` |
| **warning** | `#FBF2E8` | `#F8EADA` | `#F3DABE` | `#EEC9A3` | `#E9B987` | `#E4A96B` | `#B78A59` | `#8B6A47` | `#5E4B35` | `#312C24` |
| **error** | `#F4E5E1` | `#EDD4CF` | `#DFB4AA` | `#D19485` | `#C37361` | `#B5533C` | `#924534` | `#6F382C` | `#4C2A23` | `#291C1B` |
| **info** | `#E4F3F2` | `#D3ECEA` | `#B2DEDA` | `#91D0C9` | `#70C1B9` | `#4FB3A9` | `#41928A` | `#33706C` | `#254F4D` | `#162D2F` |

Notas de lectura: **warning ≡ rampa ámbar** e **info ≡ rampa aqua** (aliasadas a propósito — la
paleta no crece, se reinterpreta); **error** es un terracota `#B5533C`, no un rojo-cruz; y
**success** es un verde bosque `#2E8B6E` distinto de la aguamarina.

> **DANGER** — Los `st-*` son semántica de PRODUCTO, no severidad clínica
> Success/warning/error/info cubren formularios, procesos y mensajes del sistema (aprobado,
> pendiente, rechazado, informativo). La **escala de severidad clínica**
> (crítico / alerta / estable / indeterminado) **sigue pendiente** — ver Parte 11. Cuando se
> defina, estas rampas son el material del que derivarla en armonía; mientras tanto, no usar
> `st-error` como atajo para «paciente crítico».

---

# Parte 3 · Tokens semánticos por tema

La tabla que el diseñador marcó como «la referencia que el equipo de front necesita al
programar» (HTML líneas 1348–1411), extendida con los tokens de borde/sombra/foco del `:root`:

| Token | Uso | Claro | Oscuro |
|---|---|---|---|
| `--bg-base` | lienzo de la app | `#FFFFFF` | `#0A1C27` (azul-900) |
| `--bg-surface` | tarjetas, paneles, modales | `#FFFFFF` | `#0A2B3D` (azul-800) |
| `--bg-surface-alt` | secciones secundarias, sidebar | `#F8F5F0` (marfil-400) | `#0B3953` (azul-700) |
| `--bg-inset` | inputs, huecos | `#F9F8F4` (marfil-300) | `#0F2E42` |
| `--text-primary` | títulos y cuerpo | `#242828` (neutral-500) | `#F6F3ED` (marfil-500) |
| `--text-secondary` | subtítulos, metadatos | `#4E5151` (neutral-400) | `#E9EEED` (salvia-200) |
| `--text-muted` | terciario, hints | `#787B7B` (neutral-300) | `#A5B0AD` (salvia-600) |
| `--text-inverse` | texto sobre rellenos de marca | `#FFFFFF` | `#0A1C27` |
| `--brand-primary` | botón principal, enlaces clave | `#0B557E` (azul-500) | `#70C1B9` (aqua-400) |
| `--brand-primary-hover` | | `#0B4768` | `#91D0C9` |
| `--brand-primary-active` | | `#0B3953` | `#4FB3A9` |
| `--brand-secondary` | acento vital: activos, selección | `#4FB3A9` (aqua-500) | `#C3E7E2` (menta-300) |
| `--brand-secondary-hover` | | `#41928A` | `#D5EEEB` |
| `--brand-accent` | el único punto cálido | `#E4A96B` (ámbar-500) | `#E9B987` (ámbar-400) |
| `--border-default` | divisores decorativos | `#CDD9D5` (salvia-500) | `rgba(255,255,255,.12)` |
| `--border-strong` | bordes que delimitan | `#7D8786` (salvia-700) | `rgba(255,255,255,.24)` |
| `--focus-ring` | anillo de foco (4 px) | `rgba(79,179,169,.45)` | `rgba(159,216,208,.45)` |
| `--shadow-sm/md/lg` | elevación | sombras azuladas `rgba(11,85,126,…)` | sombras negras `rgba(0,0,0,…)` |
| `--st-success-bg/fg/bd` | badge/nota éxito | 50 / 700 / 200 | 800 / 200 / 600 |
| `--st-warning-bg/fg/bd` | badge/nota advertencia | 50 / 700 / 200 | 800 / 200 / 600 |
| `--st-error-bg/fg/bd` | badge/nota error | 50 / 700 / 200 | 800 / 200 / 600 |
| `--st-info-bg/fg/bd` | badge/nota información | 50 / 700 / 200 | 800 / 200 / 600 |

Los `st-*` siguen un patrón fijo: **fondo claro + texto oscuro del mismo tono** en claro
(escalones 50/700/200) y fondo hundido + texto claro en oscuro (800/200/600). *«Nunca color
sólido con texto blanco»* — regla literal del documento para badges.

### 3.1 · Chips de marca — extensión propia (2026-07-30)

El spec cubre los 4 estados, pero no un chip de **tono de marca** (un badge «primary» o
«secondary»). Se agregaron dos tríos con la misma receta, en `styles.css`:

| Token | Claro | Ratio | Oscuro | Ratio |
|---|---|---|---|---|
| `--st-primary-bg/fg/bd` | petrol 50 / **700** / 200 | 9,49:1 | petrol **600 / 100 / 400** | 6,56:1 |
| `--st-secondary-bg/fg/bd` | mint 50 / **800** / 300 | 6,62:1 | mint 800 / 200 / 600 | 5,83:1 |

Dos desvíos deliberados del patrón, ambos medidos:

- **`secondary` usa mint-800, no 700.** Menta-700 `#628683` sobre menta-50 da **3,73:1** y no
  llega a AA con texto chico (el badge es de 11,5 px). Con el 800 sube a 6,62:1.
- **`primary` en oscuro usa 600/100/400, no 800/200/600.** Petrol-800 **es** `--bg-surface` en
  oscuro: el chip desaparecería sobre una tarjeta. El 600 queda por encima de las cuatro
  superficies oscuras.

> **NOTE** — Por qué no se usó aguamarina para `secondary`
> `--brand-secondary` es aqua, pero `--c-info-*` **ya es un alias de aqua**: un chip
> `secondary` en aqua sería indistinguible de uno `info`. Menta es la familia de marca
> contigua y mantiene la distinción. Pendiente de validación del diseñador.

---

# Parte 4 · Modo oscuro — el azul estructura, la aguamarina acciona

El principio del sistema anterior sobrevive («en oscuro el petróleo deja de ser tinta y pasa a
ser tierra»), pero REDSAT lo resuelve **sin inventar colores**:

> **IMPORTANT** — En oscuro las superficies SON la rampa del azul petróleo
> `#0A1C27 → #0A2B3D → #0B3953` son azul-900/800/700 del propio manual. Y como el azul ya no
> puede ser el color de acción sobre sí mismo, **la aguamarina toma el rol de primario de
> interacción** (`#70C1B9`, aqua-400) — *«garantizando contraste suficiente sin introducir un
> color ajeno a la marca»*. El `#4FA3CC` (petróleo aclarado) del sistema anterior **queda
> retirado**: era un color inventado, y REDSAT lo reemplaza con un escalón real de la rampa aqua.

Adaptaciones de la regla de proporción:

| Regla en claro | En oscuro |
|---|---|
| Blanco = base | Azul-900 `#0A1C27` = base; la familia del petróleo ocupa el 100 % como lienzo |
| Petróleo = acción primaria | **Aqua-400 `#70C1B9`** = acción primaria; el secundario sube a menta-300 `#C3E7E2` |
| Menta 20–30 % | Extremo bajo (20 %): sobre fondo oscuro salta más |
| Ámbar ≤ 10 %, un punto por pantalla | **Sin cambios** — la regla más fuerte. El acento sube medio escalón a ámbar-400 `#E9B987` |

Y el rol que no cambia: **el Marfil sigue pasando de papel a tinta** (`#F6F3ED` como
`--text-primary`, 15,69 sobre la base). Ese matiz cálido sobre el azul frío es lo que evita el
dark mode genérico.

---

# Parte 5 · Tipografía — Poppins + Inter

El manual define Poppins para marca e Inter para cuerpo. Cuatro roles anclados a los cuatro
valores corporativos de REDSAT:

| Valor | Tipografía | Uso |
|---|---|---|
| Grandeza | Poppins Bold (700) | Display y wordmark |
| Confianza | Poppins SemiBold (600) | Encabezados de sección |
| Empatía | Inter Regular (400) | Cuerpo de texto |
| Seguridad | Inter Medium/SemiBold + **cifras tabulares** | Dosis, fechas, montos — imposibles de confundir por espaciado irregular |

## 5.1 · Escala tipográfica (9 roles)

| Rol | Familia · peso | Tamaño / interlínea |
|---|---|---|
| Display | Poppins 700 | 44 / 50 px |
| H1 | Poppins 600 | 32 / 40 px |
| H2 | Poppins 600 | 26 / 34 px |
| H3 | Poppins 500 | 21 / 28 px |
| Cuerpo grande | Inter 400 | 17 / 27 px |
| Cuerpo | Inter 400 | 15 / 23 px |
| Caption | Inter 500 | 13 / 18 px |
| Overline | Inter 700 | 11 px · tracking +8 % · MAYÚSCULAS |
| Datos / cifras | Inter 600 tabular | 15 px |

## 5.2 · Alojamiento — siempre autoalojadas

El HTML del diseñador carga Google Fonts; **el proyecto no**: convención de fuentes
autoalojadas en ambas superficies.

- **Web**: `@fontsource-variable/inter` (ya estaba) + `@fontsource/poppins` pesos estáticos
  500/600/700 — **Poppins no tiene versión variable**. Lora se retiró.
- **Flutter**: Inter Variable `.ttf` (ya estaba) + Poppins `.ttf` estáticas 500/600/700 en
  `assets/fonts/` con licencia SIL OFL 1.1. Lora y su licencia se retiraron.

> **IMPORTANT** — Asimetría variable/estática que hay que conocer
> **Inter es variable**: en Flutter el peso se mueve con `FontVariation('wght', N)` —
> `fontWeight` a secas no cambia el trazo. **Poppins es estática**: se declaran los tres pesos
> en `pubspec.yaml` y `fontWeight` funciona de forma normal. Las dos convenciones conviven en
> `MantraTypography` y hay tests que las fijan.

Cifras tabulares: `.cifras-tabulares` (web) / `MantraTypography.cifrasTabulares` (Flutter) —
obligatorias en columnas de resultados, dosis y montos.

---

# Parte 6 · Espaciado, radios y sombras

Capas que el sistema anterior no tenía. Dos reglas resuelven el 90 % de las dudas: **todo
múltiplo de 4 px** y **a mayor jerarquía visual, mayor espacio**.

## 6.1 · Espaciado

| Token | px | Uso real |
|---|---|---|
| `--sp-1` | 4 | ícono ↔ texto (badge) |
| `--sp-2` | 8 | chips, tags |
| `--sp-3` | 12 | padding vertical de botones e inputs |
| `--sp-4` | 16 | padding estándar de inputs y tarjetas chicas |
| `--sp-5` | 20 | padding horizontal de botones medianos |
| `--sp-6` | 24 | padding interno de tarjetas y modales |
| `--sp-8` | 32 | separación entre bloques de una sección |
| `--sp-10` | 40 | padding de modales grandes |
| `--sp-12` | 48 | separación entre grupos de contenido |
| `--sp-16` | 64 | separación entre secciones de página |
| `--sp-20` | 80 | padding vertical de secciones editoriales |

## 6.2 · Radios

| Token | px | Uso |
|---|---|---|
| `--r-xs` | 4 | chips chicos, tags, checkboxes |
| `--r-sm` | 8 | **botones, inputs, badges** |
| `--r-md` | 12 | tarjetas compactas, dropdowns |
| `--r-lg` | 18 | tarjetas estándar, modales, paneles |
| `--r-xl` | 24 | contenedores grandes, hero cards |
| `--r-2xl` | 32 | secciones destacadas de marketing |
| `--r-full` | 999 | avatares, píldoras, botón de ícono |

> **WARNING** — Radio de firma `28px 4px 28px 4px` — uso especial, no estructural
> Forma asimétrica que cita la diagonal del símbolo REDSAT. **Un único elemento destacado por
> pantalla** (una tarjeta hero, un dato protagonista) — la misma disciplina de «un solo acento»
> del ámbar. **Prohibido** en botones, inputs y tarjetas de lista.

## 6.3 · Sombras y foco

- `--shadow-sm/md/lg`: en claro son sombras **azuladas** (`rgba(11,85,126,…)`), en oscuro
  negras. La elevación es sutil; en componentes de lista lo que separa sigue siendo el borde.
- `--focus-ring`: anillo de 4 px `rgba(79,179,169,.45)` claro / `rgba(159,216,208,.45)` oscuro
  — el foco siempre es de la familia aqua/menta, nunca del color del control.

---

# Parte 7 · Reglas que no se negocian

> **DANGER** — El color nunca es el único portador de significado
> Literal en las FRONTEND RULES del M34 portal_catalog, recogido en
> angular-architecture-map. Todo estado clínico se codifica en **tres canales a la vez**:
> color + forma (icono con silueta distinta, no el mismo círculo teñido) + texto (el `*_label`
> que viene del M30 read_models junto al `*_tone`). Los `*_code` de M03 terminology son
> el contrato; el color es presentación y nada más.

> **DANGER** — Un solo ámbar por pantalla
> El ámbar es «un único punto de atención por pantalla» y **nunca más del 10 %** de la
> superficie. Si aparece dos veces, dejó de significar algo. Es la regla que más fácil se
> degrada cuando una pantalla crece — se vigila en revisión de UI y hay un widget test que la
> cuenta.

Otras reglas literales del documento REDSAT:

- **Badges**: fondo claro + texto oscuro del mismo tono, *nunca* color sólido con texto blanco.
- **Inputs**: el estado se comunica cambiando el **borde**, nunca solo el fondo.
- **Modales**: nunca alarmistas, ni siquiera en confirmaciones destructivas.
- **Avatares sin foto**: color por rotación entre las familias de marca.
- **Botón primario**: uno por vista; en móvil los tamaños md/lg convergen a 44 px de alto.

Nota de accesibilidad cromática (heredada, sigue vigente): menta (H174) y ámbar (H31) están
bien separados para cualquier deficiencia cromática; **petróleo (H201) y aqua/menta (H174) se
acercan bajo tritanopía** — otra razón por la que la distinción nunca descansa solo en el color.

---

# Parte 8 · Contraste medido y excepciones conocidas

Barrido WCAG 2.1 calculado el 2026-07-29 sobre **las cinco superficies de cada modo** (la
lección del 2026-07-27 sigue mandando: un token se mide contra *todas* las superficies, no
contra la base). Umbrales: texto primario AAA 7:1 · texto secundario y tintas AA 4,5:1 ·
bordes de control 3:1 (WCAG 1.4.11).

## 8.1 · Lo que pasa con holgura

| Par | Peor caso | Nivel |
|---|---|---|
| `--text-primary` claro `#242828` | 13,46 | AAA |
| `--text-secondary` claro `#4E5151` | 7,24 | AAA |
| `--brand-primary` claro `#0B557E` | 7,25 | AAA |
| `--border-strong` claro `#7D8786` | 3,34 | ≥3:1 |
| blanco sobre petróleo | 8,03 | AAA |
| `#242828` sobre aqua / menta / ámbar | 5,93 / 9,37 / 7,23 | AA–AAA |
| blanco sobre error `#B5533C` | 4,92 | AA |
| `st-success/error/info` claro (fg sobre bg) | 6,75 / 7,53 / 5,01 | AA+ |
| `--text-primary` oscuro `#F6F3ED` | 8,96 | AAA |
| `--text-secondary` oscuro `#E9EEED` | 8,47 | AAA |
| `--brand-primary` oscuro `#70C1B9` | 4,74 | AA |
| `#0A1C27` sobre aqua-400 / menta-300 / ámbar-400 / error oscuro | 8,29 / 13,12 / 9,73 / 6,86 | AA–AAA |
| `st-*` oscuro (los cuatro) | ≥ 6,15 | AA+ |

Los asertos negativos siguen valiendo: **blanco sobre aqua = 2,51 y sobre ámbar = 2,06** — los
rellenos de acento llevan tinta oscura, jamás blanca.

## 8.2 · Excepciones — el hex del manual manda (decisión 2026-07-29)

> **BUG** — Cuatro pares no llegan al umbral y NO se corrigen
> Por decisión explícita se respetan los valores del manual. Cada par queda fijado en un test
> de Flutter con su ratio medido y la razón apuntando acá. **Pendiente: avisar al diseñador.**
>
> | # | Par | Medido | Umbral | Mitigación de uso |
> |---|---|---|---|---|
> | E1 | `--text-muted` claro `#787B7B` sobre las 5 superficies | 3,86–4,27 | 4,5 | Solo texto decorativo/terciario (hints, timestamps). Nunca datos clínicos ni labels de control. |
> | E2 | `--text-muted` oscuro `#A5B0AD` sobre la superficie más alta `#0B4768` | 4,45 | 4,5 | Marginal (−0,05). Sobre las 4 superficies declaradas da ≥ 5,46. Mismo uso restringido que E1. |
> | E3 | Bordes oscuros translúcidos: `--border-strong` `rgba(255,255,255,.24)` compuesto sobre las 5 superficies | 1,93–2,16 | 3,0 | **La más seria.** En oscuro un control sin foco no alcanza 3:1; el estado enfocado (aqua + anillo) sí delimita. El HTML además usa `--border-default` (.12, ≈1,4) en inputs. Elevar a revisión con el diseñador. |
> | E4 | `st-warning` claro: warning-700 `#8B6A47` sobre warning-50 `#FBF2E8` | 4,46 | 4,5 | Marginal (−0,04). Los badges siempre llevan icono + texto (regla de 3 canales). |
>
> Nota E5 (heredada, no es nueva): `--border-default` `#CDD9D5` da 1,31–1,45 — **solo divisor
> decorativo**, jamás delimita un control. Eso ya era ley en el sistema anterior y REDSAT lo
> respeta al declarar `--border-strong` aparte… salvo en el spec de inputs (ver E3).

> **BUG** — La lección del 2026-07-27 que originó este protocolo
> La primera versión del sistema anterior fijaba un borde `#7E9A93` medido **solo contra blanco**
> (3,03). El test de Flutter que barre las cinco superficies descubrió que caía a 2,74 sobre el
> Marfil. Se corrigió a `#66827C` / `#7099AB` (hoy retirados junto con el resto de tokens
> propios). **Lección permanente:** todo token se mide contra *todas* las superficies del modo —
> es exactamente el barrido que hoy documenta E1–E4.

---

# Parte 9 · Materialización en las dos apps

## 9.1 · Web — `mantra-core-health/src/styles.css`

Se adoptó el **naming del diseñador** (`--bg-base`, `--text-primary`, `--brand-primary`,
`--st-success-bg`, `--sp-4`, `--r-sm`, `--shadow-md`, `--focus-ring`, `--r-signature`,
`--font-display`, `--font-body`) con **una divergencia deliberada** (decisión 2026-07-29,
identificadores en inglés): las familias de rampa se traducen — `--c-azul-*`→`--c-petrol-*` ·
`--c-menta-*`→`--c-mint-*` · `--c-ambar-*`→`--c-amber-*` · `--c-salvia-*`→`--c-sage-*` ·
`--c-marfil-*`→`--c-ivory-*` (aqua y neutral no cambian). Los **valores** siguen siendo
literales del HTML del diseñador, que sigue siendo la spec de componentes. Los 14 tokens en
castellano del **sistema anterior de `styles.css`** (`--fondo`, `--marca`…) fueron eliminados.

> [!warning] Eso no incluye a `redsat.css`
> `mantra-core-health/src/styles/redsat.css` es una hoja **separada** —el «marco REDSAT»,
> declarado después de `styles.css` en `angular.json`— con su **propia** familia de tokens en
> castellano (`--fondo-*`, `--sup-*`, `--nav-*`, `--tinta-*`…), viva y sin relación con la
> frase de arriba. Detalle en **§9.1.3**.

Lo que se conservó de nuestra implementación (mejor que la del HTML, que solo usa `data-theme`):

- **Estrategia de theming SSR**: `:root` claro → `@media (prefers-color-scheme: dark)` con
  `:root:not([data-theme='light'])` → `:root[data-theme='dark']` (el toggle manual gana en las
  dos direcciones).
- `color-scheme: light dark`, `.cifras-tabulares` (alias `.tabular-nums`, el nombre del spec
  REDSAT), `prefers-reduced-motion`.
- Focus visible accesible: anillo `--focus-ring` + `outline` transparente de respaldo para
  modo alto contraste.

### 9.1.1 · Capa TypeScript — `src/app/core/tokens/` (2026-07-29)

Los **valores** viven solo en `styles.css`; en TS viven solo los **nombres**. Duplicar un hex
abriría una quinta frontera de deriva, así que no se duplica ninguno.

| Archivo | Qué contiene |
|---|---|
| `design-tokens.types.ts` | `ThemeMode` · `ResolvedTheme` · `StatusType`/`StatusSlot`, las rampas y la geometría como *template literal types*, el catálogo `DESIGN_TOKENS` en runtime y el único puente a CSS: `cssVar(BRAND.primary)` → `var(--brand-primary)` |
| `theme.service.ts` | `ThemeService` con signals: `currentTheme` (preferencia), `resolvedTheme` / `isDark` (lo que se pinta), `setTheme` · `toggleTheme` · `useSystemTheme`. Persiste en `localStorage` y sigue `matchMedia` en caliente |

> **IMPORTANT** — El atributo se estampa SOLO ante elección explícita
> `'system'` **no escribe `data-theme`**: lo resuelve `@media (prefers-color-scheme)` en CSS,
> sin JS — por eso la preferencia del sistema no puede parpadear nunca. `'light'`/`'dark'`
> escriben el atributo y `'system'` se persiste como *ausencia de clave*.

Anti-parpadeo bajo SSR — dos piezas, ambas necesarias:

1. **Script en línea en el `<head>` de `index.html`** (reemplaza al `afterNextRender()` que
   documentaba la versión anterior de esta nota): el HTML del servidor llega sin `data-theme`,
   así que una preferencia manual guardada se vería con el tema contrario hasta hidratar. El
   script lo estampa antes del primer paint leyendo la misma clave `mantra-core-health.theme`.
2. **`inlineCritical: false`** en `angular.json` (producción). Beasties inlinaba solo el `:root`
   claro —los bloques oscuros no matchean el DOM servido— y diferían el resto con
   `media="print"`: un usuario en oscuro veía un flash blanco aunque el atributo ya estuviera
   puesto. Con la hoja bloqueante en el `<head>` el flash desaparece en ambas direcciones.

`ThemeService` se instancia con `provideAppInitializer` en `app.config.ts`: el tema no espera a
que exista un componente. Bajo SSR el servicio construye sin tocar `window` y no escribe nada.

### 9.1.2 · Componentes — `src/app/shared/components/` + Vitrina de Diseño (2026-07-29)

Los componentes siguen **atomic design**: `shared/components/atoms/` → `molecules/` →
`organisms/` (junto a `shared/directives/` y `shared/pipes/`). Primer componente del sistema:
**AppButton** (`shared/components/atoms/button/`, 5 archivos: `button.types.ts` ·
`app-button.component.ts`/`.html`/`.scss`/`.spec.ts`; `atoms/input/` es el siguiente, hoy
scaffold vacío).

- **Selector de atributo `button[app-button]`**: el host ES el `<button>` nativo (semántica,
  teclado y formularios gratis). Signals (`input()`/`computed()`/`output()`), `OnPush`.
- Variantes `primary · secondary · outline · danger · ghost · neutral`, tamaños
  `sm 32 · md 40 · lg 48 px` (md/lg → 44 px bajo 780 px). Valores literales del bloque Buttons
  del HTML del diseñador, en BEM (`btn--primary` ≡ su `btn-primary`). `neutral` son los colores
  que el spec le da a `btn-icon` (`--bg-inset` / `--text-secondary`, hover `--border-default`),
  promovidos a variante para que también puedan llevar texto.
- **Íconos**: se proyectan como SVG con `stroke="currentColor"` — el componente los dimensiona
  en `em` (acompañan al talle) y en carga se apagan solos, porque `currentColor` hereda el
  `color: transparent` del estado. `iconOnly` es **solo geometría** (cuadrado usando la altura
  del talle vía `--_btn-side`, radio `--r-full`, padding 0): el color lo sigue poniendo la
  variante, así existe un botón de ícono `danger` que el spec no contemplaba. En desarrollo,
  un `iconOnly` sin `aria-label`/`aria-labelledby`/texto **avisa por consola** (`isDevMode` +
  `afterNextRender`): un botón de ícono mudo es un control invisible para un lector de pantalla.
- **Deshabilitado por `aria-disabled`** (no el atributo nativo): el botón sigue enfocable, el
  lector de pantalla anuncia el estado y el click se intercepta (`preventDefault` +
  `stopPropagation`, también para `type="submit"`). `aria-busy` + spinner en carga (texto
  transparente conserva el ancho; el spinner toma la tinta de la variante).
  **Bajo `prefers-reduced-motion` el spinner NO se congela**: la regla global lo frenaría y una
  UI colgada es peor que el movimiento; se ralentiza a 1,8 s (feedback esencial, permitido por
  WCAG 2.3.3). Gana por especificidad — la regla global apunta a `*`.
- Estilos: variables locales `--_btn-*` que **alias-an tokens globales** — el único hex es el
  `#fff` del danger/spinner que el propio spec fija (en oscuro `--text-inverse` es petrol-900
  y el diseñador quiere blanco en ambos temas). `type="button"` por defecto.

> **WARNING** — `outline` es extensión propia — NO está en el spec REDSAT
> El diseñador solo define una variante con borde (`btn-secondary`, borde de marca). `outline`
> (decisión del usuario 2026-07-29) es un outline **neutro**: borde `--border-strong`, tinta
> `--text-primary`, hover `--bg-inset` — solo tokens, cero hex nuevos. Pendiente de validación
> del diseñador (pendientes, Parte 11), igual que el tratamiento disabled de las variantes
> transparentes, que el spec no define.

#### Badge — `atoms/badge/` (2026-07-30)

Traducción del bloque `Badges / status` del spec (líneas 359–364). Generado con
`ng generate component shared/components/atoms/badge`, así que sigue la convención del CLI:
`badge.ts` · clase `Badge` · selector de elemento `app-badge`. Los tipos salen de
`ng generate interface … --type=types` → `badge.types.ts`.

- Variantes `success · warning · error · info` (spec) + `primary · secondary` (§3.1).
  Tamaños `sm · md · lg`, donde **`md` son los valores literales del spec** (11,5 px, `4px 10px`).
- **Cero color propio**: cada variante es un trío `--st-<tono>-*`, así el modo oscuro lo
  resuelve el tema y el componente no repite la estrategia de theming.
- `value` acepta texto o número; con `max` (99 por defecto) un conteo mayor se muestra `99+`.
  Sin `value`, el badge muestra lo que se le proyecte — las etiquetas de estado del
  M30 read_models.
- **`dotOnly`** vacía el contenido y vuelve el badge un punto (6/8/10 px), que toma la **tinta**
  del tono en vez del fondo claro. El `label` es obligatorio: sin él avisa por consola en dev,
  igual que `iconOnly` del botón.
- Accesibilidad: `role="status"` (un conteo que cambia debe anunciarse) y un `aria-label`
  explícito armado del `label` — «3 notificaciones no leídas», o **«más de 99 …» cuando está
  truncado**, porque «99+» no se lee bien en voz alta. Sin `label` no se fija `aria-label` y el
  nombre sale del texto visible, que es lo correcto para un badge de estado.

> **CAUTION** — `role="status"` es una región viva
> Correcto para un contador que cambia; **revisar cuando el badge entre en tablas densas**,
> donde decenas de regiones vivas serían ruido para un lector de pantalla.

#### Avatar y AvatarGroup — `atoms/avatar/` · `atoms/avatar-group/` (2026-07-30)

Traducción del bloque `Avatars` del spec (líneas 409–422 y 704–705). Talles literales
`xs 24 · sm 32 · md 40 · lg 56 · xl 80`, con `lg→44` y `xl→56` bajo 780 px.

- **Cascada de respaldo**: foto → iniciales → silueta. Un `(error)` en la `<img>` baja al
  siguiente escalón, así una foto rota nunca deja un hueco.
- **Color determinista**: hash djb2 del nombre → uno de los tres tonos de marca. La misma
  persona tiene siempre el mismo color en toda la app y entre sesiones, **sin persistir nada**.
- Accesibilidad: el host es `role="img"` con `aria-label`; las iniciales y el punto de estado
  van `aria-hidden` para no leerse dos veces. **La presencia se dice con palabras**
  («Andrea Peña, en línea»): un punto de color no la comunica solo. El contador del grupo
  anuncia «4 personas más», no «+4».

> **WARNING** — Divergencia con el spec: la tinta NO es blanca en los tres tonos
> El diseñador fija `color: #fff` para todo avatar, pero el fondo rota entre petróleo, aqua y
> ámbar — y la Parte 8.1 de este mismo documento mide **blanco sobre aqua en 2,51 y sobre
> ámbar en 2,06**, y prohíbe esos rellenos con tinta clara. Dos de cada tres avatares habrían
> sido ilegibles. Cada tono lleva su tinta: blanco solo sobre petróleo (8,03); petróleo-900
> sobre aqua (6,91) y ámbar (8,43). **Pendiente de avisar al diseñador.**

> **NOTE** — Dos hex de la especificación de entrada no coincidían con su token
> Se pidió `--st-success-fg` «(#2E8B6E)» y `--c-neutral-300` «(#A2A4A4)», pero esos hex son
> `--c-success-500` y `--c-neutral-200`. Criterio aplicado: **accesibilidad primero, después
> la intención declarada**. Online usa `--c-success-500` (el hex pedido; 4,17 claro y 3,53
> oscuro, pasa el 3:1 de WCAG 1.4.11). Offline usa `--c-neutral-300` (el token pedido) porque
> el hex `#A2A4A4` da **2,5:1 sobre blanco** y no llega al umbral.

#### Controles de formulario — auditoría y corrección (2026-07-30)

Los 8 controles (`input · checkbox · radio · switch · select · file-input` y
`form-field · date-picker`) los escribió otra sesión y se auditaron completos. Cuatro defectos
se **confirmaron ejecutando** el código, no leyéndolo, y se corrigieron:

| Defecto | Evidencia observada | Corrección |
|---|---|---|
| Los labels no apuntaban a ningún control | `for="" · id="" · label.control = NO`, en los 58 campos | Contrato `FORM_CONTROL_CONTEXT` (§9.1.3) |
| Un grupo de radios permitía 2 marcados | `puntos visibles=2` tras elegir uno | `atoms/radio-group/`: el grupo es el control |
| `type="number"` devolvía el 0 como texto | `"0" (typeof string)`, 42 sí como número | `Number.isNaN(valueAsNumber)`, nunca `\|\|` |
| El select degradaba los valores a string | `2 → "2"`, y **0 options marcadas** | El `<option>` lleva el índice, no el valor |

Además: foco/Escape/trampa en el modal del date-picker (un `role="dialog"` sin eso es solo una
etiqueta); `aria-pressed` + fecha completa en los días (antes el día elegido se distinguía **solo
por color**); validación de `accept`, tamaño, cupo y duplicados **al soltar** en file-input (el
atributo nativo solo filtra el diálogo del sistema, arrastrar lo esquiva); se quitó el `any` de
`SelectOption`, radio y select; y el correo **ya no se pasa a minúsculas** — la parte local es
sensible a mayúsculas (RFC 5321) y son correos de pacientes reales.

##### 9.1.3 · `FORM_CONTROL_CONTEXT` — cómo se cierra el hueco de los labels

`shared/components/form-control/form-control.context.ts`. El **campo** conoce label, hint y
error, así que es quien genera el `id` y el `aria-describedby`; el control los consume por DI
con `{ optional: true }` y, suelto, cae en un id propio. El contador de ids arranca en 0 en
servidor y cliente y avanza en el mismo orden, así la hidratación no rompe.

> **NOTE** — Un grupo no es «etiquetable»
> `<label for>` solo puede apuntar a input/select/button/textarea. Un `radio-group` avisa al
> campo (`controlLabelable.set(false)`) y entonces el label **no emite `for`**: el nombre viaja
> por `aria-labelledby`. Sin eso quedaban 3 `for` apuntando a ids inexistentes.

El date-picker dejó de re-estilar sus botones de ícono y usa `AppButton` con `iconOnly` — eso
además bajó su CSS por debajo del presupuesto de 4 kB, que era el único warning del build.

**Vitrina de Diseño** (`features/design-system-sample/`, ruta `/design-system`): superficie de
observación donde se expone cada pieza de `shared/components` a medida que existe — variantes × tamaños
× estados del botón (incluidos íconos, solo-ícono en los 3 talles y cargas simuladas) y el
**selector de tema Claro/Oscuro/Sistema** (primera UI del
`ThemeService`, dogfooding del propio AppButton). Las rutas ya no son `[]`: `Home` (`/`),
`/design-system` y `/auth` (scaffolds), con `**` → prerender.

> Nota operativa: `security.allowedHosts` de `angular.json` pasó de `[]` a `["localhost"]` —
> con la lista vacía el server de `yarn serve:ssr:mantra-core-health` rechazaba el header
> `host` y **toda** ruta caía a CSR. Al desplegar, agregar el dominio real.

### 9.1.3 · El fondo reactivo — `redsat.css` (TAREA-08, 2026-09-02)

No es parte del sistema de tokens de `styles.css`: vive en
`mantra-core-health/src/styles/redsat.css`, el «marco REDSAT», con su propia familia de
tokens en castellano (§9.1, advertencia de arriba). Lo mueve
`src/app/core/redsat/redsat-runtime.service.ts` (método `fondoReactivo()`), instalado una
sola vez por `app.ts` — por eso está en **todas las rutas**, no en una pantalla.

**Los cuatro focos son tokens** (`--fondo-a` … `--fondo-d`, dos por capa: `body::before` cerca,
`body::after` lejos, cada una con su propio `radial-gradient`), y sólo el bloque **claro**
cambió — el oscuro sigue exactamente igual, a propósito (ver más abajo):

| Token | Antes (v4.0–v4.2) | Ahora (v4.3) | Tono |
|---|---|---|---|
| `--fondo-a` | `rgba(159, 216, 208, .82)` | `rgba(159, 216, 208, .40)` | menta, capa cercana |
| `--fondo-b` | `rgba(79, 179, 169, .48)` | `rgba(79, 179, 169, .24)` | aguamarina, capa cercana |
| `--fondo-c` | `rgba(122, 191, 232, .62)` | `rgba(122, 191, 232, .30)` | celeste, capa lejana |
| `--fondo-d` | `rgba(159, 216, 208, .58)` | `rgba(159, 216, 208, .26)` | menta, capa lejana |

**El pedido tenía dos partes** («invertí el balance de colores» + «que el celeste aparezca al
hacer hover») y se resolvieron con dos mecanismos distintos, no uno solo:

1. **Bajar los cuatro alfas** (la tabla de arriba) hace que, aun con el fondo a su opacidad
   plena, la mancha sea bastante más tenue que antes — el «balance invertido» de base.
2. **`--fondo-presencia`**, una variable numérica (0–1) nueva, multiplica la opacidad de
   `body::before`/`body::after` completos: `opacity: var(--fondo-presencia, .35)`. `.35` es el
   valor de **respaldo** — lo que se ve antes de que el servicio corra (SSR, primer pintado) y
   lo que queda tras **650 ms sin mover el mouse**—, y `fondoReactivo()` la sube a `1` en la
   misma tanda de `requestAnimationFrame` que ya escribía `--raton-x`/`--raton-y`, con un único
   `setTimeout` reprogramado en cada movimiento (nunca un `setInterval`) que la vuelve a bajar
   al reposo. Así el celeste **aparece** con el puntero activo y **se retira** al quedarse
   quieto, sin agregar ni un `requestAnimationFrame` de más por cuadro.

> [!important] El interruptor de presencia es SOLO de modo claro
> `:root[data-tema="oscuro"] body::before, … { opacity: 1; }` anula `--fondo-presencia` en
> oscuro: el fondo nocturno **no** se apaga con el reposo — sigue viéndose exactamente como
> siempre. El pedido de «invertir el balance» era del modo claro, y así se acotó.

**Bajo `prefers-reduced-motion: reduce`**, `fondoReactivo()` nunca instala el oyente de
`mousemove` (guard preexistente, sin cambios): `--fondo-presencia` no se define jamás, así
que el fondo queda fijo en el `.35` de respaldo — legible, sin manchas a medio camino, y sin
depender de un puntero que en ese contexto no importa. Mismo resultado a 390 px táctil: sin
puntero fino, la variable tampoco se define, y el reposo es el estado terminado, no uno
«apagado» esperando algo que no va a llegar.

**Sin hex nuevo**: la inversión se hizo con los cuatro tokens que ya existían y un número
(`--fondo-presencia`) — ningún color nuevo entró al sistema.

Verificado con Playwright: `playwright/lane-08-reactive-background.spec.ts` capturas de `/` y
`/auth` en 390×844 / 768×1024 / 1440×900, claro y oscuro, puntero en reposo; más el ciclo
completo aparece/se-retira con `--fondo-presencia` en `1` y en `.35`, y el
`prefers-reduced-motion` que nunca la toca. Las rutas con sesión (`/dashboard`,
`/medical-records`, `/glossary`) quedaron **fuera** de esta corrida: este entorno no tiene una
cuenta `PRACTITIONER` sembrada (`tools/redesa/` no existe) — pendiente, no maquillado.

`src/app/core/redsat/redsat-runtime.service.spec.ts` ganó 3 casos (`describe('fondoReactivo')`):
antes cubría todo **menos** este método.

## 9.2 · Flutter — `mantra_core_health_mobile/lib/theme/`

Misma estructura de 4 archivos + geometría nueva:

| Archivo | Qué contiene |
|---|---|
| `mantra_ramp.dart` | tipo `MantraRamp`: una familia como **un valor** (10 escalones, `ramp[700]`, `colors`). Habilita barrer una rampa entera o elegir el escalón por cálculo |
| `mantra_palette.dart` | los 6 de marca + **las 11 rampas REDSAT completas**, literales del HTML, más los alias `warning*`≡ámbar / `info*`≡aqua y los 3 hex fuera de rampa (`insetBlue`, bordes translúcidos oscuros). Expone además las 9 familias como `petrolRamp`…`errorRamp` y el índice `ramps`, **derivadas de las constantes planas** (cada hex escrito una sola vez). Nada más entra acá |
| `mantra_tokens.dart` | `MantraState` (terna bg/fg/bd) + `ThemeExtension<MantraTokens>` con lo que Material no expresa: `action`/`overAction`, superficies alt/inset y los 4 estados `st*` **+ los tonos de marca `stPrimary`/`stSecondary`** (espejo de `--st-primary-*`/`--st-secondary-*`, con sus dos desvíos medidos). Constantes `MantraTokens.light` / `.dark` |
| `mantra_geometry.dart` | `MantraPadding` (`sp1..sp20`), `MantraRadius` (`xs..full` + **radio de firma**), `MantraStroke` (`hairline` / `focus`) y `MantraMotion` (`fast` = 150 ms + `of(context)`, que honra «reducir movimiento») |
| `mantra_typography.dart` | Poppins (display, estática) + Inter (UI, variable), escala REDSAT → `TextTheme` M3 |
| `mantra_theme.dart` | `MantraTheme.light` / `.dark` + extensiones `context.colors` · `context.texts` · `context.mantra` |

Primer componente (2026-07-29): **`MantraButton`** en `lib/shared/atoms/button/`
(`button_tokens.dart` + `mantra_button.dart` + `mantra_icon_button.dart`) — las
**variantes literales del HTML**
`primary / secondary / ghost / danger / link` (base `TextButton`, estilo completo vía
`mantraButtonStyle`, función pura testeable sin widgets). Tamaños con los **valores móviles**
de la media query (`sm` 13/8×14/32 denso; `md` ≡ `lg` 14.5/12×20/44) y hit-area estirada a
48 con `MaterialTapTargetSize.padded`. Huecos de la spec decididos y documentados en el
código: disabled fuera de primary-claro, hover oscuro de danger (aclara un escalón, como
primary), spinner con la **tinta de la variante** (el blanco fijo del HTML es invisible
sobre el primary oscuro), foco = borde 2 px aqua/menta (el halo translúcido de 4 px no cabe
en un `ButtonStyle` stateless). **El ámbar no es variante de botón** — hay un test que lo
prohíbe.

**`MantraIconButton`** porta el `.btn-icon`: cuadrado del lado del tamaño (44 en `md`/`lg`,
32 en `sm`), radio `full`, fondo de hueco + tinta secundaria + hover en `--border-default`
—los mismos tokens sirven en los dos modos— y `tooltip` **obligatorio**: sin texto visible,
es el nombre accesible del control, y en una app clínica eso no es negociable.

La **transición de carga** dura los 150 ms de la `transition` del HTML
(`mantraButtonTransition`) y honra «reducir movimiento» del sistema vía
`MediaQuery.disableAnimationsOf` (el equivalente Flutter del `prefers-reduced-motion` que ya
respeta `styles.css`). En `MantraButton` el label se desvanece **en su lugar** —el botón
conserva el ancho y la fila no salta— con el spinner entrando por encima; en
`MantraIconButton` el spinner **reemplaza** al ícono en un cross-fade. Fuera de carga el
`CircularProgressIndicator` se desmonta, así su ticker no queda corriendo.

> **WARNING** — En tests, un spinner indeterminado nunca «asienta»
> `pumpAndSettle()` se cuelga hasta el timeout con un `CircularProgressIndicator` en
> pantalla. Hay que pumpear una duración explícita (`tester.pump(mantraButtonTransition)`).

Segundo componente: **`MantraBadge`** en `lib/shared/atoms/badge/` (`badge_tokens.dart` +
`mantra_badge.dart`), espejo del `Badge` de Angular. Variantes
`primary/secondary/success/warning/error/info` (los 4 estados del spec + los 2 tonos de
marca), tamaños `sm/md/lg` donde **`md` son los literales del spec** (11,5 px, padding 4×10,
gap 6) y el resto escala. Píldora (`--r-full`) con borde de 1 px del tono, **cifras
tabulares** para que una lista de conteos no baile, `count` con techo `max`, `text` para las
etiquetas ya resueltas del M30, `dotOnly` y `child` (overlay sobre la esquina de un ícono,
`Stack` con `Clip.none`).

Tercer componente: **`MantraAvatar`** + **`MantraAvatarStack`** en
`lib/shared/atoms/avatar/`. **No tiene par en la web todavía** — es el primer átomo que nace
en móvil, así que estas decisiones son las que va a tener que espejar Angular.

Degrada en tres escalones: **foto → iniciales → ícono**, así un avatar nunca queda vacío ni
rompe el layout de una lista clínica. Escala móvil `xs 24 · sm 32 · md 40 · lg 44 · xl 56`
(en escritorio `lg` y `xl` son 56/80; en un teléfono un avatar de 80 se come la fila). El
punto de estado es `success-500` / `neutral-300` con anillo de 2 px del color de la
superficie —sin el anillo desaparece sobre una foto oscura— y `none` **no dibuja nada**: un
punto gris permanente se lee como «desconectado».

- **El color de las iniciales sale de un hash determinista del nombre**, elegido entre
  `primary` / `secondary` / `tertiary` del `ColorScheme`: la misma persona tiene siempre el
  mismo color, en cualquier pantalla y entre sesiones, y cada fondo trae su tinta con
  contraste garantizado en los dos modos. **El ámbar queda afuera a propósito** — es el punto
  de acción único de la pantalla y una lista de avatares lo repetiría hasta vaciarlo de
  sentido. Hay un test que lo prohíbe.
- **`Image.network` con `errorBuilder`, no `CircleAvatar`.** El `onBackgroundImageError` de
  `CircleAvatar` es un callback sin retorno: para reemplazar la foto por las iniciales haría
  falta estado. Con `errorBuilder` el widget sigue siendo inmutable, y el `loadingBuilder`
  muestra las iniciales mientras la foto baja en vez de un hueco gris.
- **Las iniciales son decoración, no contenido.** Van dentro de `ExcludeSemantics`: el lector
  anuncia «Ana Pérez» con el estado como `value`, no deletrea «A P».
- **Límite conocido de la heurística:** toma la primera y la última palabra, así que «María
  Elena Ruiz Díaz» da **MD**, no MR — no sabe dónde terminan los nombres y empiezan los
  apellidos. Para fichas clínicas el llamador pasa `initials` armadas desde los campos
  estructurados del modelo.
- **`MantraAvatarStack` solapa con `Stack` + `Positioned` dentro de una caja del tamaño
  exacto**, no con `Padding` negativo: `EdgeInsets` rechaza los valores negativos y revienta
  el layout. Por encima de `maxVisible` cierra con un `+N` sobre el hueco del sistema
  (`supInset`), que no es una persona sino un resto; el grupo se anuncia como un todo
  («3 personas y 2 más»), no avatar por avatar.

Tres decisiones que se apartan del componente web, todas documentadas en el código:

- **`count` y `text` separados** en vez de `value: string | number | null`. Dart no tiene
  tipos unión; `Object?` sería `dynamic` disfrazado y forzaría un `is int` en runtime. Con
  dos campos, «el techo solo aplica a un conteo» es un hecho del tipo.
- **El punto toma la tinta del tono, no el fondo.** Un `dotOnly` con el fondo claro del chip
  (p. ej. `error-50`) sería invisible sobre una superficie blanca.
- **Con frase accesible, el texto visible va en `ExcludeSemantics`.** Sin eso el lector
  anuncia «3 mensajes» y después «3»: el número dos veces. El badge es `liveRegion`
  (equivalente del `role="status"` de la web) y `dotOnly` **exige** `label` — un punto de
  color sin nombre no existe para quien usa un lector de pantalla.

Divergencia deliberada con la web: el `AppButton` Angular expone `outline` como
extensión propia; Flutter sigue el set del HTML («outline» ≡ `secondary`) — unificar cuando
el diseñador valide.

> **NOTE** — La API pública del tema está en inglés, colores incluidos; la prosa y
> los identificadores internos siguen en castellano
> `MantraPadding` · `MantraRadius` · `MantraState` · `action` · `overAction` ·
> `light` / `dark` · `colors` / `texts`; paleta `petrol*` / `mint*` / `amber*` /
> `sage*` / `ivory*` (mismas familias que los `--c-*` de la web), marca
> `petrolBlue` / `aquamarine` / `lightMint` / `sandAmber` / `sageGray` / `ivory`,
> rampas `petrolRamp`…`errorRamp` + índice `ramps`, inset `insetPetrol`. Las dos excepciones deliberadas son `MantraRadius.firma` y
> `MantraTypography.cifrasTabulares`: nombran conceptos del manual REDSAT que
> no tienen traducción sin perder la referencia.

Correspondencia `ColorScheme` (lo que Material sabe expresar no se duplica en la extensión):

| Token REDSAT | Material 3 claro | Material 3 oscuro |
|---|---|---|
| `--brand-primary` | `primary #0B557E` | `primary #70C1B9` (aqua-400) |
| `--brand-secondary` | `secondary #4FB3A9` | `secondary #C3E7E2` (menta-300) |
| menta | `tertiary #9FD8D0` | `tertiary #B1DFD9` |
| error 500 / 300 | `error #B5533C` | `error #D19485` |
| `--bg-base` | `surface #FFFFFF` | `surface #0A1C27` |
| superficies | rampa marfil: `#FFFFFF · #FBFAF7 · #F9F8F4 · #F8F5F0 · #F6F3ED` | rampa azul + inset: `#0A1C27 · #0A2B3D · #0F2E42 · #0B3953 · #0B4768` |
| `--text-primary` | `onSurface #242828` | `onSurface #F6F3ED` |
| `--text-secondary` | `onSurfaceVariant #4E5151` | `onSurfaceVariant #E9EEED` |
| `--border-strong` | `outline #7D8786` | `outline` blanco 24 % (compuesto — E3) |
| `--border-default` | `outlineVariant #CDD9D5` | `outlineVariant` blanco 12 % |
| `--brand-accent` / `--text-inverse` | `MantraTokens.action / overAction` | ídem, ámbar-400 en oscuro |
| `--st-*` | `MantraTokens.st*` | ídem |

Las cinco superficies de cada modo salen de las **rampas del propio manual** (marfil en claro,
azul en oscuro), ordenadas por luminancia — sin colores inventados. La quinta oscura (azul-600
`#0B4768`) es la que origina la excepción E2.

## 9.3 · Red de seguridad

`test/theme_test.dart` + `test/widget_test.dart` + `test/mantra_button_test.dart`
(**106 tests**): la paleta contra el manual
REDSAT, el barrido de contraste sobre las cinco superficies de cada modo (con las excepciones
E1–E4 fijadas con su ratio y razón), los asertos negativos (blanco sobre aqua/ámbar, un solo
ámbar por pantalla), los contratos tipográficos (Poppins display estática, Inter variable con
eje `wght`, cifras tabulares), la equivalencia de los alias `warning`/`info` con sus rampas y el
contrato de `ThemeExtension` (`copyWith` parcial, `lerp` en los extremos y en la terna de
estado, `==`/`hashCode`) y los **invariantes de las 9 rampas barridas de a una** (10
escalones, el índice `ramp[N]` coincidiendo con `colors`, y luminancia estrictamente
decreciente de 50 a 900 — un hex tipeado en el escalón equivocado rompe ahí y en ningún
otro lado). El botón fija su propio contrato: mapeo de las 5 variantes × 2 modos,
disabled resuelto antes que hover, foco siempre aqua/menta, **ninguna variante usa el
ámbar**, spinner con la tinta de la variante, y geometría (sm denso, md ≡ lg 44, radio
`--r-sm`, jamás el de firma). En la web, el espejo de esta red son los 24 tests de `src/app/core/tokens/`
(§9.1.1), incluida la fidelidad TS ↔ `styles.css` en las dos direcciones.

---

# Parte 10 · Superficies y breakpoints

## 10.1 · Las dos superficies de producto

| Superficie | Proyecto | Stack | Alcance |
|---|---|---|---|
| Web | `mantra-core-health/` | Angular 21 + SSR | los 17 portales del M34 portal_catalog |
| Móvil | `mantra_core_health_mobile/` | Flutter · **Android + iOS** | subconjunto, todavía sin definir |

> **WARNING** — Una pantalla, una superficie canónica
> El scaffold Flutter generó también `web/`, `windows/`, `linux/` y `macos/`. **No son
> objetivo.** Mientras no se decida lo contrario, la web es de Angular.

## 10.2 · Breakpoints — dos vocabularios, uno por plataforma

**Web adopta los de REDSAT** (decisión 2026-07-29 — son los que el diseñador usará en cada
spec de pantalla):

| Punto de quiebre | Rango | Qué cambia |
|---|---|---|
| Móvil | `< 780 px` | navegación a hamburguesa; grids a 1 columna; tablas a tarjetas apiladas |
| Tablet | `780–1024 px` | grids de 3–4 pasan a 2; paneles laterales bajan |
| Escritorio | `> 1024 px` | layout completo: sidebar fijo, menú horizontal |

**Flutter conserva las window size classes de Material 3** (`compacta <600` · `media 600–839` ·
`expandida 840–1199` · `grande` · `extra-grande`): son la convención de plataforma, salen de
`MediaQuery` sin traducción, y la app solo gobierna `compacta` y `media`.

Reglas que acompañan (heredadas, siguen vigentes):

- **Mobile-first**: la consulta base es la chica; los `@media` suben.
- `responsive_priority` de M30 read_models`.frontend_view_fields` declara **por campo** el
  orden de degradación — una pantalla que reordena a ojo contradice el modelo.
- **Móvil nunca oculta información de seguridad** (FRONTEND RULES del M34 portal_catalog):
  alergias, interacciones y contraindicaciones no van detrás de un «ver más».
- **La densidad clínica no se sacrifica por aire**; área táctil mínima 48×48 dp / 44×44 pt;
  probar con el tamaño de texto del sistema aumentado. El estado **S8 · Offline/retry** es de
  los 9 obligatorios.

---

# Parte 11 · Estado y pendientes

**Materializado el 2026-07-29 en las dos superficies** (adopción REDSAT v1.0):

| Superficie | Dónde | Verificado con |
|---|---|---|
| Web | `mantra-core-health/src/styles.css` + `src/app/core/tokens/` (capa TS, §9.1.1) + `shared/components/` y Vitrina (§9.1.2) | `yarn build` OK (3 rutas prerenderizadas, **0 warnings de presupuesto**) · `yarn test --watch=false` **162/162** · SSR ejercitado con `curl`: `/design-system` sirve los 24 botones y los 20 badges, **0 labels huérfanos**, 8 radios con exactamente 3 marcados (uno por grupo), 28 `aria-describedby` resueltos y 24 avatares con su tono por hash, en el HTML del servidor |
| Móvil | `mantra_core_health_mobile/lib/theme/` (6 archivos + 7 de los tres átomos) | `flutter analyze` **0 issues** · `flutter test` **106/106** (barridos WCAG de 5 superficies + excepciones E1–E4 fijadas con su ratio) |

Pendientes reales:

1. **Confirmar REDSAT como nombre de producto.** El manual corporativo ya se llama REDSAT, pero
   la decisión de UI (2026-07-29) fue «solo tokens, sin renombrar»: wordmark y títulos siguen en
   *Mantra Core Health* hasta confirmación. Al confirmarse: renombre de carpeta + `package.json`
   + `angular.json` + título + `pubspec.yaml`.
2. **Avisar al diseñador las excepciones E1–E4** (Parte 8.2) — en particular E3: los bordes
   translúcidos del modo oscuro no delimitan controles según WCAG 1.4.11. Sumar al mismo aviso
   los **chips de marca** `--st-primary-*` / `--st-secondary-*` (§3.1, con sus dos desvíos
   medidos) y las **extensiones del AppButton** (§9.1.2): la variante `outline` neutra y el tratamiento
   disabled de las variantes transparentes, que el spec no define.
3. **Escala de severidad clínica** (crítico / alerta / estable / indeterminado) — sigue sin
   definir. Los `st-*` de REDSAT son semántica de producto y no la sustituyen; cuando se defina,
   derivarla de las rampas de la Parte 2.2 en armonía. El `error` de Material sigue siendo
   validación de formulario, no severidad.
4. **Ninguna pantalla de PORTAL consume los tokens todavía.** En web ya existen el AppButton y
   la Vitrina (`/design-system`, §9.1.2) — pero `Home` y `Auth` son scaffolds vacíos y ningún
   portal del M34 portal_catalog está construido; en Flutter `PantallaTokens` existe solo
   para observar el tema y se borra con la primera pantalla real. La primera UI se construye
   sobre estos tokens, nunca sobre hex literales — y los componentes se toman del spec del HTML
   del diseñador.
5. **Alcance de la app móvil sin definir** — qué subconjunto de los 17 portales vive en Flutter.
6. ~~Falta el control de tema en la UI~~ — **resuelto 2026-07-29**: selector
   Claro/Oscuro/Sistema en la Vitrina de Diseño (§9.1.2). Cuando exista chrome de aplicación,
   migrar el control ahí.

## Ver también

- angular-architecture-map — los 64 módulos, los 17 portales y la estructura de features
- frontend-view-contracts — `*_code` vs `*_label`/`*_tone`: el color es presentación
- M34 portal_catalog — FRONTEND RULES y los 9 estados de UX obligatorios
- M30 read_models — de dónde salen los tonos y las etiquetas de cada estado
- M03 terminology — los `*_concept_id`: nunca hardcodear un label ni inventar un enum

