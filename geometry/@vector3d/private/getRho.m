function rh = rho(v)
% cartesian to spherical coordinates
%
% Input
%  v - @vector3d
% Output
%  theta  - polar angle

rh = atan2(v.y,v.x);

