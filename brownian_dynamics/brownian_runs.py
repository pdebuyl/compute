import numpy as np
import brownian_wrapper
import h5py

import argparse

parser = argparse.ArgumentParser()
parser.add_argument('ID', type=str, help='ID for filename output')
parser.add_argument('-N', type=int, help='number of bath particles', default=64)
parser.add_argument('--steps', type=int, help='number of simulations steps', default=100000)
parser.add_argument('--loop', type=int, help='inner loop iterations', default=100)
parser.add_argument('--skip', type=int, help='number of simulations steps', default=1000)
parser.add_argument('--X0', type=float, nargs=2, default=[0.,0.])
parser.add_argument('-l', type=float, default=1.)
parser.add_argument('-g', type=float, default=0.1)
parser.add_argument('-a', type=float, default=1.)
parser.add_argument('--D-tracer', type=float, default=0.001)
args = parser.parse_args()

a = h5py.File('trajectory_%s.h5' % args.ID, 'w')
for k, v in args.__dict__.iteritems():
    a.attrs[k] = v

x0 = np.zeros((args.N,2))
X0 = np.array(args.X0)
print X0
x, X = brownian_wrapper.srk_with_tracer(x0, X0, 1., args.D_tracer, 0.005, args.loop, args.steps, args.a, args.g, args.l)
a['x'] = x
a['X'] = X

a.close()
