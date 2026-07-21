import os

from qiskit import QuantumCircuit

from qmeas.random import (
    AerOptions,
    QuarkOptions,
    RandomMeasConfig,
    SettingRun,
)

test_idx = 2

if __name__ == "__main__":
    qc = QuantumCircuit(6, 4)
    meas_indices = [(1,), (2,)]
    setting_runs = [
        SettingRun(setting_num=1, shot_num=2),
        SettingRun(setting_num=3, shot_num=4),
    ]
    aer_opts = AerOptions(method="statevector", device="CPU", precision="single")
    quark_opts = QuarkOptions(
        chip="Baihua",
        target_qubits=[],
        token=os.environ["QUARK_TOKEN"],
    )
    a = RandomMeasConfig(
        qc=qc,
        setting_runs=setting_runs,
        meas_indices=meas_indices,
        runner_opts=aer_opts,
    )
    print(a)
    b = RandomMeasConfig(
        qc=qc,
        setting_runs=setting_runs,
        meas_indices=meas_indices,
        runner_opts=quark_opts,
    )
    print(b)
