function [u,v] = gridCoordinates(mg,pos)
% where a position sits in grid coordinates, 0 based and fractional
%
% u counts rows and v counts columns, so pixel (i,j) is at u = i-1, v = j-1.
% Valid because d1 and d2 are perpendicular, which the constructor enforces
% - the two coordinates then separate and each is one projection.
%
% Syntax
%
%   [u,v] = gridCoordinates(mg,pos)
%
% Input
%  mg  - @mapImage
%  pos - @vector3d
%
% Output
%  u, v - fractional row and column coordinate, 0 based
%
% See also
% mapImage/pos2ind mapImage/interp

r = pos - mg.origin;

u = dot(r,mg.d1) ./ dot(mg.d1,mg.d1);
v = dot(r,mg.d2) ./ dot(mg.d2,mg.d2);

end
