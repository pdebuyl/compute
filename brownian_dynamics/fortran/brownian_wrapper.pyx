from numpy cimport ndarray
from numpy import empty
import numpy as np
cimport numpy as np

cdef extern:

    struct sea_probe_t:
        double D, rot_eps;
        double origin_k, origin_sigma;
        double wall_k, wall_sigma;
        double probe_D;
        double probe_wall_k, probe_wall_sigma;
        int force_type;
        double lam, sigma, sigma_cut, sigma_cut_sq;
        double mu, sigma_0;

    void c_srk_with_probe(double *x0, double *probe_x0,
                          sea_probe_t *params,
                           double *dt, int *nloop, int *nsteps, int *nskip, int *nstride,
                           double *data, double *probe_data, int *dim, int *n_bath,
                           double *force, int *force_count, int *bath_count, int *seed)

def srk_with_probe(double[:, ::1] x0, double[::1] probe_x0, params):
    cdef int dim = x0.shape[1]
    cdef int n_bath = x0.shape[0]
    assert dim == probe_x0.shape[0]
    cdef sea_probe_t c_params;

    cdef double dt = params.dt;
    cdef int nloop = params.loop;
    cdef int nsteps = params.steps;
    cdef int nskip = params.skip;
    cdef int nstride = params.stride;
    cdef int seed = params.seed;

    cdef double[:,:,::1]  data = empty((nsteps, n_bath, dim), dtype=np.double)
    cdef double[:,::1] probe_data = empty((nsteps, dim), dtype=np.double)
    cdef double[::1] force = empty((256,), dtype=np.double)
    cdef int[::1] force_count = empty((256,), dtype=np.int32)
    cdef int[::1] bath_count = empty((256,), dtype=np.int32)

    c_params.D = params.D;
    c_params.rot_eps = params.epsilon;
    c_params.origin_k = params.origin_k;
    c_params.origin_sigma = params.origin_s;
    c_params.wall_k = params.wall_k;
    c_params.wall_sigma = params.wall_s;
    c_params.probe_D = params.probe_D;
    c_params.probe_wall_k = params.probe_wall_k;
    c_params.probe_wall_sigma = params.probe_wall_s;
    c_params.force_type = params.force_type;
    c_params.lam = params.lam;
    c_params.sigma = params.sigma;
    c_params.sigma_cut = params.cut;
    c_params.sigma_cut_sq = params.cut**2;
    c_params.mu = params.mu;
    c_params.sigma_0 = params.sigma_0;

    c_srk_with_probe(&x0[0,0], &probe_x0[0], &c_params,
                     &dt, &nloop, &nsteps, &nskip, &nstride,
                     &data[0,0,0], &probe_data[0,0], &dim, &n_bath, &force[0], &force_count[0], &bath_count[0], &seed)

    return np.asarray(data), np.asarray(probe_data), np.asarray(force), np.asarray(force_count), np.asarray(bath_count)
