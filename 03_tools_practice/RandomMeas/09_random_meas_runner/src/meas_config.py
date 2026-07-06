from dataclasses import dataclass, field
from pathlib import Path
from typing import Any

from qiskit import QuantumCircuit
from qiskit.circuit import ParameterVector


@dataclass
class RandomMeasConfig:
    # ---- required --------------------------------------------------
    qc: QuantumCircuit
    setting_pairs: list[tuple]
    meas_indices: list[int]
    backend: str = "statevector"
    params: list[ParameterVector] | None = None

    # ---- measurement strategy --------------------------------------
    meas_mode: str = "shadow"  # "shadow" | "hamming"

    # ---- simulator options (Aer) -----------------------------------
    device: str = "CPU"
    precision: str = "single"

    # ---- remote backend options (quark) ----------------------------
    target_qubits: list[int] = field(default_factory=list)  # 防止两个class共享一个列表

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
