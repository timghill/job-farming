"""
Compute aggregate quantities from high-dimensional GlaDS outputs
"""

import numpy as np
import netCDF4 as nc

from matplotlib import pyplot as plt

model_dir = '../RUN/'
model_pattern = model_dir + 'output_%03d.nc'
para_file = '../glads_para_gamma_kc.txt'
para = np.loadtxt(para_file)
n_para = para.shape[0]

mean_press = np.zeros(n_para)
max_press = np.zeros(n_para)

for i in range(n_para):
    model_output = nc.Dataset(model_pattern % (i+1))
    N = model_output['N'][:].T
    phi = model_output['phi'][:].T

    bed = model_output['bed'][:].T
    thick = model_output['thick'][:].T

    phi_bed = 9.81*1000*bed
    phi_water = phi[:, -1] - phi_bed
    overburden = 9.81*910*thick

    press_norm = phi_water/overburden

    mean_press[i] = press_norm.mean()
    max_press[i] = press_norm.max()


aggregate_outputs = np.zeros((n_para, 2))
aggregate_outputs[:, 0] = mean_press
aggregate_outputs[:, 1] = max_press

np.savetxt('aggregate_outputs.txt', aggregate_outputs)

