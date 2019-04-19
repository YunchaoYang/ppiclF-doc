.. _external:

------------------
External Interface
------------------

The following subroutines and variables can be called from an external program's pre-compilation source code. The source code may be found in an appilcation that you are linking ppiclF to (see :ref:`Nek5000_example`) or a simple driver program that links to ppiclF (see :ref:`stokes2d`).

In what follows, the terms *int* and *real* refer to the Fortran integer*4 and real*8 types, which are also the types int and double in C.

Common Variables
^^^^^^^^^^^^^^^^
The following common variables are stored in memory and may be included by adding the following directive to the top of a routine.

.. code-block:: fortran

   #include "PPICLF.h"

.. table:: Common variables used and their descriptions.
   :align: center

   +---------------------------+------+--------------------------------------------------------------------------------------------------------+
   | Name                      | Type | Description                                                                                            |
   +===========================+======+========================================================================================================+
   | ppiclf_y(j,i)             | real | Array of j equations solution for i particle (:math:`\mathbf{Y}^{(i)}`).                               |
   +---------------------------+------+--------------------------------------------------------------------------------------------------------+
   | ppiclf_ydot(j,i)          | real | Array of j equations forcing for i particle (:math:`\dot{\mathbf{Y}}^{(i)}`).                          |
   +---------------------------+------+--------------------------------------------------------------------------------------------------------+
   | ppiclf_ydotc(j,i)         | real | Array of j equations extra storage for i particle.                                                     |
   +---------------------------+------+--------------------------------------------------------------------------------------------------------+
   | ppiclf_rprop(j,i)         | real | Array of j properties for i particle.                                                                  |
   +---------------------------+------+--------------------------------------------------------------------------------------------------------+
   | ppiclf_npart              | int  | The number of local particles on the current processor.                                                |
   +---------------------------+------+--------------------------------------------------------------------------------------------------------+
   | ppiclf_pro_fld(i,j,k,e,m) | real | Projected field m at overlap mesh point (i,j,k) on element e.                                          |
   +---------------------------+------+--------------------------------------------------------------------------------------------------------+


Initialization Subroutines
^^^^^^^^^^^^^^^^^^^^^^^^^^
The following subroutines are only to be called once at the begining of a simulation. Note that every routine does not need to be called. The actual subroutines called at setup are problem dependent. However, the subroutines **ppiclf_comm_InitMPI** and **ppiclf_solve_InitParticle** must be called at least once at initialization for every case.

..
..
.. admonition:: ppiclf_comm_InitMPI(int **comm**, int **id**, int **np**)
   
   The user inputs the current MPI communicator **comm** where the current MPI rank is **id** and there are **np** total ranks.

..
..
.. admonition:: ppiclf_comm_InitOverlapMesh(int **ncell**, int **lx**, int **ly**, int **lz**, real **xgrid**, real **ygrid**, real **zgrid**)

   The user inputs the element based mesh. The arrays **xgrid**, **ygrid**, and **zgrid** are of size (**lx,ly,lz,ncell**) and stores the mesh coordinates. Here, **ncell** is the number of local hexahedral elements on rank **id**, with **lx,ly,lz** points in each dimension.

   * **ncell** :math:`\leq` PPICLF_LEE.
   * **lx** == PPICLF_LEX.
   * **ly** == PPICLF_LEY.
   * **lz** == PPICLF_LEZ.

..
..
.. admonition:: ppiclf_io_ReadParticleVTU(char*1 **filein(132)**)

   The user specifies **filein** with .vtu extension to use as the initial conditions for particles. When this routine is called, the arrays ppiclf_y(j,i) and ppiclf_rprop(j,i) will automatically be filled. 

   * Note that ppiclf_solve_InitParticle should still be called following this, but with a dummy arguement in place of **y** and **rprop**.

..
..
.. admonition:: ppiclf_io_ReadWallVTK(char*1 **filein(132)**)

   The user specifies **filein** with .vtk extension to use as triangular plane boundaries.

   The format of the file is a minimized ASCII VTK format as shown below.

   In 3D:

   .. code::

      POINTS npoints
      p1x p1y p1z
      p2x p2y p2z
      ...
      CELLS ncells
      n1ip1 n1ip2 n1ip3
      n2ip1 n2ip2 n2ip3
      ...

   and in 2D:

   .. code:: 

      POINTS npoints
      p1x p1y p1z
      p2x p2y p2z
      ...
      CELLS ncells
      n1ip1 n1ip2
      n2ip1 n2ip2
      ...

   where:

   * a tri-element surface mesh is required in 3D problems,
   * a line-element surface mesh is required in 2D problems,
   * npoints is total number of points that follow,
   * pab is point a coordinate in b dimension,
   * nwalls is total number of walls that follow,
   * ncipd is the index of the points from 0 to npoints-1 that make up the wall with c being the wall number and d being the arbitrary ordering of points.

   This format can actually be output using the free finite element mesh generator Gmsh_. The process is to create the appropriate mesh, export as a VTK file, and then remove everything except the format as specified above. **Please make sure there are no blank lines in file.**

.. _Gmsh: https://gmsh.info

..
..
.. admonition:: ppiclf_solve_InitWall(real **xp1**, real **xp2**, real **xp3**)

   The user manually sets a boundary. This is similar to ppiclf_io_ReadWallVTK, but the user may only want to manually set a single or few walls manually without a VTK file.

   * The inputs are all vectors of length two (2D) or three (3D).
   * **xp1** stores coordinates (p1x, p1y, p1z) as in the VTK file.
   * **xp2** stores coordinates (p2x, p2y, p2z) as in the VTK file.
   * **xp3** stores coordinates (p3x, p3y, p3z) as in the VTK file.

..
..
.. admonition:: ppiclf_solve_InitNeighborBin(real **W**)

   The user specifies **W** as the minimum interaction distance to resolve. See :ref:`part-storage`.

..
..
.. admonition:: ppiclf_solve_InitSuggestedDir(char*1 **dir**)

   The user inputs **dir** dimension which lets the bin generation algorithm attempt to create more bins in chosen dimension.

   * **dir** = 'x', 'y', or 'z'.

..
..
.. admonition:: ppiclf_solve_InitPeriodicX(real **a**, real **b**)

   * The user sets periodicity in the y-z planes at x = **a** and x = **b**.
   * Note: **a** < **b**.

..
..
.. admonition:: ppiclf_solve_InitPeriodicY(real **a**, real **b**)

   The user sets periodicity in the x-z planes at y = **a** and y = **b**. 

   * **a** < **b**.

..
..
.. admonition:: ppiclf_solve_InitPeriodicZ(real **a**, real **b**)

   The user sets periodicity in the x-y planes at z = **a** and z = **b**. 

   * **a** < **b**.

..
..
.. admonition:: ppiclf_solve_InitGaussianFilter(real **f**, real **a**, int **iflg**)

   The Gaussian filter half-width for projection :math:`\delta_f` is **f** (see :ref:`overlap-mesh`). The value **a** is the percent of the r = 0 value that the Gaussian filter is computationally allowed to decay to. The flag **iflg** sets if particles should be mirrored and then projected across boundaries or not.
   
   * **a** < 1.0.
   * **iflg** = 0 (no mirror) or 1 (mirror).

..
..
.. admonition:: ppiclf_solve_InitBoxFilter(real **f**, int **iflg**)

   The box filter half-width for projection :math:`\delta_f` is **f** (see :ref:`overlap-mesh`). The flag **iflg** sets if particles should be mirrored and then projected across boundaries or not.
   
   * **iflg** = 0 (no mirror) or 1 (mirror).

..
..
.. admonition:: ppiclf_solve_InitParticle(int **imethod**, int **ndim**, int **iendian**, int **npart**, real **y**, real **rprop**)

   The user also initializes :math:`\mathbf{Y}_0`, which is the initial condition of :math:`\mathbf{Y}` for the system of equations. The user also sets the integration method **imethod**, the problem dimension **ndim**, the byte ordering **iendian**, and the number of particles being initializied on the current rank **npart**.
 
   * **imethod** = +/-1 (RK3). When **imethod** is negative, the user is in chage of looping through both steps **AND** stages.
   * **ndim** = 2 or 3.
   * **iendian** = 0 (little endian) or 1 (big endian).
   * **npart** :math:`\geq` 0.



Solve Subroutines
^^^^^^^^^^^^^^^^^
The following subroutines can be called at every time step. Note that every routine does not need to be called. The actual subroutines called at each time step are problem dependent. However, the subroutine **ppiclf_solve_IntegrateParticle** must be called at least once every time step for any opperations to be performed.

..
..
.. admonition:: ppiclf_solve_InterpFieldUser(int **ifld**, real **fld**)

   The user sets which field array **fld** of same dimensions set in initialization call to ppiclf_comm_InitOverlapMesh routine is used to interpolate to index in property array ppiclf_rprop(**ifld**,i) for the i particle. This routine may be called multiple times to interpolate multiple fields.
 
   * **ifld** :math:`\leq` PPICLF_LRP.

..
..
.. admonition:: ppiclf_solve_IntegrateParticle(int **istep**, int **iostep**, real **dt**, real **time**)

   This routine must be called every time step and uses the initial integration method to advance :math:`\mathbf{Y}` in time. The inputs are the current **time**, the current time step **dt** to advance by, the current time step number **istep**, and will output solution files every **iostep** number of time steps. Note that the user must call this routine every time step for the system to be integrated. When **imethod** is initialized to be a negative number, this routine must also be called every stage as well.
 
   * **istep** :math:`\geq` 0.
   * **iostep** :math:`\geq` 0.
   * **dt** :math:`\geq` 0.0.
   * **time** :math:`\geq` 0.0.

