
该测量只有在 $P_k$ 能够由测量投影算符线性表示时，才能仅根据这一测量设置的结果概率估计 $\langle P_k\rangle$。

设一次秩一正交投影测量为

$$
\mathsf M={\Pi_j}_j,
\qquad
\Pi_j=|\phi_j\rangle\langle\phi_j|,
\qquad
\sum_j\Pi_j=I.
$$

对未知态 $\rho$ 进行该测量，得到结果 $j$ 的概率为

$$
q_j=\operatorname{Tr}(\rho\Pi_j).
$$

如果某个力学量 $A$ 可以写成

$$
A=\sum_j a_j\Pi_j,
$$

那么

$$
\begin{aligned}
\langle A\rangle
&=
\operatorname{Tr}(\rho A)\
&=
\sum_j a_j\operatorname{Tr}(\rho\Pi_j)\
&=
\sum_j a_jq_j.
\end{aligned}
$$

因此，每当测量结果为 $j$ 时，可以把 $a_j$ 当作一次随机估计值。

重复 $N$ 次相同的测量设置，若结果依次为 $j_1,\ldots,j_N$，则

$$
\widehat{\langle A\rangle}
==========================

\frac{1}{N}\sum_{t=1}^N a_{j_t}
$$

是 $\langle A\rangle$ 的无偏估计。

反过来，若 $A$ 不属于投影算符集合的实线性张成空间，即

$$
A\notin\operatorname{span}_{\mathbb R}{\Pi_j},
$$

那么一般存在两个量子态 $\rho$ 和 $\sigma$，它们在这次测量下具有完全相同的结果概率：

$$
\operatorname{Tr}(\rho\Pi_j)
============================

\operatorname{Tr}(\sigma\Pi_j),
\qquad
\forall j,
$$

但却满足

$$
\operatorname{Tr}(\rho A)
\neq
\operatorname{Tr}(\sigma A).
$$

因此，仅凭该测量设置产生的数据，不可能确定 $\langle A\rangle$。

对于秩一正交投影测量，

$$
\operatorname{span}_{\mathbb R}{\Pi_j}
$$

正好是所有在基 ${|\phi_j\rangle}$ 下对角的厄米算符。

也就是说，可以从同一批测量数据估计的力学量必须具有形式

$$
A=\sum_j a_j|\phi_j\rangle\langle\phi_j|.
$$

这些力学量共享同一组本征态，并且彼此对易。

因此，一组厄米力学量 ${A_\alpha}$ 若能够被同一个秩一投影测量直接估计，则应当存在一组共同本征基，使得

$$
A_\alpha
========

\sum_j a_{\alpha j}\Pi_j.
$$

每次得到测量结果 $j$ 后，可以同时记录

$$
a_{1j},a_{2j},\ldots,
$$

再分别进行样本平均，从而用同一批实验结果同时估计所有的

$$
\langle A_\alpha\rangle.
$$

例如，对两个比特在计算基

$$
{|00\rangle,|01\rangle,|10\rangle,|11\rangle}
$$

下进行测量。

一次测量结果包含两个比特的 $Z$ 本征值

$$
z_1,z_2\in{+1,-1}.
$$

因此，同一批测量结果可以同时估计

$$
\langle Z\otimes I\rangle,
\qquad
\langle I\otimes Z\rangle,
\qquad
\langle Z\otimes Z\rangle,
$$

因为每次测量分别提供了随机样本

$$
z_1,
\qquad
z_2,
\qquad
z_1z_2.
$$

但是，这批数据不能估计

$$
\langle X\otimes I\rangle.
$$

例如，单比特态 $|+\rangle$ 和 $|-\rangle$ 在 $Z$ 基测量下都会产生概率分布

$$
q_0=q_1=\frac{1}{2},
$$

但二者的 $X$ 期望分别为

$$
\langle +|X|+\rangle=+1
$$

和

$$
\langle -|X|-\rangle=-1.
$$

因此，$Z$ 基测量丢失了区分这两个态所需的相干信息。

更一般地，令测量诱导的退相干映射为

$$
\mathcal D_{\mathsf M}(A)
=========================

\sum_j\Pi_jA\Pi_j.
$$

根据测量概率所计算的量

$$
\sum_jq_j\langle\phi_j|A|\phi_j\rangle
$$

实际上等于

$$
\operatorname{Tr}
\left(
\rho,\mathcal D_{\mathsf M}(A)
\right),
$$

而不一定等于

$$
\operatorname{Tr}(\rho A).
$$

只有当

$$
\mathcal D_{\mathsf M}(A)=A,
$$

也就是 $A$ 在测量基下已经对角时，二者才相等。

所以，在秩一投影测量的语境下，同一个测量设置能够同时直接估计的力学量，恰好构成由该组投影算符张成的对易算符代数。

不过，这一结论不能直接推广为“任何一次测量都只能估计对易力学量”。

对于一般 POVM

$$
\mathsf M={E_j}_j,
$$

结果概率为

$$
q_j=\operatorname{Tr}(\rho E_j).
$$

能够从这些结果概率中线性估计的力学量满足

$$
A\in\operatorname{span}_{\mathbb R}{E_j}.
$$

具体而言，如果存在一组实数系数 ${a_j}$，使得

$$
A=\sum_j a_jE_j,
$$

那么

$$
\langle A\rangle
================

# \operatorname{Tr}(\rho A)

\sum_j a_jq_j.
$$

若 POVM 是信息完备的，其测量算符能够张成整个厄米算符空间，那么原则上可以从同一种 POVM 的重复测量结果中重构所有 Pauli 期望，包括彼此不对易的 $X$、$Y$ 和 $Z$。

这并不意味着一次测量同时给出了 $X$、$Y$ 和 $Z$ 的本征值，而只是意味着可以从同一个经典概率分布中，通过不同的线性重构公式估计它们的期望值。

因此，从信息论角度看，量子测量可以理解为一个从量子态到经典概率分布的线性映射：

$$
\rho
\longmapsto
\left{
\operatorname{Tr}(\rho E_j)
\right}_j.
$$

态层析的本质不是单纯“重构某个投影子空间中的态分量”，而是选择足够多的测量算符，使这些线性函数能够唯一确定 $\rho$。

若测量算符不能张成整个厄米算符空间，测量就只能得到 $\rho$ 在相应算符子空间上的信息。

因此，可以将核心结论概括为

$$
\boxed{
\text{从一组测量概率中可估计的线性力学量}
========================

\text{该测量算符的实线性张成空间}
}
$$

“共享共同本征基”只是这一结论在秩一正交投影测量情况下的特殊表现。
