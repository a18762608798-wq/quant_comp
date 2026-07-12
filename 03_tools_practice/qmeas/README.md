# qmeas

量子测量工具箱。目前包含随机测量（经典影子）子模块 `qmeas.random`，支持在 Qiskit Aer（本地）或 quarkstudio（远程云）上运行。

## 从 GitHub 安装

仓库：`a18762608798-wq/quant_comp`，包位于子目录 `03_tools_practice/qmeas`。

### Python venv

revised the `python3` to the specific python path.

```bash
python3 -m venv .venv
source .venv/bin/activate
```

```bash
python3 -m pip install --upgrade --force-reinstall "git+https://github.com/a18762608798-wq/quant_comp.git@main#subdirectory=03_tools_practice/qmeas"
```

本地克隆后可编辑安装：

```bash
python3 -m pip install -e ./03_tools_practice/qmeas
```

更新：

```bash
pip install --upgrade "git+https://github.com/a18762608798-wq/quant_comp.git@main#subdirectory=03_tools_practice/qmeas"
```

### Julia（通过 CondaPkg.jl）

```julia
using CondaPkg

CondaPkg.add("pip")

url = "git+https://github.com/a18762608798-wq/quant_comp.git@main#subdirectory=03_tools_practice/qmeas"

CondaPkg.withenv() do
    python3 = CondaPkg.which("python3")
    run(`$python3 -m pip install --upgrade --force-reinstall $url`)
end
```

本地可编辑安装：

```julia
using CondaPkg

CondaPkg.rm_pip("qmeas")
CondaPkg.add_pip(
    "qmeas";
    version="@ .",
    editable=true,
)
```

更新：

```julia
using CondaPkg

url = "git+https://github.com/a18762608798-wq/quant_comp.git@main#subdirectory=03_tools_practice/qmeas"

CondaPkg.withenv() do
    python3 = CondaPkg.which("python3")
    run(`$python3 -m pip install --upgrade --force-reinstall --no-cache-dir $url`)
end
```

## 使用

```python
from qmeas.random import RandomMeasConfig, AerOptions, run_pipeline
```
