from __future__ import division, print_function
import numpy as np
import h5py
import matplotlib.pyplot as plt
import matplotlib.animation as animation

import sys

fig = plt.figure()
ax = plt.subplot(111, aspect='equal')


Lx = 9.5
Ly = 10

Nx = 8
X_scale = Lx/(Nx)

data = np.zeros((3*Nx, 2))

data[:Nx, 0] = np.arange(Nx)*X_scale
data[:Nx, 1] = 5

data[Nx:2*Nx, 0] = np.arange(Nx)*X_scale + 0.7
data[Nx:2*Nx, 1] = 5.9

data[2*Nx:, 0] = np.arange(Nx)*X_scale + 0.
data[2*Nx:, 1] = 6.8

lammps_data = []
j=1
for i, xy in enumerate(data):
    if i in [4, 1100, 12, 1900, 2000, 21]:
        continue
    lammps_data.append((j, 2, xy[0], xy[1],0))
    j+=1
    art = plt.Circle(xy, 0.5)
    ax.add_artist(art)

lammps_data = np.array(lammps_data)

ax.set_xlim(0, Lx)
ax.set_ylim(0, Ly)

with open('data.obstacle2d', 'w') as f:
    print('Data for an obstacle in 2D', file=f)
    print('%i atoms' % len(lammps_data), file=f)
    print('2 atom types', file=f)
    print("""%f %f xlo xhi
%f %f ylo yhi
-0.1 0.1 zlo zhi""" % (0, Lx, 0, Ly), file=f)
    print('''
Atoms
''', file=f)
    np.savetxt(f, lammps_data, fmt='%i %i %f %f %f')
    print('', file=f)

if len(sys.argv)==1:
    plt.show()

