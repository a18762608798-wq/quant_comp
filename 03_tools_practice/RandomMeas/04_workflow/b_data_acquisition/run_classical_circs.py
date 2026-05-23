import sys
from pathlib import Path

import numpy as np

sys.path.append(str(Path(__file__).resolve().parents[1]))

from a_pre_processing.create_circs import create_measured_circs
from a_pre_processing.create_circs import create_classical_circ
from run_circs import measure_circs


def savez_reflect_data(settings_num, shots):
    circs, local_unitary_settings = create_measured_circs(
        create_classical_circ,
        settings_num,
    )
    measured_res = measure_circs(circs, shots=shots)
    print(np.shape(measured_res), np.shape(local_unitary_settings))
    # NOTE: The demand of RandomMeas.jl, the tags of arrs are fixed.
    HERE = Path(__file__).resolve().parent
    out_path = HERE / "classical_group.npz"
    np.savez(
        out_path,
        measurement_results=measured_res,
        measurement_settings=local_unitary_settings,
    )


if __name__ == "__main__":
    # get measured_res
    N = 4
    settings_num = 2**9
    shots = 2**9
    savez_reflect_data(settings_num, shots)
