"""
DGP spec
---------
Solow growth model (closed economy, Cobb-Douglas):

    y_t = A_t * k_t^alpha
    k_{t+1} = (1 - delta) * k_t + s * y_t
    A_{t+1} = A_t * exp(g + eps_t)
    eps_t ~ N(0, sigma^2)

Simulate N economies over T periods. Save a tidy CSV with columns:
unit_id, t, k, y, A

Then compute and plot mean(k_t) and mean(y_t) over time.
"""

from __future__ import annotations

import numpy as np
import pandas as pd
import matplotlib.pyplot as plt

# Parameters (can be edited for the demo)
ALPHA = 0.33  # capital share
S = 0.25  # savings rate
DELTA = 0.06  # depreciation
G = 0.02  # trend growth in technology
SIGMA = 0.02  # shock std dev to log A
N = 200
T = 50
SEED = 123


def main() -> None:
    """Placeholder for Codex to implement."""
    # TODO: implement the simulation and plotting described above.
    pass


if __name__ == "__main__":
    main()
