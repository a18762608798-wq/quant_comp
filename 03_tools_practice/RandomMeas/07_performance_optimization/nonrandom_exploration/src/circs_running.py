import sys
from pathlib import Path
from tqdm.auto import tqdm

import numpy as np
from qiskit_aer import Aer
from qiskit import transpile

sys.path.append(str(Path(__file__).resolve().parents[1]))

from circs_creator import create_random_meas_circs
from circs_creator import create_pre_measured_circ
from circs_creator import add_random_meas
from circs_creator import add_conditional_random_meas


def random_measure_circs(circs, backend="aer_simulator", shots=2**9):
    settings_num = len(circs)
    qubits_num = circs[0].num_qubits
    measured_res = np.empty((settings_num, shots, qubits_num), dtype=np.uint8)
    if backend == "aer_simulator":
        backend = Aer.get_backend(backend)
        # Process in batches to show progress.
        batch_num = min(1, settings_num)
        batch_size = np.int32(np.ceil(settings_num / batch_num))
        for batch_index in range(0, batch_num):
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


def savz_random_meas_data(meas_fun, data_path, settings_num, shots):
    circs, local_unitary_settings = create_random_meas_circs(
        meas_fun,
        create_pre_measured_circ,
        settings_num,
    )
    measured_res = random_measure_circs(circs, shots=shots)
    np.savez(
        data_path,
        measurement_results=measured_res,
        measurement_settings=local_unitary_settings,
    )


def savez_random_meas_datas(meas_fun, data_paths, settings_num_vec, shots_vec):
    for data_path_idx in tqdm(range(len(data_paths)), desc="Aer batches process"):
        data_path = data_paths[data_path_idx]
        settings_num = settings_num_vec[data_path_idx]
        shots = shots_vec[data_path_idx]
        savz_random_meas_data(meas_fun, data_path, settings_num, shots)


if __name__ == "__main__":
    # get measured_res
    settings_num_vec = [i**2 for i in range(20, 25, 1)]
    shots_vec = [i**2 for i in range(20, 25, 1)]
    # random data save
    HERE = Path(__file__).resolve().parent
    data_paths = [HERE / f"../data/random/random_group{i + 1}.npz" for i in range(len(settings_num_vec))]
    savez_random_meas_datas(add_random_meas, data_paths, settings_num_vec, shots_vec)
    # conditional random data save
    data_paths = [HERE / f"../data/random/conditional_group{i + 1}.npz" for i in range(len(settings_num_vec))]
    savez_random_meas_datas(add_conditional_random_meas, data_paths, settings_num_vec, shots_vec)
