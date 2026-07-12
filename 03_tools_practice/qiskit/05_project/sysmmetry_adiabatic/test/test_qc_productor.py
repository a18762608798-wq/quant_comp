import asyncio
import os
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent.parent / "src"))


from qmeas.random import (
    CorrectionInput,
    AerOptions,
    QuarkOptions,
    RandomMeasConfig,
    SettingRun,
    run_pipeline,
)


from qc_productor import (
    get_evolutionary_qc,
    get_initial_state,
    get_ssh_op,
    get_nonuniform_grid,
)


test_idx = 4
HERE = Path(__file__).resolve().parent


if test_idx == 1:
    n, c = 8, 8
    qc = get_initial_state(n, c)
    print(qc.draw())

if test_idx == 2:
    n, t, T = 8, 1, 1.0
    ssh_op = get_ssh_op(n, t, T)
    print("ssh_op:", ssh_op)

if test_idx == 3:
    # evolution qc
    n, c, t_num, T = 8, 8, 4, 50
    initial_state = get_initial_state(n, c)
    t_ls = get_nonuniform_grid(T, t_num, steepness=3)
    qc = get_evolutionary_qc(get_ssh_op, initial_state, t_ls, T, order=1, reps=1)
    print(qc.draw())
    # aer: independence, derandom
    meas_indices = [2, 3, 4, 5]  # Arrange the swap bits together
    setting_runs = [
        SettingRun(setting_num=2, shot_num=1024),
        SettingRun(setting_num=5, shot_num=1024),
    ]
    meas_config = RandomMeasConfig(
        qc=qc,
        setting_runs=setting_runs,
        meas_indices=meas_indices,
        meas_mode="independence",
        ensemble="derandom",
        runner_opts=AerOptions(method="statevector", device="CPU", precision="single"),
        output_dir=HERE / "./data",
        name="aer-independence",
    )
    res = asyncio.run(
        run_pipeline(
            config=meas_config,
        )
    )
    print(res)

if test_idx == 4:
    n, c, t_num, T = 8, 8, 5, 50
    initial_state = get_initial_state(n, c)
    t_ls = get_nonuniform_grid(T, t_num, steepness=3)
    qc = get_evolutionary_qc(get_ssh_op, initial_state, t_ls, T, order=1, reps=1)
    print(qc.draw())
    # quark-correction-pair, derandom
    meas_indices = [2, 5, 3, 4]
    setting_runs = [
        SettingRun(setting_num=2, shot_num=1024),
        SettingRun(setting_num=5, shot_num=2048),
    ]

    meas_config = RandomMeasConfig(
        qc=qc,
        setting_runs=setting_runs,
        meas_indices=meas_indices,
        meas_mode="pair",
        ensemble="derandom",
        runner_opts=QuarkOptions(
            chip="Dongling",
            target_qubits=[],
            token=os.environ["QUARK_TOKEN"],
            correction_input=CorrectionInput(
                trivial_shot_num=1024,
            ),
        ),
        output_dir=HERE / "./data",
        name="quark-correction-pair",
    )
    res = asyncio.run(run_pipeline(config=meas_config))
    print(res)
