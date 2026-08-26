BEGIN;

CREATE TABLE IF NOT EXISTS portfolio_positions (
    as_of_date DATE NOT NULL,
    symbol TEXT NOT NULL,
    quantity NUMERIC NOT NULL,
    market_value NUMERIC NOT NULL,
    cost_basis NUMERIC,
    unrealized_pnl NUMERIC,
    portfolio_weight NUMERIC,
    currency CHAR(3) NOT NULL DEFAULT 'USD',
    PRIMARY KEY (as_of_date, symbol)
);

CREATE TABLE IF NOT EXISTS trade_orders (
    trade_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    executed_at TIMESTAMPTZ NOT NULL,
    symbol TEXT NOT NULL,
    trade_side TEXT NOT NULL CHECK (trade_side IN ('BUY', 'SELL')),
    quantity NUMERIC NOT NULL CHECK (quantity <> 0),
    trade_price NUMERIC NOT NULL CHECK (trade_price > 0),
    close_price NUMERIC CHECK (close_price > 0),
    proceeds NUMERIC NOT NULL,
    commission_fee NUMERIC NOT NULL DEFAULT 0,
    basis NUMERIC,
    realized_pnl NUMERIC,
    mtm_pnl NUMERIC,
    code TEXT,
    asset_category TEXT NOT NULL DEFAULT 'Stocks',
    currency CHAR(3) NOT NULL DEFAULT 'USD',
    source_fingerprint TEXT UNIQUE,
    CHECK (
        (trade_side = 'BUY' AND quantity > 0 AND proceeds < 0)
        OR (trade_side = 'SELL' AND quantity < 0 AND proceeds > 0)
    )
);

CREATE INDEX IF NOT EXISTS idx_trade_orders_symbol_executed_at
    ON trade_orders (symbol, executed_at);

COMMIT;
