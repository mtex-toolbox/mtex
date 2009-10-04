%% TODO List
%
%% Assigned to MTEX 2.1
%
% empty
%
%% EBSD Statistics
%
% Implement Geralds Diss. I.e. allow MTEX to answer the following
% questions:
%
% * is a EBSD data set a random sample of a certain ODF
% * are two EBSD data sets random sample of the same ODF
%
%% Misorientation Analysis
%
% Allow to compute an Misorientation ODF from EBSD data. Therefore, a new
% class MODF is needed which differs from an ordinary ODF by the fact
% that the specimen symmetry is replaced by the crystal symmetry of the
% second phase.
%
% *This requires a better find functionality in SO3Grid*
%
%% Grain Boundary Analysis
%
% * Compute grain boundary planes.
% * Analyze and visualize the distribution of grain boundary planes.
% * Classify twist / tild grain boundaries.
%
%% Single Grain Analysis
%
% Detect polar, oblate and spherical grains.
%
%% 3D Grain Detection
%
% Implement a 3d version of the EBSD/segment2d function and update the
% EBSD and Grain class accordingly.
%
%% Topological Grain Data Structure
%
% The function segment2d should provide a grain class that allows to
% answer questions like:
%
% * give me all phase one to phase one grain boundaries
% * give me all grain boundaries between grains with a certain missorientation
%
% Therefore not only the neigbouring grains has to be stored in the grain
% object but also the line segment representing the grain boundary.
%
%% Computation of Material Properties
%
% Compute various macroscopic material properties for EBSD data and ODFs.
%
%% Kernel Density Estimation
%
% Implement a robust estimator of the best kernel width. Possible ideas
% are
%
% * maximum likelihood cross validation
%
% Questions to answer:
%
% * asymptotic behavior
% *
%
%% ODF Analysis
%
% Provide a function that is able to approximate an ODF by a small number
% of simple components, i.e. unimodal components and fibres.
%
%% Bingham Distribtution
%
% Define Bingham distributed ODFs and allow to compute pole figures for
% them. Implement Bingham parameter estimation from EBSD data.
%
%% Joined Counts
%
% Incorporate the results of Müller.
%
%% Grain Simulation
%
% Allow to simulate grains under certain assumptions. To be used for
% joined counts statistics and ODF -> MODF analysis.
%
%% Voronoi Decomposition  of the Orientation Space
%
% Use the Rodriguez representation to compute an Voronoi neighborhood
% graph of a set of orientations. This can be used for faster searching
% in SO3Grids and for the decomposition of ODFs into components.
%
%% Robust Mean Computation
%
% Find and implement an algorithm that finds under certain conditions the
% true mean orientation for a given set of orientations!
%
%% New Class Orientation
%
% Implement a new class orientation. Advantages:
%
% * No more inconsistency:  - (g * h) ~=  (- g) * h
% * no quaternions appearing to the user
% * misorientation(q1,q2) can be computed directly since the symmetries
% are already stored inside.
% * faster EBSD computations due to less overhead
% * nicer syntax, e.g.

q1 = orientation('Euler',alpha,beta,gamma)
q2 = orientation('Axis',x,'angle',omega)
q3 = orientation('quaternion',a,b,c,d)

%% New Class Fibre
%
% Implement a new class fibre, which can be used for any computations
% involving fibres.
%
%% Minor Improvements
%
% * EBSD colorcoding
% * fix crystal coordinate system for symmetry 2/m
% * improve template files
% * say explicetly in generic wizard which columns has to
% be specified
% * implement grain/rotate, grain/flipud, grain/fliplr
% * better ODF import / export
% * add kernel names by Matthies
%
%% Bugs
%
%