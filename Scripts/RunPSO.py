
from pso_old import pso
import os

def objective_function(x):
    X = x[0]
    Y = x[1]
    iteration_name = str(X) + "_" + str(Y)
    command = "bash ConvertParToScore.sh " + iteration_name + " " + str(X) + " " + str(Y)
    os.system(command)
    score_file_address = iteration_name + "/" + iteration_name + ".score"
    with open(score_file_address) as f:
        score = f.readline()
    return float(score)


lb = [3.7, 110]
ub = [3.8, 130]
initial_guess = [[],[],[]]

xopt, fopt = pso(objective_function, lb, ub, swarmsize=10, omega=0.5, phip=0.5, phig=0.5, maxiter=100, minstep=1e-10, minfunc=1e-8, debug=True)

print(xopt, fopt)




