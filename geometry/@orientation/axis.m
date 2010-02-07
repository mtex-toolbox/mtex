function a = axis(o)
% rotational axis of the orientation
%% Syntax
%  v = axis(o)
%
%% Input
%  q - @orientation
%
%% Output
%  v - @vector3d

q = getFundamentalRegion(o);
a = axis(q);
