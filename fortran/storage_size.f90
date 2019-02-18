program storage_test
  implicit none

  integer, parameter :: kind_1 = selected_int_kind(3)
  integer, parameter :: kind_2 = selected_int_kind(8)
  integer, parameter :: kind_3 = selected_int_kind(10)
  integer, parameter :: kind_4 = selected_int_kind(12)

  write(*,*) 'kind selection             kind value    storage size (bits)'
  write(*,*) 'selected_int_kind(3)  = ', kind_1, storage_size(1_kind_1)
  write(*,*) 'selected_int_kind(8)  = ', kind_2, storage_size(1_kind_2)
  write(*,*) 'selected_int_kind(10) = ', kind_3, storage_size(1_kind_3)
  write(*,*) 'selected_int_kind(12) = ', kind_4, storage_size(1_kind_4)

end program storage_test
