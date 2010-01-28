function a = rotaxis(o)
% rotational axis of the orientation
%% Syntax
%  v = rotaxis(o)
%
%% Input
%  q - @orientation
%
%% Output
%  v - @vector3d

q = getFundamentalRegion(o);
a = rotaxis(q);
