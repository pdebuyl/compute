import numpy as np
from numpy import pi
import matplotlib.pyplot as plt
import matplotlib.animation as animation

plt.rcParams['font.size'] = 18
plt.rcParams['axes.labelsize'] = 'large'
plt.rcParams['figure.subplot.left'] = 0.15
plt.rcParams['figure.subplot.bottom'] = 0.15

N = 32

angles = np.random.random_sample(N)*2*pi

f = plt.figure()
plt.grid()
plt.xlabel(r'$x$')
plt.ylabel(r'$y$')

def x_y_from_angles(angles):
    bonds = np.zeros((N,2))
    bonds[:,0] = np.cos(angles)
    bonds[:,1] = np.sin(angles)
    x = np.concatenate(((0,),np.cumsum(np.cos(angles))))
    x -= x.mean()
    y = np.concatenate(((0,),np.cumsum(np.sin(angles))))
    y -= y.mean()
    return x,y

artists = []

def init():
    l, = plt.plot(*x_y_from_angles(angles),marker='o',markersize=20)
    artists.append(l)
    plt.xlim(-5,5); plt.ylim(-5,5);
    return artists

def anim_f(i):
    global angles
    angles = angles + np.random.normal(0, 0.1, N)
    artists[0].set_data(*x_y_from_angles(angles))
    return artists

ani = animation.FuncAnimation(f, anim_f, frames=10, init_func=init, interval=200)

plt.show()
