function grains = refineBoundary(grains,varargin)
% refine grain boundary
%
% Syntax
%
%   grains = refineBoundary(grains)
%   grains = refineBoundary(grains,delta)
%
% Description
% Resamples the grain boundaries at a constant spacing, so that the vertices
% are spread evenly along each boundary instead of sitting on the corners of
% the pixel grid. Junctions stay exactly where they are. This is the step
% that lets grain2d/smoothBoundary produce a genuinely smooth boundary rather
% than a finer staircase.
%
% It is also what keeps a coarsened boundary from collapsing under the
% smoothing that follows. A simplifyBoundary leaves a curve as a handful of
% long chords, and a Laplacian run on those few, unevenly spaced vertices cuts
% the corners off the polygon they form - a circle of 15 pixel radius loses
% 14% of its area over 25 iterations. Resampling first brings that back to
% 0.4%.
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

% a vertex shared by the inner and the outer boundary is of degree two to either
protect = sharedBoundaryV(grains);

% refine appends the new vertices, so the existing ids stay valid - but the
% extended list has to reach the other boundary before it is refined in turn
grains.boundary = refine(grains.boundary,delta,'protect',protect);
grains.allV = grains.boundary.allV;

grains.innerBoundary = refine(grains.innerBoundary,delta,'protect',protect);
grains.allV = grains.innerBoundary.allV;

grains = updatePoly(grains);
