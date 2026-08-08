function grains = smooth(grains,varargin)
% constraint laplacian smoothing of grain boundaries
%
% Deprecated. Renamed to grain2d/smoothBoundary, which also removes the pixel
% staircase before smoothing it. Note that EBSD/smooth means something else
% entirely - it denoises orientations, not geometry.
%
% See also
% grain2d/smoothBoundary

warning('grains.smooth has been renamed to grains.smoothBoundary');

grains = grains.smoothBoundary(varargin{:});
