import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent.parent / "src"))

from qc_productor import (
    get_evolutionary_qc,
    get_initial_state,
    get_ssh_op,
    get_nonuniform_grid,
)

test_idx = 3

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
