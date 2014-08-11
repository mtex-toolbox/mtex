function  peri = perimeter(grains,varargin)
% calculates the perimeter of a grain, with holes
%
% Input
%  p - @grain2d
%
% Output
%  peri    - perimeter
%
% Syntax
%   p = perimeter(grains) - 
%
% See also
% grain2d/equivalentperimeter

hasHole = grains.hasHole;
peri = zeros(size(grains));

polyPeri = @(ind) sum(sqrt(sum(diff(grains.V(ind,:)).^2,2)));
peri(~hasHole) = cellfun(polyPeri,...
  grains.poly(~hasHole));

peri(hasHole) = cellfun(@(c) sum(cellfun(polyPeri,c)),...
  grains.poly(hasHole));

