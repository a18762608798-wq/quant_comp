# overall_gates_operation

## case with special global and local gates.

^16f9f0

Known

$$
R_Z(\varphi_n)R_X(\frac{\pi}{2})R_Z(\theta_n)R_X(-\frac{\pi}{2}) = R_Z(\varphi_n)R_Y(\theta_n).
$$

Target

$$
\text{uniform}\begin{cases}
\cos\theta_n \in [-1, 1]\\
\varphi_n \in [0,2\pi] 
\end{cases}
$$
Since

$$
\mathbb E_{U} [g(\vec n(U))] = \int_U g\bigr[\vec n(U)) f(U)\bigr] dU = \int_\Omega g[(\Omega)]f(\Omega) d\Omega
$$

where $f(\Omega) = \frac{1}{\Omega}$, therefore

$$
expr = - \frac{1}{\Omega} \iint g\bigr [\vec n(\theta, \varphi\bigr] d[\cos\theta]d\varphi = f(u, \varphi) \int_0^{2\pi} d\varphi\int_{-1}^{1}  g(\arccos u, \varphi)du
$$

where $u = \cos\theta$

After replacing it with $dud\varphi$, the probability density becomes constant (uniform), which is why uniform sampling can be performed directly.

## extension of global and local gates

### Only make a global and a local operation

If we total make the $U$ transform

$$
R_Z(\varphi)R_X(\theta) 
$$

OK, this is not a qualified $U$ because the independence of $U_i$ is violated.

### If the global gate angle is no special fixed

^3dfa54

$$
R_Z(\beta)R_X(\delta) R_Z(\alpha) R_X(-\delta)
$$

Which could preserving the independence of $U_i$, because $R_X(\delta)$ is constant.

Which will breaken the relationship.

$$
\begin{cases}
\mathbb E_{U}[{n_i}] = 0\\
\mathbb E_{U_i}[n_in_j] = \frac{1}{3} \delta_{ij}
\end{cases}
$$

* Hamming distance-based methods 
* Classic shadow methods

In fact, they are need to revised similarly.

Ref to [[ogo_the_expend_of_R_delta]]

### If the global gate angle is not equal

$$
R_Z(\beta)R_X(\delta_1) R_Z(\alpha) R_X(\delta_2)
$$

Think of the last operation $R_Z(\beta)$, The symmetry of $U_z(1)$  is still vaild.

Therefore I think the operation of [[ogo_the_expend_of_R_delta]] is still vaild, but the condition:

1. we must perform two local operations because of the freedom of $S^2$
2. keep $\delta_1$ and $\delta_2$ unchange.
3. Know specify values of $\delta_1$ and $\delta_2$

==So the conclusion is not fited to totally uncontrollable global gate==
