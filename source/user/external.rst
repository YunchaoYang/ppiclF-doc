.. _external:

------------------
External Interface
------------------

.. table:: Initialization subroutines

   +----------------------------------------------+----------------------------------------------+----------------------------------------------+----------------------------------------------+
   |   Subroutine                                 |   Variables                                  |   Possible Values                            |   Description                                |
   +==============================================+==============================================+==============================================+==============================================+
   | ``ppiclf_comm_InitMPI``                      | | integer*4 ``comm``                         | | --                                         | | The user inputs the current MPI            |
   |                                              | | integer*4 ``id``                           | | --                                         | | communicator ``comm`` where the current    |
   |                                              | | integer*4 ``np``                           | | --                                         | | MPI rank is ``id`` and there are ``np``    |
   |                                              |                                              |                                              | | total ranks.                               |
   |                                              |                                              |                                              |                                              |
   +----------------------------------------------+----------------------------------------------+----------------------------------------------+----------------------------------------------+
   | ``ppiclf_comm_InitOverlapMesh``              | | integer*4 ``ncell``                        | | :math:`\leq` PPICLF_LEE                    | | The user inputs the element based mesh.    |
   |                                              | | integer*4 ``lx``                           | | PPICLF_LEX                                 | | The arrays ``xgrid``, ``ygrid``, and       |
   |                                              | | integer*4 ``ly``                           | | PPICLF_LEY                                 | | ``zgrid`` are of size (``lx,ly,lz,ncell``) |
   |                                              | | integer*4 ``lz``                           | | PPICLF_LEZ                                 | | and stores the mesh coordinates. Here,     |
   |                                              | | real*8    ``xgrid``                        | | --                                         | | ``ncell`` is the number of local           |
   |                                              | | real*8    ``ygrid``                        | | --                                         | | hexahedral elements on rank ``id``,        |
   |                                              | | real*8    ``zgrid``                        | | --                                         | | with ``lx,ly,lz`` points in each dimension.| 
   |                                              |                                              |                                              |                                              |
   +----------------------------------------------+----------------------------------------------+----------------------------------------------+----------------------------------------------+
   | ``ppiclf_io_ReadParticleVTU``                | | char*1 ``filein(132)``                     | | --                                         | | The user specifies ``filein`` with .vtu    |
   |                                              |                                              |                                              | | extension to use as the initial conditions |
   |                                              |                                              |                                              | | for particles.                             |
   |                                              |                                              |                                              |                                              |
   +----------------------------------------------+----------------------------------------------+----------------------------------------------+----------------------------------------------+
   | ``ppiclf_io_ReadWallVTK``                    | | char*1 ``filein(132)``                     | | --                                         | | The user specifies ``filein`` with .vtk    |
   |                                              |                                              |                                              | | extension to use as triangular plane       |
   |                                              |                                              |                                              | | boundaries.                                |
   |                                              |                                              |                                              |                                              |
   +----------------------------------------------+----------------------------------------------+----------------------------------------------+----------------------------------------------+
   | ``ppiclf_solve_InitNeighborBin``             | | real*8  ``W``                              | | NA                                         | | The user specifies ``W`` as the minimum    |
   |                                              |                                              |                                              | | interaction distance to resolve. See       |
   |                                              |                                              |                                              | | :ref:`part-storage`.                       |
   |                                              |                                              |                                              |                                              |
   +----------------------------------------------+----------------------------------------------+----------------------------------------------+----------------------------------------------+
   | ``ppiclf_solve_InitSuggestedDir``            | | char*1 ``dir``                             | | 'x', 'y', 'z'                              | | The user inputs ``dir`` (either x, y, or z)|
   |                                              |                                              |                                              | | which lets the bin generation algorithm    |
   |                                              |                                              |                                              | | attempt to create more bins in chosen      |
   |                                              |                                              |                                              | | dimension.                                 |
   |                                              |                                              |                                              |                                              |
   +----------------------------------------------+----------------------------------------------+----------------------------------------------+----------------------------------------------+
   | ``ppiclf_solve_InitPeriodicX``               | | real*8 ``a``                               | | --                                         | | The user sets periodicity in the y-z       |
   |                                              | | real*8 ``b``                               | | --                                         | | planes at x = ``a`` and x = ``b``. Note    |
   |                                              |                                              |                                              | | that a < b.                                |
   |                                              |                                              |                                              |                                              |
   +----------------------------------------------+----------------------------------------------+----------------------------------------------+----------------------------------------------+
   | ``ppiclf_solve_InitPeriodicY``               | | real*8 ``a``                               | | --                                         | | The user sets periodicity in the x-z       |
   |                                              | | real*8 ``b``                               | | --                                         | | planes at y = ``a`` and y = ``b``. Note    |
   |                                              |                                              |                                              | | that a < b.                                |
   |                                              |                                              |                                              |                                              |
   +----------------------------------------------+----------------------------------------------+----------------------------------------------+----------------------------------------------+
   | ``ppiclf_solve_InitPeriodicZ``               | | real*8 ``a``                               | | --                                         | | The user sets periodicity in the x-y       |
   |                                              | | real*8 ``b``                               | | --                                         | | planes at z = ``a`` and z = ``b``. Note    |
   |                                              |                                              |                                              | | that a < b.                                |
   |                                              |                                              |                                              |                                              |
   +----------------------------------------------+----------------------------------------------+----------------------------------------------+----------------------------------------------+
   | ``ppiclf_solve_InitGaussianFilter``          | | real*8    ``f``                            | | --                                         | | The Gaussian filter half-width for         |
   |                                              | | real*8    ``a``                            | | < 1                                        | | projection :math:`\delta_f` is ``f``       |
   |                                              | | integer*4 ``iflg``                         | | 0 (no mirror), 1 (mirror)                  | | (see :ref:`overlap-mesh`). The value ``a`` |
   |                                              |                                              |                                              | | is the percent of the r = 0 value that     |
   |                                              |                                              |                                              | | the Gaussian filter is computationally     |
   |                                              |                                              |                                              | | allowed to decay to. The flag ``iflg``     |
   |                                              |                                              |                                              | | sets if particles should be mirrored and   |
   |                                              |                                              |                                              | | then projected across boundarees.          |
   |                                              |                                              |                                              |                                              |
   +----------------------------------------------+----------------------------------------------+----------------------------------------------+----------------------------------------------+
   | ``ppiclf_solve_InitBoxFilter``               | | real*8    ``f``                            | | --                                         | | The box filter half-width for              |
   |                                              | | integer*4 ``iflg``                         | | 0 (no mirror), 1 (mirror)                  | | projection :math:`\delta_f` is ``f``       |
   |                                              |                                              |                                              | | (see :ref:`overlap-mesh`). The flag        |
   |                                              |                                              |                                              | | ``iflg`` sets if particles should be       |
   |                                              |                                              |                                              | | mirrored and then projected across         |
   |                                              |                                              |                                              | | boundaries.                                |
   |                                              |                                              |                                              |                                              |
   +----------------------------------------------+----------------------------------------------+----------------------------------------------+----------------------------------------------+
   | ``ppiclf_solve_InitParticle``                | | integer*4 ``imethod``                      | | +/-1 (RK3)                                 | | The user also initializes                  |
   |                                              | | integer*4 ``ndim``                         | | 2, 3                                       | | :math:`\mathbf{Y}_0`, which is the initial |
   |                                              | | integer*4 ``iendian``                      | | 0 (little endian), 1 (big endian)          | | condition of :math:`\mathbf{Y}` for the    |
   |                                              | | integer*4 ``npart``                        | | --                                         | | system of equations. The user also sets    |
   |                                              | | real*8    ``y``                            | | --                                         | | any properties associated with each        |
   |                                              | | real*8    ``rprop``                        | | --                                         | | particle in rprop. The user also sets      |
   |                                              |                                              |                                              | | the integration method ``imethod``, the    |
   |                                              |                                              |                                              | | problem dimension ``ndim``, the byte       |
   |                                              |                                              |                                              | | ordering ``iendian``, and the number of    |
   |                                              |                                              |                                              | | particles being initializied on the        |
   |                                              |                                              |                                              | | current rank ``npart``. When ``imethod``   |
   |                                              |                                              |                                              | | is negative, the user is in chage of       |
   |                                              |                                              |                                              | | looping through both steps **AND** stages. |
   |                                              |                                              |                                              |                                              |
   +----------------------------------------------+----------------------------------------------+----------------------------------------------+----------------------------------------------+

.. table:: Solve subroutines

   +----------------------------------------------+----------------------------------------------+----------------------------------------------+----------------------------------------------+
   |   Subroutine                                 |   Variables                                  |   Possible Values                            |   Description                                |
   +==============================================+==============================================+==============================================+==============================================+
   | ``ppiclf_solve_InterpFieldUser``             | | integer*4 ``ifld``                         | | :math:`\leq` PPICLF_LRP                    | | The user sets which field array ``fld``    |
   |                                              | | real*8    ``fld``                          | | --                                         | | of same dimensions set in initialization   |
   |                                              |                                              |                                              | | call to ppiclf_comm_InitOverlapMesh routine|
   |                                              |                                              |                                              | | is used to interpolate to index in         |
   |                                              |                                              |                                              | | property array ppiclf_rprop(``ifld``,i) for|
   |                                              |                                              |                                              | | the j particle.                            |
   |                                              |                                              |                                              |                                              |
   +----------------------------------------------+----------------------------------------------+----------------------------------------------+----------------------------------------------+
   | ``ppiclf_solve_IntegrateParticle``           | | integer*4 ``istep``                        | | :math:`\geq` 0                             | | This routine must be called every time     |
   |                                              | | integer*4 ``iostep``                       | | :math:`\geq` 0                             | | step and uses the initial integration      |
   |                                              | | real*8    ``dt``                           | | :math:`\geq` 0.0                           | | method to advance :math:`\mathbf{Y}` in    |
   |                                              | | real*8    ``time``                         | | :math:`\geq` 0.0                           | | time. The inputs are the current ``time``, |
   |                                              |                                              |                                              | | the current time step ``dt`` to advance    |
   |                                              |                                              |                                              | | by, the current time step number ``istep``,|
   |                                              |                                              |                                              | | and will output solution files every       |
   |                                              |                                              |                                              | | ``iostep`` number of time steps. Note that |
   |                                              |                                              |                                              | | the user must call this routine every time |
   |                                              |                                              |                                              | | step for the system to be integrated. When |
   |                                              |                                              |                                              | | ``imethod`` is initialized to be a negative|
   |                                              |                                              |                                              | | number, this routine must also be called   |
   |                                              |                                              |                                              | | every stage/iteration as well.             |
   |                                              |                                              |                                              |                                              |
   +----------------------------------------------+----------------------------------------------+----------------------------------------------+----------------------------------------------+
