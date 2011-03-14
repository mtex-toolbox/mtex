function [grains,ebsd] = calcGrains(ebsd,varargin)
% 2d and 3d grain detection for EBSD data
%
%% Syntax
% [grains ebsd] = calcGrains(ebsd,'angle',10*degree)
%
%% Input
%  ebsd   - @EBSD
%
%% Output
%  grains  - @grain
%  ebsd    - connected @EBSD data
%
%% Options
%  angle         - array of threshold angles per phase of mis/disorientation in radians
%  augmentation  - 'cube'/ 'cubeI' / 'sphere'
%  angletype     - misorientation (default)
%  distance      - maximum distance allowed between neighboured measurments
%
%% Flags
%  unitcell     - omit voronoi decomposition and treat a unitcell lattice
%
%% See also
% grain/grain ebsd/segment2d ebsd/segment3d


%% segmentation
% prepare data

dim = size(ebsd(1).X,2);

if dim == 3
    
  [grains, ebsd] = segment3d(ebsd,varargin{:});
  
else
  
  [grains, ebsd] = segment2d(ebsd,varargin{:});
  
end
