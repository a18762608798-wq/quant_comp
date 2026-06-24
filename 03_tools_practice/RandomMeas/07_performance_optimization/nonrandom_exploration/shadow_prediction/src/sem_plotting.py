import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
from pathlib import Path
from seaborn import lineplot

from circs_running import settings_nums
from circs_running import shot_nums
from circs_running import random_pairs

# ----------
# Z SEMs: shadow vs pauli
# ----------
def plot_z():
    HERE = Path(__file__).resolve().parent
    sem_dir = HERE / "../data/"
    pic_dir = HERE / "../pics/"
    sem_dir = Path(sem_dir)
    n_groups = len(random_pairs)

    # get the data
    # shadow
    shadow_sem_path = sem_dir / "z_sems_shadow.npz"
    shadow_data = np.load(shadow_sem_path)
    shadow_ests = shadow_data["ests"]
    shadow_sems = shadow_data["sems"]
    # pauli
    pauli_sem_path = sem_dir / "z_sems_pauli.npz"
    pauli_data = np.load(pauli_sem_path)
    pauli_ests = pauli_data["ests"]
    pauli_sems = pauli_data["sems"]

    # tick labels from shadow (NU, NM) grid
    step = max(1, n_groups // len(settings_nums))
    tick_positions = list(range(0, n_groups, step))
    tick_labels = [f"({np.sqrt(nu):.2f},{np.sqrt(s):.2f})" for nu, s in random_pairs][::step]

    # plot 1/sems
    df = pd.DataFrame({
        "group": list(range(n_groups)) * 2,
        "ests": np.append(shadow_ests, pauli_ests),
        "1/sems": np.append(1 / shadow_sems, 1 / pauli_sems),
        "method": ["shadow"] * n_groups + ["pauli"] * n_groups
    })
    plt.figure(figsize=(36, 3))
    lineplot(data=df, x='group', y='1/sems', hue="method", marker="o")
    plt.xticks(ticks=tick_positions, labels=tick_labels, rotation=45, ha='right')
    plt.title('z_sems')
    plt.savefig(pic_dir / "z_sems.png", bbox_inches='tight')
    plt.clf()

    # plot ests
    plt.figure(figsize=(36, 3))
    lineplot(data=df, x='group', y='ests', hue="method", marker="o")
    plt.xticks(ticks=tick_positions, labels=tick_labels, rotation=45, ha='right')
    plt.title('z_ests')
    plt.savefig(pic_dir / "z_ests.png", bbox_inches='tight')
    plt.clf()


if __name__ == "__main__":
    plot_z()
