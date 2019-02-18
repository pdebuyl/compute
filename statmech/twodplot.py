import numpy as np
import matplotlib.pyplot as plt
from mpl_toolkits.mplot3d import Axes3D

fig = plt.figure()
ax = Axes3D(fig)
X = np.linspace(-0.5, 1.5, 8)
Y = np.linspace(-0.5, 1.5, 8)
X, Y = np.meshgrid(X, Y)

def f(x, y):
    return (x + y)**2 /2 
Z = f(X,Y)

ax.plot_wireframe(X, Y, Z)

q = np.linspace(0, 1, 21)
p = 1 - q
z = f(p, q)

ax.plot(p, q, z)

z = 0*z

ax.plot(p, q, z)

refpoint = (0.3, 0.7, f(0.3, 0.7))
ax.scatter(*zip(refpoint), s=50)

q = np.linspace(-0.5, 1.5, 11)
p = q * 0 + refpoint[0]
z = f(p, q)
ax.plot(p, q, z)

p = np.linspace(-0.5, 1.5, 11)
q = p * 0 + refpoint[1]
z = f(p, q)
ax.plot(p, q, z)

plt.show()
