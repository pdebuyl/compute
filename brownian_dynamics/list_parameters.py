import h5py
import argparse

parser = argparse.ArgumentParser()
parser.add_argument('ID', type=str, help='ID for filename output')
args = parser.parse_args()

a = h5py.File('trajectory_%s.h5' % args.ID, 'r')

for k in a.attrs:
    print(k, a.attrs[k])
