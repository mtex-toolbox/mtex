%% Roadmap
%
%% Contents
%
%% Assigned to Next Minor Release
%
% *Kernel Density Estimation*
%
% Improve automatic optimal kernel detection from EBSD data

%% Planned for Next Minor Release
%
% *Grain Boundary Analysis* (Florian Bachmann)
%
% * Compute grain boundary planes.
% * Analyze and visualize the distribution of grain boundary planes.
% * Classify twist / tild grain boundaries.
% 
% *Plotting*: support datacursor for spherical projections, (pole figures,
% inverse pole figure, odf plots) to get coordinate (and function value)
%
%% Assigned to Next Major Release
%
% *Robust Mean Computation*
%
% Find and implement an algorithm that finds under certain conditions the
% true mean orientation for a given set of orientations!
%
% *Bingham Distribution*
%
% compute Fourier coefficients of Bingham ODFs.
%
%% Future
%
% *EBSD Statistics*
%
% Implement results of K. G. v.d. Boogaart dissertation. i.e. allow MTEX to
% answer the following questions:
%
% * is an EBSD data set a random sample of a certain ODF
% * are two EBSD data sets random sample of the same ODF
%
% *Misorientation Analysis*
%
% Allow to compute a misorientation ODF from EBSD data. Therefore, a new
% class MODF is needed which differs from an ordinary ODF by the fact
% that the specimen symmetry is replaced by the crystal symmetry of the
% second phase.
%
% This requires a better find functionality in SO3Grid
%
% * allow volume computation for miss axes
% * allow annotations in misaxes plot
%
% *ODF Analysis*
%
% Provide a function that is able to approximate an ODF by a small number
% of simple components, i.e. unimodal components, and fibres.
%
% *Joined Counts*
%
% Incorporate the results of Müller.
%
% *Grain Simulation*
%
% Allow to simulate grains under certain assumptions. To be used for
% joined counts statistics and ODF -> MODF analysis.
%
% *Voronoi Decomposition of the Orientation Space*
%
% Use the Rodriguez representation to compute a Voronoi neighborhood
% graph of a set of orientations. This can be used for faster searching
% in SO3Grids and for the decomposition of ODFs into components.
%
% *New Class Fibre*
%
% Implement a new class fibre, which can be used for any computations
% involving fibres.
%
% *Minor Improvements*
%
% * EBSD colorcoding
% * fix crystal coordinate system for symmetry 2/m
% * improve template files
% * say explicitly in generic wizard which columns has to
% be specified
% * implement grain/rotate, grain/flipud, grain/fliplr
% * better ODF import / export
% * add kernel names by Matthies
%
%% Supported/Implemented since MTEX 3.3
%
% *Single Grain Analysis*
%
% * Detect polar, oblate and spherical grains.
% * Profiles through grains
%
% *Topological Grain Data Structure* (Florian Bachmann)
%
% The function segment2d should provide a grain class that allows
% answering questions like:
%
% * give me all phase one to phase two grain boundaries
% * give me all grain boundaries between grains with a certain misorientation
%
% Therefore not only the neigboring grains has to be stored in the grain
% object but also the line segment representing the grain boundary.
%
%% Supported/Implemented since MTEX 3.1
%
% *Computation of Material Properties*
%
% Compute various macroscopic material properties for EBSD data and ODFs.
%
%% Supported/Implemented since MTEX 3.*
%
% *Bingham Distribution*
%
% Implement Bingham parameter estimation from EBSD data 
%