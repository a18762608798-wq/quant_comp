import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
from pathlib import Path
from seaborn import lineplot
from seaborn import scatterplot


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
    spectrum_min = np.min(spectrum_arr)
    spectrum_max = np.max(spectrum_arr[:, t_num // 2])
    spectrum_intvl = spectrum_max - spectrum_min
    plt.ylim(spectrum_min - spectrum_intvl * 1/6, spectrum_max + spectrum_intvl * 1/6)
    plt.savefig(pic_path, bbox_inches='tight')
    plt.title("spectrum")


def plot_Mzt(eigen_path, evolution_path, pic_path, show_eigen_vec = np.array([0])):
    # get data
    eigen_data = np.load(eigen_path)
    evolution_data = np.load(evolution_path)
    tlist = eigen_data["tlist"]
    eigen_Mzt = eigen_data["Ot_vals"][show_eigen_vec, :]
    evolution_Mzt = evolution_data["Ot_vals"][:]
    t_num = np.size(tlist)
    show_eigen_num = np.size(show_eigen_vec)
    names = np.append([f"eigen_Mzt{i}" for i in show_eigen_vec], ["evolution_Mzt"])
    df = pd.DataFrame({
        "t": np.tile(tlist, 1 + show_eigen_num), 
        "Mz(t)": np.append(eigen_Mzt.ravel(), evolution_Mzt),
        "name": np.repeat(names, t_num)
    })
    # plot
    plt.figure(figsize=(12, 8))
    lineplot(data=df, x='t', y='Mz(t)', hue='name', style='name')
    plt.savefig(pic_path, bbox_inches='tight')
    plt.title("Mz")


def plot_overlap(eigen_path, evolution_path, pic_path, show_eigen_vec = np.array([0])):
    # get data
    eigen_data = np.load(eigen_path)
    evolution_data = np.load(evolution_path)
    tlist = eigen_data["tlist"]
    eigen_states = eigen_data["eigen_states_t"][:, show_eigen_vec, :]
    evolution_states = evolution_data["evolution_states_t"][:, :]
    t_num = np.size(tlist)
    show_eigen_num = np.size(show_eigen_vec)
    # clean data, overlap[k, t] = | <ground_k(t) | psi(t)> |^2
    overlaps = np.abs(
        np.einsum("ikt,it->kt", np.conj(eigen_states), evolution_states)
    ) ** 2
    names = [f"overlaps{i}" for i in show_eigen_vec]
    df = pd.DataFrame({
        "t": np.tile(tlist, show_eigen_num),
        "overlaps": overlaps.ravel(order="C"), 
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
    plot_Mzt(eigen_data_path, evolution_data_path, pic_path, show_eigen_vec = np.array([0]))
    pic_path = HERE / "./pic/overlaps.png"
    plot_overlap(eigen_data_path, evolution_data_path, pic_path, show_eigen_vec = np.array([0]))

