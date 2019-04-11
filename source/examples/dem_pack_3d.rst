.. _dem3d:

-----------
dem_pack_3d
-----------
.. raw:: html

    <div style="position: relative; padding-bottom: 10.00%; height: 0; overflow: hidden; max-width: 100%; height: auto;">
       <iframe width="560" height="315" src="https://www.youtube.com/embed/0VSfiedYaCI" frameborder="0" allow="accelerometer; autoplay; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>
    </div>

Background
^^^^^^^^^^
This is an example that illustrates a particle packing in a realistic geometry. To accomplish this, an efficient neighbor search is performed along with reading in of external boundary conditions. The following system of equations is solved for the i particle

.. math::
   \begin{align}\dfrac{d \mathbf{X}^{(i)}}{d t} &= \mathbf{V}^{(i)}, \\ M_p^{(i)} \dfrac{d \mathbf{V}^{(i)}}{d t} &= \mathbf{F}_{c}^{(i)} + \mathbf{F}_b^{(i)}, \end{align}

where, for each particle we have the position vector :math:`\mathbf{X}`, the velocity vector :math:`\mathbf{V}`, the collision force :math:`\mathbf{F}_{c}`, and the weight force :math:`\mathbf{F}_{b}`, defined by

.. math::
   \mathbf{X}^{(i)} = \begin{bmatrix}X^{(i)} \\ Y^{(i)} \\ Z^{(i)} \end{bmatrix},\quad \mathbf{V}^{(i)} = \begin{bmatrix}V_x^{(i)} \\ V_y^{(i)} \\ V_z^{(i)} \end{bmatrix},\quad \mathbf{F}_{c}^{(i)} = \begin{bmatrix}F_{cx}^{(i)} \\ F_{cy}^{(i)} \\ F_{cz}^{(i)} \end{bmatrix} = \sum_{j=1}^{N_p^{(i)}}-k_c \delta^{(i,j)}\mathbf{n}^{(i,j)} - \eta \mathbf{V}^{(i,j)},\quad \mathbf{F}_{b} = M_p^{(i)} \begin{bmatrix}0 \\ g \\ 0\end{bmatrix}.
   
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

This time scale must be resolved in the simulation. As we will see, this sets practical limitations on the simulation time step.

Thus, for each particle we can write the following system of equations

.. math::
   \dfrac{d \mathbf{Y}^{(i)}}{d t} = \dot{\mathbf{Y}^{(i)}},

where

.. math::
   \mathbf{Y}^{(i)} = \begin{bmatrix}X^{(i)} \\ Y^{(i)} \\ Z^{(i)} \\ V_x^{(i)} \\ V_y^{(i)} \\ V_z^{(i)} \end{bmatrix},\quad \dot{\mathbf{Y}}^{(i)} = \begin{bmatrix}V_x \\ V_y \\ V_z \\ (F_{cx}^{(i)} + 0)/M_p^{(i)}\\ (F_{cy}^{(i)} + M_p^{(i)}g)/M_p^{(i)} \\ (F_{cz}^{(i)} + 0)/M_p^{(i)} \end{bmatrix}.

The H-File (PPICLF_USER.h)
^^^^^^^^^^^^^^^^^^^^^^^^^^
As is demonstrated above, for each particle we are solving a system of 6 equations, which is the length of the vectors :math:`\mathbf{Y}` and :math:`\dot{\mathbf{Y}}`. We will order each equation as they appear in the array above. Note that the actual ordering of equations is up to the user, but it is required that the positions :math:`X`, :math:`Y`, and :math:`Z` (3D only) must be the first equations when ordering the vector. Accordinging we call the solution variables

.. code::

   PPICLF_JX
   PPICLF_JY
   PPICLF_JZ
   PPICLF_JVX
   PPICLF_JVY
   PPICLF_JVZ

Additionally, we allow three properties to vary for each particle. These are the particle density :math:`\rho_p`, the particle diameter :math:`D_p`, and the particle volume :math:`V_p`. As a result, each particle has 3 properties associated with it. We name the properties

.. code::

   PPICLF_R_JRHOP
   PPICLF_R_JDP
   PPICLF_R_JVOLP

For this example then, the PPICLF_USER.h header file is

.. code-block:: c

   #define PPICLF_LRS 6
   #define PPICLF_JX  1
   #define PPICLF_JY  2
   #define PPICLF_JZ  3
   #define PPICLF_JVX 4
   #define PPICLF_JVY 5
   #define PPICLF_JVZ 6

   #define PPICLF_LRP 3
   #define PPICLF_R_JRHOP 1
   #define PPICLF_R_JDP   2
   #define PPICLF_R_JVOLP 3

   #define PPICLF_LWALL 800


It is seen that the number of equations is specified (PPICLF_LRS), the equation names are ordered from 1 to PPICLF_LRS with the position being first, the number of properties is specified (PPICLF_LRP), and the properties are ordered from 1 to PPICLF_LRP.

Additionally, for reasons that we will seen later, the value PPICLF_LWALL is specified to be 800. This declares memory for a max of 800 walls to be read in.

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
       real*8 rmass,fbx,fby,fbz,fcx,fcy,fcz
       integer*4 i
 !
 ! evaluate ydot
       do i=1,ppiclf_npart
          ! Particle mass
          rmass = ppiclf_rprop(PPICLF_R_JVOLP,i)
      >          *ppiclf_rprop(PPICLF_R_JRHOP,i)
 
          ! Gravity
          fbx  = 0.0d0
          fby  = -9.8d0*rmass
          fbz  = 0.0d0
 
          ! Collision search
          call ppiclf_solve_NearestNeighbor(i)
 
          ! User implemented collision force from EvalNearestNeighbor()
          fcx  = ppiclf_ydotc(PPICLF_JVX,i)
          fcy  = ppiclf_ydotc(PPICLF_JVY,i)
          fcz  = ppiclf_ydotc(PPICLF_JVZ,i)
 
          ! set ydot for all PPICLF_LRS number of equations
          ppiclf_ydot(PPICLF_JX ,i) = ppiclf_y(PPICLF_JVX,i)
          ppiclf_ydot(PPICLF_JY ,i) = ppiclf_y(PPICLF_JVY,i)
          ppiclf_ydot(PPICLF_JZ ,i) = ppiclf_y(PPICLF_JVZ,i)
          ppiclf_ydot(PPICLF_JVX,i) = (fbx+fcx)/rmass
          ppiclf_ydot(PPICLF_JVY,i) = (fby+fcy)/rmass
          ppiclf_ydot(PPICLF_JVZ,i) = (fbz+fcz)/rmass
       enddo 
 ! evaluate ydot
 
       return
       end

In this example, the do-loop loops through the total number of particles on each processor, which is the variable ppiclf_npart. The user computes the total collision force (see below) and weight in each direction for each particle. Then, the 6 equations are specified according to the system of equations defined in this case. 

As given in the governing equations, a collision search results in many computed values for each particle pair that overlapps. The ppiclF library uses a special algorithm (**here**) so that the user does not have to deal with the complications, and a parallel neighbor search is performed behind the scenes. In the external calls (see below in the next section), a distance, which for now we will call :code:`W`, is specified. By invoking the optional subroutine ppiclf_solve_NearestNeighbor() in line 24, the routine ppiclf_user_EvalNearestNeighbor() is called. 

The routine ppiclf_user_EvalNearestNeighbor(i,j,yi,rpropi,yj,rpropj) has six arguements. For the i particle, this routine will call all the j neighboring particles and boundaries that are within :code:`W` of the i particle's location. The current :math:`\mathbf{Y}` vector of the i and j particles may be accessed through the dummy input arguement yi(k) and yj(k), where k is one of the PPICLF_LRS values declared in the PPICLF_USER.h file. Similarly, the properties of the i and j particles may be accessed through the dummy input arguements rpropi(k) and rpropj(k), where k is one of the PPICLF_LRP values declared in the PPICLF_USER.h file.

While i corresponds to the i particle in the do-loop in the routine ppiclf_user_SetYdot(), the actual value of index j can be positive, negiative, or zero. **The user should not attempt to use index j in any calculation.** The index j **CAN** be used as a conditional check though, as it is in this example. When j is zero, it corresponds to the point on a nearby boundary surface (see section below). When j is not zero, a distance can be used between the coordinates of yi and yj to see if the two particles overlap. If they do, a collision force is computed and stored in a vector ppiclf_ydotc which is then used to compute the collision force in the above routine ppiclf_user_SetYdot().

When j is zero, a collision force is still computed with the same soft sphere model, with the assumption that the boundary is a particle of infinite mass. The corresponding coordinates in the yj array in the case of a boundary then gives the closest point on a nearby boundary. The subroutine ppiclf_user_EvalNearestNeighbor() is given below for this case.

.. code-block:: fortran
 :linenos:

       subroutine ppiclf_user_EvalNearestNeighbor
      >                                        (i,j,yi,rpropi,yj,rpropj)
 !
       implicit none
 !
 #include "PPICLF.h"
 !
 ! Input:
 !
       integer*4 i
       integer*4 j
       real*8 yi(*)     ! PPICLF_LRS
       real*8 rpropi(*) ! PPICLF_LRP
       real*8 yj(*)     ! PPICLF_LRS
       real*8 rpropj(*) ! PPICLF_LRP
 !
 ! Internal:
 !
       real*8 ksp,erest
       common /ucollision/ ksp,erest
 #ifdef PPICLC
       BIND(C, name="ucollision") :: /ucollision/ ! c binding
 #endif
 
       real*8 rpi2, rthresh, rxdiff, rydiff, rzdiff, rdiff, rm1, rm2,
      >       rmult, eta, rbot, rn_12x, rn_12y, rn_12z, rdelta12,
      >       rv12_mag, rv12_mage, rksp_max, rnmag, rksp_wall, rextra
 !
       rpi2  =  9.869604401089358d0
 
       ! other particles
       if (j .ne. 0) then
          rthresh  = 0.5d0*(rpropi(PPICLF_R_JDP) + rpropj(PPICLF_R_JDP))
          
          rxdiff = yj(PPICLF_JX) - yi(PPICLF_JX)
          rydiff = yj(PPICLF_JY) - yi(PPICLF_JY)
          rzdiff = yj(PPICLF_JZ) - yi(PPICLF_JZ)
          
          rdiff = sqrt(rxdiff**2 + rydiff**2 + rzdiff**2)
          
          if (rdiff .gt. rthresh) return
          
          rm1 = rpropi(PPICLF_R_JRHOP)*rpropi(PPICLF_R_JVOLP)
          rm2 = rpropj(PPICLF_R_JRHOP)*rpropj(PPICLF_R_JVOLP)
          
          rmult = 1.0d0/sqrt(1.0d0/rm1+1.0d0/rm2)
          eta   = 2.0d0*sqrt(ksp)*log(erest)/sqrt(log(erest)**2+rpi2)
      >           *rmult
          
          rbot = 1.0d0/rdiff
          rn_12x = rxdiff*rbot
          rn_12y = rydiff*rbot
          rn_12z = rzdiff*rbot
          
          rdelta12 = rthresh - rdiff
          
          rv12_mag = (yj(PPICLF_JVX)-yi(PPICLF_JVX))*rn_12x +
      >              (yj(PPICLF_JVY)-yi(PPICLF_JVY))*rn_12y +
      >              (yj(PPICLF_JVZ)-yi(PPICLF_JVZ))*rn_12z
 
          rv12_mage = rv12_mag*eta
          rksp_max  = ksp*rdelta12
          rnmag     = -rksp_max - rv12_mage
          
          ppiclf_ydotc(PPICLF_JVX,i) = ppiclf_ydotc(PPICLF_JVX,i)
      >                              + rnmag*rn_12x
          ppiclf_ydotc(PPICLF_JVY,i) = ppiclf_ydotc(PPICLF_JVY,i)
      >                              + rnmag*rn_12y
          ppiclf_ydotc(PPICLF_JVZ,i) = ppiclf_ydotc(PPICLF_JVZ,i)
      >                              + rnmag*rn_12z
 
       ! boundaries
       elseif (j .eq. 0) then
 
          rksp_wall = ksp
 
          ! give a bit larger collision threshold for walls
          rextra   = 0.5d0
          rthresh  = (0.5d0+rextra)*rpropi(PPICLF_R_JDP)
          
          rxdiff = yj(PPICLF_JX) - yi(PPICLF_JX)
          rydiff = yj(PPICLF_JY) - yi(PPICLF_JY)
          rzdiff = yj(PPICLF_JZ) - yi(PPICLF_JZ)
          
          rdiff = sqrt(rxdiff**2 + rydiff**2 + rzdiff**2)
          
          if (rdiff .gt. rthresh) return
          
          rm1 = rpropi(PPICLF_R_JRHOP)*rpropi(PPICLF_R_JVOLP)
          
          rmult = sqrt(rm1)
          eta   = 2.0d0*sqrt(rksp_wall)*log(erest)
      >           /sqrt(log(erest)**2+rpi2)*rmult
          
          rbot = 1.0d0/rdiff
          rn_12x = rxdiff*rbot
          rn_12y = rydiff*rbot
          rn_12z = rzdiff*rbot
          
          rdelta12 = rthresh - rdiff
          
          rv12_mag = -1.0d0*(yi(PPICLF_JVX)*rn_12x +
      >                      yi(PPICLF_JVY)*rn_12y +
      >                      yi(PPICLF_JVZ)*rn_12z)
 
          rv12_mage = rv12_mag*eta
          rksp_max  = rksp_wall*rdelta12
          rnmag     = -rksp_max - rv12_mage
          
          ppiclf_ydotc(PPICLF_JVX,i) = ppiclf_ydotc(PPICLF_JVX,i)
      >                              + rnmag*rn_12x
          ppiclf_ydotc(PPICLF_JVY,i) = ppiclf_ydotc(PPICLF_JVY,i)
      >                              + rnmag*rn_12y
          ppiclf_ydotc(PPICLF_JVZ,i) = ppiclf_ydotc(PPICLF_JVZ,i)
      >                              + rnmag*rn_12z
 
       endif
 
       return
       end
 
Note that the additional subroutine ppiclf_user_MapProjPart() is delcared as well. Since it is not used in this example, it is left empty but still delcared.

The two user files PPICLF_USER.h and ppiclf_user.f are then copied to the LocalCodeDir/ppiclF/source/ directory and the library can be built using make.

External Calls
^^^^^^^^^^^^^^
In order to solve the system of equations, a driver program is used. In this case, a simple fortran MPI program in the example file test.f is used for this purpose (the library can instead be linked as a static library, as decribed in the :ref:`linking` section). Specifically, the driver program is responsible for setting the initial conditions of the solution variables :math:`\mathbf{Y}_0 = \mathbf{Y} (t = 0)`, specifying solver options, and looping through time. 

The program in test.f for this case is nearly identical as the :ref:`stokes2d` example case. However, there are a few key differences. These differences are:

1. Particles are initialized with a random diameter between the variables dp_min and dp_max.

2. The subroutine ppiclf_solve_InitNeighborBin(dp_max) is called directly after the particles are initialized. The input to this routine is the 8-byte real variable :code:`W`. In this cases, a collision only happens when particles overlap, so it is sufficient to pass in the largest possible particle diameter dp_max.

3. The subroutine ppiclf_io_ReadWallVTK() is called to specify the boundary conditions (see next section).

4. The time step is limited by the collision time scale given previously.

5. The collision spring stiffness and coefficient of restitituion are save in the common block /ucollision/ so they can be specified at run time after the library has been built.

Boundary Specification
^^^^^^^^^^^^^^^^^^^^^^
As previously mentioned, the subroutine ppiclf_io_ReadWallVTK() is called to specify the boundary conditions. The input to this routine is a character string and specifies the file with VTK format that will be read in to specifiy the boundary conditions. 

The format of the file is a minimized ascii VTK format as shown below.

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

This format can actually be output using the free finite element mesh generator Gmsh_. The process is to create the appropriate mesh, export as a VTK file, and then remove everything except the format as specified above. **Please make sure there are no blank lines.**

.. _Gmsh: https://gmsh.info

In the present example, a cylindrical tank with an opening at the bottom which feeds into a box is used.
