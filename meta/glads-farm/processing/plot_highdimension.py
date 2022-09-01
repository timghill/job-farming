import netCDF4 as nc
import numpy as np
from matplotlib import pyplot as plt
from matplotlib import tri
from mpl_toolkits.axes_grid1.axes_divider import make_axes_locatable

import cmocean

fig, axs = plt.subplots(nrows=5, ncols=7)
axs = axs.flatten()

ensemble_press = np.zeros((866, 35))

paras = np.loadtxt('../glads_para_gamma_kc.txt')

for i in range(9):

    glads_fname = '../RUN/output_%03d.nc' % (i+1)
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
    ensemble_press[:, i] = press_norm

    # Translate MATLAB's 1-indexing to Python's 0-indexing
    connect = (connect-1).astype(int)

    # Make a MATLAB Triangulation object
    mtri = tri.Triangulation(nodes[:, 0]/1e3, nodes[:, 1]/1e3, connect)


mean_press = np.mean(ensemble_press, axis=1)
for i in range(35):
    ax = axs[i]
    trip = ax.tripcolor(mtri, ensemble_press[:, i] - mean_press, vmin=-0.2, vmax=0.2, cmap=cmocean.cm.balance)
    ax.set_xlim([0, 100])
    ax.set_ylim([0, 25])
    ax.set_adjustable('box')
    ax.set_aspect('equal')

    # Labels, units
    ax.set_xlabel('X (km)')
    ax.set_ylabel('Y (km)')

    ax.set_title('$\gamma = %.1f$, $k_c = %.2f$' % (paras[i, 0], paras[i, 1]))

    ax.xaxis.set_visible(False)
    ax.yaxis.set_visible(False)

    # trip = ax.tripcolor(mtri, N[:, -1]/1e6, vmin=0, vmax=3, cmap=cmocean.cm.speed)

    # # Colorbar with nicely located cax
    # ax1_divider = make_axes_locatable(ax)
    # cax = ax1_divider.append_axes("right", size="5%", pad="2%")
    # cb = fig.colorbar(trip, label='N (MPa)', cax=cax, ticks=[0, 1, 2, 3])
    #
    #
    # qxy = glads_output['qs'][-1, :, :].T
    #
    # trip2 = ax2.tripcolor(mtri, qxy[:, 1], cmap=cmocean.cm.delta, vmin=-5e-4, vmax=5e-4)
    # # trip2 = ax2.tripcolor(nodes[:, 0]/1e3, nodes[:, 1]/1e3, qxy[:, 1])
    #
    # ax2.set_xlim([0, 100])
    # ax2.set_ylim([0, 25])
    # ax2.set_aspect('equal')
    #
    # ax2_divider = make_axes_locatable(ax2)
    # cax2 = ax2_divider.append_axes('right', size='5%', pad='2%')
    # cb2 = fig.colorbar(trip2, cax=cax2, label='q_y')

    # plt.savefig('myfig.png', dpi=600)
plt.tight_layout()
fig.savefig('highdimension_ensemble.png', dpi=600)
