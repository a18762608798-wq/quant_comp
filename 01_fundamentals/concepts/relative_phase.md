# relative phase

For the first question, we rotate the basic of all the space, meaning

$$
\begin{cases}
R_{YY} = U_4 R_{ZZ} U_4^\dagger\\
where \quad Y\otimes Y = (U \otimes U) (Z\otimes Z) (U^\dagger \otimes U^\dagger)
\end{cases}
$$

Where

$$
U_{ij} = \langle \phi^z_i | \phi^y_j\rangle \Rightarrow U = \frac{1}{\sqrt 2} \begin{Bmatrix}
1 & 1\\
i & -i
\end{Bmatrix} = SH
$$

**这个自由度不是整体相位自由度，而是算符绕自身旋转的自由度。体现在本征态的相对相位而非整体。换言之整体相位决定的是定义X, Y, Z的时候的形式，表象变换U的自由度来自其本征向量的相对相位**

Z到X和Z到Y的两个规范对应表象变换只需要一次旋转的补充。比如z到x只需要绕y旋转。但是开始的绕z旋转和绕被旋转向量的旋转依然对整个刚体有意义。

**我们量子计算给了一个固定的约定就是为了保证完整表象变换的固定。**