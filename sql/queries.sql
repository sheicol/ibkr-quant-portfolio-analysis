-- Portfolio composition and concentration
SELECT
    symbol,
    market_value,
    portfolio_weight,
    SUM(POWER(portfolio_weight, 2)) OVER () AS hhi
FROM portfolio_positions
WHERE as_of_date = (SELECT MAX(as_of_date) FROM portfolio_positions)
ORDER BY portfolio_weight DESC;

-- Trading activity by month
SELECT
    DATE_TRUNC('month', executed_at) AS month,
    trade_side,
    COUNT(*) AS trade_count,
    SUM(ABS(proceeds)) AS gross_notional,
    SUM(commission_fee) AS commissions,
    SUM(COALESCE(realized_pnl, 0)) AS realized_pnl
FROM trade_orders
GROUP BY 1, 2
ORDER BY 1, 2;
