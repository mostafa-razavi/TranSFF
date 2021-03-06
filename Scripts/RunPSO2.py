import os, sys
sys.path.insert(1, os.path.expanduser('~') +'/Git/TranSFF/Scripts/')
from pso import parallel_pso, serial_pso, parallel_pso_auxiliary
from multiprocessing import Process, Pool
import numpy



# Input parameters ##################
molecule = "C2"
NS = 1
config_filename = "FSWITCH_BULK_2M.conf"
raw_par = "C2_MiPPE-GEN_Alkanes_sSOMEeSOME.par"
nbatch = "5"
selected_itic_points = "0.4286/259.42 0.5571/174.46 360.00/0.1714 360.00/0.4286 360.00/0.5571"  # C2 select5
true_data_file = "$HOME/Git/TranSFF/Data/C2/MiPPE_select5.res" 
true_data_label = "MiPPE"                                                              
inner_pso_gomc_exe_address="$HOME/Git/GOMC/GOMC-FSHIFT2-SWF-HighPrecisionPDB-StartFrame/bin/GOMC_CPU_NVT"
all_ref_array="3.7561399186002613-140.4665649259206 3.7417084099511273-142.42506367833323 3.771782534918835-141.14290962908598 3.71987310251875-140.00690290691065 3.804905733195129-136.036048956761 3.7801005170043966-141.62302432139552 3.7785209156049646-142.2673032845526 3.791496276433352-139.33874886906526 3.800301697481128-139.74864272042353 3.768414863783031-143.17368280832508"
n_closest = "4"
coeff_aray = "20 1"
Nsnapshots = "500"
rerun_inp = "none"                                                                                 # "none" or filename
z_wt = "0.50"
u_wt = "0.40"
n_wt = "0.10"
number_of_lowest_Neff = "1"
target_Neff = "25"

# Set PSO parameters ################
swarm_size = 5
max_iterations = 100
tol = 1e-3

# Set PSO bounds and initial guesses ################
lb = [3.69, 135.0]
ub = [3.81, 145.0]
initial_guess = [[], [], [], [], []]



#============================================================================================
log = "pso.log"

selected_itic_points =  "\"" + selected_itic_points + "\""
all_ref_array =  "\"" + all_ref_array + "\""
coeff_aray =  "\"" + coeff_aray + "\""

it = 0

def objective_function(x):
    global it
    it = it + 1  

    np = len(x[:, 0])   # Number of particles (candidate solutions) of inner PSO optimization
    nd = len(x[0, :])   # Number of dimensions (variables) of inner PSO optimization
    
    objective_array = []    
    def run_one_particle(run_particle_input_array):
        iteration = run_particle_input_array[0]
        particle = run_particle_input_array[1]
        sig_eps_nnn = run_particle_input_array[2]

        string = ""
        for d in range(0, nd):
            sig_or_eps_or_nnn = sig_eps_nnn[d]

            if d == int(nd/NS) - 1:
                delimiter = "_"
            else:
                delimiter = "-"
                                        
            string = string + str(sig_or_eps_or_nnn) + delimiter
        sig_eps_nnn_string = string[:-1]

        arg0 = "bash ~/Git/TranSFF/Scripts/run_particle2.sh"
        arg1 = "i-" + str(iteration) + "_p-" + str(particle)                                                    # keyword
        arg2 = molecule                                                                                         # molecule
        arg3 = selected_itic_points                                                                             # selected_itic_points
        arg4 = config_filename                                                                                  # config_filename
        arg5 = nbatch                                                                                            # nbatch
        arg6 = sig_eps_nnn_string                                                                               # sig_eps_nnn_string
        arg7 = all_ref_array
        arg8 = coeff_aray
        arg9 = n_closest
        arg10 = true_data_file                                                                                   
        arg11 = true_data_label
        arg12 = raw_par
        arg13 = inner_pso_gomc_exe_address
        arg14 = Nsnapshots
        arg15 = rerun_inp
        arg16 = z_wt
        arg17 = u_wt
        arg18 = n_wt
        arg19 = number_of_lowest_Neff
        arg20 = target_Neff        

        command = arg0 + " " + arg1 + " " + arg2 + " " + arg3 + " " + arg4 + " " + arg5 + " " + arg6 + " " + arg7 + " " + arg8 + " " + arg9 + " " + arg10 + " " + arg11 + " " + arg12 + " " + arg13 + " " + arg14 + " " + arg15 + " " + arg16 + " " + arg17 + " " + arg18 + " " + arg19 + " " + arg20
        print(command)
        print()

        os.system( command )

        return 

    run_particle_input_array = []
    for p in range(0, np):
        run_particle_input_array.append( [it, p + 1, x[p, :]] )

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
        iter_particle_prefix = "i-" +  str(it) + "_p-" + str(p + 1)
        score_file_address = iter_particle_prefix + "/" + iter_particle_prefix + ".score"
        with open(score_file_address) as f:
            score = f.readline()
        list_of_scores = list(score.split())  
        objective_array.append(float(list_of_scores[0]))
    
    print("objective_array: ", objective_array)
    print()

    return objective_array  ####################### End of objective_function

print("initial_guess: ", initial_guess)
print()
xopt, fopt = parallel_pso(objective_function, lb, ub, ig = initial_guess ,swarmsize=swarm_size, omega=0.5, phip=0.5, phig=0.5, maxiter=max_iterations, minstep=tol, minfunc=tol, debug=False, outFile = log)

print("xopt, fopt: ", xopt, fopt)

os.system( "mkdir Results; mv i-* Results" )

os.system("cd Results; for folder in `ls -d i-* | sort -V`; do score=$(cat $folder/*.score); par=$(ls $folder/*.par); ref=$(cat $folder/*.ref); echo $score $ref; done | tee iterations.res")