
VPATH=../
FC=gfortran
FCFLAGS=-fpic -O3 -funroll-loops

LD=gcc
LDFLAGS=-shared

all: libbrownian.so

%.o: %.f90
	$(FC) $(FCFLAGS) -c $<

libbrownian.so: stdtypes.o mtprng.o brownian.o brownian_wrapper.o
	$(LD) $(LDFLAGS) -o $@ $^ -lgfortran


