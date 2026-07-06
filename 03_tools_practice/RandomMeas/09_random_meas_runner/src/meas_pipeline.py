import json
from pathlib import Path
from typing import Any

from .meas_config import RandomMeasConfig
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
            config.params, config.meas_indices, config.setting_pairs[setting_idx][0]
        )
        for setting_idx in range(len(config.setting_pairs))
    ]

    # Run
    is_aer = config.backend == "statevector"
    count_groups: list[list[dict[str, int]]] = []
    res: dict[str, Any] = {}

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
                device=config.device,
                precision=config.precision,
            )
        else:
            counts = await meas_runner.run_quark_qc(
                qc_meas,
                parameter_binds,
                setting_num,
                shot_num,
                backend=config.backend,
                name=f"{config.name}_setting{setting_idx}",
                target_qubits=config.target_qubits,
            )
        count_groups.append(counts)

    # Record
    res: dict[str, Any] = _build_result_dict(config, count_groups)
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
        "shadow": params_setting.get_shadow_params,
        "hamming": params_setting.get_hamming_params,
    }
    if meas_mode not in mapping:
        raise ValueError(
            f"Unknown meas_mode={meas_mode!r}. Choose from {list(mapping.keys())}."
        )
    return mapping[meas_mode]


def _build_result_dict(
    config: RandomMeasConfig,
    count_groups: list[list[dict[str, int]]],
) -> dict[str, Any]:
    """Construct the output dictionary with all metadata and counts."""
    return {
        "setting_pairs": config.setting_pairs,
        "count_group": count_groups,
        "meas_indices": list(config.meas_indices),  # numpy → list
        "meas_mode": config.meas_mode,
        "backend": config.backend,
        "qc_num_qubits": config.qc.num_qubits,
        "qc_num_clbits": config.qc.num_clbits,
    }


def _write_json(filepath: Path, data) -> None:
    with open(filepath, "w", encoding="utf-8") as fh:
        json.dump(data, fh, indent=2, ensure_ascii=False, default=str)
