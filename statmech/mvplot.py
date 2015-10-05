import numpy as np
from mayavi import mlab 

X = np.linspace(-1, 1.5, 21)
Y = np.linspace(-1, 1.5, 21)
X, Y = np.meshgrid(X, Y)
X = X.T ; Y = Y.T

def f(x, y):
    return (x + y)**2 /2 
Z = f(X,Y)

mlab.surf(X, Y, Z)


q = np.linspace(0, 1, 21)
p = 1 - q
z = f(p, q)

mlab.plot3d(p, q, z)

z = 0*z

mlab.plot3d(p, q, z)


refpoint = (0.3, 0.7, f(0.3, 0.7))
mlab.points3d(*zip(refpoint),scale_mode='none', scale_factor=0.2)

q = np.linspace(-0.5, 1.5, 11)
p = q * 0 + refpoint[0]
z = f(p, q)
mlab.plot3d(p, q, z)

p = np.linspace(-0.5, 1.5, 11)
q = p * 0 + refpoint[1]
z = f(p, q)
mlab.plot3d(p, q, z)

mlab.axes(extent=[-1,1.5,-1,1.5,0,3],ranges=[-1, 1.5, -1, 1.5, 0, 3])
mlab.outline(extent=[-1,1.5,-1,1.5,0,3])
mlab.orientation_axes()
mlab.show()


