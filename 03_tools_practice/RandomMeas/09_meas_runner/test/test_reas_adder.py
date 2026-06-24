import asyncio
import sys
from pathlib import Path


import numpy as np
from qiskit import QuantumCircuit
from qiskit.circuit import ParameterVector


# 将 09_reas_runner 目录加入搜索路径
sys.path.insert(0, str(Path(__file__).resolve().parent.parent))

from src import get_shadow_params, get_hamming_params, add_meas, run_meas_qc

test_idx = 1

if __name__ == "__main__":
    # add params meas
    meas_indices = [2, 3]
    meas_num = len(meas_indices)
    theta = ParameterVector("theta", meas_num)
    llambda = ParameterVector("lambda", meas_num)
    qc = QuantumCircuit(5, 2)
    qc.cx(0, 1)
    qc.cx(1, 2)
    qc = add_meas(qc, [theta, llambda], meas_indices)
    # give specific vals.
    setting_num = 100
    shots = 100
    if test_idx == 1:
        parameter_binds = get_shadow_params([theta, llambda], meas_indices, setting_num)
        counts_ls = asyncio.run(run_meas_qc(qc, parameter_binds, setting_num, shots))
    elif test_idx == 2:
        parameter_binds = get_hamming_params([theta, llambda], meas_indices, setting_num)
        counts_ls = asyncio.run(run_meas_qc(qc, parameter_binds, setting_num, shots))
