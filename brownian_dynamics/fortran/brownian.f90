module brownian
  use stdtypes
  use mtprng
  implicit none

  integer, parameter :: dim = 2

contains

  subroutine srk_with_tracer(x0, tracer_x0, D, tracer_D, dt, nloop, nsteps, hat_a, hat_g, k, data, tracer_data)
    double precision, intent(in) :: x0(:,:)
    double precision, intent(in) :: tracer_x0(:)
    double precision, intent(in) :: D, tracer_D, dt, hat_a, hat_g, k
    integer, intent(in) :: nloop, nsteps
    double precision, intent(out) :: data(dim, size(x0, dim=2), nsteps), &
         tracer_data(dim, nsteps)

    double precision, dimension(:,:), allocatable :: x, x1, f1, f2, g0, rsq, &
         bond_f1, bond_f2
    double precision, dimension(dim) :: tracer_x, tracer_x1, tracer_f1, tracer_f2, tracer_g0

    integer :: i, n_bath, j, i_loop
    integer(INT32) :: seed
    type(mtprng_state) :: state

    n_bath = size(x0, dim=2)

    seed = nint(100*secnds(0.))
    call mtprng_init(seed, state)

    allocate(x(dim, n_bath))
    allocate(x1(dim, n_bath))
    allocate(f1(dim, n_bath))
    allocate(f2(dim, n_bath))
    allocate(g0(dim, n_bath))
    allocate(rsq(dim, n_bath))
    allocate(bond_f1(dim, n_bath))
    allocate(bond_f2(dim, n_bath))

    x = x0
    tracer_x = tracer_x0

    do i = 1, nsteps
       do i_loop = 1, nloop
          rsq = spread(sum(x**2 , dim=1), dim=1, ncopies=dim)
          f1 = hat_a*x - hat_g*rsq*x
          bond_f1 = k * ( spread(tracer_x, dim=2, ncopies=n_bath) - x ) / n_bath
          f1 = f1 + bond_f1
          tracer_f1 = - sum(bond_f1, dim=2)
          do j=1, n_bath
             g0(1, j) = mtprng_normal(state)
             g0(2, j) = mtprng_normal(state)
          end do
          g0 = g0 * sqrt(2.d0*D*dt)
          tracer_g0(1) = mtprng_normal(state) * sqrt(2.d0*tracer_D*dt)
          tracer_g0(2) = mtprng_normal(state) * sqrt(2.d0*tracer_D*dt)
          x1 = x * D*f1*dt + g0
          tracer_x1 = tracer_x + D*tracer_f1*dt + tracer_G0
          rsq = spread(sum(x**2 , dim=1), dim=1, ncopies=dim)
          f2 = hat_a*x1 - hat_g*rsq*x1
          bond_f2 = k * ( spread(tracer_x1, dim=2, ncopies=n_bath) - x1 ) / n_bath
          f2 = f2 + bond_f2
          tracer_f2 = - sum(bond_f2, dim=2)

          x = x + D*(f1+f2)*dt/2 + g0
          tracer_x = tracer_x + tracer_D*(tracer_f1+tracer_f2)*dt/2 + tracer_g0

       end do

       data(:, :, i) = x
       tracer_data(:, i) = tracer_x

    end do

  end subroutine srk_with_tracer

end module brownian
