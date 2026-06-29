import asyncio
import sys
from pathlib import Path


import numpy as np
from qiskit import QuantumCircuit
from qiskit.circuit import ParameterVector


# 将 09_reas_runner 目录加入搜索路径
sys.path.insert(0, str(Path(__file__).resolve().parent.parent))

from src import MeasConfig

test_idx = 1

if __name__ == "__main__":
    qc = QuantumCircuit(6, 4)
    meas_indices = np.array([1, 2])
    setting_nums = np.array([1, 2])
    shot_nums = np.array([1, 2])
    a = MeasConfig(
        qc=qc,
        setting_nums=setting_nums,
        shot_nums=shot_nums,
        meas_indices=meas_indices,
        backend = "statevector",
    )
    print(a)
