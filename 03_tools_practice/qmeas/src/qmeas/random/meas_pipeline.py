import json
from pathlib import Path
from typing import Any

from qiskit import QuantumCircuit

from .meas_config import (
    AerOptions,
    CorrectionInput,
    QuarkOptions,
    RandomMeasConfig,
)
from .meas_runner import RunResult, add_meas, create_runner
from .params_setting import create_parameter_generator


# 公共函数，兼容所有情况而不做if分支。
async def run_pipeline(config: RandomMeasConfig) -> dict[str, Any]:
    # 1. 构造参数生成器
    param_generator = create_parameter_generator(
        meas_mode=config.meas_mode,
        ensemble=config.ensemble,
    )

    # 2. 构造带测量的电路
    qc_meas = add_meas(
        config.qc.copy(),
        config.params,
        config.meas_indices,
    )

    # 3. 为每一组 setting 生成参数
    assert config.params is not None, (
        "__post_init__(self)实际上已经避免None, 这里只是让pyright闭嘴。"
    )
    parameter_bind_groups = [
        param_generator.generate(
            params=config.params,
            meas_indices=config.meas_indices,
            setting_num=setting_run.setting_num,
        )
        for setting_run in config.setting_runs
    ]

    # 4. 准备当前项目已有的 correction 输入
    correction_base = _prepare_correction_base(config=config)

    correction_bind_groups = _build_correction_bind_groups(
        config=config,
        param_generator=param_generator,
        correction_base=correction_base,
    )

    # 5. 构造 runner
    runner = create_runner(config.runner_opts)

    # 6. 执行
    run_results: list[RunResult] = []

    for run_idx, setting_run in enumerate(config.setting_runs):
        correction_input = _make_run_correction_input(
            correction_base=correction_base,
            correction_binds=(
                correction_bind_groups[run_idx] if correction_bind_groups else None
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


# ------------------------------------------------------------------
# Correction helpers
# ------------------------------------------------------------------


# 若是 Quark 且需 correction，准备 trivial 电路（没给就自动建一个）；
# 其它情况返回 `None`
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


# 给每个 setting 生成 correction 参数；无 correction 则返回 `[]`。
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


# 把 base + 当前 setting 的参数组合成单次 `CorrectionInput`。
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


# ------------------------------------------------------------------
# Result helpers
# ------------------------------------------------------------------


def _build_result_dict(
    config: RandomMeasConfig,
    run_results: list[RunResult],
    parameter_bind_groups,
    correction_bind_groups,
) -> dict[str, Any]:
    runner_opts = config.runner_opts

    result: dict[str, Any] = {}
    result["runner"] = "aer" if isinstance(runner_opts, AerOptions) else "quark"
    if isinstance(runner_opts, QuarkOptions):
        result["chip"] = runner_opts.chip
        result["target_qubits"] = runner_opts.target_qubits

    result["meas_mode"] = config.meas_mode
    result["ensemble"] = config.ensemble
    result["setting_runs"] = [
        (setting_run.setting_num, setting_run.shot_num)
        for setting_run in config.setting_runs
    ]
    result["qc_num_qubits"] = config.qc.num_qubits
    result["qc_num_clbits"] = config.qc.num_clbits
    result["meas_indices"] = list(config.meas_indices)

    store_params = config.meas_mode != "pair"

    if store_params:
        result["params"] = [
            _binds_to_vec_dict(binds[0], config.params)
            for binds in parameter_bind_groups
        ]

    has_trivial = any(
        run_result.trivial_counts is not None for run_result in run_results
    )

    if store_params and has_trivial and correction_bind_groups:
        result["trivial_params"] = [
            _binds_to_vec_dict(binds[0], config.params)
            for binds in correction_bind_groups
        ]

    result["count_group"] = [run_result.counts for run_result in run_results]

    if has_trivial:
        result["trivial_count_group"] = [
            run_result.trivial_counts
            for run_result in run_results
            if run_result.trivial_counts is not None
        ]

    return result


def _binds_to_vec_dict(binds: dict, params) -> dict[str, list]:
    """Group parameter binds by ParameterVector into 2D lists.

    Returns e.g. {"theta": [[...], ...], "lambda": [[...], ...]} where the
    outer index is setting_idx and the inner list is the value per parameter
    number.
    """
    result: dict[str, list] = {}
    for pvec in params:
        per_param = [list(binds[p]) for p in pvec]
        result[pvec.name] = [list(col) for col in zip(*per_param)]
    return result


def _write_result(
    output_dir: Path,
    name: str,
    result: dict[str, Any],
) -> None:
    output_dir.mkdir(parents=True, exist_ok=True)

    filepath = output_dir / f"{name}.json"

    with filepath.open("w", encoding="utf-8") as file:
        json.dump(
            result,
            file,
            indent=2,
            ensure_ascii=False,
            default=str,
        )
