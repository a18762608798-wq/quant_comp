# Error Bounds

## Classical error

Some possible relevant evidence [[classical error]]

## Error of classical shadow

### The measurement axis is X, Y, Z 

Ref to [[Classical_Shadow#The measurement axis is X, Y, Z]]

If we intend to est a **expectation of a pauli base of a shot**, mean:

$$
y_P(s)^2 = 1
$$

then we calculate the variance simply, assume $E[X_O] = p$

$$
Var(X_O(B, s)) = \mathbb E[X_O^2] - \mathbb E^2[X_O] = \mathbb E[3^{2\omega}1_{P\preceq B}y_P^2(s)] - p^2 = 3^{2\omega} \mathbb E[1_{P\preceq B}] - p^2 = 3^{\omega} - p^2 \approx 3^\omega
$$

For a generate est of mechanical quantity, we could not get a strict expression, but giving a relationship with pauli measurement is simple.

$$
Var(X_O) = \mathbb E_B [Var_s[X_O|B]] + Var_B [\mathbb E_s[X_O|B]]
$$

We could give a simple estimate, ignoring cross-correlation, there are

$$
Var(\sum_pc_p\frac{1}{M}\sum_M p^{(m)}) = \frac{Var(\sum_P c_P p^{(m)})}{M} \approx \frac{1}{M}\sum_P c_P^2 3^\omega
$$

### The measurement axis is $\sigma_n$

Ref to [[Classical_Shadow#The measurement axis is $ sigma_n$]]

Therefore we could get the variance of expectation with $M, K = 1$,

$$
Var(X_P) = \mathbb E[X_P^2] - \mathbb E[X_P]^2 = \mathbb E[3^{2\omega} \prod_i s_i^2(\vec a_i \cdot \vec n_i)^2] - p^2 = 3^{2\omega} \prod_i \mathbb E[(\vec a_i \cdot \vec n_i)^2] - p^2 = 3^\omega - p^2
$$

## Error of Hamming Core

不确定是否方差增长小于对所有pauli bases测量。

答: 否，鬼知道怎么计算。

## Pauli measurement

Ref to [[Pauli_Scan]]

there are

$$
Var(X_O) = E_B[Var_B[X_O|B]] + 0
$$

The second term is zero because the group of B is certain and the statistical error disappears.

If we intend to est a **expectation of pauli base of a shot**, then we calculate the variance simply, assume $E[X_O] = p$

$$
Var(o) = \frac{1 -  p^2}{K'} = \frac{3^\omega(1 - p^2)}{K}
$$

Where o is a pauli bases

We could give a simple estimate, ignoring cross-correlation, there are

$$
Var(\sum_pc_p p) \approx \sum_P c_P^2 Var(p) = \sum_P c_P^2 \frac{3^\omega(1 - p^2)}{K}
$$

**这说明对泡利基的均匀扫描稳定精度高于经典阴影。**