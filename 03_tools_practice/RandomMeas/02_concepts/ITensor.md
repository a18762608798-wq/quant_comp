# ITensor

## operator

### Definition

对于任意两个空间态的线性映射，其实是对bases的映射。

$$
F(e_{1s_1}\otimes e_{2s_2}...) = F^{s_1's_2'...}_{s_1s_2...}e_{1s_1'}'\otimes e_{2s_2'}'...
$$

对应 dirac 符号

$$
|e_{1s_1}\otimes e_{2s_2}...\rangle = \sum_{s_1's_2'...} F^{s_1's_2'...}_{s_1s_2...}|e_{1s_1'}'\otimes e_{2s_2'}'...\rangle
$$

或者写成

$$
F = F_{s_1s_2...}^{s_1's_2'...}(e_{1s_1'}'\otimes e_{2s_2'}'...)\otimes(e_1^{s_1}\otimes e_2^{s_2}...)
$$

对应 dirac 符号

$$
F = \sum_{s_1's_2'...;s_1,s_2} F_{s_1s_2...}^{s_1's_2'...} |e_{1s_1'}'\otimes e_{2s_2'}'...\rangle\langle e_{1s_1}\otimes e_{2s_2}...|
$$

但是有两点：

* 这里的空间 bases 不一定非要是同一组。
* 这里F的指标的排布也不一定非要是这种自然的输入输出向对应的“槽位"，这只是一个标记，没有特殊属性，只是一般我们会取同一个比特的下标为 $s_i$ 和 $s_i'$

对于量子态，有

$$
\psi = \psi^{s_1s_2...}e_{1s_1}\otimes e_{2s_2}...
$$

### qubits room

#### concept

显然上述指标对应每个比特的指标

$$
s_i', s_i
$$

也代表了空间顺序按照比特直积分排列, 默认的正常的槽位也是如此。

#### cases

For instance, 对于坐标视角

$$
tr(\rho R_I) = \langle \psi|SWAP|\psi\rangle = \psi_{s_1's_2'...}S^{s_1's_2'...}_{s_1s_2....}\psi^{s_1s_2...}
$$

Where

$$
S = \bigotimes\limits_{n=1}^N S_n \Rightarrow S_{s_1s_2...}^{s_1's_2'...} = \prod_{n=1}^N S_{ns_ns_{2N -n +1}}^{s_n's_{2N-n+1}'} = \prod_{n=1}^N \delta_{s_n's_{2N-n+1}}\delta_{s_{2N-n+1}'s_n},
$$

So

$$
expr = \psi_{s_1's_2'...}\psi^{s_{2N}'s_{2N-1}'...}
$$

**这里交换算符的张量元素写成连乘事实上和空间顺序无关, prod 张量算符本身就有相同的交换效果。

对于 bases 视角

$$
\langle \psi |S|\psi\rangle = \langle \psi| S|ab\rangle \langle ab|\psi\rangle = \langle \psi|ba\rangle \langle ab|\psi\rangle = \langle \psi|ab\rangle\langle ba|\psi\rangle
$$
