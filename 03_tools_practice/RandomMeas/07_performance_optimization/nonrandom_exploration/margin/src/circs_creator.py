import numpy as np
from qiskit import QuantumCircuit
from qiskit.circuit.library import UnitaryGate, HGate, SdgGate
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


def add_pauli_meas(circ_fun, pauli_base):
    circ = circ_fun()
    qubits_num = circ.num_qubits
    for index in range(qubits_num):
        if pauli_base[index] == 2:
            circ.append(HGate(), [index])
        elif pauli_base[index] == 3:
            circ.append(SdgGate(), [index])
            circ.append(HGate(), [index])
    circ.measure(range(qubits_num), range(qubits_num))
    return circ


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


def create_pauli_meas_circs(circ_fun, pauli_bases):
    pauli_num = len(pauli_bases)
    circs = []
    for index in range(pauli_num):
        pauli_base = pauli_bases[index]
        circ = add_pauli_meas(circ_fun, pauli_base)
        circs.append(circ)
    return circs
