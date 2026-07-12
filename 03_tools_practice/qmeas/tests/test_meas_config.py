import os

from qiskit import QuantumCircuit

from qmeas.random import (
    AerOptions,
    QuarkOptions,
    RandomMeasConfig,
    SettingRun,
)

test_idx = 1

if __name__ == "__main__":
    qc = QuantumCircuit(6, 4)
    meas_indices = [1, 2]
    setting_runs = [
        SettingRun(setting_num=1, shot_num=2),
        SettingRun(setting_num=3, shot_num=4),
    ]
    a = RandomMeasConfig(
        qc=qc,
        setting_runs=setting_runs,
        meas_indices=meas_indices,
        runner_opts=AerOptions(method="statevector", device="CPU", precision="single"),
    )
    print(a)
    b = RandomMeasConfig(
        qc=qc,
        setting_runs=setting_runs,
        meas_indices=meas_indices,
        runner_opts=QuarkOptions(
            chip="Baihua",
            target_qubits=[],
            token=os.environ["QUARK_TOKEN"],
        ),
    )
    print(b)
