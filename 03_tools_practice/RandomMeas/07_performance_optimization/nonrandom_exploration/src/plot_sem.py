import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
from pathlib import Path
from seaborn import lineplot

def plot_sems(
    sem_dir, 
    pic_dir
):
    # get the data
    sem_dir = Path(sem_dir)
    sem_path = sem_dir / "sems.npz"
    data = np.load(sem_path)
    ests = data["ests"]
    sems = data["sems"]

    # plot
    df = pd.DataFrame({
        "√NU": [i for i in range(20, 60, 5)],
        "ests": ests,
        "1/sems": 1 / sems,
    })
    lineplot(data=df, x='√NU', y='1/sems')  # 单条线
    plt.savefig(pic_dir / "sems.png")
    plt.show()
    
if __name__ == "__main__":
    HERE = Path(__file__).resolve().parent
    sem_dir = HERE / "../data/random/shadow/"
    pic_dir = HERE / "../pics/random/"
    plot_sems(sem_dir, pic_dir)




