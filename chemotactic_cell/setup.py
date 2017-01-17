from distutils.core import setup
from distutils.extension import Extension
from Cython.Distutils import build_ext

import numpy as np
import os.path
from numpy.random import mtrand

setup(
    cmdclass = {'build_ext': build_ext},
    ext_modules = [Extension("stochastic_nanomotor", ["stochastic_nanomotor_module.pyx"], extra_objects = [mtrand.__file__])],
    include_dirs=[os.path.dirname(np.random.__file__)],
)
