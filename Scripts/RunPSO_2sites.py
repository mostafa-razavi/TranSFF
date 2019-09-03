import os, sys
sys.path.insert(1, os.path.expanduser('~') +'/Git/TranSFF/Scripts/')
from pso import pso


log = open("RunPSO_2sites.feval", "w", encoding="utf-8")
print('feval_count sig_site1 eps_site1 sig_site2 eps_site2', file = log)

feval_count = 0
def objective_function(x):
    global feval_count
    feval_count = feval_count + 1

    some_sig_site1 = x[0]
    some_eps_site1 = x[1]
    some_sig_site2 = x[2]
    some_eps_site2 = x[3]   

    iteration_name = "feval-" + str(feval_count) #+ "_" +  str(some_sig_site1) + "-" + str(some_eps_site1) + "_" +  str(some_sig_site2) + "-" + str(some_eps_site2)

    command = "bash ConvertParToScore_2sites.sh " + iteration_name + " " + str(some_sig_site1) + " " + str(some_eps_site1) + " " + str(some_sig_site2) + " " + str(some_eps_site2)
    os.system(command)

    score_file_address = iteration_name + "/" + iteration_name + ".score"
    with open(score_file_address) as f:
        score = f.readline()
        
    print(feval_count, some_sig_site1, some_eps_site1, some_sig_site2, some_eps_site2, score, file = log)
    return float(score)


lb = [3.700, 100.0, 3.900, 40.0]
ub = [3.950, 140.0, 4.100, 80.0]
#initial_guess = [[],[],[]]

xopt, fopt = pso(objective_function, lb, ub, swarmsize=10, omega=0.5, phip=0.5, phig=0.5, maxiter=1000, minstep=1e-10, minfunc=1e-8, debug=False)

print(xopt, fopt, file = log)




