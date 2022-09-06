import netCDF4 as nc
import numpy as np
from matplotlib import pyplot as plt
from matplotlib import tri
from mpl_toolkits.axes_grid1.axes_divider import make_axes_locatable

import cmocean

fig, (ax1, ax2) = plt.subplots(figsize=(8, 4), ncols=2)

gamma_press = np.zeros((866, 11))

paras = np.loadtxt('./mixing/para.txt')


for i in range(paras.shape[0]):

    glads_fname = './mixing/RUN/output_%03d.nc' % (i+1)
    glads_output = nc.Dataset(glads_fname, 'r')

    # Read variables, transpose to make column vectors
    connect = glads_output['connect'][:].T
    nodes = glads_output['nodes'][:].T
    N = glads_output['N'][:].T
    phi = glads_output['phi'][:].T


    bed = glads_output['bed'][:].T
    thick = glads_output['thick'][:].T

    phi_bed = 9.81*1000*bed;
    phi_w = phi[:, -1] - phi_bed;

    overburden = 9.81*910*thick;

    press_norm = phi_w/overburden
    gamma_press[:, i] = press_norm

exp_press = np.zeros((866, 11))
exp_paras = np.loadtxt('./no-mixing/para.txt')
for j in range(exp_paras.shape[0]):
    glads_fname = './no-mixing/RUN/output_%03d.nc' % (j+1)
    glads_output = nc.Dataset(glads_fname, 'r')
    N = glads_output['N'][:].T
    phi = glads_output['phi'][:].T


    bed = glads_output['bed'][:].T
    thick = glads_output['thick'][:].T

    phi_bed = 9.81*1000*bed
    phi_w = phi[:, -1] - phi_bed

    overburden = 9.81*910*thick

    press_norm = phi_w/overburden
    exp_press[:, j] = press_norm


for i in range(11):
    map1 = ax1.scatter(nodes[:, 0]/1e3, gamma_press[:, i], c=paras[i]*np.ones(gamma_press[:, i].shape), vmin=0, vmax=1, cmap=cmocean.cm.dense)
    map2 = ax2.scatter(nodes[:, 0]/1e3, exp_press[:, i], c=exp_paras[i, 1]*np.ones(exp_press[:, i].shape), vmin=1.5, vmax=2, cmap=cmocean.cm.dense)

fig.colorbar(map1, ax=ax1)
fig.colorbar(map2, ax=ax2)
    
ax1.set_xlim([0, 100])
ax2.set_xlim([0, 100])

ax1.set_title

ax1.set_ylim([0, 1.2])
ax2.set_ylim([0, 1.2])
fig.savefig('formulations.png', dpi=600)
