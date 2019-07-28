.. _dem3d:

--------------------------------------------------------------------------------------
`DEM Packing 3D <https://github.com/dpzwick/ppiclF/tree/master/examples/dem_pack_3d>`_
--------------------------------------------------------------------------------------
.. raw:: html

    <div style="position: relative; padding-bottom: 10.00%; height: 0; overflow: hidden; max-width: 100%; height: auto;">
       <iframe width="560" height="315" src="https://www.youtube.com/embed/0VSfiedYaCI" frameborder="0" allow="accelerometer; autoplay; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>
    </div>

Background
^^^^^^^^^^
This is an example that illustrates a particle packing in a realistic geometry. To accomplish this, an efficient neighbor search is performed along with reading in external boundary conditions. The following system of equations is solved for the i particle

.. math::
   \dfrac{d \mathbf{X}^{(i)}}{d t} &= \mathbf{V}^{(i)}, \\ M_p^{(i)} \dfrac{d \mathbf{V}^{(i)}}{d t} &= \mathbf{F}_{c}^{(i)} + \mathbf{F}_b^{(i)},

where, for each particle we have the position vector :math:`\mathbf{X}`, the velocity vector :math:`\mathbf{V}`, the collision force :math:`\mathbf{F}_{c}`, and the weight force :math:`\mathbf{F}_{b}`, defined by

.. math::
   \mathbf{X}^{(i)} = \begin{bmatrix}X^{(i)} \\ Y^{(i)} \\ Z^{(i)} \end{bmatrix},\quad \mathbf{V}^{(i)} = \begin{bmatrix}V_x^{(i)} \\ V_y^{(i)} \\ V_z^{(i)} \end{bmatrix},

.. math::
   \mathbf{F}_{c}^{(i)} = \begin{bmatrix}F_{cx}^{(i)} \\ F_{cy}^{(i)} \\ F_{cz}^{(i)} \end{bmatrix} = \sum_{j=1}^{N_p^{(i)}}-k_c \delta^{(i,j)}\mathbf{n}^{(i,j)} - \eta \mathbf{V}^{(i,j)},\quad \mathbf{F}_{b} = M_p^{(i)} \begin{bmatrix}0 \\ g \\ 0\end{bmatrix}.
   
Here, we have used the mass of each particle, :math:`M_p` and the gravitational acceleration :math:`g`. Additionally, the collision force is a soft-sphere normal force which only acts on physically overlapping particles. Due to this, the particle must add the forces from all j overlapping nearby particles. The variable :math:`N_p^{(i)}` is the number of nearby overlapping particles, which is local to the i particle itself.

For the collision model, the user must specify the two numerical constants, which are the spring stiffness :math:`k_c` and the coefficient of restitution :math:`e_n`. The distance between two particle's center locations is

.. math::
   d^{(i,j)} = |\mathbf{X}^{(j)} - \mathbf{X}^{(i)}|.

The unit normal vector between nearby particles is computed by

.. math::
   \mathbf{n}^{(i,j)} = (\mathbf{X}^{(j)} - \mathbf{X}^{(i)})/d^{(i,j)}.

Two particles are said to be overlapping, and thus have a non-zero collision force, when the overlap :math:`\delta^{(i,j)} > 0`. The overlap is computed by

.. math::
   \delta^{(i,j)} = \dfrac{1}{2} (D_p^{(i)} + D_p^{(j)}) - d^{(i,j)}, 

where :math:`D_p` is the particle's diameter.

Additionally, the particles dissipate energy when they collide. Thus, the collision force also includes the damping coefficient :math:`\eta`, computed by

.. math::
   \eta = -2 \sqrt{M^{(i,j)}k_c} \dfrac{\ln e_n}{\sqrt{\ln^2 e_n + \pi^2}},

where :math:`M^{(i,j)} = (1/M_p^{(i)} + 1/M_p^{(j)})^{-1}`. Additionally, we have the normal relative velocity which is

.. math::
   \mathbf{V}^{(i,j)} = ((\mathbf{V}^{(i)} - \mathbf{V}^{(j)}) \cdot \mathbf{n}^{(i,j)}) \mathbf{n}^{(i,j)}.

Note that the time in collision can be computed by

.. math::
   t_c = \sqrt{\dfrac{M^{(i,j)}}{k_c} (\ln^2 e_n + \pi^2)}.

This time scale must be resolved in the simulation. As can be seen, this sets practical limitations on the simulation time step.

Thus, for each particle we can write the following system of equations

.. math::
   \dfrac{d \mathbf{Y}^{(i)}}{d t} = \dot{\mathbf{Y}^{(i)}},

where

.. math::
   \mathbf{Y}^{(i)} = \begin{bmatrix}X^{(i)} \\ Y^{(i)} \\ Z^{(i)} \\ V_x^{(i)} \\ V_y^{(i)} \\ V_z^{(i)} \end{bmatrix},\quad \dot{\mathbf{Y}}^{(i)} = \begin{bmatrix}V_x \\ V_y \\ V_z \\ (F_{cx}^{(i)} + 0)/M_p^{(i)}\\ (F_{cy}^{(i)} + M_p^{(i)}g)/M_p^{(i)} \\ (F_{cz}^{(i)} + 0)/M_p^{(i)} \end{bmatrix}.

User Interface
^^^^^^^^^^^^^^
:ref:`hfile` for this case (`DEM Packing 3D H-File <https://github.com/dpzwick/ppiclf/tree/master/examples/dem_pack_3d/user_routines/PPICLF_USER.h>`_) is given below and corresponds to the equations being solved and the property being stored for each particle. Note that since :math:`g` is constant, we do not included in in the list of properties.

.. code-block:: c

   #define PPICLF_LRS 6
   #define PPICLF_LRP 3
   #define PPICLF_LWALL 800
   
   #define PPICLF_JX  1
   #define PPICLF_JY  2
   #define PPICLF_JZ  3
   #define PPICLF_JVX 4
   #define PPICLF_JVY 5
   #define PPICLF_JVZ 6
   #define PPICLF_R_JRHOP 1
   #define PPICLF_R_JDP   2
   #define PPICLF_R_JVOLP 3

The two blocks of lines denote the pre-defined and user-only directives. The pre-defined directives are in the top block and are the number of equations, the number of properties, and the maximum number of boundaries. The user-only directives are in the bottom block.
 
:ref:`ffile` for this case (`DEM Packing 3D F-File <https://github.com/dpzwick/ppiclf/tree/master/examples/dem_pack_3d/user_routines/ppiclf_user.f>`_) is similar to the :ref:`stokes2d` exmaple. In ppiclf_user_SetYdot, the forces are evaulated. Note that the routine ppiclf_solve_NearestNeighbor is invoked which activates the routine ppiclf_user_EvalNearestNeighbor. In ppiclf_user_EvalNearestNeighbor, the collision force model is applied between the j nearby particles as well as the j nearby boundaries. The collision force is stored in the extra storage array ppiclf_ydotc. The other routine ppiclf_user_MapProjPart is defined only.

The :ref:`external` calls for this example occur in a simple driver program in the file `test.f <https://github.com/dpzwick/ppiclf/tree/master/examples/dem_pack_3d/fortran/test.f>`_ with the minimum number of initialization and solve subroutines called. In this case:

* ppiclf_comm_InitMPI is called to initialize the communication, 
* ppiclf_comm_InitParticle is called with initial properites and conditions for the particles,
* ppiclf_solve_InitNeighborBin is called with minimum interaction distance of the largest particle size,
* ppiclf_io_ReadWallVTK is called which reads the minimal ASCII triangular patch boundary file,
* ppiclf_solve_IntegrateParticle is called in a simple time step loop.

Compiling and Running
^^^^^^^^^^^^^^^^^^^^^
This example can be tested by issuing the following commands:

.. code-block:: bash

   cd ~
   git clone https://github.com/dpzwick/ppiclF.git       # clone ppiclF
   mkdir TestCase                                        # make test directory
   cd TestCase
   cp ../ppiclF/examples/dem_pack_3d/fortran/* .         # copy example files to test case
   cp -r ../ppiclF/examples/dem_pack_3d/user_routines . # copy example files to test case
   cp -r ../ppiclF/examples/dem_pack_3d/geometry/*.vtk . # copy example files to test case
   cd ../ppiclF                                          # go to ppiclF code
   cp ../TestCase/user_routines/* source/                # copy ppiclf_user.f and PPICLF_USER.h to source
   make                                                  # build ppiclF
   cd ../TestCase
   make                                                  # build test case and link with ppiclF
   mpirun -np 4 test.out                                 # run case with 4 processors
