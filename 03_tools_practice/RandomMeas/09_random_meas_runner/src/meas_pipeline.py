import json
from pathlib import Path
from typing import Any

from qiskit import QuantumCircuit

from .meas_config import AerOptions, CorrectionInput, RandomMeasConfig
from . import params_setting
from . import meas_runner


async def run_pipeline(
    config: RandomMeasConfig,
):

    # Add measurements
    qc_meas = meas_runner.add_meas(config.qc.copy(), config.params, config.meas_indices)

    # Parameter generation
    _get_param_fun = _pick_param_fun(config.meas_mode)
    parameter_bind_groups = [
        _get_param_fun(
            config.params, config.meas_indices, config.setting_pairs[setting_idx][0],
            ensemble=config.ensemble,
        )
        for setting_idx in range(len(config.setting_pairs))
    ]

    # Run
    opts = config.runner_opts
    is_aer = isinstance(opts, AerOptions)
    count_groups: list[list[dict[str, int]]] = []
    trivial_count_groups: list[list[dict[str, int]]] = []

    # ---- correction pre-build -------------------------------------
    trivial_parameter_bind_groups = []
    correction_input_base = opts.correction_input if not is_aer else None
    if correction_input_base is not None:
        if correction_input_base.trivial_qc is None:
            trivial_qc = QuantumCircuit(config.qc.num_qubits, config.qc.num_clbits)
            trivial_qc = meas_runner.add_meas(
                trivial_qc, config.params, config.meas_indices
            )
            correction_input_base = CorrectionInput(
                trivial_qc=trivial_qc,
                trivial_parameter_binds=None,
                trivial_shot_num=correction_input_base.trivial_shot_num,
            )
        trivial_parameter_bind_groups = [
            _get_param_fun(
                config.params, config.meas_indices, config.setting_pairs[i][0],
                ensemble=config.ensemble,
            )
            for i in range(len(config.setting_pairs))
        ]

    for setting_idx in range(len(config.setting_pairs)):
        setting_num = config.setting_pairs[setting_idx][0]
        shot_num = config.setting_pairs[setting_idx][1]
        parameter_binds = parameter_bind_groups[setting_idx]

        if is_aer:
            counts = meas_runner.run_aer_qc(
                qc_meas,
                parameter_binds,
                setting_num,
                shot_num,
                method=opts.method,
                device=opts.device,
                precision=opts.precision,
            )
        else:
            correction_input = None
            if correction_input_base is not None:
                correction_input = CorrectionInput(
                    trivial_qc=correction_input_base.trivial_qc,
                    trivial_parameter_binds=trivial_parameter_bind_groups[setting_idx],
                    trivial_shot_num=correction_input_base.trivial_shot_num,
                )

            counts, trivial_counts = await meas_runner.run_quark_qc(
                qc_meas,
                parameter_binds,
                setting_num,
                shot_num,
                token=opts.token,
                backend=opts.chip,
                name=f"{config.name}_setting{setting_idx}",
                target_qubits=opts.target_qubits,
                correction_input=correction_input,
            )
            if trivial_counts is not None:
                trivial_count_groups.append(trivial_counts)
        count_groups.append(counts)

    # Record
    res: dict[str, Any] = _build_result_dict(
        config,
        count_groups,
        trivial_count_groups,
        parameter_bind_groups,
        trivial_parameter_bind_groups,
    )
    # Write to JSON
    config.output_dir.mkdir(parents=True, exist_ok=True)
    filename = f"{config.name}.json"
    filepath = config.output_dir / filename
    _write_json(filepath, res)

    return res


# ------------------------------------------------------------------
# Helpers
# ------------------------------------------------------------------


def _pick_param_fun(meas_mode: str):
    """Return the parameter-generation function for the given mode."""
    mapping = {
        "random": params_setting.get_random_params,
        "condition": params_setting.get_condition_params,
    }
    if meas_mode not in mapping:
        raise ValueError(
            f"Unknown meas_mode={meas_mode!r}. Choose from {list(mapping.keys())}."
        )
    return mapping[meas_mode]


def _build_result_dict(
    config: RandomMeasConfig,
    count_groups: list[list[dict[str, int]]],
    trivial_count_groups: list[list[dict[str, int]]],
    parameter_bind_groups,
    trivial_parameter_bind_groups,
) -> dict[str, Any]:
    """Construct the output dictionary with all metadata and counts."""
    result: dict[str, Any] = {}
    # aer
    result["runner"] = "aer" if isinstance(config.runner_opts, AerOptions) else "quark"
    if not isinstance(config.runner_opts, AerOptions):
        result["chip"] = config.runner_opts.chip
        result["target_qubits"] = config.runner_opts.target_qubits
    # settings
    result["meas_mode"] = config.meas_mode
    result["ensemble"] = config.ensemble
    result["setting_pairs"] = config.setting_pairs
    result["qc_num_qubits"] = config.qc.num_qubits
    result["qc_num_clbits"] = config.qc.num_clbits
    result["meas_indices"] = list(config.meas_indices)
    result["parameter_bind_groups"] = [
        {str(k): v for k, v in binds[0].items()} for binds in parameter_bind_groups
    ]
    if trivial_count_groups:
        result["trivial_parameter_bind_groups"] = [
            {str(k): v for k, v in binds[0].items()}
            for binds in trivial_parameter_bind_groups
        ]
    # res
    result["count_group"] = count_groups
    if trivial_count_groups:
        result["trivial_count_group"] = trivial_count_groups
    return result


def _write_json(filepath: Path, data) -> None:
    with open(filepath, "w", encoding="utf-8") as fh:
        json.dump(data, fh, indent=2, ensure_ascii=False, default=str)
