function grains = plus(grains,shift)
% shift grains in x/y direction
%
% Syntax
%
%   % shift in x direction
%   grains = grains + vector3d(100,200,0) 
%
% Input
%  grains- @grain2d
%  shift - @vector3d, coordinates of the shift
%
% Output
%  grains - @grain2d

if isa(shift,'grain2d'), [shift,grains] = deal(grains,shift); end

if ~isa(shift,'vector3d')
  shift = vector3d(shift(:,1),shift(:,2),0);
end

grains.allV = grains.allV + shift;
