import os, sys
import numpy
from scipy.optimize import least_squares
import scipy


# Input parameters ##################
run_name = "SimultaneousLM_C2E-C3E-1C4E-1C8E_N500_select9"
molecules_array = ["C2E", "C3E", "1C4E", "1C8E"]
datafile_keyword_array=["MiPPE", "MiPPE", "MiPPE", "MiPPE"]
site_names_array = ["CH2=", "CH1="]

ref_array1="3.73-115.0 3.7-100.0 3.67-111.2 3.76-103.8 3.64-107.5" #C2E
ref_array2="3.783-129.3_3.76-107.5_3.75-55.0 3.783-129.3_3.7-103.8_3.81-70.0 3.783-129.3_3.73-111.2_3.78-62.5 3.783-129.3_3.64-100.0_3.84-66.2 3.783-129.3_3.67-115.0_3.87-58.8" #C3E
ref_array3="3.783-129.3_4.012-66.2_3.76-107.5_3.78-62.5 3.783-129.3_4.012-66.2_3.7-111.2_3.87-66.2 3.783-129.3_4.012-66.2_3.67-115.0_3.84-70.0 3.783-129.3_4.012-66.2_3.73-103.8_3.75-58.8 3.783-129.3_4.012-66.2_3.64-100.0_3.81-55.0" #1C4E
ref_array4="3.783-129.3_4.012-66.2_3.76-103.8_3.87-55.0 3.783-129.3_4.012-66.2_3.64-111.2_3.84-66.2 3.783-129.3_4.012-66.2_3.7-115.0_3.78-70.0 3.783-129.3_4.012-66.2_3.67-107.5_3.81-58.8 3.783-129.3_4.012-66.2_3.73-100.0_3.75-62.5" #1C8E

raw_par_path="$HOME/myProjects/GOMC/MBAR/MiPPE-SWF_alkenes_references/MiPPE-SW2_alkanes-alkenes_SOME.par"
GOMC_exe="$HOME/Git/GOMC/GOMC-FSHIFT2-SWF-HighPrecisionPDB-StartFrame/bin/GOMC_CPU_NVT"
z_wt="0.80"
u_wt="0.20"
n_wt="0.0001"
Nsnapshots="500"
rerun_inp="none"
number_of_lowest_Neff="1"
target_Neff="25"
Nproc="8"
ITIC_subset_name="select9"
n_exp = 15


# Set LM parameters ################
TOL = 1e-06
initial_guess = [3.70, 110, 3.80, 65]
nnbp = 2
DIFF_STEP=1e-2







#===================================================
molecules = ""
datafile_keywords_string = ""
all_molecules_ref_string = ""
for imolec in range(0, len(molecules_array)):
    molecules = molecules + molecules_array[imolec] + " "
    datafile_keywords_string = datafile_keywords_string + datafile_keyword_array[imolec] + " "
    vars()['ref_array' + str(imolec+1)] = "\"" + vars()['ref_array' + str(imolec+1)] + "\""
    all_molecules_ref_string = all_molecules_ref_string + vars()['ref_array' + str(imolec+1)] + " "
all_molecules_ref_string = all_molecules_ref_string[:-1]
molecules = molecules[:-1]
molecules =  "\"" + molecules + "\""
datafile_keywords_string = datafile_keywords_string[:-1]
datafile_keywords_string =  "\"" + datafile_keywords_string + "\""


log = open("trf.log", "w")
iter = 0
def objective_function(x):
    global iter

    iter = iter + 1

    for isite in range(0, len(site_names_array)):
        for inbp in range(0, nnbp):
            print("variable:===============================", x)
            if inbp/nnbp == 0:
                vars()['sig' + str(isite)] = round( x[isite * nnbp + inbp], 4)
            else:
                vars()['eps' + str(isite)] = round( x[isite * nnbp + inbp], 2)

    site_sig_eps_nnn = ""
    for isite in range(0, len(site_names_array)):
        site_sig_eps_nnn = site_sig_eps_nnn + site_names_array[isite] + "-" +  str(vars()['sig' + str(isite)]) + "-" + str(vars()['eps' + str(isite)]) + "-" + str(n_exp) + "_"
    site_sig_eps_nnn = site_sig_eps_nnn[:-1]
    
    prefix = "i-" + str(iter)

    arg1 = site_sig_eps_nnn
    arg2 = prefix
    arg3 = molecules
    arg4 = raw_par_path
    arg5 = datafile_keywords_string
    arg6 = GOMC_exe
    arg7 = z_wt
    arg8 = u_wt
    arg9 = n_wt
    arg10 = Nsnapshots
    arg11 = rerun_inp                                                                             
    arg12 = number_of_lowest_Neff
    arg13 = target_Neff
    arg14 = Nproc
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
    score_array = []
    for i in range(len(initial_guess)):
        score_array.append(score)
    print("score_array: ", score_array)
    return score_array


result = least_squares(objective_function, initial_guess, jac='2-point', method='lm', ftol=TOL, xtol=TOL, gtol=TOL, x_scale='jac', loss='linear', f_scale=None, diff_step=DIFF_STEP, tr_solver=None, tr_options={}, jac_sparsity=None, max_nfev=None, verbose=2, args=(), kwargs={})


print(result)

print("Jacobian: ")
print(result.jac)

os.system("bash $HOME/Git/TranSFF/Scripts/simulticomp_organize.sh " + run_name + " " + molecules)