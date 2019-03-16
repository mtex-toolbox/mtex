function grains = plus(grains,xy)
% shift grains in x/y direction
%
% Syntax
%
%   % shift in x direction
%   grains = grains + [100,0] 
%
% Input
%  grains- @grain2d
%  xy - x and y coordinates of the shift
%
% Output
%  grains - @grain2d

if isa(xy,'grain2d'), [xy,grains] = deal(grains,xy); end

if isa(xy,'vector3d'), xy = [xy.x,xy.y]; end

grains.V = grains.V + repmat(xy,size(grains.V,1),1);
