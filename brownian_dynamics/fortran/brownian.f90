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
  integer, parameter :: nbins = 256

  interface
     pure function pair_force_t(x1, x2, sigma, cut, cut_sq) result(r)
       double precision, intent(in) :: x1(2), x2(2)
       double precision, intent(in) :: sigma, cut, cut_sq
       double precision, dimension(2) :: r
     end function pair_force_t
  end interface

contains

  pure function hat(x, x_sq, hat_a, hat_g) result(f)
    double precision, intent(in) :: x(:,:), x_sq(:,:)
    double precision, intent(in) :: hat_a, hat_g
    double precision, dimension(dim, size(x, dim=2)) :: f

    f = hat_a*x - hat_g*x_sq*x

  end function hat

  !! Origin potential
  !! k exp( - x^2 / 2 sigma^2 )
  pure function gaussian_hat(x, k, sigma) result(f)
    double precision, intent(in) :: x(dim)
    double precision, intent(in) :: k, sigma
    double precision :: f(dim)

    double precision :: rsq

    rsq = sum(x**2)

    f = k * x / sigma**2 * exp(-rsq/(2*sigma**2))

  end function gaussian_hat

  !! Box potential
  !! k exp( (|x| - sigma) )
  pure function exponential_box(x, k, sigma) result(f)
    double precision, intent(in) :: x(dim)
    double precision, intent(in) :: k, sigma
    double precision :: f(dim)

    double precision, parameter :: n=2
    double precision :: r

    r = sqrt(sum(x**2))

    f = - k * n * exp(n*(r - sigma)) * x / (r+1d-8)

  end function exponential_box

  pure function harmonic_cut(x1, x2, sigma, cut, cut_sq) result(r)
    double precision, dimension(dim), intent(in) :: x1, x2
    double precision, intent(in) :: sigma, cut, cut_sq
    double precision, dimension(dim) :: r

    double precision :: dist_sq

    dist_sq = sum((x1-x2)**2)

    if ( dist_sq <= cut_sq ) then
       r = - (x1 - x2)
    else
       r = - (x1 - x2) * cut / sqrt(dist_sq)
    end if

  end function harmonic_cut

  pure function lj_cut(x1, x2, sigma, cut, cut_sq) result(r)
    double precision, dimension(dim), intent(in) :: x1, x2
    double precision, intent(in) :: sigma, cut, cut_sq
    double precision, dimension(dim) :: r

    double precision :: dist_sq, dist, sig6_o_r6

    dist_sq = sum((x1-x2)**2)

    if ( dist_sq <= cut_sq ) then
       dist = sqrt(dist_sq)
       sig6_o_r6 = sigma**6 / dist_sq**3
       r = 24 * sig6_o_r6 / dist_sq * ( 2*sig6_o_r6 - 1 ) * (x1 - x2)
    else
       r = 0
    end if

  end function lj_cut

  pure function quartic_cut(x1, x2, sigma, cut, cut_sq) result(r)
    double precision, dimension(dim), intent(in) :: x1, x2
    double precision, intent(in) :: sigma, cut, cut_sq
    double precision, dimension(dim) :: r

    double precision :: dist_sq

    dist_sq = sum((x1-x2)**2)

    if ( dist_sq <= cut_sq ) then
       r = 4 / cut_sq * ( 1 - dist_sq/cut_sq ) * (x1 - x2)
    else
       r = 0
    end if

  end function quartic_cut

  pure function rotate(x) result(f)
    double precision, dimension(dim), intent(in) :: x
    double precision, dimension(dim) :: f

    f(1) = -x(2)
    f(2) = x(1)

  end function rotate

  subroutine srk_with_probe(x0, probe_x0, D, probe_D, dt, nloop, nsteps, nskip, nstride, &
       origin_k, origin_sigma, &
       wall_k, wall_sigma, &
       probe_wall_k, probe_wall_sigma, &
       lambda, sigma, cut, &
       rot_eps, data, probe_data, force, force_count, pair_force)
    double precision, intent(in) :: x0(:,:)
    double precision, intent(in) :: probe_x0(:)
    double precision, intent(in) :: D, probe_D, dt
    double precision, intent(in) :: origin_k, origin_sigma
    double precision, intent(in) :: wall_k, wall_sigma
    double precision, intent(in) :: probe_wall_k, probe_wall_sigma
    double precision, intent(in) :: lambda, sigma, cut
    double precision, intent(in) :: rot_eps
    integer, intent(in) :: nloop, nsteps, nskip, nstride
    double precision, intent(out) :: data(dim, size(x0, dim=2), nsteps), &
         probe_data(dim, nsteps)
    double precision, intent(out) :: force(nbins)
    integer, intent(out) :: force_count(nbins)
    procedure(pair_force_t) :: pair_force

    double precision, dimension(:,:), allocatable :: x, x1, f1, f2, g0
    double precision, dimension(dim) :: probe_x, probe_x1, probe_f1, probe_f2, probe_g0
    double precision, dimension(dim) :: tmp
    double precision :: cut_sq, radius
    double precision :: probe_r
    double precision :: bath_step, probe_step
    integer :: idx

    integer :: i, n_bath, j, i_loop
    integer(INT32) :: seed
    type(mtprng_state) :: state

    n_bath = size(x0, dim=2)
    cut_sq = cut**2
    bath_step = sqrt(2.d0*D*dt)
    probe_step = sqrt(2.d0*probe_D*dt)

    seed = nint(100*secnds(0.))
    call mtprng_init(seed, state)

    allocate(x(dim, n_bath))
    allocate(x1(dim, n_bath))
    allocate(f1(dim, n_bath))
    allocate(f2(dim, n_bath))
    allocate(g0(dim, n_bath))

    x = x0
    probe_x = probe_x0
    force = 0
    force_count = 0

    do i = 1, (nsteps + nskip)*nstride
       do i_loop = 1, nloop
          ! First step of algorithm: x1 = x + D f dt + xi sqrt(2 D dt)
          probe_f1 = exponential_box(probe_x, probe_wall_k, probe_wall_sigma)
          do j = 1, n_bath
             tmp = lambda * pair_force(x(:,j), probe_x, sigma, cut, cut_sq)
             f1(:,j) = gaussian_hat(x(:,j), origin_k, origin_sigma) + &
                  exponential_box(x(:,j), wall_k, wall_sigma) + &
                  tmp + rot_eps*rotate(x(:,j))
             probe_f1 = probe_f1 - tmp
          end do
          do j=1, n_bath
             g0(1, j) = mtprng_normal(state) * bath_step
             g0(2, j) = mtprng_normal(state) * bath_step
          end do
          probe_g0(1) = mtprng_normal(state) * probe_step
          probe_g0(2) = mtprng_normal(state) * probe_step
          x1 = x + D*f1*dt + g0
          probe_x1 = probe_x + D*probe_f1*dt + probe_g0

          ! Second step of algorithm: x = x + D (f1 + f2)/2 dt + xi sqrt(2 D dt)

          probe_f2 = exponential_box(probe_x1, probe_wall_k, probe_wall_sigma)
          do j = 1, n_bath
             tmp = lambda * pair_force(x1(:,j), probe_x1, sigma, cut, cut_sq)
             f2(:,j) = gaussian_hat(x1(:,j), origin_k, origin_sigma) + &
                  exponential_box(x1(:,j), wall_k, wall_sigma) + &
                  tmp + rot_eps*rotate(x1(:,j))
             probe_f2 = probe_f2 - tmp
          end do

          x = x + D*(f1+f2)*dt/2 + g0
          probe_x = probe_x + probe_D*(probe_f1+probe_f2)*dt/2 + probe_g0

       end do

       if (i > nskip*nstride) then

          ! Binning force data
          radius = sqrt(sum(probe_x**2))
          if ( radius < wall_sigma ) then
             idx = floor(radius*nbins/wall_sigma) + 1
             force_count(idx) = force_count(idx) + 1
             tmp = lambda * pair_force(probe_x, x(:,1), sigma, cut, cut_sq)
             force(idx) = force(idx) + sum(probe_x * tmp) / radius
          end if

          ! Store trajectory every nstride
          j = i - nskip*nstride
          if ( modulo(j, nstride) == 1 ) then
             j = j / nstride + 1
             data(:, :, j) = x
             probe_data(:, j) = probe_x
          end if

       end if

    end do

  end subroutine srk_with_probe

end module brownian
