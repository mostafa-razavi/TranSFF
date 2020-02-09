# This script plots the MBAR vs true data
# Example:
# python3.6 $HOME/Git/TranSFF/Scripts/plot_mbar_vs_true_data_2.py 170.33484 $HOME/Git/TranSFF/Data/C12/REFPROP_select5.res my_keyword/my_keyword.target.res REFPROP out.png C12_s3.780e120.0_s4.00e60.0/trhozures.res
    
    
import matplotlib
import numpy
import sys
import os
if os.environ.get('DISPLAY','') == '': # then no display found. Use non-interactive Agg backend'
    matplotlib.use('Agg')
import matplotlib.pyplot as plt

MW = float(sys.argv[1])
true_data_file = sys.argv[2]               # The file that is used to minimize the deviations against, i.e. the target. It could be experimental data or a simulation results of a force field from literature.
mbar_data_file = sys.argv[3]               # The file that contains MBAR results at ITIC state points
true_data_label = sys.argv[4]               # Label for true data
output_figure_filename = sys.argv[5]        # Output file name
try:
    dsim_data_file = sys.argv[6]            # If provided, this argument is a file containing direct simulation results
except:
    isDSIM = False
else:
    isDSIM = True


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

mbar_data = numpy.loadtxt(mbar_data_file, skiprows=1)
mbar_temp_k = mbar_data[:,0]
mbar_rho_gcc = mbar_data[:,1]
mbar_Nmolec = mbar_data[:,2]
Neff = mbar_data[:,3]
mbar_p_mpa = mbar_data[:,4] * bar_to_mpa
mbar_p_mpa_err = mbar_data[:,5] * bar_to_mpa
mbar_u_kjmol = mbar_data[:,6] * kelvin_to_kjmol
mbar_u_kjmol_err = mbar_data[:,7] * kelvin_to_kjmol
mbar_ub_kjmol = mbar_data[:,8] * kelvin_to_kjmol
mbar_ub_kjmol_err = mbar_data[:,9] * kelvin_to_kjmol
mbar_unb_kjmol = mbar_data[:,10] * kelvin_to_kjmol
mbar_unb_kjmol_err = mbar_data[:,11] * kelvin_to_kjmol

mbar_u_res = ( mbar_u_kjmol - mbar_ub_kjmol - mbar_unb_kjmol ) / mbar_Nmolec / R_const / mbar_temp_k * 1e3
mbar_u_res_err = numpy.sqrt( mbar_u_kjmol_err**2 + mbar_ub_kjmol_err**2 + mbar_unb_kjmol_err**2) / mbar_Nmolec / R_const / mbar_temp_k * 1e3
mbar_z = mbar_p_mpa * MW / ( mbar_rho_gcc  * R_const * mbar_temp_k )
mbar_z_err = mbar_p_mpa_err * MW / ( mbar_rho_gcc  * R_const * mbar_temp_k )
mbar_zminus1overRho = ( mbar_z - 1 ) / mbar_rho_gcc
mbar_zminus1overRho_err = mbar_z_err / mbar_rho_gcc

if isDSIM:
    dsim_data = numpy.loadtxt(dsim_data_file, skiprows=1)
    dsim_temp_k = dsim_data[:,0]
    dsim_rho_gcc = dsim_data[:,1]
    dsim_z = dsim_data[:,2]
    dsim_u_res = dsim_data[:,3]
    dsim_z_std = dsim_data[:,4]
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
plt.scatter(mbar_rho_gcc, mbar_zminus1overRho, marker="o", s=70, facecolors='none', edgecolors='r', label='MBAR')
plt.errorbar(mbar_rho_gcc, mbar_zminus1overRho, yerr=mbar_zminus1overRho_err, color='r', capsize=5, marker=None, linewidth=0, elinewidth=1, ms=0)

if isDSIM:
    plt.scatter(dsim_rho_gcc, dsim_zminus1overRho, marker="^", s=70, facecolors='none', edgecolors='g', label='Direct simulation')
    plt.errorbar(dsim_rho_gcc, dsim_zminus1overRho, yerr=dsim_zminus1overRho_err, color='g', capsize=5, marker=None, linewidth=0, elinewidth=1, ms=0)

# Add labels to the plot to show Neff    
for i in range(0,len(mbar_rho_gcc)):
    plt.text(mbar_rho_gcc[i]+0.01, mbar_zminus1overRho[i], str(round(Neff[i],1)), color='red', fontsize=9, alpha=0.9, bbox=dict(color='red', alpha=0.01))


plt.legend()

############### Z vs. 1000/T plot #############################################
plt.subplot(1, 3, 2 )
plt.xlabel("$1000/T$ [K$^{-1}$]")
plt.ylabel("$Z$")
plt.scatter(1000.0 / true_temp_k, true_z, marker="s", s=70, facecolors='none', edgecolors='k')
plt.scatter(1000.0 / mbar_temp_k, mbar_z, marker="o", s=70, facecolors='none', edgecolors='r')
plt.errorbar(1000.0 / mbar_temp_k, mbar_z, yerr=mbar_z_err, color='r', capsize=5, marker=None, linewidth=0, elinewidth=1, ms=0)

if isDSIM:
    plt.scatter(1000.0 / dsim_temp_k, dsim_z, marker="^", s=70, facecolors='none', edgecolors='g')
    plt.errorbar(1000.0 / dsim_temp_k, dsim_z, yerr=dsim_z_std, color='g', capsize=5, marker=None, linewidth=0, elinewidth=1, ms=0)

############### TU^ vs 1000/T plot #############################################
plt.subplot(1, 3, 3 )
plt.xlabel("$1000/T$ [K$^{-1}$]")
plt.ylabel("$T\hat{U}^\mathrm{res}$ [K]")
plt.scatter(1000.0 / true_temp_k, true_u_res * true_temp_k, marker="s", s=70, facecolors='none', edgecolors='k')
plt.scatter(1000.0 / mbar_temp_k, mbar_u_res * mbar_temp_k, marker="o", s=70, facecolors='none', edgecolors='r')
plt.errorbar(1000.0 / mbar_temp_k, mbar_u_res * mbar_temp_k, yerr=mbar_u_res_err*mbar_temp_k, color='r', capsize=5, marker=None, linewidth=0, elinewidth=1, ms=0)

if isDSIM:
    plt.scatter(1000.0 / dsim_temp_k, dsim_u_res * dsim_temp_k, marker="^", s=70, facecolors='none', edgecolors='g')
    plt.errorbar(1000.0 / dsim_temp_k, dsim_u_res * dsim_temp_k, yerr=dsim_u_res_std * dsim_temp_k, color='g', capsize=5, marker=None, linewidth=0, elinewidth=1, ms=0)

plt.savefig(output_figure_filename)
plt.close()