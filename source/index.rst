===============================================================================================
 A Parallel Particle-In-Cell Library in Fortran (`ppiclF <https://github.com/dpzwick/ppiclF>`_)
===============================================================================================

Capabilities
------------

* Integration for the system of equations:

.. math::
   \dfrac{d \mathbf{Y}}{d t} = \dot{\mathbf{Y}}.

* Open MPI parallelization allows billions of equations to be solved.
								           
* Load balances equations based on spatial position of particles.

* Links with both Fortran and C++ external code.
									            
* Allows simple user input of external overlapping mesh for interactions between particles and external mesh, including interpolation and projection.
											       
* Includes optional fast binned parallel nearest neighbor search between particles within a user defined distance.

.. .. admonition:: Recommended publication for citing
   :class: tip

.. Zwick, D., Scalable highly-resolved Euler-Lagrange multiphase flow simulation with applications to shock tubes, PhD Thesis, University of Flordia, 2019.

Quickstart
----------
.. toctree::
   :maxdepth: 2

   quickstart

Algorithms
----------

.. toctree::
   :maxdepth: 2

   algorithms

User Interface
--------------

.. toctree::
   :maxdepth: 2

   user

Examples
--------

.. toctree::
   :maxdepth: 2

   examples

Contributing
------------

.. toctree::
   :maxdepth: 2

   contribute

Acknowledgements
----------------

.. toctree::
   :maxdepth: 2

   acknowledge
