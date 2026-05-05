# review

其中每一层的职责是：

| 目录             | 用途              |
| -------------- | --------------- |
| `00_inbox`     | 临时笔记、未整理问题      |
| `01_setup`     | 安装、环境、账号、版本     |
| `02_concepts`  | 量子计算基础概念        |
| `03_core`      | Qiskit 最核心对象和机制 |
| `04_workflows` | 按“做一件事”的流程整理    |
| `05_projects`  | 完整案例和实验项目       |
| `06_debugging` | 报错、坑、排错经验       |
| `07_reference` | 速查表、术语表、链接      |
| `99_index`     | 总索引、学习路线、主题地图   |

我个人最推荐这个精简版：

```text
qiskit_note/
├── 00_inbox
├── 01_setup
├── 02_concepts
├── 03_core_api
├── 04_workflows
├── 05_projects
├── 06_debugging
├── 07_reference
└── 99_index
```

```text
03_api/
├── circuit/
│   ├── QuantumCircuit.md
│   ├── Gate.md
│   └── Parameter.md
├── quantum_info/
│   ├── Statevector.md
│   ├── DensityMatrix.md
│   └── SparsePauliOp.md
├── transpiler/
│   ├── transpile.md
│   └── PassManager.md
├── primitives/
│   ├── Sampler.md
│   └── Estimator.md
├── backends/
│   ├── AerSimulator.md
    ├── Quark.md
    └── QiskitRuntimeService.md
```
