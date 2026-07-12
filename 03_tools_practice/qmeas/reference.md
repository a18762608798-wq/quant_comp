> 在现有四个文件的范围内，明确每个文件放什么 class、什么函数，以及分支应该在哪里发生。

核心划分只有四层：

```text
meas_config.py      只保存配置
params_setting.py   只生成测量参数
meas_runner.py      只执行电路
meas_pipeline.py    只串联流程、保存结果
```

其中：

* `random / condition` 属于**参数关联方式**；
* `haar / pauli / derandom` 属于**参数采样方式**；
* `Aer / Quark` 属于**执行后端**；
* `correction_input` 原样保留为 Quark 执行时的输入，不额外推断它的物理意义。

---

# 1. `meas_config.py`

文件：[meas_config.py](sandbox:/mnt/data/meas_config.py)

## 这个文件只放数据类

不放：

* 参数生成算法；
* Qiskit 电路操作；
* Aer 或 Quark 调用；
* JSON 保存；
* runner 判断。

建议有下面这些类型：

```python
from dataclasses import dataclass, field
from pathlib import Path
from typing import Any, Literal

from qiskit import QuantumCircuit
from qiskit.circuit import ParameterVector


MeasMode = Literal["independence", "pair"]
Ensemble = Literal["haar", "pauli", "derandom"]
```

## `SettingRun`

代替不明确的 `tuple`：

```python
@dataclass(frozen=True)
class SettingRun:
    setting_num: int
    shot_num: int
```

这样：

```python
setting_runs=[
    SettingRun(setting_num=100, shot_num=1024),
    SettingRun(setting_num=200, shot_num=2048),
]
```

比下面清楚：

```python
setting_pairs=[
    (100, 1024),
    (200, 2048),
]
```

## `AerOptions`

保留：

```python
@dataclass(frozen=True)
class AerOptions:
    method: str = "statevector"
    device: str = "CPU"
    precision: str = "single"
```

## `CorrectionInput`

保留你当前的定义和语义：

```python
@dataclass
class CorrectionInput:
    trivial_qc: QuantumCircuit | None = None
    trivial_parameter_binds: Any = None
    trivial_shot_num: int = 1024
```

这里不把它扩展成“纠错策略”，因为目前没有必要。

## `QuarkOptions`

```python
@dataclass
class QuarkOptions:
    chip: str = "Baihua"
    target_qubits: list[int] = field(default_factory=list)
    token: str = ""
    correction_input: CorrectionInput | None = None
```

## `RandomMeasConfig`

```python
@dataclass
class RandomMeasConfig:
    qc: QuantumCircuit
    setting_runs: list[SettingRun]
    meas_indices: list[int]

    runner_opts: AerOptions | QuarkOptions = field(
        default_factory=AerOptions
    )

     meas_mode: MeasMode = "independence"
    ensemble: Ensemble = "haar"

    params: list[ParameterVector] | None = None

    output_dir: Path = field(
        default_factory=lambda: Path("./data")
    )
    name: str = "experiment"

    extra: dict[str, Any] = field(default_factory=dict)

    def __post_init__(self) -> None:
        self.output_dir = Path(self.output_dir)

        if self.params is None:
            meas_num = len(self.meas_indices)
            self.params = [
                ParameterVector("theta", meas_num),
                ParameterVector("lambda", meas_num),
            ]

        if not self.setting_runs:
            raise ValueError("setting_runs cannot be empty")

        if not self.meas_indices:
            raise ValueError("meas_indices cannot be empty")
```

## 最终这个文件应该有

```text
MeasMode
Ensemble

SettingRun
AerOptions
CorrectionInput
QuarkOptions
RandomMeasConfig
```

除此之外不放其他函数。

---

# 2. `params_setting.py`

文件：[params_setting.py](sandbox:/mnt/data/params_setting.py)

这个文件只负责：

> 根据 `meas_mode + ensemble` 生成 Qiskit 的 `parameter_binds`。

你现在的问题主要在这里。

当前代码把：

```text
random × haar
random × pauli
random × derandom
condition × haar
condition × pauli
condition × derandom
```

全部展开了。

实际应该拆成两个维度：

```text
meas_mode 决定：哪些测量位共享参数
ensemble 决定：参数值怎么采样
```

不需要为每一种组合写一个 class。

## 类型定义

```python
from collections.abc import Callable
from dataclasses import dataclass
from itertools import product

import numpy as np
from qiskit.circuit import ParameterVector


ParameterBinds = list[dict]
ParameterGroups = list[tuple[int, ...]]

GroupBuilder = Callable[[int], ParameterGroups]
AngleSampler = Callable[
    [int, int, np.random.Generator],
    tuple[np.ndarray, np.ndarray],
]
```

## 常量

```python
PAULI_ROTATIONS = np.array(
    [
        [np.pi / 2, 0],
        [np.pi / 2, np.pi / 2],
        [0, 0],
    ],
    dtype=float,
)
```

---

## 第一类函数：测量位如何分组

### `_independent_groups`

对应你现在的 `random`：

```python
def _independent_groups(meas_num: int) -> ParameterGroups:
    return [(i,) for i in range(meas_num)]
```

例如四个测量位：

```text
[(0,), (1,), (2,), (3,)]
```

每一个位置独立生成参数。

### `_paired_groups`

对应你现在的 `condition`：

```python
def _paired_groups(meas_num: int) -> ParameterGroups:
    if meas_num % 2 != 0:
        raise ValueError(
            "condition mode requires an even number of measured qubits"
        )

    return [
        (i, i + 1)
        for i in range(0, meas_num, 2)
    ]
```

例如四个测量位：

```text
[(0, 1), (2, 3)]
```

同一组内的位置共享参数。

### 分组注册表

```python
GROUP_BUILDERS: dict[str, GroupBuilder] = {
     "independence": _independent_groups,
     "pair": _paired_groups,
}
```

以后增加新的参数关联方式，例如三元分组：

```python
def _triplet_groups(meas_num: int) -> ParameterGroups:
    ...
```

然后只增加：

```python
GROUP_BUILDERS["triplet"] = _triplet_groups
```

不需要修改 Haar、Pauli、derandom。

---

## 第二类函数：角度怎么生成

这些函数完全不知道 `random` 或 `condition`。

它们只接收：

```text
group_num
setting_num
rng
```

返回：

```text
theta.shape  == (group_num, setting_num)
lambda.shape == (group_num, setting_num)
```

### `_sample_haar`

```python
def _sample_haar(
    group_num: int,
    setting_num: int,
    rng: np.random.Generator,
) -> tuple[np.ndarray, np.ndarray]:
    theta = np.arccos(
        rng.uniform(
            -1.0,
            1.0,
            size=(group_num, setting_num),
        )
    )

    llambda = rng.uniform(
        0.0,
        2.0 * np.pi,
        size=(group_num, setting_num),
    )

    return theta, llambda
```

### `_sample_pauli`

```python
def _sample_pauli(
    group_num: int,
    setting_num: int,
    rng: np.random.Generator,
) -> tuple[np.ndarray, np.ndarray]:
    indices = rng.choice(
        3,
        size=(group_num, setting_num),
        replace=True,
    )

    theta = PAULI_ROTATIONS[indices, 0]
    llambda = PAULI_ROTATIONS[indices, 1]

    return theta, llambda
```

### `_sample_derandom`

```python
def _sample_derandom(
    group_num: int,
    setting_num: int,
    rng: np.random.Generator,
) -> tuple[np.ndarray, np.ndarray]:
    setting_upper = 3**group_num

    if setting_num > setting_upper:
        raise ValueError(
            f"setting_num={setting_num} exceeds 3^{group_num}"
        )

    all_bases = np.array(
        list(product(range(3), repeat=group_num)),
        dtype=int,
    )

    if setting_num == setting_upper:
        selected = all_bases
    else:
        selected_indices = rng.choice(
            setting_upper,
            size=setting_num,
            replace=False,
        )
        selected = all_bases[selected_indices]

    # selected shape: (setting_num, group_num)
    selected = selected.T

    theta = PAULI_ROTATIONS[selected, 0]
    llambda = PAULI_ROTATIONS[selected, 1]

    return theta, llambda
```

### 采样注册表

```python
ANGLE_SAMPLERS: dict[str, AngleSampler] = {
    "haar": _sample_haar,
    "pauli": _sample_pauli,
    "derandom": _sample_derandom,
}
```

---

## `ParameterGenerator`

这个文件只需要一个真正的 class：

```python
@dataclass
class ParameterGenerator:
    group_builder: GroupBuilder
    angle_sampler: AngleSampler
    rng: np.random.Generator

    def generate(
        self,
        params: list[ParameterVector],
        meas_indices: list[int],
        setting_num: int,
    ) -> ParameterBinds:
        meas_num = len(meas_indices)

        groups = self.group_builder(meas_num)

        group_theta, group_lambda = self.angle_sampler(
            len(groups),
            setting_num,
            self.rng,
        )

        theta_values, lambda_values = _expand_group_values(
            groups=groups,
            group_theta=group_theta,
            group_lambda=group_lambda,
            meas_num=meas_num,
            setting_num=setting_num,
        )

        return _to_parameter_binds(
            params=params,
            theta_values=theta_values,
            lambda_values=lambda_values,
        )
```

## `_expand_group_values`

把逻辑 group 参数复制到真实测量位置：

```python
def _expand_group_values(
    groups: ParameterGroups,
    group_theta: np.ndarray,
    group_lambda: np.ndarray,
    meas_num: int,
    setting_num: int,
) -> tuple[np.ndarray, np.ndarray]:
    theta_values = np.empty(
        (meas_num, setting_num),
        dtype=float,
    )
    lambda_values = np.empty(
        (meas_num, setting_num),
        dtype=float,
    )

    for group_idx, members in enumerate(groups):
        for meas_idx in members:
            theta_values[meas_idx] = group_theta[group_idx]
            lambda_values[meas_idx] = group_lambda[group_idx]

    return theta_values, lambda_values
```

## `_to_parameter_binds`

只负责转换成 Qiskit 格式：

```python
def _to_parameter_binds(
    params: list[ParameterVector],
    theta_values: np.ndarray,
    lambda_values: np.ndarray,
) -> ParameterBinds:
    theta, llambda = params
    meas_num = len(theta)

    binds = {
        theta[i]: theta_values[i].tolist()
        for i in range(meas_num)
    }

    binds.update(
        {
            llambda[i]: lambda_values[i].tolist()
            for i in range(meas_num)
        }
    )

    return [binds]
```

## `create_parameter_generator`

所有字符串判断集中在这个入口：

```python
def create_parameter_generator(
    meas_mode: str,
    ensemble: str,
    *,
    seed: int | None = None,
) -> ParameterGenerator:
    try:
        group_builder = GROUP_BUILDERS[meas_mode]
    except KeyError:
        raise ValueError(
            f"Unknown meas_mode: {meas_mode!r}. "
            f"Available: {list(GROUP_BUILDERS)}"
        ) from None

    try:
        angle_sampler = ANGLE_SAMPLERS[ensemble]
    except KeyError:
        raise ValueError(
            f"Unknown ensemble: {ensemble!r}. "
            f"Available: {list(ANGLE_SAMPLERS)}"
        ) from None

    return ParameterGenerator(
        group_builder=group_builder,
        angle_sampler=angle_sampler,
        rng=np.random.default_rng(seed),
    )
```

## 最终这个文件应该有

```text
常量：
    PAULI_ROTATIONS
    GROUP_BUILDERS
    ANGLE_SAMPLERS

class：
    ParameterGenerator

public function：
    create_parameter_generator()

private functions：
    _independent_groups()
    _paired_groups()

    _sample_haar()
    _sample_pauli()
    _sample_derandom()

    _expand_group_values()
    _to_parameter_binds()
```

不再保留：

```python
get_random_params()
get_condition_params()
```

因为这两个函数正是重复的来源。

---

# 3. `meas_runner.py`

文件：[meas_runner.py](sandbox:/mnt/data/meas_runner.py)

这个文件只负责：

* 添加测量门；
* Aer 执行；
* Quark 执行；
* 参数绑定和 QASM 转换；
* 返回统一结果。

它不负责：

* 选择 ensemble；
* 生成参数；
* 遍历所有 `setting_runs`；
* 写 JSON；
* 构造最终实验结果字典。

---

## `RunResult`

统一 Aer 和 Quark 的返回值：

```python
from dataclasses import dataclass


Counts = dict[str, int]


@dataclass
class RunResult:
    counts: list[Counts]
    trivial_counts: list[Counts] | None = None
```

这样 pipeline 不需要处理：

```python
Aer -> counts
Quark -> counts, trivial_counts
```

两者都返回 `RunResult`。

---

## `MeasurementRunner`

用 `Protocol` 描述统一接口：

```python
from typing import Protocol

from qiskit import QuantumCircuit


class MeasurementRunner(Protocol):
    async def run(
        self,
        qc: QuantumCircuit,
        parameter_binds: list[dict],
        setting_num: int,
        shot_num: int,
        *,
        name: str,
        correction_input: CorrectionInput | None = None,
    ) -> RunResult:
        ...
```

这不是复杂继承，只是规定 AerRunner 和 QuarkRunner 都提供同样的 `run()`。

---

## `AerRunner`

```python
class AerRunner:
    def __init__(self, options: AerOptions) -> None:
        self.options = options

    async def run(
        self,
        qc,
        parameter_binds,
        setting_num,
        shot_num,
        *,
        name,
        correction_input=None,
    ) -> RunResult:
        if correction_input is not None:
            raise ValueError(
                "AerRunner does not accept correction_input"
            )

        simulator = AerSimulator(
            method=self.options.method,
            device=self.options.device,
            precision=self.options.precision,
        )

        transpiled_qc = transpile(qc, simulator)

        job = simulator.run(
            transpiled_qc,
            shots=shot_num,
            parameter_binds=parameter_binds,
        )

        result = job.result()

        counts = []
        for setting_idx in range(setting_num):
            raw_count = result.get_counts(setting_idx)
            count = {
                bitstring[::-1]: value
                for bitstring, value in raw_count.items()
            }
            counts.append(count)

        return RunResult(counts=counts)
```

注意这里使用 Qiskit 的参数名：

```python
shots=shot_num
```

而不是：

```python
shot_num=shot_num
```

---

## `QuarkRunner`

把你现在的 `run_quark_qc()` 移进这个 class：

```python
class QuarkRunner:
    def __init__(self, options: QuarkOptions) -> None:
        self.options = options

    async def run(
        self,
        qc,
        parameter_binds,
        setting_num,
        shot_num,
        *,
        name,
        correction_input=None,
    ) -> RunResult:
        qasm2_strings = _bind_to_qasm2(
            qc,
            setting_num,
            parameter_binds,
        )

        trivial_qasm2_strings = None

        if correction_input is not None:
            trivial_qasm2_strings = _bind_to_qasm2(
                correction_input.trivial_qc,
                setting_num,
                correction_input.trivial_parameter_binds,
            )

        tasks = []

        for setting_idx, qasm2_string in enumerate(qasm2_strings):
            tasks.append(
                _submit_quark_task(
                    qasm2_string=qasm2_string,
                    shot_num=shot_num,
                    token=self.options.token,
                    chip=self.options.chip,
                    name=f"{name}_U{setting_idx}",
                    target_qubits=self.options.target_qubits,
                )
            )

            if trivial_qasm2_strings is not None:
                tasks.append(
                    _submit_quark_task(
                        qasm2_string=trivial_qasm2_strings[setting_idx],
                        shot_num=correction_input.trivial_shot_num,
                        token=self.options.token,
                        chip=self.options.chip,
                        name=f"{name}_calib_U{setting_idx}",
                        target_qubits=self.options.target_qubits,
                    )
                )

        results = await asyncio.gather(*tasks)

        if correction_input is None:
            return RunResult(counts=results)

        return RunResult(
            counts=results[0::2],
            trivial_counts=results[1::2],
        )
```

这段只是把你现有逻辑归到正确位置，没有改变其含义。

---

## `create_runner`

只在一个地方根据 options 类型构造 runner：

```python
def create_runner(
    options: AerOptions | QuarkOptions,
) -> MeasurementRunner:
    runner_types = {
        AerOptions: AerRunner,
        QuarkOptions: QuarkRunner,
    }

    try:
        runner_class = runner_types[type(options)]
    except KeyError:
        raise TypeError(
            f"Unsupported runner options: {type(options).__name__}"
        ) from None

    return runner_class(options)
```

这是唯一需要选择 runner 的地方。

pipeline 不再写：

```python
if isinstance(opts, AerOptions):
    ...
else:
    ...
```

---

## `add_meas`

保留为普通函数，因为它是无状态的电路变换：

```python
def add_meas(
    qc,
    params,
    meas_indices,
):
    ...
```

不需要为了所有东西都面向对象而创建 `MeasurementCircuitBuilder`。

---

## `_bind_to_qasm2`

代替当前 `_bound_param`：

```python
def _bind_to_qasm2(
    qc,
    setting_num,
    parameter_binds,
) -> list[str]:
    binds = parameter_binds[0]

    bound_circuits = [
        qc.assign_parameters(
            {
                parameter: values[setting_idx]
                for parameter, values in binds.items()
            }
        )
        for setting_idx in range(setting_num)
    ]

    return [
        qasm2.dumps(bound_qc)
        for bound_qc in bound_circuits
    ]
```

## `_submit_quark_task`

就是你当前的 `_run_quark_qc`：

```python
async def _submit_quark_task(
    qasm2_string,
    shot_num,
    *,
    token,
    chip,
    name,
    target_qubits,
):
    ...
```

这里建议名字改成 `_submit_quark_task`，避免和 `QuarkRunner.run()` 混淆。

## 最终这个文件应该有

```text
class：
    RunResult
    MeasurementRunner Protocol
    AerRunner
    QuarkRunner

public functions：
    add_meas()
    create_runner()

private functions：
    _bind_to_qasm2()
    _submit_quark_task()
```

删除：

```text
run_aer_qc()
run_quark_qc()
_run_quark_qc()
```

它们的实现分别进入 `AerRunner`、`QuarkRunner` 和 `_submit_quark_task`。

---

# 4. `meas_pipeline.py`

文件：[meas_pipeline.py](sandbox:/mnt/data/meas_pipeline.py)

这个文件不要再创建很多策略 class。

它只做：

```text
读取 config
    ↓
构造测量电路
    ↓
生成每组参数
    ↓
选择 runner
    ↓
依次执行 setting_run
    ↓
整理结果
    ↓
写 JSON
```

这个文件只需要一个 public 函数：

```python
async def run_pipeline(config: RandomMeasConfig) -> dict[str, Any]:
    ...
```

---

## `run_pipeline`

结构应该明确写成几个阶段：

```python
async def run_pipeline(
    config: RandomMeasConfig,
) -> dict[str, Any]:
    # 1. 构造参数生成器
    param_generator = create_parameter_generator(
        meas_mode=config.meas_mode,
        ensemble=config.ensemble,
    )

    # 2. 构造 runner
    runner = create_runner(config.runner_opts)

    # 3. 构造带测量的电路
    qc_meas = add_meas(
        config.qc.copy(),
        config.params,
        config.meas_indices,
    )

    # 4. 为每一组 setting 生成参数
    parameter_bind_groups = [
        param_generator.generate(
            params=config.params,
            meas_indices=config.meas_indices,
            setting_num=setting_run.setting_num,
        )
        for setting_run in config.setting_runs
    ]

    # 5. 准备当前项目已有的 correction 输入
    correction_base = _prepare_correction_base(
        config=config,
    )

    correction_bind_groups = _build_correction_bind_groups(
        config=config,
        param_generator=param_generator,
        correction_base=correction_base,
    )

    # 6. 执行
    run_results = []

    for run_idx, setting_run in enumerate(config.setting_runs):
        correction_input = _make_run_correction_input(
            correction_base=correction_base,
            correction_binds=(
                correction_bind_groups[run_idx]
                if correction_bind_groups
                else None
            ),
        )

        run_result = await runner.run(
            qc=qc_meas,
            parameter_binds=parameter_bind_groups[run_idx],
            setting_num=setting_run.setting_num,
            shot_num=setting_run.shot_num,
            name=f"{config.name}_setting{run_idx}",
            correction_input=correction_input,
        )

        run_results.append(run_result)

    # 7. 构造最终结果
    result = _build_result_dict(
        config=config,
        run_results=run_results,
        parameter_bind_groups=parameter_bind_groups,
        correction_bind_groups=correction_bind_groups,
    )

    # 8. 保存
    _write_result(
        output_dir=config.output_dir,
        name=config.name,
        result=result,
    )

    return result
```

这里没有：

```python
if ensemble == ...
if meas_mode == ...
if is_aer ...
```

这些选择分别已经封装在：

```text
ParameterGenerator
AerRunner / QuarkRunner
```

---

## `_prepare_correction_base`

这个函数只迁移你目前 pipeline 中已有的 correction 准备代码。

```python
def _prepare_correction_base(
    config: RandomMeasConfig,
) -> CorrectionInput | None:
    if not isinstance(config.runner_opts, QuarkOptions):
        return None

    correction_input = config.runner_opts.correction_input

    if correction_input is None:
        return None

    if correction_input.trivial_qc is not None:
        return correction_input

    trivial_qc = QuantumCircuit(
        config.qc.num_qubits,
        config.qc.num_clbits,
    )

    trivial_qc = add_meas(
        trivial_qc,
        config.params,
        config.meas_indices,
    )

    return CorrectionInput(
        trivial_qc=trivial_qc,
        trivial_parameter_binds=None,
        trivial_shot_num=correction_input.trivial_shot_num,
    )
```

这里我不判断你的 correction 参数应该如何生成，只保持当前结构。

---

## `_build_correction_bind_groups`

```python
def _build_correction_bind_groups(
    config,
    param_generator,
    correction_base,
):
    if correction_base is None:
        return []

    return [
        param_generator.generate(
            params=config.params,
            meas_indices=config.meas_indices,
            setting_num=setting_run.setting_num,
        )
        for setting_run in config.setting_runs
    ]
```

是否应独立生成、复用还是使用其他规则，是你的项目语义。这个结构只是给现有行为一个明确位置。

---

## `_make_run_correction_input`

```python
def _make_run_correction_input(
    correction_base,
    correction_binds,
):
    if correction_base is None:
        return None

    return CorrectionInput(
        trivial_qc=correction_base.trivial_qc,
        trivial_parameter_binds=correction_binds,
        trivial_shot_num=correction_base.trivial_shot_num,
    )
```

---

## `_build_result_dict`

保留，但输入改成统一的 `RunResult`：

```python
def _build_result_dict(
    config,
    run_results,
    parameter_bind_groups,
    correction_bind_groups,
) -> dict[str, Any]:
    ...
```

它负责：

* runner 名称；
* chip；
* target qubits；
* measurement metadata；
* params；
* count groups；
* trivial count groups。

不负责执行任何电路。

---

## `_binds_to_vec_dict`

保留：

```python
def _binds_to_vec_dict(
    binds,
    params,
) -> dict[str, list]:
    ...
```

这是结果序列化辅助函数，放在 pipeline 中是可以接受的。

---

## `_write_result`

比 `_write_json(filepath, data)` 更适合 pipeline 使用：

```python
def _write_result(
    output_dir: Path,
    name: str,
    result: dict[str, Any],
) -> None:
    output_dir.mkdir(
        parents=True,
        exist_ok=True,
    )

    filepath = output_dir / f"{name}.json"

    with filepath.open(
        "w",
        encoding="utf-8",
    ) as file:
        json.dump(
            result,
            file,
            indent=2,
            ensure_ascii=False,
            default=str,
        )
```

## 最终这个文件应该有

```text
public function：
    run_pipeline()

private functions：
    _prepare_correction_base()
    _build_correction_bind_groups()
    _make_run_correction_input()

    _build_result_dict()
    _binds_to_vec_dict()
    _write_result()
```

不需要 class。

---

# 最终四个文件的完整职责表

| 文件                  | Class                                                                             | Public function                 | Private function                           |
| ------------------- | --------------------------------------------------------------------------------- | ------------------------------- | ------------------------------------------ |
| `meas_config.py`    | `SettingRun`, `AerOptions`, `CorrectionInput`, `QuarkOptions`, `RandomMeasConfig` | 无                               | 无                                          |
| `params_setting.py` | `ParameterGenerator`                                                              | `create_parameter_generator()`  | 分组函数、采样函数、参数展开和转换函数                        |
| `meas_runner.py`    | `RunResult`, `MeasurementRunner`, `AerRunner`, `QuarkRunner`                      | `add_meas()`, `create_runner()` | `_bind_to_qasm2()`, `_submit_quark_task()` |
| `meas_pipeline.py`  | 无                                                                                 | `run_pipeline()`                | correction 准备、结果整理、JSON 保存                 |

---

# 添加新选项时改哪里

## 新增一种测量参数关联方式

例如新的 `meas_mode="triplet"`：

只修改 `params_setting.py`：

```python
def _triplet_groups(...):
    ...
```

然后注册：

```python
GROUP_BUILDERS["triplet"] = _triplet_groups
```

不会碰 Haar、Pauli、runner 和 pipeline。

## 新增一种 ensemble

例如 `ensemble="clifford"`：

只修改 `params_setting.py`：

```python
def _sample_clifford(...):
    ...
```

然后：

```python
ANGLE_SAMPLERS["clifford"] = _sample_clifford
```

不会碰 random、condition、runner 和 pipeline。

## 新增一种计算后端

例如 IBM：

只修改 `meas_runner.py`：

```python
class IBMRunner:
    async def run(...):
        ...
```

然后注册到 `create_runner()`。

不会碰参数生成和 pipeline 主流程。

---

最关键的一点是：

```text
random / condition
```

不要再各自实现完整的：

```text
haar / pauli / derandom
```

它们只负责“参数如何在测量位之间共享”；而 Haar、Pauli、derandom 只负责“每个逻辑组生成什么值”。这就是当前代码最应该拆开的边界。

