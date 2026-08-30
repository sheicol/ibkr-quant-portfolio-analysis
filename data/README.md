# Data policy and contracts

This directory intentionally contains no broker data.

## Sources

The private source is an Interactive Brokers Activity Statement processed locally in KNIME. Raw statements and derived row-level exports must remain outside Git.

## Expected tables

### `analytics_positions`

Curated position snapshot created by KNIME. Expected columns: currency, model,
symbol, asset class, quantity, close price, market value and portfolio weight.
Account identifiers and redundant portfolio totals are excluded.

### `analytics_trade_orders`

Curated trading activity created by KNIME. Expected columns: asset category,
currency, symbol, execution timestamp, quantity, prices, proceeds, commission,
basis, realized P&L, mark-to-market P&L and code. Trade side is derived during
analysis from the sign of quantity and is not stored in PostgreSQL.

The canonical SQL names and types are defined in `sql/create_tables.sql`. Confirm them against the exported KNIME workflow before loading production data.

## Safe contribution rules

- Never commit statements, account IDs, credentials or row-level transaction history.
- Prefer synthetic samples when tests need data.
- Remove notebook outputs before committing analyses run on private data.
- Review every chart for account values, order IDs and timestamps before publishing.

