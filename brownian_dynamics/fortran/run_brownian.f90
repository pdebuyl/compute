program run
  use brownian
  implicit none

  integer, parameter :: n = 32
  integer, parameter :: n_loop = 100
  integer, parameter :: n_steps = 10000
  integer, parameter :: n_skip = 1

  double precision :: x0(dim, n), tracer_x0(dim)
  double precision :: dt
  double precision :: x(dim, n, n_steps), tracer_x(dim, n_steps)
  double precision :: force(nbins)
  integer :: force_count(nbins)
  type(sea_probe_t) :: params

  ! bath
  params%D = 1
  params%rot_eps = 0
  params%origin_k = 1
  params%origin_sigma = 1
  params%wall_k = 1
  params%wall_sigma = 5
  params%probe_D = 0.01
  params%probe_wall_k = 1
  params%probe_wall_sigma = 6
  params%lambda = -1
  params%sigma = 1
  params%sigma_cut = 1
  params%sigma_cut_sq = 1
  params%mu = 0
  params%sigma_0 = 0

  dt = 0.01
  x0 = 0
  tracer_x0 = 0

  call srk_with_probe(x0, tracer_x0, params, dt, &
       n_loop, n_steps, n_skip, 1, x, tracer_x, force, force_count, quartic_cut, 28183271)

  open(12, file='x')
  write(12, *) x
  close(12)
  open(12, file='tracer_x')
  write(12, *) tracer_x
  close(12)

end program run
