"""
Run a simulation of the constant gradient stochastic model for nanomotor
chemotaxis.
"""
from __future__ import print_function, division

import argparse

parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('file', type=str, help='output filename')
parser.add_argument('--n-steps', type=int, default=1000,
                    help='Number of timesteps')
parser.add_argument('--n-inner-steps', type=int, default=50,
                    help='Number of inner loop steps')
parser.add_argument('-C-force', action='store_true',
                    help='Turn on sensitivity of C bead')
parser.add_argument('--Lambda_NM', type=float, default=0.421,
                    help='Interaction parameter')
args = parser.parse_args()

import stochastic_nanomotor
import h5py
import sys

xy, phi, v= stochastic_nanomotor.run_cg_nm(phi_0=0, N_steps=args.n_steps,
    N_MD=args.n_inner_steps, C_force=args.C_force, Lambda_NM=args.Lambda_NM)

with h5py.File(sys.argv[1]) as f:
    f['xy'] = xy
    f['phi'] = phi
    f['v'] = v

