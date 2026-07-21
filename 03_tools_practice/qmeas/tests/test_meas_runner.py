import asyncio
import os


from qiskit import QuantumCircuit
from qiskit.circuit import ParameterVector


from qmeas.random import (
    CorrectionInput,
    AerOptions,
    QuarkOptions,
    create_parameter_generator,
    create_runner,
    add_meas,
)

test_idx = 4

if __name__ == "__main__":
    setting_num = 2
    shot_num = 1024

    if test_idx == 1:
        meas_indices = [(0,), (5,), (1,), (4,)]
        group_num = len(meas_indices)
        theta = ParameterVector("theta", group_num)
        llambda = ParameterVector("lambda", group_num)
        qc = QuantumCircuit(6, 4)
        qc.cx(0, 1)
        qc.cx(1, 2)
        qc.cx(3, 4)
        qc = add_meas(qc, [theta, llambda], meas_indices)

        generator = create_parameter_generator("derandom")
        parameter_binds = generator.generate(
            [theta, llambda], setting_num
        )
        aer_opts = AerOptions(method="density_matrix", device="CPU", precision="single")
        runner = create_runner(aer_opts)
        result = asyncio.run(
            runner.run(
                qc,
                parameter_binds,
                setting_num,
                shot_num,
                name="my_job",
            )
        )
        print(result.counts)

    elif test_idx == 2:
        meas_indices = [(0, 5), (1, 4)]
        group_num = len(meas_indices)
        theta = ParameterVector("theta", group_num)
        llambda = ParameterVector("lambda", group_num)
        qc = QuantumCircuit(6, 4)
        qc.cx(0, 1)
        qc.cx(1, 2)
        qc.cx(3, 4)
        qc = add_meas(qc, [theta, llambda], meas_indices)

        generator = create_parameter_generator("haar")
        parameter_binds = generator.generate(
            [theta, llambda], setting_num
        )
        aer_opts = AerOptions(method="statevector", device="CPU", precision="single")
        runner = create_runner(aer_opts)
        result = asyncio.run(
            runner.run(
                qc,
                parameter_binds,
                setting_num,
                shot_num,
                name="my_job",
            )
        )
        print(result.counts)

    elif test_idx == 3:
        meas_indices = [(0, 5), (1, 4)]
        group_num = len(meas_indices)
        theta = ParameterVector("theta", group_num)
        llambda = ParameterVector("lambda", group_num)
        qc = QuantumCircuit(6, 4)
        qc.cx(0, 1)
        qc.cx(1, 2)
        qc.cx(3, 4)
        qc = add_meas(qc, [theta, llambda], meas_indices)

        generator = create_parameter_generator("pauli")
        parameter_binds = generator.generate(
            [theta, llambda], setting_num
        )
        quark_opts = QuarkOptions(
            chip="Dongling",
            target_qubits=[],
            token=os.environ["QUARK_TOKEN"],
        )
        runner = create_runner(quark_opts)
        result = asyncio.run(
            runner.run(
                qc,
                parameter_binds,
                setting_num,
                shot_num,
                name="my_job",
            )
        )
        print(result.counts)

    elif test_idx == 4:
        meas_indices = [(0, 5), (1, 4)]
        group_num = len(meas_indices)
        theta = ParameterVector("theta", group_num)
        llambda = ParameterVector("lambda", group_num)
        qc = QuantumCircuit(6, 4)
        qc.cx(0, 1)
        qc.cx(1, 2)
        qc.cx(3, 4)
        qc = add_meas(qc, [theta, llambda], meas_indices)

        trivial_qc = QuantumCircuit(6, 4)
        trivial_qc = add_meas(trivial_qc, [theta, llambda], meas_indices)

        generator = create_parameter_generator("derandom")
        parameter_binds = generator.generate(
            [theta, llambda], setting_num
        )
        trivial_generator = create_parameter_generator("pauli")
        trivial_parameter_binds = trivial_generator.generate(
            [theta, llambda], setting_num
        )

        quark_opts = QuarkOptions(
            chip="Dongling",
            target_qubits=[],
            token=os.environ["QUARK_TOKEN"],
        )
        runner = create_runner(quark_opts)
        result = asyncio.run(
            runner.run(
                qc,
                parameter_binds,
                setting_num,
                shot_num,
                name="my_job",
                correction_input=CorrectionInput(
                    trivial_qc=trivial_qc,
                    trivial_parameter_binds=trivial_parameter_binds,
                    trivial_shot_num=1024,
                ),
            )
        )
        print("counts:", result.counts)
        print("trivial_counts:", result.trivial_counts)