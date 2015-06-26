program run
  use brownian
  implicit none

  integer, parameter :: n = 32
  integer, parameter :: n_steps = 1000000

  double precision :: x0(dim, n), tracer_x0(dim)
  double precision :: D, tracer_D, dt, hat_a, hat_g, k
  double precision :: x(dim, n, n_steps), tracer_x(dim, n_steps)

  D = 1
  tracer_D = 0.001
  dt = 0.01
  hat_a = 1
  hat_g = 1.2
  k = 1.5

  x0 = 0
  tracer_x0 = 0

  call srk_with_tracer(x0, tracer_x0, D, tracer_D, dt, n_steps, hat_a, hat_g, k, x, tracer_x)

  open(12, file='x')
  write(12, *) x
  close(12)
  open(12, file='tracer_x')
  write(12, *) tracer_x
  close(12)

end program run
