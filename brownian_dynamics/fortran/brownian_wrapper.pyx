from numpy cimport ndarray
from numpy import empty
import numpy as np
cimport numpy as np

cdef extern:

    void c_srk_with_probe(double *x0, double *probe_x0, double *D, double *probe_D,
                           double *dt, int *nloop, int *nsteps, int *nskip, int *nstride,
			   double *origin_k, double *origin_sigma,
			   double *wall_k, double *wall_sigma,
			   double *probe_wall_k, double *probe_wall_sigma,
			   double *lam, double *sigma, double *cut,
			   double *rot_eps, int *force_type,
                           double *data,
                           double *probe_data, int *dim, int *n_bath,
                           double *force, int *force_count)

def srk_with_probe(double[:, ::1] x0, double[::1] probe_x0, double D,
                    double probe_D, double dt, int nloop, int nsteps, int nskip, int nstride,
		    double origin_k, double origin_sigma, double wall_k,
		    double wall_sigma, double probe_wall_k, double probe_wall_sigma,
                    double lam, double sigma, double cut, double rot_eps, int force_type):
    cdef int dim = x0.shape[1]
    cdef int n_bath = x0.shape[0]
    assert dim == probe_x0.shape[0]

    cdef double[:,:,::1]  data = empty((nsteps, n_bath, dim), dtype=np.double)
    cdef double[:,::1] probe_data = empty((nsteps, dim), dtype=np.double)
    cdef double[::1] force = empty((256,), dtype=np.double)
    cdef int[::1] force_count = empty((256,), dtype=np.int32)

    c_srk_with_probe(&x0[0,0], &probe_x0[0], &D, &probe_D, &dt, &nloop, &nsteps, &nskip, &nstride,
                     &origin_k, &origin_sigma, &wall_k, &wall_sigma, &probe_wall_k,
                     &probe_wall_sigma, &lam, &sigma, &cut,
                     &rot_eps, &force_type,
                     &data[0,0,0], &probe_data[0,0], &dim, &n_bath, &force[0], &force_count[0])

    return np.asarray(data), np.asarray(probe_data), np.asarray(force), np.asarray(force_count)
