import asyncio
import sys
from pathlib import Path


import numpy as np
from qiskit import QuantumCircuit
from qiskit.circuit import ParameterVector


# 将 09_reas_runner 目录加入搜索路径
sys.path.insert(0, str(Path(__file__).resolve().parent.parent))

from src import RandomMeasConfig

test_idx = 1

if __name__ == "__main__":
    qc = QuantumCircuit(6, 4)
    meas_indices = np.array([1, 2])
    setting_pairs = [(1, 2), (3, 4)]
    a = RandomMeasConfig(
        qc=qc,
        setting_pairs=setting_pairs,
        meas_indices=meas_indices,
        backend = "statevector",
    )
    print(a)
