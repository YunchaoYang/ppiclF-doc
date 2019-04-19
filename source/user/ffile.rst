.. _ffile:

----------
The F-File
----------
The F-File refers to the file ppiclf_user.f. This file is required for each case and specifies three key subroutines in the code. Each of these subroutines are described below. In what follows, the terms *int* and *real* refer to the Fortran integer*4 and real*8 types, which are also the types int and double in C.

ppiclf_user_SetYdot
^^^^^^^^^^^^^^^^^^^
The main purpose of this subroutine is described below.

..
..
.. admonition:: ppiclf_user_SetYdot()

   This routine must set :math:`\dot{\mathbf{Y}}` for the system of equations

   .. math::
      \dfrac{d \mathbf{Y}}{d t} = \dot{\mathbf{Y}}

   This is done by specifying the j indices (corresponding to the j equations) of the array ppiclf_ydot(j,i) for the i particle.


Typically, this subroutine amounts to a do-loop over the index i which loops through the total number of particles on each processor (ppiclf_npart). The user is then required to specify :math:`\dot{\mathbf{Y}}^{(i)}` by setting the j indices ranging from 1 to :code:`PPICLF_LRS` of the array ppiclf_ydot(j,i). Since :math:`\dot{\mathbf{Y}}^{(i)}` may be a function of :math:`\mathbf{Y}` and other properties associated with each particle, the user-defined pre-processor directives can be useful in organizing this evaluation.

Note that additionally, the routine ppiclf_solve_NearestNeighbor can optionally be called for the i particle within the do-loop. When this occurs, the nearby neighbor searching routine ppiclf_user_EvalNearestNeighbor is activated (see below). 

After ppiclf_ydot(j,i) is set, a user may also choose to store some computed values in the array ppiclf_ydotc(j,i) which is ordered the same as ppiclf_ydot(j,i). Values stored in this array are then passed to the projection mapping routine ppiclf_user_MapProjPart (see below).

ppiclf_user_MapProjPart
^^^^^^^^^^^^^^^^^^^^^^^
The main purpose of this subroutine is to specify which particle properties :math:`A` are projected to which fields :math:`a(\mathbf{x})`. For more details on the projection opperation, see :ref:`projection`. Note that projection can only be performed when there is an overlap mesh specified. A description of this routine is given below.

..
..
.. admonition:: ppiclf_user_MapProjPart(real **map**, real **y**, real **ydot**, real **ydotc**, real **rprop**)

   This routine specifies which particle properties are projected to which fields.

   * **map(m)** is a vector input of length :code:`PPICLF_LRP_PRO` which must be set, corresponding to the particle property :math:`A`. The m index corresponds to which field is being projected in the ppiclf_pro_fld(i,j,k,e,m) array. The user-defined pre-processor directives can be useful in organizing this evaluation.
   * **y(j)**, **ydot(j)**, and **ydotc(j)** are vector inputs of length :code:`PPICLF_LRS`. They correspond to the values in the arrays of the i particle ppiclf_y(j,i), ppiclf_ydot(j,i), and ppiclf_ydotc(j,i). Each of these can be used in evaulating **map(m)**.
   * **rprop(j)** is a vector input of length :code:`PPICLF_LRP`. It corresponds to the values in the array of the i particle ppiclf_rprop(j,i). Its values can be used in evaulating **map(m)**.

ppiclf_user_EvalNearestNeighbor
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
The main purpose of this subroutine is to allow the user to have access to neighboring particle's information. For the i particle, the j nearest points are passed in within a distance :code:`W` (see :ref:`part-storage`). This routine is only activated when the routine ppiclf_user_NearestNeighbor is called for the i particle in the do-loop in ppiclf_user_SetYdot (see :ref:`dem3d` for an example of this). The routine ppiclf_user_NearestNeighbor is described below.

..
..
.. admonition:: ppiclf_user_NearestNeighbor(int **i**)

   This routine specifies that the ppiclf_user_EvalNearestNeighbor routine should be called.

   * **i** is the i particle for which the nearest neighbors are found.

Additionally, the routine ppiclf_user_EvalNearestNeighbor is described below.

..
..
.. admonition:: ppiclf_user_EvalNearestNeighbor(int **i**, int **j**, real **yi**, real **rpropi**, real **yj**, real **rpropj***)

   This routine evaluates the nearest neighbors of the i particle. The neighbors are the j points which are either nearby particles or nearby boundaries. This routine is only activated when ppiclf_user_NearestNeighbor is called for the i particle in ppiclf_user_SetYdot.

   * **i** is the i particle for which the nearest neighbors are found for. The index i may also be used to access the internal arrays (i.e., ppiclf_y(:,i), ppiclf_ydot(:,i), ppiclf_ydotc(:,i), and ppiclf_rprop(:,i).
   * **j** is the j point for which the nearest neighbors of particle i are found. **DO NOT USE j TO ACCESS THE INTERNAL ARRAYS**. The index j may be positive, negative, or zero. A positive value means that the neighbor particle is on the same processor. A negative value means that the neighbor particle is on a different processor. A value of j = 0 means that the neighbor point is a boundary point.
   * **yi** is a vector of length :code:`PPICLF_LRS` which passes in the solution variables of the i particle.
   * **rpropi** is a vector of length :code:`PPICLF_LRP` which passes in the properties of the i particle.
   * **yj** is a vector of length :code:`PPICLF_LRS` which passes in the solution variables of the j particle. Note that when a boundary point is passed in as point j (j == 0), then only the first two (2D) or three (3D) values of **yj** can be used, which store the nearest point on the boundary to the i particle.
   * **rpropj** is a vector of length :code:`PPICLF_LRP` which passes in the properties of the j particle. Note that when a boundary point is passed in as point j (j == 0), the values of **rpropj** are meaningless.
