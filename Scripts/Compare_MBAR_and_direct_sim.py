# This script plots the MBAR and direct simulation results or computes the deviation score between them


import matplotlib
import numpy
import sys
import os
if os.environ.get('DISPLAY','') == '':
    print('no display found. Using non-interactive Agg backend')
    matplotlib.use('Agg')
import matplotlib.pyplot as plt

plot_or_deviation = sys.argv[1]            # if "plot" then Z and U plots are generated else if "deviatin" one single score value is printed
true_data_file = sys.argv[2]               # The file that is used to minimize the deviation against
mbar_data_file = sys.argv[3]               # The MBAR file that contains MBAR results at ITIC state points
output_figure_filename = sys.argv[4]
MW = float(sys.argv[5])
if plot_or_deviation == "deviation":
    z_wt = float(sys.argv[6])
    u_wt = float(sys.argv[7])

R_const = 8.31446261815324

true_data = numpy.loadtxt(true_data_file, skiprows=1, usecols=(0,1,2,5,11))
mbar_data = numpy.loadtxt(mbar_data_file, skiprows=1, usecols=(1,3))

temp_k = true_data[:,0]
rho_gcc = true_data[:,1]
Nmolec = true_data[:,4]

# Convert energy to kJ/mol and pressure to Mpa

atm_to_mpa = 0.101325
kcalmol_to_kjmol = 4.184

bar_to_mpa = 0.1
kelvin_to_kjmol = 0.0083

true_p_mpa = true_data[:,2] * atm_to_mpa
true_u_kjmol = true_data[:,3] * kcalmol_to_kjmol
true_u_res = true_data[:,3] * kcalmol_to_kjmol / Nmolec / R_const / temp_k * 1e3
true_z = true_p_mpa * MW / ( rho_gcc  * R_const * temp_k )
true_zminus1overRho = ( true_z - 1 ) / rho_gcc

mbar_p_mpa = mbar_data[:,1] * bar_to_mpa
mbar_u_kjmol = mbar_data[:,0] * kelvin_to_kjmol
mbar_u_res = mbar_data[:,0] * kelvin_to_kjmol / Nmolec / R_const / temp_k * 1e3
mbar_z = mbar_p_mpa * MW / ( rho_gcc  * R_const * temp_k )
mbar_zminus1overRho = ( mbar_z - 1 ) / rho_gcc

def plot_zrho_urest():
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
    plt.scatter(rho_gcc, true_zminus1overRho, marker="o", facecolors='none', edgecolors='k', label='TraPPE-UA')
    plt.scatter(rho_gcc, mbar_zminus1overRho, marker="o", facecolors='none', edgecolors='r', label='MBAR')

    # TU^res vs 1000/T plot
    plt.subplot(2, 2, 2 )
    plt.ticklabel_format(style='sci', axis='y', scilimits=(0,0))
    plt.xlabel("$1000/T$ [K$^{-1}$]")
    plt.ylabel("$TU^\mathrm{res}$")
    #plt.xlim([2.0,7.5])
    #plt.ylim([-2.0e3,-0.2e3])
    plt.scatter(1000.0 / temp_k[:10], true_u_res[:10] * temp_k[:10], marker="o", facecolors='none', edgecolors='k')
    plt.scatter(1000.0 / temp_k[:10], mbar_u_res[:10] * temp_k[:10], marker="o", facecolors='none', edgecolors='r')
    plt.scatter(1000.0 / temp_k[21:], true_u_res[21:] * temp_k[21:], marker="o", facecolors='none', edgecolors='k', label='TraPPE-UA')
    plt.scatter(1000.0 / temp_k[21:], mbar_u_res[21:] * temp_k[21:], marker="o", facecolors='none', edgecolors='r', label='MBAR')

    # Z vs. 1000/T plot
    plt.subplot(2, 2, 3 )
    plt.xlabel("$1000/T$ [K$^{-1}$]")
    plt.ylabel("$Z$")
    #plt.xlim([0,0.65])
    #plt.ylim([-5.0,8.0])
    plt.scatter(1000.0 / temp_k[:10], true_z[:10], marker="o", facecolors='none', edgecolors='k')
    plt.scatter(1000.0 / temp_k[:10], mbar_z[:10], marker="o", facecolors='none', edgecolors='r')
    plt.scatter(1000.0 / temp_k[21:], true_z[21:], marker="o", facecolors='none', edgecolors='k', label='TraPPE-UA')
    plt.scatter(1000.0 / temp_k[21:], mbar_z[21:], marker="o", facecolors='none', edgecolors='r', label='MBAR')    

    plt.legend()
    plt.savefig(output_figure_filename)
    plt.close()
    #plt.show()

if plot_or_deviation == "plot":
    plot_zrho_urest()
elif plot_or_deviation == "deviation":
    z_dev = ( mbar_zminus1overRho - true_zminus1overRho ) / true_zminus1overRho * 100.0
    u_dev = ( mbar_u_res - true_u_res ) / true_u_res * 100.0

    z_aad = numpy.mean(numpy.abs(z_dev))
    u_aad = numpy.mean(numpy.abs(u_dev))

    z_wt = 1.0
    u_wt = 0.0
    score = z_wt * z_aad + u_wt * u_aad
    print(score)
