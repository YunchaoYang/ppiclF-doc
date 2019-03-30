.. _stokes2d:


---------
stokes_2d
---------

Background
^^^^^^^^^^

This is a simple example that illustrates Stokes drag on solid spherical particles. This can be illustrated by the following system of equations. For each particle, we have

.. math::
   \begin{align}\dfrac{d \mathbf{X}}{d t} &= \mathbf{V}, \\ M_p \dfrac{d \mathbf{V}}{d t} &= \mathbf{F}_{qs} + \mathbf{F}_b, \end{align}

where :math:`\mathbf{X} = [X, Y]^T` is the position of each particle, :math:`\mathbf{V} = [V_x, V_y]^T` is the velocity of each particle, :math:`M_p` is the mass of each particle, :math:`\mathbf{F}_{qs} = -3 \pi \mu D_p \mathbf{V}` is the Stokes drag force on each particle, and :math:`\mathbf{F}_{b} = [0,-M_p g]^T` is the weight force on each particle.

Thus, for each particle we can write the following system of equations

.. math::
   \dfrac{d \mathbf{Y}}{d t} = \dot{\mathbf{Y}},

where

.. math::
   \mathbf{Y} = \begin{bmatrix}X \\ Y \\ V_x \\ V_y \end{bmatrix},\quad \dot{\mathbf{Y}} = \begin{bmatrix}V_x \\ V_y \\ -V_x/\tau_p \\ -V_y/\tau_p - g \end{bmatrix},

where :math:`\tau_p = 3 \pi \mu D_p / M_p`.

User Files
^^^^^^^^^^

As is demonstrated above, for each particle we are solving a system of :code:`PPICLF_LRS = 4` equations, which is the length of the vectors :math:`\mathbf{Y}` and :math:`\dot{\mathbf{Y}}`. We will order each equation as they appear in the array above (note that position must always come first when ordering the vector, but the remaining ordering is up to the user). Accordinging we call the solution variables

.. code::

   PPICLF_JX
   PPICLF_JY
   PPICLF_JVX
   PPICLF_JVY

Additionally, we allow :math:`\tau_p` to vary for particle, so each particle has :code:`PPICLF_LRP = 1` real property associated with it. Accordingly we call the properties

.. code::

   PPICLF_R_JTAUP

For this example then, the ppiclf_user.h header file is

.. code-block:: c

   #define PPICLF_LRS 4
   #define PPICLF_JX 1
   #define PPICLF_JY 2
   #define PPICLF_JVX 3
   #define PPICLF_JVY 4

   #define PPICLF_LRP 1
   #define PPICLF_R_JTAUP 1

Thus, when we access the array ppiclf_y(i,j), the i (max :code:`PPICLF_LRS`) solution variable (:math:`\mathbf{Y}`) for the j particle may be accessed. Similarly, the ppiclf_ydot(i,j) array is the corresponding right side of the system (:math:`\dot{\mathbf{Y}}`). The real property array for each particle can be accessed in the code as ppiclf_rprop(k,j) for the k (max :code:`PPICLF_LRP`) property of the j particle. 

The user is required to supply the ppiclf_user.f file. The main purpose of this file is to set :math:`\dot{\mathbf{Y}}`. Accordingly, the subroutine :code:`ppiclf_user_SetYdot(time,y,ydot)` sets :math:`\dot{\mathbf{Y}}` and for this case is given as

.. code-block:: fortran

       subroutine ppiclf_user_SetYdot(time,y,ydot)
 #include "PPICLF"
 
       real    time
       real    y(*)
       real    ydot(*)
 
 c evaluate ydot
       do i=1,ppiclf_npart
          ! striding solution y vector
          j = PPICLF_LRS*(i-1)
 
          ! Stokes drag
          fqsx = -y(PPICLF_JVX+j)/ppiclf_rprop(PPICLF_R_JTAUP,i)
          fqsy = -y(PPICLF_JVY+j)/ppiclf_rprop(PPICLF_R_JTAUP,i)
 
          ! Gravity
          fbx  = 0.0
          fby  = -9.8
 
          ! set ydot for all PPICLF_LRS number of equations
          ydot(PPICLF_JX +j) = y(PPICLF_JVX +j)
          ydot(PPICLF_JY +j) = y(PPICLF_JVY +j)
          ydot(PPICLF_JVX+j) = fqsx+fbx
          ydot(PPICLF_JVY+j) = fqsy+fby
       enddo 
 c evaluate ydot
 
       return
       end

In this example, the do-loop loops through the total number of particles on each processor, which is :code:`ppiclf_npart`. There are three input arguments to this routine, which are the current time (:code:`time`), a pointer to the first location of the array ppiclf_y(:,:) (:code:`y(*)`), and a pointer to the first location of the array ppiclf_ydot(:,:) (:code:`ydot(*)`). 

It is the users responsibility to set :code:`ydot(*)` for each particle, which corresponds to :math:`\dot{\textbf{Y}}`. At the end of the loop in this example, this is done by

.. code-block:: fortran

   ydot(PPICLF_JX +j) = y(PPICLF_JVX +j)
   ydot(PPICLF_JY +j) = y(PPICLF_JVY +j)
   ydot(PPICLF_JVX+j) = fqsx+fbx
   ydot(PPICLF_JVY+j) = fqsy+fby

Note that within the loop, the striding variable :code:`j` is used to access the :code:`i` particles properties in the pointer arrays :code:`y(*)` and :code:`ydot(*)`. This equation corresponds to the system described above where fqsx and fqsy are the directional drag components as a function of :math:`\tau_p` and fbx and fby are the directional weight components.

Note that two additional subroutines are also declared in this file, which are :code:`ppiclf_user_MapProjPart(map,y,ydot,ydotc,rprop)` and :code:`ppiclf_user_EvalNearestNeighbor(i,j,yi,rpropi,yj,rpropj)`. In this example these routines are not used so their contents are blank. However, they must still be decleared.


The two user files (ppiclf_user.f and ppiclf_user.h) are then copied to the source/ directory and the library can be built using make.

External Calls
^^^^^^^^^^^^^^

In order to solve the system of equations, a driver program is used. In this case, a simple MPI program in the example file test.f is used for this purpose, but these calls may be from an external program that has been linked to the static library which was built in the last step. Specifically, the driver program is responsible for setting the initial conditions of the solution variables :math:`\mathbf{Y}_0 = \mathbf{Y} (t = 0)`, specifying solver options, and looping through time steps. Thus, the program in test.f is given and explained below.

.. code-block:: fortran

       program test
 #include "PPICLF"
       include 'mpif.h' 
 
       call MPI_INIT(ierr) 
       icomm = MPI_COMM_WORLD
       call MPI_COMM_RANK(ppiclf_comm, nid, ierr) 
       call MPI_COMM_SIZE(ppiclf_comm, np , ierr)
 
       call ppiclf_comm_InitMPI(icomm,nid,np)
          call PlaceParticle(npart,ppiclf_y)
       call ppiclf_solve_InitParticle(1,2,0,npart,ppiclf_y) 
 
       ! time loop
       iostep = 1E2
       nstep  = 1E4
       dt     = 1E-4
       do istep=1,nstep
          time = (istep-1)*dt
          call ppiclf_solve_IntegrateParticle(istep,iostep,dt,time
      >                                      ,ppiclf_y,ppiclf_ydot)
       enddo
 
       call MPI_FINALIZE(ierr) 
 
       stop
       end

First, MPI is initialized using the current communicator :code:`icomm`, the current MPI rank :code:`nid`, and the total number of processors :code:`np`. These are passed to the routine :code:`ppiclf_comm_InitMPI(icomm,nid,np)`.

Following this, the user initializes the initial conditions :math:`\mathbf{Y}_0` for :code:`npart` local particles and the local properties (only property :math:`\tau_p`) for each particle in the local subroutine :code:`PlaceParticle(npart,ppiclf_y)`. These are then passed to the subroutine :code:`ppiclf_solve_InitParticle(imethod,ndim,iendian,npart,ppiclf_y)`. The inputs to this routine are imethod (the time integration method), ndim (the dimensionality of the problem, iendian (byte swapping on system), and the number and initial condition of particles (npart and ppiclf_y).

Following this, a dummy time loop is iterated with the subroutine :code:`ppiclf_solve_IntegrateParticle(istep,iostep,dt,time,ppiclf_y,ppiclf_ydot)` called at each time step. This routine will advance the system of equations in time, with istep being the current time step, output of the solution every iostep, with a time step of dt, at a current time of time. Additionally, the current system solution array ppiclf_y and to-be-set right side of the system ppiclf_ydot are also passed in.

The makefile includes an example of linking the static library to test.f file in compilation. This case can be built and run on <#> processors using your systems MPI compiler. For example

.. code-block:: bash

   make
   mpirun -np <#> test.out
