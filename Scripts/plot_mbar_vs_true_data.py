# This script computes the deviation between MBAR and true data. The data in true_data_file and mbar_data_file should be consistent in terms of order of lines. 

import matplotlib
import numpy
import sys
import os
if os.environ.get('DISPLAY','') == '': # then no display found. Use non-interactive Agg backend'
    matplotlib.use('Agg')
import matplotlib.pyplot as plt

MW = float(sys.argv[1])
true_data_file = sys.argv[2]               # The file that is used to minimize the deviations against
mbar_data_file = sys.argv[3]               # The file that contains MBAR results at ITIC state points
true_data_label = sys.argv[4]               # Label for true data
output_figure_filename = sys.argv[5]

R_const = 8.31446261815324

# Conversion factors
atm_to_mpa = 0.101325
kcalmol_to_kjmol = 4.184

bar_to_mpa = 0.1
kelvin_to_kjmol = 0.0083

# Import data
true_data = numpy.loadtxt(true_data_file, skiprows=1, usecols=(0,1,2,5,11))
true_temp_k = true_data[:,0]
true_rho_gcc = true_data[:,1]
true_p_mpa = true_data[:,2] * atm_to_mpa
true_u_kjmol = true_data[:,3] * kcalmol_to_kjmol
Nmolec = true_data[:,4]

mbar_data = numpy.loadtxt(mbar_data_file, skiprows=1, usecols=(0,1,3,5))
mbar_temp_k = mbar_data[:,0]
mbar_rho_gcc = mbar_data[:,1]
mbar_u_kjmol = mbar_data[:,2] * kelvin_to_kjmol
mbar_p_mpa = mbar_data[:,3] * bar_to_mpa


# Calcualte properties
true_u_res = true_data[:,3] * kcalmol_to_kjmol / Nmolec / R_const / true_temp_k * 1e3
true_z = true_p_mpa * MW / ( true_rho_gcc  * R_const * true_temp_k )
true_zminus1overRho = ( true_z - 1 ) / true_rho_gcc

mbar_u_res = mbar_data[:,2] * kelvin_to_kjmol / Nmolec / R_const / mbar_temp_k * 1e3
mbar_z = mbar_p_mpa * MW / ( mbar_rho_gcc  * R_const * mbar_temp_k )
mbar_zminus1overRho = ( mbar_z - 1 ) / mbar_rho_gcc

# Initiate plot
plt.figure(num=None, figsize=(15, 15), dpi=100, facecolor='w', edgecolor='w')
plt.subplots_adjust(left=None, bottom=None, right=None, top=None, wspace=0.3, hspace=None)
font = {'weight' : 'normal', 'size' : 14}
matplotlib.rc('font', **font)    

# (Z-1)/rho vs. rho plot
plt.subplot(2, 2, 1 )
plt.xlabel("$\\rho$ [g/ml]")
plt.ylabel("$\\frac{Z-1}{\\rho}$")
#plt.xlim([0,0.65])
#plt.ylim([-5.0,8.0])
plt.scatter(true_rho_gcc, true_zminus1overRho, marker="o", facecolors='none', edgecolors='k', label=true_data_label)
plt.scatter(mbar_rho_gcc, mbar_zminus1overRho, marker="o", facecolors='none', edgecolors='r', label='MBAR')

# TU^res vs 1000/T plot
plt.subplot(2, 2, 2 )
plt.ticklabel_format(style='sci', axis='y', scilimits=(0,0))
plt.xlabel("$1000/T$ [K$^{-1}$]")
plt.ylabel("$TU^\mathrm{res}$")
#plt.xlim([2.0,7.5])
#plt.ylim([-2.0e3,-0.2e3])
plt.scatter(1000.0 / true_temp_k[:10], true_u_res[:10] * true_temp_k[:10], marker="o", facecolors='none', edgecolors='k')
plt.scatter(1000.0 / mbar_temp_k[:10], mbar_u_res[:10] * mbar_temp_k[:10], marker="o", facecolors='none', edgecolors='r')
plt.scatter(1000.0 / true_temp_k[21:], true_u_res[21:] * true_temp_k[21:], marker="o", facecolors='none', edgecolors='k', label=true_data_label)
plt.scatter(1000.0 / mbar_temp_k[21:], mbar_u_res[21:] * mbar_temp_k[21:], marker="o", facecolors='none', edgecolors='r', label='MBAR')

# Z vs. 1000/T plot
plt.subplot(2, 2, 3 )
plt.xlabel("$1000/T$ [K$^{-1}$]")
plt.ylabel("$Z$")
#plt.xlim([0,0.65])
#plt.ylim([-5.0,8.0])
plt.scatter(1000.0 / true_temp_k[:10], true_z[:10], marker="o", facecolors='none', edgecolors='k')
plt.scatter(1000.0 / mbar_temp_k[:10], mbar_z[:10], marker="o", facecolors='none', edgecolors='r')
plt.scatter(1000.0 / true_temp_k[21:], true_z[21:], marker="o", facecolors='none', edgecolors='k', label=true_data_label)
plt.scatter(1000.0 / mbar_temp_k[21:], mbar_z[21:], marker="o", facecolors='none', edgecolors='r', label='MBAR')    

plt.legend()
plt.savefig(output_figure_filename)
plt.close()
#plt.show()