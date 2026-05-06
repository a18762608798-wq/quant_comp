# HCE Core Calculation

## SWAP

^09be31

Where

$$
\begin{cases}
A_{same} = \mathbb E_{U_n}[P_n(0)\otimes P_n(0)]\\
A_{diff} = \mathbb E_{U_n}[P_n(0)\otimes P_n(1)]\\
\end{cases},
$$

since 

$$
\begin{cases}
P_n(0)\otimes P_n(0) = \frac{1}{4}(I + \vec n\cdot \vec \sigma)\otimes(I + \vec n \cdot \vec \sigma) = \frac{1}{4}[I \otimes I+ I \otimes \sigma_n + \sigma_n \otimes I + \sigma_n \otimes \sigma_n] \\
P_n(0)\otimes P_n(1) = \frac{1}{4}[I\otimes I + I\otimes\sigma_n - \sigma_n \otimes I - \sigma_n \otimes \sigma_n],
\end{cases}
$$

evidently

$$
E_{U_n} [\sigma_n] = E_{U_n}[n_i] \sigma_i= 0,
$$

also

$$
E_{U_n}\bigr[(n_i[\sigma_i]^\alpha_\beta n_j[\sigma_j]^c_d)\bigr] = E_{U_n} [n_in_j] [\sigma_i\otimes\sigma_j]^{(\alpha, c)}_{\beta, d} = \frac{1}{3}\delta_{ij}[\sigma_i\otimes\sigma_j]^{(\alpha, c)}_{\beta, d}.
$$

Viz.,

$$
\begin{aligned}
&2A_{same} - A_{diff} \\
&= 2[\frac{1}{4}(I \otimes I + \frac{1}{3}\sum_{\mu=1}^3 \sigma_\mu \otimes \sigma_\mu)] - [\frac{1}{4}(I \otimes I - \frac{1}{3}\sum_{\mu=1}^3 \sigma_\mu \otimes \sigma_\mu)]\\
&= \frac{1}{4} [I\otimes I + \sum_{\mu=1}^3 \sigma_\mu \otimes \sigma_\mu]\\
&= \frac{1}{2}\sum_{R_\mu} R_\mu \otimes R_\mu
\end{aligned}.
$$

## General Solution

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
\end{split},
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
&= \frac{1}{2^{N_l-1}}(\sum_{s_2, s_{3}, ...}\varepsilon_{0,s_2,s_3,...})I^{\otimes N_l} + \frac{1}{2^{N_l-1}}[\sum_{s_2, s_3, ...}\varepsilon_{0,s_2,s_3,...}\sum_q \epsilon_{0, s_2, s_3,...}^q\Phi_q ]\\
&=   \frac{1}{2^{N_l-1}}(\sum_{s_2, s_{3}, ...}\varepsilon_{0,s_2,s_3,...})I^{\otimes N_l} + \frac{1}{2^{N_l-1}}[\sum_q \sum_{s_2, s_3, ...}\epsilon_{0, s_2, s_3,...}^q\varepsilon_{0,s_2,s_3,...}\Phi_q ]
\end{split}
$$

Where(**this direct product form is a concise notation**).

$$
\Phi_q = \mathbb {E}_{\vec n} \bigl[\bigotimes\limits_{a\in q}\sigma_n^{a} \bigl]\otimes I_{q^c} =\sum_{\mu_{a_1}\mu_{a_2}...} \mathbb {E}_{\vec n} [n_{\mu_{a_1}}n_{\mu_{a_2}}...](\sigma_{\mu_{a_1}}\otimes\sigma_{\mu_{a_2}}...) \otimes I_{q^c}
$$

Let $|S|=2k, k\in \mathbb N^+$, where 

$$
\mathbb E_{\vec n} [n_{\mu_{a_1}}n_{\mu_{a_2}}...]= \frac{1}{(2k+1)!!}\sum_{\text{pairings}} \delta_{\mu_{a_1}\mu_{a_2}}\delta_{\mu_{a_3}\mu_{a_4}}...
$$

Where pairing  is a set of allocations for the positions in q. Each group consists of two elements, and the groups are identical to each other. For instance, if $k = 2$, the allocations are

$$
(1,2)(3,4)\quad(1,3)(2,4)\quad(1,4)(2,3)
$$

Therefore

$$
\Phi_q = \frac{1}{(2k+1)!!}\sum_{\text{pairings}} \sum_{\mu_{a_1}\mu_{a_3}...}(\sigma_{\mu_{a_1}}^{\otimes 2} \otimes\sigma_{\mu_{a_3}}^{\otimes 2}...) \otimes I_{q^c}
$$

In conclusion

$$
\begin{split}
&E_{U_n}\bigl[\sum_{s_1, s_2, s_3,...}  f_n(s_1, s_2, s_3, ...)P_1\otimes P_{2}\otimes P_{3}\otimes...]\bigl ] \\
&=   \frac{1}{2^{N_l-1}}(\sum_{s_2, s_{3}, ...}\varepsilon_{0,s_2,s_3,...})I^{\otimes N_l} + \frac{1}{2^{N_l-1}}[\sum_q \sum_{s_2, s_3, ...}\epsilon_{0, s_2, s_3,...}^q\varepsilon_{0,s_2,s_3,...}\Phi_q ]
\end{split}
$$

Where

$$
\begin{cases}
\varepsilon_{s_1,s_2,s_3,...} = \varepsilon_{\neg s_1, \neg s_2, \neg s_3,...}\\
\epsilon_{0, s_2, s_3,...}^q = (-1)^{\sum_{a\in q}s_a}\\
\Phi_q = \frac{1}{(2k+1)!!}\sum_{\text{pairings}} \sum_{\mu_{a_1}\mu_{a_3}...}(\sigma_{\mu_{a_1}}^{\otimes 2} \otimes\sigma_{\mu_{a_3}}^{\otimes 2}...) \otimes I_{q^c}\\
q = S \subseteq \{1, 2, ..., N_{l}\}, \quad |S|=2k, \quad k\in \mathbb N^+
\end{cases}
$$

q is a set of positions on which the nontrivial Pauli operator acts.