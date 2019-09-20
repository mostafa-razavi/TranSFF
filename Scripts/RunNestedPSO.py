import os, sys
sys.path.insert(1, os.path.expanduser('~') +'/Git/TranSFF/Scripts/')
from pso import parallel_pso, serial_pso
from multiprocessing import Process, Pool
import numpy




# Input parameters ##################
molecule="C2"
NS=1
config_filename="FSHIFT_BULK_LONG.conf"
nproc="4"
selected_itic_points = "0.4286/259.42 0.5571/174.46 360.00/0.4286 360.00/0.5571"  # C2 select4
true_data_file="$HOME/Git/TranSFF/Data/C2/REFPROP_select4.res" 
true_data_label="REFPROP"                                                              


# Set PSO parameters ################
SWARM_SIZE = 3
swarm_size = 6

LB = [3.700, 110.0]
UB = [3.800, 130.0]
#MP = numpy.average(numpy.array([LB, UB]), axis=0)   # Average of LB and UB
#INITIAL_GUESS = [LB, UB, MP]
INITIAL_GUESS = [[], [3.75, 117], []]
#INITIAL_GUESS = [[],[],[]]







#============================================================================================
LOG = "OUTER.out"
log = "inner.out"

selected_itic_points =  "\"" + selected_itic_points + "\""
REFERENCE_SIM_ARRAY = [[]]

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

    COMMAND = "bash $HOME/Git/TranSFF/Scripts/RUN_PARTICLES_AND_WAIT.sh" + " " + ITER_PARTICLE_PREFIX_STRING + " " + molecule + " " + selected_itic_points + " " + config_filename + " " + nproc + " " + SIG_EPS_NNN_ARRAY_STRING
    #if ITER != 1:
    os.system(COMMAND)
    # wait

    print("COMMAND: ", COMMAND)
    



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
            sigma = run_particle_input_array[4]
            epsilon = run_particle_input_array[5]

            arg0 = "bash ~/Git/TranSFF/Scripts/run_particle.sh"
            arg1 = "I-" + str(ITERATION) + "_P-" + str(PARTICLE) + "_i-" + str(iteration) + "_p-" + str(particle)   # keyword
            arg2 = "C2"                                                                                             # molecule
            arg3 = selected_itic_points                                                                             # selected_itic_points
            arg4 = config_filename                                                                                  # config_filename
            arg5 = nproc                                                                                            # Nproc
            arg6 = str(sigma) + "-" + str(epsilon)                                                                  # sig_eps_nnn
            arg7 = "I-" + str(ITERATION) + "_P-" + str(PARTICLE) + "_" + str(SIG_EPS_NNN_ARRAY[PARTICLE-1])         # reference_foldernames_array
            arg8 = true_data_file                                                                                   
            arg9 = true_data_label
            command = arg0 + " " + arg1 + " " + arg2 + " " + arg3 + " " + arg4 + " " + arg5 + " " + arg6 + " " + arg7 + " " + arg8 + " " + arg9
            print(command)
            os.system( command )

            return 

        run_particle_input_array = []
        for p in range(0, np):
            run_particle_input_array.append( [ITER, SIMULATED_P , it, p + 1, x[p, 0], x[p, 1]] )
        print("run_particle_input_array: ", run_particle_input_array)

        #pool = Pool(len(run_particle_input_array))
        #pool.map( run_one_particle,  run_particle_input_array )

        p1 = Process(target = run_one_particle, args=(run_particle_input_array[0],))
        p1.start()
        p2 = Process(target = run_one_particle, args=(run_particle_input_array[1],))
        p2.start()
        p3 = Process(target = run_one_particle, args=(run_particle_input_array[2],))
        p3.start()
        p4 = Process(target = run_one_particle, args=(run_particle_input_array[3],))
        p4.start()
        p5 = Process(target = run_one_particle, args=(run_particle_input_array[4],))
        p5.start()
        p6 = Process(target = run_one_particle, args=(run_particle_input_array[5],))
        p6.start()                        
        p1.join()
        p2.join()        
        p3.join() 
        p4.join()
        p5.join()        
        p6.join()                
        # wait

        for p in range(0, np):
            iter_particle_prefix = "I-" + str(ITER) + "_P-" + str(SIMULATED_P) + "_i-" +  str(it) + "_p-" + str(p + 1)
            score_file_address = iter_particle_prefix + "/" + iter_particle_prefix + ".score"
            with open(score_file_address) as f:
                score = f.readline()
            list_of_scores = list(score.split())  
            objective_array.append(float(list_of_scores[0]))
        
        print("list_of_scores: ", list_of_scores)

        return objective_array  ####################### End of objective_function


    for i in range(0, NP):
        global it
        it = 0
        SIMULATED_P = SIMULATED_P + 1

        # Get sigma and epsilon of PARTICLE
        sig_mid = X[SIMULATED_P-1, 0]
        eps_mid = X[SIMULATED_P-1, 1]
        #sig_low = sig_mid * 0.995
        #sig_high = sig_mid * 1.05
        #eps_low = eps_mid * 0.995
        #eps_high = eps_mid * 1.01

        #lb = [sig_low, eps_low]
        #ub = [sig_high, eps_high]
        #mp = numpy.average(numpy.array([lb, ub]), axis=0)   # Average of lb and ub
        #initial_guess = [lb, ub, mp]

        # Get bounds and initial guess
        lb = LB 
        ub = UB
        initial_guess = [[],[],[],[],[],[]]

        xopt, fopt = parallel_pso(objective_function, lb, ub, ig = initial_guess ,swarmsize=swarm_size, omega=0.5, phip=0.5, phig=0.5, maxiter=1000, minstep=1e-4, minfunc=1e-4, debug=False, outFile = log)
        
        print("xopt, fopt: ", xopt, fopt)
        OBJECTIVE_ARRAY.append(float(fopt))
        it = 0
    


    return OBJECTIVE_ARRAY ############################# Endo of OBJECTIVE_FUNCTION






print("INITIAL_GUESS: ", INITIAL_GUESS)
XOPT, FOPT = parallel_pso(OBJECTIVE_FUNCTION, LB, UB, ig = INITIAL_GUESS ,swarmsize=SWARM_SIZE, omega=0.5, phip=0.5, phig=0.5, maxiter=100, minstep=1e-4, minfunc=1e-4, debug=False, outFile = LOG)

print(XOPT, FOPT, file = LOG)





















#    print("#!/bin/bash", file = wait_script)
#    for p in range(0, NP):
#        COMMAND = "bash $HOME/Git/TranSFF/Scripts/ConvertParToScore_1site.sh" + " " +  ITER_PARTICLE_PREFIX[p] + " " + reference_sim[i] + " " + SOME_SIG_SITE1[i] + " " + SOME_EPS_SITE1[i] + " " + "&"
#        print(COMMAND, file = wait_script)
#    print("wait", file = wait_script)


        #COMMAND = "bash ConvertParToScore_2sites_test.sh " + ITER_PARTICLE_PREFIX[p] + " " + str(SOME_SIG_SITE1[p]) + " " + str(SOME_EPS_SITE1[p]) #+ " " + str(some_sig_site2) + " " + str(some_eps_site2)
        #os.system(COMMAND)

        #score_file_address = ITER_PARTICLE_PREFIX + "/" + ITER_PARTICLE_PREFIX + ".score"
        #with open(score_file_address) as f:
        #    score = f.readline()
        #OBJECTIVE_ARRAY.append(float(score))
        #print(ITER, SOME_SIG_SITE1, SOME_EPS_SITE1, some_sig_site2, some_eps_site2, score, file = LOG)




'''
iter_particle_prefix = []
sig_eps_nnn_array = []   
particle_names_array = [] 

for p in range(0, np):
    string = ""
    for d in range(0, nd):
        sig_or_eps_or_nnn = x[p,d] 

        if d == int(nd/ns) - 1:
            delimiter = "_"
        else:
            delimiter = "-"
            
        string = string + str(sig_or_eps_or_nnn) + delimiter

    iter_particle_prefix.append( "I-"  + str(iter) + "_P-" + str(p+1) )
    sig_eps_nnn_array.append( string[:-1] )
    particle_names_array.append( str(iter_particle_prefix[p]) + "_" + str(sig_eps_nnn_array[p]) )

iter_particle_prefix_STRING = "\"" + ' '.join(map(str, iter_particle_prefix)) + "\""
sig_eps_nnn_array_STRING = "\"" + ' '.join(map(str, sig_eps_nnn_array)) + "\""
'''