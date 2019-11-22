.. _CMT-nek_example:

--------------------------------------------------------------------------------
`CMT-nek Case <https://github.com/dpzwick/ppiclF/tree/master/examples/CMT-nek>`_
--------------------------------------------------------------------------------

Background
^^^^^^^^^^
This is an example that illustrates a two-dimensional multiphase shock tube. This example also illustrates linking ppiclF to the compressible Discontinuous Galerkin solver CMT-nek_.

.. _CMT-nek: https://github.com/dpzwick/Nek5000/tree/jason

The core particle equations being solved in this case are

.. math::
   \dfrac{d \mathbf{X}}{d t} &= \mathbf{V}, \\ M_p \dfrac{d \mathbf{V}}{d t} &= \mathbf{F}_{qs} + \mathbf{F}_{pg} + \mathbf{F}_{am} + \mathbf{F}_{c}, \\ C_{p} M_p \dfrac{d T}{d t} &= Q_{qs}

where, for each particle we have the position vector :math:`\mathbf{X}`, the velocity vector :math:`\mathbf{V}`, the particle temperature :math:`T`, the particle mass :math:`M_p`, the particle specific heat :math:`C_p`, the viscous drag force :math:`\mathbf{F}_{qs}`, the pressure gradient force :math:`\mathbf{F}_{pg}`, the added-mass force :math:`\mathbf{F}_{am}`, the collision force :math:`\mathbf{F}_{c}`, and the quasi-steady heat transfer :math:`Q_{qs}`. The position and velocity vectors are given by

.. math::
   \mathbf{X} = \begin{bmatrix}X \\ Y \end{bmatrix},\quad \mathbf{V} = \begin{bmatrix}V_x \\ V_y \end{bmatrix}.

The collision force in the same as in the :ref:`dem3d` example. The drag force is complicated so it is not detailed here. It is given by the model found in `Parmar et al. (2010) <https://doi.org/10.2514/1.J050161>`_.

The pressure gradient force is given by

.. math::
   \mathbf{F}_{pg} = - V_p \nabla p

where :math:`V_p` is the particle volume and :math:`p` is the fluid pressure at each particle's position. The added-mass force is given by

.. math::
   \mathbf{F}_{am} = V_p C_M \left( -\nabla p - \dfrac{ d (\rho_f \mathbf{V})}{d t} \right)

where :math:`C_M` is an added mass coefficient given by the Mach number corrections of `Parmar et al. (2008) <https://doi.org/10.1098/rsta.2008.0027>`_ and the volume fraction corrections of `Zuber (1964) <https://doi.org/10.1016/0009-2509(64)85067-3>`_. For simplicity, we assume that the density of the fluid at each particle's location :math:`\rho_f` is relatively constant in time so that it can be pulled out of the time derivative.

The quasi-steady heat transfer is given by

.. math::
   Q_{qs} = 2 \pi \kappa D_p (T_f - T) \Phi_{qs}

where :math:`\kappa = C_{p,f}/Pr`, :math:`C_{p,f}` is the specific heat at constant pressure of the fluid at the particle's location, :math:`Pr` is the Prandtl number of the fluid at the particle's position, :math:`T_f` is the fluid temperature at the particle's position, and :math:`\Phi_{qs}` is a correction factor for the heat transfer that is a function of the particle Reynolds number and the Prandtl number.

With some manipulation, the final form of the particle equations which are being solved are

.. math::
   \dfrac{d \mathbf{X}}{d t} &= \mathbf{V}, \\ (C_M V_p \rho_f+ M_p) \dfrac{d \mathbf{V}}{d t} &= \mathbf{F}_{qs} - V_p (1 + C_M) \nabla p + \mathbf{F}_{c}, \\ C_{p} M_p \dfrac{d T}{d t} &= Q_{qs}

The hydrodynamic forces must be projected so that they are correctly coupled to the fluid. In this case, the coupled hydrodynamic forces are the added mass and the quasi-steady force. Since in the above form the added mass force isn't directly avaiable, we save :math:`d \mathbf{V}/dt` before computing the new :math:`\dot{Y}` so that the entire added mass force may be computed.

CMT-nek without particles solves the following equations

.. math::
   \dfrac{\partial \rho_f}{\partial t} + \nabla \cdot (\rho_f \mathbf{u}) &= 0, \\ \dfrac{\partial (\rho_f \mathbf{u})}{\partial t} + \nabla \cdot (\rho \mathbf{u} \mathbf{u} + p \mathbf{I} ) &= 0, \\ \dfrac{\partial (\rho_f E)}{\partial t} + \nabla \cdot (\rho_f \mathbf{u} E + \mathbf{u} p) &= 0

The governing multiphase equations are

.. math::
   \dfrac{\partial \phi_f \rho_f}{\partial t} + \nabla \cdot (\rho_f \phi_f \mathbf{u}) &= 0, \\ \phi_f \rho_f \left( \dfrac{\partial \mathbf{u}}{\partial t} + \mathbf{u} \cdot \nabla \mathbf{u}\right) + \nabla p &= \mathbf{f}_{pf}, \\ \phi_f \rho_f \left( \dfrac{\partial E}{\partial t} + \mathbf{u} \cdot \nabla E \right) + \nabla \cdot ( \phi_f \mathbf{u} p + \phi_p \mathbf{v} p) &= e_{pf}

which can be arranged to yield the equations
   
.. Current place...

The fluid equations that Nek5000 solves in this example are

.. math::
   \nabla \cdot \mathbf{u} &= - \dfrac{1}{\phi_f} \dfrac{D \phi_f}{D t}, \\ \rho_f \dfrac{D \mathbf{u}}{D t} &= \nabla \cdot \mathbf{\sigma}_f + \dfrac{\mathbf{f}_{pf}}{\phi_f},

where :math:`\mathbf{u}` is the fluid velocity, :math:`\rho_f` is the fluid density, :math:`\mathbf{\sigma}_f` is the Navier-Stokes fluid stress tensor, :math:`\phi_f` is the fluid volume fraction, and :math:`\phi_p` is the particle volume fraction (:math:`\phi_f + \phi_p = 1`), and :math:`\mathbf{f}_{pf}` is a particle-fluid coupling force.

The solution to these equations reside on a mesh within Nek5000. Since the particles are solved in the Lagrangian reference frame, their contributions on the mesh must be accounted for. Most notably, the explicit particle contributions from ppiclF to Nek5000 are :math:`\phi_p` (and as a result :math:`\phi_f`) and :math:`\mathbf{f}_{pf}`. The method by which these fields are obtained is :ref:`projection`.

User Interface
^^^^^^^^^^^^^^
:ref:`hfile` for this case (`Nek5000 H-File <https://github.com/dpzwick/ppiclf/tree/master/examples/Nek5000/user_routines/PPICLF_USER.h>`_) is given below and corresponds to the equations being solved and the property being stored for each particle. Note that since :math:`g` is constant, we do not included in in the list of properties.

.. code-block:: c

   #define PPICLF_LRS 4
   #define PPICLF_LRP 6
   #define PPICLF_LEE 1000
   #define PPICLF_LEX 6
   #define PPICLF_LEY 6
   #define PPICLF_LRP_INT 3
   #define PPICLF_LRP_PRO 3
   
   #define PPICLF_JX 1
   #define PPICLF_JY 2
   #define PPICLF_JVX 3
   #define PPICLF_JVY 4
   #define PPICLF_R_JRHOP 1
   #define PPICLF_R_JDP 2
   #define PPICLF_R_JVOLP 3
   #define PPICLF_R_JPHIP 4
   #define PPICLF_R_JUX 5
   #define PPICLF_R_JUY 6
   #define PPICLF_P_JPHIP 1
   #define PPICLF_P_JFX 2
   #define PPICLF_P_JFY 3

The two blocks of lines denote the pre-defined and user-only directives. The pre-defined directives are in the top block and are the number of equations, the number of properties, the sizes of the overlap mesh, the number of interpolated fields, and the number of projected fields. The user-only directives are in the bottom block.

:ref:`ffile` for this case (`Nek5000 F-File <https://github.com/dpzwick/ppiclf/tree/master/examples/Nek5000/user_routines/ppiclf_user.f>`_) has meaningful information in every routine. The routine ppiclf_user_SetYdot is nearly the same as the :ref:`dem3d` example but with an added drag model evaluation that is slightly more complicated than the :ref:`stokes2d` example. Also, the ppiclf_user_EvalNearestNeighbor routine is similar to the :ref:`dem3d` example. The new addition is the mapping of particle properties to be projected in ppiclf_user_MapProjPart. With some study, it can be found that the three fields being projected in 2D are:


.. table:: Projection mapping in ppiclf_user_MapProjPart.
   :align: center

   +----------------------------------------+-------------------------------------+
   | Projected Field (:math:`a(\mathbf{x})`)| Particle Property (:math:`A^{(i)}`) |
   +========================================+=====================================+
   | :math:`\phi_p(\mathbf{x})`             | :math:`V_p/D_p`                     |
   +----------------------------------------+-------------------------------------+
   | :math:`f_{pf,x}(\mathbf{x})`           | :math:`-F_{qs,x}/D_p`               |
   +----------------------------------------+-------------------------------------+
   | :math:`f_{pf,y}(\mathbf{x})`           | :math:`-F_{qs,y}/D_p`               |
   +----------------------------------------+-------------------------------------+

where :math:`D_p` has been used to normalize the values in 2D. Note that the negative signs of the components of :math:`\mathbf{F}_{qs}` were added when the forces were stored in the storage array ppiclf_ydotc at the end of the routine ppiclf_user_SetYdot.

The :ref:`external` calls for this example occur within the user initialization Nek5000 routine usrdat2 in the file `uniform.usr <https://github.com/dpzwick/ppiclf/tree/master/examples/Nek5000/uniform.usr>`_ with the minimum number of initialization and solve subroutines called. In this case:

* ppiclf_comm_InitMPI is called to initialize the communication, 
* ppiclf_comm_InitParticle is called with initial properites and conditions for the particles,
* ppiclf_solve_InitGaussianFilter is called to initialize the fitler for projection to the overlap mesh,
* ppiclf_comm_InitOverlapMesh is called to initialize the overlap mesh from Nek5000,
* ppiclf_solve_InitNeighborBin is called with minimum interaction distance of the largest particle size,
* ppiclf_solve_InitWall is called which sets a wall for the particles at the bottom of the domain,
* ppiclf_solve_InitPeriodicX is called which sets periodicity in the x dimension along the domain.

Additionally, the solve routines are called every time step in the same file in various Nek5000 user routines. In this example,

* ppiclf_solve_InterpFieldUser is called three times to interpolate the fields :math:`\phi_p`, :math:`u_x`, and :math:`u_y` into the property array,
* ppiclf_solve_IntegrateParticle is called to integrate the system at the current time step,
* ppiclf_solve_GetProFldIJKEF is called to access the projected fields and use them locally in Nek5000 (force coupling and volume fraction effects).

Also, note that ppiclF has been linked with Nek5000 in the Nek5000 makenek compilation file through the following lines:

.. code-block:: make

   SOURCE_ROOT_PPICLF=$HOME/libraries/ppiclF/source
   FFLAGS=" -I$SOURCE_ROOT_PPICLF"
   USR_LFLAGS+=" -L$SOURCE_ROOT_PPICLF -lppiclF"

Compiling and Running
^^^^^^^^^^^^^^^^^^^^^
This example can be tested with Nek5000 by issuing the following commands:

.. code-block:: bash

   cd ~
   git clone https://github.com/dpzwick/ppiclF.git            # clone ppiclF
   git clone https://github.com/Nek5000/Nek5000.git           # clone Nek5000
   mkdir TestCase                                             # make test directory
   cd TestCase
   cp -r ../ppiclF/examples/Nek5000/* .                       # copy example files to test case
   cd ../ppiclF                                               # go to ppiclF code
   cp ../TestCase/user_routines/* source/                     # copy ppiclf_user.f and PPICLF_USER.h to source
   make                                                       # build ppiclF
   cd ../TestCase
   ./makenek uniform                                          # build Nek5000 and link with ppiclF
   echo uniform > SESSION.NAME && echo `pwd`/ >> SESSION.NAME # create Nek5000 necessary file
   mpirun -np 4 nek5000                                       # run case with 4 processors