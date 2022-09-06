"""
Experimental design for GlaDS ensemble simulations
"""

import numpy as np
import pyDOE

# PARAMETERS
N = 11          # Number of samples
iters = 1000    # Number of iterations in LHS optimization

X = pyDOE.lhs(1, samples=N, criterion='cm', iterations=iters)

_gamma_bounds = [0, 1]

def scale_column(z, bounds):
    z_scale = bounds[0] + z*(bounds[1] - bounds[0])
    return z_scale

X_scale = np.zeros(X.shape)
X_scale[:, 0] = scale_column(X[:, 0], _gamma_bounds)

fname = 'para.txt'
np.savetxt(fname, X_scale)

print('Save exp design to file "%s"' % fname)
print(np.max(X_scale, axis=0))
print(np.min(X_scale, axis=0))
