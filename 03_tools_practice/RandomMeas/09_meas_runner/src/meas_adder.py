import os
import time
import asyncio


import numpy as np
from qiskit import QuantumCircuit, transpile
from qiskit.circuit import ParameterVector
from qiskit_aer import AerSimulator
from qiskit import qasm2
from quark import Task


def add_meas(qc, params, meas_indices):
    theta = params[0]
    llambda = params[1]
    for param_idx in range(len(meas_indices)):
        qubit_idx = meas_indices[param_idx]
        qc.u(theta[param_idx], 0, llambda[param_idx], qubit_idx)
    qc.measure(meas_indices, range(len(meas_indices))) # adjust the classical bits for fitting the addition mode.
    return qc


def bound_param(qc, parameter_binds):
    binds = parameter_binds[0]

    bound_circuits = [
        qc.assign_parameters({
            param: vals[s]
            for param, vals in binds.items()
        })
        for s in range(setting_num)
    ]

    qasm2_strings = [
        qasm2.dumps(bound_qc)
        for bound_qc in bound_circuits
    ]
    return qasm2_strings


async def run_quark_qc(
    qasm2_string,
    shots,
    backend="Dongling", # an integer multiple of 1024
    name="my_job",
    target_qubits=[],
):
    token = os.environ["QUARK_TOKEN"]
    tmgr = Task(token)
    task = {
    'chip': backend, # the quantum computer choice,  
    'name': name,  
    'circuit':qasm2_string, 
    'shots': shots, 
    'options':{
        'compiler': 'qiskit',
        'correct': False,
        'target_qubits': target_qubits # 具体bit而非范围, [] is automatic choice. 
        }
    }
    tid = tmgr.run(task) # shots = repeat*1024
    res = {}
    while res == {}:
        time.sleep(10)
        res = tmgr.result(tid)
    return res["count"]


async def run_meas_qc(
        qc, 
        parameter_binds, 
        setting_num, 
        shots, 
        device="CPU", 
        backend="statevector",
        precision="single"
):
    if backend == "statevector":
        sim = AerSimulator(
            method=backend,
            device=device,     
            precision=precision,
        )
        tqc = transpile(qc, sim)
        job = sim.run(
            tqc,
            shots=shots,
            parameter_binds=parameter_binds,
        )
        result = job.result()        
        counts_list = []
        for i in range(setting_num):
            counts = result.get_counts(i)
            reversed_counts = {bitstr[::-1]: count for bitstr, count in counts.items()}
            counts_list.append(reversed_counts)

    else:
        qasm2_strings = bound_param(qc, parameter_binds)
        setting_num = len(qasm2_strings)
        tasks = []
        for setting_idx in range(setting_num):
            qasm2_string = qasm2_strings[setting_idx]
            task = asyncio.create_task(
                run_quark_qc(
                    qasm2_string,
                    shots,
                    backend=backend, 
                )
            )
            tasks.append(task)
        counts_list = await asyncio.gather(*tasks)

    return counts_list
