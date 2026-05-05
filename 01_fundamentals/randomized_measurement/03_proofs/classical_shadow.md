# classical shadow

## single qubit random gate

^1624d1

### single-bit import

<span style="color:red">key point: There is no need to mark m for the actual state ρ because what remains constant in your perspective is the state, and what changes is the measurement direction / measurement settings.</span>

$$
\left\{
\begin{aligned}
\hat o
&= \frac{1}{M}\sum_{m=1}^{M}
   \operatorname{tr}\!\left(\hat O \hat \rho^{(m)}\right) \quad where,
\\[0.8em]
\hat \rho^{(m)}
&= \frac{1}{K}
   \bigotimes_{n=1}^{N}
   \left(
   3\left(
   U_n^{(m)}
   |s_n^{(m,k)}\rangle
   \langle s_n^{(m,k)}|
   U_n^{(m\dagger)}
   - \hat I
   \right)
   \right).
\end{aligned}
\right.
$$

$$
\text{Target: }\mathbb E_{U, s}(\widetilde o)=tr(\hat O \hat\rho).  
$$

Let:

$$
\widetilde o =
 \operatorname{tr}\bigl(\hat O\widetilde{\hat\rho}(U^m, s^k)\bigr).  
$$

<span style="color:purple">Subsequent omission marker m and k</span>, sufficient and necessary condition is

$$
\mathbb E_{U, s} [\overline{\widetilde{\hat \rho}(U^m, s^k)}] = \mathbb E_{U, s} \bigl(\widetilde{\hat\rho}^{(U, s)}\bigr)=\hat\rho.  
$$

==Where $U_i$ are independent but $s_i$ are not, they only independent when $U_i$ are same.==

Here $\widetilde{\hat\rho}^{(U, s)}$ is a random estimation operator. (<span style="color:purple">Subsequent omission marker U and s</span>)

$$
\widetilde{\hat \rho}:= 3U_n^{\dagger}|s_n^{(U,s),z}\rangle\langle s_n^{(U,s),z}|U_n - \hat I.  
$$

 Let the single-qubit state $\hat\rho$ have Bloch vector $\vec r$ **(which could be a mixed state and $|\vec r| \le 1$)**, and let the measurement direction be $\vec n$ (randomized). Then

$$
\begin{cases}  
\hat \rho = \dfrac{1}{2}\bigl(\hat I + \vec r \cdot \vec{\hat \sigma}\bigr)\\  
\hat P_{\pm} = \dfrac{1}{2}\bigl(\hat I \pm \vec n \cdot \vec{\hat \sigma}\bigr),
\end{cases}
$$

therefore

$$
\mathbb E_{U,s}\bigr[\widetilde\rho\bigr] = \mathbb E_U \bigr[\sum_{s} P(s|U) \widetilde \rho(s)\bigr ] = \mathbb E_U[\sum_{\pm} tr(P_\pm \rho)\widetilde \rho(\pm)]
$$

 A direct calculation gives (ref  [[cs_single_bit_average_s]])

$$
\mathbb E_{U, s}\bigl(\widetilde{\hat \rho}\bigr)=\hat \rho.  
$$

QED.

### general situation

Target

$$
\mathbb E_{U, s}[\widetilde{\rho}(U, s)] = \rho.
$$
Definite

$$
R \in \bigr(\frac{1}{\sqrt 2}\{X, Y, Z, I\}\bigr)^{\otimes N}.
$$

<span style="color:purple">Subsequent omission marker U and s</span>, therefore

$$
\begin{aligned}
&\mathbb E_{U}[\sum\limits_s tr(P\rho) \widetilde \rho]\\
&= \mathbb E_{U} [\sum_s tr(P\sum_R tr(R\rho)R) \widetilde \rho]\\
&= \sum_R tr(R\rho) \mathbb E_U [\sum_s tr(PR)\widetilde \rho]\\
&= \sum_R tr(R\rho) \mathbb E_U [\sum_s tr(\bigotimes\limits_{n=1}^N P_nR_n)\bigotimes\limits_{i=1}^N \widetilde \rho_i]\\
&= \sum_R tr(R\rho) \mathbb E_U [\sum_s \prod\limits_{n = 1}^N tr(P_nR_n) \bigotimes\limits_{i=1}^N \widetilde \rho_i]]\\
&= \sum_R tr(R\rho) \mathbb E_U [\sum_s  \bigotimes\limits_{n=1}^N  tr(P_nR_n) \widetilde \rho_n]] \\
&= \sum_R tr(R\rho) \mathbb E_U [\sum_{s_1,...,s_N} \bigotimes_{n=1}^N tr(P_n R_n) \widetilde \rho_n],
\end{aligned}
$$

this relationship was established from the very beginning, summing an unconstrained vector is equivalent to summing the coordinates of all points in the vector's space.

$$
\sum\limits_{s \in \{0, 1\}^N} f(\vec s)= \sum\limits_{s_1\in \{0, 1\}}\sum\limits_{s_2 \in \{0, 1\}}...\sum\limits_{s_N \in \{0, 1\}} f(s_1, s_2, ... s_N)
$$

since $U_i$ are independent.

$$
\begin{aligned}
expr &=\sum_R tr(R\rho) \mathbb E_U [\sum_{s_1,...,s_N} \bigotimes_{n=1}^N tr(P_n R_n) \widetilde \rho_n]\\
&= \sum_R tr(R\rho) \mathbb E_U [\bigotimes_{n=1}^N \sum_{s_n}  tr(P_n R_n) \widetilde \rho_n]\\\\
&= \sum_R tr(R\rho) \bigotimes_{n=1}^N \mathbb E_{U_n}[\sum_{s_n} tr(P_nR_n)\widetilde \rho_n]
\end{aligned}
$$

According to the relationship when there are only one qubit

$$
\hat \rho = \mathbb E_{U, s} [\widetilde{\hat \rho}] = \mathbb E_{U} [\sum_{s} tr(\hat P(U. s) \hat \rho)  \widetilde{\hat \rho}],
$$

extend to any operator of single bit(ref to [[cs_extend_multiple_bits_to_operator]])

$$
\hat A = \mathbb E_{U} [\sum_{s} tr(\hat P(U, s) \hat A)(3 \hat P(U, s) - \hat I)],
$$

therefore

$$
expr = \sum_R tr(R\rho) \bigotimes_{n=1}^N R_n = \sum_R tr(R\rho) R = \rho.
$$

QED.

### (the trace of) polynomials of the density matrix

^16f9f8

$$
\hat P_2 = \frac{1}{M(M-1)}\sum\limits_{m\neq m'} tr(\hat \rho^{(m)}\hat \rho^{(m')})
$$

Which could be easily derived from (1) and (2), known the form of purity

$$
p_2 = tr(\hat \rho^2).
$$

Define the corresponding estimator

$$
\widetilde p_2 = tr(\widetilde{\hat \rho}(U^m, s^k)\widetilde{\hat \rho}(U^{m'}, s^{k'})),
$$

since $\widetilde {\hat \rho}^{(m, k)}$ is independent with  $\widetilde {\hat \rho}^{(m', k')}$($m \neq m'$),

$$
\begin{aligned}
&\mathbb E_{U,U',s, s'}[\overline{\widetilde p_2^{m,m',k,k'}}] \\
&= \mathbb E_{U,U',s, s'}[\widetilde p_2(U, U', s, s')] \\
&= tr(\mathbb E_{U,U',s, s'} [\widetilde{\hat \rho}(U, s)\widetilde{\hat \rho}(U', s')]) \\
&= tr(\mathbb E_{U,s} [\widetilde{\hat \rho}(U, s)]\mathbb E_{U', s'}[\widetilde{\hat \rho}(U', s')]) \\
&= tr(\rho^2)
\end{aligned}
$$

therefore

$$
\mathbb E_{U,U',s,s'}[\widetilde{p}_2] = p_2
$$

QED.

## Local U gates of multiple qubits

^6dc453

There are

$$
\begin{aligned}
&\mathbb E_{U}[\sum\limits_s tr(P\rho) \widetilde \rho]\\
&= \sum_R tr(R\rho) \bigotimes_{n=1}^N \mathbb E_{U_n}[\sum_{s_n} tr(P_nR_n)\widetilde \rho_n]
\end{aligned}
$$

Where $P_n$, $R_n$, $\widetilde \rho_n$ are the operators of subsystem(N>1).

Ref to [[cs_pair_U_random_gates]], the reflection channel is restricted, which in turn limits the expression of physical quantities.