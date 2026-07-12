import asyncio
import os
from pathlib import Path


from qiskit import QuantumCircuit


from qmeas.random import (
    CorrectionInput,
    AerOptions,
    QuarkOptions,
    RandomMeasConfig,
    SettingRun,
    run_pipeline,
)


test_idx = 4

if __name__ == "__main__":
    HERE = Path(__file__).resolve().parent
    if test_idx == 1:
        # aer: independence, derandom
        qc = QuantumCircuit(6, 4)
        meas_indices = [2, 3, 4, 5]  # Arrange the swap bits together
        setting_runs = [
            SettingRun(setting_num=2, shot_num=1024),
            SettingRun(setting_num=5, shot_num=1024),
        ]
        meas_config = RandomMeasConfig(
            qc=qc,
            setting_runs=setting_runs,
            meas_indices=meas_indices,
            meas_mode="independence",
            ensemble="derandom",
            runner_opts=AerOptions(
                method="statevector", device="CPU", precision="single"
            ),
            output_dir=HERE / "./data",
            name="aer-independence",
        )
        res = asyncio.run(
            run_pipeline(
                config=meas_config,
            )
        )
        print(res)
    elif test_idx == 2:
        # aer: pair, haar
        qc = QuantumCircuit(6, 4)
        meas_indices = [2, 5, 3, 4]  # Arrange the swap bits together
        setting_runs = [
            SettingRun(setting_num=2, shot_num=1024),
            SettingRun(setting_num=5, shot_num=1024),
        ]
        meas_config = RandomMeasConfig(
            qc=qc,
            setting_runs=setting_runs,
            meas_indices=meas_indices,
            meas_mode="pair",
            ensemble="haar",
            runner_opts=AerOptions(
                method="statevector", device="CPU", precision="single"
            ),
            output_dir=HERE / "./data",
            name="aer-pair",
        )
        res = asyncio.run(
            run_pipeline(
                config=meas_config,
            )
        )
        print(res)
    elif test_idx == 3:
        # quark-native-independence, pauli
        qc = QuantumCircuit(6, 4)
        qc.cz(list(range(0, 5)), list(range(1, 6)))
        meas_indices = [2, 3, 4, 5]
        setting_runs = [
            SettingRun(setting_num=2, shot_num=1024),
            SettingRun(setting_num=5, shot_num=2048),
        ]

        meas_config = RandomMeasConfig(
            qc=qc,
            setting_runs=setting_runs,
            meas_indices=meas_indices,
            meas_mode="independence",
            ensemble="pauli",
            runner_opts=QuarkOptions(
                chip="Dongling",
                target_qubits=[],
                token=os.environ["QUARK_TOKEN"],
            ),
            output_dir=HERE / "./data",
            name="quark-native-independence",
        )
        res = asyncio.run(run_pipeline(config=meas_config))
        print(res)
    elif test_idx == 4:
        # quark-correction-pair, derandom
        qc = QuantumCircuit(6, 4)
        qc.cx(list(range(0, 5)), list(range(1, 6)))
        meas_indices = [2, 5, 3, 4]
        setting_runs = [
            SettingRun(setting_num=2, shot_num=1024),
            SettingRun(setting_num=5, shot_num=2048),
        ]

        meas_config = RandomMeasConfig(
            qc=qc,
            setting_runs=setting_runs,
            meas_indices=meas_indices,
            meas_mode="pair",
            ensemble="derandom",
            runner_opts=QuarkOptions(
                chip="Dongling",
                target_qubits=[],
                token=os.environ["QUARK_TOKEN"],
                correction_input=CorrectionInput(
                    trivial_shot_num=1024,
                ),
            ),
            output_dir=HERE / "./data",
            name="quark-correction-pair",
        )
        res = asyncio.run(run_pipeline(config=meas_config))
        print(res)
