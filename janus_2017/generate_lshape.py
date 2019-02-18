#!/usr/bin/env python3
"""
Generate the coordinates for an assembly of beads forming a L shape. The body is aligned
to its principal axes and the bottom row of beads has species 1 while the rest has species
2.
"""
from __future__ import print_function, division
import numpy as np
import argparse

parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('--step', type=float, default=1.5,
                    help='spacing between beads')
parser.add_argument('--sigma', type=float, default=1.,
                    help='radius of the beads')
parser.add_argument('--nx', type=int, default=4,
                    help='number of beads along the bottom of the L')
parser.add_argument('--ny', type=int, default=7,
                    help='number of beads along the long arm of the L')
parser.add_argument('--n-tiles', type=int, default=2,
                    help='number of tiles for the thickness of the bottom arm')
parser.add_argument('--arm-width', type=int, default=2,
                    help='width of long arm')
parser.add_argument('--thickness', type=int, default=2,
                    help='thickness of the colloid')
parser.add_argument('--out', help='H5MD output filename')
args = parser.parse_args()

assert args.ny>args.nx

n_links_x = args.nx-1
n_links_y = args.ny-1

x = np.linspace(0, n_links_x*args.step, n_links_x+1)
xl = args.n_tiles*list(x) + (n_links_y+1-args.n_tiles)*list(x[:args.arm_width])
planar_count = len(xl)
xl = args.thickness*xl
print('planar_count', planar_count)

zl = []
for i in range(n_links_y+1):
    if i < args.n_tiles:
        zl += (n_links_x+1)*[i*args.step]
    else:
        zl += args.arm_width*[i*args.step]

zl = args.thickness*zl

yl = np.arange(args.thickness)[:,None] * np.ones(planar_count)*args.step
yl = yl.reshape((-1,))

r = np.zeros((len(xl), 3))

r[:,0] = xl
r[:,1] = zl
r[:,2] = yl

s = np.ones(len(xl), dtype=int)*2
s[r[:,1]<args.step] = 1

if __name__ == '__main__':

    from mayavi import mlab
    import colloids_to_janus
    mlab.figure(bgcolor=(1, 1, 1))

    r -= r.mean(axis=0)
    colloids_to_janus.align_axis(r, 0)
    mlab.points3d(*r.T, 1-s, scale_factor=2*args.sigma, scale_mode='none', resolution=40)
    print("I", colloids_to_janus.inertia_tensor(r))
    mlab.show()

    if args.out:
        assert args.out[-3:] == '.h5'
        import pyh5md
        with pyh5md.File(args.out, 'w') as hfile:
            L_group = hfile.particles_group('L')
            half_side = 1.2*args.sigma*args.ny
            r += half_side
            pyh5md.element(L_group, 'position', store='fixed', data=r)
            pyh5md.element(L_group, 'species', store='fixed', data=s)
            L_group.create_box(dimension=3, boundary=['periodic']*3, store='fixed',
                               data=[2*half_side]*3)

