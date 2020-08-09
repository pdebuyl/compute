import json
import itertools
import argparse
import numpy as np
import matplotlib.pyplot as plt
import h5py
import tidynamics

parser = argparse.ArgumentParser()
parser.add_argument('input', type=str, nargs='+')
parser.add_argument('--abscissa', required=True)
parser.add_argument('--fix')
parser.add_argument('--single', action='store_true')
parser.add_argument('--verbose', action='store_true')
parser.add_argument('--debug', action='store_true')
parser.add_argument('--std', action='store_true')
parser.add_argument('--analysis', choices=['diffusion', 'mobility', 'ratio', 'kinetic'], required=True)
parser.add_argument('--out')

args = parser.parse_args()

if args.fix is not None:
    fix_k, fix_v = args.fix.split('=')
    if args.abscissa == fix_k:
        raise Exception('Cannot use same parameter for `--abscissa` and `--fix` argument')
else:
    fix_k, fix_v = None, None

def force_float(x):
    try:
        result = float(x)
    except:
        result = x
    return result

def cmp_dict(d1, d2, keys=None):
    if keys is None:
        keys = d2.keys()
    for k in keys:
        if d1[k] != d2[k] and str(d1[k]) != str(d2[k]) and force_float(d1[k]) != force_float(d2[k]):
            return False
    return True

skip = ['filename']

dl = []

for fn in args.input:
    with open(fn, 'r') as f:
        d = json.load(f)
    d['filename'] = fn
    dl.append(d)

# Gather all keys
all_keys = []
for d in dl:
    all_keys.extend(d.keys())
all_keys = set(all_keys)

uncommon_keys = set()
for d in dl:
    local_keys = all_keys - set(d.keys())
    uncommon_keys = uncommon_keys.union(local_keys)

common_keys = all_keys - uncommon_keys

if args.verbose:
    print('common keys', common_keys)
    print('uncommon keys', uncommon_keys)

fixed_keys = {}
varying_keys = {}
for k in common_keys:
    if k in skip:
        continue
    values = [d[k] for d in dl]
    if type(values[1]) not in [int, float, str, list]:
        continue
    values = set(values)
    if len(values) == 1:
        fixed_keys[k] = values
    else:
        varying_keys[k] = values


available_parameters = set(varying_keys.keys())-set([args.abscissa, fix_k])

if args.verbose:
    print('\nFixed parameters')
    print('----------------')
    for k, v in fixed_keys.items():
        print(k, v)

    print('\nVarying parameters')
    print('------------------')
    for k, v in varying_keys.items():
        print(k, v)

    print('\nAvailable parameters')
    print('------------------')
    print(available_parameters)


listing = []
for params in itertools.product(*[varying_keys[k] for k in available_parameters]):
    d = {}
    for k, v in zip(available_parameters, params):
        d[k] = v
    if fix_k is not None:
        d[fix_k] = fix_v
    if args.verbose: print(d)
    data = {}
    keys = list(varying_keys[args.abscissa])
    keys.sort()
    for v in keys:
        dd = d.copy()
        dd[args.abscissa] = v
        selection = [x for x in dl if cmp_dict(x, dd)]
        if args.verbose:
            print('----------------')
            print(args.abscissa, '=', v)
        filenames = [s['filename'] for s in selection]
        if args.single:
            filenames = [filenames[0]]
        if args.verbose:
            print('selection = ', filenames)
        data[v] = filenames
    d['data'] = data
    listing.append(d)

listing.sort(key=lambda x: x[list(available_parameters)[0]])

def processor(fname):
    with open(fname, 'r') as f:
        d = json.load(f)
    with h5py.File(d['filename'], 'r') as a:
        g = a['particles/probe']                                                                                                              
        L = g['box/edges/value'][0]
        r = g['position/value'][:,0,:]                                                                                                        
        im = g['image/value'][:,0,:]
        r += im*L[None,:]
        v = g['velocity/value'][:,0,:]
        r_t = g['position/time'][:]
        v_t = g['velocity/time'][:]

    r_t -= r_t[0]
    v_t -= v_t[0]
    u = v / np.sqrt(np.sum(v**2, axis=1))[:,None]

    msd = tidynamics.msd(r)
    n = len(msd)
    slope, intercept = np.polyfit(r_t[n//8:n//4], msd[n//8:n//4], 1)

    if args.debug:
        l, = plt.plot(r_t, msd, label=fname)
        plt.plot(r_t, np.poly1d((slope, intercept))(r_t), color=l.get_color())

    return slope/4

def processor_diffusion(fname):
    with open(fname, 'r') as f:
        d = json.load(f)
    #print(d)
    data_fname = d['runs']['free']['filename'][:-3]+'_processed.h5'
    with h5py.File(data_fname, 'r') as a:
        msd = a['msd'][:]
        msd_dt = a['r_dt'][()]
    n = len(msd)
    t = np.arange(n)*msd_dt

    slope, intercept = np.polyfit(t[n//8:n//4], msd[n//8:n//4], 1)

    if args.debug:
        l, = plt.plot(t, msd, label=fname)
        plt.plot(t, np.poly1d((slope, intercept))(t), color=l.get_color())

    return slope/4


def processor_mobility(fname):
    with open(fname, 'r') as f:
        d = json.load(f)
    data_fname = d['runs']['force']['filename'][:-3]+'_processed.h5'
    force_value = d['runs']['force']['force']
    with h5py.File(data_fname, 'r') as a:
        x = a['x'][:]
        x_dt = a['r_dt'][()]
    n = len(x)
    t = np.arange(n)*x_dt

    slope, intercept = np.polyfit(t, x, 1)

    if args.debug:
        l, = plt.plot(t, x, label=fname)
        plt.plot(t, np.poly1d((slope, intercept))(t), color=l.get_color())

    return slope/force_value


def processor_ratio(fname):
    with open(fname, 'r') as f:
        d = json.load(f)
    data_fname = d['runs']['free']['filename'][:-3]+'_processed.h5'
    with h5py.File(data_fname, 'r') as a:
        msd = a['msd'][:]
        msd_dt = a['r_dt'][()]
    n = len(msd)
    t = np.arange(n)*msd_dt

    slope, intercept = np.polyfit(t[n//8:n//4], msd[n//8:n//4], 1)
    D = slope/4

    with open(fname, 'r') as f:
        d = json.load(f)
    data_fname = d['runs']['force']['filename'][:-3]+'_processed.h5'
    force_value = d['runs']['force']['force']
    with h5py.File(data_fname, 'r') as a:
        x = a['x'][:]
        x_dt = a['r_dt'][()]
    n = len(x)
    t = np.arange(n)*x_dt

    slope, intercept = np.polyfit(t, x, 1)
    mu = slope

    return D, mu

def processor_kinetic(fname):
    with open(fname, 'r') as f:
        d = json.load(f)
    data_fname = d['runs']['free']['filename'][:-3]+'_processed.h5'
    with h5py.File(data_fname, 'r') as a:
        vsq = a['vacf'][0]

    return vsq

processors = {'diffusion': processor_diffusion, 'mobility': processor_mobility,
              'ratio': processor_ratio, 'kinetic': processor_kinetic}
processor = processors[args.analysis]
ylabels = {'diffusion': r'$D_{eff}$', 'mobility': r'$\mu$',
           'ratio': r'$D_{eff} / \mu$', 'kinetic': r'$\langle v^2 \rangle$'}

for l in listing:
    print('-------------')
    label = ' '.join([str(k)+' '+str(l[k]) for k in available_parameters])
    print(label)
    x_data = []
    y_m_data = []
    y_s_data = []
    for v, files in l['data'].items():
        x_data.append(v)
        processed_data = [processor(f) for f in files]
        m = np.mean(processed_data, axis=0)
        if args.analysis == 'ratio':
            m = m[0]/m[1]
        s = np.std(processed_data, axis=0, ddof=1)
        y_m_data.append(m)
        y_s_data.append(s)

    y_m_data = np.array(y_m_data)
    y_s_data = np.array(y_s_data) / len(y_s_data)
    line, = plt.plot(x_data, y_m_data, label=label, marker='o')
    if args.std:
        plt.plot(x_data, y_m_data-y_s_data, color=line.get_color(), ls='--')
        plt.plot(x_data, y_m_data+y_s_data, color=line.get_color(), ls='--')

plt.xlabel(args.abscissa)
plt.ylabel(ylabels[args.analysis])
plt.title(f'{args.analysis}')

plt.legend()

if args.out:
    plt.savefig(args.out)
else:
    plt.show()
