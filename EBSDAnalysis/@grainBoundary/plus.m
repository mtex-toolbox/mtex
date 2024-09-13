function gB = plus(gB,xy)
% shift grains in x/y direction
%
% Syntax
%
%   % shift in x direction
%   gB = gB + [100,0] 
%
% Input
%  gB - @grainBoundary
%  xy - x and y coordinates of the shift
%
% Output
%  gB - @grainBoundary

if isa(xy,'grainBoundary'), [xy,gB] = deal(gB,xy); end
if isa(xy,'vector3d'), xy = [xy.x,xy.y]; end

gB.allV = gB.allV + repmat(xy,size(gB.allV,1),1);
