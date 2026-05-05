For this Hamiltonian:

$$
\hat O = 2II - 2XX + 2YY - 3ZZ
$$
```python
from qiskit.quantum_info import SparsePauliOp
 
observable_1 = SparsePauliOp.from_list([("II", 2), ("XX", -2), ("YY", 3), ("ZZ", -3)])
```

## 7.1 Custom VQE

* Add reference state
* Change the initial point
* Experimenting with different optimizers

## 7.2 VQD example

* Change betas: ensuring they are bigger than the difference between eigenvalues.
* Calculate the eigenvalue follow the order.

## 7.3 Quantum chemistry: ground state and excited energy solver
## 7.4 Optimization: Max-Cut

* Measure to get the max probabilities result, to be targeted bit strings.
[^1]: In fact, the Optimal solution could be multiple.