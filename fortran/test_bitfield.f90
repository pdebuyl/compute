program test_bitfield
  implicit none

  write(*,*) ibset(0, 0)
  write(*,*) int(b'01')

  write(*,*) ibset(0, 1)
  write(*,*) int(b'10')

end program test_bitfield
