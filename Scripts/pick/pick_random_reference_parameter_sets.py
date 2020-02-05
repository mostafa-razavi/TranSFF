'''
This script generates random non-bonded parameter sets based on given ranges. The ranges_file should include n ranges and if they are is_n_needed == no-n, then the n values are not written.

Example:
            /usr/bin/python3 /home/mostafa/Git/TranSFF/Scripts/pick_random_reference_parameter_sets/pick_random_reference_parameter_sets.py ranges.txt no-names yes-n "CH3 CH2 CH1" 2
'''

from pymbar import MBAR
import numpy as np
import sys
from scipy import stats
import sys

ranges_file = sys.argv[1]         
is_include_site_names = sys.argv[2]             # no-names or yes-names
is_n_needed = sys.argv[3]                       # no-n or yes-n
molecule_types_list = sys.argv[4].split(" ")    # E.g.: "CH3 CH2 CH1"
how_man_refs = int(sys.argv[5]         )        # Number of parameter sets


if is_include_site_names == "yes-names":
    include_site_names = True
elif is_include_site_names == "no-names":
    include_site_names = False



ranges_array = np.loadtxt(ranges_file, skiprows=1, usecols=[1,2,3,4,5,6])
    
all_site_types_array = np.loadtxt(ranges_file, skiprows=1, usecols=[0], dtype=np.str)

list = []
for isite in range(len(all_site_types_array)):
    if all_site_types_array[isite] in molecule_types_list:
        sig_low = ranges_array[isite,0]
        sig_high = ranges_array[isite,1]

        eps_low = ranges_array[isite,2]
        eps_high = ranges_array[isite,3]

        n_low = ranges_array[isite,4]
        n_high = ranges_array[isite,5]    

        sig_array = np.linspace(sig_low, sig_high, num=how_man_refs, endpoint=True)
        eps_array = np.linspace(eps_low, eps_high, num=how_man_refs, endpoint=True)
        n_array = np.linspace(n_low, n_high, num=how_man_refs, endpoint=True)

        sig_array = np.around(sig_array, decimals=3)
        eps_array = np.around(eps_array, decimals=1)
        n_array = np.around(n_array, decimals=1)

        np.random.shuffle(sig_array)
        np.random.shuffle(eps_array)
        np.random.shuffle(n_array)

        temp_array = np.concatenate(([sig_array], [eps_array]), axis=0)
        if is_n_needed == "yes-n":
            temp_array = np.concatenate((temp_array, [n_array]), axis=0)
        list.append(temp_array)


for iref in range(len(list[0][0,:])):
    for isite in range(len(list)):
        if isite == 0:
            prefix1 = ""
        else:
            prefix1 = "_"
        print(prefix1, end = '')
        if include_site_names:
            print(molecule_types_list[isite] + "", end = '' )
        for ipar in range(len(list[0][:,0])):
            if ipar == 0 and include_site_names == False:
                prefix2 = ""
            else:
                prefix2 = "-"            
            print( prefix2 + str(list[isite][ipar,iref]) ,  end = '')
    print(" ", end = '')
print()
