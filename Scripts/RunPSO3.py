import os, sys
sys.path.insert(1, os.path.expanduser('~') +'/Git/TranSFF/Scripts/')
from pso import parallel_pso, serial_pso, parallel_pso_auxiliary
from multiprocessing import Process, Pool
import numpy



# Input parameters ##################
molecule = "C1"
NS = 1
#config_filename = "FSWITCH_1M_rc1012_light.conf"
config_filename = "VDW_VERY_SHORT.conf"

raw_par = "C1_sSOMEeSOMEnSOME.par"
nproc = "1"
selected_itic_points = "0.3179/167.20 0.3814/137.14 0.4450/95.90 228.00/0.0212 228.00/0.0636 228.00/0.1907 228.00/0.3179 228.00/0.3814 228.00/0.4450"  # C1 select9
true_data_file = "$HOME/Git/TranSFF/Data/C1/MiPPE_select9.res" 
true_data_label = "MiPPE"                                                              
Z_WT = "0.8"
U_WT = "0.2"
OUTER_PSO_GOMC_EXE_ADDRESS="$HOME/Git/GOMC/GOMC-FSHIFT2-SWF-HighPrecisionPDB-StartFrame/bin/GOMC_CPU_NVT"


# Set outer PSO parameters ################
SWARM_SIZE = 8
MAX_ITERATIONS = 25
TOL = 1e-2

# Set PSO bounds and initial guesses ################
LB = [3.7, 155, 11]
UB = [3.8, 175, 16]
INITIAL_GUESS = [[], [], [], [], [], [], [], []]
NNBP = 3










#============================================================================================
LOG = "OUTER.out"
log = "inner.out"

selected_itic_points =  "\"" + selected_itic_points + "\""

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

            if D % (NNBP) == NNBP-1:
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
         + " " + Z_WT + " " + U_WT + " " + true_data_file + " " + true_data_label + " " + raw_par + " " + OUTER_PSO_GOMC_EXE_ADDRESS
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

    return OBJECTIVE_ARRAY #, AUX_ARRAY ############################# End of OBJECTIVE_FUNCTION






print("INITIAL_GUESS: ", INITIAL_GUESS)
print()

XOPT, FOPT = parallel_pso(OBJECTIVE_FUNCTION, LB, UB, ig = INITIAL_GUESS ,swarmsize=SWARM_SIZE, omega=0.5, phip=0.5, phig=0.5, maxiter=MAX_ITERATIONS, minstep=TOL, minfunc=TOL, debug=False, outFile = LOG)

print("XOPT:", XOPT)
print("FOPT:", FOPT)
