import numpy as np
cimport numpy as np
cimport cython
from libc.stdlib cimport malloc
from libc.math cimport cos, sin, sqrt, acos

cdef extern from "randomkit.h":
    ctypedef enum rk_error:
        RK_NOERR = 0
        RK_ENODEV = 1
        RK_ERR_MAX = 2

    ctypedef struct rk_state:
        unsigned long key[624];
        int pos;
        int has_gauss;
        double gauss;
        int has_binomial;
        double psave;
        long nsave;
        double r;
        double q;
        double fm;
        long m;
        double p1;
        double xm;
        double xl;
        double xr;
        double c;
        double laml;
        double lamr;
        double p2;
        double p3;
        double p4;

    # 0xFFFFFFFFUL
    cdef unsigned long RK_MAX
    cdef unsigned long rk_interval(unsigned long max, rk_state *state)
    cdef rk_error rk_randomseed(rk_state *state)
    cdef double rk_double(rk_state *state)
    cdef double rk_gauss(rk_state *state)

cdef rk_state *s = <rk_state *> malloc(sizeof(rk_state))
cdef rk_error local_error = rk_randomseed(s)

ctypedef struct doublepair:
    double x
    double y

cdef double RHO = 10
cdef double FLUID_D = 0.0655964394275
cdef double V_MAX = 0.0953096390684
cdef double R = 3.367386144928119
cdef double T = 0.3333
cdef double k0 = 32.6559814827
cdef double kD = 2.77576727425
cdef double PI = np.pi
cdef double LY = 30
cdef double d = 6.7

@cython.cdivision(True)
cdef double cg_c_A(double x,double y):
    return RHO*y/LY

@cython.cdivision(True)
cdef double cg_lam(double x, double y):
    return RHO/LY

@cython.cdivision(True)
cdef double cg_F_C_y(double x, double y, double phi):
    return 8*PI*T/3 * R * k0/(k0+2*kD) * cg_lam(x-d*cos(phi)/2, y-d*sin(phi)/2)

@cython.cdivision(True)
cdef double cg_polar_c_B(double theta, double varphi, double r, double x, double y, double phi):
    """Concentration of B at location theta, varphi, r from the N bead.
    x, y are the c.o.m. coordinates and phi is the orientation of the dimer."""
    cdef double x_C, y_C, x_N, y_N, c0, c1, c2, x_p, y_p, z_p, r_0
    x_C = x + d*cos(phi)/2
    y_C = y + d*sin(phi)/2
    x_N = x - d*cos(phi)/2
    y_N = y - d*sin(phi)/2
    
    c0 = cg_c_A(x_C, y_C)
    c1 = -k0/(k0+kD)*c0
    c2 = -k0/(k0+2*kD)*cg_lam(x_C, y_C)

    x_p = x_N + r*cos(varphi)*sin(theta)
    y_p = y_N + r*cos(theta)
    z_p = r*sin(varphi)*sin(theta)

    r_0 = sqrt((x_p-x_C)**2+(y_p-y_C)**2+z_p**2)
    theta_0 = acos((r*cos(theta)-d*sin(phi))/r_0)

    return -c1*(R/r_0) - c2*(R/r_0)**2*cos(theta_0)

cdef double wall_force(double y):
    cdef double fy
    cdef double k_wall = 10
    if y<2:
        fy = -k_wall*(y-2)
    elif y>LY-2:
        fy = k_wall*(LY-y-2)
    else:
        fy = 0
    return fy

@cython.boundscheck(False)
@cython.cdivision(True)
@cython.wraparound(False)
cdef doublepair cg_F_N(double x, double y, double phi):
    cdef doublepair result
    cdef double fx = 0
    cdef double fy = 0
    cdef int i_theta, i_varphi, N_theta, N_varphi
    cdef double c, th, vphi
    N_theta = 32
    N_varphi = 32
    cdef double inv_N_theta = 1.0/N_theta
    cdef double inv_N_varphi = 1.0/N_varphi
    for i_theta in range(N_theta):
        th = (i_theta+0.5)*PI*inv_N_theta
        for i_varphi in range(N_varphi):
            vphi = (i_varphi+0.5)*2*PI*inv_N_varphi
            c = cg_polar_c_B(th, vphi, R, x, y, phi)
            fx = fx + c*sin(th)*sin(th)*cos(vphi)
            fy = fy + c*sin(th)*cos(th)
    factor = 2*T*PI*inv_N_theta*2*PI*inv_N_varphi
    result.x = fx*factor
    result.y = fy*factor
    return result


@cython.boundscheck(False)
@cython.wraparound(False)
def one_step(np.ndarray[np.int64_t, ndim=1] individusAleatoires, np.ndarray[np.int64_t, ndim=1] TableauFourmis, int capa, int loi, int asyn_steps):
    cdef int NbIndividus = TableauFourmis.shape[0]
    cdef int k, l, don
    cdef unsigned int i
    cdef int ChargePremier, ChargeSecond
    cdef int n_steps
    cdef double x,y, P1, P2

    k = rk_interval(NbIndividus,s)
    l = rk_interval(NbIndividus,s)

    x = rk_double(s)
    y = rk_double(s)

cdef doublepair rotate_xy(double x, double y, double phi):
    cdef doublepair result
    result.x = cos(phi)*x - sin(phi)*y
    result.y = sin(phi)*x + cos(phi)*y
    return result

cdef double torque(double f_c_y, double f_n_x, double f_n_y, double phi):
    return (cos(phi) * (f_c_y - f_n_y) + sin(phi) * f_n_x)*d/2

@cython.boundscheck(False)
@cython.cdivision(True)
@cython.wraparound(False)
def run_cg_nm(phi_0=0, int N_steps=1000, int N_MD=100, C_force=False, double Lambda_NM=0):

    cdef double x, y, phi, D_para, gamma_para, D_perp, gamma_perp, D_r, gamma_r
    cdef double dt, x_para_factor, x_perp_factor, phi_factor, F_y_coeff
    cdef int t, i
    cdef double F_y, F_N_x, F_N_y, F_com_x, F_com_y, xi_para, xi_perp, xi_phi, F_para, F_perp
    cdef doublepair F_N_xy, F_paraperp, F_com

    x, y = 30, LY/2
    phi = phi_0
    D_para = 0.002
    gamma_para = T/D_para
    D_perp = 0.0015
    gamma_perp = T/D_perp
    D_r = 1.4e-4
    gamma_r = T/D_r

    dt = 1./N_MD
    x_para_factor = sqrt(2*D_para*dt)
    x_perp_factor = sqrt(2*D_perp*dt)
    phi_factor = sqrt(2*D_r*dt)
    if C_force:
        F_y_coeff = Lambda_NM
    else:
        F_y_coeff = 0

    cdef double[:,::1] dimer_data = np.empty((N_steps,7))

    for t in range(N_steps):
        for i in range(N_MD):
            F_y = F_y_coeff*cg_F_C_y(x, y, phi)
            F_N_xy = cg_F_N(x, y, phi)
            F_N_x = Lambda_NM*F_N_xy.x
            F_N_y = Lambda_NM*F_N_xy.y
            F_com_x = F_N_x
            F_com_y = F_N_y + F_y + wall_force(y)
            F_paraperp = rotate_xy(F_com_x, F_com_y, -phi)
            F_para = F_paraperp.x*dt/gamma_para + x_para_factor*rk_gauss(s)
            F_perp = F_paraperp.y*dt/gamma_perp + x_perp_factor*rk_gauss(s)
            F_com = rotate_xy(F_para, F_perp, phi)
            x += F_com.x
            y += F_com.y
            phi += torque(F_y, F_N_x, F_N_y, phi)*dt / gamma_r + phi_factor*rk_gauss(s)
        dimer_data[t,0] = x
        dimer_data[t,1] = y
        dimer_data[t,2] = phi
        dimer_data[t,3] = F_N_x
        dimer_data[t,4] = F_N_y
        dimer_data[t,5] = F_com.x/dt
        dimer_data[t,6] = F_com.y/dt

    return np.asarray(dimer_data[:,:2]), np.asarray(dimer_data[:,2]), np.asarray(dimer_data[:,5:])
