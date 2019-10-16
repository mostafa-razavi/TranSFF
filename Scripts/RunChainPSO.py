import os, sys
sys.path.insert(1, os.path.expanduser('~') +'/Git/TranSFF/Scripts/')
from pso import parallel_pso, serial_pso, parallel_pso_auxiliary
from multiprocessing import Process, Pool
import numpy




# Input parameters ##################
molecule="C2"
NS=1
config_filename="FSHIFT_BULK_2M.conf"
nproc="5"
selected_itic_points = "0.4286/259.42 0.5571/174.46 360.00/0.1714 360.00/0.4286 360.00/0.5571"  # C2 select5
true_data_file="$HOME/Git/TranSFF/Data/C2/REFPROP_select5.res" 
true_data_label="REFPROP"                                                              
Z_WT="0.5"
U_WT="0.5"


# Set PSO parameters ################
SWARM_SIZE = 3
MAX_ITERATIONS = 100
TOL = 1e-4

swarm_size = 5
max_iterations = 100
tol = 1e-4

LB = [3.700, 110.0]
UB = [3.800, 130.0]
INITIAL_GUESS = [[3.71, 128.0],[3.71, 112.0],[3.79, 112.0]]


#MP = numpy.average(numpy.array([LB, UB]), axis=0)   # Average of LB and UB
#INITIAL_GUESS = [LB, UB, MP]
#INITIAL_GUESS = [[3.798439938521785, 112.96044772170356],[3.7232740107259135, 120.53420612478035],[3.756567056242516, 123.93603301460698]]


#============================================================================================
LOG = "OUTER.out"
log = "inner.out"

selected_itic_points =  "\"" + selected_itic_points + "\""

it = 0
ITER = 0
SIMULATED_P = 0


def OBJECTIVE_FUNCTION(X):
    global ITER
    global SIMULATED_P
    global it

    SIMULATED_P = 0
    ITER = ITER + 1

    NP = len(X[:, 0])   # Number of particles (candidate solutions) of outer PSO optimization
    ND = len(X[0, :])   # Number of dimensions (variables) of outer PSO optimization
    
    ITER_PARTICLE_PREFIX = []
    SIG_EPS_NNN_ARRAY = []  
    PARTICLE_NAMES_ARRAY = []
    OBJECTIVE_ARRAY = []
    AUX_ARRAY = numpy.zeros((0, ND))


    for P in range(0, NP):
        string = ""
        for D in range(0, ND):
            SIG_or_EPS_or_NNN = X[P,D]

            if D == int(ND/NS) - 1:
                delimiter = "_"
            else:
                delimiter = "-"
                
            string = string + str(SIG_or_EPS_or_NNN) + delimiter

        ITER_PARTICLE_PREFIX.append( "I-"  + str(ITER) + "_P-" + str(P+1) )
        SIG_EPS_NNN_ARRAY.append( string[:-1] )
        PARTICLE_NAMES_ARRAY.append( str(ITER_PARTICLE_PREFIX[P]) + "_" + str(SIG_EPS_NNN_ARRAY[P]) )

    ITER_PARTICLE_PREFIX_STRING = "\"" + ' '.join(map(str, ITER_PARTICLE_PREFIX)) + "\""
    SIG_EPS_NNN_ARRAY_STRING = "\"" + ' '.join(map(str, SIG_EPS_NNN_ARRAY)) + "\""

    COMMAND = "bash $HOME/Git/TranSFF/Scripts/RUN_PARTICLES_AND_WAIT_AUX.sh" + " " + ITER_PARTICLE_PREFIX_STRING \
         + " " + molecule + " " + selected_itic_points + " " + config_filename + " " + nproc + " " + SIG_EPS_NNN_ARRAY_STRING \
         + " " + Z_WT + " " + U_WT + " " + true_data_file + " " + true_data_label
    print("COMMAND: ", COMMAND)
    print()

    os.system(COMMAND)
    # WAIT for all PARTICLES (reference simulations) to finish

    
    for P in range(0, NP):
        SCORE_FILE_ADDRESS = PARTICLE_NAMES_ARRAY[P] + "/" + PARTICLE_NAMES_ARRAY[P] + ".SCORE"
        with open(SCORE_FILE_ADDRESS) as f:
            SCORE = f.readline()
        LIST_OF_SCORES = list(SCORE.split())  
        OBJECTIVE_ARRAY.append(float(LIST_OF_SCORES[0]))
    
    print("OBJECTIVE_ARRAY: ", OBJECTIVE_ARRAY)    
    print()    


    def objective_function(x):
        global SIMULATED_P
        global it
        it = it + 1  

        np = len(x[:, 0])   # Number of particles (candidate solutions) of inner PSO optimization
        nd = len(x[0, :])   # Number of dimensions (variables) of inner PSO optimization
        
        objective_array = []    
        def run_one_particle(run_particle_input_array):
            ITERATION = run_particle_input_array[0]
            PARTICLE = run_particle_input_array[1]
            iteration = run_particle_input_array[2]
            particle = run_particle_input_array[3]
            sig_eps_nnn = run_particle_input_array[4]

            string = ""
            for d in range(0, nd):
                sig_or_eps_or_nnn = sig_eps_nnn[d]

                if d == int(nd/NS) - 1:
                    delimiter = "_"
                else:
                    delimiter = "-"
                                            
                string = string + str(sig_or_eps_or_nnn) + delimiter
            sig_eps_nnn_string = string[:-1]

            arg0 = "bash ~/Git/TranSFF/Scripts/run_particle.sh"
            arg1 = "I-" + str(ITERATION) + "_P-" + str(PARTICLE) + "_i-" + str(iteration) + "_p-" + str(particle)   # keyword
            arg2 = molecule                                                                                         # molecule
            arg3 = selected_itic_points                                                                             # selected_itic_points
            arg4 = config_filename                                                                                  # config_filename
            arg5 = nproc                                                                                            # Nproc
            arg6 = sig_eps_nnn_string                                                                               # sig_eps_nnn_string
            arg7 = "I-" + str(ITERATION) + "_P-" + str(PARTICLE) + "_" + str(SIG_EPS_NNN_ARRAY[PARTICLE-1])         # reference_foldernames_array
            arg8 = true_data_file                                                                                   
            arg9 = true_data_label
            command = arg0 + " " + arg1 + " " + arg2 + " " + arg3 + " " + arg4 + " " + arg5 + " " + arg6 + " " + arg7 + " " + arg8 + " " + arg9
            print(command)
            print()

            os.system( command )

            return 

        run_particle_input_array = []
        for p in range(0, np):
            run_particle_input_array.append( [ITER, SIMULATED_P , it, p + 1, x[p, :]] )

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
            iter_particle_prefix = "I-" + str(ITER) + "_P-" + str(SIMULATED_P) + "_i-" +  str(it) + "_p-" + str(p + 1)
            score_file_address = iter_particle_prefix + "/" + iter_particle_prefix + ".score"
            with open(score_file_address) as f:
                score = f.readline()
            list_of_scores = list(score.split())  
            objective_array.append(float(list_of_scores[0]))
        
        print("objective_array: ", objective_array)
        print()

        return objective_array  ####################### End of objective_function


    for i in range(0, NP):
        global it
        it = 0
        SIMULATED_P = SIMULATED_P + 1

        # Get bounds and initial guess
        lb = LB 
        ub = UB
        initial_guess = []
        initial_guess.append(X[SIMULATED_P-1,:])    # Set the first particle to be at the reference simulation exactly, to make sure the PSO algorithm discovers the n_score region.
        for i in range(0, swarm_size-1):
            initial_guess.append([])

        print("initial_guess: ", initial_guess)
        print()
        xopt, fopt = parallel_pso(objective_function, lb, ub, ig = initial_guess ,swarmsize=swarm_size, omega=0.5, phip=0.5, phig=0.5, maxiter=max_iterations, minstep=tol, minfunc=tol, debug=False, outFile = log)
        
        print("xopt, fopt: ", xopt, fopt)
        print()
        AUX_ARRAY = numpy.append(AUX_ARRAY, [xopt], axis=0)
        it = 0
    
    print("AUX_ARRAY ", AUX_ARRAY)
    print()

    return OBJECTIVE_ARRAY, AUX_ARRAY ############################# End of OBJECTIVE_FUNCTION






print("INITIAL_GUESS: ", INITIAL_GUESS)
print()

XOPT, FOPT = parallel_pso_auxiliary(OBJECTIVE_FUNCTION, LB, UB, ig = INITIAL_GUESS ,swarmsize=SWARM_SIZE, omega=0.5, phip=0.5, phig=0.5, phia=0.5, maxiter=MAX_ITERATIONS, minstep=TOL, minfunc=TOL, debug=False, outFile = LOG)

print("XOPT:", XOPT)
print("FOPT:", FOPT)
