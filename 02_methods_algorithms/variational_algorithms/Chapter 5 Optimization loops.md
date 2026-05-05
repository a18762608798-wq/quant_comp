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

## 5.1 local and global optimizers

### 5.1.1 local optimizers

#### 5.1.1.1 SLSQP

This implies that the convergence of these algorithms will usually be **fast**, but can be  be especially vulnerable to **local minima**.

```python
from qiskit import QuantumCircuit
from qiskit.quantum_info import SparsePauliOp
from qiskit.circuit.library import TwoLocal
import numpy as np
from scipy import stats
 
low = 0
high = 2 * np.pi
theta_list = stats.uniform.rvs(loc=low, scale=high-low, size=(8,))
observable = SparsePauliOp.from_list([("XX", 1), ("YY", -3)])
 
reference_circuit = QuantumCircuit(2)
reference_circuit.x(0)
 
variational_form = TwoLocal(
    2,
    rotation_blocks=["rz", "ry"],
    entanglement_blocks="cx",
    entanglement="linear",
    reps=1,
)
ansatz = reference_circuit.compose(variational_form)
 
ansatz.decompose().draw()
```

```python
def cost_func_vqe(params, ansatz, hamiltonian, estimator):
    """Return estimate of energy from estimator
 
    Parameters:
        params (ndarray): Array of ansatz parameters
        ansatz (QuantumCircuit): Parameterized ansatz circuit
        hamiltonian (SparsePauliOp): Operator representation of Hamiltonian
        estimator (Estimator): Estimator primitive instance
 
    Returns:
        float: Energy estimate
    """
    pub = (ansatz, hamiltonian, params)
    cost = estimator.run([pub]).result()[0].data.evs
    return cost
```

```python
from qiskit.primitives import StatevectorEstimator
 
estimator = StatevectorEstimator()
```

```python
# SciPy minimizer routine
from scipy.optimize import minimize
 
x0 = np.ones(8)
 
result = minimize(
    cost_func_vqe, x0, args=(ansatz, observable, estimator), method="SLSQP",     
    options={
        'maxiter': 100,   
        'ftol': 1e-6,    
        'disp': True      
    }
)
 
result
```

#### 5.1.1.2 COBYLA

Gradient-free optimization algorithms do not require gradient information and can be useful in situations **where computing the gradient is difficult, expensive, or too noisy**.
[^1]: First, use a coarser mesh to probe the local lowest direction, and then **dynamically adjust** the mesh density based on the results: expand the exploration if the results are good, and shrink the mesh for a finer search if the results are poor.
[^2]: **Gradient-free optimization has no particular resistance to Barren Plateaus.**

```python
# SciPy minimizer routine
from scipy.optimize import minimize
 
x0 = np.ones(8)
 
result = minimize(
    cost_func_vqe, x0, args=(ansatz, observable, estimator), method="COBYLA"
)
 
result
```

### Global optimizers

Global optimizers evaluating it iteratively (that is, **at iteration i) over a set of parameter vectors** $\Theta_{i} := \vec \theta_{i, j}| j \in \mathcal{J}_{opt}^i$​ determined by the optimizer.  This makes them less susceptible to local minima and somewhat independent of initialization, but also significantly slower to converge to a proposed solution.

### bootstrapping optimization

Set the initial value for parameters $\vec \theta$ based on a prior optimization. meaning: 

$$
|\psi(\vec \theta_0)\rangle = \hat U_V(\vec \theta_0) |\rho\rangle
$$

$\hat U_V(\vec \theta_0)$ has same structure with latter iterative $\vec \theta$ circuit.


