#!/usr/bin/env python3
# Author: Pierre de Buyl
# License: 3-clause BSD
"""Generate a test program for Fortran bitmasks.

The tests use selected_real_kind(KIND_SELECTOR) to select an integer kind.

The program will create n independent bitmasks, using either `integer(kind=ik),
parameter = ibset(0, i)` or `integer(kind=ik), parameter = b'01'` if the option
'--boz' is selected.

"""
from __future__ import print_function, division
import itertools
import argparse

parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('n', help='Number of bits in the bitmask', type=int)
parser.add_argument('--kind-selector', type=int, default=3,
                    help='Argument to selected_int_kind')
parser.add_argument('--do-triple', help='Perform three by three checks',
                    action='store_true')
parser.add_argument('--boz',
                    help='Use binary BOZ constants to define the bitmasks',
                    action='store_true')
args = parser.parse_args()


class Bitmask(object):
    """Bitmasks for Fortran.

    The routines print bitmasks either using BOZ constants or ibset(0, i).
    """

    def __init__(self, size, boz):
        """Initialize the bitmask class."""
        self._size = size
        self._boz = boz

    def get_boz_mask(self, i):
        """Return the definition of the i-th bitmask as a binary constant."""
        s = ['0']*self._size
        s[self._size-i-1] = '1'
        return "b'"+''.join(s)+"'"

    def get_ibset_mask(self, i):
        """Return the definition of the i-th bitmask using ibset."""
        return 'ibset(0, {})'.format(i)

    def get_mask(self, i):
        """Return the definition of the i-th bitmask."""
        if self._boz:
            return self.get_boz_mask(i)
        else:
            return self.get_ibset_mask(i)

    @property
    def size(self):
        """Return the size of the bitmasks."""
        return self._size

    @property
    def indices(self):
        """Return all indices for the list of bitmasks."""
        return range(self.size)


bm = Bitmask(args.n, boz=args.boz)

p = """! This program was created by generate_bitmasks_tests.py
! by Pierre de Buyl
program bm_test
  implicit none

  integer, parameter :: ik = selected_int_kind({R})
""".format(R=args.kind_selector)

for i in bm.indices:
    p += """  integer(kind=ik), parameter :: FLAG_{i:02d} = {mask}\n""".format(i=i, mask=bm.get_mask(i))

p += """
  integer(kind=ik) :: b

  write(*,*) 'selected_int_kind({R}) =', ik
  write(*,*) 'storage_size(b) = ', storage_size(b), 'bits'
""".format(R=args.kind_selector)

for i in bm.indices:
    p += """  b = FLAG_{i:02d}
  write(*,*) 'FLAG_{i:02d} = ', b
""".format(i=i)

for i in bm.indices:
    p += """  b = FLAG_{i:02d}
  call show_comparison
  if (b == 0) then
    stop 'error at FLAG_{i:02d} test for zero'
  end if
  if (FLAG_{i:02d} /= iand(b, FLAG_{i:02d})) then
    stop 'error at FLAG_{i:02d} equality'
  end if
""".format(i=i)


for i, j in itertools.combinations(bm.indices, 2):
    p += """
  b = ior(FLAG_{i:02d}, FLAG_{j:02d})""".format(i=i, j=j)
    for k in bm.indices:
        if k==i or k==j:
            cmp = '/='
        else:
            cmp = '=='
        p += """
  if (FLAG_{k:02d} {cmp} iand(b, FLAG_{k:02d})) then
    stop 'error at FLAG_{i:02d} FLAG_{j:02d} equality'
  end if
""".format(i=i, j=j, k=k, cmp=cmp)

if args.do_triple:
    for i, j, k in itertools.combinations(bm.indices, 3):
        p += """
      b = ior(FLAG_{i:02d}, ior(FLAG_{j:02d}, FLAG_{k:02d}))""".format(i=i, j=j, k=k)
        for l in bm.indices:
            if l==i or l==j or l==k:
                cmp = '/='
            else:
                cmp = '=='
            p += """
      if (FLAG_{l:02d} {cmp} iand(b, FLAG_{l:02d})) then
        stop 'error at FLAG_{i:02d} FLAG_{j:02d} FLAG_{k:02d} equality'
      end if
    """.format(i=i, j=j, k=k, l=l, cmp=cmp)

p += """contains
  subroutine show_comparison
  write(*,'({i}(l2))') &
""".format(i=bm.size)

for i in bm.indices[:-1]:
    p += """
    FLAG_{i:02d} == iand(b, FLAG_{i:02d}), &""".format(i=i)

i = bm.indices[-1]
p += """
    FLAG_{i:02d} == iand(b, FLAG_{i:02d})""".format(i=i)

p += """
  end subroutine show_comparison

end program bm_test
"""

print(p)
