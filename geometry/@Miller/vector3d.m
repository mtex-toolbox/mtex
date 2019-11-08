function v = vector3d(m)
% transform Miller to vector3d
%
% Syntax
%   v = vector3d(m)
%

v = vector3d(m.x,m.y,m.z);
v.antipodal = m.antipodal;
v.opt = m.opt;
end