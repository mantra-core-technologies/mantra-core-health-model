# -*- coding: utf-8 -*-
"""
insights_demo.py — generador determinista de los datos de demostración de AloVida Insights.

Es un PUERTO LÍNEA A LÍNEA del simulador del front (repo `mantra-core-health`):

  src/app/core/data-access/insights/insights-prng.ts     hashSeed · mulberry32 · noise
  src/app/core/data-access/insights/insights-dates.ts    weekdayIndex · eachDay
  src/app/core/mock/handlers/insights/catalog.dataset.ts campañas · hitos · corte
  src/app/core/mock/handlers/insights/facts.dataset.ts   hechos diarios campaña × canal × día

La paridad es un contrato, no una intención: la suma de TODAS las filas de hechos debe ser
exactamente la del simulador (ver `PARITY_TOTALS` y `tests/test_insights_demo.py`). Por eso
este módulo no importa nada del resto de `salud-db/` (sólo la biblioteca estándar): lo puede
ejecutar una prueba sin el vault ni la base.

Tres trampas del puerto, resueltas aquí y que no se pueden "simplificar":

  * `Math.imul` es una multiplicación de 32 bits CON signo; en Python se enmascara a 32 bits
    sin signo en cada paso (`& MASK`), y `>>> 0` es exactamente ese enmascarado.
  * `Math.round(x)` de JavaScript es `floor(x + 0.5)` (el .5 sube también en negativos),
    NO el `round` de Python, que redondea a par ("banker's rounding"): `round(2.5) == 2`.
  * El orden de las multiplicaciones de punto flotante se conserva idéntico al TS; reordenar
    `a * b * c` cambia el último bit y, tras el redondeo, alguna fila.

Sin dependencias, sin azar real, sin reloj: dos ejecuciones dan los mismos bytes.
"""
from __future__ import annotations

import math
from datetime import date, timedelta

MASK32 = 0xFFFFFFFF

# ------------------------------------------------------------------ aleatoriedad (insights-prng.ts)


def imul(a: int, b: int) -> int:
    """`Math.imul` devuelto SIN signo (módulo 2^32): los usos siguientes sólo hacen XOR y suma."""
    return ((a & MASK32) * (b & MASK32)) & MASK32


def hash_seed(key: str) -> int:
    """FNV-1a de 32 bits sobre unidades de código UTF-16 (como `charCodeAt`)."""
    h = 0x811C9DC5
    raw = key.encode("utf-16-le")
    for i in range(0, len(raw), 2):
        unit = raw[i] | (raw[i + 1] << 8)
        h ^= unit
        h = imul(h, 0x01000193)
    return h & MASK32


def mulberry32(seed: int):
    """Devuelve el generador `() -> float` en [0, 1): mismo estado y mismas operaciones que el TS."""
    state = seed & MASK32

    def nxt() -> float:
        nonlocal state
        state = (state + 0x6D2B79F5) & MASK32
        t = state
        t = imul(t ^ (t >> 15), t | 1)
        t = (t ^ ((t + imul(t ^ (t >> 7), t | 61)) & MASK32)) & MASK32
        return ((t ^ (t >> 14)) & MASK32) / 4294967296

    return nxt


def noise(key: str, amplitude: float) -> float:
    """Ruido multiplicativo centrado en 1 (±amplitude), estable para una clave."""
    value = mulberry32(hash_seed(key))()
    return 1 + (value * 2 - 1) * amplitude


def js_round(x: float) -> int:
    """`Math.round` de JavaScript: floor(x + 0.5)."""
    return int(math.floor(x + 0.5))


# ------------------------------------------------------------------ fechas (insights-dates.ts)


def each_day(frm: str, to: str):
    d, end = date.fromisoformat(frm), date.fromisoformat(to)
    while d <= end:
        yield d.isoformat()
        d += timedelta(days=1)


def weekday_index(iso: str) -> int:
    """0 = lunes … 6 = domingo (igual que `date.weekday()`)."""
    return date.fromisoformat(iso).weekday()


# ------------------------------------------------------------------ catálogo (catalog.dataset.ts)

CUTOFF = "2026-10-29"
WINDOW_FROM = "2026-09-01"

PAID_CHANNELS = ("instagram", "facebook", "tiktok", "youtube", "google")
VIDEO_CHANNELS = ("instagram", "tiktok", "youtube", "facebook")

# Escala de volumen y calidad del embudo de cada campaña (sólo la usa el generador).
CAMPAIGN_SCALE = {
    "c1": (0.36, 1.0),
    "c2": (0.3, 1.1),
    "c3": (0.28, 1.05),
    "c4": (0.2, 1.0),
}

# Campos que el TS no tiene (`short_name`, `kind_code`) los fija el modelo; el resto es el TS.
CAMPAIGNS = (
    {
        "code": "c1", "short_name": "Registro Médicos", "kind_code": "acquisition",
        "name": "Campaña Registro Médicos — Octubre 2026",
        "objective": "Registrar 650 médicos verificados en octubre",
        "audience": "Médicos generales y especialistas de Bolivia",
        "start": "2026-10-01", "end": "2026-10-31", "budget_cents": 4_200_000,
        "status": "active", "revenue_per_conversion_cents": 18_500,
        "targets": {"ctr": 0.025, "cpa": 6500, "roas": 3.2, "conversions": 650, "retention": 0.6},
        "channels": ("google", "instagram", "facebook", "youtube", "email", "web"),
    },
    {
        "code": "c2", "short_name": "Abran paso", "kind_code": "acquisition",
        "name": "Abran paso · La maqueta de los anillos",
        "objective": "4.800 registros de pacientes por QR y redes",
        "audience": "Pacientes de Santa Cruz, de 18 a 44 años",
        "start": "2026-09-15", "end": "2026-11-14", "budget_cents": 5_000_000,
        "status": "active", "revenue_per_conversion_cents": 7_200,
        "targets": {"ctr": 0.016, "cpa": 4200, "roas": 1.6, "conversions": 1500, "retention": 0.45},
        "channels": ("tiktok", "instagram", "facebook", "app", "web"),
    },
    {
        "code": "c3", "short_name": "Ahorro en medicamentos", "kind_code": "engagement",
        "name": "Ahorro en medicamentos · Farmacias aliadas",
        "objective": "1.900 usuarios que consultan precios de genéricos",
        "audience": "Familias que compran medicamentos con frecuencia",
        "start": "2026-10-05", "end": "2026-11-04", "budget_cents": 2_000_000,
        "status": "active", "revenue_per_conversion_cents": 12_800,
        "targets": {"ctr": 0.02, "cpa": 5200, "roas": 1.4, "conversions": 520, "retention": 0.5},
        "channels": ("facebook", "google", "tiktok", "email"),
    },
    {
        "code": "c4", "short_name": "Historial de salud", "kind_code": "always_on",
        "name": "Historial de salud en un solo lugar",
        "objective": "Siempre activa: sostener 900 registros al mes",
        "audience": "Pacientes crónicos y cuidadores",
        "start": "2026-09-01", "end": "2026-12-31", "budget_cents": 5_600_000,
        "status": "active", "revenue_per_conversion_cents": 8_800,
        "targets": {"ctr": 0.018, "cpa": 4800, "roas": 1.5, "conversions": 900, "retention": 0.62},
        "channels": ("instagram", "youtube", "google", "web"),
    },
)

MILESTONES = (
    {"date": "2026-09-15", "label": "Inicio de «Abran paso»", "campaign": "c2", "kind": "launch"},
    {"date": "2026-10-01", "label": "Inicio de Registro Médicos", "campaign": "c1", "kind": "launch"},
    {"date": "2026-10-05", "label": "Inicio de Ahorro en medicamentos", "campaign": "c3", "kind": "launch"},
    {"date": "2026-10-09", "label": "El video de la maqueta se viraliza en TikTok", "campaign": "c2", "kind": "viral"},
    {"date": "2026-10-17", "label": "Nota en prensa regional", "campaign": "c2", "kind": "press"},
    {"date": "2026-10-22", "label": "Cambio de oferta en Facebook", "campaign": "c3", "kind": "offer_change"},
)

# Orden y nombre de las seis fuentes de datos del portal.
DATA_SOURCES = (
    ("youtube", "YouTube"),
    ("meta", "Meta (Instagram y Facebook)"),
    ("google", "Google"),
    ("tiktok", "TikTok"),
    ("app", "App móvil de AloVida"),
    ("web", "Sitio web de AloVida"),
)

# Reglas de alerta: (code, name, description, severity, unit, umbral por defecto, dirección).
# direction '+' = alerta cuando la métrica SUBE por encima del umbral; '-' = cuando BAJA.
# Los mínimos de muestra (`min_sample_json`) los fija el motor de reglas del API (lane C2), no
# esta semilla: se siembran en NULL en vez de inventarlos.
ALERT_RULES = (
    ("cac", "CAC al alza",
     "El costo de adquisición por conversión sube respecto de la ventana anterior.",
     "critical", "percent", 20, "+"),
    ("ctrdrop", "CTR en caída",
     "La tasa de clics cae respecto de la ventana anterior.",
     "risk", "percent", 12, "-"),
    ("ctrspike", "CTR en pico",
     "La tasa de clics se dispara de forma anómala respecto de la ventana anterior.",
     "anomaly", "percent", 50, "+"),
    ("cvr", "Conversión en caída",
     "La tasa de conversión baja respecto de la ventana anterior.",
     "risk", "percent", 15, "-"),
    ("neg", "Menciones negativas al alza",
     "La proporción de menciones negativas sobre la marca crece respecto de la ventana anterior.",
     "risk", "percent", 25, "+"),
    ("onb", "Onboarding con abandono",
     "La finalización del onboarding de la app cae respecto de la versión anterior.",
     "risk", "percent", 20, "-"),
    ("feed", "Fuente sin datos",
     "Una fuente de datos lleva más horas de las permitidas sin entregar información.",
     "critical", "hours", 24, "+"),
)

# ------------------------------------------------------------------ generador (facts.dataset.ts)
# (gasto diario Bs, cpm Bs, impresiones propias, ctr, engagement, visitas, calidad, frecuencia,
#  tasa de video, segundos vistos)
_CHANNEL_MODEL = {
    "instagram": dict(daily_spend_bs=1300, cpm_bs=22, owned_impressions=0, ctr=0.024, engagement_rate=0.048, visit_rate=0.78, quality=1.0, daily_frequency=1.22, video_rate=0.42, avg_watch_seconds=7.2),
    "facebook": dict(daily_spend_bs=700, cpm_bs=18, owned_impressions=0, ctr=0.016, engagement_rate=0.021, visit_rate=0.76, quality=0.95, daily_frequency=1.3, video_rate=0.3, avg_watch_seconds=6.1),
    "tiktok": dict(daily_spend_bs=800, cpm_bs=14, owned_impressions=0, ctr=0.031, engagement_rate=0.062, visit_rate=0.7, quality=0.72, daily_frequency=1.18, video_rate=0.65, avg_watch_seconds=9.5),
    "youtube": dict(daily_spend_bs=350, cpm_bs=30, owned_impressions=0, ctr=0.009, engagement_rate=0.014, visit_rate=0.82, quality=1.15, daily_frequency=1.12, video_rate=0.45, avg_watch_seconds=21),
    "google": dict(daily_spend_bs=700, cpm_bs=38, owned_impressions=0, ctr=0.036, engagement_rate=0.002, visit_rate=0.88, quality=1.3, daily_frequency=1.08, video_rate=0, avg_watch_seconds=0),
    "web": dict(daily_spend_bs=0, cpm_bs=0, owned_impressions=9000, ctr=0.06, engagement_rate=0.011, visit_rate=0.96, quality=1.35, daily_frequency=1.4, video_rate=0, avg_watch_seconds=0),
    "app": dict(daily_spend_bs=0, cpm_bs=0, owned_impressions=15000, ctr=0.05, engagement_rate=0.018, visit_rate=0.98, quality=1.5, daily_frequency=2.1, video_rate=0, avg_watch_seconds=0),
    "email": dict(daily_spend_bs=0, cpm_bs=0, owned_impressions=6000, ctr=0.034, engagement_rate=0.052, visit_rate=0.94, quality=1.45, daily_frequency=1.05, video_rate=0, avg_watch_seconds=0),
}

STAGE = dict(lead=0.12, registration=0.55, activation=0.68, first_use=0.8, conversion=0.5)
WEEKDAY_FACTOR = (1, 1.06, 1.05, 1, 0.94, 0.8, 0.74)

MEASURES = ("impressions", "reach", "engagements", "clicks", "video_views", "watch_seconds",
            "visits", "leads", "registrations", "activations", "first_uses", "conversions",
            "spend_cents", "revenue_cents")


def _event_effect(campaign: str, channel: str, day: str) -> dict:
    """Hechos inyectados a propósito (mismas fechas y multiplicadores que el TS)."""
    e = dict(cpm=1, ctr=1, lead=1, activation=1, conversion=1)
    if campaign == "c1" and day >= "2026-10-20":
        e["activation"] = 0.905
    if campaign == "c2" and channel == "tiktok":
        if "2026-10-09" <= day <= "2026-10-14":
            e["ctr"] = 1.7
        if day >= "2026-10-26":
            e["ctr"] = 1.9
    if campaign == "c3" and day >= "2026-10-22" and channel == "facebook":
        e["cpm"], e["lead"], e["conversion"] = 1.4, 0.42, 0.78
    return e


def _flight_factor(day: str, start: str, end: str) -> float:
    start_d = date.fromisoformat(start)
    d = (date.fromisoformat(day) - start_d).days / 1.0
    total = (date.fromisoformat(end) - start_d).days / 1.0
    ramp = min(1, 0.55 + d * 0.15)
    taper = 0.85 if d > total - 2 else 1
    return ramp * taper


def _build_fact(campaign: dict, channel: str, day: str) -> dict:
    cid = campaign["code"]
    scale, funnel_quality = CAMPAIGN_SCALE[cid]
    m = _CHANNEL_MODEL[channel]
    eff = _event_effect(cid, channel, day)
    key = f"{cid}|{channel}|{day}"
    day_factor = WEEKDAY_FACTOR[weekday_index(day)] * _flight_factor(day, campaign["start"], campaign["end"])
    paid = channel in PAID_CHANNELS

    spend_bs = m["daily_spend_bs"] * scale * day_factor * noise(key + "|s", 0.06) if paid else 0
    cpm = m["cpm_bs"] * eff["cpm"] * noise(key + "|cpm", 0.07)
    if paid:
        impressions = (spend_bs / cpm) * 1000
    else:
        impressions = m["owned_impressions"] * scale * day_factor * noise(key + "|i", 0.09)
    ctr = m["ctr"] * eff["ctr"] * noise(key + "|ctr", 0.09)
    clicks = impressions * ctr
    visits = clicks * m["visit_rate"] * noise(key + "|v", 0.03)
    q = m["quality"] * funnel_quality
    leads = visits * STAGE["lead"] * q * eff["lead"] * noise(key + "|l", 0.07)
    registrations = leads * STAGE["registration"] * noise(key + "|r", 0.06)
    activations = registrations * STAGE["activation"] * eff["activation"] * noise(key + "|a", 0.05)
    first_uses = activations * STAGE["first_use"] * noise(key + "|u", 0.04)
    conversions = first_uses * STAGE["conversion"] * eff["conversion"] * noise(key + "|c", 0.06)
    views = impressions * m["video_rate"] * noise(key + "|vv", 0.08) if channel in VIDEO_CHANNELS else 0

    r = js_round
    impressions_i = r(impressions)
    clicks_i = min(r(clicks), impressions_i)
    visits_i = min(r(visits), clicks_i)
    leads_i = min(r(leads), visits_i)
    registrations_i = min(r(registrations), leads_i)
    activations_i = min(r(activations), registrations_i)
    first_uses_i = min(r(first_uses), activations_i)
    conversions_i = min(r(conversions), first_uses_i)

    return {
        "date": day,
        "campaign": cid,
        "channel": channel,
        "impressions": impressions_i,
        "reach": r(impressions / (m["daily_frequency"] * noise(key + "|f", 0.04))),
        "engagements": r(impressions * m["engagement_rate"] * noise(key + "|e", 0.1)),
        "clicks": clicks_i,
        "video_views": r(views),
        "watch_seconds": r(views * m["avg_watch_seconds"] * noise(key + "|w", 0.06)),
        "visits": visits_i,
        "leads": leads_i,
        "registrations": registrations_i,
        "activations": activations_i,
        "first_uses": first_uses_i,
        "conversions": conversions_i,
        "spend_cents": r(spend_bs * 100),
        "revenue_cents": r(conversions_i * campaign["revenue_per_conversion_cents"] * noise(key + "|rev", 0.05)),
    }


def build_daily_facts() -> list:
    """Todos los hechos diarios, ordenados por fecha, campaña y canal (como `mockCampaignFacts`)."""
    facts = []
    for campaign in CAMPAIGNS:
        last = campaign["end"] if campaign["end"] < CUTOFF else CUTOFF
        for day in each_day(campaign["start"], last):
            for channel in campaign["channels"]:
                facts.append(_build_fact(campaign, channel, day))
    facts.sort(key=lambda f: (f["date"], f["campaign"], f["channel"]))
    return facts


# ------------------------------------------------------------------ paridad

# Suma sobre TODAS las filas del simulador del front (ventana 2026-09-01..2026-10-29).
PARITY_TOTALS = {
    "rows": 735,
    "impressions": 5_455_307,
    "clicks": 152_886,
    "registrations": 9_116,
    "conversions": 2_454,
    "spend_cents": 10_412_901,
}


def sum_measures(rows) -> dict:
    out = {"rows": 0, **{k: 0 for k in MEASURES}}
    for row in rows:
        out["rows"] += 1
        for k in MEASURES:
            out[k] += row[k]
    return out


def golden(facts: list | None = None) -> dict:
    """Sumas de control por campaña × canal, por campaña y totales (insights-golden.json)."""
    facts = build_daily_facts() if facts is None else facts
    by_cc: dict = {}
    by_c: dict = {}
    for f in facts:
        by_cc.setdefault(f"{f['campaign']}|{f['channel']}", []).append(f)
        by_c.setdefault(f["campaign"], []).append(f)
    return {
        "_comment": "Generado por salud-db/gen_seeds.py (fase v4269_marketing_insights) desde "
                    "salud-db/insights_demo.py. Sumas de control del puerto del simulador del front: "
                    "no editar a mano.",
        "window": {"from": WINDOW_FROM, "to": CUTOFF},
        "totals": sum_measures(facts),
        "byCampaign": {k: sum_measures(v) for k, v in sorted(by_c.items())},
        "byCampaignChannel": {k: sum_measures(v) for k, v in sorted(by_cc.items())},
    }
