# ITensor

## operator

### Definition

对于任意两个空间态的线性映射，其实是对bases的映射。

$$
F(e_{1s_1}\otimes e_{2s_2}...) = F^{s_1's_2'...}_{s_1s_2...}e_{1s_1'}'\otimes e_{2s_2'}'...
$$

或者写成

$$
F = F_{s_1s_2...}^{s_1's_2'...}(e_{1s_1'}'\otimes e_{2s_2'}'...)\otimes(e_1^{s_1}\otimes e_2^{s_2}...)
$$

但是有两点：

* 这里的空间 bases 不一定非要是同一组。
* 这里F的指标的排布也不一定非要是这种自然的和空间顺序对应的“槽位”。可以随便更换指标槽位但是对应的数值也需要交换。

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

For instance,

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

注意空间的bases顺序从未改变。一般依然是默认的(1, 2, 3,..., 2N)