import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
from pathlib import Path
from seaborn import lineplot

from circs_running import settings_nums
from circs_running import shot_nums
from circs_running import pairs

step = max(1, len(pairs) // len(settings_nums))
tick_positions = list(range(0, len(pairs), step))
tick_labels = [f"({int(np.sqrt(nu))},{int(np.sqrt(s))})" for nu, s in pairs][::step]


def plot_reflect():
    HERE = Path(__file__).resolve().parent
    sem_dir = HERE / "../data/"
    pic_dir = HERE / "../pics/"
    sem_dir = Path(sem_dir)
    # get the data
    # shadow
    shadow_sem_path = sem_dir / "reflect_sems_shadow.npz"
    shadow_data = np.load(shadow_sem_path)
    shadow_ests = shadow_data["ests"]
    shadow_sems = shadow_data["sems"]
    # hamming
    hamming_sem_path = sem_dir / "reflect_sems_hamming.npz"
    hamming_data = np.load(hamming_sem_path)
    hamming_ests = hamming_data["ests"]
    hamming_sems = hamming_data["sems"]
    # pauli
    pauli_sem_path = sem_dir / "reflect_sems_pauli.npz"
    pauli_data = np.load(pauli_sem_path)
    pauli_ests = pauli_data["ests"]
    pauli_sems = pauli_data["sems"]

    # plot sems
    df = pd.DataFrame({
        "(√NU, √NM)": list(range(len(pairs))) * 3,
        "ests": np.append(shadow_ests, np.append(hamming_ests, pauli_ests)),
        "1/sems": np.append(1 / shadow_sems, np.append(1 / hamming_sems, 1 / pauli_sems)),
        "calculate_way": ["shadow"] * len(pairs) + ["hamming"] * len(pairs) + ["pauli"] * len(pairs)
    })
    plt.figure(figsize=(36, 3))
    lineplot(data=df, x='(√NU, √NM)', y='1/sems', hue="calculate_way", marker="o",)
    plt.xticks(ticks=tick_positions, labels=tick_labels, rotation=45, ha='right')
    plt.title('reflect_sems')
    plt.savefig(pic_dir / "reflect_sems.png", bbox_inches='tight')
    plt.clf()

    # plot ests
    plt.figure(figsize=(36, 3))
    lineplot(data=df, x='(√NU, √NM)', y='ests', hue="calculate_way", marker="o",)
    plt.xticks(ticks=tick_positions, labels=tick_labels, rotation=45, ha='right')
    plt.title('reflect_ests')
    plt.savefig(pic_dir / "reflect_ests.png", bbox_inches='tight')
    plt.clf()


def plot_purity():
    HERE = Path(__file__).resolve().parent
    sem_dir = HERE / "../data/"
    pic_dir = HERE / "../pics/"
    sem_dir = Path(sem_dir)
    # get the data
    # shadow
    shadow_sem_path = sem_dir / "purity_sems_shadow.npz"
    shadow_data = np.load(shadow_sem_path)
    shadow_ests = shadow_data["ests"]
    shadow_sems = shadow_data["sems"]
    # hamming
    hamming_sem_path = sem_dir / "purity_sems_hamming.npz"
    hamming_data = np.load(hamming_sem_path)
    hamming_ests = hamming_data["ests"]
    hamming_sems = hamming_data["sems"]
    # pauli
    pauli_sem_path = sem_dir / "purity_sems_pauli.npz"
    pauli_data = np.load(pauli_sem_path)
    pauli_ests = pauli_data["ests"]
    pauli_sems = pauli_data["sems"]

    # plot sems
    df = pd.DataFrame({
        "(√NU, √NM)": list(range(len(pairs))) * 3,
        "ests": np.append(shadow_ests, np.append(hamming_ests, pauli_ests)),
        "1/sems": np.append(1 / shadow_sems, np.append(1 / hamming_sems, 1 / pauli_sems)),
        "calculate_way": ["shadow"] * len(pairs) + ["hamming"] * len(pairs) + ["pauli"] * len(pairs)
    })
    plt.figure(figsize=(36, 3))
    lineplot(data=df, x='(√NU, √NM)', y='1/sems', hue="calculate_way", marker="o",)
    plt.xticks(ticks=tick_positions, labels=tick_labels, rotation=45, ha='right')
    plt.title('purity_sems')
    plt.savefig(pic_dir / "purity_sems.png", bbox_inches='tight')
    plt.clf()

    # plot ests
    plt.figure(figsize=(36, 3))
    lineplot(data=df, x='(√NU, √NM)', y='ests', hue="calculate_way", marker="o",)
    plt.xticks(ticks=tick_positions, labels=tick_labels, rotation=45, ha='right')
    plt.title('purity_ests')
    plt.savefig(pic_dir / "purity_ests.png", bbox_inches='tight')
    plt.clf()


if __name__ == "__main__":
    plot_reflect()
    plot_purity()
