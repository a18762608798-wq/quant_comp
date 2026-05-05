# 2023_Elben_Zoller_randomized_measurement_review

## Description

It is not possible to use classical data to fully and succinctly characterize generic quantum systems of many strongly interacting particles. Fortunately, a far less complete description of the state is adequate for many purposes.

The advantage of random measurements lies not in the measurement of specific mechanical quantities, but in the construction of classical projections and the reuse of data. Especially suitable for measuring physical quantities of multiple local systems.

## Unbiased Estimation Theory

### Basic Unbiased Estimation Method

#### Based on Classical Shadow

##### Classical Shadow and Observation Quantify Estimator

$$
\left\{
\begin{aligned}
\hat o
&= \frac{1}{M}\sum_{m=1}^{M}
   \operatorname{tr}\!\left(\hat O \hat \rho^{(m)}\right) \quad where\\
\hat \rho^{(m)}
&= \frac{1}{K}\sum_{k=1}^K
   \bigotimes_{n=1}^{N}
   \left(
   3\left(
   U_n^{(m)}
   |s_n^{(m,k)}\rangle
   \langle s_n^{(m,k)}|
   U_n^{(m)\dagger}
   - \hat I
   \right)
   \right).
\end{aligned}
\right.
$$

If the targeted operator is easy to breaken, the post-processing computational load can be significantly reduced.

Proof ref to [[classical_shadow#^1624d1]]

##### Classical Shadow Extend to Polynomials of the Density Matrix

$$
\hat P_2 = \frac{1}{M(M-1)}\sum\limits_{m\neq m'} tr(\hat \rho^{(m)}\hat \rho^{(m')})
$$

$\widetilde\rho$ is easy to breaken, the post-processing computational load can be significantly reduced.

#### Based on Hamming Distance

^97922d

$$
\hat P_2 = \frac{2^N}{MK(K-1)} \sum\limits_{m=1}^M\sum\limits_{k,k'=1;k\neq k'}^K (-2)^{-D[s^{(m, k)}, s^{(m, k')}]}
$$

Proof ref to [[Hamming_core_estimation]]. 

<span style="color:red">I think the Hamming core come from the local global gate in N_l qubits system or its equivalent</span>. ref to [[Perspective_of_physical_quantities_of_expr_of_rho]]

Which could extend to any operators which satisfy limitations, ref to [[Hamming_core_estimation#^f7a70a]]

### Extended Unbiased Estimation Methods

#### Local U Gate of N_l Qubits

The reflection channel is restricted by the form of the operator. Ref to [[classical_shadow#^6dc453]] and [[Hamming_core_estimation#^b54c3a]]. I think they are not useful.

### error bounds 

The special case of Pauli expectation values, an improved scaling of M  

$$
M \propto \log(L)3^\omega/\epsilon^2
$$

For the general expectation values of operation, the M is 

$$
M \propto \log(L)4^\omega/\epsilon^2
$$

Where L is the quantity of operation, $\omega$ is the scale of sub-system, $\epsilon$ is the accuracy requirements.

<span style="color:red">I will give the proof in the future, may be...</span>

Some possible relevant evidence [[classical error]]

### cases

#### basic solution of S^2 operation

The system only requires local Z-rotations, while the ions were rotated along the X-axis via a global beam.

Operation to every qubit

$$
R_Z(\varphi_n)R_X(\frac{\pi}{2})R_Z(\theta_n)R_X(-\frac{\pi}{2}) = R_Z(\varphi_n)R_Y(\theta_n).
$$

Where

$$
\text{uniform}\begin{cases}
\cos\theta_n \in [-1, 1]\\
\varphi_n \in [0,2\pi] 
\end{cases}
$$

The proof ref to [[overall_gates_operation]]

The proof could extend to more general angle of $R_X$, ref to [[ogo_the_expend_of_R_delta]]

####  reflection invariant

^12e242

$$
\begin{split}
\widetilde Z_R = \frac{Z_R}{\sqrt{\bigr [tr(\rho_1^2)+tr(\rho_2^2)\bigr ]/2}}\\
where \quad Z_R = tr(R_I\rho),
\end{split}
$$

* Classical shadow, which is a mechanical quantity and easy to use [[classical_shadow]]; If we deliberately forming the space order, the numerical calculation is easy to simplify [[reflection_invariant#^2b4427]].
* Based on Hamming Distance, **whose U transform is not independent between those qubits**. ref to [[reflection_invariant#^45a4ea]].

**In conclusion $R_I$ is a SWAP operation of $\rho$**, ref to [[Perspective_of_physical_quantities_of_expr_of_rho#^d0f2c8]].

#### time reversal symmetry

$$
\begin{cases}
\widetilde Z_T =\frac{Z_T}{\bigr ({\bigr [tr(\rho_1^2)+tr(\rho_2^2)\bigr ]/2}\bigr )^\frac{3}{2}}\\
where \quad Z_T = tr(\rho u_T\rho^{T_1}u_T^\dagger)
\end{cases},
$$

* Classical shadow, Base on $T_1$ is a kind of linear mapping, the classical shadow is still vaild, ref to [[time_reversal]].