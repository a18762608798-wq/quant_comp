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

也就是如果只关心一个算符的变换，绕自身的自由度本身就无效果。只有对多个算符对采用同一个变换，才要考虑这些算符的相对位置不变性。**我们量子计算给了一个固定的约定就是为了保证完整表象变换的固定。**