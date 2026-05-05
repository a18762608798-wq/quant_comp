---
jupyter:
  jupytext:
    cell_metadata_filter: -all
    formats: ipynb,md
    text_representation:
      extension: .md
      format_name: markdown
      format_version: '1.3'
      jupytext_version: 1.18.1
  kernelspec:
    display_name: Python 3
    language: python
    name: python3
---

According to Chapter 1, ![[Chapter 1 Variational algorithms#^2]]
we'll construct our ansatz by applying this variational form to our reference state, viz., construct 
$\hat U_V(\vec \theta)$; 
[^1]: We refer to the combination of these two halves as an ansatz: $\hat U_V(\vec \theta)\hat U_R = \hat U_A​$, but they are two separated part continuous function in circuit.
[^2]: There dimensionality of n-quant system is $2^{2n}$, meaning the complexity of  **traversing** the target state $|\psi(\vec \theta)\rangle$ during the optimization process is too tough. To counter this setback, it is common practice to impose some **reasonable constraints on the variational form**(Mainly the form of the restricted state and restrict our circuit search space to a specific type, The specific parameter path still depends on the classic optimization algorithms.) such that **only the most relevant states are explored**.

## 3.1 Parameterized Quantum Circuits

the class: `Parameter` could build circuit without binging parameter gate.

```python
from qiskit.circuit import QuantumCircuit, Parameter
theta = Parameter("θ") # define a param var.
 
param_circ = QuantumCircuit(3)
param_circ.rx(theta, 0)
param_circ.cx(0, 1)
param_circ.x(2)
 
param_circ.draw("mpl")
```
```python
import numpy as np
from IPython.display import display
circ = param_circ.assign_parameters({theta: np.pi/2}) # assign a value to the parameter
circ.draw("mpl")

```


## 3.2 Heuristic ansaetze and trade-offs

If you do not have any information about your particular problem that can help restrict the dimensionality, you can try an arbitrary family of parameterized circuits with fewer than $2^{2n}$ parameters. However, reducing the space could risk excluding the actual solution to the problem, leading to suboptimal solutions. 

### 3.2.1 N-local circuits

Definition: These circuits consist of *rotation and entanglement layers* that are repeated alternatively one or more times; Each layer is formed by **gates of size at most N**.
[^3]: Optionally(Always), an extra rotation layer is added to the end of the circuit.
Advantage: it is easy to be achieved and could captures important correlations...

#### 3.2.1.1 TwoLocal

refer to chapter 2.

#### 3.2.1.2 NLocal

```python
from qiskit.circuit.library import NLocal, CCXGate, CRZGate, RXGate
from qiskit.circuit import Parameter
import numpy as np
 
theta = Parameter("θ")
ansatz = NLocal(
    num_qubits=5,
    rotation_blocks=[RXGate(theta), CRZGate(theta)], # Specify gates each column.
    entanglement_blocks=CCXGate(),
    entanglement=[[0, 1, 2], [0, 2, 3], [4, 2, 1], [3, 1, 0]],
    reps=2,
    insert_barriers=True,
)
param_circ = ansatz.decompose()
param_circ.decompose().draw("mpl")

# get parameters number
actual_params = list(ansatz.parameters)
print("实际参数:", [p.name for p in actual_params])
```
```python
from IPython.display import display
# 2. 使用实际参数进行绑定
param_mapping = {
    actual_params[i]: np.pi/2 for i in range(len(actual_params))
}
circ = ansatz.assign_parameters(param_mapping).decompose()
display(circ.draw("mpl"))
```

[^3]: I want to observe the parameterized vector of psi, but Aer could not process circuit with parameters. 

### 3.2.2 Problem-specific ansaetze

#### 3.2.2.1 Optimization

* max-cut problem

#### 3.2.2.2 Quantum Machine Learning

Series combination zz_feature_map and NLocal circuit.

```python
from qiskit.circuit.library import zz_feature_map, TwoLocal
 
data = [0.1, 0.2]
 
zz_feature_map_reference = zz_feature_map(feature_dimension=2, reps=2)
zz_feature_map_reference = zz_feature_map_reference.assign_parameters(data)
 
variation_form = TwoLocal(2, ["ry", "rz"], "cz", reps=2)
vqc_ansatz = zz_feature_map_reference.compose(variation_form) # Series combination
vqc_ansatz.decompose().draw("mpl")
```


