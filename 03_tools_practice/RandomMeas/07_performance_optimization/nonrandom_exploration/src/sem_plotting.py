import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
from pathlib import Path
from seaborn import lineplot

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
        "√NU or √ NM": [i for i in range(20, 25, 1)] * 3,
        "ests": np.append(shadow_ests, np.append(hamming_ests, pauli_ests)),
        "1/sems": np.append(1 / shadow_sems, np.append(1 / hamming_sems, 1 / pauli_sems)),
        "calculate_way": ["shadow" for i in range(20, 25)] + ["hamming" for i in range(20, 25)] + ["pauli" for i in range(20, 25)] 
    })
    lineplot(data=df, x='√NU or √ NM', y='1/sems', hue="calculate_way", marker="o",)  
    plt.title('reflect_sems')
    plt.savefig(pic_dir / "reflect_sems.png")
    plt.clf()  

    # plot ests
    lineplot(data=df, x='√NU or √ NM', y='ests', hue="calculate_way", marker="o",)  
    plt.title('reflect_ests')
    plt.savefig(pic_dir / "reflect_ests.png")
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

    # plot sems
    df = pd.DataFrame({
        "√NU or √ NM": [i for i in range(20, 25, 1)] * 2,
        "ests": np.append(shadow_ests, hamming_ests),
        "1/sems": np.append(1 / shadow_sems, 1 / hamming_sems),
        "calculate_way": ["shadow" for i in range(20, 25)] + ["hamming" for i in range(20, 25)] 
    })
    lineplot(data=df, x='√NU or √ NM', y='1/sems', hue="calculate_way", marker="o",)  
    plt.title('purity_sems')
    plt.savefig(pic_dir / "purity_sems.png")
    plt.clf()  

    # plot ests
    lineplot(data=df, x='√NU or √ NM', y='ests', hue="calculate_way", marker="o",)  
    plt.title('purity_ests')
    plt.savefig(pic_dir / "purity_ests.png")
    plt.clf()  
    
if __name__ == "__main__":
    plot_reflect()
    plot_purity()
