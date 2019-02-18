FC=gfortran
#FCFLAGS=-fno-range-check

all: autotest

autotest: autotest.f90
	$(FC) $(FCFLAGS) -o $@ $<

bitmask_test: bitmask_test.f90
	$(FC) $(FCFLAGS) -o $@ $<

example_bitmasks: example_bitmasks.f90
	$(FC) $(FCFLAGS) -o $@ $<

storage_size: storage_size.f90
	$(FC) $(FCFLAGS) -o $@ $<

test_bitfield: test_bitfield.f90
	$(FC) $(FCFLAGS) -o $@ $<

shortc: shortc.c
	$(CC) -o $@ $<
