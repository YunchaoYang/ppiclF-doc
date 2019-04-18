.. _stokes2d:

-------------------------------------------------------------------------------
`Stokes 2D <https://github.com/dpzwick/ppiclF/tree/master/examples/stokes_2d>`_
-------------------------------------------------------------------------------

Background
^^^^^^^^^^
This is a simple example that illustrates Stokes drag on solid spherical particles. This can be illustrated by the following system of equations. For each particle, we have

.. math::
   \dfrac{d \mathbf{X}}{d t} &= \mathbf{V}, \\ M_p \dfrac{d \mathbf{V}}{d t} &= \mathbf{F}_{qs} + \mathbf{F}_b,

where, for each particle we have the position vector :math:`\mathbf{X}`, the velocity vector :math:`\mathbf{V}`, the Stokes drag force :math:`\mathbf{F}_{qs}`, and the weight force :math:`\mathbf{F}_{b}`, defined by

.. math::
   \mathbf{X} = \begin{bmatrix}X \\ Y \end{bmatrix},\quad \mathbf{V} = \begin{bmatrix}V_x \\ V_y \end{bmatrix},\quad \mathbf{F}_{qs} = \dfrac{M_p}{\tau_p} \begin{bmatrix}V_x \\ V_y \end{bmatrix},\quad \mathbf{F}_{b} = M_p \begin{bmatrix}0 \\ g \end{bmatrix}.
   
Here, each particle has the same mass :math:`M_p`, time scale :math:`\tau_p`, and gravitational acceleration :math:`g`. Thus, for each particle we can write the following system of equations

.. math::
   \dfrac{d \mathbf{Y}}{d t} = \dot{\mathbf{Y}},

where

.. math::
   \mathbf{Y} = \begin{bmatrix}X \\ Y \\ V_x \\ V_y \end{bmatrix},\quad \dot{\mathbf{Y}} = \begin{bmatrix}V_x \\ V_y \\ -V_x/\tau_p + 0\\ -V_y/\tau_p - g \end{bmatrix}.

User Interface
^^^^^^^^^^^^^^
:ref:`hfile` for this case is given below and corresponds to the equations being solved and the property being stored for each particle. Note that since :math:`g` is constant, we do not included in in the list of properties.

.. code-block:: c

   #define PPICLF_LRS 4 
   #define PPICLF_LRP 1 

   #define PPICLF_JX  1
   #define PPICLF_JY  2
   #define PPICLF_JVX 3
   #define PPICLF_JVY 4
   #define PPICLF_R_JTAUP 1

The two blocks of lines denote the pre-defined and user-only directives. The pre-defined directives are in the top block and are the number of equations and the number of properties. The user-only directives are in the bottom block.

:ref:`ffile` for this case only has meaningful information in ppiclf_user_SetYdot. The other two routines ppiclf_user_MapProjPart and ppiclf_user_EvalNearestNeighbor are defined only.

.. code-block:: fortran

       subroutine ppiclf_user_SetYdot
 !
       implicit none
 !
 #include "PPICLF.h"
 !
 ! Internal:
 !
       real*8 fqsx,fqsy,fbx,fby
       integer*4 i
 !
 ! evaluate ydot
       do i=1,ppiclf_npart
          ! Stokes drag
          fqsx = -ppiclf_y(PPICLF_JVX,i)/ppiclf_rprop(PPICLF_R_JTAUP,i)
          fqsy = -ppiclf_y(PPICLF_JVY,i)/ppiclf_rprop(PPICLF_R_JTAUP,i)
 
          ! Gravity
          fbx  = 0.0d0
          fby  = -9.8d0
 
          ! set ydot for all PPICLF_LRS number of equations
          ppiclf_ydot(PPICLF_JX ,i) = ppiclf_y(PPICLF_JVX,i)
          ppiclf_ydot(PPICLF_JY ,i) = ppiclf_y(PPICLF_JVY,i)
          ppiclf_ydot(PPICLF_JVX,i) = fqsx+fbx
          ppiclf_ydot(PPICLF_JVY,i) = fqsy+fby
       enddo 
 ! evaluate ydot
 
       return
       end

In this example, the do-loop loops through the total number of particles on each processor. The user computes the stokes drag force and weight in each direction for each particle. Then, the 4 equations are specified according to the system of equations defined in this case.

The :ref:`external` calls for this example occur in a simple driver program in the file `test.f <https://github.com/dpzwick/ppiclf/tree/master/examples/stokes_2d/fortran/test.f>`_ with the minimum number of initialization and solve subroutines called. In this case:

* ppiclf_comm_InitMPI is called to initialize the communication, 
* ppiclf_comm_InitParticle is called with initial properites and conditions for the particles,
* ppiclf_solve_IntegrateParticle is called in a simple time step loop.

Compiling and Running
^^^^^^^^^^^^^^^^^^^^^
This example can be tested by issuing the following commands:

.. code-block:: bash

   cd ~
   git clone https://github.com/dpzwick/ppiclF.git     # clone ppiclF
   mkdir TestCase                                      # make test directory
   cd TestCase
   cp ../ppiclF/examples/stokes_2d/fortran/* .         # copy example files to test case
   cp -r ../ppiclF/examples/stokes_2d/user_routines/ . # copy example files to test case
   cd ../ppiclF                                        # go to ppiclF code
   cp ../TestCase/user_routines/* source/              # copy ppiclf_user.f and PPICLF_USER.h to source
   make                                                # build ppiclF
   cd ../TestCase
   make                                                # build test case and link with ppiclF
   mpirun -np 4 test.out                               # run case with 4 processors

Simulation Output
^^^^^^^^^^^^^^^^^
The system of equations can analytically be solved subject to the previously given initial conditions. The solution is

.. math::
   \mathbf{Y} = \begin{bmatrix}X \\ Y \\ V_x \\ V_y \end{bmatrix} = \begin{bmatrix}X_0 \\ Y_0 - t - e^{-tg}/g \\ 0 \\ e^{-tg} - 1 \end{bmatrix}.

As a result, it is clear that the velocity :math:`V_y` will increase exponentially in time at a rate of :math:`\tau_p = g^{-1}`, eventually reaching :math:`V_y ( t \rightarrow \infty) \approx -1`. 

In the user code above, :math:`g = 9.8` and the driver program runs for a total time of :math:`t = 0.1 \approx \tau_p`. The analytical velocity at this time is :math:`V_y = -0.62468890114`. The simulation output in this case can be confirmed to be :math:`V_y = -0.62468886375`. 

In this case, third order Runge-Kutta time integration was used with a time step of :math:`10^{-4}`, resulting in error of the order :math:`10^{-8}` when compounded over 1000 time steps. Since ppiclF outputs only 4-byte precision on the real numbers which is accurate to 7 digits, we expect the precision to be more important than the third order trunacation error. To test this, the difference between the simulation output and analytic solution is :math:`0.00000003739`, reflecting the larger byte precision.

If instead we change the time step to :math:`10^{-2}` and the number of time steps to 10, we expect the new truncation error of order :math:`10^{-5}` to be larger than byte precision. To confirm this, the simulation with these parameters give :math:`V_y = -0.62470448017`. The difference between the simulation output and analytic solution is :math:`0.00001557903`, reflecting the larger truncation error.

