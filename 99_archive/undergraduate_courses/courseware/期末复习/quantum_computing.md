# the Revive of Quantum Computing

## $\S 0$ 选择填空题

### $0.0$ 傻瓜记忆型

* 经典计算机的物理基础是?

<details>
<summary>折叠答案</summary><br>
量子力学原理
</details>
* 量子计算机离我们有多有远?

<details>
<summary>折叠答案</summary><br>
通用容错的量子计算机还在起步.
</details>

* BB84协议提出年份?

### $0.1$ <font color=red>强行记忆型</font>

* 量子科技的主要研究方向? 

<details>
<summary>折叠答案</summary><br>
量子通信,量子精密测量,量子模拟与计算
</details>

* 墨子号的任务

<details>
<summary>折叠答案</summary><br>
量子隐形传态,量子密钥分发,纠缠分发和验证贝尔不等式的破坏
</details>

* 量子计算机算法分类

<details>
<summary>折叠答案</summary><br>
1. 量子傅里叶变换: 所有量子算法指数加速的核心
2. 量子搜索
3. 量子模拟
</details>

* 量子计算的三个历程碑

<details>
<summary>折叠答案</summary><br>
1. Google 量子霸权
2. 量子纠错超过阈值
3. 原子阵列的逻辑门操作
</details>

* HHL算法的三大模块

<details>
<summary>折叠答案</summary><br>
1. 量子相位估计2. 受控旋转3. 逆量子相位估计
</details>

### $0.2$ 理论支持型

* 量子计算机核心零件?量子计算的逻辑门操作是一种什么操作?

<details>
<summary>折叠答案</summary><br>
1. 量子比特; 2. 量子比特在Bloch球上做幺正变换
</details>

* 量子计算和量子信息可进行的核心量子力学原理是?

<details>
<summary>折叠答案</summary><br>
1. 量子态的叠加性;2. 坍缩
</details>

* <font color=orange>常用的gate有那些?作用是?</font>

<details>
<summary>折叠答案</summary><br>
单比特基本的有U=I,X,Z,XZ,集成的有H; 多比特有C-NOT gate; 任何多量⼦⽐特逻辑⻔可以由单⽐特量⼦⻔和受控⾮⻔（C-NOT）组成。
</details>
$$
Z=\begin{Bmatrix}
1,0\\
0,-1
\end{Bmatrix}
$$

* 以纠缠分发进行量子加密,若第三方Eve全程监听,会在生钥中产生多少错误率?

<details>
<summary>折叠答案</summary><br>
1/4
</details>

* <font color=blue>贝尔不等式的破坏体现在?这说明什么?怎么利用此特性?</font>

<details>
<summary>折叠答案</summary><br>
实验中不等式的左端可以大于2,说明即所谓基本独立事件不独立,测量引起坍缩; 量子力学不是定域且实在的; 量子密钥分发
</details>

## $\S 1$ 简答证明题

* <font color=blue>如何制备贝尔态?</font>

<details>
<summary>折叠答案</summary><br>
需要两个比特的直积态,分别经过一个H-gate和一个CNOT-gate即可.
</details>

* <font color=red>量子比特"复制"电路:</font>

假设此门为G操作效果为 $\hat G\ket{\psi}\otimes\ket{0}=\ket{\psi}\otimes\ket{\psi}$ 以实现复制的效果. 其中第一位为复制目标,第二位为预复制空位.

1. 证明<font color=red>量子不可克隆原理</font>.

假设有:
$$
\begin{cases}
G\ket{00}=G\ket{00}\\
G\ket{10}=G\ket{11}\\
\end{cases}
$$
那么很容易发现,下面这个功能是无法实现的.
$$
G(\ket{00}+\ket{10})\ne(\ket{0}+\ket{1})\otimes(\ket{0}+\ket{1})
$$
此复制门无法同时满足(1)和(2), 即量子态不可克隆

2. 那这个"复制"的效果是如何达到的?

<details>
<summary>折叠答案</summary><br>
我们所谓复制会多一个比特位.从前文可看出,复制的是 $\ket{00}+\ket{11}$ 这种高度纠缠态.
</details>
* 直积态和纠缠态的辨别,证明态为纠缠态

## $\S2$ 大题

* 运算量子隐形传态的步骤

<img src="/home/Hanyijie/Nutstore Files/我的坚果云/Physics/contemporary_physics/quantum_computation/courseware/期末复习/量子隐形传态.png" alt="量子隐形传态" style="zoom:50%;" />

显然他只会考前两个比特.我们以 $\ket{\beta_{00}}$ 为例, 在双 $\sigma_z$ 表象下展开. 
$$
\ket{\psi_{0}}=\ket{\beta_{00}}=\begin{Bmatrix}
1\\
0\\
0\\
0
\end{Bmatrix}
$$
 furthermore, C-NOT gate和H gate的写法也可知.
$$
CNOT(1,0)=\begin{Bmatrix}
I,O\\
O,X
\end{Bmatrix};\quad
H(0)=\frac{1}{\sqrt 2}\begin{Bmatrix}
1,\quad1\\
1,-1
\end{Bmatrix}\otimes I=\frac{1}{\sqrt 2}\begin{Bmatrix}
I,\quad I\\
I,-I
\end{Bmatrix}
$$
由此 $\ket{\psi_2}$ 可以做矩阵乘法 
$$
\ket{\psi_2}=CNOT(1,0)H(0)\ket{\beta_{00}}=\frac{1}{\sqrt 2}\begin{Bmatrix}
1\\
1\\
0\\
0
\end{Bmatrix}
$$


* 交换门运算

交换门由三个CNOT组成.
$$
CNOT(1,0)CNOT(0,1)CNOT(1,0)
$$
输入态以 $\ket{\psi_0}=\ket{01}$ 为例,交换门算符非常显然:
$$
Exchange=\begin{Bmatrix}
1,0,0,0\\
0,0,1,0\\
0,1,0,0\\
0,0,0,1
\end{Bmatrix}
$$
结果亦然:
$$
\ket{\psi_1}=\begin{Bmatrix}
0\\
0\\
1\\
0
\end{Bmatrix}=\ket{10}
$$
