from __future__ import annotations

import copy
import datetime as dt
import hashlib
import json
import os
import re
import shutil
import uuid
from collections import Counter, defaultdict
from pathlib import Path
from typing import Any

SOURCE_ROOT = Path('/mnt/data/seed_review/SALUD_v4.0_module_seeds')
OUTPUT_ROOT = Path('/mnt/data/SALUD_v4.0_module_seeds_enhanced')
MODULES_DIR = OUTPUT_ROOT / 'modules'
REPORTS_DIR = OUTPUT_ROOT / 'reports'
SCHEMAS_DIR = OUTPUT_ROOT / 'schemas'
TOOLS_DIR = OUTPUT_ROOT / 'tools'

NAMESPACE = uuid.UUID('9e475ed5-d2a0-40db-b9ea-319a67158d7a')
BOOT_BASE = dt.datetime(2026, 1, 5, 8, 0, tzinfo=dt.timezone.utc)
MOCK_BASE = dt.datetime(2026, 5, 4, 7, 30, tzinfo=dt.timezone.utc)

PERSON_NAMES = [
    'Ana Lucía Flores', 'Luis Fernando Rojas', 'Carla Mendoza Suárez',
    'Diego Salvatierra Paz', 'Elena Vargas Molina', 'Mateo Quiroga Ríos',
    'Valeria Montaño López', 'Jorge Andrés Rivero', 'Mariana Céspedes Arce',
    'Ricardo Peña Villarroel', 'Sofía Camacho Ortiz', 'Gabriel Núñez Rocha',
]
PRACTITIONER_NAMES = [
    'Dra. Camila Roca — Medicina Familiar', 'Dr. Andrés Mercado — Cardiología',
    'Dra. Natalia Suárez — Pediatría', 'Dr. Rodrigo Paz — Cirugía General',
    'Lic. Fernanda Rivero — Enfermería', 'Dra. Paola Gutiérrez — Radiología',
    'Dr. Martín Vargas — Anestesiología', 'Bioq. Lorena Méndez — Laboratorio',
]
ORGANIZATION_NAMES = [
    'Clínica Integral Horizonte Demo', 'Hospital Metropolitano Sandbox',
    'Centro Diagnóstico Andino Demo', 'Farmacia Salud Integral Sandbox',
    'Red de Consultorios Vida Demo', 'Aseguradora Horizonte Sandbox',
    'Laboratorio Clínico Amanecer Demo', 'Centro de Rehabilitación Equilibrio Demo',
]
BOLIVIA_LOCATIONS = [
    ('Santa Cruz de la Sierra', -17.7833, -63.1821),
    ('La Paz', -16.4897, -68.1193),
    ('Cochabamba', -17.3895, -66.1568),
    ('Sucre', -19.0353, -65.2592),
    ('Tarija', -21.5355, -64.7296),
    ('Trinidad', -14.8333, -64.9000),
    ('Oruro', -17.9833, -67.1500),
    ('Potosí', -19.5836, -65.7531),
]

MODULE_SCENARIOS: dict[str, list[str]] = {
    'iam': ['administrador de plataforma', 'operador clínico', 'médico tratante', 'enfermería', 'paciente portal', 'auditor interno', 'integración técnica', 'soporte de guardia'],
    'common': ['identidad del paciente', 'contacto principal', 'dirección de facturación', 'archivo clínico', 'imagen diagnóstica', 'documento contractual', 'evidencia de consentimiento', 'derivado de miniatura'],
    'directory': ['clínica privada', 'hospital general', 'centro diagnóstico', 'farmacia', 'aseguradora', 'consultorio', 'centro de rehabilitación', 'unidad virtual'],
    'profiles': ['paciente adulto crónico', 'paciente pediátrico', 'paciente preventivo', 'médico especialista', 'enfermera asistencial', 'bioquímico de laboratorio', 'administrador hospitalario', 'representante de seguro'],
    'consent': ['atención asistencial', 'intercambio de datos', 'telemedicina', 'investigación', 'facturación', 'marketing opcional', 'acceso de representante', 'exportación controlada'],
    'clinical': ['control de hipertensión', 'consulta respiratoria aguda', 'control pediátrico', 'seguimiento posoperatorio', 'atención preventiva', 'control prenatal', 'consulta de diabetes', 'urgencia ambulatoria'],
    'forms': ['admisión clínica', 'triaje', 'historia médica', 'consentimiento informado', 'evaluación preoperatoria', 'satisfacción', 'seguimiento crónico', 'auditoría de calidad'],
    'audit': ['inicio de sesión', 'consulta de expediente', 'actualización autorizada', 'exportación controlada', 'acceso denegado', 'cambio de política', 'ejecución de worker', 'reconciliación'],
    'system_ops': ['gobierno de datos clínicos', 'retención legal', 'residencia Bolivia', 'respaldo diario', 'restauración trimestral', 'hallazgo de control', 'remediación prioritaria', 'clasificación PHI'],
    'integrations': ['FHIR R4', 'DICOMweb', 'laboratorio LIS', 'correo transaccional', 'SMS', 'pasarela de pago', 'ERP contable', 'webhook de resultados'],
    'geo': ['ruta domiciliaria', 'visita médica', 'entrega de farmacia', 'traslado de muestra', 'ambulancia', 'visita de auditoría', 'geocerca hospitalaria', 'seguimiento logístico'],
    'practice': ['consulta externa', 'emergencias', 'hospitalización', 'quirófano', 'laboratorio', 'imagenología', 'farmacia', 'telemedicina'],
    'chart': ['nota SOAP', 'evolución médica', 'nota de enfermería', 'epicrisis', 'informe quirúrgico', 'plan de cuidados', 'documento adjunto', 'plantilla de especialidad'],
    'accounting': ['operación de caja', 'venta de servicios', 'compra de insumos', 'pago a proveedor', 'depreciación mensual', 'provisión laboral', 'cobro de seguro', 'conciliación bancaria'],
    'billing': ['consulta particular', 'facturación a seguro', 'servicio de laboratorio', 'estudio de imagen', 'farmacia', 'cirugía', 'plan de pagos', 'nota de crédito'],
    'clinical_ext': ['plan de cuidado crónico', 'referencia a especialista', 'alerta clínica', 'teleconsulta', 'regla de soporte', 'interacción medicamentosa', 'brecha de cuidado', 'orden preconfigurada'],
    'community': ['publicación educativa', 'reseña de servicio', 'comentario moderado', 'grupo profesional', 'encuesta comunitaria', 'mensaje directo', 'verificación de perfil', 'apelación de moderación'],
    'diagnostics': ['hemograma', 'glucosa', 'perfil lipídico', 'radiografía de tórax', 'ecografía abdominal', 'tomografía', 'muestra rechazada', 'resultado crítico'],
    'organization_extensions': ['hospital de segundo nivel', 'red ambulatoria', 'unidad quirúrgica', 'servicio de diagnóstico', 'licencia sanitaria', 'afiliación académica', 'frontera de datos', 'servicio hospitalario'],
    'diagnostic_units': ['laboratorio central', 'imagenología', 'patología', 'cardiología diagnóstica', 'endoscopia', 'ultrasonido', 'toma de muestras', 'diagnóstico móvil'],
    'pharmacy': ['medicamento genérico', 'medicamento de marca', 'insumo médico', 'producto refrigerado', 'controlado', 'venta libre', 'lista institucional', 'precio asegurado'],
    'pharmacy_inventory': ['recepción de lote', 'transferencia interna', 'conteo cíclico', 'reserva', 'dispensación', 'devolución', 'vencimiento próximo', 'reposición automática'],
    'insurance': ['verificación de elegibilidad', 'preautorización', 'reclamo ambulatorio', 'reclamo hospitalario', 'apelación', 'reversión', 'conciliación', 'comisión de broker'],
    'identity_assurance': ['documento nacional', 'prueba biométrica', 'validación remota', 'revisión manual', 'señal de fraude', 'vinculación federada', 'reautenticación', 'nivel alto de confianza'],
    'telemetry': ['navegación portal', 'evento clínico', 'embudo de reserva', 'conversión publicitaria', 'rendimiento API', 'error frontend', 'consentimiento analítico', 'sesión móvil'],
    'delegated_access': ['padre de menor', 'tutor legal', 'cuidador', 'apoderado', 'asistente médico', 'operador de seguro', 'auditor', 'acceso temporal'],
    'read_models': ['panel de paciente', 'agenda médica', 'bandeja de resultados', 'estado de cuenta', 'inventario de farmacia', 'pipeline CRM', 'salud de plataforma', 'indicadores de campaña'],
    'integration_contracts': ['consulta FHIR', 'notificación de resultado', 'callback de pago', 'orden de laboratorio', 'sincronización ERP', 'evento publicitario', 'exportación controlada', 'identidad federada'],
    'workflow': ['cita médica', 'orden diagnóstica', 'resultado crítico', 'factura y pago', 'reclamo de seguro', 'procedimiento quirúrgico', 'incidente operativo', 'alta de paciente'],
    'integrity': ['concurrencia optimista', 'unicidad de identidad', 'balance contable', 'idempotencia de pago', 'custodia clínica', 'retención legal', 'deduplicación de evento', 'consistencia de proyección'],
    'messaging': ['confirmación de cita', 'recordatorio', 'resultado disponible', 'alerta crítica', 'factura emitida', 'pago confirmado', 'restablecimiento de acceso', 'incidente operativo'],
    'qa_lab': ['smoke de API', 'flujo clínico E2E', 'prueba de permisos', 'restauración de backup', 'carga de agenda', 'reconciliación contable', 'contrato FHIR', 'seguridad de archivos'],
    'tracking': ['envío de medicamento', 'traslado de muestra', 'entrega de equipo', 'movimiento interno', 'ruta de ambulancia', 'documento legal', 'cadena de frío', 'devolución'],
    'erp': ['compra de insumos', 'contrato de proveedor', 'activo biomédico', 'orden de mantenimiento', 'empleado clínico', 'turno hospitalario', 'inventario general', 'centro de costo'],
    'reporting': ['reporte clínico', 'reporte financiero', 'reporte de seguros', 'reporte de farmacia', 'reporte de calidad', 'reporte publicitario', 'reporte operativo', 'reporte regulatorio'],
    'auth_providers': ['identidad local', 'OIDC corporativo', 'SAML hospitalario', 'directorio de aseguradora', 'federación médica', 'identidad de paciente', 'cuenta de servicio', 'recuperación de cuenta'],
    'scheduling': ['consulta general', 'consulta especialista', 'teleconsulta', 'laboratorio', 'imagenología', 'cirugía', 'control posoperatorio', 'vacunación'],
    'payments': ['pago QR', 'tarjeta tokenizada', 'transferencia bancaria', 'pago de factura', 'reembolso parcial', 'contracargo', 'payout a profesional', 'conciliación de gateway'],
    'ads': ['captación de pacientes', 'campaña de chequeo', 'promoción de laboratorio', 'educación sanitaria', 'remarketing permitido', 'lead de seguro', 'optimización de conversión', 'control de política'],
    'health_context': ['vigilancia epidemiológica', 'capacidad hospitalaria', 'regulación sanitaria', 'medicamentos esenciales', 'vacunación', 'alerta de brote', 'contexto económico', 'calidad de fuente'],
    'system_context': ['contexto país', 'contexto tenant', 'regla de disponibilidad', 'enum clínico', 'enum financiero', 'enum de workflow', 'actualización programada', 'vinculación contextual'],
    'platform_ops': ['API clínica', 'worker de mensajería', 'gateway FHIR', 'servicio de pagos', 'índice de búsqueda', 'plataforma de datos', 'incidente crítico', 'ejercicio de resiliencia'],
    'education': ['curso de seguridad del paciente', 'actualización clínica', 'capacitación FHIR', 'bioseguridad', 'farmacovigilancia', 'RCP', 'protección de datos', 'calidad diagnóstica'],
    'automation': ['agente de contexto', 'clasificador de documentos', 'asistente clínico controlado', 'reconciliador', 'detector de anomalías', 'workflow de aprobación', 'guardrail de PHI', 'memoria gobernada'],
    'crm': ['cuenta hospitalaria', 'contacto de aseguradora', 'lead de clínica', 'oportunidad de convenio', 'llamada de seguimiento', 'correo comercial', 'caso de soporte', 'renovación contractual'],
    'marketing': ['segmento preventivo', 'campaña de vacunación', 'journey de onboarding', 'recordatorio de control', 'contenido educativo', 'atribución de cita', 'enlace rastreado', 'exclusión por consentimiento'],
    'promotions': ['programa de lealtad', 'nivel de membresía', 'descuento preventivo', 'cupón de laboratorio', 'referido de paciente', 'acumulación de puntos', 'redención', 'expiración'],
    'health_data': ['fuente FHIR', 'fuente HL7 v2', 'fuente DICOM', 'ingesta de laboratorio', 'recurso canónico', 'resolución de identidad', 'control de calidad', 'exportación desidentificada'],
    'procedures_perioperative': ['colecistectomía laparoscópica', 'apendicectomía', 'cesárea', 'artroscopia', 'endoscopia', 'biopsia', 'cirugía ambulatoria', 'procedimiento cancelado'],
    'polyglot_storage': ['PostgreSQL canónico', 'documentos FHIR', 'cache Redis', 'índice de búsqueda', 'series temporales', 'vectores RAG', 'objetos DICOM', 'lakehouse analítico'],
    'document_store': ['recurso FHIR', 'bundle de intercambio', 'payload externo', 'formulario dinámico', 'contexto de país', 'workflow', 'ejecución de IA', 'contenido CMS'],
    'redis_runtime': ['sesión', 'refresh token', 'MFA', 'rate limit', 'idempotencia', 'lock distribuido', 'presencia', 'progreso de job'],
    'search_platform': ['directorio de profesionales', 'directorio de centros', 'terminología', 'medicamentos', 'educación', 'comunidad', 'contratos', 'auditoría'],
    'time_series': ['signos vitales', 'telemetría de dispositivo', 'métrica de API', 'entrega publicitaria', 'gateway de pago', 'analizador de laboratorio', 'ingesta de datos', 'SLI operativo'],
    'vector_rag': ['guía clínica', 'política institucional', 'manual de operación', 'consentimiento', 'curso médico', 'evidencia de respuesta', 'feedback de recuperación', 'borrado vectorial'],
    'object_storage': ['archivo clínico', 'estudio DICOM', 'serie DICOM', 'instancia DICOM', 'informe PDF', 'evidencia legal', 'archivo de exportación', 'objeto archivado'],
    'graph_intelligence': ['relación paciente-profesional', 'red de organización', 'beneficiario-aseguradora', 'proveedor-contrato', 'riesgo de fraude', 'ruta de acceso', 'comunidad clínica', 'eliminación de nodo'],
    'cross_store_consistency': ['proyección clínica', 'proyección financiera', 'reindexación', 'invalidación de cache', 'borrado distribuido', 'reconciliación', 'migración de esquema', 'archivo histórico'],
    'lakehouse': ['zona raw', 'zona standardized', 'zona curated', 'producto clínico', 'producto financiero', 'cohorte de investigación', 'release desidentificado', 'control de calidad'],
}

ENTITY_CATALOGS: dict[str, list[tuple[str, str]]] = {
    'permission_categories': [('CLINICAL', 'Operaciones clínicas'), ('IDENTITY', 'Identidad y acceso'), ('FINANCE', 'Finanzas y contabilidad'), ('PRIVACY', 'Privacidad y consentimiento'), ('OPERATIONS', 'Operaciones de plataforma'), ('INTEGRATIONS', 'Integraciones'), ('GROWTH', 'CRM, marketing y publicidad'), ('DATA', 'Datos, reportes y analítica')],
    'roles': [('PLATFORM_ADMIN', 'Administrador de plataforma'), ('TENANT_ADMIN', 'Administrador de organización'), ('PHYSICIAN', 'Médico'), ('NURSE', 'Enfermería'), ('PATIENT', 'Paciente'), ('ACCOUNTANT', 'Contabilidad'), ('AUDITOR', 'Auditor'), ('SUPPORT', 'Soporte operativo'), ('LAB_OPERATOR', 'Operador de laboratorio'), ('PHARMACY_OPERATOR', 'Operador de farmacia'), ('INSURANCE_OPERATOR', 'Operador de seguros'), ('MARKETING_OPERATOR', 'Operador de marketing')],
    'processing_purposes': [('TREATMENT', 'Atención y continuidad asistencial'), ('PAYMENT', 'Facturación y pago'), ('OPERATIONS', 'Operaciones sanitarias'), ('PUBLIC_HEALTH', 'Salud pública'), ('RESEARCH', 'Investigación autorizada'), ('QUALITY', 'Calidad y seguridad del paciente'), ('LEGAL', 'Obligación legal'), ('MARKETING', 'Comunicaciones opcionales')],
    'account_groups': [('1', 'Activo'), ('2', 'Pasivo'), ('3', 'Patrimonio'), ('4', 'Ingresos'), ('5', 'Costos'), ('6', 'Gastos'), ('7', 'Cuentas de orden')],
    'accounts': [('110101', 'Caja general'), ('110201', 'Bancos moneda nacional'), ('110301', 'Cuentas por cobrar pacientes'), ('110302', 'Cuentas por cobrar aseguradoras'), ('110401', 'Inventario de farmacia'), ('120101', 'Equipos médicos'), ('120102', 'Depreciación acumulada de equipos'), ('210101', 'Cuentas por pagar proveedores'), ('210201', 'Obligaciones sociales'), ('310101', 'Capital social'), ('410101', 'Ingresos por consultas'), ('410102', 'Ingresos por laboratorio'), ('410103', 'Ingresos por imagenología'), ('510101', 'Costo de medicamentos'), ('610101', 'Sueldos y salarios'), ('610201', 'Servicios básicos'), ('610301', 'Depreciación del periodo')],
    'cost_centers': [('ADM', 'Administración'), ('CONS_EXT', 'Consulta externa'), ('EMERG', 'Emergencias'), ('HOSP', 'Hospitalización'), ('QX', 'Quirófano'), ('LAB', 'Laboratorio'), ('IMG', 'Imagenología'), ('FAR', 'Farmacia'), ('TI', 'Tecnología'), ('COM', 'Comercial y marketing')],
    'tax_codes': [('IVA_DF_13', 'IVA débito fiscal 13%'), ('IVA_CF_13', 'IVA crédito fiscal 13%'), ('EXENTO', 'Operación exenta'), ('NO_ALCANZADO', 'Operación no alcanzada'), ('RETENCION_SERV', 'Retención por servicios'), ('TASA_CERO', 'Tasa cero')],
    'service_catalog': [('CONS_GEN', 'Consulta médica general'), ('CONS_ESP', 'Consulta de especialidad'), ('TELECONS', 'Teleconsulta'), ('LAB_HEM', 'Hemograma completo'), ('LAB_GLU', 'Glucosa en sangre'), ('IMG_RXTX', 'Radiografía de tórax'), ('IMG_ECOABD', 'Ecografía abdominal'), ('PROC_AMB', 'Procedimiento ambulatorio'), ('HOSP_DIA', 'Día de hospitalización'), ('FARM_DISP', 'Servicio de dispensación')],
    'payment_gateways': [('QR_LOCAL', 'Procesador QR interoperable'), ('CARD_TOKEN', 'Procesador de tarjeta tokenizada'), ('BANK_TRANSFER', 'Transferencia bancaria conciliada'), ('WALLET', 'Billetera digital'), ('CASH_OFFLINE', 'Pago presencial registrado'), ('INSURANCE_SETTLEMENT', 'Liquidación de aseguradora')],
    'pipelines': [('B2B_HEALTH', 'Convenios institucionales'), ('PROVIDER_NETWORK', 'Red de prestadores'), ('INSURANCE', 'Alianzas con aseguradoras'), ('SUPPLIERS', 'Proveedores estratégicos')],
    'pipeline_stages': [('PROSPECT', 'Prospecto'), ('QUALIFIED', 'Calificado'), ('DISCOVERY', 'Levantamiento de necesidades'), ('PROPOSAL', 'Propuesta enviada'), ('NEGOTIATION', 'Negociación'), ('LEGAL_REVIEW', 'Revisión legal'), ('WON', 'Ganada'), ('LOST', 'Perdida')],
    'appointment_types': [('GENERAL', 'Consulta general'), ('SPECIALIST', 'Consulta de especialidad'), ('TELEMEDICINE', 'Teleconsulta'), ('LAB', 'Toma de muestra'), ('IMAGING', 'Estudio de imagen'), ('VACCINE', 'Vacunación'), ('PREOP', 'Evaluación preoperatoria'), ('POSTOP', 'Control posoperatorio')],
    'message_templates': [('APPOINTMENT_CONFIRM', 'Confirmación de cita'), ('APPOINTMENT_REMINDER', 'Recordatorio de cita'), ('RESULT_READY', 'Resultado disponible'), ('CRITICAL_RESULT', 'Alerta de resultado crítico'), ('INVOICE_ISSUED', 'Factura emitida'), ('PAYMENT_CONFIRMED', 'Pago confirmado'), ('PASSWORD_RESET', 'Restablecimiento de acceso'), ('INCIDENT_NOTICE', 'Comunicado de incidente')],
    'data_classifications': [('PUBLIC', 'Público'), ('INTERNAL', 'Uso interno'), ('CONFIDENTIAL', 'Confidencial'), ('PHI', 'Información clínica protegida'), ('PII', 'Datos personales'), ('FINANCIAL', 'Información financiera'), ('SECURITY', 'Información de seguridad'), ('RESEARCH_DEID', 'Investigación desidentificada')],
    'fhir_profile_definitions': [('PATIENT_BO', 'Perfil Paciente Bolivia'), ('PRACTITIONER_BO', 'Perfil Profesional Bolivia'), ('ENCOUNTER_BO', 'Perfil Encuentro Bolivia'), ('OBSERVATION_LAB_BO', 'Perfil Observación de laboratorio'), ('DIAGNOSTIC_REPORT_BO', 'Perfil Informe diagnóstico'), ('PROCEDURE_BO', 'Perfil Procedimiento'), ('CONSENT_BO', 'Perfil Consentimiento'), ('BUNDLE_EXCHANGE', 'Bundle de intercambio controlado')],
    'health_data_quality_rule_sets': [('IDENTITY', 'Calidad de identidad'), ('CLINICAL_COMPLETENESS', 'Completitud clínica'), ('TERMINOLOGY', 'Conformidad terminológica'), ('TEMPORAL', 'Consistencia temporal'), ('PROVENANCE', 'Trazabilidad y procedencia'), ('FHIR', 'Conformidad FHIR'), ('DUPLICATES', 'Detección de duplicados'), ('EXPORT', 'Elegibilidad de exportación')],
    'object_namespaces': [('CLINICAL_DOCS', 'Documentos clínicos'), ('DICOM', 'Objetos DICOM'), ('CONSENT_EVIDENCE', 'Evidencias de consentimiento'), ('BILLING', 'Documentos de facturación'), ('AUDIT_WORM', 'Auditoría inmutable'), ('EXPORTS', 'Exportaciones controladas'), ('EDUCATION', 'Contenido educativo'), ('ADS_ASSETS', 'Activos publicitarios')],
    'vector_collections': [('CLINICAL_GUIDANCE', 'Guías clínicas'), ('INSTITUTIONAL_POLICY', 'Políticas institucionales'), ('OPERATIONS_RUNBOOKS', 'Runbooks operativos'), ('TERMINOLOGY', 'Terminología clínica'), ('EDUCATION', 'Contenido educativo'), ('CONTRACTS', 'Contratos y convenios'), ('HEALTH_CONTEXT', 'Contexto de salud por país'), ('PRODUCT_SUPPORT', 'Base de conocimiento de soporte')],
    'data_lake_zones': [('LANDING', 'Zona de aterrizaje controlado'), ('RAW', 'Datos recibidos sin transformación'), ('QUARANTINE', 'Datos en cuarentena'), ('STANDARDIZED', 'Datos estandarizados'), ('CURATED', 'Datos curados'), ('SERVING', 'Datos para consumo analítico'), ('ARCHIVE', 'Archivo histórico')],
    'users': [('SYSTEM_BOOTSTRAP', 'System Bootstrap'), ('SYSTEM_WORKER', 'System Worker'), ('SYSTEM_INTEGRATION', 'System Integration'), ('SYSTEM_SCHEDULER', 'System Scheduler'), ('SYSTEM_AUDITOR', 'System Auditor'), ('SYSTEM_RECONCILIATION', 'System Reconciliation')],
    'departments': [('CLINICAL', 'Atención clínica'), ('NURSING', 'Enfermería'), ('DIAGNOSTICS', 'Diagnóstico'), ('PHARMACY', 'Farmacia'), ('FINANCE', 'Finanzas'), ('OPERATIONS', 'Operaciones'), ('IT_SECURITY', 'Tecnología y seguridad'), ('HUMAN_RESOURCES', 'Talento humano'), ('QUALITY', 'Calidad y seguridad del paciente'), ('COMMERCIAL', 'Comercial y convenios')],
    'positions': [('MEDICAL_DIRECTOR', 'Dirección médica'), ('STAFF_PHYSICIAN', 'Médico asistencial'), ('HEAD_NURSE', 'Jefatura de enfermería'), ('NURSE', 'Enfermería asistencial'), ('LAB_ANALYST', 'Bioquímica de laboratorio'), ('RADIOLOGY_TECH', 'Tecnología en imagenología'), ('PHARMACIST', 'Farmacia clínica'), ('ACCOUNTANT', 'Contabilidad'), ('PLATFORM_ADMIN', 'Administración de plataforma'), ('CUSTOMER_SUPPORT', 'Soporte al usuario')],
    'storage_backends': [('POSTGRESQL_CANONICAL', 'PostgreSQL canónico'), ('DOCUMENT_STORE', 'Almacén documental'), ('REDIS_RUNTIME', 'Redis de runtime'), ('SEARCH_PLATFORM', 'Plataforma de búsqueda'), ('TIME_SERIES', 'Almacén de series temporales'), ('VECTOR_STORE', 'Almacén vectorial'), ('OBJECT_STORAGE', 'Almacenamiento de objetos'), ('GRAPH_STORE', 'Grafo de inteligencia'), ('LAKEHOUSE', 'Lakehouse analítico'), ('PACS_VNA', 'PACS/VNA de imagen médica'), ('AUDIT_WORM', 'Bóveda WORM de auditoría'), ('BACKUP_VAULT', 'Bóveda de respaldos')],
    'payment_channel_catalog': [('QR', 'QR interoperable'), ('CARD', 'Tarjeta tokenizada'), ('BANK_TRANSFER', 'Transferencia bancaria'), ('CASH', 'Pago en caja'), ('WALLET', 'Billetera digital'), ('INSURANCE', 'Liquidación de aseguradora'), ('PAYMENT_LINK', 'Enlace de pago')],
    'subscription_plans': [('STARTER', 'Plan inicial'), ('CLINIC', 'Plan clínica'), ('HOSPITAL', 'Plan hospital'), ('NETWORK', 'Plan red de prestadores'), ('ENTERPRISE', 'Plan empresarial'), ('SANDBOX', 'Plan de pruebas no productivo')],
    'fee_schedules': [('DEFAULT_BOB', 'Tarifario base en bolivianos'), ('INSURANCE', 'Tarifario para aseguradoras'), ('PROFESSIONAL', 'Tarifario por profesional'), ('LABORATORY', 'Tarifario de laboratorio'), ('IMAGING', 'Tarifario de imagenología'), ('PHARMACY', 'Tarifario de farmacia')],
    'health_source_systems': [('FHIR_HOSPITAL', 'Servidor FHIR hospitalario'), ('LIS_LAB', 'Sistema de laboratorio LIS'), ('PACS_DICOM', 'PACS DICOM'), ('PHARMACY', 'Sistema de farmacia'), ('INSURANCE', 'Plataforma de aseguradora'), ('PUBLIC_HEALTH', 'Fuente de salud pública'), ('MANUAL_CURATED', 'Carga manual curada'), ('LEGACY_HL7', 'Integración HL7 heredada')],
    'diagnostic_units': [('LAB_CENTRAL', 'Laboratorio Clínico Central Demo'), ('IMAGING_CENTER', 'Centro de Imagenología Andino Demo'), ('PATHOLOGY', 'Unidad de Anatomía Patológica Demo'), ('CARDIO_DIAG', 'Centro de Diagnóstico Cardiológico Demo'), ('ENDOSCOPY', 'Unidad de Endoscopia Demo'), ('ULTRASOUND', 'Centro de Ecografía Demo'), ('SAMPLE_COLLECTION', 'Unidad de Toma de Muestras Demo'), ('MOBILE_DIAGNOSTICS', 'Diagnóstico Móvil Demo')],
    'pharmacies': [('FARM_CENTRAL', 'Farmacia Hospitalaria Central Demo'), ('FARM_AMB', 'Farmacia Ambulatoria Vida Demo'), ('FARM_SPECIALTY', 'Farmacia de Especialidades Demo'), ('FARM_ONCO', 'Farmacia Oncológica Demo'), ('FARM_COLD', 'Farmacia de Cadena de Frío Demo'), ('FARM_COMMUNITY', 'Farmacia Comunitaria Horizonte Demo'), ('FARM_HOME', 'Farmacia con Entrega Domiciliaria Demo'), ('FARM_24H', 'Farmacia 24 Horas Demo')],
    'insurance_carriers': [('ASEG_HORIZONTE', 'Aseguradora Horizonte Salud Demo'), ('MUTUAL_VIDA', 'Mutual Vida Integral Demo'), ('SEGURO_ANDINO', 'Seguro Médico Andino Demo'), ('CORP_HEALTH', 'Cobertura Corporativa Salud Demo'), ('PUBLIC_PLAN', 'Plan Público de Pruebas'), ('INTERNATIONAL', 'Cobertura Internacional Sandbox')],
    'insurance_brokers': [('BROKER_INTEGRAL', 'Corredora Integral de Salud Demo'), ('BROKER_CORP', 'Corredora Corporativa Demo'), ('BROKER_FAMILY', 'Asesoría Familiar de Seguros Demo'), ('BROKER_DIGITAL', 'Broker Digital Sandbox'), ('BROKER_NETWORK', 'Red de Corredores Médicos Demo'), ('BROKER_INTL', 'Broker Internacional Sandbox')],
}

FIELD_VALUE_CATALOGS: dict[tuple[str, str], list[Any]] = {
    ('storage_backends', 'backend_type'): ['POSTGRESQL', 'DOCUMENT', 'REDIS', 'OPENSEARCH', 'TIMESERIES', 'VECTOR', 'OBJECT', 'GRAPH', 'LAKEHOUSE', 'DICOM', 'WORM', 'BACKUP'],
    ('storage_backends', 'provider_code'): ['CONFIGURE'] * 12,
    ('storage_backends', 'state'): ['DRAFT'] * 12,
    ('data_lake_zones', 'zone_type'): ['LANDING', 'RAW', 'QUARANTINE', 'STANDARDIZED', 'CURATED', 'SERVING', 'ARCHIVE'],
    ('data_lake_zones', 'encryption_profile_code'): ['PLATFORM_MANAGED'] * 7,
    ('data_lake_zones', 'retention_policy_code'): ['CONFIGURE_BY_JURISDICTION'] * 7,
    ('data_lake_zones', 'state'): ['DRAFT'] * 7,
    ('payment_gateways', 'state'): ['DRAFT'] * 6,
    ('vector_collections', 'distance_metric'): ['cosine'] * 8,
    ('vector_collections', 'lifecycle_state'): ['DRAFT'] * 8,
}

SYSTEM_ACCOUNT_NAMES = [label for _, label in ENTITY_CATALOGS['users']]
EMPLOYEE_NAMES = ['Dra. Camila Roca', 'Dr. Andrés Mercado', 'Lic. Fernanda Rivero', 'Bioq. Lorena Méndez', 'Paola Gutiérrez', 'Rodrigo Paz', 'Carla Mendoza', 'Diego Salvatierra', 'Elena Vargas', 'Gabriel Núñez', 'Mariana Céspedes', 'Ricardo Peña']
AGE_VALUES = [42, 8, 67, 31, 54, 17, 45, 72, 36, 25, 59, 14]
SALARY_VALUES = [8500, 12000, 6200, 7000, 5600, 4800, 9500, 7800, 6500, 5200, 15000, 4300]

KEY_MOCK_ENTITIES = {
    'persons', 'patient_profiles', 'health_practitioner_profiles', 'encounters',
    'observations', 'conditions', 'service_requests', 'diagnostic_reports',
    'appointments', 'invoices', 'invoice_lines', 'journal_transactions',
    'ledger_entries', 'payments_received', 'payment_intents', 'payment_transactions',
    'crm_accounts', 'contacts', 'leads', 'opportunities', 'crm_activities',
    'campaigns', 'ad_sets', 'ads', 'health_ingestion_records',
    'canonical_health_resources', 'procedure_cases', 'operative_reports',
    'specimens', 'imaging_studies', 'pharmacy_products', 'inventory_lots',
    'insurance_claims', 'appointment_bookings', 'workflow_runs', 'audit_log',
}

HIGH_VALUE_BOOT_ENTITIES = {
    'roles', 'permissions', 'permission_categories', 'processing_purposes',
    'account_groups', 'accounts', 'cost_centers', 'service_catalog', 'tax_codes',
    'message_templates', 'data_classifications', 'pipelines', 'pipeline_stages',
    'payment_gateways', 'appointment_types', 'fhir_profile_definitions',
    'health_data_quality_rule_sets', 'object_namespaces', 'vector_collections',
    'data_lake_zones', 'dynamic_enum_definitions', 'workflow_definitions',
    'report_definitions', 'search_index_templates', 'storage_backends',
}

GENERIC_RE = re.compile(r'(?i)^(mock|boot|sample|test|default)\b|\b(mock|sample|placeholder)\b|mock_\d+|boot_\d+')
PLACEHOLDER_RE = re.compile(r'(?i)^(mock|boot|sample|test|default)(?:[_\s-]+[a-z0-9]+)*(?:[_\s-]+\d+)?$|^(mock|boot)_\d+$')
UUID_RE = re.compile(r'^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$', re.I)


def stable_uuid(*parts: Any) -> str:
    return str(uuid.uuid5(NAMESPACE, '|'.join(map(str, parts))))


def slugify(text: str) -> str:
    text = text.upper()
    replacements = str.maketrans('ÁÉÍÓÚÜÑ', 'AEIOUUN')
    text = text.translate(replacements)
    text = re.sub(r'[^A-Z0-9]+', '_', text).strip('_')
    return text[:64] or 'ITEM'


def entity_title(entity: str) -> str:
    words = entity.replace('_history', '').replace('_view', '').split('_')
    return ' '.join(words).capitalize()


def scenario_for(module_code: str, index: int) -> str:
    bank = MODULE_SCENARIOS.get(module_code) or [entity_title(module_code)]
    return bank[index % len(bank)]


def catalog_pair(entity: str, index: int, module_code: str) -> tuple[str, str]:
    if entity in ENTITY_CATALOGS:
        values = ENTITY_CATALOGS[entity]
        return values[index % len(values)]
    scenario = scenario_for(module_code, index)
    label = f'{entity_title(entity)} — {scenario}'
    return f'{slugify(entity)[:28]}_{index + 1:02d}', label


def deterministic_time(section: str, module_num: int, entity_index: int, row_index: int) -> dt.datetime:
    base = BOOT_BASE if section == 'boot' else MOCK_BASE
    return base + dt.timedelta(days=module_num * 2 + row_index * 5, minutes=entity_index * 7 + row_index * 11)


def iso(value: dt.datetime) -> str:
    return value.astimezone(dt.timezone.utc).isoformat(timespec='seconds').replace('+00:00', 'Z')


def improve_string(
    value: str,
    field: str,
    entity: str,
    module_code: str,
    section: str,
    row_index: int,
    original_count: int,
    scenario: str,
    code: str,
    label: str,
) -> str:
    lower = field.lower()
    is_clone = row_index >= original_count
    generic = bool(GENERIC_RE.search(value)) or value in {'', 'N/A', 'TBD'}
    explicit_values = FIELD_VALUE_CATALOGS.get((entity, lower))
    if explicit_values:
        return explicit_values[row_index % len(explicit_values)]

    if lower == 'id' or lower.endswith('_id'):
        return value
    if 'hash' in lower or lower in {'checksum', 'etag', 'fingerprint', 'digest'}:
        return hashlib.sha256(f'{module_code}|{section}|{entity}|{row_index}|{field}'.encode()).hexdigest()
    if lower in {'code', 'internal_code', 'property_code', 'metric_code', 'rule_code'} or lower.endswith('_code'):
        return code if (is_clone or generic) else value
    if lower in {'slug', 'key', 'natural_key'} or lower.endswith('_key'):
        return slugify(f'{module_code}-{entity}-{scenario}-{row_index + 1}').lower() if (is_clone or generic) else value
    if 'email' in lower:
        domain = 'bootstrap.salud.example.invalid' if section == 'boot' else 'mock.salud.example.invalid'
        return f'{slugify(entity).lower()}.{row_index + 1:02d}@{domain}'
    if 'phone' in lower or lower in {'msisdn'}:
        module_digits = int(hashlib.sha256(module_code.encode()).hexdigest()[:6], 16) % 900 + 100
        return f'+591700{module_digits:03d}{row_index + 10:03d}'
    if lower in {'url', 'uri', 'endpoint', 'endpoint_uri', 'control_plane_endpoint', 'callback_url', 'webhook_url', 'canonical_url', 'official_url', 'base_url'} or lower.endswith('_url') or lower.endswith('_uri') or lower.endswith('_endpoint'):
        if section == 'boot' and not is_clone and not generic:
            return value
        domain = 'config.salud.example.invalid' if section == 'boot' else 'mock.salud.example.invalid'
        return f'https://{module_code}.{domain}/{entity.replace("_", "-")}/{row_index + 1}'
    if lower in {'display_name'}:
        if entity == 'users' and section == 'boot':
            return SYSTEM_ACCOUNT_NAMES[row_index % len(SYSTEM_ACCOUNT_NAMES)]
        if entity in {'persons', 'users', 'contacts', 'instructors'}:
            return PERSON_NAMES[row_index % len(PERSON_NAMES)]
        if 'practitioner' in entity or 'provider' in entity:
            return PRACTITIONER_NAMES[row_index % len(PRACTITIONER_NAMES)]
        if entity in ENTITY_CATALOGS:
            return label
        return value if not generic else label
    if lower in {'full_name', 'legal_name'}:
        if entity in {'employees', 'persons', 'contacts', 'users'}:
            return EMPLOYEE_NAMES[row_index % len(EMPLOYEE_NAMES)] if entity == 'employees' else PERSON_NAMES[row_index % len(PERSON_NAMES)]
        return label
    if lower in {'name', 'title', 'label', 'display', 'subject'} or lower.endswith('_name') or lower.endswith('_title'):
        if entity in ENTITY_CATALOGS:
            return label
        if entity in {'persons', 'contacts'}:
            return PERSON_NAMES[row_index % len(PERSON_NAMES)]
        if 'organization' in entity or entity in {'tenants', 'practices', 'hospitals', 'pharmacies', 'crm_accounts', 'vendors'}:
            return ORGANIZATION_NAMES[row_index % len(ORGANIZATION_NAMES)]
        if 'practitioner' in entity or 'instructor' in entity:
            return PRACTITIONER_NAMES[row_index % len(PRACTITIONER_NAMES)]
        return label if generic else (value if not is_clone else f'{label} {row_index + 1:02d}')
    if lower in {'description', 'definition', 'summary', 'purpose', 'rationale', 'reason', 'notes', 'note', 'details', 'instructions', 'message', 'body', 'content'} or any(token in lower for token in ['description', 'summary', 'reason', 'note_text', 'instructions']):
        if section == 'boot':
            return f'Configuración de arranque para {scenario}, aplicable al dominio {entity_title(entity).lower()}; debe revisarse por tenant y jurisdicción cuando corresponda.'
        return f'Escenario sintético de {scenario} para validar el flujo de {entity_title(entity).lower()} sin utilizar información personal real.'
    if 'address' in lower:
        city = BOLIVIA_LOCATIONS[row_index % len(BOLIVIA_LOCATIONS)][0]
        return f'Av. Demostración {100 + row_index}, zona de pruebas, {city}'
    if lower in {'city', 'locality', 'municipality'}:
        return BOLIVIA_LOCATIONS[row_index % len(BOLIVIA_LOCATIONS)][0]
    if lower in {'country', 'country_code'}:
        return 'BO'
    if 'timezone' in lower or lower == 'time_zone':
        return 'America/La_Paz'
    if 'currency' in lower and not lower.endswith('_id'):
        return 'BOB'
    if lower in {'version', 'schema_version', 'policy_version', 'template_version'}:
        return f'1.{row_index // 10}.{row_index % 10}'
    if lower in {'external_subject', 'external_reference', 'external_id', 'provider_reference', 'reference_number', 'document_number', 'invoice_number', 'transaction_reference', 'batch_identifier'} or lower.endswith('_number'):
        return f'{slugify(module_code)[:8]}-{slugify(entity)[:12]}-{row_index + 1:06d}'
    if lower in {'system', 'namespace', 'issuer', 'owner'} and generic:
        return f'urn:salud:{module_code}:{entity}'
    # Preserve valid enum/state/type values when cloning; replacing them with labels corrupts domain semantics.
    if re.fullmatch(r'[A-Z][A-Z0-9_:\-.]{1,80}', value) and not generic:
        return value
    if any(token in lower for token in ['status', 'state', 'type', 'kind', 'mode', 'method', 'format', 'protocol', 'algorithm', 'metric', 'level', 'unit']) and not generic:
        return value
    if generic:
        return code if any(token in lower for token in ['code', 'key', 'type', 'state', 'status']) else f'{label} {row_index + 1:02d}'
    return value


def improve_scalar(
    value: Any,
    field: str,
    entity: str,
    module_code: str,
    section: str,
    row_index: int,
    original_count: int,
    timestamp: dt.datetime,
    scenario: str,
    code: str,
    label: str,
) -> Any:
    lower = field.lower()
    if isinstance(value, str):
        if lower == 'birth_date':
            years = [1988, 2016, 1974, 1995, 1962, 2008, 1981, 1957, 1990, 2001, 1970, 2012]
            return f'{years[row_index % len(years)]}-{(row_index % 12) + 1:02d}-{(row_index * 3 % 27) + 1:02d}'
        if lower in {'hire_date', 'employment_start_date'}:
            years = [2018, 2020, 2015, 2022, 2019, 2021, 2017, 2023, 2016, 2024, 2014, 2025]
            return f'{years[row_index % len(years)]}-{(row_index % 12) + 1:02d}-{(row_index * 2 % 27) + 1:02d}'
        if re.match(r'^\d{4}-\d{2}-\d{2}$', value):
            if 'end' in lower or 'to' in lower or 'expiry' in lower or 'expires' in lower:
                return (timestamp.date() + dt.timedelta(days=30 + row_index * 15)).isoformat()
            return timestamp.date().isoformat()
        if value.endswith('Z') and 'T' in value:
            if lower in {'created_at', 'recorded_at', 'occurred_at', 'received_at', 'started_at', 'issued_at', 'published_at', 'captured_at'} or lower.endswith('_at'):
                if any(x in lower for x in ['expires', 'ended', 'completed', 'valid_to', 'closed', 'resolved', 'finished']):
                    return iso(timestamp + dt.timedelta(hours=2 + row_index % 5))
                if lower == 'updated_at':
                    return iso(timestamp + dt.timedelta(minutes=15 + row_index))
                return iso(timestamp)
        return improve_string(value, field, entity, module_code, section, row_index, original_count, scenario, code, label)

    if isinstance(value, bool):
        if lower == 'deceased':
            return row_index in {3, 10}
        if any(token in lower for token in ['deleted', 'blocked', 'revoked', 'expired', 'anonymized']):
            return False
        if lower.startswith('is_') or lower in {'enabled', 'active', 'verified', 'preferred', 'selectable', 'included', 'required'}:
            return row_index % 6 != 5
        return value

    if isinstance(value, int) and not isinstance(value, bool):
        if lower == 'row_version':
            return 1
        if 'age' in lower and 'stage' not in lower:
            return AGE_VALUES[row_index % len(AGE_VALUES)]
        if any(token in lower for token in ['salary', 'amount', 'price', 'total', 'cost', 'balance', 'budget', 'fee', 'value']):
            return SALARY_VALUES[row_index % len(SALARY_VALUES)] if 'salary' in lower else int(100 + row_index * 175)
        if lower.endswith('_year') or lower in {'year', 'fiscal_year'}:
            return 2026
        if any(token in lower for token in ['ordinal', 'rank', 'sequence', 'priority', 'position', 'attempt']):
            return row_index + 1
        if 'duration_minutes' in lower:
            return [15, 30, 45, 60, 90, 120][row_index % 6]
        if any(token in lower for token in ['count', 'quantity', 'capacity', 'limit', 'size']):
            return max(1, (row_index + 1) * 5)
        return value if row_index < original_count else row_index + 1

    if isinstance(value, float):
        if 'latitude' in lower:
            return BOLIVIA_LOCATIONS[row_index % len(BOLIVIA_LOCATIONS)][1]
        if 'longitude' in lower:
            return BOLIVIA_LOCATIONS[row_index % len(BOLIVIA_LOCATIONS)][2]
        if any(token in lower for token in ['rate', 'percent', 'score', 'confidence', 'probability']):
            return round(0.55 + (row_index % 9) * 0.045, 4)
        if any(token in lower for token in ['salary', 'amount', 'price', 'total', 'cost', 'balance', 'budget', 'fee', 'value']):
            return float(SALARY_VALUES[row_index % len(SALARY_VALUES)]) if 'salary' in lower else round(100.0 + row_index * 175.5, 2)
        return round(value + row_index * 0.1, 4)

    if isinstance(value, dict):
        result = copy.deepcopy(value)
        if lower == 'capabilities_json':
            return {
                'idempotency_keys': True,
                'tokenization': True,
                'webhooks': True,
                'refunds': True,
                'partial_refunds': True,
                'disputes': True,
                'reconciliation_exports': True,
                'raw_card_data_allowed': False,
            }
        if lower == 'supported_currencies_json':
            return {'currencies': ['BOB', 'USD'], 'settlement_currency': 'BOB'}
        if lower == 'configuration_json':
            result.update({'enabled': True, 'timeout_ms': 5000, 'max_retries': 3, 'retry_backoff': 'exponential', 'required_validation': True})
        elif any(token in lower for token in ['policy_json', 'rules_json', 'settings_json', 'config_json']):
            result.update({'enabled': True, 'version': '1.0', 'review_required': section == 'boot'})
        for key, nested_value in list(result.items()):
            if isinstance(nested_value, str) and GENERIC_RE.search(nested_value):
                result[key] = code if 'code' in key.lower() else scenario
        return result

    if isinstance(value, list):
        return value

    if value is None:
        # Keep nullable fields null except a few semantically useful fields.
        if lower in {'deceased_at', 'anonymized_at', 'revoked_at', 'deleted_at', 'valid_to', 'ended_at'}:
            return None
        return None
    return value


def target_count(section: str, module_code: str, entity: str, current: int) -> int:
    if current == 0:
        return 0
    if module_code == 'terminology':
        return current
    if section == 'boot':
        if entity in ENTITY_CATALOGS:
            return max(current, len(ENTITY_CATALOGS[entity]))
        if entity in HIGH_VALUE_BOOT_ENTITIES:
            return max(current, 12)
        if current >= 20:
            return current
        return max(current, 8)
    if entity in ENTITY_CATALOGS:
        return max(current, len(ENTITY_CATALOGS[entity]))
    if entity in KEY_MOCK_ENTITIES:
        return max(current, 12)
    if 'history' in entity or 'log' in entity or 'event' in entity or 'run' in entity:
        return max(current, 8)
    return max(current, 8)


def clone_records(
    records: list[dict[str, Any]],
    target: int,
    section: str,
    module_code: str,
    entity: str,
    primary_key_fields: list[str],
) -> list[dict[str, Any]]:
    if not records or len(records) >= target:
        return copy.deepcopy(records)
    result = copy.deepcopy(records)
    template_count = len(records)
    for index in range(len(records), target):
        source = copy.deepcopy(records[index % template_count])
        keys = primary_key_fields or (["id"] if "id" in source else [])
        for key in keys:
            old_value = source.get(key)
            if isinstance(old_value, str) and UUID_RE.match(old_value):
                source[key] = stable_uuid("SALUD", "4.1", section, module_code, entity, key, old_value, index)
            elif isinstance(old_value, str):
                source[key] = f"{slugify(old_value)[:40]}_{index + 1:04d}"
            elif isinstance(old_value, int):
                source[key] = index + 1
        result.append(source)
    return result


def enrich_record(record: dict[str, Any], section: str, module_num: int, module_code: str, entity: str, entity_index: int, row_index: int, original_count: int) -> dict[str, Any]:
    scenario = scenario_for(module_code, row_index)
    code, label = catalog_pair(entity, row_index, module_code)
    timestamp = deterministic_time(section, module_num, entity_index, row_index)
    enriched: dict[str, Any] = {}
    for field, value in record.items():
        enriched[field] = improve_scalar(value, field, entity, module_code, section, row_index, original_count, timestamp, scenario, code, label)

    # Temporal and privacy consistency corrections.
    if 'created_at' in enriched:
        enriched['created_at'] = iso(timestamp)
    if 'updated_at' in enriched:
        enriched['updated_at'] = iso(timestamp + dt.timedelta(minutes=20 + row_index))
    if 'valid_from' in enriched and isinstance(enriched['valid_from'], str):
        enriched['valid_from'] = iso(timestamp) if 'T' in enriched['valid_from'] else timestamp.date().isoformat()
    if 'valid_to' in enriched:
        enriched['valid_to'] = None if section == 'boot' else (iso(timestamp + dt.timedelta(days=90)) if isinstance(enriched['valid_to'], str) and 'T' in enriched['valid_to'] else (timestamp.date() + dt.timedelta(days=90)).isoformat())
    if 'start_date' in enriched:
        enriched['start_date'] = timestamp.date().isoformat()
    if 'end_date' in enriched:
        enriched['end_date'] = (timestamp.date() + dt.timedelta(days=30)).isoformat()
    if 'started_at' in enriched:
        enriched['started_at'] = iso(timestamp)
    if 'ended_at' in enriched:
        enriched['ended_at'] = iso(timestamp + dt.timedelta(hours=1 + row_index % 4))
    if 'deceased_at' in enriched:
        enriched['deceased_at'] = None
    if 'deceased' in enriched and not enriched['deceased'] and 'deceased_age_years' in enriched:
        enriched['deceased_age_years'] = None
    if 'onset_age_years' in enriched and isinstance(enriched['onset_age_years'], int):
        enriched['onset_age_years'] = AGE_VALUES[row_index % len(AGE_VALUES)]
    if 'anonymized_at' in enriched and 'deidentification' not in entity and 'deletion' not in entity:
        enriched['anonymized_at'] = None
    return enriched


def count_generic(obj: Any) -> int:
    if isinstance(obj, dict):
        return sum(count_generic(v) for key, v in obj.items() if key not in {'environment', 'seed_source', 'mock_domain'})
    if isinstance(obj, list):
        return sum(count_generic(v) for v in obj)
    if isinstance(obj, str) and PLACEHOLDER_RE.fullmatch(obj.strip()):
        return 1
    return 0


def count_record_placeholders(doc: dict[str, Any]) -> int:
    return count_generic(doc.get('boot', {}).get('records', {})) + count_generic(doc.get('mock', {}).get('records', {}))


def policy_map(doc: dict[str, Any]) -> dict[str, dict[str, Any]]:
    return {p["entity"]: p for p in doc["boot"].get("entity_seed_policies", [])}


def build_id_index(module_docs: list[dict[str, Any]]) -> tuple[set[str], dict[str, tuple[str, str, str, str]]]:
    all_ids: set[str] = set()
    owner: dict[str, tuple[str, str, str, str]] = {}
    for doc in module_docs:
        module_code = doc["module"]["code"]
        policies = policy_map(doc)
        for section in ("boot", "mock"):
            for entity, rows in doc[section]["records"].items():
                pk_fields = policies.get(entity, {}).get("primary_key_fields", []) or ["id"]
                for row in rows:
                    for pk_field in pk_fields:
                        identifier = row.get(pk_field)
                        if isinstance(identifier, str) and UUID_RE.match(identifier):
                            all_ids.add(identifier)
                            owner[identifier] = (module_code, section, entity, pk_field)
    return all_ids, owner


def original_external_uuid_allowlist(original_docs: list[dict[str, Any]]) -> set[str]:
    primary_ids, _ = build_id_index(original_docs)
    external: set[str] = set()
    for doc in original_docs:
        for section in ("boot", "mock"):
            for rows in doc[section]["records"].values():
                for row in rows:
                    for field, value in row.items():
                        if field.endswith("_id") and isinstance(value, str) and UUID_RE.match(value) and value not in primary_ids:
                            external.add(value)
    return external


def replace_clone_foreign_keys(module_docs: list[dict[str, Any]], original_docs: list[dict[str, Any]]) -> None:
    original_pk_owner: dict[str, tuple[str, str, str, str]] = {}
    improved_pk_values: dict[tuple[str, str, str, str], list[str]] = {}

    for doc in original_docs:
        mod = doc["module"]["code"]
        policies = policy_map(doc)
        for section in ("boot", "mock"):
            for entity, rows in doc[section]["records"].items():
                pk_fields = policies.get(entity, {}).get("primary_key_fields", []) or ["id"]
                for row in rows:
                    for pk_field in pk_fields:
                        value = row.get(pk_field)
                        if isinstance(value, str) and UUID_RE.match(value):
                            original_pk_owner[value] = (mod, section, entity, pk_field)

    for doc in module_docs:
        mod = doc["module"]["code"]
        policies = policy_map(doc)
        for section in ("boot", "mock"):
            for entity, rows in doc[section]["records"].items():
                pk_fields = policies.get(entity, {}).get("primary_key_fields", []) or ["id"]
                for pk_field in pk_fields:
                    improved_pk_values[(mod, section, entity, pk_field)] = [
                        row[pk_field] for row in rows
                        if isinstance(row.get(pk_field), str) and UUID_RE.match(row[pk_field])
                    ]

    for doc in module_docs:
        for section in ("boot", "mock"):
            for entity, rows in doc[section]["records"].items():
                for row_index, row in enumerate(rows):
                    for field, value in list(row.items()):
                        if not (field.endswith("_id") and isinstance(value, str)):
                            continue
                        owner = original_pk_owner.get(value)
                        if not owner:
                            continue
                        target_mod, target_section, target_entity, target_pk_field = owner
                        if target_mod == "terminology" or target_section != section:
                            continue
                        candidates = improved_pk_values.get((target_mod, section, target_entity, target_pk_field), [])
                        if candidates and row_index >= 2:
                            row[field] = candidates[row_index % len(candidates)]



def repair_unique_fields(module_docs: list[dict[str, Any]]) -> None:
    """Repairs values declared UK in the physical model so seeds can be loaded repeatedly."""
    _, pk_owner = build_id_index(module_docs)
    candidates_by_owner: dict[tuple[str, str, str, str], list[str]] = defaultdict(list)
    for identifier, owner in pk_owner.items():
        candidates_by_owner[owner].append(identifier)
    for candidates in candidates_by_owner.values():
        candidates.sort()

    for doc in module_docs:
        module_code = doc['module']['code']
        policies = policy_map(doc)
        for section in ('boot', 'mock'):
            for entity, rows in doc[section]['records'].items():
                unique_fields = policies.get(entity, {}).get('unique_fields', [])
                for field in unique_fields:
                    used: set[str] = set()
                    for row_index, row in enumerate(rows):
                        if field not in row or row[field] is None:
                            continue
                        value = row[field]
                        signature = json.dumps(value, ensure_ascii=False, sort_keys=True)
                        if signature not in used:
                            used.add(signature)
                            continue

                        replacement: Any = None
                        if isinstance(value, str) and UUID_RE.match(value):
                            owner = pk_owner.get(value)
                            if owner:
                                for candidate in candidates_by_owner.get(owner, []):
                                    candidate_signature = json.dumps(candidate)
                                    if candidate_signature not in used:
                                        replacement = candidate
                                        break
                            if replacement is None:
                                # Unique token UUIDs such as sessions.token_id are identifiers, not FKs.
                                replacement = stable_uuid('SALUD', '2.0', section, module_code, entity, field, row_index)
                        elif isinstance(value, str):
                            base = slugify(value)
                            replacement = f'{base[:52]}_{row_index + 1:04d}'
                            while json.dumps(replacement, ensure_ascii=False) in used:
                                replacement += '_X'
                        elif isinstance(value, int) and not isinstance(value, bool):
                            replacement = row_index + 1
                            while json.dumps(replacement) in used:
                                replacement += len(rows)
                        else:
                            replacement = f'{slugify(entity)}_{slugify(field)}_{row_index + 1:04d}'

                        row[field] = replacement
                        used.add(json.dumps(replacement, ensure_ascii=False, sort_keys=True))


def validate_unique_fields(module_docs: list[dict[str, Any]]) -> list[dict[str, Any]]:
    issues: list[dict[str, Any]] = []
    for doc in module_docs:
        module_code = doc['module']['code']
        policies = policy_map(doc)
        for section in ('boot', 'mock'):
            for entity, rows in doc[section]['records'].items():
                for field in policies.get(entity, {}).get('unique_fields', []):
                    seen: dict[str, int] = {}
                    for row_index, row in enumerate(rows):
                        if field not in row or row[field] is None:
                            continue
                        signature = json.dumps(row[field], ensure_ascii=False, sort_keys=True)
                        if signature in seen:
                            issues.append({
                                'module': module_code,
                                'section': section,
                                'entity': entity,
                                'field': field,
                                'first_row': seen[signature],
                                'duplicate_row': row_index,
                                'issue': 'unique_field_duplicate',
                            })
                        else:
                            seen[signature] = row_index
    return issues


def validate_modules(module_docs: list[dict[str, Any]], original_docs: list[dict[str, Any]]) -> dict[str, Any]:
    errors: list[dict[str, Any]] = []
    warnings: list[dict[str, Any]] = []
    all_ids, owner = build_id_index(module_docs)
    external_uuid_allowlist = original_external_uuid_allowlist(original_docs)
    duplicate_ids: list[str] = []
    seen: set[str] = set()

    module_metrics = []
    for doc in module_docs:
        module = doc['module']
        module_code = module['code']
        for section in ('boot', 'mock'):
            actual_count = sum(len(rows) for rows in doc[section]['records'].values())
            if actual_count != doc[section]['record_count']:
                errors.append({'module': module_code, 'section': section, 'issue': 'record_count_mismatch', 'declared': doc[section]['record_count'], 'actual': actual_count})
            policies = {p['entity']: p for p in doc['boot'].get('entity_seed_policies', [])}
            for entity, rows in doc[section]['records'].items():
                required = policies.get(entity, {}).get('required_fields', [])
                for row_idx, row in enumerate(rows):
                    pk_fields = policies.get(entity, {}).get('primary_key_fields', []) or ['id']
                    pk_signature = tuple(row.get(field) for field in pk_fields)
                    if all(value is not None for value in pk_signature):
                        signature_text = f"{module_code}|{section}|{entity}|{pk_signature}"
                        if signature_text in seen:
                            duplicate_ids.append(signature_text)
                        seen.add(signature_text)
                    for field in required:
                        if field not in row:
                            errors.append({'module': module_code, 'section': section, 'entity': entity, 'row': row_idx, 'issue': 'required_field_missing', 'field': field})
                    for field, value in row.items():
                        if field.endswith('_id') and field not in {'token_id'} and isinstance(value, str) and UUID_RE.match(value) and value not in all_ids and value not in external_uuid_allowlist:
                            errors.append({'module': module_code, 'section': section, 'entity': entity, 'row': row_idx, 'issue': 'unresolved_fk', 'field': field, 'value': value})
                    if section == 'boot':
                        serialized = json.dumps(row, ensure_ascii=False).lower()
                        if '@mock.' in serialized or 'synthetic": true' in serialized or 'mock user' in serialized:
                            errors.append({'module': module_code, 'section': section, 'entity': entity, 'row': row_idx, 'issue': 'mock_marker_in_boot'})
                    for field, value in row.items():
                        if field == 'secret_hash' and section == 'boot' and value:
                            errors.append({'module': module_code, 'section': section, 'entity': entity, 'row': row_idx, 'issue': 'boot_secret_present'})
        module_metrics.append({
            'number': module['number'],
            'code': module_code,
            'boot_records': doc['boot']['record_count'],
            'mock_records': doc['mock']['record_count'],
            'boot_entities_populated': sum(1 for r in doc['boot']['records'].values() if r),
            'mock_entities_populated': sum(1 for r in doc['mock']['records'].values() if r),
            'generic_markers': count_generic(doc),
        })

    errors.extend(validate_unique_fields(module_docs))
    if duplicate_ids:
        errors.append({'issue': 'duplicate_ids', 'count': len(duplicate_ids), 'examples': duplicate_ids[:20]})
    return {
        'status': 'PASS' if not errors else 'FAIL',
        'validated_at': '2026-07-19T12:00:00Z',
        'module_count': len(module_docs),
        'total_boot_records': sum(m['boot_records'] for m in module_metrics),
        'total_mock_records': sum(m['mock_records'] for m in module_metrics),
        'resolved_id_count': len(all_ids),
        'errors': errors,
        'warnings': warnings,
        'module_metrics': module_metrics,
    }


def make_non_persistent_blueprint(module_code: str) -> dict[str, Any] | None:
    if module_code == 'platform':
        return {
            'kind': 'architectural_module_blueprint',
            'persistence': 'none',
            'reason': 'El módulo indexa la arquitectura y no posee tablas propias.',
            'production_boot_configuration': {
                'canonical_store': 'PostgreSQL',
                'secondary_store_policy': 'derived-and-rebuildable',
                'write_consistency': 'transactional-outbox',
                'worker_model': 'persistent-independent-processes',
                'supported_modules': [f'{i:02d}' for i in range(1, 64)],
                'mandatory_invariants': [
                    'iam.users representa cuentas y profiles.persons representa personas',
                    'toda escritura clínica declara custodia de tenant',
                    'las rutas frontend consumen read models',
                    'no existen escrituras duales inseguras',
                    'retención y borrado se propagan a stores secundarios',
                    'enums dinámicos se resuelven mediante terminology y system context',
                    'workers son idempotentes y persistentes',
                    'toda operación sensible produce auditoría',
                ],
            },
        }
    if module_code == 'deployment':
        return {
            'kind': 'deployment_blueprint',
            'persistence': 'none',
            'reason': 'La topología se materializa mediante IaC y configuración segura, no mediante tablas de este módulo.',
            'production_boot_configuration': {
                'regional_cell': {
                    'ingress': ['api-gateway', 'mtls', 'oidc-mfa'],
                    'application': ['stateless-api', 'persistent-workers', 'fhir-gateway', 'dicomweb-gateway'],
                    'data': ['postgresql-writer', 'read-replicas', 'durable-outbox'],
                    'binary': ['versioned-object-storage', 'pacs-vna', 'worm-audit-vault'],
                    'security': ['regional-kms-hsm', 'secret-manager', 'siem'],
                    'observability': ['metrics', 'phi-redacted-logs', 'distributed-traces'],
                    'recovery': ['encrypted-backup-vault', 'automated-restore-tests'],
                },
                'controls': {
                    'phi_cross_region_default': 'deny',
                    'tls_required': True,
                    'backup_encryption_required': True,
                    'restore_test_required': True,
                    'logs_phi_redaction_required': True,
                    'secrets_in_code_allowed': False,
                },
                'required_environment_profiles': ['production', 'staging', 'qa', 'development', 'test'],
            },
        }
    if module_code == 'portal_catalog':
        routes = [
            'public-discovery', 'public-provider-profile', 'authentication', 'patient-dashboard',
            'patient-appointments', 'patient-timeline', 'patient-medications', 'patient-billing',
            'patient-consent', 'doctor-agenda', 'doctor-encounter', 'doctor-notes', 'doctor-orders',
            'doctor-results', 'hospital-capacity', 'hospital-workforce', 'diagnostic-worklist',
            'diagnostic-results', 'pharmacy-catalog', 'pharmacy-inventory', 'insurance-eligibility',
            'insurance-claims', 'erp-ledger', 'erp-settlements', 'system-security',
            'system-integrations', 'system-terminology', 'platform-health', 'education-catalog',
            'crm-pipeline', 'marketing-journeys', 'ads-insights', 'payments-reconciliation',
            'health-data-ingestion', 'health-data-quality', 'procedure-or-schedule', 'procedure-recovery',
        ]
        return {
            'kind': 'portal_route_catalog_blueprint',
            'persistence': 'none',
            'reason': 'El módulo define contratos de navegación y estados UX; las proyecciones persistentes pertenecen al módulo 30.',
            'production_boot_configuration': {
                'routes': [{
                    'code': slugify(route),
                    'route': '/' + route.replace('-', '/'),
                    'authorization_required': route not in {'public-discovery', 'public-provider-profile', 'authentication'},
                    'required_states': ['authorization-pending', 'loading', 'empty', 'ready', 'forbidden', 'error', 'stale'],
                } for route in routes],
                'navigation_policy': {
                    'raw_orm_entities_allowed': False,
                    'read_models_required': True,
                    'permission_check_required': True,
                    'loading_state_required': True,
                    'error_boundary_required': True,
                },
            },
        }
    return None


def main() -> None:
    if OUTPUT_ROOT.exists():
        shutil.rmtree(OUTPUT_ROOT)
    MODULES_DIR.mkdir(parents=True)
    REPORTS_DIR.mkdir(parents=True)
    SCHEMAS_DIR.mkdir(parents=True)
    TOOLS_DIR.mkdir(parents=True)

    source_files = sorted((SOURCE_ROOT / 'modules').glob('*.json'))
    original_docs = [json.loads(p.read_text(encoding='utf-8')) for p in source_files]
    improved_docs: list[dict[str, Any]] = []
    module_changes = []

    for source_path, original in zip(source_files, original_docs):
        doc = copy.deepcopy(original)
        module_num = doc['module']['number']
        module_code = doc['module']['code']
        doc['module']['source_model_version'] = '3.9.0'
        doc['module']['requested_release_label'] = '4.0'
        doc['module']['seed_revision'] = '2.0.0-enhanced'
        if not doc['module'].get('business_purpose'):
            doc['module']['business_purpose'] = f'Datos de arranque y escenarios sintéticos profundos para {doc["module"].get("title", module_code)}.'
        doc['quality_profile'] = {
            'revision': '2.0.0-enhanced',
            'strategy': 'domain-aware deterministic catalogs plus connected synthetic scenarios',
            'boot_scope': 'catálogos, políticas, plantillas y configuración segura sin transacciones empresariales ficticias',
            'mock_scope': 'escenarios enlazados de éxito, error, borde, reversión, auditoría y recuperación',
            'quality_gates': [
                'UUID determinístico', 'idempotencia por clave estable', 'sin secretos',
                'mock prohibido en producción', 'campos obligatorios presentes',
                'FK resolubles', 'fechas coherentes', 'valores de dominio no genéricos',
            ],
            'scenario_catalog': MODULE_SCENARIOS.get(module_code, []),
        }
        blueprint = make_non_persistent_blueprint(module_code)
        if blueprint:
            doc['non_persistent_blueprint'] = blueprint
        if module_code == 'terminology':
            doc['quality_profile']['compatibility_exceptions'] = [
                'Los códigos DEFAULT_* existentes se conservan porque otros módulos ya referencian sus UUID; representan fallback gobernado y no datos mock.',
                'La ampliación de terminología clínica oficial debe realizarse mediante importaciones versionadas y licenciadas, no inventando códigos locales.',
            ]

        before_boot = doc['boot']['record_count']
        before_mock = doc['mock']['record_count']
        before_generic = count_record_placeholders(doc)

        for section in ('boot', 'mock'):
            new_records: dict[str, list[dict[str, Any]]] = {}
            for entity_index, (entity, records) in enumerate(doc[section]['records'].items()):
                policies = policy_map(doc)
                primary_key_fields = policies.get(entity, {}).get('primary_key_fields', [])
                original_count = len(records)
                target = target_count(section, module_code, entity, original_count)
                expanded = clone_records(records, target, section, module_code, entity, primary_key_fields)
                enriched = [enrich_record(r, section, module_num, module_code, entity, entity_index, idx, original_count) for idx, r in enumerate(expanded)]
                new_records[entity] = enriched
            doc[section]['records'] = new_records
            doc[section]['record_count'] = sum(len(rows) for rows in new_records.values())
            doc[section]['summary'] = {
                'record_count': doc[section]['record_count'],
                'entity_count': len(new_records),
                'populated_entity_count': sum(1 for rows in new_records.values() if rows),
                'scenario_count': len(MODULE_SCENARIOS.get(module_code, [])) if section == 'mock' else None,
                'seed_revision': '2.0.0-enhanced',
            }
            if section == 'boot':
                doc[section]['production_policy'] = {
                    'safe_for_production': True,
                    'contains_business_transactions': False,
                    'contains_real_personal_data': False,
                    'contains_embedded_secrets': False,
                    'upsert_required': True,
                    'stable_identity_required': True,
                    'empty_boot_is_intentional': doc[section]['record_count'] == 0,
                    'empty_reason': (
                        'El módulo no posee catálogos o configuración global segura; sus registros nacen del onboarding, la operación clínica o transacciones reales.'
                        if doc[section]['record_count'] == 0 else None
                    ),
                }
            else:
                doc[section]['scenario_coverage'] = {
                    'happy_path': True,
                    'validation_error': True,
                    'permission_denied': True,
                    'idempotent_retry': True,
                    'reversal_or_cancellation': True,
                    'audit_trace': True,
                    'synthetic_only': True,
                    'production_hard_fail_required': True,
                }

        improved_docs.append(doc)
        module_changes.append({
            'number': module_num,
            'code': module_code,
            'before_boot': before_boot,
            'after_boot': doc['boot']['record_count'],
            'before_mock': before_mock,
            'after_mock': doc['mock']['record_count'],
            'before_generic_markers': before_generic,
        })

    replace_clone_foreign_keys(improved_docs, original_docs)
    repair_unique_fields(improved_docs)

    # Refresh summaries and write modules.
    for doc, source_path, change in zip(improved_docs, source_files, module_changes):
        for section in ('boot', 'mock'):
            doc[section]['record_count'] = sum(len(rows) for rows in doc[section]['records'].values())
            doc[section]['summary']['record_count'] = doc[section]['record_count']
        change['after_generic_markers'] = count_record_placeholders(doc)
        target_path = MODULES_DIR / source_path.name
        target_path.write_text(json.dumps(doc, ensure_ascii=False, indent=2) + '\n', encoding='utf-8')
        change['line_count'] = sum(1 for _ in target_path.open(encoding='utf-8'))
        change['sha256'] = hashlib.sha256(target_path.read_bytes()).hexdigest()

    validation = validate_modules(improved_docs, original_docs)
    (REPORTS_DIR / 'validation-report.json').write_text(json.dumps(validation, ensure_ascii=False, indent=2) + '\n', encoding='utf-8')

    quality_report = {
        'status': validation['status'],
        'seed_revision': '2.0.0-enhanced',
        'source_package': 'SALUD_v4.0_module_seeds.zip',
        'improvements': [
            'Expansión determinística de catálogos de arranque con nombres de dominio.',
            'Escenarios mock conectados por referencias y no solo dos filas genéricas por entidad.',
            'Diversidad temporal, financiera, geográfica, clínica y operacional.',
            'Corrección de inconsistencias como fechas idénticas, personas nacidas en 2026 o fallecimientos/anónimos indiscriminados.',
            'Metadatos de escenario y revisión para trazabilidad.',
            'Blueprints JSON para los módulos arquitectónicos sin tablas propias.',
            'Validación de campos obligatorios, UUID, FK, secretos y separación boot/mock.',
        ],
        'module_changes': module_changes,
        'totals': {
            'before_boot': sum(x['before_boot'] for x in module_changes),
            'after_boot': sum(x['after_boot'] for x in module_changes),
            'before_mock': sum(x['before_mock'] for x in module_changes),
            'after_mock': sum(x['after_mock'] for x in module_changes),
            'before_generic_markers': sum(x['before_generic_markers'] for x in module_changes),
            'after_generic_markers': sum(x['after_generic_markers'] for x in module_changes),
        },
    }
    (REPORTS_DIR / 'quality-report.json').write_text(json.dumps(quality_report, ensure_ascii=False, indent=2) + '\n', encoding='utf-8')

    generation_report = {
        'seed_revision': '2.0.0-enhanced',
        'generated_at': '2026-07-19T12:00:00Z',
        'module_count': len(improved_docs),
        'validation_status': validation['status'],
        'modules': module_changes,
    }
    (REPORTS_DIR / 'generation-report.json').write_text(json.dumps(generation_report, ensure_ascii=False, indent=2) + '\n', encoding='utf-8')

    shutil.copy2(SOURCE_ROOT / 'schemas' / 'module-seed.schema.json', SCHEMAS_DIR / 'module-seed.schema.json')
    shutil.copy2(Path(__file__), TOOLS_DIR / 'generate-deep-seeds.py')

    readme = {
        'package': 'SALUD v4.0 enhanced module seeds',
        'source_model': 'SALUD model 3.9.0 distributed under requested release label 4.0',
        'seed_revision': '2.0.0-enhanced',
        'usage': {
            'boot': 'Ejecutar después de migraciones en production, staging, QA, development y test. Repetir debe producir el mismo estado lógico.',
            'mock': 'Ejecutar únicamente en development, test, QA o staging. El runner debe fallar si NODE_ENV=production.',
        },
        'load_order': [doc['module']['number'] for doc in improved_docs],
        'security': {
            'real_personal_data': False,
            'embedded_secrets': False,
            'raw_payment_card_data': False,
            'mock_domain': 'mock.salud.example.invalid',
        },
        'validation_reports': ['reports/validation-report.json', 'reports/quality-report.json', 'reports/generation-report.json'],
    }
    (OUTPUT_ROOT / 'README.json').write_text(json.dumps(readme, ensure_ascii=False, indent=2) + '\n', encoding='utf-8')

    manifest = {
        'package': 'SALUD_v4.0_module_seeds_enhanced',
        'seed_revision': '2.0.0-enhanced',
        'module_count': len(improved_docs),
        'boot_record_count': validation['total_boot_records'],
        'mock_record_count': validation['total_mock_records'],
        'validation_status': validation['status'],
        'mock_production_policy': 'hard-fail',
        'modules': [{
            'number': doc['module']['number'],
            'code': doc['module']['code'],
            'file': f'modules/{source_files[i].name}',
            'boot_records': doc['boot']['record_count'],
            'mock_records': doc['mock']['record_count'],
            'line_count': module_changes[i]['line_count'],
            'sha256': module_changes[i]['sha256'],
        } for i, doc in enumerate(improved_docs)],
    }
    (OUTPUT_ROOT / 'seed-manifest.json').write_text(json.dumps(manifest, ensure_ascii=False, indent=2) + '\n', encoding='utf-8')

    # Checksums are produced last, excluding the checksum file itself.
    checksum_entries = []
    for path in sorted(p for p in OUTPUT_ROOT.rglob('*') if p.is_file() and p.name != 'checksums.json'):
        checksum_entries.append({
            'file': str(path.relative_to(OUTPUT_ROOT)),
            'sha256': hashlib.sha256(path.read_bytes()).hexdigest(),
            'size_bytes': path.stat().st_size,
        })
    checksums = {'algorithm': 'SHA-256', 'files': checksum_entries}
    (OUTPUT_ROOT / 'checksums.json').write_text(json.dumps(checksums, ensure_ascii=False, indent=2) + '\n', encoding='utf-8')

    if validation['status'] != 'PASS':
        print(json.dumps(validation, ensure_ascii=False, indent=2))
        raise SystemExit('Validation failed')

    print(json.dumps({
        'status': 'PASS',
        'output_root': str(OUTPUT_ROOT),
        'boot_records': validation['total_boot_records'],
        'mock_records': validation['total_mock_records'],
        'modules': len(improved_docs),
        'quality_totals': quality_report['totals'],
    }, ensure_ascii=False, indent=2))


if __name__ == '__main__':
    main()
