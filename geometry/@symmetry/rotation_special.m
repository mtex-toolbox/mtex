function rot = rotation_special(cs,varargin)
% returns symmetry elements different from rotation about c-axis
%
% Input:
%  cs - @symmetry
%
% Output
%  q   - symmetry elements other then rotation about the z--axis
%  rho - position of the mirroring plane

ll0axis = vector3d(1,1,0);
lllaxis = vector3d(1,1,1);

if isa(cs,'crystalSymmetry')
  a1 = cs.axes(1);
  a2 = cs.axes(2);
  m = a1 - a2;
else
  a1 = xvector;
end

switch symmetry.pointGroups(cs.id).LaueId
  case {2, 5, 8} % 1, 211, 121
    rot = quaternion(cs.rot(~cs.rot.i));
  case {11, 18, 27, 35} % 112, 3, 4, 6
    rot = quaternion.id;
  case {16, 32, 40} % 222, 422, 622
    rot = symAxis(a1,2);
  case 21 % 321
    rot = symAxis(a1,2);
  case 24 % 312
    rot = symAxis(m,2);
  case 42 % 23
    rot = symAxis(lllaxis,3) * symAxis(a1,2);
  case 45 % 432
    rot = symAxis(lllaxis,3) * symAxis(ll0axis,2);
end

end
