import numpy as np
from qiskit import QuantumCircuit
from qiskit.circuit.library import UnitaryGate
from qiskit.quantum_info import random_unitary


def create_pre_measured_circ(N):
    circ = QuantumCircuit(N, N)
    circ.x([0])
    circ.x([N - 1])
    return circ


def add_local_unitary_setting(circ_fun, N):
    circ = circ_fun(N)
    qubits_num = circ.num_qubits
    local_unitary_setting = np.empty((qubits_num, 2, 2), dtype=np.complex128)
    for index in range(qubits_num):
        u3 = random_unitary(2)
        gate = UnitaryGate(u3)
        circ.append(gate, [index])
        local_unitary_setting[index, :, :] = u3.data
    circ.measure(range(qubits_num), range(qubits_num))
    return circ, local_unitary_setting


def create_measured_circs(circ_fun, settings_num, N):
    circ = circ_fun(N)
    qubits_num = circ.num_qubits
    circs = []
    local_unitary_settings = np.empty(
        (settings_num, qubits_num, 2, 2), dtype=np.complex128
    )
    for settings_index in range(settings_num):
        circ, local_unitary_setting = add_local_unitary_setting(circ_fun, N)
        circs.append(circ)
        local_unitary_settings[settings_index, :, :, :] = local_unitary_setting
    return circs, local_unitary_settings


if __name__ == "__main__":
    N = 4
    settings_num = 2**7
    circs, local_unitary_settings = create_measured_circs(
        create_pre_measured_circ,
        settings_num,
        N,
    )
    print(len(circs), np.shape(local_unitary_settings))
    print(circs[0].decompose(reps=1).draw())
