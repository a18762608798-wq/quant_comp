import sys
from pathlib import Path
from tqdm.auto import tqdm

import numpy as np
from qiskit_aer import Aer
from qiskit import transpile

sys.path.append(str(Path(__file__).resolve().parents[1]))

from a_pre_processing.circs_creator import create_measured_circs
from a_pre_processing.circs_creator import create_pre_measured_circ
from a_pre_processing.circs_creator import add_random_meas
from a_pre_processing.circs_creator import add_conditional_random_meas


def random_measure_circs(circs, backend="aer_simulator", shots=2**9):
    settings_num = len(circs)
    qubits_num = circs[0].num_qubits
    measured_res = np.empty((settings_num, shots, qubits_num), dtype=np.uint8)
    if backend == "aer_simulator":
        backend = Aer.get_backend(backend)
        # Process in batches to show progress.
        batch_num = min(5, settings_num)
        batch_size = np.int32(np.ceil(settings_num / batch_num))
        for batch_index in tqdm(range(0, batch_num), desc="Aer batches process"):
            start = batch_size * batch_index
            end = min(start + batch_size, settings_num)
            batch_circs = circs[start:end]
            transpiled_batch_circs = transpile(batch_circs, backend)
            job = backend.run(transpiled_batch_circs, shots=shots, memory=True)
            results = job.result()
            for local_index, setting_index in enumerate(range(start, end)):
                measured_re = np.empty((shots, qubits_num), dtype=np.uint8)
                memory = results.get_memory(local_index)
                # transform the bitstr to bitarr
                for shot in range(shots):
                    bitstr = memory[shot]
                    bitarr = np.array([int(b) for b in bitstr], dtype=np.uint8)
                    measured_re[shot, :] = bitarr
                measured_res[setting_index, :, :] = measured_re
        measured_res = measured_res[:, :, ::-1]
    return measured_res

def savez_meas_data(meas_fun, data_path, settings_num, shots):
    circs, local_unitary_settings = create_measured_circs(
        meas_fun,
        create_pre_measured_circ,
        settings_num,
    )
    measured_res = random_measure_circs(circs, shots=shots)
    print(np.shape(measured_res), np.shape(local_unitary_settings))
    np.savez(
        data_path,
        measurement_results=measured_res,
        measurement_settings=local_unitary_settings,
    )


if __name__ == "__main__":
    # get measured_res
    settings_num = 2**10
    shots = 2**8
    # NOTE: The demand of RandomMeas.jl, the tags of arrs are fixed.
    HERE = Path(__file__).resolve().parent
    out_path = HERE / "./random_group.npz"
    savez_meas_data(add_random_meas, out_path, settings_num, shots)
    out_path = HERE / "./conditional_random_group.npz"
    savez_meas_data(add_conditional_random_meas, out_path, settings_num, shots)
