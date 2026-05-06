# CS U(2) of Multiple Qubits

## 二阶映射量

由于四个系数A可以被估计量反解只需要四个估计量，A覆盖了pair系统的所有泡利基，所以最一般的pair估计量（足够表达n可以表达的所有态）形如
 
$$
\widetilde\rho_{ss'}(\vec n) = A_0(\vec n) + \eta_s A_1(\vec n) + \eta_{s'}A_2(\vec n) + \eta_s\eta_{s'}A_{12}(\vec n)
$$

这个形式涵盖了估计算符的所有基。投影算符形如

$$
P_s(\vec n) =
\frac12(I+\eta_s\vec n\cdot\vec\sigma),  
\qquad  
\eta_0=+1,\quad \eta_1=-1.  
$$

只要算 Pauli 基

$$
II,\quad \sigma_i I,\quad I\sigma_j,\quad \sigma_i\sigma_j  
$$

定义测量-重构通道

$$
\tau(A)=
\mathbb E_{\vec n}  
\left[  
\sum_{s,s'}  
tr\left(P_{ss'}(\vec n)A\right)  
\widetilde\rho_{ss'}(\vec n)  
\right].  
$$

其中

$$
P_{ss'}=P_s\otimes P_{s'}.  
$$

Thereof,


$$
\begin{cases}
\tau(II)= \mathbb E_{n}[4A_0(n)]\\
\tau(\sigma_i I) =  \mathbb E_{n}[4n_iA_1(n)]\\
\tau(I\sigma_j)=\mathbb E_{n}[4n_jA_2(n)]\\
\tau(\sigma_i\sigma_j) = \mathbb E_{n} [4n_in_j A_{12}(n)]
\end{cases}
$$

Target: $\tau (R) = R$, evidently

$$
\begin{split}
A_0 &= \frac{1}{4} II\\
A_1 &= \frac{3}{4} n_j \sigma_j I\\
A_2 &= \frac{3}{4} I n_i \sigma_i\\
\end{split}
$$

But how to meet the condition of $\sigma_i \sigma_j$ ?

$$
\tau(\sigma_i\sigma_j) = \mathbb E_{n} [4n_in_j A_{12}(n)] = \mathbb E_n [4n_jn_i A_{12}(n)] = \tau(\sigma_j \sigma_i)
$$

如果我们可以做到 $\tau(\sigma_i\sigma_j) = \sigma_i\sigma_j$ ，

对于 $i \neq j$ 上式显然矛盾。

所以我们无法完全恢复二体pauli operators. 或者说：

$$
\tau(\sigma_i\sigma_j - \sigma_j\sigma_i) = 0
$$

**也就是反对称部分没有逆向通道**

also

$$
\sigma_i\sigma_j = \frac{1}{2}[\sigma_i\sigma_j + \sigma_j\sigma_i + (\sigma_i\sigma_j - \sigma_j\sigma_i)]
$$

so

$$
\tau(\sigma_i\sigma_j) = \tau[\frac{1}{2}(\sigma_i\sigma_j + \sigma_j \sigma_i)]
$$

反正反对称映射全丢失，干脆让对称部分无偏，Let the result is $\frac{1}{2}(\sigma_i\sigma_j + \sigma_j \sigma_i)$, Viz.,

$$
\tau((\sigma_i\sigma_j)^S) = \tau[\frac{1}{2}(\sigma_i\sigma_j + \sigma_j \sigma_i)] =  \frac{1}{2}(\sigma_i\sigma_j + \sigma_j\sigma_i)
$$

where

$$
A_{12} = \frac{15}{8}n_k\sigma_kn_l\sigma_l - \frac{3}{8} \sigma_\mu\sigma_\mu
$$

所以对于任何对称的泡利基，可以正确映射。否则无法得到态。同样的，对于所需估计力学量也是如此，只能命中对称的组分。

## 推广

$$
\tau(\sigma_i\sigma_j\sigma_k\sigma_l...) = \mathbb E_{n} [n_in_jn_kn_l... A_{1234...}(n)]
$$

考虑到 $n_i, n_j, n_k,...$ 顺序随便换，所以左边也随便换

所以

$$
\tau(\sigma_i\sigma_j\sigma_k\sigma_l...) = \tau(a)\quad a \in S = Perm(\sigma_i,\sigma_j,\sigma_k,\sigma_l,...)
$$

其中Perm表示全排列，则若算符F满足

$$
\tau(F) = F
$$

一定需要所有的组分F'满足

$$
F' = \frac{1}{|S|}\sum_{a\in S} a
$$

Case:

对于XXYY分量，必然绑定XYYX分量。


