# This script computes the APD of vle file from dippr data 

import numpy
import sys

simu_file = sys.argv[1]               
true_file = sys.argv[2]               

data = numpy.loadtxt(true_file, skiprows=1)
true_temp = data[:,0]
true_rhoL = data[:,1]
true_psat = data[:,2]
true_hvap = data[:,3]

data = numpy.loadtxt(simu_file, skiprows=1)
simu_temp = data[:,0]
simu_rhoL = data[:,1]
simu_psat = data[:,3]
simu_hvap = data[:,4]

# Calculate deviations
rhoL_apd = numpy.mean(numpy.abs(( simu_rhoL - true_rhoL ) / true_rhoL * 100.0))
psat_apd = numpy.mean(numpy.abs(( simu_psat - true_psat ) / true_psat * 100.0))
hvap_apd = numpy.mean(numpy.abs(( simu_hvap - true_hvap ) / true_hvap * 100.0))

print(rhoL_apd, psat_apd, hvap_apd)