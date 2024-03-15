function d = fullDouble(v)
% converts vector3d to double
% Input
%  v - @vector3d
% Output
%  x, y, z - double

d = cat(length(size(v.x))+1,v.x,v.y,v.z);
