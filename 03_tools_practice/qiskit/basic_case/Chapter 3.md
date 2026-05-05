在构造多体算子时，需按 **qubit 0 → qubit n−1 从右向左** 的顺序进行张量积（即 `Reverse@Table[...]`），但这**不影响单个量子比特基矢的定义**。

换言之：在 Qiskit 的 little-endian 约定下，**n 量子比特电路的初始全零态 ∣00⋯0⟩∣00⋯0⟩ 始终表示为向量 [1,0,0,…,0]T[1,0,0,…,0]T**（第一个分量为 1，其余为 0）。

CPHASE：

assume control bit c, targeted bit t.

$$
U = |0\rangle_c \langle 0| \otimes I + |1\rangle_c\langle1| \otimes (|0\rangle_t\langle 0| + |1\rangle_t\langle1|) \otimes I
$$