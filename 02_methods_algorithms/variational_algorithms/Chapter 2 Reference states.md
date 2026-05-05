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

According to Chapter 1, ![[Chapter 1 Variational algorithms#^1]]
In this lesson, we will explore how we can initialize our system with a **reference state to help our variational algorithm converge faster** and **affects the quality of the solution**. 
[^1]: In the fact, Its function is not only to enhance the convergence speed, but also to **Problem-specific encoding**. In applications such as quantum machine learning, the reference state can be used to encode training data, as shown in *zz_feature_map*.

## 2.1 Default state

Let $\rho\rangle = |000\rangle$, 
$$
\hat U_R = \hat I
$$

## 2.2 Classical reference state

classical state, such as $|01010...\rangle$, for instance:
$$
\begin{cases}
\hat U_R = \hat X_0\\
|\rho\rangle = |001\rangle
\end{cases}
$$

## 2.3 Quantum reference state
### 2.3.1 bell state


Aim to start with a more complex state,
$$
\begin{cases}
\hat U_R = X_2CNOT_{01}X_0\\
|\rho\rangle = \sqrt{\frac{1}{2}}(|100\rangle + |111\rangle)
\end{cases}
$$

### 2.3.2 template circuits

* TwoLocal gate 
```python
from qiskit.circuit.library import TwoLocal
import numpy as np
from IPython.display import display
 
ansatz = TwoLocal(
    num_qubits=5,
    rotation_blocks=["rx", "rz"],
    entanglement_blocks="cx",
    entanglement="linear",
    reps=2,
    insert_barriers=True,
)
ansatz.decompose().draw("mpl")

# get parameters number
actual_params = list(ansatz.parameters)
print("实际参数:", [p.name for p in actual_params])
```
```python
# 2. 使用实际参数进行绑定
param_mapping = {
    actual_params[i]: np.pi/2 for i in range(len(actual_params))
}
circ = ansatz.assign_parameters(param_mapping).decompose()
display(circ.draw("mpl"))
```
### 2.3.3 Quantum machine learning

Aim to **feature map the input dataset to the parms of the parameters of initialize circuit** to form the reference state, the `zz_feature_map` is a type of parameterized circuit that can be utilized to pass our data points (x) to this feature map.

```python
from qiskit.circuit.library import zz_feature_map
 
data = [0.5, 0.6, 0.7, 0.8]
 
zz_feature_map_reference = zz_feature_map(feature_dimension=len(data), reps=2, insert_barriers=True) # the dim of data and the mapping depth.
zz_feature_map_reference = zz_feature_map_reference.assign_parameters(data)
zz_feature_map_reference.decompose().draw("mpl")
```
[^2]: Unlike  Ansaetze, the initialize circuit  here are unsupervised and once determined, they remain fixed feature relationship from primal data and initialize parameters.

