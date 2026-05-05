VQA**和量子退火

- 陷入贫瘠高原（训练类算法），要么
- 能隙指数小（绝热类算法），要么
- I/O 开销吃掉一切（HHL 类）。

## 量子退火
**量子退火是物理系统直接编码问题，不依赖量子门**，靠**重复采样**提高得到好解的概率，本质是**启发式方法**，非理论保证的优化算法。

问题：**模拟退火时间指数增加，**


## VQA

离散绝热演化，但一是不能确定是否有优势，而是layer随n指数爆炸，训练复杂度相对于经典毫无优势，即使比特数少。
二是Barren plateaus 被严格证明导致cost function梯度方差指数衰减，这点无法被绝热演化弥补。

总之对于大概50以下的NP-hard问题，经典算法虽然无法暴力计算，但是近似解也比vqa的解好。

## 补充：
"没有近似算法的 NP-hard 问题"（MaxCut、TSP、3-SAT 等）几乎不存在

Barren plateaus核心就是：希尔伯特空间指数级大，看似能容纳超强表达能力；但当你用参数化量子电路去“探索”它时，损失函数（算符期望）在参数空间里几乎处处平坦——不是空间本身光滑，而是随机或过度自由的电路会让期望值“均匀分布”，导致梯度趋近于零。
参考：https://www.semanticscholar.org/paper/Barren-plateaus-in-quantum-neural-network-training-McClean-Boixo/d699e0958fe1d8a4c1d691765f7e11b823fa606f
## 方向：
1. 量子原生问题（模拟，AI for Quantum【贫瘠高原。。。】）
2. **容错纠错路径**：通过量子纠错将物理错误压至阈值下，实现任意长计算 → **原理已验证，但需10年以上工程突破**（**修得够及时，不让错误累积超标**， 等待也是错误。）

**NISQ = Noisy Intermediate-Scale Quantum**
**VQA**（Variational Quantum Algorithm）
**QAOA = Quantum Approximate Optimization Algorithm**  
（量子近似优化算法）