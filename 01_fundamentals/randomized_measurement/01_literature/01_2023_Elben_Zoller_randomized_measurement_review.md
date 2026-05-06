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
\begin{split}
&o = \frac{1}{M} \sum_{m=1}^M tr\bigr(O\rho^{(m)}\bigr)\\
&\rho^{(m)} = \frac{1}{K} \bigotimes_{n=1}^N\bigr[3(U_n^{(m)}|s_n^{(m,k)}\rangle\langle s_n^{(m,k)}| U_n^{(m\dagger)} - I) \bigr]
\end{split}
\right.
$$

If the targeted operator is easy to breaken, the post-processing computational load can be significantly reduced.

Proof ref to [[Classical_Shadow#^1624d1]]

##### Classical Shadow Extend to Polynomials of the Density Matrix

$$
\hat P_2 = \frac{1}{M(M-1)}\sum\limits_{m\neq m'} tr(\hat \rho^{(m)}\hat \rho^{(m')})
$$

Since $\widetilde\rho$ is easy to breaken, the post-processing computational load can be significantly reduced.

Proof ref to [[Classical_Shadow#^16f9f8]]

#### Based on Hamming Distance

^97922d

$$
\hat P_2 = \frac{2^N}{MK(K-1)} \sum\limits_{m=1}^M\sum\limits_{k,k'=1;k\neq k'}^K (-2)^{-D[s^{(m, k)}, s^{(m, k')}]}
$$

Proof ref to [[Hamming_Core_Estimation]]

此方法天生带有局限性，从某种意义上一般无法达到不记录 U setting 的功能, ref to [[HCE_Limit_of_Hamming_Core]]

### Extended Unbiased Estimation Methods

#### Random U(2) of Multiple Qubits

2 比特系统可用于构建两两交换算符已知，ref to [[HCE_Limit_of_Hamming_Core]]

对于 2 比特以上系统的整体的 U(2) 随机变换, the reflection channel is restricted by the form of the operator. Ref to [[Classical_Shadow#^6dc453]] and [[Hamming_Core_Estimation#^b54c3a]]. I think they are not useful.

### Error Bounds 

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

### Cases

#### Basic solution of S^2 Operation

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

The proof ref to [[S_2_Operation]]

The proof could extend to more general angle of $R_X$, ref to [[S2O_the_Expend_of_R_Delta]]

####  Reflection Invariant

^12e242

$$
\begin{split}
\widetilde Z_R = \frac{Z_R}{\sqrt{\bigr [tr(\rho_1^2)+tr(\rho_2^2)\bigr ]/2}}\\
where \quad Z_R = tr(R_I\rho),
\end{split}
$$

* Classical shadow, which is a mechanical quantity and easy to use [[Classical_Shadow]]; If we deliberately forming the space order, the numerical calculation is easy to simplify [[Reflection_Invariant#^2b4427]].
* Based on Hamming Distance, **whose U transform is not independent between those qubits**. ref to [[Reflection_Invariant#^45a4ea]].

**In conclusion $R_I$ is a SWAP operation of $\rho$**, ref to [[HCE_Limit_of_Hamming_Core#^d0f2c8]].

#### Time Reversal Symmetry

$$
\begin{cases}
\widetilde Z_T =\frac{Z_T}{\bigr ({\bigr [tr(\rho_1^2)+tr(\rho_2^2)\bigr ]/2}\bigr )^\frac{3}{2}}\\
where \quad Z_T = tr(\rho u_T\rho^{T_1}u_T^\dagger)
\end{cases},
$$

* Classical shadow, Base on $T_1$ is a kind of linear mapping, the classical shadow is still vaild, ref to [[Time_Reversal]].