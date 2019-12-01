import os, sys
sys.path.insert(1, os.path.expanduser('~') +'/Git/TranSFF/Scripts/')
from pso import parallel_pso, serial_pso, parallel_pso_auxiliary
from multiprocessing import Process, Pool
import numpy

# Input parameters ##################
run_name = "Simultaneous_PSO_test"
molecules_array = [ "C2", "C12" ]
site_names_array = ["CH3", "CH2"]

ref_array1="3.81-127 3.79-134 3.78-131 3.77-133 3.75-129" #C2 
ref_array2="3.81-127_3.95-74 3.79-134_3.97-67 3.78-131_3.99-70 3.77-133_4.01-68 3.75-129_4.03-72" #C12

raw_par_path="$HOME/Git/TranSFF/Forcefields/MiPPE-GEN_Alkanes_SOME.par"
datafile_keyword="MiPPE"
GOMC_exe="$HOME/Git/GOMC/GOMC-FSHIFT2-SWF-HighPrecisionPDB-StartFrame/bin/GOMC_CPU_NVT"
n_closest="5"
z_wt="0.80"
u_wt="0.20"
n_wt="0.0001"
Nsnapshots="10"
rerun_inp="none"
number_of_lowest_Neff="1"
target_Neff="2"
Nproc_per_particle="8"
ITIC_subset_name="select9"
n_exp = 16


# Set PSO parameters ################
swarm_size = 3
max_iterations = 100
tol = 1e-3

# Set PSO bounds and initial guesses ################
lb = [3.69, 135.0, 3.95, 60]
ub = [3.81, 145.0, 4.05, 80]
initial_guess = [[], [], []]
nnbp = 2







#============================================================================================
molecules = ""
all_molecules_ref_string = ""
for imolec in range(0, len(molecules_array)):
    molecules = molecules + molecules_array[imolec] + " "
    vars()['ref_array' + str(imolec+1)] = "\"" + vars()['ref_array' + str(imolec+1)] + "\""
    all_molecules_ref_string = all_molecules_ref_string + vars()['ref_array' + str(imolec+1)] + " "
all_molecules_ref_string = all_molecules_ref_string[:-1]
molecules = molecules[:-1]
molecules =  "\"" + molecules + "\""


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
                    vars()['sig' + str(isite)] = round( sig_eps_nnn[isite * nnbp + inbp], 5)
                else:
                    vars()['eps' + str(isite)] = round( sig_eps_nnn[isite * nnbp + inbp], 5)

        site_sig_eps_nnn = ""
        for isite in range(0, len(site_names_array)):
            site_sig_eps_nnn = site_sig_eps_nnn + site_names_array[isite] + "-" +  str(vars()['sig' + str(isite)]) + "-" + str(vars()['eps' + str(isite)]) + "-" + str(n_exp) + "_"
        site_sig_eps_nnn = site_sig_eps_nnn[:-1]
        prefix = "i-" + str(iter) + "_p-" + str(particle)

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
            sum_z_scores = numpy.sum(scores_data[1])  # if only one molecule is being optimized => sum_z_scores = numpy.sum(scores_data[1])
            sum_u_scores = numpy.sum(scores_data[2])  # if only one molecule is being optimized => sum_u_scores = numpy.sum(scores_data[2])
        else:
            sum_z_scores = numpy.sum(scores_data[:,1])  # if more than one molecule is being optimized => sum_z_scores = numpy.sum(scores_data[:,1])
            sum_u_scores = numpy.sum(scores_data[:,2])  # if more than one molecule is being optimized => sum_u_scores = numpy.sum(scores_data[:,2])

        score = sum_z_scores + sum_u_scores
        objective_array.append(score)

    print("objective_array: ", objective_array)
    print()

    return objective_array  ####################### End of objective_function

print("initial_guess: ", initial_guess)
print()
xopt, fopt = parallel_pso(objective_function, lb, ub, ig = initial_guess ,swarmsize=swarm_size, omega=0.5, phip=0.5, phig=0.5, maxiter=max_iterations, minstep=tol, minfunc=tol, debug=False, outFile = log)

print("xopt, fopt: ", xopt, fopt)

os.system("bash $HOME/Git/TranSFF/Scripts/simulticomp_organize.sh " + run_name + " " + molecules)
