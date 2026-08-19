function gB = minus(gB,v)
% shift grain boundaries in x/y direction
%
% Syntax
%
%   % shift in x direction
%   gB = gB - vector3d(100,200,0)
%
% Input
%  gB - @grainBoundary
%  v  - @vector3d, coordinates of the shift
%
% Output
%  gB - @grainBoundary

gB = gB + (-v);
