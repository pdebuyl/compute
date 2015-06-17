program test_int
  implicit none

  integer, parameter :: dim=3
  integer, parameter :: mask=2**dim-1

  integer :: i, j, k

  print *, dim, mask

  do i=1, dim
     print *, i, 'right', rotate_right(1, i)
     print *, i, 'left', rotate_left(1, i)
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

end program test_int
