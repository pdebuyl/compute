import numpy as np
import h5py
import argparse

parser = argparse.ArgumentParser()
parser.add_argument('file', type=str, help='H5MD datafile')
parser.add_argument('--sigma', type=float, default=3)
parser.add_argument('--group', type=str, default='janus')
parser.add_argument('--type', type=str, choices=['2D', '3D'])
args = parser.parse_args()

with h5py.File(args.file, 'r') as f:
    pgroup = f['particles'][args.group]
    r = pgroup['position'][:]
    s = pgroup['species'][:]
    edges = pgroup['box/edges'][:]

if args.type=='2D':
    import matplotlib.pyplot as plt
    plt.subplot(111, aspect=1)
    plt.plot(r[:,0], r[:,2], ls='', marker='o')
    plt.show()

elif args.type=='3D':
    from mayavi import mlab

    mlab.figure(bgcolor=(1, 1, 1), fgcolor=(0, 0, 0))
    mlab.points3d(r[:,0], r[:,1], r[:,2], -s, scale_mode='none',
              scale_factor=2*args.sigma, resolution=32)
    mlab.axes(extent=[0, edges[0], 0, edges[1], 0, edges[2]])
    mlab.view(azimuth=270, elevation=90)
    mlab.show()
