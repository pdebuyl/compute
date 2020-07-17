import numpy as np
import argparse
import json


def write_in_file(args):

    name = f'{args.name}_{args.type}'
    infile = f'{name}.in'

    # Base quantities

    kT = 1

    L = 40

    sedimentation_line = ''
    boundary_line = 'boundary p p p'

    if args.force:
        force_line = f'fix eforce probe addforce {args.force} 0 0'
    else:
        force_line = ''

    if args.response:
        response_line = f'''fix push probe addforce {args.response} 0 0 

run {args.sampling*3000}
'''
    else:
        response_line = ''

    bath_dump_line = f'dump bathdump bath h5md 50 wl.h5 position image velocity file_from hdump create_group yes'
    bath_dump_line = ''

    if args.movie:
        movie_line = f'''dump mdump all movie 100 wl.avi type type
    dump_modify mdump adiam 2 10
    '''
    else:
        movie_line = ''

    # abp parameters

    radius = 1/2
    mass = 1
    gamma = 1
    damp = mass / gamma
    D = kT / gamma
    tau_r = args.tau_r
    v0 = args.v0

    # probe parameters
    sigma_probe = 5
    mass_probe = 100
    gamma_probe = 10
    D_probe = kT / gamma_probe
    damp_probe = mass_probe / gamma_probe

    # ABP parameters for the inertial dynamics
    I = 2/5 * mass * radius**2
    ascale = 2*kT*damp*tau_r / I

    seed_1, seed_2, seed_3, seed_4 = np.random.randint(1, 2**25-1, size=4)

    # N so that rho is surface area
    rho = args.rho
    N = int(rho * (L**2 - np.pi*sigma_probe**2) / (np.pi*radius**2))

    rho_eff = rho / (np.pi*radius**2)

    tmpl = \
    f"""
dimension 2
{boundary_line}
units lj

atom_style ellipsoid

# Set up box and particles:
variable L equal {L/2}
lattice hex {rho}
region total block -$L $L -$L $L -0.5 0.5 units box
region probe_r sphere 0 0 0 {1.15*(sigma_probe+radius)} side out units box
region free_space intersect 2 total probe_r
create_box 2 total
create_atoms 1 region free_space
create_atoms 2 single 0 0 0

neighbor 0.6 bin
neigh_modify every 1 delay 1 check yes

group bath type 1
group probe type 2

# Set particle shape:
# set all radii to 1 (the command set shape sets the diameters)
set group bath shape 2 2 2
set group probe shape 0 0 0
set group bath quat/random {seed_2}
variable V   equal "4.0/3.0*PI"
variable rho equal "{mass} / v_V"
# Density so that mass = 0.1
set group bath density ${{rho}}
set group probe mass {mass_probe}

# Purely repulsive particles:
variable rc equal "2^(1.0/6.0)"
variable rc_probe equal "{sigma_probe}*2^(1.0/6.0)"
pair_style lj/cut ${{rc}}
pair_coeff 1 1 1.0 1.0 ${{rc}}
pair_coeff 1 2 1.0 {sigma_probe+radius} ${{rc_probe}}
pair_coeff 2 2 1.0 {2*sigma_probe} ${{rc_probe}}
pair_modify shift yes


# Fixes for time integration
fix temp bath langevin 1 1 {damp} {seed_3} angmom {ascale}
fix temp_probe probe langevin 1 1 {damp_probe} {seed_4}
fix 5 all enforce2d
fix probe_nve probe nve

{force_line}
{sedimentation_line}

fix 1 bath nve/limit 0.1

timestep 0.0001
run 100000

fix move bath propel/self quat {v0}

run 10000
unfix 1

fix 1 bath nve/limit 0.1
timestep 0.0001
run 20000
unfix 1

fix step bath nve/asphere

timestep 0.0001
run 100000

# Compute temperature and orientation
compute T    bath temp/asphere
compute quat bath property/atom quatw quati quatj quatk

# Some output:
thermo_style custom time step pe ke etotal temp c_T
thermo 100000

dump hdump probe h5md 100 {name}.h5 position image velocity
{bath_dump_line}
{movie_line}

timestep 0.001
run {args.sampling*1000}

{response_line}
"""

    with open(infile, 'w') as f:
        print(tmpl, file=f)

    return infile

def create_json_file(args):

    params = {}
    for k in ['tau_r', 'v0', 'rho']:
        params[k] = args.__dict__[k]

    params['runs'] = {}

    with open(f'{args.name}.json', 'w') as f:
        json.dump(params, f)

def add_to_json_file(args):

    with open(f'{args.name}.json', 'r') as f:
        params = json.load(f)

    args.tau_r = params['tau_r']
    args.v0 = params['v0']
    args.rho = params['rho']

    run_data = {}
    run_data['filename'] = write_in_file(args)
    if args.response is not None:
        run_data['response'] = args.response
    if args.force is not None:
        run_data['force'] = args.force

    params['runs'][args.type] = run_data

    with open(f'{args.name}.json', 'w') as f:
        json.dump(params, f)


main_parser = argparse.ArgumentParser()
main_parser.set_defaults(func=None)

main_parser.add_argument('name')
main_parser.add_argument('--movie', action='store_true')

sub_parsers = main_parser.add_subparsers()

parser_create = sub_parsers.add_parser('create')
parser_create.set_defaults(func=create_json_file)

parser_create.add_argument('--tau-r', type=float, default=0.1)
parser_create.add_argument('--v0', type=float, default=20)
parser_create.add_argument('--rho', type=float, default=0.25)

parser_add = sub_parsers.add_parser('add')
parser_add.set_defaults(func=add_to_json_file)
parser_add.add_argument('--type', choices=['free', 'force', 'response'], required=True)
parser_add.add_argument('--response', type=float)
parser_add.add_argument('--force', type=float)
parser_add.add_argument('--sampling', type=int, default=1000)

args = main_parser.parse_args()

args.func(args)
