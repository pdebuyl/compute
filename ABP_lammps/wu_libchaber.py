import numpy as np
import argparse

parser = argparse.ArgumentParser()
parser.add_argument('name')
parser.add_argument('--tau-r', type=float, default=0.1)
parser.add_argument('--v0', type=float, default=20)
parser.add_argument('--sampling', type=int, default=10000)
parser.add_argument('--rho', type=float, default=0.25)
parser.add_argument('--response', type=float)
parser.add_argument('--movie', action='store_true')
args = parser.parse_args()


# Base quantities

kT = 1
L = 40

sedimentation_line = ''
boundary_line = 'boundary p p p'
add_force_line = ''

if args.response:
    response_line = f'''fix push probe addforce {args.response} 0 0 

run {args.sampling*3000}
'''
else:
    response_line = ''

bath_dump_line = f'dump bathdump bath h5md 50 wl.h5 position image velocity file_from hdump create_group yes'
bath_dump_line = ''

if args.movie:
    movie_line = f'dump mdump all movie 100 wl.avi type type'
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

tmpl = \
f"""
dimension 2
{boundary_line}
units lj

atom_style ellipsoid

# Set up box and particles:
variable L equal {L/2}
region total block -$L $L -$L $L -$L $L
create_box 2 total
variable N equal {N}
create_atoms 1 random $N {seed_1} total
create_atoms 2 single 0 0 0

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

{add_force_line}
{sedimentation_line}

fix 1 bath nve/limit 0.1

timestep 0.0001
run 10000
fix move bath propel/self quat {v0}
run 10000

unfix 1

fix step bath nve/asphere
fix probe_nve probe nve

timestep 0.0001
run 100000

# Compute temperature and orientation
compute T    bath temp/asphere
compute quat bath property/atom quatw quati quatj quatk

# Some output:
thermo_style custom time step pe ke etotal temp c_T
thermo 100000

dump hdump probe h5md 100 {args.name}.h5 position image velocity
{bath_dump_line}
{movie_line}

timestep 0.001
run {args.sampling*1000}

{response_line}
"""

print(tmpl)

