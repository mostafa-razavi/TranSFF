# This script computes the deviation between MBAR and true data. The data in true_data_file and mbar_data_file should be consistent in terms of order of lines. 

import numpy
import sys


MW = float(sys.argv[1])
true_data_file = sys.argv[2]               # The file that is used to minimize the deviations against
mbar_data_file = sys.argv[3]               # The file that contains MBAR results at ITIC state points
weights_file = sys.argv[4]

R_const = 8.31446261815324  

# Conversion factors
atm_to_mpa = 0.101325
kcalmol_to_kjmol = 4.184

bar_to_mpa = 0.1
kelvin_to_kjmol = 0.0083

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
mbar_z = mbar_p_mpa * MW / ( mbar_rho_gcc  * R_const * mbar_temp_k )
mbar_z_err = mbar_p_mpa_err * MW / ( mbar_rho_gcc  * R_const * mbar_temp_k )
mbar_zminus1overRho = ( mbar_z - 1 ) / mbar_rho_gcc
mbar_zminus1overRho_err = mbar_z_err / mbar_rho_gcc

# Obtain weights
z_wt = numpy.loadtxt(weights_file, skiprows=1, usecols=[0])
u_wt = numpy.loadtxt(weights_file, skiprows=1, usecols=[1])
sum_z_wt = numpy.sum(z_wt)
sum_u_wt = numpy.sum(u_wt)
sum_wt = sum_z_wt + sum_u_wt

# Calculate RMSE
z_sse = numpy.sum( (mbar_zminus1overRho - true_zminus1overRho)**2 * z_wt  )   
u_sse = numpy.sum( (mbar_u_res - true_u_res)**2 * u_wt  )   

# Calculate score
total_rmse = numpy.sqrt( (z_sse + u_sse) / sum_wt)
z_rmse = numpy.sqrt(z_sse / sum_z_wt)
u_rmse = numpy.sqrt(u_sse / sum_u_wt)
print(total_rmse, z_rmse, u_rmse)