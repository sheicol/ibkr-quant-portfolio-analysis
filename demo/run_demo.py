"""Demo determinista con datos inventados. Solo requiere la biblioteca estándar."""
import csv
import json
from decimal import Decimal
from pathlib import Path

ROOT = Path(__file__).resolve().parent


def read_rows(name):
    with (ROOT / "data" / name).open(encoding="utf-8", newline="") as handle:
        return list(csv.DictReader(handle))


def calculate(positions, trades):
    if not positions or not trades:
        raise ValueError("Se requieren posiciones y operaciones")
    if any(row["currency"] != "USD" for row in positions + trades):
        raise ValueError("La demo solo admite USD; no convierte monedas")
    values = [Decimal(row["market_value"]) for row in positions]
    if any(v < 0 for v in values) or sum(values) <= 0:
        raise ValueError("Solo se admite una cartera larga de valor positivo")
    for row, value in zip(positions, values):
        if Decimal(row["quantity"]) * Decimal(row["close_price"]) != value:
            raise ValueError("Valor de mercado inconsistente")
    weights = [v / sum(values) for v in values]
    buys = Decimal(0)
    sells = Decimal(0)
    fees = Decimal(0)
    for row in trades:
        quantity = Decimal(row["quantity"])
        price = Decimal(row["trade_price"])
        fee = Decimal(row["commission_fee"])
        if not quantity or price <= 0 or fee > 0:
            raise ValueError("Convención inválida: cantidad no nula, precio positivo, comisión <= 0")
        if quantity > 0:
            buys += quantity * price
        else:
            sells += -quantity * price
        fees -= fee
    hhi = sum(w * w for w in weights)
    return {
        "data_kind": "synthetic",
        "currency": "USD",
        "market_value": float(sum(values)),
        "weights": {row["symbol"]: float(w) for row, w in zip(positions, weights)},
        "hhi": float(hhi),
        "effective_positions": float(1 / hhi),
        "trade_count": len(trades),
        "purchases_notional": float(buys),
        "sales_notional": float(sells),
        "gross_traded_notional": float(buys + sells),
        "commission_cost": float(fees),
        "net_trade_cash_flow": float(sells - buys - fees),
    }


def main():
    result = calculate(read_rows("positions.csv"), read_rows("trades.csv"))
    out = ROOT / "output"
    out.mkdir(exist_ok=True)
    (out / "summary.json").write_text(json.dumps(result, indent=2) + "\n", encoding="utf-8")
    lines = ["# IBKR Analytics — demo sintética", "",
             "Datos inventados; no corresponden a una cuenta real.", "",
             "| Métrica | Valor |", "|---|---|"]
    for key in ("market_value", "hhi", "effective_positions", "trade_count",
                "purchases_notional", "sales_notional", "gross_traded_notional",
                "commission_cost", "net_trade_cash_flow"):
        lines.append(f"| {key} | {result[key]:,.4f} |")
    lines += ["", "El flujo de operaciones no es rentabilidad. La tabla de operaciones no reconstruye las posiciones de cierre.",
              "", "![Pesos sintéticos](weights.svg)", ""]
    (out / "report.md").write_text("\n".join(lines), encoding="utf-8")
    bars = []
    for i, (symbol, weight) in enumerate(result["weights"].items()):
        y = 65 + i * 45
        bars.append(f'<text x="15" y="{y + 18}">{symbol}</text><rect x="110" y="{y}" width="{weight * 700}" height="25" fill="#176b70"/><text x="{120 + weight * 700}" y="{y + 18}">{weight:.0%}</text>')
    svg = '<svg xmlns="http://www.w3.org/2000/svg" width="600" height="280" viewBox="0 0 600 280" role="img" aria-label="Pesos de cartera sintética"><rect width="600" height="280" fill="white"/><text x="15" y="30">Cartera sintética · sin datos reales</text>' + "".join(bars) + "</svg>"
    (out / "weights.svg").write_text(svg, encoding="utf-8")
    print(json.dumps(result, indent=2))


if __name__ == "__main__":
    main()
