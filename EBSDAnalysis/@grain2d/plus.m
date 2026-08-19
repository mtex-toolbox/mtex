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

% a numeric shift is added to each of x, y and z separately, so a 1 x 2 row
% implicitly expands the N x 1 coordinate arrays into N x 2 and silently
% returns a nonsensical object instead of a translation
if ~isa(shift,'vector3d')
  error('MTEX:shift:invalidShift','Grains can only be shifted by a vector3d.');
end

grains.allV = grains.allV + shift;
