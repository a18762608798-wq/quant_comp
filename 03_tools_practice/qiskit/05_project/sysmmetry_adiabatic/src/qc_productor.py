import numpy as np
from qiskit import QuantumCircuit
from qiskit.quantum_info import SparsePauliOp
from qiskit.circuit.library import PauliEvolutionGate
from qiskit.synthesis import SuzukiTrotter


def get_initial_state(
    qubit_num,
    clbit_num,
):
    qc = QuantumCircuit(qubit_num, clbit_num)
    # internal connection
    qc.x([qubit for qubit in range(1, qubit_num - 1)])
    qc.h([qubit for qubit in range(1, qubit_num - 1, 2)])
    qc.cx(
        [qubit for qubit in range(1, qubit_num - 2, 2)],
        [qubit for qubit in range(2, qubit_num - 1, 2)],
    )
    # boundary condition
    qc.x([0, qubit_num - 1])
    qc.h([0])
    qc.cx([0], [qubit_num - 1])
    return qc


def get_H_nontrivial(n):
    x_link = [("XX", [i, i + 1], 1.0) for i in range(1, n - 2, 2)]
    z_link = [("ZZ", [i, i + 1], 1.0) for i in range(1, n - 2, 2)]
    return SparsePauliOp.from_sparse_list([*x_link, *z_link], num_qubits=n)


def get_H_trivial(n):
    x_link = [("XX", [i, i + 1], 1.0) for i in range(0, n - 1, 2)]
    z_link = [("ZZ", [i, i + 1], 1.0) for i in range(0, n - 1, 2)]
    return SparsePauliOp.from_sparse_list([*x_link, *z_link], num_qubits=n)


def get_ssh_op(qubit_num, t, T):
    H_nontrivial = get_H_nontrivial(qubit_num)
    H_trivial = get_H_trivial(qubit_num)
    s = t / T
    ssh_op = (1 - s) * H_nontrivial + s * H_trivial
    return ssh_op


def get_nonuniform_grid(
    T, N, steepness=3
):  # steepness is to control the distribution of points
    x = np.linspace(-1, 1, N)
    s = np.sinh(steepness * x) / np.sinh(steepness)
    return (s + 1) / 2 * T


def get_evolutionary_qc(
    get_op,
    initial_state,
    t_ls,
    T,
    order=2,
    reps=1,
):
    # clean the data
    t_num = len(t_ls)
    qubit_num = initial_state.num_qubits
    synth = SuzukiTrotter(order=order, reps=reps)
    # evolution
    for t_idx in range(t_num - 1):
        # get the time
        dt = t_ls[t_idx + 1] - t_ls[t_idx]
        t = t_ls[t_idx] + 0.5 * dt
        # get H(t)
        H_t = get_op(qubit_num, t, T)
        # add evolution gate
        evo = PauliEvolutionGate(
            H_t,
            time=dt,
            synthesis=synth,
        )
        initial_state.append(evo, range(qubit_num))

    evolutionary_qc = initial_state

    return evolutionary_qc
