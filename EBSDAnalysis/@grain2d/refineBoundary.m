function grains = refineBoundary(grains,varargin)
% refine grain boundary
%
% Syntax
%
%   grains = refineBoundary(grains)
%   grains = refineBoundary(grains,segLength)
%
% Description
% Resamples the grain boundaries at a constant spacing, so that the vertices
% are spread evenly along each boundary instead of sitting on the corners of
% the pixel grid. Junctions stay exactly where they are. This is the step
% that lets grain2d/smooth produce a genuinely smooth boundary rather than a
% finer staircase.
%
% Only grains.boundary is resampled. Since refine keeps just the junctions at
% both ends of a chain and mints fresh vertices in between, a vertex where the
% inner boundary ends on the outer one does not survive - grains.innerBoundary
% is left as it was and may hang off a vertex the outer boundary no longer
% visits. Unlike simplifyBoundary and reduceBoundary, which protect it.
%
% Input
%  grains - @grain2d
%  delta  - new segment length (default: half the median segment length)
%
% Output
%  grains - @grain2d
%
% See also
% grainBoundary/refine grain2d/simplifyBoundary grain2d/reduceBoundary grain2d/smooth

if nargin > 1 && isnumeric(varargin{1})
  delta = varargin{1};
else
  delta = median(grains.boundary.segLength) / 2;
end

grains.boundary = refine(grains.boundary,delta);

% refine appends the new vertices, so the existing ids stay valid - this
% just propagates the extended list to the inner boundary as well
grains.allV = grains.boundary.allV;

grains = updatePoly(grains);
