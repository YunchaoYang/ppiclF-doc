.. _linking:

------------------------
Linking to External Code
------------------------

In order to use the ppiclF library that was built in the last step (see :ref:`installing`), the library file source/libppiclF.a must be linked to your existing code. This will be specific to your exisiting code compilation. However, ppiclF may be used on its own as well. An example of this is given in the simple MPI driver program in examples/stokes_2d. We will use this to test the linking. 

First, create a working directory to run a case. We will call this TestCaseDir, and it should be located outside of the cloned GitHub repository ppiclF:

.. code:: bash

    mkdir TestCaseDir

The example case can then be copied from the cloned GitHub code to TestCaseDir

.. code:: bash

    cp -r LocalCodeDir/ppiclF/examples/stokes/* TestCaseDir/
    cd TestCaseDir

Included in this test case is a simple Makefile, a driver program called test.f, and the user_source that was already compiled when we installed the library (see :ref:`installing`).

The Makefile is simple and should be edited as needed. In particular, the variable PPICLF_LOCATION may need to be changed to match the location that was set as LocalCodeDir/ppiclF.

The driver program is found in test.f and is explained in further detail **here**.

The user source files in user_source/ can be edited, copied to LocalCodeDir/ppiclF/source/, and the library can be reinstalled (see :ref:`installing`) if changes need to be made to either of these files.

