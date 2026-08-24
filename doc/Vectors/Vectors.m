%% Vectors
%
%%
% Almost everything in texture analysis is eventually a direction. A crystal
% axis, the normal of a lattice plane, the direction a rolling mill pushed
% the metal, the direction a diffracted beam left the sample - all of them
% are answers to the question "which way?", and none of them cares how long
% the arrow is.
%
% This is why directions here live on a sphere. Fix the length at one and a
% direction becomes a point on the unit sphere, so a collection of
% directions becomes a cloud of points and the natural way to look at it is
% a projection of that sphere onto the page. Every pole figure you will ever
% plot is exactly that.

% a hundred random directions and the three specimen axes
v = vector3d.rand(100);

plot(v,'upper','grid','MarkerSize',4)
hold on
plot([vector3d.X,vector3d.Y,vector3d.Z],'labeled','backgroundColor','w')
hold off

%%
% Only half the sphere is drawn above. That is not laziness - see the note
% on axes below.
%
%% Directions and axes are not the same thing
%
% A *direction* distinguishes its two ends: north is not south. An *axis*
% does not. The normal of a lattice plane is an axis, because the plane has
% no preferred side, and so is the direction of a twofold rotation. In MTEX
% this distinction is the |antipodal| flag, and setting it changes real
% answers: the angle between two axes is never obtuse, the mean of a set of
% axes is not the mean of the same set read as directions, and a density
% estimated from axes is symmetric under inversion by construction.
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
