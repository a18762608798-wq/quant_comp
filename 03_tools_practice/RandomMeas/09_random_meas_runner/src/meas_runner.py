import os
import asyncio


from qiskit_aer import AerSimulator
from qiskit import qasm2, transpile
from .meas_config import CorrectionInput
from quark import Task


def add_meas(qc, params, meas_indices):
    theta = params[0]
    llambda = params[1]
    for param_idx in range(len(meas_indices)):
        qubit_idx = meas_indices[param_idx]
        qc.u(theta[param_idx], 0, llambda[param_idx], qubit_idx)
    qc.measure(
        meas_indices, range(len(meas_indices))
    )  # Adjust the classical bits for fitting the addition mode.
    return qc


async def run_quark_qc(
    qc,
    parameter_binds,
    setting_num,
    shot_num,
    token=os.environ["QUARK_TOKEN"],
    backend="Baihua",
    name="my_job",
    target_qubits=[],
    correction_input: CorrectionInput | None = None,
):
    qasm2_strings = _bound_param(qc, setting_num, parameter_binds)
    setting_num = len(qasm2_strings)

    if correction_input is not None:
        trivial_qasm2_strings = _bound_param(
            correction_input.trivial_qc,
            setting_num,
            correction_input.trivial_parameter_binds,
        )

    tasks: list[asyncio.Task] = []
    for setting_idx in range(setting_num):
        tasks.append(
            asyncio.create_task(
                _run_quark_qc(
                    qasm2_strings[setting_idx],
                    shot_num,
                    token=token,
                    backend=backend,
                    name=f"{name}_U{setting_idx}",
                    target_qubits=target_qubits,
                )
            )
        )
        if correction_input is not None:
            tasks.append(
                asyncio.create_task(
                    _run_quark_qc(
                        trivial_qasm2_strings[setting_idx],
                        correction_input.trivial_shot_num,
                        token=token,
                        backend=backend,
                        name=f"{name}_calib_U{setting_idx}",
                        target_qubits=target_qubits,
                    )
                )
            )

    results = await asyncio.gather(*tasks)

    if correction_input is not None:
        counts = results[0::2]
        trivial_counts = results[1::2]
        return counts, trivial_counts
    else:
        return results, None


def run_aer_qc(
    qc,
    parameter_binds,
    setting_num,
    shot_num,
    method="statevector",
    device="CPU",
    precision="single",
):
    sim = AerSimulator(
        method=method,
        device=device,
        precision=precision,
    )
    tqc = transpile(qc, sim)
    job = sim.run(
        tqc,
        shot_num=shot_num,
        parameter_binds=parameter_binds,
    )
    result = job.result()
    counts = []
    for i in range(setting_num):
        count = result.get_counts(i)
        reversed_count = {bitstr[::-1]: count for bitstr, count in count.items()}
        counts.append(reversed_count)
    return counts


# ---------------
# Helper
# -----------
def _bound_param(qc, setting_num, parameter_binds):
    binds = parameter_binds[0]

    bound_circuits = [
        qc.assign_parameters({param: vals[s] for param, vals in binds.items()})
        for s in range(setting_num)
    ]

    qasm2_strings = [qasm2.dumps(bound_qc) for bound_qc in bound_circuits]
    return qasm2_strings


async def _run_quark_qc(
    qasm2_string,
    shot_num,
    token=os.environ["QUARK_TOKEN"],
    backend="Baihua",  # an integer multiple of 1024
    name="my_job",
    target_qubits=[],
):
    tmgr = Task(token)
    task = {
        "chip": backend,  # the quantum computer choice,
        "name": name,
        "circuit": qasm2_string,
        "shots": shot_num,
        "options": {
            "compiler": "qiskit",
            "correct": False,
            "target_qubits": target_qubits,  # 具体bit而非范围, [] is automatic choice.
        },
    }
    tid = tmgr.run(task)  # shot_num = repeat*1024
    res = {}
    while res == {}:
        await asyncio.sleep(10)
        res = tmgr.result(tid)
    return res["count"]
