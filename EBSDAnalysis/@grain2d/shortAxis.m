function sA = shortAxis(grains,varargin)
% short axis of a grain 
%
% the long axis is the direction of the smallest
% <grain2d.principalComponents.html,principal component> of a grain
%
% Syntax
%   sA = grains.shortAxis
%
% Input
%  grains - @grain2d
%
% Output
%  sA - @vector3d direction of the shortest elongation
%
% See also
% grain2d/principalComponents

[~,sA] = principalComponents(grains);
