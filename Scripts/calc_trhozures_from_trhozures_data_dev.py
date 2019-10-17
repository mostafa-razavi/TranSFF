# This script computes the deviation between two tzrhoures dat files.
# Example:
# python3.6 ~/Git/TranSFF/Scripts/calc_trhozures_from_trhozures_data_dev.py 170 dsim.trhozures.res N1000_MBAR_s3.850e127-s4.000e56.trhozures.res 0.5 0.5
import numpy
import sys


MW = float(sys.argv[1])
true_data_file = sys.argv[2]               # The file that is used to minimize the deviations against
dsim_data_file = sys.argv[3]               # The file that contains sim results at ITIC state points
z_wt = float(sys.argv[4])                  # The weight of Z in score
u_wt = float(sys.argv[5])                  # The weight of U in score

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
true_u_res = true_data[:,4]
true_zminus1overRho = ( true_z - 1 ) / true_rho_gcc

dsim_data = numpy.loadtxt(dsim_data_file, skiprows=1)
dsim_temp_k = dsim_data[:,0]
dsim_rho_gcc = dsim_data[:,1]
dsim_z = dsim_data[:,2]
dsim_u_res = dsim_data[:,4]
dsim_zminus1overRho = ( dsim_z - 1 ) / dsim_rho_gcc

# Calculate deviations
z_dev = ( dsim_zminus1overRho - true_zminus1overRho ) / true_zminus1overRho * 100.0
u_dev = ( dsim_u_res - true_u_res ) / true_u_res * 100.0

z_aad = numpy.mean(numpy.abs(z_dev))
u_aad = numpy.mean(numpy.abs(u_dev))

# Calculate score

z_score = z_wt * z_aad 
u_score = u_wt * u_aad

score = z_score + u_score 
print(score, z_score, u_score)
