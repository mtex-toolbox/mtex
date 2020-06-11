function lA = longAxis(grains,varargin)
% long axis of a grain 
%
% the long axis is the direction of the largest
% <grain2d.principalComponents.html,principal component> of a grain
%
% Syntax
%   lA = grains.longAxis
%
% Input
%  grains - @grain2d
%
% Output
%  lA - @vector3d direction of the longest elongation
%
% See also
% grain2d/principalComponents

omega = principalComponents(grains);

lA = vector3d.byPolar(pi/2,omega,'antipodal');

