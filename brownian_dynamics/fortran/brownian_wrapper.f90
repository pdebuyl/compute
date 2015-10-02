module brownian_wrapper
  use iso_c_binding, only: c_double, c_int
  use brownian, only: srk_with_tracer, nbins, &
       harmonic_cut, lj_cut
  implicit none

contains

  subroutine c_srk_with_tracer(x0, tracer_x0, D, tracer_D, dt, nloop, nsteps, nskip, &
       hat_a, hat_g, &
       k, sigma, cut, rot_eps, &
       force_type, &
       data, tracer_data, dim, n_bath, force, force_count) bind(c)
    integer(c_int), intent(in) :: n_bath
    real(c_double), intent(in) :: x0(dim, n_bath)
    real(c_double), intent(in) :: tracer_x0(dim)
    real(c_double), intent(in) :: D, tracer_D, dt, hat_a, hat_g, k, sigma, cut, rot_eps
    integer(c_int), intent(in) :: dim
    integer(c_int), intent(in) :: nloop, nsteps, nskip
    integer(c_int), intent(in) :: force_type
    real(c_double), intent(out) :: data(dim, n_bath, nsteps), &
         tracer_data(dim, nsteps)
    real(c_double), intent(out) :: force(nbins)
    integer(c_int), intent(out) :: force_count(nbins)


    if (force_type == 1) then
        call srk_with_tracer(x0, tracer_x0, D, tracer_D, dt, nloop, nsteps, nskip, hat_a, hat_g, &
             k, sigma, cut, rot_eps, data, tracer_data, force, force_count, harmonic_cut)
    else if (force_type == 2) then
        call srk_with_tracer(x0, tracer_x0, D, tracer_D, dt, nloop, nsteps, nskip, hat_a, hat_g, &
             k, sigma, cut, rot_eps, data, tracer_data, force, force_count, lj_cut)
    end if 

  end subroutine c_srk_with_tracer

end module brownian_wrapper
