# This script computes the deviation between MBAR and true data. The data in true_data_file and mbar_data_file should be consistent in terms of order of lines. 

import numpy
import sys
import matplotlib
import matplotlib.pyplot as plt


MW = float(sys.argv[1])
true_data_file = sys.argv[2]               # The file that is used to minimize the deviations against
mbar_data_file = sys.argv[3]               # The file that contains MBAR results at ITIC state points
z_wt = float(sys.argv[4])                  # The weight of Z in score
u_wt = float(sys.argv[5])                  # The weight of U in score
n_wt = float(sys.argv[6])                  # The weight of Neff criteria in score
if n_wt != 0.0:
    number_of_lowest_Neff = int(sys.argv[7])
    target_Neff = int(sys.argv[8])

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

# Calculate deviations
z_dev = ( mbar_zminus1overRho - true_zminus1overRho ) / true_zminus1overRho * 100.0
u_dev = ( mbar_u_res - true_u_res ) / true_u_res * 100.0

z_aad = numpy.mean(numpy.abs(z_dev))
u_aad = numpy.mean(numpy.abs(u_dev))

# Find number_of_lowest_Neff ITIC points with lowest Neff values, put them in an array, and calculate n_score
n_score = 0.0
if n_wt != 0.0:
    def neff_criteria_function(target_Neff, neff):
        neff_minus_one = (target_Neff - 1)/abs( (target_Neff - 1) - (target_Neff) )
        neff_plus_one = (target_Neff + 1)/abs( (target_Neff + 1) - (target_Neff) ) 
        max_dev = 2 * neff_plus_one - neff_minus_one 

        if neff < 1:
            return 100
            
        if abs( target_Neff - neff) >= 1:
            dev_percent = 100.0 - (neff)/abs( (neff) - (target_Neff) ) / max_dev * 100.0
        else:
            dev_percent = 0.0
        return dev_percent  

    lowest_m_Neff_index = Neff.argsort()[:number_of_lowest_Neff]
    lowest_m_Neff_dev = []
    for i in range(0, len(lowest_m_Neff_index)):
        #lowest_m_Neff.append()
        lowest_m_Neff_dev.append( neff_criteria_function(target_Neff, Neff[lowest_m_Neff_index[i]]) )
    lowest_m_Neff_dev = numpy.asarray(lowest_m_Neff_dev)
    n_dev = numpy.mean(lowest_m_Neff_dev)
    n_score = n_wt * n_dev

# Calculate score

z_score = z_wt * z_aad 
u_score = u_wt * u_aad

score = z_score + u_score + n_score
print(score, z_score, u_score, n_score)
