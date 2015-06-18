from __future__ import print_function, division                                                                                                                           
import matplotlib.pyplot as plt
import numpy as np
from mpl_toolkits.mplot3d import Axes3D                                                                                                                                   

i, x, y, z = np.loadtxt('i_p.txt', unpack=True)

fig = plt.figure()
ax = fig.add_subplot(111, projection='3d')

ax.plot(x, y, z)

plt.show()
