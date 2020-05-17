import numpy as np
import argparse

def write_input(**args):

    args = argparse.Namespace(**args)

    # Base quantities
    D = 1
    kT = 1
    radius = 1

    sigma_probe = args.sigma_probe

    if 'add_force' in args:
        add_force_line = f'fix eforce probe addforce {args.add_force} 0 0'
    else:
        add_force_line = ''

    if 'bath_dump_every' in args and args.bath_dump_every > 0:
        bath_dump_line = f'dump bathdump bath h5md {args.bath_dump_every} {args.hfile} position image velocity file_from hdump create_group yes'
    else:
        bath_dump_line = ''

    if 'gravity' in args:
        sedimentation_line = f"""fix walls all wall/reflect ylo EDGE yhi EDGE
fix grav probe addforce 0 {args.gravity} 0
"""
        boundary_line = 'boundary p f p'
    else:
        sedimentation_line = ''
        boundary_line = 'boundary p p p'

    # damp < 1
    damp = 0.1

    # probe parameters
    D_probe = D * radius / sigma_probe
    gamma_probe = kT / D_probe
    mass_probe = damp*gamma_probe

    # ABP parameters for the inertial dynamics
    mass = kT * damp / D
    I = 2/5 * mass * radius**2
    ascale = 2*kT*damp*args.tau_r / I

    seed_1, seed_2, seed_3, seed_4 = np.random.randint(1, 2**25-1, size=4)

    # N so that rho is surface area
    N = int(args.rho * (args.L**2 / np.pi - sigma_probe**2))

    infodict = {
        'mass_probe': mass_probe,
        'I': I,
        'ascale': ascale,
        'N': N,
        'mass': mass,
        'D_probe': D_probe
    }

    L = args.L/2

    tmpl = \
    f"""
dimension 2
{boundary_line}
units lj

atom_style ellipsoid

# Set up box and particles:
variable L equal {L}
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
pair_coeff 1 2 1.0 {sigma_probe} ${{rc_probe}}
pair_coeff 2 2 1.0 {sigma_probe} ${{rc_probe}}
pair_modify shift yes


# Fixes for time integration
fix temp bath langevin 1 1 0.1 {seed_3} angmom {ascale}
fix temp_probe probe langevin 1 1 0.1 {seed_4}
fix 5 all enforce2d

{add_force_line}
{sedimentation_line}

fix 1 bath nve/limit 0.1

timestep 0.0001
run 10000

unfix 1

fix step bath nve/asphere
fix probe_nve probe nve

fix move bath propel/self quat {args.v0}
timestep 0.001
run 100000

# Compute temperature and orientation
compute T    bath temp/asphere
compute quat bath property/atom quatw quati quatj quatk

# Some output:
thermo_style custom time step pe ke etotal temp c_T
thermo 100000

dump hdump probe h5md {args.dump_every} {args.hfile} position image velocity
{bath_dump_line}

timestep 0.001
run {args.sampling*1000}
"""

    return tmpl, infodict


