function s = surface(grains, varargin)
% grain surface area in µm²
%
% Input
%  grains - @grain3d
%
% Output
%  s - surface are in µm² 
%
% See also
% grain3d/volume

allArea = grains.boundary.area;
allArea = [allArea;allArea];

isIndexed = ismember(grains.boundary.grainId,grains.id);

s = accumarray(grains.boundary.grainId(isIndexed), ...
  allArea(isIndexed));

s = s(grains.id);

