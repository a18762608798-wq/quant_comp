# Hamming Core Estimation

## Purity


$$
\hat P_2 = \frac{2^N}{MK(K-1)} \sum\limits_{m=1}^M\sum\limits_{k,k'=1;k\neq k'}^K (-2)^{-D[s^{(m, k)}, s^{(m, k')}]}
$$

Target

$$
tr( \rho^2) = \mathcal p = \mathbb E_{U, s, s'}[\widetilde {\mathcal P}].
$$

Where

$$
\widetilde {\mathcal{P}} = \frac{1}{MK(K-1)} \sum_{m=1}^M\sum_{k=1}^K\sum_{k'=1, k'\neq k}^K \widetilde{\mathcal P}(m, k),
$$

therefore we should proof

$$
tr(\rho^2) = E_{U, s, s'}[\overline{\widetilde {\mathcal{P}}(m, k, k')}] = E_{U, s, s'}[\widetilde{\mathcal P}(U, s, s')],
$$

<span style="color:purple">Subsequent omission marker U and s</span>, where

$$
\widetilde{\mathcal P}_2 = 2^N (-2)^{-D[s, s']},
$$

<span style="color:purple">Subsequent omission marker 2</span>, therefore

$$
\mathbb E_{U, s, s'}[\widetilde{\mathcal P}] = \mathbb E_U [\sum_{s, s'} \widetilde{\mathcal P} P(s|U) P(s'|U)],
$$

where

$$
P(s|U) = tr(P(U, s)\rho),
$$

also

$$
P(s|U)P(s'|U) = tr[(\rho \otimes \rho)(P(s)\otimes P(s'))],
$$

therefore

$$
\begin{aligned}
expr &= \sum_{s, s'} \widetilde{\mathcal P} \mathbb E_{U}[ tr[(\rho \otimes \rho)(P(s)\otimes P(s'))]]\\
&= 2^N tr\big [(\rho\otimes\rho) \mathbb E_{U}[\sum_{s, s'} (-2)^{-D[s, s']}(P(s)\otimes P(s'))\big ].
\end{aligned}
$$

So now the core calculation is

$$
\mathbb E_{U}[\sum_{s, s'} (-2)^{-D[s, s']}(P(s)\otimes P(s'))\big ].
$$

where

$$
P(s) \otimes P(s') = \bigotimes\limits_{n=1}^N P_n(s_n)\otimes \bigotimes\limits_{i=1}^N P_i(s'_i) = \Pi^\dagger[\bigotimes\limits_{n=1}^N P_n(s_n)\otimes P_n(s'_n) ]\Pi.
$$

$\Pi$ is use to reorder Hilbert space, which change the room ordering $(1, ..., N, 1', ..., N')$ to $(1, 1', ..., N, N')$ (basic perspective)

Aim to breaken $(-2)^{D[s, s']}$, definite

$$
(-2)^{-D[s, s']} = \prod\limits_{i = 1}^N (-2)^{-D[s_n, s'_n]}
$$

therefore

$$
\begin{aligned}
&E_{U}[\sum_{s, s'} \prod\limits_{n = 1}^N (-2)^{-D[s_n, s'_n]}\Pi^\dagger[\bigotimes\limits_{n=1}^N P_n(s_n)\otimes P_n(s'_n) ]\Pi\big ] \\
&= \Pi^\dagger\ \big[\bigotimes\limits_{n=1}^N \mathbb E_{U_n}[\sum_{s_n,s'_n}(-2)^{-D[s_n, s'_n]}P_n(s_n)\otimes P_n(s'_n) ] \big]\Pi,
\end{aligned}
$$

For $E_{U_n}[\sum_{s_n,s'_n}\kappa(s_n, s'_n)P_n(s_n)\otimes P_n(s'_n) ]$, **evidently the result is only related to the relative position of $P_n(s_n)$ and $P_n(s_n')$**, Viz.,

$$
E_{U_n}[\sum_{s_n,s'_n}(-2)^{-D[s_n, s'_n]}P_n(s_n)\otimes P_n(s'_n) ] = 2A_{same} - A_{diff},
$$

ref to [[HCE_Core_Calculation#^09be31]], there are

$$
\frac{1}{2} \sum_{\mu_n} R_{\mu_n} \otimes R_{\mu_n},
$$

Viz.,

$$
\begin{aligned}
&\mathbb E_{U}\bigr[\sum_{s, s'} (-2)^{-D[s, s']}(P(s)\otimes P(s'))\bigr]\\
&= \frac{1}{2^N} \Pi^\dagger \bigr[\bigotimes\limits_{n=1}^N \sum_{\mu_n} R_{\mu_n} \otimes R_{\mu_n} \bigr]\Pi \\
&= \frac{1}{2^N} \sum_{\mu\in \{0, 1, 2, 3\}^N}\Pi^\dagger[\bigotimes\limits_{n=1}^N R_{\mu_n}\otimes R_{\mu_n}]\Pi.
\end{aligned}
$$

Also $\Pi^\dagger$ change the room ordering $(1, 1', ..., N, N')$ back to $(1, ..., N, 1', ..., N')$, Viz.,

$$
\mathbb E_{U}\bigr[\sum_{s, s'} (-2)^{-D[s, s']}(P(s)\otimes P(s'))\bigr] = \frac{1}{2^N} \sum_R R\otimes R.
$$

Therefore

$$
\begin{aligned}
expr &= 2^N tr\big [(\rho\otimes\rho) \mathbb E_{U}[\sum_{s, s'} (-2)^{-D[s, s']}(P(s)\otimes P(s'))\big ]\\
& = \sum_R tr\big [(\rho\otimes\rho) (R\otimes R)]\\
& = tr[(\rho \otimes \rho) SWAP]\\
& = \sum_R [tr(R\rho)]^2.
\end{aligned}
$$

Since $\rho = \sum_R tr(R\rho) R$,

$$
expr = \sum_R tr(R\rho)tr(R\rho) = tr(\sum_R tr(R\rho)R \rho)=tr(\rho^2)
$$

QED.

<span style="color:red">Supplementary proof</span>

There are

$$
expr = tr[(\rho \otimes \rho)SWAP]
$$

There SWAP operation is purely swap, but math operation need to swap twice room order.

**这里上来就重排希尔伯特空间对汉明距离估计没有收益(但是从tr[]开始就有用了其实，交换空间顺序不改变trace)，但是对经典阴影数值计算显然很有用**。

## U(2) Transformation of Multiple Qubits

^f7a70a

### Pair

^3108d5

Assumming the nunber of qubit are $2N$ , rearrange the room order, let

$$
O = \bigotimes\limits_{n=1}^N O_n
$$

Assumming the hamming core is

$$
\begin{split}
f(s, s') = \prod\limits_{n=1}^N f_n(s_n, s_n') = \prod\limits_{n=1}^N \varepsilon_{s_n,s_n'}\\
\end{split}
$$

where s' and s are a pair. Ref to [[Reflection_Invariant]], there are

$$
\mathbb E_{U, s}[f] = \mathbb E_U [\sum_{s} f P(s|U)] = tr[\rho \bigotimes_{n=1}^N\mathbb E_{U_n}\bigr[\sum_{s_n, s_n'}  f_n(s_n, s_n')P_n\otimes P_{n'}]\bigr ]
$$

Aslo

$$
\begin{cases}
\mathbb E[(0, 0)] = [\frac{1}{4}(I \otimes I + \frac{1}{3}\sum_{\mu=1}^3 \sigma_\mu \otimes \sigma_\mu)]\\
\mathbb E[(0, 1)] = [\frac{1}{4}(I \otimes I - \frac{1}{3}\sum_{\mu=1}^3 \sigma_\mu \otimes \sigma_\mu)]
\end{cases},
$$

Evidently

$$
\mathbb E_{U_n}\bigr[\sum_{s_n, s_n'} \varepsilon_{s_n, s_n}'P_n\otimes P_{n'}]\bigr ] = \frac{1}{4} \sum_{s_n, s'_n}\varepsilon_{s_ns_n'}I\otimes I + \frac{1}{12}(\varepsilon_{00} + \varepsilon_{11} - \varepsilon_{01} - \varepsilon_{10})\sum\limits_{\mu=1}^3 \sigma_\mu\otimes \sigma_\mu,
$$

**The freedom is enough(It holds true for any bit in subspace) so we could let $\varepsilon_{00} = \varepsilon_{11}, \varepsilon_{01} = \varepsilon_{10}$, Viz.,**

$$
expr = \frac{1}{2} (\varepsilon_{00} + \varepsilon_{01})I\otimes I + \frac{1}{6}(\varepsilon_{00} - \varepsilon_{01})\sum\limits_{\mu=1}^3 \sigma_\mu\otimes \sigma_\mu
$$

Therefore if we use hamming core to estimate the mechanical quantity, the form of this quantity must be limited. 

$$
O_n = \frac{1}{2} (\varepsilon_{00} + \varepsilon_{01})I\otimes I + \frac{1}{6}(\varepsilon_{00} - \varepsilon_{01})\sum\limits_{\mu=1}^3 \sigma_\mu\otimes \sigma_\mu
$$

### General Situation

^b54c3a

If the number of qubits with local random U gate is arbitary,  the key part is as follow,

$$
E_{U_n}\bigr[\sum_{s_1, s_2, s_3,...}  f_n(s_1, s_2, s_3, ...)P_1\otimes P_{2}\otimes P_{3}\otimes...]\bigr ] 
$$

Ref to [[HCE_Core_Calculation#^ddf915]], the result is 

$$
\begin{split}
\frac{1}{2^{N_l-1}}(\sum_{s_2, s_{3}, ...}\varepsilon_{0,s_2,s_3,...})I^{\otimes N_l} + \frac{1}{2^{N_l-1}}[\sum_q \sum_{s_2, s_3, ...}\epsilon_{0, s_2, s_3,...}^q\varepsilon_{0,s_2,s_3,...}\Phi_q ]
\end{split}
$$

Where

$$
\begin{cases}
\varepsilon_{s_1,s_2,s_3,...} = \varepsilon_{\neg s_1, \neg s_2, \neg s_3,...}\\
\epsilon_{0, s_2, s_3,...}^q = (-1)^{\sum_{a\in q}s_a}\\
\Phi_q = \frac{1}{(2k+1)!!}\sum_{\text{pairing}} \sum_{\mu_{a_1}\mu_{a_3}...}(\sigma_{\mu_{a_1}}^{\otimes 2} \otimes\sigma_{\mu_{a_3}}^{\otimes 2}...) \otimes I_{q^c}\quad \text{ignore the order of space}\\
q = S \subseteq \{1, 2, ..., N_{l}\}, \quad |S|=2k, \quad k\in \mathbb N^+
\end{cases}
$$

where pairing  is a set of allocations for the positions in q. Each group consists of two elements, and the groups are identical to each other. For instance, if $k = 2$, the allocations are

<span style="color:green">In the conclution, the local operator could be estimated by constructing the Hamming core, which can only have components on $\Phi_q$ </span>, and the the difficulty of hitting targeted operator will keep increasing as the size of the subspace increases.


