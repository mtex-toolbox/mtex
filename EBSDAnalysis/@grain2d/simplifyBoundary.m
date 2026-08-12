function grains = simplifyBoundary(grains,varargin)
% remove boundary vertices that carry no shape information
%
% Syntax
%
%   grains = simplifyBoundary(grains)
%   grains = simplifyBoundary(grains,epsilon)
%
% Description
% Douglas-Peucker simplification of the grain boundaries. A vertex is dropped
% if removing it moves the boundary by less than epsilon, so a straight run
% collapses into a single segment while a corner is kept. On a pixel grid this
% is what turns the staircase into the straight line it approximates.
%
% Junctions stay exactly where they are, so which grains touch, and where, is
% unchanged. The grain polygons are retraced along with the boundary, so the
% grain areas do move - by at most about epsilon times the perimeter. A grain
% too small to survive the tolerance is left uncoarsened rather than collapsed,
% so no grain is ever simplified away.
%
% Input
%  grains  - @grain2d
%  epsilon - tolerance in EBSD units (default: the median segment length over
%            sqrt(2), which is exactly how far a staircase can stray from the
%            straight line it approximates)
%
% Output
%  grains - @grain2d
%
% See also
% grainBoundary/simplify grain2d/reduceBoundary grain2d/refineBoundary grain2d/smoothBoundary

% both boundaries have to be coarsened before either of them may drop a
% vertex the other one still uses, so collect the shared vertices first
protect = sharedBoundaryV(grains);

grains.boundary = simplify(grains.boundary,varargin{:},'protect',protect);
grains.innerBoundary = simplify(grains.innerBoundary,varargin{:},'protect',protect);

% simplify only stops referencing vertices, it never appends any, so the
% existing ids stay valid and allV needs no propagation - grains.V filters by
% the poly loops and drops the orphans by itself
grains = updatePoly(grains);
