## 1.1 Simplified hybrid workflow

1. **Initialize problem**: Variational algorithms start by initializing the quantum computer in a default state $|0\rangle$, then transforming it to some desired (**non-parametrized**) state $|\rho\rangle$, for instance: ^1
$$
|\rho\rangle = U_R|0\rangle
$$
2. **Prepare ansatz**:  Ansatze will ultimately take the form of parametrized quantum circuits capable of taking the default state $|0\rangle$ to the target state $|\psi(\vec \theta)\rangle$. ^2
$$
|\psi(\vec \theta)\rangle = \hat U_V(\vec \theta) |\rho\rangle = \hat U_V(\vec \theta)\hat U_R|0\rangle = \hat U_A(\vec \theta)|0\rangle\tag{1}
$$
3. **Evaluate cost function**: We can encode our problem into a  cost function  $C(\vec \theta)$ as a linear combination of Pauli operators. ^3
$$
C(\vec \theta) := \min\langle\psi(\vec \theta)|\hat{\mathcal{H}}|\psi(\vec \theta)\rangle \tag{2}
$$
4. **Optimize parameters**: Iterate the values of $\vec \theta$ using classical optimization algorithms.
5. **Adjust ansatz parameters with results, and re-run**:
$$
|\psi(\vec \theta^*)\rangle = \hat U_A(\vec \theta^*)|0\rangle
$$

## 1.2 Variational theorem

According to *lagrangian multiplier method*,
$$
\delta(\frac{\bar{\mathcal{H}}}{\langle\psi(\vec \theta)|\psi(\vec \theta)\rangle}) = 0
$$
Let $\hat{\mathcal{H}} = \frac{\bar{\mathcal{H}}}{\langle\psi(\vec \theta)|\psi(\vec \theta)\rangle}$ In the $\vec \theta$ room, the variational relationship transforms into a differential relationship.
$$
\frac{\partial\bar{\mathcal{H}}(\vec\theta)}{\partial\vec\theta}=0
$$
Such that: 
$$
C(\vec \theta) := \min\langle\psi(\vec \theta)|\hat{\mathcal{H}}|\psi(\vec \theta)\rangle
$$
let $\lambda_0$ is the ground energy.
$$
C(\vec \theta) = \langle \psi(\vec \theta)|\sum_k \lambda_k |k\rangle \langle k|\psi(\vec\theta)\rangle = \sum_k\lambda_k p_k \ge \lambda_0
$$
where $|\psi(\vec \theta^*)\rangle \approx |\psi_0\rangle$

If when $\delta\overline{\mathcal{H}} = 0$ , corresponding $\langle \psi(\vec \theta^*)|\hat{\mathcal{H}}|\psi(\vec \theta^*)\rangle$  takes the minimum value, viz., 
$$
C(\vec\theta) = \langle \psi(\vec \theta^*)|\hat{\mathcal{H}}|\psi(\vec \theta^*)\rangle
$$

[^1]: Also, note that if finite upper bounds exist, the same mathematical arguments could be made for maximizing eigenvalues by swapping lower bounds for upper bounds. **What mean the zero point of variation could be a max value**.