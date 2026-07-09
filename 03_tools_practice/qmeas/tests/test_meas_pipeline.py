import asyncio
import os
from pathlib import Path


from qiskit import QuantumCircuit


from qmeas.random import (
    CorrectionInput,
    AerOptions,
    QuarkOptions,
    RandomMeasConfig,
    run_pipeline,
)


test_idx = 1

if __name__ == "__main__":
    HERE = Path(__file__).resolve().parent
    if test_idx == 1:
        # aer: random, derandom
        qc = QuantumCircuit(6, 4)
        meas_indices = [2, 3, 4, 5]  # Arrange the swap bits together
        setting_pairs = [(2, 1024), (5, 1024)]
        meas_config = RandomMeasConfig(
            qc=qc,
            setting_pairs=setting_pairs,
            meas_indices=meas_indices,
            meas_mode="random",
            ensemble="derandom",
            runner_opts=AerOptions(
                method="statevector", device="CPU", precision="single"
            ),
            output_dir=HERE / "./data",
            name="aer-random",
        )
        res = asyncio.run(
            run_pipeline(
                config=meas_config,
            )
        )
        print(res)
    elif test_idx == 2:
        # aer: condition, haar
        qc = QuantumCircuit(6, 4)
        meas_indices = [2, 5, 3, 4]  # Arrange the swap bits together
        setting_pairs = [(2, 1024), (5, 1024)]
        meas_config = RandomMeasConfig(
            qc=qc,
            setting_pairs=setting_pairs,
            meas_indices=meas_indices,
            meas_mode="condition",
            ensemble="haar",
            runner_opts=AerOptions(
                method="statevector", device="CPU", precision="single"
            ),
            output_dir=HERE / "./data",
            name="aer-condition",
        )
        res = asyncio.run(
            run_pipeline(
                config=meas_config,
            )
        )
        print(res)
    elif test_idx == 3:
        # quark-native-random, pauli
        qc = QuantumCircuit(6, 4)
        qc.cz(list(range(0, 5)), list(range(1, 6)))
        meas_indices = [2, 3, 4, 5]
        setting_pairs = [(2, 1024), (5, 2048)]

        meas_config = RandomMeasConfig(
            qc=qc,
            setting_pairs=setting_pairs,
            meas_indices=meas_indices,
            meas_mode="random",
            ensemble="pauli",
            runner_opts=QuarkOptions(
                chip="Dongling",
                target_qubits=[],
                token=os.environ["QUARK_TOKEN"],
            ),
            output_dir=HERE / "./data",
            name="quark-native-random",
        )
        res = asyncio.run(run_pipeline(config=meas_config))
        print(res)
    elif test_idx == 4:
        # quark-correction-condition, derandom
        qc = QuantumCircuit(6, 4)
        qc.cx(list(range(0, 5)), list(range(1, 6)))
        meas_indices = [2, 5, 3, 4]
        setting_pairs = [(2, 1024), (5, 2048)]

        meas_config = RandomMeasConfig(
            qc=qc,
            setting_pairs=setting_pairs,
            meas_indices=meas_indices,
            meas_mode="condition",
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
            name="quark-correction-condition",
        )
        res = asyncio.run(run_pipeline(config=meas_config))
        print(res)
