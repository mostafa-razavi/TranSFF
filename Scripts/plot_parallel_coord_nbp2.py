# This script visualizes the Auxiliary Nested PSO optimization for when two non-bonded parameters are being optimized
# Example:
# python3.6 plot_parallel_coord_nbp2.py All_scores.res All_scores.res.png 2 CH_3 CH_2

import matplotlib as mpl
from mpl_toolkits.mplot3d import Axes3D
import numpy
import pandas as pd
import matplotlib.pyplot as plt
from matplotlib import ticker
import sys

score_file = sys.argv[1]
output_figure_filename = sys.argv[2]
NS = int(sys.argv[3])
if NS < 1:
    raise ValueError("Number of site types (NS) should be an integer greater or equal to 1")
for i in range(1, NS+1):
    exec('SiteTypeName' + str(i) + '= sys.argv[3+ ' + str(i) + "]")

if NS == 1:
    cols = ['MBAR_Sig1', 'MBAR_Eps1']
    COLS = ['ref_sig1', 'ref_eps1']
    cols_COLS = [ 'MBAR_Sig1', 'MBAR_Eps1', 'ref_sig1', 'ref_eps1' ]
    ytitles = ['$\sigma_{' + SiteTypeName1 + '}$ [$\mathrm{\AA}$]', '${\epsilon/k_\mathrm{B}}_{' + SiteTypeName1 + '}$ [K]' ]

if NS == 2:
    cols = ['MBAR_Sig1', 'MBAR_Eps1', 'MBAR_Sig2', 'MBAR_Eps2']
    COLS = ['ref_sig1', 'ref_eps1', 'ref_sig2', 'ref_eps2']
    cols_COLS = [ 'MBAR_Sig1', 'MBAR_Eps1', 'MBAR_Sig2', 'MBAR_Eps2', 'ref_sig1', 'ref_eps1', 'ref_sig2', 'ref_eps2' ]
    ytitles = ['$\sigma_{' + SiteTypeName1 + '}$ [$\mathrm{\AA}$]', '${\epsilon/k_\mathrm{B}}_{' + SiteTypeName1 + '}$ [K]', '$\sigma_{' + SiteTypeName2 + '}$ [$\mathrm{\AA}$]', '${\epsilon/k_\mathrm{B}}_{' + SiteTypeName2 + '}$ [K]' ]

df = pd.read_csv(score_file, sep=' ')

NI = df['I'].max()
NP = df['P'].max()

x = [i for i, _ in enumerate(cols)]

if NP == 2: 
    PCOLORS = ['red', 'green']
if NP == 3: 
    PCOLORS = ['red', 'green', 'blue']
if NP == 4: 
    PCOLORS = ['red', 'green', 'blue', 'orange']
if NP == 5: 
    PCOLORS = ['red', 'green', 'blue', 'orange', 'cyan']
if NP == 6: 
    PCOLORS = ['red', 'green', 'blue', 'orange', 'cyan', 'purple']

# Create sublots along x axis
fig, axes = plt.subplots(NI, len(x)-1, sharey=False, figsize=(5*len(x)-1, 5*NI), squeeze=0)


# Get min, max and range for each column, Normalize the data for each column
min_max_range = {}
for col in cols:
    min_max_range[col] = [df[col].min(), df[col].max(), numpy.ptp(df[col])]
    df[col] = numpy.true_divide(df[col] - df[col].min(), numpy.ptp(df[col]))
n=-1
for col in COLS:
    n = n + 1
    min_max_range[col] = [df[cols[n]].min(), df[cols[n]].max(), numpy.ptp(df[cols[n]])]
    df[col] = numpy.true_divide(df[cols[n]] - df[cols[n]].min(), numpy.ptp(df[cols[n]]))

for ITERATION in range(0, NI):
    for iax, ax in enumerate(axes[ITERATION]):
        for idx in df.index:
            I = df.iloc[idx,0]
            P = df.iloc[idx,1]
            if I == ITERATION + 1:
                y = df.loc[idx, cols]
                ax.plot(x, y, color=PCOLORS[P-1], alpha=0.05)    # plot particles

                i = df.iloc[idx,2] 
                p = df.iloc[idx,3] 
                if i == 1 and p == 1:
                    Y = df.loc[idx, COLS]
                    ax.plot(x, Y, color=PCOLORS[P-1], alpha=0.8, dashes=[2, 5, 3, 5])   # plot PARTICLES
            
        ax.set_xlim([x[iax], x[iax+1]])
      
    # Set the tick positions and labels on y axis for each plot. Tick positions based on normalised data. Tick labels are based on original data
    def set_ticks_for_axis(dim, ax, ticks):
        min_val, max_val, val_range = min_max_range[cols[dim]]
        step = val_range / float(ticks-1)
        tick_labels = [round(min_val + step * i, 2) for i in range(ticks)]
        norm_min = df[cols[dim]].min()
        norm_range = numpy.ptp(df[cols[dim]])
        norm_step = norm_range / float(ticks-1)
        ticks = [round(norm_min + norm_step * i, 3) for i in range(ticks)]
        ax.yaxis.set_ticks(ticks)
        ax.set_yticklabels(tick_labels)

    for dim, ax in enumerate(axes[ITERATION]):
        ax.xaxis.set_major_locator(ticker.FixedLocator([dim]))
        set_ticks_for_axis(dim, ax, ticks=20)
        if ITERATION == NI - 1:
            ax.set_xticklabels([ytitles[dim]])
        else: 
            ax.set_xticklabels([""])
        

    # Move the final axis' ticks to the right-hand side
    ax = plt.twinx(axes[ITERATION, -1])
    dim = len(axes[ITERATION])
    ax.xaxis.set_major_locator(ticker.FixedLocator([x[-2], x[-1]]))
    set_ticks_for_axis(dim, ax, ticks=20)
    if ITERATION == NI - 1:
        ax.set_xticklabels([ytitles[-2], ytitles[-1]])
    else:
        ax.set_xticklabels(["", ""])


    ax.set_ylabel("Iteration " + str(ITERATION + 1))

# Remove space between subplots
plt.subplots_adjust(wspace=0) #, hspace=0)

#plt.show()
plt.savefig(output_figure_filename)
plt.close()