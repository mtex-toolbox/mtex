%% Orientations
%
%%
% An <orientation.orientation.html |orientation|> answers one question: how
% is this crystal placed in this specimen? In MTEX it maps coordinates from
% the crystal frame into the specimen frame. It is the bridge between the
% sample sitting on the stage and the lattice inside it.
%
% A *reference frame* is the coordinate system in which data are expressed.
% The crystal frame is fixed to the lattice, while the specimen frame is
% fixed to the sample. An orientation relates those frames and carries the
% symmetry attached to each one. It is therefore more than three Euler
% angles or a bare rotation matrix.
%
% Everything in texture analysis builds on this idea. A texture is a
% population of orientations. A pole figure shows where selected crystal
% directions point. A misorientation is the relative map between two
% crystal frames. Get the definition right here and the rest of MTEX follows.
% Get it wrong and every later plot is rotated by something you cannot find.

%% A Crystal Placed in the Specimen
%
% The most direct picture of an orientation is the crystal where it sits.
% This example uses one cubic crystal and one Bunge Euler-angle triplet.

cs = crystalSymmetry('m-3m');
cS = crystalShape.cube(cs);
ori = orientation.byEuler(30*degree,50*degree,10*degree,'Bunge',cs);

plot(ori * cS,'colored','faceAlpha',0.35);
hold on;
arrow3d(0.62*[vector3d.X,vector3d.Y,vector3d.Z],...
  'faceColor','black','label',{'X','Y','Z'});
hold off;
camzoom(0.8);

%%
% The blue cube and its $(100)$ face-family label remain fixed to the
% crystal. The black X, Y and Z arrows remain fixed to the specimen. The
% orientation is the relationship between them, not either frame by itself.
%
% Three independent choices can change the numbers or the picture. An active
% rotation turns an object, while a passive rotation changes coordinates.
% The two maps are inverses. Second, several Euler-angle conventions use the
% same three symbols in different ways. Third, the Cartesian crystal frame
% can be aligned with the lattice axes in different ways. Most disagreements
% between two people's orientation results begin with one of these choices.
%
% MTEX makes the map direction and Euler convention explicit. The
% <CrystalReferenceSystem.html Crystal Reference System> explains the
% independent crystal-frame alignment. A *plotting convention* describes
% how a reference frame is laid out on screen; it is not the orientation or
% the symmetry.

%% Symmetry Makes an Orientation a Set
%
% A crystal cannot distinguish settings related by its point-group
% symmetry. One physical orientation therefore has many equivalent
% descriptions. A cubic crystal has 24 proper symmetry rotations, and all
% 24 describe the same physical placement.
%
% The full point group |m-3m| also contains 24 improper operations, so MTEX
% can list 48 symmetry-related orthogonal transformations. Only the 24
% proper operations can reorient a rigid crystal. The distinction matters
% when a calculation separates rotations from reflections or inversion.
%
% Symmetry is also why "the angle between two orientations" needs care.
% MTEX compares their proper-symmetry descriptions and returns the smallest
% rotation angle. Comparing only the stored representatives makes the result
% depend on how the same physical orientations happened to be labelled.
%
% A *fundamental region* is the part of rotation space used to retain one
% representative from each equivalence class. Representatives on its
% boundary can be tied, so MTEX also needs a consistent boundary convention.
% The corresponding construction for crystal directions is the fundamental
% sector.

%% Prerequisites
%
% Start with <VectorDefinition.html Defining Three-Dimensional Vectors>.
% Then read the plane and direction notation in
% <CrystalDirections.html Miller Indices> and the Euler-angle representations
% in <RotationDefinition.html Defining Rotations>.
% <CrystalSymmetries.html Crystal Symmetries> supplies the point-group
% background. The plotting pages also use
% <SphericalProjections.html Spherical Projections>.

%% Recommended Reading Order
%
% The chapter contents give the recommended core route.
% <OrientationDefinition.html Definition> constructs orientations from
% Euler angles, matrices, crystal directions, and random samples.
% <DefinitionAsCoordinateTransform.html Theory> then develops the
% crystal-to-specimen map. <OrientationSymmetry.html Symmetry> explains the
% equivalent descriptions. <OrientationStandard.html Standard Orientations>
% introduces named components such as Goss, Brass, and Cube.
% <MTEXvsBungeConvention.html MTEX vs. Bunge Convention> completes this
% foundation. Read it before trusting Euler angles you did not produce yourself.
%
% The next four pages compare ways to look at orientations.
% <OrientationPoleFigure.html Pole Figures> fix a crystal direction and ask
% where it points in the specimen. <OrientationInversePoleFigure.html Inverse
% Pole Figures> ask which crystal direction lies along a specimen direction.
% Both are projections and discard information.
% <OrientationVisualization3d.html 3D Plots> retain all three rotational
% degrees of freedom. <OrientationVisualizationSections.html Section Plots>
% cut that space into two-dimensional slices. They retain more information
% than projections but are harder to read.
%
% <OrientationFundamentalRegion.html Fundamental Regions> explains the
% symmetry-dependent domains in those plots. <SpecimenSymmetry.html Specimen
% Symmetry> covers invariance of the sample texture. That differs from
% symmetry of the crystal lattice. Rolling and other processes may impose it.
%
% The remaining pages treat sets and workflows. <OrientationGrid.html Grids>
% constructs finite samples of orientation space.
% <OrientationFibre.html Fibres> constructs the curves followed by many real
% textures. <OrientationImport.html Import> and
% <OrientationExport.html Export> handle files and their conventions.
%
% <OrientationEmbeddings.html Embeddings> represents orientations as points
% in a linear space so that averaging and machine learning are well behaved.
% It is last in the chapter contents, but it assumes
% <MisorientationTheory.html misorientation theory>. Read that page before
% returning to Embeddings.

%% References
%
% * H.-J. Bunge, <https://doi.org/10.1016/C2013-0-11769-2 Texture Analysis
% in Materials Science: Mathematical Methods>, Butterworths, 1982.
% It establishes the orientation and Euler-angle conventions of texture analysis.
% * A. Morawiec, <https://doi.org/10.1007/978-3-662-09156-2 Orientations
% and Rotations: Computations in Crystallographic Textures>, Springer, 2004.
% It develops rotation space, symmetry, and orientation statistics.
% * D. Rowenhorst et al.,
% <https://doi.org/10.1088/0965-0393/23/8/083501 Consistent representations
% of and conversions between 3D rotations>, _Modelling and Simulation in
% Materials Science and Engineering_ 23, 083501, 2015.
% It compares rotation conventions and gives reproducible conversion rules.
% * <https://www.iso.org/standard/82749.html ISO 24173:2024>, _Microbeam
% analysis - Guidelines for orientation measurement using electron
% backscatter diffraction_. It gives current guidance for reproducible EBSD
% orientation measurements.

%% Next
%
% The relative orientation of two crystals is
% <Misorientations.html Misorientations>. A whole population described as a
% density rather than a list is <ODFAnalysis.html an ODF>. Orientations
% measured on a grid across a sample are <EBSDAnalysis.html EBSD>.
