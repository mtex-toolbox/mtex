%% Defining Orientations
%
%%
% An <orientation.orientation.html |@orientation|> is a
% <rotation.rotation.html |@rotation|> that knows which crystal it belongs
% to. Everything on <RotationDefinition.html Defining Rotations> therefore
% applies here as well - the same constructors, with a
% <crystalSymmetry.crystalSymmetry.html |crystalSymmetry|> handed in as an
% extra argument.
%
% What the rotation *means* is a separate question, answered in
% <DefinitionAsCoordinateTransform.html Theory> and in
% <MTEXvsBungeConvention.html MTEX vs. Bunge Convention>. This page is about
% building one.

plottingConvention.default('y↑→x');

% load copper cif file
cs = crystalSymmetry.load('Cu-Copper.cif')

%% Euler Angles
%
% The most common input, and the one that needs its convention stated -
% MTEX reads and writes Bunge angles by default.

ori = orientation.byEuler(30*degree,50*degree,10*degree,cs)

%%
% The display names the crystal symmetry alongside the angles. An
% orientation without a symmetry is just a rotation, and MTEX keeps the two
% apart for that reason.

%% Rotation Matrix
%
% A $3 \times 3$ matrix defines an orientation just as it defines a
% rotation.

M = eye(3)

%%

ori = orientation.byMatrix(M,cs)

%%
% The identity matrix gives the orientation in which the Cartesian crystal
% frame is aligned with the specimen frame - the reference setting from
% which the Euler angles of every other orientation are counted.

%% Miller Indices
%
% Metallurgy usually names an orientation by two crystal directions: the
% lattice plane facing the specimen Z axis and the lattice direction
% pointing along X. That is what
% <orientation.byMiller.html |orientation.byMiller|> takes, here for the
% Goss orientation $(011)[100]$.

ori = orientation.byMiller([0 1 1],[1 0 0],cs)

%%
% A spherical plot confirms the reading: the $(011)$ pole sits at the
% centre, where Z is, and the $[100]$ direction on the X axis at the rim.

rPlane = ori * Miller(0,1,1,cs);
rDirection = ori * Miller(1,0,0,cs,'uvw');

plot([rPlane,rDirection],'upper','grid','MarkerSize',10,...
  'label',{'(011)','[100]'},'backgroundColor','w','figSize','small')
hold on
annotate([vector3d.X,vector3d.Z],'label',{'X','Z'},'backgroundColor','w')
hold off

%%
% Goss and the other named textures are predefined, so this one is also
% |orientation.goss(cs)| - see
% <OrientationStandard.html Standard Orientations>.

angle(ori,orientation.goss(cs)) ./ degree

%% Random Orientations
%
% As for rotations, uniformly distributed orientations come from |rand|,
% which needs the symmetry as well.

ori = orientation.rand(100,cs);

length(ori)

%% Symmetrically Equivalent Orientations
%
% A crystal cannot distinguish its symmetrically equivalent settings, so
% every orientation stands for a whole set of them.
% <orientation.symmetrise.html |symmetrise|> lists that set.

ori = orientation.byEuler(30*degree,50*degree,10*degree,cs);

length(ori.symmetrise)

%%
% Copper is m-3m, which has 48 elements, and 24 of them are improper.

nnz(ori.symmetrise.isImproper)

%%
% Only the 24 proper ones are settings a crystal can be physically turned
% into. The improper ones remain symmetries of the lattice and matter when
% a calculation treats opposite plane normals as equivalent, as
% conventional diffraction does under Friedel's law. This is why "the
% angle between two orientations" is always
% taken as the smallest over all equivalent pairs, see
% <OrientationSymmetry.html Symmetry>.

%% Specimen Symmetry
%
% The specimen may have symmetry of its own - rolling, for instance, makes
% the sheet look the same under three mirror planes. It is given as a
% <specimenSymmetry.specimenSymmetry.html |specimenSymmetry|> and passed
% alongside the crystal symmetry.

% define orthotropic specimen symmetry
ss = specimenSymmetry('orthorhombic')

%%

ori = orientation.byEuler(30*degree,50*degree,10*degree,cs,ss)

%%
% Both symmetries now act, one from each side, and the set of equivalent
% orientations grows accordingly - the 48 crystal elements times the 8
% specimen ones.

length(ori.symmetrise)

%%
% Specimen symmetry is a statement about the sample, not about the
% measurement, and imposing one that is not there hides real texture
% components. <SpecimenSymmetry.html Specimen Symmetry> says when to use it.

%% Next
%
% <DefinitionAsCoordinateTransform.html Theory> explains what an orientation
% does to coordinates, which is the definition the rest of MTEX rests on.
% <OrientationPoleFigure.html Pole Figures> and
% <OrientationInversePoleFigure.html Inverse Pole Figures> are the two ways
% of looking at one.

%#ok<*NASGU>
%#ok<*NOPTS>
