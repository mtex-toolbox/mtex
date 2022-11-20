function [x,y,z] = double(v)
% converts vector3d to double
% Input
%  v - @vector3d
% Output
%  x, y, z - double

if nargout >= 2
  x = v.x;
  y = v.y;
  z = v.z;
else
  x = [v.x(:),v.y(:),v.z(:)].';
end