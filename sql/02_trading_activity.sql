-- Analysis 02: Trading activity
-- Source: analytics_trade_orders
-- trade_side is derived from signed quantity and is not stored in PostgreSQL.

-- Question 1: What period is covered and are required fields valid?
SELECT
    COUNT(*) AS total_trades,
    COUNT(DISTINCT symbol) AS unique_symbols,
    MIN(executed_at) AS first_trade,
    MAX(executed_at) AS last_trade,
    COUNT(*) FILTER (WHERE symbol IS NULL) AS missing_symbol,
    COUNT(*) FILTER (WHERE executed_at IS NULL) AS missing_datetime,
    COUNT(*) FILTER (WHERE quantity = 0) AS zero_quantity,
    COUNT(*) FILTER (WHERE trade_price <= 0) AS invalid_trade_price
FROM analytics_trade_orders;

-- Question 2: Are quantity and proceeds signs internally consistent?
SELECT
    COUNT(*) FILTER (WHERE quantity > 0 AND proceeds < 0) AS valid_buys,
    COUNT(*) FILTER (WHERE quantity < 0 AND proceeds > 0) AS valid_sells,
    COUNT(*) FILTER (
        WHERE NOT (
            (quantity > 0 AND proceeds < 0)
            OR (quantity < 0 AND proceeds > 0)
        )
    ) AS sign_anomalies
FROM analytics_trade_orders;

-- Question 3: How did buying and selling activity compare?
WITH classified_trades AS (
    SELECT
        *,
        CASE WHEN quantity > 0 THEN 'BUY' ELSE 'SELL' END AS trade_side
    FROM analytics_trade_orders
)
SELECT
    trade_side,
    COUNT(*) AS trade_count,
    ROUND((COUNT(*) * 100.0 / SUM(COUNT(*)) OVER ())::numeric, 2)
        AS trade_count_pct,
    COUNT(DISTINCT symbol) AS unique_symbols,
    ROUND(SUM(ABS(proceeds))::numeric, 2) AS gross_traded_amount,
    ROUND(AVG(ABS(proceeds))::numeric, 2) AS average_trade_amount
FROM classified_trades
GROUP BY trade_side
ORDER BY trade_side;

-- Question 4: How did activity evolve each month?
WITH classified_trades AS (
    SELECT
        *,
        CASE WHEN quantity > 0 THEN 'BUY' ELSE 'SELL' END AS trade_side
    FROM analytics_trade_orders
)
SELECT
    DATE_TRUNC('month', executed_at)::date AS month,
    COUNT(*) AS total_trades,
    COUNT(*) FILTER (WHERE trade_side = 'BUY') AS buy_count,
    COUNT(*) FILTER (WHERE trade_side = 'SELL') AS sell_count,
    ROUND(SUM(ABS(proceeds))::numeric, 2) AS gross_traded_amount,
    ROUND(COALESCE(SUM(ABS(proceeds)) FILTER (WHERE trade_side = 'BUY'), 0)::numeric, 2)
        AS buy_amount,
    ROUND(COALESCE(SUM(ABS(proceeds)) FILTER (WHERE trade_side = 'SELL'), 0)::numeric, 2)
        AS sell_amount,
    ROUND(SUM(proceeds)::numeric, 2) AS net_trading_cash_flow
FROM classified_trades
GROUP BY DATE_TRUNC('month', executed_at)
ORDER BY month;

-- Question 5: Which months concentrated the most activity?
WITH monthly_activity AS (
    SELECT
        DATE_TRUNC('month', executed_at)::date AS month,
        COUNT(*) AS trade_count,
        SUM(ABS(proceeds)) AS gross_traded_amount
    FROM analytics_trade_orders
    GROUP BY DATE_TRUNC('month', executed_at)
)
SELECT
    month,
    trade_count,
    ROUND(gross_traded_amount::numeric, 2) AS gross_traded_amount,
    ROUND((trade_count * 100.0 / SUM(trade_count) OVER ())::numeric, 2)
        AS share_of_trades_pct,
    ROUND((gross_traded_amount * 100.0 / SUM(gross_traded_amount) OVER ())::numeric, 2)
        AS share_of_volume_pct
FROM monthly_activity
ORDER BY gross_traded_amount DESC;

-- Question 6: Which symbols had the greatest trading activity?
WITH classified_trades AS (
    SELECT
        *,
        CASE WHEN quantity > 0 THEN 'BUY' ELSE 'SELL' END AS trade_side
    FROM analytics_trade_orders
)
SELECT
    symbol,
    COUNT(*) AS trade_count,
    COUNT(*) FILTER (WHERE trade_side = 'BUY') AS buy_count,
    COUNT(*) FILTER (WHERE trade_side = 'SELL') AS sell_count,
    ROUND(SUM(ABS(proceeds))::numeric, 2) AS gross_traded_amount,
    ROUND(AVG(ABS(proceeds))::numeric, 2) AS average_trade_amount,
    ROUND(SUM(proceeds)::numeric, 2) AS net_trading_cash_flow
FROM classified_trades
GROUP BY symbol
ORDER BY gross_traded_amount DESC
LIMIT 15;

-- Question 7: How concentrated was activity by volume and frequency?
WITH activity_by_symbol AS (
    SELECT
        symbol,
        COUNT(*) AS trade_count,
        SUM(ABS(proceeds)) AS gross_traded_amount
    FROM analytics_trade_orders
    GROUP BY symbol
),
ranked_activity AS (
    SELECT
        *,
        ROW_NUMBER() OVER (ORDER BY gross_traded_amount DESC) AS volume_rank,
        ROW_NUMBER() OVER (ORDER BY trade_count DESC) AS frequency_rank
    FROM activity_by_symbol
)
SELECT
    COUNT(*) AS traded_symbols,
    ROUND((SUM(gross_traded_amount) FILTER (WHERE volume_rank <= 5)
        * 100.0 / SUM(gross_traded_amount))::numeric, 2) AS top_5_volume_pct,
    ROUND((SUM(gross_traded_amount) FILTER (WHERE volume_rank <= 10)
        * 100.0 / SUM(gross_traded_amount))::numeric, 2) AS top_10_volume_pct,
    ROUND((SUM(trade_count) FILTER (WHERE frequency_rank <= 5)
        * 100.0 / SUM(trade_count))::numeric, 2) AS top_5_frequency_pct,
    ROUND((SUM(trade_count) FILTER (WHERE frequency_rank <= 10)
        * 100.0 / SUM(trade_count))::numeric, 2) AS top_10_frequency_pct
FROM ranked_activity;

-- Question 8: What did trading commissions cost?
SELECT
    COUNT(*) AS trade_records,
    COUNT(*) FILTER (WHERE commission_fee < 0) AS negative_commissions,
    COUNT(*) FILTER (WHERE commission_fee > 0) AS positive_commissions,
    COUNT(*) FILTER (WHERE commission_fee = 0) AS zero_commissions,
    ROUND(SUM(commission_fee)::numeric, 2) AS signed_commission_total,
    ROUND(SUM(ABS(commission_fee))::numeric, 2) AS total_commission_cost,
    ROUND(AVG(ABS(commission_fee))::numeric, 4) AS average_commission,
    ROUND(MAX(ABS(commission_fee))::numeric, 2) AS largest_commission
FROM analytics_trade_orders;

-- Question 9: Does reported realized P&L reconcile for ordinary sell records?
SELECT
    COUNT(*) FILTER (WHERE quantity < 0) AS sell_records,
    COUNT(*) FILTER (
        WHERE quantity < 0
          AND ABS(realized_pnl - (proceeds + commission_fee + basis)) <= 0.01
    ) AS formula_matches,
    COUNT(*) FILTER (
        WHERE quantity < 0
          AND ABS(realized_pnl - (proceeds + commission_fee + basis)) > 0.01
    ) AS formula_mismatches,
    ROUND(MAX(ABS(realized_pnl - (proceeds + commission_fee + basis)))
        FILTER (WHERE quantity < 0)::numeric, 4) AS largest_difference
FROM analytics_trade_orders;

-- Question 10: What were the definitive realized P&L metrics?
WITH realized_results AS (
    SELECT realized_pnl
    FROM analytics_trade_orders
    WHERE realized_pnl <> 0
)
SELECT
    COUNT(*) AS records_with_realized_pnl,
    COUNT(*) FILTER (WHERE realized_pnl > 0) AS profitable_records,
    COUNT(*) FILTER (WHERE realized_pnl < 0) AS losing_records,
    ROUND(SUM(realized_pnl)::numeric, 2) AS net_realized_pnl,
    ROUND(SUM(realized_pnl) FILTER (WHERE realized_pnl > 0)::numeric, 2)
        AS gross_realized_profit,
    ROUND(ABS(SUM(realized_pnl) FILTER (WHERE realized_pnl < 0))::numeric, 2)
        AS gross_realized_loss,
    ROUND((COUNT(*) FILTER (WHERE realized_pnl > 0) * 100.0 / COUNT(*))::numeric, 2)
        AS profitable_records_pct,
    ROUND((SUM(realized_pnl) FILTER (WHERE realized_pnl > 0)
        / NULLIF(ABS(SUM(realized_pnl) FILTER (WHERE realized_pnl < 0)), 0))::numeric, 2)
        AS profit_factor
FROM realized_results;

-- Question 11: In which months was realized P&L generated?
SELECT
    DATE_TRUNC('month', executed_at)::date AS month,
    COUNT(*) FILTER (WHERE realized_pnl <> 0) AS records_with_realized_pnl,
    COUNT(*) FILTER (WHERE realized_pnl > 0) AS profitable_records,
    COUNT(*) FILTER (WHERE realized_pnl < 0) AS losing_records,
    ROUND(SUM(realized_pnl)::numeric, 2) AS net_realized_pnl,
    ROUND(COALESCE(SUM(realized_pnl) FILTER (WHERE realized_pnl > 0), 0)::numeric, 2)
        AS gross_realized_profit,
    ROUND(ABS(COALESCE(SUM(realized_pnl) FILTER (WHERE realized_pnl < 0), 0))::numeric, 2)
        AS gross_realized_loss
FROM analytics_trade_orders
GROUP BY DATE_TRUNC('month', executed_at)
ORDER BY month;

-- Question 12: Which symbols were the leading contributors and detractors?
WITH symbol_results AS (
    SELECT
        symbol,
        COUNT(*) FILTER (WHERE realized_pnl <> 0) AS records_with_realized_pnl,
        COUNT(*) FILTER (WHERE realized_pnl > 0) AS profitable_records,
        COUNT(*) FILTER (WHERE realized_pnl < 0) AS losing_records,
        SUM(realized_pnl) AS net_realized_pnl,
        COALESCE(SUM(realized_pnl) FILTER (WHERE realized_pnl > 0), 0)
            AS gross_realized_profit,
        ABS(COALESCE(SUM(realized_pnl) FILTER (WHERE realized_pnl < 0), 0))
            AS gross_realized_loss
    FROM analytics_trade_orders
    GROUP BY symbol
),
ranked_results AS (
    SELECT
        *,
        ROW_NUMBER() OVER (ORDER BY net_realized_pnl DESC) AS gain_rank,
        ROW_NUMBER() OVER (ORDER BY net_realized_pnl ASC) AS loss_rank
    FROM symbol_results
)
SELECT
    CASE WHEN gain_rank <= 10 THEN 'TOP_GAINER' ELSE 'TOP_DETRACTOR' END
        AS contribution_type,
    symbol,
    records_with_realized_pnl,
    profitable_records,
    losing_records,
    ROUND(net_realized_pnl::numeric, 2) AS net_realized_pnl,
    ROUND(gross_realized_profit::numeric, 2) AS gross_realized_profit,
    ROUND(gross_realized_loss::numeric, 2) AS gross_realized_loss
FROM ranked_results
WHERE gain_rank <= 10 OR loss_rank <= 10
ORDER BY
    CASE WHEN gain_rank <= 10 THEN 1 ELSE 2 END,
    CASE WHEN gain_rank <= 10 THEN net_realized_pnl END DESC,
    CASE WHEN loss_rank <= 10 THEN net_realized_pnl END ASC;

