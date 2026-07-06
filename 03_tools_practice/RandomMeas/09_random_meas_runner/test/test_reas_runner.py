import asyncio
import sys
from pathlib import Path


from qiskit import QuantumCircuit
from qiskit.circuit import ParameterVector


sys.path.insert(0, str(Path(__file__).resolve().parent.parent))

from src import (
    get_shadow_params,
    get_hamming_params,
    add_meas,
    run_quark_qc,
    run_aer_qc,
)

test_idx = 3

if __name__ == "__main__":
    # add params meas
    meas_indices = [0, 3, 1, 2]
    meas_num = len(meas_indices)
    theta = ParameterVector("theta", meas_num)
    llambda = ParameterVector("lambda", meas_num)
    qc = QuantumCircuit(6, 4)
    qc.cx(0, 1)
    qc.cx(1, 2)
    qc = add_meas(qc, [theta, llambda], meas_indices)
    # give specific vals.
    setting_num = 2
    shot_num = 1024
    if test_idx == 1:
        parameter_binds = get_shadow_params([theta, llambda], meas_indices, setting_num)
        counts_ls = run_aer_qc(qc, parameter_binds, setting_num, shot_num)
        print(counts_ls)
    elif test_idx == 2:
        parameter_binds = get_hamming_params(
            [theta, llambda], meas_indices, setting_num
        )
        counts_ls = run_aer_qc(qc, parameter_binds, setting_num, shot_num)
        print(counts_ls)
    elif test_idx == 3:
        parameter_binds = get_hamming_params(
            [theta, llambda], meas_indices, setting_num
        )
        counts_ls = asyncio.run(
            run_quark_qc(qc, parameter_binds, setting_num, shot_num, backend="Baihua")
        )
        print(counts_ls)
