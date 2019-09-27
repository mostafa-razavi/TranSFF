import numpy as np
    
def parallel_pso(func, lb, ub, ig=[], ieqcons=[], f_ieqcons=None, args=(), kwargs={}, 
        swarmsize=100, omega=0.5, phip=0.5, phig=0.5, maxiter=100, 
        minstep=1e-8, minfunc=1e-8, debug=False, outFile=None):
    """
    Perform syncronous parallel particle swarm optimization (PSO)
   
    Parameters
    ==========
    func : function
        The function to be minimized
    lb : array
        The lower bounds of the design variable(s)
    ub : array
        The upper bounds of the design variable(s)
   
    Optional
    ========
    ig : list
        A list of tuples each representing the initial guess for one particle
    ieqcons : list
        A list of functions of length n such that ieqcons[j](x,*args) >= 0.0 in 
        a successfully optimized problem (Default: [])
    f_ieqcons : function
        Returns a 1-D array in which each element must be greater or equal 
        to 0.0 in a successfully optimized problem. If f_ieqcons is specified, 
        ieqcons is ignored (Default: None)
    args : tuple
        Additional arguments passed to objective and constraint functions
        (Default: empty tuple)
    kwargs : dict
        Additional keyword arguments passed to objective and constraint 
        functions (Default: empty dict)
    swarmsize : int
        The number of particles in the swarm (Default: 100)
    omega : scalar
        Particle velocity scaling factor (Default: 0.5)
    phip : scalar
        Scaling factor to search away from the particle's best known position
        (Default: 0.5)
    phig : scalar
        Scaling factor to search away from the swarm's best known position
        (Default: 0.5)
    maxiter : int
        The maximum number of iterations for the swarm to search (Default: 100)
    minstep : scalar
        The minimum stepsize of swarm's best position before the search
        terminates (Default: 1e-8)
    minfunc : scalar
        The minimum change of swarm's best objective value before the search
        terminates (Default: 1e-8)
    debug : boolean
        If True, progress statements will be displayed every iteration
        (Default: False)
   
    Returns
    =======
    g : array
        The swarm's best known position (optimal design)
    f : scalar
        The objective value at ``g``
   
    """

    if outFile != None:
        log = open(outFile, "w", encoding="utf-8")

    assert len(lb)==len(ub), 'Lower- and upper-bounds must be the same length'
    assert hasattr(func, '__call__'), 'Invalid function handle'
    lb = np.array(lb)
    ub = np.array(ub)
    assert np.all(ub>lb), 'All upper-bound values must be greater than lower-bound values'
   
    vhigh = np.abs(ub - lb)
    vlow = -vhigh
    if not ig:
        pass
    else:
        assert len(ig)==swarmsize, 'The size of initial guess list should be the same as number of particles'

    # Check for constraint function(s) #########################################
    obj = lambda x: func(x, *args, **kwargs)
    if f_ieqcons is None:
        if not len(ieqcons):
            if outFile != None:
                print('No constraints given.', file = log)
            if debug:
                print('No constraints given.')
            cons = lambda x: np.array([0])
        else:
            if outFile != None:
                print('Converting ieqcons to a single constraint function', file = log)
            if debug:
                print('Converting ieqcons to a single constraint function')
            cons = lambda x: np.array([y(x, *args, **kwargs) for y in ieqcons])
    else:
        if outFile != None:
            print('Single constraint function given in f_ieqcons', file = log)
        if debug:
            print('Single constraint function given in f_ieqcons')
        cons = lambda x: np.array(f_ieqcons(x, *args, **kwargs))
        
    def is_feasible(x):
        check = np.all(cons(x)>=0)
        return check
        
    # Initialize the particle swarm ############################################
    S = swarmsize
    D = len(lb)  # the number of dimensions each particle has
    x = np.random.rand(S, D)  # particle positions
    v = np.zeros_like(x)  # particle velocities
    p = np.zeros_like(x)  # best particle positions
    fp = np.zeros(S)  # best particle function values
    g = []  # best swarm position
    fg = 1e100  # artificial best swarm position starting value
    for i in range(S):
        # Initialize the particle's position
        try: 
            x[i, :] = ig[i]
        except:
            x[i, :] = lb + x[i, :]*(ub - lb)

        # Initialize the particle's best known position
        p[i, :] = x[i, :]
       
    
    # Calculate the objective's value for all particles
    fp = obj(p[:, :])
    #print("p:", p)
    #print("fp:", fp)
    for i in range(S):

        # At the start, there may not be any feasible starting point, so just
        # give it a temporary "best" point since it's likely to change
        if i==0:
            g = p[0, :].copy()

        # If the current particle's position is better than the swarm's,
        # update the best swarm position
        if fp[i]<fg and is_feasible(p[i, :]):
            fg = fp[i]
            g = p[i, :].copy()
       
        # Initialize the particle's velocity
        v[i, :] = vlow + np.random.rand(D)*(vhigh - vlow)


    # Iterate until termination criterion met ##################################
    it = 1
    while it<=maxiter:
        rp = np.random.uniform(size=(S, D))
        rg = np.random.uniform(size=(S, D))
        
        for i in range(S):

            # Update the particle's velocity
            v[i, :] = omega*v[i, :] + phip*rp[i, :]*(p[i, :] - x[i, :]) + \
                      phig*rg[i, :]*(g - x[i, :])
                      
            # Update the particle's position, correcting lower and upper bound 
            # violations, then update the objective function value
            x[i, :] = x[i, :] + v[i, :]
            mark1 = x[i, :]<lb
            mark2 = x[i, :]>ub
            x[i, mark1] = lb[mark1]
            x[i, mark2] = ub[mark2]

        # Evaluate objective function for all particles
        fx = obj(x[:, :])

        if outFile != None:
            print("", file = log)
            for i in range(S):
                print("Iteration/particle:", it, i, x[i, :], fx[i], file = log)
        if debug:
            print()
            for i in range(S):
                print("Iteration/particle:", it, i, x[i, :], fx[i])

        for i in range(S):
            # Compare particle's best position (if constraints are satisfied)
            if fx[i]<fp[i] and is_feasible(x[i, :]):
                p[i, :] = x[i, :].copy()
                fp[i] = fx[i]

                # Compare swarm's best position to current particle's position
                # (Can only get here if constraints are satisfied)
                if fx[i]<fg:
                    if outFile != None:
                        print('New best for swarm at iteration: {:} {:} {:} {:}'.format(it, i, x[i, :], fx[i]), file = log)                            
                    if debug:
                        print('New best for swarm at iteration: {:} {:} {:} {:}'.format(it, i, x[i, :], fx[i]))

                    tmp = x[i, :].copy()
                    stepsize = np.sqrt(np.sum((g-tmp)**2))
                    if np.abs(fg - fx[i])<=minfunc:
                        if outFile != None:  
                            print('Stopping search: Swarm best objective change less than {:}'.format(minfunc), file = log)
                        if debug:
                            print('Stopping search: Swarm best objective change less than {:}'.format(minfunc))
                        return tmp, fx[i]
                    elif stepsize<=minstep:
                        if outFile != None:  
                            print('Stopping search: Swarm best position change less than {:}'.format(minstep), file = log)
                        if debug:
                            print('Stopping search: Swarm best position change less than {:}'.format(minstep))
                        return tmp, fx[i]
                    else:
                        g = tmp.copy()
                        fg = fx[i]
        if outFile != None:  
            print('Best after iteration: {:} {:} {:}'.format(it, g, fg), file = log)
        if debug:
            print('Best after iteration: {:} {:} {:}'.format(it, g, fg))
        it += 1

    if outFile != None:  
        print('Stopping search: maximum iterations reached --> {:}'.format(maxiter), file = log)
    if debug:
        print('Stopping search: maximum iterations reached --> {:}'.format(maxiter))
    
    if not is_feasible(g) and outFile != None:     
        print("However, the optimization couldn't find a feasible design. Sorry", file = log)
    if not is_feasible(g) and debug:
        print("However, the optimization couldn't find a feasible design. Sorry")
        
    return g, fg

def serial_pso(func, lb, ub, ig=[], ieqcons=[], f_ieqcons=None, args=(), kwargs={}, 
        swarmsize=100, omega=0.5, phip=0.5, phig=0.5, maxiter=100, 
        minstep=1e-8, minfunc=1e-8, debug=False, outFile=None):
    """
    Perform serial particle swarm optimization (PSO)
   
    Parameters
    ==========
    func : function
        The function to be minimized
    lb : array
        The lower bounds of the design variable(s)
    ub : array
        The upper bounds of the design variable(s)
   
    Optional
    ========
    ig : list
        A list of tuples each representing the initial guess for one particle
    ieqcons : list
        A list of functions of length n such that ieqcons[j](x,*args) >= 0.0 in 
        a successfully optimized problem (Default: [])
    f_ieqcons : function
        Returns a 1-D array in which each element must be greater or equal 
        to 0.0 in a successfully optimized problem. If f_ieqcons is specified, 
        ieqcons is ignored (Default: None)
    args : tuple
        Additional arguments passed to objective and constraint functions
        (Default: empty tuple)
    kwargs : dict
        Additional keyword arguments passed to objective and constraint 
        functions (Default: empty dict)
    swarmsize : int
        The number of particles in the swarm (Default: 100)
    omega : scalar
        Particle velocity scaling factor (Default: 0.5)
    phip : scalar
        Scaling factor to search away from the particle's best known position
        (Default: 0.5)
    phig : scalar
        Scaling factor to search away from the swarm's best known position
        (Default: 0.5)
    maxiter : int
        The maximum number of iterations for the swarm to search (Default: 100)
    minstep : scalar
        The minimum stepsize of swarm's best position before the search
        terminates (Default: 1e-8)
    minfunc : scalar
        The minimum change of swarm's best objective value before the search
        terminates (Default: 1e-8)
    debug : boolean
        If True, progress statements will be displayed every iteration
        (Default: False)
   
    Returns
    =======
    g : array
        The swarm's best known position (optimal design)
    f : scalar
        The objective value at ``g``
   
    """

    if outFile != None:
        log = open(outFile, "w", encoding="utf-8")

    assert len(lb)==len(ub), 'Lower- and upper-bounds must be the same length'
    assert hasattr(func, '__call__'), 'Invalid function handle'
    lb = np.array(lb)
    ub = np.array(ub)
    assert np.all(ub>lb), 'All upper-bound values must be greater than lower-bound values'
   
    vhigh = np.abs(ub - lb)
    vlow = -vhigh
    if not ig:
        pass
    else:
        assert len(ig)==swarmsize, 'The size of initial guess list should be the same as number of particles'

    # Check for constraint function(s) #########################################
    obj = lambda x: func(x, *args, **kwargs)
    if f_ieqcons is None:
        if not len(ieqcons):
            if outFile != None:
                print('No constraints given.', file = log)
            if debug:
                print('No constraints given.')
            cons = lambda x: np.array([0])
        else:
            if outFile != None:
                print('Converting ieqcons to a single constraint function', file = log)
            if debug:
                print('Converting ieqcons to a single constraint function')
            cons = lambda x: np.array([y(x, *args, **kwargs) for y in ieqcons])
    else:
        if outFile != None:
            print('Single constraint function given in f_ieqcons', file = log)
        if debug:
            print('Single constraint function given in f_ieqcons')
        cons = lambda x: np.array(f_ieqcons(x, *args, **kwargs))
        
    def is_feasible(x):
        check = np.all(cons(x)>=0)
        return check
        
    # Initialize the particle swarm ############################################
    S = swarmsize
    D = len(lb)  # the number of dimensions each particle has
    x = np.random.rand(S, D)  # particle positions
    v = np.zeros_like(x)  # particle velocities
    p = np.zeros_like(x)  # best particle positions
    fp = np.zeros(S)  # best particle function values
    g = []  # best swarm position
    fg = 1e100  # artificial best swarm position starting value
    for i in range(S):
        # Initialize the particle's position
        try: 
            x[i, :] = ig[i]
        except:
            x[i, :] = lb + x[i, :]*(ub - lb)

        # Initialize the particle's best known position
        p[i, :] = x[i, :]
       
    
        # Calculate the objective's value for all particles
        fp = obj(p[i, :])

        # At the start, there may not be any feasible starting point, so just
        # give it a temporary "best" point since it's likely to change
        if i==0:
            g = p[0, :].copy()

        # If the current particle's position is better than the swarm's,
        # update the best swarm position
        if fp<fg and is_feasible(p[i, :]):
            fg = fp
            g = p[i, :].copy()
       
        # Initialize the particle's velocity
        v[i, :] = vlow + np.random.rand(D)*(vhigh - vlow)


    # Iterate until termination criterion met ##################################
    it = 1
    while it<=maxiter:
        rp = np.random.uniform(size=(S, D))
        rg = np.random.uniform(size=(S, D))
        
        for i in range(S):

            # Update the particle's velocity
            v[i, :] = omega*v[i, :] + phip*rp[i, :]*(p[i, :] - x[i, :]) + \
                      phig*rg[i, :]*(g - x[i, :])
                      
            # Update the particle's position, correcting lower and upper bound 
            # violations, then update the objective function value
            x[i, :] = x[i, :] + v[i, :]
            mark1 = x[i, :]<lb
            mark2 = x[i, :]>ub
            x[i, mark1] = lb[mark1]
            x[i, mark2] = ub[mark2]

            # Evaluate objective function for this particle
            fx = obj(x[i, :])

            if outFile != None:
                print("Iteration/particle:", it, i, x[i, :], fx, file = log)
            if debug:
                print("Iteration/particle:", it, i, x[i, :], fx)

            # Compare particle's best position (if constraints are satisfied)
            if fx<fp and is_feasible(x[i, :]):
                p[i, :] = x[i, :].copy()
                fp = fx

                # Compare swarm's best position to current particle's position
                # (Can only get here if constraints are satisfied)
                if fx<fg:
                    if outFile != None:
                        print('New best for swarm at iteration: {:} {:} {:} {:}'.format(it, i, x[i, :], fx), file = log)                            
                    if debug:
                        print('New best for swarm at iteration: {:} {:} {:} {:}'.format(it, i, x[i, :], fx))

                    tmp = x[i, :].copy()
                    stepsize = np.sqrt(np.sum((g-tmp)**2))
                    if np.abs(fg - fx)<=minfunc:
                        if outFile != None:  
                            print('Stopping search: Swarm best objective change less than {:}'.format(minfunc), file = log)
                        if debug:
                            print('Stopping search: Swarm best objective change less than {:}'.format(minfunc))
                        return tmp, fx
                    elif stepsize<=minstep:
                        if outFile != None:  
                            print('Stopping search: Swarm best position change less than {:}'.format(minstep), file = log)
                        if debug:
                            print('Stopping search: Swarm best position change less than {:}'.format(minstep))
                        return tmp, fx
                    else:
                        g = tmp.copy()
                        fg = fx
        if outFile != None:  
            print('Best after iteration: {:} {:} {:}'.format(it, g, fg), file = log)
            print("", file = log)
        if debug:
            print('Best after iteration: {:} {:} {:}'.format(it, g, fg))
            print()
        it += 1

    if outFile != None:  
        print('Stopping search: maximum iterations reached --> {:}'.format(maxiter), file = log)
    if debug:
        print('Stopping search: maximum iterations reached --> {:}'.format(maxiter))
    
    if not is_feasible(g) and outFile != None:     
        print("However, the optimization couldn't find a feasible design. Sorry", file = log)
    if not is_feasible(g) and debug:
        print("However, the optimization couldn't find a feasible design. Sorry")
        
    return g, fg

def parallel_pso_auxiliary(func, lb, ub, ig=[], ieqcons=[], f_ieqcons=None, args=(), kwargs={}, 
        swarmsize=100, omega=0.5, phip=0.5, phig=0.5, phia=0.5, maxiter=100, 
        minstep=1e-8, minfunc=1e-8, debug=False, outFile=None):
    """
    Perform syncronous parallel particle swarm optimization (PSO)
   
    Parameters
    ==========
    func : function
        The function to be minimized
    lb : array
        The lower bounds of the design variable(s)
    ub : array
        The upper bounds of the design variable(s)
   
    Optional
    ========
    ig : list
        A list of tuples each representing the initial guess for one particle
    ieqcons : list
        A list of functions of length n such that ieqcons[j](x,*args) >= 0.0 in 
        a successfully optimized problem (Default: [])
    f_ieqcons : function
        Returns a 1-D array in which each element must be greater or equal 
        to 0.0 in a successfully optimized problem. If f_ieqcons is specified, 
        ieqcons is ignored (Default: None)
    args : tuple
        Additional arguments passed to objective and constraint functions
        (Default: empty tuple)
    kwargs : dict
        Additional keyword arguments passed to objective and constraint 
        functions (Default: empty dict)
    swarmsize : int
        The number of particles in the swarm (Default: 100)
    omega : scalar
        Particle velocity scaling factor (Default: 0.5)
    phip : scalar
        Scaling factor to search away from the particle's best known position
        (Default: 0.5)
    phig : scalar
        Scaling factor to search away from the swarm's best known position
        (Default: 0.5)
    phia : scalar
        Scaling factor to search away from the particle's best known auxiliary position
        (Default: 0.5)        
    maxiter : int
        The maximum number of iterations for the swarm to search (Default: 100)
    minstep : scalar
        The minimum stepsize of swarm's best position before the search
        terminates (Default: 1e-8)
    minfunc : scalar
        The minimum change of swarm's best objective value before the search
        terminates (Default: 1e-8)
    debug : boolean
        If True, progress statements will be displayed every iteration
        (Default: False)
   
    Returns
    =======
    g : array
        The swarm's best known position (optimal design)
    f : scalar
        The objective value at ``g``
   
    """

    if outFile != None:
        log = open(outFile, "w", encoding="utf-8")

    assert len(lb)==len(ub), 'Lower- and upper-bounds must be the same length'
    assert hasattr(func, '__call__'), 'Invalid function handle'
    lb = np.array(lb)
    ub = np.array(ub)
    assert np.all(ub>lb), 'All upper-bound values must be greater than lower-bound values'
   
    vhigh = np.abs(ub - lb)
    vlow = -vhigh
    if not ig:
        pass
    else:
        assert len(ig)==swarmsize, 'The size of initial guess list should be the same as number of particles'

    # Check for constraint function(s) #########################################
    obj = lambda x: func(x, *args, **kwargs)
    if f_ieqcons is None:
        if not len(ieqcons):
            if outFile != None:
                print('No constraints given.', file = log)
            if debug:
                print('No constraints given.')
            cons = lambda x: np.array([0])
        else:
            if outFile != None:
                print('Converting ieqcons to a single constraint function', file = log)
            if debug:
                print('Converting ieqcons to a single constraint function')
            cons = lambda x: np.array([y(x, *args, **kwargs) for y in ieqcons])
    else:
        if outFile != None:
            print('Single constraint function given in f_ieqcons', file = log)
        if debug:
            print('Single constraint function given in f_ieqcons')
        cons = lambda x: np.array(f_ieqcons(x, *args, **kwargs))
        
    def is_feasible(x):
        check = np.all(cons(x)>=0)
        return check
        
    # Initialize the particle swarm ############################################
    S = swarmsize
    D = len(lb)  # the number of dimensions each particle has
    x = np.random.rand(S, D)  # particle positions
    v = np.zeros_like(x)  # particle velocities
    p = np.zeros_like(x)  # best particle positions
    fp = np.zeros(S)  # best particle function values
    g = []  # best swarm position
    fg = 1e100  # artificial best swarm position starting value
    for i in range(S):
        # Initialize the particle's position
        try: 
            x[i, :] = ig[i]
        except:
            x[i, :] = lb + x[i, :]*(ub - lb)

        # Initialize the particle's best known position
        p[i, :] = x[i, :]
       
    
    # Calculate the objective's value for all particles
    fp, a = obj(p[:, :])
    #print("p:", p)
    #print("fp:", fp)
    for i in range(S):

        # At the start, there may not be any feasible starting point, so just
        # give it a temporary "best" point since it's likely to change
        if i==0:
            g = p[0, :].copy()

        # If the current particle's position is better than the swarm's,
        # update the best swarm position
        if fp[i]<fg and is_feasible(p[i, :]):
            fg = fp[i]
            g = p[i, :].copy()
       
        # Initialize the particle's velocity
        v[i, :] = vlow + np.random.rand(D)*(vhigh - vlow)


    # Iterate until termination criterion met ##################################
    it = 1
    while it<=maxiter:
        rp = np.random.uniform(size=(S, D))
        rg = np.random.uniform(size=(S, D))
        rx = np.random.uniform(size=(S, D))

        for i in range(S):

            # Update the particle's velocity
            v[i, :] = omega*v[i, :] + phip*rp[i, :]*(p[i, :] - x[i, :]) + \
                      phig*rg[i, :]*(g - x[i, :]) + phia*rx[i, :]*(a[i, :] - x[i, :])
                      
            # Update the particle's position, correcting lower and upper bound 
            # violations, then update the objective function value
            x[i, :] = x[i, :] + v[i, :]
            mark1 = x[i, :]<lb
            mark2 = x[i, :]>ub
            x[i, mark1] = lb[mark1]
            x[i, mark2] = ub[mark2]

        # Evaluate objective function for all particles
        fx, a = obj(x[:, :])

        if outFile != None:
            print("", file = log)
            for i in range(S):
                print("Iteration/particle:", it, i, x[i, :], fx[i], file = log)
        if debug:
            print()
            for i in range(S):
                print("Iteration/particle:", it, i, x[i, :], fx[i])

        for i in range(S):
            # Compare particle's best position (if constraints are satisfied)
            if fx[i]<fp[i] and is_feasible(x[i, :]):
                p[i, :] = x[i, :].copy()
                fp[i] = fx[i]

                # Compare swarm's best position to current particle's position
                # (Can only get here if constraints are satisfied)
                if fx[i]<fg:
                    if outFile != None:
                        print('New best for swarm at iteration: {:} {:} {:} {:}'.format(it, i, x[i, :], fx[i]), file = log)                            
                    if debug:
                        print('New best for swarm at iteration: {:} {:} {:} {:}'.format(it, i, x[i, :], fx[i]))

                    tmp = x[i, :].copy()
                    stepsize = np.sqrt(np.sum((g-tmp)**2))
                    if np.abs(fg - fx[i])<=minfunc:
                        if outFile != None:  
                            print('Stopping search: Swarm best objective change less than {:}'.format(minfunc), file = log)
                        if debug:
                            print('Stopping search: Swarm best objective change less than {:}'.format(minfunc))
                        return tmp, fx[i]
                    elif stepsize<=minstep:
                        if outFile != None:  
                            print('Stopping search: Swarm best position change less than {:}'.format(minstep), file = log)
                        if debug:
                            print('Stopping search: Swarm best position change less than {:}'.format(minstep))
                        return tmp, fx[i]
                    else:
                        g = tmp.copy()
                        fg = fx[i]
        if outFile != None:  
            print('Best after iteration: {:} {:} {:}'.format(it, g, fg), file = log)
        if debug:
            print('Best after iteration: {:} {:} {:}'.format(it, g, fg))
        it += 1

    if outFile != None:  
        print('Stopping search: maximum iterations reached --> {:}'.format(maxiter), file = log)
    if debug:
        print('Stopping search: maximum iterations reached --> {:}'.format(maxiter))
    
    if not is_feasible(g) and outFile != None:     
        print("However, the optimization couldn't find a feasible design. Sorry", file = log)
    if not is_feasible(g) and debug:
        print("However, the optimization couldn't find a feasible design. Sorry")
        
    return g, fg
