from distutils.core import setup
from distutils.extension import Extension
from Cython.Distutils import build_ext

import os.path

here = os.path.dirname(os.path.abspath(__file__))
obj_dir = 'build'

fortran_objects = [ os.path.join(here,obj_dir,o_name) for o_name in [ "brownian.o", "brownian_wrapper.o", "mtprng.o", "stdtypes.o" ]]

ext_modules = [
    Extension("brownian_wrapper",
              ["brownian_wrapper.pyx"],
              libraries=['brownian', 'gfortran'],
              library_dirs=[here],
              runtime_library_dirs=[here],
              )
]

setup(
    name="brownian_wrapper",
    cmdclass={"build_ext": build_ext},
    ext_modules=ext_modules)
