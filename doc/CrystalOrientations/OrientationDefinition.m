%% Defining Orientations
%
%%
% An <orientation.orientation.html |orientation|> answers one question:
% how is this crystal placed in this specimen? In MTEX it is a
% <rotation.rotation.html |rotation|> that maps coordinates from the
% crystal reference frame into the specimen reference frame. It also carries
% the symmetry attached to each frame.
%
% This page assumes the three-dimensional directions introduced in
% <VectorDefinition.html Defining Three-Dimensional Vectors>, the plane and
% direction notation from <CrystalDirections.html Miller Indices>, and basic
% matrix algebra. The constructors are the same as on
% <RotationDefinition.html Defining Rotations>, with a
% <crystalSymmetry.crystalSymmetry.html |crystalSymmetry|> supplied as an
% extra argument.
%
% What this mapping means is developed in
% <DefinitionAsCoordinateTransform.html Theory> and compared with other
% conventions in <MTEXvsBungeConvention.html MTEX vs. Bunge Convention>.
% This page concentrates on building orientations.

plottingConvention.default('y↑→x');

% load the crystal symmetry and reference frame from a CIF file
cs = crystalSymmetry.load('Cu-Copper.cif');

%% Euler Angles
%
% Euler angles are the most common input and the one most easily
% misinterpreted. Their axes, order, and mapping direction belong to the
% convention. Equal angle triplets in different conventions need not
% describe the same orientation.
%
% MTEX uses the Bunge convention by default. Naming it explicitly keeps a
% reusable script independent of the current session preference. Angles are
% in radians, so values stated in degrees are multiplied by |degree|.

ori = orientation.byEuler(30*degree,50*degree,10*degree,'Bunge',cs)

%%
% The display gives the three Bunge angles and names the copper crystal
% symmetry alongside them. This attached crystal frame and symmetry are
% what distinguish an orientation from a bare rotation.

%% Rotation Matrix
%
% A $3 \times 3$ matrix can define the same mapping. Its convention must be
% checked when it comes from another program: this matrix maps crystal-frame
% coordinates into specimen-frame coordinates.

M = eye(3);

%%

ori = orientation.byMatrix(M,cs)

%%
% The identity matrix gives the orientation in which the Cartesian crystal
% frame is aligned with the specimen frame. It is the reference setting from
% which the Euler angles of every other orientation are counted.
%
% The point group does not by itself determine how the Cartesian crystal
% frame is inscribed into the lattice axes. A statement such as
% X &#124;&#124; a*, Z &#124;&#124; c belongs to the crystal reference frame,
% not to the symmetry. Changing that alignment changes the coordinate
% description without moving the crystal; see
% <CrystalReferenceSystem.html The Crystal Reference System>.

%% Miller Indices
%
% Metallurgy often names an orientation by two crystal quantities: the
% lattice plane facing the specimen Z axis and the lattice direction
% pointing along specimen X. The inputs must describe an orthogonal plane
% normal and direction. That is what
% <orientation.byMiller.html |orientation.byMiller|> takes, here for the
% Goss orientation $(011)[100]$.

ori = orientation.byMiller([0 1 1],[1 0 0],cs)

%%
% Apply the orientation to the plane normal and the lattice direction to
% check where they point in the specimen frame.

rPlane = ori * Miller(0,1,1,cs,'hkl');
rDirection = ori * Miller(1,0,0,cs,'uvw');

plot([rPlane,rDirection],'upper','grid','MarkerSize',10,...
  'label',{'(011)','[100]'},'backgroundColor','w','figSize','small')

%%
% Notice that the $(011)$ pole is at the centre, the specimen Z direction,
% while $[100]$ is on the specimen X axis at the rim.
%
% Goss and the other named texture components are predefined. The zero
% angular difference confirms that this result is also
% |orientation.goss(cs)|; see
% <OrientationStandard.html Standard Orientations>.

angle(ori,orientation.goss(cs)) ./ degree

%% Random Orientations
%
% As for rotations, |rand| generates uniformly distributed orientations and
% needs the crystal symmetry as well. MTEX stores the 100 results in one
% vectorized orientation array.

ori = orientation.rand(100,cs);

length(ori)

%% Symmetrically Equivalent Orientations
%
% A crystal cannot distinguish its symmetrically equivalent settings, so an
% orientation represents a whole class of rotations.
% <orientation.symmetrise.html |symmetrise|> lists that class.

ori = orientation.byEuler(30*degree,50*degree,10*degree,'Bunge',cs);

length(ori.symmetrise)

%%
% Copper has point group m-3m with 48 elements. Only the 24 proper elements
% describe settings into which the crystal can be physically turned.

length(ori.symmetrise('proper'))

%%
% The other 24 are improper lattice symmetries. They still matter when a
% calculation treats opposite plane normals as equivalent, as conventional
% diffraction does under Friedel's law.
%
% This equivalence is why the angle between two orientations is the smallest
% angle over all equivalent pairs. The dedicated
% <OrientationSymmetry.html Symmetry> page develops this rule and explains
% when to use the |'noSymmetry'| option.

%% Specimen Symmetry
%
% A specimen may have symmetry of its own. A rolled sheet, for example, is
% commonly modelled with orthorhombic symmetry: three mutually perpendicular
% twofold axes, or equivalently three mirror planes in the full point group.
% It is represented by a
% <specimenSymmetry.specimenSymmetry.html |specimenSymmetry|> and passed
% alongside the crystal symmetry.

ss = specimenSymmetry('orthorhombic');

%%

ori = orientation.byEuler(30*degree,50*degree,10*degree,'Bunge',cs,ss)

%%
% Crystal symmetry acts in the crystal frame and specimen symmetry in the
% specimen frame. With the full point groups, the class contains the 48
% copper elements times the 8 orthorhombic elements.

length(ori.symmetrise)

%%
% Restricting both groups to proper operations leaves the 24 crystal
% rotations times the 4 specimen rotations.

length(ori.symmetrise('proper'))

%%
% Specimen symmetry is a statement about the sample, not about the
% measurement. Its axes must match the physical specimen frame, and imposing
% a symmetry that is not present hides real texture components.
% <SpecimenSymmetry.html Specimen Symmetry> explains when to use it.

%% References
%
% * H.-J. Bunge, <https://doi.org/10.1016/C2013-0-11769-2 Texture Analysis
% in Materials Science: Mathematical Methods>, Butterworths, English ed.,
% 1982, establishes the Euler-angle convention used in texture analysis.
% * A. Morawiec, <https://doi.org/10.1007/978-3-662-09156-2 Orientations
% and Rotations: Computations in Crystallographic Textures>, Springer,
% 2004, develops orientations as rotations modulo crystallographic symmetry.
% * D. Rowenhorst et al.,
% <https://doi.org/10.1088/0965-0393/23/8/083501 Consistent
% representations of and conversions between 3D rotations>, Modelling and
% Simulation in Materials Science and Engineering 23 (2015) 083501,
% compares conventions and conversion formulas.
% * The International Union of Crystallography,
% <https://dictionary.iucr.org/Friedel%27s_law Friedel's law>, states the
% diffraction equivalence and its exception for resonant scattering.

%% Next
%
% <DefinitionAsCoordinateTransform.html Theory> explains how an orientation
% maps coordinates, which is the definition the rest of MTEX rests on.
% <OrientationPoleFigure.html Pole Figures> and
% <OrientationInversePoleFigure.html Inverse Pole Figures> are the two ways
% of looking at one. Existing orientation files are handled by
% <OrientationImport.html Import>.

%#ok<*NASGU>
%#ok<*NOPTS>
