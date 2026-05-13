# ITensor

相比于 MPO 这就是纯粹的带指标张量，或者说 ITensor 是 MPO 的基本单元。

MPO 的乘法本质上是内部 ITensor 的收缩；ITensor 和 MPO 相乘也是如此。

**但是需要注意，MPO终归是个矩阵，缩并联合指标必须相同，不能错位相连。** ITensor 本身对指标求和就没有顺序概念,  随便连, 但本质上等于平行相连的MPO。