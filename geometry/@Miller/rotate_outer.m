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

% the frame fit is checked in vector3d/rotate_outer via
% orientation/fitFrame - the symmetries need not agree, only the frames
% have to fit
v = rotate_outer@vector3d(m,rot);
