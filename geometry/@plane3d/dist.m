function d = dist(plane, v)
% distance plane / point or plane / plane
%
% Syntax
%   d = dist(planes,points)
%
%   d = dist(planesA,planesB)
%
% Input
%
% See also
% 

if isa(v,'vector3d')

  d = dot(plane.N,v) - plane.d;
  
elseif isa(v,'plane3d')

  lambda = dot(plane.N,v.N);
  lambda = lambda .* (abs(lambda)==1);
  d = plane.d - v.d .* lambda;
  
end