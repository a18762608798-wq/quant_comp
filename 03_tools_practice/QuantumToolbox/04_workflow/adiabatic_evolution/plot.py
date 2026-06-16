import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
from pathlib import Path
from seaborn import lineplot


def plot_spectrum(data_path, pic_path):
    # get data
    data = np.load(data_path)
    tlist = data["tlist"]
    spectrum_arr = data["Ets"]
    energy_num, _ = np.shape(spectrum_arr)
    t_num = np.size(tlist)
    names = [f"E_{i}" for i in range(energy_num)]
    df = pd.DataFrame({
        "t": np.tile(tlist, energy_num), 
        "E": spectrum_arr.ravel(),
        "name": np.repeat(names, t_num)
    })
    # plot
    plt.figure(figsize=(12, 8))
    lineplot(data=df, x='t', y='E', hue='name')
    plt.savefig(pic_path, bbox_inches='tight')
    plt.title("spectrum")


def plot_Mzt(eigen_path, evolution_path, pic_path):
    # get data
    eigen_data = np.load(eigen_path)
    evolution_data = np.load(evolution_path)
    tlist = eigen_data["tlist"]
    ground_Mzt = eigen_data["Ot_vals"]
    evolution_Mzt = evolution_data["Ot_vals"]
    t_num = np.size(tlist)
    names = ["ground_Mzt", "evolution_Mzt"]
    df = pd.DataFrame({
        "t": np.tile(tlist, 2), 
        "Mz(t)": np.append(ground_Mzt, evolution_Mzt),
        "name": np.repeat(names, t_num)
    })
    # plot
    plt.figure(figsize=(12, 8))
    lineplot(data=df, x='t', y='Mz(t)', hue='name')
    plt.savefig(pic_path, bbox_inches='tight')
    plt.title("Mz")


def plot_overlap(eigen_path, evolution_path, pic_path):
    # get data
    eigen_data = np.load(eigen_path)
    evolution_data = np.load(evolution_path)
    tlist = eigen_data["tlist"]
    ground_states = eigen_data["eigen_states_t"][:, 0, :]
    evolution_states = evolution_data["evolution_states_t"][:, :]
    # overlap = |<ground|evolution>|^2 at each time step
    overlaps = np.abs(np.sum(np.conj(ground_states) * evolution_states, axis=0)) ** 2
    t_num = np.size(tlist)
    names = ["overlaps"]
    df = pd.DataFrame({
        "t": tlist,
        "overlaps": overlaps,
        "name": np.repeat(names, t_num)
    })
    # plot
    plt.figure(figsize=(12, 8))
    lineplot(data=df, x='t', y='overlaps', hue='name')
    plt.savefig(pic_path, bbox_inches='tight')
    plt.title("Overlaps")


if __name__ == "__main__":
    HERE = Path(__file__).resolve().parent
    eigen_data_path = HERE / "./data/eigen.npz"
    pic_path = HERE / "./pic/spectrum.png"
    plot_spectrum(eigen_data_path, pic_path)
    evolution_data_path = HERE / "./data/evolution.npz"
    pic_path = HERE / "./pic/Mzt.png"
    plot_Mzt(eigen_data_path, evolution_data_path, pic_path)
    pic_path = HERE / "./pic/overlaps.png"
    plot_overlap(eigen_data_path, evolution_data_path, pic_path)

