# fidelity

## definition

$$
F(\rho, \sigma) = f^2 = Tr[\sqrt{\sqrt \rho\sigma \sqrt \rho}]^2,
$$

## properities

* verification state similarity

Sufficiency:

$$
\sqrt \rho \rho \sqrt \rho = \rho \sqrt \rho \sqrt \rho = \rho^2 
$$

Therefore

$$
F = 1
$$

Necessity:

...Difficultly to proof.

* $0 \le F \le 1$

* If $\rho = |\psi\rangle\langle \psi|$, evidently, $\rho^2 = \rho$, therefore

$$
\sqrt \rho = \rho,
$$

Viz.,

$$
F = \langle \psi|\sigma|\psi\rangle
$$

## Experiment

### strictly

使用复空间的任意一组投影算符的测量结果构建目标函数，找到可以让目标函数最小的一组测量基。

这在实验上是不可能的。

### RandomMeas

一般使用矩阵的内积替代传统的保真度

$$
F_{HS} (\rho, \sigma) = \frac{Tr(\rho \sigma)}{\sqrt {{Tr(\rho^2)} Tr(\sigma^2)}}
$$

这是矩阵夹角，范围正常是 $[-1, 1]$, 但是这里 $\rho \ge 0, \sigma \ge 0$ , 也就是半正定，即有存在

$$
Tr(AA^\dagger B B^\dagger) = Tr(B^\dagger A A^\dagger B) = Tr((A^\dagger B)^\dagger(A^\dagger B)) \ge 0
$$

Viz.,

$$
F_{HS} \in [0, 1]
$$

必要性显然；充分性：

If $F = 1$,  the direction of $\rho$ is same with $\sigma$, so

$$
\rho = c \sigma,
$$

also

$$
tr(\rho) = tr(\sigma) = 1,
$$

Viz.,

$$
c = 1
$$

meaning

$$
\rho = \sigma
$$




