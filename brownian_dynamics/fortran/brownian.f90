! Module to perform brownian dynamics simulations of n_bath particles that feel
! an external potential.  A single probe is coupled via harmonic bonds to all of
! the bath particles.  The algorithm is the "Stochastic Runge Kutta" (or SRK)
! from Branka & Heyes, "Algorithms for Brownian dynamics simulation". Physical
! Review E 58, p 2611 (1998). http://dx.doi.org/10.1103/PhysRevE.58.2611

! Author: Pierre de Buyl
! License: BSD 3-clause

module brownian
  use stdtypes
  use mtprng
  implicit none

  integer, parameter :: dim = 2
  integer, parameter :: nbins = 24

contains

  pure function harmonic_cut(x1, x2, cut, cut_sq) result(r)
    double precision, dimension(dim), intent(in) :: x1, x2
    double precision, intent(in) :: cut, cut_sq
    double precision, dimension(dim) :: r

    double precision :: dist_sq

    dist_sq = sum((x1-x2)**2)

    if ( dist_sq <= cut_sq ) then
       r = - (x1 - x2)
    else
       r = - (x1 - x2) * cut / sqrt(dist_sq)
    end if

  end function harmonic_cut

  pure function rotate(x) result(f)
    double precision, dimension(dim), intent(in) :: x
    double precision, dimension(dim) :: f

    f(1) = -x(2)
    f(2) = x(1)

  end function rotate

  subroutine srk_with_tracer(x0, tracer_x0, D, tracer_D, dt, nloop, nsteps, &
       hat_a, hat_g, k, sigma, rot_eps, data, tracer_data, force, force_count)
    double precision, intent(in) :: x0(:,:)
    double precision, intent(in) :: tracer_x0(:)
    double precision, intent(in) :: D, tracer_D, dt, hat_a, hat_g, k
    double precision, intent(in) :: sigma, rot_eps
    integer, intent(in) :: nloop, nsteps
    double precision, intent(out) :: data(dim, size(x0, dim=2), nsteps), &
         tracer_data(dim, nsteps)
    double precision, intent(out) :: force(nbins)
    integer, intent(out) :: force_count(nbins)

    double precision, dimension(:,:), allocatable :: x, x1, f1, f2, g0, rsq
    double precision, dimension(dim) :: tracer_x, tracer_x1, tracer_f1, tracer_f2, tracer_g0
    double precision, dimension(dim) :: tmp
    double precision :: sigma_sq, radius
    integer :: idx

    integer :: i, n_bath, j, i_loop
    integer(INT32) :: seed
    type(mtprng_state) :: state

    n_bath = size(x0, dim=2)
    sigma_sq = sigma**2

    seed = nint(100*secnds(0.))
    call mtprng_init(seed, state)

    allocate(x(dim, n_bath))
    allocate(x1(dim, n_bath))
    allocate(f1(dim, n_bath))
    allocate(f2(dim, n_bath))
    allocate(g0(dim, n_bath))
    allocate(rsq(dim, n_bath))

    x = x0
    tracer_x = tracer_x0
    force = 0
    force_count = 0

    do i = 1, nsteps
       do i_loop = 1, nloop
          rsq = spread(sum(x**2 , dim=1), dim=1, ncopies=dim)
          f1 = hat_a*x - hat_g*rsq*x
          tracer_f1 = 0
          do j = 1, n_bath
             tmp = k * harmonic_cut(x(:,j), tracer_x, sigma, sigma_sq)
             f1(:,j) = f1(:,j) + tmp + rot_eps*rotate(x(:,j))
             tracer_f1 = tracer_f1 - tmp
          end do
          do j=1, n_bath
             g0(1, j) = mtprng_normal(state)
             g0(2, j) = mtprng_normal(state)
          end do
          g0 = g0 * sqrt(2.d0*D*dt)
          tracer_g0(1) = mtprng_normal(state) * sqrt(2.d0*tracer_D*dt)
          tracer_g0(2) = mtprng_normal(state) * sqrt(2.d0*tracer_D*dt)
          x1 = x + D*f1*dt + g0
          tracer_x1 = tracer_x + D*tracer_f1*dt + tracer_g0
          rsq = spread(sum(x1**2 , dim=1), dim=1, ncopies=dim)
          f2 = hat_a*x1 - hat_g*rsq*x1
          tracer_f2 = 0
          do j = 1, n_bath
             tmp = k * harmonic_cut(x1(:,j), tracer_x1, sigma, sigma_sq)
             f2(:, j) = f2(:, j) + tmp + rot_eps*rotate(x1(:,j))
             tracer_f2 = tracer_f2 - tmp
          end do

          x = x + D*(f1+f2)*dt/2 + g0
          tracer_x = tracer_x + tracer_D*(tracer_f1+tracer_f2)*dt/2 + tracer_g0

       end do

       data(:, :, i) = x
       tracer_data(:, i) = tracer_x

       radius = sqrt(sum(tracer_x**2))
       if ( radius < 1.d0 ) then
          idx = floor(radius*nbins) + 1
          force_count(idx) = force_count(idx) + 1
          tmp = k * harmonic_cut(tracer_x, x(:,1), sigma, sigma_sq)
          force(idx) = force(idx) + sum(tracer_x * tmp) / radius
       end if

    end do

  end subroutine srk_with_tracer

end module brownian
