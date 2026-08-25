%% Crystal Orientation as Coordinate Transformation
%
%%
% An orientation in MTEX maps crystal coordinates to specimen coordinates.
% It takes a direction or tensor expressed in the crystal frame and returns
% the same object expressed in the specimen frame.
%
% A *reference frame* is the coordinate system in which data are expressed.
% The *crystal frame* is the Cartesian frame fixed to a phase's lattice,
% while the *specimen frame* describes the sample in a measurement, rolling,
% or geological frame.
%
% This page assumes the Miller indices introduced in
% <CrystalDirections.html Crystal Directions> and the active rotations from
% <RotationOperations.html Rotation Operations>. Everything below follows
% from the direction of the coordinate map, including which side a rotation
% acts on and what happens when the specimen is turned.

plottingConvention.default('y↑→x');

%% The Two Ingredients
%
% An orientation combines a <rotation.rotation.html rotation> with the
% symmetry, lattice metric, and crystal frame stored by a
% <crystalSymmetry.crystalSymmetry.html |crystalSymmetry|>.

rot = rotation.byEuler(10*degree,20*degree,30*degree,'Bunge');

cs = crystalSymmetry.load("Al-Aluminum.cif")

%%
% The summary identifies aluminium, its point group, lattice parameters,
% and crystal-frame alignment. Combining |rot| and |cs| gives an
% orientation.

ori = orientation(rot,cs)

%%
% The arrow in the summary reads from the crystal frame on the left to the
% specimen frame on the right. An orientation is also a rotation, so every
% <RotationOperations.html rotation operation> applies to it.

%% From Crystal Coordinates to Specimen Coordinates
%
% Take the crystal direction $[100]$.

h = Miller(1,0,0,cs,'uvw');

%%
% In a grain with orientation |ori|, that direction has the following
% Cartesian components in the specimen frame.

r = ori * h

%%
% The picture shows the same map. The translucent cube is the crystal where
% |ori| places it. The black arrows are the specimen axes X, Y and Z, and
% the red arrow is the crystal direction |h| expressed in specimen
% coordinates. The direction is fixed in the lattice; what the orientation
% supplies is where the lattice is pointing.

cS = crystalShape.cube(cs);

figure;
plot(ori * cS,'faceAlpha',0.35,'faceColor',[0.6 0.75 0.9]);
hold on;
arrow3d(0.75*normalize(r),'faceColor','red');
arrow3d(0.75*[vector3d.X,vector3d.Y,vector3d.Z],...
  'faceColor','black');
hold off;

%% Other Crystal Objects Transform the Same Way
%
% The same multiplication applies to a stiffness tensor. This example starts
% with tensor components in the crystal frame.

C = stiffnessTensor(...
  [[2 1 1 0 0 0];...
  [1 2 1 0 0 0];...
  [1 1 2 0 0 0];...
  [0 0 0 1 0 0];...
  [0 0 0 0 1 0];...
  [0 0 0 0 0 1]],cs)

%%
% After the coordinate transform, the summary names the specimen frame and
% displays the transformed components.

Cspecimen = ori * C

%%
% Everything defined in the crystal frame travels in the same direction:
%
% * <Miller.Miller.html crystal directions>
% * <tensor.tensor.html tensors>
% * <slipSystem.slipSystem.html slip systems>
% * <twinningSystem.twinningSystem.html twinning systems>
% * <dislocationSystem.dislocationSystem.html dislocation systems>
% * <crystalShape.crystalShape.html crystal shapes>

%% And Back Again
%
% The inverse orientation maps specimen coordinates to crystal coordinates.
% Applying it to |r| therefore returns the direction we started from.

hBack = inv(ori) * r

%%
% The displayed coefficients do not resemble $[100]$ yet. A |Miller| made
% from a specimen direction displays as $(hkl)$ unless told otherwise, while
% the original $[100]$ direction has the aluminium lattice-vector length of
% 4.04958 Angstrom. Selecting lattice-direction notation and rounding recovers
% the original indices.

hBack.dispStyle = 'uvw';
hRounded = round(hBack)

%%
% Much of the literature defines an orientation in the opposite direction,
% from specimen to crystal coordinates. That is what MTEX calls |inv(ori)|.
% Both conventions are in use, and reading Euler angles with the wrong one
% inverts every orientation in the data. See
% <MTEXvsBungeConvention.html MTEX vs. Bunge Convention> for the practical
% consequences.

%% Turning the Specimen
%
% Putting the sample on the stage in another position actively turns the
% crystal relative to the fixed measurement frame. A rotation expressed in
% specimen coordinates therefore multiplies every orientation from the left.

rotSpecimen = rotation.byAxisAngle(vector3d.X,60*degree);
oriNew = rotSpecimen * ori;

%%
% Every crystal direction moves with the specimen. Going through the new
% orientation and turning the old specimen direction must agree.

leftConsistency = angle(oriNew * h,rotSpecimen * r) ./ degree

%%
% The residual is numerically zero. The same rotation written on the right
% is interpreted in crystal coordinates: it turns the direction inside the
% lattice before |ori| maps that direction into the specimen frame.

rightDifference = angle(ori * (rotSpecimen * h),oriNew * h) ./ degree

%%
% The nonzero result confirms that left and right multiplication describe
% different operations. The rotation on the right acts first, just as in
% ordinary matrix multiplication.

%% Crystal Symmetry Also Acts from the Right
%
% Right multiplication has a second, symmetry-aware meaning. A point-group
% operation changes the crystal-frame representative but not the physical
% crystal setting. <orientation.symmetrise.html |symmetrise|> lists those
% equivalent descriptions.

equivalentCounts = [length(ori.symmetrise),...
  length(ori.symmetrise('proper'))]

%%
% The first count is 48, the number of elements in aluminium's |m-3m| point
% group. The second count is 24, because only the proper operations are rigid
% rotations. The 24 improper operations remain symmetries of the lattice and
% are relevant when opposite plane normals are treated as equivalent.
%
% A symmetry-aware orientation comparison regards all 48 descriptions as
% equivalent. Their largest angular difference from |ori| is only a
% floating-point residual.

symmetryResidual = max(angle(ori.symmetrise,ori)) ./ degree

%% Rotating Is Not Changing Frame
%
% The stage rotation above moves the physical object in a fixed frame. A
% *frame change* instead re-expresses the same physical object in another
% reference frame and leaves the object untouched. Use
% <orientation.transformReferenceFrame.html |transformReferenceFrame|> when
% crystal data use a different Cartesian crystal frame. Orientations also
% depend on how the Cartesian crystal frame $\vec x$, $\vec y$, $\vec z$ is
% inscribed into the crystal axes $\vec a$, $\vec b$, $\vec c$.
%
% A *plotting convention* only states how a reference frame is laid out on
% screen. Changing it does not rotate the specimen or re-express the data.
% <CrystalReferenceSystem.html The Crystal Reference System> develops both
% distinctions for crystal axes.

%% The Maths Behind the Multiplication Order
%
% Let $\mathbf{G}$ be the matrix of |ori|, and let $\mathbf{h}$ and
% $\mathbf{r}$ contain the crystal and specimen components of one direction.
% Then
%
% $$ \mathbf{r} = \mathbf{G}\mathbf{h}, \qquad
%    \mathbf{h} = \mathbf{G}^{\mathrm{T}}\mathbf{r}. $$
%
% The transpose appears because a rotation matrix is orthogonal, so
% $\mathbf{G}^{-1}=\mathbf{G}^{\mathrm{T}}$. A specimen rotation
% $\mathbf{Q}$ gives $\mathbf{QG}$, while a crystal-frame rotation
% $\mathbf{P}$ gives $\mathbf{GP}$. This is the matrix form of the two
% multiplication examples above.
%
% The same rule determines the order of a misorientation product. See
% <MisorientationTheory.html Misorientations>.

%% References
%
% * H.-J. Bunge, <https://doi.org/10.1016/C2013-0-11769-2 Texture Analysis
% in Materials Science: Mathematical Methods>, Butterworths, English ed.,
% 1982, establishes the Euler-angle and orientation conventions used in
% texture analysis.
% * A. Morawiec, <https://doi.org/10.1007/978-3-662-09156-2 Orientations
% and Rotations: Computations in Crystallographic Textures>, Springer,
% 2004, develops coordinate maps, symmetry, and the geometry of orientation
% space.
% * D. Rowenhorst et al.,
% <https://doi.org/10.1088/0965-0393/23/8/083501 Consistent representations
% of and conversions between 3D rotations>, _Modelling and Simulation in
% Materials Science and Engineering_ 23, 083501, 2015, compares active and
% passive conventions and gives reproducible conversion rules.
% * <https://www.iso.org/standard/82749.html ISO 24173:2024>, _Microbeam
% analysis -- Guidelines for orientation measurement using electron
% backscatter diffraction_, gives current guidance for reproducible EBSD
% orientation measurements.

%% Next
%
% <OrientationSymmetry.html Symmetry> develops the equivalent rotations that
% an orientation represents. <OrientationPoleFigure.html Pole Figures> then
% draws the specimen directions computed here, while
% <OrientationInversePoleFigure.html Inverse Pole Figures> asks the inverse
% question.

%#ok<*NOPTS>
%#ok<*MINV>
