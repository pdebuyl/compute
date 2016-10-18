#!/usr/bin/env python
"""Scan a simulation file for the existence of clusters whose radius is below
the given treshold. The clusters are centered and their x, y, and z moment of
inertia set to an equal value.

The resulting clusters are output to numbered H5MD files containing the
`_janus` suffix.
"""
from __future__ import print_function, division
import argparse


def parse_args(args=None):
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('file', type=str, help='H5MD datafile')
    parser.add_argument('--sigma', type=float, required=True,
                        help='radius of the individual colloids')
    parser.add_argument('--rho', type=float, help='mass density', default=10)
    parser.add_argument('--scale', type=float,
                        help='scale for the final coordinates', default=1)
    parser.add_argument('--treshold', type=float,
                        help='maximum distance to center', required=True)
    parser.add_argument('--group', type=str, default='colloids',
                        help='name of the particles group')
    return parser.parse_args(args)

import pyh5md
import numpy as np
import itertools
import os.path


def center_cluster(r, edges):
    n = r.shape[0]
    s_min = n*np.sum(edges**2)
    nx, ny, nz = map(lambda x: int(x)//2, edges)
    keep_shift = np.zeros(3)
    for i, j, k in itertools.product(range(nx), range(ny), range(nz)):
        shift = np.zeros(3) + np.array((i, j, k))*2
        s = np.mod(r+shift.reshape((1, 3)), edges.reshape((1, 3)))
        s_com = s.mean(axis=0)
        s = s - s_com.reshape((1, 3))
        s_sq = np.sum(s**2)
        if s_sq < s_min:
            s_min = s_sq
            keep_shift = shift.copy()
    r = np.mod(r+keep_shift.reshape((1, 3)), edges.reshape((1, 3)))
    r_com = r.mean(axis=0)
    r -= r_com.reshape((1, 3))
    return r


def inertia_gyr(r, mass_bead):
    I = np.zeros(3)
    gyr = np.mean(r**2)*mass_bead
    for part in range(r.shape[0]):
        pos = r[part, :]
        I[0] += pos[1]**2 + pos[2]**2
        I[1] += pos[2]**2 + pos[0]**2
        I[2] += pos[0]**2 + pos[1]**2
    return I*mass_bead, gyr


def transform(r, target_Iz):
    x, y, z = np.sum(r**2, axis=0)
    for part in range(r.shape[0]):
        r[part, 0] *= np.sqrt(z/x)
        r[part, 1] *= np.sqrt(z/y)


def rotate_z(x, theta):
    return np.dot(np.array([[np.cos(theta), -np.sin(theta), 0],
                            [np.sin(theta), np.cos(theta), 0],
                            [0, 0, 1]]), x)


def rotate_y(x, theta):
    return np.dot(np.array([[np.cos(theta), 0, -np.sin(theta)],
                            [0, 1, 0],
                            [np.sin(theta), 0, np.cos(theta)]]), x)


def align_to_z(r, v):
    theta = np.arctan2(v[1], v[0])
    for i in range(r.shape[0]):
        r[i, :] = rotate_z(r[i, :], -theta)
    v = rotate_z(v, -theta)
    phi = np.arctan(v[2]/v[0])
    for i in range(r.shape[0]):
        r[i, :] = rotate_y(r[i, :], np.pi/2-phi)
    v = rotate_y(v, np.pi/2-phi)
    return r


def write_configuration(r, species, filename, sigma, treshold):
    kwargs = {'author': 'Pierre de Buyl',
              'creator': os.path.basename(__file__)}
    with pyh5md.File(filename, mode='w', **kwargs) as b:
        cluster = b.particles_group('janus')
        edges = np.ones(3) * 2 * np.ceil(sigma + treshold + 1)
        r += edges.reshape((1, 3))/2
        cluster.create_box(dimension=3, boundary=['periodic']*3,
                           store='fixed', data=edges)
        pos = pyh5md.element(cluster, 'position', store='fixed', data=r)
        pyh5md.element(cluster, 'box/edges', store='fixed', data=edges)
        pyh5md.element(cluster, 'species', store='fixed', data=species)


def cut_in_half(r):
    """Sort the particles so that the first and second half represent the two
    hemispheres of the sphere. Assumes that the particles are centered around
    the origin."""
    assert np.allclose(r.mean(axis=0), np.zeros(r.shape[1]))
    n = r.shape[0]
    is_odd = not n%2==0
    weigth = np.inf
    keep_up = None
    for i in range(n):
        v = r[i] / np.sqrt(np.sum(r[i]**2))
        sign = np.sum(r*v.reshape((1, 3)), axis=1)
        up = sign > 0
        r_up = r[up]
        r_down = r[~up]
        if len(r_up) == n//2 or (is_odd and len(r_up) == n//2+1):
            new_weigth = np.sum(sign**2)
            if new_weigth < weigth:
                keep_i = i
                weigth = new_weigth
                keep_up = up.copy()
                print(args.file, weigth)
    i, up = keep_i, keep_up
    r_up = r[up]
    r_down = r[~up]
    new_index = np.searchsorted(np.arange(n)[up], i)
    assert np.allclose(r[i], r_up[new_index])
    r = np.concatenate((r_up, r_down))
    species = np.zeros(n)
    species[:] = 2
    species[:np.sum(up)] = 1
    return r, species, new_index

# read
# select clusters
# align to z

if __name__ == '__main__':
    args = parse_args()
    assert args.file[-3:] == '.h5'

    with pyh5md.File(args.file, 'r') as a:
        colloids = a.particles_group(args.group)
        all_r = pyh5md.element(colloids, 'position')
        edges = colloids['box/edges'][:]
        n_colloids = all_r.value.shape[1]
        mass_bead = args.rho * 4/3*np.pi*args.sigma**3
        I_target = n_colloids * mass_bead * 2/5 * args.treshold**2
        step = 0
        configurations = []
        for r in all_r.value:
            r = center_cluster(r, edges)
            I, gyr = inertia_gyr(r, mass_bead)
            ratio = np.std(I)/np.mean(I)
            radius = np.sqrt(np.sum(r**2, axis=1))
            transform(r, I[2])
            I_trans, gyr_trans = inertia_gyr(r, mass_bead)
            r *= np.sqrt(I_target / I_trans[2])
            Ip, gyrp = inertia_gyr(r, mass_bead)
            count, bins = np.histogram(radius, bins=np.linspace(0, 10, 11))
            if radius.max() < args.treshold:
                print(args.file, 'step', step)
                print('I = ', I, 'ratio = ', ratio, 'target I', I_target)
                print('Ip = ', Ip)
                print(count, sum(count))
                print('Max. radius =', radius.max())
                configurations.append(r.copy())
            step += 1

    for i, r in enumerate(configurations):
        r, species, idx = cut_in_half(r.copy())
        r = align_to_z(r, r[idx].copy())*args.scale
        I, gyr = inertia_gyr(r, mass_bead)
        print('I = ', I)
        transform(r, I[2])
        I_trans, gyr_trans = inertia_gyr(r, mass_bead)
        r *= np.sqrt(I_target / I_trans[2])
        Ip, gyrp = inertia_gyr(r, mass_bead)
        print('Ip = ', Ip)
        filename = '%s_janus_b_%03i.h5' % (args.file[:-3], i+1)
        write_configuration(r, species, filename, args.sigma*args.scale, args.treshold*args.scale)
        print('Wrote', filename)
