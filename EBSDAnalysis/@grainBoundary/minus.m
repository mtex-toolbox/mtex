function gB = minus(gB,xy)
% shift grains in x/y direction
%
% Syntax
%
%   % shift in x direction
%   gB = gB - [100,0] 
%
% Input
%  gB - @grainBoundary
%  xy - x and y coordinates of the shift
%
% Output
%  gB - @grainBoundary

gB = gB + (-xy);
