from mayavi import mlab
import numpy as np
import h5py
import argparse

parser = argparse.ArgumentParser()
parser.add_argument('file', type=str, help='H5MD datafile')
parser.add_argument('--sigma', type=float, default=3)
args = parser.parse_args()

with h5py.File(args.file, 'r') as f:
    r = f['particles/janus/position'][:]
    s = f['particles/janus/species'][:]

mlab.points3d(r[:,0], r[:,1], r[:,2], -s, scale_mode='none', scale_factor=2*args.sigma)

mlab.show()
