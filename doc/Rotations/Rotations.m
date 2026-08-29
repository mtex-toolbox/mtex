%% Rotations
%
%%
% A rotation moves a geometric object within a fixed reference frame.
% It preserves lengths, angles, and handedness. Such a motion is called a
% *proper rotation*.
%
% A reference frame is the coordinate system in which data are expressed.
% Moving an object within one frame is an *active rotation*. A frame change
% instead re-expresses the same physical object in a different reference
% frame without moving it.
%
% This chapter assumes the three-dimensional directions introduced in
% <VectorDefinition.html Defining Three-Dimensional Vectors>. The angle and
% Euler conventions used throughout MTEX are collected in
% <NotationAndConventions.html Notation and Conventions>.
%
% In MTEX, |rot * v| actively turns the direction |v| by |rot|. The same
% scalar rotation acts on a whole array of directions without a loop.
% Open circles below show the directions before the rotation, and red
% circles show them afterwards. The larger blue squares identify one pair.

plottingConvention.default('y↑→x');

% turn by 60 degrees about the z axis
rot = rotation.byAxisAngle(vector3d.Z,60*degree);

v = equispacedS2Grid('points',80,'upper');
% highlight one direction of the grid and its image
[~,iExample] = min(angle(v,vector3d(1,2,2)));
vExample = v(iExample);

plot(v,'upper','grid','MarkerFaceColor','none','MarkerEdgeColor','k')
hold on
plot(rot*v,'upper','MarkerFaceColor','r','MarkerSize',5)
plot(vExample,'upper','Marker','s','MarkerSize',10,...
  'MarkerFaceColor','none','MarkerEdgeColor','b')
plot(rot*vExample,'upper','Marker','s','MarkerSize',10,...
  'MarkerFaceColor','b','MarkerEdgeColor','b')
hold off

%% Reading the rotation
%
% The two blue squares lie on the same latitude circle, as does every red
% point and its open starting point. The Z direction at the centre does not
% move because it is the rotation axis.
%
% Every non-identity proper rotation in three dimensions has a fixed axis.
% The identity has angle zero and no unique axis. This axis--angle result is
% one description of the same rotation, not a different kind of motion.

%% Why rotations need their own geometry
%
% Rotations do not add or compose like ordinary vectors. The product on the
% right acts first, and reversing two factors usually changes the result.
% <RotationOperations.html Operations> demonstrates both facts directly.
%
% Coordinate-wise averaging is another trap. Averaging the entries of
% rotation matrices, Euler-angle triplets, or Rodrigues vectors does not in
% general give the geometric mean of the rotations. MTEX operations such as
% <quaternion.mean.html |mean|> work with the geometry of rotation space.

%% One rotation, many descriptions
%
% The same rotation can be written as three Euler angles, an axis and angle,
% a $3 \times 3$ matrix, a unit quaternion, or a Rodrigues--Frank vector.
% The best description depends on whether the rotation will be entered,
% composed, sampled, or plotted.
% <RotationDefinition.html Definition> introduces and compares these
% descriptions.
%
% Euler angles are common in texture analysis and especially easy to
% misread. Three angle values are incomplete unless their axes, order, and
% active or passive interpretation are also known. A quaternion avoids
% Euler singularities, but $q$ and $-q$ describe the same rotation.
% <RotationRepresentations.html Representations> compares Rodrigues--Frank,
% homochoric, and cubochoric coordinates for rotation space.

%% Improper transformations and symmetry
%
% Proper rotations form the rotation group SO(3). Reflections and inversion
% also preserve lengths and angles, but reverse handedness. They are
% *improper transformations* in the larger orthogonal group O(3).
%
% MTEX stores proper and improper transformations in the
% <rotation.rotation.html |rotation|> class because crystal point groups can
% contain both. <RotationImproper.html Improper Rotations> explains their
% representation and why not every symmetry operation can physically turn
% a crystal.

%% Follow the chapter
%
% Start with <RotationDefinition.html Definition> to construct and inspect
% rotations. Continue with <RotationRepresentations.html Representations>
% to compare coordinate systems. Then read <RotationImproper.html Improper
% Rotations> before <RotationOperations.html Operations>, which applies,
% composes, inverts, and compares rotations.
%
% <RotationPlotting.html Plotting> shows sets of rotations as points in
% Euler, axis--angle, and Rodrigues space. <RotationFibre.html Fibres>
% treats the curve of rotations that maps one fixed direction onto another.
% Such curves recur in pole figures and ideal texture components.
% Before reading Fibres, read <OrientationDefinition.html Orientation
% Definition> and <OrientationSymmetry.html Orientation Symmetry>, which
% that page assumes.
%
% <RotationTangentSpace.html Tangent Spaces> describes small changes in a
% rotation. <RotationSpinTensor.html Spin Tensors> connects those changes to
% rates of rotation in deforming materials.
%
% <OrientationImport.html Import> and <OrientationExport.html Export>
% exchange orientation data with files.

%% How rotations connect to MTEX
%
% An *orientation* maps coordinates from a crystal frame into a specimen
% frame. It also carries the relevant symmetries, so several rotation
% representatives can describe the same physical crystal placement. This
% is developed in <CrystalOrientations.html Orientations>.
%
% A *misorientation* is the relative rotation between two crystals. It is
% introduced in <Misorientations.html Misorientations>. A continuous density
% over crystal orientations is an orientation distribution function, or
% ODF, developed in <ODFAnalysis.html ODF>.
%
% <SO3Functions.html Orientation Functions> provides the general machinery
% for functions on rotations. The worked <Tutorials.html Tutorials> use
% rotations inside EBSD import corrections, orientation maps, grain-boundary
% comparisons, pole figures, and ODF calculations.

%% Further reading
%
% * A. Morawiec,
% <https://doi.org/10.1007/978-3-662-09156-2 Orientations and Rotations:
% Computations in Crystallographic Textures>, Springer, 2004, develops
% parametrisations, rotation-space geometry, symmetry, and statistics.
% * D. Rowenhorst et al.,
% <https://doi.org/10.1088/0965-0393/23/8/083501 Consistent representations
% of and conversions between 3D rotations>, _Modelling and Simulation in
% Materials Science and Engineering_ 23 (2015) 083501, compares conventions
% and conversion rules for the representations used in materials science.
% * H.-J. Bunge,
% <https://doi.org/10.1016/C2013-0-11769-2 Texture Analysis in Materials
% Science: Mathematical Methods>, Butterworths, English ed., 1982, connects
% rotations and Euler space to orientation distributions and texture.

%% Next
%
% Continue with <RotationDefinition.html Defining Rotations>. Crystal
% symmetry is introduced in <CrystalGeometry.html Crystal Geometry> before
% rotations become <CrystalOrientations.html crystal orientations>.
