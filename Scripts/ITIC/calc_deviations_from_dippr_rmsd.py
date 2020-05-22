# This script computes the rmsd of vle file from dippr data 

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
rhoL_sse = numpy.sum( (simu_rhoL - true_rhoL)**2  )   
psat_sse = numpy.sum( (simu_psat - true_psat)**2  )   
hvap_sse = numpy.sum( (simu_hvap - true_hvap)**2  )   

rhoL_rmse = numpy.sqrt(rhoL_sse / len(simu_rhoL))
psat_rmse = numpy.sqrt(psat_sse / len(simu_psat))
hvap_rmse = numpy.sqrt(hvap_sse / len(simu_hvap))


print(rhoL_rmse, psat_rmse, hvap_rmse)