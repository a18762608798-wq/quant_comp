---
jupyter:
  jupytext:
    cell_metadata_filter: -all
    formats: ipynb,md
    text_representation:
      extension: .md
      format_name: markdown
      format_version: '1.3'
      jupytext_version: 1.19.0
  kernelspec:
    display_name: Python 3
    language: python
    name: python3
---

we'll learn about *Qiskit Runtime primitives* and define a "cost function"-a problem-specific function that defines the problem's goal for the optimizer to minimize (or maximize).
![[Chapter 1 Variational algorithms#^3]]

## 4.1 Primitives

* `Sampler`: Give a quatum state $\psi$, then obtains the probability of **each possible computational basis** state. 
* `Estimator`: Give a a quantum observable $\hat H$ and a state $\psi$, this primitive computes the **expected value** of $\hat H$.
[^1]: The computational basis usually refers to the standard basis spanned by |0⟩ and |1⟩. For instance $|k\rangle = |0100011\rangle$

### 4.1.1 Sampler

The Sampler does not rely on theoretical calculations but rather on **simulated measurement processes**. So it is only efficient *for sparse probability distributions*;
[^2]: The sparsity is to reduce the number of shots while maintaining accuracy. Classical algorithms can also utilize sparsity.
[^3]: High-dimensional cases, sampler can also be roughly estimated.

### 4.1.2 Estimator

**Experimentally**, The Estimator calculating the expectation value by breaking down the observable into a combination of other observables whose eigenbasis we do know **as the hardware could only be directed measured on a computational basis and we always do not know the U operation that transforms to the Pauli basis.**

<span style="color:red">However, StatevectorEstimator using the analytical method but with experimental input...</span>, such that when using the eigenvalue estimator, **we only need the original reference circuit.**

Give a a quantum observable $\hat H$ and a state $\psi$, assume $\hat H = \sum_{k=0}^{4^n - 1} \omega_k \hat P_k$

$$
\langle\hat H\rangle_{\psi} = \sum_{k=0}^{4^n - 1} \omega_k \sum_{j=0}^{2^n} p_{kj}\lambda_{kj}
$$
where 
* n is the number of bits,
* $\langle \hat P_k\rangle = \sum_{j=0}^{2^n}p_{kj}\lambda_{kj}$, $\hat P_k$ is a Pauli basis.
* $k_l \in \{0, 1, 2, 3\}$,
* $\{\sigma_0, \sigma_1, \sigma_2, \sigma_3\} := \{I, X, Y, Z\}$.
[^4]: the dim of matrix basis is $N^2$ and  the dim of $\hat H$ is $2^n$, therefore the num of Pauli basis is $4^n$. Which Consistent with the composition of the Pauli basis.
[^5]: Similarly it is only efficient *for sparse distributions*.

For instance, $\langle +|\hat H|+\rangle = 2\langle +|\hat X|+\rangle - \langle +|\hat Z|+\rangle$

```python
from qiskit import QuantumCircuit
from qiskit.quantum_info import SparsePauliOp
from IPython.display import display
 
# The following code will work for any other initial single-qubit state and observable.
original_circuit = QuantumCircuit(1)
original_circuit.h(0) # product |+\rangle
 
H = SparsePauliOp(["X", "Z"], [2, -1]) # Express with pauil basis.
 
aux_circuits = [] # Rotational measurement of base vectors.
for pauli in H.paulis:
    aux_circ = original_circuit.copy()
    aux_circ.barrier()
    if str(pauli) == "X":
        aux_circ.h(0)
    elif str(pauli) == "Y": # U^\dagger = S^\dagger \hat H^\dagger
        aux_circ.sdg(0) 
        aux_circ.h(0)
    else:
        aux_circ.id(0)
    aux_circ.measure_all()
    aux_circuits.append(aux_circ)
 
original_circuit.draw("mpl")
```

the circuit of $X$ and $Z$

```python
# Auxiliary circuit for X
aux_circuits[0].draw()

```

```python
aux_circuits[1].draw()
```

We can now carry out the computation manually using `Sampler` and check the results on `Estimator`:

```python
from qiskit.primitives import StatevectorSampler, StatevectorEstimator
from qiskit.result import QuasiDistribution
import numpy as np
 
## SAMPLER
shots = 100000
sampler = StatevectorSampler()
job = sampler.run(aux_circuits, shots=shots) # use sampler
 
# Run the sampler job and step through results
expvals = []
for index, pauli in enumerate(H.paulis):
    data_pub = job.result()[index].data
    counts = data_pub.meas.get_counts() # a dict of counts of 0 and 1.
    quasi_dist = QuasiDistribution(
        {outcome: freq / shots for outcome, freq in counts.items()}
    )
 
    # Use the probabilities and **known eigenvalues** of Pauli operators to estimate the expectation value.
    val = 0
 
    if str(pauli) == "X":
        val += 1 * quasi_dist.get(0, 0)
        val += -1 * quasi_dist.get(1, 0)
 
    if str(pauli) == "Y":
        val += 1 * quasi_dist.get(0, 0)
        val += -1 * quasi_dist.get(1, 0)

    if str(pauli) == "Z":
        val += 1 * quasi_dist.get(0, 0)
        val += -1 * quasi_dist.get(1, 0)
 
    expvals.append(val)
 
# Print expectation values
 
print("Sampler results:")
for pauli, expval in zip(H.paulis, expvals):
    print(f"  >> Expected value of {str(pauli)}: {expval:.5f}")
 
total_expval = np.sum(H.coeffs * expvals).real
print(f"  >> Total expected value: {total_expval:.5f}")
 
# ----------
# Use estimator for comparison
observables = [
    *H.paulis,
    H,
]  # Note: run for individual Paulis as well as full observable H
 
estimator = StatevectorEstimator()
job = estimator.run([(original_circuit, observables)]) # estimator job
estimator_expvals = job.result()[0].data.evs
 
# Print results
print("Estimator results:")
for obs, expval in zip(observables, estimator_expvals): # a list composed of tuples.
    if obs is not H:
        print(f"  >> Expected value of {str(obs)}: {expval:.10f}")
    else:
        print(f"  >> Total expected value: {expval:.10f}")
```
## 4.2 Cost Function

### 4.2.1 Challenges

Notice how we will only be able to minimize the cost function for the limited set of states that we are considering. This leads us to two separate possibilities:

- Our ansatz does not define the solution state across the search space.
- Local optimal solution.

### 4.2.2 easy cases of twolocal gate

#### 4.2.2.1 classical simulation

```python
def cost_func_vqe(params, circuit, hamiltonian, estimator): # Variational Quantum Eigensolver
    """Return estimate of energy from estimator
    Parameters:
        params (ndarray): Array of ansatz parameters
        ansatz (QuantumCircuit): Parameterized ansatz circuit
        hamiltonian (SparsePauliOp): Operator representation of Hamiltonian
        estimator (Estimator): Estimator primitive instance
    Returns:
        float: Energy estimate
    """
    pub = (circuit, hamiltonian, params)
    cost = estimator.run([pub]).result()[0].data.evs
    return cost
```

```python
from qiskit.circuit.library import TwoLocal
 
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
 
theta_list = (2 * np.pi * np.random.rand(1, 8)).tolist()
ansatz.decompose().draw("mpl")
```

```python
estimator = StatevectorEstimator()
cost = cost_func_vqe(theta_list, ansatz, observable, estimator)
print(cost)
```

#### 4.2.2.2  real quantum computer computation

Isa format is not matched for quark studio, we will talk this question in the future.

### 4.2.3 Max-Cut question

#### 4.2.3.1 Classical form

```python
import rustworkx as rx
from rustworkx.visualization import mpl_draw
 
n = 4
G = rx.PyGraph()
G.add_nodes_from(range(n))
# The edge syntax is (start, end, weight)
edges = [(0, 1, 1.0), (0, 2, 1.0), (0, 3, 1.0), (1, 2, 1.0), (2, 3, 1.0)]
G.add_edges_from(edges)
 
mpl_draw(
    G, pos=rx.shell_layout(G), with_labels=True, edge_labels=str, node_color="#1192E8"
)
```

This problem can be expressed as a binary optimization problem. The classical cost function form:

$$
C(\vec \theta) = \sum_{i,j=0}^n w_{ij}x_i(1-x_j)
$$
where the value of $x_i$ depends on the set to which it belongs(0 or 1), $w_{ij}$ is the weight between $x_i$ and $x_j$

#### 4.2.3.2 quantum form

 The observables that Qiskit admits natively consist of Pauli operators, that have eigenvalues 1 and −1 instead of 0 and 1. 

$$
C(\vec \theta) = \sum_{i,j=0}^n w_{ij}\frac{1-z_i}{2}(1-\frac{1-z_i}{2}) = \sum_{i,j=0}\frac{w_{ij}}{4} - \sum_{i,j=0} \frac{w_{ij}}{4}z_iz_j
$$
**NOTICE:** $\omega_{ij}$ is a  symmetric matrix.

Therefore, 

$$
C(\vec \theta) = \frac{1}{2} \sum_{i = 0}^n \sum_{j = 0}^i \omega_{ij} - \frac{1}{2}\sum_{i = 0}^n \sum_{j = 0}^i w_{ij} z_i z_j 
$$

Moreover, the natural tendency of a quantum computer is to find minima (usually the lowest energy)

* case of classical query:

$$
\hat H = \frac{1}{2}(IIZZ + IZIZ + IZZI + ZIZI + ZZII) - \frac{5}{2} IIII
$$

```python
from qiskit.circuit.library import QAOAAnsatz
from qiskit.quantum_info import SparsePauliOp
from IPython.display import display
 
hamiltonian = SparsePauliOp.from_list(
    [("IIZZ", 1), ("IZIZ", 1), ("IZZI", 1), ("ZIIZ", 1), ("ZZII", 1)]
)

qaoa_layer = 4
ansatz = QAOAAnsatz(hamiltonian, reps=qaoa_layer) # Designing parametric variational circuits based on the Hamiltonian.
# Draw
# display(ansatz.decompose(reps=1).draw()) # decompose the circ to a more fundational form. t is a placeholder.

# Sum the weights, and divide by 2
 
offset = -sum(edge[2] for edge in edges) / 2
print(f"""Offset: {offset}""")
#ansatz.decompose(reps=1).draw()
```

cost function calculation

```python
from qiskit.primitives import StatevectorSampler, StatevectorEstimator
    
def cost_func_vqe(params, circuit, hamiltonian, estimator):
    """Return estimate of energy from estimator
 
    Parameters:
        params (ndarray): Array of ansatz parameters
        ansatz (QuantumCircuit): Parameterized ansatz circuit
        hamiltonian (SparsePauliOp): Operator representation of Hamiltonian
        estimator (Estimator): Estimator primitive instance
 
    Returns:
        float: Energy estimate
    """
    pub = (circuit, hamiltonian, params)
    cost = estimator.run([pub]).result()[0].data.evs
    return cost

def calculate_nega_cut(params, circuit, hamiltonian, estimator):
	h_m = cost_func_vqe(params, circuit, hamiltonian, estimator)
	nega_cut_cost = 1/2 * h_m + offset
	return nega_cut_cost
```
```python
# SciPy minimizer routine
from scipy.optimize import minimize
import numpy as np
 
x0 = 1/np.sqrt(qaoa_layer) * 2 * np.pi * np.random.rand(ansatz.num_parameters)
 
result = minimize(
    calculate_nega_cut, x0, args=(ansatz, hamiltonian, estimator), method="SLSQP",     
    options={
        'maxiter': 100,   
        'ftol': 1e-6,        
    }
)

max_cut_cost = -result.fun
print(max_cut_cost)
```

[^1]: Theoretically, the larger the number of layers, the smaller the parameter values should be for the best results.

## 4.3 Error

#### 4.3.1 Error Suppression

Error suppression refers to techniques used to **optimize and transform a circuit during compilation** in order to minimize errors.

- Expressing the circuit using the native gates available on a quantum system
- Mapping the virtual qubits to physical qubits
- Adding SWAPs based on connectivity requirements
- Optimizing 1Q and 2Q gates
- Adding dynamical decoupling to idle qubits to prevent the effects of decoherence.

```python
from qiskit.circuit import Parameter, QuantumCircuit
from qiskit.quantum_info import SparsePauliOp
 
theta = Parameter("theta")
 
qc = QuantumCircuit(2)
qc.x(1)
qc.h(0)
qc.cp(theta, 0, 1)
qc.h(0)
observables = SparsePauliOp.from_list([("ZZ", 1)])
 
qc.draw("mpl")
```

```python
## Setup phases
import numpy as np
 
phases = np.linspace(0, 2 * np.pi, 50)
 
# phases need to be expressed as a list of lists in order to work
individual_phases = [[phase] for phase in phases]
```

```python
from qiskit_ibm_runtime import QiskitRuntimeService
from qiskit_aer import AerSimulator
 
# get a real backend from the runtime service
service = QiskitRuntimeService()
backend = service.backend("ibm_fez")
 
# generate a simulator that mimics the real quantum system with the latest calibration results
backend_sim = AerSimulator.from_backend(backend)
```

```python
# Import estimator and specify that we are using the simulated backend:
 
from qiskit_ibm_runtime import EstimatorV2 as Estimator
 
estimator = Estimator(mode=backend_sim)
 
circuit = qc
```

```python
# Use a pass manager to transpile the circuit and observable for the backend being simulated.
# Start with no optimization:
 
from qiskit.transpiler.preset_passmanagers import generate_preset_pass_manager
 
pm = generate_preset_pass_manager(backend=backend_sim, optimization_level=0)
isa_circuit = pm.run(circuit)
isa_observables = observables.apply_layout(layout=isa_circuit.layout)
 
pub = (isa_circuit, isa_observables, [individual_phases])
cost = estimator.run([pub]).result()[0].data.evs
noisy_exp_values = cost[0]

# Repeat above steps, but now with optimization = 2:
pm = generate_preset_pass_manager(backend=backend_sim, optimization_level=2)
isa_circuit = pm.run(circuit)
isa_observables = observables.apply_layout(layout=isa_circuit.layout)
 
pub = (isa_circuit, isa_observables, [individual_phases])
cost = estimator.run([pub]).result()[0].data.evs
exp_values_with_opt_es2 = cost[0]
 
# Repeat above steps, but now with optimization = 3:
pm = generate_preset_pass_manager(backend=backend_sim, optimization_level=3)
isa_circuit = pm.run(circuit)
isa_observables = observables.apply_layout(layout=isa_circuit.layout)
 
pub = (isa_circuit, isa_observables, [individual_phases])
cost = estimator.run([pub]).result()[0].data.evs
exp_values_with_opt_es3 = cost[0]
```

```python
import matplotlib.pyplot as plt
 
plt.plot(phases, noisy_exp_values, "o", label="opt=0")
plt.plot(phases, exp_values_with_opt_es2, "o", label="opt=2")
plt.plot(phases, exp_values_with_opt_es3, "o", label="opt=3")
plt.plot(phases, 2 * np.sin(phases / 2) ** 2 - 1, label="ideal")
plt.ylabel("Expectation")
plt.legend()
plt.show()
```

[^2]: Simulator behavior: First optimize the circuit, then simulate execution using a hardware noise model.
## 4.4 Math theory

### 4.2.1 Hilbert-Schmidt内积

对于n维矩阵，可由n个矩阵规范正交完备矩阵构成，这玩意应该要点数学理论，但是我其实根本上是不完全清楚的。


* 正交要求：
 
$$
\langle A, B\rangle_{HS} = Tr(A^\dagger B) = 0
$$

* 规范要求范数：

$$
||P|| = \sqrt{Tr(P^\dagger P)} = \sqrt n
$$
* 完备性要求：

$$
\sum_i A_i\otimes A_i^\dagger = I_{HS}
$$
综上，假$\hat{\mathcal{H}}$ 是希尔伯特空间, $\{\hat B_i\}_{i=1}^{N^2}$ 是一组完备基矢，则有：

$$
\begin{cases}
\hat A = \sum_{i=1}^{N^2} Tr(\hat B^\dagger_i \hat A)\hat B_i\\
Tr(B^\dagger_iB_j) = \delta_{ij}
\end{cases}
$$

### 4.2.2 Theorem of Adiabatic Process

根据量子绝热定理，当哈密顿量随时间缓慢变化时，若系统初始处于某非简并本征态（通常是基态），则系统将始终保持在该哈密顿量的瞬时本征态上.
#### 4.2.2.1 Continuous adiabatic evolution

For the Hamiltonian of the form:

$$
\hat H(t) = (1-\frac{t}{T})\hat H_B + \frac{t}{T}\hat H_C
$$
where: 
* Initially, the system is the ground state of $\hat H_B$.
* $\hat H_C$ is the targeted Hamiltonian, $\hat H_B$ is the primal Hamiltonian, 
* when $\hat H(t)$ from $\hat H_B$ to $\hat H_C$, $T \rightarrow \infty$, 
**The system has been in the $\hat H(t)$ ground state, and will be in the ground state of $\hat H_C$ at the last.**

#### 4.2.2.2 Discrete adiabatic evolution

For $\hat H(t, 0)|\psi_B\rangle = |\psi_C\rangle$
$$
U(t, 0) = \prod_i^\infty e^{-i\Delta t_i \hat H(t)} \approx \prod_i^\infty e^{-i\Delta t_i (1-s_i)\hat H_B} e^{-i \Delta t_i s_i \hat H_C} = \prod_i^n e^{-i\hat H_B\beta_i}e^{-i\hat H_C\gamma_i}
$$
where $\Delta t \rightarrow 0$
<span style="color:red">NOTICE the error form if</span> $\hat H = \hat H_1 + \hat H_2$, <span style="color:red">which could be proof when it be extend to two order.</span>
$$
e^{-i\hat H t} \neq e^{-i\hat H_1 t\hbar} e^{-i\hat H_2 t/\hbar}
$$
[^2]: Of course, $e^{A + B} = e^{B + A}$, therefore, the order of the effects of $H_B$ and $H_C$ can theoretically be interchanged. which means the infinite small rotation is a vector.
[^3]: Therefore, the more effective method is to expend higher order(Zassenhaus).

