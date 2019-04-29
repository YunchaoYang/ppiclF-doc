.. _linking:

----
Link
----

In order to use the ppiclF library that was built in the last step (see :ref:`build`), the library file source/libppiclF.a must be linked to your existing code. This will be specific to your exisiting code compilation. The process of linking will generally involve adding "-I LocalCodeDir/ppiclF/source" to the compiler flags and "-L LocalCodeDir/ppiclF/source -lppiclF" to the linking flags.

Alternatively, ppiclF may be used on its own as well. Both a Fortran and C++ example of this is given in the simple MPI driver program example :ref:`stokes2d`. We will use the Fortran program to test the linking. 

First, create a working directory to run the test case. We will call this TestCaseDir, and it should be located outside of the cloned GitHub repository ppiclF:

.. code:: bash

    mkdir TestCaseDir

The example case can then be copied from the cloned GitHub code to TestCaseDir

.. code:: bash

    cp -r LocalCodeDir/ppiclF/examples/stokes_2d/fortran/* TestCaseDir/
    cd TestCaseDir

Included in this test case is a Makefile and a driver program called test.f.

This case may be compiled and linked to ppiclF by setting the variable :code:`PPICLF_LOCATION` in the Makefile to :code:`LocalCodeDir/ppiclF` and using the command

.. code:: bash

    make

The built executable test.out can then be run using your MPI wrapper. For example, the following may be used to run with 4 MPI ranks

.. code:: bash

   mpirun -np 4 test.out

Note the driver program test.f is explained in further detail in the :ref:`stokes2d` example.
