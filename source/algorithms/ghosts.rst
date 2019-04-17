.. _ghosts:

---------------
Ghost Particles
---------------
Particles in the interior of bins have access to locally stored particles through the mapping of bins to ranks (see :ref:`part-storage`) and the locally stored mesh through mapping the mesh to bins (see :ref:`overlap-mesh`). However, particles near the boundary of bins may interact with data that is stored in the processing ranks associated with neighboring bins. This interaction may occur in two ways:

1. Particles near the edge of one bin need information from particles in a neighboring bin,
2. Projection of particles near the edge of one bin spills over into neighboring bins.

In either case, ppiclF handles these interactions through the use of ghost particles. Ghost particles are simply copies of computational particles which are used to communicate particle data to neighboring bins that are stored on different processors. 

Recall that a user may specify a minimum interaction length, which we called :code:`W` (see :ref:`part-storage`). This length specifies the minimum length of bins in each dimension, even though the actual length of bins is most often determined by the number of processors used. For this reason, a single ghost particle is created for each bin that touches the current bin that a particle is stored with when the distance from the particle to the closest point in the neighboring bin is less than :code:`W`. 

As a result, only the single layer of neighbor bins to the bin a particle is stored in may recieve a ghost particle. Due to the Cartesian layout of bins, this results in at most 26 ghost particles in 3D and 8 ghost particles in 2D being created for each computational particle.
