import numpy as np
import h5py
import matplotlib.pyplot as plt
import matplotlib.animation as animation

import sys

a = h5py.File(sys.argv[1], 'r')
x = a['x']
X = a['X']

SLICE=100

fig = plt.figure(figsize=(6,6))
ax = plt.subplot(111, aspect='equal')

artists = []
def init():
    art = plt.Circle(X[SLICE], 0.5, color='g')
    artists.append(art)
    ax.add_artist(art)
    art, = plt.plot(X[:SLICE, 0], X[:SLICE, 1], 'k-')
    artists.append(art)
    ax.add_artist(art)
    count, x_e, y_e, art = plt.hist2d(x[:SLICE,:,0].reshape((-1,)), x[:SLICE,:,1].reshape((-1,)), range=[[-5, 5], [-5, 5]], bins=32)
    artists.append(art)
    ax.add_artist(art)
    art = plt.Circle(x[SLICE,:,:].mean(axis=0), 0.2, color='r')
    artists.append(art)
    ax.add_artist(art)
    plt.axhline(0, color='k')
    plt.axvline(0, color='k')
    plt.xlabel(r'$x$')
    plt.ylabel(r'$y$')
    return artists

def animate(i):
    artists[0].center = X[SLICE*i]
    artists[1].set_data(X[SLICE*i:SLICE*(i+1), 0], X[SLICE*i:SLICE*(i+1), 1])
    count, x_e, y_e = np.histogram2d(x[SLICE*i:SLICE*(i+1),:,0].reshape((-1,)), x[SLICE*i:SLICE*(i+1),:,1].reshape((-1,)), range=[[-5,5], [-5, 5]], bins=32)
    artists[2].set_data(count)
    artists[3].center = x[SLICE*i].mean(axis=0)
    return artists

ani = animation.FuncAnimation(fig, animate, np.arange(1, 100),
    interval=500, blit=False, init_func=init)

#ani.save('bath_and_probe.mp4', dpi=100)

plt.show()
a.close()
