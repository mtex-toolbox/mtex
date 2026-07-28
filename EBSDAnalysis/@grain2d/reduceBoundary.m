function grains = reduceBoundary(grains,varargin)
% coarsen the grain boundaries by keeping only every n-th vertex
%
% Syntax
%
%   grains = reduceBoundary(grains)
%   grains = reduceBoundary(grains,n)
%
% Description
% Dissolves boundary vertices regardless of shape, keeping every n-th one
% along each chain. Junctions stay exactly where they are, so which grains
% touch, and where, is unchanged, and the grain polygons are retraced along
% with the boundary.
%
% This is the blunt instrument - it thins a straight run and a corner alike.
% Prefer simplifyBoundary, which spends its vertices where the shape needs
% them.
%
% Input
%  grains - @grain2d
%  n      - keep every n-th vertex (default 2)
%
% Output
%  grains - @grain2d
%
% See also
% grainBoundary/reduce grain2d/simplifyBoundary grain2d/refineBoundary

% both boundaries have to be coarsened before either of them may drop a
% vertex the other one still uses, so collect the shared vertices first
protect = sharedBoundaryV(grains);

grains.boundary = reduce(grains.boundary,varargin{:},'protect',protect);
grains.innerBoundary = reduce(grains.innerBoundary,varargin{:},'protect',protect);

% reduce only stops referencing vertices, it never appends any, so the
% existing ids stay valid and allV needs no propagation
grains = updatePoly(grains);
