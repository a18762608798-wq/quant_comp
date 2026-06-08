import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
from pathlib import Path
from seaborn import lineplot

def plot_reflect():
    HERE = Path(__file__).resolve().parent
    shadow_sem_dir = HERE / "../data/random/shadow/"
    pic_dir = HERE / "../pics/random/"
    # get the data
    shadow_sem_dir = Path(shadow_sem_dir)
    shadow_sem_path = shadow_sem_dir / "reflectsems.npz"
    shadow_data = np.load(shadow_sem_path)
    shadow_ests = shadow_data["ests"]
    shadow_sems = shadow_data["sems"]

    # plot sems
    shadow_df = pd.DataFrame({
        "√NU or √ NM": [i for i in range(20, 80, 1)],
        "ests": shadow_ests,
        "1/sems": 1 / shadow_sems,
    })
    lineplot(data=shadow_df, x='√NU or √ NM', y='1/sems')  # 单条线
    plt.savefig(pic_dir / "reflectsems.png")
    plt.clf()  # 清除当前 figure，避免下一张画重叠

    # plot ests
    lineplot(data=shadow_df, x='√NU or √ NM', y='ests')  # 单条线
    plt.savefig(pic_dir / "reflectests.png")
    plt.clf()  # 清除当前 figure，避免下一张画重叠


def plot_purity():
    HERE = Path(__file__).resolve().parent
    shadow_sem_dir = HERE / "../data/random/shadow/"
    pic_dir = HERE / "../pics/random/"
    # get the data
    shadow_sem_dir = Path(shadow_sem_dir)
    shadow_sem_path = shadow_sem_dir / "puritysems.npz"
    shadow_data = np.load(shadow_sem_path)
    shadow_ests = shadow_data["ests"]
    shadow_sems = shadow_data["sems"]

    # plot sems
    shadow_df = pd.DataFrame({
        "√NU or √ NM": [i for i in range(20, 80, 1)],
        "ests": shadow_ests,
        "1/sems": 1 / shadow_sems,
    })
    lineplot(data=shadow_df, x='√NU or √ NM', y='1/sems')  # 单条线
    plt.savefig(pic_dir / "puritysems.png")
    plt.clf()  # 清除当前 figure，避免下一张画重叠

    # plot ests
    lineplot(data=shadow_df, x='√NU or √ NM', y='ests')  # 单条线
    plt.savefig(pic_dir / "purityests.png")
    plt.clf()  # 清除当前 figure，避免下一张画重叠
    
if __name__ == "__main__":
    plot_reflect()
    plot_purity()




