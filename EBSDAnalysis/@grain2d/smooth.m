function grains = smooth(grains,varargin)
% constraint laplacian smoothing of grain boundaries
%
% Deprecated. Renamed to grain2d/smoothBoundary. Note that EBSD/smooth means
% something else entirely - it denoises orientations, not geometry.
%
% It is forwarded to smoothBoundary with a <laplaceFilter.html
% |laplaceFilter|> built from the same arguments and without the
% simplification, which would change the number of boundary segments.
%
% Call <grain2d.smoothBoundary.html |smoothBoundary|> directly to simplify the
% boundary as well, and to choose the smoothing algorithm.
%
% See also
% grain2d/smoothBoundary grain2d/simplifyBoundary laplaceFilter

warning(['grains.smooth has been renamed to grains.smoothBoundary, which ' ...
  'additionally simplifies the boundary after smoothing it - see the help ' ...
  'of grain2d/smooth.']);

grains = grains.smoothBoundary(laplaceFilter(varargin{:}),varargin{:},'noSimplify');
