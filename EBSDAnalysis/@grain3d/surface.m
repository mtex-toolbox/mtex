function s = surface(grains, varargin)

allArea = grains.boundary.area;
allArea = [allArea;allArea];

isIndexed = grains.boundary.grainId > 0;

s = accumarray(grains.boundary.grainId(isIndexed), ...
  allArea(isIndexed),[length(grains),1]);

