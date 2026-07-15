# haar

Haar 随机酉不是“Haar 群”，而是指在整个 $U(2)$ 或 $U(2^n)$ 上按 Haar 测度均匀随机抽样. Haar 对应从完整的 U(2)U(2)U(2) 连续空间中随机取一个真正任意的单比特酉变换, **整体相位也包含在内**.

pauli measurement 设置的变换只用从 z 到 x, y,z 就可以了. 区分符号也只有6种；实际上RadomMeas.jl只设置了3种。(这个定义不统一，有的人甚至拿这个区分global 和 local cfifford)


