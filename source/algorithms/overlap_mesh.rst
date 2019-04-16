.. _overlap-mesh:

------------
Overlap Mesh
------------

Overview
^^^^^^^^
In particle-in-cell simulations, the particles are often required to interact with an Eulerian mesh. Since the particle are tracked individually at discrete locations that do not necessarily coincide with a mesh, interactions between the particles and mesh must be handled carefully. We define two key opperations between the particles and the mesh:

1. Interpolation - field quantities on the mesh are evaulated at the particle's coordinates,
2. Projection - particle quantities are filtered from the particle's coordinates to the mesh.

Both of these operations require the user to initially specify the coordinates of the mesh. In the current version of ppiclF, only element based hexahedral meshes are supported.

.. figure:: bin_map.png
   :align: center
   :figclass: align-center

   Illustration of mapping overlapping mesh to bins
