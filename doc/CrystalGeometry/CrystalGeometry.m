%% Crystal Geometry
%
%%
% A crystal is a lattice repeated over and over, and a lattice looks the
% same from more than one point of view. Rotate a cubic crystal by ninety
% degrees about a cube axis and nothing has changed that any measurement
% could detect. The set of all such motions is the crystal's *symmetry*,
% and it is the single most consequential fact about working with crystal
% data.
%
% The consequence is this: inside a crystal there is no such thing as one
% direction. Ask for the [111] direction of a cubic crystal and you have
% named eight directions at once, because symmetry cannot tell them apart.
% Every angle, every average, every distance computed later has to respect
% that, or it computes something the crystal does not know about.

cs = crystalSymmetry('m-3m');

% the eight directions that the label (111) names in a cubic crystal
plot(Miller(1,1,1,cs).symmetrise('unique'),'labeled','grid','backgroundColor','w')

%%
% Note the |'unique'| above. Without it |symmetrise| returns one entry per
% symmetry operation - 48 for this point group - and the eight distinct
% directions simply appear repeatedly.

%%
% Symmetry is also why a direction in a crystal and a plane in a crystal
% are written differently and behave differently. In a cubic lattice the
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
% Diffraction cannot distinguish a direction from its opposite, so what an
% EBSD or X-ray measurement actually determines is the Laue group. MTEX
% works with point groups, and accepts a space group name by reducing it to
% its point group.
%
%% Where to start
%
% <CrystalSymmetries.html Crystal Symmetries> is the foundation - how to
% declare a phase, from a name, from lattice parameters or from a CIF file.
%
% <CrystalDirections.html Miller Indices> covers directions and planes in a
% crystal and the difference between them raised above.
% <CrystalOperations.html Operations> is the arithmetic - angles, symmetric
% equivalents, zone axes.
%
% Two pages then deal with something that causes more confusion than any
% other topic here. A point group says which operations exist; it does not
% say how the crystal's axes are laid onto Cartesian ones, and for
% everything but cubic there is a choice to make.
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
