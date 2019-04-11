.. _linking:

----
Link
----

In order to use the ppiclF library that was built in the last step (see :ref:`build`), the library file source/libppiclF.a must be linked to your existing code. This will be specific to your exisiting code compilation. The process of linking will generally involve adding "-I LocalCodeDir/ppiclF/source" to the compiler flags and "-L LocalCodeDir/ppiclF/source -lppiclF" to the linking flags.

Alternatively, ppiclF may be used on its own as well. Both a fortran and C++ example of this is given in the simple MPI driver example found in examples/stokes_2d. We will use the fortran program to test the linking. 

First, create a working directory to run the test case. We will call this TestCaseDir, and it should be located outside of the cloned GitHub repository ppiclF:

.. code:: bash

    mkdir TestCaseDir

The example case can then be copied from the cloned GitHub code to TestCaseDir

.. code:: bash

    cp -r LocalCodeDir/ppiclF/examples/stokes_2d/fortran/* TestCaseDir/
    cd TestCaseDir

Included in this test case is a Makefile and a driver program called test.f.

The Makefile is simple and should be edited as needed. In particular, the variable PPICLF_LOCATION may need to be changed to match the location that was set as LocalCodeDir/ppiclF.

The driver program test.f is explained in further detail in the :ref:`stokes2d` example.
