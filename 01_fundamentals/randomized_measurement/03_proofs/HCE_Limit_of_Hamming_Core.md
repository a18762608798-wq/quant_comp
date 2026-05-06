# HCE Limit of Hamming Core

## Purity

^9c6063

Where

$$
tr(\rho^2) = \sum_R[tr(\rho R)]^2= \sum_Rtr[(\rho \otimes \rho)(R\otimes R)] = tr[(\rho\otimes \rho)SWAP]
$$

Ref to [[Hamming_Core_Estimation]]

这里类似于不同shot的同一个比特位置上的pair公用一个双比特整体U门，这反应了 hamming core 的核心观点是构建双比特的U(2)随机变换。

此方法限制有二：

* 不同shots的 $\rho$ 只在自己的shot中纠缠。这否定了 [[Random_U(2)_of_Multiple_Qubits#^55aa46]] 中的错误尝试。
* 需要有重复上一次shot中同样的 U settings 的能力。这说明原生汉明核并没有免去记录 U settings 信息的功能。

## Reflection Invariant

^d0f2c8

$$
Z_R = tr(R_I\rho) = tr(SWAP\rho)
$$

Ref to [[Reflection_Invariant]]]

这个实验天生带有双比特的 U(2) 随机变换，更能反应 hamming core 的本质。如果让 the number of shots is 1, 也就是 $K = 1$ , 这依然无法免去记录 U settings, 因为需要在 pair 内两个比特重复。

但是如果真的有 pair U(2) gates，确实可以免去 U settings.