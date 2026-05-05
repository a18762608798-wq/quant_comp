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
   \operatorname{tr}\!\left(\hat O \hat \rho^{(m)}\right) \quad where,
\\[0.8em]
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
## general solution

^ddf915

The term of the odd order is zero, the term of the even order as follow.

$$
\mathbb E_{\vec n} [n_{\mu_{a_1}}n_{\mu_{a_2}}...]= \frac{1}{(2k+1)!!}\sum_{\text{pairing}} \delta_{\mu_{a_1}\mu_{a_2}}\delta_{\mu_{a_3}\mu_{a_4}}...
$$

For instance, the dim of subspace is 3, there are

$$
\begin{split}
\mathbb E_U[P_n(0)\otimes P_n(0)  \otimes P_n(0)] &= \frac{1}{8}\mathbb E_U[(I +  \sigma_n)\otimes(I +  \sigma_n)\otimes (I + \sigma_n)] \\
&=  \frac{1}{8} \mathbb E_U[III + I\sigma_n\sigma_n + \sigma_n I \sigma_n + \sigma_n\sigma_nI]\\
&= \frac{1}{8}[III + \frac{1}{3}\sum_{\mu=1}^3 (I\sigma_\mu\sigma_\mu + \sigma_\mu I \sigma_\mu + \sigma_\mu\sigma_\mu I)]
\end{split}
$$

the signs of the coefs satisfy,

|                          | 000 | 001 | 010 | 011 |
| ------------------------ | --- | --- | --- | --- |
| $I \sigma_\mu\sigma_\mu$ | 1   | -1  | -1  | 1   |
| $\sigma_\mu I\sigma_\mu$ | 1   | -1  | 1   | -1  |
| $\sigma_\mu\sigma_\mu I$ | 1   | 1   | -1  | -1  |

Evidently the coefs is $(-1)^q_{s_1,s_2,...} = (-1)^{\sum_{a\in q} s_a}$ , whose exponent equal the sum of the strings that are non-trivially hit by Pauli bases, where q is the set of positions on which the nontrivial Pauli operator acts.

Case: $(-1)^{12}_{s_1s_2s_3} = (-1)^{s_1+s_2}$

**The freedom is enough so we could let $\varepsilon_{ijk,...} = \varepsilon_{\neg i, \neg j, \neg k, ...}$, Viz.,**

$$
\begin{split}
&E_{U_n}\bigr[\sum_{s_1, s_2, s_3,...}  f_n(s_1, s_2, s_3, ...)P_1\otimes P_{2}\otimes P_{3}\otimes...]\bigr ] \\
&= 2\mathbb E_{U_i} \bigr[ \sum_{s_2, s_3, ...}\varepsilon_{0,s_2,s_3,...} P(0)\otimes P_{2}\otimes P_3\otimes...]\bigr]\\
&=   \frac{1}{2^{N_l-1}}(\sum_{s_2, s_{3}, ...}\varepsilon_{0,s_2,s_3,...})I^{\otimes N_l} + \frac{1}{2^{N_l-1}}[\sum_q \sum_{s_2, s_3, ...}\epsilon_{0, s_2, s_3,...}^q\varepsilon_{0,s_2,s_3,...}\Phi_q ]
\end{split}
$$

where(**this direct product form is a concise notation**.)

$$
\Phi_q = \mathbb E_{\vec n} \bigr[\bigotimes\limits_{a\in q}\sigma_n^{a} \bigr]\otimes I_{q^c} =\sum_{\mu_{a_1}\mu_{a_2}...} \mathbb E_{\vec n} [n_{\mu_{a_1}}n_{\mu_{a_2}}...](\sigma_{\mu_{a_1}}\otimes\sigma_{\mu_{a_2}}...) \otimes I_{q^c}
$$

Let $|S|=2k, k\in \mathbb N^+$, where 

$$
\mathbb E_{\vec n} [n_{\mu_{a_1}}n_{\mu_{a_2}}...]= \frac{1}{(2k+1)!!}\sum_{\text{pairing}} \delta_{\mu_{a_1}\mu_{a_2}}\delta_{\mu_{a_3}\mu_{a_4}}...
$$

where pairing  is a set of allocations for the positions in q. Each group consists of two elements, and the groups are identical to each other. For instance, if $k = 2$, the allocations are

$$
(1,2)(3,4)\quad(1,3)(2,4)\quad(1,4)(2,3)
$$

therefore

$$
\Phi_q = \frac{1}{(2k+1)!!}\sum_{\text{pairing}} \sum_{\mu_{a_1}\mu_{a_3}...}(\sigma_{\mu_{a_1}}^{\otimes 2} \otimes\sigma_{\mu_{a_3}}^{\otimes 2}...) \otimes I_{q^c}
$$
In conclusion

$$
\begin{split}
&E_{U_n}\bigr[\sum_{s_1, s_2, s_3,...}  f_n(s_1, s_2, s_3, ...)P_1\otimes P_{2}\otimes P_{3}\otimes...]\bigr ] \\
&=   \frac{1}{2^{N_l-1}}(\sum_{s_2, s_{3}, ...}\varepsilon_{0,s_2,s_3,...})I^{\otimes N_l} + \frac{1}{2^{N_l-1}}[\sum_q \sum_{s_2, s_3, ...}\epsilon_{0, s_2, s_3,...}^q\varepsilon_{0,s_2,s_3,...}\Phi_q ]
\end{split}
$$

Where

$$
\begin{cases}
\varepsilon_{s_1,s_2,s_3,...} = \varepsilon_{\neg s_1, \neg s_2, \neg s_3,...}\\
\epsilon_{0, s_2, s_3,...}^q = (-1)^{\sum_{a\in q}s_a}\\
\Phi_q = \frac{1}{(2k+1)!!}\sum_{\text{pairing}} \sum_{\mu_{a_1}\mu_{a_3}...}(\sigma_{\mu_{a_1}}^{\otimes 2} \otimes\sigma_{\mu_{a_3}}^{\otimes 2}...) \otimes I_{q^c}\\
q = S \subseteq \{1, 2, ..., N_{l}\}, \quad |S|=2k, \quad k\in \mathbb N^+
\end{cases}
$$

q is a set of positions on which the nontrivial Pauli operator acts.
Proof ref to [[classical_shadow#^16f9f8]]

In face, which could be seen as  SWAP operator expectation of $\rho \otimes \rho$, ref to [[Perspective_of_physical_quantities_of_expr_of_rho#^9c6063]]'

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