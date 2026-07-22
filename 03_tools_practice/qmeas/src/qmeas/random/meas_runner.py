import asyncio
from dataclasses import dataclass

# `Protocol`（`typing`）用来定义**结构化类型 / 鸭子类型接口**：
# 只要某个类“长得对”（有匹配的方法签名），就算符合这个接口，**不需要显式继承**。
from typing import Protocol

from qiskit import QuantumCircuit, qasm2, transpile
from qiskit_aer import AerSimulator
from quark import Task

from .meas_config import AerOptions, CorrectionInput, QuarkOptions


Counts = dict[str, int]


# `RunResult` — 统一返回值：`counts`（+ 可选 `trivial_counts`）。
@dataclass
class RunResult:
    counts: list[Counts]
    trivial_counts: list[Counts] | None = None


# `MeasurementRunner` — 接口声明，规定 runner 都要有 `run()`, 只是一个声明。
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
    ) -> RunResult: ...  # No return and no operation.


# `AerRunner` — 本地模拟执行。
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
            raise ValueError("AerRunner does not accept correction_input")

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
            count = {bitstring[::-1]: value for bitstring, value in raw_count.items()}
            counts.append(count)

        return RunResult(counts=counts)


# `QuarkRunner` — 远程云执行，支持 correction。
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
        qasm2_strings = _bind_to_qasm2(qc, setting_num, parameter_binds)

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


# 工厂函数：`create_runner()` — 按 options 类型返回对应 runner。
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


# 给电路加测量门.
def add_meas(qc, params, meas_indices):
    theta = params[0]
    phi = params[1]
    flat_indices: list[int] = []
    for group_idx, group in enumerate(meas_indices):
        for qubit_idx in group:
            qc.u(-theta[group_idx], 0, -phi[group_idx], qubit_idx)
        flat_indices.extend(group)
    qc.measure(flat_indices, range(len(flat_indices)))
    return qc


# ------------------------------------------------------------------
# Helpers
# ------------------------------------------------------------------


# 绑参数并转 QASM2
def _bind_to_qasm2(qc, setting_num, parameter_binds) -> list[str]:
    binds = parameter_binds[0]

    bound_circuits = [
        qc.assign_parameters(
            {parameter: values[setting_idx] for parameter, values in binds.items()}
        )
        for setting_idx in range(setting_num)
    ]

    return [qasm2.dumps(bound_qc) for bound_qc in bound_circuits]


# 提交单个 Quark 任务并等结果
async def _submit_quark_task(
    qasm2_string,
    shot_num,
    *,
    token,
    chip,
    name,
    target_qubits,
):
    tmgr = Task(token)
    task = {
        "chip": chip,  # the quantum computer choice,
        "name": name,
        "circuit": qasm2_string,
        "shots": shot_num,
        "options": {
            "compiler": "qiskit",
            "correct": False,
            "target_qubits": target_qubits,  # 具体bit而非范围, [] is automatic choice.
        },
    }
    tid = tmgr.run(task)  # shot_num = repeat*1024
    res = {}
    while res == {}:
        await asyncio.sleep(10)
        res = tmgr.result(tid)
    return res["count"]
