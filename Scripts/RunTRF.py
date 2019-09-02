
from scipy.optimize import least_squares
import os
import scipy
from numpy import inf

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

xy_initial_guess = [3.700,110.0]

result = least_squares(objective_function_2D, xy_initial_guess, jac='2-point', bounds=(lb, ub), method='trf', ftol=1e-08, xtol=1e-08, gtol=1e-08, x_scale=1.0, loss='linear', f_scale=1.0, diff_step=None, tr_solver=None, tr_options={}, jac_sparsity=None, max_nfev=None, verbose=0, args=(), kwargs={})

print(result.x[0], result.x[1])




