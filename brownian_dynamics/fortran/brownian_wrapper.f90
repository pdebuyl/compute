module brownian_wrapper
  use iso_c_binding, only: c_double, c_int
  use brownian, only: srk_with_tracer
  implicit none

contains

  subroutine c_srk_with_tracer(x0, tracer_x0, D, tracer_D, dt, nloop, nsteps, hat_a, hat_g, k, &
       data, tracer_data, dim, n_bath) bind(c)
    real(c_double), intent(in) :: x0(dim, n_bath)
    real(c_double), intent(in) :: tracer_x0(dim)
    real(c_double), intent(in) :: D, tracer_D, dt, hat_a, hat_g, k
    integer(c_int), intent(in) :: dim
    integer(c_int), intent(in) :: n_bath
    integer(c_int), intent(in) :: nloop, nsteps
    real(c_double), intent(out) :: data(dim, n_bath, nsteps), &
         tracer_data(dim, nsteps)

    call srk_with_tracer(x0, tracer_x0, D, tracer_D, dt, nloop, nsteps, hat_a, hat_g, k, data, tracer_data)

  end subroutine c_srk_with_tracer

end module brownian_wrapper
