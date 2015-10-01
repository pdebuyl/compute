import numpy as np
import h5py
import matplotlib.pyplot as plt

a = h5py.File('dump_prism.h5', 'r')

obstacle = a['/particles/obstacle/position'][:]
pos = a['/particles/colloids/position/value']

d = obstacle.shape[1]

plt.figure()

ax1 = plt.subplot(311)
plt.plot(pos[:,0,0])

ax2 = plt.subplot(312, sharex=ax1)
plt.plot(pos[:,0,-1])

ax3 = plt.subplot(313, sharex=ax1)

plt.plot(pos[:,:,-1])

a.close()

plt.show()
