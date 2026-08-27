%% Orientations
%
%%
% An *orientation* answers one question: how is this crystal placed in this
% specimen? It is the rotation that takes the specimen's coordinate axes
% onto the crystal's own, so it is the bridge between the two frames that
% every measurement lives between - the sample sitting on the stage, and
% the lattice inside it.
%
% Everything in texture analysis is built on this one idea. A texture is a
% population of orientations. A pole figure is a projection of one. A
% misorientation is the difference between two. Get the definition right
% here and the rest of MTEX follows; get it wrong and every plot afterwards
% is rotated by something you cannot find.
%
% The most direct way to see an orientation is to draw the crystal where it
% sits. Below is a cubic crystal at a single orientation, with the specimen
% axes marked.

cs = crystalSymmetry('m-3m');
cS = crystalShape.cube(cs);

ori = orientation.byEuler(30*degree,50*degree,10*degree,cs);

plot(ori * cS,'colored')

%%
% Two conventions are hiding in that picture, and both matter. One is
% whether the rotation is understood to turn the crystal or to turn the
% coordinate axes - the *active* and *passive* readings, which are inverses
% of each other. The other is which of the several Euler angle conventions
% those three numbers follow. MTEX is explicit about both, on the pages
% below, and the reason it is explicit is that most disagreements between
% two people's results come from here.
%
%% Symmetry makes an orientation a set
%
% A crystal cannot tell its symmetrically equivalent settings apart, so an
% orientation is never really one rotation. A cubic crystal has 24 of them,
% and all 24 describe the same physical placement. You will sometimes see 48
% listed instead: the point group m-3m contains 24 rotations and 24 improper
% operations, and only the rotations can actually reorient a crystal.
%
% This is why an orientation carries its symmetry with it. It is also why
% "the angle between two orientations" needs care: the honest answer is the
% smallest angle over all equivalent pairs, and computing it any other way
% gives a number that depends on which of the equivalent labels each
% orientation happened to be written with. The *fundamental region* is the
% patch of rotation space holding exactly one representative of each, and
% it is the orientation counterpart of the fundamental sector for
% directions.
%
%% Where to start
%
% <OrientationDefinition.html Definition> shows how to build one - from
% Euler angles, from a matrix, from crystal directions, or at random.
% <DefinitionAsCoordinateTransform.html Theory> then says what an
% orientation actually is, as a change between two coordinate frames, and
% <MTEXvsBungeConvention.html MTEX vs. Bunge Convention> spells out where
% MTEX sits relative to the convention most textbooks use. Read those two
% before trusting any Euler angles you did not produce yourself.
%
% <OrientationSymmetry.html Symmetry> and
% <OrientationFundamentalRegion.html Fundamental Region> develop the point
% made above. <SpecimenSymmetry.html Specimen Symmetry> covers the other
% kind - symmetry of the sample rather than of the crystal, which rolling
% and other processes impose.
%
% <OrientationStandard.html Standard Orientations> lists the named textures
% such as Goss, Brass and Cube, so you can name what you see.
%
% Four pages are about looking at orientations, and they differ in what
% they sacrifice. <OrientationPoleFigure.html Pole Figures> fixes a crystal
% direction and asks where it points in the specimen;
% <OrientationInversePoleFigure.html Inverse Pole Figure> does the reverse.
% Both are projections and both lose information.
% <OrientationVisualization3d.html 3D Plots> and
% <OrientationVisualizationSections.html Section Plots> show the full
% rotation space instead, at the cost of being harder to read.
%
% <OrientationGrid.html Grids> and <OrientationFibre.html Fibres> deal with
% sets of orientations - evenly spread ones, and the curves that many real
% textures follow. <OrientationEmbeddings.html Embeddings> is for readers
% who need orientations as points in a linear space, which is what makes
% averaging and machine learning well behaved.
%
% <OrientationImport.html Import> and <OrientationExport.html Export> handle
% files.
%
%% Next
%
% The relative orientation of two crystals is
% <Misorientations.html Misorientations>. A whole population of
% orientations, described as a density rather than a list, is
% <ODFAnalysis.html ODF>. Orientations measured on a grid across a sample
% are <EBSDAnalysis.html EBSD>.
%
