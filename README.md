# IBKR Portfolio Analytics — SQL & Python

Pipeline analítico de Interactive Brokers con KNIME, PostgreSQL y Python: composición, concentración y actividad de trading.

**Estado:** SQL y notebooks de composición y actividad disponibles. Rendimiento, riesgo y optimización permanecen previstos; sus notebooks iniciales no son análisis terminados.

## Demo pública sin datos privados

```bash
python demo/run_demo.py
```

Usa exclusivamente archivos sintéticos versionados, sin red, credenciales ni PostgreSQL. Genera `demo/output/summary.json`, `report.md` y `weights.svg`. Ver [método y límites](demo/README.md).

La demo ilustra pesos, concentración, compras/ventas y comisiones. No reconstruye una cuenta real ni estima su rentabilidad.

## Pipeline del proyecto

IBKR Activity Statement privado → KNIME (ETL y controles) → PostgreSQL → SQL / Python.

| Componente | Evidencia |
|---|---|
| Contrato de datos | [data/README.md](data/README.md) |
| ETL | [knime/README.md](knime/README.md); workflow privado |
| Esquema | [create_tables.sql](sql/create_tables.sql) |
| Composición y concentración | [SQL](sql/01_portfolio_composition.sql) · [Notebook](notebooks/01_portfolio_composition.ipynb) |
| Actividad de trading | [SQL](sql/02_trading_activity.sql) · [Notebook](notebooks/02_trading_activity.ipynb) |
| Rendimiento, riesgo y optimización | Plantillas; implementación pendiente |

El README anterior reportó ejecuciones locales con datos privados. Esta revisión no verifica la base privada; esos resultados no se presentan como evidencia pública reproducida.

## Entorno completo

```bash
python -m venv .venv
python -m pip install -r requirements.txt
```

Copiar `.env.example` a `.env`, configurar PostgreSQL local, ejecutar el esquema y cargar datos autorizados según el contrato. Ejecutar los notebooks de composición y actividad. La demo independiente no necesita estos pasos.

## Privacidad

No versionar extractos reales, credenciales, identificadores de cuenta, exportaciones privadas ni resultados sensibles de notebooks. Los datos de `demo/data/` son inventados y usan símbolos ficticios.

## Próximos pasos

- Validar flujos de caja, moneda y convención de retornos antes de calcular rendimiento.
- Implementar y comprobar métricas de riesgo.
- Documentar benchmark, costos y supuestos antes de optimizar.

[SheyQuant Research Lab](https://github.com/sheicol/quant-research-portfolio) · [Calidad del aire](https://github.com/sheicol/analisis-calidad-aire-medellin)

Proyecto educativo; no constituye asesoría financiera.
