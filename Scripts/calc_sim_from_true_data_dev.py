# This script computes the deviation between sim and true data. The data in true_data_file and sim_data_file should be consistent in terms of order of lines. 

import numpy
import sys
import matplotlib
import matplotlib.pyplot as plt


MW = float(sys.argv[1])
true_data_file = sys.argv[2]               # The file that is used to minimize the deviations against
sim_data_file = sys.argv[3]               # The file that contains sim results at ITIC state points
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
true_u_res = true_data[:,3]
true_zminus1overRho = ( true_z - 1 ) / true_rho_gcc

sim_data = numpy.loadtxt(sim_data_file, skiprows=1)
sim_temp_k = sim_data[:,0]
sim_rho_gcc = sim_data[:,1]
sim_z = sim_data[:,2]
sim_z_err = sim_data[:,3]
sim_u_res = sim_data[:,4]
sim_u_res_err = sim_data[:,5]
sim_Nmolec = sim_data[:,6]
sim_zminus1overRho = ( sim_z - 1 ) / sim_rho_gcc
#sim_zminus1overRho_err = sim_z_err / sim_rho_gcc

# Calculate deviations
z_dev = ( sim_zminus1overRho - true_zminus1overRho ) / true_zminus1overRho * 100.0
u_dev = ( sim_u_res - true_u_res ) / true_u_res * 100.0

z_aad = numpy.mean(numpy.abs(z_dev))
u_aad = numpy.mean(numpy.abs(u_dev))

# Calculate score

z_score = z_wt * z_aad 
u_score = u_wt * u_aad

score = z_score + u_score 
print(score, z_score, u_score)
