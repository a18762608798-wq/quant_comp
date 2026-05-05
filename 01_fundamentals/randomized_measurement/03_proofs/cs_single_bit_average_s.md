Known

$$
\mathbb E_{\vec n}\left[  
\sum_{\pm}  
\operatorname{tr}\bigl(\hat P_{\pm}\hat \rho \bigr)\widetilde\rho(\pm)  
\right].
$$

Where

$$
\begin{cases}
tr(\hat P_{\pm} \hat \rho^) = \frac{1}{2}(1 \pm \vec r \cdot \vec n)\\
\widetilde \rho(\pm) = 3(\frac{1}{2}(I \pm \vec n\cdot \vec \sigma)) - I = \frac{1}{2} I \pm \frac{3}{2} \vec n\cdot \vec \sigma,
\end{cases}
$$
therefore

$$
\sum_\pm \frac{1}{2}(1 \pm \vec r \cdot \vec n)(\frac{1}{2} I \pm \frac{3}{2} \vec n\cdot \vec \sigma) = \frac{1}{2} I + \frac{3}{2} (\vec r\cdot \vec n)(\vec n\cdot \vec \sigma)
$$

whereite_indi

$$
\mathbb E_{\vec n} [(\vec r \cdot \vec n)(\vec n \cdot \vec{ \sigma})] = E_{\vec n}[(\vec r \cdot \vec n)\vec n] \cdot \vec{\hat \sigma},
$$

also

$$
\mathbb E_{\vec n}[(\vec r\cdot {\vec n)\vec n})_j] = r_i \mathbb E_{\vec n}[n_in_j]
$$

If $i=j$, since $n_in_i = 1$

$$
\mathbb E_{\vec n}[n_in_j] = \frac{1}{3}\quad (i = j),
$$

if $i \neq j$, $f(x, y, z) = xy = - f(x, -y, z)$, the sphere is symmetric about the x-o-z. therefore

$$
\mathbb E_{\vec n}[n_in_j] = 0 \quad (i \neq j),
$$

in conclusion,

$$
\mathbb E_{\vec n}[n_i n_j] = \frac{1}{3}\delta_{ij} \Rightarrow \mathbb E_{\vec n} [(\vec r \cdot \vec n)(\vec n \cdot \vec{ \sigma})] = \frac{1}{3} \vec r\cdot \vec \sigma
$$

Viz.,

$$
\mathbb E_{\vec n}\left[  
\sum_{\pm}  
\operatorname{tr}\bigl(\hat P_{\pm}\hat \rho(\pm) \bigr)\widetilde\rho
\right]
=  \frac{1}{2} I + \frac{1}{2} \vec r\cdot \vec\sigma = \rho
.  
$$
Clifford unitaries could be proof as follow, just exchange $\vec n$ as discrete value.

<span style="color:red">However, are the averages over U and the averages over n truly equal?</span>

In math which is clearly

$$
P(s) = U^\dagger |s\rangle\langle s|U,
$$

where

$$
U(\theta, \varphi, \lambda) = \exp\bigr[{\frac{\varphi+\lambda}{2}}\bigr] R_Z(\varphi) R_Y(\theta) R_Z(\lambda)
$$

therefore $\varphi$ is unused. $\widetilde \rho(\pm)$ is simiar as follow.

Viz., **a single vector $\vec n$ does not utilize all the symmetries of $SU_2$**.