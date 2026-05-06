# Reflection Invariant

## Classical Shadow

^2b4427

The key step is to calculate

$$
Z_R = tr(R_I \widetilde \rho).
$$

Where

$$
\begin{cases}
R_I |1, 2,...,2N\rangle  = |2N, 2N-1,..,2,1\rangle,\\
\widetilde \rho = \bigotimes\limits_{n=1}^N \widetilde \rho_n,
\end{cases}
$$

In fact, we colud revised the space order, let

$$
\widetilde \rho = \bigotimes_{n=1}^{N}\widetilde \rho_n \otimes \widetilde \rho_{2N-n+1}.
$$

also,

$$
R_I = \bigotimes\limits_{n=1}^NSWAP(n, 2N-n+1).
$$

Therefore,

$$
\begin{split}
tr(R_I\widetilde \rho) &= tr[\bigotimes\limits_{n=1}^NSWAP(n, 2N-n+1)\bigotimes_{n=1}^{N}\widetilde \rho_n \otimes \widetilde \rho_{2N-n+1}]\\
&= tr[\bigotimes\limits_{n=1}^NSWAP(n, 2N-n+1)\widetilde \rho_n \otimes \widetilde \rho_{2N-n+1}]\\
&= \prod\limits_{n=1}^N tr(SWAP (\widetilde \rho_n \otimes \widetilde \rho_{2N-n+1}))
\end{split}
$$

## Based on Hamming Core

^45a4ea

==NOTE: the U transform gate of $U_n$ and $U_{2N-n+1}$ are same.==

Definite

$$
\widetilde{\mathcal P} = 2^N (-2)^{-\frac{1}{2}D[s, R_I(s)]},
$$

therefore

$$
\mathbb E_{U, s}[\widetilde{\mathcal P}] = \mathbb E_U [\sum_{s} \widetilde{\mathcal P} P(s|U)],
$$

where

$$
P(s|U) = tr(P(s)\rho).
$$

According to the definition of core, we re revised the space order as follow, Viz.,

$$
\begin{split}
tr(P(s)\rho) &= tr[\rho \bigotimes_{n=1}^N P_n\otimes P_{n'}]
\end{split}
$$

Where $n' = 2N - n +1$, $s' = R_I(s)$, the core could be breaken to

$$
\begin{split}
\widetilde {\mathcal P} = 2^N \prod_n^{N} (-2)^{-D[s_n, s_n']}
\end{split}
$$

in conclusion, there are

$$
\begin{split}
\mathbb E_U [\sum_{s} \widetilde{\mathcal P} P(s|U)] 
&= 2^N \mathbb E_{U}\bigr[ \sum_s (-2)^{-\frac{1}{2}D[s, R_I(s)]}tr(P(s)\rho)\bigr]\\ 
&= 2^N \mathbb E_{U}\bigr[\sum_s \prod\limits_n^N (-2)^{-D[s_n, s_n']} tr[\rho \bigotimes_{n=1}^N P_n\otimes P_{n'}]\bigr]\\
&= 2^N tr[\rho\mathbb E_{U}\bigr[\sum_s  \bigotimes_{n=1}^N (-2)^{-D[s_n, s_n']}P_n\otimes P_{n'}]\bigr ]\\
&= 2^N tr[\rho \bigotimes_{n=1}^N\mathbb E_{U_n}\bigr[\sum_{s_n, s_n'}  (-2)^{-D[s_n, s_n']}P_n\otimes P_{n'}]\bigr ]
\end{split}
$$

Ref to [[HCE_Core_Calculation#^09be31]], evidently

$$
\mathbb E_{U_i} [\sum_{s_n, s_n'=\{0, 1\}^N}(-2)^{-D[s_n, s_{n'}]}P_n\otimes P_{n'}] = \frac{1}{2}\sum_{R_n} R_n \otimes R_{n'}.
$$

therefore

$$
\mathbb E_U [\sum_{s} \widetilde{\mathcal P} P(s|U)] = tr[\rho SWAP] = tr(\rho R_I)
$$