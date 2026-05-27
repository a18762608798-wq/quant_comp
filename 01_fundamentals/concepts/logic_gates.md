# logic gates

## single qubit

### X

Definition, flipped qubit 

$$
X = \begin{Bmatrix}
0 & 1\\
1 & 0
\end{Bmatrix}
$$

Y, Z is similar as X, we can think of them as NOT gates with rotation axes Y and Z. 

And there is a import relationship,

$$
Y = iXZ
$$

### H

Definition

$$
\begin{cases}
H |0\rangle = \frac{1}{\sqrt 2} (|0\rangle +|1\rangle)\\
H |1\rangle = \frac{1}{\sqrt 2} (|0\rangle - |1\rangle)
\end{cases},
$$

we can also think of it as a rotation $\pi$ with rotation of $\frac{X + Z}{\sqrt 2}$

### S

$$
S = \sqrt Z
$$

In qiskit we office tag it $Sdg$ .
### $R_n(\sigma)$

Definiton

$$
R_n(\alpha) = \exp (-\frac{i}{\hbar}\alpha j_n ) = \cos(\frac{\alpha}{2})I - i \sin(\frac{\alpha}{2}) \sigma_n =
\begin{Bmatrix}
\cos\frac{\alpha}{2}-i\cos\theta\sin\frac{\alpha}{2} & -i\sin\frac{\alpha}{2}\sin\theta e^{-i\varphi}\\
-i\sin\frac{\alpha}{2}\sin\theta e^{i\varphi} & \cos\frac{\alpha}{2}+i\cos\theta\sin\frac{\alpha}{2}
\end{Bmatrix}.
$$

### general form

$$
U_3(\theta, \varphi, \lambda) = \exp\bigr[{\frac{\varphi+\lambda}{2}}\bigr] R_Z(\varphi) R_Y(\theta) R_Z(\lambda) = \begin{Bmatrix}
\cos\frac{\theta}{2} & -e^{i\lambda} \sin \frac{\theta}{2}\\
e^{i\varphi}\sin\frac{\theta}{2} & e^{i(\varphi + \lambda)}\cos(\frac{\theta}{2})
\end{Bmatrix},
$$

where

$$
\begin{cases}
X = U_3(\pi, 0, \pi)\\
H = U_3(\frac{\pi}{2}, 0, \pi)
\end{cases}
$$

## mutiple qubits

### SWAP

#### Definition

$$
SWAP |mn\rangle = |nm\rangle
$$

Aslo,

$$
SWAP = C_1XC_2XC_1X
$$

pauli basic development

$$
SWAP = \sum_R tr(SWAP R) R,
$$

where

$$
\sum_{i_1j_1}\langle i_1 j_1|SWAP R|i_1j_1\rangle = \sum_{i_1j_1} \langle j_1i_1 |R_{1i}\otimes R_{2j}|i_1j_1\rangle = \sum_{i_1j_1} \langle j_1|R_{1i}|i_1\rangle \langle i_1| R_{2j} |j_1\rangle = \sum_{j_1} \langle j_1|R_{1i}R_{2j}|j_1\rangle = \delta_{ij},
$$

therefore

$$
SWAP = \sum_i R_{1i} \otimes R_{2i}
$$
#### Expansion

For n qubit, for instance

$$
SWAP = \sum_R R \otimes R = \Pi^\dagger [\bigotimes\limits_{n=1}^N R_{\mu_n}\otimes R_{\mu_n}]\Pi
$$

the proof is ref to [[Hamming_Core_Estimation]]

$\Pi$ is use to reorder Hilbert space, which change the room ordering $(1, ..., N, 1', ..., N')$ to $(1, 1', ..., N, N')$ (basic perspective)

So it mean that we exchange the state between two sub-system

$$
SWAP |\psi_1\rangle_A|\psi_2\rangle_B =  |\psi_2\rangle_A |\psi_1\rangle_B
$$

### C-NOT

Definition

$$
C-X |ab\rangle = |a a\oplus b\rangle
$$

therefore

$$
C-NOT = \begin{Bmatrix}
I_2 & O\\
O & X
\end{Bmatrix},
$$

when we change the room order, there are

$$
\langle i_1 j_1|SWAP F SWAP^\dagger|i_2j_2\rangle = \langle j_1i_1 | F |j_2 i_2\rangle
$$

### evolutionary gate

#### $RZZ$ and the expansion

Definition 

$$
R_{ZZ}(\alpha) = \exp\bigr[{i \frac{\alpha}{2} \sigma_z \otimes \sigma_z\bigr ]}
$$
Which could be combined with 

$$
(CX)R_Z(CX)
$$

proof ref to [[RZZ_composition]]

Now there are two extended questions, 

1. How to express the logic gates such as $R_{YY}$.
2. What will happen if we use two single rotating gate. 

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

<span style="color:red">NOTE: the form is not fixed, which own to the the phase degrees of freedom preceding different eigenvalues</span> . However, we usually stipulate that the first number to be taken is a real number. 

For the second question, for instance, we get $X$ and $Y$, there are

$$
\begin{aligned}
CX(R_X\otimes R_Y)CX^\dagger = CX (\exp(-i\frac{\alpha}{2} X \otimes I) \exp(-i \frac{\alpha}{2} I \otimes Y))CX^\dagger
\\= CX \exp(-i\frac{\alpha}{2} X \otimes I) CX^\dagger CX \exp(-i \frac{\alpha}{2} I \otimes Y)CX^\dagger
\end{aligned}
$$

where

$$
\exp(-i\frac{\alpha}{2} X \otimes I) \exp(-i \frac{\alpha}{2} I \otimes Y) = (A \otimes I)(I \otimes B) = A\otimes B
$$

Evidently which is a operation simlar as 

$$
R_{XX} R_{ZY}
$$

Which is noting to do with $R_{YY}$

#### general evolutionary gate

For

$$
\exp[\tau \int_0 ^t -i H(t') \delta t'] \xrightarrow[\delta t' \rightarrow 0]{} \prod_{n=0}^N \exp [-iH(t)\delta t],
$$

where

$$
\exp [-iH(t)\delta t] = \exp [-i\sum_Ptr(PH(t))P \delta t] \rightarrow \prod_P \exp[-i tr(PH)P\delta t] = \prod_R \exp [-i P\theta/2],
$$

where

$$
\exp[-iP\theta/2] = R_P(\theta)
$$

where $P$ is pauli bases, evidently,

$$
R_P(\theta) = U_{Z\rightarrow P}R_{ZZZ...}(\theta) U^\dagger_{Z\rightarrow P}.
$$

Now the only question is to contruct $R_{ZZZ}...$ . Ref to $RZZ$ .

$$
U (I^{\otimes N-1} \otimes R_Z(\theta)) U^\dagger = \exp[-iU(I^{\otimes N-1}\otimes Z) U^\dagger\theta /2)]
$$

So now our target is to find a U meet 

$$
U(I^{\otimes N-1}\otimes Z) U^\dagger = Z^{\otimes N}
$$

Evidently

$$
Z^{\otimes N} |s_1s_2,...\rangle = (-1)^{s_1+s_2...} |s_1s_2...\rangle
$$

This effect can be achieved by many different combinations of CNOT operations, for instance,

$$
\begin{aligned}
&U^\dagger Z_N\prod_i^{N-1} CX(i, i+1) |s_1s_2...\rangle\\
&= U^\dagger Z_N|s_1, (s_1 \oplus s_2), (s_1 \oplus s_2 \oplus s_3...)...\rangle \\ 
&=U^\dagger (-1)^{s_1+s_2...} |s_1, (s_1 \oplus s_2), (s_1 \oplus s_2 \oplus s_3...)...\rangle  \\
&= (-1)^{s_1+s_2+...} |s_1s_2...\rangle  \\
&= Z^{\otimes N}|s_1s_2...\rangle
\end{aligned}
$$

QED.

**Any CNOT combination can achieve this operation as long as the control and the transmission can reach the last qubit**.

## 表象变换

qiskit 规范是

$$
\begin{cases}
Z\rightarrow X := H\\
Z\rightarrow Y = SH或(\sqrt X)^\dagger
\end{cases}
$$

Where

$$
\begin{cases}
S = \sqrt Z\\
\sqrt X = HSH^\dagger
\end{cases}
$$