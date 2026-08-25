%% Crystal Geometry
%
%%
% A crystal structure repeats a motif at the translation points of a
% lattice, and it can look the same from more than one point of view. For a
% crystal with point group |m-3m|, a ninety-degree rotation about a cube axis
% leaves the structure indistinguishable. The operations that do this form
% the crystal's *symmetry*, and they have to be respected whenever crystal
% directions or orientations are compared.
%
% The indices $[111]$ still select one direction relative to the named
% crystal axes. Symmetry associates it with seven other directions, however;
% together the eight are the $\langle111\rangle$ family for |m-3m|. Whether
% a calculation uses the indexed direction or all equivalent members must
% therefore be explicit.

cs = crystalSymmetry('m-3m');

% the eight members of the symmetry-equivalent direction family
d111 = Miller(1,1,1,cs,'uvw');
plot(d111.symmetrise('unique'),'labeled','grid','backgroundColor','w')

%%
% Note the |'unique'| above. Without it |symmetrise| returns one entry per
% symmetry operation - 48 for this point group - and the eight distinct
% directions simply appear repeatedly.

%%
% A direction in a crystal and a plane in a crystal are written differently
% and belong to dual coordinate systems. In a cubic lattice the
% [111] direction happens to be perpendicular to the (111) plane, which
% makes cubic a bad place to learn the difference; in a monoclinic lattice
% they are not perpendicular at all, and confusing the two silently gives
% the wrong answer.
%
%% Point groups, space groups, Laue groups
%
% Three classifications turn up constantly and are easy to mix up. The
% *point group* collects the symmetry operations that leave one point
% fixed - rotations, mirrors, inversion - and there are 32 of them. The
% *space group* additionally allows translations, screw axes and glide
% planes, giving 230. The *Laue group* is the point group with an inversion
% centre added, giving 11.
%
% Under Friedel's law, conventional diffraction intensities cannot
% distinguish a reflection from its opposite, so diffraction symmetry is
% commonly described by the Laue group. Dynamical and resonant diffraction
% can reveal departures from Friedel's law. MTEX stores point groups and
% accepts a space-group symbol or number by reducing it to the corresponding
% point group.
%
%% Where to start
%
% <CrystalSymmetries.html Crystal Symmetries> is the foundation - how to
% declare a phase, from a name, from lattice parameters or from a CIF file.
%
% <CrystalDirections.html Miller Indices> covers directions and planes in a
% crystal and the difference between them raised above.
% <LatticeMetric.html Lattice Metric and Plane Geometry> covers the unit
% cell, reciprocal basis, physical lengths, interplanar spacings and the
% constraints of the seven crystal systems.
% <CrystalOperations.html Operations> is the arithmetic - angles, symmetric
% equivalents, multiplicities, incidence tests and zone axes.
%
% Two pages then separate conventions that are easily confused. A point
% group says which operations exist; it does not say how the crystal axes
% are laid onto Cartesian ones. Nor does it say which physical lattice
% vectors a particular source calls $\vec a$, $\vec b$ and $\vec c$.
% <CrystalReferenceSystem.html Reference System> and
% <SymmetryAlignment.html Crystal Axes Alignment> are where that choice is
% made explicit. If data imported from two sources disagrees by a rotation
% that looks like nothing physical, this is almost always why.
%
% <CrystalShapes.html Crystal Shapes> and
% <CrystalShapeSmorf.html Advanced Crystal Shapes> build the little
% polyhedra used to draw a crystal in a map, which is the most direct way
% to see what an orientation means.
%
% <FundamentalSector.html Fundamental Sector> is the counterpart of the
% opening figure: since symmetry makes many directions equivalent, only a
% patch of the sphere is needed to hold every distinct one. That patch is
% what an inverse pole figure is drawn on.
%
% <QuasiCrystals.html Quasi Symmetries> covers symmetries that no periodic
% lattice can have.
%
%% Next
%
% A crystal placed in a specimen is an *orientation*,
% <CrystalOrientations.html Orientations>. Directions without a crystal
% attached are <Vectors.html Vectors>. Physical properties that depend on
% crystal direction are <Tensors.html Tensors>.
%
% Geometry used in deformation is developed in
% <SlipSystems.html Slip Systems> and
% <DislocationSystems.html Dislocation Systems>. Twin relationships are
% <Twinning.html Twinning>, and geometry connecting two phases starts with
% <ParentChildVariants.html Parent-Child Variants>.
%
