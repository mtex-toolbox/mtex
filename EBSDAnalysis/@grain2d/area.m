function A = area(grains,varargin)
% calculates the area of a list of grains
%
% Input
%  grains - @grain2d
%
% Output
%  A  - list of areas (in measurement units)
%

% signed Area
A = zeros(length(grains),1);
for i=1:length(grains)

  V = grains.V(grains.poly{i});
  A(i) = dot(grains.N, sum(cross(V(2:end),V(1:end-1)))) / 2;

end
