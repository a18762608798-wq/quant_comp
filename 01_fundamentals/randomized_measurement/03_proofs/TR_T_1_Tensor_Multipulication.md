
Specificantly speaking, Let

$$
\rho = \sum_{a,b; \mu,\nu} \rho^{a, \mu}_{b, \nu}(|a\rangle \langle b|\otimes |\mu\rangle\langle \nu|),
$$

where $|a\rangle$ is own to subsystem 1 and $|\mu\rangle$ is own to sybsystem 2 , so

$$
T_1[\rho] = \sum_{a,b; \mu,\nu} \rho^{a, \mu}_{b, \nu}(|b\rangle \langle a|\otimes |\mu\rangle\langle \nu|),
$$

Viz.,

$$
[T_1[\rho]]_{a,\mu;b,v} = \rho_{b,\mu;a,\nu}
$$

If we writen as specific tensor multiplication,

$$
\begin{split}
\rho_{b,\mu;a,\nu} = [T_1]_{a;b}^{c;d} \rho_{c,\mu;d,\nu}\\
where \quad [T_1]_{c;d}^{a;b} = \delta_{bc}\delta_{ad}
\end{split}
$$

For the estimator $\widetilde \rho$, there are

$$
\widetilde \rho = \widetilde \rho_1 \otimes \widetilde \rho_2 .
$$

Therefore,

$$
[T_1[\widetilde \rho]]_{a,\mu;b, \nu} = \widetilde \rho_{b,\mu;a, \nu} = [\widetilde \rho_1]_{b;a}[\widetilde\rho_2]_{\mu,\nu} = \prod\limits_{i=1}^N [\widetilde \rho_{1i}]_{b_i;a_i}[\widetilde\rho_{2i}]_{\mu_i,\nu_i} = \prod\limits_{i=1}^N T[\widetilde \rho_{1i}]_{a_i;b_i}[\widetilde\rho_{2i}]_{\mu_i,\nu_i}
$$