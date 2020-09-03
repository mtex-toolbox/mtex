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


switch m1.dispStyle
  case 'hkl'
    m.dispStyle = 'uvw';
  case 'hkil'
    m.dispStyle = 'UVTW';
  case 'uvw'
    m.dispStyle = 'hkl';
  case 'UVTW'
    m.dispStyle = 'hkil';
end
