# Data policy and contracts

This directory intentionally contains no broker data.

## Sources

The private source is an Interactive Brokers Activity Statement processed locally in KNIME. Raw statements and derived row-level exports must remain outside Git.

## Expected tables

### `portfolio_positions`

Expected concepts: symbol, quantity, market value, cost basis, unrealized P&L and portfolio weight.

### `trade_orders`

Expected concepts: timestamp, symbol, side, quantity, trade price, close price, proceeds, commission, basis, realized P&L, mark-to-market P&L and code.

The canonical SQL names and types are defined in `sql/create_tables.sql`. Confirm them against the exported KNIME workflow before loading production data.

## Safe contribution rules

- Never commit statements, account IDs, credentials or row-level transaction history.
- Prefer synthetic samples when tests need data.
- Remove notebook outputs before committing analyses run on private data.
- Review every chart for account values, order IDs and timestamps before publishing.
