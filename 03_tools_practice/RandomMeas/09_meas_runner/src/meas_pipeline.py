"""Pipeline: config → run → save JSON.

Ties together ``params_setting`` (parameter generation) and
``meas_adder`` (circuit construction & execution), then serialises
the result counts to disk.
"""


import json
import logging
from datetime import datetime, timezone
from pathlib import Path
from typing import Any

from .meas_config import MeasConfig
from . import params_setting
from . import meas_adder

logger = logging.getLogger(__name__)


# ------------------------------------------------------------------
# Top-level entry point
# ------------------------------------------------------------------

def run_pipeline(
    qc,                # QuantumCircuit — the *bare* circuit (no measurements yet)
    params,            # tuple[ParameterVector, ParameterVector]  — (theta, lambda)
    config: MeasConfig,
) -> dict[str, Any]:
    """Run a full randomised-measurement experiment and save results.

    1. Generate parameter binds (shadow / hamming).
    2. Add measurements to *a copy* of ``qc`` and execute.
    3. Write a JSON file: ``<output_dir>/<name>_<timestamp>.json``.
    4. Return the result dictionary.

    Parameters
    ----------
    qc : QuantumCircuit
        The bare circuit that will be measured.
    params : tuple[ParameterVector, ParameterVector]
        ``(theta, llambda)`` parameter vectors matching the circuit.
    config : MeasConfig
        Experiment configuration (shots, backend, setting_num, …).

    Returns
    -------
    dict
        Dictionary with keys ``"config"``, ``"counts"``, ``"metadata"``.
    """
    # ------------------------------------------------------------------
    # 1. Parameter generation
    # ------------------------------------------------------------------
    _get_param_fn = _pick_param_function(config.meas_mode)
    parameter_binds = _get_param_fn(params, config.meas_indices, config.setting_num)

    # ------------------------------------------------------------------
    # 2. Add measurements & run
    # ------------------------------------------------------------------
    # Copy the circuit so the original stays clean.
    qc_meas = qc.copy() if hasattr(qc, "copy") else qc
    qc_meas = meas_adder.add_meas(qc_meas, params, config.meas_indices)

    # TODO: you may need to adjust the async call depending on your
    #       event-loop setup.  If calling from a script, use:
    #           import asyncio
    #           counts_list = asyncio.run(
    #               meas_adder.run_meas_qc(...)
    #           )
    counts_list = None  # ← replace with the real call
    # counts_list = asyncio.run(
    #     meas_adder.run_meas_qc(
    #         qc_meas,
    #         parameter_binds,
    #         config.setting_num,
    #         config.shots,
    #         device=config.device,
    #         backend=config.backend,
    #         precision=config.precision,
    #     )
    # )

    # ------------------------------------------------------------------
    # 3. Assemble result
    # ------------------------------------------------------------------
    timestamp = datetime.now(timezone.utc).strftime("%Y%m%dT%H%M%SZ")
    result = _build_result_dict(config, counts_list, timestamp)

    # ------------------------------------------------------------------
    # 4. Write JSON
    # ------------------------------------------------------------------
    config.output_dir.mkdir(parents=True, exist_ok=True)
    filename = f"{config.name}_{timestamp}.json"
    filepath = config.output_dir / filename

    _write_json(filepath, result)
    logger.info("Result saved → %s", filepath)

    return result


# ------------------------------------------------------------------
# Helpers
# ------------------------------------------------------------------

def _pick_param_function(meas_mode: str):
    """Return the parameter-generation function for the given mode."""
    mapping = {
        "shadow": params_setting.get_shadow_params,
        "hamming": params_setting.get_hamming_params,
    }
    if meas_mode not in mapping:
        raise ValueError(
            f"Unknown meas_mode={meas_mode!r}. "
            f"Choose from {list(mapping.keys())}."
        )
    return mapping[meas_mode]


def _build_result_dict(
    config: MeasConfig,
    counts_list: list[dict[str, int]] | None,
    timestamp: str,
) -> dict[str, Any]:
    """Package everything into a single serialisable dictionary."""
    return {
        "config": {
            "shots": config.shots,
            "backend": config.backend,
            "setting_num": config.setting_num,
            "meas_indices": config.meas_indices,
            "meas_mode": config.meas_mode,
            "device": config.device,
            "precision": config.precision,
            "target_qubits": config.target_qubits,
            "name": config.name,
            "extra": config.extra,
        },
        "counts": counts_list,
        "metadata": {
            "timestamp": timestamp,
            "num_settings": len(counts_list) if counts_list else 0,
        },
    }


def _write_json(filepath: Path, data: dict[str, Any]) -> None:
    """Write *data* as pretty-printed JSON, converting Paths etc."""
    with open(filepath, "w", encoding="utf-8") as fh:
        json.dump(data, fh, indent=2, ensure_ascii=False, default=str)
