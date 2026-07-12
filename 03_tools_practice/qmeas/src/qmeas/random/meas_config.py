import os
from dataclasses import dataclass, field
from pathlib import Path
from typing import Any, Literal

from qiskit import QuantumCircuit
from qiskit.circuit import ParameterVector


MeasMode = Literal["independence", "pair"]
Ensemble = Literal["haar", "pauli", "derandom"]


@dataclass(frozen=True)  # Immutable
class SettingRun:
    setting_num: int
    shot_num: int


@dataclass(frozen=True)
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
    token: str = field(default_factory=lambda: os.environ["QUARK_TOKEN"])
    correction_input: CorrectionInput | None = None


@dataclass
class RandomMeasConfig:
    qc: QuantumCircuit
    setting_runs: list[SettingRun]
    meas_indices: list[int]

    runner_opts: AerOptions | QuarkOptions = field(default_factory=AerOptions)

    meas_mode: MeasMode = "independence"
    ensemble: Ensemble = "haar"

    params: list[ParameterVector] | None = None

    output_dir: Path = field(default_factory=lambda: Path("./data"))
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
