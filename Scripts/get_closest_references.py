import numpy
import sys
import os
import re
import math 

sig_eps_nnn = sys.argv[1]              
ref_array = sys.argv[2].split(" ")
coeff_array = sys.argv[3].split(" ")
n_closest = int(sys.argv[4])

coeff_array = numpy.array(coeff_array, dtype=float)
mbar_par_set = re.split('-|_',sig_eps_nnn)
mbar_par_set = numpy.array(mbar_par_set, dtype=float)


distance_array = numpy.zeros(shape=(0,0))
for i in ref_array:
    ref = re.split('-|_',i)
    ref = numpy.array(ref, dtype=float)
    for j in range(0, len(ref)):
        ref[j] = ref[j] * coeff_array[j]
    dist = math.sqrt(sum([(xi-yi)**2 for xi,yi in zip(mbar_par_set, ref)]))
    distance_array = numpy.append(distance_array, dist)

closest_index_array = numpy.argsort(distance_array)[0:n_closest]

for i in range(0,len(closest_index_array)):
    print(ref_array[closest_index_array[i]], " ", end = '')
print()
