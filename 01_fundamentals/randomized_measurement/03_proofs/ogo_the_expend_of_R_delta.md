
$$
R_X(-\delta) R_Z(\alpha) R_X(\delta) R_Z(\beta)
$$

since

$$
P_\pm = U^\dagger [\frac{1}{2}(I \pm Z)]U = \frac{1}{2} [I + U^\dagger Z U] = \frac{1}{2}(I +\vec r \cdot \vec \sigma)
$$

where

$$
\begin{cases}
x = −sinδ[sinαcosβ−cosδ(1−cosα)sinβ],\\
y = sinδ[sinαsinβ+cosδ(1−cosα)cosβ],\\
z=cos^2δ+sin⁡^2δcos⁡α.\\
\end{cases}
$$

==Evidenly z is indepencent with $\beta$, so the joint probability distribution of $f(z, \beta)$ could be breaken to $f(z)f(\beta)$==

The relationship is still valid as follow.

$$
\sum_\pm \frac{1}{2}(1 \pm \vec r \cdot \vec n)(\frac{1}{2} I \pm \frac{3}{2} \vec n\cdot \vec \sigma) = \frac{1}{2} I + \frac{3}{2} (\vec r\cdot \vec n)(\vec n\cdot \vec \sigma)
$$

**Accroding to the last step of $R_z$, It still has U(1) symmetry around Z.** (independent with$\beta$)

Since

$$
\begin{cases}
\mathbb E[n_i] = \mathbb E_z[\mathbb E[n_i|z]]\\
\mathbb E[n_i] = \mathbb E_z[\mathbb E[n_in_j|z]] 
\end{cases}
$$

where

$$
\begin{cases}
\mathbb E[n_i|z] = \delta_{iz}z\\
\mathbb E[n_in_j|z] = diag\bigr(\frac{1 - z^2}{2}, \frac{1 - z^2}{2}, z^2 \bigr)
\end{cases}
$$

therefore

$$
\begin{cases}
\mathbb E[n_i] = \delta_{iz} \mathbb E[z] \\
\mathbb E[n_in_j] = diag\bigr(\frac{1 - \mathbb E [z^2]}{2}, \frac{1 - \mathbb E[z^2]}{2}, \mathbb E[z^2] \bigr)
\end{cases}
$$

To get the target

$$
\begin{cases}
\mathbb E[n_i] = 0\\
\mathbb E[n_in_j] = \frac{1}{3}\delta_{ij}
\end{cases}
$$

Let

$$
\begin{cases}
\mathbb E[z] = 0\\
\mathbb E[z^2] = \frac{1}{3} 
\end{cases} 
$$

If z is uniform this is impossible, but we could importace samping, satifty,

$$
\begin{cases}
\int f(z) dz = 1\\
\int f(z)z dz= 0\\
\int f(z) z^2 dz = 2/3*1/2
\end{cases}
$$

For instance, just choose two parallels of latitude, let $z_1 = 1$

there are

$$
\begin{cases}
p_1+p_2 = 1\\
p_1 z_1 + p_2z_2 = 0\\
p_1z_1^2 + p_2 z_2^2 = \frac{1}{3}
\end{cases}
$$
so

$$
\begin{cases}
z_1 = 1; p_1 = 1/4\\
z_2 = -\frac{1}{3}; p_2 = 3/4
\end{cases}
$$

Inverse solution $\alpha$ and $\beta$, evidently $f(n) dn = f(z)f(\beta) dz d\beta$

$$
\beta \in [0, 2\pi], \quad \text{uniform}
$$

when $z_1 = 1$ there are $\alpha_1 = 0, p_1 = \frac{1}{4}$.

when $z_2 = -1/3$ there are 

$$
\alpha_2 = \arccos \bigr[\frac{-1/3 - \cos^2\delta}{\sin^2\delta}\bigr ],p_2 = \frac{3}{4}
$$

**The limitation**: From the satisfaction of the expected relation and the constraint of z values ​​on δ. 




