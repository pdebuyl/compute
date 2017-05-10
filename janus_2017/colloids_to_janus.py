#!/usr/bin/env python
"""Scan a simulation file for the existence of clusters whose radius is below
the given treshold. The clusters are centered and their x, y, and z moment of
inertia set to an equal value.

The resulting clusters are output to numbered H5MD files containing the
`_janus` suffix.
"""
from __future__ import print_function, division
import argparse
import pyh5md
import numpy as np
import itertools
import os.path
from transforms3d import quaternions


def parse_args(args=None):
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('file', type=str, help='H5MD datafile')
    parser.add_argument('--sigma', type=float, required=True,
                        help='radius of the individual colloids')
    parser.add_argument('--rho', type=float, help='mass density', default=10)
    parser.add_argument('--scale', default='1',
                        help='scale for the final coordinates')
    parser.add_argument('--treshold', type=float,
                        help='maximum distance to center', required=True)
    parser.add_argument('--group', type=str, default='colloids',
                        help='name of the particles group')
    return parser.parse_args(args)


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


def inertia_tensor(r):
    r = np.asarray(r)
    res = np.zeros((3,3))
    for i in range(r.shape[0]):
        res += np.eye(3)*np.sum(r[i]**2)
        res -= np.outer(r[i], r[i])

    return res


def align_axis(r, idx):
    r = np.asarray(r)
    I = inertia_tensor(r)
    e_val, e_vec = np.linalg.eig(I)
    e_z = e_vec[:,idx]
    one_z = np.zeros(3)
    one_z[idx] = 1
    vec = np.cross(e_z, one_z)
    vec = vec/np.sqrt(np.dot(vec, vec))
    theta = np.arccos(np.dot(e_z, one_z))
    q = np.array([np.cos(theta/2), *np.sin(theta/2)*vec])
    for i in range(r.shape[0]):
        r[i] = quaternions.rotate_vector(r[i], q)
    return r


def balance_diagonal(r):
    x, y, z = inertia_tensor(r).diagonal()
    r[:,0] /= np.sqrt((y+z-x))
    r[:,1] /= np.sqrt((x+z-y))
    r[:,2] /= np.sqrt((x+y-z))
    return r


def write_configuration(r, species, filename, sigma, treshold, attrs=None):
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
        if attrs is not None:
            for k, v in attrs.items():
                pos.attrs[k] = v


def cut_along_xyz(r):
    assert np.allclose(r.mean(axis=0), np.zeros(r.shape[1]))
    n_up = np.sum(r>0, axis=0)
    n_down = np.sum(r<0, axis=0)
    return np.equal(n_up, n_down)


def change_axis(r, new_z):
    return r[:,np.roll(np.arange(3), 2-new_z)]

def get_scale(s):
    split = s.split('/')
    if len(split)==1:
        return float(split[0])
    elif len(split)==2:
        return float(split[0])/float(split[1])
    else:
        raise ValueError("Bad value for scale")

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
        r = balance_diagonal(align_axis(align_axis(r, 0), 1))
        r *= np.sqrt(I_target/mass_bead)
        print('full I', mass_bead*inertia_tensor(r))
        cut = cut_along_xyz(r)
        if np.any(cut):
            axis = np.argwhere(cut)[0]
            r = change_axis(r, axis)
            species = np.ones(r.shape[0])
            species[r[:,2]<0] = 2
            print('C com', r[species==1,:].mean(axis=0))
            print('N com', r[species==2,:].mean(axis=0))
            x1, y1, z1 = r[0]
            x2, y2, z2 = r[1]
            x3, y3, z3 = r[2]
            alpha = (x3*y1 - x1*y3) / (x2*y3 - x3*y2)
            beta = -(y1+alpha*y2)/y3
            u_r = r[0]+alpha*r[1]+beta*r[2]
            filename = '%s_janus_b_%03i.h5' % (args.file[:-3], i+1)
            attrs = {'alpha': alpha, 'beta': beta, 'z0': u_r[2]}
            scale = get_scale(args.scale)
            write_configuration(r*scale, species, filename, args.sigma*scale,
                                args.treshold*scale, attrs=attrs)
            print('Wrote', filename)
