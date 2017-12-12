function d = det(v1,v2,v3)
% pointwise determinant or triple product of three vector3d
%
% Input
%  v1,v2,v3 - @vector3d
% Output
%  d - double

d = dot(v1,cross(v2,v3));
