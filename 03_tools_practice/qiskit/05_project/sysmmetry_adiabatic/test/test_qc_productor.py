import asyncio
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent.parent / "src"))


from qmeas.random import (
    CorrectionInput,
    AerOptions,
    QuarkOptions,
    RandomMeasConfig,
    run_pipeline,
)


from qc_productor import (
    get_evolutionary_qc,
    get_initial_state,
    get_ssh_op,
    get_nonuniform_grid,
)


test_idx = 3
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
    n, c, t_num, T = 8, 8, 4, 50
    initial_state = get_initial_state(n, c)
    t_ls = get_nonuniform_grid(T, t_num, steepness=3)
    qc = get_evolutionary_qc(get_ssh_op, initial_state, t_ls, T, order=2, reps=1)
    print(qc.draw())
    # print(qc.decompose(reps=4).draw())
    # aer: random, derandom
    meas_indices = list(range(8))  # Arrange the swap bits together
    setting_pairs = [(2, 1024)]
    meas_config = RandomMeasConfig(
        qc=qc,
        setting_pairs=setting_pairs,
        meas_indices=meas_indices,
        meas_mode="random",
        ensemble="derandom",
        runner_opts=AerOptions(method="statevector", device="CPU", precision="single"),
        output_dir=HERE / "./data",
        name="aer-random",
    )
    res = asyncio.run(
        run_pipeline(
            config=meas_config,
        )
    )
    print(res)
