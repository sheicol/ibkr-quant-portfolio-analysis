# IBKR Quantitative Portfolio Analysis

Proyecto de portafolio que transforma datos de Interactive Brokers en análisis reproducibles de composición, actividad, rendimiento y riesgo.

## Arquitectura

```text
IBKR Activity Statement (privado)
        ↓
      KNIME — ETL y controles de calidad
        ↓
   PostgreSQL — almacenamiento analítico
        ↓
      Python — análisis cuantitativo
```

## Alcance

- `analytics_positions`: composición actual, valoración y pesos por símbolo y modelo.
- `analytics_trade_orders`: operaciones individuales, comisiones y P&L realizado.
- Análisis previstos: concentración, HHI, actividad de trading, rendimiento, riesgo y optimización.

La auditoría exploratoria original reportó 1,189 órdenes de acciones en USD, sin valores faltantes, duplicados según la clave evaluada ni anomalías de signo. Estos resultados son contexto del proceso y deben reproducirse contra la base privada antes de usarlos como evidencia analítica.

## Estructura

```text
data/       documentación de datos; los datos reales no se versionan
figures/    gráficos generados (sin información sensible)
knime/      documentación y futuro workflow exportado
notebooks/  análisis numerados y reproducibles
sql/        esquema PostgreSQL y consultas analíticas
src/        funciones Python reutilizables
```

## Configuración local

1. Crea un entorno virtual e instala `requirements.txt`.
2. Copia `.env.example` a `.env` y completa la URL de PostgreSQL localmente.
3. Ejecuta `sql/create_tables.sql` en una base autorizada.
4. Exporta el workflow de KNIME como `knime/ibkr_etl_workflow.knwf`.
5. Ejecuta los notebooks en orden.

```bash
python -m venv .venv
pip install -r requirements.txt
```

## Privacidad

Nunca se deben versionar Activity Statements, CSV exportados, identificadores de cuenta, credenciales, archivos `.env`, backups de base de datos ni notebooks con resultados privados. Consulta [data/README.md](data/README.md) para el contrato de datos y las reglas de anonimización.

## Estado

- [x] Estructura profesional del repositorio
- [x] Esquema PostgreSQL inicial
- [x] Notebooks base
- [ ] Incorporar el workflow KNIME exportado por el propietario
- [ ] Validar el esquema contra PostgreSQL
- [ ] Ejecutar análisis con datos privados locales

## Aviso

Proyecto educativo y de portafolio. No constituye asesoría financiera.

