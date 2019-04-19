.. _output:

-----------
File Output
-----------
Two different files are output for viewing the solution. The default names for these files are:

1. parXXXXX*.vtu,
2. binXXXXX*.vtu,

where XXXXX refers to a particular file output number ordered from 00001 to the number of output files in a simulation. Each file is in a combined binary/ASCII VTU_ format.

The par-prefixed file stores the solution :math:`\mathbf{Y}` and property arrays of each particle according to the order in :ref:`hfile`. Additionally, a three part tag is given to every particle and also stored in the par files so that any particle can be uniquely identified throughout a simulation. These files can be used to restart from a particular output step by calling the external interface routine ppiclf_io_ReadParticleVTU at initialization.

The bin file stores the volumes enclosed by the bins and how many particles are stored within that bin (see :ref:`part-storage`). This can be useful for analyzing the distribution of particles-to-ranks throughout a simulation.

These files may be viewed and/or post-processed in outside programs, such as VisIt_ or ParaView_.

.. _VTU: https://vtk.org
.. _VisIt: https://wci.llnl.gov/simulation/computer-codes/visit
.. _ParaView: https://paraview.org
