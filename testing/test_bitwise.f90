program test_int
  implicit none

  integer, parameter :: dim=3
  integer, parameter :: mask=2**dim-1

  integer :: i, j
  integer :: compact_m(dim)

  write(*,*) bin_str(dim), ' ', bin_str(mask)

  do i=1, 2**dim-1
     write(*,*) i, ' ', bin_str(i)
  end do

  do i=1, dim
     write(*, '(a7 a7 i3 a3 i5 a7)') bin_str(1), ' right', i, ' = ', rotate_right(1, i), bin_str(rotate_right(1, i))
     write(*, '(a7 a7 i3 a3 i5 a7)') bin_str(1), ' left', i, '= ', rotate_left(1, i), bin_str(rotate_left(1, i))
  end do
  
  do i=0, 2**dim-1
     print *, i, gc(i), entry_point(i), exit_point(i), inverse_gc(gc(i)), intercube_g(i), intracube_d(i)
  end do

  print *, p_to_h([7, 3, 5], 3)
  print *, h_to_p(407, 3)

  open(12, file='i_p.txt')
  do i=0, 2**(dim*3)-1
     write(12, *) i, h_to_p(i, 3)
  end do
  close(12)

  write(*,*) 'compact'
  open(12, file='compact_i_p.txt')
  compact_m = [3, 2, 2]
  do i=0, 2**sum(compact_m)-1
     write(12, *) i, compact_h_to_p(i, compact_m)
  end do
  close(12)
  write(*,*) 'compact'

  do i=0, 2**(dim*3)-1
     if ( p_to_h(h_to_p(i, 3), 3) .ne. i ) then
        stop 'p_to_h and h_to_p do not agree'
     end if
  end do
  
  do i=0, 2**dim-1
     print *, i, (ibits(i, j, 1), j=0, dim-1)
  end do

  do i=0,dim-1
     write(*,*) extract_mask(i, compact_m)
  end do

contains

  pure function rotate_right(x, d)
    integer, intent(in) :: x
    integer, intent(in) :: d
    integer :: rotate_right
    integer :: tmp

    rotate_right = shiftr(x, d)
    tmp = shiftl(x, dim-d)
    rotate_right = iand(ior(rotate_right, tmp), mask)

  end function rotate_right

  pure function rotate_left(x, d)
    integer, intent(in) :: x
    integer, intent(in) :: d
    integer :: rotate_left
    integer :: tmp

    rotate_left = shiftl(x, d)
    tmp = shiftr(x, dim-d)
    rotate_left = iand(ior(rotate_left, tmp), mask)

  end function rotate_left

  function bin_str(x)
    integer, intent(in) :: x

    character(len=dim) :: bin_str
    integer :: i, j, total_size

    total_size = bit_size(x)

    do i=1, dim
       j = dim-(i-1)
       if (ibits(x, i-1, 1).eq.1) then
          bin_str(j:j) = '1'
       else
          bin_str(j:j) = '0'
       end if
    end do

  end function bin_str

  function gc(i)
    integer, intent(in) :: i
    integer gc

    gc = ieor(i, shiftr(i, 1))

  end function gc

  function entry_point(i)
    integer, intent(in) :: i
    integer :: entry_point

    if (i .eq. 0) then
       entry_point = 0
    else
       entry_point = gc(2*((i-1)/2))
    end if

  end function entry_point

  function exit_point(i)
    integer, intent(in) :: i
    integer :: exit_point

    exit_point = ieor(entry_point(mask-i), 2**(dim-1))

  end function exit_point

  function inverse_gc(g)
    integer, intent(in) :: g
    integer :: inverse_gc
    integer :: j

    inverse_gc = g
    j = 1
    do while ( j .lt. dim )
       inverse_gc = ieor(inverse_gc, shiftr(g, j))
       j = j + 1
    end do

  end function inverse_gc

  function intercube_g(i) result(g)
    integer, intent(in) :: i
    integer :: g

    g = trailz(ieor(gc(i), gc(i+1)))

  end function intercube_g

  function intracube_d(i) result(d)
    integer, intent(in) :: i
    integer :: d

    if (i .eq. 0) then
       d = 0
    else if ( modulo(i, 2) .eq. 0 ) then
       d = modulo(intercube_g(i-1), dim)
    else
       d = modulo(intercube_g(i), dim)
    end if
  end function intracube_d

  function transform(e, d, b) result(t)
    integer, intent(in) :: e, d, b
    integer :: t

    t = rotate_right( ieor(b, e), d+1)
  end function transform

  function inverse_transform(e, d, b) result(t)
    integer, intent(in) :: e, d, b
    integer :: t

    t = transform(rotate_right(e, d+1), dim-d-2, b)

  end function inverse_transform

  function p_to_h(p, m) result(h)
    integer, intent(in) :: p(dim), m
    integer :: h

    integer :: e, d, i, j, l, w

    h = 0
    e = 0
    d = 2
    do i = m-1, 0, -1
       l = 0
       do j=1, dim
          l = l + 2**(j-1)*ibits(p(j), i, 1)
       end do
       l = transform(e, d, l)
       w = inverse_gc(l)
       e = ieor(e, rotate_left(entry_point(w), d+1))
       d = modulo(d + intracube_d(w) + 1, dim)
       h = ior(shiftl(h, dim), w)
    end do
  end function p_to_h

  function h_to_p(h, m) result(p)
    integer, intent(in) :: h, m
    integer :: p(dim)

    integer :: e, d, i, l, w

    e = 0
    d = 2
    p = 0
    do i=m-1, 0, -1
       w = 0
       do j=0, dim-1
          w = w + 2**j*ibits(h, i*dim+j, 1)
       end do
       l = gc(w)
       l = inverse_transform(e, d, l)
       do j=1, dim
          p(j) = p(j) + shiftl(ibits(l, j-1, 1) , i)
       end do
       e = ieor( e, rotate_left(entry_point(w), d+1))
       d = modulo(d + intracube_d(w) + 1, dim)
    end do

  end function h_to_p

  function gcr(i, mu) result(r)
    integer, intent(in) :: i, mu
    integer :: r

    integer :: k
    r = 0
    do k=dim-1, 0, -1
       if (ibits(mu, k, 1) .eq. 1) then
          r = ior( shiftl(r, 1), ibits(i, k, 1))
       end if
    end do

  end function gcr

  function inverse_gcr(r, mu, pi) result(i)
    integer, intent(in) :: r, mu, pi
    integer :: i

    integer :: g, j, k
    i = 0
    g = 0
    j = -1
    do k=0, dim - 1
       j = j + ibits(mu, k, 1)
    end do
    do k=dim-1, 0, -1
       if (ibits(mu, k, 1) .eq. 1) then
          i = ior(i, shiftl( ibits(r, j, 1), k))
          g = ior(g, shiftl( modulo( ibits(i, k, 1)+ibits(i, k+1, 1), 2), k) )
          j = j-1
       else
          g = ior(g, shiftl( ibits(pi, k, 1), k))
          i = ior(i, shiftl( modulo( ibits(g, k, 1)+ibits(i, k+1, 1), 2), k) )
       end if
    end do
  end function inverse_gcr

  function extract_mask(i, m) result(mu)
    integer, intent(in) :: i, m(dim)
    integer :: mu

    integer :: j

    mu = 0
    do j=dim, 1, -1
       mu = shiftl(mu, 1)
       if ( m(j) .gt. i ) then
          mu = ior(mu, 1)
       end if
    end do

  end function extract_mask

  function compact_p_to_h(p, m) result(h)
    integer, intent(in) :: p(dim), m(dim)
    integer :: h

    integer :: e, d, max_m, i, j, l, mu, mu_norm, pi, r, w

    h = 0
    e = 0
    d = 2
    max_m = maxval(m)
    do i=max_m-1, 0, -1
       mu = extract_mask(i, m)
       mu_norm = 0
       do j=0, dim-1
          mu_norm = mu_norm + ibits(mu, j, 1)
       end do
       mu = rotate_right(mu, d+1)
       pi = iand(rotate_right(e, d+1), iand(not(mu), mask))
       l = 0
       do j=1, dim
          l = l + 2**(j-1)*ibits(p(j), i, 1)
       end do
       l = transform(e, d, l)
       w = inverse_gc(l)
       r = gcr(w, mu)
       e = ieor(e, rotate_left(entry_point(w), d+1))
       d = modulo(d + intracube_d(w) + 1, dim)
       h = ior( shiftl(h, mu_norm), r)
    end do

  end function compact_p_to_h

  function compact_h_to_p(h, m) result(p)
    integer, intent(in) :: h, m(dim)
    integer :: p(dim)

    integer :: e, d, i, j, k, max_m, sum_m, mu_norm, mu, pi, r, l, w

    e = 0
    d = 2
    k = 0
    p = 0
    max_m = maxval(m)
    sum_m = sum(m)
    do i=max_m-1, 0, -1
       mu = extract_mask(i, m)
       mu_norm = 0
       do j=0, dim-1
          mu_norm = mu_norm + ibits(mu, j, 1)
       end do
       mu = rotate_right(mu, d+1)
       pi = iand(rotate_right(e, d+1), iand(not(mu), mask))
       r = 0
       do j=0, mu_norm-1
          r = r + 2**j*ibits(h, sum_m - k - mu_norm + j, 1)
       end do
       k = k + mu_norm
       w = inverse_gcr(r, mu, pi)
       l = gc(w)
       l = inverse_transform(e, d, l)
       do j=1, dim
          p(j) = p(j) + shiftl(ibits(l, j-1, 1), i)
       end do
       e = ieor(e, rotate_left(entry_point(w), d+1))
       d = modulo(d + intracube_d(w) + 1, dim)
    end do
  end function compact_h_to_p

end program test_int
