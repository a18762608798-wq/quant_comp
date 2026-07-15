# native quant comp csco

量子电路原生表象显然是 Z 表象，所以其对易组可以取：

$$
[IZ, ZI, ZZ, II]
$$

在这里，需要的独立组只有两个，一般取 CSCO:

$$
[IZ, ZI]
$$

注意 $II = (IZ)^2 = (ZI)^2$ 一定不独立.

由此：**对测量基的旋转本质上是对CSCO空间旋转**, 如果旋转操作取 Cliffford groups, 旋转前后可以保证CSCO都是 pauli operators, 测量基则恒为 pauli bases 的共同本征态.
