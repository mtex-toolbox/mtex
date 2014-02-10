function th = theta(v)
% cartesian to spherical coordinates
%
% Input
%  v - @vector3d
% Output
%  theta  - polar angle

th = acos(v.z./v.norm);

