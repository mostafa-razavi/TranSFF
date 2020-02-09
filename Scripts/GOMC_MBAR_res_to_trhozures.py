# This script converts the GOMC MBAR results to a trhozures file
# Example:
# python3.6 $HOME/Git/TranSFF/Scripts/GOMC_MBAR_res_to_trhozures.py 170 N1000_MBAR_s3.850e127-s3.920e60.target.res trhozures.res
    
import matplotlib
import numpy
import sys
import os
if os.environ.get('DISPLAY','') == '': # then no display found. Use non-interactive Agg backend'
    matplotlib.use('Agg')
import matplotlib.pyplot as plt

MW = float(sys.argv[1])
mbar_data_file = sys.argv[2]               # The file that contains MBAR results at ITIC state points
output_figure_filename = sys.argv[3]        # Output file name

OutFile=open(output_figure_filename, "w")

# Conversion factors and constants
atm_to_mpa = 0.101325
kcalmol_to_kjmol = 4.184
bar_to_mpa = 0.1
kelvin_to_kjmol = 0.0083
R_const = 8.31446261815324

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

print('T_K RHO_GCC Z Z_std Ures Ures_std N', file = OutFile)
for i in range(0, len(mbar_temp_k)):
	print(mbar_temp_k[i], mbar_rho_gcc[i], mbar_z[i], mbar_u_res[i], mbar_z_err[i], mbar_u_res_err[i], mbar_Nmolec[i], Neff[i], file = OutFile)

OutFile.close()