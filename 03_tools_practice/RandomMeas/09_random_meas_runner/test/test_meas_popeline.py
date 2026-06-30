import asyncio
import sys
from pathlib import Path


import numpy as np
from qiskit import QuantumCircuit


sys.path.insert(0, str(Path(__file__).resolve().parent.parent))

from src import *


if __name__ == "__main__":
    qc = QuantumCircuit(6, 4)
    meas_indices = np.array([0, 3, 1, 2]) # Arrange the swap bits together
    setting_pairs = [(2, 1024), (5, 1024)]
    HERE = Path(__file__).resolve().parent
    meas_config = RandomMeasConfig(
        qc=qc,
        setting_pairs=setting_pairs,
        meas_indices=meas_indices,
        meas_mode="hamming",         
        backend="Dongling",
        output_dir=HERE / "./data",
        name="test",
    )
    res = asyncio.run(run_pipeline(
        config = meas_config,
    ))
    print(res)
