%% Crystal Orientation as Coordinate Transformation
%
%%
% An orientation in MTEX is the rotation that takes
% <CrystalDirections.html crystal coordinates> - a direction or a tensor
% written in the <CrystalReferenceSystem.html crystal reference frame> - to
% specimen coordinates, the description of the same object in the frame the
% sample sits in.
%
% Everything else on this page follows from that one sentence, including the
% side an orientation has to be multiplied on and what happens when the
% specimen is turned.

plottingConvention.default('y↑→x');

%% The Two Ingredients
%
% An orientation is a <rotation.rotation.html rotation>

rot = rotation.rand

%%
% together with a description of the crystal lattice, a
% <crystalSymmetry.crystalSymmetry.html |crystalSymmetry|>.

cs = crystalSymmetry.load("Al-Aluminum.cif")

%%
% Combined, they are an orientation.

ori = orientation(rot,cs)

%%
% An orientation is therefore a rotation as well, and every
% <RotationOperations.html rotation operation> applies to it.

%% From Crystal Coordinates to Specimen Coordinates
%
% Take a crystal direction.

h = Miller(1,0,0,cs,'uvw')

%%
% In a grain of orientation |ori| that direction points here, in specimen
% coordinates.

r = ori * h

%%
% This is the whole idea in one picture. The crystal is drawn where the
% orientation |ori| puts it, the black arrows are the specimen axes X, Y and
% Z, and the red arrow is the crystal direction |h| expressed in specimen
% coordinates. The direction is fixed in the lattice; what the orientation
% supplies is where the lattice is pointing.

cS = crystalShape.cube(cs);

plot(ori * cS,'faceAlpha',0.35,'faceColor',[0.6 0.75 0.9])
hold on
arrow3d(1.3*normalize(vector3d(r)),'faceColor','red')
arrow3d(1.6*[vector3d.X,vector3d.Y,vector3d.Z],'faceColor','black')
hold off

%%
% Tensors transform the same way. A single crystal stiffness tensor given in
% the crystal frame

C = stiffnessTensor(...
  [[2 1 1 0 0 0];...
  [1 2 1 0 0 0];...
  [1 1 2 0 0 0];...
  [0 0 0 1 0 0];...
  [0 0 0 0 1 0];...
  [0 0 0 0 0 1]],cs)

%%
% becomes a stiffness tensor in the specimen frame.

ori * C

%%
% Everything that is defined in the crystal frame travels this way:
%
% * <Miller.Miller.html crystal directions>
% * <tensor.tensor.html tensors>
% * <slipSystem.slipSystem.html slip systems>
% * <twinningSystem.twinningSystem.html twinning systems>
% * <dislocationSystem.dislocationSystem.html dislocation systems>
% * <crystalShape.crystalShape.html crystal shapes>
%
%% And Back Again
%
% The inverse orientation takes specimen coordinates to crystal coordinates,
% so applying it to |r| returns the direction we started from.

hBack = inv(ori) * r

%%
% The numbers look nothing like the $[100]$ we started from, because a
% |Miller| displays as $(hkl)$ unless told otherwise, and $[100]$ for
% aluminium is the vector of length $a = 4.05$ Angstrom. Asking for the
% lattice direction notation gives it back.

hBack.dispStyle = 'uvw';
round(hBack)

%%
% Much of the literature defines an orientation the other way round, as the
% transformation from specimen to crystal coordinates - what MTEX calls
% |inv(ori)|. Both conventions are in use, and reading a table of Euler
% angles in the wrong one inverts every orientation in it. The consequences
% are spelled out in <MTEXvsBungeConvention.html MTEX vs. Bunge Convention>.

%% Turning the Specimen
%
% Rotating the specimen - putting the sample on the stage the other way
% round - changes every orientation in it. Such a rotation acts in specimen
% coordinates, hence from the left.

rotSpecimen = rotation.byAxisAngle(vector3d.X,60*degree);

ori_new = rotSpecimen * ori

%%
% Every crystal direction moves with the specimen, which is what
% multiplying from the left means:

angle(ori_new * h, rotSpecimen * r) ./ degree

%%
% Zero - going through the new orientation and turning the old result give
% the same direction.
%
% The same rotation applied on the other side means something else. Used in
% crystal coordinates it turns the direction inside the lattice, before the
% orientation maps it out, and the result is a different specimen direction
% altogether.

angle(ori * (rotSpecimen * h), ori_new * h) ./ degree

%%
% Right multiplication is nonetheless the meaningful side for one purpose:
% multiplying by a symmetry operation of the crystal changes nothing at all,
% because the crystal cannot tell the two settings apart. That is precisely
% what <orientation.symmetrise.html |symmetrise|> does, and all 48 results
% are the same orientation - the largest angle between any of them and the
% original is zero up to rounding.

max(angle(ori.symmetrise,ori)) ./ degree

%%
% Which side a rotation belongs on is decided by the frame it is given in,
% and the same question decides the order of a misorientation product, see
% <MisorientationTheory.html Misorientations>.
%
% Orientations also depend on how the Cartesian crystal frame $\vec x$,
% $\vec y$, $\vec z$ is inscribed into the crystal axes $\vec a$, $\vec b$,
% $\vec c$, which is <CrystalReferenceSystem.html The Crystal Reference
% System>.

%% Next
%
% <OrientationSymmetry.html Symmetry> adds the fact that an orientation
% stands for a whole set of equivalent rotations, and
% <OrientationPoleFigure.html Pole Figures> is the standard way of drawing
% what this page computes by hand.

%#ok<*NOPTS>
