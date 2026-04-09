import pandas as pd
import matplotlib.pyplot as plt
import matplotlib.ticker as ticker
import sys
import os

# ── Config ────────────────────────────────────────────────────────────────────
EXCEL_FILE = "omp_benchmarks.xlsx"
THREADS    = [1, 2, 4, 8, 10, 12]
COLORS     = plt.cm.tab10.colors

# Energy file display order (smallest → largest problem)
ENERGY_ORDER = ['energy4', 'energy5', 'energy6', 'energy7', 'energy8', 'energy9', 'energy10']

# ── Load data ─────────────────────────────────────────────────────────────────
if not os.path.exists(EXCEL_FILE):
    print(f"Error: '{EXCEL_FILE}' not found. Place it in the same directory as this script.")
    sys.exit(1)

df = pd.read_excel(EXCEL_FILE)
df.columns = df.columns.str.strip()

# Keep only the energy files present in the file
present = [e for e in ENERGY_ORDER if e in df['Input'].values]

# ── Helper ────────────────────────────────────────────────────────────────────
def plot_speedup(ax, df, energy_files, speedup_col, title, ylabel):
    for i, name in enumerate(energy_files):
        sub = df[df['Input'] == name].sort_values('Threads')
        ax.plot(sub['Threads'], sub[speedup_col],
                marker='o', markersize=5, linewidth=1.8,
                color=COLORS[i % len(COLORS)], label=name, zorder=2)

    ax.set_title(title, fontsize=12, fontweight='bold', pad=8)
    ax.set_xlabel('Number of Threads', fontsize=10)
    ax.set_ylabel(ylabel, fontsize=10)
    ax.set_xticks(THREADS)
    ax.xaxis.set_minor_locator(ticker.NullLocator())
    ax.grid(True, linestyle='--', alpha=0.5)
    ax.legend(fontsize=8, loc='upper left')
    ax.set_xlim(left=0.5)
    ax.set_ylim(bottom=0)

# ── Figure 1: side-by-side total vs computational speedup ─────────────────────
fig, axes = plt.subplots(1, 2, figsize=(14, 5.5))
fig.suptitle('OpenMP Branch-and-Bound — Speedup vs Threads', fontsize=14, fontweight='bold', y=1.01)

plot_speedup(axes[0], df, present, 'Speedup',
             'Total Speedup  (T_total,1 / T_total,p)',
             'Speedup')

plot_speedup(axes[1], df, present, 'Comp_Speedup',
             'Computational Speedup  (T_comp,1 / T_comp,p)',
             'Computational Speedup')

plt.tight_layout()
plt.savefig('speedup_comparison.png', dpi=150, bbox_inches='tight')
print("Saved: speedup_comparison.png")

# ── Figure 2: per-energy-file subplots ────────────────────────────────────────
n = len(present)
ncols = 3
nrows = (n + ncols - 1) // ncols
fig2, axes2 = plt.subplots(nrows, ncols, figsize=(14, 4.5 * nrows), squeeze=False)
fig2.suptitle('OpenMP Speedup per Input File', fontsize=14, fontweight='bold', y=1.01)

for idx, name in enumerate(present):
    ax = axes2[idx // ncols][idx % ncols]
    sub = df[df['Input'] == name].sort_values('Threads')

    ax.plot(sub['Threads'], sub['Speedup'],
            marker='o', markersize=5, linewidth=1.8,
            color='steelblue', label='Total Speedup', zorder=2)
    ax.plot(sub['Threads'], sub['Comp_Speedup'],
            marker='s', markersize=5, linewidth=1.8,
            color='tomato', label='Comp Speedup', zorder=2)

    ax.set_title(name, fontsize=11, fontweight='bold')
    ax.set_xlabel('Threads', fontsize=9)
    ax.set_ylabel('Speedup', fontsize=9)
    ax.set_xticks(THREADS)
    ax.xaxis.set_minor_locator(ticker.NullLocator())
    ax.grid(True, linestyle='--', alpha=0.5)
    ax.legend(fontsize=8)
    ax.set_xlim(left=0.5)
    ax.set_ylim(bottom=0)

# Hide unused subplots
for idx in range(n, nrows * ncols):
    axes2[idx // ncols][idx % ncols].set_visible(False)

plt.tight_layout()
plt.savefig('speedup_per_file.png', dpi=150, bbox_inches='tight')
print("Saved: speedup_per_file.png")

plt.show()
