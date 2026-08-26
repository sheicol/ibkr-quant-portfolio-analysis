BEGIN;

-- Canonical analytics tables produced by the KNIME ETL workflow.
CREATE TABLE IF NOT EXISTS analytics_positions (
    currency TEXT NOT NULL,
    model TEXT,
    symbol TEXT NOT NULL,
    asset_class TEXT NOT NULL,
    quantity DOUBLE PRECISION NOT NULL,
    close_price DOUBLE PRECISION NOT NULL,
    market_value DOUBLE PRECISION NOT NULL,
    portfolio_weight DOUBLE PRECISION NOT NULL,
    CHECK (portfolio_weight >= 0)
);

CREATE TABLE IF NOT EXISTS analytics_trade_orders (
    asset_category TEXT NOT NULL,
    currency TEXT NOT NULL,
    symbol TEXT NOT NULL,
    executed_at TIMESTAMP WITHOUT TIME ZONE NOT NULL,
    trade_side TEXT NOT NULL CHECK (trade_side IN ('BUY', 'SELL')),
    quantity DOUBLE PRECISION NOT NULL CHECK (quantity <> 0),
    trade_price DOUBLE PRECISION NOT NULL CHECK (trade_price > 0),
    close_price DOUBLE PRECISION NOT NULL CHECK (close_price > 0),
    proceeds DOUBLE PRECISION NOT NULL,
    commission_fee DOUBLE PRECISION NOT NULL,
    cost_basis DOUBLE PRECISION NOT NULL,
    realized_pnl DOUBLE PRECISION NOT NULL,
    mtm_pnl DOUBLE PRECISION NOT NULL,
    code TEXT
);

CREATE INDEX IF NOT EXISTS idx_analytics_positions_symbol
    ON analytics_positions (symbol);

CREATE INDEX IF NOT EXISTS idx_analytics_trade_orders_symbol_executed_at
    ON analytics_trade_orders (symbol, executed_at);

COMMIT;

