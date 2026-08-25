%% Vectors
%
%%
% Many quantities in texture analysis are ultimately directions: a
% crystallographic direction, a lattice-plane normal, the rolling direction
% of a sheet, or the direction of a diffracted beam. They answer "which
% way?" rather than "how far?".
%
% MTEX represents both directions and magnitude-bearing three-dimensional
% vectors with <vector3d.vector3d.html |vector3d|>. When only direction
% matters, divide out the length: a unit direction is a point on the sphere,
% and a collection of directions is a cloud of points. A spherical plot uses
% this direction and not the stored length. Pole figures use the same
% spherical geometry for crystallographic directions.

% a hundred random directions and the three specimen axes
v = vector3d.rand(100);

plot(v,'upper','grid','MarkerSize',4)
hold on
plot([vector3d.X,vector3d.Y,vector3d.Z],'labeled','backgroundColor','w')
hold off

%%
% The option |'upper'| hides directions on the lower hemisphere; it does not
% by itself identify a direction with its negative. For unoriented axes the
% lower hemisphere is genuinely redundant, as the next section explains.
%
%% Directions and axes are not the same thing
%
% A *direction* distinguishes its two ends: north is not south. An *axis*
% does not. Examples include the axis of a twofold rotation and a plane
% normal when its two signs are physically equivalent, as in a conventional
% kinematic pole figure under Friedel's law. In MTEX this distinction is the
% |antipodal| flag. Setting it changes real answers: the angle between two
% axes is never obtuse, the mean of a set of axes is not the mean of the same
% set read as directions, and a density estimated from axes is symmetric
% under inversion by construction.
%
% Forgetting the flag is one of the more common ways to get a plausible
% wrong number, because nothing complains. When a quantity is an axis, say
% so.
%
%% Where to start
%
% <VectorDefinition.html Definition> shows the ways of building a direction -
% from Cartesian components, from spherical angles, from the specimen axes -
% and how to move between them.
%
% <VectorsOperations.html Operations> covers the arithmetic: angles, dot and
% cross products, rotations, projections. Read it before writing loops, since
% a |vector3d| variable holds a whole cloud of directions and the operations
% work on all of them at once.
%
% Then two pages about looking at many directions rather than one.
% <VectorsAxes.html Axes> is where the antipodal distinction above is treated
% properly, and <VectorsDensityEstimation.html Density Estimation> turns a
% cloud of directions into a smooth function on the sphere, which is the step
% from data to distribution.
%
% <VectorGrids.html Spherical Grids> matters when you need directions spread
% evenly over the sphere - for numerical integration, or for sampling a
% function. There is no perfectly even arrangement of points on a sphere,
% which is why several constructions exist and why they differ.
%
% <VectorsImport.html Import> and <VectorsExport.html Export> handle files.
%
%% Next
%
% Directions attached to a crystal lattice, written as Miller indices, are
% the subject of <CrystalGeometry.html Crystal Geometry>. Functions defined
% on the sphere rather than points on it are
% <SphericalFunctions.html Spherical Functions>. Rotating a direction, and
% the objects that do the rotating, are <Rotations.html Rotations>.
%
