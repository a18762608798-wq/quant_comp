import sys
from pathlib import Path

import numpy as np
from qiskit_aer import Aer
from qiskit import transpile

sys.path.append(str(Path(__file__).resolve().parents[1]))

from a_pre_processing.create_circs import creat_measured_circs


def measure_circs(circs, backend="aer_simulator", shots=2**9):
    settings_num = len(circs)
    qubits_num = circs[0].num_clbits
    measured_res = np.empty((settings_num, shots, qubits_num), dtype=np.uint8)
    if backend == "aer_simulator":
        backend = Aer.get_backend(backend)
        transpiled_circs = transpile(circs, backend)
        job = backend.run(transpiled_circs, shots=shots, memory=True)
        results = job.result()
        for setting_index in range(settings_num):
            measured_re = np.empty((shots, qubits_num), dtype=np.uint8)
            memory = results.get_memory(setting_index)
            # transform the bitstr to bitarr
            for shot in range(shots):
                bitstr = memory[shot]
                bitarr = np.array([int(b) for b in bitstr], dtype=np.uint8)
                measured_re[shot, :] = bitarr
            measured_res[setting_index, :, :] = measured_re
        measured_res = measured_res[:, :, ::-1]
    return measured_res


if __name__ == "__main__":
    circs, local_unitary_settings = creat_measured_circs(2**10)
    measured_res = measure_circs(circs)
    print(np.shape(measured_res), np.shape(local_unitary_settings))
    # NOTE: the demand of RandomMeas.jl, the tags of arrs are fixed.
    np.savez(
        "./03_tools_practice/RandomMeas/04_workflow/b_data_acquisition/group.npz",
        measurement_results=measured_res,
        measurement_settings=local_unitary_settings,
    )
