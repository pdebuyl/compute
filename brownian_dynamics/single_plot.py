import h5py
import numpy as np
import matplotlib.pyplot as plt

import argparse

parser = argparse.ArgumentParser()
parser.add_argument('ID', type=str, help='ID for simulation filename')
parser.add_argument('--out', type=str, help='output')
args = parser.parse_args()

NSKIP = 0
STRIDE = 10
QUIV_STR = 10000
a = h5py.File('trajectory_%s.h5' % args.ID, 'r')

plt.rcParams['figure.figsize'] = (10, 7.5)

f1 = plt.figure()

X = a['X'][NSKIP::STRIDE]
X_sq = X**2
X_sqrt = np.sqrt(np.sum(X_sq, axis=1))
ax = f1.add_subplot(221)
plt.hist(X_sqrt, bins=64, normed=True, weights=1/X_sqrt, range=[0, 30])
plt.xlabel(r'probe - $r = \sqrt{x^2+y^2}$')
plt.ylabel(r'probe - $P(r)$')

X = a['X'][NSKIP::STRIDE]
ax = f1.add_subplot(222)
plt.hist2d(X[NSKIP::STRIDE,0], X[NSKIP::STRIDE,1], bins=32, cmap=plt.cm.gnuplot);
plt.xlabel(r'probe - $x$')
plt.ylabel(r'probe - $y$')

ax = f1.add_subplot(223)
x = a['x'][NSKIP::STRIDE].reshape((-1,2))
x_sqrt = np.sqrt(np.sum(x**2, axis=1))
plt.hist(x_sqrt, bins=64, normed=True, weights=1/x_sqrt)
plt.xlabel(r'bath - $r = \sqrt{x^2+y^2}$')
plt.ylabel(r'bath - $P(r)$')

ax = f1.add_subplot(224, frame_on=False)
ax.axes.get_xaxis().set_visible(False)
ax.axes.get_yaxis().set_visible(False)

plt.text(0.1, 0.9, 'Simulation parameters for\ntrajectory_%s.h5' % args.ID)
d = {'a': r'$\alpha$', 'g': r'$\gamma$', 'l': r'$\lambda$', 'N': r'$N$', 'D': r'$D_{\bath}$', 'D_tracer': r'$D_{probe}$'}
for i, k in enumerate(['a', 'g', 'l', 'N', 'D_tracer']):
    plt.text(0.1, 0.75-0.1*i,d[k] + ' = ' + str(a.attrs[k])) 

a.close()

if args.out:
    plt.savefig(args.out)
else:
    plt.show()
