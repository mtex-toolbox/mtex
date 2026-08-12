function grains = minus(grains,shift)
% shift grains in x/y direction
%
% Syntax
%
%   % shift in x direction
%   grains = grains - vector3d(100,200,0)
%
% Input
%  grains- @grain2d
%  shift - @vector3d, coordinates of the shift
%
% Output
%  grains - @grain2d

grains = grains + (-shift);
