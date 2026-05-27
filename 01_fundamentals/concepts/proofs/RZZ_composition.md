
Target

$$
CX(I \otimes R_Z)CX = R_{ZZ}
$$

Evidently

$$
I \otimes \exp(A) = I \otimes \sum_n C_n A^n = \sum_n C_n (I^n \otimes A^n) = \sum_n C_n (I \otimes A)^n = \exp(I \otimes A)
$$

also

$$
U^\dagger \exp(I \otimes A) U = \exp [U^\dagger (I \otimes A) U],
$$

so we only shout to proof 

$$
CX^\dagger (I \otimes Z)CX = ZZ
$$

Kown

$$
\begin{cases}
CX|ab\rangle = |a(a \oplus b)\rangle\\
Z|a\rangle = (-1)^a |a\rangle
\end{cases}
$$

Therefore

$$
CX(I \otimes Z)CX^\dagger |ab\rangle = CX(I\otimes Z) |a(a\oplus b)\rangle = (-1)^{a\oplus b} |a(a\oplus (a\oplus b))\rangle = (-1)^{a+b} |ab\rangle = ZZ|ab\rangle
$$

QED.

Similarly

$$
\begin{cases}
Z \otimes I \Rightarrow ZI\\
I \otimes X \Rightarrow IX\\
X \otimes I \Rightarrow XX\\
Y \otimes I \Rightarrow YX\\
I \otimes Y \Rightarrow ZY\\
\end{cases}
$$

