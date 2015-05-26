import numpy as np
import h5py
import matplotlib.pyplot as plt

a = h5py.File('dump_prism.h5', 'r')

obstacle = a['/particles/obstacle/position'][:]
pos = a['/particles/colloids/position/value']

ax1 = plt.subplot(211)
plt.plot(pos[:,0,:])
ax2 = plt.subplot(212, sharex=ax1)
plt.plot(pos[:,:,2])

a.close()

plt.show()
