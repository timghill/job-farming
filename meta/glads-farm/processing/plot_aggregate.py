import numpy as np
from matplotlib import pyplot as plt

para_file = '../glads_para_gamma_kc.txt'
para = np.loadtxt(para_file)
n_para = para.shape[0]

agg_outputs = np.loadtxt('aggregate_outputs.txt')


fig, (ax1, ax2) = plt.subplots(ncols=2)

ax1.scatter(para[:, 0], agg_outputs[:, 0])
ax1.scatter(para[:, 0], agg_outputs[:, 1])
ax1.set_xlabel('$\Gamma$')
ax1.set_ylabel('Pressure (-)')
ax1.grid()

ax2.scatter(para[:, 1], agg_outputs[:, 0])
ax2.scatter(para[:, 1], agg_outputs[:, 1])
ax2.set_xlabel('$k_c$')
ax2.grid()

fig.savefig('aggregate.png', dpi=600)
plt.show()
