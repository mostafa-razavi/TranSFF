import os, sys
import numpy
from scipy.optimize import least_squares
import scipy


# Input parameters ##################
run_name = "SimultaneousTRF_C2_N500_select9"
molecules_array = [ "C2", "C12" ]
site_names_array = ["CH3", "CH2"]

ref_array1="3.81-127 3.79-134 3.78-131 3.77-133 3.75-129" #C2 
ref_array2="3.81-127_3.95-74 3.79-134_3.97-67 3.78-131_3.99-70 3.77-133_4.01-68 3.75-129_4.03-72" #C12

raw_par_path="$HOME/Git/TranSFF/Forcefields/MiPPE-GEN_Alkanes_SOME.par"
datafile_keyword="MiPPE"
GOMC_exe="$HOME/Git/GOMC/GOMC-FSHIFT2-SWF-HighPrecisionPDB-StartFrame/bin/GOMC_CPU_NVT"
z_wt="0.80"
u_wt="0.20"
n_wt="0.0001"
Nsnapshots="500"
rerun_inp="none"
number_of_lowest_Neff="1"
target_Neff="25"
Nproc_per_particle="6"
ITIC_subset_name="select9"
n_exp = 16


# Set TRF parameters ################
DIFF_STEP = [1e-2, 1e-1]
TOL = 1e-06

# Set TRF bounds and initial guesses ################
lb = [3.70, 127.0, 3.95, 67.0]
ub = [3.81, 134.0, 4.03, 74.0]
initial_guess = [3.78, 130, 4.00, 70.0]
nnbp = 2








#===================================================
molecules = ""
all_molecules_ref_string = ""
for imolec in range(0, len(molecules_array)):
    molecules = molecules + molecules_array[imolec] + " "
    vars()['ref_array' + str(imolec+1)] = "\"" + vars()['ref_array' + str(imolec+1)] + "\""
    all_molecules_ref_string = all_molecules_ref_string + vars()['ref_array' + str(imolec+1)] + " "
all_molecules_ref_string = all_molecules_ref_string[:-1]
molecules = molecules[:-1]
molecules =  "\"" + molecules + "\""


log = open("trf.log", "w")
iter = 0
def objective_function(x):
    global iter

    iter = iter + 1

    for isite in range(0, len(site_names_array)):
        for inbp in range(0, nnbp):
            if inbp/nnbp == 0:
                vars()['sig' + str(isite)] = round( x[isite * nnbp + inbp], 5)
            else:
                vars()['eps' + str(isite)] = round( x[isite * nnbp + inbp], 5)

    site_sig_eps_nnn = ""
    for isite in range(0, len(site_names_array)):
        site_sig_eps_nnn = site_sig_eps_nnn + site_names_array[isite] + "-" +  str(vars()['sig' + str(isite)]) + "-" + str(vars()['eps' + str(isite)]) + "-16" + "_"
    site_sig_eps_nnn = site_sig_eps_nnn[:-1]
    
    prefix = "i-" + str(iter)

    arg1 = site_sig_eps_nnn
    arg2 = prefix
    arg3 = molecules
    arg4 = raw_par_path
    arg5 = datafile_keyword
    arg6 = GOMC_exe
    arg7 = z_wt
    arg8 = u_wt
    arg9 = n_wt
    arg10 = Nsnapshots
    arg11 = rerun_inp                                                                             
    arg12 = number_of_lowest_Neff
    arg13 = target_Neff
    arg14 = Nproc_per_particle
    arg15 = ITIC_subset_name
    arg16 = all_molecules_ref_string

    command = "bash $HOME/Git/TranSFF/Scripts/simulticomp.sh" + " " + arg1 + " " + arg2+  " " + arg3 + " " + arg4 + " " + arg5 + " " + arg6 + " " + arg7 + " " + arg8 + " " + arg9 + " " + arg10 + " " + arg11 + " " + arg12 + " " + arg13 + " " + arg14 + " " + arg15 + " " + arg16
    print(command)

    os.system(command)


    score_file_address = prefix + ".score"
    scores_data = numpy.loadtxt(score_file_address, skiprows=1, usecols=[1,2,3])

    if len(molecules_array) == 1:
        sum_z_scores = numpy.sum(scores_data[1])  # if only one molecule is being optimized => sum_z_scores = numpy.sum(scores_data[1])
        sum_u_scores = numpy.sum(scores_data[2])  # if only one molecule is being optimized => sum_u_scores = numpy.sum(scores_data[2])
    else:
        sum_z_scores = numpy.sum(scores_data[:,1])  # if more than one molecule is being optimized => sum_z_scores = numpy.sum(scores_data[:,1])
        sum_u_scores = numpy.sum(scores_data[:,2])  # if more than one molecule is being optimized => sum_u_scores = numpy.sum(scores_data[:,2])

    score = sum_z_scores + sum_u_scores

    print(x, score, file = log)

    return score


result = least_squares(objective_function, initial_guess, jac='2-point', bounds=(lb, ub), method='trf', ftol=TOL, xtol=TOL, gtol=TOL, x_scale='jac', loss='linear', diff_step=DIFF_STEP, tr_solver=None, tr_options={}, jac_sparsity=None, max_nfev=None, verbose=2, args=(), kwargs={})


print(result)

os.system("bash $HOME/Git/TranSFF/Scripts/simulticomp_organize.sh " + run_name + " " + molecules)