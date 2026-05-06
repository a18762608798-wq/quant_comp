# Random U(2) of Multiple Qubits

## An Incorrect Ideas

^55aa46

> the core error: we damaged the form of the projection operator. We do not conduct an overall measurement.
> 这也是标准 hamming core 不同 shots 组成的 rho 只能在 shot 内部纠缠的体现。

### Controllable U

#### Classical Shadow

We consider the worst-case scenario: we just have a global U gate.

let $M = \mathscr M N$, where $N$ is the number of qubits, and $\mathscr M$ is the number of times each bit is set to 

$$
U^{(\mathscr m n)} = U^m
$$

The expr of classical shadow as follow,

$$
\begin{split}
&o = \frac{1}{M} \sum_{m=1}^M tr\bigr(O\rho^{(m)}\bigr)\quad where,\\
&\rho^{(m)} = \frac{1}{K} \bigotimes_{n=1}^N\bigr[3(U_n^{(m)}|s_n^{(m,k)}\rangle\langle s_n^{(m,k)}| U_n^{(m\dagger)} - I) \bigr].
\end{split}
$$

where

$$
m = \mathscr m n
$$

#### Hamming core method

If we could use classical shadow, the Hamming core method is not very meaningful.

### Uncontrollable U

#### Classical Shadow

We could get the info gnerally if the global gate is uncontrollable. So classical shadow method is invaild.

#### Hamming core

Since we could not control the gate, **we could not set common U gates to measure**, meaning

$$
K = 1
$$

Assuming the number of qubits in system is $2N$,  the hamming core is

$$
\widetilde{\mathcal P} = \prod\limits_{n=1}^N \varepsilon_{s_ns_n'}\quad \text{qubit n and n' are a pair}
$$

Ref to the sample average in [[01_2023_Elben_Zoller_randomized_measurement_review#^12e242]], let $K = 1$, renew hamming core. 

let $M = \mathscr M N$, where $2N$ is the number of qubits, and $\mathscr M$ is the number of settings groups of all pair. in one settings groups $\mathscr m$, the U gate of a pair(with oreder n) is $U^{(\mathscr m n)} = U^m$ , therefore the form of sample average of operator is

$$
o = \frac{1}{\mathscr M} \sum\limits_{\mathscr m=1}^{\mathscr M}  \prod\limits_{n=1}^N \varepsilon_{s_{\mathscr m n}s_{\mathscr m n}'}
$$

Where o is the unbiased estimation of $tr(O \rho)$, 

$$
O = \bigotimes\limits_{n=1}^N O_n
$$

the size of $O_n$ is 2, and also has(ref to [[Hamming_Core_Estimation#^3108d5]])

$$
O_n = \frac{1}{2} (\varepsilon_{00} + \varepsilon_{01})I\otimes I + \frac{1}{6}(\varepsilon_{00} - \varepsilon_{01})\sum\limits_{\mu=1}^3 \sigma_\mu\otimes \sigma_\mu 
$$

## Main Body

### Controllable U

#### Classical Shadow

Ref to [[Classical_Shadow#^6dc453]], the reflection channel is restricted, which in turn limits the expression of physical quantities.

#### Hamming core

Similarly as Uncontrollable U but $K > 1$.

### Uncontrollable U

* Classical Shadow: No way evidently
* Hamming core: Ref to [[Hamming_Core_Estimation#^b54c3a]], subject to severe restrictions on physical quantities and $K = 1$
