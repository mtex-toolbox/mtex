function v = rotate(m,rot,varargin)
% rotate crystal directions
%
% Input
%  m - @Miller
%  ori - @orientation
%
% Output
%  v - vector3d
%

% the frame fit is checked in vector3d/rotate via orientation/fitFrame -
% the symmetries need not agree, only the frames have to fit
v = rotate@vector3d(m,rot);
