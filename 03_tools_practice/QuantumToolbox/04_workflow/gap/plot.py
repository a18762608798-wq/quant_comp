import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
from pathlib import Path
from seaborn import lineplot
from seaborn import scatterplot


def plot_gap(data_folder, pic_path):
    # get data
    data = np.load(data_folder)
    L = data["L"][7:]
    L_num = np.size(L)
    E_gap = data["E_gap"][7:]
    names = ["E_gap with 1/L"]
    df = pd.DataFrame({
        "1/L": 1 / L,
        "E_gap": E_gap,
        "name": np.repeat(names, L_num)
    })
    # linear fit: E_gap = intercept + slope * (1/L)
    x_fit = 1 / L
    y_fit = E_gap
    coeffs = np.polyfit(x_fit, y_fit, 1)
    slope, intercept = coeffs[0], coeffs[1]
    y_pred = np.polyval(coeffs, x_fit)
    ss_res = np.sum((y_fit - y_pred) ** 2)
    ss_tot = np.sum((y_fit - np.mean(y_fit)) ** 2)
    r2 = 1 - ss_res / ss_tot
    print(f"拟合结果: E_gap = {intercept:.6f} + {slope:.6f} * (1/L)")
    print(f"截距 E_gap(∞) = {intercept:.6f}")
    print(f"R² = {r2:.6f}")
    # plot
    plt.figure(figsize=(12, 8))
    lineplot(data=df, x='1/L', y='E_gap', hue='name')
    # plot fit line
    x_line = np.linspace(0, np.max(x_fit) * 1.1, 100)
    y_line = intercept + slope * x_line
    label_fit = f"fit: $E_\mathrm{{gap}}(\infty) = {intercept:.4f}$"
    plt.plot(x_line, y_line, '--', color='red', label=label_fit)
    plt.legend()
    plt.xlabel("1/L")
    plt.ylabel("$E_\mathrm{gap}$")
    plt.title("$E_\mathrm{gap}$ vs $1/L$")
    plt.savefig(pic_path, bbox_inches='tight')
    print(f"图片已保存至: {pic_path}")


if __name__ == "__main__":
    HERE = Path(__file__).resolve().parent
    gap_data_path = HERE / "./data/gap.npz"
    pic_path = HERE / "./pic/gap.png"
    plot_gap(gap_data_path, pic_path)

