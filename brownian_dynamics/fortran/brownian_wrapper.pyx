from numpy cimport ndarray
from numpy import empty
import numpy as np
cimport numpy as np

cdef extern:
    void c_srk_with_tracer(double *x0, double *tracer_x0, double *D, double *tracer_D,
                           double *dt, int *nloop, int *nsteps, double *hat_a, double *hat_g,
                           double *k, double *sigma, double *rot_eps, double *data,
                           double *tracer_data, int *dim, int *n_bath)

def srk_with_tracer(double[:, ::1] x0, double[::1] tracer_x0, double D,
                    double tracer_D, double dt, int nloop, int nsteps, double hat_a,
                    double hat_g, double k, double sigma, double rot_eps):
    cdef int dim = x0.shape[1]
    cdef int n_bath = x0.shape[0]
    assert dim == tracer_x0.shape[0]

    cdef double[:,:,::1]  data = empty((nsteps, n_bath, dim), dtype=np.double)
    cdef double[:,::1] tracer_data = empty((nsteps, dim), dtype=np.double)

    c_srk_with_tracer(&x0[0,0], &tracer_x0[0], &D, &tracer_D, &dt, &nloop, &nsteps, &hat_a,
                      &hat_g, &k, &sigma, &rot_eps,
                      &data[0,0,0], &tracer_data[0,0], &dim, &n_bath)

    return np.asarray(data), np.asarray(tracer_data)
