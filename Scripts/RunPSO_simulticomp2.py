import os, sys
sys.path.insert(1, os.path.expanduser('~') +'/Git/TranSFF/Scripts/')
from pso import parallel_pso, serial_pso, parallel_pso_auxiliary
from multiprocessing import Process, Pool
import numpy

# Input parameters ##################
run_name = "SimulPSO_C2-C3-C4-C8-C12_N500_select9_rmsd_wide-range_P12"
molecules_array = ["C2", "C3", "C4", "C8", "C12"]
datafile_keyword_array=[ "REFPROP", "REFPROP", "REFPROP", "REFPROP", "REFPROP"]
site_names_array = ["CH3", "CH2"]

ref_array1 = "3.80-100 3.82-110 3.75-98.0 3.73-93.0 3.79-98.0 3.77-88.0 3.75-108.0" #C2
ref_array2 = "3.80-100_4.00-48 3.82-110_4.01-45 3.75-98.0_3.95-46.0 3.79-93.0_3.97-43.5 3.75-108.0_3.91-50.5 3.73-98.0_3.95-54.0 3.77-103.0_3.93-47.0" #C3
ref_array3 = "3.80-100_4.00-48 3.82-110_4.01-45 3.75-98.0_3.95-46.0 3.73-88.0_3.97-50.5 3.77-98.0_3.91-47.0 3.75-108.0_3.95-43.5 3.79-93.0_3.99-40.0" #C4
ref_array4 = "3.80-100_4.00-48 3.82-110_4.01-45 3.75-98.0_3.95-46.0 3.73-88.0_3.97-50.5 3.77-98.0_3.91-47.0 3.75-108.0_3.95-43.5 3.79-93.0_3.99-40.0" #C8
ref_array5 = "3.80-100_4.00-48 3.82-110_4.01-45 3.75-98.0_3.95-46.0 3.73-88.0_3.97-50.5 3.77-98.0_3.91-47.0 3.75-108.0_3.95-43.5 3.79-93.0_3.99-40.0" #C12

#ref_array1 = "3.75-98.0 3.73-93.0 3.71-103.0 3.79-98.0 3.77-88.0 3.75-108.0" #C2
#ref_array2 = "3.75-98.0_3.95-46.0 3.79-93.0_3.97-43.5 3.75-108.0_3.91-50.5 3.71-88.0_3.99-40.0 3.73-98.0_3.95-54.0 3.77-103.0_3.93-47.0" #C3
#ref_array3 = "3.75-98.0_3.95-46.0 3.73-88.0_3.97-50.5 3.77-98.0_3.91-47.0 3.75-108.0_3.95-43.5 3.71-103.0_3.93-54.0 3.79-93.0_3.99-40.0" #C4
#ref_array4 = "3.75-98.0_3.95-46.0 3.73-88.0_3.97-50.5 3.77-98.0_3.91-47.0 3.75-108.0_3.95-43.5 3.71-103.0_3.93-54.0 3.79-93.0_3.99-40.0" #C8
#ref_array5 = "3.75-98.0_3.95-46.0 3.73-88.0_3.97-50.5 3.77-98.0_3.91-47.0 3.75-108.0_3.95-43.5 3.71-103.0_3.93-54.0 3.79-93.0_3.99-40.0" #C12

weights_file = "$HOME/Git/TranSFF/Weights/select9_satZx10_lowrhoZx4_satUx2.wts"
raw_par_path = "$HOME/Git/TranSFF/Forcefields/TraPPE-UA_Alkanes_SOME.par"
GOMC_exe = "$HOME/Git/GOMC/GOMC-FSHIFT2-SWF-HighPrecisionPDB-StartFrame/bin/GOMC_CPU_NVT"
#z_wt="0.8"
#u_wt="0.2"
#n_wt="0.0001"
ZU_or_onlyU = "ZU"
Nsnapshots = "500"
rerun_inp = "none"
#number_of_lowest_Neff="1"
#target_Neff="25"
Nproc_per_particle = "3"
ITIC_subset_name = "select9"
n_exp = 12
sig_sigfig = 3
eps_sigfig = 1

# Set PSO parameters ################
swarm_size = 12
max_iterations = 20
tol = 1e-6

# Set PSO bounds and initial guesses ################
lb = [3.73, 92, 3.93, 42]
ub = [3.82, 106, 4.02, 60]
initial_guess = [[], [], [], [], [], [], [], [], [], [], [], []]
nnbp = 2


#============================================================================================
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


log = "pso.log"
iter = 0
def objective_function(x):
    global iter
    iter = iter + 1  

    np = len(x[:, 0])   # Number of particles (candidate solutions)
    nd = len(x[0, :])   # Number of dimensions (variables)
    
    objective_array = [] 
    def run_one_particle(run_particle_input_array):        
        iteration = run_particle_input_array[0]
        particle = run_particle_input_array[1]
        sig_eps_nnn = run_particle_input_array[2]

        for isite in range(0, len(site_names_array)):
            for inbp in range(0, nnbp):
                if inbp/nnbp == 0:
                    vars()['sig' + str(isite)] = round( sig_eps_nnn[isite * nnbp + inbp], sig_sigfig)
                else:
                    vars()['eps' + str(isite)] = round( sig_eps_nnn[isite * nnbp + inbp], eps_sigfig)

        site_sig_eps_nnn = ""
        for isite in range(0, len(site_names_array)):
            site_sig_eps_nnn = site_sig_eps_nnn + site_names_array[isite] + "-" +  str(vars()['sig' + str(isite)]) + "-" + str(vars()['eps' + str(isite)]) + "-" + str(n_exp) + "_"
        site_sig_eps_nnn = site_sig_eps_nnn[:-1]
        prefix = "i-" + str(iteration) + "_p-" + str(particle)

        arg1 = site_sig_eps_nnn
        arg2 = prefix
        arg3 = molecules
        arg4 = raw_par_path
        arg5 = datafile_keywords_string
        arg6 = GOMC_exe
        arg7 = weights_file
        arg8 = ZU_or_onlyU
        arg9 = Nsnapshots
        arg10 = rerun_inp                                                                             
        arg11 = Nproc_per_particle
        arg12 = ITIC_subset_name
        arg13 = all_molecules_ref_string

        command = "bash $HOME/Git/TranSFF/Scripts/simulticomp2.sh" + " " + arg1 + " " + arg2+  " " + arg3 + " " + arg4 + " " + arg5 + " " + arg6 + " " + arg7 + " " + arg8 + " " + arg9 + " " + arg10 + " " + arg11 + " " + arg12 + " " + arg13 #+ " " + arg14 + " " + arg15 + " " + arg16
        print(command)

        os.system(command)

        return 
    
    run_particle_input_array = []
    for p in range(0, np):
        run_particle_input_array.append( [iter, p + 1, x[p, :]] )

    for p in range(0, np):
        exec_string = "p" + str(p) + " = Process(target = run_one_particle, args=(run_particle_input_array[" + str(p) + "],))"
        exec(exec_string)
        exec_string = "p" + str(p) + ".start()"
        exec(exec_string)

    for p in range(0, np):
        exec_string = "p" + str(p) + ".join()"
        exec(exec_string)
    
    # wait for all particles to get ready

    for p in range(0, np):
        score_file_address = "i-" + str(iter) + "_p-" + str(p + 1) + ".score"
        scores_data = numpy.loadtxt(score_file_address, skiprows=1, usecols=[1,2,3])

        if len(molecules_array) == 1:
            #sum_z_scores = numpy.sum(scores_data[1])  # if only one molecule is being optimized => sum_z_scores = numpy.sum(scores_data[1])
            #sum_u_scores = numpy.sum(scores_data[2])  # if only one molecule is being optimized => sum_u_scores = numpy.sum(scores_data[2])
            score = numpy.sum(scores_data[0])
        else:
            #sum_z_scores = numpy.sum(scores_data[:,1])  # if more than one molecule is being optimized => sum_z_scores = numpy.sum(scores_data[:,1])
            #sum_u_scores = numpy.sum(scores_data[:,2])  # if more than one molecule is being optimized => sum_u_scores = numpy.sum(scores_data[:,2])
            score = numpy.sum(scores_data[:,0])

        #score = sum_z_scores + sum_u_scores
        objective_array.append(score)

    print("objective_array: ", objective_array)
    print()

    return objective_array  ####################### End of objective_function

print("initial_guess: ", initial_guess)
print()
xopt, fopt = parallel_pso(objective_function, lb, ub, ig = initial_guess ,swarmsize=swarm_size, omega=0.5, phip=0.5, phig=0.5, maxiter=max_iterations, minstep=tol, minfunc=tol, debug=False, outFile = log)

print("xopt, fopt: ", xopt, fopt)

os.system("bash $HOME/Git/TranSFF/Scripts/simulticomp_organize2.sh " + run_name + " " + molecules)
