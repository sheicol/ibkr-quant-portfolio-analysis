"""Performance metrics."""

import numpy as np
import pandas as pd


def annualized_return(returns: pd.Series, periods: int = 252) -> float:
    """Annualize a series of simple periodic returns."""
    clean = returns.dropna()
    if clean.empty:
        raise ValueError("returns must contain at least one observation")
    return float(np.prod(1 + clean) ** (periods / len(clean)) - 1)
