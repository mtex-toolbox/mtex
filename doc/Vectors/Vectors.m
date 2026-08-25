%% Vectors
%
%%
% Directions occur throughout texture analysis. A lattice-plane normal, the
% rolling direction of a sheet, and the direction of a diffracted beam all
% answer "which way?" A force or a displacement also has a length, so it is
% a vector rather than only a direction.
%
% MTEX represents both with <vector3d.vector3d.html |vector3d|>. One variable
% can hold a whole list, and MTEX operations act on that list without a loop.
% When only direction matters, normalization divides out the length. Each
% unit direction is then a point on the sphere.
%
% This page assumes basic MATLAB lists and indexing. Read
% <ListsAndIndexing.html Lists and Indexing> if those are new. The angle and
% plotting conventions used throughout MTEX are collected in
% <NotationAndConventions.html Notation and Conventions>.

plottingConvention.default('y↑→x');

% one hundred random directions and the three Cartesian basis directions
v = vector3d.rand(100)

plot(v,'upper','grid','MarkerSize',4);
hold on;
plot([vector3d.X,vector3d.Y,vector3d.Z],...
  'labeled','backgroundColor','w');
hold off;

%%
% The summary reports a 100 by 1 |vector3d| array. This is the first point to
% notice: one MTEX variable stores the whole list.
%
% In the upper-hemisphere spherical plot, X lies at the right rim, Y at the
% top rim, and Z at the centre. The plotting convention states that layout;
% it changes the drawing, not the directions. The random points on the lower
% hemisphere are hidden. Their stored lengths would not affect their
% positions in this plot. <SphericalProjections.html Spherical Projections>
% explains how the sphere is mapped to the circular page.
%
%% Directions, Reference Frames, and Plots
%
% A reference frame is the coordinate system in which data are expressed.
% It has an identity, a basis, and a default convention for drawing it. The
% random directions above are frame-free, so they use the session default
% when rendered. Data tied to a specimen or crystal frame use the convention
% carried by that frame. <AxesAlignment.html Axes Alignment> develops
% reference frames, plotting conventions, and frame changes.
%
% A spherical plot uses direction only. Use <vector3d.norm.html |norm|> when
% length is part of the quantity, and <vector3d.normalize.html |normalize|>
% when it is not. Do not infer a vector's length from a marker's distance
% from the centre of a spherical plot.
%
%% Directions and Axes Are Not the Same
%
% A *direction* distinguishes its two ends: north is not south. An *axis*
% does not. The axis of a twofold rotation is one example. Conventional pole
% figures usually treat a plane normal as an axis because
% <https://dictionary.iucr.org/Friedel%27s_law Friedel's law> makes opposite
% reflection intensities equal under its stated conditions.
%
% MTEX records this distinction with the |antipodal| property. It changes
% calculations as well as plots. The angle between two axes is never obtuse,
% an axial mean does not let opposite endpoints cancel, and an axial density
% satisfies $f(v)=f(-v)$.
%
% The plot option |'upper'| only hides the lower hemisphere. It does not set
% |antipodal| or identify a direction with its negative. Forgetting that
% distinction can produce a plausible result without an error message.
% <VectorsAxes.html Axes and Antipodal Symmetry> treats the consequences in
% detail.
%
%% Follow the Chapter
%
% <VectorDefinition.html Definition> constructs vectors from Cartesian
% components, spherical angles, and the specimen basis directions. It also
% explains how to inspect components, angles, and lengths.
%
% <VectorsImport.html Import> and <VectorsExport.html Export> exchange lists
% with text files. Read them after the definition when data exchange is your
% immediate task.
%
% <VectorsOperations.html Operations> covers angles, dot and cross products,
% rotations, projections, normalization, and vectorized list operations.
% Read <VectorsAxes.html Axes and Antipodal Symmetry> before analysing data
% whose two signs are physically equivalent.
%
% <VectorsDensityEstimation.html Density Estimation> turns a measured list
% into a smooth function on the sphere. <VectorGrids.html Spherical Grids>
% instead constructs finite sets of directions for sampling, integration,
% or numerical representation.
%
%% How Vectors Connect to MTEX
%
% Directions attached to a crystal lattice carry crystal symmetry and are
% written as Miller indices. They are introduced in
% <CrystalGeometry.html Crystal Geometry>. <Rotations.html Rotations> act on
% vectors without changing their lengths. <SphericalFunctions.html Spherical
% Functions> attach a value to every direction rather than storing a finite
% list of points.
%
% The worked <Tutorials.html Tutorials> use these foundations inside larger
% analyses. EBSD orientations map crystal directions into specimen
% directions, pole figures place diffraction intensity over specimen
% directions, and ODF calculations connect the two through orientations.
%
%% Further Reading
%
% * F. Bachmann, R. Hielscher, and H. Schaeben,
% <https://doi.org/10.4028/www.scientific.net/SSP.160.63 Texture Analysis with
% MTEX - Free and Open Source Software Toolbox>, _Solid State Phenomena_ 160,
% 63-68, 2010, connects the toolbox's vector-based geometry to EBSD, pole
% figures, and orientation distributions.
% * N. I. Fisher, T. Lewis, and B. J. J. Embleton,
% <https://doi.org/10.1017/CBO9780511623059 Statistical Analysis of
% Spherical Data>, Cambridge University Press, 1987. Chapters 2, 5, and 6
% distinguish spherical coordinates, unit vectors, and undirected lines.
% * K. V. Mardia and P. E. Jupp,
% <https://doi.org/10.1002/9780470316979 Directional Statistics>, Wiley,
% 1999, develops statistical methods for both directional and axial data.
% * H.-J. Bunge,
% <https://doi.org/10.1016/C2013-0-11769-2 Texture Analysis in Materials
% Science: Mathematical Methods>, Butterworths, 1982, connects specimen and
% crystal directions to pole figures and orientation distributions.
% * <https://dictionary.iucr.org/Friedel%27s_law IUCr Online Dictionary of
% Crystallography: Friedel's law> states when opposite reflections have equal
% intensity.
% * <https://www.iso.org/standard/64973.html ISO 80000-2:2019, Quantities and
% units - Part 2: Mathematics> specifies mathematical symbols and their
% meanings, including vector notation.

%% Next
%
% Begin with <VectorDefinition.html Defining Three-Dimensional Vectors>.
% Readers who already construct vectors comfortably can continue with
% <VectorsOperations.html Vector Operations> or go directly to
% <VectorsAxes.html Axes and Antipodal Symmetry> for unoriented data.
