import numpy as np
import brownian_wrapper
import h5py
import time

import argparse

parser = argparse.ArgumentParser()
parser.add_argument('ID', type=str, help='ID for filename output')
parser.add_argument('-N', type=int, help='number of bath particles', default=32)
parser.add_argument('--repeat', type=int, default=1)
parser.add_argument('--steps', type=int, help='number of simulations steps', default=10000)
parser.add_argument('--loop', type=int, help='inner loop iterations', default=100)
parser.add_argument('--skip', type=int, help='number of simulations steps', default=1000)
parser.add_argument('--stride', type=int, help='striding for storage', default=1)
parser.add_argument('--X0', type=float, nargs=2, default=[0.,0.])
parser.add_argument('--origin-k', type=float, default=1.)
parser.add_argument('--origin-s', type=float, default=1.)
parser.add_argument('--wall-k', type=float, default=1.)
parser.add_argument('--wall-s', type=float, default=4.)
parser.add_argument('--probe-wall-k', type=float, default=1.)
parser.add_argument('--probe-wall-s', type=float, default=6.)
parser.add_argument('--lam', type=float, default=1.)
parser.add_argument('--sigma', type=float, default=1.)
parser.add_argument('--cut', type=float, default=1.)
parser.add_argument('--epsilon', type=float, default=0)
parser.add_argument('--probe-D', type=float, default=0.001)
parser.add_argument('--D', type=float, default=1.0)
parser.add_argument('--force-type', type=int, default=3)
parser.add_argument('--seed', type=int, default=1)
parser.add_argument('--mu', type=float, default=0)
parser.add_argument('--sigma_0', type=float, default=0)
parser.add_argument('--dt', type=float, default=0.01)
args = parser.parse_args()

a = h5py.File('trajectory_%s.h5' % args.ID, 'w')
for k, v in args.__dict__.iteritems():
    a.attrs[k] = v

t0 = time.time()

x0 = np.zeros((args.N,2))
X0 = np.array(args.X0)
force_data = []
force_count_data = []
bath_count_data = []
for i in range(args.repeat):
    x, X, force, force_count, bath_count = brownian_wrapper.srk_with_probe(x0, X0, args)
    x0 = x[-1]
    X0 = X[-1]
    force_data.append(force)
    force_count_data.append(force_count)
    bath_count_data.append(bath_count)
a['x'] = x
a['X'] = X
a['force'] = np.array(force_data).sum(axis=0)
a['force_count'] = np.array(force_count_data).sum(axis=0)
a['bath_count'] = np.array(bath_count_data).sum(axis=0)

a.close()

print 'simulation %s done - %7.1f s' % (args.ID, time.time() - t0)
