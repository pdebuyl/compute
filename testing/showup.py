from __future__ import print_function, division                                                                                                                           
import matplotlib.pyplot as plt
import numpy as np
from mpl_toolkits.mplot3d import Axes3D                                                                                                                                   
import sys

data = np.loadtxt(sys.argv[1])

fig = plt.figure()
ax = fig.add_subplot(111, projection='3d')

ax.plot(*zip(*data[:,1:]))
for i, x, y, z in data:
    ax.text(x, y, z, str(int(i)))

plt.show()
