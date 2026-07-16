# native quant comp csco

量子电路原生测量基对应的表象显然是 Z 表象，所以其对易组可以取：

$$
[IZ, ZI, ZZ, II]
$$

也就是可以直接测量的 pauli bases 内容; 在这里，需要的独立组只有两个，一般取 CSCO:

$$
[IZ, ZI]
$$

注意 $II = (IZ)^2 = (ZI)^2$ 一定不独立.

由此：**对测量基的旋转本质上是对CSCO测量基空间旋转**, 如果旋转操作取 Cliffford groups, 旋转前后可以保证可以直接测量的CSCO都是 pauli operators, 测量基则恒为 pauli bases 的共同本征态.
