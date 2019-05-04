===============================================================================================
 A Parallel Particle-In-Cell Library in Fortran (`ppiclF <https://github.com/dpzwick/ppiclF>`_)
===============================================================================================

ppiclF is a parallel particle-in-cell library written in Fortran. 

Applications of ppilcF include element-based particle-in-cell simulations, such as Euler-Lagrange mutliphase flow simulation, immersed boundary methods, and even atomistic-scale modeling. At its essence, ppiclF's main purpose is to provide a unified and scalable interface for a user to solve the following system of differential equations

           
.. math::
   \frac{d \mathbf{Y}}{d t} = \dot{\mathbf{Y}}

which are found in all of the previously given particle-in-cell applications. The library can be downloaded from ppiclF_. On this documentation website, you will find more details, theory, examples, questions, etc.

Capabilities
------------

* On-the-fly load-balancing of the system of equations across MPI processing ranks based on the coordinates associated with each particle. 

* Simple user input of an external overlapping mesh for interactions between particles and their nearby cells.

* Optional fast binned parallel nearest neighbor search between particles within a user specified distance so that more sophisticated user-implemented right-hand-side forcing models can easily be evaluated. 

* Algorithms have demonstrated scalability to 100,000 processors, allowing billions of equations to be solved simultaneously. 

* Links to both Fortran and C++ external code as a library.


* :download:`Overview of ppiclF <ppiclF_overview.pdf>`.

.. .. admonition:: Recommended publication for citing
   :class: tip

.. Zwick, D., Scalable highly-resolved Euler-Lagrange multiphase flow simulation with applications to shock tubes, PhD Thesis, University of Flordia, 2019.

Quickstart
----------
.. toctree::
   :maxdepth: 3

   quickstart

Algorithms
----------

.. toctree::
   :maxdepth: 3

   algorithms

User Interface
--------------

.. toctree::
   :maxdepth: 3

   user

Examples
--------

.. toctree::
   :maxdepth: 3

   examples

Contributing
------------

.. toctree::
   :maxdepth: 3

   contribute

Acknowledgements
----------------

.. toctree::
   :maxdepth: 3

   acknowledge
