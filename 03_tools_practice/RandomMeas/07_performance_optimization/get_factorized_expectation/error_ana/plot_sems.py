import numpy as np
import pandas as pd
from pathlib import Path
import seaborn as sns
import matplotlib.pyplot as plt

HERE = Path(__file__).resolve().parent


def plot_sems_of_diff_size():
    # get the data
    filename = "./data/compare_diff_size.npz"
    input_path = HERE / filename
    data = np.load(input_path)
    N_ls = data["N_ls"]
    expect_val_vec = data["expect_val_vec"]
    sem_vec = data["sem_vec"]
    df1 = pd.DataFrame(
        {
            "N": N_ls,
            "expect": expect_val_vec,
        }
    )
    df2 = pd.DataFrame(
        {
            "N": N_ls,
            "sem": sem_vec,
        }
    )
    # figure
    ax = [0, 0]
    fig = plt.figure(figsize=(12, 4))
    ax[0] = fig.add_subplot(1, 2, 1)
    ax[1] = fig.add_subplot(1, 2, 2)
    sns.lineplot(data=df1, x="N", y="expect", ax=ax[0])
    sns.lineplot(data=df2, x="N", y="sem", ax=ax[1])
    # titles
    ax[0].set_title("expect")
    ax[1].set_title("sem")
    # output
    output_path = HERE / "sems_of_diff_size.jpg"
    plt.savefig(output_path)
    plt.show()


def plot_sems_of_diff_settings():
    # get the data
    filename = "./data/compare_diff_settings.npz"
    input_path = HERE / filename
    data = np.load(input_path)
    settings_num_ls = data["settings_num_ls"]
    shots_ls = data["shots_ls"]
    expect_val_matrix = data["expect_val_matrix"]
    sem_matrix = data["sem_matrix"]
    # figure
    ax = [0, 0]
    fig = plt.figure(figsize=(10, 4))
    ax[0] = fig.add_subplot(1, 2, 1)
    ax[1] = fig.add_subplot(1, 2, 2)
    sns.heatmap(np.abs(np.real(expect_val_matrix) - 1), cmap="coolwarm", ax=ax[0])
    sns.heatmap(np.sqrt(np.real(sem_matrix)), cmap="coolwarm", ax=ax[1])
    # titles
    ax[0].set_title(r"|expect - 1|")
    ax[1].set_title(r"$\sqrt{sem}$")
    # labels
    ax[0].set_xlabel("NU")
    ax[1].set_xlabel("NU")
    ax[0].set_ylabel("NM")
    ax[1].set_ylabel("NM")
    # ticks
    ax[0].set_xticklabels([str(i) for i in settings_num_ls])
    ax[1].set_xticklabels([str(i) for i in settings_num_ls])
    ax[0].set_yticklabels([str(i) for i in shots_ls])
    ax[1].set_yticklabels([str(i) for i in shots_ls])
    # output
    output_path = HERE / "sems_of_diff_settings.jpg"
    plt.savefig(output_path)
    plt.show()


if __name__ == "__main__":
    plot_sems_of_diff_size()
    plot_sems_of_diff_settings()
