function p = dot(v1,v2)
% pointwise dot product
%% Input
%  v1, v2 - @vector3d
%% Output
%  @vector3d

p = v1.x .* v2.x + v1.y .* v2.y + v1.z .* v2.z;
