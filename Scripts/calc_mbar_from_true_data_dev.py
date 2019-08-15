# This script computes the deviation between MBAR and true data. The data in true_data_file and mbar_data_file should be consistent in terms of order of lines. 

import numpy
import sys

MW = float(sys.argv[1])
true_data_file = sys.argv[2]               # The file that is used to minimize the deviations against
mbar_data_file = sys.argv[3]               # The file that contains MBAR results at ITIC state points
z_wt = float(sys.argv[4])                  # The weight of Z in score
u_wt = float(sys.argv[5])                  # The weight of U in score

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

# Calculate score
z_dev = ( mbar_zminus1overRho - true_zminus1overRho ) / true_zminus1overRho * 100.0
u_dev = ( mbar_u_res - true_u_res ) / true_u_res * 100.0

z_aad = numpy.mean(numpy.abs(z_dev))
u_aad = numpy.mean(numpy.abs(u_dev))

score = z_wt * z_aad + u_wt * u_aad
print(score)
