# How to understand $\hat U$

## Definition

Which is a Sencond order tensor, one input and one output. There are two kinds of viewpoint: basics vectors and coordinate.

**We prefer the viewpoint of basis vectors.**

$$
\hat U_{1 \rightarrow 2} = \sum_{i} |\phi^2_i\rangle \langle \phi^1_i|
$$

meaning

$$
\hat U_{1\rightarrow 2} |\phi_n^1\rangle = |\phi^2_n\rangle
$$

The elements of $\hat U$ for representation 1 or 2 is equal,

$$
\hat U_{{1 \rightarrow 2}_{m,n}} = \langle \phi^1_m | \phi^2_n \rangle
$$

## For quantum state

$$
\bigr (\langle \phi^1_m | \hat U_{1 \rightarrow 2}^\dagger\bigr ) | \psi\rangle = \langle \phi^2_m | \psi\rangle
$$

**Therefore**,

$$
U_{1 \rightarrow 2}^\dagger \psi^1 = \psi^2
$$

## For operator

$$
\langle \phi^1_m | \hat U_{1 \rightarrow 2}^\dagger \hat F \hat U_{1 \rightarrow 2} |\phi^1_n\rangle = \langle \phi^2_m |\hat F |\phi^2_n\rangle
$$

**Therefore**,

$$
U_{1 \rightarrow 2}^\dagger F^1 U_{1 \rightarrow 2} = F^2
$$

## For operator transform(U)

It is similar as representation transform, which has same eignevalues evidently.

$$
\begin{aligned}
\hat F_1 = \sum_i f_{i} | \phi_i^1\rangle \langle \phi_i^1|\\
\hat F_2 = \sum_i f_{i} |\phi_i^2\rangle \langle \phi_i^2|
\end{aligned}
$$
Therefore :

$$
\hat U_{1 \rightarrow 2} \hat F_1 \hat U_{1\rightarrow 2}^\dagger = \sum_i f_{i} |\phi_i^2\rangle \langle \phi_i^2| = \hat F_2
$$