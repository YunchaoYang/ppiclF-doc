User Interface
==============

In this section, the user interface is detailed. This consists of the user providing two required files to the source code, which are the H-File and the F-File. In order to drive the library, the external interface provides possible variables and subroutines that can be called from an outside program.

Note that a user can copy an existing H-File, F-File, and external calls from a previous example case to fit their setup. Alternatively, there is a simple python script `usergen.py <https://github.com/dpzwick/ppiclF/blob/master/tools/usergen.py>`_ which will walk the user through generating these files for a specific case from scratch. This file can be used by issuing the command :code:`python usergen.py`.

.. toctree::
   :maxdepth: 1

   user/hfile
   user/ffile
   user/external
   user/output
