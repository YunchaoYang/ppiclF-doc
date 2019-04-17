.. _hfile:

----------
The H-File
----------
The H-File (PPICLF_USER.h) is required for each case and specifies the maximum size of different arrays used in the code. These sizes are defined by C pre-processor directives.

In order to understand the naming convention, we recall that we solve the following system of equations for each particle

.. math::
   \dfrac{d \mathbf{Y}}{d t} = \dot{\mathbf{Y}},

where, for example, each particle may have

.. math::
   \mathbf{Y} = \begin{bmatrix}Y_1 \\ Y_2 \\ Y_3 \\ Y_4 \end{bmatrix},\quad \dot{\mathbf{Y}} = \begin{bmatrix}\dot{Y}_1 \\ \dot{Y}_2 \\ \dot{Y}_3 \\ \dot{Y}_3 \end{bmatrix}.

As is demonstrated above, for each particle in this case we are solving a system of 4 equations, which is the length of the vectors :math:`\mathbf{Y}` and :math:`\dot{\mathbf{Y}}`. We will order each equation as they appear in the array above. Note that the actual ordering of equations is up to the user, but it is required that the positions :math:`X`, :math:`Y`, and :math:`Z` (3D only) must be the first equations when ordering the vector. Accordinging we call the solution variables

.. code::

   PPICLF_JY1
   PPICLF_JY2
   PPICLF_JY3
   PPICLF_JY4

For this example then, the PPICLF_USER.h header file would define

.. code-block:: c

   #define PPICLF_LRS 4
   #define PPICLF_JY1 1
   #define PPICLF_JY2 2
   #define PPICLF_JY3 3
   #define PPICLF_JY4 4

It is seen that the number of equations is specified (PPICLF_LRS) and the equation names are ordered from 1 to PPICLF_LRS with the position being first. Note that you are not required to define PPICLF_JY1, PPICLF_JY2, PPICLF_JY3, and PPICLF_JY4, as these are user defined and only used in :ref:`ffile`. However, PPICLF_LRS must be defined based on the number of equations being solved.

Similarly, each particle may have a number of properties associated with them. For demonstration, lets say that each particle has properties PROPA and PROPB. We will name them accordingly

.. code::

   PPICLF_R_JPROPA
   PPICLF_R_JPROPB

Then, in the PPICLF_USER.h header file we would define

.. code-block:: c

   #define PPICLF_LRP 2
   #define PPICLF_R_JPROPA 1
   #define PPICLF_R_JPROPB 2

meaning that the number of properties is PPICLF_LRP and the property names are ordered from 1 to PPICLF_LRP. Note that you are not required to define PPICLF_R_JPROPA and PPICLF_R_JPROPB, as these are user determined and only used in :ref:`ffile`. However, PPICLF_LRP must be defined if any properties are to be used.

When an overlap mesh is specified, the size of the mesh must be specified. These varaibles must be named as follows

.. code::

   PPICLF_LEX
   PPICLF_LEY
   PPICLF_LEZ
   PPICLF_LEE

where PPICLF_LEZ does not need to be defined in 2D. Here, PPICLF_LEE is the maximum number of elements allowed on each rank. PPICLF_LEX, PPICLF_LEY, and PPICLF_LEZ specify the overlap mesh element coordinates in respecitve dimension. For example, in finite volume methods we would have 

.. code-block:: c

   #define PPICLF_LEX 2
   #define PPICLF_LEY 2
   #define PPICLF_LEZ 2
   #define PPICLF_LEE 1000

where the number 1000 should be replaced with an appropriate number of elements per processor on your application.

When used, the number of interpolated fields to interpolate must be set in PPICLF_USER.h. For 3 fields to interpolate, we would have

.. code-block:: c

   #define PPICLF_LRP_INT 3

Additionally, when used, the number of projected fields must be set in PPICLF_USER.h. For 6 projected fields, we would have

.. code-block:: c

   #define PPICLF_LRP_PRO 6

For ease of user access, we can name the fields similar to how the solution vector and property arrays were named but are not required to.
