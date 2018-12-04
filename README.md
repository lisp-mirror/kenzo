

imported from a tarball from https://www-fourier.ujf-grenoble.fr/~sergerar/Kenzo/

The Kenzo program implements the methods of Constructive Algebraic Topology. The funny corresponding acronym CAT gave the idea to name this program as my beloved cat.

The first version of this program, called EAT for Effective Algebraic Topology, was a joint work with Julio Rubio (1990). The EAT program was totally rewritten with Xavier Dousson in 1998, becoming Kenzo, on the one hand to include many technical improvements, in particular in memory management, improvements deduced from the EAT experience, and on the other hand to implement the Whitehead Tower and compute homotopy groups of arbitrary simply connected simplicial sets, the heart of Xavier's thesis. A detailed Kenzo documentation was simulatneously written by Yvon Siret.

The 1.1.8 version now proposed takes account of the new mathematical technology based on Discrete Vector Fields. Discovered by Robin Forman, it happens this method considerably improves the implementation of the Eilenberg-Zilber theorem, twisted or not, and also the computation of the effective homology of the Eilenberg-MacLane spaces, crucial when using the Postnikov or Whitehead towers.