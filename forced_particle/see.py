import numpy as np
import h5py
import mayavi.mlab as mlab

a = h5py.File('dump_prism.h5', 'r')

obstacle = a['/particles/obstacle/position'][:]
pos = a['/particles/colloids/position/value']

x = pos[0,:,0]
y = pos[0,:,1]
z = pos[0,:,2]

a.close()

mlab.points3d(obstacle[:,0], obstacle[:,1], obstacle[:,2], scale_factor=2, color=(1, 0, 0))
mlab.points3d(x,y,z, scale_factor=2, color=(0, 0, 1))

mlab.show()
