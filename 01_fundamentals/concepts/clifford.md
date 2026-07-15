# Clifford

其定义是对于 pauli operator 幺正变换后依然是 pauli operators。即：
$$
C \in \mathrm{Cl}(n) \iff \forall P \in \mathcal{P}_n,\; C^\dagger P C \in \mathcal{P}_n.
$$

## 生成元

n-qubit Clifford 群可由以下三个基本门生成：

### 1. Hadamard (H)

$$
H = \frac{1}{\sqrt{2}}\begin{pmatrix} 1 & 1 \\ 1 & -1 \end{pmatrix}
$$

对 Pauli 的作用：
$$
H^\dagger X H = Z,\quad H^\dagger Y H = -Y,\quad H^\dagger Z H = X.
$$

### 2. Phase gate (S)

$$
S = \begin{pmatrix} 1 & 0 \\ 0 & i \end{pmatrix},\quad S^\dagger = \begin{pmatrix} 1 & 0 \\ 0 & -i \end{pmatrix}
$$

对 Pauli 的作用：
$$
S^\dagger X S = Y,\quad S^\dagger Y S = -X,\quad S^\dagger Z S = Z.
$$

$S^2 = Z \in \mathcal{P}_1$，$S^4 = I$。

### 3. CNOT (CX)

$$
\mathrm{CNOT} = \begin{pmatrix}
1 & 0 & 0 & 0 \\
0 & 1 & 0 & 0 \\
0 & 0 & 0 & 1 \\
0 & 0 & 1 & 0
\end{pmatrix}
$$

对双 qubit Pauli 的作用（control=q1, target=q2）：
$$
\begin{aligned}
\mathrm{CNOT}^\dagger (I \otimes X) \mathrm{CNOT} &= I \otimes X, &
\mathrm{CNOT}^\dagger (X \otimes I) \mathrm{CNOT} &= X \otimes X, \\
\mathrm{CNOT}^\dagger (I \otimes Z) \mathrm{CNOT} &= Z \otimes Z, &
\mathrm{CNOT}^\dagger (Z \otimes I) \mathrm{CNOT} &= Z \otimes I. \\
\mathrm{CNOT}^\dagger (I \otimes Y) \mathrm{CNOT} &= Z \otimes Y, &
\mathrm{CNOT}^\dagger (Y \otimes I) \mathrm{CNOT} &= Y \otimes X, 
\end{aligned}
$$

其中Y组是另外两组的乘积.

CNOT 可与 H、S 互换生成 CZ：$\mathrm{CZ} = (I \otimes H)\,\mathrm{CNOT}\,(I \otimes H) \in \mathrm{Cl}(2)$。

## 单 qubit Clifford 群

$\mathrm{Cl}(1)$ 共 24 个元素，群结构为：

$$
\mathrm{Cl}(1) / \mathcal{P}_1 \cong S_3
$$

（商掉 Pauli 群后同构于 3 元置换群，对应 Bloch 球面上 X, Y, Z 轴的置换。）

24 = 3 (轴置换) × 2 (方向翻转) × 4 (全局相位) / 1（相位归入 $\mathcal{P}_1$ 后）——意即单 qubit Clifford 对应正八面体对称群 $O$，也是 Bloch 球面保 Pauli 轴的旋转。

## Native CSCO 和 目标 CSCO 的 Cliffford 变换技巧

查表用CNOT解link，然后单比特表象变换.
