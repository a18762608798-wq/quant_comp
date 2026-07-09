import os

from qiskit import QuantumCircuit

from qmeas import random as src

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
        runner_opts=src.QuarkOptions(
            chip="Baihua",
            target_qubits=[],
            token=os.environ["QUARK_TOKEN"],
        ),
    )
    print(b)
