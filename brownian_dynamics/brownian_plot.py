from __future__ import division
import h5py
import numpy as np
import matplotlib.pyplot as plt

import argparse

parser = argparse.ArgumentParser()
parser.add_argument('ID', type=str, help='ID for filename output', nargs='+')
parser.add_argument('--tracer-Pxy', action='store_true')
parser.add_argument('--bath-Pxy', action='store_true')
parser.add_argument('--bath-Pr', action='store_true')
parser.add_argument('--tracer-field', action='store_true')
parser.add_argument('--force', action='store_true')
args = parser.parse_args()

NSKIP=0
STRIDE=1
QUIV_STR=10

aa = []
for ID in args.ID:
    aa.append(h5py.File('trajectory_%s.h5' % ID, 'r'))

f1 = plt.figure()

N_runs = min(len(args.ID), 4)

def radial_hist(data, nbins, nsteps=1):
    count, bins = np.histogram(data, bins=nbins)
    mid_bins = (bins[1:] + bins[:-1]) / 2.
    dr = bins[1]-bins[0]
    count = np.array(count, dtype=float)
    count /= 2*np.pi*mid_bins*nsteps*dr
    return count, bins

def plot_radial_hist(count, bins):
    plt.bar(bins[:-1], count, width=np.diff(bins))


for i, a in enumerate(aa[:N_runs]):
    X = a['X'][NSKIP::STRIDE]
    X_sqrt = np.sqrt(np.sum(X**2, axis=1))
    ax = f1.add_subplot(2, 2, i+1)
    count, bins = radial_hist(X_sqrt, nbins=64, nsteps=a['X'].shape[0])
    plot_radial_hist(count, bins)
    if i>1: plt.xlabel(r'probe - $r = \sqrt{x^2+y^2}$')
    if i%2==0: plt.ylabel(r'probe - $P(r)$')

if args.tracer_Pxy:
    f2 = plt.figure()
    for i, a in enumerate(aa[:N_runs]):
        X = a['X'][NSKIP::STRIDE]
        ax = f2.add_subplot(2, 2, i+1)
        plt.hist2d(X[NSKIP::STRIDE,0], X[NSKIP::STRIDE,1], bins=32);
        if i>1: plt.xlabel(r'probe - $x$')
        if i%2==0: plt.ylabel(r'probe - $y$')

if args.tracer_field:
    f3 = plt.figure()

    for i, a in enumerate(aa[:N_runs]):
        X = a['X'][NSKIP::STRIDE*QUIV_STR]
        x = a['x'][NSKIP::STRIDE*QUIV_STR]
        ax = f3.add_subplot(2, 2, i+1)
        force_on_X = 0.5 * np.mean(x - (X.reshape((X.shape[0], 1, X.shape[1]))), axis=1)
        plt.quiver(X[:,0], X[:,1], force_on_X[:,0], force_on_X[:,1])
        if i>1: plt.xlabel(r'probe - $x$')
        if i%2==0: plt.ylabel(r'probe - $y$')

if args.bath_Pxy:
    f4 = plt.figure()
    for i, a in enumerate(aa[:N_runs]):
        x = a['x'][NSKIP::STRIDE]
        ax = f4.add_subplot(2, 2, i+1)
        plt.hist2d(x[:,:,0].reshape((-1,)), x[:,:,1].reshape((-1,)), bins=64);
        if i>1: plt.xlabel(r'bath - $x$')
        if i%2==0: plt.ylabel(r'bath - $y$')

if args.bath_Pr:
    f5 = plt.figure()
    for i, a in enumerate(aa[:N_runs]):
        x = a['x'][NSKIP::STRIDE].reshape((-1,2))
        x = np.sqrt(np.sum(x**2, axis=1))
        ax = f5.add_subplot(2, 2, i+1)
        count, bins = radial_hist(x, nbins=64, nsteps=a['x'].shape[0])
        plot_radial_hist(count, bins)
        if i>1: plt.xlabel(r'bath - $r = \sqrt{x^2+y^2}$')
        if i%2==0: plt.ylabel(r'bath - $P(r)$')

if False:
    f6 = plt.figure()
    for i, a in enumerate(aa[:N_runs]):
        ax = f5.add_subplot(2, 2, i+1)
        x = a['x'][NSKIP::STRIDE].reshape((-1,2))
        x_sqrt = np.sqrt(np.sum(x**2, axis=1))
        plt.hist(x_sqrt, bins=64, normed=True, weights=1/x_sqrt)
        if i>1: plt.xlabel(r'bath - $r = \sqrt{x^2+y^2}$')
        if i%2==0: plt.ylabel(r'bath - $P(r)$')

if args.force:
    f7 = plt.figure()
    for i, a in enumerate(aa[:N_runs]):
        force = a['force'][:]
        force_count = a['force_count'][:]
        force[force_count > 0] /= force_count[force_count > 0]
        r = a.attrs['probe_wall_s'][()] * (np.arange(force.shape[0])+0.5) / force.shape[0]
        ax = f7.add_subplot(2, 2, i+1)
        plt.plot(r, force)
        if i>1: plt.xlabel(r'probe - $r = \sqrt{x^2+y^2}$')
        if i%2==0: plt.ylabel(r'probe - $f_r$')

for a in aa: a.close()

plt.show()
