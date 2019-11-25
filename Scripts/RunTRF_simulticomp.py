
import numpy
from scipy.optimize import least_squares
import os
import scipy
from numpy import inf

run_name = "Simultaneous_TRF_IC4-NP"
site_names_array = ["CH3b", "CH1", "CT"]
molecules = "IC4 NP"

#========== bounds and initial guess =============
lb = [3.78, 116.0, 4.4, 5.00, 6.0, 0.00]
ub = [3.82, 126.0, 5.0, 20.0, 6.6, 20.0]
xy_initial_guess = [3.8, 120, 4.7, 14, 6.3, 2] 
DIFF_STEP = [1e-2, 1e-1, 1e-2, 1e-1, 1e-2, 1e-1]
TOL = 1e-04
nnbp = 2















#===================================================
molecules =  "\"" + molecules + "\""

OutFile=open("iterations.log", "w")
iter = 0

def objective_function(x):
    global iter

    iter = iter + 1

    for isite in range(0, len(site_names_array)):
        for inbp in range(0, nnbp):
            if inbp/nnbp == 0:
                vars()['sig' + str(isite)] = x[isite * nnbp + inbp]
            else:
                vars()['eps' + str(isite)] = x[isite * nnbp + inbp]      

    iteration_name = ""
    for isite in range(0, len(site_names_array)):
        iteration_name = iteration_name + site_names_array[isite] + "-" +  str(vars()['sig' + str(isite)]) + "-" + str(vars()['eps' + str(isite)]) + "-12" + "_"
    iteration_name = iteration_name[:-1]
    
    command = "bash simulticomp.sh " + iteration_name + " I" + str(iter)
    os.system(command)

    score_file_address = iteration_name + ".score"
    scores_data = numpy.loadtxt(score_file_address, skiprows=1, usecols=[1,2,3])

    sum_z_scores = numpy.sum(scores_data[:,1])  # if only one molecule is being optimized => sum_z_scores = numpy.sum(scores_data[1])
    sum_u_scores = numpy.sum(scores_data[:,2])  # if only one molecule is being optimized => #sum_u_scores = numpy.sum(scores_data[2])
    
    score = sum_z_scores + sum_u_scores

    print(x, score, file = OutFile)

    return score


result = least_squares(objective_function, xy_initial_guess, jac='2-point', bounds=(lb, ub), method='trf', ftol=TOL, xtol=TOL, gtol=TOL, x_scale='jac', loss='linear', diff_step=DIFF_STEP, tr_solver=None, tr_options={}, jac_sparsity=None, max_nfev=None, verbose=2, args=(), kwargs={})

print(result)

os.system("bash $HOME/Git/TranSFF/Scripts/simulticomp_organize.sh " + run_name + " " + molecules)