function v = cross_outer(v1,v2)
% pointwise cross product of two vector3d
%
% Input
%  v1,v2 - @vector3d
%
% Output
%  v - @vector3d
%

% Calculate cross product
v = v1;
v.x = v1.y(:) * v2.z(:).' -v1.z(:) * v2.y(:).';
v.y = v1.z(:) * v2.x(:).' -v1.x(:) * v2.z(:).';
v.z = v1.x(:) * v2.y(:).' -v1.y(:) * v2.x(:).';

v.isNormalized = false;