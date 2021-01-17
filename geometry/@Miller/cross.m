function m = cross(m1,m2)
% pointwise cross product of two vector3d
%
% Syntax
%   v = cross(v1,v2)
%
% Input
%  v1,v2 - @vector3d
%
% Output
%  v - @vector3d

m = cross@vector3d(m1,m2);

% switch from recirprocal to direct and vice verca
m.dispStyle = MillerConvention(-MillerConvention(m.dispStyle));
