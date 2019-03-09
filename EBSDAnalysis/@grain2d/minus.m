function grains = minus(grains,xy)
% shift grains in x/y direction
%
% Syntax
%
%   % shift in x direction
%   grains = grains - [100,0] 
%
% Input
%  grains- @grain2d
%  xy - x and y coordinates of the shift
%
% Output
%  grains - @grain2d

grains = grains + (-xy);