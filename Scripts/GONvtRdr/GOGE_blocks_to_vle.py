# This script takes block average results from GONVT_BlockAvg.sh (bulk simulation) and outputs a file containing T, rho, Z, Z_std, Ures, Ures_std, and N. If the 3rd argument is intra bulk simulation results
# suffices, because Ures is calculated using EN_INTRA_B and EN_INTRA_NB. However, if the 3rd arguments is "single", two extra files are needed, i.e. single moleculae simulation results.
#
# Example:
# python3.6 GONVT_blocks_to_trhozures.py 58.1222 intra Blocks.avg Blocks.std
# python3.6 GONVT_blocks_to_trhozures.py 58.1222 single Blocks.avg Blocks.std single.avg single.std

import numpy
import sys

MW = float(sys.argv[1])
blocks_avg_filename_L = sys.argv[2]
blocks_std_filename_L = sys.argv[3]
blocks_avg_filename_V = sys.argv[4]
blocks_std_filename_V = sys.argv[5]


# Conversion factors and constants
atm_to_mpa = 0.101325
kcalmol_to_kjmol = 4.184
bar_to_mpa = 0.1
kelvin_to_kjmol = 0.0083
R_const = 8.31446261815324

blocks_avg_L = numpy.loadtxt(blocks_avg_filename_L, skiprows=1)
blocks_std_L = numpy.loadtxt(blocks_std_filename_L, skiprows=1)
blocks_avg_V = numpy.loadtxt(blocks_avg_filename_V, skiprows=1)
blocks_std_V = numpy.loadtxt(blocks_std_filename_V, skiprows=1)

T_K = blocks_avg_L[:,0]	# K
PRESSURE_L = blocks_avg_L[:,10]/10.0	# MPa
RHO_GCC_L = blocks_avg_L[:,12]/1000.0	# g/ml
HEAT_VAP = blocks_avg_L[:,13]	# KJ/mol
PRESSURE_V = blocks_avg_V[:,10]/10.0	# MPa
RHO_GCC_V = blocks_avg_V[:,12]/1000.0	# g/ml

PRESSURE_L_std = blocks_std_L[:,10]/10.0	# MPa
RHO_GCC_L_std = blocks_std_L[:,12]/1000.0	# g/ml
HEAT_VAP_std = blocks_std_L[:,13]	# KJ/mol
PRESSURE_V_std = blocks_std_V[:,10]/10.0	# MPa
RHO_GCC_V_std = blocks_std_V[:,12]/1000.0	# g/ml

print('T[K]	ρL[gcc]	ρV[gcc]	P[Mpa]	   Hvap[KJ/mol]	ρL+/-	ρV+/-	P+/-	Hvap+/-')
for i in range(0, len(T_K)):
	print(T_K[i], RHO_GCC_L[i], RHO_GCC_V[i], PRESSURE_V[i], HEAT_VAP[i], RHO_GCC_L_std[i], RHO_GCC_V_std[i], PRESSURE_V_std[i], HEAT_VAP_std[i])
