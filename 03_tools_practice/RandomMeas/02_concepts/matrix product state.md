
> 我对此知之甚少，需要解答。

设有 $N$ 个 qubit，一个态

$$
|\psi\rangle

\sum_{i_1,\dots,i_N=0}^{1}
c_{i_1\dots i_N}
|i_1\dots i_N\rangle
$$

如果它是 **bond dimension (D=2) 的 MPS**，意思是这些系数可以写成

$$
c_{i_1\dots i_N} =
A^{[1]}*{i_1}
A^{[2]}*{i_2}
\cdots
A^{[N]}_{i_N}
$$

其中每个 $$A^{[k]}_{i_k}$$ 是矩阵，并且中间矩阵的维度最多是 (2\times 2)。

更明确地写：

$$
A^{[1]}_{i_1} \in \mathbb{C}^{1\times 2}
$$

$$
A^{[k]}_{i_k} \in \mathbb{C}^{2\times 2},
\quad 2\le k\le N-1
$$

$$
A^{[N]}_{i_N} \in \mathbb{C}^{2\times 1}
$$

---

等价地说，bond dimension (D=2) 的数学定义是：

 对任意切分
 
$$
 1,\dots,k \mid k+1,\dots,N
$$ 
这个态的 Schmidt rank 最多是 2。

也就是说它总能写成

$$
|\psi\rangle =
\lambda_1 |L_1\rangle |R_1\rangle +
\lambda_2 |L_2\rangle |R_2\rangle
$$

最多两个项。
