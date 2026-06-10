import numpy as np
from qiskit import QuantumCircuit
from qiskit.circuit.library import UnitaryGate
from qiskit.quantum_info import random_unitary


def create_pre_measured_circ():
    N = 8
    circ = QuantumCircuit(N, N)
    for i in range(1, N - 1, 1):
        circ.x(i)
    for i in range(1, N - 1, 2):
        circ.h(i)
    for i in range(1, N - 2, 2):
        circ.cx(i, i + 1)
    return circ


def create_classical_circ():
    qubits_num = 8
    clcirc = QuantumCircuit(qubits_num, qubits_num)
    return clcirc


def add_random_meas(circ_fun):
    circ = circ_fun()
    qubits_num = circ.num_qubits
    local_unitary_setting = np.empty((qubits_num, 2, 2), dtype=np.complex128)
    for index in range(qubits_num):
        u3 = random_unitary(2)
        gate = UnitaryGate(u3)
        circ.append(gate, [index])
        local_unitary_setting[index, :, :] = u3.data
    circ.measure(range(qubits_num), range(qubits_num))
    return circ, local_unitary_setting


def add_conditional_random_meas(circ_fun):
    circ = circ_fun()
    qubits_num = circ.num_qubits
    local_unitary_setting = np.empty((qubits_num, 2, 2), dtype=np.complex128)
    for index in range(qubits_num//2):
        reflect_index = qubits_num - 1 - index
        u3 = random_unitary(2)
        gate = UnitaryGate(u3)
        circ.append(gate, [index])
        circ.append(gate, [reflect_index])
        local_unitary_setting[index, :, :] = u3.data
        local_unitary_setting[reflect_index, :, :] = u3.data
    circ.measure(range(qubits_num), range(qubits_num))
    return circ, local_unitary_setting


def create_random_meas_circs(meas_fun, circ_fun, settings_num):
    circ = circ_fun()
    qubits_num = circ.num_qubits
    circs = []
    local_unitary_settings = np.empty(
        (settings_num, qubits_num, 2, 2), dtype=np.complex128
    )
    for settings_index in range(settings_num):
        circ, local_unitary_setting = meas_fun(circ_fun)
        circs.append(circ)
        local_unitary_settings[settings_index, :, :, :] = local_unitary_setting
    return circs, local_unitary_settings


if __name__ == "__main__":
    settings_num = 2**7
    clcircs, classical_local_unitary_settings = create_random_meas_circs(
        add_random_meas,
        create_classical_circ,
        settings_num,
    )
    circs, local_unitary_settings = create_random_meas_circs(
        add_random_meas,
        create_pre_measured_circ,
        settings_num,
    )
    condition_circs, conditional_local_unitary_settings = create_random_meas_circs(
        add_conditional_random_meas,
        create_pre_measured_circ,
        settings_num,
    )

    print(len(clcircs), np.shape(classical_local_unitary_settings))
    print(len(circs), np.shape(local_unitary_settings))
    print(len(condition_circs), np.shape(conditional_local_unitary_settings))
    print(circs[0].decompose(reps=1).draw())
    print(clcircs[1].decompose(reps=1).draw())
    print(condition_circs[0].decompose(reps=1).draw())
