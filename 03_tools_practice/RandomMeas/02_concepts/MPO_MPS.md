# MPO MPS

## Definition

### MPO

==Core support: 任何一个矩阵可以拆解为两个矩阵的乘积，比如奇异值分解。== Meaning

$$
A_k^i = B_j^iV^{\dagger j}_k = U^i_l S^l_jV^{\dagger j}_k 
$$

**For any operator, there are**

$$
\rho_{s_1s_2s_3,...}^{s_1's_2's_3',...} = [A_1]_{s_1l_1}^{s_1'}[A_2]_{s_2l_2}^{s_2'l_1}...[A_N]_{s_N}^{s_N'l_{N-1}}
$$

Proof as follow

$$
\rho_{s_1s_2s_3,...}^{s_1's_2's_3',...} = \rho_{s_1(s_2s_3,...)}^{s_1'(s_2's_3',...)} = \rho_{(s_2's_3',...)(s_2s_3,...)}^{s_1's_1} = [A_1]_{l_1}^{s_1's_1}[B_1]^{l_1}_{ (s_2's_3',...)({s_2s_3,...})} =... 
$$

where

$$
[B_1]^{l_1}_{ (s_2's_3',...)({s_2s_3,...})} = [B_1]^{l_1s_2's_2}_{ (s_3',...)({s_3,...})} = [A_2]^{l_1s_2's_2}_{l_2} [B_2]^{l_2}_{(s_3'...)(s_3...)}
$$

Repeat to break $B_2$

QED.

### MPS

$$
\psi^{s_1s_2s_3...} = [A_1]^{s_1}_{l_1}[A_2]^{s_2l_1}_{l_2}...[A]^{s_N l_{N-1}}
$$

## SVD

$$
\rho_{s_1s_2s_3,...}^{s_1's_2's_3',...} = [U_1]_{l_1}^{s_1's_1}[SV^\dagger]^{l_1}_{ (s_2's_3',...)({s_2s_3,...})} =... 
$$

在中线之前，这里S一般行数远小于列数，所以一般缩并指标 $l_i$ 的维度就是分解时奇异值的数量。具体优化时可能取非0奇异值数量。这个MPO不太好吧缩并指标写成清晰的矩阵相乘的格式，非要写的话要把矩阵“拉直”进行联合指标重排。
	
如果精确分解，和MPO中除了分出的前一项为U矩阵其他并无不同。

关键在于S作为广义diag矩阵，S可以直接小奇异值起到近似的作用。

## In ITensors

### Picture

```text
s1'          s2'          s3'
 |            |            |
A[1] --l1-- A[2] --l2-- A[3]
 |            |            |
s1           s2           s3
```

所谓的bond/link dim，就是 $l_i$ 维度或者说是保留的奇异值的数量。

### Operation

#### MPO Multiplication

* concept

$$
[\rho]^{s'}_s [\rho]_{s''}^{s} = [\rho^2]^{s'}_{s''}
$$

meaning

$$
\begin{split}
&\bigl[[A_1]_{s_1l_1}^{s_1'}[A_2]_{s_2l_2}^{s_2'l_1}...[A_N]_{s_N}^{s_N'l_{N-1}}\bigl] \bigl[[A_1]_{s_1''l_1'}^{s_1}[A_2]_{s_2''l_2'}^{s_2l_1'}...[A_N]_{s_N''}^{s_Nl_{N-1}'}\bigl] \\
=&[A_1]_{s_1l_1}^{s_1'}[A_1]_{s_1''l_1'}^{s_1}[A_2]_{s_2l_2}^{s_2'l_1}[A_2]_{s_2''l_2'}^{s_2l_1'}...[A_N]_{s_N}^{s_N'l_{N-1}}[A_N]_{s_N''}^{s_Nl_{N-1}'} \\
=& [B_1]^{s_1'}_{s_1''l_1l_1'}[B_2]^{s_2's_2''l_1l_1'}_{l_2l_2'}...[B_N]^{s_N'l_{N-1}l'_{N-1}}_{s_N''}
\end{split}
$$

将 $l_il_i'$ 这个联合指标看成一个指标。则 MPO 相乘后结构和原来的MPO相同，只是 link dim 增加。

**换言之，本质上是内部ITensor收缩**

* The picture

```text
s1'          s2'          s3'
 |            |            |
A[1] --l1-- A[2] --l2-- A[3]
 |            |            |
s1           s2           s3
 |            |            |
A[1] --l1'-- A[2] --l2'-- A[3]
 |            |            |
s1''         s2''         s3''
```

Viz.,

```
s1'               s2'                 s3'
 |                 |                  |
B[1] --(l1, l1')-- B[2] --(l2, l2')-- B[3]
 |                 |                  |
s1''              s2''                s3''
```

#### MPO Sum

* concept

本质上是直和。但是实际上为了节省空间一般经常先求trace之类的标量最后再相加。

$$
\rho_1 + \rho_2
$$

$$
\begin{aligned}
&[\rho_1]_{s_1s_2s_3,...}^{s_1's_2's_3',...} = [A_1]_{s_1l_1}^{s_1'}[A_2]_{s_2l_2}^{s_2'l_1}...[A_N]_{s_N}^{s_N'l_{N-1}}\\
&[\rho_2]_{t_1t_2t_3,...}^{t_1't_2't_3',...} = [B_1]_{t_1o_1}^{t_1'}[B_2]_{t_2o_2}^{t_2'o_1}...[B_N]_{t_N}^{t_N'o_{N-1}}
\end{aligned}
$$

Therefore

$$
\begin{aligned}
&[\rho_1]_{s_1s_2s_3,...}^{s_1's_2's_3',...} + [\rho_2]_{t_1t_2t_3,...}^{t_1't_2't_3',...}\\
&=[C_1]^{s_1's_1l_1}_{p_1}[C_2]^{s_2's_2l_1l_2 p_1}_{p_2} ... [C_N]^{s_N's_Nl_{N-1}p_{N-1}}
\end{aligned}
$$

where the dim of $p_i$ is 2, and

$$
\begin{cases}
[C_1]_{p_1=0} = A_1 \\
[C_2]_{p_2=1} = B_1\\
[C_N]_{p_{N-1}=0} = A_N\\
[C_N]_{p_{N-1}=1} = B_N\\
\end{cases}
$$

When $i \neq 1, N-1$ , there are

$$
[C]_i = \delta_{p_{i-1}0}\delta_{p_i0}A + \delta_{p_{i-1}1}\delta_{p_i1}B + O
$$