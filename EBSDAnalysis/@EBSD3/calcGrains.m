function [grains,grainId,mis2mean] = calcGrains(ebsd,varargin)
% grains reconstruction from 2d EBSD data
%
% Syntax
%
%   [grains, ebsd.grainId] = calcGrains(ebsd,'angle',10*degree)
%
%   % reconstruction low and high angle grain boundaries
%   lagb = 2*degree;
%   hagb = 10*degree;
%   grains = calcGrains(ebsd,'angle',[hagb lagb])
%
%   % allow grains to grow into not indexed regions
%   grains = calcGrains(ebsd('indexed'),'angle',10*degree) 
%
%   % do not allow grains to grow into not indexed regions
%   grains = calcGrains(ebsd,'unitCell')
%
%   % follow non convex outer boundary
%   grains = calcGrains(ebsd,'boundary','tight')
%
%   % specify phase dependent thresholds
%   % thresholds follow the same order as ebsd.CSList and should have the same length
%   grains = calcGrains(ebsd,'angle',{angl_1 angle_2 angle_3})
%
%   % Markovian clustering algorithm
%   p = 1.5;    % inflation power (default = 1.4)
%   maxIt = 10; % number of iterations (default = 4)
%   delta = 5*degree % variance of the threshold angle
%   grains = calcGrains(ebsd,'method','mcl',[p maxIt],'soft',[angle delta])
%
% Input
%  ebsd   - @EBSD
%
% Output
%  grains       - @grain2d
%  ebsd.grainId - grainId of each pixel
%
% Options
%  threshold, angle - array of threshold angles per phase of mis/disorientation in radians
%  boundary         - bounds the spatial domain ('convexhull', 'tight')
%  maxDist          - maximum distance to for two pixels to be in one grain (default inf)
%  fmc       - fast multiscale clustering method
%  mcl       - markovian clustering algorithm
%  custom    - use a custom property for grain separation
%
% Flags
%  unitCell - omit Voronoi decomposition and treat a unitcell lattice
%  qhull    - use qHull for the Voronoi decomposition
%
% References
%
% * F.Bachmann, R. Hielscher, H. Schaeben, Grain detection from 2d and 3d
% EBSD data - Specification of the MTEX algorithm: Ultramicroscopy, 111,
% 1720-1733, 2011
%
% * C. McMahon, B. Soe, A. Loeb, A. Vemulkar, M. Ferry, L. Bassman,
%   Boundary identification in EBSD data with a generalization of fast
%   multiscale clustering, <https://doi.org/10.1016/j.ultramic.2013.04.009
%   Ultramicroscopy, 2013, 133:16-25>.
%
% See also
% GrainReconstruction GrainReconstructionAdvanced

error('not yet implemented')

