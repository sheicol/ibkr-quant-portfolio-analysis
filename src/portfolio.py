"""Portfolio composition metrics."""

import pandas as pd


def normalized_weights(market_values: pd.Series) -> pd.Series:
    """Return long-only portfolio weights from non-negative market values."""
    if market_values.empty or (market_values < 0).any():
        raise ValueError("market_values must be non-empty and non-negative")
    total = market_values.sum()
    if total <= 0:
        raise ValueError("total market value must be positive")
    return market_values / total


def hhi(weights: pd.Series) -> float:
    """Calculate the Herfindahl-Hirschman concentration index."""
    return float(weights.pow(2).sum())
