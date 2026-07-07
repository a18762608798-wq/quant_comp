import sys
from pathlib import Path


from qiskit import QuantumCircuit


# 将 09_reas_runner 目录加入搜索路径
sys.path.insert(0, str(Path(__file__).resolve().parent.parent))

import src

test_idx = 1

if __name__ == "__main__":
    qc = QuantumCircuit(6, 4)
    meas_indices = [1, 2]
    setting_pairs = [(1, 2), (3, 4)]
    a = src.RandomMeasConfig(
        qc=qc,
        setting_pairs=setting_pairs,
        meas_indices=meas_indices,
        runner_opts=src.AerOptions(
            method="statevector", device="CPU", precision="single"
        ),
    )
    print(a)
    b = src.RandomMeasConfig(
        qc=qc,
        setting_pairs=setting_pairs,
        meas_indices=meas_indices,
        runner_opts=src.QuarkOptions(chip="Baihua", target_qubits=[]),
    )
    print(b)
