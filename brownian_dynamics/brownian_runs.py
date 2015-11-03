import numpy as np
import brownian_wrapper
import h5py
import time

import argparse

parser = argparse.ArgumentParser()
parser.add_argument('ID', type=str, help='ID for filename output')
parser.add_argument('-N', type=int, help='number of bath particles', default=32)
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
parser.add_argument('--D-probe', type=float, default=0.001)
parser.add_argument('--seed', type=int, default=1)
args = parser.parse_args()

a = h5py.File('trajectory_%s.h5' % args.ID, 'w')
for k, v in args.__dict__.iteritems():
    a.attrs[k] = v

t0 = time.time()

x0 = np.zeros((args.N,2))
X0 = np.array(args.X0)
print X0
x, X, force, force_count = brownian_wrapper.srk_with_probe(x0, X0, 1., args.D_probe, 0.01, args.loop, args.steps, args.skip, args.stride, args.origin_k,
                                       args.origin_s, args.wall_k, args.wall_s, args.probe_wall_k, args.probe_wall_s,
                                       args.lam, args.sigma, args.cut, args.epsilon, 3, args.seed)
a['x'] = x
a['X'] = X
a['force'] = force
a['force_count'] = force_count

a.close()

print 'simulation %s done - %7.1f s' % (args.ID, time.time() - t0)
