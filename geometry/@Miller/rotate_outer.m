function v = rotate_outer(m,rot,varargin)
% rotate crystal directions
%
% Input
%  m - @Miller
%  ori - @orientation
%
% Output
%  v - vector3d
%

% ensure that the rotations have the right reference frame
if isa(rot,'orientation') && nargin == 2
  rot = m.CS.ensureCS(rot);
end

v = rotate_outer@vector3d(m,rot);
