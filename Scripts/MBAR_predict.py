'''
This script takes reference simulation data and outputs the MBAR predictions for desired properties.
'''

from pymbar import MBAR
import numpy as np
import sys
from scipy import stats
import sys

Temp = float(sys.argv[1])               # Temperature
rho = float(sys.argv[2])                # Density
Nmolec = float(sys.argv[3])
Ns = int(sys.argv[4])                   # Number of snapshots saved during reference simulation
ref_sim_fol_string = sys.argv[5]    	# Space delimited string containing the absolute path to simulation folders of reference simulations, eg. ".../IT/360.0/0.6000 ..."
ref_ff_string = sys.argv[6]             # Space delimited string containing the names of all reference simulations, eg. "s3.78e115 s3.88e115"
target_ff_name = sys.argv[7]            # The name of target force field
which_cols_string = sys.argv[8]         # Space delimited string containing the column indexes (starting from 0) of the desired properties. First element should be the column index of U
Nrows_to_skip = int(sys.argv[9])        # Number of data file lines that need to be skipped, eg. 3 for Cassandra
energy_unit = sys.argv[10]               # "kj/mol" or "kcal/mol", or "K"

ref_sim_fol_array = ref_sim_fol_string.split()
ref_ff_array = ref_ff_string.split()
all_ff_array = ref_ff_array.copy()
all_ff_array.append(target_ff_name)

which_cols_array = which_cols_string.split()

Nref = len(ref_ff_array)    # Number of reference force fields
Nff = Nref + 1              # Number of all force fields involved
u_array = np.zeros([Nff, Nref*Ns])
property_array = np.zeros([Nff, Nref*Ns])

for iF in range(0, Nff):
    for iX in range(0, Nref):
        u_array[iF, (iX)*Ns:(iX+1)*Ns] = np.array([np.loadtxt(ref_sim_fol_array[iX] + ref_ff_array[iX] + ".ref_" +  all_ff_array[iF] + ".rer", skiprows=Nrows_to_skip)[:,int(which_cols_array[0])]])

if energy_unit == "kj/mol":
    R_g = 8.3144598e-3        
elif energy_unit == "kcal/mol" :
    R_g = 1.9872036e-3
elif energy_unit == "K" :
    R_g = 1.00   
else:
    raise ValueError('energy_unit cannot be ' + energy_unit)

u_RT = u_array / ( R_g * Temp )

N_k = np.zeros([Nff])
for i in range(0, Nref):
    N_k[i] = Ns
N_k[Nref] = 0

mbar = MBAR(u_RT, N_k)
Neff = mbar.computeEffectiveSampleNumber()[Nff-1]

print(Temp, rho, Nmolec, Neff, end = ' ')
for iCol in range(0, len(which_cols_array)):
    for iF in range(0, Nff):
        for iX in range(0, Nref):
            property_array[iF, (iX)*Ns:(iX+1)*Ns] = np.array([np.loadtxt(ref_sim_fol_array[iX] + ref_ff_array[iX] + ".ref_" +  all_ff_array[iF] + ".rer", skiprows=Nrows_to_skip)[:, int(which_cols_array[iCol])]])
    (property, property_error) = mbar.computeExpectations(property_array[Nff-1,:],output='averages') 
    print(property[Nff-1], property_error[Nff-1], end = ' ')
print()
