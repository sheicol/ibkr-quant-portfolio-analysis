-- Consolidated portfolio composition by symbol.
SELECT
    symbol,
    COUNT(DISTINCT model) AS model_count,
    STRING_AGG(DISTINCT COALESCE(model, 'Sin modelo'), ', ') AS models,
    SUM(portfolio_weight) AS portfolio_weight
FROM analytics_positions
GROUP BY symbol
ORDER BY portfolio_weight DESC;

-- Trading activity by month and side.
WITH classified_trades AS (
    SELECT
        *,
        CASE WHEN quantity > 0 THEN 'BUY' ELSE 'SELL' END AS trade_side
    FROM analytics_trade_orders
)
SELECT
    DATE_TRUNC('month', executed_at) AS month,
    trade_side,
    COUNT(*) AS trade_count,
    SUM(ABS(proceeds)) AS gross_notional,
    SUM(commission_fee) AS commissions,
    SUM(realized_pnl) AS realized_pnl
FROM classified_trades
GROUP BY 1, 2
ORDER BY 1, 2;

