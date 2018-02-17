function A = area(grains,varargin)
% calculates the area of a list of grains
%
% Input
%  grains - @grain2d
%
% Output
%  A  - list of areas (in measurement units)
%

A = zeros(length(grains.poly),1);

poly = grains.poly;
V = grains.V;

for ig = 1:length(poly)
  A(ig) = polySgnArea(V(poly{ig},1),V(poly{ig},2));
end
