import sys
import itertools    
from pathlib import Path
from tqdm.auto import tqdm

import numpy as np
from qiskit_aer import Aer
from qiskit import transpile

from circs_creator import create_random_meas_circs
from circs_creator import create_pre_measured_circ
from circs_creator import add_random_meas
from circs_creator import add_conditional_random_meas
from circs_creator import add_pauli_meas
from circs_creator import create_pauli_meas_circs


# ----------------------
# random measure circs
# ----------------------
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


def savez_random_meas_data(meas_fun, data_path, settings_num, shots):
    circs, local_unitary_settings = create_random_meas_circs(
        meas_fun,
        create_pre_measured_circ,
        settings_num,
    )
    measured_res = random_measure_circs(circs, shots=shots)
    np.savez(
        # NOTE: The demand of RandomMeas.jl, the tags of arrs are fixed.
        data_path,
        measurement_results=measured_res,
        measurement_settings=local_unitary_settings,
    )

# --------------------
# pauli measure circs
# --------------------
def pauli_measure_circs(circs, pauli_bases, backend="aer_simulator", shots=2**9):
    qubit_num = circs[0].num_qubits
    base_num = len(pauli_bases)
    pauli_shots = shots // base_num
    measured_res = np.empty((base_num, pauli_shots, qubit_num), dtype=np.uint8)
    if backend == "aer_simulator":
        backend = Aer.get_backend(backend)
        transpiled_circs = transpile(circs, backend)
        job = backend.run(transpiled_circs, shots=pauli_shots, memory=True)
        results = job.result()
        for base_idx in range(base_num):
            memory = results.get_memory(base_idx)
            for shot in range(pauli_shots):
                bitstr = memory[shot]
                bitarr = np.array([int(b) for b in bitstr], dtype=np.uint8)
                measured_res[base_idx, shot, :] = bitarr
        measured_res = measured_res[:, :, ::-1]
    return measured_res


def savez_reflect_pauli_meas_data(data_path, shots):
    circ = create_pre_measured_circ()
    qubit_num = circ.num_qubits
    pair_num = qubit_num // 2
    bases = [2, 3, 4]
    pauli_bases = [] 
    for combo in itertools.product(bases, repeat=pair_num):
        base_arr = np.ones(qubit_num, dtype=np.int64)  
        for i, base in enumerate(combo):
            reflect_i = qubit_num - 1 - i
            base_arr[i] = base
            base_arr[reflect_i] = base
        pauli_bases.append(base_arr)

    circs = create_pauli_meas_circs(
        create_pre_measured_circ,
        pauli_bases,
    )
    measured_res = pauli_measure_circs(circs, pauli_bases, shots=shots)
    np.savez(
        data_path,
        measurement_results=measured_res,
        measurement_settings=pauli_bases,
    )


def savez_purity_pauli_meas_data(data_path, shots):
    circ = create_pre_measured_circ()
    qubit_num = circ.num_qubits
    bases = [2, 3, 4]
    pauli_bases = [] 
    for combo in itertools.product(bases, repeat=qubit_num):
        base_arr = np.ones(qubit_num, dtype=np.int64)  
        for i, base in enumerate(combo):
            base_arr[i] = base
        pauli_bases.append(base_arr)

    circs = create_pauli_meas_circs(
        create_pre_measured_circ,
        pauli_bases,
    )
    measured_res = pauli_measure_circs(circs, pauli_bases, shots=shots)
    np.savez(
        data_path,
        measurement_results=measured_res,
        measurement_settings=pauli_bases,
    )

# ---------------------
# savez datas for nonrandom exploration 
# ---------------------
def savez_random_meas_datas(meas_fun, data_paths, settings_num_vec, shots_vec):
    for data_path_idx in tqdm(range(len(data_paths)), desc="Aer batches process"):
        data_path = data_paths[data_path_idx]
        settings_num = settings_num_vec[data_path_idx]
        shots = shots_vec[data_path_idx]
        savez_random_meas_data(meas_fun, data_path, settings_num, shots)


def savez_reflect_pauli_meas_datas(data_paths, shot_nums):
    for idx in tqdm(range(len(data_paths)), desc="Aer batches process"):
        data_path = data_paths[idx]
        shot_num = shot_nums[idx]
        savez_reflect_pauli_meas_data(data_path, shot_num)


def savez_purity_pauli_meas_datas(data_paths, shot_nums):
    for idx in tqdm(range(len(data_paths)), desc="Aer batches process"):
        data_path = data_paths[idx]
        shot_num = shot_nums[idx]
        savez_purity_pauli_meas_data(data_path, shot_num)


# base settings for grid scan
settings_nums = [i * 3**8 for i in range(1, 6)]  # [6561, 13122, 19683, 26244]
shot_nums = [i for i in range(3, 8)]              # [1, 2, 3, 4]
pairs = list(itertools.product(settings_nums, shot_nums))

if __name__ == "__main__":
    # get measured_res: grid scan and flatten
    settings_num_vec = [p[0] for p in pairs]
    shots_vec = [p[1] for p in pairs]
    pauli_shots = [settings_num_vec[i] * shots_vec[i] for i in range(len(shots_vec))]
    # random data save
    HERE = Path(__file__).resolve().parent
    data_paths = [HERE / f"../data/random_group{i + 1}.npz" for i in range(len(settings_num_vec))]
    savez_random_meas_datas(add_random_meas, data_paths, settings_num_vec, shots_vec)
    # conditional random data save
    data_paths = [HERE / f"../data/conditional_group{i + 1}.npz" for i in range(len(settings_num_vec))]
    savez_random_meas_datas(add_conditional_random_meas, data_paths, settings_num_vec, shots_vec)
    # reflect pauli datas
    data_paths = [HERE / f"../data/reflect_pauli_group{i + 1}.npz" for i in range(len(pauli_shots))]
    savez_reflect_pauli_meas_datas(data_paths, pauli_shots)
    # purity pauli datas
    data_paths = [HERE / f"../data/purity_pauli_group{i + 1}.npz" for i in range(len(pauli_shots))]
    savez_purity_pauli_meas_datas(data_paths, pauli_shots)
