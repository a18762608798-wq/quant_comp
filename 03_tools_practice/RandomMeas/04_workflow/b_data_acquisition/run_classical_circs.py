import sys
from pathlib import Path

import numpy as np

sys.path.append(str(Path(__file__).resolve().parents[1]))

from a_pre_processing.create_circs import create_measured_circs
from a_pre_processing.create_circs import create_classical_circ
from run_circs import measure_circs

if __name__ == "__main__":
    # get classical measured_res
    classical_settings_num = 2**10
    shots = 2**9
    clcircs, classical_local_unitary_settings = create_measured_circs(
        create_classical_circ,
        classical_settings_num,
    )
    classical_measured_res = measure_circs(clcircs, shots=shots)
    print(np.shape(classical_measured_res), np.shape(classical_local_unitary_settings))
    np.savez(
        "./03_tools_practice/RandomMeas/04_workflow/b_data_acquisition/classical_group.npz",
        measurement_results=classical_measured_res,
        measurement_settings=classical_local_unitary_settings,
    )
