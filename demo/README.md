# Demo reproducible — datos sintéticos

Desde la raíz: `python demo/run_demo.py`. Requiere Python 3.10+; solo usa biblioteca estándar. Los CSV se encuentran mediante la ruta del script, independientemente del directorio actual.

[Informe generado](output/report.md) · [Resultados JSON](output/summary.json) · [Gráfico](output/weights.svg)

## Método

- Posiciones largas en USD: peso = valor de mercado / valor total.
- HHI = suma de pesos al cuadrado; posiciones efectivas = 1 / HHI.
- Compras y ventas: suma de cantidad absoluta × precio según el signo de cantidad.
- Las comisiones se almacenan negativas; el costo se presenta positivo.
- Flujo neto de operaciones = ventas − compras − costo de comisiones.

## Resultados esperados

Valor: USD 5,000. Pesos: 40%, 30%, 20%, 10%. HHI: 0.30. Posiciones efectivas: 3.3333. Cuatro operaciones; compras: USD 2,750; ventas: USD 550; comisiones: USD 4; flujo neto: USD −2,204.

## Límites

Datos inventados, no anonimizados desde una cuenta real. Los símbolos no representan activos reales. Las operaciones son una muestra independiente y no reconstruyen la foto de posiciones. No hay dividendos, flujos externos, precios históricos ni conversión de monedas. El flujo neto no es rendimiento; no se calculan Sharpe, VaR ni drawdown.
