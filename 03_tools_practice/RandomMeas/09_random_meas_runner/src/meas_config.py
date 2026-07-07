import os
from dataclasses import dataclass, field
from pathlib import Path
from typing import Any

from qiskit import QuantumCircuit
from qiskit.circuit import ParameterVector


@dataclass
class AerOptions:
    method: str = "statevector"
    device: str = "CPU"
    precision: str = "single"


@dataclass
class CorrectionInput:
    trivial_qc: QuantumCircuit | None = None
    trivial_parameter_binds: Any = None
    trivial_shot_num: int = 1024


@dataclass
class QuarkOptions:
    chip: str = "Baihua"
    target_qubits: list[int] = field(default_factory=list)
    token: str = field(default_factory=lambda: os.environ.get("QUARK_TOKEN", ""))
    correction_input: CorrectionInput | None = None


@dataclass
class RandomMeasConfig:
    # ---- required --------------------------------------------------
    qc: QuantumCircuit
    setting_pairs: list[tuple]
    meas_indices: list[int]
    params: list[ParameterVector] | None = None

    # ---- runner selection ------------------------------------------
    runner_opts: AerOptions | QuarkOptions = field(default_factory=AerOptions)

    # ---- measurement strategy --------------------------------------
    meas_mode: str = "random"  # "random" | "condition"

    # ---- output ----------------------------------------------------
    output_dir: Path = "./data/"
    name: str = "experiment"

    # ---- misc ------------------------------------------------------
    extra: dict[str, Any] = field(default_factory=dict)

    def __post_init__(self):
        if self.params is None:
            n = len(self.meas_indices)
            self.params = [
                ParameterVector("theta", n),
                ParameterVector("lambda", n),
            ]
