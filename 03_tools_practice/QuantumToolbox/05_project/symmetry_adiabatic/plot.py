import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
from pathlib import Path
from seaborn import lineplot
from seaborn import scatterplot


def plot_spectrum(data_path, pic_path, show_eigen_vec=np.array([0, 1, 2, 3])):
    # get data
    data = np.load(data_path)
    tlist = data["tlist"][1:]
    spectrum_arr = data["Ets"][show_eigen_vec, 1:]  
    energy_num = np.size(show_eigen_vec) 
    t_num = np.size(tlist)
    names = [f"E_{i}" for i in show_eigen_vec]
    df = pd.DataFrame({
        "t": np.tile(tlist, energy_num), 
        "E": spectrum_arr.ravel(),
        "name": np.repeat(names, t_num)
    })
    # plot
    plt.figure(figsize=(12, 8))
    lineplot(data=df, x='t', y='E', hue='name')
    plt.savefig(pic_path, bbox_inches='tight')
    plt.title("sepctrum")


def plot_gap(data_path, pic_path, show_eigen_vec=np.array([1, 2, 3])):
    # get data
    data = np.load(data_path)
    tlist = data["tlist"][1:]
    spectrum_arr = data["Ets"][:, 1:]
    gap_arr = spectrum_arr[show_eigen_vec, :] - spectrum_arr[0, :]   # shape: (energy_num-1, t_num)
    energy_num = np.size(show_eigen_vec)
    t_num = np.size(tlist)
    names = [f"gap_{i}" for i in show_eigen_vec]
    df = pd.DataFrame({
        "t": np.tile(tlist, energy_num), 
        "ΔE": gap_arr.ravel(),
        "name": np.repeat(names, t_num)
    })
    # plot
    plt.figure(figsize=(12, 8))
    lineplot(data=df, x='t', y='ΔE', hue='name')
    plt.savefig(pic_path, bbox_inches='tight')
    plt.title("gap")


def plot_Mzt(eigen_path, evolution_path, pic_path, show_eigen_vec = np.array([0])):
    # get data
    eigen_data = np.load(eigen_path)
    evolution_data = np.load(evolution_path)
    tlist = eigen_data["tlist"][1:]
    eigen_Mzt = eigen_data["Ot_vals"][show_eigen_vec, 1:]
    evolution_Mzt = evolution_data["Ot_vals"][1:]
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
    tlist = eigen_data["tlist"][1:]
    eigen_states = eigen_data["eigen_states_t"][:, show_eigen_vec, 1:]
    evolution_states = evolution_data["evolution_states_t"][:, 1:]
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
    plt.ylim(1.0 - 1e-2, 1.0) # limit y to see the variation of overlaps.
    plt.savefig(pic_path, bbox_inches='tight')
    plt.title("Overlaps")


if __name__ == "__main__":
    HERE = Path(__file__).resolve().parent
    # spectrum
    eigen_data_path = HERE / "./data/eigen.npz"
    pic_path = HERE / "./pic/spectrum.png"
    plot_spectrum(eigen_data_path, pic_path, show_eigen_vec=np.array([0, 1, 2, 3]))
    # gap
    eigen_data_path = HERE / "./data/eigen.npz"
    pic_path = HERE / "./pic/gap.png"
    plot_gap(eigen_data_path, pic_path, show_eigen_vec=np.array([1, 2, 3]))
    # Mzt
    evolution_data_path = HERE / "./data/evolution.npz"
    pic_path = HERE / "./pic/Mzt.png"
    #plot_Mzt(eigen_data_path, evolution_data_path, pic_path, show_eigen_vec = np.array([0]))
    # overlap
    pic_path = HERE / "./pic/overlaps.png"
    plot_overlap(eigen_data_path, evolution_data_path, pic_path, show_eigen_vec = np.array([0]))

