program test_int
  implicit none

  integer, parameter :: dim=3
  integer, parameter :: mask=2**dim-1

  integer :: i, j, k

  write(*,*) bin_str(dim), ' ', bin_str(mask)

  do i=1, 2**dim-1
     write(*,*) i, ' ', bin_str(i)
  end do

  do i=1, dim
     write(*, '(a7 a7 i3 a3 i5 a7)') bin_str(1), ' right', i, ' = ', rotate_right(1, i), bin_str(rotate_right(1, i))
     write(*, '(a7 a7 i3 a3 i5 a7)') bin_str(1), ' left', i, '= ', rotate_left(1, i), bin_str(rotate_left(1, i))
  end do
  
  do i=0, 2**dim-1
     print *, i, (i-1)/2, floor((i-1)/2.d0), 2*((i-1)/2), 2*floor((i-1)/2.d0)
  end do
  do i=0, 2**dim-1
     print *, i, gc(i), entry_point(i), exit_point(i)
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

end program test_int
