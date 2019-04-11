.. _stokes2d:

---------
stokes_2d
---------

Background
^^^^^^^^^^
This is a simple example that illustrates Stokes drag on solid spherical particles. This can be illustrated by the following system of equations. For each particle, we have

.. math::
   \begin{align}\dfrac{d \mathbf{X}}{d t} &= \mathbf{V}, \\ M_p \dfrac{d \mathbf{V}}{d t} &= \mathbf{F}_{qs} + \mathbf{F}_b, \end{align}

where, for each particle we have the position vector :math:`\mathbf{X}`, the velocity vector :math:`\mathbf{V}`, the Stokes drag force :math:`\mathbf{F}_{qs}`, and the weight force :math:`\mathbf{F}_{b}`, defined by

.. math::
   \mathbf{X} = \begin{bmatrix}X \\ Y \end{bmatrix},\quad \mathbf{V} = \begin{bmatrix}V_x \\ V_y \end{bmatrix},\quad \mathbf{F}_{qs} = \dfrac{M_p}{\tau_p} \begin{bmatrix}V_x \\ V_y \end{bmatrix},\quad \mathbf{F}_{b} = M_p \begin{bmatrix}0 \\ g \end{bmatrix}.
   
Here, each particle has the same mass :math:`M_p`, time scale :math:`\tau_p`, and gravitational acceleration :math:`g`. Thus, for each particle we can write the following system of equations

.. math::
   \dfrac{d \mathbf{Y}}{d t} = \dot{\mathbf{Y}},

where

.. math::
   \mathbf{Y} = \begin{bmatrix}X \\ Y \\ V_x \\ V_y \end{bmatrix},\quad \dot{\mathbf{Y}} = \begin{bmatrix}V_x \\ V_y \\ -V_x/\tau_p + 0\\ -V_y/\tau_p - g \end{bmatrix}.

The H-File (PPICLF_USER.h)
^^^^^^^^^^^^^^^^^^^^^^^^^^
As is demonstrated above, for each particle we are solving a system of 4 equations, which is the length of the vectors :math:`\mathbf{Y}` and :math:`\dot{\mathbf{Y}}`. We will order each equation as they appear in the array above. Note that the actual ordering of equations is up to the user, but it is required that the positions :math:`X`, :math:`Y`, and :math:`Z` (3D only) must be the first equations when ordering the vector. Accordinging we call the solution variables

.. code::

   PPICLF_JX
   PPICLF_JY
   PPICLF_JVX
   PPICLF_JVY

Additionally, we allow :math:`\tau_p` to vary for particle, so each particle has 1 property associated with it. We name the property

.. code::

   PPICLF_R_JTAUP

For this example then, the PPICLF_USER.h header file is

.. code-block:: c

   #define PPICLF_LRS 4
   #define PPICLF_JX 1
   #define PPICLF_JY 2
   #define PPICLF_JVX 3
   #define PPICLF_JVY 4

   #define PPICLF_LRP 1
   #define PPICLF_R_JTAUP 1

It is seen that the number of equations is specified (PPICLF_LRS), the equation names are ordered from 1 to PPICLF_LRS with the position being first, the number of properties is specified (PPICLF_LRP), and the properties are ordered from 1 to PPICLF_LRP.

The F-File (ppiclf_user.f)
^^^^^^^^^^^^^^^^^^^^^^^^^^
The values set in the PPICLF_USER.h file are used to access array values in the ppiclf_user.f file. 

Specifically, the arrays ppiclf_y(j,i) and ppiclf_ydot(j,i) correspond to :math:`\mathbf{Y}` and :math:`\dot{\mathbf{Y}}`. The arrays are arranged by the j equation number (max PPICLF_LRS) for the i particle. The property array ppiclf_rprop(j,i) stores the j (max PPICLF_LRP) properties of the j particle. 

The user is required to define the ppiclf_user.f file. The main purpose of this file is to set :math:`\dot{\mathbf{Y}}`. Due to this, the subroutine ppiclf_user_SetYdot() sets :math:`\dot{\mathbf{Y}}` and for this case is given as

.. code-block:: fortran
 :linenos:

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

In this example, the do-loop loops through the total number of particles on each processor, which is the variable ppiclf_npart. The user computes the stokes drag force and weight in each direction for each particle. Then, the 4 equations are specified according to the system of equations defined in this case.

Note that two additional subroutines are also declared in this file, which are ppiclf_user_MapProjPart() and ppiclf_user_EvalNearestNeighbor(). In this example these routines are not used so their contents are blank. However, they must still be decleared.

The two user files PPICLF_USER.h and ppiclf_user.f are then copied to the LocalCodeDir/ppiclF/source/ directory and the library can be built using make.

External Calls
^^^^^^^^^^^^^^
In order to solve the system of equations, a driver program is used. In this case, a simple fortran MPI program in the example file test.f is used for this purpose (the library can instead be linked as a static library, as decribed in the :ref:`linking` section). Specifically, the driver program is responsible for setting the initial conditions of the solution variables :math:`\mathbf{Y}_0 = \mathbf{Y} (t = 0)`, specifying solver options, and looping through time. The program in test.f is found below.

.. code-block:: fortran
 :linenos:

       program main
 #include "PPICLF.h"
       include 'mpif.h' 
 !
       integer*4 np, nid, icomm
       integer*4 imethod, ndim, iendian, npart
       real*8 y(PPICLF_LRS    , PPICLF_LPART) ! Normal ordering
       real*8 rprop(PPICLF_LRP, PPICLF_LPART) ! Normal ordering
 
       integer*4 nstep, iostep
       real*8 dt, time
       integer*4 ierr
       real*8 rdum, ran2
       external ran2
 !
       ! Init MPI
       call MPI_Init(ierr) 
       icomm = MPI_COMM_WORLD
       call MPI_Comm_rank(icomm, nid, ierr) 
       call MPI_Comm_size(icomm, np , ierr)
 
       ! Pass to library to Init MPI
       call ppiclf_comm_InitMPI(icomm,
      >                         nid  ,
      >                         np   )
 
       ! Set initial conditions and parameters for particles
       imethod = 1
       ndim    = 2
       iendian = 0
       npart   = 250
       rdum    = ran2(-1-nid) ! init random numbers
       do i=1,npart
 
          y(PPICLF_JX,i)  = ran2(2)
          y(PPICLF_JY,i)  = ran2(2)
          y(PPICLF_JVX,i) = 0.0
          y(PPICLF_JVY,i) = 0.0
 
          rprop(PPICLF_R_JTAUP,i) = 1.0/9.8
       enddo
       call ppiclf_solve_InitParticle(imethod   ,
      >                               ndim      ,
      >                               iendian   ,
      >                               npart     ,
      >                               y(1,1)    ,
      >                               rprop(1,1))
 
       ! Integrate particles in time
       nstep  = 1000
       iostep = 100
       dt     = 1E-4
       do istep=1,nstep
 
          time = (istep-1)*dt
          call ppiclf_solve_IntegrateParticle(istep ,
      >                                       iostep,
      >                                       dt    ,
      >                                       time  )
       enddo
 
       ! Finalize MPI
       call MPI_FINALIZE(ierr) 
 
       stop
       end

First, MPI is initialized using the current communicator icomm, the current MPI rank nid, and the total number of processors np. These are passed to the routine ppiclf_comm_InitMPI(icomm,nid,np).

Following this, the user initializes the initial conditions :math:`\mathbf{Y}_0` and properties for npart local particles. This is accomplished in the loop from lines 33-41. For each particle initialized, the PPICLF_LRS initial condtions are set in the array y(j,i). The positions of each particle in :math:`X` and :math:`Y` are set with a random number generator to be between 0 and 1. The initial velocities are set to zero. The property :math:`\tau_p` is specified to be :math:`g^{-1}` in the array rprop(j,i). Here, y and rprop are defiend to be 8-byte real arrays of size (PPICLF_LRS,PPICLF_LPART) and (PPICLF_LRP,PPICLF_LPART), respectfully. These are temporary arrays which are copied to the internal arrays ppiclf_y and ppiclf_rprop upon initialization.

The routine ppiclf_solve_InitParticle(imethod,ndim,iendian,npart,y,rprop) is then called. The inputs are the time integration method (4-byte integer imethod), the problem dimension (4-byte integer ndim), the byte ordering (4-byte integer iendian), the local number of particles on this processor (4-byte integer npart), and the first location of the temporary arrays y and rprop.

Following this, a dummy time loop is iterated. At each step, the subroutine ppiclf_solve_IntegrateParticle(istep,iostep,dt,time) is called. This routine will advance the system of equations in time. Here, we pass in the current time step (4-byte integer istep), the time step file output frequency (4-byte integer iostep), the time step (8-byte real dt), and the current time (8-byte real time). Whenever ppiclf_solve_IntegrateParticle() is called, it will advance the solution ppiclf_y with a time step of dt and a forcing ppiclf_ydot which was specified in the ppiclf_user.f file.

The makefile includes an example of linking the static library to the test.f file in compilation. This driver program can compiled and run on <#> processors using your systems MPI compiler. For example

.. code-block:: bash

   make
   mpirun -np <#> test.out


Simulation Output
^^^^^^^^^^^^^^^^^
The system of equations can analytically be solved subject to the previously given initial conditions. The solution is

.. math::
   \mathbf{Y} = \begin{bmatrix}X \\ Y \\ V_x \\ V_y \end{bmatrix} = \begin{bmatrix}X_0 \\ Y_0 - t - e^{-tg}/g \\ 0 \\ e^{-tg} - 1 \end{bmatrix}.

As a result, it is clear that the velocity :math:`V_y` will increase exponentially in time at a rate of :math:`\tau_p = g^{-1}`, eventually reaching :math:`V_y ( t \rightarrow \infty) \approx -1`. 

In the user code above, :math:`g = 9.8` and the driver program runs for a total time of :math:`t = 0.1 \approx \tau_p`. The analytical velocity at this time is :math:`V_y = -0.62468890114`. The simulation output in this case can be confirmed to be :math:`V_y = -0.62468886375`. 

In this case, third order Runge-Kutta time integration was used with a time step of :math:`10^{-4}`, resulting in error of the order :math:`10^{-8}` when compounded over 1000 time steps. Since ppiclF outputs only 4-byte precision on the real numbers which is accurate to 7 digits, we expect the precision to be more important than the third order trunacation error. To test this, the difference between the simulation output and analytic solution is :math:`0.00000003739`, reflecting the larger byte precision.

If instead we change the time step to :math:`10^{-2}` and the number of time steps to 10, we expect the new truncation error of order :math:`10^{-5}` to be larger than byte precision. To confirm this, the simulation with these parameters give :math:`V_y = -0.62470448017`. The difference between the simulation output and analytic solution is :math:`0.00001557903`, reflecting the larger truncation error.
