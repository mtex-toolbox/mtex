function A = area(grains,varargin)
% calculates the area of a list of grains
%
% Input
%  grains - @grain2d
%
% Output
%  A  - list of areas (in measurement units)
%

A = zeros(length(grains),1);
poly = grains.poly;

if isscalar(grains)   % 3d algorithm

  % signed area
  for i=1:length(grains)
    V = grains.allV(poly{i});
    A(i) = -dot(grains.N, sum(cross(V(2:end),V(1:end-1)))) / 2;
  end
else 
  
  V = grains.rot2Plane .* grains.allV;
  Vx = V.x;
  Vy = V.y;

  for ig = 1:length(poly)
    A(ig) = polySgnArea(Vx(poly{ig}),Vy(poly{ig}));
  end

end