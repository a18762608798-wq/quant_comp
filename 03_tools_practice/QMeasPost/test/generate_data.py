"""Generate test JSON files for different ensembles."""

import asyncio
from pathlib import Path

from qiskit import QuantumCircuit

from qmeas.random import (
    AerOptions,
    RandomMeasConfig,
    SettingRun,
    run_pipeline,
)

HERE = Path(__file__).resolve().parent

QC = QuantumCircuit(6, 4)
QC.h(0)
QC.cx(0, 1)
QC.h(2)
QC.cx(2, 3)
QC.h(4)
QC.cx(4, 5)
MEAS_INDICES = [(1,), (2,), (3,), (4,)]
SETTING_RUNS = [
    SettingRun(setting_num=int(0.1 * k * 3**4), shot_num=2**15) for k in range(6, 11)
]
AER_OPTS = AerOptions(method="statevector", device="CPU", precision="single")


async def main():
    for ensemble in ["pauli", "haar", "derandom"]:
        config = RandomMeasConfig(
            qc=QC,
            setting_runs=SETTING_RUNS,
            meas_indices=MEAS_INDICES,
            ensemble=ensemble,
            runner_opts=AER_OPTS,
            output_dir=HERE,
            name=f"aer-independence_{ensemble}",
        )
        print(f"Generating {ensemble} ...", flush=True)
        await run_pipeline(config=config)


if __name__ == "__main__":
    asyncio.run(main())
