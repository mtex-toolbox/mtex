function s = surface(grains, varargin)
% grain surface area
%

allArea = grains.boundary.area;
allArea = [allArea;allArea];

isIndexed = ismember(grains.boundary.grainId,grains.id);

s = accumarray(grains.boundary.grainId(isIndexed), ...
  allArea(isIndexed),[length(grains),1]);

