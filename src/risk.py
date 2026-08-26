"""Risk metrics."""

import numpy as np
import pandas as pd


def annualized_volatility(returns: pd.Series, periods: int = 252) -> float:
    """Calculate annualized sample volatility."""
    return float(returns.dropna().std(ddof=1) * np.sqrt(periods))


def max_drawdown(returns: pd.Series) -> float:
    """Return the most negative drawdown from simple periodic returns."""
    wealth = (1 + returns.dropna()).cumprod()
    drawdown = wealth / wealth.cummax() - 1
    return float(drawdown.min())
