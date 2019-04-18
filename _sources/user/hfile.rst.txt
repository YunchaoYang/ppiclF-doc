.. _hfile:

----------
The H-File
----------
The H-File refers to the file PPICLF_USER.h. This file is required for each case and specifies the maximum size of different arrays used in the code. These sizes are defined by C pre-processor directives, which use the :code:`#define NAME N` syntax, where :code:`NAME` is the variable name in capital letters and :code:`N` is the integer number that :code:`NAME` is replaced by everywhere in the code at compilation. 

The pre-processor directives, along with the actual arrays and other ppiclF variables can be included for use in any Fortran subroutine by simply including the following directive at the top of a routine

.. code-block:: fortran

   #include "PPICLF.h"

Pre-Defined Directives
^^^^^^^^^^^^^^^^^^^^^^
A list of pre-defined names are found in the table below with their descriptions.

.. table:: Pre-processor pre-defined names in PPICLF_USER.h.
   :align: center

   +------------------------+-----------+-------------------------------------------------------+
   | :code:`NAME`           | Required? | Description                                           |
   +========================+===========+=======================================================+
   | :code:`PPICLF_LRS`     | Yes       | The number of equations solved per particle.          |
   +------------------------+-----------+-------------------------------------------------------+
   | :code:`PPICLF_LRP`     | No        | The number of additional properties per particle.     |
   +------------------------+-----------+-------------------------------------------------------+
   | :code:`PPICLF_LPART`   | No        | The maximum number of particles per rank.             |
   +------------------------+-----------+-------------------------------------------------------+
   | :code:`PPICLF_LRP_INT` | No        | The number of interpolated fields.                    |
   +------------------------+-----------+-------------------------------------------------------+
   | :code:`PPICLF_LRP_PRO` | No        | The number of projected fields.                       |
   +------------------------+-----------+-------------------------------------------------------+
   | :code:`PPICLF_LEE`     | No        | The maximum number of overlap mesh elements per rank. |
   +------------------------+-----------+-------------------------------------------------------+
   | :code:`PPICLF_LEX`     | No        | The number of x coordinates per overlap mesh element. |
   +------------------------+-----------+-------------------------------------------------------+
   | :code:`PPICLF_LEY`     | No        | The number of y coordinates per overlap mesh element. |
   +------------------------+-----------+-------------------------------------------------------+
   | :code:`PPICLF_LEZ`     | No        | The number of z coordinates per overlap mesh element. |
   +------------------------+-----------+-------------------------------------------------------+
   | :code:`PPICLF_LWALL`   | No        | The maximum number of triangular patch boundaries.    |
   +------------------------+-----------+-------------------------------------------------------+

User-Only Directives
^^^^^^^^^^^^^^^^^^^^
A list of user-only suggested names are found in the table below with their descriptions. Each of these names can be chosen by the user to reflect the equations being solved.

.. table:: Pre-processor suggested names in PPICLF_USER.h.
   :align: center

   +------------------------+---------------------------------+
   | Suggested :code:`NAME` | Description                     |
   +========================+=================================+
   | :code:`PPICLF_J*`      | Index in solution array.        |
   +------------------------+---------------------------------+
   | :code:`PPICLF_R_J*`    | Index in property array.        |
   +------------------------+---------------------------------+
   | :code:`PPICLF_P_J*`    | Index in projected field array. |
   +------------------------+---------------------------------+

Here, the above suggested names may be used for easy naming with user-edited coded. For example, consider the system of equations

.. math::
   \dfrac{d \mathbf{Y}}{d t} = \dot{\mathbf{Y}},

.. math::
   \mathbf{Y} = \begin{bmatrix}X \\ Y \\ V_x \\ V_y \end{bmatrix},\quad \dot{\mathbf{Y}} = \begin{bmatrix} V_x \\ V_y \\ -a V_x \\ -a V_y + b \end{bmatrix}.

In this case, we can refer to the equations as solving for the variables :math:`X`, :math:`Y`, :math:`V_x`, and :math:`V_y`. As a result, the user may want to refer to the equations as

.. code-block:: c

   #define PPICLF_JX 1
   #define PPICLF_JY 2
   #define PPICLF_JVX 3
   #define PPICLF_JVY 4

Then, the user can use these directive names in place of the index j for the i particle in the solution arrays ppiclf_y(j,i), ppiclf_ydot(j,i), and ppiclf_ydotc(j,i).

.. admonition:: Caution: User ordering of solution array indices.
   :class: warning

   1. The indices are ordered from 1 to :code:`PPICLF_LRS`.
   2. The first two (2D) or three (3D) indicies must always be the :math:`X`, :math:`Y`, and :math:`Z` (3D only) coordinates of each particle.

Similarly, if :math:`a` and :math:`b` are properties of each particle that are not being solved for, the user may want to refer to the properties as

.. code-block:: c

   #define PPICLF_R_JA 1
   #define PPICLF_R_JB 2

Then, the user can use these directive names in place of the index j for the i particle in the property array ppiclf_rprop(j,i). 

.. admonition:: Caution: User ordering of property array indices.
   :class: warning

   1. The indices are ordered from 1 to :code:`PPICLF_LRP`.

Similarly, if the user is projecting any properties, each mapped (see :ref:`ffile`) projected fields can also be referenced in this way. Consider three projected fields :math:`f(\mathbf{x})`, :math:`g(\mathbf{x})`, and :math:`h(\mathbf{x})`. The user may want to refer to these fields as

.. code-block:: c

   #define PPICLF_P_JF 1
   #define PPICLF_P_JG 2
   #define PPICLF_P_JH 3

Then, the user can use these directive names in place of the index m for the (i,j,k) coordinate of the e element on the overlap mesh in the projected field array ppiclf_pro_fld(i,j,k,e,m). 

.. admonition:: Caution: User ordering of projection array indices.
   :class: warning

   1. The indices are ordered from 1 to :code:`PPICLF_LRP_PRO`.
