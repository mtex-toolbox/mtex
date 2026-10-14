function grains = refineBoundary(grains,varargin)
% refine grain boundary
%
% Syntax
%
%   grains = refineBoundary(grains)
%   grains = refineBoundary(grains,delta)
%
% Description
% Splits every boundary segment into pieces of about length delta. The
% existing vertices stay where they are, so the boundaries keep their shape
% and their length. This is what keeps a coarsened boundary from collapsing
% under the smoothing that follows: a simplifyBoundary leaves a curve as a
% handful of long chords, and a Laplacian run on those few vertices cuts the
% corners off the polygon they form.
%
% Input
%  grains - @grain2d
%  delta  - new segment length (default: half the median segment length)
%
% Output
%  grains - @grain2d
%
% See also
% grainBoundary/refine grain2d/simplifyBoundary grain2d/reduceBoundary grain2d/smoothBoundary

if nargin > 1 && isnumeric(varargin{1})
  delta = varargin{1};
else
  delta = median(grains.boundary.segLength) / 2;
end

% refine appends the new vertices, so the existing ids stay valid - but the
% extended list has to reach the other boundary before it is refined in turn
grains.boundary = refine(grains.boundary,delta);
grains.allV = grains.boundary.allV;

grains.innerBoundary = refine(grains.innerBoundary,delta);
grains.allV = grains.innerBoundary.allV;

grains = updatePoly(grains);
