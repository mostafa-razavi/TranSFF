# This script takes block average results from GONVT_BlockAvg.sh (bulk simulation) and outputs a file containing T, rho, Z, Z_std, Ures, Ures_std, and N. If the 3rd argument is intra bulk simulation results
# suffices, because Ures is calculated using EN_INTRA_B and EN_INTRA_NB. However, if the 3rd arguments is "single", two extra files are needed, i.e. single moleculae simulation results.
#
# Example:
# python3.6 GONVT_blocks_to_trhozures.py 58.1222 intra Blocks.avg Blocks.std
# python3.6 GONVT_blocks_to_trhozures.py 58.1222 single Blocks.avg Blocks.std single.avg single.std

import numpy
import sys

MW = float(sys.argv[1])
single_or_intra = sys.argv[2]
blocks_avg_filename = sys.argv[3]
blocks_std_filename = sys.argv[4]
if single_or_intra == "single":
	single_avg_filename = sys.argv[5]
	single_std_filename = sys.argv[6]


# Conversion factors and constants
atm_to_mpa = 0.101325
kcalmol_to_kjmol = 4.184
bar_to_mpa = 0.1
kelvin_to_kjmol = 0.0083
R_const = 8.31446261815324

blocks_avg = numpy.loadtxt(blocks_avg_filename, skiprows=1)
blocks_std = numpy.loadtxt(blocks_std_filename, skiprows=1)

if single_or_intra == "single":
	single_avg = numpy.loadtxt(single_avg_filename, skiprows=1)
	single_std = numpy.loadtxt(single_std_filename, skiprows=1)

T_K = blocks_avg[:,0]	# K
RHO_GCC = blocks_avg[:,1]	# g/ml
TOT_EN = blocks_avg[:,2]	# K
PRESSURE = blocks_avg[:,11]	# bar
TOT_EN_std = blocks_std[:,2]
PRESSURE_std = blocks_std[:,11] 
TOT_MOL = blocks_avg[:,12]

Z = PRESSURE * bar_to_mpa * MW / ( RHO_GCC  * R_const * T_K )
Z_std = PRESSURE_std * bar_to_mpa * MW / ( RHO_GCC  * R_const * T_K )

if single_or_intra == "single":
	T_K_single = single_avg[:,0]
	TOT_EN_single = single_avg[:,2]

	Uig = []
	for Temp in T_K:
		index = numpy.where(T_K_single == Temp)[0][0]
		Uig.append(TOT_EN_single[index])
		
	Ures = ( TOT_EN - Uig * TOT_MOL )* kelvin_to_kjmol * 1e3 / TOT_MOL / R_const / T_K 
	Ures_std = ( TOT_EN_std ) * kelvin_to_kjmol * 1e3 / TOT_MOL / R_const / T_K 

elif single_or_intra == "intra":
	EN_INTRA_B = blocks_avg[:,5] 
	EN_INTRA_NB = blocks_avg[:,6]
	EN_INTRA_B_std = blocks_std[:,5] 
	EN_INTRA_NB_std = blocks_std[:,6]

	Ures = ( TOT_EN - EN_INTRA_B - EN_INTRA_NB ) * kelvin_to_kjmol * 1e3 / TOT_MOL / R_const / T_K 
	Ures_std = ( TOT_EN_std ) * kelvin_to_kjmol * 1e3 / TOT_MOL / R_const / T_K

print('T_K RHO_GCC Z Z_std Ures Ures_std N')
for i in range(0, len(T_K)):
	print(T_K[i], RHO_GCC[i], Z[i], Ures[i], Z_std[i], Ures_std[i], TOT_MOL[i])
