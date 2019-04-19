.. _build:

-----
Build
-----

To install ppiclF, checkout the master branch from the `offical GitHub repository <https://github.com/dpzwick/ppiclF>`_. First, create a local directory where the souce code will be copied to. Here, we will call this LocalCodeDir:

.. code:: bash

    cd LocalCodeDir
    git clone https://github.com/dpzwick/ppiclF.git
    cd ppiclF

Then, set the appropriate properties in the files source/ppiclf_user.f and source/PPICLF_USER.h (see :ref:`hfile` and :ref:`ffile`). For now, we will copy these files from an existing example:

.. code:: bash

    cp examples/stokes_2d/user_source/ppiclf_user.f source/
    cp examples/stokes_2d/user_source/PPICLF_USER.h source/

Now, set the appropriate parameters in the Makefile. Either mpif77 or mpif90 are supported Fortran compilers. Note that mpicc is also required for a 3rd party library internally. 

If you are compiling for a C or C++ applicaiton, add the flag -DPPICLC to the FFLAGS variable in the Makefile for correct bindings. The code can then be built with:

.. code:: bash

    make

Upon successful compilation, you should see the following output:

.. code:: bash

    ***********************
    *** LIBRARY SUCCESS ***
    ***********************
