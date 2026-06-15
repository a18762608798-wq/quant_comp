import sys
from pathlib import Path

import numpy as np
from circs_running import random_measure_circs
from a_pre_processing.circs_creator import create_classical_circ
from a_pre_processing.circs_creator import add_random_meas
from a_pre_processing.circs_creator import create_random_meas_circs 


def savez_classical_meas_data(data_path, settings_num, shots):
    circs, local_unitary_settings = create_random_meas_circs(
        add_random_meas,
        create_classical_circ,
        settings_num,
    )
    measured_res = random_measure_circs(circs, shots=shots)
    print(np.shape(measured_res), np.shape(local_unitary_settings))
    np.savez(
        # NOTE: The demand of RandomMeas.jl, the tags of arrs are fixed.
        data_path,
        measurement_results=measured_res,
        measurement_settings=local_unitary_settings,
    )

if __name__ == "__main__":
    # get measured_res
    settings_num = 2**10
    shots = 2**8
    HERE = Path(__file__).resolve().parent
    out_path = HERE / "./classical_group.npz"
    savez_classical_meas_data(out_path, settings_num, shots)
