function grains = smooth(grains,varargin)
% constraint laplacian smoothing of grain boundaries
%
% Deprecated. Renamed to grain2d/smoothBoundary. Note that EBSD/smooth means
% something else entirely - it denoises orientations, not geometry.
%
% smoothBoundary does more than smooth ever did: it removes the pixel
% staircase with simplifyBoundary and resamples with refineBoundary before
% smoothing at all. Those two steps change the number of boundary segments and
% move the grain areas, so a script written against smooth would silently get
% different numbers out. It is therefore forwarded with both of them switched
% off, which is exactly what smooth used to compute.
%
% Call <grain2d.smoothBoundary.html |smoothBoundary|> directly to get the full
% three steps, and to choose the smoothing algorithm.
%
% See also
% grain2d/smoothBoundary grain2d/simplifyBoundary grain2d/refineBoundary

warning(['grains.smooth has been renamed to grains.smoothBoundary, which ' ...
  'additionally removes the pixel staircase before smoothing it. You are ' ...
  'getting the old behaviour - see the help of grain2d/smooth.']);

grains = grains.smoothBoundary(varargin{:},'noSimplify','noRefine');
