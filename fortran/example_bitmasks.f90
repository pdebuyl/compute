program example_bitmasks
  implicit none

  integer, parameter :: ik = selected_int_kind(2)
  integer, parameter :: BIT_00 = 0
  integer(kind=ik), parameter :: MASK_00 = ibset(0, BIT_00)
  integer, parameter :: BIT_01 = 1
  integer(kind=ik), parameter :: MASK_01 = ibset(0, BIT_01)
  integer, parameter :: BIT_02 = 2
  integer(kind=ik), parameter :: MASK_02 = ibset(0, BIT_02)

  integer(kind=ik) :: mask

  mask = ior(MASK_00, MASK_02)

  write(*,*) 'Truth table of mask with the three bitmasks'
  write(*,*) 'iand(mask, MASK_00) == MASK_00', iand(mask, MASK_00) == MASK_00
  write(*,*) 'btest(mask, BIT_00)', btest(mask, BIT_00)
  write(*,*) 'iand(mask, MASK_00) == MASK_00', iand(mask, MASK_01) == MASK_01
  write(*,*) 'btest(mask, BIT_01)', btest(mask, BIT_01)
  write(*,*) 'iand(mask, MASK_00) == MASK_00', iand(mask, MASK_02) == MASK_02
  write(*,*) 'btest(mask, BIT_02)', btest(mask, BIT_02)


end program example_bitmasks
