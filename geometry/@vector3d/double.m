function [x,y,z] = double(v)
% converts vector3d to double
% Input
%  v - @vector3d
% Output
%  x, y, z - double

if nargout == 3
  x = v.x;
  y = v.y;
  z = v.z;
elseif nargout == 1
  x = cat(length(size(v.x))+1,v.x,v.y,v.z);
elseif nargout == 0
  x = cat(length(size(v.x))+1,v.x,v.y,v.z);
end