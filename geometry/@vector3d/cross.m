function v = cross(v1,v2)
% pointwise cross product of two vector3d
%% Input
%  v1,v2 - @vector3d
%% Output
%  @vector3d

% Calculate cross product
cpx = v1.y.*v2.z-v1.z.*v2.y;
cpy = v1.z.*v2.x-v1.x.*v2.z;
cpz = v1.x.*v2.y-v1.y.*v2.x;

v = vector3d(cpx,cpy,cpz);
