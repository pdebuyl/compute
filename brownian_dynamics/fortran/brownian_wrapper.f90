module brownian_wrapper
  use iso_c_binding, only: c_double, c_int
  use brownian, only: srk_with_probe, nbins, &
       harmonic_cut, lj_cut, quartic_cut
  implicit none

  integer(c_int), parameter :: force_harmonic=1
  integer(c_int), parameter :: force_lj=2
  integer(c_int), parameter :: force_quartic=3

contains

  subroutine c_srk_with_probe(x0, probe_x0, D, probe_D, dt, nloop, nsteps, nskip, nstride, &
       origin_k, origin_sigma, &
       wall_k, wall_sigma, &
       probe_wall_k, probe_wall_sigma, &
       lambda, sigma, cut, &
       rot_eps, force_type, &
       data, probe_data, dim, n_bath, force, force_count) bind(c)
    integer(c_int), intent(in) :: dim
    real(c_double), intent(in) :: x0(dim, n_bath)
    real(c_double), intent(in) :: probe_x0(dim)
    real(c_double), intent(in) :: D, probe_D, dt, origin_k, origin_sigma, &
         wall_k, wall_sigma, probe_wall_k, probe_wall_sigma, lambda, sigma, cut, rot_eps
    integer(c_int), intent(in) :: nloop, nsteps, nskip, nstride
    integer(c_int), intent(in) :: force_type
    real(c_double), intent(out) :: data(dim, n_bath, nsteps), &
         probe_data(dim, nsteps)
    integer(c_int), intent(in) :: n_bath
    real(c_double), intent(out) :: force(nbins)
    integer(c_int), intent(out) :: force_count(nbins)


    if (force_type == force_harmonic) then
        call srk_with_probe(x0, probe_x0, D, probe_D, dt, nloop, nsteps, nskip, nstride, &
             origin_k, origin_sigma, wall_k, wall_sigma, probe_wall_k, probe_wall_sigma, &
             lambda, sigma, cut, rot_eps, data, probe_data, force, force_count, harmonic_cut)
    else if (force_type == force_lj) then
        call srk_with_probe(x0, probe_x0, D, probe_D, dt, nloop, nsteps, nskip, nstride, &
             origin_k, origin_sigma, wall_k, wall_sigma, probe_wall_k, probe_wall_sigma, &
             lambda, sigma, cut, rot_eps, data, probe_data, force, force_count, lj_cut)
    else if (force_type == force_quartic) then
        call srk_with_probe(x0, probe_x0, D, probe_D, dt, nloop, nsteps, nskip, nstride, &
             origin_k, origin_sigma, wall_k, wall_sigma, probe_wall_k, probe_wall_sigma, &
             lambda, sigma, cut, rot_eps, data, probe_data, force, force_count, quartic_cut)
    end if

  end subroutine c_srk_with_probe

end module brownian_wrapper
