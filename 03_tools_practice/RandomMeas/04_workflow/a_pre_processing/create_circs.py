import numpy as np
from qiskit import QuantumCircuit
from qiskit.circuit.library import UnitaryGate
from qiskit.quantum_info import random_unitary


def create_pre_measured_circ():
    circ = QuantumCircuit(4, 4)
    circ.x([0])
    circ.x([3])
    return circ


def create_classical_circ():
    circ = create_pre_measured_circ()
    qubits_num = circ.num_qubits
    clcirc = QuantumCircuit(qubits_num, qubits_num)
    return clcirc


def add_local_unitary_setting(circ_fun):
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


def create_measured_circs(circ_fun, settings_num):
    circ = circ_fun()
    qubits_num = circ.num_qubits
    circs = []
    local_unitary_settings = np.empty(
        (settings_num, qubits_num, 2, 2), dtype=np.complex128
    )
    for settings_index in range(settings_num):
        circ, local_unitary_setting = add_local_unitary_setting(circ_fun)
        circs.append(circ)
        local_unitary_settings[settings_index, :, :, :] = local_unitary_setting
    return circs, local_unitary_settings


if __name__ == "__main__":
    settings_num = 2**7
    circs, local_unitary_settings = create_measured_circs(
        create_pre_measured_circ,
        settings_num,
    )
    clcircs, classical_local_unitary_settings = create_measured_circs(
        create_classical_circ,
        settings_num,
    )
    print(len(circs), np.shape(local_unitary_settings))
    print(len(clcircs), np.shape(classical_local_unitary_settings))
    print(circs[0].decompose(reps=1).draw())
    print(clcircs[1].decompose(reps=1).draw())
