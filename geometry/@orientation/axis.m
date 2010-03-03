function a = axis(o)
% rotational axis of the orientation
%% Syntax
%  v = axis(o)
%
%% Input
%  o - @orientation
%
%% Output
%  v - @vector3d

o = project2FundamentalRegion(o);
a = axis(o.rotation);
