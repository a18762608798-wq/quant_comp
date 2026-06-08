import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
from pathlib import Path
from seaborn import lineplot

def plot_reflect():
    HERE = Path(__file__).resolve().parent
    shadow_sem_dir = HERE / "../data/random/"
    pic_dir = HERE / "../pics/"
    # get the data
    shadow_sem_dir = Path(shadow_sem_dir)
    shadow_sem_path = shadow_sem_dir / "reflect_sems.npz"
    shadow_data = np.load(shadow_sem_path)
    shadow_ests = shadow_data["ests"]
    shadow_sems = shadow_data["sems"]

    # plot sems
    shadow_df = pd.DataFrame({
        "√NU or √ NM": [i for i in range(20, 25, 1)],
        "ests": shadow_ests,
        "1/sems": 1 / shadow_sems,
    })
    lineplot(data=shadow_df, x='√NU or √ NM', y='1/sems')  
    plt.savefig(pic_dir / "reflect_sems.png")
    plt.clf()  

    # plot ests
    lineplot(data=shadow_df, x='√NU or √ NM', y='ests')  
    plt.savefig(pic_dir / "reflect_ests.png")
    plt.clf()  


def plot_purity():
    HERE = Path(__file__).resolve().parent
    shadow_sem_dir = HERE / "../data/random/"
    pic_dir = HERE / "../pics/"
    # get the data
    shadow_sem_dir = Path(shadow_sem_dir)
    shadow_sem_path = shadow_sem_dir / "purity_sems.npz"
    shadow_data = np.load(shadow_sem_path)
    shadow_ests = shadow_data["ests"]
    shadow_sems = shadow_data["sems"]

    # plot sems
    shadow_df = pd.DataFrame({
        "√NU or √ NM": [i for i in range(20, 25, 1)],
        "ests": shadow_ests,
        "1/sems": 1 / shadow_sems,
    })
    lineplot(data=shadow_df, x='√NU or √ NM', y='1/sems')  
    plt.savefig(pic_dir / "purity_sems.png")
    plt.clf()  

    # plot ests
    lineplot(data=shadow_df, x='√NU or √ NM', y='ests')  
    plt.savefig(pic_dir / "purity_ests.png")
    plt.clf()  
    
if __name__ == "__main__":
    plot_reflect()
    plot_purity()
