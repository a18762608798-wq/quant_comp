# AGENTS.md

## 架构

这是一个用于量子计算学习笔记的 **Obsidian 仓库**。没有单一项目 —— `03_tools_practice/` 下有三个独立的 Julia 环境，各自拥有独立的 `Project.toml`、`Manifest.toml`、`CondaPkg.toml`。不要在根目录寻找 `Project.toml`。

| 目录 | 用途 |
|---|---|
| `03_tools_practice/RandomMeas/` | 随机测量经典影子层析（Julia + Python） |
| `03_tools_practice/qiskit/` | Qiskit 工具 |
| `03_tools_practice/QuantumToolbox/` | 量子工具箱工具 |

大多数 `.md` 文件是个人笔记，非项目文档。数字前缀（00–99）遵循 Zettelkasten 编号惯例。

## RandomMeas 项目（`03_tools_practice/RandomMeas/`）

三层结构：

1. **`RandomMeas.jl`**（外部 Julia 包）—— 核心经典影子层析类型与算法
2. **`RandomMeasAdd`**（`08_RandomMeasAdd/src/`）—— 本地 Julia 模块，扩展了 jackknife 误差估计、具体可观测量估计（reflect、purity、Z_r），以及 ITensor 算符构造器
3. **`random_meas_runner`**（`09_random_meas_runner/src/`）—— Python 包，用于生成随机测量线路并在 Qiskit Aer（本地）或 quarkstudio（远程云）上运行

工作流：Python 创建线路 → 在 Aer/quarkstudio 上运行 → 保存 `.npz` → Julia 加载结果并计算影子估计值。

## 命令

```bash
# 激活 RandomMeas Julia 环境
cd 03_tools_practice/RandomMeas
julia --project=.

# 格式化 Julia 代码（blue 风格，92 字符边距）
julia --project=. -e 'using JuliaFormatter; format(".")'
```

## 测试

无正式测试框架。测试脚本是 `08_RandomMeasAdd/test/` 和 `09_random_meas_runner/test/` 中的手动运行脚本。每个脚本用 `include()` 加载模块，然后通过 `test_index` 整数变量选择测试用例。测试会加载 `04_workflow/b_data_acquisition/*.npz` 中的真实数据。

## 注意

- 每个 Julia 子项目是独立的，务必从对应目录用 `--project=.` 激活。
- `.CondaPkg/` 为自动生成且被 git 忽略。Python 依赖（qiskit、numpy 等）在 `CondaPkg.toml` 中声明，首次 `using PythonCall` 时自动解析。
- JuliaFormatter 使用 **blue** 风格（非默认的 YAS），边距 92。
- `09_random_meas_runner/` 需要设置 `PYTHONPATH` 或手动操作 `sys.path` 才能导入；测试脚本会手动处理。
