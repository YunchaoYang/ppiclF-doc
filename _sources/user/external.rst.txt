.. _external:

------------------
External Interface
------------------

The following subroutines and variables can be called from an external program's pre-compilation source code. The source code may be found in an appilcation that you are linking ppiclF to (see :ref:`Nek5000_example`) or a simple driver program that links to ppiclF (see :ref:`stokes2d`).

In what follows, the terms *int* and *real* refer to the Fortran integer*4 and real*8 types, which are also the types int and double in C.

Common Variables
^^^^^^^^^^^^^^^^
The following common variables are stored in memory internally. In the current verision, **ppiclf_pro_fld** may be accessed in an externally linked program through the calling of the subroutine **ppiclf_solve_GetProFldIJKEF()** as defined at the end of this section. However, the table below shows some of the key variables that can be used for internal development of the ppiclF library.

.. code-block:: fortran

   include "PPICLF"

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
.. admonition:: ppiclf_solve_InitTargetBins(char*1 **dir**, int n, int balance)

   The user specifies that **n** bins be created in the **dir** dimension. When **balance** is set to 1, the bins are evenly distributed about the mean particle position in **dir**. If any rule is violated, such as there are too many bins or the bins are too small, the binning algorithm will change **n** so that the rules are not violated.

   * **dir** = 'x', 'y', or 'z'.
   * **n** :math:`\geq` 1.
   * **balance** = 0 or 1

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

   The user also initializes :math:`\mathbf{Y}_0`, which is the initial condition of :math:`\mathbf{Y}` for the system of equations. The user also sets the integration method **imethod**, the problem dimension **ndim**, the byte ordering **iendian**, and the number of particles being initializied on the current rank **npart**. The arrays **y** and **rprop** must be ordered as ppiclf_y(j,i) and ppiclf_rprop(j,i) since they are internally copied when this routine is called.
 
   * **imethod** = +/-1 (RK3). When **imethod** is negative, the user is in chage of looping through both steps **AND** stages.
   * **ndim** = 2 or 3.
   * **iendian** = 0 (little endian) or 1 (big endian).
   * 0 :math:`\leq` **npart** :math:`\leq` PPICLF_LPART.

..
..
.. admonition:: ppiclf_solve_AddParticles(int **npart**, real **y**, real **rprop**)

   After ppiclf_solve_InitParticle has been called, this routine may be called to add particles into the current simulation at any time. The arrays **y** and **rprop** have the same interpretation as in ppiclf_solve_InitParticle.
 
   * 0 :math:`\leq` **npart** :math:`\leq` PPICLF_LPART.

..
..
.. admonition:: ppiclf_solve_MarkForRemoval(int **i**)

   While particles are automatically removed when they are located outside of an overlap mesh when specified, this routine allows a user to forcibly remove a particle based on any critieria. Calling this routine during a simulation will remove the **i** particle from the arrays ppiclf_y(j,i) and ppiclf_rprop(j,i).
 
   * 1 :math:`\leq` **i** :math:`\leq` ppiclf_npart


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

..
..
.. admonition:: ppiclf_solve_GetProFldIJKEF(int **i**, int **j**, int **k**, int **e**, int **m**, real **fld**)

   This routine may be called on the **i**, **j**, **k** grid point of the **e** element of the overlap mesh. The index **m** is the desired projected field index (which is user defined in the H-File) which is returned at the selected grid point in **fld**. This routine allows external access of the internal array **ppiclf_pro_fld**.
 
   * **i** :math:`\leq` PPICLF_LEX
   * **j** :math:`\leq` PPICLF_LEY
   * **k** :math:`\leq` PPICLF_LEZ
   * **e** :math:`\leq` PPICLF_NEE :math:`\leq` PPICLF_LEE
   * **m** :math:`\leq` PPICLF_LRP_PRO
