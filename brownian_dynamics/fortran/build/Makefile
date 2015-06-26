
FC=gfortran
FCFLAGS=-fpic -O3 -funroll-loops

LD=gcc
LDFLAGS=-shared

all: libbrownian.so

%.o: %.f90
	$(FC) $(FCFLAGS) -c $<

libbrownian.so: brownian.o brownian_wrapper.o mtprng.o stdtypes.o
	$(LD) $(LDFLAGS) -o $@ $^ -lgfortran


