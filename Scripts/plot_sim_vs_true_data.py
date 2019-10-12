# This script plots the MBAR vs true data
# Example:
# python3.6 plot_sim_vs_true_data.py 170.33484 $HOME/Git/TranSFF/Data/C12/REFPROP_select5.res REFPROP out.png trhozures.res

import matplotlib
import numpy
import sys
import os
if os.environ.get('DISPLAY','') == '': # then no display found. Use non-interactive Agg backend'
    matplotlib.use('Agg')
import matplotlib.pyplot as plt

MW = float(sys.argv[1])
true_data_file = sys.argv[2]               # The file that is used to minimize the deviations against, i.e. the target. It could be experimental data or a simulation results of a force field from literature.
true_data_label = sys.argv[3]               # Label for true data
output_figure_filename = sys.argv[4]        # Output file name
dsim_data_file = sys.argv[5]            # If provided, this argument is a file containing direct simulation results


# Conversion factors and constants
atm_to_mpa = 0.101325
kcalmol_to_kjmol = 4.184
bar_to_mpa = 0.1
kelvin_to_kjmol = 0.0083
R_const = 8.31446261815324

# Import data
true_data = numpy.loadtxt(true_data_file, skiprows=1)
true_temp_k = true_data[:,0]
true_rho_gcc = true_data[:,1]
true_z = true_data[:,2]
true_u_res = true_data[:,3]
true_zminus1overRho = ( true_z - 1 ) / true_rho_gcc

dsim_data = numpy.loadtxt(dsim_data_file, skiprows=1)
dsim_temp_k = dsim_data[:,0]
dsim_rho_gcc = dsim_data[:,1]
dsim_z = dsim_data[:,2]
dsim_z_std = dsim_data[:,3]
dsim_u_res = dsim_data[:,4]
dsim_u_res_std = dsim_data[:,5]
dsim_zminus1overRho = ( dsim_z - 1 ) / dsim_rho_gcc
dsim_zminus1overRho_err = dsim_z_std / dsim_rho_gcc

############### Initiate plot #############################################
plt.figure(num=None, figsize=(24, 7), dpi=100, facecolor='w', edgecolor='w')
plt.subplots_adjust(left=0.04, bottom=None, right=0.99, top=None, wspace=0.3, hspace=None)
font = {'weight' : 'normal', 'size' : 14}
matplotlib.rc('font', **font)    

############### (Z-1)/rho vs. rho plot ##############################
plt.subplot(1, 3, 1 )
plt.xlabel("$\\rho$ [$\mathrm{g/cm^3}$]")
plt.ylabel("$(Z-1)/\\rho}$ [$\mathrm{cm^3/g}$]")

plt.scatter(true_rho_gcc, true_zminus1overRho, marker="s", s=70, facecolors='none', edgecolors='k', label=true_data_label)

plt.scatter(dsim_rho_gcc, dsim_zminus1overRho, marker="^", s=70, facecolors='none', edgecolors='g', label='Direct simulation')
plt.errorbar(dsim_rho_gcc, dsim_zminus1overRho, yerr=dsim_zminus1overRho_err, color='g', capsize=5, marker=None, linewidth=0, elinewidth=1, ms=0)

plt.legend()

############### Z vs. 1000/T plot #############################################
plt.subplot(1, 3, 2 )
plt.xlabel("$1000/T$ [K$^{-1}$]")
plt.ylabel("$Z$")
plt.scatter(1000.0 / true_temp_k, true_z, marker="s", s=70, facecolors='none', edgecolors='k')

plt.scatter(1000.0 / dsim_temp_k, dsim_z, marker="^", s=70, facecolors='none', edgecolors='g')
plt.errorbar(1000.0 / dsim_temp_k, dsim_z, yerr=dsim_z_std, color='g', capsize=5, marker=None, linewidth=0, elinewidth=1, ms=0)

############### TU^ vs 1000/T plot #############################################
plt.subplot(1, 3, 3 )
plt.xlabel("$1000/T$ [K$^{-1}$]")
plt.ylabel("$T\hat{U}^\mathrm{res}$ [K]")
plt.scatter(1000.0 / true_temp_k, true_u_res * true_temp_k, marker="s", s=70, facecolors='none', edgecolors='k')

plt.scatter(1000.0 / dsim_temp_k, dsim_u_res * dsim_temp_k, marker="^", s=70, facecolors='none', edgecolors='g')

plt.savefig(output_figure_filename)
plt.close()