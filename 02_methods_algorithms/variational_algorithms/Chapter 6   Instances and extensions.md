---
jupyter:
  jupytext:
    cell_metadata_filter: -all
    formats: ipynb,md
    text_representation:
      extension: .md
      format_name: markdown
      format_version: '1.3'
      jupytext_version: 1.19.1
  kernelspec:
    display_name: .python
    language: python
    name: python3
---

## 6.1 Variational Quantum Eigensolver (VQE)


```python
from qiskit import QuantumCircuit
from qiskit.quantum_info import SparsePauliOp
from qiskit.circuit.library import TwoLocal
import numpy as np
 
observable = SparsePauliOp.from_list([("XX", 1), ("YY", -3)])
 
reference_circuit = QuantumCircuit(2)
reference_circuit.x(0)
reference_circuit.barrier([0, 1])
 
variational_form = TwoLocal(
    2,
    rotation_blocks=["rz", "ry"],
    entanglement_blocks="cx",
    entanglement="linear",
    reps=1,
)
ansatz = reference_circuit.compose(variational_form)

ansatz.decompose().draw("mpl")
```

```python
def cost_func_vqe(params0, ansatz, hamiltonian, estimator):
    """Return estimate of energy from estimator
 
    Parameters:
        params (ndarray): Array of ansatz parameters
        ansatz (QuantumCircuit): Parameterized ansatz circuit
        hamiltonian (SparsePauliOp): Operator representation of Hamiltonian
        estimator (Estimator): Estimator primitive instance
 
    Returns:
        float: Energy estimate
    """
 
    estimator_job = estimator.run([(ansatz, hamiltonian, [params0])])
    estimator_result = estimator_job.result()[0]
 
    cost = estimator_result.data.evs[0]
    return cost
```

```python
from qiskit.primitives import StatevectorEstimator
# SciPy minimizer routine
from scipy.optimize import minimize
 
estimator = StatevectorEstimator()

theta0_list = np.random.uniform(0, 2 * np.pi, ansatz.num_parameters)
 
result = minimize(
    cost_func_vqe, theta0_list, args=(ansatz, observable, estimator), method="COBYLA"
)
 
result
```

## 6.2 Subspace Search VQE (SSVQE)

$$
C(\vec \theta) = \sum_{j = 0}^{k - 1} w_j \langle \rho_j | U_V^\dagger(\vec\theta)\hat H U_V(\vec \theta) |\rho_j\rangle
$$
Where $\langle \rho_i|\rho_j\rangle = \delta_{ij}$, $k \le N$; If $j < l < k$ then $\omega_j > \omega_l$.

The advantage of this algorithm is to calculate the eigenvalue subspace $\{\lambda_0, \lambda_1, ..., \lambda_j, ..., \lambda_{k-1}\}$

[^1]: of course you will get some same eigenvalues when the system is degenerate.


```python
from qiskit import QuantumCircuit
from qiskit.quantum_info import SparsePauliOp
from qiskit.circuit.library import TwoLocal
import numpy as np
from qiskit.primitives import StatevectorEstimator
from scipy.optimize import minimize
 
 
def cost_func_ssvqe(
    params:np.ndarray, weights:np.ndarray, ansatzs:list, hamiltonian, estimator
):
    ansatzs_count = len(ansatzs)
    energies = np.zeros((ansatzs_count, ))
    for i in range(ansatzs_count):
        estimator_job = estimator.run([(ansatzs[i], hamiltonian, [params])])
        estimator_result = estimator_job.result()[0]
        energies[i] = estimator_result.data.evs[0]
 
    # Define SSVQE
    weighted_energy_sum = np.dot(energies, weights)
    return weighted_energy_sum
```

```python
bit_count = 3
weights_count = 8

ref_circ_list = []
for i in range(weights_count):
    state_str = f"{i:0{bit_count}b}"  # 格式化为bit_count位二进制字符串，如'001'
    # 创建bit_count量子比特电路
    qc = QuantumCircuit(bit_count)
    # 注意：字符串最右边位对应qubit 0（Qiskit约定）
    for qubit_idx, bit in enumerate(reversed(state_str)):
        if bit == '1':
            qc.x(qubit_idx)
    qc.barrier(range(bit_count))
    ref_circ_list.append(qc)

variational_form = TwoLocal(
    bit_count,
    rotation_blocks=["rz", "ry"],
    entanglement_blocks="cx",
    entanglement="full",  # 全连接提升表达能力
    reps=3,               # 增加层数
    skip_unentangled_qubits=False
)

ansatzs = []
for i in range(weights_count):
    ansatzs.append(ref_circ_list[i].compose(variational_form))

weights = np.linspace(1, 0.3, weights_count)
params0 = np.random.uniform(0, 2 * np.pi, variational_form.num_parameters)
observable = SparsePauliOp.from_list([("XYZ", 1), ("XYX", -3), ("ZZI", 0.5)])
estimator = StatevectorEstimator()
```

```python
result = minimize(
    cost_func_ssvqe, params0, args=(weights,ansatzs, observable, estimator), method="COBYLA",
    options={"maxiter": 10000}
)
 
result
```

```python
eigenvalues = []
for i in range(len(weights)):
    new_weights = np.zeros(np.size(weights))
    new_weights[i] = 1.
    eigenvalues.append(cost_func_ssvqe(
    params=result.x, weights=new_weights, ansatzs=ansatzs, hamiltonian=observable, estimator=estimator
))
print(eigenvalues)
```

## 6.3 Variational Quantum Deflation (VQD)

VQD introduces the notion of a penalty cost to guide the optimization process.

$$
C_{k}(\vec \theta) := \langle \psi(\vec \theta)|\hat H_k|\psi(\vec \theta)\rangle
$$

where, $\hat H_k = \hat H_{k - 1} + \beta_{k - 1} |\psi(\vec \theta^{k - 1})\rangle\langle \psi(\vec \theta^{k - 1})\rangle$, $\hat H_0 = \hat H$, $\beta_{k - 1} < \lambda_{k} - \lambda_{k - 1}$.

Therefore, the form of this cost function: 

$$
\hat C_k(\vec \theta) = \langle \psi(\vec \theta)| \hat H_{k -1 }|\psi(\vec \theta)\rangle + \beta_{k - 1}|\langle \psi(\vec \theta)|\psi(\vec \theta^{k - 1})\rangle |^2 = \langle \psi(\vec \theta)|\hat H |\psi(\vec \theta)\rangle + \sum_{j = 0}^{k - 1} \beta_{j} |\langle\psi(\vec \theta)|\psi(\vec \theta^{j})\rangle|^2
$$
[^1]: The method to get the values of $\langle \psi|\psi^j\rangle$ is to measure $\langle \psi| U^j |0\rangle = \langle \psi'|0\rangle$, meaning product $|\psi'\rangle$ and measure the probability of $|0\rangle$.


```python
from qiskit.circuit.library import TwoLocal
 
ansatz = TwoLocal(2, rotation_blocks=["ry", "rz"], entanglement_blocks="cz", reps=1)
 
ansatz.decompose().draw("mpl")
```

```python
import numpy as np
 
 
def calculate_overlaps(ansatz, prev_circuits, parameters, sampler):
    def create_fidelity_circuit(circuit_1, circuit_2):
        """
        Constructs the list of fidelity circuits to be evaluated.
        These circuits represent the state overlap between pairs of input circuits,
        and their construction depends on the fidelity method implementations.
        """
 
        if len(circuit_1.clbits) > 0:
            circuit_1.remove_final_measurements()
        if len(circuit_2.clbits) > 0:
            circuit_2.remove_final_measurements()
 
        circuit = circuit_1.compose(circuit_2.inverse())
        circuit.measure_all()
        return circuit
 
    overlaps = []
 
    for prev_circuit in prev_circuits:
        fidelity_circuit = create_fidelity_circuit(ansatz, prev_circuit)
        sampler_job = sampler.run([(fidelity_circuit, parameters)])
        meas_data = sampler_job.result()[0].data.meas
 
        counts_0 = meas_data.get_int_counts().get(0, 0)
        shots = meas_data.num_shots
        overlap = counts_0 / shots
        overlaps.append(overlap)
 
    return np.array(overlaps)
```

```python
def cost_func_vqd(
    parameters, ansatz, prev_states, step, betas, estimator, sampler, hamiltonian
):
    estimator_job = estimator.run([(ansatz, hamiltonian, [parameters])])
 
    total_cost = 0
 
    if step > 1:
        overlaps = calculate_overlaps(ansatz, prev_states, parameters, sampler)
        total_cost = np.sum(
            [np.real(betas[state] * overlap) for state, overlap in enumerate(overlaps)]
        )
 
    estimator_result = estimator_job.result()[0]
 
    value = estimator_result.data.evs[0] + total_cost
 
    return value
```

```python
from qiskit.primitives import StatevectorEstimator as Estimator
from qiskit.primitives import StatevectorSampler as Sampler
 
sampler = Sampler()
estimator = Estimator()
```

```python
from qiskit.quantum_info import SparsePauliOp
 
observable = SparsePauliOp.from_list([("II", 2), ("XX", -2), ("YY", 3), ("ZZ", -3)])
```

```python
k = 3
betas = [33, 33, 33]
x0 = np.zeros(8)
```

```python
from scipy.optimize import minimize
 
prev_states = []
prev_opt_parameters = []
eigenvalues = []
 
for step in range(1, k + 1):
    if step > 1:
        prev_states.append(ansatz.assign_parameters(prev_opt_parameters))
 
    result = minimize(
        cost_func_vqd,
        x0,
        args=(ansatz, prev_states, step, betas, estimator, sampler, observable),
        method="COBYLA",
        options={
            "maxiter": 200,
        },
    )
    print(result)
 
    prev_opt_parameters = result.x # product quantum state.
    eigenvalues.append(result.fun)
    print(eigenvalues)
```
