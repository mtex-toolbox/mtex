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

switch symmetry.pointGroups(cs.id).properId
  case {1, 3, 6} % 1, 211, 121
    rot = quaternion(cs);
  case {9, 17,25, 33} % 112, 3, 4, 6
    rot = idquaternion;
  case {12, 28,36} % 222, 422, 622
    rot = symAxis(a1,2);
  case 19 % 321
    rot = symAxis(a1,2);
  case 22 % 312
    rot = symAxis(m,2);
  case 41 % 23
    rot = symAxis(lllaxis,3) * symAxis(a1,2);
  case 43 % 23
    rot = symAxis(lllaxis,3) * symAxis(ll0axis,2);
end


end
