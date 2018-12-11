function rot = map(varargin)
% define rotations by pairs of vectors
%
% Description
% Define a rotation that maps |u1| onto |v1| and |u2| onto |v2|
%
% Syntax
%   rot = rotation(u1,v1)
%   rot = rotation(u1,v1,u2,v2)
%
% Input
%  u1, v1, u2, v2 - @vector3d
%
% Output
%  rot - @rotation
%
% See also
% rotation_index rotation/byMiller rotation/byAxisAngle
% rotation/byEuler

if nargin == 4
  quat = vec42quat(varargin{1:4});  
else
  quat = hr2quat(varargin{1:2});
end

rot = rotation(quat);

end
