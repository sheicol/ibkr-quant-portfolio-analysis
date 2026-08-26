-- Analysis 01: Portfolio composition and concentration
-- Source: analytics_positions
-- All outputs are structural metrics and portfolio weights; no account IDs are used.

-- Question 1: How many rows and unique positions exist, and are the data complete?
SELECT
    COUNT(*) AS rows,
    COUNT(DISTINCT symbol) AS unique_symbols,
    COUNT(*) FILTER (WHERE symbol IS NULL) AS missing_symbols,
    COUNT(*) FILTER (
        WHERE market_value IS NULL OR portfolio_weight IS NULL
    ) AS incomplete_positions,
    COUNT(*) FILTER (
        WHERE quantity < 0 OR market_value < 0 OR portfolio_weight < 0
    ) AS negative_positions,
    ROUND(SUM(portfolio_weight)::numeric, 6) AS total_weight,
    ROUND(MIN(portfolio_weight)::numeric, 6) AS smallest_weight,
    ROUND(MAX(portfolio_weight)::numeric, 6) AS largest_weight
FROM analytics_positions;

-- Question 2: How is the portfolio distributed by currency and asset class?
SELECT
    currency,
    asset_class,
    COUNT(*) AS positions,
    ROUND(SUM(portfolio_weight)::numeric, 6) AS combined_weight
FROM analytics_positions
GROUP BY currency, asset_class
ORDER BY combined_weight DESC;

-- Question 3: Which symbols have more than one row in the source table?
SELECT
    symbol,
    COUNT(*) AS occurrences,
    ROUND(SUM(portfolio_weight)::numeric, 6) AS combined_weight
FROM analytics_positions
GROUP BY symbol
HAVING COUNT(*) > 1
ORDER BY occurrences DESC, symbol;

-- Question 4: Which assets are held in more than one model?
SELECT
    symbol,
    COUNT(DISTINCT model) AS model_count,
    STRING_AGG(
        DISTINCT COALESCE(model, 'Sin modelo'),
        ', '
        ORDER BY COALESCE(model, 'Sin modelo')
    ) AS models,
    ROUND(SUM(portfolio_weight)::numeric, 6) AS combined_weight,
    ROUND((SUM(portfolio_weight) * 100)::numeric, 2) AS combined_weight_pct
FROM analytics_positions
GROUP BY symbol
HAVING COUNT(DISTINCT model) > 1
ORDER BY combined_weight DESC;

-- Question 5: What are the ten largest consolidated portfolio positions?
WITH positions_by_symbol AS (
    SELECT
        symbol,
        COUNT(DISTINCT model) AS model_count,
        STRING_AGG(
            DISTINCT COALESCE(model, 'Sin modelo'),
            ', '
            ORDER BY COALESCE(model, 'Sin modelo')
        ) AS models,
        SUM(portfolio_weight) AS symbol_weight
    FROM analytics_positions
    GROUP BY symbol
)
SELECT
    symbol,
    model_count,
    models,
    ROUND(symbol_weight::numeric, 6) AS portfolio_weight,
    ROUND((symbol_weight * 100)::numeric, 2) AS weight_pct
FROM positions_by_symbol
ORDER BY symbol_weight DESC
LIMIT 10;

-- Question 6: How much of the portfolio is controlled by the Top 5 and Top 10?
WITH positions_by_symbol AS (
    SELECT
        symbol,
        SUM(portfolio_weight) AS symbol_weight
    FROM analytics_positions
    GROUP BY symbol
),
ranked_positions AS (
    SELECT
        symbol,
        symbol_weight,
        ROW_NUMBER() OVER (ORDER BY symbol_weight DESC) AS position_rank
    FROM positions_by_symbol
)
SELECT
    ROUND(
        (SUM(symbol_weight) FILTER (WHERE position_rank <= 5) * 100)::numeric,
        2
    ) AS top_5_weight_pct,
    ROUND(
        (SUM(symbol_weight) FILTER (WHERE position_rank <= 10) * 100)::numeric,
        2
    ) AS top_10_weight_pct
FROM ranked_positions;

-- Question 7: What is the HHI and the effective number of positions?
-- Reference interpretation: <0.10 low; 0.10-0.18 moderate; >0.18 high.
WITH positions_by_symbol AS (
    SELECT
        symbol,
        SUM(portfolio_weight) AS symbol_weight
    FROM analytics_positions
    GROUP BY symbol
)
SELECT
    COUNT(*) AS unique_positions,
    ROUND(SUM(POWER(symbol_weight, 2))::numeric, 6) AS hhi,
    ROUND((1 / SUM(POWER(symbol_weight, 2)))::numeric, 2)
        AS effective_number_of_positions
FROM positions_by_symbol;

-- Question 8: How is the portfolio allocated among IBKR models?
SELECT
    COALESCE(model, 'Sin modelo') AS model,
    COUNT(*) AS position_rows,
    COUNT(DISTINCT symbol) AS unique_symbols,
    ROUND(SUM(portfolio_weight)::numeric, 6) AS model_weight,
    ROUND((SUM(portfolio_weight) * 100)::numeric, 2) AS model_weight_pct
FROM analytics_positions
GROUP BY model
ORDER BY model_weight DESC;

-- Reproducibility check: Does PostgreSQL match the documented analytics schema?
SELECT
    table_name,
    ordinal_position,
    column_name,
    data_type,
    is_nullable
FROM information_schema.columns
WHERE table_schema = 'public'
  AND table_name IN ('analytics_positions', 'analytics_trade_orders')
ORDER BY table_name, ordinal_position;

