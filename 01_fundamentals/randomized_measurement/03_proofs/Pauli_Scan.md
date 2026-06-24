Known

$$
o = \sum_P c_P \overline p = \sum_P c_P \frac{1}{3^{N-w}} \sum_{B:P\preceq B} \frac{1}{K'}\sum_{k'} y_P(s^{(k')}) = \frac{1}{3^N}\sum_{B}\frac{1}{K'} \sum_{k'} X_O(B, s^{(B, k')})
$$

Where

$$
\begin{cases}
X_O(B, s) = \sum_{P\preceq B} 3^\omega c_P y_P(s) = \sum_{P} 3^\omega 1_{P\preceq B} c_P y_P(s)\\
K' = \frac{K}{3^N}
\end{cases}
$$

B is total nontrival pauli bases.

一般计算的时候的顺序应该是

$$
o = \frac{1}{K} \sum_{k'}\sum_{P}3^\omega c_P \sum_B 1_{P\preceq B} \prod_i s_i(B, k') 
$$

这里把 $k'$ 放在外面主要的目的是方便估计误差。