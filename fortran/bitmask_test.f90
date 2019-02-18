! This program was created by generate_bitmasks_tests.py
! by Pierre de Buyl
program bm_test
  implicit none

  integer, parameter :: ik = selected_int_kind(2)
  integer(kind=ik), parameter :: FLAG_00 = ibset(0, 0)
  integer(kind=ik), parameter :: FLAG_01 = ibset(0, 1)
  integer(kind=ik), parameter :: FLAG_02 = ibset(0, 2)
  integer(kind=ik), parameter :: FLAG_03 = ibset(0, 3)
  integer(kind=ik), parameter :: FLAG_04 = ibset(0, 4)
  integer(kind=ik), parameter :: FLAG_05 = ibset(0, 5)
  integer(kind=ik), parameter :: FLAG_06 = ibset(0, 6)

  integer(kind=ik) :: b

  write(*,*) 'selected_int_kind(2) =', ik
  write(*,*) 'storage_size(b) = ', storage_size(b), 'bits'
  b = FLAG_00
  write(*,*) 'FLAG_00 = ', b
  b = FLAG_01
  write(*,*) 'FLAG_01 = ', b
  b = FLAG_02
  write(*,*) 'FLAG_02 = ', b
  b = FLAG_03
  write(*,*) 'FLAG_03 = ', b
  b = FLAG_04
  write(*,*) 'FLAG_04 = ', b
  b = FLAG_05
  write(*,*) 'FLAG_05 = ', b
  b = FLAG_06
  write(*,*) 'FLAG_06 = ', b
  b = FLAG_00
  call show_comparison
  if (b == 0) then
    stop 'error at FLAG_00 test for zero'
  end if
  if (FLAG_00 /= iand(b, FLAG_00)) then
    stop 'error at FLAG_00 equality'
  end if
  b = FLAG_01
  call show_comparison
  if (b == 0) then
    stop 'error at FLAG_01 test for zero'
  end if
  if (FLAG_01 /= iand(b, FLAG_01)) then
    stop 'error at FLAG_01 equality'
  end if
  b = FLAG_02
  call show_comparison
  if (b == 0) then
    stop 'error at FLAG_02 test for zero'
  end if
  if (FLAG_02 /= iand(b, FLAG_02)) then
    stop 'error at FLAG_02 equality'
  end if
  b = FLAG_03
  call show_comparison
  if (b == 0) then
    stop 'error at FLAG_03 test for zero'
  end if
  if (FLAG_03 /= iand(b, FLAG_03)) then
    stop 'error at FLAG_03 equality'
  end if
  b = FLAG_04
  call show_comparison
  if (b == 0) then
    stop 'error at FLAG_04 test for zero'
  end if
  if (FLAG_04 /= iand(b, FLAG_04)) then
    stop 'error at FLAG_04 equality'
  end if
  b = FLAG_05
  call show_comparison
  if (b == 0) then
    stop 'error at FLAG_05 test for zero'
  end if
  if (FLAG_05 /= iand(b, FLAG_05)) then
    stop 'error at FLAG_05 equality'
  end if
  b = FLAG_06
  call show_comparison
  if (b == 0) then
    stop 'error at FLAG_06 test for zero'
  end if
  if (FLAG_06 /= iand(b, FLAG_06)) then
    stop 'error at FLAG_06 equality'
  end if

  b = ior(FLAG_00, FLAG_01)
  if (FLAG_00 /= iand(b, FLAG_00)) then
    stop 'error at FLAG_00 FLAG_01 equality'
  end if

  if (FLAG_01 /= iand(b, FLAG_01)) then
    stop 'error at FLAG_00 FLAG_01 equality'
  end if

  if (FLAG_02 == iand(b, FLAG_02)) then
    stop 'error at FLAG_00 FLAG_01 equality'
  end if

  if (FLAG_03 == iand(b, FLAG_03)) then
    stop 'error at FLAG_00 FLAG_01 equality'
  end if

  if (FLAG_04 == iand(b, FLAG_04)) then
    stop 'error at FLAG_00 FLAG_01 equality'
  end if

  if (FLAG_05 == iand(b, FLAG_05)) then
    stop 'error at FLAG_00 FLAG_01 equality'
  end if

  if (FLAG_06 == iand(b, FLAG_06)) then
    stop 'error at FLAG_00 FLAG_01 equality'
  end if

  b = ior(FLAG_00, FLAG_02)
  if (FLAG_00 /= iand(b, FLAG_00)) then
    stop 'error at FLAG_00 FLAG_02 equality'
  end if

  if (FLAG_01 == iand(b, FLAG_01)) then
    stop 'error at FLAG_00 FLAG_02 equality'
  end if

  if (FLAG_02 /= iand(b, FLAG_02)) then
    stop 'error at FLAG_00 FLAG_02 equality'
  end if

  if (FLAG_03 == iand(b, FLAG_03)) then
    stop 'error at FLAG_00 FLAG_02 equality'
  end if

  if (FLAG_04 == iand(b, FLAG_04)) then
    stop 'error at FLAG_00 FLAG_02 equality'
  end if

  if (FLAG_05 == iand(b, FLAG_05)) then
    stop 'error at FLAG_00 FLAG_02 equality'
  end if

  if (FLAG_06 == iand(b, FLAG_06)) then
    stop 'error at FLAG_00 FLAG_02 equality'
  end if

  b = ior(FLAG_00, FLAG_03)
  if (FLAG_00 /= iand(b, FLAG_00)) then
    stop 'error at FLAG_00 FLAG_03 equality'
  end if

  if (FLAG_01 == iand(b, FLAG_01)) then
    stop 'error at FLAG_00 FLAG_03 equality'
  end if

  if (FLAG_02 == iand(b, FLAG_02)) then
    stop 'error at FLAG_00 FLAG_03 equality'
  end if

  if (FLAG_03 /= iand(b, FLAG_03)) then
    stop 'error at FLAG_00 FLAG_03 equality'
  end if

  if (FLAG_04 == iand(b, FLAG_04)) then
    stop 'error at FLAG_00 FLAG_03 equality'
  end if

  if (FLAG_05 == iand(b, FLAG_05)) then
    stop 'error at FLAG_00 FLAG_03 equality'
  end if

  if (FLAG_06 == iand(b, FLAG_06)) then
    stop 'error at FLAG_00 FLAG_03 equality'
  end if

  b = ior(FLAG_00, FLAG_04)
  if (FLAG_00 /= iand(b, FLAG_00)) then
    stop 'error at FLAG_00 FLAG_04 equality'
  end if

  if (FLAG_01 == iand(b, FLAG_01)) then
    stop 'error at FLAG_00 FLAG_04 equality'
  end if

  if (FLAG_02 == iand(b, FLAG_02)) then
    stop 'error at FLAG_00 FLAG_04 equality'
  end if

  if (FLAG_03 == iand(b, FLAG_03)) then
    stop 'error at FLAG_00 FLAG_04 equality'
  end if

  if (FLAG_04 /= iand(b, FLAG_04)) then
    stop 'error at FLAG_00 FLAG_04 equality'
  end if

  if (FLAG_05 == iand(b, FLAG_05)) then
    stop 'error at FLAG_00 FLAG_04 equality'
  end if

  if (FLAG_06 == iand(b, FLAG_06)) then
    stop 'error at FLAG_00 FLAG_04 equality'
  end if

  b = ior(FLAG_00, FLAG_05)
  if (FLAG_00 /= iand(b, FLAG_00)) then
    stop 'error at FLAG_00 FLAG_05 equality'
  end if

  if (FLAG_01 == iand(b, FLAG_01)) then
    stop 'error at FLAG_00 FLAG_05 equality'
  end if

  if (FLAG_02 == iand(b, FLAG_02)) then
    stop 'error at FLAG_00 FLAG_05 equality'
  end if

  if (FLAG_03 == iand(b, FLAG_03)) then
    stop 'error at FLAG_00 FLAG_05 equality'
  end if

  if (FLAG_04 == iand(b, FLAG_04)) then
    stop 'error at FLAG_00 FLAG_05 equality'
  end if

  if (FLAG_05 /= iand(b, FLAG_05)) then
    stop 'error at FLAG_00 FLAG_05 equality'
  end if

  if (FLAG_06 == iand(b, FLAG_06)) then
    stop 'error at FLAG_00 FLAG_05 equality'
  end if

  b = ior(FLAG_00, FLAG_06)
  if (FLAG_00 /= iand(b, FLAG_00)) then
    stop 'error at FLAG_00 FLAG_06 equality'
  end if

  if (FLAG_01 == iand(b, FLAG_01)) then
    stop 'error at FLAG_00 FLAG_06 equality'
  end if

  if (FLAG_02 == iand(b, FLAG_02)) then
    stop 'error at FLAG_00 FLAG_06 equality'
  end if

  if (FLAG_03 == iand(b, FLAG_03)) then
    stop 'error at FLAG_00 FLAG_06 equality'
  end if

  if (FLAG_04 == iand(b, FLAG_04)) then
    stop 'error at FLAG_00 FLAG_06 equality'
  end if

  if (FLAG_05 == iand(b, FLAG_05)) then
    stop 'error at FLAG_00 FLAG_06 equality'
  end if

  if (FLAG_06 /= iand(b, FLAG_06)) then
    stop 'error at FLAG_00 FLAG_06 equality'
  end if

  b = ior(FLAG_01, FLAG_02)
  if (FLAG_00 == iand(b, FLAG_00)) then
    stop 'error at FLAG_01 FLAG_02 equality'
  end if

  if (FLAG_01 /= iand(b, FLAG_01)) then
    stop 'error at FLAG_01 FLAG_02 equality'
  end if

  if (FLAG_02 /= iand(b, FLAG_02)) then
    stop 'error at FLAG_01 FLAG_02 equality'
  end if

  if (FLAG_03 == iand(b, FLAG_03)) then
    stop 'error at FLAG_01 FLAG_02 equality'
  end if

  if (FLAG_04 == iand(b, FLAG_04)) then
    stop 'error at FLAG_01 FLAG_02 equality'
  end if

  if (FLAG_05 == iand(b, FLAG_05)) then
    stop 'error at FLAG_01 FLAG_02 equality'
  end if

  if (FLAG_06 == iand(b, FLAG_06)) then
    stop 'error at FLAG_01 FLAG_02 equality'
  end if

  b = ior(FLAG_01, FLAG_03)
  if (FLAG_00 == iand(b, FLAG_00)) then
    stop 'error at FLAG_01 FLAG_03 equality'
  end if

  if (FLAG_01 /= iand(b, FLAG_01)) then
    stop 'error at FLAG_01 FLAG_03 equality'
  end if

  if (FLAG_02 == iand(b, FLAG_02)) then
    stop 'error at FLAG_01 FLAG_03 equality'
  end if

  if (FLAG_03 /= iand(b, FLAG_03)) then
    stop 'error at FLAG_01 FLAG_03 equality'
  end if

  if (FLAG_04 == iand(b, FLAG_04)) then
    stop 'error at FLAG_01 FLAG_03 equality'
  end if

  if (FLAG_05 == iand(b, FLAG_05)) then
    stop 'error at FLAG_01 FLAG_03 equality'
  end if

  if (FLAG_06 == iand(b, FLAG_06)) then
    stop 'error at FLAG_01 FLAG_03 equality'
  end if

  b = ior(FLAG_01, FLAG_04)
  if (FLAG_00 == iand(b, FLAG_00)) then
    stop 'error at FLAG_01 FLAG_04 equality'
  end if

  if (FLAG_01 /= iand(b, FLAG_01)) then
    stop 'error at FLAG_01 FLAG_04 equality'
  end if

  if (FLAG_02 == iand(b, FLAG_02)) then
    stop 'error at FLAG_01 FLAG_04 equality'
  end if

  if (FLAG_03 == iand(b, FLAG_03)) then
    stop 'error at FLAG_01 FLAG_04 equality'
  end if

  if (FLAG_04 /= iand(b, FLAG_04)) then
    stop 'error at FLAG_01 FLAG_04 equality'
  end if

  if (FLAG_05 == iand(b, FLAG_05)) then
    stop 'error at FLAG_01 FLAG_04 equality'
  end if

  if (FLAG_06 == iand(b, FLAG_06)) then
    stop 'error at FLAG_01 FLAG_04 equality'
  end if

  b = ior(FLAG_01, FLAG_05)
  if (FLAG_00 == iand(b, FLAG_00)) then
    stop 'error at FLAG_01 FLAG_05 equality'
  end if

  if (FLAG_01 /= iand(b, FLAG_01)) then
    stop 'error at FLAG_01 FLAG_05 equality'
  end if

  if (FLAG_02 == iand(b, FLAG_02)) then
    stop 'error at FLAG_01 FLAG_05 equality'
  end if

  if (FLAG_03 == iand(b, FLAG_03)) then
    stop 'error at FLAG_01 FLAG_05 equality'
  end if

  if (FLAG_04 == iand(b, FLAG_04)) then
    stop 'error at FLAG_01 FLAG_05 equality'
  end if

  if (FLAG_05 /= iand(b, FLAG_05)) then
    stop 'error at FLAG_01 FLAG_05 equality'
  end if

  if (FLAG_06 == iand(b, FLAG_06)) then
    stop 'error at FLAG_01 FLAG_05 equality'
  end if

  b = ior(FLAG_01, FLAG_06)
  if (FLAG_00 == iand(b, FLAG_00)) then
    stop 'error at FLAG_01 FLAG_06 equality'
  end if

  if (FLAG_01 /= iand(b, FLAG_01)) then
    stop 'error at FLAG_01 FLAG_06 equality'
  end if

  if (FLAG_02 == iand(b, FLAG_02)) then
    stop 'error at FLAG_01 FLAG_06 equality'
  end if

  if (FLAG_03 == iand(b, FLAG_03)) then
    stop 'error at FLAG_01 FLAG_06 equality'
  end if

  if (FLAG_04 == iand(b, FLAG_04)) then
    stop 'error at FLAG_01 FLAG_06 equality'
  end if

  if (FLAG_05 == iand(b, FLAG_05)) then
    stop 'error at FLAG_01 FLAG_06 equality'
  end if

  if (FLAG_06 /= iand(b, FLAG_06)) then
    stop 'error at FLAG_01 FLAG_06 equality'
  end if

  b = ior(FLAG_02, FLAG_03)
  if (FLAG_00 == iand(b, FLAG_00)) then
    stop 'error at FLAG_02 FLAG_03 equality'
  end if

  if (FLAG_01 == iand(b, FLAG_01)) then
    stop 'error at FLAG_02 FLAG_03 equality'
  end if

  if (FLAG_02 /= iand(b, FLAG_02)) then
    stop 'error at FLAG_02 FLAG_03 equality'
  end if

  if (FLAG_03 /= iand(b, FLAG_03)) then
    stop 'error at FLAG_02 FLAG_03 equality'
  end if

  if (FLAG_04 == iand(b, FLAG_04)) then
    stop 'error at FLAG_02 FLAG_03 equality'
  end if

  if (FLAG_05 == iand(b, FLAG_05)) then
    stop 'error at FLAG_02 FLAG_03 equality'
  end if

  if (FLAG_06 == iand(b, FLAG_06)) then
    stop 'error at FLAG_02 FLAG_03 equality'
  end if

  b = ior(FLAG_02, FLAG_04)
  if (FLAG_00 == iand(b, FLAG_00)) then
    stop 'error at FLAG_02 FLAG_04 equality'
  end if

  if (FLAG_01 == iand(b, FLAG_01)) then
    stop 'error at FLAG_02 FLAG_04 equality'
  end if

  if (FLAG_02 /= iand(b, FLAG_02)) then
    stop 'error at FLAG_02 FLAG_04 equality'
  end if

  if (FLAG_03 == iand(b, FLAG_03)) then
    stop 'error at FLAG_02 FLAG_04 equality'
  end if

  if (FLAG_04 /= iand(b, FLAG_04)) then
    stop 'error at FLAG_02 FLAG_04 equality'
  end if

  if (FLAG_05 == iand(b, FLAG_05)) then
    stop 'error at FLAG_02 FLAG_04 equality'
  end if

  if (FLAG_06 == iand(b, FLAG_06)) then
    stop 'error at FLAG_02 FLAG_04 equality'
  end if

  b = ior(FLAG_02, FLAG_05)
  if (FLAG_00 == iand(b, FLAG_00)) then
    stop 'error at FLAG_02 FLAG_05 equality'
  end if

  if (FLAG_01 == iand(b, FLAG_01)) then
    stop 'error at FLAG_02 FLAG_05 equality'
  end if

  if (FLAG_02 /= iand(b, FLAG_02)) then
    stop 'error at FLAG_02 FLAG_05 equality'
  end if

  if (FLAG_03 == iand(b, FLAG_03)) then
    stop 'error at FLAG_02 FLAG_05 equality'
  end if

  if (FLAG_04 == iand(b, FLAG_04)) then
    stop 'error at FLAG_02 FLAG_05 equality'
  end if

  if (FLAG_05 /= iand(b, FLAG_05)) then
    stop 'error at FLAG_02 FLAG_05 equality'
  end if

  if (FLAG_06 == iand(b, FLAG_06)) then
    stop 'error at FLAG_02 FLAG_05 equality'
  end if

  b = ior(FLAG_02, FLAG_06)
  if (FLAG_00 == iand(b, FLAG_00)) then
    stop 'error at FLAG_02 FLAG_06 equality'
  end if

  if (FLAG_01 == iand(b, FLAG_01)) then
    stop 'error at FLAG_02 FLAG_06 equality'
  end if

  if (FLAG_02 /= iand(b, FLAG_02)) then
    stop 'error at FLAG_02 FLAG_06 equality'
  end if

  if (FLAG_03 == iand(b, FLAG_03)) then
    stop 'error at FLAG_02 FLAG_06 equality'
  end if

  if (FLAG_04 == iand(b, FLAG_04)) then
    stop 'error at FLAG_02 FLAG_06 equality'
  end if

  if (FLAG_05 == iand(b, FLAG_05)) then
    stop 'error at FLAG_02 FLAG_06 equality'
  end if

  if (FLAG_06 /= iand(b, FLAG_06)) then
    stop 'error at FLAG_02 FLAG_06 equality'
  end if

  b = ior(FLAG_03, FLAG_04)
  if (FLAG_00 == iand(b, FLAG_00)) then
    stop 'error at FLAG_03 FLAG_04 equality'
  end if

  if (FLAG_01 == iand(b, FLAG_01)) then
    stop 'error at FLAG_03 FLAG_04 equality'
  end if

  if (FLAG_02 == iand(b, FLAG_02)) then
    stop 'error at FLAG_03 FLAG_04 equality'
  end if

  if (FLAG_03 /= iand(b, FLAG_03)) then
    stop 'error at FLAG_03 FLAG_04 equality'
  end if

  if (FLAG_04 /= iand(b, FLAG_04)) then
    stop 'error at FLAG_03 FLAG_04 equality'
  end if

  if (FLAG_05 == iand(b, FLAG_05)) then
    stop 'error at FLAG_03 FLAG_04 equality'
  end if

  if (FLAG_06 == iand(b, FLAG_06)) then
    stop 'error at FLAG_03 FLAG_04 equality'
  end if

  b = ior(FLAG_03, FLAG_05)
  if (FLAG_00 == iand(b, FLAG_00)) then
    stop 'error at FLAG_03 FLAG_05 equality'
  end if

  if (FLAG_01 == iand(b, FLAG_01)) then
    stop 'error at FLAG_03 FLAG_05 equality'
  end if

  if (FLAG_02 == iand(b, FLAG_02)) then
    stop 'error at FLAG_03 FLAG_05 equality'
  end if

  if (FLAG_03 /= iand(b, FLAG_03)) then
    stop 'error at FLAG_03 FLAG_05 equality'
  end if

  if (FLAG_04 == iand(b, FLAG_04)) then
    stop 'error at FLAG_03 FLAG_05 equality'
  end if

  if (FLAG_05 /= iand(b, FLAG_05)) then
    stop 'error at FLAG_03 FLAG_05 equality'
  end if

  if (FLAG_06 == iand(b, FLAG_06)) then
    stop 'error at FLAG_03 FLAG_05 equality'
  end if

  b = ior(FLAG_03, FLAG_06)
  if (FLAG_00 == iand(b, FLAG_00)) then
    stop 'error at FLAG_03 FLAG_06 equality'
  end if

  if (FLAG_01 == iand(b, FLAG_01)) then
    stop 'error at FLAG_03 FLAG_06 equality'
  end if

  if (FLAG_02 == iand(b, FLAG_02)) then
    stop 'error at FLAG_03 FLAG_06 equality'
  end if

  if (FLAG_03 /= iand(b, FLAG_03)) then
    stop 'error at FLAG_03 FLAG_06 equality'
  end if

  if (FLAG_04 == iand(b, FLAG_04)) then
    stop 'error at FLAG_03 FLAG_06 equality'
  end if

  if (FLAG_05 == iand(b, FLAG_05)) then
    stop 'error at FLAG_03 FLAG_06 equality'
  end if

  if (FLAG_06 /= iand(b, FLAG_06)) then
    stop 'error at FLAG_03 FLAG_06 equality'
  end if

  b = ior(FLAG_04, FLAG_05)
  if (FLAG_00 == iand(b, FLAG_00)) then
    stop 'error at FLAG_04 FLAG_05 equality'
  end if

  if (FLAG_01 == iand(b, FLAG_01)) then
    stop 'error at FLAG_04 FLAG_05 equality'
  end if

  if (FLAG_02 == iand(b, FLAG_02)) then
    stop 'error at FLAG_04 FLAG_05 equality'
  end if

  if (FLAG_03 == iand(b, FLAG_03)) then
    stop 'error at FLAG_04 FLAG_05 equality'
  end if

  if (FLAG_04 /= iand(b, FLAG_04)) then
    stop 'error at FLAG_04 FLAG_05 equality'
  end if

  if (FLAG_05 /= iand(b, FLAG_05)) then
    stop 'error at FLAG_04 FLAG_05 equality'
  end if

  if (FLAG_06 == iand(b, FLAG_06)) then
    stop 'error at FLAG_04 FLAG_05 equality'
  end if

  b = ior(FLAG_04, FLAG_06)
  if (FLAG_00 == iand(b, FLAG_00)) then
    stop 'error at FLAG_04 FLAG_06 equality'
  end if

  if (FLAG_01 == iand(b, FLAG_01)) then
    stop 'error at FLAG_04 FLAG_06 equality'
  end if

  if (FLAG_02 == iand(b, FLAG_02)) then
    stop 'error at FLAG_04 FLAG_06 equality'
  end if

  if (FLAG_03 == iand(b, FLAG_03)) then
    stop 'error at FLAG_04 FLAG_06 equality'
  end if

  if (FLAG_04 /= iand(b, FLAG_04)) then
    stop 'error at FLAG_04 FLAG_06 equality'
  end if

  if (FLAG_05 == iand(b, FLAG_05)) then
    stop 'error at FLAG_04 FLAG_06 equality'
  end if

  if (FLAG_06 /= iand(b, FLAG_06)) then
    stop 'error at FLAG_04 FLAG_06 equality'
  end if

  b = ior(FLAG_05, FLAG_06)
  if (FLAG_00 == iand(b, FLAG_00)) then
    stop 'error at FLAG_05 FLAG_06 equality'
  end if

  if (FLAG_01 == iand(b, FLAG_01)) then
    stop 'error at FLAG_05 FLAG_06 equality'
  end if

  if (FLAG_02 == iand(b, FLAG_02)) then
    stop 'error at FLAG_05 FLAG_06 equality'
  end if

  if (FLAG_03 == iand(b, FLAG_03)) then
    stop 'error at FLAG_05 FLAG_06 equality'
  end if

  if (FLAG_04 == iand(b, FLAG_04)) then
    stop 'error at FLAG_05 FLAG_06 equality'
  end if

  if (FLAG_05 /= iand(b, FLAG_05)) then
    stop 'error at FLAG_05 FLAG_06 equality'
  end if

  if (FLAG_06 /= iand(b, FLAG_06)) then
    stop 'error at FLAG_05 FLAG_06 equality'
  end if
contains
  subroutine show_comparison
  write(*,'(7(l2))') &

    FLAG_00 == iand(b, FLAG_00), &
    FLAG_01 == iand(b, FLAG_01), &
    FLAG_02 == iand(b, FLAG_02), &
    FLAG_03 == iand(b, FLAG_03), &
    FLAG_04 == iand(b, FLAG_04), &
    FLAG_05 == iand(b, FLAG_05), &
    FLAG_06 == iand(b, FLAG_06)
  end subroutine show_comparison

end program bm_test

