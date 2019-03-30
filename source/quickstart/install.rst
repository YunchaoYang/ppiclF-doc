.. _installing:

----------
Installing
----------

To install ppiclF, checkout the master branch from the `offical GitHub repository <https://github.com/dpzwick/ppiclF>`_. First, create a local directory where the souce code will be copied to. Here, we will call this LocalCodeDir:

.. code:: bash

    cd LocalCodeDir
    git clone https://github.com/dpzwick/ppiclF 
    cd ppiclF

Then, set the appropriate properties in the files source/ppiclf_user.f and source/ppiclf_user.h (see **here**). For now, we will copy these files from an existing example:

.. code:: bash

    cp examples/stokes_2d/user_source/ppiclf_user.f source/
    cp examples/stokes_2d/user_source/ppiclf_user.h source/

Now, set the appropriate parameters in the Makefile. For now, the only compiler supported is mpif77. Note that mpicc is also required for a 3rd party library. Due to this, the current Makefile does not need to be modified can the ppiclF library can be built by:

.. code:: bash

    make

Upon successful compilation, you should see the following output:

.. code:: bash

    ***********************
    *** LIBRARY SUCCESS ***
    ***********************
