import asyncio
import os
import sys
from pathlib import Path


from qiskit import QuantumCircuit
from qiskit.circuit import ParameterVector


sys.path.insert(0, str(Path(__file__).resolve().parent.parent))

from src import (
    CorrectionInput,
    get_random_params,
    get_condition_params,
    add_meas,
    run_quark_qc,
    run_aer_qc,
)

test_idx = 4

if __name__ == "__main__":
    # add params meas
    meas_indices = [0, 3, 1, 2]
    meas_num = len(meas_indices)
    theta = ParameterVector("theta", meas_num)
    llambda = ParameterVector("lambda", meas_num)
    qc = QuantumCircuit(6, 4)
    qc.cx(0, 1)
    qc.cx(1, 2)
    qc.cx(4, 5)
    qc = add_meas(qc, [theta, llambda], meas_indices)
    # give specific vals.
    setting_num = 2
    shot_num = 1024

    if test_idx == 1:
        parameter_binds = get_random_params([theta, llambda], meas_indices, setting_num)
        counts_ls = run_aer_qc(
            qc,
            parameter_binds,
            setting_num,
            shot_num,
            method="statevector",
            device="CPU",
            precision="single",
        )
        print(counts_ls)

    elif test_idx == 2:
        parameter_binds = get_condition_params(
            [theta, llambda], meas_indices, setting_num
        )
        counts_ls = run_aer_qc(
            qc,
            parameter_binds,
            setting_num,
            shot_num,
            method="statevector",
            device="CPU",
            precision="single",
        )
        print(counts_ls)

    elif test_idx == 3:
        parameter_binds = get_condition_params(
            [theta, llambda], meas_indices, setting_num
        )
        counts_ls, _ = asyncio.run(
            run_quark_qc(
                qc,
                parameter_binds,
                setting_num,
                shot_num,
                token=os.environ["QUARK_TOKEN"],
                backend="Dongling",
                name="my_job",
                target_qubits=[],
            )
        )
        print(counts_ls)

    elif test_idx == 4:
        # trivial circuit
        trivial_qc = QuantumCircuit(6, 4)
        trivial_qc = add_meas(trivial_qc, [theta, llambda], meas_indices)

        # parameter binds
        parameter_binds = get_condition_params(
            [theta, llambda], meas_indices, setting_num
        )
        trivial_parameter_binds = get_condition_params(
            [theta, llambda], meas_indices, setting_num
        )

        counts_ls, trivial_counts = asyncio.run(
            run_quark_qc(
                qc,
                parameter_binds,
                setting_num,
                shot_num,
                token=os.environ["QUARK_TOKEN"],
                backend="Dongling",
                name="my_job",
                target_qubits=[],
                correction_input=CorrectionInput(
                    trivial_qc=trivial_qc,
                    trivial_parameter_binds=trivial_parameter_binds,
                    trivial_shot_num=1024,
                ),
            )
        )
        print("counts:", counts_ls)
        print("trivial_counts:", trivial_counts)
